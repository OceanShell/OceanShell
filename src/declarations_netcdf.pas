unit declarations_netcdf;

{$mode objfpc}{$H+}

(*
These declarations facilitate the use of netcdf with Lazarus.
Alexander Smirnov
Arctic and Antarctic Research Institute
St. Petersburg, Russia
2011-2019
*)

interface

{$IFDEF WINDOWS}
const
  netcdf='netcdf.dll';
{$ENDIF}

{$IFDEF LINUX}
const
  netcdf='libnetcdf.so';
{$ENDIF}


type size_t = PtrUInt;
     PArraySize_t = ^TArraySize_t;
     TArraySize_t = array [Word] of PtrUInt;
     ptrdiff_t = PtrUInt;

    { cmode =   (NC_NOCLOBBER,
                NC_SHARE,
                NC_64BIT_OFFSET,
                NC_64BIT_DATA,
                NC_NETCDF4,
                NC_CLASSIC_MODEL,
                NC_DISKLESS,
                NC_MMAP
                );
      mode =   (NC_NOWRITE,
                NC_WRITE,
                NC_SHARE,
                NC_DISKLESS,
                NC_MMAP
                ); }

     nc_type = (NC_NAT,     { 0 -> NAT = 'Not A Type' (c.f. NaN) }
                NC_BYTE,    { 1 -> signed 1 byte integer }
                NC_CHAR,    { 2 -> ISO/ASCII character }
                NC_SHORT,   { 3 -> signed 2 byte integer }
                NC_INT,     { 4 -> signed 4 byte integer }
                NC_FLOAT,   { 5 -> single precision floating point number }
                NC_DOUBLE,  { 6 -> double precision floating point number }
                NC_UBYTE,   { 7 -> unsigned 1 byte int}
                NC_USHORT,  { 8 -> unsigned 2-byte int}
                NC_UINT,    { 9 -> unsigned 4-byte int}
                NC_INT64,   {10 -> signed 8-byte int}
                NC_UINT64,  {11 -> unsigned 8-byte int}
                NC_STRING,  {12 -> string}
                NC_VLEN,    {13 -> vlen (variable-length) types}
                NC_OPAQUE,  {14 -> opaque types}
                NC_ENUM,    {15 -> enum types}
                NC_COMPOUND {16 -> compound types}
                );

(* ============================== NetCDF Files ============================== *)
//function nc__create;             //CHECK!!
//function nc__enddef;             //CHECK!!
//function nc__open;               //CHECK!!
//function NC_check_file_type;     //CHECK!!
function nc_close    (ncid : integer) : integer; cdecl; external netcdf;
function nc_create (path : pAnsiChar; cmode : integer; var ncidp : integer) :integer; cdecl; external netcdf;
function nc_enddef   (ncid : integer) : integer; cdecl; external netcdf;
function nc_inq (ncid : integer; var ndimsp : integer; var nvarsp : integer; var ngattsp : integer; var unlimdimidp : integer) : integer; cdecl; external netcdf;
function nc_inq_format   (ncid : integer; var formatp : integer)     : integer; cdecl; external netcdf;
//function nc_inq_format_extended; //CHECK!!
//function nc_inq_path;            //CHECK!!
//function nc_inq_type;            //CHECK!!
function nc_open   (path : pAnsiChar; mode  : integer; var ncidp : integer) :integer; cdecl; external netcdf;
//function nc_open_mem;            //CHECK!!
function nc_redef    (ncid : integer) : integer; cdecl; external netcdf;
function nc_set_fill (ncid : integer; fillmode : integer; var old_modep :integer) : integer; cdecl; external netcdf;
function nc_sync     (ncid : integer) : integer; cdecl; external netcdf;



(* =============================== Dimentions =============================== *)
function nc_def_dim      (ncid : integer; name : pAnsiChar; len : size_t; var idp : integer) : integer; cdecl; external netcdf;
function nc_inq_dim      (ncid : integer; dimid : integer; var name : array of pAnsiChar; var lenp : size_t) : integer; cdecl; external netcdf;
function nc_inq_dimid    (ncid : integer; name : pAnsiChar; var idp : integer)            : integer; cdecl; external netcdf;
function nc_inq_dimlen   (ncid : integer; dimid : integer; var lenp : size_t)             : integer; cdecl; external netcdf;
function nc_inq_dimname  (ncid : integer; dimid : integer; var name : array of pAnsiChar) : integer; cdecl; external netcdf;
function nc_inq_ndims    (ncid : integer; var ndimsp : integer)                           : integer; cdecl; external netcdf;
function nc_inq_unlimdim (ncid : integer; var unlimdimidp : integer)                      : integer; cdecl; external netcdf;
function nc_rename_dim   (ncid : integer; dimid : integer; name : pAnsiChar)              : integer; cdecl; external netcdf;



