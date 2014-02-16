# ox-mm

MoinMoin-Exporter for Emacs org-mode 8.0+

## Installation

Place the file 'ox-mm.el' where emacs can find it. E.g., place it in `~/.emacs.d/elisp/` and add the path to your `.emacs` using 
```lisp
(add-to-list 'load-path "~/.emacs.d/elisp")
```

Then add the following code to your `.emacs` file to load the exporter plugin:
```lisp
  (require 'ox-mm)
```

That's it. 

## Usage
You can export using the org-mode exporter menu (`C-c C-e`).
