(require 'wpdl-wy)
(require 'wisi)

;;
;; (add-to-list 'load-path "~/tmp/wisi")
;; (add-to-list 'load-path "~/works/projprog/wpdl")
(defvar wpdl-mode-hook nil
  "hooks when wpdl mode has been enabled"
  )

(defvar wpdl-basic-indent-offset 4
  "Indent offset of WPDL mode")

(defvar wpdl-mode-syntax-table
  (let ((table (make-syntax-table)))
    (modify-syntax-entry ?\s " " table)
    (modify-syntax-entry ?\' "\"" table)
    (modify-syntax-entry ?- "." table)
    (modify-syntax-entry ?\n "." table)
    ;;(modify-syntax-entry ?# "<" table)
    table)
  "syntax table of WPDL mode")

(defconst wpdl-wisi-class-list
  '(
    block-start
    block-middle
    block-end
    statement-start
    statement-end
    statement-middle))

(defun wpdl-wisi-post-parse-fail ()
  (save-excursion
    (let ((start-cache (wisi-goto-start (or (wisi-get-cache (point))
                                            (wisi-backward-cache)))))
      (when start-cache
        (indent-region (point) (wisi-cache-end start-cache))))
    (back-to-indentation)))

(defun wpdl-wisi-comment ()
  "calculate comment indentation current dummy because we have no comment"
  (when (and (not (= (point) (point-max)))
             (= 11 (syntax-class (syntax-after (point)))))
    (cond
     ((= 0 (current-column))
      0)
     ((or (save-excursion (forward-line -1) (looking-at "\\s *$"))
          (save-excursion (forward-comment -1) (not (looking-at comment-start))))
      (let ((indent (wpdl-wisi-after-cache))
            prev-indent next-indent)
        indent))
     (t (forward-comment -1)
        (current-column)))))

(defun wpdl-indent-containing (offset cache &optional before)
  (save-excursion
    (cond
     ((markerp (wisi-cache-containing cache))
      (wpdl-indent-cache offset (wisi-goto-containing cache)))
     (t
      (if before
          0
        offset)))))

(defun wpdl-wisi-before-cache ()
  (let ((pos-0 (point))
        (cache (wisi-get-cache (point)))
        (prev-token (save-excursion (wisi-backward-token))))
    (when cache
      (cl-ecase (wisi-cache-class cache)
        (block-start
         (wpdl-indent-containing wpdl-basic-indent-offset cache t))
        (block-end
         (wpdl-indent-containing 0  cache t))
        (block-middle
         (wpdl-indent-containing 0 cache t))
        (statement-start
         (wpdl-indent-containing wpdl-basic-indent-offset cache t))
        (statement-end
         (wpdl-indent-containing 0 cache t))
        (statement-middle
         (wpdl-indent-containing 0 cache t))
        (t
         )))))

(defun wpdl-indent-cache (offset cache)
  (let ((indent (current-indentation)))
    (while (and cache
                (not (= (current-column) indent)))
      (setq offset (+ offset wpdl-basic-indent-offset))
      (setq cache (wisi-goto-containing cache)))
    (+ indent offset)))

(defun wpdl-wisi-after-cache ()
  (save-excursion
    (let ((start (point))
          (prev-token (save-excursion (wisi-backward-token)))
          (cache (wisi-backward-cache)))
      (cond
       ((not cache) 0)
       (t
        (while (memq (wisi-cache-class cache) '(keyword))
          (setq cache (wisi-backward-cache)))
        (cl-case (wisi-cache-class cache)
          (block-end
           (wisi-indent-current 0))
          (block-middle
           (wpdl-indent-containing wpdl-basic-indent-offset cache nil))
          (block-start
           (wpdl-indent-cache wpdl-basic-indent-offset cache))
          (statement-middle
           )
          (statement-end
           (wpdl-indent-containing 0 cache nil))
          (statement-start
           (wpdl-indent-cache wpdl-basic-indent-offset cache))
          (statement-other)))))))

(defun wpdl-wisi-setup ()
  (wisi-setup '(wpdl-wisi-comment
                wpdl-wisi-before-cache
                wpdl-wisi-after-cache)
              'wpdl-wisi-post-parse-fail
              wpdl-wisi-class-list
              wpdl-wy--keyword-table
              wpdl-wy--token-table
              wpdl-wy--parse-table)
  (set (make-local-variable 'comment-start) "#")
  (set (make-local-variable 'comment-indent-function)
       'wisi-comment-indent))

(add-hook 'wpdl-mode-hook 'wpdl-wisi-setup)

(defun wpdl-mode ()
  (interactive)
  (kill-all-local-variables)
  (setq major-mode 'wpdl-mode)
  (setq mode-name "WPDL")
  (set-syntax-table wpdl-mode-syntax-table)
  (run-mode-hooks 'wpdl-mode-hook)
  (setq wisi-debug 99))
