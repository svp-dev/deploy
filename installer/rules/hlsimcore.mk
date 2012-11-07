## hlsimcore.mk: this file is part of the SL tool chain installer.
## 
## Copyright (C) 2011,2012 The SL project.
##
## This program is free software; you can redistribute it and/or
## modify it under the terms of the GNU General Public License
## as published by the Free Software Foundation; either version 2
## of the License, or (at your option) any later version.
##
## The complete GNU General Public Licence Notice can be found as the
## `COPYING' file in the root directory.
##

HLSIM_SRC = $(SRCBASE)/hlsim-core-$(HLSIM_VERSION)
HLSIM_BUILD = $(BLDBASE)/hlsim-core-$(HLSIM_VERSION)

if ENABLE_PTL
HLSIM_TARGETS = ptl-opt ptl-dbg
else 
HLSIM_TARGETS =
endif

HLSIM_CFG_TARGETS = $(foreach T,$(HLSIM_TARGETS),$(HLSIM_BUILD)-$(T)/configure_done)
HLSIM_BUILD_TARGETS = $(foreach T,$(HLSIM_TARGETS),$(HLSIM_BUILD)-$(T)/build_done)
HLSIM_CHECK_TARGETS = $(foreach T,$(HLSIM_TARGETS),$(HLSIM_BUILD)-$(T)/check_done)
HLSIM_INST_TARGETS = $(foreach T,$(HLSIM_TARGETS),$(SLDIR)/.hlsim-core-installed-$(T))

.PRECIOUS: $(HLSIM_ARCHIVE) $(HLSIM_CFG_TARGETS) $(HLSIM_BUILD_TARGETS) $(HLSIM_CHECK_TARGETS) $(HLSIM_INST_TARGETS)

hlsim-fetch: $(HLSIM_ARCHIVE) ; $(RULE_DONE)
hlsim-configure: $(HLSIM_CFG_TARGETS) ; $(RULE_DONE)
hlsim-build: $(HLSIM_CHECK_TARGETS) ; $(RULE_DONE)
hlsim-install: $(HLSIM_INST_TARGETS) ; $(RULE_DONE)

$(HLSIM_SRC)/configure: $(HLSIM_ARCHIVE)
	rm -f $@
	$(UNTAR) $(SRCBASE) $(HLSIM_ARCHIVE)
	touch $@

$(HLSIM_BUILD)-%/configure_done: $(HLSIM_SRC)/configure $(PTL_INST_TARGETS)
	rm -f $@
	$(MKDIR_P) $(HLSIM_BUILD)-$*
	SRC=$$($(am__cd) $(HLSIM_SRC) && pwd) && \
	   $(am__cd) $(HLSIM_BUILD)-$* && \
	   $$SRC/configure --includedir="$(SLDIR)/include/$*" --libdir="$(SLDIR)/lib/$*" \
			  CC="$(CC)" CXX="$(CXX)" \
	                  CPPFLAGS="$(CPPFLAGS)" \
			  CFLAGS="$(CFLAGS)" CXXFLAGS="$(CXXFLAGS)" \
	                  LDFLAGS="$(LDFLAGS)" \
	                   --with-ptl-includedir="$(SLDIR)/include/$*" --with-ptl-libdir="$(SLDIR)/lib/$*"
	$(am__cd) $(HLSIM_BUILD)-$* && $(MAKE) clean
	touch $@

$(HLSIM_BUILD)-%/build_done: $(HLSIM_BUILD)-%/configure_done
	rm -f $@
	$(am__cd) $(HLSIM_BUILD)-$* && $(MAKE) all
	touch $@

$(HLSIM_BUILD)-%/check_done: $(HLSIM_BUILD)-%/build_done
	rm -f $@
	$(am__cd) $(HLSIM_BUILD)-$* && $(MAKE) check
	touch $@

$(SLDIR)/.hlsim-core-installed-%: $(HLSIM_BUILD)-%/check_done
	rm -f $@
	$(MKDIR_P) $(SLDIR)
	$(am__cd) $(HLSIM_BUILD)-$* && $(MAKE) install
	touch $@
