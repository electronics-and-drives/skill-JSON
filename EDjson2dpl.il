/*=============================================================================*
*
*   EDdpl2json
*
*   Purpose:    Convert a JSON string in a disembodied property list (dpl)
*
*   Author:     Matthias Schweikardt
*   Email:      matthias.schweikardt@reutlingen-university.de
*
*   Language:   Cadence Skill
*   Lint:       IQ score is 96 (best is 100) 
*                {sklint ?file "EDjson2dpl.il"}
*
*   Globals:
*    - Symbols: None
*    - Forms and Fields: None
*    - Functions:
*       o EDjson2dpl
*       o _EDjson2dplHier
*       o _EDjson2dplGoToNextNonWhitespace
*       o _EDdpl2jsonGoToNext
*       o _EDdpl2jsonExtractString
*
*   Revision:   2022-11-22 Created
*
*   Copyright 2022, Reutlingen University, Electronics & Drives 
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
; EDjson2dpl
;
;Description:
; Converts a syntax-conformal (!) JSON string in a disembodied property list (dpl)
; Any syntax errors in the string can lead to a corrupted dpl
;
;Parameters:
; json             syntax-conformal (!) JSON string
;
;Return:
; dpl
;
(defun EDjson2dpl (json)
  (let (dpl)
    (setq dpl (car (_EDjson2dplHier (instring json))))

    (unless (complexp dpl)
      dpl
    );unless
  );let
);defun



;INTERNAL FUNCTION
; _EDjson2dplHier
;
;Description:
; Traverse an input stream (port) and identify the JSON-formatted data
;
;Parameters:
; port             Input port
; ?nextChar        Next character to be considered for parsing that was 
;                  popped previously from the port
;
;Return:
; two-element list The first element corresponds to the identified data
;                  and the second element to a character that was popped 
;                  previously from the port but must be considered in 
;                  a following step
;
;
(defun _EDjson2dplHier (port @key (nextChar nil))
  (let (char)

    ;use nextChar as current char when avail, search for next 
    ;non-whitespace char otherwise
    (setq
      char
      (if nextChar
        nextChar
        (_EDjson2dplGoToNextNonWhitespace port)
      );if
    );setq


    (case char
      ; JSON symbol
      (\{

        (let (nextSymbol dpl key value)

          (setq dpl (list nil))
          (setq nextSymbol (quote \,))

          (while
            (and
              (equal nextSymbol (quote \,))
              (setq
                nextSymbol
                (_EDdpl2jsonGoToNext 
                  port 
                  (list 
                    (quote \")
                    (quote \})
                  );list
                );_EDdpl2jsonGoToNext
              );setq
              (equal nextSymbol (quote \"))
            );and

            (setq key (_EDdpl2jsonExtractString port))

            (_EDdpl2jsonGoToNext 
              port 
              (list 
                (quote \:)
              );list
            );_EDdpl2jsonGoToNext

            (setq value (_EDjson2dplHier port))

            (if (nequal (car value) (quote unbound))
              (unless (complexp (car value))
                (putprop
                  dpl
                  (car value)
                  key
                );putprop
              );unless

              (putprop
                dpl
                (quote unbound)
                key
              );putprop
            );when

            (setq nextSymbol (cadr value))

            (unless
              (or
                (equal (cadr value) (quote \,))
                (equal (cadr value) (quote \}))
              );or

              (setq
                nextSymbol
                (_EDdpl2jsonGoToNext 
                  port 
                  (list 
                    (quote \,)
                    (quote \})
                  );list
                );_EDdpl2jsonGoToNext
              );setq
            );unless
          );while

          (list dpl nil)
        );let
      )

      ; JSON array
      (\[

        (let (value retval nextSymbol)

          (setq retval (tconc nil nil))
          (setq nextSymbol (quote \,))

          (while 
            (and
              (equal nextSymbol (quote \,))
              (setq nextSymbol (_EDjson2dplGoToNextNonWhitespace port))
              (nequal nextSymbol (quote \]))
            );and

            (setq value (_EDjson2dplHier port ?nextChar nextSymbol))

            (if (nequal (car value) (quote unbound))
              (unless (complexp (car value))
                (tconc
                  retval
                  (car value)
                );tconc
              );unless
              (tconc
                retval
                (quote unbound)
              );tconc
            );when

            (setq nextSymbol (cadr value))

            (unless
              (or
                (equal (cadr value) (quote \,))
                (equal (cadr value) (quote \]))
              );or

              (setq
                nextSymbol
                (_EDdpl2jsonGoToNext 
                  port 
                  (list 
                    (quote \,)
                    (quote \])
                  );list
                );_EDdpl2jsonGoToNext
              );setq
            );unless

          );while

          (list
            (if (cdar retval)

              (cdar retval)

              ;return complex number when array is empty to prevent that 
              ;an empty list is identified as 'nil'
              (complex 1)

            );if
          );list
        );let
      )

      ; JSON string
      (\"
       (list (_EDdpl2jsonExtractString port) nil)
      )

      ; JSON false
      (f
        (when
          (and
            (equal (getc port) (quote a))
            (equal (getc port) (quote l))
            (equal (getc port) (quote s))
            (equal (getc port) (quote e))
          );and
          (list nil nil)
        );when
      )

      ; JSON true
      ((quote t)
        (when
          (and
            (equal (getc port) (quote r))
            (equal (getc port) (quote u))
            (equal (getc port) (quote e))
          );and
          (list t nil)
        );when
      )

      ; JSON null
      (n
        (when
          (and
            (equal (getc port) (quote u))
            (equal (getc port) (quote l))
            (equal (getc port) (quote l))
          );and
          (list (quote unbound) nil)
        );when
      )

      ; JSON number
      (t
        (let (num (accu (tconc nil nil)))

          (tconc accu char)
          
          (while
            (and
              (setq char (getc port))
              (not
                (or
                  (equal char (quote \ ))
                  (equal char (quote \t))       
                  (equal char (quote \n))   
                  (equal char (quote \,))
                  (equal char (quote \]))
                );or
              );not
            );and
            (tconc accu char)
          );while

          (setq
            num
            (buildString (mapcar (quote symbolToString) (cdar accu)) "")
          );setq

          (list
            (if (zerop (difference (atoi num) (atof num)))
              (atoi num)
              (atof num)
            );if
            char
          );list
        );let
      )
    );case
  );let
);defun _EDjson2dplHier


;INTERNAL FUNCTION
; _EDjson2dplGoToNextNonWhitespace
;
;Description:
; Goes to the next non-whitespace element in an input port and returns
; the (next non-whitespace) character
;
;Parameters:
; port             Input port
;
;Return:
; next non-whitespace character
;
(defun _EDjson2dplGoToNextNonWhitespace (port)
  (let (char)

    (while
      (and
        (setq char (getc port))
        (or
          (equal char (quote \n))
          (equal char (quote \t))
          (equal char (quote \ ))
        );or
      );and
      nil
    );while

    char
  );let
);defun

;INTERNAL FUNCTION
; _EDdpl2jsonGoToNext
;
;Description:
; Goes to next position in input string for a list of possible characters
;
;Parameters:
; port             Input port
; possibilities    List of character where to stop
;
;Return:
; Next character that matches the possibilities list
;
(defun _EDdpl2jsonGoToNext (port possibilities)
  (let (char)

    (while
      (and
        (setq char (getc port))
        (not (member char possibilities))
      );and
      nil
    );while

    char
  );let
);defun _EDdpl2jsonGoToNext

;INTERNAL FUNCTION
; _EDdpl2jsonExtractString
;
;Description:
; Extract next string in an input port
;
;Parameters:
; port             Input port
;
;Return:
; Next string
;
(defun _EDdpl2jsonExtractString (port)
  (let (char (accu (tconc nil nil)))
    
    (while
      (and
        (setq char (getc port))
        (or
          (nequal char (quote \"))
          (equal (cadr accu) (quote \\))
        );or
      );and
      (tconc accu char)
    );while

    (buildString (mapcar (quote symbolToString) (cdar accu)) "")
  );let
);defun _EDdpl2jsonExtractString