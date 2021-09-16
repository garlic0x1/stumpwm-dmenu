;;;; package.lisp

(defpackage #:dmenu
  (:use #:cl #:alexandria)
  (:export #:*dmenu-position*
           #:*dmenu-fast-p*
	   #:*dmenu-case-sensitive-p*
	   #:*dmenu-font*
	   #:*dmenu-background-color*
	   #:*dmenu-foreground-color*
	   #:*selected-background-color*
	   #:*dmenu-max-vertical-lines*))

