
(in-package :cl-rtl-sdr)

;; low level

(cffi:defctype rtlsdr-dev :pointer)

(cffi:defcfun "rtlsdr_get_device_count" :uint32)

(cffi:defcfun "rtlsdr_get_device_name" (:pointer :char)
  (p :uint32))

(cffi:defcfun "rtlsdr_get_device_usb_strings" :int
  (index :uint32)
  (manufacturer (:pointer :char))
  (product (:pointer :char))
  (serial (:pointer :char)))

(cffi:defcfun "rtlsdr_get_index_by_serial" :int
  (serial (:pointer :char)))

(cffi:defcfun "rtlsdr_open" :int
  (dev (:pointer rtlsdr-dev))
  (index :uint32))

(cffi:defcfun "rtlsdr_close" :int
  (dev rtlsdr-dev))

;; ;; configuration functions

;; (cffi:defcfun "rtlsdr_set_xtal_freq" :int
;;   (dev (:pointer :void))
;;   (rtl-freq :uint32)
;;   (tuner-freq :uint32))

;; (cffi:defcfun "rtlsdr_get_xtal_freq" :int
;;   (dev (:pointer :void))
;;   (rtl-freq (:pointer :uint32))
;;   (tuner-freq (:pointer :uint32)))

;; (cffi:defcfun "rtlsdr_get_usb_strings" :int
;;   (dev (:pointer :void))
;;   (manufacturer (:pointer :char))
;;   (product (:pointer :char))
;;   (serial (:pointer :char)))

;; (cffi:defcfun "rtlsdr_wrote_eeprom" :int
;;   (dev (:pointer :void))
;;   (data (:pointer :uint8))
;;   (offset :uint8)
;;   (len :uint16))

;; (cffi:defcfun "rtlsdr_read_eeprom" :int
;;   (dev (:pointer :void))
;;   (data (:pointer :uint8))
;;   (offset :uint8)
;;   (len :uint16))

;; (cffi:defcfun "rtlsdr_set_center_freq" :int
;;   (dev (:pointer :void))
;;   (freq :uint32))

;; (cffi:defcfun "rtlsdr_get_center_freq" :uint32
;;   (dev (:pointer :void)))

;; ;; (cffi:defcfun "rtlsdr_set_freq_correction" :int
;; ;;   (dev (:pointer rtlsdr-dev))
;; ;;   (ppm :int))

;; (cffi:defcfun "rtlsdr_get_freq_correction" :int
;;   (dev (:pointer rtlsdr-dev)))

(cffi:defcenum tuner
  (:unknown 0)
  :e4000
  :fc0012
  :fc0013
  :fc2850
  :r820t
  :r828d)

(cffi:defcfun "rtlsdr_get_tuner_type" tuner
  (dev rtlsdr-dev))

;; (cffi:defcfun "rtlsdr_get_tuner_gains" :int
;;   (dev (:pointer :void))
;;   (gains (:pointer :int)))

;; (cffi:defcfun "rtlsdr_set_tuner_gain" :int
;;   (dev :pointer)
;;   (gain :int))

;; (cffi:defcfun "rtlsdr_get_tuner_gain" :int
;;   (dev :pointer))

;; (cffi:defcfun "rtlsdr_set_tuner_if_gain" :int
;;   (dev (:pointer :void))
;;   (stage :int)
;;   (gain :int))

;; (cffi:defcfun "rtlsdr_set_tuner_gain_mode" :int
;;   (dev (:pointer :void))
;;   (manual :int))

;; (cffi:defcfun "rtlsdr_set_sample_rate" :int
;;   (dev (:pointer :void))
;;   (rate :uint32))

;; (cffi:defcfun "rtlsdr_get_sample_rate" :uint32
;;   (dev (:pointer :void)))

;; (cffi:defcfun "rtlsdr_set_testmode" :int
;;   (dev (:pointer :void))
;;   (on :int))

;; (cffi:defcfun "rtlsdr_set_direct_sampling" :int
;;   (dev (:pointer :void))
;;   (on :int))

;; (cffi:defcfun "rtlsdr_get_direct_sampling" :int
;;   (dev (:pointer :void)))

;; (cffi:defcfun "rtlsdr_set_offset_tuning" :int
;;   (dev (:pointer :void))
;;   (on :int))

;; (cffi:defcfun "rtlsdr_get_offset_tuning" :int
;;   (dev (:pointer :void)))

;; (cffi:defcfun "rtlsdr_reset_buffer" :int
;;   (dev (:pointer :void)))

;; (cffi:defcfun "rtlsdr_read_sync" :int
;;   (dev :pointer)
;;   (buf :pointer)
;;   (len :int)
;;   (n-read :pointer))

;(cffi:defctype read-async-callback )

; rtlsdr_wait_async (deprecated)
; rtlsdr_read_async TODO


;; (defcfun "rtlsdr_cancel_async" :int
;;   (dev (:pointer :void)))

;; (defcfun "rtlsdr_set_bias_tee" :int
;;   (dev (:pointer :void))
;;   (on :int))

;; (defcfun "rtlsdr_set_bias_tee_gpio" :int
;;   (dev (:pointer :void))
;;   (gpio :int)
;;   (on :int))

;; high level

(defun device-count () (rtlsdr-get-device-count))
(defun device-connected-p () (< 0 (device-count)))
(defun device-name (&optional (index 0))
  (cffi:foreign-string-to-lisp (rtlsdr-get-device-name index)))

(defun device-usb-strings (&optional (index 0))
  (cffi:with-foreign-objects ((m :char 256)
                              (p :char 256)
                              (s :char 256))
    (let ((result (rtlsdr-get-device-usb-strings index m p s)))
      (if (zerop result)
          (values (cffi:foreign-string-to-lisp m)
                  (cffi:foreign-string-to-lisp p)
                  (cffi:foreign-string-to-lisp s))
          (error "non zero return value ~a" result)))))

(defun index-by-serial (serial)
  (cffi:with-foreign-string (pointer serial)
    (let ((index (rtlsdr-get-index-by-serial pointer)))
      (when (= -3 index)
        (error "devices were found but none with matching name"))
      (when (= -2 index)
        (error "no devices found at all"))
      (when (= -1 index)
        (error "name was null"))
      index)))

(defmacro with-rtl-sdr ((var &optional (index 0)) &body body)
  (let ((index-name (gensym "INDEX"))
        (pointer-name (gensym "POINTER")))
    (assert (symbolp var))
    `(let ((,index-name ,index))
       (cffi:with-foreign-pointer (,pointer-name 1)
         (unless (zerop (rtlsdr-open ,pointer-name ,index-name))
           (error "open not zero"))
         (let ((,var (cffi:mem-ref ,pointer-name :pointer)))
           (unwind-protect
                (progn ,@body)
             (rtlsdr-close ,var)))))))
