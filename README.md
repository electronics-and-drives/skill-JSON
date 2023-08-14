# SKILL-JSON

The Cadence Skill functions in the repository are used
to convert Disembodied Property Lists (DPLs) to 
JavaScript Object Notation (JSON) strings and backwards.
Utilize the function *EDdpl2json* to convert a DPL in a JSON string
and *EDjson2dpl* to convert a JSON string in a DPL.

The below shown table shows the corresponding data structures
in Skill and JSON.
Skill tables, arrays, database-objects etc. are *NOT* considered 
(a warning message is given).

| JSON              | Skill                           |
| ----------------- | ------------------------------- |
| Object            | Disembodied Property List (DPL) |
| Array (non-empty) | List                            |
| Array (empty)     | -                               |
| Double            | Floatnum                        |
| Integer           | Fixnum                          |
| String            | String                          |
| `true`            | Symbol `t`                      |
| `false`           | `nil` (empty list)              |
| `null`            | Symbol `unbound`                |


JSON arrays are converted to Skill lists, because the elements
of a JSON array can be arbitrary type, but in the Skill domain
the array elements must be of the same type.
An empty JSON array is not considered by *EDjson2dpl*, because 
an empty Skill list is equal to *nil*, which represents
*false* in Skill.

I spend little effort on the performance of the converting functions,
because the JSON files that are considered in my on-top application
are small.

## Setup

Load the file *EDdpl2json.il* with
```scheme
load("EDdpl2json.il")
```
to convert a DPL to JSON and *EDjson2dpl.il* with
```scheme
load("EDjson2dpl.il")
```
to convert JSON in a DPL.

## Example

```scheme
dpl='(nil grades (nil english unbound math 2.3) likesWine nil likesBeer t 
  favouriteFood ("pizza" "pie" "chips") favouriteNumbers (3.141592 42 1337) 
  height 179.56 age 42 lastName "Doe" firstName "John")

json=EDdpl2json(dpl)
>>"{\"firstName\": \"John\", \"lastName\": \"Doe\", \"age\": 42, \"height\":
 179.56, \"favouriteNumbers\": [3.141592, 42, 1337], \"favouriteFood\":
  [\"pizza\", \"pie\", \"chips\"], \"likesBeer\": true, \"likesWine\": false,
  \"grades\": {\"math\": 2.3, \"english\": null}}"

dpl=EDjson2dpl(json)
(nil grades (nil english unbound math 2.3) likesWine nil
likesBeer t favouriteFood ("pizza" "pie" "chips") favouriteNumbers
(3.141592 42 1337) height 179.56 age 42
lastName "Doe" firstName "John"
)
```

## Pretty Print

The above shown JSON string can be pretty-printed in Virtuoso with
the below shown commands

```scheme
(setq str (lsprintf "%L" (lsprintf "%L" json)))

(setq
  cid
  (ipcBeginProcess
    (lsprintf
      "python -c 'import sys,json;data=json.loads(%s);print(json.dumps(data,indent=2))'"
      (substring str 2 (difference (strlen str) 2))
    );lsprintf
  );ipcBeginProcess
);setq

(ipcWait cid)

(setq pretty_json (ipcReadProcess cid))
```
