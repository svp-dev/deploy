## gcc.mk: this file is part of the SL tool chain installer.
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

GCC_SRC = $(SRCBASE)/gcc-$(GCC_VERSION)
GCC_BUILD = $(BLDBASE)/gcc-$(GCC_VERSION)
GCC_TARGETS = 
if ENABLE_MTALPHA
GCC_TARGETS += mtalpha-linux-gnu 
endif
if ENABLE_MTSPARC
GCC_TARGETS += mtsparc-linux-gnu
endif
if ENABLE_MIPSEL
GCC_TARGETS += mipsel-linux-gnu
endif

GCC_CFG_TARGETS = $(foreach T,$(GCC_TARGETS),$(GCC_BUILD)-$(T)/configure_done)
GCC_BUILD_TARGETS = $(foreach T,$(GCC_TARGETS),$(GCC_BUILD)-$(T)/build_done)
GCC_INST_TARGETS = $(foreach T,$(GCC_TARGETS),$(REQDIR)/.gcc-installed-$(T))

GCC_CONFIG_FLAGS = \
   --disable-bootstrap --disable-libmudflap --disable-libssp \
   --disable-coverage --enable-gdb --disable-threads --disable-nls \
   --disable-multilib --enable-languages=c 

.PRECIOUS: $(GCC_ARCHIVE) $(GCC_CFG_TARGETS) $(GCC_BUILD_TARGETS) $(GCC_INST_TARGETS)

gcc-fetch: $(GCC_ARCHIVE) ; $(RULE_DONE)
gcc-configure: $(GCC_CFG_TARGETS) ; $(RULE_DONE)
gcc-build: $(GCC_BUILD_TARGETS) ; $(RULE_DONE)
gcc-install: $(GCC_INST_TARGETS) ; $(RULE_DONE)

$(GCC_SRC)/configure: $(GCC_ARCHIVE)
	rm -f $@
	$(UNTAR) $(SRCBASE) $(GCC_ARCHIVE)
	touch $@

$(GCC_BUILD)-%/configure_done: $(GCC_SRC)/configure $(REQDIR)/.binutils-installed-%
	rm -f $@
	$(MKDIR_P) $(GCC_BUILD)-$*
	SRC=$$($(am__cd) $(GCC_SRC) && pwd) && \
           $(am__cd) $(GCC_BUILD)-$* && \
	   find . -name config.cache -exec rm '{}' \; && \
	   $$SRC/configure --target=$* \
			   --prefix=$(REQDIR) \
			       CC="$(CC)" \
			       CFLAGS="$(CPPFLAGS) $(CFLAGS)" \
	                       LDFLAGS="$(CFLAGS) $(LDFLAGS)" \
			       MAKEINFO=/bin/true \
	                       $(GCC_CONFIG_FLAGS) && \
	  $(GREP) -v 'maybe-[a-z]*-target-\(libgcc\|libiberty\|libgomp\|zlib\)' <Makefile >Makefile.tmp && \
	  mv -f Makefile.tmp Makefile
	$(am__cd) $(GCC_BUILD)-$* && $(MAKE) clean
	touch $@

$(GCC_BUILD)-%/build_done: $(GCC_BUILD)-%/configure_done
	rm -f $@
	$(am__cd) $(GCC_BUILD)-$* && $(MAKE)
	touch $@

$(REQDIR)/.gcc-installed-%: $(GCC_BUILD)-%/build_done
	rm -f $*
	$(am__cd) $(GCC_BUILD)-$* && $(MAKE) -j1 install
	touch $@


