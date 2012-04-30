## hlsim-core-dist.mk: this file is part of the SL packager.
## 
## Copyright (C) 2011,2012 The SL project.
## All rights reserved. 

include common.mk
include dist-common.mk

HLSIM_CORE_DIST_SVNBRANCH = trunk
HLSIM_CORE_DIST_REV = latest

HLSIM_CORE_BASEBRANCH := $(strip $(shell basename $(HLSIM_CORE_DIST_SVNBRANCH)))
HLSIM_CORE_SVN_REV := $(strip $(if $(filter latest, $(HLSIM_CORE_DIST_REV)), \
	          $(shell $(SVN) info $(HLSIM_CORE_REPO)/$(HLSIM_CORE_DIST_SVNBRANCH) | \
	                  grep 'Last Changed Rev' | \
	                  cut -d: -f2), $(HLSIM_CORE_DIST_REV)))

HLSIM_CORE_DIST_VERSION = $(HLSIM_CORE_SVN_REV)-$(HLSIM_CORE_BASEBRANCH)
HLSIM_CORE_DISTBASE = hlsim-core-$(HLSIM_CORE_DIST_VERSION)
HLSIM_CORE_METASRC = $(META_SOURCES)/$(HLSIM_CORE_DISTBASE)

$(HLSIM_CORE_METASRC)/download_done:
	rm -f $@
	$(MKDIR_P) $(META_SOURCES)
	cd $(META_SOURCES) && $(SVN) checkout -r$(HLSIM_CORE_SVN_REV) $(HLSIM_CORE_REPO)/$(HLSIM_CORE_DIST_SVNBRANCH) $(HLSIM_CORE_DISTBASE)
	touch $@

$(HLSIM_CORE_METASRC)/bootstrap_done: $(HLSIM_CORE_METASRC)/download_done
	rm -f $@
	cd $(HLSIM_CORE_METASRC)/hlsim-core && autoreconf -v -f -i
	touch $@

$(HLSIM_CORE_METASRC)/configure_done: $(HLSIM_CORE_METASRC)/bootstrap_done
	rm -f $@
	cd $(HLSIM_CORE_METASRC)/hlsim-core && ./configure CPPFLAGS="$$CPPFLAGS" LDFLAGS="$$LDFLAGS"
	touch $@

.PHONY: hlsim-core-dist
hlsim-core-dist: $(HLSIM_CORE_METASRC)/configure_done
	$(MKDIR_P) $(ARCHIVEDIR)
	rm -f $(HLSIM_CORE_METASRC)/hlsim-core/*.tar.*
	cd $(HLSIM_CORE_METASRC)/hlsim-core && make dist distdir=$(HLSIM_CORE_DISTBASE)
	for arch in $(HLSIM_CORE_METASRC)/hlsim-core/*.tar.bz2; do \
	   bn=`basename $$arch`; \
	   if ! test -f $(ARCHIVEDIR)/$$bn; then \
	      mv -f $$arch $(ARCHIVEDIR)/; \
	   fi; \
	done

