unit declarations_netcdf;

{$mode objfpc}{$H+}

(*
These declarations facilitate the use of netcdf with Lazarus.

Alexander Smirnov
Arctic and Antarctic Research Institute
St. Petersburg, Russia
2011-2026

This program is free software; you can redistribute it and/or modify it under
the terms of the GNU General Public License 3 as published by the Free Software
Foundation. See the GNU General Public License for more details
(http://www.gnu.org/licenses/).

This program is distributed in the hope that it will be useful, but WITHOUT
ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
FITNESS FOR A PARTICULAR PURPOSE.


!!! Set correct path to netcdf for your OS at the Begin section !!!

*)

interface

uses
  Forms, dynlibs;  //Forms is only needed if the application path is used


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
Tnc_def_var = function(ncid : integer; name : pAnsiChar; xtype : nc_type; ndims :integer; dimidsp : array of integer; var varidp : integer) : integer; cdecl;
Tnc_free_string = function(lenp : size_t; ip : array of ppAnsiChar ) : integer; cdecl;
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
Tnc_inq_varid    = function(ncid : integer; name : pAnsiChar; var varidp : integer)         : integer; cdecl;
Tnc_inq_varname  = function(ncid : integer; varid : integer; var name : array of pAnsiChar) : integer; cdecl;
Tnc_inq_varnatts = function(ncid : integer; varid : integer; var nattsp :integer)           : integer; cdecl;
Tnc_inq_varndims = function(ncid : integer; varid : integer; var ndimsp :integer)           : integer; cdecl;
Tnc_inq_vartype  = function(ncid : integer; varid : integer; var xtypep :nc_type)           : integer; cdecl;

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
Tnc_get_att_long = function(ncid : integer; varid : integer; name : pAnsiChar;var ip : array of int64)   : integer; cdecl;
//function nc_get_att_longlong;  //CHECK!!
Tnc_get_att_schar = function(ncid : integer; varid : integer; name : pAnsiChar;var ip : array of shortint)  : integer; cdecl;
Tnc_get_att_short = function(ncid : integer; varid : integer; name : pAnsiChar;var ip : array of smallint)  : integer; cdecl;
Tnc_get_att_string = function(ncid : integer; varid : integer; name : pAnsiChar;var ip : array of ppAnsiChar): integer; cdecl;
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
Tnc_inq_libvers = function : pAnsiChar; cdecl;

(* ========================= NetCDF Error Handling ========================== *)
Tnc_strerror = function(ncerr : integer) : pAnsiChar; cdecl;


Var
  netcdf:TLibHandle;

  nc_close:Tnc_close;
  nc_create:Tnc_create;
  nc_enddef:Tnc_enddef;
  nc_inq:Tnc_inq;
  nc_inq_format:Tnc_inq_format;
  nc_open:Tnc_open;
  nc_redef:Tnc_redef;
  nc_set_fill:Tnc_set_fill;
  nc_sync:Tnc_sync;
  nc_def_dim:Tnc_def_dim;
  nc_inq_dim:Tnc_inq_dim;
  nc_inq_dimid:Tnc_inq_dimid;
  nc_inq_dimlen:Tnc_inq_dimlen;
  nc_inq_dimname:Tnc_inq_dimname;
  nc_inq_ndims:Tnc_inq_ndims;
  nc_inq_unlimdim:Tnc_inq_unlimdim;
  nc_rename_dim:Tnc_rename_dim;
  nc_def_var:Tnc_def_var;
  nc_free_string:Tnc_free_string;
  nc_get_var_double:Tnc_get_var_double;
  nc_get_var_float:Tnc_get_var_float;
  nc_get_var_int:Tnc_get_var_int;
  nc_get_var_long:Tnc_get_var_long;
  nc_get_var_longlong:Tnc_get_var_longlong;
  nc_get_var_schar:Tnc_get_var_schar;
  nc_get_var_short:Tnc_get_var_short;
  nc_get_var_text:Tnc_get_var_text;
  nc_get_var_uchar:Tnc_get_var_uchar;
  nc_get_var1_double:Tnc_get_var1_double;
  nc_get_var1_float:Tnc_get_var1_float;
  nc_get_var1_int:Tnc_get_var1_int;
  nc_get_var1_long:Tnc_get_var1_long;
  nc_get_var1_longlong:Tnc_get_var1_longlong;
  nc_get_var1_schar:Tnc_get_var1_schar;
  nc_get_var1_short:Tnc_get_var1_short;
  nc_get_var1_text:Tnc_get_var1_text;
  nc_get_var1_uchar:Tnc_get_var1_uchar;
  nc_get_vara_double:Tnc_get_vara_double;
  nc_get_vara_float:Tnc_get_vara_float;
  nc_get_vara_int:Tnc_get_vara_int;
  nc_get_vara_long:Tnc_get_vara_long;
  nc_get_vara_longlong:Tnc_get_vara_longlong;
  nc_get_vara_schar:Tnc_get_vara_schar;
  nc_get_vara_short:Tnc_get_vara_short;
  nc_get_vara_text:Tnc_get_vara_text;
  nc_get_vara_uchar:Tnc_get_vara_uchar;
  nc_get_vars_double:Tnc_get_vars_double;
  nc_get_vars_float:Tnc_get_vars_float;
  nc_get_vars_int:Tnc_get_vars_int;
  nc_get_vars_long:Tnc_get_vars_long;
  nc_get_vars_longlong:Tnc_get_vars_longlong;
  nc_get_vars_schar:Tnc_get_vars_schar;
  nc_get_vars_short:Tnc_get_vars_short;
  nc_get_vars_text:Tnc_get_vars_text;
  nc_get_vars_uchar:Tnc_get_vars_uchar;
  nc_inq_var:Tnc_inq_var;
  nc_inq_var_deflate:Tnc_inq_var_deflate;
  nc_inq_vardimid:Tnc_inq_vardimid;
  nc_inq_varid:Tnc_inq_varid;
  nc_inq_varname:Tnc_inq_varname;
  nc_inq_varnatts:Tnc_inq_varnatts;
  nc_inq_varndims:Tnc_inq_varndims;
  nc_inq_vartype:Tnc_inq_vartype;
  nc_put_var_double:Tnc_put_var_double;
  nc_put_var_float:Tnc_put_var_float;
  nc_put_var_int:Tnc_put_var_int;
  nc_put_var_long:Tnc_put_var_long;
  nc_put_var_longlong:Tnc_put_var_longlong;
  nc_put_var_schar:Tnc_put_var_schar;
  nc_put_var_short:Tnc_put_var_short;
  nc_put_var_text:Tnc_put_var_text;
  nc_put_var_uchar:Tnc_put_var_uchar;
  nc_put_var1_double:Tnc_put_var1_double;
  nc_put_var1_float:Tnc_put_var1_float;
  nc_put_var1_int:Tnc_put_var1_int;
  nc_put_var1_long:Tnc_put_var1_long;
  nc_put_var1_longlong:Tnc_put_var1_longlong;
  nc_put_var1_schar:Tnc_put_var1_schar;
  nc_put_var1_short:Tnc_put_var1_short;
  nc_put_var1_text:Tnc_put_var1_text;
  nc_put_var1_uchar:Tnc_put_var1_uchar;
  nc_put_vara_double:Tnc_put_vara_double;
  nc_put_vara_float:Tnc_put_vara_float;
  nc_put_vara_int:Tnc_put_vara_int;
  nc_put_vara_long:Tnc_put_vara_long;
  nc_put_vara_longlong:Tnc_put_vara_longlong;
  nc_put_vara_schar:Tnc_put_vara_schar;
  nc_put_vara_short:Tnc_put_vara_short;
  nc_put_vara_text:Tnc_put_vara_text;
  nc_put_vara_uchar:Tnc_put_vara_uchar;
  nc_put_vars_double:Tnc_put_vars_double;
  nc_put_vars_float:Tnc_put_vars_float;
  nc_put_vars_int:Tnc_put_vars_int;
  nc_put_vars_long:Tnc_put_vars_long;
  nc_put_vars_longlong:Tnc_put_vars_longlong;
  nc_put_vars_schar:Tnc_put_vars_schar;
  nc_put_vars_short:Tnc_put_vars_short;
  nc_put_vars_text:Tnc_put_vars_text;
  nc_put_vars_uchar:Tnc_put_vars_uchar;
  nc_rename_var:Tnc_rename_var;
  nc_del_att:Tnc_del_att;
  nc_get_att_double:Tnc_get_att_double;
  nc_get_att_float:Tnc_get_att_float;
  nc_get_att_int:Tnc_get_att_int;
  nc_get_att_long:Tnc_get_att_long;
  nc_get_att_schar:Tnc_get_att_schar;
  nc_get_att_short:Tnc_get_att_short;
  nc_get_att_string:Tnc_get_att_string; 
  nc_get_att_text:Tnc_get_att_text;
  nc_get_att_uchar:Tnc_get_att_uchar;
  nc_inq_att:Tnc_inq_att;
  nc_inq_attid:Tnc_inq_attid;
  nc_inq_attlen:Tnc_inq_attlen;
  nc_inq_attname:Tnc_inq_attname;
  nc_inq_atttype:Tnc_inq_atttype;
  nc_inq_natts:Tnc_inq_natts;
  nc_put_att_double:Tnc_put_att_double;
  nc_put_att_float:Tnc_put_att_float;
  nc_put_att_int:Tnc_put_att_int;
  nc_put_att_long:Tnc_put_att_long;
  nc_put_att_schar:Tnc_put_att_schar;
  nc_put_att_short:Tnc_put_att_short;
  nc_put_att_text:Tnc_put_att_text;
  nc_put_att_uchar:Tnc_put_att_uchar;
  nc_rename_att:Tnc_rename_att;
  nc_inq_libvers:Tnc_inq_libvers;
  nc_strerror:Tnc_strerror;

implementation

Begin

  (* Loading NetCDF *)
  {$IFDEF WINDOWS}
    netcdf := SafeLoadLibrary(PChar('netcdf.dll'));
  {$ENDIF}
  {$IFDEF LINUX}
    netcdf := SafeLoadLibrary(PChar('libnetcdf.so'));
  {$ENDIF}
  {$IFDEF DARWIN}
    netcdf := SafeLoadLibrary(PChar(GlobalPath+'libnetcdf.dylib'));
  {$ENDIF}

  if netcdf=NilHandle then exit;

  nc_close:=Tnc_close(GetProcedureAddress(netcdf, 'nc_close'));
  nc_create:=Tnc_create(GetProcedureAddress(netcdf, 'nc_create'));
  nc_enddef:=Tnc_enddef(GetProcedureAddress(netcdf, 'nc_enddef'));
  nc_inq:=Tnc_inq(GetProcedureAddress(netcdf, 'nc_inq'));
  nc_inq_format:=Tnc_inq_format(GetProcedureAddress(netcdf, 'nc_inq_format'));
  nc_open:=Tnc_open(GetProcedureAddress(netcdf, 'nc_open'));
  nc_redef:=Tnc_redef(GetProcedureAddress(netcdf, 'nc_redef'));
  nc_set_fill:=Tnc_set_fill(GetProcedureAddress(netcdf, 'nc_set_fill'));
  nc_sync:=Tnc_sync(GetProcedureAddress(netcdf, 'nc_sync'));
  nc_def_dim:=Tnc_def_dim(GetProcedureAddress(netcdf, 'nc_def_dim'));
  nc_inq_dim:=Tnc_inq_dim(GetProcedureAddress(netcdf, 'nc_inq_dim'));
  nc_inq_dimid:=Tnc_inq_dimid(GetProcedureAddress(netcdf, 'nc_inq_dimid'));
  nc_inq_dimlen:=Tnc_inq_dimlen(GetProcedureAddress(netcdf, 'nc_inq_dimlen'));
  nc_inq_dimname:=Tnc_inq_dimname(GetProcedureAddress(netcdf, 'nc_inq_dimname'));
  nc_inq_ndims:=Tnc_inq_ndims(GetProcedureAddress(netcdf, 'nc_inq_ndims'));
  nc_inq_unlimdim:=Tnc_inq_unlimdim(GetProcedureAddress(netcdf, 'nc_inq_unlimdim'));
  nc_rename_dim:=Tnc_rename_dim(GetProcedureAddress(netcdf, 'nc_rename_dim'));
  nc_free_string:=Tnc_free_string(GetProcedureAddress(netcdf, 'nc_free_string'));
  nc_def_var:=Tnc_def_var(GetProcedureAddress(netcdf, 'nc_def_var'));
  nc_get_var_double:=Tnc_get_var_double(GetProcedureAddress(netcdf, 'nc_get_var_double'));
  nc_get_var_float:=Tnc_get_var_float(GetProcedureAddress(netcdf, 'nc_get_var_float'));
  nc_get_var_int:=Tnc_get_var_int(GetProcedureAddress(netcdf, 'nc_get_var_int'));
  nc_get_var_long:=Tnc_get_var_long(GetProcedureAddress(netcdf, 'nc_get_var_long'));
  nc_get_var_longlong:=Tnc_get_var_longlong(GetProcedureAddress(netcdf, 'nc_get_var_longlong'));
  nc_get_var_schar:=Tnc_get_var_schar(GetProcedureAddress(netcdf, 'nc_get_var_schar'));
  nc_get_var_short:=Tnc_get_var_short(GetProcedureAddress(netcdf, 'nc_get_var_short'));
  nc_get_var_text:=Tnc_get_var_text(GetProcedureAddress(netcdf, 'nc_get_var_text'));
  nc_get_var_uchar:=Tnc_get_var_uchar(GetProcedureAddress(netcdf, 'nc_get_var_uchar'));
  nc_get_var1_double:=Tnc_get_var1_double(GetProcedureAddress(netcdf, 'nc_get_var1_double'));
  nc_get_var1_float:=Tnc_get_var1_float(GetProcedureAddress(netcdf, 'nc_get_var1_float'));
  nc_get_var1_int:=Tnc_get_var1_int(GetProcedureAddress(netcdf, 'nc_get_var1_int'));
  nc_get_var1_long:=Tnc_get_var1_long(GetProcedureAddress(netcdf, 'nc_get_var1_long'));
  nc_get_var1_longlong:=Tnc_get_var1_longlong(GetProcedureAddress(netcdf, 'nc_get_var1_longlong'));
  nc_get_var1_schar:=Tnc_get_var1_schar(GetProcedureAddress(netcdf, 'nc_get_var1_schar'));
  nc_get_var1_short:=Tnc_get_var1_short(GetProcedureAddress(netcdf, 'nc_get_var1_short'));
  nc_get_var1_text:=Tnc_get_var1_text(GetProcedureAddress(netcdf, 'nc_get_var1_text'));
  nc_get_var1_uchar:=Tnc_get_var1_uchar(GetProcedureAddress(netcdf, 'nc_get_var1_uchar'));
  nc_get_vara_double:=Tnc_get_vara_double(GetProcedureAddress(netcdf, 'nc_get_vara_double'));
  nc_get_vara_float:=Tnc_get_vara_float(GetProcedureAddress(netcdf, 'nc_get_vara_float'));
  nc_get_vara_int:=Tnc_get_vara_int(GetProcedureAddress(netcdf, 'nc_get_vara_int'));
  nc_get_vara_long:=Tnc_get_vara_long(GetProcedureAddress(netcdf, 'nc_get_vara_long'));
  nc_get_vara_longlong:=Tnc_get_vara_longlong(GetProcedureAddress(netcdf, 'nc_get_vara_longlong'));
  nc_get_vara_schar:=Tnc_get_vara_schar(GetProcedureAddress(netcdf, 'nc_get_vara_schar'));
  nc_get_vara_short:=Tnc_get_vara_short(GetProcedureAddress(netcdf, 'nc_get_vara_short'));
  nc_get_vara_text:=Tnc_get_vara_text(GetProcedureAddress(netcdf, 'nc_get_vara_text'));
  nc_get_vara_uchar:=Tnc_get_vara_uchar(GetProcedureAddress(netcdf, 'nc_get_vara_uchar'));
  nc_get_vars_double:=Tnc_get_vars_double(GetProcedureAddress(netcdf, 'nc_get_vars_double'));
  nc_get_vars_float:=Tnc_get_vars_float(GetProcedureAddress(netcdf, 'nc_get_vars_float'));
  nc_get_vars_int:=Tnc_get_vars_int(GetProcedureAddress(netcdf, 'nc_get_vars_int'));
  nc_get_vars_long:=Tnc_get_vars_long(GetProcedureAddress(netcdf, 'nc_get_vars_long'));
  nc_get_vars_longlong:=Tnc_get_vars_longlong(GetProcedureAddress(netcdf, 'nc_get_vars_longlong'));
  nc_get_vars_schar:=Tnc_get_vars_schar(GetProcedureAddress(netcdf, 'nc_get_vars_schar'));
  nc_get_vars_short:=Tnc_get_vars_short(GetProcedureAddress(netcdf, 'nc_get_vars_short'));
  nc_get_vars_text:=Tnc_get_vars_text(GetProcedureAddress(netcdf, 'nc_get_vars_text'));
  nc_get_vars_uchar:=Tnc_get_vars_uchar(GetProcedureAddress(netcdf, 'nc_get_vars_uchar'));
  nc_inq_var:=Tnc_inq_var(GetProcedureAddress(netcdf, 'nc_inq_var'));
  nc_inq_var_deflate:=Tnc_inq_var_deflate(GetProcedureAddress(netcdf, 'nc_inq_var_deflate'));
  nc_inq_vardimid:=Tnc_inq_vardimid(GetProcedureAddress(netcdf, 'nc_inq_vardimid'));
  nc_inq_varid:=Tnc_inq_varid(GetProcedureAddress(netcdf, 'nc_inq_varid'));
  nc_inq_varname:=Tnc_inq_varname(GetProcedureAddress(netcdf, 'nc_inq_varname'));
  nc_inq_varnatts:=Tnc_inq_varnatts(GetProcedureAddress(netcdf, 'nc_inq_varnatts'));
  nc_inq_varndims:=Tnc_inq_varndims(GetProcedureAddress(netcdf, 'nc_inq_varndims'));
  nc_inq_vartype:=Tnc_inq_vartype(GetProcedureAddress(netcdf, 'nc_inq_vartype'));
  nc_put_var_double:=Tnc_put_var_double(GetProcedureAddress(netcdf, 'nc_put_var_double'));
  nc_put_var_float:=Tnc_put_var_float(GetProcedureAddress(netcdf, 'nc_put_var_float'));
  nc_put_var_int:=Tnc_put_var_int(GetProcedureAddress(netcdf, 'nc_put_var_int'));
  nc_put_var_long:=Tnc_put_var_long(GetProcedureAddress(netcdf, 'nc_put_var_long'));
  nc_put_var_longlong:=Tnc_put_var_longlong(GetProcedureAddress(netcdf, 'nc_put_var_longlong'));
  nc_put_var_schar:=Tnc_put_var_schar(GetProcedureAddress(netcdf, 'nc_put_var_schar'));
  nc_put_var_short:=Tnc_put_var_short(GetProcedureAddress(netcdf, 'nc_put_var_short'));
  nc_put_var_text:=Tnc_put_var_text(GetProcedureAddress(netcdf, 'nc_put_var_text'));
  nc_put_var_uchar:=Tnc_put_var_uchar(GetProcedureAddress(netcdf, 'nc_put_var_uchar'));
  nc_put_var1_double:=Tnc_put_var1_double(GetProcedureAddress(netcdf, 'nc_put_var1_double'));
  nc_put_var1_float:=Tnc_put_var1_float(GetProcedureAddress(netcdf, 'nc_put_var1_float'));
  nc_put_var1_int:=Tnc_put_var1_int(GetProcedureAddress(netcdf, 'nc_put_var1_int'));
  nc_put_var1_long:=Tnc_put_var1_long(GetProcedureAddress(netcdf, 'nc_put_var1_long'));
  nc_put_var1_longlong:=Tnc_put_var1_longlong(GetProcedureAddress(netcdf, 'nc_put_var1_longlong'));
  nc_put_var1_schar:=Tnc_put_var1_schar(GetProcedureAddress(netcdf, 'nc_put_var1_schar'));
  nc_put_var1_short:=Tnc_put_var1_short(GetProcedureAddress(netcdf, 'nc_put_var1_short'));
  nc_put_var1_text:=Tnc_put_var1_text(GetProcedureAddress(netcdf, 'nc_put_var1_text'));
  nc_put_var1_uchar:=Tnc_put_var1_uchar(GetProcedureAddress(netcdf, 'nc_put_var1_uchar'));
  nc_put_vara_double:=Tnc_put_vara_double(GetProcedureAddress(netcdf, 'nc_put_vara_double'));
  nc_put_vara_float:=Tnc_put_vara_float(GetProcedureAddress(netcdf, 'nc_put_vara_float'));
  nc_put_vara_int:=Tnc_put_vara_int(GetProcedureAddress(netcdf, 'nc_put_vara_int'));
  nc_put_vara_long:=Tnc_put_vara_long(GetProcedureAddress(netcdf, 'nc_put_vara_long'));
  nc_put_vara_longlong:=Tnc_put_vara_longlong(GetProcedureAddress(netcdf, 'nc_put_vara_longlong'));
  nc_put_vara_schar:=Tnc_put_vara_schar(GetProcedureAddress(netcdf, 'nc_put_vara_schar'));
  nc_put_vara_short:=Tnc_put_vara_short(GetProcedureAddress(netcdf, 'nc_put_vara_short'));
  nc_put_vara_text:=Tnc_put_vara_text(GetProcedureAddress(netcdf, 'nc_put_vara_text'));
  nc_put_vara_uchar:=Tnc_put_vara_uchar(GetProcedureAddress(netcdf, 'nc_put_vara_uchar'));
  nc_put_vars_double:=Tnc_put_vars_double(GetProcedureAddress(netcdf, 'nc_put_vars_double'));
  nc_put_vars_float:=Tnc_put_vars_float(GetProcedureAddress(netcdf, 'nc_put_vars_float'));
  nc_put_vars_int:=Tnc_put_vars_int(GetProcedureAddress(netcdf, 'nc_put_vars_int'));
  nc_put_vars_long:=Tnc_put_vars_long(GetProcedureAddress(netcdf, 'nc_put_vars_long'));
  nc_put_vars_longlong:=Tnc_put_vars_longlong(GetProcedureAddress(netcdf, 'nc_put_vars_longlong'));
  nc_put_vars_schar:=Tnc_put_vars_schar(GetProcedureAddress(netcdf, 'nc_put_vars_schar'));
  nc_put_vars_short:=Tnc_put_vars_short(GetProcedureAddress(netcdf, 'nc_put_vars_short'));
  nc_put_vars_text:=Tnc_put_vars_text(GetProcedureAddress(netcdf, 'nc_put_vars_text'));
  nc_put_vars_uchar:=Tnc_put_vars_uchar(GetProcedureAddress(netcdf, 'nc_put_vars_uchar'));
  nc_rename_var:=Tnc_rename_var(GetProcedureAddress(netcdf, 'nc_rename_var'));
  nc_del_att:=Tnc_del_att(GetProcedureAddress(netcdf, 'nc_del_att'));
  nc_get_att_double:=Tnc_get_att_double(GetProcedureAddress(netcdf, 'nc_get_att_double'));
  nc_get_att_float:=Tnc_get_att_float(GetProcedureAddress(netcdf, 'nc_get_att_float'));
  nc_get_att_int:=Tnc_get_att_int(GetProcedureAddress(netcdf, 'nc_get_att_int'));
  nc_get_att_long:=Tnc_get_att_long(GetProcedureAddress(netcdf, 'nc_get_att_long'));
  nc_get_att_schar:=Tnc_get_att_schar(GetProcedureAddress(netcdf, 'nc_get_att_schar'));
  nc_get_att_short:=Tnc_get_att_short(GetProcedureAddress(netcdf, 'nc_get_att_short'));
  nc_get_att_string:=Tnc_get_att_string(GetProcedureAddress(netcdf, 'nc_get_att_string'));
  nc_get_att_text:=Tnc_get_att_text(GetProcedureAddress(netcdf, 'nc_get_att_text'));
  nc_get_att_uchar:=Tnc_get_att_uchar(GetProcedureAddress(netcdf, 'nc_get_att_uchar'));
  nc_inq_att:=Tnc_inq_att(GetProcedureAddress(netcdf, 'nc_inq_att'));
  nc_inq_attid:=Tnc_inq_attid(GetProcedureAddress(netcdf, 'nc_inq_attid'));
  nc_inq_attlen:=Tnc_inq_attlen(GetProcedureAddress(netcdf, 'nc_inq_attlen'));
  nc_inq_attname:=Tnc_inq_attname(GetProcedureAddress(netcdf, 'nc_inq_attname'));
  nc_inq_atttype:=Tnc_inq_atttype(GetProcedureAddress(netcdf, 'nc_inq_atttype'));
  nc_inq_natts:=Tnc_inq_natts(GetProcedureAddress(netcdf, 'nc_inq_natts'));
  nc_put_att_double:=Tnc_put_att_double(GetProcedureAddress(netcdf, 'nc_put_att_double'));
  nc_put_att_float:=Tnc_put_att_float(GetProcedureAddress(netcdf, 'nc_put_att_float'));
  nc_put_att_int:=Tnc_put_att_int(GetProcedureAddress(netcdf, 'nc_put_att_int'));
  nc_put_att_long:=Tnc_put_att_long(GetProcedureAddress(netcdf, 'nc_put_att_long'));
  nc_put_att_schar:=Tnc_put_att_schar(GetProcedureAddress(netcdf, 'nc_put_att_schar'));
  nc_put_att_short:=Tnc_put_att_short(GetProcedureAddress(netcdf, 'nc_put_att_short'));
  nc_put_att_text:=Tnc_put_att_text(GetProcedureAddress(netcdf, 'nc_put_att_text'));
  nc_put_att_uchar:=Tnc_put_att_uchar(GetProcedureAddress(netcdf, 'nc_put_att_uchar'));
  nc_rename_att:=Tnc_rename_att(GetProcedureAddress(netcdf, 'nc_rename_att'));
  nc_inq_libvers:=Tnc_inq_libvers(GetProcedureAddress(netcdf, 'nc_inq_libvers'));
  nc_strerror:=Tnc_strerror(GetProcedureAddress(netcdf, 'nc_strerror'));

end.

