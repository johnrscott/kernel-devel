(defun make-new-vterm ()
  "Open a new vterm window in vertical split window"
  (interactive)
  (require 'vterm)
  (unless (get-buffer vterm-buffer-name)
    (split-window-right)
    (other-window 1)
    (vterm)))

(defun get-selected-commands ()
  "If a region is highlighted, return the highlighted text;
  else, return the current line"
  (if (region-active-p)
      (buffer-substring (point) (mark))
    (buffer-substring
     (save-excursion (beginning-of-line) (point))
     (save-excursion (end-of-line) (point)))))

;; This function can be used to send the current line
;; to a vterm. Use it for buffers containing scripting
;; languages
(defun vterm-execute-current-line ()
  "Execute the highlighted region, or the current line,
  in a vterm buffer"
  (interactive)
  (require 'vterm)
  (let ((commands (get-selected-commands)))
    (message commands)
    (let ((buf (current-buffer)))
      (unless (get-buffer vterm-buffer-name)
	(vterm))
      (display-buffer vterm-buffer-name t)
      (switch-to-buffer-other-window vterm-buffer-name)
      (vterm--goto-line -1)
      (vterm-send-string commands)
      (vterm-send-return)
      (switch-to-buffer-other-window buf)
      (next-line))))
