## binutils-dist.mk: this file is part of the SL packager.
## 
## Copyright (C) 2010,2011,2012 The SL project.
## All rights reserved. 

include common.mk
include dist-common.mk

BINUTILSNG_GIT_BRANCH = master

BINUTILSNG_GIT_HASH := $(strip $(shell $(GIT) ls-remote $(BINUTILSNG_REPO) $(BINUTILSNG_GIT_BRANCH)|head -n1|cut -c1-6))
BINUTILSNG_DISTBASE = binutils-mt-2.25-$(BINUTILSNG_GIT_HASH)
BINUTILSNG_METASRC = $(META_SOURCES)/$(BINUTILSNG_DISTBASE)

$(BINUTILSNG_METASRC)/download_done:
	rm -f $@
	$(MKDIR_P) $(META_SOURCES)
	cd $(META_SOURCES) && $(GIT) clone $(BINUTILSNG_REPO) $(BINUTILSNG_DISTBASE)
	cd $(BINUTILSNG_METASRC) && $(GIT) checkout origin/$(BINUTILSNG_GIT_BRANCH)
	touch $@

.PHONY: binutilsng-dist
binutilsng-dist: $(BINUTILSNG_METASRC)/download_done
	$(MKDIR_P) $(ARCHIVEDIR)
	cd $(META_SOURCES) && tar --exclude=.git --exclude=download_done -cjvf $(BINUTILSNG_DISTBASE).tar.bz2 $(BINUTILSNG_DISTBASE)
	arch=$(BINUTILSNG_DISTBASE).tar.bz2; \
	if ! test -f $(ARCHIVEDIR)/$$arch; then \
	      mv -f $(META_SOURCES)/$$arch $(ARCHIVEDIR)/; \
	fi


