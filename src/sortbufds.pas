unit sortbufds;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, sqldb, typinfo, DB;

function SortBufDataSet(DataSet: TSQLQuery; const FieldName: String): Boolean;

implementation


function SortBufDataSet(DataSet: TSQLQuery{TBufDataSet};const FieldName: String): Boolean;
var
  i: Integer;
  IndexDefs: TIndexDefs;
  IndexName: String;
  IndexOptions: TIndexOptions;
  Field: TField;
begin
  Result := False;
  Field := DataSet.Fields.FindField(FieldName);
  //If invalid field name, exit.
  if Field = nil then Exit;
  //if invalid field type, exit.
  if {(Field is TObjectField) or} (Field is TBlobField) or
    {(Field is TAggregateField) or} (Field is TVariantField)
     or (Field is TBinaryField) then Exit;
  //Get IndexDefs and IndexName using RTTI
  if IsPublishedProp(DataSet, 'IndexDefs') then
    IndexDefs := GetObjectProp(DataSet, 'IndexDefs') as TIndexDefs
  else
    Exit;
  if IsPublishedProp(DataSet, 'IndexName') then
    IndexName := GetStrProp(DataSet, 'IndexName')
  else
    Exit;
  //Ensure IndexDefs is up-to-date
  IndexDefs.Updated:=false; {<<<<---This line is critical as IndexDefs.Update will do nothing on the next sort if it's already true}
  IndexDefs.Update;
  //If an ascending index is already in use,
  //switch to a descending index
  if IndexName = FieldName + '__IdxA'
  then
    begin
      IndexName := FieldName + '__IdxD';
      IndexOptions := [ixDescending];
    end
  else
    begin
      IndexName := FieldName + '__IdxA';
      IndexOptions := [];
    end;
  //Look for existing index
  for i := 0 to Pred(IndexDefs.Count) do
  begin
    if IndexDefs[i].Name = IndexName then
      begin
        Result := True;
        Break
      end;  //if
  end; // for
  //If existing index not found, create one
  if not Result then
      begin
        if IndexName=FieldName + '__IdxD' then
          DataSet.AddIndex(IndexName, FieldName, IndexOptions, FieldName)
        else
          DataSet.AddIndex(IndexName, FieldName, IndexOptions);
        Result := True;
      end; // if not
  //Set the index
  SetStrProp(DataSet, 'IndexName', IndexName);
end;

end.

