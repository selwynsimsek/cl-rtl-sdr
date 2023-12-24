;; library

(cffi:define-foreign-library librtlsdr
  (:unix (:or "librtlsdr.so"))
  (:windows (:or "librtlsdr.dll"))
  (t (:or "librtlsdr")))

(cffi:use-foreign-library librtlsdr)
