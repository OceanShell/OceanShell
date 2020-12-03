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
Tnc_close = function(ncid : integer) : integer; cdecl;
Tnc_create = function(path : pAnsiChar; cmode : integer; var ncidp : integer) :integer; cdecl;
Tnc_enddef = function(ncid : integer) : integer; cdecl;
Tnc_inq = function(ncid : integer; var ndimsp : integer; var nvarsp : integer; var ngattsp : integer; var unlimdimidp : integer) : integer; cdecl;
Tnc_inq_format = function(ncid : integer; var formatp : integer)     : integer; cdecl;
//function nc_inq_format_extended; //CHECK!!
//function nc_inq_path;            //CHECK!!
//function nc_inq_type;            //CHECK!!
Tnc_open = function(path : pAnsiChar; mode  : integer; var ncidp : integer) :integer; cdecl;
//function nc_open_mem;            //CHECK!!
Tnc_redef = function(ncid : integer) : integer; cdecl;
Tnc_set_fill = function(ncid : integer; fillmode : integer; var old_modep :integer) : integer; cdecl;
Tnc_sync = function(ncid : integer) : integer; cdecl;



(* =============================== Dimentions =============================== *)
Tnc_def_dim = function(ncid : integer; name : pAnsiChar; len : size_t; var idp : integer) : integer; cdecl;
Tnc_inq_dim = function(ncid : integer; dimid : integer; var name : array of pAnsiChar; var lenp : size_t) : integer; cdecl;
Tnc_inq_dimid = function(ncid : integer; name : pAnsiChar; var idp : integer)            : integer; cdecl;
Tnc_inq_dimlen = function(ncid : integer; dimid : integer; var lenp : size_t)             : integer; cdecl;
Tnc_inq_dimname = function(ncid : integer; dimid : integer; var name : array of pAnsiChar) : integer; cdecl;
Tnc_inq_ndims = function(ncid : integer; var ndimsp : integer)                           : integer; cdecl;
Tnc_inq_unlimdim = function(ncid : integer; var unlimdimidp : integer)                      : integer; cdecl;
Tnc_rename_dim = function(ncid : integer; dimid : integer; name : pAnsiChar)              : integer; cdecl;