(* =============================== Variables ================================ *)
//function nc_def_var (ncid : integer; name : pAnsiChar; xtype : nc_type; ndims :integer; dimidsp : TArraySize_t; var varidp : integer) : integer; cdecl; external netcdf;
function nc_def_var (ncid : integer; name : pAnsiChar; xtype : nc_type; ndims :integer; dimidsp : array of integer; var varidp : integer) : integer; cdecl; external netcdf;
//function nc_free_string;       //CHECK!!
// nc_get_var - read an entire variable in one call
//function nc_get_var;           //CHECK!!
function nc_get_var_double     (ncid : integer; varid : integer; Var ip : array of double)    :integer; cdecl; external netcdf;
function nc_get_var_float      (ncid : integer; varid : integer; Var ip : array of single)    :integer; cdecl; external netcdf;
function nc_get_var_int        (ncid : integer; varid : integer; Var ip : array of integer)   :integer; cdecl; external netcdf;
function nc_get_var_long       (ncid : integer; varid : integer; Var ip : array of int64)     :integer; cdecl; external netcdf;
function nc_get_var_longlong   (ncid : integer; varid : integer; Var ip : array of int64)     :integer; cdecl; external netcdf;
function nc_get_var_schar      (ncid : integer; varid : integer; Var ip : array of shortint)  :integer; cdecl; external netcdf;
function nc_get_var_short      (ncid : integer; varid : integer; Var ip : array of smallint)  :integer; cdecl; external netcdf;
//function nc_get_var_string;    //CHECK
function nc_get_var_text       (ncid : integer; varid : integer; Var ip : array of pAnsiChar) :integer; cdecl; external netcdf;
//function nc_get_var_ubyte;     //CHECK
function nc_get_var_uchar      (ncid : integer; varid : integer; Var ip : array of pwidechar) :integer; cdecl; external netcdf;
//function nc_get_var_uint;      //CHECK
//function nc_get_var_ulonglong; //CHECK
//function nc_get_var_ushort;    //CHECK
// nc_get_var1 - single value for selected variable
//function nc_get_var1;          //CHECK!!
function nc_get_var1_double     (ncid : integer; varid : integer; var indexp :TArraySize_t; Var ip : array of double)    : integer; cdecl; external netcdf;
function nc_get_var1_float      (ncid : integer; varid : integer; var indexp :TArraySize_t; Var ip : array of single)    : integer; cdecl; external netcdf;
function nc_get_var1_int        (ncid : integer; varid : integer; var indexp :TArraySize_t; Var ip : array of integer)   : integer; cdecl; external netcdf;
function nc_get_var1_long       (ncid : integer; varid : integer; var indexp :TArraySize_t; Var ip : array of int64)     : integer; cdecl; external netcdf;
function nc_get_var1_longlong   (ncid : integer; varid : integer; var indexp :TArraySize_t; Var ip : array of int64)     : integer; cdecl; external netcdf;
function nc_get_var1_schar      (ncid : integer; varid : integer; var indexp :TArraySize_t; Var ip : array of pAnsiChar) : integer; cdecl; external netcdf;
function nc_get_var1_short      (ncid : integer; varid : integer; var indexp :TArraySize_t; Var ip : array of smallint)  : integer; cdecl; external netcdf;
//function nc_get_var1_string;    //CHECK
function nc_get_var1_text       (ncid : integer; varid : integer; var indexp :TArraySize_t; Var ip : array of pAnsiChar) : integer; cdecl; external netcdf;
//function nc_get_var1_ubyte;     //CHECK
function nc_get_var1_uchar      (ncid : integer; varid : integer; var indexp :TArraySize_t; Var ip : array of pwidechar) : integer; cdecl; external netcdf;
//function nc_get_var1_uint;      //CHECK
//function nc_get_var1_ulonglong; //CHECK
//function nc_get_var1_ushort;    //CHECK
// nc_get_vara - read an array of values from a variable
//function nc_get_vara;           //CHECK!!
function nc_get_vara_double     (ncid : integer; varid : integer; startp :TArraySize_t; countp : TArraySize_t; Var ip : array of double)    : integer; cdecl; external netcdf;
function nc_get_vara_float      (ncid : integer; varid : integer; startp :TArraySize_t; countp : TArraySize_t; Var ip : array of single)    : integer; cdecl; external netcdf;
function nc_get_vara_int        (ncid : integer; varid : integer; startp :TArraySize_t; countp : TArraySize_t; Var ip : array of integer)   : integer; cdecl; external netcdf;
function nc_get_vara_long       (ncid : integer; varid : integer; startp :TArraySize_t; countp : TArraySize_t; Var ip : array of int64)     : integer; cdecl; external netcdf;
function nc_get_vara_longlong   (ncid : integer; varid : integer; startp :TArraySize_t; countp : TArraySize_t; Var ip : array of int64)     : integer; cdecl; external netcdf;
function nc_get_vara_schar      (ncid : integer; varid : integer; startp :TArraySize_t; countp : TArraySize_t; Var ip : array of pAnsiChar) : integer; cdecl; external netcdf;
function nc_get_vara_short      (ncid : integer; varid : integer; startp :TArraySize_t; countp : TArraySize_t; Var ip : array of smallint)  : integer; cdecl; external netcdf;
//function nc_get_vara_string;    //CHECK
function nc_get_vara_text       (ncid : integer; varid : integer; startp :TArraySize_t; countp : TArraySize_t; Var ip : array of pAnsiChar) : integer; cdecl; external netcdf;
//function nc_get_vara_ubyte;     //CHECK
function nc_get_vara_uchar      (ncid : integer; varid : integer; startp :TArraySize_t; countp : TArraySize_t; Var ip : array of pwidechar) : integer; cdecl; external netcdf;
//function nc_get_vara_uint;      //CHECK
//function nc_get_vara_ulonglong; //CHECK
//function nc_get_vara_ushort;    //CHECK
// nc_get_vars - read a strided array from a variable
//function nc_get_vars;           //CHECK;
function nc_get_vars_double (ncid : integer; varid : integer; var startp :size_t; var countp : size_t; var stridep : ptrdiff_t; ip : pointer) :integer; cdecl; external netcdf;
function nc_get_vars_float  (ncid : integer; varid : integer; var startp :size_t; var countp : size_t; var stridep : ptrdiff_t; ip : pointer) :integer; cdecl; external netcdf;
function nc_get_vars_int    (ncid : integer; varid : integer; var startp :size_t; var countp : size_t; var stridep : ptrdiff_t; ip : pointer) :integer; cdecl; external netcdf;
function nc_get_vars_long   (ncid : integer; varid : integer; var startp :size_t; var countp : size_t; var stridep : ptrdiff_t; ip : pointer) :integer; cdecl; external netcdf;
function nc_get_vars_longlong   (ncid : integer; varid : integer; var startp :size_t; var countp : size_t; var stridep : ptrdiff_t; ip : pointer) :integer; cdecl; external netcdf;
function nc_get_vars_schar  (ncid : integer; varid : integer; var startp :size_t; var countp : size_t; var stridep : ptrdiff_t; ip : pointer) :integer; cdecl; external netcdf;
function nc_get_vars_short  (ncid : integer; varid : integer; var startp :size_t; var countp : size_t; var stridep : ptrdiff_t; ip : pointer) :integer; cdecl; external netcdf;
//function nc_get_vars_string;    //CHECK
function nc_get_vars_text   (ncid : integer; varid : integer; var startp :size_t; var countp : size_t; var stridep : ptrdiff_t; ip : pAnsiChar) : integer;cdecl; external netcdf;
//function nc_get_vars_ubyte;     //CHECK
function nc_get_vars_uchar  (ncid : integer; varid : integer; var startp :size_t; var countp : size_t; var stridep : ptrdiff_t; ip : pointer) :integer; cdecl; external netcdf;
//function nc_get_vars_uint;      //CHECK
//function nc_get_vars_ulonglong; //CHECK
//function nc_get_vars_ushort;    //CHECK

