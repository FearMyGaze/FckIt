;;; init.el -*- lexical-binding: t; -*-
;; Doom Emacs configuration - F#ckIt! edition

;; Core packages (always loaded)
(setq doom-packages
  '(
    ;; Essentials
    (emacs +everywhere)
    (editor +everywhere)
    (term +everywhere)
    (checkers +everywhere)
    (completion +everywhere company vertico)
    (project +everywhere projectile)
    (snippets +everywhere yasnippet)

    ;; UI
    (ui +everywhere doom-modeline doom-dashboard hl-todo which-key)
    (ui +everywhere treemacs)
    (ui +everywhere minimap)

    ;; Language support
    (lang +everywhere)
    (lsp +everywhere lsp lsp-pyright lsp-rust-analyzer lsp-typescript)
    (treesitter +everywhere)

    ;; Tools
    (tools +everywhere magit editorconfig direnv docker)
    (tools +everywhere make)

    ;; Data
    (data +everywhere org csv json yaml toml)

    ;; Config
    (config +everywhere)
    )
  )

;; Package pins (optional - uncomment to pin versions)
;; (setq doom-pinned-packages
;;   '(
;;     (magit :branch "main")
;;     (projectile :branch "main")
;;     )
;;   )

;; Unpin packages (if needed)
;; (setq doom-unpinned-packages '())