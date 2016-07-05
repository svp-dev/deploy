## slc.mk: this file is part of the SL tool chain installer.
## 
## Copyright (C) 2010,2011,2012 The SL project.
##
## This program is free software; you can redistribute it and/or
## modify it under the terms of the GNU General Public License
## as published by the Free Software Foundation; either version 2
## of the License, or (at your option) any later version.
##
## The complete GNU General Public Licence Notice can be found as the
## `COPYING' file in the root directory.
##

SLC_SRC = $(SRCBASE)/sl-core-$(SLC_VERSION)
SLC_BUILD = $(BLDBASE)/sl-core-$(SLC_VERSION)

SLC_CFG_TARGETS = $(SLC_BUILD)/configure_done
SLC_BUILD_TARGETS = $(SLC_BUILD)/build_done
SLC_INST_TARGETS = $(SLDIR)/.slc-installed

SLC_TARGET_SELECT =

if ENABLE_MTALPHA
SLC_TARGET_SELECT += --enable-mtalpha
else
SLC_TARGET_SELECT += --disable-mtalpha
endif
if ENABLE_MTSPARC
SLC_TARGET_SELECT += --enable-mtsparc
else
SLC_TARGET_SELECT += --disable-mtsparc
endif
if ENABLE_MIPSEL
SLC_TARGET_SELECT += --enable-mipsel
else
SLC_TARGET_SELECT += --disable-mipsel
endif
if ENABLE_LEON2MT
SLC_TARGET_SELECT += --enable-leon2mt
else
SLC_TARGET_SELECT += --disable-leon2mt
endif
if ENABLE_PTL
SLC_TARGET_SELECT += --enable-ptl --enable-hlsim --with-ptl-includedir=$(SLDIR)/include --with-ptl-libdir=$(SLDIR)/lib
else
SLC_TARGET_SELECT += --disable-ptl --disable-hlsim 
endif

.PRECIOUS: $(SLC_ARCHIVE) $(SLC_CFG_TARGETS) $(SLC_BUILD_TARGETS) $(SLC_INST_TARGETS)

slc-fetch: $(SLC_ARCHIVE) ; $(RULE_DONE)
slc-configure: $(SLC_CFG_TARGETS) ; $(RULE_DONE)
slc-build: $(SLC_BUILD_TARGETS) ; $(RULE_DONE)
slc-install: $(SLC_INST_TARGETS) ; $(RULE_DONE)

$(SLC_SRC)/configure: $(SLC_ARCHIVE)
	rm -f $@
	$(UNTAR) $(SRCBASE) $(SLC_ARCHIVE)
	touch $@

$(SLC_BUILD)/configure_done: $(SLC_SRC)/configure $(REQCURRENT) \
		$(BINUTILS_INST_TARGETS) \
		$(GCC_INST_TARGETS) \
		$(BINUTILSNG_INST_TARGETS) \
		$(GCC5_INST_TARGETS) \
		$(MGGCC_INST_TARGETS) \
		$(M4_INST_TARGETS) \
		$(MGSIM_INST_TARGETS) \
	        $(HLSIM_INST_TARGETS)
	rm -f $@
	$(MKDIR_P) $(SLC_BUILD)
	SRC=$$($(am__cd) $(SLC_SRC) && pwd) && \
	   $(am__cd) $(SLC_BUILD) && \
	   PATH=$(SLCURRENT)/bin:$(REQCURRENT)/bin:$$PATH \
	     $$SRC/configure --prefix=$(SLDIR) \
			  CC="$(CC)" CXX="$(CXX)" \
	                  CPPFLAGS="-I$(REQCURRENT)/include $(CPPFLAGS)" \
			  CFLAGS="$(CFLAGS)" CXXFLAGS="$(CXXFLAGS)" \
	                  LDFLAGS="-L$(REQCURRENT)/lib $(LDFLAGS)" \
	                  $(SLC_TARGET_SELECT)
	touch $@

$(SLC_BUILD)/build_done: $(SLC_BUILD)/configure_done
	rm -f $@
	$(am__cd) $(SLC_BUILD) && $(MAKE) all
	touch $@

$(SLDIR)/.slc-installed: $(SLC_BUILD)/build_done
	rm -f $@
	$(MKDIR_P) $(SLDIR)
	$(am__cd) $(SLC_BUILD) && $(MAKE) install
	touch $@