(* =============================== Variables ================================ *)
//function nc_def_var (ncid : integer; name : pAnsiChar; xtype : nc_type; ndims :integer; dimidsp : TArraySize_t; var varidp : integer) : integer; cdecl; external netcdf;
Tnc_def_var = function(ncid : integer; name : pAnsiChar; xtype : nc_type; ndims :integer; dimidsp : array of integer; var varidp : integer) : integer; cdecl;
//function nc_free_string;       //CHECK!!
// nc_get_var - read an entire variable in one call
//function nc_get_var;           //CHECK!!
Tnc_get_var_double = function(ncid : integer; varid : integer; Var ip : array of double)    :integer; cdecl;
Tnc_get_var_float = function(ncid : integer; varid : integer; Var ip : array of single)    :integer; cdecl;
Tnc_get_var_int = function(ncid : integer; varid : integer; Var ip : array of integer)   :integer; cdecl;
Tnc_get_var_long = function(ncid : integer; varid : integer; Var ip : array of int64)     :integer; cdecl;
Tnc_get_var_longlong = function(ncid : integer; varid : integer; Var ip : array of int64)     :integer; cdecl;
Tnc_get_var_schar = function(ncid : integer; varid : integer; Var ip : array of shortint)  :integer; cdecl;
Tnc_get_var_short = function(ncid : integer; varid : integer; Var ip : array of smallint)  :integer; cdecl;
//function nc_get_var_string;    //CHECK
Tnc_get_var_text = function(ncid : integer; varid : integer; Var ip : array of pAnsiChar) :integer; cdecl;
//function nc_get_var_ubyte;     //CHECK
Tnc_get_var_uchar = function(ncid : integer; varid : integer; Var ip : array of pwidechar) :integer; cdecl;
//function nc_get_var_uint;      //CHECK
//function nc_get_var_ulonglong; //CHECK
//function nc_get_var_ushort;    //CHECK
// nc_get_var1 - single value for selected variable
//function nc_get_var1;          //CHECK!!
Tnc_get_var1_double = function(ncid : integer; varid : integer; var indexp :TArraySize_t; Var ip : array of double)    : integer; cdecl;
Tnc_get_var1_float = function(ncid : integer; varid : integer; var indexp :TArraySize_t; Var ip : array of single)    : integer; cdecl;
Tnc_get_var1_int = function(ncid : integer; varid : integer; var indexp :TArraySize_t; Var ip : array of integer)   : integer; cdecl;
Tnc_get_var1_long = function(ncid : integer; varid : integer; var indexp :TArraySize_t; Var ip : array of int64)     : integer; cdecl;
Tnc_get_var1_longlong = function(ncid : integer; varid : integer; var indexp :TArraySize_t; Var ip : array of int64)     : integer; cdecl;
Tnc_get_var1_schar = function(ncid : integer; varid : integer; var indexp :TArraySize_t; Var ip : array of pAnsiChar) : integer; cdecl;
Tnc_get_var1_short = function(ncid : integer; varid : integer; var indexp :TArraySize_t; Var ip : array of smallint)  : integer; cdecl;
//function nc_get_var1_string;    //CHECK
Tnc_get_var1_text = function(ncid : integer; varid : integer; var indexp :TArraySize_t; Var ip : array of pAnsiChar) : integer; cdecl;
//function nc_get_var1_ubyte;     //CHECK
Tnc_get_var1_uchar = function(ncid : integer; varid : integer; var indexp :TArraySize_t; Var ip : array of pwidechar) : integer; cdecl;
//function nc_get_var1_uint;      //CHECK
//function nc_get_var1_ulonglong; //CHECK
//function nc_get_var1_ushort;    //CHECK
// nc_get_vara - read an array of values from a variable
//function nc_get_vara;           //CHECK!!
Tnc_get_vara_double = function(ncid : integer; varid : integer; startp :TArraySize_t; countp : TArraySize_t; Var ip : array of double)    : integer; cdecl;
Tnc_get_vara_float = function(ncid : integer; varid : integer; startp :TArraySize_t; countp : TArraySize_t; Var ip : array of single)    : integer; cdecl;
Tnc_get_vara_int = function(ncid : integer; varid : integer; startp :TArraySize_t; countp : TArraySize_t; Var ip : array of integer)   : integer; cdecl;
Tnc_get_vara_long = function(ncid : integer; varid : integer; startp :TArraySize_t; countp : TArraySize_t; Var ip : array of int64)     : integer; cdecl;
Tnc_get_vara_longlong = function(ncid : integer; varid : integer; startp :TArraySize_t; countp : TArraySize_t; Var ip : array of int64)     : integer; cdecl;
Tnc_get_vara_schar = function(ncid : integer; varid : integer; startp :TArraySize_t; countp : TArraySize_t; Var ip : array of pAnsiChar) : integer; cdecl;
Tnc_get_vara_short = function(ncid : integer; varid : integer; startp :TArraySize_t; countp : TArraySize_t; Var ip : array of smallint)  : integer; cdecl;
//function nc_get_vara_string;    //CHECK
Tnc_get_vara_text = function(ncid : integer; varid : integer; startp :TArraySize_t; countp : TArraySize_t; Var ip : array of pAnsiChar) : integer; cdecl;
//function nc_get_vara_ubyte;     //CHECK
Tnc_get_vara_uchar = function(ncid : integer; varid : integer; startp :TArraySize_t; countp : TArraySize_t; Var ip : array of pwidechar) : integer; cdecl;
//function nc_get_vara_uint;      //CHECK
//function nc_get_vara_ulonglong; //CHECK
//function nc_get_vara_ushort;    //CHECK
// nc_get_vars - read a strided array from a variable
//function nc_get_vars;           //CHECK;
Tnc_get_vars_double = function(ncid : integer; varid : integer; var startp :size_t; var countp : size_t; var stridep : ptrdiff_t; ip : pointer) :integer; cdecl;
Tnc_get_vars_float = function(ncid : integer; varid : integer; var startp :size_t; var countp : size_t; var stridep : ptrdiff_t; ip : pointer) :integer; cdecl;
Tnc_get_vars_int = function(ncid : integer; varid : integer; var startp :size_t; var countp : size_t; var stridep : ptrdiff_t; ip : pointer) :integer; cdecl;
Tnc_get_vars_long = function(ncid : integer; varid : integer; var startp :size_t; var countp : size_t; var stridep : ptrdiff_t; ip : pointer) :integer; cdecl;
Tnc_get_vars_longlong = function(ncid : integer; varid : integer; var startp :size_t; var countp : size_t; var stridep : ptrdiff_t; ip : pointer) :integer; cdecl;
Tnc_get_vars_schar = function(ncid : integer; varid : integer; var startp :size_t; var countp : size_t; var stridep : ptrdiff_t; ip : pointer) :integer; cdecl;
Tnc_get_vars_short = function(ncid : integer; varid : integer; var startp :size_t; var countp : size_t; var stridep : ptrdiff_t; ip : pointer) :integer; cdecl;
//function nc_get_vars_string;    //CHECK
Tnc_get_vars_text = function(ncid : integer; varid : integer; var startp :size_t; var countp : size_t; var stridep : ptrdiff_t; ip : pAnsiChar) : integer;cdecl;
//function nc_get_vars_ubyte;     //CHECK
Tnc_get_vars_uchar = function(ncid : integer; varid : integer; var startp :size_t; var countp : size_t; var stridep : ptrdiff_t; ip : pointer) :integer; cdecl;
//function nc_get_vars_uint;      //CHECK
//function nc_get_vars_ulonglong; //CHECK
//function nc_get_vars_ushort;    //CHECK