// Inq variable
//function nc_inq_unlimdims;      //CHECK
function nc_inq_var (ncid : integer; varid : integer; var name : array of pAnsiChar; var xtypep : nc_type; var ndimsp : integer; var dimidsp : integer; var nattsp :integer) : integer; cdecl; external netcdf;
//function nc_inq_var_chunking;   //CHECK;
function nc_inq_var_deflate (ncid : integer; varid : integer; Var shufflep: integer; Var deflatep : integer; Var deflate_levelp : integer) : integer; cdecl; external netcdf;
//function nc_inq_var_endian;     //CHECK
//function nc_inq_var_fill;       //CHECK
//function nc_inq_var_fletcher32; //CHECK
//function nc_inq_var_szip;       //CHECK
function nc_inq_vardimid (ncid : integer; varid : integer; var dimidsp :array of integer) : integer; cdecl; external netcdf;
function nc_inq_varid    (ncid : integer; name : pAnsiChar; var varidp : integer)         : integer; cdecl; external netcdf;
function nc_inq_varname  (ncid : integer; varid : integer; var name : array of pAnsiChar) : integer; cdecl; external netcdf;
function nc_inq_varnatts (ncid : integer; varid : integer; var nattsp :integer)           : integer; cdecl; external netcdf;
function nc_inq_varndims (ncid : integer; varid : integer; var ndimsp :integer)           : integer; cdecl; external netcdf;
function nc_inq_vartype  (ncid : integer; varid : integer; var xtypep :nc_type)           : integer; cdecl; external netcdf;

