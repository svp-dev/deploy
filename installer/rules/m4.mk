## m4.mk: this file is part of the SL tool chain installer.
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

M4_SRC = $(SRCBASE)/m4-$(M4_VERSION)
M4_BUILD = $(BLDBASE)/m4-$(M4_VERSION)
M4_BUILD_TARGETS = $(M4_BUILD)/build_done
M4_INST_TARGETS = $(REQDIR)/.m4-installed
M4_PATCH = patches/m4-patch-gnulib.patch

.PRECIOUS: $(M4_ARCHIVE) $(M4_BUILD_TARGETS) $(M4_INST_TARGETS)

m4-fetch: $(M4_ARCHIVE) ; $(RULE_DONE)
m4-configure:  ; $(RULE_DONE)
m4-build: $(M4_BUILD_TARGETS) ; $(RULE_DONE)
m4-install: $(M4_INST_TARGETS) ; $(RULE_DONE)

$(M4_SRC)/configure: $(M4_ARCHIVE)
	rm -f $@
	$(UNTAR) $(SRCBASE) $(M4_ARCHIVE)
	touch $@

$(M4_BUILD)/patch_done: $(M4_SRC)/configure $(M4_PATCH)
	rm -f $@
	$(am__cd) $(M4_SRC) && patch -p1 <$(abs_top_srcdir)/$(M4_PATCH)
	touch $@

$(M4_BUILD)/build_done: $(M4_BUILD)/patch_done $(REQTAG)
	rm -f $@
	$(MKDIR_P) $(M4_BUILD)
	SRC=$$($(am__cd) $(M4_SRC) && pwd) && \
	  $(am__cd) $(M4_BUILD) && \
	  find . -name config.cache -exec rm '{}' \; && \
	  $$SRC/configure --prefix=$(REQDIR) \
			  CC="$(CC)" \
			  CFLAGS="$(CPPFLAGS) $(CFLAGS)" \
	                  LDFLAGS="$(CFLAGS) $(LDFLAGS)" \
	     && \
	  if ! $(MAKE) ; then \
	     rm -rf * && POSIXLY_CORRECT=1 $$SRC/configure --prefix=$(REQDIR) \
			  CC="$(CC)" \
			  CFLAGS="$(CPPFLAGS) $(CFLAGS)" \
	                  LDFLAGS="$(CFLAGS) $(LDFLAGS)" \
	      && \
	     $(MAKE) ; \
	  fi
	touch $@

$(REQDIR)/.m4-installed: $(M4_BUILD)/build_done
	rm -f $@
	$(am__cd) $(M4_BUILD) && $(MAKE) install
	touch $@
