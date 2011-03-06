## common.mk: this file is part of the SL packager.
## 
## Copyright (C) 2010,2011 The SL project.
## All rights reserved. 

ARCHIVEDIR = distfiles
META_SOURCES = sl/meta
INST_SOURCES = sl/src
INST_BUILD = sl/build

REQPARTS = binutils m4 gcc slenv
SLPARTS = mgsim slc
PARTS = $(REQPARTS) $(SLPARTS)

