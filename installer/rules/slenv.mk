## slenv.mk: this file is part of the SL tool chain installer.
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

$(DSTBASE)/slenv: slenv
	rm -f $@
	$(MKDIR_P) $(DSTBASE)
	$(INSTALL_SCRIPT) $^ $@
	chmod -w $@

$(DSTBASE)/deslenv: deslenv
	rm -f $@
	$(MKDIR_P) $(DSTBASE)
	$(INSTALL_SCRIPT) $^ $@
	chmod -w $@

$(DSTBASE)/slversion: slversion
	rm -f $@
	$(MKDIR_P) $(DSTBASE)
	$(INSTALL_SCRIPT) $^ $@
	chmod -w $@

slenv-fetch: ; $(RULE_DONE)
slenv-configure: ; $(RULE_DONE)
slenv-build: ; $(RULE_DONE)

slenv-install: $(DSTBASE)/slenv $(DSTBASE)/deslenv $(DSTBASE)/slversion; $(RULE_DONE)