// nc_put_var - write an entire variable with one call
//function nc_put_var;          //CHECK
function nc_put_var_double    (ncid:integer; varid:integer; op: array of double)    :integer; cdecl; external netcdf;
function nc_put_var_float     (ncid:integer; varid:integer; op: array of single)    :integer; cdecl; external netcdf;
function nc_put_var_int       (ncid:integer; varid:integer; op: array of integer)   :integer; cdecl; external netcdf;
function nc_put_var_long      (ncid:integer; varid:integer; op: array of integer)   :integer; cdecl; external netcdf;
function nc_put_var_longlong  (ncid:integer; varid:integer; op: array of integer)   :integer; cdecl; external netcdf;
function nc_put_var_schar     (ncid:integer; varid:integer; op: array of shortint)  :integer; cdecl; external netcdf;
function nc_put_var_short     (ncid:integer; varid:integer; op: array of smallint)  :integer; cdecl; external netcdf;
//function nc_put_var_string;   //CHECK
function nc_put_var_text      (ncid:integer; varid:integer; op: array of pAnsiChar) :integer; cdecl; external netcdf;
//function nc_put_var_ubyte;    //CHECK
function nc_put_var_uchar     (ncid:integer; varid:integer; op: array of byte)      :integer; cdecl; external netcdf;
//function nc_put_var_uint;     //CHECK
//function nc_put_var_ulonglong;//CHECK
//function nc_put_var_ushort;   //CHECK
// nc_put_var1 - write one datum
//function nc_put_var1;          //CHECK!!
function nc_put_var1_double    (ncid : integer; varid : integer; var indexp :size_t; op : pointer) : integer; cdecl; external netcdf;
function nc_put_var1_float     (ncid : integer; varid : integer; var indexp :TArraySize_t; op : array of single) : integer; cdecl; external netcdf;
function nc_put_var1_int       (ncid : integer; varid : integer; var indexp :size_t; op : pointer) : integer; cdecl; external netcdf;
function nc_put_var1_long      (ncid : integer; varid : integer; var indexp :size_t; op : pointer) : integer; cdecl; external netcdf;
function nc_put_var1_longlong  (ncid : integer; varid : integer; var indexp :size_t; op : pointer) : integer; cdecl; external netcdf;
function nc_put_var1_schar     (ncid : integer; varid : integer; var indexp :size_t; op : pointer) : integer; cdecl; external netcdf;
function nc_put_var1_short     (ncid : integer; varid : integer; var indexp :size_t; op : pointer) : integer; cdecl; external netcdf;
//function nc_put_var1_string;   //CHECK
function nc_put_var1_text      (ncid : integer; varid : integer; var indexp :size_t; op : pAnsiChar) : integer; cdecl; external netcdf;
//function nc_put_var1_ubyte;    //CHECK
function nc_put_var1_uchar     (ncid : integer; varid : integer; var indexp :size_t; op : pointer) : integer; cdecl; external netcdf;
//function nc_put_var1_uint;     //CHECK
//function nc_put_var1_ulonglong;//CHECK
//function nc_put_var1_ushort;   //CHECK
// nc_put_var_a - write an array of values to a variable
//function nc_put_vara;          //CHECK
function nc_put_vara_double    (ncid : integer; varid : integer; var startp :size_t; var countp : size_t; op : pointer) : integer; cdecl; external netcdf;
function nc_put_vara_float     (ncid : integer; varid : integer; var startp :size_t; var countp : size_t; op : pointer) : integer; cdecl; external netcdf;
function nc_put_vara_int       (ncid : integer; varid : integer; var startp :size_t; var countp : size_t; op : pointer) : integer; cdecl; external netcdf;
function nc_put_vara_long      (ncid : integer; varid : integer; var startp :size_t; var countp : size_t; op : pointer) : integer; cdecl; external netcdf;
function nc_put_vara_longlong  (ncid : integer; varid : integer; var startp :size_t; var countp : size_t; op : pointer) : integer; cdecl; external netcdf;
function nc_put_vara_schar     (ncid : integer; varid : integer; var startp :size_t; var countp : size_t; op : pointer) : integer; cdecl; external netcdf;
function nc_put_vara_short     (ncid : integer; varid : integer; var startp :size_t; var countp : size_t; op : pointer) : integer; cdecl; external netcdf;
//function nc_put_vara_string;   //CHECK
function nc_put_vara_text      (ncid : integer; varid : integer; var startp :size_t; var countp : size_t; op : pAnsiChar) : integer; cdecl; external netcdf;
//function nc_put_vara_ubyte;    //CHECK
function nc_put_vara_uchar     (ncid : integer; varid : integer; var startp :size_t; var countp : size_t; op : pointer) : integer; cdecl; external netcdf;
//function nc_put_vara_uint;     //CHECK
//function nc_put_vara_ulonglong;//CHECK
//function nc_put_vara_ushort;   //CHECK
// nc_put_vars - write a strided array of values to a variable
//function nc_put_vars; //CHECK
function nc_put_vars_double (ncid : integer; varid : integer; var startp :size_t; var countp : size_t; var stridep : ptrdiff_t; op : pointer) :integer; cdecl; external netcdf;
function nc_put_vars_float  (ncid : integer; varid : integer; var startp :size_t; var countp : size_t; var stridep : ptrdiff_t; op : pointer) :integer; cdecl; external netcdf;
function nc_put_vars_int    (ncid : integer; varid : integer; var startp :size_t; var countp : size_t; var stridep : ptrdiff_t; op : pointer) :integer; cdecl; external netcdf;
function nc_put_vars_long   (ncid : integer; varid : integer; var startp :size_t; var countp : size_t; var stridep : ptrdiff_t; op : pointer) :integer; cdecl; external netcdf;
function nc_put_vars_longlong   (ncid : integer; varid : integer; var startp :size_t; var countp : size_t; var stridep : ptrdiff_t; op : pointer) :integer; cdecl; external netcdf;
function nc_put_vars_schar  (ncid : integer; varid : integer; var startp :size_t; var countp : size_t; var stridep : ptrdiff_t; op : pointer) :integer; cdecl; external netcdf;
function nc_put_vars_short  (ncid : integer; varid : integer; var startp :size_t; var countp : size_t; var stridep : ptrdiff_t; op : pointer) :integer; cdecl; external netcdf;
//function nc_put_vars_string;   //CHECK
function nc_put_vars_text   (ncid : integer; varid : integer; var startp :size_t; var countp : size_t; var stridep : ptrdiff_t; op : pAnsiChar) : integer;cdecl; external netcdf;
//function nc_put_vars_ubyte;    //CHECK
function nc_put_vars_uchar  (ncid : integer; varid : integer; var startp :size_t; var countp : size_t; var stridep : ptrdiff_t; op : pointer) :integer; cdecl; external netcdf;
//function nc_put_vars_uint;     //CHECK
//function nc_put_vars_ulonglong;//CHECK
//function nc_put_vars_ushort;   //CHECK
// Rename variable
function nc_rename_var (ncid : integer; varid : integer; name : pAnsiChar) :integer; cdecl; external netcdf;



