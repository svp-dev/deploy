## mgsim-dist.mk: this file is part of the SL packager.
## 
## Copyright (C) 2010,2011,2012 The SL project.
## All rights reserved. 

include common.mk
include dist-common.mk

MGSIM_GIT_BRANCH = master

MGSIM_GIT_HASH := $(strip $(shell $(GIT) ls-remote $(MGSIM_REPO) $(MGSIM_GIT_BRANCH)|head -n1|cut -c1-6))
MGSIM_DISTBASE = mgsim-$(MGSIM_GIT_HASH)
MGSIM_METASRC = $(META_SOURCES)/$(MGSIM_DISTBASE)

$(MGSIM_METASRC)/download_done:
	rm -f $@
	$(MKDIR_P) $(META_SOURCES)
	cd $(META_SOURCES) && $(GIT) clone $(MGSIM_REPO) $(MGSIM_DISTBASE)
	cd $(MGSIM_METASRC) && $(GIT) checkout origin/$(MGSIM_GIT_BRANCH)
	touch $@

$(MGSIM_METASRC)/bootstrap_done: $(MGSIM_METASRC)/download_done
	rm -f $@
	cd $(MGSIM_METASRC) && bash -e ./bootstrap
	touch $@

$(MGSIM_METASRC)/configure_done: $(MGSIM_METASRC)/bootstrap_done
	rm -f $@
	cd $(MGSIM_METASRC) && ./configure --target=mtalpha CPPFLAGS="$$CPPFLAGS" LDFLAGS="$$LDFLAGS"
	touch $@

$(MGSIM_METASRC)/build1_done: $(MGSIM_METASRC)/configure_done
	rm -f $@
	cd $(MGSIM_METASRC) && $(MAKE) .version && $(MAKE) mgsim
	touch $@

.PHONY: mgsim-dist
mgsim-dist: $(MGSIM_METASRC)/build1_done
	$(MKDIR_P) $(ARCHIVEDIR)
	rm -f $(MGSIM_METASRC)/*.tar.*
	cd $(MGSIM_METASRC) && rm -f ChangeLog && make ChangeLog && make dist
	for arch in $(MGSIM_METASRC)/*.tar.bz2; do \
	   bn=`basename $$arch`; \
	   if ! test -f $(ARCHIVEDIR)/$$bn; then \
	      mv -f $$arch $(ARCHIVEDIR)/; \
	   fi; \
	done

