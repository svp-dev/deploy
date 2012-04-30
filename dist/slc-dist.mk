## slc-dist.mk: this file is part of the SL packager.
## 
## Copyright (C) 2010,2011,2012 The SL project.
## All rights reserved. 

include common.mk
include dist-common.mk

SLC_GIT_BRANCH = master

SLC_GIT_HASH := $(strip $(shell $(GIT) ls-remote $(SLC_REPO) $(SLC_GIT_BRANCH)|head -n1|cut -c1-6))
SLC_DISTBASE = slc-$(SLC_GIT_HASH)
SLC_METASRC = $(META_SOURCES)/$(SLC_DISTBASE)/slc

$(SLC_METASRC)/download_done:
	rm -f $@
	$(MKDIR_P) $(META_SOURCES)
	cd $(META_SOURCES) && $(GIT) clone $(SLC_REPO) $(SLC_DISTBASE)
	cd $(SLC_METASRC) && $(GIT) checkout origin/$(SLC_GIT_BRANCH)
	touch $@

$(SLC_METASRC)/bootstrap_done: $(SLC_METASRC)/download_done
	rm -f $@
	cd $(SLC_METASRC) && bash -e ./bootstrap
	touch $@

$(SLC_METASRC)/configure_done: $(SLC_METASRC)/bootstrap_done
	rm -f $@
	cd $(SLC_METASRC) && ./configure
	touch $@

$(SLC_METASRC)/build1_done: $(SLC_METASRC)/configure_done
	rm -f $@
	cd $(SLC_METASRC) && $(MAKE) all
	touch $@

.PHONY: slc-dist
slc-dist: $(SLC_METASRC)/build1_done
	$(MKDIR_P) $(ARCHIVEDIR)
	rm -f $(SLC_METASRC)/*.tar.*
	cd $(SLC_METASRC) && make dist
	for arch in $(SLC_METASRC)/*.tar.bz2; do \
	   bn=`basename $$arch`; \
	   if ! test -f $(ARCHIVEDIR)/$$bn; then \
	      mv -f $$arch $(ARCHIVEDIR)/; \
	   fi; \
	done

