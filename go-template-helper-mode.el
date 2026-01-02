;;; go-template-helper-mode.el --- Overlay Go template highlighting -*- lexical-binding: t; -*-

;; Copyright (C) 2026 Robert Charusta

;; Author: Robert Charusta <rch-public@posteo.net>
;; Maintainer: Robert Charusta <rch-public@posteo.net>
;; URL: https://codeberg.org/rch/go-template-helper-mode
;; Version: 1.0.0
;; Keywords: tools, faces
;; Package-Requires: ((emacs "28.1"))

;; This file is NOT part of GNU Emacs.

;; This program is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.
;;
;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.
;;
;; You should have received a copy of the GNU General Public License
;; along with this program.  If not, see
;; <https://www.gnu.org/licenses/>.

;;; Commentary:

;; go-template-helper-mode is a small minor mode that overlays Go
;; text/template (Go template) syntax highlighting on top of another
;; major mode, such as `yaml-mode`, without changing indentation or
;; syntax rules of the host mode.
;;
;; It is useful for files that embed Go template snippets ({{ ... }})
;; inside other formats, for example Helm chart templates under a
;; `templates/' directory.
;;
;; The implementation is intentionally lightweight: it adds a small set
;; of font-lock keywords (regexes) and relies on JIT font-lock for
;; incremental refontification.

;;; Code:

(defgroup go-template-helper nil
  "Overlay Go template highlighting on top of other major modes."
  :group 'faces
  :prefix "go-template-helper-")

(defun go-template-helper--font-lock-comments (limit)
  "Match Go template comments up to LIMIT.
This highlights constructs of the form {{/* ... */}}."
  (let (start)
    (when (re-search-forward "{{/\\*" limit t)
      (setq start (match-beginning 0))
      (if (search-forward "*/}}" limit t)
          (progn
            (set-match-data (list start (point)))
            (put-text-property start (point) 'font-lock-multiline t)
            t)
        (goto-char limit)
        nil))))

(defconst go-template-helper--keywords
  (let* ((kw '("define" "else" "end" "if" "range" "template" "with"))
         (bi '("and" "html" "index" "js" "len" "not" "or" "print"
               "printf" "println" "urlquery")))
    `((go-template-helper--font-lock-comments 0 font-lock-comment-face t)
      (,(regexp-opt '("{{" "}}")) . font-lock-preprocessor-face)
      ("\\$[A-Za-z0-9_]+" . font-lock-variable-name-face)
      (,(regexp-opt kw 'words) . font-lock-keyword-face)
      (,(regexp-opt bi 'words) . font-lock-builtin-face)))
  "Font-lock keywords used by `go-template-helper-mode'.")

(defun go-template-helper--enable ()
  "Enable Go template overlay highlighting in the current buffer."
  (font-lock-add-keywords nil go-template-helper--keywords 'append)
  (font-lock-flush))

(defun go-template-helper--disable ()
  "Disable Go template overlay highlighting in the current buffer."
  (font-lock-remove-keywords nil go-template-helper--keywords)
  (font-lock-flush))

;;;###autoload
(define-minor-mode go-template-helper-mode
  "Overlay Go template highlighting on top of the current major mode."
  :lighter " Gtmpl"
  (if go-template-helper-mode
      (go-template-helper--enable)
    (go-template-helper--disable)))

(provide 'go-template-helper-mode)
;;; go-template-helper-mode.el ends here
