## ptl.mk: this file is part of the SL tool chain installer.
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

PTL_SRC = $(SRCBASE)/ptl-$(PTL_VERSION)
PTL_BUILD = $(BLDBASE)/ptl-$(PTL_VERSION)

if ENABLE_PTL
PTL_TARGETS = ptln-opt ptln-dbg ptl-opt ptl-dbg
else 
PTL_TARGETS =
endif

PTL_CFG_TARGETS = $(foreach T,$(PTL_TARGETS),$(PTL_BUILD)-$(T)/configure_done)
PTL_BUILD_TARGETS = $(foreach T,$(PTL_TARGETS),$(PTL_BUILD)-$(T)/build_done)
PTL_INST_TARGETS = $(foreach T,$(PTL_TARGETS),$(SLDIR)/.ptl-installed-$(T))

.PRECIOUS: $(PTL_ARCHIVE) $(PTL_CFG_TARGETS) $(PTL_BUILD_TARGETS) $(PTL_INST_TARGETS)

ptl-fetch: $(PTL_ARCHIVE) ; $(RULE_DONE)
ptl-configure: $(PTL_CFG_TARGETS) ; $(RULE_DONE)
ptl-build: $(PTL_CHECK_TARGETS) ; $(RULE_DONE)
ptl-install: $(PTL_INST_TARGETS) ; $(RULE_DONE)

$(PTL_SRC)/configure: $(PTL_ARCHIVE)
	rm -f $@
	$(UNTAR) $(SRCBASE) $(PTL_ARCHIVE)
	touch $@

$(PTL_BUILD)-%/configure_done: $(PTL_SRC)/configure $(SLTAG)
	rm -f $@
	$(MKDIR_P) $(PTL_BUILD)-$*
	more_cppflags= && \
	more_cxxflags= && \
	case $* in \
	  *-opt) more_cxxflags="-O2 -g";     more_cppflags="-DNDEBUG" ;; \
	  *-dbg) more_cxxflags="-O0 -ggdb3"; more_cppflags="-DDEBUG" ;; \
	esac && \
	case $* in \
	  ptln-*) more_cppflags="-DUSE_PLAIN_PTL" ;; \
	esac && \
	SRC=$$(cd $(PTL_SRC) && pwd) && \
	   cd $(PTL_BUILD)-$* && \
	   $$SRC/configure --includedir="$(SLDIR)/include/$*" --libdir="$(SLDIR)/lib/$*" \
			  CC="$(CC)" CXX="$(CXX)" \
	                  CPPFLAGS="$(CPPFLAGS) $$more_cppflags" \
			  CFLAGS="$(CFLAGS)" CXXFLAGS="$(CXXFLAGS) $$more_cxxflags" \
	                  LDFLAGS="$(LDFLAGS)"
	touch $@

$(PTL_BUILD)-%/build_done: $(PTL_BUILD)-%/configure_done
	rm -f $@
	cd $(PTL_BUILD)-$* && $(MAKE) all
	touch $@

$(SLDIR)/.ptl-installed-%: $(PTL_BUILD)-%/build_done
	rm -f $@
	$(MKDIR_P) $(SLDIR)
	cd $(PTL_BUILD)-$* && $(MAKE) install
	touch $@