// Inq variable
//function nc_inq_unlimdims;      //CHECK
Tnc_inq_var = function(ncid : integer; varid : integer; var name : array of pAnsiChar; var xtypep : nc_type; var ndimsp : integer; var dimidsp : integer; var nattsp :integer) : integer; cdecl;
//function nc_inq_var_chunking;   //CHECK;
Tnc_inq_var_deflate = function(ncid : integer; varid : integer; Var shufflep: integer; Var deflatep : integer; Var deflate_levelp : integer) : integer; cdecl;
//function nc_inq_var_endian;     //CHECK
//function nc_inq_var_fill;       //CHECK
//function nc_inq_var_fletcher32; //CHECK
//function nc_inq_var_szip;       //CHECK
Tnc_inq_vardimid = function(ncid : integer; varid : integer; var dimidsp :array of integer) : integer; cdecl;
Tnc_inq_varid = function(ncid : integer; name : pAnsiChar; var varidp : integer)         : integer; cdecl;
Tnc_inq_varname = function(ncid : integer; varid : integer; var name : array of pAnsiChar) : integer; cdecl;
Tnc_inq_varnatts = function(ncid : integer; varid : integer; var nattsp :integer)           : integer; cdecl;
Tnc_inq_varndims = function(ncid : integer; varid : integer; var ndimsp :integer)           : integer; cdecl;
Tnc_inq_vartype = function(ncid : integer; varid : integer; var xtypep :nc_type)           : integer; cdecl;

