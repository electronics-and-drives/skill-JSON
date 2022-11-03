


(defun EDjson2dpl (json)
  (let (tokens)
    (setq tokens (parseString json ""))
  );let
);defun

(defun _EDjson2dplGotoNextChar (tokens char)

  (while (nequal (car tokens) char)
    (setq tokens (cdar tokens))
  );while

  (cdr tokens)
);defun


(defun _EDjson2dplIgnoreChars (tokens ignoreChars)
  (while 
    (apply
      (quote or)
      (foreach mapcar char ignoreChars
        (equal (car tokens) char)
      );mapcar
    );or
    (setq tokens (cdar tokens))
  );while

  tokens
);defun


(defun _EDjson2dplNextString (tokens)
  (let (string)

    (setq string (tconc nil nil))

    (while (nequal (car tokens) "\"")
      (setq tokens (cdar tokens))
    );while


    (setq tokens (cdr tokens))


    (while 
      (and 
        (nequal (car tokens) "\"")
        (not (equal (cadar string) "\\"))
      );and

      (tconc string (car tokens))
      (setq tokens (cdr tokens))
    );while

    (setq tokens (cdr tokens))

    (list tokens (buildString (cdar string) ""))
  );let
);defun



lines = tconc(nil nil)
port = (infile "test.json")


(while (gets s port) 
  (tconc lines s)
);while

(close port)

json = (buildString (cdar lines) "")



tokens = (setq tokens (parseString json ""))

tokens = _EDjson2dplGotoNextChar(tokens "{")

tokens = _EDjson2dplGotoNextChar(tokens "{")

retval 





