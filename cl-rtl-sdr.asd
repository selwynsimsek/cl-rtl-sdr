(defsystem "cl-rtl-sdr"
  :version "0.1.0"
  :author "Selwyn Simsek"
  :license ""
  :depends-on ("cffi")
  :components ((:module "src"
                :components
                ((:file "package")
                 (:file "library")
                 (:file "main"))))
  :description "Common Lisp bindings for librtlsdr"
  :in-order-to ((test-op (test-op "cl-rtl-sdr/tests"))))

(defsystem "cl-rtl-sdr/tests"
  :author "Selwyn Simsek"
  :license ""
  :depends-on ("cl-rtl-sdr"
               "rove")
  :components ((:module "tests"
                :components
                ((:file "main"))))
  :description "Test system for cl-rtl-sdr"
  :perform (test-op (op c) (symbol-call :rove :run c)))