// nc_put_var - write an entire variable with one call
//function nc_put_var;          //CHECK
Tnc_put_var_double = function(ncid:integer; varid:integer; op: array of double)    :integer; cdecl;
Tnc_put_var_float = function(ncid:integer; varid:integer; op: array of single)    :integer; cdecl;
Tnc_put_var_int = function(ncid:integer; varid:integer; op: array of integer)   :integer; cdecl;
Tnc_put_var_long = function(ncid:integer; varid:integer; op: array of integer)   :integer; cdecl;
Tnc_put_var_longlong = function(ncid:integer; varid:integer; op: array of integer)   :integer; cdecl;
Tnc_put_var_schar = function(ncid:integer; varid:integer; op: array of shortint)  :integer; cdecl;
Tnc_put_var_short = function(ncid:integer; varid:integer; op: array of smallint)  :integer; cdecl;
//function nc_put_var_string;   //CHECK
Tnc_put_var_text = function(ncid:integer; varid:integer; op: array of pAnsiChar) :integer; cdecl;
//function nc_put_var_ubyte;    //CHECK
Tnc_put_var_uchar = function(ncid:integer; varid:integer; op: array of byte)      :integer; cdecl;
//function nc_put_var_uint;     //CHECK
//function nc_put_var_ulonglong;//CHECK
//function nc_put_var_ushort;   //CHECK
// nc_put_var1 - write one datum
//function nc_put_var1;          //CHECK!!
Tnc_put_var1_double = function(ncid : integer; varid : integer; var indexp :size_t; op : pointer) : integer; cdecl;
Tnc_put_var1_float = function(ncid : integer; varid : integer; var indexp :TArraySize_t; op : array of single) : integer; cdecl;
Tnc_put_var1_int = function(ncid : integer; varid : integer; var indexp :size_t; op : pointer) : integer; cdecl;
Tnc_put_var1_long = function(ncid : integer; varid : integer; var indexp :size_t; op : pointer) : integer; cdecl;
Tnc_put_var1_longlong = function(ncid : integer; varid : integer; var indexp :size_t; op : pointer) : integer; cdecl;
Tnc_put_var1_schar = function(ncid : integer; varid : integer; var indexp :size_t; op : pointer) : integer; cdecl;
Tnc_put_var1_short = function(ncid : integer; varid : integer; var indexp :size_t; op : pointer) : integer; cdecl;
//function nc_put_var1_string;   //CHECK
Tnc_put_var1_text = function(ncid : integer; varid : integer; var indexp :size_t; op : pAnsiChar) : integer; cdecl;
//function nc_put_var1_ubyte;    //CHECK
Tnc_put_var1_uchar = function(ncid : integer; varid : integer; var indexp :size_t; op : pointer) : integer; cdecl;
//function nc_put_var1_uint;     //CHECK
//function nc_put_var1_ulonglong;//CHECK
//function nc_put_var1_ushort;   //CHECK
// nc_put_var_a - write an array of values to a variable
//function nc_put_vara;          //CHECK
Tnc_put_vara_double = function(ncid : integer; varid : integer; var startp :size_t; var countp : size_t; op : pointer) : integer; cdecl;
Tnc_put_vara_float = function(ncid : integer; varid : integer; var startp :size_t; var countp : size_t; op : pointer) : integer; cdecl;
Tnc_put_vara_int = function(ncid : integer; varid : integer; var startp :size_t; var countp : size_t; op : pointer) : integer; cdecl;
Tnc_put_vara_long = function(ncid : integer; varid : integer; var startp :size_t; var countp : size_t; op : pointer) : integer; cdecl;
Tnc_put_vara_longlong = function(ncid : integer; varid : integer; var startp :size_t; var countp : size_t; op : pointer) : integer; cdecl;
Tnc_put_vara_schar = function(ncid : integer; varid : integer; var startp :size_t; var countp : size_t; op : pointer) : integer; cdecl;
Tnc_put_vara_short = function(ncid : integer; varid : integer; var startp :size_t; var countp : size_t; op : pointer) : integer; cdecl;
//function nc_put_vara_string;   //CHECK
Tnc_put_vara_text = function(ncid : integer; varid : integer; var startp :size_t; var countp : size_t; op : pAnsiChar) : integer; cdecl;
//function nc_put_vara_ubyte;    //CHECK
Tnc_put_vara_uchar = function(ncid : integer; varid : integer; var startp :size_t; var countp : size_t; op : pointer) : integer; cdecl;
//function nc_put_vara_uint;     //CHECK
//function nc_put_vara_ulonglong;//CHECK
//function nc_put_vara_ushort;   //CHECK
// nc_put_vars - write a strided array of values to a variable
//function nc_put_vars; //CHECK
Tnc_put_vars_double = function(ncid : integer; varid : integer; var startp :size_t; var countp : size_t; var stridep : ptrdiff_t; op : pointer) :integer; cdecl;
Tnc_put_vars_float = function(ncid : integer; varid : integer; var startp :size_t; var countp : size_t; var stridep : ptrdiff_t; op : pointer) :integer; cdecl;
Tnc_put_vars_int = function(ncid : integer; varid : integer; var startp :size_t; var countp : size_t; var stridep : ptrdiff_t; op : pointer) :integer; cdecl;
Tnc_put_vars_long = function(ncid : integer; varid : integer; var startp :size_t; var countp : size_t; var stridep : ptrdiff_t; op : pointer) :integer; cdecl;
Tnc_put_vars_longlong = function(ncid : integer; varid : integer; var startp :size_t; var countp : size_t; var stridep : ptrdiff_t; op : pointer) :integer; cdecl;
Tnc_put_vars_schar = function(ncid : integer; varid : integer; var startp :size_t; var countp : size_t; var stridep : ptrdiff_t; op : pointer) :integer; cdecl;
Tnc_put_vars_short = function(ncid : integer; varid : integer; var startp :size_t; var countp : size_t; var stridep : ptrdiff_t; op : pointer) :integer; cdecl;
//function nc_put_vars_string;   //CHECK
Tnc_put_vars_text = function(ncid : integer; varid : integer; var startp :size_t; var countp : size_t; var stridep : ptrdiff_t; op : pAnsiChar) : integer;cdecl;
//function nc_put_vars_ubyte;    //CHECK
Tnc_put_vars_uchar = function(ncid : integer; varid : integer; var startp :size_t; var countp : size_t; var stridep : ptrdiff_t; op : pointer) :integer; cdecl;
//function nc_put_vars_uint;     //CHECK
//function nc_put_vars_ulonglong;//CHECK
//function nc_put_vars_ushort;   //CHECK
// Rename variable
Tnc_rename_var = function(ncid : integer; varid : integer; name : pAnsiChar) :integer; cdecl;



