## Makefile.am: this file is part of the SL tool chain installer.
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
DSTBASE = $(DESTDIR)$(prefix)

if ENABLE_MTALPHA
MTA = -mta
else
MTA =
endif
if ENABLE_MTSPARC
MTS = -mts
else
MTS =
endif
if ENABLE_MIPSEL
MIPS = -mips
else
MIPS =
endif

REQBASENAME = b$(BINUTILS_VERSION)-u$(MGGCC_VERSION)-g$(GCC_VERSION)-m$(M4_VERSION)

REQNAME = slreqs-$(REQBASENAME)
REQDIR = $(DSTBASE)/$(REQNAME)
REQTAG = $(REQDIR)/.tag

SLBASENAME = s$(MGSIM_VERSION)-c$(SLC_VERSION)$(MTA)$(MTS)$(MIPS)-p$(PTL_VERSION)-h$(HLSIM_VERSION)
SLNAME = sl-$(SLBASENAME)
SLDIR = $(DSTBASE)/$(SLNAME)
SLTAG = $(SLDIR)/.tag

REQCURRENT = $(DSTBASE)/slreqs-$(SLNAME)
SLCURRENT = $(DSTBASE)/$(SLNAME)

ARCHIVEDIR = ./distfiles
SRCBASE = ./sources
BLDBASE = ./build

REQPARTS = 
SLPARTS = 
if ENABLE_PTL
SLPARTS += ptl hlsim
endif
if ENABLE_MT
REQPARTS += binutils gcc
SLPARTS += mgsim
endif
REQPARTS += m4 slenv
SLPARTS += slc

PARTS = $(REQPARTS) $(SLPARTS)

.PRECIOUS: $(REQTAG) $(SLTAG)
%/.tag:
	$(MKDIR_P) `dirname $@`
	touch $@

$(REQCURRENT): $(SLTAG)
	$(am__cd) $(DSTBASE) && rm -f slreqs-$(SLNAME) && $(LN_S) $(REQNAME) slreqs-$(SLNAME)

.PRECIOUS: $(ARCHIVEDIR)/%
$(ARCHIVEDIR)/%:
	$(AM_V_at)$(MKDIR_P) $(ARCHIVEDIR)
	$(AM_V_at)rm -f "$@" "$@".tmp
	$(AM_V_GEN)$(FETCH) $(DIST_SITE)/$* >"$@".tmp
	$(AM_V_at)mv -f "$@".tmp "$@"

.PHONY: help
help:
	@echo "Usage: $(MAKE) <rule> -jN"
	@echo
	@echo "General rules:"
	@echo "   fetch          fetch all archives"
	@echo "   reqs-install   build and install requirements"
	@echo "   install        build and install everything"
	@echo "   moretags       detect installed configuration tags"
	@echo
	@echo "Part-specific rules rules:"
	@echo "   XXX-fetch      fetch archive for part XXX"
	@echo "   XXX-configure  configure build for part XXX"
	@echo "   XXX-build      build part XXX"
	@echo "   XXX-install    install part XXX"
	@echo
	@echo "Parts:"
	@echo "   m4 binutils gcc"
	@echo "   mgsim ptl hlsim slc slenv"

RULE_DONE = @echo "*** $@: done. ***"; echo
UNTAR = do_extract() { \
     $(MKDIR_P) "$$1" && \
     case "$$2" in \
        *.tar.gz|*.tgz) GZIP=$(GZIP_ENV) gzip -dc "$$2" | ( $(am__cd) "$$1" && $(am__untar) ) ;; \
	*.tar.bz2*|*.tbz) bzip2 -dc "$$2" | ( $(am__cd) "$$1" && $(am__untar) ) ;; \
     esac; }; do_extract

include $(srcdir)/build-aux/version.mk

include $(srcdir)/rules/binutils.mk
include $(srcdir)/rules/gcc.mk
include $(srcdir)/rules/m4.mk
include $(srcdir)/rules/ptl.mk
include $(srcdir)/rules/mgsim.mk
include $(srcdir)/rules/hlsimcore.mk
include $(srcdir)/rules/slc.mk
include $(srcdir)/rules/slenv.mk

EXTRA_DIST += \
	rules/binutils.mk \
	rules/gcc.mk \
	rules/m4.mk \
	rules/ptl.mk \
	rules/mgsim.mk \
	rules/hlsimcore.mk \
	rules/slc.mk \
	rules/slenv.mk \
	latest.dist

