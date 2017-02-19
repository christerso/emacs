;;========================================================================================
;; Christer Söderlunds emacs config
;;========================================================================================

(require 'package)
(add-to-list 'package-archives
			              '("melpa" . "https://melpa.org/packages/") t)
(when (< emacs-major-version 24)
    ;; For important compatibility libraries like cl-lib
	  (add-to-list 'package-archives '("gnu" . "https://elpa.gnu.org/packages/")))
(package-initialize)

;;========================================================================================
;; Add scripts beneath this separator
;;========================================================================================

(defalias 'yes-or-no-p 'y-or-n-p)

;; Stop the annoying autosave
(setq backup-directory-alist
          `((".*" . ,temporary-file-directory)))
    (setq auto-save-file-name-transforms
          `((".*" ,temporary-file-directory t)))
(setq make-backup-files nil)

(require 'company)
(add-hook 'after-init-hook 'global-company-mode)

(require 'irony)
(add-hook 'c++-mode-hook 'irony-mode)
(add-hook 'c-mode-hook 'irony-mode)
(add-hook 'objc-mode-hook 'irony-mode)
(add-hook 'irony-mode-hook 'irony-cdb-autosetup-compile-options)

(defun my-irony-mode-hook ()
  (define-key irony-mode-map [remap completion-at-point]
    'irony-completion-at-point-async)
  (define-key irony-mode-map [remap complete-symbol]
    'irony-completion-at-point-async))
(add-hook 'irony-mode-hook 'my-irony-mode-hook)
;;(add-hook 'irony-mode-hook 'company-irony-setup-begin-commands)

(require 'company-irony-c-headers)
(eval-after-load 'company
  '(add-to-list
    'company-backends '(company-irony-c-headers company-irony)))

(require 'flycheck-irony)
;;(add-hook 'c++-mode-hook 'flycheck-mode)
(add-hook 'c++-mode-hook (lambda () (setq flycheck-gcc-language-standard "c++11")))
(add-hook 'c-mode-hook 'flycheck-mode)
(eval-after-load 'flycheck
  '(add-hook 'flycheck-mode-hook #'flycheck-irony-setup))
(defun irony--check-expansion ()
  (save-excursion
    (if (looking-at "\\_>") t
      (backward-char 1)
      (if (looking-at "\\.") t
	(backward-char 1)
	(if (looking-at "->") t nil)))))
(defun irony--indent-or-complete ()
  "Indent or Complete"
  (interactive)
  (cond ((and (not (use-region-p))
	      (irony--check-expansion))
	 (message "complete")
	 (company-complete-common))
	(t
	 (message "indent")
	 (call-interactively 'c-indent-line-or-region))))
(defun irony-mode-keys ()
  "Modify keymaps used by `irony-mode'."
  (local-set-key (kbd "TAB") 'irony--indent-or-complete)
  (local-set-key [tab] 'irony--indent-or-complete))
(add-hook 'c-mode-common-hook 'irony-mode-keys)

;; Switch to help window on open
(setq help-window-select t)
;;===========================================
(setq shell-file-name "bash")

;; Switch between buffers by number
(require 'frame-tag)
(frame-tag-mode 1)

;; IComplete +
(eval-after-load "icomplete" '(progn (require 'icomplete+)))

(require 'ido)
(ido-mode t)
(setq ido-use-virtual-buffers t)

(defun ido-choose-from-recentf ()
  "Use ido to select a recently visited file from the `recentf-list'"
  (interactive)
  (find-file (ido-completing-read "Open file: " recentf-list nil t)))

(global-set-key (kbd "C-c f") 'ido-choose-from-recentf)
(global-set-key "\C-x\C-b" 'buffer-menu)

(setq company-idle-delay 0)

;; Default directory is home directory
(setq default-directory "~/")

;; CMake support
(defun maybe-cmake-project-hook ()
  (if (file-exists-p "CMakeLists.txt") (cmake-project-mode)))
(add-hook 'c-mode-hook 'maybe-cmake-project-hook)
(add-hook 'c++-mode-hook 'maybe-cmake-project-hook)

;; Remove toolbar and menu
(menu-bar-mode 0)
(tool-bar-mode -1)
(scroll-bar-mode 0)
;; After splitting a frame automatically, switch to the new window (unless we
;;were in the minibuffer)
(setq split-window-preferred-function 'my/split-window-func)
(defun my/split-window-func (&optional window)
  (let ((new-window (split-window-sensibly window)))
    (if (not (active-minibuffer-window))
        (select-window new-window))))
(defun split-window--select-window (orig-func &rest args)
  "Switch to the other window after a `split-window'"
  (let ((cur-window (selected-window))
        (new-window (apply orig-func args)))
    (when (equal (window-buffer cur-window) (window-buffer new-window))
      (select-window new-window))
    new-window))
(advice-add 'split-window :around #'split-window--select-window)


;; Peristent scratch buffer
(setq persistent-scratch-autosave-mode 1)

;; KEY SETTINGS =================================================================

;; Unbinding any keys I do not want
(global-unset-key (kbd "C-x f")) ; fill
(global-unset-key (kbd "C-x c")) ; fill
(global-unset-key (kbd "M-z")) ; zap key

;; Move windows
(global-set-key (kbd "<C-S-up>")     'buf-move-up)
(global-set-key (kbd "<C-S-down>")   'buf-move-down)
(global-set-key (kbd "<C-S-left>")   'buf-move-left)
(global-set-key (kbd "<C-S-right>")  'buf-move-right)

;; Jump between windows
(global-set-key (kbd "C-c <left>")  'windmove-left)
(global-set-key (kbd "C-c <right>") 'windmove-right)
(global-set-key (kbd "C-c <up>")    'windmove-up)
(global-set-key (kbd "C-c <down>")  'windmove-down)

;; Binding keys
(global-set-key (kbd "C-c c") 'comment-dwim)
;; Using CEDET Eassist to switch between header and implementation
(defun my-c-mode-common-hook ()
   (define-key c-mode-base-map (kbd "C-x c") 'eassist-switch-h-cpp)
   (define-key c-mode-base-map (kbd "C-x m") 'eassist-list-methods))
(add-hook 'c-mode-common-hook 'my-c-mode-common-hook)
(add-hook 'c-mode-common-hook 'uncrustify-mode)

;;===============================================================================

;; Leave anything below this line alone as emacs themes mess around with it
(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(ansi-color-faces-vector
   [default bold shadow italic underline bold bold-italic bold])
 '(ansi-color-names-vector
   ["#212121" "#CC5542" "#6aaf50" "#7d7c61" "#5180b3" "#DC8CC3" "#9b55c3" "#bdbdb3"])
 '(custom-enabled-themes (quote (atom-dark)))
 '(custom-safe-themes
   (quote
    ("1db337246ebc9c083be0d728f8d20913a0f46edc0a00277746ba411c149d7fe5" "db2ecce0600e3a5453532a89fc19b139664b4a3e7cbefce3aaf42b6d9b1d6214" "cc60d17db31a53adf93ec6fad5a9cfff6e177664994a52346f81f62840fe8e23" "4aee8551b53a43a883cb0b7f3255d6859d766b6c5e14bcb01bed572fcbef4328" "4cf3221feff536e2b3385209e9b9dc4c2e0818a69a1cdb4b522756bcdf4e00a4" "82d2cac368ccdec2fcc7573f24c3f79654b78bf133096f9b40c20d97ec1d8016" "1b8d67b43ff1723960eb5e0cba512a2c7a2ad544ddb2533a90101fd1852b426e" "bb08c73af94ee74453c90422485b29e5643b73b05e8de029a6909af6a3fb3f58" "628278136f88aa1a151bb2d6c8a86bf2b7631fbea5f0f76cba2a0079cd910f7d" "8db4b03b9ae654d4a57804286eb3e332725c84d7cdab38463cb6b97d5762ad26" "8df8dcdfb3ab16796818e750684c186e1a42db38b7f36603d1f9d938cad0e933" "66132890ee1f884b4f8e901f0c61c5ed078809626a547dbefbb201f900d03fd8" "f04122bbc305a202967fa1838e20ff741455307c2ae80a26035fbf5d637e325f" "9d91458c4ad7c74cf946bd97ad085c0f6a40c370ac0a1cbeb2e3879f15b40553" "227edf860687e6dfd079dc5c629cbfb5c37d0b42a3441f5c50873ba11ec8dfd2" "fad38808e844f1423c68a1888db75adf6586390f5295a03823fa1f4959046f81" "3ff96689086ebc06f5f813a804f7114195b7c703ed2f19b51e10026723711e33" "06f0b439b62164c6f8f84fdda32b62fb50b6d00e8b01c2208e55543a6337433a" "ac5584b12254623419499c3a7a5388031a29be85a15fdef9b94df2292d3e2cbb" "8ec2e01474ad56ee33bc0534bdbe7842eea74dccfb576e09f99ef89a705f5501" "7997e0765add4bfcdecb5ac3ee7f64bbb03018fb1ac5597c64ccca8c88b1262f" "604648621aebec024d47c352b8e3411e63bdb384367c3dd2e8db39df81b475f5" "726dd9a188747664fbbff1cd9ab3c29a3f690a7b861f6e6a1c64462b64b306de" "a1289424bbc0e9f9877aa2c9a03c7dfd2835ea51d8781a0bf9e2415101f70a7e" default)))
 '(ensime-sem-high-faces
   (quote
    ((var :foreground "#9876aa" :underline
	  (:style wave :color "yellow"))
     (val :foreground "#9876aa")
     (varField :slant italic)
     (valField :foreground "#9876aa" :slant italic)
     (functionCall :foreground "#a9b7c6")
     (implicitConversion :underline
			 (:color "#808080"))
     (implicitParams :underline
		     (:color "#808080"))
     (operator :foreground "#cc7832")
     (param :foreground "#a9b7c6")
     (class :foreground "#4e807d")
     (trait :foreground "#4e807d" :slant italic)
     (object :foreground "#6897bb" :slant italic)
     (package :foreground "#cc7832")
     (deprecated :strike-through "#a9b7c6"))))
 '(fci-rule-color "#2e2e2e")
 '(fringe-mode 6 nil (fringe))
 '(hl-paren-colors
   (quote
    ("#B9F" "#B8D" "#B7B" "#B69" "#B57" "#B45" "#B33" "#B11")))
 '(initial-scratch-message ";; Peristent scratch buffer

")
 '(linum-format (quote dynamic))
 '(main-line-color1 "#222232")
 '(main-line-color2 "#333343")
 '(notmuch-search-line-faces
   (quote
    (("unread" :foreground "#aeee00")
     ("flagged" :foreground "#0a9dff")
     ("deleted" :foreground "#ff2c4b" :bold t))))
 '(nrepl-message-colors
   (quote
    ("#CC9393" "#DFAF8F" "#F0DFAF" "#7F9F7F" "#BFEBBF" "#93E0E3" "#94BFF3" "#DC8CC3")))
 '(package-selected-packages
   (quote
    (egg buffer-move uncrustify-mode persistent-scratch realgud zonokai-theme zenburn-theme org icomplete+ frame-tag flycheck-irony dired-toggle-sudo darktooth-theme darcula-theme danneskjold-theme dakrone-theme cpputils-cmake company-irony-c-headers company-irony color-theme-solarized color-theme-sanityinc-tomorrow color-theme-sanityinc-solarized colonoscopy-theme cmake-project cmake-ide clues-theme cherry-blossom-theme calmer-forest-theme boron-theme badwolf-theme atom-dark-theme arjen-grey-theme ample-zen-theme ample-theme alect-themes airline-themes ahungry-theme afternoon-theme)))
 '(pdf-view-midnight-colors (quote ("#DCDCCC" . "#383838")))
 '(persistent-scratch-autosave-mode t)
 '(persistent-scratch-backup-directory "~/Dropbox/backup/emacs-scratch")
 '(persistent-scratch-save-file "~/Dropbox/backup/emacs-scratch/persistent-scratch")
 '(pos-tip-background-color "#36473A")
 '(pos-tip-foreground-color "#FFFFC8")
 '(powerline-color1 "#222232")
 '(powerline-color2 "#333343")
 '(uncrustify-config-path "~/uncrustify.cfg")
 '(vc-annotate-background "#3b3b3b")
 '(vc-annotate-color-map
   (quote
    ((20 . "#dd5542")
     (40 . "#CC5542")
     (60 . "#fb8512")
     (80 . "#baba36")
     (100 . "#bdbc61")
     (120 . "#7d7c61")
     (140 . "#6abd50")
     (160 . "#6aaf50")
     (180 . "#6aa350")
     (200 . "#6a9550")
     (220 . "#6a8550")
     (240 . "#6a7550")
     (260 . "#9b55c3")
     (280 . "#6CA0A3")
     (300 . "#528fd1")
     (320 . "#5180b3")
     (340 . "#6380b3")
     (360 . "#DC8CC3"))))
 '(vc-annotate-very-old-color "#DC8CC3"))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(company-preview ((t (:background "darkgray" :foreground "black"))))
 '(company-preview-common ((t (:background "dark slate gray" :foreground "white smoke"))))
 '(company-preview-search ((t (:inherit company-preview :background "dark gray"))))
 '(company-scrollbar-bg ((t (:background "darkgray"))))
 '(company-scrollbar-fg ((t (:background "white"))))
 '(company-template-field ((t (:background "dark goldenrod" :foreground "black"))))
 '(company-tooltip ((t (:background "dark slate gray" :foreground "white"))))
 '(company-tooltip-annotation ((t (:foreground "pale turquoise"))))
 '(company-tooltip-common ((t (:foreground "white"))))
 '(company-tooltip-mouse ((t (:background "black" :foreground "deep sky blue"))))
 '(company-tooltip-selection ((t (:background "black" :foreground "orange"))))
 '(isearch ((t (:background "black" :foreground "orange"))))
 '(isearch-fail ((t (:background "orange" :foreground "black"))))
 '(lazy-highlight ((t (:background "dark orange" :foreground "black"))))
 '(region ((t (:background "light goldenrod" :foreground "dark blue" :inverse-video nil))))
 '(tty-menu-selected-face ((t (:background "dark green")))))
