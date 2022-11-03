# DPL-JSON

The Cadence Skill functions in the repository are used
to convert Disembodied Property Lists (DPLs) to 
JavaScript Object Notation (JSON) and backwards.

The below shown table shows the corresponding data structures
in Skill and JSON.
Skill tables, arrays etc. are *NOT* considered (a warning message is given).

| JSON              | SKILL                           |
| ----------------- | ------------------------------- |
| Object            | Disembodied Property List (DPL) |
| Array (non-empty) | List                            |
| Array (empty)     | -                               |
| Double            | Floatnum                        |
| Integer           | Fixnum                          |
| String            | String                          |
| `true`            | Symbol `t`                      |
| `false`           | `nil`                           |
| `null`            | Symbol `unbound`                |


