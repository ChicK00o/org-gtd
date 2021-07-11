
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
  (quote (
          ("t" "todo" entry (file gtd/org-default-notes-file)
           "* TODO %?\n:PROPERTIES:\n:CREATED: %U\n:END:\n%a\n"
           :clock-in t
           :clock-resume t
           :empty-lines-after 1)
          ("r" "respond" entry (file gtd/org-default-notes-file)
           "* NEXT Respond to %:from on %:subject\nSCHEDULED: %t\n:PROPERTIES:\n:CREATED: %U\n:END:\n%a\n"
           :clock-in t
           :clock-resume t
           :immediate-finish t
           :empty-lines-after 1)
          ("n" "note" entry (file gtd/org-default-notes-file)
           "* %? :NOTE:\n:PROPERTIES:\n:CREATED: %U\n:END:\n%a\n"
           :clock-in t
           :clock-resume t
           :empty-lines-after 1)
          ("j" "Journal" entry (file+datetree gtd/org-agenda-diary-file)
           "* %?\n:PROPERTIES:\n:CREATED: %U\n:END:\n"
           :clock-in t
           :clock-resume t
           :empty-lines-after 1)
          ("w" "org-protocol" entry (file gtd/org-default-notes-file)
           "* TODO Review %c\n:PROPERTIES:\n:CREATED: %U\n:END:\n"
           :immediate-finish t
           :empty-lines-after 1)
          ("M" "Old Meeting" entry (file gtd/org-default-notes-file)
           "* MEETING with %? :MEETING:\n:PROPERTIES:\n:CREATED: %U\n:END:"
           :clock-in t
           :clock-resume t
           :empty-lines-after 1)
          ("m" "Meeting" entry
           (function vulpea-capture-meeting-target)
           (function vulpea-capture-meeting-template)
           :clock-in t
           :clock-resume t
           :empty-lines-after 1)
          ("h" "Habit" entry (file gtd/org-default-notes-file)
           "* NEXT %?\nSCHEDULED: %(format-time-string \"%<<%Y-%m-%d %a .+1d/3d>>\")\n:PROPERTIES:\n:CREATED: %U\n:STYLE: habit\n:REPEAT_TO_STATE: NEXT\n:END:\n%a\n")
          ("s" "SOMEDAY/MAYBE" entry (file+olp gtd/org-default-someday-file "Someday")
           "* TODO %?\n:PROPERTIES:\n:CREATED: %U\n:END:\n%a\n"
           :clock-in t
           :clock-resume t
           :empty-lines-after 1)
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

;;; Vulpea config

(defvar vulpea-directory
  org-directory
  "Directory containing notes.")

;;; Vulpea agenda

(defvar vulpea-agenda-hide-scheduled-and-waiting-next-tasks t
  "Non-nil means to hide scheduled and waiting tasks.
Affects the following commands:
- `vulpea-agenda-cmd-focus'
- `vulpea-agenda-cmd-waiting'")

(defvar vulpea-agenda-main-buffer-name "*agenda:main*"
  "Name of the main agenda buffer.")

;;; Vulpea capture

(defvar vulpea-capture-inbox-file
  (expand-file-name "inbox.org" org-directory)
  "The path to the inbox file.

It is relative to 'org-directory', unless it is absolute.")

;;; Vulpea id

(defvar vulpea-id-auto-targets '(file headings)
  "Targets for automatic ID assignment.
Each element of this list can be one of the following:
- file - to automatically set ID on the file level;
- headings - to automatically set ID for each heading in the file.
Empty list means no id assignment is needed.")

;;; Vulpea refile

(defvar vulpea-refile-ignored-tags '("JOURNAL" "REFILE")
  "List of tags to ignore during refile.")

;;; Vulpea litnotes

(defconst litnotes-tag "litnotes"
"Tag of all them litnotes.")

(defface litnotes-group-title-face
  '((t (:inherit org-roam-header-line)))
  "Face for displaying group title."
  :group 'litnotes)

(defface litnotes-group-counter-face
  '((t (:inherit font-lock-comment-face)))
  "Face for displaying group counter."
  :group 'litnotes)

(defface litnotes-entry-title-face
  '((t (:inherit org-document-title)))
  "Face for displaying entry title."
  :group 'litnotes)

(defface litnotes-entry-authors-face
  '((t (:inherit font-lock-comment-face)))
  "Face for displaying entry authors."
  :group 'litnotes)

(defvar litnotes-status-values '("ongoing" "new" "done" "dropped")
  "List with all valid values of status.")

(defconst litnotes-status-tag-prefix "status/"
  "Prefix of the status tag.")

(defvar litnotes-content-types '("book"
                                 "article"
                                 "video"
                                 "course"
                                 "game")
  "List with all valid content types.")

(defconst litnotes-content-tag-prefix "content/"
  "Prefix of the content tag.")

(cl-defstruct litnotes-entry
  note
  title
  meta
  status
  content
  authors)
