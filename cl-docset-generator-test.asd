#|
  This file is a part of lodo project.
|#

(in-package :cl-user)
(defpackage lodo-test-asd
  (:use :cl :asdf))
(in-package :lodo-test-asd)

(defsystem lodo-test
  :author "Masashi Iizuka <liquidz.uo@gmail.com>"
  :license "MIT"
  :depends-on (:lodo
               :prove)
  :components ((:module "t"
                :components
                ((:test-file "lodo"))))
  :description "Test system for lodo"

  :defsystem-depends-on (:prove-asdf)
  :perform (test-op :after (op c)
                    (funcall (intern #.(string :run-test-system) :prove-asdf) c)
                    (asdf:clear-system c)))
