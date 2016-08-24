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

GCC5_PATCH = patches/gcc-patch-$(GCC5_VERSION).patch
GCC5_PATCH_INTDIV = patches/gcc-patch-intdiv-$(GCC5_VERSION).patch
GCC5_SRC = $(SRCBASE)/gcc-$(GCC5_VERSION)
GCC5_BUILD = $(BLDBASE)/gcc-$(GCC5_VERSION)
GCC5_TARGETS = 
if ENABLE_LEON2MT
GCC5_TARGETS += sparc-linux-gnu
endif

GCC5_CFG_TARGETS = $(foreach T,$(GCC5_TARGETS),$(GCC5_BUILD)-$(T)/configure_done)
GCC5_BUILD_TARGETS = $(foreach T,$(GCC5_TARGETS),$(GCC5_BUILD)-$(T)/build_done)
GCC5_INST_TARGETS = $(foreach T,$(GCC5_TARGETS),$(REQDIR)/.gcc5-installed-$(T))

GCC5_CONFIG_FLAGS = \
   --disable-bootstrap --disable-libmudflap --disable-libssp \
   --disable-libquadmath --disable-coverage --enable-gdb --disable-threads --disable-nls \
   --disable-multilib --enable-languages=c --disable-libatomic

.PRECIOUS: $(GCC5_ARCHIVE) $(GCC5_CFG_TARGETS) $(GCC5_BUILD_TARGETS) $(GCC5_INST_TARGETS)

gcc5-fetch: $(GCC5_ARCHIVE) ; $(RULE_DONE)
gcc5-configure: $(GCC5_CFG_TARGETS) ; $(RULE_DONE)
gcc5-build: $(GCC5_BUILD_TARGETS) ; $(RULE_DONE)
gcc5-install: $(GCC5_INST_TARGETS) ; $(RULE_DONE)

$(GCC5_SRC)/configure: $(GCC5_ARCHIVE)
	rm -f $@
	$(UNTAR) $(SRCBASE) $(GCC5_ARCHIVE)
	touch $@

$(GCC5_SRC).patch_done: $(GCC5_SRC)/configure $(GCC5_PATCH) $(GCC5_PATCH_INTDIV)
	rm -f $@
	$(am__cd) $(GCC5_SRC) && patch -p1 <$(abs_top_srcdir)/$(GCC5_PATCH)
	$(am__cd) $(GCC5_SRC) && patch -p2 <$(abs_top_srcdir)/$(GCC5_PATCH_INTDIV)
	touch $@

$(GCC5_BUILD)-%/configure_done: $(GCC5_SRC).patch_done $(REQDIR)/.binutilsng-installed-%
	rm -f $@
	$(MKDIR_P) $(GCC5_BUILD)-$*
	SRC=$$($(am__cd) $(GCC5_SRC) && pwd) && \
           $(am__cd) $(GCC5_BUILD)-$* && \
	   find . -name config.cache -exec rm '{}' \; && \
	   $$SRC/configure --target=$* \
			   --prefix=$(REQDIR) \
			       CC="$(CC)" \
			       CFLAGS="$(CPPFLAGS) $(CFLAGS)" \
	                       LDFLAGS="$(CFLAGS) $(LDFLAGS)" \
			       MAKEINFO=/bin/true \
	                       $(GCC5_CONFIG_FLAGS) && \
	  $(GREP) -v 'maybe-[a-z]*-target-\(libgcc\|libiberty\|libgomp\|zlib\)' <Makefile >Makefile.tmp && \
	  mv -f Makefile.tmp Makefile
	$(am__cd) $(GCC5_BUILD)-$* && $(MAKE) clean
	touch $@

$(GCC5_BUILD)-%/build_done: $(GCC5_BUILD)-%/configure_done
	rm -f $@
	$(am__cd) $(GCC5_BUILD)-$* && $(MAKE)
	touch $@

$(REQDIR)/.gcc5-installed-%: $(GCC5_BUILD)-%/build_done
	rm -f $*
	$(am__cd) $(GCC5_BUILD)-$* && $(MAKE) -j1 install
	touch $@


