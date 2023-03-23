/*=============================================================================*
*
*   EDdpl2json
*
*   Purpose:    Convert a disembodied property list (dpl) in a JSON string
*
*   Author:     Matthias Schweikardt
*   Email:      matthias.schweikardt@reutlingen-university.de
*
*   Language:   Cadence Skill
*   Lint:       IQ score is 100 (best is 100) 
*                {sklint ?file "EDdpl2json.il"}
*
*   Globals:
*    - Symbols: None
*    - Forms and Fields: None
*    - Functions:
*       o EDdpl2json
*       o _EDdpl2jsonHier
*
*   Revision:   2022-11-22 Created
*
*   Copyright 2023, Reutlingen University, Electronics & Drives 
*
*   Permission is hereby granted, free of charge, to any person obtaining a 
*   copy of this software and associated documentation files (the "Software"), 
*   to deal in the Software without restriction, including without limitation 
*   the rights to use, copy, modify, merge, publish, distribute, sublicense, 
*   and/or sell copies of the Software, and to permit persons to whom the 
*   Software is furnished to do so, subject to the following conditions:
*
*   The above copyright notice and this permission notice shall be included in 
*   all copies or substantial portions of the Software.
*
*   THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR 
*   IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, 
*   FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL 
*   THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER 
*   LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING 
*   FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER 
*   DEALINGS IN THE SOFTWARE.
*
*=============================================================================*/

;FUNCTION
; EDdpl2json
;
;Description:
; Converts a disembodied property list (dpl) in a JSON string
;
;Parameters:
; dpl              dpl to be converted
;
;Return:
; json             string in JSON format
;
(defun EDdpl2json (dpl)
  (let (port)
    (if (dplp dpl) then

      (setq port (outstring))

      (_EDdpl2jsonHier dpl port)

      (getOutstring port)
    else
      (error "[ED] Provided parameter is not a disembodied property list (dpl)")
    );if
  );let
);defun

;INTERNAL FUNCTION
; _EDdpl2jsonHier
;
;Description:
; Prints any Skill data to a port in JSON syntax.
; Only dpls, lists, flonums, fixnums, strings, the symbols 't and 'unbound
; are considered
;
;Parameters:
; val              Skill data
; port             Output port
;
;Return:
; always 'nil'
;
(defun _EDdpl2jsonHier (val port)

  (cond
    ((fixp val)    (fprintf port "%L" val)     )
    ((floatp val)  (fprintf port "%L" val)     )
    ((stringp val) (fprintf port "\"%s\"" val) )  

    ((and
      (dplp val)
      (oddp (length val))
      (let ((even t))
        (apply
          (quote and)
          (foreach mapcar elem (cdr val)
            (if even then
              (setq even nil)
              (symbolp elem)  
            else
              (setq even t)
            );if
          );foreach
        );apply
      );let
     );and

        (fprintf port "{")

        (let ((first t))

          (foreach elem val->?
            (if first then
              (setq first nil) 
            else
              (fprintf port ", ")
            );if

            (fprintf port "\"%s\": " elem)

            (_EDdpl2jsonHier (get val elem) port)
          );foreach
        );let

        (fprintf port "}")
    )
    ((listp val)

      (if (zerop (length val)) then
        (fprintf port "false")  
      else
        (fprintf port "[")

        (let ((first t))

          (foreach elem val
            (if first then
              (setq first nil)  
            else
              (fprintf port ", ")
            );if

            (if (boundp (quote elem))
              (_EDdpl2jsonHier elem port)
              (fprintf port "null")
            );if
          );foreach
        );let

        (fprintf port "]")
      );if
    );
    ((and (symbolp val) (equal (get_pname val) "t")) (fprintf port "true"))
    ((and (symbolp val) (equal (get_pname val) "unbound")) (fprintf port "null"))
    (t 
      (warn "[ED] Cannot write %L of type %s to JSON, is ignored" val (type val))
    )
  );cond

  nil
);defun