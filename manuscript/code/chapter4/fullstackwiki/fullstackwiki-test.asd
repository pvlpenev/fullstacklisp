(in-package :cl-user)
(defpackage fullstackwiki-test-asd
  (:use :cl :asdf))
(in-package :fullstackwiki-test-asd)

(defsystem fullstackwiki-test
  :author "Pavel"
  :license "MIT"
  :depends-on (:fullstackwiki
               :prove)
  :components ((:module "t"
                :components
                ((:file "fullstackwiki"))))
  :perform (load-op :after (op c) (asdf:clear-system c)))
