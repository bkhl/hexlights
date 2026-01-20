((lua-mode
  . ((eval
      . (let ((root (expand-file-name (project-root (project-current)))))
          (setq-local tab-width 4
                      eglot-server-programs
                      `((lua-mode
                         "podman" "run" "--rm" "--interactive"
                         ,(concat "--volume=" root ":" root ":z")
                         ,(concat "--workdir=" root)
                         "ghcr.io/bkhl/image-lua-language-server:latest"))
                      eglot-workspace-configuration
                      '(:Lua
                        (:workspace
                         (:library ["${3rd}/tic80"
                                    "${3rd}/luassert"
                                    "${3rd}/busted"])
                         :diagnostics (:disable ["lowercase-global"]))))
          (add-hook 'before-save-hook #'eglot-format-buffer nil t)
          (eglot-ensure))))))
