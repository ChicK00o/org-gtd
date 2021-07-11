
;;; Thrid File to be loaded Layers -> Package -> Funcs -> Config -> Keybinding

;; (when (configuration-layer/package-used-p 'gtd)

(defun bh/org-auto-exclude-function (tag)
  "Automatic task exclusion in the agenda with / RET"
  (and
   (loop for ctag in gtd/agenda-exclude-fast do (if (string= tag ctag ) (return t)))
   (concat "-" tag)))


;; Erase all reminders and rebuilt reminders for today from the agenda
(defun bh/org-agenda-to-appt ()
  (interactive)
  (setq appt-time-msg-list nil)
  (org-agenda-to-appt))

(defun bh/org-todo (arg)
  (interactive "p")
  (if (equal arg 4)
      (save-restriction
        (bh/narrow-to-org-subtree)
        (org-show-todo-tree nil))
    (bh/narrow-to-org-subtree)
    (org-show-todo-tree nil)))

(defun bh/widen ()
  (interactive)
  (if (equal major-mode 'org-agenda-mode)
      (progn
        (org-agenda-remove-restriction-lock)
        (when org-agenda-sticky
          (org-agenda-redo)))
    (widen)))

(defun bh/restrict-to-file-or-follow (arg)
  "Set agenda restriction to 'file or with argument invoke follow mode.
I don't use follow mode very often but I restrict to file all the time
so change the default 'F' binding in the agenda to allow both"
  (interactive "p")
  (if (equal arg 4)
      (org-agenda-follow-mode)
    (widen)
    (bh/set-agenda-restriction-lock 4)
    (org-agenda-redo)
    (beginning-of-buffer)))

(defun bh/narrow-to-org-subtree ()
  (widen)
  (org-narrow-to-subtree)
  (save-restriction
    (org-agenda-set-restriction-lock)))

(defun bh/narrow-to-subtree ()
  (interactive)
  (if (equal major-mode 'org-agenda-mode)
      (progn
        (org-with-point-at (org-get-at-bol 'org-hd-marker)
          (bh/narrow-to-org-subtree))
        (when org-agenda-sticky
          (org-agenda-redo)))
    (bh/narrow-to-org-subtree)))


(defun bh/narrow-up-one-org-level ()
  (widen)
  (save-excursion
    (outline-up-heading 1 'invisible-ok)
    (bh/narrow-to-org-subtree)))

(defun bh/get-pom-from-agenda-restriction-or-point ()
  (or (and (marker-position org-agenda-restrict-begin) org-agenda-restrict-begin)
      (org-get-at-bol 'org-hd-marker)
      (and (equal major-mode 'org-mode) (point))
      org-clock-marker))

(defun bh/narrow-up-one-level ()
  (interactive)
  (if (equal major-mode 'org-agenda-mode)
      (progn
        (org-with-point-at (bh/get-pom-from-agenda-restriction-or-point)
          (bh/narrow-up-one-org-level))
        (org-agenda-redo))
    (bh/narrow-up-one-org-level)))

(defun bh/narrow-to-org-project ()
  (widen)
  (save-excursion
    (bh/find-project-task)
    (bh/narrow-to-org-subtree)))

(defun bh/narrow-to-project ()
  (interactive)
  (if (equal major-mode 'org-agenda-mode)
      (progn
        (org-with-point-at (bh/get-pom-from-agenda-restriction-or-point)
          (bh/narrow-to-org-project)
          (save-excursion
            (bh/find-project-task)))
        (org-agenda-redo)
        (beginning-of-buffer))
    (bh/narrow-to-org-project)
    (save-restriction
      (org-agenda-set-restriction-lock))))

(defun bh/view-next-project ()
    (interactive)
    (let (num-project-left current-project)
      (unless (marker-position org-agenda-restrict-begin)
        (goto-char (point-min))
                                        ; Clear all of the existing markers on the list
        (while bh/project-list
          (set-marker (pop bh/project-list) nil))
        (re-search-forward "Tasks to Refile")
        (forward-visible-line 1))

                                        ; Build a new project marker list
      (unless bh/project-list
        (while (< (point) (point-max))
          (while (and (< (point) (point-max))
                      (or (not (org-get-at-bol 'org-hd-marker))
                          (org-with-point-at (org-get-at-bol 'org-hd-marker)
                            (or (not (bh/is-project-p))
                                (bh/is-project-subtree-p)))))
            (forward-visible-line 1))
          (when (< (point) (point-max))
            (add-to-list 'bh/project-list (copy-marker (org-get-at-bol 'org-hd-marker)) 'append))
          (forward-visible-line 1)))

                                        ; Pop off the first marker on the list and display
      (setq current-project (pop bh/project-list))
      (when current-project
        (org-with-point-at current-project
          (setq bh/hide-scheduled-and-waiting-next-tasks nil)
          (bh/narrow-to-project))
                                        ; Remove the marker
        (setq current-project nil)
        (org-agenda-redo)
        (beginning-of-buffer)
        (setq num-projects-left (length bh/project-list))
        (if (> num-projects-left 0)
            (message "%s projects left to view" num-projects-left)
          (beginning-of-buffer)
          (setq bh/hide-scheduled-and-waiting-next-tasks t)
          (error "All projects viewed.")))))

(defun bh/set-agenda-restriction-lock (arg)
  "Set restriction lock to current task subtree or file if prefix is specified"
  (interactive "p")
  (let* ((pom (bh/get-pom-from-agenda-restriction-or-point))
         (tags (org-with-point-at pom (org-get-tags-at))))
    (let ((restriction-type (if (equal arg 4) 'file 'subtree)))
      (save-restriction
        (cond
         ((and (equal major-mode 'org-agenda-mode) pom)
          (org-with-point-at pom
            (org-agenda-set-restriction-lock restriction-type))
          (org-agenda-redo))
         ((and (equal major-mode 'org-mode) (org-before-first-heading-p))
          (org-agenda-set-restriction-lock 'file))
         (pom
          (org-with-point-at pom
            (org-agenda-set-restriction-lock restriction-type))))))))

(defun bh/clock-in-task-by-id (id)
  "Clock in a task by id"
  (org-with-point-at (org-id-find id 'marker)
    (org-clock-in nil)))

(defun bh/clock-in-organization-task-as-default ()
  (interactive)
  (org-with-point-at (org-id-find bh/organization-task-id 'marker)
    (org-clock-in '(16))))

(defun bh/hide-other ()
  (interactive)
  (save-excursion
    (org-back-to-heading 'invisible-ok)
    (hide-other)
    (org-cycle)
    (org-cycle)
    (org-cycle)))

(defun bh/set-truncate-lines ()
  "Toggle value of truncate-lines and refresh window display."
  (interactive)
  (setq truncate-lines (not truncate-lines))
  ;; now refresh window display (an idiom from simple.el):
  (save-excursion
    (set-window-start (selected-window)
                      (window-start (selected-window)))))

(defun bh/make-org-scratch ()
  (interactive)
  (find-file "/tmp/publish/scratch.org")
  (gnus-make-directory "/tmp/publish"))

(defun bh/switch-to-scratch ()
  (interactive)
  (switch-to-buffer "*scratch*"))

(defun bh/remove-empty-drawer-on-clock-out ()
  (interactive)
  (save-excursion
    (beginning-of-line 0)
    ;; Following line from original document by Bernt Hansen
    ;; will lead to an error, next to it is the corrected form.
    ;; (org-remove-empty-drawer-at "LOGBOOK" (point))
    (org-remove-empty-drawer-at (point))))


(defun bh/verify-refile-target ()
  "Exclude todo keywords with a done state from refile targets"
  (not (member (nth 2 (org-heading-components)) org-done-keywords)))

(defun bh/clock-in-to-next (kw)
  "Switch a task from TODO to NEXT when clocking in.
Skips capture tasks, projects, and subprojects.
Switch projects and subprojects from NEXT back to TODO"
  (when (not (and (boundp 'org-capture-mode) org-capture-mode))
    (cond
     ((and (member (org-get-todo-state) (list "TODO"))
           (bh/is-task-p))
      "NEXT")
     ((and (member (org-get-todo-state) (list "NEXT"))
           (bh/is-project-p))
      "TODO"))))

(defun bh/find-project-task ()
  "Move point to the parent (project) task if any"
  (save-restriction
    (widen)
    (let ((parent-task (save-excursion (org-back-to-heading 'invisible-ok) (point))))
      (while (org-up-heading-safe)
        (when (member (nth 2 (org-heading-components)) org-todo-keywords-1)
          (setq parent-task (point))))
      (goto-char parent-task)
      parent-task)))

(defun bh/punch-in (arg)
  "Start continuous clocking and set the default task to the
selected task.  If no task is selected set the Organization task
as the default task."
  (interactive "p")
  (setq bh/keep-clock-running t)
  (if (equal major-mode 'org-agenda-mode)
      ;;
      ;; We're in the agenda
      ;;
      (let* ((marker (org-get-at-bol 'org-hd-marker))
             (tags (org-with-point-at marker (org-get-tags-at))))
        (if (and (eq arg 4) tags)
            (org-agenda-clock-in '(16))
          (bh/clock-in-organization-task-as-default)))
    ;;
    ;; We are not in the agenda
    ;;
    (save-restriction
      (widen)
      ;; Find the tags on the current task
      (if (and (equal major-mode 'org-mode) (not (org-before-first-heading-p)) (eq arg 4))
          (org-clock-in '(16))
        (bh/clock-in-organization-task-as-default)))))


(defun bh/punch-out ()
  (interactive)
  (setq bh/keep-clock-running nil)
  (when (org-clock-is-active)
    (org-clock-out))
  (org-agenda-remove-restriction-lock))


(defun bh/clock-in-default-task ()
  (save-excursion
    (org-with-point-at org-clock-default-task
      (org-clock-in))))


(defun bh/clock-in-parent-task ()
  "Move point to the parent (project) task if any and clock in"
  (let ((parent-task))
    (save-excursion
      (save-restriction
        (widen)
        (while (and (not parent-task) (org-up-heading-safe))
          (when (member (nth 2 (org-heading-components)) org-todo-keywords-1)
            (setq parent-task (point))))
        (if parent-task
            (org-with-point-at parent-task
              (org-clock-in))
          (when bh/keep-clock-running
            (bh/clock-in-default-task)))))))


(defun bh/clock-out-maybe ()
  (when (and bh/keep-clock-running
             (not org-clock-clocking-in)
             (marker-buffer org-clock-default-task)
             (not org-clock-resolving-clocks-due-to-idleness))
    (bh/clock-in-parent-task)))


(defun bh/clock-in-last-task (arg)
  "Clock in the interrupted task if there is one
Skip the default task and get the next one.
A prefix arg forces clock in of the default task."
  (interactive "p")
  (let ((clock-in-to-task
         (cond
          ((eq arg 4) org-clock-default-task)
          ((and (org-clock-is-active)
                (equal org-clock-default-task (cadr org-clock-history)))
           (caddr org-clock-history))
          ((org-clock-is-active) (cadr org-clock-history))
          ((equal org-clock-default-task (car org-clock-history)) (cadr org-clock-history))
          (t (car org-clock-history)))))
    (widen)
    (org-with-point-at clock-in-to-task
      (org-clock-in nil))))

(defun bh/is-project-p ()
  "Any task with a todo keyword subtask"
  (save-restriction
    (widen)
    (let ((has-subtask)
          (subtree-end (save-excursion (org-end-of-subtree t)))
          (is-a-task (member (nth 2 (org-heading-components)) org-todo-keywords-1)))
      (save-excursion
        (forward-line 1)
        (while (and (not has-subtask)
                    (< (point) subtree-end)
                    (re-search-forward "^\*+ " subtree-end t))
          (when (member (org-get-todo-state) org-todo-keywords-1)
            (setq has-subtask t))))
      (and is-a-task has-subtask))))

 (defun bh/is-project-subtree-p ()
    "Any task with a todo keyword that is in a project subtree.
Callers of this function already widen the buffer view."
    (let ((task (save-excursion (org-back-to-heading 'invisible-ok)
                                (point))))
      (save-excursion
        (bh/find-project-task)
        (if (equal (point) task)
            nil
          t))))

  (defun bh/is-task-p ()
    "Any task with a todo keyword and no subtask"
    (save-restriction
      (widen)
      (let ((has-subtask)
            (subtree-end (save-excursion (org-end-of-subtree t)))
            (is-a-task (member (nth 2 (org-heading-components)) org-todo-keywords-1)))
        (save-excursion
          (forward-line 1)
          (while (and (not has-subtask)
                      (< (point) subtree-end)
                      (re-search-forward "^\*+ " subtree-end t))
            (when (member (org-get-todo-state) org-todo-keywords-1)
              (setq has-subtask t))))
        (and is-a-task (not has-subtask)))))

  (defun bh/is-subproject-p ()
    "Any task which is a subtask of another project"
    (let ((is-subproject)
          (is-a-task (member (nth 2 (org-heading-components)) org-todo-keywords-1)))
      (save-excursion
        (while (and (not is-subproject) (org-up-heading-safe))
          (when (member (nth 2 (org-heading-components)) org-todo-keywords-1)
            (setq is-subproject t))))
      (and is-a-task is-subproject)))

  (defun bh/list-sublevels-for-projects-indented ()
    "Set org-tags-match-list-sublevels so when restricted to a subtree we list all subtasks.
  This is normally used by skipping functions where this variable is already local to the agenda."
    (if (marker-buffer org-agenda-restrict-begin)
        (setq org-tags-match-list-sublevels 'indented)
      (setq org-tags-match-list-sublevels nil))
    nil)

  (defun bh/list-sublevels-for-projects ()
    "Set org-tags-match-list-sublevels so when restricted to a subtree we list all subtasks.
  This is normally used by skipping functions where this variable is already local to the agenda."
    (if (marker-buffer org-agenda-restrict-begin)
        (setq org-tags-match-list-sublevels t)
      (setq org-tags-match-list-sublevels nil))
    nil)

 (defun bh/toggle-next-task-display ()
    (interactive)
    (setq bh/hide-scheduled-and-waiting-next-tasks (not bh/hide-scheduled-and-waiting-next-tasks))
    (when  (equal major-mode 'org-agenda-mode)
      (org-agenda-redo))
    (message "%s WAITING and SCHEDULED NEXT Tasks" (if bh/hide-scheduled-and-waiting-next-tasks "Hide" "Show")))

  (defun bh/skip-stuck-projects ()
    "Skip trees that are not stuck projects"
    (save-restriction
      (widen)
      (let ((next-headline (save-excursion (or (outline-next-heading) (point-max)))))
        (if (bh/is-project-p)
            (let* ((subtree-end (save-excursion (org-end-of-subtree t)))
                   (has-next ))
              (save-excursion
                (forward-line 1)
                (while (and (not has-next) (< (point) subtree-end) (re-search-forward "^\\*+ NEXT " subtree-end t))
                  (unless (member "WAITING" (org-get-tags-at))
                    (setq has-next t))))
              (if has-next
                  nil
                next-headline)) ; a stuck project, has subtasks but no next task
          nil))))

  (defun bh/skip-non-stuck-projects ()
    "Skip trees that are not stuck projects"
    ;; (bh/list-sublevels-for-projects-indented)
    (save-restriction
      (widen)
      (let ((next-headline (save-excursion (or (outline-next-heading) (point-max)))))
        (if (bh/is-project-p)
            (let* ((subtree-end (save-excursion (org-end-of-subtree t)))
                   (has-next ))
              (save-excursion
                (forward-line 1)
                (while (and (not has-next) (< (point) subtree-end) (re-search-forward "^\\*+ NEXT " subtree-end t))
                  (unless (member "WAITING" (org-get-tags-at))
                    (setq has-next t))))
              (if has-next
                  next-headline
                nil)) ; a stuck project, has subtasks but no next task
          next-headline))))

  (defun bh/skip-non-projects ()
    "Skip trees that are not projects"
    ;; (bh/list-sublevels-for-projects-indented)
    (if (save-excursion (bh/skip-non-stuck-projects))
        (save-restriction
          (widen)
          (let ((subtree-end (save-excursion (org-end-of-subtree t))))
            (cond
             ((bh/is-project-p)
              nil)
             ((and (bh/is-project-subtree-p) (not (bh/is-task-p)))
              nil)
             (t
              subtree-end))))
      (save-excursion (org-end-of-subtree t))))

  (defun bh/skip-non-tasks ()
    "Show non-project tasks.
Skip project and sub-project tasks, habits, and project related tasks."
    (save-restriction
      (widen)
      (let ((next-headline (save-excursion (or (outline-next-heading) (point-max)))))
        (cond
         ((bh/is-task-p)
          nil)
         (t
          next-headline)))))

  (defun bh/skip-project-trees-and-habits ()
    "Skip trees that are projects"
    (save-restriction
      (widen)
      (let ((subtree-end (save-excursion (org-end-of-subtree t))))
        (cond
         ((bh/is-project-p)
          subtree-end)
         ((org-is-habit-p)
          subtree-end)
         (t
          nil)))))

  (defun bh/skip-projects-and-habits-and-single-tasks ()
    "Skip trees that are projects, tasks that are habits, single non-project tasks"
    (save-restriction
      (widen)
      (let ((next-headline (save-excursion (or (outline-next-heading) (point-max)))))
        (cond
         ((org-is-habit-p)
          next-headline)
         ((and bh/hide-scheduled-and-waiting-next-tasks
               (member "WAITING" (org-get-tags-at)))
          next-headline)
         ((bh/is-project-p)
          next-headline)
         ((and (bh/is-task-p) (not (bh/is-project-subtree-p)))
          next-headline)
         (t
          nil)))))

  (defun bh/skip-project-tasks-maybe ()
    "Show tasks related to the current restriction.
When restricted to a project, skip project and sub project tasks, habits, NEXT tasks, and loose tasks.
When not restricted, skip project and sub-project tasks, habits, and project related tasks."
    (save-restriction
      (widen)
      (let* ((subtree-end (save-excursion (org-end-of-subtree t)))
             (next-headline (save-excursion (or (outline-next-heading) (point-max))))
             (limit-to-project (marker-buffer org-agenda-restrict-begin)))
        (cond
         ((bh/is-project-p)
          next-headline)
         ((org-is-habit-p)
          subtree-end)
         ((and (not limit-to-project)
               (bh/is-project-subtree-p))
          subtree-end)
         ((and limit-to-project
               (bh/is-project-subtree-p)
               (member (org-get-todo-state) (list "NEXT")))
          subtree-end)
         (t
          nil)))))

  (defun bh/skip-project-tasks ()
    "Show non-project tasks.
Skip project and sub-project tasks, habits, and project related tasks."
    (save-restriction
      (widen)
      (let* ((subtree-end (save-excursion (org-end-of-subtree t))))
        (cond
         ((bh/is-project-p)
          subtree-end)
         ((org-is-habit-p)
          subtree-end)
         ((bh/is-project-subtree-p)
          subtree-end)
         (t
          nil)))))

  (defun bh/skip-non-project-tasks ()
    "Show project tasks.
Skip project and sub-project tasks, habits, and loose non-project tasks."
    (save-restriction
      (widen)
      (let* ((subtree-end (save-excursion (org-end-of-subtree t)))
             (next-headline (save-excursion (or (outline-next-heading) (point-max)))))
        (cond
         ((bh/is-project-p)
          next-headline)
         ((org-is-habit-p)
          subtree-end)
         ((and (bh/is-project-subtree-p)
               (member (org-get-todo-state) (list "NEXT")))
          subtree-end)
         ((not (bh/is-project-subtree-p))
          subtree-end)
         (t
          nil)))))

  (defun bh/skip-projects-and-habits ()
    "Skip trees that are projects and tasks that are habits"
    (save-restriction
      (widen)
      (let ((subtree-end (save-excursion (org-end-of-subtree t))))
        (cond
         ((bh/is-project-p)
          subtree-end)
         ((org-is-habit-p)
          subtree-end)
         (t
          nil)))))

  (defun bh/skip-non-subprojects ()
    "Skip trees that are not projects"
    (let ((next-headline (save-excursion (outline-next-heading))))
      (if (bh/is-subproject-p)
          nil
        next-headline)))

  ;; (setq org-archive-mark-done nil)
  ;; (setq org-archive-location "%s_archive::* Archived Tasks")

  (defun bh/skip-non-archivable-tasks ()
    "Skip trees that are not available for archiving"
    (save-restriction
      (widen)
      ;; Consider only tasks with done todo headings as archivable candidates
      (let ((next-headline (save-excursion (or (outline-next-heading) (point-max))))
            (subtree-end (save-excursion (org-end-of-subtree t))))
        (if (member (org-get-todo-state) org-todo-keywords-1)
            (if (member (org-get-todo-state) org-done-keywords)
                (let* ((daynr (string-to-number (format-time-string "%d" (current-time))))
                       (a-month-ago (* 60 60 24 (+ daynr 1)))
                       (last-month (format-time-string "%Y-%m-" (time-subtract (current-time) (seconds-to-time a-month-ago))))
                       (this-month (format-time-string "%Y-%m-" (current-time)))
                       (subtree-is-current (save-excursion
                                             (forward-line 1)
                                             (and (< (point) subtree-end)
                                                  (re-search-forward (concat last-month "\\|" this-month) subtree-end t)))))
                  (if subtree-is-current
                      subtree-end ; Has a date in this month or last month, skip it
                    nil))  ; available to archive
              (or subtree-end (point-max)))
          next-headline))))


(defun bh/display-inline-images ()
  (condition-case nil
      (org-display-inline-images)
    (error nil)))

(defun bh/org-clock-select-task ()
  (interactive)
  (org-clock-select-task))


;;; Vulpea agenda lib
;; https://github.com/d12frosted/environment/blob/master/emacs/lisp/lib-vulpea-agenda.el

(defun vulpea-agenda-main ()
  "Show main `org-agenda' view."
  (interactive)
  (org-agenda nil "k"))


(defun vulpea-agenda-person ()
  "Show main `org-agenda' view."
  (interactive)
  (let* ((person (vulpea-select
                  "Person"
                  :filter-fn
                  (lambda (note)
                    (seq-contains-p (vulpea-note-tags note)
                                    "people"))))
         (node (org-roam-node-from-id (vulpea-note-id person)))
         (names (cons (org-roam-node-title node)
                      (org-roam-node-aliases node)))
         (tags (seq-map #'vulpea--title-to-tag names))
         (query (string-join tags "|")))
    (dlet ((org-agenda-overriding-arguments (list t query)))
      (org-agenda nil "M"))))

(defun vulpea-agenda-files-update (&rest _)
  "Update the value of 'org-agenda-files'."
  (setq org-agenda-files (vulpea-project-files)))

;; Commands

(defconst vulpea-agenda-cmd-refile
  '(tags
    "REFILE"
    ((org-agenda-overriding-header "To refile")
     (org-tags-match-list-sublevels nil))))

(defconst vulpea-agenda-cmd-today
  '(agenda
    ""
    ((org-agenda-span 'day)
     (org-agenda-skip-deadline-prewarning-if-scheduled t)
     (org-agenda-sorting-strategy '(habit-down
                                    time-up
                                    category-keep
                                    todo-state-down
                                    priority-down)))))

(defconst vulpea-agenda-cmd-focus
  '(tags-todo
    "FOCUS"
    ((org-agenda-overriding-header
      (concat "To focus on"
              (if vulpea-agenda-hide-scheduled-and-waiting-next-tasks
                  ""
                " (including WAITING and SCHEDULED tasks)")))
     (org-agenda-skip-function 'vulpea-agenda-skip-habits)
     (org-tags-match-list-sublevels t)
     (org-agenda-todo-ignore-scheduled
      vulpea-agenda-hide-scheduled-and-waiting-next-tasks)
     (org-agenda-todo-ignore-deadlines
      vulpea-agenda-hide-scheduled-and-waiting-next-tasks)
     (org-agenda-todo-ignore-with-date
      vulpea-agenda-hide-scheduled-and-waiting-next-tasks)
     (org-agenda-tags-todo-honor-ignore-options t)
     (org-agenda-sorting-strategy
      '(todo-state-down priority-down effort-up category-keep)))))

(defconst vulpea-agenda-cmd-stuck-projects
  '(tags-todo
    "PROJECT-CANCELLED-HOLD/!"
    ((org-agenda-overriding-header "Stuck Projects")
     (org-agenda-skip-function 'vulpea-agenda-skip-non-stuck-projects)
     (org-agenda-sorting-strategy
      '(todo-state-down priority-down effort-up category-keep)))))

(defconst vulpea-agenda-cmd-projects
  '(tags-todo
    "PROJECT-HOLD"
    ((org-agenda-overriding-header (concat "Projects"))
     (org-tags-match-list-sublevels t)
     (org-agenda-skip-function 'vulpea-agenda-skip-non-projects)
     (org-agenda-tags-todo-honor-ignore-options t)
     (org-agenda-sorting-strategy
      '(todo-state-down priority-down effort-up category-keep)))))

(defconst vulpea-agenda-cmd-waiting
  '(tags-todo
    "-CANCELLED+WAITING-READING-FOCUS|+HOLD/!"
    ((org-agenda-overriding-header
      (concat "Waiting and Postponed Tasks"
              (if vulpea-agenda-hide-scheduled-and-waiting-next-tasks
                  ""
                " (including WAITING and SCHEDULED tasks)")))
     (org-agenda-skip-function 'vulpea-agenda-skip-non-tasks)
     (org-tags-match-list-sublevels nil)
     (org-agenda-todo-ignore-scheduled
      vulpea-agenda-hide-scheduled-and-waiting-next-tasks)
     (org-agenda-todo-ignore-deadlines
      vulpea-agenda-hide-scheduled-and-waiting-next-tasks))))

;; Utilities to build agenda commands -- skip

(defun vulpea-agenda-skip-habits ()
  "Skip tasks that are habits."
  (save-restriction
    (widen)
    (let ((subtree-end (save-excursion (org-end-of-subtree t))))
      (cond
       ((org-is-habit-p)
        subtree-end)
       (t
        nil)))))

(defun vulpea-agenda-skip-non-projects ()
  "Skip trees that are not projects."
  (if (save-excursion (vulpea-agenda-skip-non-stuck-projects))
      (save-restriction
        (widen)
        (let ((subtree-end (save-excursion (org-end-of-subtree t))))
          (cond
           ((vulpea-agenda-project-p)
            nil)
           ((and (vulpea-agenda-project-subtree-p)
                 (not (vulpea-agenda-task-p)))
            nil)
           (t
            subtree-end))))
    (save-excursion (org-end-of-subtree t))))

(defun vulpea-agenda-skip-non-tasks ()
  "Show non-project tasks.
Skip project and sub-project tasks, habits, and project related
tasks."
  (save-restriction
    (widen)
    (let ((next-headline (save-excursion
                           (or (outline-next-heading)
                               (point-max)))))
      (cond
       ((vulpea-agenda-task-p)
        nil)
       (t
        next-headline)))))

(defun vulpea-agenda-skip-non-stuck-projects ()
  "Skip trees that are not stuck projects."
  (save-restriction
    (widen)
    (let ((next-headline (save-excursion
                           (or (outline-next-heading)
                               (point-max)))))
      (if (vulpea-agenda-project-p)
          (let* ((subtree-end (save-excursion
                                (org-end-of-subtree t)))
                 (has-next ))
            (save-excursion
              (forward-line 1)
              (while (and (not has-next)
                          (< (point) subtree-end)
                          (re-search-forward "^\\*+ TODO "
                                             subtree-end t))
                (unless (member "WAITING" (org-get-tags))
                  (setq has-next t))))
            (if has-next
                next-headline
              nil)) ; a stuck project, has subtasks but no next task
        next-headline))))

;; Utilities to build agenda commands -- predicates

(defun vulpea-agenda-project-p ()
  "Return non-nil if the heading at point is a project.
Basically, it's any item with some todo keyword and tagged as
PROJECT."
  (let* ((comps (org-heading-components))
         (todo (nth 2 comps))
         (tags (split-string (or (nth 5 comps) "") ":")))
    (and (member todo org-todo-keywords-1)
         (member "PROJECT" tags))))

(defun vulpea-agenda-project-subtree-p ()
  "Any task with a todo keyword that is in a project subtree.
Callers of this function already widen the buffer view."
  (let ((task (save-excursion (org-back-to-heading 'invisible-ok)
                              (point))))
    (save-excursion
      (vulpea-agenda-find-project-task)
      (if (equal (point) task)
          nil
        t))))

(defun vulpea-agenda-task-p ()
  "Any task with a todo keyword and no subtask."
  (save-restriction
    (widen)
    (let ((has-subtask)
          (subtree-end (save-excursion (org-end-of-subtree t)))
          (is-a-task (member (nth 2 (org-heading-components))
                             org-todo-keywords-1)))
      (save-excursion
        (forward-line 1)
        (while (and (not has-subtask)
                    (< (point) subtree-end)
                    (re-search-forward "^\*+ " subtree-end t))
          (when (member (org-get-todo-state) org-todo-keywords-1)
            (setq has-subtask t))))
      (and is-a-task (not has-subtask)))))

;; Utilities to build agenda commands -- search

(defun vulpea-agenda-find-project-task ()
  "Move point to the parent (project) task if any."
  (save-restriction
    (widen)
    (let ((parent-task (save-excursion
                         (org-back-to-heading 'invisible-ok)
                         (point))))
      (while (org-up-heading-safe)
        (when (member (nth 2 (org-heading-components))
                      org-todo-keywords-1)
          (setq parent-task (point))))
      (goto-char parent-task)
      parent-task)))

(defun vulpea-agenda-category (&optional len)
  "Get category of item at point for agenda.

Category is defined by one of the following items:

- CATEGORY property
- TITLE keyword
- TITLE property
- filename without directory and extension

When LEN is a number, resulting string is padded right with
spaces and then truncated with ... on the right if result is
longer than LEN.

Usage example:

  (setq org-agenda-prefix-format
        '((agenda . \" %(vulpea-agenda-category 12) %?-12t %12s\")))

Refer to `org-agenda-prefix-format' for more information."
  (let* ((file-name (when buffer-file-name
                      (file-name-sans-extension
                       (file-name-nondirectory buffer-file-name))))
         (title (vulpea-buffer-prop-get "title"))
         (category (org-get-category))
         (result
          (or (if (and
                   title
                   (string-equal category file-name))
                  title
                category)
              "")))
    (if (numberp len)
        (s-truncate len (s-pad-right len " " result))
      result)))


;;; Vulpea capture lib
;; https://github.com/d12frosted/environment/blob/master/emacs/lisp/lib-vulpea-capture.el

(defun vulpea-capture-setup ()
  "Wire all bits for capturing."
  (dolist (var '(vulpea-capture-inbox-file))
    (set var (expand-file-name (symbol-value var) vulpea-directory)))
  (unless org-default-notes-file
    (setq org-default-notes-file vulpea-capture-inbox-file))
  (setq
   org-capture-templates gtd/org-capture-templates
   org-roam-capture-templates
   '(("d" "default" plain "%?"
      :if-new (file+head
               "%(vulpea-subdir-select)/%<%Y%m%d%H%M%S>-${slug}.org"
               "#+title: ${title}\n\n")
      :unnarrowed t))
   org-roam-dailies-capture-templates
   `(("d" "default" entry
      "* %<%H:%M>\n\n%?"
      :if-new (file+head
               ,(expand-file-name "%<%Y-%m-%d>.org"
                                  org-roam-dailies-directory)
               ,(string-join '("#+title: %<%A, %d %B %Y>"
                               "#+filetags: journal"
                               "\n")
                             "\n"))))))

(defun vulpea-capture-task ()
  "Capture a task."
  (interactive)
  (org-capture nil "t"))

(defun vulpea-capture-meeting ()
  "Capture a meeting."
  (interactive)
  (org-capture nil "m"))

(defun vulpea-capture-meeting-target ()
  "Return a target for a meeting capture."
  (let ((person (org-capture-get :meeting-person)))
    ;; unfortunately, I could not find a way to reuse
    ;; `org-capture-set-target-location'
    (if (vulpea-note-id person)
        (let ((path (vulpea-note-path person))
              (headline "Meetings"))
          (set-buffer (org-capture-target-buffer path))
          ;; Org expects the target file to be in Org mode, otherwise
          ;; it throws an error. However, the default notes files
          ;; should work out of the box. In this case, we switch it to
          ;; Org mode.
          (unless (derived-mode-p 'org-mode)
            (org-display-warning
             (format
              "Capture requirement: switching buffer %S to Org mode"
              (current-buffer)))
            (org-mode))
          (org-capture-put-target-region-and-position)
          (widen)
          (goto-char (point-min))
          (if (re-search-forward
               (format org-complex-heading-regexp-format
                       (regexp-quote headline))
               nil t)
              (beginning-of-line)
            (goto-char (point-max))
            (unless (bolp) (insert "\n"))
            (insert "* " headline "\n")
            (beginning-of-line 0)))
      (let ((path vulpea-capture-inbox-file))
        (set-buffer (org-capture-target-buffer path))
        (org-capture-put-target-region-and-position)
        (widen)))))

(defun vulpea-capture-meeting-template ()
  "Return a template for a meeting capture."
  (let ((person (vulpea-select
                 "Person"
                 :filter-fn
                 (lambda (note)
                   (let ((tags (vulpea-note-tags note)))
                     (seq-contains-p tags "people"))))))
    (org-capture-put :meeting-person person)
    (if (vulpea-note-id person)
        "* MEETING [%<%Y-%m-%d %a>] :REFILE:MEETING:\n:PROPERTIES:\n:CREATED: %U\n:END:\n%?"
      (concat "* MEETING with "
              (vulpea-note-title person)
              " on [%<%Y-%m-%d %a>] :MEETING:\n:PROPERTIES:\n:CREATED: %U\n:END:\n%?"))))

(defun vulpea-capture-article ()
  "Capture an article using `vulpea-capture-article-template'.
User is asked to provide an URL, title and authors of the article
being captured.
Title is inferred from URL, but user may edit it.
Authors can be created on the fly. See
`vulpea-capture-person-template' for more information."
  (interactive)
  (when-let*
      ((url (read-string "URL: "))
       (title (org-cliplink-retrieve-title-synchronously url))
       (title (read-string "Title: " title))
       (people (fun-collect-while
                (lambda ()
                  (let ((person
                         (vulpea-select
                          "Person"
                          :filter-fn
                          (lambda (note)
                            (let ((tags (vulpea-note-tags note)))
                              (seq-contains-p tags "people"))))))
                    (if (vulpea-note-id person)
                        person
                      (vulpea-create
                       (vulpea-note-title person)
                       "people/%<%Y%m%d%H%M%S>-${slug}.org"
                       :immediate-finish t))))
                nil))
       (note (vulpea-create
              title
              "litnotes/%<%Y%m%d%H%M%S>-${slug}.org"
              :tags '("litnotes" "content/article" "status/new")
              :properties (list (cons "ROAM_REFS" url))
              :immediate-finish t)))
    (vulpea-meta-set note "authors" people t)
    (find-file (vulpea-note-path note))
    (save-buffer)))

(defun vulpea-capture-journal ()
  "Capture a journal entry.
By default it uses current date to find a daily. With
\\[universal-argument] user may select the date."
  (interactive)
  (cond
   ((equal current-prefix-arg '(4))     ; select date
    (org-roam-dailies-capture-date))
   (t
    (org-roam-dailies-capture-today))))


;;; Vulpea id lib
;; https://github.com/d12frosted/environment/blob/master/emacs/lisp/lib-vulpea-id.el

(defun vulpea-id-auto-assign ()
  "Add ID property to the current file.
Targets are defined by `vulpea-id-auto-targets'."
  (when (and vulpea-id-auto-targets
             (or (eq major-mode 'org-mode)
                 (eq major-mode 'org-journal-mode))
             (eq buffer-read-only nil))
    (save-excursion
      (widen)
      (goto-char (point-min))
      (when (seq-contains-p vulpea-id-auto-targets 'file)
        (org-id-get-create))
      (when (seq-contains-p vulpea-id-auto-targets 'headings)
        (org-map-entries #'org-id-get-create)))))


;;; Vulpea refile
;; https://github.com/d12frosted/environment/blob/master/emacs/lisp/lib-vulpea-refile.el

(defun vulpea-refile-verify-target ()
  "Exclude todo keywords with a done state from refile targets."
  (let ((tags-at (org-get-tags)))
    (and
     ;; doesn't have done keyword
     (not (member (nth 2 (org-heading-components)) org-done-keywords))

     ;; doesn't have blacklisted tag
     (or (null tags-at)
         (cl-member-if-not
          (lambda (x)
            (member (if (listp x) (car x) x)
                    vulpea-refile-ignored-tags))
          tags-at)))))


;;; Vulpea lib
;; https://github.com/d12frosted/environment/blob/master/emacs/lisp/lib-vulpea.el

(defun vulpea-buffer-p ()
  "Return non-nil if the currently visited buffer is a note."
  (and buffer-file-name
       (eq major-mode 'org-mode)
       (string-suffix-p "org" buffer-file-name)
       (string-prefix-p
        (expand-file-name (file-name-as-directory vulpea-directory))
        (file-name-directory buffer-file-name))))

(defun vulpea-project-p ()
  "Return non-nil if current buffer has any todo entry.
TODO entries marked as done are ignored, meaning the this
function returns nil if current buffer contains only completed
tasks. The only exception is headings tagged as REFILE."
  (org-element-map
      (org-element-parse-buffer 'headline)
      'headline
    (lambda (h)
      (or (eq 'todo (org-element-property :todo-type h))
          (seq-contains-p (org-element-property :tags h)
                          "REFILE")))
    nil 'first-match))

(defun vulpea-project-files ()
  "Return a list of note files containing 'project' tag." ;
  (seq-uniq
   (seq-map
    #'car
    (org-roam-db-query
     [:select [nodes:file]
              :from tags
              :left-join nodes
              :on (= tags:node-id nodes:id)
              :where (like tag (quote "%\"project\"%"))]))))

(defun vulpea-insert-handle (note)
  "Hook to be called on NOTE after `vulpea-insert'."
  (when-let* ((title (vulpea-note-title note))
              (tags (vulpea-note-tags note)))
    (when (seq-contains-p tags "people")
      (save-excursion
        (ignore-errors
          (org-back-to-heading)
          (when (eq 'todo (org-element-property
                           :todo-type
                           (org-element-at-point)))
            (org-set-tags
             (seq-uniq
              (cons
               (vulpea--title-to-tag title)
               (org-get-tags nil t))))))))))

(defun vulpea-tags-add ()
  "Add a tag to current note."
  (interactive)
  ;; since https://github.com/org-roam/org-roam/pull/1515
  ;; `org-roam-tag-add' returns added tag, we could avoid reading tags
  ;; in `vulpea-ensure-filetag', but this way it can be used in
  ;; different contexts while having simple implementation.
  (when (call-interactively #'org-roam-tag-add)
    (vulpea-ensure-filetag)))

(defun vulpea-tags-delete ()
  "Delete a tag from current note."
  (interactive)
  (call-interactively #'org-roam-tag-remove))

(defun vulpea-ensure-filetag ()
  "Add missing FILETAGS to the current note."
  (let* ((file (buffer-file-name))
         (path-tags
          (when file
            (seq-filter
             (lambda (x) (not (string-empty-p x)))
             (split-string
              (string-remove-prefix
               vulpea-directory
               (file-name-directory file))
              "/"))))
         (original-tags (vulpea-buffer-tags-get))
         (tags (append original-tags path-tags)))

    ;; process people
    (when (seq-contains-p tags "people")
      (let ((tag (vulpea--title-as-tag)))
        (unless (seq-contains-p tags tag)
          (setq tags (cons tag tags)))))

    ;; process litnotes
    (setq tags (litnotes-ensure-filetags tags))

    ;; process projects
    (if (vulpea-project-p)
        (setq tags (cons "project" tags))
      (setq tags (remove "project" tags)))

    (setq tags (seq-uniq tags))

    ;; update tags if changed
    (when (or (seq-difference tags original-tags)
              (seq-difference original-tags tags))
      (apply #'vulpea-buffer-tags-set (seq-uniq tags)))))

(defun vulpea-alias-add ()
  "Add an alias to current note."
  (interactive)
  (call-interactively #'org-roam-alias-add))

(defun vulpea-alias-delete ()
  "Delete an alias from current note."
  (interactive)
  (call-interactively #'org-roam-alias-remove))

(defun vulpea-alias-extract ()
  "Extract an alias from current note as a separate note.
Make all the links to this alias point to newly created note."
  (interactive)
  (if-let* ((node (org-roam-node-at-point 'assert))
            (aliases (org-roam-node-aliases node)))
      (let* ((alias (completing-read
                     "Alias: " aliases nil 'require-match))
             (backlinks (seq-map
                         #'org-roam-backlink-source-node
                         (org-roam-backlinks-get node)))
             (id-old (org-roam-node-id node)))
        (org-roam-alias-remove alias)
        (org-roam-db-update-file (org-roam-node-file node))
        (let* ((note (vulpea-create
                      alias
                      "%<%Y%m%d%H%M%S>-${slug}.org"
                      :immediate-finish t
                      :unnarrowed t)))
          (seq-each
           (lambda (node)
             (vulpea-utils-with-file (org-roam-node-file node)
               (goto-char (point-min))
               (let ((link-old
                      (org-link-make-string
                       (concat "id:" id-old)
                       alias))
                     (link-new
                      (vulpea-utils-link-make-string note)))
                 (while (search-forward link-old nil 'noerror)
                   (replace-match link-new))))
             (org-roam-db-update-file (org-roam-node-file node)))
           backlinks)))
    (user-error "No aliases to extract")))

(defun vulpea-setup-buffer (&optional _)
  "Setup current buffer for notes viewing and editing."
  (when (and (not (active-minibuffer-window))
             (vulpea-buffer-p))
    (org-with-point-at 1
      (org-hide-drawer-toggle 'off))
    (vulpea-ensure-filetag)))

(defun vulpea-pre-save-hook ()
  "Do all the dirty stuff when file is being saved."
  (when (and (not (active-minibuffer-window))
             (vulpea-buffer-p))
    (vulpea-ensure-filetag)))

(defun vulpea-dailies-today ()
  "Find a daily note for today."
  (interactive)
  (org-roam-dailies-find-today))

(defun vulpea-dailies-date ()
  "Find a daily note for date specified using calendar."
  (interactive)
  (org-roam-dailies-find-date))

(defun vulpea-dailies-prev ()
  "Find a daily note that comes before current."
  (interactive)
  (org-roam-dailies-find-previous-note))

(defun vulpea-dailies-next ()
  "Find a daily note that comes after current."
  (interactive)
  (org-roam-dailies-find-next-note))

(defun vulpea-db-build ()
  "Update notes database."
  (when (file-directory-p vulpea-directory)
    (org-roam-db-sync)
    (vino-db-sync)))

(defun vulpea-subdir-select ()
  "Select notes subdirectory."
  (interactive)
  (let ((dirs (cons
               "."
               (seq-map
                (lambda (p)
                  (string-remove-prefix vulpea-directory p))
                (directory-subdirs vulpea-directory 'recursive)))))
    (completing-read "Subdir: " dirs nil t)))


(defun vulpea--title-as-tag ()
  "Return title of the current note as tag."
  (vulpea--title-to-tag (vulpea-buffer-prop-get "title")))

(defun vulpea--title-to-tag (title)
  "Convert TITLE to tag."
  (concat "@" (s-replace " " "" title)))

;; org-check-agenda-file
(defun vulpea-check-agenda-file (&rest _)
  "A noop advice for `org-check-agenda-file'.
Since this function is called from multiple places, it is very
irritating to answer this question every time new note is created.
Also, it doesn't matter if the file in question is present in the
list of `org-agenda-files' or not, since it is built dynamically
via `vulpea-agenda-files-update'.")


(defun vulpea-migrate-buffer ()
  "Migrate current buffer note to `org-roam' v2."
  ;; Create file level ID if it doesn't exist yet
  (org-with-point-at 1
    (org-id-get-create))

  ;; update title (just to make sure it's lowercase)
  (vulpea-buffer-title-set (vulpea-buffer-prop-get "title"))

  ;; move roam_key into properties drawer roam_ref
  (when-let* ((ref (vulpea-buffer-prop-get "roam_key")))
    (org-set-property "ROAM_REFS" ref)
    (let ((case-fold-search t))
      (org-with-point-at 1
        (while (re-search-forward "^#\\+roam_key:" (point-max) t)
          (beginning-of-line)
          (kill-line 1)))))

  ;; move roam_alias into properties drawer roam_aliases
  (when-let* ((aliases (vulpea-buffer-prop-get-list "roam_alias")))
    (org-set-property "ROAM_ALIASES"
                      (combine-and-quote-strings aliases))
    (let ((case-fold-search t))
      (org-with-point-at 1
        (while (re-search-forward "^#\\+roam_alias:" (point-max) t)
          (beginning-of-line)
          (kill-line 1)))))

  ;; move roam_tags into filetags
  (let* ((roam-tags (vulpea-buffer-prop-get-list "roam_tags"))
         (file-tags (vulpea-buffer-prop-get-list "filetags"))
         (path-tags (seq-filter
                     (lambda (x) (not (string-empty-p x)))
                     (split-string
                      (string-remove-prefix
                       org-roam-directory
                       (file-name-directory (buffer-file-name)))
                      "/")))
         (tags (seq-map
                (lambda (tag)
                  (setq tag (replace-regexp-in-string
                             ;; see `org-tag-re'
                             "[^[:alnum:]_@#%]"
                             "_"        ; use any valid char - _@#%
                             tag))
                  (if (or
                       (string-prefix-p "status" tag 'ignore-case)
                       (string-prefix-p "content" tag 'ignore-case)
                       (string-equal "Project" tag))
                      (setq tag (downcase tag)))
                  tag)
                (seq-uniq (append roam-tags file-tags path-tags)))))
    (when tags
      (apply #'vulpea-buffer-tags-set tags)
      (let ((case-fold-search t))
        (org-with-point-at 1
          (while (re-search-forward "^#\\+roam_tags:" (point-max) t)
            (beginning-of-line)
            (kill-line 1))))))

  (save-buffer))

(defun vulpea-migrate-db ()
  "Migrate all notes."
  (dolist (f (org-roam--list-all-files))
    (with-current-buffer (find-file f)
      (message "migrating %s" f)
      (vulpea-migrate-buffer)))

  ;; Step 2: Build cache
  (org-roam-db-sync 'force))


;;; Vulpea Libnotes
;; https://github.com/d12frosted/environment/blob/master/emacs/lisp/lib-litnotes.el

(defun litnotes-status-compare (a b)
  "Compare status A with status B."
  (< (seq-position litnotes-status-values a)
     (seq-position litnotes-status-values b)))

(defun litnotes-status-display (status)
  "Display STATUS."
  (let ((icon (pcase status
                (`"ongoing" (all-the-icons-faicon "spinner"))
                (`"new" (all-the-icons-faicon "inbox"))
                (`"done" (all-the-icons-faicon "check"))
                (`"dropped" (all-the-icons-faicon "times")))))
    (if (featurep 'all-the-icons)
        (concat icon " " status)
      status)))

(defun litnotes-status-to-tag (status)
  "Return a tag representing STATUS."
  (concat litnotes-status-tag-prefix status))

(defun litnotes-status-from-tag (tag)
  "Return a status representing as TAG."
  (string-remove-prefix litnotes-status-tag-prefix tag))

(defun litnotes-status-tag-p (tag)
  "Return non-nil when TAG represents a status."
  (string-prefix-p litnotes-status-tag-prefix tag))

(defun litnotes-status-read (&optional old-status)
  "Read a status excluding OLD-STATUS."
  (completing-read
   "Status: "
   (-remove-item old-status litnotes-status-values)))

(defun litnotes-content-compare (a b)
  "Compare content A with content B."
  (< (seq-position litnotes-content-types a)
     (seq-position litnotes-content-types b)))

(defun litnotes-content-display (content)
  "Display CONTENT."
  (let ((icon (pcase content
                (`"book" (all-the-icons-faicon "book"))
                (`"article" (all-the-icons-faicon "align-justify"))
                (`"video" (all-the-icons-material "videocam"))
                (`"game" (all-the-icons-faicon "gamepad")))))
    (if (and icon (featurep 'all-the-icons))
        (concat icon " ")
      "")))

(defun litnotes-content-to-tag (content)
  "Return a tag representing CONTENT."
  (concat litnotes-content-tag-prefix content))

(defun litnotes-content-from-tag (tag)
  "Return a content representing as TAG."
  (string-remove-prefix litnotes-content-tag-prefix tag))

(defun litnotes-content-tag-p (tag)
  "Return non-nil when TAG represents a content."
  (string-prefix-p litnotes-content-tag-prefix tag))

(defun litnotes-entry (note)
  "Create a `litnotes-entry' from NOTE."
  (let ((meta (vulpea-meta note)))
    (make-litnotes-entry
     :note note
     :title (vulpea-note-title note)
     :meta meta
     :status (litnotes-status-from-tag
              (seq-find
               #'litnotes-status-tag-p
               (vulpea-note-tags note)))
     :content (string-remove-prefix
               "content/"
               (seq-find
                (lambda (x)
                  (string-prefix-p "content/" x))
                (vulpea-note-tags note)))
     :authors (vulpea-buffer-meta-get-list!
               meta "authors" 'note))))

(defun litnotes-entry-visit (entry &optional other-window)
  "Visit a litnote ENTRY possible in OTHER-WINDOW."
  (org-roam-node-visit
   (org-roam-node-from-id
    (vulpea-note-id (litnotes-entry-note entry)))
   other-window))

(defun litnotes-entries ()
  "Fetch a list of `litnotes-entry' entries."
  (seq-map
   #'litnotes-entry
   (seq-remove
    #'vulpea-note-primary-title
    (vulpea-db-query
     (lambda (x)
       (seq-contains-p (vulpea-note-tags x)
                       litnotes-tag))))))

(defun litnotes ()
  "Display a list of litnotes."
  (interactive)
  (let* ((name "*litnotes*")
         (_ (and (get-buffer name)
                 (kill-buffer name)))
         (buffer (generate-new-buffer name)))
    (with-current-buffer buffer
      (litnotes-mode)
      (setq litnotes-buffer-data (litnotes-buffer-data))
      (lister-highlight-mode 1)
      (lister-insert-sequence
       buffer (point) litnotes-status-values)
      (lister-goto buffer :first)
      (litnotes-buffer-expand-sublist buffer (point)))
    (switch-to-buffer buffer)))

(defun litnotes-buffer-data ()
  "Get data for litnotes buffer."
  (seq-sort-by
   #'car
   #'litnotes-status-compare
   (seq-group-by #'litnotes-entry-status (litnotes-entries))))

(defun litnotes-buffer-mapper (data)
  "DATA mapper for `litnotes-mode'."
  (if (stringp data)
      (concat
       (propertize
        (litnotes-status-display data)
        'face 'litnotes-group-title-face)
       " "
       (propertize
        (concat "("
                (number-to-string
                 (length (cdr (assoc data litnotes-buffer-data))))
                ")")
        'face 'litnotes-group-counter-face))
    (concat
     (litnotes-content-display
      (litnotes-entry-content data))
     (propertize
      (litnotes-entry-title data)
      'face 'litnotes-entry-title-face)
     (when (litnotes-entry-authors data)
       (concat
        " by "
        (string-join
         (seq-map
          (lambda (note)
            (propertize
             (vulpea-note-title note)
             'face 'litnotes-entry-authors-face))
          (litnotes-entry-authors data))
         ", "))))))

(defun litnotes-buffer-groups-refresh (buffer)
  "Refresh groups in litnotes BUFFER."
  (lister-walk-all
   buffer
   (lambda (data)
     (lister-replace buffer (point) data))
   #'stringp))

(defun litnotes-buffer-refresh ()
  "Refresh litnotes buffer."
  (interactive)
  (let ((pos (point)))
    (litnotes)
    (goto-char pos)))

(defun litnotes-buffer-expand (buffer pos)
  "Perform expansion on item at POS in litnotes BUFFER."
  (interactive (list (current-buffer) (point)))
  (let ((item (lister-get-data buffer pos)))
    (cond
     ((litnotes-entry-p item)
      (litnotes-entry-visit item 'other-window))

     ((ignore-errors (lister-sublist-below-p buffer pos))
      (lister-remove-sublist-below buffer pos))

     (t (litnotes-buffer-expand-sublist buffer pos)))))

(defun litnotes-buffer-expand-sublist (buffer pos)
  "Expand litnotes in the current list.
BUFFER must be a valid lister buffer populated with litnotes
items. POS can be an integer or the symbol `:point'."
  (interactive (list (current-buffer) (point)))
  (let* ((position
          (pcase pos
            ((and (pred integerp) pos) pos)
            (:point (with-current-buffer buffer (point)))
            (_ (error "Invalid value for POS: %s" pos))))
         (item (lister-get-data buffer position))
         (sublist (cdr (assoc item litnotes-buffer-data))))
    (if sublist
        (with-temp-message "Inserting expansion results..."
          (lister-insert-sublist-below buffer position sublist))
      (user-error "No expansion found"))))

(defun litnotes-buffer-visit (buffer pos)
  "Visit a litnote at POS from BUFFER."
  (interactive (list (current-buffer) (point)))
  (let* ((item (lister-get-data buffer pos)))
    (if (litnotes-entry-p item)
        (litnotes-entry-visit item)
      (user-error "Not a litnote"))))

(defun litnotes-buffer-set-status ()
  "Set status of a litnote at point."
  (interactive)
  (let* ((buffer (current-buffer))
         (pos (point))
         (item (lister-get-data buffer pos)))
    (if (litnotes-entry-p item)
        (let* ((old-status (litnotes-entry-status item))
               (status (litnotes-status-read old-status))
               (note (litnotes-entry-note item))
               (file (vulpea-note-path note)))
          (vulpea-utils-with-file file
            (litnotes-status-set status))
          (setf (litnotes-entry-status item) status)
          (setq litnotes-buffer-data
                (litnotes-buffer-data-change-group
                 item old-status status))
          (litnotes-buffer-change-group buffer pos item status)
          (litnotes-buffer-groups-refresh buffer))
      (user-error "Not a litnote"))))

(defun litnotes-buffer-change-group (buffer pos item new-group)
  "Move ITEM at POS to NEW-GROUP in litnotes BUFFER."
  ;; basically, remove whatever is in point
  (lister-remove buffer pos)

  ;; add to new group if it's expanded
  (lister-walk-all
   buffer
   (lambda (_)
     (let ((pos (point)))
       (when (ignore-errors
               (lister-sublist-below-p buffer pos))
         (let* ((next-item (lister-end-of-lines buffer pos))
                (next-level (lister-get-level-at buffer next-item)))
           (lister-insert
            buffer
            next-item
            item
            next-level)))))
   (lambda (data)
     (and (stringp data)
          (string-equal new-group data)))))

(defun litnotes-buffer-data-change-group (item old-group new-group)
  "Move ITEM from OLD-GROUP to NEW-GROUP in cached data."
  (seq-map
   (lambda (kvs)
     (cond
      ((string-equal old-group (car kvs))
       (cons (car kvs)
             (seq-remove
              (lambda (x)
                (string-equal
                 (vulpea-note-id (litnotes-entry-note x))
                 (vulpea-note-id (litnotes-entry-note item))))
              (cdr kvs))))
      ((string-equal new-group (car kvs))
       (cons (car kvs)
             (cons item (cdr kvs))))
      (t kvs)))
   litnotes-buffer-data))

(defun litnotes-ensure-filetags (tags)
  "Ensure that TAGS contain the right set of tags."
  (when (seq-contains-p tags litnotes-tag)
    (unless (seq-find #'litnotes-status-tag-p tags)
      (setq tags (cons (litnotes-status-to-tag "new") tags)))
    (unless (seq-find #'litnotes-content-tag-p tags)
      (setq tags (cons
                  (litnotes-content-to-tag
                   (completing-read
                    "Content:"
                    litnotes-content-types))
                  tags))))
  tags)

(defun litnotes-status-set (&optional status)
  "Change STATUS tag of the current litnote."
  (when-let*
      ((file (buffer-file-name (buffer-base-buffer)))
       (tags (vulpea-buffer-prop-get-list "filetags"))
       (old-status (litnotes-status-from-tag
                    (seq-find #'litnotes-status-tag-p tags)))
       (status (or status (litnotes-status-read old-status)))
       (new-tags (litnotes-tags-set-status tags status)))
    (vulpea-buffer-prop-set-list "filetags" new-tags)
    (org-roam-db-update-file file)
    (save-buffer)))

(defun litnotes-tags-set-status (tags status)
  "Add STATUS to TAGS and return result.
STATUS is converted into proper tag, an any other status tag is
removed from TAGS."
  (cons
   (litnotes-status-to-tag status)
   (seq-remove
    #'litnotes-status-tag-p
    tags)))


;;; Extra commands

(defun vulpea-insert ()
  "Insert a link to the note."
  (interactive)
  (when-let*
      ((node (org-roam-node-insert))
       (title (org-roam-node-title node))
       (tags (org-roam-node-tags node)))
    (when (seq-contains-p tags "people")
      (save-excursion
        (ignore-errors
          (org-back-to-heading)
          (org-set-tags
           (seq-uniq
            (cons
             (vulpea--title-to-tag title)
             (org-get-tags nil t)))))))))



(defun vulpea-project-update-tag ()
  "Update PROJECT tag in the current buffer."
  (when (and (not (active-minibuffer-window))
             (vulpea-buffer-p))
    (save-excursion
      (goto-char (point-min))
      (let* ((tags (vulpea-buffer-tags-get))
             (original-tags tags))
        (if (vulpea-project-p)
            (setq tags (cons "project" tags))
          (setq tags (remove "project" tags)))
        (unless (eq original-tags tags)
          (apply #'vulpea-buffer-tags-set (seq-uniq tags)))))))


(defun vulpea-visit-update-files-for-project-tag ()
  "Visit each org roam file and update the project tags in the note"
  (interactive)
  (dolist (file (org-roam--list-all-files))
    (message "processing %s" file)
    (with-current-buffer (or (find-buffer-visiting file)
                             (find-file-noselect file))
      (vulpea-project-update-tag)
      (save-buffer))))


;; (defun +org-auto-id-add-to-headlines-in-file ()
;;   "Add ID property to the current file and all its headlines."
;;   (when (and (or (eq major-mode 'org-mode)
;;                  (eq major-mode 'org-journal-mode))
;;              (eq buffer-read-only nil))
;;     (save-excursion
;;       (widen)
;;       (goto-char (point-min))
;;       (org-id-get-create)
;;       (org-map-entries #'org-id-get-create))))

;; )
