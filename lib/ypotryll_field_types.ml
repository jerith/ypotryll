
module Table = struct
  type field =
    | (* t *) Boolean of bool
    | (* b *) Shortshort_int of int
    | (* B *) Shortshort_uint of int
    | (* U *) Short_int of int
    | (* u *) Short_uint of int
    | (* I *) Long_int of int32
    | (* i *) Long_uint of int32
    | (* L *) Longlong_int of int64
    | (* l *) Longlong_uint of int64
    | (* f *) Float of float
    | (* d *) Double of float
    (* | (\* D *\) Decimal of ??? *)
    | (* s *) Short_string of string
    | (* S *) Long_string of string
    (* | (\* A *\) Field_array of ??? *)
    | (* T *) Timestamp of int64
    | (* F *) Field_table of t
    | (* V *) No_value
  and t = (string * field) list
end
