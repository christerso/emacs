;;; frame-tag-autoloads.el --- automatically extracted autoloads
;;
;;; Code:
(add-to-list 'load-path (directory-file-name (or (file-name-directory #$) (car load-path))))

;;;### (autoloads nil "frame-tag" "frame-tag.el" (0 0 0 0))
;;; Generated autoloads from frame-tag.el

(defvar frame-tag-mode nil "\
Non-nil if Frame-Tag mode is enabled.
See the `frame-tag-mode' command
for a description of this minor mode.")

(custom-autoload 'frame-tag-mode "frame-tag" nil)

(autoload 'frame-tag-mode "frame-tag" "\
A minor mode that assigns a number to the frames by position order

\(fn &optional ARG)" t nil)

(if (fboundp 'register-definition-prefixes) (register-definition-prefixes "frame-tag" '("frame-tag-")))

;;;***

;; Local Variables:
;; version-control: never
;; no-byte-compile: t
;; no-update-autoloads: t
;; End:
;;; frame-tag-autoloads.el ends here
