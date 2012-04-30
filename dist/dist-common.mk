## dist-common.mk: this file is part of the SL packager.
## 
## Copyright (C) 2010,2011,2012 The SL project.
## All rights reserved. 

SVN = svn
GIT = git
FETCH = wget
MKDIR_P = mkdir -p

BASE_REPO = https://git.svp-home.org
MGSIM_REPO = $(BASE_REPO)/mgsim.git
SLC_REPO = $(BASE_REPO)/slcore.git
BINUTILS_REPO = $(BASE_REPO)/binutils.git
DEPLOY_REPO = $(BASE_REPO)/deploy.git
GCC_REPO = $(BASE_REPO)/gcc.git

PTL_REPO = https://svn.svp-home.org/sw/svp/utc-ptl
HLSIM_CORE_REPO = https://svn.svp-home.org/sw/svp/hl-sim-ptl

M4_REPO = git://git.sv.gnu.org/m4

