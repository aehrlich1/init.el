(require 'package)
(add-to-list 'package-archives '("melpa" . "https://melpa.org/packages/"))
(package-initialize)
(setq custom-file "~/.config/emacs/custom.el")
(setq org-directory "~/Dropbox/emacs/")

(defadvice keyboard-escape-quit
  (around keyboard-escape-quit-dont-close-windows activate)
  (let ((buffer-quit-function (lambda () ())))
    ad-do-it))

(defun ae/counsel-rg-preview-advice (orig-fun &rest args)
  (minibuffer-with-setup-hook
      (lambda () (setq ivy-calling t))
    (apply orig-fun args)))

(defun ae/counsel-rg ()
    (interactive)
    (counsel-rg nil org-directory))

(exec-path-from-shell-initialize)

(setq user-full-name "Anatol Ehrlich")
(setq user-mail-address "anatol.ehrlich@gmail.com")
(setq mac-command-modifier 'meta)
(setq mac-right-option-modifier nil)
(setq frame-resize-pixelwise t)
(add-to-list 'default-frame-alist '(font . "Fira Code-11.5"))
(add-to-list 'default-frame-alist '(undecorated-round . t))

(setq inhibit-startup-screen t)
(setq scroll-preserve-screen-position t)
(setq auto-save-default nil)
(setq create-lockfiles nil)
(setq make-backup-files nil)
(setq inhibit-startup-echo-area-message "")
(setq initial-major-mode 'org-mode)
(setq show-paren-delay 0)
(setq dired-kill-when-opening-new-dired-buffer t)
(setq help-window-select t)
(setq-default display-line-numbers-width 3)
(setq-default fill-column 90)

(tool-bar-mode -1)
(menu-bar-mode -1)
(tooltip-mode -1)
(scroll-bar-mode -1)
(blink-cursor-mode 0)
(show-paren-mode 1)
(delete-selection-mode 1)
(global-hl-line-mode 1)
(global-auto-revert-mode 1)
(global-display-line-numbers-mode 1)
(recentf-mode 1)
(visual-line-mode 1)
(add-hook 'text-mode-hook 'turn-on-visual-line-mode)

(global-set-key (kbd "<escape>") 'keyboard-escape-quit)
(global-set-key (kbd "C-M-p") (lambda () (interactive) (scroll-down 2)))
(global-set-key (kbd "C-M-n") (lambda () (interactive) (scroll-up 2)))
(global-set-key (kbd "C-x 2") (lambda () (interactive) (split-window-vertically) (other-window 1)))
(global-set-key (kbd "C-x 3") (lambda () (interactive) (split-window-horizontally) (other-window 1)))
(global-set-key (kbd "C-x r l") #'bookmark-jump)

(use-package counsel
  :ensure t
  :init
  (ivy-mode 1)
  (counsel-mode 1)
  :config
  (setq ivy-initial-inputs-alist nil)
  (advice-add 'counsel-rg :around #'ae/counsel-rg-preview-advice)
  :bind
  ("C-h C-s" . swiper-isearch)
  ("C-x C-g" . counsel-org-goto-all)
  ("C-x C-r" . counsel-recentf))

(use-package doom-themes
  :ensure t
  :config
  (load-theme 'doom-nord t)) ; doom-palenight

(use-package doom-modeline
  :ensure t
  :init
  (doom-modeline-mode 1)
  :config
  (setq doom-modeline-icon nil)
  (setq doom-modeline-height 22))

(use-package ivy-prescient
  :ensure t
  :init
  (ivy-prescient-mode 1))

(use-package ivy-rich
  :ensure t
  :init
  (ivy-rich-mode 1))

(use-package multiple-cursors
  :ensure t
  :bind ("C-S-c C-S-c" . mc/edit-lines))

(use-package org
  :init
  (setq org-ascii-text-width 80)
  (setq org-cycle-open-archived-trees t)
  (setq org-indent-indentation-per-level 1)
  (setq org-indent-mode-turns-on-hiding-stars nil)
  (setq org-startup-indented t)
  (setq org-catch-invisible-edits 'error)
  (setq org-bookmark-names-plist nil)
  (setq org-todo-keywords
	'((sequence "TODO(t)" "PROJ(p)" "WAIT(w)" "SOME(s)" "|" "DONE(d)" "KILL(k)")))
  (setq org-list-demote-modify-bullet '(("+" . "-") ("-" . "+") ("*" . "+")))
  (setq org-agenda-files (list (concat org-directory "/gtd")))
  (setq org-default-notes-file (concat org-directory "/gtd/capture.org"))
  (setq org-refile-use-outline-path 'file)
  (setq org-refile-targets
	'((org-agenda-files . (:level . 0))))
  (setq org-todo-keyword-faces
   '(("TODO" . "#ff6961")
     ("PROJ" . "#1b85b8")
     ("SOME" . "#895AD6")
     ("WAIT" . "#FFEE8C")
     ("DONE" . org-done)
     ("KILL" . "#F1420B")))
  (setq org-capture-templates
	'(("t" "Todo" entry (file "")
	   "* TODO %?\nSCHEDULED: %t\n %i")))
  (setq org-deadline-warning-days 0)
  (setq org-agenda-skip-deadline-prewarning-if-scheduled t)
  (setq org-agenda-span 'week)
  (setq org-agenda-window-setup 'current-window)
  (setq org-agenda-sorting-strategy
	'((agenda time-up todo-state-up priority-down tag-up category-keep deadline-down)
	  (todo priority-down category-keep tag-up)))
  (setq org-agenda-custom-commands
	'(("w" "Weekly Agenda"
	   ((agenda ""
		    ((org-agenda-overriding-header "WEEKLY AGENDA")
		     (org-agenda-span 'week)))
	    (todo "WAIT"
		  ((org-agenda-overriding-header "WAITING ITEMS")))
	    (todo "TODO"
		  ((org-agenda-overriding-header "UNSCHEDULED TODO ITEMS")
		  (org-agenda-skip-function
		   '(org-agenda-skip-entry-if 'deadline 'scheduled))))
	    ))
	  ("d" "Daily Agenda"
	   ((agenda ""
		    ((org-agenda-overriding-header "DAILY AGENDA")
		     (org-agenda-span 'day)))))
	  ("o" "Overview"
	   ((todo "WAIT"
		    ((org-agenda-overriding-header "WAITING ITEMS")))
	    (todo "TODO"
		  ((org-agenda-overriding-header "UNSCHEDULED TODO ITEMS")
		   (org-agenda-tag-filter-preset nil)
		  (org-agenda-skip-function
		   '(org-agenda-skip-entry-if 'deadline 'scheduled))))
	    (todo "PROJ"
		  ((org-agenda-overriding-header "PROJECTS")))
	    (todo "SOME"
		  ((org-agenda-overriding-header "SOMEDAY ITEMS")))
	    ))
	  ("r" "Weekly Review"
	   ((todo "DONE"
		    ((org-agenda-overriding-header "DONE ITEMS")))
	    (todo "KILL"
		  ((org-agenda-overriding-header "KILLED ITEMS")))
	    (todo "TODO"
		  ((org-agenda-overriding-header "UNSCHEDULED TODO ITEMS")
		  (org-agenda-skip-function
		   '(org-agenda-skip-entry-if 'deadline 'scheduled))))
	    (todo "SOME"
		  ((org-agenda-overriding-header "SOMEDAY ITEMS")))
	    ))
	  ))
  :bind
  (("C-c l"   . org-store-link)
   ("C-c a"   . org-agenda)
   ("C-c c"   . org-capture)
   ("M-j"     . (lambda () (interactive) (org-capture nil "t")))
   (:map org-mode-map)
   ("C-x C-x" . org-edit-special)
   ("C-j"     . nil)
   ("C-C C-q" . counsel-org-tag)
   (:map org-agenda-mode-map)
   ("C-C C-q" . counsel-org-tag-agenda)
   (:map org-src-mode-map)
   ("C-x C-x" . org-edit-src-exit)))

(use-package org-journal
  :ensure t
  :bind
  ("C-j" . org-journal-new-entry)
  (:map org-journal-mode-map)
  ("C-c C-s" . nil)
  ("C-c C-s" . org-schedule)
  :config
  (setq org-journal-dir (concat org-directory "journal"))
  (setq org-journal-file-type 'daily)
  (setq org-journal-hide-entries-p 'nil)
  (setq org-journal-find-file 'find-file)
  (setq org-journal-carryover-items 'nil)
  (setq org-journal-date-format "%Y-%m-%d %A W:%V")
  (setq org-journal-file-format "%Y-%m-%d.org"))

(use-package org-roam
  :ensure t
  :init
  (setq org-roam-directory (concat org-directory "/roam")))

(use-package org-reveal
  :disabled
  :init
  (org-reveal-root "file:///Users/anatol/src/reveal.js"))

(use-package nord-theme
  :disabled t
  :ensure t
  :config
  (setq nord-region-highlight "frost")
  (load-theme 'nord t))

(use-package rainbow-delimiters
  :ensure t
  :init
  (rainbow-delimiters-mode t))

(use-package visual-fill-column
  :ensure t
  :init
  (add-hook 'visual-line-mode-hook #'visual-fill-column-mode))

(load custom-file)
