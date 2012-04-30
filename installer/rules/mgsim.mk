## mgsim.mk: this file is part of the SL tool chain installer.
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

MGSIM_SRC = $(SRCBASE)/mgsim-$(MGSIM_VERSION)
MGSIM_BUILD = $(BLDBASE)/mgsim-$(MGSIM_VERSION)

MGSIM_TARGETS_BASE = opt-nosdl dbg-nosdl
if ENABLE_SDL
MGSIM_TARGETS_BASE += opt-sdl dbg-sdl
endif

MGSIM_TARGETS =
if ENABLE_MTALPHA
MGSIM_TARGETS += $(foreach T,$(MGSIM_TARGETS_BASE),mtalpha-$(T))
endif
if ENABLE_MTSPARC
MGSIM_TARGETS += $(foreach T,$(MGSIM_TARGETS_BASE),mtsparc-$(T))
endif

MGSIM_CFG_TARGETS = $(foreach T,$(MGSIM_TARGETS),$(MGSIM_BUILD)-$(T)/configure_done)
MGSIM_BUILD_TARGETS = $(foreach T,$(MGSIM_TARGETS),$(MGSIM_BUILD)-$(T)/build_done)
MGSIM_INST_TARGETS = $(foreach T,$(MGSIM_TARGETS),$(SLDIR)/.mgsim-installed-$(T))

MGSIM_CONFIG_FLAGS = --disable-abort-on-trace-failure --disable-verbose-trace-checks

.PRECIOUS: $(MGSIM_ARCHIVE) $(MGSIM_CFG_TARGETS) $(MGSIM_BUILD_TARGETS) $(MGSIM_INST_TARGETS)

mgsim-fetch: $(MGSIM_ARCHIVE) ; $(RULE_DONE)
mgsim-configure: $(MGSIM_CFG_TARGETS) ; $(RULE_DONE)
mgsim-build: $(MGSIM_BUILD_TARGETS) ; $(RULE_DONE)
mgsim-install: $(MGSIM_INST_TARGETS) ; $(RULE_DONE)

$(MGSIM_SRC)/configure: $(MGSIM_ARCHIVE)
	rm -f $@
	$(UNTAR) $(SRCBASE) $(MGSIM_ARCHIVE)
	touch $@

$(MGSIM_BUILD)-%/configure_done: $(MGSIM_SRC)/configure $(SLTAG) $(BINUTILS_INST_TARGETS) $(REQCURRENT)
	rm -f $@
	$(MKDIR_P) $(MGSIM_BUILD)-$*
	mgsim_target=`echo $*|cut -d- -f1` && program_suffix=-`echo $$mgsim_target|cut -c3-` && \
	mgsim_conf_flags=--target=$$mgsim_target && \
	more_cflags= && \
	case $* in \
	  *-opt-*) mgsim_conf_flags="$$mgsim_conf_flags --disable-assert"; more_cflags="-O3 -g0" ;; \
	  *-dbg-*) more_cflags="-O0 -g"; program_suffix=$$program_suffix.dbg ;; \
	esac && \
	case $* in \
	  *-sdl) program_suffix=$$program_suffix.gfx ;; \
	  *-nosdl) mgsim_conf_flags="$$mgsim_conf_flags --disable-sdl" ;; \
	esac && \
	SRC=$$(cd $(MGSIM_SRC) && pwd) && \
	   cd $(MGSIM_BUILD)-$* && \
	   PATH=$(REQCURRENT)/bin:$$PATH $$SRC/configure --prefix=$(SLDIR) \
			  CC="$(CC)" CXX="$(CXX)" \
	                  CPPFLAGS="$(CPPFLAGS)" \
			  CFLAGS="$(CFLAGS) $$more_cflags" CXXFLAGS="$(CXXFLAGS) $$more_cflags" \
	                  LDFLAGS="$(LDFLAGS)" \
	                  $(MGSIM_CONFIG_FLAGS) \
	                  --program-suffix=$$program_suffix \
	                  $$mgsim_conf_flags
	rm -f $(MGSIM_BUILD)-$*/src/*main.o
	touch $@

$(MGSIM_BUILD)-%/build_done: $(MGSIM_BUILD)-%/configure_done
	rm -f $@
	cd $(MGSIM_BUILD)-$* && $(MAKE) all
	touch $@

$(SLDIR)/.mgsim-installed-%: $(MGSIM_BUILD)-%/build_done
	rm -f $@
	$(MKDIR_P) $(SLDIR)
	cd $(MGSIM_BUILD)-$* && $(MAKE) install
	touch $@

