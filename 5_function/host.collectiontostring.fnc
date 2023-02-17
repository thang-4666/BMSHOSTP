SET DEFINE OFF;
CREATE OR REPLACE function CollectionToString(nt_in        in collection,
                                              delimiter_in in varchar2 default ',')
  return varchar2 is

  v_idx pls_integer;
  v_str varchar2(32767);
  v_dlm varchar2(10);

begin

  v_idx := nt_in.FIRST;
  while v_idx is not null
  loop
    v_str := v_str || v_dlm || nt_in(v_idx);
    v_dlm := delimiter_in;
    v_idx := nt_in.NEXT(v_idx);
  end loop;

  return v_str;

end CollectionToString;
 
 
 
 
 
 
 
 
 
 
 
/
