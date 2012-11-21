## binutils.mk: this file is part of the SL tool chain installer.
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

BINUTILS_SRC = $(SRCBASE)/binutils-$(BINUTILS_VERSION)
BINUTILS_BUILD = $(BLDBASE)/binutils-$(BINUTILS_VERSION)
BINUTILS_TARGETS = 
if ENABLE_MTALPHA
BINUTILS_TARGETS += mtalpha-linux-gnu
endif
if ENABLE_MTSPARC
BINUTILS_TARGETS += mtsparc-linux-gnu
endif
if ENABLE_MIPSEL
BINUTILS_TARGETS += mipsel-linux-gnu
endif

BINUTILS_CFG_TARGETS = $(foreach T,$(BINUTILS_TARGETS),$(BINUTILS_BUILD)-$(T)/configure_done)
BINUTILS_BUILD_TARGETS = $(foreach T,$(BINUTILS_TARGETS),$(BINUTILS_BUILD)-$(T)/build_done)
BINUTILS_INST_TARGETS = $(foreach T,$(BINUTILS_TARGETS),$(REQDIR)/.binutils-installed-$(T))

.PRECIOUS: $(BINUTILS_ARCHIVE) $(BINUTILS_CFG_TARGETS) $(BINUTILS_BUILD_TARGETS) $(BINUTILS_INST_TARGETS)

binutils-fetch: $(BINUTILS_ARCHIVE) ; $(RULE_DONE)
binutils-configure: $(BINUTILS_CFG_TARGETS) ; $(RULE_DONE)
binutils-build: $(BINUTILS_BUILD_TARGETS) ; $(RULE_DONE)
binutils-install: $(BINUTILS_INST_TARGETS) ; $(RULE_DONE)

$(BINUTILS_SRC)/configure: $(BINUTILS_ARCHIVE)
	rm -f $@
	$(UNTAR) $(SRCBASE) $(BINUTILS_ARCHIVE)
	touch $@

$(BINUTILS_BUILD)-%/configure_done: $(BINUTILS_SRC)/configure $(REQTAG)
	rm -f $@
	$(MKDIR_P) $(BINUTILS_BUILD)-$*
	SRC=$$($(am__cd) $(BINUTILS_SRC) && pwd) && \
           $(am__cd) $(BINUTILS_BUILD)-$* && \
	   find . -name config.cache -exec rm '{}' \; && \
	   $$SRC/configure --target=$* \
			  CC="$(CC)" \
	                  CFLAGS="$(CPPFLAGS) $(CFLAGS)" \
	                  LDFLAGS="$(CFLAGS) $(LDFLAGS)" \
			   --disable-werror \
	                   --prefix=$(REQDIR)
	$(am__cd) $(BINUTILS_BUILD)-$* && $(MAKE) clean
	touch $@

$(BINUTILS_BUILD)-%/build_done: $(BINUTILS_BUILD)-%/configure_done
	rm -f $@
	$(am__cd) $(BINUTILS_BUILD)-$* && $(MAKE) 
	touch $@

$(REQDIR)/.binutils-installed-%: $(BINUTILS_BUILD)-%/build_done
	rm -f $@
	$(am__cd) $(BINUTILS_BUILD)-$* && $(MAKE) -j1 install
	touch $@
