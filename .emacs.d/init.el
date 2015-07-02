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
      (concat  "%b - emacs@" (system-name)))

;; default to unified diffs
(setq diff-switches "-u")

;; always end a file with a newline
;(setq require-final-newline 'query)

;; load path
(setq load-path
      (append '("~/.emacs.d/elisp")
              load-path))

;; dired-x
(require 'dired-x)

;; wdired
(require 'wdired)

;; color-moccur
;;(require 'color-moccur)
;;(setq moccur-split-word t)

;; moccur-edit
;;(require 'moccur-edit)

;; for dired
(define-key dired-mode-map "r" 'wdired-change-to-wdired-mode)
(define-key dired-mode-map "j" 'dired-jump)

;; for global
(global-set-key "\C-x\C-o" 'other-window)
(global-set-key "\C-x\C-b" 'buffer-menu)
(global-set-key "\M-h" 'backward-kill-word)
(global-set-key "\C-z" 'undo)
(global-set-key "\M-^" 'next-error)
(global-set-key "\M-\\" 'previous-error)
(global-set-key "\M- " 'dabbrev-expand)
(global-set-key [f1] 'describe-bindings)
(global-set-key [f2] 'comment-region)
(global-set-key [f3] 'igrep-find)
;;(global-set-key [f4] 'moccur)
(global-set-key [f5] 'align)
(global-set-key [f6] 'imenu)

;;; dired を使って、一気にファイルの coding system (漢字) を変換する
;; m でマークして T で一括変換
(require 'dired-aux)
(add-hook 'dired-mode-hook
          (lambda ()
            (define-key (current-local-map) "T"
              'dired-do-convert-coding-system)))

(defvar dired-default-file-coding-system nil
  "*Default coding system for converting file (s).")

(defvar dired-file-coding-system 'no-conversion)

(defun dired-convert-coding-system ()
  (let ((file (dired-get-filename))
        (coding-system-for-write dired-file-coding-system)
        failure)
    (condition-case err
        (with-temp-buffer
          (insert-file file)
          (write-region (point-min) (point-max) file))
      (error (setq failure err)))
    (if (not failure)
        nil
      (dired-log "convert coding system error for %s:\n%s\n" file failure)
      (dired-make-relative file))))

(defun dired-do-convert-coding-system (coding-system &optional arg)
  "Convert file (s) in specified coding system."
  (interactive
   (list (let ((default (or dired-default-file-coding-system
                            buffer-file-coding-system)))
           (read-coding-system
            (format "Coding system for converting file (s) (default, %s): "
                    default)
            default))
         current-prefix-arg))
  (check-coding-system coding-system)
  (setq dired-file-coding-system coding-system)
  (dired-map-over-marks-check
   (function dired-convert-coding-system) arg 'convert-coding-system t))

;;; .svnをigrepから除外
(setq igrep-find t
      igrep-find-prune-clause
      (format "-type d %s -name RCS -o -name CVS -o -name SCCS -o -name .svn %s"
	      (shell-quote-argument "(")
	      (shell-quote-argument ")")))