(* ============================== Attributes  =============================== *)
// Delete attribute
function nc_del_att (ncid : integer; varid : integer; name : pAnsiChar) :integer; cdecl; external netcdf;
// Get attribute
//function nc_get_att;           //CHECK!!
function nc_get_att_double   (ncid : integer; varid : integer; name : pAnsiChar;var ip : array of double)    : integer; cdecl; external netcdf;
function nc_get_att_float    (ncid : integer; varid : integer; name : pAnsiChar;var ip : array of single)    : integer; cdecl; external netcdf;
function nc_get_att_int      (ncid : integer; varid : integer; name : pAnsiChar;var ip : array of integer)   : integer; cdecl; external netcdf;
function nc_get_att_long     (ncid : integer; varid : integer; name : pAnsiChar;var ip : array of integer)   : integer; cdecl; external netcdf;
//function nc_get_att_longlong;  //CHECK!!
function nc_get_att_schar    (ncid : integer; varid : integer; name : pAnsiChar;var ip : array of shortint)  : integer; cdecl; external netcdf;
function nc_get_att_short    (ncid : integer; varid : integer; name : pAnsiChar;var ip : array of smallint)  : integer; cdecl; external netcdf;
//function nc_get_att_string;    //CHECK!!
function nc_get_att_text     (ncid : integer; varid : integer; name : pAnsiChar;var ip : array of pAnsiChar) : integer; cdecl; external netcdf;
//function nc_get_att_ubyte;     //CHECK!!
function nc_get_att_uchar    (ncid : integer; varid : integer; name : pAnsiChar;var ip : array of byte)      : integer; cdecl; external netcdf;
//function nc_get_att_uint ;     //CHECK!!
//function nc_get_att_ulonglong; //CHECK!!
//function nc_get_att_ushort;    //CHECK!!
//Inq attribute
function nc_inq_att     (ncid : integer; varid : integer; name :  pAnsiChar; var xtypep : nc_type; var lenp : size_t) : integer; cdecl; external netcdf;
function nc_inq_attid   (ncid : integer; varid : integer; name :  pAnsiChar; var idp : integer)             : integer; cdecl; external netcdf;
function nc_inq_attlen  (ncid : integer; varid : integer; name :  pAnsiChar; var lenp : size_t)             : integer; cdecl; external netcdf;
function nc_inq_attname (ncid : integer; varid : integer; attnum : integer; var name : array of pAnsiChar) : integer; cdecl; external netcdf;
function nc_inq_atttype (ncid : integer; varid : integer; name : array of pAnsiChar; var xtypep : nc_type) : integer; cdecl; external netcdf;
function nc_inq_natts   (ncid : integer; var ngattsp : integer)     : integer; cdecl; external netcdf;
//Put attribute
//function nc_put_att;           //CHECK!!
function nc_put_att_double     (ncid : integer; varid : integer; name : pAnsiChar; xtype : nc_type; len : size_t; op : array of double)    : integer; cdecl; external netcdf;
function nc_put_att_float      (ncid : integer; varid : integer; name : pAnsiChar; xtype : nc_type; len : size_t; op : array of single)    : integer; cdecl; external netcdf;
function nc_put_att_int        (ncid : integer; varid : integer; name : pAnsiChar; xtype : nc_type; len : size_t; op : array of integer)   : integer; cdecl; external netcdf;
function nc_put_att_long       (ncid : integer; varid : integer; name : pAnsiChar; xtype : nc_type; len : size_t; op : array of integer)   : integer; cdecl; external netcdf;
//function nc_put_att_longlong;  //CHECK!!
function nc_put_att_schar      (ncid : integer; varid : integer; name : pAnsiChar; xtype : nc_type; len : size_t; op : array of shortint)  : integer; cdecl; external netcdf;
function nc_put_att_short      (ncid : integer; varid : integer; name : pAnsiChar; xtype : nc_type; len : size_t; op : array of smallint)  : integer; cdecl; external netcdf;
//function nc_put_att_string;    //CHECK!!
function nc_put_att_text       (ncid : integer; varid : integer; name : pAnsiChar; len: size_t; op : pAnsiChar)                            : integer; cdecl; external netcdf;
//function nc_put_att_ubyte;     //CHECK!!
function nc_put_att_uchar      (ncid : integer; varid : integer; name : pAnsiChar; xtype : nc_type; len : size_t; op : array of byte)      : integer; cdecl; external netcdf;
//function nc_put_att_uint;      //CHECK!!
//function nc_put_att_ulonglong; //CHECK!!
//function nc_put_att_ushort;    //CHECK!!
//Rename attribute
function nc_rename_att (ncid : integer; varid : integer; name : pAnsiChar; newname : pAnsiChar) : integer; cdecl; external netcdf;



(* ============================ Library Version ============================= *)
function nc_inq_libvers : pAnsiChar; cdecl; external netcdf;



(* ========================= NetCDF Error Handling ========================== *)
function nc_strerror(ncerr : integer) : pAnsiChar; cdecl; external netcdf;


implementation

end.

