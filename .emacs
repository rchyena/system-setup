;; .emacs

;;; uncomment this line to disable loading of "default.el" at startup
;; (setq inhibit-default-init t)

;; turn on font-lock mode
(when (fboundp 'global-font-lock-mode)
  (global-font-lock-mode t))

;; enable visual feedback on selections
;(setq transient-mark-mode t)

;; default to better frame titles
(setq frame-title-format
      (concat  "%b - emacs@" system-name))

;; My defaults
(setq-default major-mode 'text-mode)
(setq-default indent-tabs-mode nil)
(setq column-number-mode t)
(setq c-default-style "user")
(define-key global-map "\C-x?" 'help-command)
(define-key global-map "\C-H" 'delete-backward-char)

(add-hook 'c-mode-common-hook 'flyspell-prog-mode)
(add-hook 'tcl-mode-hook 'flyspell-prog-mode)
(add-hook 'text-mode-hook 'flyspell-mode)

(defun unfill-paragraph ()
  (interactive)
  (let ((fill-column (point-max)))
    (fill-paragraph nil)))

(defun unfill-region ()
  (interactive)
  (let ((fill-column (point-max)))
    (fill-region (region-beginning) (region-end) nil)))

(global-auto-revert-mode)

;; Change text color (rather than backgrounds, which is the default
;; for Fedora distributions).
(custom-set-faces
 '(diff-added       ((t (:foreground "Green"  :background "None"))) 'now)
 '(diff-removed     ((t (:foreground "Red"    :background "None"))) 'now)
 '(diff-file-header ((t (:foreground "Orange" :background "None"))) 'now)
 '(diff-context     ((t (:foreground "Grey50" :background "None"))) 'now)
 '(diff-hunk-header ((t (:foreground "Purple" :background "None"))) 'now)
 '(diff-header      ((t (:foreground "Blue"   :background "None"))) 'now)
 ;; diff-changed
 ;; diff-context
 ;; diff-index
 ;; diff-indicator-added
 ;; diff-indicator-changed
 ;; diff-indicator-removed
 ;; diff-nonexistent
 )
