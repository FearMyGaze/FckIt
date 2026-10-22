;;; packages.el -*- lexical-binding: t; -*-
;; Additional packages for Doom Emacs - F#ckIt! edition

;; Extra packages beyond doom-packages
(setq my-extra-packages
  '(
    ;; Utilities
    (embark :pin "main")
    (consult :pin "main")
    (marginalia :pin "main")
    (orderless :pin "main")
    (prescient :pin "main")
    (corfu :pin "main")

    ;; Git
    (forge :pin "main")
    (transient :pin "main")

    ;; Editing
    (multiple-cursors :pin "main")
    (expand-region :pin "main")
    (undo-tree :pin "main")

    ;; Navigation
    (avy :pin "main")
    (wgrep :pin "main")

    ;; Languages
    (markdown-mode :pin "main")
    (yaml-mode :pin "main")
    (toml-mode :pin "main")
    (dockerfile-mode :pin "main")
    (nginx-mode :pin "main")

    ;; Tools
    (restclient :pin "main")
    (json-mode :pin "main")
    (web-mode :pin "main")

    ;; UI
    (doom-modeline :pin "main")
    (all-the-icons :pin "main")
    ))

;; Install extra packages
(dolist (pkg my-extra-packages)
  (apply #'package! pkg))