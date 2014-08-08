
module Table = struct
  type field =
    (* TODO: overflows? *)
    | (* t *) Boolean of bool
    | (* b *) Shortshort_int of int
    | (* B *) Shortshort_uint of int
    | (* U *) Short_int of int
    | (* u *) Short_uint of int
    | (* I *) Long_int of int
    | (* i *) Long_uint of int
    | (* L *) Longlong_int of int
    | (* l *) Longlong_uint of int
    | (* f *) Float of float
    | (* d *) Double of float
    (* | (\* D *\) Decimal of ??? *)
    | (* s *) Short_string of string
    | (* S *) Long_string of string
    (* | (\* A *\) Field_array of ??? *)
    | (* T *) Timestamp of int
    | (* F *) Field_table of t
    | (* V *) No_value
  and t = (string * field) list
end
