
;;; Forth File to be loaded Layers -> Package -> Funcs -> Config -> Keybinding


(defvar gtd/org-agenda-files (directory-files-recursively org-directory "\.org$")
  "Complete list of agenda files")

(defvar gtd/org-default-notes-file (expand-file-name "refile.org" org-directory)
  "New Stuff collected in this file. All new notes come here first")

(defvar gtd/org-default-someday-file (expand-file-name "someday.org" org-directory)
  "Someday Stuff collected in this file. All new notes come here first")

(defvar gtd/org-agenda-diary-file (expand-file-name "diary.org" org-journal-dir)
  "All agenda diary data is in this file")

;; On the task to use as default using M-x command call org-id-get-create, then copy paste the value generated here.
(defvar bh/organization-task-id "2C0326E7-6DFD-418B-B34B-94A778D3558B"
  "org task id")

(defvar bh/project-list nil
  "project list")

(defvar bh/hide-scheduled-and-waiting-next-tasks t
  "hide scheduled and waiting next task")

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
  "Todo faces")

;; Capture templates for: TODO tasks, Notes, appointments, phone calls,
;; meetings, and org-protocol
(defvar gtd/org-capture-templates
  (quote (("t" "todo" entry (file gtd/org-default-notes-file)
           "* TODO %?\n%U\n%a\n" :clock-in t :clock-resume t :empty-lines-after 1)
          ("r" "respond" entry (file gtd/org-default-notes-file)
           "* NEXT Respond to %:from on %:subject\nSCHEDULED: %t\n%U\n%a\n" :clock-in t :clock-resume t :immediate-finish t)
          ("n" "note" entry (file gtd/org-default-notes-file)
           "* %? :NOTE:\n%U\n%a\n" :clock-in t :clock-resume t :empty-lines-after 1)
          ("j" "Journal" entry (file+datetree gtd/org-agenda-diary-file)
           "* %?\n%U\n" :clock-in t :clock-resume t :empty-lines-after 1)
          ("w" "org-protocol" entry (file gtd/org-default-notes-file)
           "* TODO Review %c\n%U\n" :immediate-finish t :empty-lines-after 1)
          ("m" "Meeting" entry (file gtd/org-default-notes-file)
           "* MEETING with %? :MEETING:\n%U" :clock-in t :clock-resume t :empty-lines-after 1)
          ("p" "Phone call" entry (file gtd/org-default-notes-file)
           "* PHONE %? :PHONE:\n%U" :clock-in t :clock-resume t :empty-lines-after 1)
          ("h" "Habit" entry (file gtd/org-default-notes-file)
           "* NEXT %?\n%U\n%a\nSCHEDULED: %(format-time-string \"%<<%Y-%m-%d %a .+1d/3d>>\")\n:PROPERTIES:\n:STYLE: habit\n:REPEAT_TO_STATE: NEXT\n:END:\n")
          ("s" "SOMEDAY/MAYBE" entry (file+olp gtd/org-default-someday-file "Someday")
           "* TODO %?\n%U\n%a\n" :clock-in t :clock-resume t :empty-lines-after 1)
          ("c" "Slack" entry (file gtd/org-default-notes-file)
           "* SLACK time %?\n%U" :clock-in t :clock-resume t :empty-lines-after 1)
          ))
  "Capture templates for org-capture")


;; Tags with fast selection keys
(defvar gtd/org-tag-alist (quote ((:startgroup)
                            ("@errand" . ?e)
                            ("@office" . ?o)
                            ("@home" . ?H)
                            (:endgroup)
                            ("WAITING" . ?w)
                            ("HOLD" . ?h)
                            ("PERSONAL" . ?P)
                            ("WORK" . ?W)
                            ("ORG" . ?O)
                            ("crypt" . ?E)
                            ("NOTE" . ?n)
                            ("CANCELLED" . ?c)
                            ("FLAGGED" . ??)))
  "org tag list"
  )

;; For tag searches ignore tasks with scheduled and deadline dates
(defvar gtd/org-agenda-tags-todo-honor-ignore-options t
  "tags ignore options")

;; Allow setting single tags without the menu
(defvar gtd/org-fast-tag-selection-single-key (quote expert)
  "fast tag selection option")

(defvar gtd/org-babel-do-load-languages
 (quote ((emacs-lisp . t)
         (python . t)
         (shell . t)
         (org . t)
         ))
 "babel loaded languages"
 )

(defvar gtd/agenda-exclude-fast '("gfg" "dwj")
  "exclude this tags from Agenda by pressing M-\ RET. always small characters here!")
