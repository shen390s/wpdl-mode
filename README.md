Example of EMACS major mode
===========================

# WPDL mode

  tutorial of emacs mode WPDL is described in https://www.emacswiki.org/emacs/ModeTutorial. 
  
# The detail of example

  - using wisi indent engine from opentoken http://www.stephe-leake.org/ada/opentoken.html
  - support both font lock and indentation
  
# Usage

  - install wisi from github or melpa
  - using wisi-generate to compile wpdl.wy to generate wpdl-wy.el

    ``
    wisi-generate.exe -v 2 wpdl.wy Elisp
    `` 

  - setup load path and load wpdl-mode.el
  - load wpdl.txt and enable wpdl-mode 
  
