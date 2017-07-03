#|
  This file is a part of cl-docset-generator project.
|#

(in-package :cl-user)
(defpackage cl-docset-generator-asd
  (:use :cl :asdf))
(in-package :cl-docset-generator-asd)

(defsystem cl-docset-generator
  :version "0.1"
  :author "Masashi Iizuka <liquidz.uo@gmail.com>"
  :license "MIT"
  :depends-on (
               :cl-ppcre
               :alexandria
               :cl-mustache
               :dbd-sqlite3
               )
  :components ((:module "src"
                :components
                ((:file "core"))))
  :description "Docset generator for Common Lisp"
  :long-description
  #.(with-open-file (stream (merge-pathnames
                             #p"README.md"
                             (or *load-pathname* *compile-file-pathname*))
                            :if-does-not-exist nil
                            :direction :input)
      (when stream
        (let ((seq (make-array (file-length stream)
                               :element-type 'character
                               :fill-pointer t)))
          (setf (fill-pointer seq) (read-sequence seq stream))
          seq)))
  :in-order-to ((test-op (test-op cl-docset-generator-test))))
