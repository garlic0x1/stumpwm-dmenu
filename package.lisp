;;;; package.lisp

(uiop:define-package #:dmenu
  (:use #:cl #:alexandria)
  (:export #:dmenu
           #:*dmenu-position*
           #:*dmenu-fast-p*
           #:*dmenu-case-sensitive-p*
           #:*dmenu-font*
           #:*dmenu-background-color*
           #:*dmenu-foreground-color*
           #:*dmenu-selected-background-color*
           #:*dmenu-selected-foreground-color*
           #:*selected-background-color*
           #:*dmenu-max-vertical-lines*))
