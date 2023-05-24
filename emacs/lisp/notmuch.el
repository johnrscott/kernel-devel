(defun notmuch-show-view-as-patch ()
  "View the the current message as a patch."
  (interactive)
  (let* ((id (notmuch-show-get-message-id t))
	 (date (notmuch-show-get-date))
	 (from_ (concat "From " id " " date "\n"))
	 (from: (concat "From: " (notmuch-show-get-from) "\n"))
	 (date: (concat "Date: " date "\n"))
	 (subject (concat "Subject: " (notmuch-show-get-subject) "\n"))
	 (diff-default-read-only t)
	 (buf (get-buffer-create (concat "*notmuch-patch-" id "*"))))
    (switch-to-buffer buf)
    (let ((inhibit-read-only t))
      (erase-buffer)
      (insert from_)
      (insert from:)
      (insert date:)
      (insert subject)
      (insert "\n")
      (insert (notmuch-get-bodypart-internal (concat "id:" id) 1 nil)))
    (set-buffer-modified-p nil)
    (diff-mode)
    (goto-char (point-min))))