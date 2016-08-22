(include-lib "../include/lbx.lfe")
(include-lib "../include/mkapp.lfe")

;An exmaple of a gen_server and its api generated bu mk-genserver
;This creates the info module and the info_api module
(genserver info
  ((info (tuple 'store val)
     (progn
       (ets:insert 'testdb `#(info ,val))
       (let ((`#(info ,val) (hd (ets:lookup 'testdb 'info)))) val)
       `#(noreply ,(state))))
  ) ;end of api
  (print)
)

;Anything here goes in the info module


;Tests
(defmodule mkapp-simple-tests
 (behaviour ltest-unit)
 (export all)
 (import
  (from ltest
   (check-failed-is 2)
   (check-wrong-is-exception 2))))

(include-lib "ltest/include/ltest-macros.lfe")

(defun set-up ()
  (progn
    (ets:new 'testdb '(public named_table))
    (info:start_link)))

(defun tear-down (set-up-result)
  (progn
    (gen_server:stop 'info)
    (ets:delete 'testdb)))

(deftest start-info-server
 (is-match (tuple 'ok _) (set-up)))

(deftest stop-info-server
 (is-equal 'true (tear-down 'ok)))

(deftestcase info-msg (sres)
 (is-equal 'test_msg
   (progn
     (! 'info #(store test_msg))
     (? 200 'ok) ;wait for insert
     (2nd (hd (ets:lookup 'testdb 'info) )))))

(deftestcase initial-state (sres)
 (is-equal '() (sys:get_state 'info)))

(deftestgen stup-setup-cleanup
  `#(foreach
     ,(defsetup set-up)
     ,(defteardown tear-down)
     ,(deftestcases
         info-msg
         initial-state
         )))
