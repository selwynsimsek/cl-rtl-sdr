(defpackage cl-rtl-sdr/tests/main
  (:use :cl
        :cl-rtl-sdr
        :rove))
(in-package :cl-rtl-sdr/tests/main)

;; NOTE: To run this test file, execute `(asdf:test-system :cl-rtl-sdr)' in your Lisp.

(deftest test-target-1
  (testing "should (= 1 1) to be true"
    (ok (= 1 1))))