(* ============================== Attributes  =============================== *)
// Delete attribute
Tnc_del_att = function(ncid : integer; varid : integer; name : pAnsiChar) :integer; cdecl;
// Get attribute
//function nc_get_att;           //CHECK!!
Tnc_get_att_double = function(ncid : integer; varid : integer; name : pAnsiChar;var ip : array of double)    : integer; cdecl;
Tnc_get_att_float = function(ncid : integer; varid : integer; name : pAnsiChar;var ip : array of single)    : integer; cdecl;
Tnc_get_att_int = function(ncid : integer; varid : integer; name : pAnsiChar;var ip : array of integer)   : integer; cdecl;
Tnc_get_att_long = function(ncid : integer; varid : integer; name : pAnsiChar;var ip : array of integer)   : integer; cdecl;
//function nc_get_att_longlong;  //CHECK!!
Tnc_get_att_schar = function(ncid : integer; varid : integer; name : pAnsiChar;var ip : array of shortint)  : integer; cdecl;
Tnc_get_att_short = function(ncid : integer; varid : integer; name : pAnsiChar;var ip : array of smallint)  : integer; cdecl;
//function nc_get_att_string;    //CHECK!!
Tnc_get_att_text = function(ncid : integer; varid : integer; name : pAnsiChar;var ip : array of pAnsiChar) : integer; cdecl;
//function nc_get_att_ubyte;     //CHECK!!
Tnc_get_att_uchar = function(ncid : integer; varid : integer; name : pAnsiChar;var ip : array of byte)      : integer; cdecl;
//function nc_get_att_uint ;     //CHECK!!
//function nc_get_att_ulonglong; //CHECK!!
//function nc_get_att_ushort;    //CHECK!!
//Inq attribute
Tnc_inq_att = function(ncid : integer; varid : integer; name :  pAnsiChar; var xtypep : nc_type; var lenp : size_t) : integer; cdecl;
Tnc_inq_attid = function(ncid : integer; varid : integer; name :  pAnsiChar; var idp : integer)             : integer; cdecl;
Tnc_inq_attlen = function(ncid : integer; varid : integer; name :  pAnsiChar; var lenp : size_t)             : integer; cdecl;
Tnc_inq_attname = function(ncid : integer; varid : integer; attnum : integer; var name : array of pAnsiChar) : integer; cdecl;
Tnc_inq_atttype = function(ncid : integer; varid : integer; name : array of pAnsiChar; var xtypep : nc_type) : integer; cdecl;
Tnc_inq_natts = function(ncid : integer; var ngattsp : integer)     : integer; cdecl;
//Put attribute
//function nc_put_att;           //CHECK!!
Tnc_put_att_double = function(ncid : integer; varid : integer; name : pAnsiChar; xtype : nc_type; len : size_t; op : array of double)    : integer; cdecl;
Tnc_put_att_float = function(ncid : integer; varid : integer; name : pAnsiChar; xtype : nc_type; len : size_t; op : array of single)    : integer; cdecl;
Tnc_put_att_int = function(ncid : integer; varid : integer; name : pAnsiChar; xtype : nc_type; len : size_t; op : array of integer)   : integer; cdecl;
Tnc_put_att_long = function(ncid : integer; varid : integer; name : pAnsiChar; xtype : nc_type; len : size_t; op : array of integer)   : integer; cdecl;
//function nc_put_att_longlong;  //CHECK!!
Tnc_put_att_schar = function(ncid : integer; varid : integer; name : pAnsiChar; xtype : nc_type; len : size_t; op : array of shortint)  : integer; cdecl;
Tnc_put_att_short = function(ncid : integer; varid : integer; name : pAnsiChar; xtype : nc_type; len : size_t; op : array of smallint)  : integer; cdecl;
//function nc_put_att_string;    //CHECK!!
Tnc_put_att_text = function(ncid : integer; varid : integer; name : pAnsiChar; len: size_t; op : pAnsiChar)                            : integer; cdecl;
//function nc_put_att_ubyte;     //CHECK!!
Tnc_put_att_uchar = function(ncid : integer; varid : integer; name : pAnsiChar; xtype : nc_type; len : size_t; op : array of byte)      : integer; cdecl;
//function nc_put_att_uint;      //CHECK!!
//function nc_put_att_ulonglong; //CHECK!!
//function nc_put_att_ushort;    //CHECK!!
//Rename attribute
Tnc_rename_att = function(ncid : integer; varid : integer; name : pAnsiChar; newname : pAnsiChar) : integer; cdecl;



(* ============================ Library Version ============================= *)
Tnc_inq_libvers = function() : pAnsiChar; cdecl;

(* ========================= NetCDF Error Handling ========================== *)
Tnc_strerror = function(ncerr : integer) : pAnsiChar; cdecl;


implementation

end.

