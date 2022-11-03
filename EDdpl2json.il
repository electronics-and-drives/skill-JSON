(defun EDdpl2json (dpl)
  (let (port)
    (if (dplp dpl) then

      (setq port (outstring))

      (_EDdpl2jsonHier dpl port)

      (getOutstring port)
    else
      (error "[ED] Provided parameter is not a dpl")
    );if
  );let
);defun

(defun _EDdpl2jsonHier (val port)

  (cond
    ((fixp val)    (fprintf port "%L" val)     )
    ((floatp val)  (fprintf port "%L" val)     )
    ((stringp val) (fprintf port "\"%s\"" val) )  
    ((dplp val)

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

            (_EDdpl2jsonHier elem port)
          );foreach
        );let


        (fprintf port "]")
      );if
    );
    ((and (symbolp val) (equal (get_pname val) "t")) (fprintf port "true"))
    (t 
      (warn "[ED] Cannot write %L of type %s to JSON, is ignored" val (type val))
    )
  );cond
);defun
