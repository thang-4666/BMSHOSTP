SET DEFINE OFF;
CREATE OR REPLACE FUNCTION fn_checkpass(p_email VARCHAR2) return number as
  numberPattern    varchar2(1000) := '^.*[0-9]';
  lowerCasePattern varchar2(1000) := '^.*[a-z]';
  upperCasePattern varchar2(1000) := '^.*[A-Z]';
  lengthParttern varchar2(1000) := '^[a-zA-Z0-9!@#$%^&*()]{4,}$';
  specialPartern varchar2(1000) := '[!@#$%^&*()]';
begin

  if not REGEXP_LIKE(p_email, numberPattern) then
    dbms_output.put_line('must has number');
    return - 1;

  elsif not REGEXP_LIKE(p_email, lowerCasePattern) then
    dbms_output.put_line('must has lower char');
    return - 2;
  elsif not REGEXP_LIKE(p_email, upperCasePattern) then
    dbms_output.put_line('must has upper char');
    return - 3;
  elsif not REGEXP_LIKE(p_email, specialPartern) then
    dbms_output.put_line('must has special char');
    return - 4;
  elsif not REGEXP_LIKE(p_email, lengthParttern) then
    dbms_output.put_line('must has min 4 char');
    return - 5;
  end if;

  return 0;

exception
  when others then
    dbms_output.put(sqlerrm);
end fn_checkPass;
 
/
