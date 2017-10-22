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

;; Add Chapel mode
(load-file "~/.local/packages/Emacs-Chapel-Mode/chapel-mode.el")
(autoload 'chapel-mode "chapel-mode" "Chapel enhanced cc-mode" t)
(add-to-list 'auto-mode-alist '("\\.chpl$" . chapel-mode))

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

;; Disable default "newline-and-indent" behavior.
(when (fboundp 'electric-indent-mode) (electric-indent-mode -1))

;; Use the startup directory to store Emacs desktop session files.
(setq desktop-dirname default-directory)
(setq desktop-restore-forces-onscreen nil)
(setq session-loaded nil)

(defun session-exists ()
  (file-exists-p (concat desktop-dirname ".emacs.desktop")))

(defun session-load ()
  "Restore a saved emacs session."
  (interactive)
  (if (session-exists)
      (setq session-loaded (desktop-read desktop-dirname))
    (message "No desktop found.")))

(defun session-save ()
  "Save an emacs session."
  (interactive)
  (desktop-save-in-desktop-dir))

;; Ask user whether to restore desktop at start-up.
(add-hook 'after-init-hook
          '(lambda ()
             (if (session-exists)
                 (if (y-or-n-p "Restore desktop session? ")
                     (session-load)))))

;; Update the session if the buffer-list changes.
(add-hook 'kill-emacs-query-functions
          '(lambda ()
             (if (and (session-exists) session-loaded)
                 (desktop-save-in-desktop-dir)
                 t)))

(defun unfill-paragraph ()
  (interactive)
  (let ((fill-column (point-max)))
    (fill-paragraph nil)))

(defun unfill-region ()
  (interactive)
  (let ((fill-column (point-max)))
    (fill-region (region-beginning) (region-end) nil)))

(global-auto-revert-mode)
;(add-hook 'before-save-hook 'delete-trailing-whitespace)

;; Add the Solarized color theme.
(add-to-list 'custom-theme-load-path
             "~/.local/packages/emacs-color-theme-solarized")
(load-theme 'solarized t)

(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(frame-background-mode (quote dark))
 '(safe-local-variable-values (quote ((make-backup-files)))))

(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )
