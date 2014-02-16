;;; ox-mm.el --- MoinMoin Back-End for Org Export Engine

;; Copyright (C) 2014, Martin Becker <becker@rcs.ei.tum.de>

;; Keywords: org, exporter, moinmoin

;; GNU Emacs is free software: you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.

;; GNU Emacs is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with GNU Emacs.  If not, see <http://www.gnu.org/licenses/>.

;;; Commentary:

;; This library implements an exporter to MoinMoin Wiki format for
;; Org exporter, based on `html' back-end.
;;
;; It provides two commands for export, depending on the desired
;; output: `org-mm-export-as-markdown' (temporary buffer) and
;; `org-mm-export-to-markdown' ("mm" file).

;;; Code:

(eval-when-compile (require 'cl))
(require 'ox-html)



;;; User-Configurable Variables

(defgroup org-export-mm nil
  "Options specific to MoinMoin export back-end."
  :tag "MoinMoin Wiki"
  :group 'org-export
  :version "24.4"
  :package-version '(Org . "8.0"))

(defcustom org-mm-headline-style 'atx
  "Style used to format headlines.
This variable can be set to either `atx' or `setext'."
  :group 'org-export-mm
  :type '(choice
	  (const :tag "Use \"atx\" style" atx)
	  (const :tag "Use \"Setext\" style" setext)))


(defcustom org-mm-caption-above nil
  "When non-nil, place caption string before the element.
Otherwise, place it right after it."
  :group 'org-export-mm
  :version "24.4"
  :package-version '(Org . "8.0")
  :type 'boolean)



;;; Define Back-End

(org-export-define-derived-backend 'mm 'html
  :export-block '("MM" "MOINMOIN")
  :filters-alist '((:filter-parse-tree . org-mm-separate-elements))
  :menu-entry
  '(?m "Export to MoinMoin"
       ((?M "To temporary buffer"
	    (lambda (a s v b) (org-mm-export-as-markdown a s v)))
	(?m "To file" (lambda (a s v b) (org-mm-export-to-markdown a s v)))
	(?o "To file and open"
	    (lambda (a s v b)
	      (if a (org-mm-export-to-markdown t s v)
		(org-open-file (org-mm-export-to-markdown nil s v)))))))
  :translate-alist '((bold . org-mm-bold)
                     (clock . ignore)
		     (code . org-mm-verbatim)
		     (comment . (lambda (&rest args) ""))
		     (comment-block . (lambda (&rest args) ""))
		     (example-block . org-mm-example-block)
		     (fixed-width . org-mm-example-block)
		     (footnote-definition . ignore)
		     (footnote-reference . ignore)
		     (headline . org-mm-headline)
		     (horizontal-rule . org-mm-horizontal-rule)
		     (inline-src-block . org-mm-verbatim)
		     (italic . org-mm-italic)
		     (item . org-mm-item)
		     (line-break . org-mm-line-break)
		     (link . org-mm-link)
		     (paragraph . org-mm-paragraph)
		     (plain-list . org-mm-plain-list)
		     (plain-text . org-mm-plain-text)
                     (planning . ignore)
		     (quote-block . org-mm-quote-block)
		     (quote-section . org-mm-example-block)
		     (section . org-mm-section)
                     (subscript . org-mm-subscript)
                     (superscript . org-mm-superscript)
		     (src-block . org-mm-example-block)
                     (strike-through . org-mm-strikethrough)
                     (table . org-mm-table)
                     (table-cell . org-mm-table-cell)
                     (table-row . org-mm-table-row)
		     (template . org-mm-template)
                     (timestamp . ignore)
                     (underline . org-mm-underline)
		     (verbatim . org-mm-verbatim)))

    ;; (center-block . org-html-center-block)
    ;; (clock . org-html-clock)
    ;; (code . org-html-code)
    ;; (drawer . org-html-drawer)
    ;; (dynamic-block . org-html-dynamic-block)
    ;; (entity . org-html-entity)
    ;; (example-block . org-html-example-block)
    ;; (export-block . org-html-export-block)
    ;; (export-snippet . org-html-export-snippet)
    ;; (fixed-width . org-html-fixed-width)
    ;; (footnote-definition . org-html-footnote-definition)
    ;; (footnote-reference . org-html-footnote-reference)
    ;; (headline . org-html-headline)
    ;; (horizontal-rule . org-html-horizontal-rule)
    ;; (inline-src-block . org-html-inline-src-block)
    ;; (inlinetask . org-html-inlinetask)
    ;; (inner-template . org-html-inner-template)
    ;; (italic . org-html-italic)
    ;; (item . org-html-item)
    ;; (keyword . org-html-keyword)
    ;; (latex-environment . org-html-latex-environment)
    ;; (latex-fragment . org-html-latex-fragment)
    ;; (line-break . org-html-line-break)
    ;; (link . org-html-link)
    ;; (paragraph . org-html-paragraph)
    ;; (plain-list . org-html-plain-list)
    ;; (plain-text . org-html-plain-text)
    ;; (planning . org-html-planning)
    ;; (property-drawer . org-html-property-drawer)
    ;; (quote-block . org-html-quote-block)
    ;; (quote-section . org-html-quote-section)
    ;; (radio-target . org-html-radio-target)
    ;; (section . org-html-section)
    ;; (special-block . org-html-special-block)
    ;; (src-block . org-html-src-block)
    ;; (statistics-cookie . org-html-statistics-cookie)
    ;; (strike-through . org-html-strike-through)
    ;; (subscript . org-html-subscript)
    ;; (superscript . org-html-superscript)
    ;; (table . org-html-table)
    ;; (table-cell . org-html-table-cell)
    ;; (table-row . org-html-table-row)
    ;; (target . org-html-target)
    ;; (template . org-html-template)
    ;; (timestamp . org-html-timestamp)
    ;; (underline . org-html-underline)
    ;; (verbatim . org-html-verbatim)
    ;; (verse-block . org-html-verse-block))



;;; Filters

(defun org-mm-separate-elements (tree backend info)
  "Make sure elements are separated by at least one blank line.

TREE is the parse tree being exported.  BACKEND is the export
back-end used.  INFO is a plist used as a communication channel.

Assume BACKEND is `mm'."
  (org-element-map tree org-element-all-elements
    (lambda (elem)
      (unless (eq (org-element-type elem) 'org-data)
	(org-element-put-property
	 elem :post-blank
	 (let ((post-blank (org-element-property :post-blank elem)))
	   (if (not post-blank) 1 (max 1 post-blank)))))))
  ;; Return updated tree.
  tree)



;;; Transcode Functions

;;;; Bold

(defun org-mm-bold (bold contents info)
  "Transcode BOLD object into MoinMoin format.
CONTENTS is the text within bold markup.  INFO is a plist used as
a communication channel. OK"
  (format "'''%s'''" contents))

(defun org-mm-underline (bold contents info)
  "Transcode UNDERLINE object into MoinMoin format."
  (format "__%s__" contents))

(defun org-mm-strikethrough (bold contents info)
  "Transcode UNDERLINE object into MoinMoin format."
  (format "--(%s)--" contents))


;;;; Code and Verbatim

(defun org-mm-verbatim (verbatim contents info)
  "Transcode VERBATIM object into MoinMoin format.
CONTENTS is nil.  INFO is a plist used as a communication
channel. TODO"
  (let ((value (org-element-property :value verbatim)))
    (format (cond ((not (string-match "`" value)) "`%s`")
		  ((or (string-match "\\``" value)
		       (string-match "`\\'" value))
		   "`` %s ``")
		  (t "``%s``"))
	    value)))


;;;; Example Block and Src Block

(defun org-mm-example-block (example-block contents info)
  "Transcode EXAMPLE-BLOCK element into MoinMoin format.
CONTENTS is nil.  INFO is a plist used as a communication
channel. OK"
  (let* ((lang (org-element-property :language example-block))
         (lst-lang (or (cadr (assq (intern lang) org-latex-listings-langs)) lang)))
  (concat "\n{{{!highlight " (format "%s" lst-lang) " \n" (replace-regexp-in-string
   "^" "    "
   (org-remove-indentation
    (org-element-property :value example-block))) "\n}}}\n")))


;;;; Headline

(defun org-mm-headline (headline contents info)
  "Transcode HEADLINE element into MoinMoin format.
CONTENTS is the headline contents.  INFO is a plist used as
a communication channel. OK"
  (unless (org-element-property :footnote-section-p headline)
    (let* ((level (org-export-get-relative-level headline info))
	   (title (org-export-data (org-element-property :title headline) info))
	   (todo (and (plist-get info :with-todo-keywords)
		      (let ((todo (org-element-property :todo-keyword
							headline)))
			(and todo (concat (org-export-data todo info) " ")))))
	   (tags (and (plist-get info :with-tags)
		      (let ((tag-list (org-export-get-tags headline info)))
			(and tag-list
			     (format "     :%s:"
				     (mapconcat 'identity tag-list ":"))))))
	   (priority
	    (and (plist-get info :with-priority)
		 (let ((char (org-element-property :priority headline)))
		   (and char (format "[#%c] " char)))))
	   ;; Headline text without tags.
	   (heading (concat todo priority title)))
      (cond
       ;; Cannot create a headline.  Fall-back to a list.
       ((or (org-export-low-level-p headline info)
	    (not (memq org-mm-headline-style '(atx setext)))
	    (and (eq org-mm-headline-style 'atx) (> level 6))
	    (and (eq org-mm-headline-style 'setext) (> level 2)))
	(let ((bullet
	       (if (not (org-export-numbered-headline-p headline info)) " *"
		 (concat (number-to-string
			  (car (last (org-export-get-headline-number
				      headline info))))
			 "."))))
	  (concat bullet (make-string (- 4 (length bullet)) ? ) heading tags
		  "\n\n"
		  (and contents
		       (replace-regexp-in-string "^" "    " contents)))))
       ;; Use "Setext" style.
       ((eq org-mm-headline-style 'setext)
	(concat heading tags "\n"
		(make-string (length heading) (if (= level 1) ?= ?-))
		"\n\n"
		contents))
       ;; Use "axt" style/moin
       (t 
        (if tags (concat (make-string level ?=) " " heading " " (make-string level ?=) "\n\n''" tags " ''\n\n" contents)
          (concat (make-string level ?=) " " heading " " (make-string level ?=) "\n\n" contents)))))))

(defun org-mm-subscript (subscript contents info)
  "Transcode a SUBSCRIPT object from Org to HTML.
CONTENTS is the contents of the object.  INFO is a plist holding
contextual information."
  (format ",,%s,," contents))

;;;; Superscript

(defun org-mm-superscript (superscript contents info)
  "Transcode a SUPERSCRIPT object from Org to HTML.
CONTENTS is the contents of the object.  INFO is a plist holding
contextual information."
  (format "^^%s^^" contents))



;;;; Horizontal Rule

(defun org-mm-horizontal-rule (horizontal-rule contents info)
  "Transcode HORIZONTAL-RULE element into MoinMoin format.
CONTENTS is the horizontal rule contents.  INFO is a plist used
as a communication channel. OK"
  "----")


;;;; Italic

(defun org-mm-italic (italic contents info)
  "Transcode ITALIC object into MoinMoin format.
CONTENTS is the text within italic markup.  INFO is a plist used
as a communication channel. OK"
  (format "''%s''" contents))


;;;; Item

(defun org-mm-item (item contents info)
  "Transcode ITEM element into MoinMoin format.
CONTENTS is the item contents.  INFO is a plist used as
a communication channel. OK"
  (let* ((type (org-element-property :type (org-export-get-parent item)))
	 (struct (org-element-property :structure item))
	 (bullet (if (not (eq type 'ordered)) " *"
		   (concat (number-to-string
			    (car (last (org-list-get-item-number
					(org-element-property :begin item)
					struct
					(org-list-prevs-alist struct)
					(org-list-parents-alist struct)))))
			   "."))))
    (concat bullet
	    (make-string (- 4 (length bullet)) ? )
	    (case (org-element-property :checkbox item)
	      (on "[X] ")
	      (trans "[-] ")
	      (off "[ ] "))
	    (let ((tag (org-element-property :tag item)))
	      (and tag (format "**%s:** "(org-export-data tag info))))
	    (org-trim (replace-regexp-in-string "^" "    " contents)))))


;;;; Line Break

(defun org-mm-line-break (line-break contents info)
  "Transcode LINE-BREAK object into MoinMoin format.
CONTENTS is nil.  INFO is a plist used as a communication
channel. OK"
  "<<BR>>")


;;;; Link

(defun org-mm-link (link contents info)
  "Transcode LINE-BREAK object into MoinMoin format.
CONTENTS is the link's description.  INFO is a plist used as
a communication channel. TODO"
  (let ((--link-org-files-as-html-maybe
	 (function
	  (lambda (raw-path info)
	    ;; Treat links to `file.org' as links to `file.html', if
            ;; needed.  See `org-html-link-org-files-as-html'.
	    (cond
	     ((and org-html-link-org-files-as-html
		   (string= ".org"
			    (downcase (file-name-extension raw-path "."))))
	      (concat (file-name-sans-extension raw-path) "."
		      (plist-get info :html-extension)))
	     (t raw-path)))))        
	(type (org-element-property :type link)))
    ;; let's statements
    (cond ((member type '("custom-id" "id"))
	   (let ((destination (org-export-resolve-id-link link info)))
	     (if (stringp destination)	; External file.
		 (let ((path (funcall --link-org-files-as-html-maybe
				      destination info)))
		   (if (not contents) (format "[[%s]]" path)
		     (format "[[%s|%s]]" path contents)))
	       (concat
		(and contents (concat contents " "))
		(format "(%s)"
			(format (org-export-translate "See section %s" :html info)
				(mapconcat 'number-to-string
					   (org-export-get-headline-number
					    destination info)
					   ".")))))))
	  ((org-export-inline-image-p link org-html-inline-image-rules)
	   (let ((path (let ((raw-path (org-element-property :path link)))
			 (if (not (file-name-absolute-p raw-path)) raw-path
			   (expand-file-name raw-path)))))
	     (format "![%s](%s)"
		     (let ((caption (org-export-get-caption
				     (org-export-get-parent-element link))))
		       (when caption (org-export-data caption info)))
		     path)))
	  ((string= type "coderef")
	   (let ((ref (org-element-property :path link)))
	     (format (org-export-get-coderef-format ref contents)
		     (org-export-resolve-coderef ref info))))
	  ((equal type "radio")
	   (let ((destination (org-export-resolve-radio-link link info)))
	     (org-export-data (org-element-contents destination) info)))
	  ((equal type "fuzzy")
	   (let ((destination (org-export-resolve-fuzzy-link link info)))
	     (if (org-string-nw-p contents) contents
	       (when destination
		 (let ((number (org-export-get-ordinal destination info)))
		   (when number
		     (if (atom number) (number-to-string number)
		       (mapconcat 'number-to-string number "."))))))))
          ;; default:
	  (t (let* ((raw-path (org-element-property :path link))
		    (path (cond
			   ((member type '("http" "https" "ftp")) (concat type ":" raw-path))
			   ((equal type "file")
                            (cond 
                             ;; link to bib file entries: set path to nil 
                             ((string= ".bib" (downcase (file-name-extension raw-path "."))) nil)
                             ;; all other file links
                             (t (setq raw-path (funcall --link-org-files-as-html-maybe raw-path info))
                             ;; If file path is absolute, prepend it
                             ;; with protocol component - "file://".
                                (if (not (file-name-absolute-p raw-path)) raw-path
                                  (concat "file://" (expand-file-name raw-path))))
                             )) ;; end type=file
                           ;; all other things that are not files: raw
                           (t raw-path)))) ;; end of let*'s vars
             (cond ((and contents path) (format "[[%s|%s]]" path contents ))
                   (path (format "[[%s]]" path))
                   (contents (format "[%s]" contents))
                   (t "???")))))))


;;;; Paragraph

(defun org-mm-paragraph (paragraph contents info)
  "Transcode PARAGRAPH element into MoinMoin format.
CONTENTS is the paragraph contents.  INFO is a plist used as
a communication channel."
  (let ((first-object (car (org-element-contents paragraph))))
    ;; If paragraph starts with a #, protect it.
    (if (and (stringp first-object) (string-match "\\`#" first-object))
	(replace-regexp-in-string "\\`#" "\\#" contents nil t)
      contents)))


;;;; Plain List

(defun org-mm-plain-list (plain-list contents info)
  "Transcode PLAIN-LIST element into MoinMoin format.
CONTENTS is the plain-list contents.  INFO is a plist used as
a communication channel."
  contents)


;;;; Plain Text

(defun org-mm-plain-text (text info)
  "Transcode a TEXT string into MoinMoin format.
TEXT is the string to transcode.  INFO is a plist holding
contextual information. TODO"
  (when (plist-get info :with-smart-quotes)
    (setq text (org-export-activate-smart-quotes text :html info)))
  ;; Protect ambiguous #.  This will protect # at the beginning of
  ;; a line, but not at the beginning of a paragraph.  See
  ;; `org-mm-paragraph'.
  (setq text (replace-regexp-in-string "\n#" "\n\\\\#" text))
  ;; Protect ambiguous !
  (setq text (replace-regexp-in-string "\\(!\\)\\[" "\\\\!" text nil nil 1))
  ;; Protect `, *, _ and \
  (setq text (replace-regexp-in-string "[`*_\\]" "\\\\\\&" text))
  ;; Handle special strings, if required.
  (when (plist-get info :with-special-strings)
    (setq text (org-html-convert-special-strings text)))
  ;; Handle break preservation, if required.
  (when (plist-get info :preserve-breaks)
    (setq text (replace-regexp-in-string "[ \t]*\n" "  \n" text)))
  ;; Return value.
  text)


;;;; Quote Block

(defun org-mm-quote-block (quote-block contents info)
  "Transcode QUOTE-BLOCK element into MoinMoin format.
CONTENTS is the quote-block contents.  INFO is a plist used as
a communication channel."
  (replace-regexp-in-string
   "^" "> "
   (replace-regexp-in-string "\n\\'" "" contents)))


;;;; Table stuff stolen from ox-ascii.el

(defcustom org-mm-table-keep-all-vertical-lines nil
  "Non-nil means keep all vertical lines in ASCII tables.
When nil, vertical lines will be removed except for those needed
for column grouping."
  :group 'org-export-mm
  :version "24.4"
  :package-version '(Org . "8.0")
  :type 'boolean)

(defcustom org-mm-table-widen-columns t
  "Non-nil means widen narrowed columns for export.
When nil, narrowed columns will look in ASCII export just like in
Org mode, i.e. with \"=>\" as ellipsis."
  :group 'org-export-mm
  :version "24.4"
  :package-version '(Org . "8.0")
  :type 'boolean)

(defcustom org-mm-table-use-ascii-art nil
  "Non-nil means table.el tables are turned into ascii-art.

It only makes sense when export charset is `utf-8'.  It is nil by
default since it requires ascii-art-to-unicode.el package.  You
can download it here:

  http://gnuvola.org/software/j/aa2u/ascii-art-to-unicode.el."
  :group 'org-export-mm
  :version "24.4"
  :package-version '(Org . "8.0")
  :type 'boolean)


(defun org-mm-table (table contents info)
  "Transcode a TABLE element from Org to MoinMoin.
CONTENTS is the contents of the table.  INFO is a plist holding
contextual information."
  (let ((caption (org-mm--build-caption table info)))
    (concat
     ;; Possibly add a caption string above.
     (when (and caption org-mm-caption-above) (concat caption "\n"))
     ;; Insert table.  Note: "table.el" tables are left unmodified.
     (cond ((eq (org-element-property :type table) 'org) (replace-regexp-in-string
	     "\n\n" "\n" contents))
	   ((and org-mm-table-use-ascii-art
		 (eq (plist-get info :ascii-charset) 'utf-8)
		 (require 'ascii-art-to-unicode nil t))
	    (with-temp-buffer
	      (insert (org-remove-indentation
		       (org-element-property :value table)))
	      (goto-char (point-min))
	      (aa2u)
	      (goto-char (point-max))
	      (skip-chars-backward " \r\t\n")
	      (buffer-substring (point-min) (point))))
	   (t (org-remove-indentation (org-element-property :value table))))
     ;; Possible add a caption string below.
     (and (not org-mm-caption-above) caption))))


;;;; Table Cell

(defun org-mm--table-cell-width (table-cell info)
  "Return width of TABLE-CELL.

INFO is a plist used as a communication channel.

Width of a cell is determined either by a width cookie in the
same column as the cell, or by the maximum cell's length in that
column.

When `org-mm-table-widen-columns' is non-nil, width cookies
are ignored."
  (let* ((row (org-export-get-parent table-cell))
	 (table (org-export-get-parent row))
	 (col (let ((cells (org-element-contents row)))
		(- (length cells) (length (memq table-cell cells)))))
	 (cache
	  (or (plist-get info :ascii-table-cell-width-cache)
	      (plist-get (setq info
			       (plist-put info :ascii-table-cell-width-cache
					  (make-hash-table :test 'equal)))
			 :ascii-table-cell-width-cache)))
	 (key (cons table col)))
    (or (gethash key cache)
	(puthash
	 key
	 (or (and (not org-mm-table-widen-columns)
		  (org-export-table-cell-width table-cell info))
	     (let* ((max-width 0))
	       (org-element-map table 'table-row
		 (lambda (row)
		   (setq max-width
			 (max (length
			       (org-export-data
				(org-element-contents
				 (elt (org-element-contents row) col))
				info))
			      max-width)))
		 info)
	       max-width))
	 cache))))

(defun org-mm-table-cell (table-cell contents info)
  "Transcode a TABLE-CELL object from Org to ASCII.
CONTENTS is the cell contents.  INFO is a plist used as
a communication channel."
  ;; Determine column width.  When `org-mm-table-widen-columns'
  ;; is nil and some width cookie has set it, use that value.
  ;; Otherwise, compute the maximum width among transcoded data of
  ;; each cell in the column.
  (let ((width (org-mm--table-cell-width table-cell info)))
    ;; When contents are too large, truncate them.
    (unless (or org-mm-table-widen-columns (<= (length contents) width))
      (setq contents (concat (substring contents 0 (- width 2)) "=>")))
    ;; Align contents correctly within the cell.
    (let* ((indent-tabs-mode nil)
	   (data
	    (when contents
	      (org-mm--justify-string
	       contents width
	       (org-export-table-cell-alignment table-cell info)))))
      (setq contents (concat data (make-string (- width (length data)) ? ))))
    ;; Return cell, force border.
    (concat (format "| %s |" contents))))


;;;; Table Row
(defun org-mm-table-row (table-row contents info)
  "Transcode a TABLE-ROW element from Org to ASCII.
CONTENTS is the row contents.  INFO is a plist used as
a communication channel."
  (when (eq (org-element-property :type table-row) 'standard)
      (concat
       "|" ; left border of row
       contents 
       "|" ; right border of row
       ;;(funcall build-hline "+" "-" "+" "+") ;; line after row
       )))

;; (when (and (memq 'bottom borders) (or utf8p (memq 'below borders)))
;;   (if utf8p (funcall build-hline "┕" "━" "┷" "┙")
;;     (funcall build-hline "+" "-" "+" "+")))))))


;;;; Section

(defun org-mm-section (section contents info)
  "Transcode SECTION element into MoinMoin format.
CONTENTS is the section contents.  INFO is a plist used as
a communication channel."
  contents)


;;; Internal Functions

;; Internal functions fall into three categories.

;; The first one is about text formatting.  The core function is
;; `org-mm--current-text-width', which determines the current
;; text width allowed to a given element.  In other words, it helps
;; keeping each line width within maximum text width defined in
;; `org-mm-text-width'.  Once this information is known,
;; `org-mm--fill-string', `org-mm--justify-string',
;; `org-mm--box-string' and `org-mm--indent-string' can
;; operate on a given output string.

;; The second category contains functions handling elements listings,
;; triggered by "#+TOC:" keyword.  As such, `org-mm--build-toc'
;; returns a complete table of contents, `org-mm--list-listings'
;; returns a list of referenceable src-block elements, and
;; `org-mm--list-tables' does the same for table elements.

;; The third category includes general helper functions.
;; `org-mm--build-title' creates the title for a given headline
;; or inlinetask element.  `org-mm--build-caption' returns the
;; caption string associated to a table or a src-block.
;; `org-mm--describe-links' creates notes about links for
;; insertion at the end of a section.  It uses
;; `org-mm--unique-links' to get the list of links to describe.
;; Eventually, `org-mm--translate' translates a string according
;; to language and charset specification.


(defun org-mm--fill-string (s text-width info &optional justify)
  "Fill a string with specified text-width and return it.

S is the string being filled.  TEXT-WIDTH is an integer
specifying maximum length of a line.  INFO is the plist used as
a communication channel.

Optional argument JUSTIFY can specify any type of justification
among `left', `center', `right' or `full'.  A nil value is
equivalent to `left'.  For a justification that doesn't also fill
string, see `org-mm--justify-string'.

Return nil if S isn't a string."
  ;; Don't fill paragraph when break should be preserved.
  (cond ((not (stringp s)) nil)
	((plist-get info :preserve-breaks) s)
	(t (let ((double-space-p sentence-end-double-space))
	     (with-temp-buffer
	       (let ((fill-column text-width)
		     (use-hard-newlines t)
		     (sentence-end-double-space double-space-p))
		 (insert s)
		 (fill-region (point-min) (point-max) justify))
	       (buffer-string))))))

(defun org-mm--justify-string (s text-width how)
  "Justify string S.
TEXT-WIDTH is an integer specifying maximum length of a line.
HOW determines the type of justification: it can be `left',
`right', `full' or `center'."
  (with-temp-buffer
    (insert s)
    (goto-char (point-min))
    (let ((fill-column text-width)
	  ;; Disable `adaptive-fill-mode' so it doesn't prevent
	  ;; filling lines matching `adaptive-fill-regexp'.
	  (adaptive-fill-mode nil))
      (while (< (point) (point-max))
	(justify-current-line how)
	(forward-line)))
    (buffer-string)))

(defun org-mm--indent-string (s width)
  "Indent string S by WIDTH white spaces.
Empty lines are not indented."
  (when (stringp s)
    (replace-regexp-in-string
     "\\(^\\)\\(?:.*\\S-\\)" (make-string width ? ) s nil nil 1)))

(defun org-mm--box-string (s info)
  "Return string S with a partial box to its left.
INFO is a plist used as a communicaton channel."
  (let ((utf8p (eq (plist-get info :ascii-charset) 'utf-8)))
    (format (if utf8p "╭────\n%s\n╰────" ",----\n%s\n`----")
	    (replace-regexp-in-string
	     "^" (if utf8p "│ " "| ")
	     ;; Remove last newline character.
	     (replace-regexp-in-string "\n[ \t]*\\'" "" s)))))

(defun org-mm--current-text-width (element info)
  "Return maximum text width for ELEMENT's contents.
INFO is a plist used as a communication channel."
  (case (org-element-type element)
    ;; Elements with an absolute width: `headline' and `inlinetask'.
    (inlinetask org-mm-inlinetask-width)
    ('headline
     (- org-mm-text-width
	(let ((low-level-rank (org-export-low-level-p element info)))
	  (if low-level-rank (* low-level-rank 2) org-mm-global-margin))))
    ;; Elements with a relative width: store maximum text width in
    ;; TOTAL-WIDTH.
    (otherwise
     (let* ((genealogy (cons element (org-export-get-genealogy element)))
	    ;; Total width is determined by the presence, or not, of an
	    ;; inline task among ELEMENT parents.
	    (total-width
	     (if (loop for parent in genealogy
		       thereis (eq (org-element-type parent) 'inlinetask))
		 org-mm-inlinetask-width
	       ;; No inlinetask: Remove global margin from text width.
	       (- org-mm-text-width
		  org-mm-global-margin
		  (let ((parent (org-export-get-parent-headline element)))
		    ;; Inner margin doesn't apply to text before first
		    ;; headline.
		    (if (not parent) 0
		      (let ((low-level-rank
			     (org-export-low-level-p parent info)))
			;; Inner margin doesn't apply to contents of
			;; low level headlines, since they've got their
			;; own indentation mechanism.
			(if low-level-rank (* low-level-rank 2)
			  org-mm-inner-margin))))))))
       (- total-width
	  ;; Each `quote-block', `quote-section' and `verse-block' above
	  ;; narrows text width by twice the standard margin size.
	  (+ (* (loop for parent in genealogy
		      when (memq (org-element-type parent)
				 '(quote-block quote-section verse-block))
		      count parent)
		2 org-mm-quote-margin)
	     ;; Text width within a plain-list is restricted by
	     ;; indentation of current item.  If that's the case,
	     ;; compute it with the help of `:structure' property from
	     ;; parent item, if any.
	     (let ((parent-item
		    (if (eq (org-element-type element) 'item) element
		      (loop for parent in genealogy
			    when (eq (org-element-type parent) 'item)
			    return parent))))
	       (if (not parent-item) 0
		 ;; Compute indentation offset of the current item,
		 ;; that is the sum of the difference between its
		 ;; indentation and the indentation of the top item in
		 ;; the list and current item bullet's length.  Also
		 ;; remove checkbox length, and tag length (for
		 ;; description lists) or bullet length.
		 (let ((struct (org-element-property :structure parent-item))
		       (beg-item (org-element-property :begin parent-item)))
		   (+ (- (org-list-get-ind beg-item struct)
			 (org-list-get-ind
			  (org-list-get-top-point struct) struct))
		      (length (org-mm--checkbox parent-item info))
		      (length
		       (or (org-list-get-tag beg-item struct)
			   (org-list-get-bullet beg-item struct)))))))))))))

(defun org-mm--build-title
  (element info text-width &optional underline notags toc)
  "Format ELEMENT title and return it.

ELEMENT is either an `headline' or `inlinetask' element.  INFO is
a plist used as a communication channel.  TEXT-WIDTH is an
integer representing the maximum length of a line.

When optional argument UNDERLINE is non-nil, underline title,
without the tags, according to `org-mm-underline'
specifications.

If optional argument NOTAGS is non-nil, no tags will be added to
the title.

When optional argument TOC is non-nil, use optional title if
possible.  It doesn't apply to `inlinetask' elements."
  (let* ((headlinep (eq (org-element-type element) 'headline))
	 (numbers
	  ;; Numbering is specific to headlines.
	  (and headlinep (org-export-numbered-headline-p element info)
	       ;; All tests passed: build numbering string.
	       (concat
		(mapconcat
		 'number-to-string
		 (org-export-get-headline-number element info) ".")
		" ")))
	 (text
	  (org-trim
	   (org-export-data
	    (if (and toc headlinep) (org-export-get-alt-title element info)
	      (org-element-property :title element))
	    info)))
	 (todo
	  (and (plist-get info :with-todo-keywords)
	       (let ((todo (org-element-property :todo-keyword element)))
		 (and todo (concat (org-export-data todo info) " ")))))
	 (tags (and (not notags)
		    (plist-get info :with-tags)
		    (let ((tag-list (org-export-get-tags element info)))
		      (and tag-list
			   (format ":%s:"
				   (mapconcat 'identity tag-list ":"))))))
	 (priority
	  (and (plist-get info :with-priority)
	       (let ((char (org-element-property :priority element)))
		 (and char (format "(#%c) " char)))))
	 (first-part (concat numbers todo priority text)))
    (concat
     first-part
     ;; Align tags, if any.
     (when tags
       (format
	(format " %%%ds"
		(max (- text-width  (1+ (length first-part))) (length tags)))
	tags))
     ;; Maybe underline text, if ELEMENT type is `headline' and an
     ;; underline character has been defined.
     (when (and underline headlinep)
       (let ((under-char
	      (nth (1- (org-export-get-relative-level element info))
		   (cdr (assq (plist-get info :ascii-charset)
			      org-mm-underline)))))
	 (and under-char
	      (concat "\n"
		      (make-string (length first-part) under-char))))))))

(defun org-mm--has-caption-p (element info)
  "Non-nil when ELEMENT has a caption affiliated keyword.
INFO is a plist used as a communication channel.  This function
is meant to be used as a predicate for `org-export-get-ordinal'."
  (org-element-property :caption element))

(defun org-mm--build-caption (element info)
  "Return caption string for ELEMENT, if applicable.

INFO is a plist used as a communication channel.

The caption string contains the sequence number of ELEMENT along
with its real caption.  Return nil when ELEMENT has no affiliated
caption keyword."
  (let ((caption (org-export-get-caption element)))
    (when caption
      ;; Get sequence number of current src-block among every
      ;; src-block with a caption.
      (let ((reference
	     (org-export-get-ordinal
	      element info nil 'org-mm--has-caption-p))
	    (title-fmt (org-mm--translate
			(case (org-element-type element)
			  (table "Table %d:")
			  (src-block "Listing %d:"))
			info)))
	(org-mm--fill-string
	 (concat (format title-fmt reference)
		 " "
		 (org-export-data caption info))
	 (org-mm--current-text-width element info) info)))))

(defun org-mm--build-toc (info &optional n keyword)
  "Return a table of contents.

INFO is a plist used as a communication channel.

Optional argument N, when non-nil, is an integer specifying the
depth of the table.

Optional argument KEYWORD specifies the TOC keyword, if any, from
which the table of contents generation has been initiated."
  (let ((title (org-mm--translate "Table of Contents" info)))
    (concat
     title "\n"
     (make-string (length title)
		  (if (eq (plist-get info :ascii-charset) 'utf-8) ?─ ?_))
     "\n\n"
     (let ((text-width
	    (if keyword (org-mm--current-text-width keyword info)
	      (- org-mm-text-width org-mm-global-margin))))
       (mapconcat
	(lambda (headline)
	  (let* ((level (org-export-get-relative-level headline info))
		 (indent (* (1- level) 3)))
	    (concat
	     (unless (zerop indent) (concat (make-string (1- indent) ?.) " "))
	     (org-mm--build-title
	      headline info (- text-width indent) nil
	      (or (not (plist-get info :with-tags))
		  (eq (plist-get info :with-tags) 'not-in-toc))
	      'toc))))
	(org-export-collect-headlines info n) "\n")))))

(defun org-mm--list-listings (keyword info)
  "Return a list of listings.

KEYWORD is the keyword that initiated the list of listings
generation.  INFO is a plist used as a communication channel."
  (let ((title (org-mm--translate "List of Listings" info)))
    (concat
     title "\n"
     (make-string (length title)
		  (if (eq (plist-get info :ascii-charset) 'utf-8) ?─ ?_))
     "\n\n"
     (let ((text-width
	    (if keyword (org-mm--current-text-width keyword info)
	      (- org-mm-text-width org-mm-global-margin)))
	   ;; Use a counter instead of retreiving ordinal of each
	   ;; src-block.
	   (count 0))
       (mapconcat
	(lambda (src-block)
	  ;; Store initial text so its length can be computed.  This is
	  ;; used to properly align caption right to it in case of
	  ;; filling (like contents of a description list item).
	  (let ((initial-text
		 (format (org-mm--translate "Listing %d:" info)
			 (incf count))))
	    (concat
	     initial-text " "
	     (org-trim
	      (org-mm--indent-string
	       (org-mm--fill-string
		;; Use short name in priority, if available.
		(let ((caption (or (org-export-get-caption src-block t)
				   (org-export-get-caption src-block))))
		  (org-export-data caption info))
		(- text-width (length initial-text)) info)
	       (length initial-text))))))
	(org-export-collect-listings info) "\n")))))

(defun org-mm--list-tables (keyword info)
  "Return a list of tables.

KEYWORD is the keyword that initiated the list of tables
generation.  INFO is a plist used as a communication channel."
  (let ((title (org-mm--translate "List of Tables" info)))
    (concat
     title "\n"
     (make-string (length title)
		  (if (eq (plist-get info :ascii-charset) 'utf-8) ?─ ?_))
     "\n\n"
     (let ((text-width
	    (if keyword (org-mm--current-text-width keyword info)
	      (- org-mm-text-width org-mm-global-margin)))
	   ;; Use a counter instead of retreiving ordinal of each
	   ;; src-block.
	   (count 0))
       (mapconcat
	(lambda (table)
	  ;; Store initial text so its length can be computed.  This is
	  ;; used to properly align caption right to it in case of
	  ;; filling (like contents of a description list item).
	  (let ((initial-text
		 (format (org-mm--translate "Table %d:" info)
			 (incf count))))
	    (concat
	     initial-text " "
	     (org-trim
	      (org-mm--indent-string
	       (org-mm--fill-string
		;; Use short name in priority, if available.
		(let ((caption (or (org-export-get-caption table t)
				   (org-export-get-caption table))))
		  (org-export-data caption info))
		(- text-width (length initial-text)) info)
	       (length initial-text))))))
	(org-export-collect-tables info) "\n")))))

(defun org-mm--unique-links (element info)
  "Return a list of unique link references in ELEMENT.

ELEMENT is either a headline element or a section element.  INFO
is a plist used as a communication channel."
  (let* (seen
	 (unique-link-p
	  (function
	   ;; Return LINK if it wasn't referenced so far, or nil.
	   ;; Update SEEN links along the way.
	   (lambda (link)
	     (let ((footprint
		    (cons (org-element-property :raw-link link)
			  (org-element-contents link))))
	       ;; Ignore LINK if it hasn't been translated already.
	       ;; It can happen if it is located in an affiliated
	       ;; keyword that was ignored.
	       (when (and (org-string-nw-p
			   (gethash link (plist-get info :exported-data)))
			  (not (member footprint seen)))
		 (push footprint seen) link)))))
	 ;; If at a section, find parent headline, if any, in order to
	 ;; count links that might be in the title.
	 (headline
	  (if (eq (org-element-type element) 'headline) element
	    (or (org-export-get-parent-headline element) element))))
    ;; Get all links in HEADLINE.
    (org-element-map headline 'link
      (lambda (l) (funcall unique-link-p l)) info nil nil t)))

(defun org-mm--describe-links (links width info)
  "Return a string describing a list of links.

LINKS is a list of link type objects, as returned by
`org-mm--unique-links'.  WIDTH is the text width allowed for
the output string.  INFO is a plist used as a communication
channel."
  (mapconcat
   (lambda (link)
     (let ((type (org-element-property :type link))
	   (anchor (let ((desc (org-element-contents link)))
		     (if desc (org-export-data desc info)
		       (org-element-property :raw-link link)))))
       (cond
	;; Coderefs, radio links and fuzzy links are ignored.
	((member type '("coderef" "radio" "fuzzy")) nil)
	;; Id and custom-id links: Headlines refer to their numbering.
	((member type '("custom-id" "id"))
	 (let ((dest (org-export-resolve-id-link link info)))
	   (concat
	    (org-mm--fill-string
	     (format
	      "[%s] %s"
	      anchor
	      (if (not dest) (org-mm--translate "Unknown reference" info)
		(format
		 (org-mm--translate "See section %s" info)
		 (mapconcat 'number-to-string
			    (org-export-get-headline-number dest info) "."))))
	     width info) "\n\n")))
	;; Do not add a link that cannot be resolved and doesn't have
	;; any description: destination is already visible in the
	;; paragraph.
	((not (org-element-contents link)) nil)
	(t
	 (concat
	  (org-mm--fill-string
	   (format "[%s] %s" anchor (org-element-property :raw-link link))
	   width info)
	  "\n\n")))))
   links ""))

(defun org-mm--checkbox (item info)
  "Return checkbox string for ITEM or nil.
INFO is a plist used as a communication channel."
  (let ((utf8p (eq (plist-get info :ascii-charset) 'utf-8)))
    (case (org-element-property :checkbox item)
      (on (if utf8p "☑ " "[X] "))
      (off (if utf8p "☐ " "[ ] "))
      (trans (if utf8p "☒ " "[-] ")))))



;;;; Template

(defun org-mm-template (contents info)
  "Return complete document string after MoinMoin conversion.
CONTENTS is the transcoded contents string.  INFO is a plist used
as a communication channel."
  contents)



;;; Interactive function

;;;###autoload
(defun org-mm-export-as-markdown (&optional async subtreep visible-only)
  "Export current buffer to a MoinMoin buffer.

If narrowing is active in the current buffer, only export its
narrowed part.

If a region is active, export that region.

A non-nil optional argument ASYNC means the process should happen
asynchronously.  The resulting buffer should be accessible
through the `org-export-stack' interface.

When optional argument SUBTREEP is non-nil, export the sub-tree
at point, extracting information from the headline properties
first.

When optional argument VISIBLE-ONLY is non-nil, don't export
contents of hidden elements.

Export is done in a buffer named \"*Org MM Export*\", which will
be displayed when `org-export-show-temporary-export-buffer' is
non-nil."
  (interactive)
  (org-export-to-buffer 'mm "*Org MM Export*"
    async subtreep visible-only nil nil (lambda () (text-mode))))

;;;###autoload
(defun org-mm-convert-region-to-mm ()
  "Assume the current region has org-mode syntax, and convert it to MoinMoin.
This can be used in any buffer.  For example, you can write an
itemized list in org-mode syntax in a MoinMoin buffer and use
this command to convert it."
  (interactive)
  (org-export-replace-region-by 'mm))


;;;###autoload
(defun org-mm-export-to-markdown (&optional async subtreep visible-only)
  "Export current buffer to a MoinMoin file.

If narrowing is active in the current buffer, only export its
narrowed part.

If a region is active, export that region.

A non-nil optional argument ASYNC means the process should happen
asynchronously.  The resulting file should be accessible through
the `org-export-stack' interface.

When optional argument SUBTREEP is non-nil, export the sub-tree
at point, extracting information from the headline properties
first.

When optional argument VISIBLE-ONLY is non-nil, don't export
contents of hidden elements.

Return output file's name."
  (interactive)
  (let ((outfile (org-export-output-file-name ".mm" subtreep)))
    (org-export-to-file 'mm outfile async subtreep visible-only)))


(provide 'ox-mm)

;; Local variables:
;; generated-autoload-file: "org-loaddefs.el"
;; End:

;;; ox-mm.el ends here
