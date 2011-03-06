##
## GCC dist
## 

include common.mk
include dist-common.mk

GCC_GIT_BRANCH = master

GCC_GIT_HASH := $(strip $(shell $(GIT) ls-remote $(GCC_REPO) $(GCC_GIT_BRANCH) | cut -c1-6))
GCC_DISTBASE = gcc-mt-$(GCC_GIT_HASH)
GCC_METASRC = $(META_SOURCES)/$(GCC_DISTBASE)

$(GCC_METASRC)/download_done:
	rm -f $@
	$(MKDIR_P) $(META_SOURCES)
	cd $(META_SOURCES) && $(GIT) clone $(GCC_REPO) $(GCC_DISTBASE)
	cd $(GCC_METASRC) && $(GIT) checkout origin/$(GCC_GIT_BRANCH)
	touch $@

$(GCC_METASRC)/bootstrap_done: $(GCC_METASRC)/download_done
	rm -f $@
	cd $(GCC_METASRC)/src && ./bootstrap
	touch $@

.PHONY: gcc-dist
gcc-dist: $(GCC_METASRC)/bootstrap_done
	$(MKDIR_P) $(ARCHIVEDIR)
	rm -f $(GCC_METASRC)/*.tar.*
	cd $(GCC_METASRC) && ver=gcc-mt-`$(GIT) describe --abbrev=4 --tags|sed -e 's/^v//g'` && \
	   echo "**** Preparing $$ver ****" && \
	   rm -rf $$ver && \
	   cp -RL src $$ver && \
	   tar -cjvf $$ver.tar.bz2 $$ver
	for arch in $(GCC_METASRC)/*.tar.bz2; do \
	   bn=`basename $$arch`; \
	   if ! test -f $(ARCHIVEDIR)/$$bn; then \
	      mv -f $$arch $(ARCHIVEDIR)/; \
	   fi; \
	done

