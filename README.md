# cl-docset-generator
Docset generator for Common Lisp

## Requirements

* [sqlite3](https://sqlite.org/cli.html)

## Installation

* clone to your local-projects
```sh
# ex
git clone https://github.com/liquidz/cl-docset-generator ~/.roswell/local-projects
```
* register local project
```lisp
(ql:register-local-projects)
```

## Usage

```lisp
(in-package :cl-user)
(defpackage foo.bar
  (:use :cl :docset-generator))
(in-package :foo.bar)

;; define Docset
(let ((docset (make-docset :id "foo"
                           :name "foo"
                           :family "foo"
                           :base-dir "/tmp")))
  ;; add record to docset
  (add-record docset
              (make-record :name "bar"
                           :type "Guide"
                           :prefix "foo"
                           :body "hello"))
  ;; "/tmp/foo.docset" will be generated
  (generate docset))
```

Other examples are [here](example).

