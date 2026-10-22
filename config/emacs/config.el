;;; config.el -*- lexical-binding: t; -*-
;; Doom Emacs user configuration - F#ckIt! edition

;; Load custom packages
(defun my/packages ()
  (package! treemacs-all-the-icons
    :recipe (:host github :repo "Alexander-Miller/treemacs-all-the-icons"))
  (package! all-the-icons
    :recipe (:host github :repo "domtronn/all-the-icons.el"))
  (package! modus-themes
    :recipe (:host github :repo "protesilaos/modus-themes"))
  (package! catppuccin
    :recipe (:host github :repo "catppuccin/emacs")))

;; UI settings
(setq doom-theme 'catppuccin-mocha
      doom-modeline-height 22
      doom-modeline-bar-width 2
      doom-dashboard-banner-logo "doom-logo"
      doom-dashboard-banner-info-type 'version+system)

;; Font settings
(setq doom-font (font-spec :family "JetBrains Mono" :size 14 :weight 'normal)
      doom-variable-pitch-font (font-spec :family "JetBrains Mono" :size 14 :weight 'light)
      doom-big-font (font-spec :family "JetBrains Mono" :size 24 :weight 'normal))

;; Completion settings
(setq doom-vertical-completion t
      doom-company-vertical t
      vertico-cycle t
      vertico-count 15
      consult-preview-key "C-.")

;; LSP settings
(setq lsp-enable-symbol-highlighting t
      lsp-enable-on-type-formatting t
      lsp-prefer-flymake nil
      lsp-rust-analyzer-server-display-inlay-hints t
      lsp-typescript-auto-install t)

;; Project settings
(setq projectile-completion-system 'vertico
      projectile-switch-project-action 'projectile-dired)

;; Org mode
(setq org-directory "~/org"
      org-default-notes-file (concat org-directory "/notes.org")
      org-agenda-files (list org-directory)
      org-startup-truncated nil
      org-startup-indented t
      org-hide-leading-stars t
      org-log-done 'time)

;; Magit
(setq magit-completing-read-function 'vertico-completing-read
      magit-display-buffer-function #'magit-display-buffer-fullframe-status-v1)

;; Treemacs
(setq treemacs-collapse-dirs (lambda (dir) (or (string-prefix-p "." dir) (string-prefix-p "node_modules" dir)))
      treemacs-file-event-delay 1000
      treemacs-follow-after-init t
      treemacs-filewatch-use-polling t)

;; Keybindings
(map! :leader
  :desc "Find file" "f" #'projectile-find-file
  :desc "Switch project" "p" #'projectile-switch-project
  :desc "Magit status" "g" #'magit-status
  :desc "Treemacs toggle" "t" #'treemacs
  :desc "Org agenda" "a" #'org-agenda
  :desc "Org capture" "c" #'org-capture
  :desc "LSP workspace symbol" "s" #'lsp-workspace-symbol
  :desc "LSP document symbol" "S" #'lsp-document-symbol
  :desc "Restart LSP" "R" #'lsp-restart-workspace
  :desc "Format buffer" "F" #'lsp-format-buffer
  :desc "Rename symbol" "r" #'lsp-rename
  :desc "Code actions" "." #'lsp-execute-code-action
  :desc "Go to definition" "gd" #'lsp-find-definition
  :desc "Go to references" "gr" #'lsp-find-references
  :desc "Hover" "K" #'lsp-ui-peek
  :desc "Next diagnostic" "]" #'flymake-goto-next-error
  :desc "Prev diagnostic" "[" #'flymake-goto-prev-error)

;; Hooks
(add-hook 'prog-mode-hook #'lsp)
(add-hook 'prog-mode-hook #'treesitter-mode)
(add-hook 'org-mode-hook #'visual-line-mode)
(add-hook 'before-save-hook #'delete-trailing-whitespace)

;; Disable startup message
(setq inhibit-startup-message t
      initial-scratch-message nil)