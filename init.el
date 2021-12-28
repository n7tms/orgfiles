;; ====================================================================================
;; Startup Settings
(setq inhibit-startup-message t)

(scroll-bar-mode -1)  ; disable visible scrollbar
(tool-bar-mode -1)    ; disable toolbar
(tooltip-mode -1)     ; disable tooltips
(set-fringe-mode 10)  ; give some breathing room
(menu-bar-mode -1)    ; disable the menu bar
(setq visible-bell t) ; flash instead of beep
(setq initial-frame-alist '((fullscreen . maximized)))  ; startup in fullscreen



;(set-face-attribute 'default nil :font "Fira Code Retina" :height 10)
;(load-theme 'tango-dark)
(load-theme 'wombat)
;(load-theme 'deeper-blue)


; Check if the hostname is the Surface Pro
(defun my-system-is-surface ()
  "Return true if the system we are running on is surface pro"
  (or
    (string-equal system-name "RexIT-SC-Tb01")
    (string-equal system-name "RexIT-SC-Tb01.lan")
    )
  )

; Check if the hostname is Deathstar
(defun my-system-is-deathstar ()
  "Return true if the system we are running on is deathstar"
  (or
    (string-equal system-name "deathstar")
    (string-equal system-name "deathstar.lan")
    )
  )


;; ====================================================================================
;; Initialize Package Sources
(require 'package)

(setq package-archives '(("melpa" . "https://melpa.org/packages/")
			 ("org" . "https://orgmode.org/elpa/")
			 ("elpa" . "https://elpa.gnu.org/packages/")))

(package-initialize)
(unless package-archive-contents
  (package-refresh-contents))

;; Bootstrap 'use-package'
(unless (package-installed-p 'use-package)
  (package-refresh-contents)
  (package-install 'use-package))
(eval-when-compile
  (require 'use-package))
(require 'bind-key)
(setq use-package-always-ensure t)



;; ====================================================================================
;; Show line numbers on the left and column numbers in the status bar
(global-display-line-numbers-mode t)

;; do not show line numbers in the following modes:
(dolist (mode '(org-mode-hook
		term-mode-hook
		shell-mode-hook
		eshell-mode-hook))
  (add-hook mode (lambda () (display-line-numbers-mode 0))))

(column-number-mode)



;; ====================================================================================
;; Completion Framework
(use-package ivy
  :diminish
  :bind (("C-s" . swiper)
	 :map ivy-minibuffer-map
	 ("TAB" . ivy-alt-done)
	 ("C-l" . ivy-alt-done)
	 ("C-j" . ivy-next-line)
	 ("C-k" . ivy-previous-line)
	 :map ivy-switch-buffer-map
	 ("C-k" . ivy-previous-line)
	 ("C-l" . ivy-alt-done)
	 ("C-d" . ivy-switch-buffer-kill)
	 :map ivy-reverse-i-search-map
	 ("C-k" . ivy-previous-line)
	 ("C-d" . ivy-reverse-i-search-kill))
  :config
  (ivy-mode 1))


(use-package counsel
  :bind (("M-x" . counsel-M-x)
	 ("C-x b" . counsel-ibuffer)
	 ("C-x C-f" . counsel-find-file)
	 :map minibuffer-local-map
	 ("C-r" . 'counsel-minibuffer-history))
  :config
  (setq ivy-initial-inputs-alist nil))  ;; do not start searches with ^

(use-package ivy-rich
  :after counsel
  :diminish
  :init
  (ivy-rich-mode 1))


;; ====================================================================================
;; Rainbow Delimiters  -- color match parenthesis
(use-package rainbow-delimiters
  :hook (prog-mode . rainbow-delimiters-mode))


;; ====================================================================================
;; Which Key Mode  -- shows possible key completion list
(use-package which-key
  :init (which-key-mode)
  :diminish which-key-mode
  :config
  (setq which-key-idle-delay 2))



;; ====================================================================================
;; magit  -- a git manager
(use-package magit
  :commands (magit-status magit-get-current-branch)
  :custom
  (magit-display-buffer-function #'magit-display-buffer-same-window-except-diff-v1))

;(use-package evil-magit
;  :after magit)




;; ====================================================================================
;; Custom Key Bindings
;;
(global-set-key (kbd "<escape>") 'keyboard-escape-quit)
(global-set-key (kbd "C-c a") 'org-agenda)

(define-key global-map (kbd "C-a")   (lambda () (interactive) (org-agenda)))
(define-key global-map (kbd "C-c c") (lambda () (interactive) (org-capture)))





;; ====================================================================================
;; Org Mode Stuff
(use-package org
  :pin org
  :commands (org-capture org-agenda)
  :hook (org-mode . efs/org-mode-setup)
  :config
  (setq org-ellipsis " ▾"
	org-hide-emphasis-markers t)

  (setq org-agenda-start-with-log-mode t)
  (setq org-log-done 'time)
  (setq org-log-into-drawer t)

  (cond ((eq system-type 'windows-nt)
         ;; Windows-specific code goes here.
	 (setq org-agenda-files
               '("c:\\mydata\\orgfiles\\myplan.org"
		 "c:\\mydata\\orgfiles\\tasks.org"
		 "c:\\mydata\\orgfiles\\dates.org")))
          
          ((eq system-type 'gnu/linux)
           ;; Linux-specific code goes here.
	   (setq org-agenda-files
		 '("~/orgfiles/myplan.org"
		   "~/orgfiles/tasks.org"
		   "~/orgfiles/dates.org"))))

  (setq org-refile-targets '(("archive.org" :maxlevel . 1)
			     ("tasks.org" :maxlevel . 1)))
  
  (advice-add 'org-refile :after 'org-save-all-org-buffers)

  (setq org-capture-templates
	'(("t" "Tasks / Projects")
	  ("tt" "Task" entry (file+olp "~/org-files/tasks.org" "Inbox")
	   "** TODO %?\n  %U\n  %a\n  %i" :empty-lines 1)
	  
	  ("j" "Journal Entries")
	  ("jj" "Journal" entry (file+olp+datetree "~/org-files/journal.org")
	   "\n* %<%I:%M %p> - Journal :journal:\n\n%?\n\n"
	   :clock-in :clock-resume
	   :empty-lines 1)
	  
	))
 
) ;; org

  
  
(use-package org-bullets
  :hook (org-mode . org-bullets-mode)
  :custom
  (org-bullets-bullet-list '("◉" "○" "●" "○" "●" "○" "●")))

(font-lock-add-keywords 'org-mode
			'(("^ *\\([-]\\) "
			   (0 (prog1 () (compose-region (match-beginning 1) (match-end 1) "•"))))))


;; I don't like the green font at the top level header. Watch for ways to change this.






;; (require 'org-habit)
;; (add-to-list 'org-modules 'org-habit)
;; (setq org-habit-graph-column 60)

;; ====================================================================================











(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(package-selected-packages
   (quote
    (ivy-rich yasnippet-snippets find-file-in-project elpy which-key use-package tagedit smex rainbow-delimiters projectile paredit org-bullets magit ido-completing-read+ exec-path-from-shell counsel clojure-mode-extra-font-locking cider))))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )
