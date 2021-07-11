;;; packages.el --- gtd Layer packages File for Spacemacs
;;
;; Copyright (c) 2012-2014 Sylvain Benner
;; Copyright (c) 2014-2015 Sylvain Benner & Contributors
;;
;; Author: Sylvain Benner <sylvain.benner@gmail.com>
;; URL: https://github.com/syl20bnr/spacemacs
;;
;; This file is not part of GNU Emacs.
;;
;;; License: GPLv3

;;; Second File to be loaded Layers -> Package -> Funcs -> Config -> Keybinding

(defconst gtd-packages
    '(
      (vulpea
       :location (recipe :fetcher github :repo "d12frosted/vulpea" :branch "feature/org-roam-v2"))
      org
      org-agenda
      boxquote
      ))

;; These can be defined for the above packages
;; <layer>/pre-init-<package>
;; <layer>/init-<package>
;; <layer>/post-init-<package>

;; This should be added as code in the pre-init-<package> function always, else :pre-init part of the code will not be called before 'init'
;; (spacemacs|use-package-add-hook helm
;;   :pre-init
;;   ;; Code
;;   :post-init
;;   ;; Code
;;   :pre-config
;;   ;; Code
;;   :post-config
;;   ;; Code
;;   )

(defun gtd/pre-init-vulpea()
  (use-package vulpea
    :ensure t
    :config
    (progn
      (spacemacs/declare-prefix "on" "vulpea...")
      (spacemacs/declare-prefix "ond" "by date...")
      (spacemacs/set-leader-keys
        "ondd" 'vulpea-dailies-date
        "ondt" 'vulpea-dailies-today
        "ondn" 'vulpea-dailies-next
        "ondp" 'vulpea-dailies-prev
        "onf" 'vulpea-find
        "onF" 'vulpea-find-backlink
        "oni" 'vulpea-insert
        "ont" 'vulpea-tags-add
        "onT" 'vulpea-tags-delete
        "ona" 'vulpea-alias-add
        "onA" 'vulpea-alias-delete
        "ool" 'litnotes)
    )
    :init
    (add-hook 'before-save-hook #'vulpea-pre-save-hook)
    (add-to-list 'window-buffer-change-functions
                 #'vulpea-setup-buffer)
    (add-hook 'vulpea-insert-handle-functions
              #'vulpea-insert-handle)
    (setq-default
     vulpea-find-default-filter
     (lambda (note)
       (= (vulpea-note-level note) 0))
     vulpea-insert-default-filter
     (lambda (note)
       (= (vulpea-note-level note) 0))))
  )

(defun gtd/init-vulpea()
  (use-package s
    :ensure t)
  )

(defun gtd/init-boxquote()
  (use-package boxquote
    :defer t))

(defun gtd/pre-init-org-agenda()
  (use-package org-habit
    :defer t
    :commands org-is-habit-p)
  )

(defun gtd/pre-init-org-archive ()
  (spacemacs|use-package-add-hook org-archive
    :post-config
    (progn
      (setq org-archive-mark-done nil)
      (setq org-archive-location "%s_archive::* Archived Tasks")
      )
    )
  )

(defun gtd/post-init-org-agenda()

  (setq org-agenda-span 'day)

  ;; (setq org-agenda-files gtd/org-agenda-files)
  (advice-add 'org-agenda :before #'vulpea-agenda-files-update)

  ;; Do not dim blocked tasks
  (setq org-agenda-dim-blocked-tasks nil)

  ;; Compact the block agenda view
  (setq org-agenda-compact-blocks t)

  ;; Custom agenda command definitions

  (setq org-agenda-custom-commands
        `(
          ("k" "V-Agenda"
           (,vulpea-agenda-cmd-refile
            ,vulpea-agenda-cmd-today
            ,vulpea-agenda-cmd-focus
            ,vulpea-agenda-cmd-waiting)
           ((org-agenda-buffer-name vulpea-agenda-main-buffer-name)))
          ("N" "Notes" tags "NOTE"
           ((org-agenda-overriding-header "Notes")
            (org-tags-match-list-sublevels t)))
          ("h" "Habits" tags-todo "STYLE=\"habit\""
           ((org-agenda-overriding-header "Habits")
            (org-agenda-sorting-strategy
             '(todo-state-down effort-up category-keep))))
          ("o" "Agenda"
                 ((agenda "" nil)
                  (tags "REFILE"
                        ((org-agenda-overriding-header "Tasks to Refile")
                         (org-tags-match-list-sublevels nil)))
                  (tags-todo "-CANCELLED/!"
                             ((org-agenda-overriding-header "Stuck Projects")
                              (org-agenda-skip-function 'bh/skip-non-stuck-projects)
                              (org-agenda-sorting-strategy
                               '(category-keep))))
                  (tags-todo "-HOLD-CANCELLED/!"
                             ((org-agenda-overriding-header "Projects")
                              (org-agenda-skip-function 'bh/skip-non-projects)
                              (org-tags-match-list-sublevels 'indented)
                              (org-agenda-sorting-strategy
                               '(category-keep))))
                  (tags-todo "-CANCELLED/!NEXT"
                             ((org-agenda-overriding-header
                               (concat "Project Next Tasks"
                                       (if bh/hide-scheduled-and-waiting-next-tasks
                                           ""
                                         " (including WAITING and SCHEDULED tasks)")))
                              (org-agenda-skip-function 'bh/skip-projects-and-habits-and-single-tasks)
                              (org-tags-match-list-sublevels t)
                              (org-agenda-todo-ignore-scheduled bh/hide-scheduled-and-waiting-next-tasks)
                              (org-agenda-todo-ignore-deadlines bh/hide-scheduled-and-waiting-next-tasks)
                              (org-agenda-todo-ignore-with-date bh/hide-scheduled-and-waiting-next-tasks)
                              (org-agenda-sorting-strategy
                               '(todo-state-down effort-up category-keep))))
                  (tags-todo "-REFILE-CANCELLED-WAITING-HOLD/!"
                             ((org-agenda-overriding-header
                               (concat "Project Subtasks"
                                       (if bh/hide-scheduled-and-waiting-next-tasks
                                           ""
                                         " (including WAITING and SCHEDULED tasks)")))
                              (org-agenda-skip-function 'bh/skip-non-project-tasks)
                              (org-agenda-todo-ignore-scheduled bh/hide-scheduled-and-waiting-next-tasks)
                              (org-agenda-todo-ignore-deadlines bh/hide-scheduled-and-waiting-next-tasks)
                              (org-agenda-todo-ignore-with-date bh/hide-scheduled-and-waiting-next-tasks)
                              (org-agenda-sorting-strategy
                               '(category-keep))))
                  (tags-todo "-REFILE-CANCELLED-WAITING-HOLD/!"
                             ((org-agenda-overriding-header
                               (concat "Standalone Tasks"
                                       (if bh/hide-scheduled-and-waiting-next-tasks
                                           ""
                                         " (including WAITING and SCHEDULED tasks)")))
                              (org-agenda-skip-function 'bh/skip-project-tasks)
                              (org-agenda-todo-ignore-scheduled bh/hide-scheduled-and-waiting-next-tasks)
                              (org-agenda-todo-ignore-deadlines bh/hide-scheduled-and-waiting-next-tasks)
                              (org-agenda-todo-ignore-with-date bh/hide-scheduled-and-waiting-next-tasks)
                              (org-agenda-sorting-strategy
                               '(category-keep))))
                  (tags-todo "-CANCELLED+WAITING|HOLD/!"
                             ((org-agenda-overriding-header
                               (concat "Waiting and Postponed Tasks"
                                       (if bh/hide-scheduled-and-waiting-next-tasks
                                           ""
                                         " (including WAITING and SCHEDULED tasks)")))
                              (org-agenda-skip-function 'bh/skip-non-tasks)
                              (org-tags-match-list-sublevels nil)
                              (org-agenda-todo-ignore-scheduled bh/hide-scheduled-and-waiting-next-tasks)
                              (org-agenda-todo-ignore-deadlines bh/hide-scheduled-and-waiting-next-tasks)))
                  (tags "-REFILE/"
                        ((org-agenda-overriding-header "Tasks to Archive")
                         (org-agenda-skip-function 'bh/skip-non-archivable-tasks)
                         (org-tags-match-list-sublevels nil))))
                 nil)
          ))

  (setq org-agenda-auto-exclude-function 'bh/org-auto-exclude-function)

  (setq org-agenda-clock-consistency-checks
        (quote (:max-duration "4:00"
                              :min-duration 0
                              :max-gap 0
                              :gap-ok-around ("4:00"))))

  ;; Agenda clock report parameters
  (setq org-agenda-clockreport-parameter-plist
        (quote (:link t :maxlevel 5 :fileskip0 t :compact t :narrow 80)))

  ;; Agenda log mode items to display (closed and state changes by default)
  (setq org-agenda-log-mode-items (quote (closed state)))

  ;; For tag searches ignore tasks with scheduled and deadline dates
  (setq org-agenda-tags-todo-honor-ignore-options gtd/org-agenda-tags-todo-honor-ignore-options)


  ;; Rebuild the reminders everytime the agenda is displayed
  (add-hook 'org-finalize-agenda-hook 'bh/org-agenda-to-appt 'append)

  ;; ;; WARNING!!! Following function call will drastically increase spacemacs launch time.
  ;; ;; This is at the end of my .emacs - so appointments are set up when Emacs starts
  (bh/org-agenda-to-appt)

  ;; Activate appointments so we get notifications,
  ;; but only run this when emacs is idle for 15 seconds
  (run-with-idle-timer 15 nil (lambda () (appt-activate t)))

  ;; If we leave Emacs running overnight - reset the appointments one minute after midnight
  (run-at-time "24:01" nil 'bh/org-agenda-to-appt)


  ;; Limit restriction lock highlighting to the headline only
  (setq org-agenda-restriction-lock-highlight-subtree nil)

  ;; Always hilight the current agenda line
  (add-hook 'org-agenda-mode-hook
            '(lambda () (hl-line-mode 1))
            'append)

  ;; Keep tasks with dates on the global todo lists
  (setq org-agenda-todo-ignore-with-date nil)

  ;; Keep tasks with deadlines on the global todo lists
  (setq org-agenda-todo-ignore-deadlines nil)

  ;; Keep tasks with scheduled dates on the global todo lists
  (setq org-agenda-todo-ignore-scheduled nil)

  ;; Keep tasks with timestamps on the global todo lists
  (setq org-agenda-todo-ignore-timestamp nil)

  ;; Remove completed deadline tasks from the agenda view
  (setq org-agenda-skip-deadline-if-done t)

  ;; Remove completed scheduled tasks from the agenda view
  (setq org-agenda-skip-scheduled-if-done t)

  ;; Remove completed items from search results
  (setq org-agenda-skip-timestamp-if-done t)

  ;; Skip scheduled items if they are repeated beyond the current deadline.
  (setq org-agenda-skip-scheduled-if-deadline-is-shown  (quote repeated-after-deadline))

  (setq org-agenda-include-diary nil)
  (setq org-agenda-diary-file gtd/org-agenda-diary-file)
  (setq org-agenda-insert-diary-extract-time t)

  ;; Include agenda archive files when searching for things
  (setq org-agenda-text-search-extra-files (quote (agenda-archives))))


;; (defun gtd/pre-init-org ()
;;   (spacemacs|use-package-add-hook org
;;     :post-config
;;     (progn
;;       (setq org-default-notes-file gtd/org-default-notes-file)
;; )))

(defun gtd/post-init-org ()

  (use-package org-id
    :defer t
    :init
    (add-hook 'before-save-hook #'vulpea-id-auto-assign)
    (add-hook 'org-capture-prepare-finalize-hook #'org-id-get-create))

  (add-to-list 'auto-mode-alist '("\\.\\(org\\|org_archive\\|txt\\)$" . org-mode))


  ;; =TODO= state keywords and colour settings:
  (setq org-todo-keywords
        (quote ((sequence "TODO(t)" "NEXT(n)" "|" "DONE(d!)")
                (sequence "WAITING(w@/!)" "HOLD(h@/!)" "|" "CANCELLED(c@/!)" "PHONE" "MEETING"))))

  ;; ;; TODO Other todo keywords doesn't have appropriate faces yet. They should
  ;; ;; have faces similar to spacemacs defaults.
  (setq org-todo-keyword-faces gtd/org-todo-keyword-faces)

  (setq
   ;; use fast todo selection
   org-use-fast-todo-selection t
   org-log-states-order-reversed t
   ;; use drawer for state changes
   org-log-into-drawer t
   org-reverse-note-order t
   org-tag-persistent-alist '(("FOCUS" . ?f)
                              ("PROJECT" . ?p))
   org-use-tag-inheritance t
   org-tags-exclude-from-inheritance '("project"
                                       "litnotes"
                                       "people")
   ;; block parent until children are done
   org-enforce-todo-dependencies t
   )

  ;; This cycles through the todo states but skips setting timestamps and
  ;; entering notes which is very convenient when all you want to do is fix
  ;; up the status of an entry.
  (setq org-treat-S-cursor-todo-selection-as-state-change nil)

  (setq org-todo-state-tags-triggers
        (quote (("CANCELLED" ("CANCELLED" . t))
                ("WAITING" ("WAITING" . t))
                ("HOLD" ("WAITING") ("HOLD" . t))
                (done ("WAITING") ("HOLD") ("FOCUS"))
                ("TODO" ("WAITING") ("CANCELLED") ("HOLD"))
                ("NEXT" ("WAITING") ("CANCELLED") ("HOLD"))
                ("DONE" ("WAITING") ("CANCELLED") ("HOLD")))))

  ;; (setq org-directory "~/git/org")

  ;; Capture templates for: TODO tasks, Notes, appointments, phone calls,
  ;; meetings, and org-protocol
  (setq org-capture-templates gtd/org-capture-templates)

  ;; Remove empty LOGBOOK drawers on clock out
  (add-hook 'org-clock-out-hook 'bh/remove-empty-drawer-on-clock-out 'append)

  ;; Targets include this file and any file contributing to the agenda - up to 9 levels deep
  (setq org-refile-targets (quote ((nil :maxlevel . 9)
                                   (org-agenda-files :maxlevel . 9))))

  ;; Use full outline paths for refile targets - we file directly with IDO
  (setq org-refile-use-outline-path t)

  ;; ;; Targets complete directly with IDO
  ;; (setq org-outline-path-complete-in-steps nil)

  ;; Allow refile to create parent tasks with confirmation
  (setq org-refile-allow-creating-parent-nodes (quote confirm))

  ;;   ;; ;; Use IDO for both buffer and file completion and ido-everywhere to t
  ;;   ;; (setq org-completion-use-ido t)
  ;;   ;; (setq ido-everywhere t)
  ;;   ;; (setq ido-max-directory-size 100000)
  ;;   ;; (ido-mode (quote both))
  ;;   ;; ;; Use the current window when visiting files and buffers with ido
  ;;   ;; (setq ido-default-file-method 'selected-window)
  ;;   ;; (setq ido-default-buffer-method 'selected-window)
  ;;   ;; ;; Use the current window for indirect buffer display
  ;;   ;; (setq org-indirect-buffer-display 'current-window)

;;;; Refile settings
  ;; Exclude DONE state tasks from refile targets
  (setq org-refile-target-verify-function #'vulpea-refile-verify-target)

  ;; Show lot of clocking history so it's easy to pick items off the C-F11 list
  (setq org-clock-history-length 23)
  ;; Resume clocking task on clock-in if the clock is open
  (setq org-clock-in-resume t)
  ;; Change tasks to NEXT when clocking in
  (setq org-clock-in-switch-to-state 'bh/clock-in-to-next)
  ;; Separate drawers for clocking and logs
  (setq org-drawers (quote ("PROPERTIES" "LOGBOOK")))
  ;; Save clock data and state changes and notes in the LOGBOOK drawer
  (setq org-clock-into-drawer t)
  ;; Sometimes I change tasks I'm clocking quickly - this removes clocked tasks with 0:00 duration
  (setq org-clock-out-remove-zero-time-clocks t)
  ;; Clock out when moving task to a done state
  (setq org-clock-out-when-done t)
  ;; Save the running clock and all clock history when exiting Emacs, load it on startup
  (setq org-clock-persist t)
  ;; Do not prompt to resume an active clock
  (setq org-clock-persist-query-resume nil)
  ;; Enable auto clock resolution for finding open clocks
  (setq org-clock-auto-clock-resolution (quote when-no-clock-is-running))
  ;; Include current clocking task in clock reports
  (setq org-clock-report-include-clocking-task t)
  ;; Resolve open clocks if the user is idle for more than 10 minutes.
  (setq org-clock-idle-time 10)
  ;;
  ;; Resume clocking task when emacs is restarted
  (org-clock-persistence-insinuate)

  (setq bh/keep-clock-running nil)


  (add-hook 'org-clock-out-hook 'bh/clock-out-maybe 'append)

  (setq org-time-stamp-rounding-minutes (quote (1 1)))
  ;; ;; Sometimes I change tasks I'm clocking quickly - this removes clocked
  ;; ;; tasks with 0:00 duration
  ;; (setq org-clock-out-remove-zero-time-clocks t)

  ;; Set default column view headings: Task Effort Clock_Summary
  (setq org-columns-default-format
        "%50ITEM(Task) %10TODO %3PRIORITY %TAGS %10Effort(Effort){:} %10CLOCKSUM")
  ;; global Effort estimate values
  ;; global STYLE property values for completion
  (setq org-global-properties (quote (("Effort_ALL" . "0:15 0:30 0:45 1:00 2:00 3:00 4:00 5:00 6:00 0:00")
                                      ("STYLE_ALL" . "habit"))))
  ;; Tags with fast selection keys
  (setq org-tag-alist gtd/org-tag-alist)

  ;; Allow setting single tags without the menu
  (setq org-fast-tag-selection-single-key gtd/org-fast-tag-selection-single-key)
  ;; Disable the default org-mode stuck projects agenda view
  (setq org-stuck-projects (quote ("" nil nil "")))

  (setq org-list-allow-alphabetical t)

  (setq org-ditaa-jar-path "~/.emacs.d/private/gtd/ditaa.jar")
  (setq org-plantuml-jar-path "~/.emacs.d/private/gtd/plantuml.jar")

  (add-hook 'org-babel-after-execute-hook 'bh/display-inline-images 'append)

  ;; Make babel results blocks lowercase
  (setq org-babel-results-keyword "results")


  (org-babel-do-load-languages
   (quote org-babel-load-languages)
   gtd/org-babel-do-load-languages)

  ;; Do not prompt to confirm evaluation
  ;; This may be dangerous - make sure you understand the consequences
  ;; of setting this -- see the docstring for details
  (setq org-confirm-babel-evaluate nil)

  ;; Use fundamental mode when editing plantuml blocks with C-c '
  (add-to-list 'org-src-lang-modes (quote ("plantuml" . fundamental)))

  ;; Don't enable this because it breaks access to emacs from my
  ;; Android phone
  (setq org-startup-with-inline-images nil)

  ;; Adding hooks to save all org buffers after some changes
  (advice-add 'org-refile :after (lambda (&rest _) (org-save-all-org-buffers)))
  (advice-add 'org-agenda-refile :after (lambda (&rest _) (org-save-all-org-buffers)))
  (advice-add 'org-agenda-bulk-action :after (lambda (&rest _) (org-save-all-org-buffers)))
  (advice-add 'org-todo :after (lambda (&rest _) (org-save-all-org-buffers)))
  (advice-add 'org-capture :after (lambda (&rest _) (org-save-all-org-buffers)))

  ;; (add-hook 'auto-save-hook 'org-save-all-org-buffers)

  ;;; Custom setup from d12frosted vulpea library and using org-roam-v2

  (setq org-agenda-prefix-format
        '((agenda . " %i %-12(vulpea-agenda-category 12)%?-12t% s")
          (todo . " %i %-12(vulpea-agenda-category 12) ")
          (tags . " %i %-12(vulpea-agenda-category 12) ")
          (search . " %i %-12(vulpea-agenda-category 12) ")))

  ;; (add-to-list 'org-tags-exclude-from-inheritance '("project" "litnotes" "people"))
  (add-hook 'find-file-hook #'vulpea-project-update-tag)
  (add-hook 'before-save-hook #'vulpea-project-update-tag)
  ;; (advise-add 'org-agenda :before #'vulpea-agenda-files-update)


  ;; avoid noisy `org-check-agenda-file'
  (advice-add #'org-check-agenda-file
              :around
              #'vulpea-check-agenda-file)

  ;; (add-hook 'before-save-hook #'+org-auto-id-add-to-headlines-in-file)

  ;; open directory links in `dired'
  (add-to-list 'org-file-apps '(directory . emacs))

  ;; open files in the same window
  (add-to-list 'org-link-frame-setup '(file . find-file))
  (setq org-indirect-buffer-display 'current-window)

  (setq org-directory vulpea-directory)

  )

;; EOF
