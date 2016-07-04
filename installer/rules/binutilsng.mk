## binutilsng.mk: this file is part of the SL tool chain installer.
## 
## Copyright (C) 2016 The SL project.
##
## This program is free software; you can redistribute it and/or
## modify it under the terms of the GNU General Public License
## as published by the Free Software Foundation; either version 2
## of the License, or (at your option) any later version.
##
## The complete GNU General Public Licence Notice can be found as the
## `COPYING' file in the root directory.
##

BINUTILSNG_SRC = $(SRCBASE)/binutils-$(BINUTILSNG_VERSION)
BINUTILSNG_BUILD = $(BLDBASE)/binutils-$(BINUTILSNG_VERSION)
BINUTILSNG_TARGETS = 
if ENABLE_LEON2MT
BINUTILSNG_TARGETS += sparc-linux-gnu
endif

BINUTILSNG_CFG_TARGETS = $(foreach T,$(BINUTILSNG_TARGETS),$(BINUTILSNG_BUILD)-$(T)/configure_done)
BINUTILSNG_BUILD_TARGETS = $(foreach T,$(BINUTILSNG_TARGETS),$(BINUTILSNG_BUILD)-$(T)/build_done)
BINUTILSNG_INST_TARGETS = $(foreach T,$(BINUTILSNG_TARGETS),$(REQDIR)/.binutilsng-installed-$(T))

.PRECIOUS: $(BINUTILSNG_ARCHIVE) $(BINUTILSNG_CFG_TARGETS) $(BINUTILSNG_BUILD_TARGETS) $(BINUTILSNG_INST_TARGETS)

binutilsng-fetch: $(BINUTILSNG_ARCHIVE) ; $(RULE_DONE)
binutilsng-configure: $(BINUTILSNG_CFG_TARGETS) ; $(RULE_DONE)
binutilsng-build: $(BINUTILSNG_BUILD_TARGETS) ; $(RULE_DONE)
binutilsng-install: $(BINUTILSNG_INST_TARGETS) ; $(RULE_DONE)

$(BINUTILSNG_SRC)/configure: $(BINUTILSNG_ARCHIVE)
	rm -f $@
	$(UNTAR) $(SRCBASE) $(BINUTILSNG_ARCHIVE)
	touch $@

$(BINUTILSNG_BUILD)-%/configure_done: $(BINUTILSNG_SRC)/configure $(REQTAG)
	rm -f $@
	$(MKDIR_P) $(BINUTILSNG_BUILD)-$*
	SRC=$$($(am__cd) $(BINUTILSNG_SRC) && pwd) && \
           $(am__cd) $(BINUTILSNG_BUILD)-$* && \
	   find . -name config.cache -exec rm '{}' \; && \
	   $$SRC/configure --target=$* \
			  CC="$(CC)" \
	                  CFLAGS="$(CPPFLAGS) $(CFLAGS)" \
	                  LDFLAGS="$(CFLAGS) $(LDFLAGS)" \
			   --disable-werror \
	                   --prefix=$(REQDIR)
	$(am__cd) $(BINUTILSNG_BUILD)-$* && $(MAKE) clean
	touch $@

$(BINUTILSNG_BUILD)-%/build_done: $(BINUTILSNG_BUILD)-%/configure_done
	rm -f $@
	$(am__cd) $(BINUTILSNG_BUILD)-$* && $(MAKE) 
	touch $@

$(REQDIR)/.binutilsng-installed-%: $(BINUTILSNG_BUILD)-%/build_done
	rm -f $@
	$(am__cd) $(BINUTILSNG_BUILD)-$* && $(MAKE) -j1 install
	touch $@
