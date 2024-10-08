(in-package #:dmenu)

(defvar *dmenu-position* :bottom)
(defvar *dmenu-fast-p* t)
(defvar *dmenu-case-sensitive-p* nil)
(defvar *dmenu-font* nil)
(defvar *dmenu-background-color* nil)
(defvar *dmenu-foreground-color* nil)

(defvar *dmenu-selected-background-color* nil)
(defvar *dmenu-selected-foreground-color* nil)
(defvar *dmenu-max-vertical-lines* 20)

(defun dmenu-build-cmd-options ()
  (format nil " ~@[~A~] ~@[~A~] ~@[~A~] ~@[~A~] ~@[~A~] ~@[~A~] ~@[~A~] ~@[~A~]"
          (when (equal *dmenu-position* :bottom) "-b")
          ;;(format nil "-m ~A" 1)
          (when *dmenu-fast-p* "-f")
          (when (not *dmenu-case-sensitive-p*) "-i")
          (when *dmenu-font* (format nil "-fn ~A" *dmenu-font*))
          (when *dmenu-background-color* (format nil "-nb ~A" *dmenu-background-color*))
          (when *dmenu-foreground-color* (format nil "-nf ~A" *dmenu-foreground-color*))
          (when *dmenu-selected-background-color* (format nil "-sb ~A" *dmenu-selected-background-color*))
          (when *dmenu-selected-foreground-color* (format nil "-sf ~A" *dmenu-selected-foreground-color*))))

(defun dmenu (&key (item-list "") prompt vertical-lines (cmd-options (dmenu-build-cmd-options)))
  (let* ((cmd (format nil
                      "printf ~A | dmenu~A ~@[-p \"~A\"~] ~@[-l \"~A\"~]"
                      (format nil (prin1-to-string "~{~A\\n~}")
                              (mapcar (lambda (i)
                                        (remove #\" i))
                                      item-list))
                      cmd-options
                      prompt
                      vertical-lines))
         (selection (stumpwm::run-shell-command cmd t)))
    (when (not (equal selection ""))
      (string-trim '(#\Newline) selection))))

(defun dmenu-calc-vertica-lines (menu-length)
  (if (> menu-length *dmenu-max-vertical-lines*)
      *dmenu-max-vertical-lines*
      menu-length))

;; https://gist.github.com/scottjad/5262930
(defun select-from-menu (screen table &optional prompt (initial-selection 0))
  (declare (ignore screen initial-selection))
  (let* ((menu-options (mapcar #'stumpwm::menu-element-name table))
         (menu-length (length menu-options))
         (selection-string (dmenu
                            :item-list menu-options
                            :prompt prompt
                            :vertical-lines (dmenu-calc-vertica-lines menu-length)))
         (selection (find selection-string menu-options
                          :test (lambda (selection-string item)
                                  (string-equal selection-string (format nil "~A" item))))))
    (if (listp (car table))
        (assoc selection table)
        selection)))

(defun dmenu-get-screen-number ()
  (stumpwm::frame-number (stumpwm::tile-group-current-frame (stumpwm:current-group))))

(stumpwm:defcommand dmenu-call-command () ()
  "Uses dmenu to call a Stumpwm command"
  (let ((selection (dmenu :item-list (stumpwm::all-commands) :prompt "Commands:")))
    (when selection (stumpwm:run-commands selection))))

(stumpwm:defcommand dmenu-eval-lisp () ()
  "Uses dmenu to eval a Lisp expression"
  (let ((selection (dmenu :prompt "Eval: ")))
    (when selection (eval (read-from-string selection)))))

(stumpwm:defcommand dmenu-windowlist () ()
  "Uses dmenu to change the visible window"
  (labels ((get-window (window-name)
             (find window-name (stumpwm::all-windows)
                   :key #'stumpwm::window-title :test #'equal)))
    (let* ((open-windows (mapcar #'stumpwm::window-name (stumpwm::all-windows)))
           (num-of-windows (length open-windows))
           (selection (dmenu
                       :item-list open-windows
                       :prompt "Choose a window:"
                       :vertical-lines (dmenu-calc-vertica-lines num-of-windows))))
      (alexandria:when-let* ((window (get-window selection))
                             (group (stumpwm::window-group window)))
        (stumpwm::switch-to-group group)
        (stumpwm::focus-frame group (stumpwm::window-frame window))
        (stumpwm::group-focus-window group window)))))

(stumpwm:defcommand dmenu-run () ()
  "Just a simple wrapper to call dmenu_run from lisp"
  (stumpwm:run-shell-command (format nil "dmenu_run ~A -p Run: " (dmenu-build-cmd-options))))
