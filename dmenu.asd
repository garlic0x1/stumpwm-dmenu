(asdf:defsystem #:dmenu			
  :serial t
  :description "Dmenu wrapper"
  :author "Fermin MF"
  :license "GPLv3"
  :depends-on (#:stumpwm #:alexandria)
  :components ((:file "package")
               (:file "dmenu-wrapper")))

