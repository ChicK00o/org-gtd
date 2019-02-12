
(define-key global-map (kbd "<f9> r") 'boxquote-region)
(define-key global-map (kbd "<f9> f") 'boxquote-insert-file)


(global-set-key (kbd "<f12>") 'org-agenda)


(global-set-key "\C-cb" 'org-switchb)


  ;; Custom Key Bindings
  (global-set-key (kbd "<f5>") 'bh/org-todo)
  (global-set-key (kbd "<S-f5>") 'bh/widen)
  (global-set-key (kbd "<f10>") 'bh/set-truncate-lines)
  (global-set-key (kbd "<f8>") 'org-cycle-agenda-files)
  (global-set-key (kbd "<f9> <f9>") 'bh/show-org-agenda)
  (global-set-key (kbd "<f9> c") 'calendar)
  (global-set-key (kbd "<f9> g") 'gnus)
  (global-set-key (kbd "<f9> h") 'bh/hide-other)
  (global-set-key (kbd "<f9> n") 'bh/toggle-next-task-display)

  (global-set-key (kbd "<f9> I") 'bh/punch-in)
  (global-set-key (kbd "<f9> O") 'bh/punch-out)

  (global-set-key (kbd "<f9> o") 'bh/make-org-scratch)

  (global-set-key (kbd "<f9> s") 'bh/switch-to-scratch)

  (global-set-key (kbd "<f9> S") 'org-save-all-org-buffers)

  (global-set-key (kbd "<f9> t") 'bh/insert-inactive-timestamp)
  (global-set-key (kbd "<f9> T") 'bh/toggle-insert-inactive-timestamp)

  (global-set-key (kbd "<f9> v") 'visible-mode)
  (global-set-key (kbd "<f9> l") 'org-toggle-link-display)
  (global-set-key (kbd "<f9> SPC") 'bh/clock-in-last-task)
  (global-set-key (kbd "C-<f9>") 'previous-buffer)
  (global-set-key (kbd "M-<f9>") 'org-toggle-inline-images)
  (global-set-key (kbd "C-<f10>") 'next-buffer)
  (global-set-key (kbd "S-<f11>") 'org-clock-goto)
  (global-set-key (kbd "C-<f11>") 'org-clock-in)
  ;; (global-set-key (kbd "C-s-<f12>") 'bh/save-then-publish)



(add-hook 'org-agenda-mode-hook
          '(lambda () (org-defkey org-agenda-mode-map "W" (lambda () (interactive) (setq bh/hide-scheduled-and-waiting-next-tasks t) (bh/widen))))
          'append)

(add-hook 'org-agenda-mode-hook
          '(lambda () (org-defkey org-agenda-mode-map "F" 'bh/restrict-to-file-or-follow))
          'append)


(add-hook 'org-agenda-mode-hook
          '(lambda () (org-defkey org-agenda-mode-map "N" 'bh/narrow-to-subtree))
          'append)


(add-hook 'org-agenda-mode-hook
          '(lambda () (org-defkey org-agenda-mode-map "U" 'bh/narrow-up-one-level))
          'append)

(add-hook 'org-agenda-mode-hook
          '(lambda () (org-defkey org-agenda-mode-map "P" 'bh/narrow-to-project))
          'append)


(add-hook 'org-agenda-mode-hook
          '(lambda () (org-defkey org-agenda-mode-map "V" 'bh/view-next-project))
          'append)

(add-hook 'org-agenda-mode-hook
          '(lambda () (org-defkey org-agenda-mode-map "\C-c\C-x<" 'bh/set-agenda-restriction-lock))
          'append)

