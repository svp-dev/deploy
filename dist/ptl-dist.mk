## ptl-dist.mk: this file is part of the SL packager.
## 
## Copyright (C) 2010,2011,2012 The SL project.
## All rights reserved. 

include common.mk
include dist-common.mk

PTL_DIST_SVNBRANCH = branches/ptl-preV5-hlsim-irfan
PTL_DIST_REV = latest

PTL_BASEBRANCH := $(strip $(shell basename $(PTL_DIST_SVNBRANCH)))
PTL_SVN_REV := $(strip $(if $(filter latest, $(PTL_DIST_REV)), \
	          $(shell $(SVN) info $(PTL_REPO)/$(PTL_DIST_SVNBRANCH) | \
	                  grep 'Last Changed Rev' | \
	                  cut -d: -f2), $(PTL_DIST_REV)))

PTL_DIST_VERSION = $(PTL_SVN_REV)-$(PTL_BASEBRANCH)
PTL_DISTBASE = ptl-$(PTL_DIST_VERSION)
PTL_METASRC = $(META_SOURCES)/$(PTL_DISTBASE)

$(PTL_METASRC)/download_done:
	rm -f $@
	$(MKDIR_P) $(META_SOURCES)
	cd $(META_SOURCES) && $(SVN) checkout -r$(PTL_SVN_REV) $(PTL_REPO)/$(PTL_DIST_SVNBRANCH) $(PTL_DISTBASE)
	touch $@

$(PTL_METASRC)/bootstrap_done: $(PTL_METASRC)/download_done
	rm -f $@
	cd $(PTL_METASRC) && autoreconf -v -f -i
	touch $@

$(PTL_METASRC)/configure_done: $(PTL_METASRC)/bootstrap_done
	rm -f $@
	cd $(PTL_METASRC) && ./configure
	touch $@

.PHONY: ptl-dist
ptl-dist: $(PTL_METASRC)/configure_done
	$(MKDIR_P) $(ARCHIVEDIR)
	rm -f $(PTL_METASRC)/*.tar.*
	cd $(PTL_METASRC) && make dist distdir=$(PTL_DISTBASE)
	for arch in $(PTL_METASRC)/*.tar.bz2; do \
	   bn=`basename $$arch`; \
	   if ! test -f $(ARCHIVEDIR)/$$bn; then \
	      mv -f $$arch $(ARCHIVEDIR)/; \
	   fi; \
	done