latest.dist:
	$(AM_V_at)rm -f latest latest.dist
	$(AM_V_GEN)$(FETCH) $(TAGS_SITE)/latest >latest
	$(AM_V_at)mv -f latest latest.dist

reqs-fetch: 
	$(AM_V_at)$(MAKE) $(foreach P,$(REQPARTS),$(P)-fetch)
	$(RULE_DONE)

reqs-install: reqs-fetch
	$(AM_V_at)$(MAKE) $(foreach P,$(REQPARTS),$(P)-install)
	$(RULE_DONE)

fetch:
	$(AM_V_at)$(MAKE) $(foreach P,$(PARTS),$(P)-fetch)
	$(RULE_DONE)

install-data-local: fetch tags/.installed
	$(MAKE) $(foreach P,$(PARTS),$(P)-install)
	$(MAKE) moretags
	$(MKDIR_P) $(DSTBASE)/tags
	for tf in tags/*; do \
	   tag=`basename "$$tf"`; \
	   if ! test -r "$$tf"; then continue; fi; \
	   if test -r $(DSTBASE)/tags/"$$tag" && cmp -s "$$tf" $(DSTBASE)/tags/"$$tag"; then continue; fi; \
	   echo "$$tf -> $(DSTBASE)/tags/$$tag"; \
	   $(INSTALL_DATA) "$$tf" $(DSTBASE)/tags/; \
	done
	$(INSTALL_DATA) tags/.installed $(DSTBASE)/tags/installed-`date +%Y%m%d%H%M%S`
	$(INSTALL_DATA) tags/.installed $(DSTBASE)/tags/last-installed
	$(RULE_DONE)

tags/.installed: Makefile
	$(AM_V_at)$(MKDIR_P) tags
	$(AM_V_at)rm -f $@
	$(AM_V_GEN)(echo "# `date +'%Y-%m-%d %H:%M:%S'`"; \
	 echo "m4:$(M4_VERSION)"; \
	 echo "gcc:$(GCC_VERSION)"; \
	 echo "binutils:$(BINUTILS_VERSION)"; \
	 echo "mgsim:$(MGSIM_VERSION)"; \
	 echo "ptl:$(PTL_VERSION)"; \
	 echo "hlsim:$(HLSIM_VERSION)"; \
	 echo "slc:$(SLC_VERSION)"; \
	 echo "reqtag:$(REQBASENAME)"; \
	 echo "sltag:$(SLBASENAME)" ) >$@

uninstall-local:
	rm -rf $(REQDIR) $(SLDIR) $(REQCURRENT)
	for tag in $(DSTBASE)/tags/*; do \
	   test -r "$$tag" && $(MAKE) check-tag CHECKTAG="$$tag"; \
	done; true
	found= ; set -e; \
	  for d in $(DSTBASE)/tags/* $(DSTBASE)/sl-* $(DSTBASE)/slreqs-*; do \
	     if test -r $$d; then found=1; fi; \
	  done; \
	  rmdir $(DSTBASE)/tags || true; \
	  if test -z "$$found"; then \
	     rm -f $(DSTBASE)/slenv $(DSTBASE)/deslenv; \
	  fi; \
	  true

check-tag:
	$(AM_V_at)echo $(ECHO_N) "Trying tag: $(CHECKTAG)... $(ECHO_C)"; \
	   sltag=`grep sltag "$(CHECKTAG)"|cut -d: -f2-`; \
	   reqtag=`grep reqtag "$(CHECKTAG)"|cut -d: -f2-`; \
	   if test -d $(DSTBASE)/sl-$$sltag && test -d $(DSTBASE)/slreqs-$$reqtag; then \
	      echo "$(ECHO_T)good, keep"; \
	   else \
	      echo "$(ECHO_T)not installed, ignore"; \
	      rm -f "$(CHECKTAG)"; \
	   fi; true

moretags:
	$(AM_V_at)$(MKDIR_P) tags
	$(AM_V_at)for tag in `($(FETCH) "$(TAGS_SITE)/?F=0" || true) | grep 'href' | sed -e 's/^.*"\([^"]*\)".*$$/\1/g'|grep -v /`; do \
	   if ! $(FETCH) $(TAGS_SITE)/"$$tag" >"tags/$$tag"; then rm -f tags/"$$tag"; continue; fi; \
	   $(MAKE) check-tag CHECKTAG=tags/$$tag; \
	done; true

ALL_RULES = fetch reqs-install install moretags check-tag $(foreach P,$(PARTS),$(foreach R,fetch configure build install,$(P)-$(R)))
.PHONY: $(ALL_RULES)

