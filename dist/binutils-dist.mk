## binutils-dist.mk: this file is part of the SL packager.
## 
## Copyright (C) 2010-2015 The SL project.
## All rights reserved. 

include common.mk
include dist-common.mk

BINUTILS_GIT_BRANCH = master

BINUTILS_GIT_HASH := $(strip $(shell $(GIT) ls-remote $(BINUTILS_REPO) $(BINUTILS_GIT_BRANCH)|head -n1|cut -c1-6))
BINUTILS_DISTBASE = binutils-mt-$(BINUTILS_GIT_HASH)
BINUTILS_METASRC = $(META_SOURCES)/$(BINUTILS_DISTBASE)

$(BINUTILS_METASRC)/download_done:
	rm -f $@
	$(MKDIR_P) $(META_SOURCES)
	cd $(META_SOURCES) && $(GIT) clone $(BINUTILS_REPO) $(BINUTILS_DISTBASE)
	cd $(BINUTILS_METASRC) && $(GIT) checkout origin/$(BINUTILS_GIT_BRANCH)
	touch $@

$(BINUTILS_METASRC)/bootstrap_done: $(BINUTILS_METASRC)/download_done
	rm -f $@
	#cd $(BINUTILS_METASRC)/src && ./bootstrap
	touch $@

.PHONY: binutils-dist
binutils-dist: $(BINUTILS_METASRC)/bootstrap_done
	$(MKDIR_P) $(ARCHIVEDIR)
	rm -f $(BINUTILS_METASRC)/*.tar.*
	cd $(BINUTILS_METASRC) && \
	   ver=binutils-mt-`$(GIT) describe --abbrev=4 --tags|sed -e 's/^v//g'` && \
	   echo "**** Preparing $$ver ****" && \
	   rm -rf $$ver && \
	   cp -RL src $$ver && \
	   tar -cjvf $$ver.tar.bz2 $$ver
	for arch in $(BINUTILS_METASRC)/*.tar.bz2; do \
	   bn=`basename $$arch`; \
	   if ! test -f $(ARCHIVEDIR)/$$bn; then \
	      mv -f $$arch $(ARCHIVEDIR)/; \
	   fi; \
	done


