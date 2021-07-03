;; (defvar gtd/org-agenda-files org-directory)

(defvar gtd/org-default-notes-file (expand-file-name "refile.org" org-directory)
  "New Stuff collected in this file. All new notes come here first")

(defvar gtd/org-agenda-diary-file (expand-file-name "diary.org" org-journal-dir)
  "All agenda diary data is in this file")

(defvar bh/organization-task-id "e2fb68ed-2c63-4f32-9fa3-9ce17349191e")

(defvar bh/project-list nil)

(defvar bh/hide-scheduled-and-waiting-next-tasks t)

;; ;; TODO Other todo keywords doesn't have appropriate faces yet. They should
;; ;; have faces similar to spacemacs defaults.
(defvar gtd/org-todo-keyword-faces
  (quote (("TODO" :foreground "red" :weight bold)
          ("NEXT" :foreground "blue" :weight bold)
          ("DONE" :foreground "forest green" :weight bold)
          ("WAITING" :foreground "orange" :weight bold)
          ("HOLD" :foreground "magenta" :weight bold)
          ("CANCELLED" :foreground "forest green" :weight bold)
          ("MEETING" :foreground "forest green" :weight bold)
          ("PHONE" :foreground "forest green" :weight bold)))
  )

;; Capture templates for: TODO tasks, Notes, appointments, phone calls,
;; meetings, and org-protocol
(defvar gtd/org-capture-templates
  (quote (("t" "todo" entry (file gtd/org-default-notes-file)
           "* TODO %?\n%U\n%a\n" :clock-in t :clock-resume t)
          ("r" "respond" entry (file gtd/org-default-notes-file)
           "* NEXT Respond to %:from on %:subject\nSCHEDULED: %t\n%U\n%a\n" :clock-in t :clock-resume t :immediate-finish t)
          ("n" "note" entry (file gtd/org-default-notes-file)
           "* %? :NOTE:\n%U\n%a\n" :clock-in t :clock-resume t)
          ("j" "Journal" entry (file+datetree gtd/org-agenda-diary-file)
           "* %?\n%U\n" :clock-in t :clock-resume t)
          ("w" "org-protocol" entry (file gtd/org-default-notes-file)
           "* TODO Review %c\n%U\n" :immediate-finish t)
          ("m" "Meeting" entry (file gtd/org-default-notes-file)
           "* MEETING with %? :MEETING:\n%U" :clock-in t :clock-resume t)
          ("p" "Phone call" entry (file gtd/org-default-notes-file)
           "* PHONE %? :PHONE:\n%U" :clock-in t :clock-resume t)
          ("h" "Habit" entry (file gtd/org-default-notes-file)
           "* NEXT %?\n%U\n%a\nSCHEDULED: %(format-time-string \"%<<%Y-%m-%d %a .+1d/3d>>\")\n:PROPERTIES:\n:STYLE: habit\n:REPEAT_TO_STATE: NEXT\n:END:\n")))
  "Capture templates for org-capture")
