SET DEFINE OFF;
CREATE OR REPLACE function md5raw (text in varchar2)
return varchar2 is
hash_value varchar2(20);
begin
   hash_value := dbms_obfuscation_toolkit.md5 (input_string => text);
   return hash_value;
end;
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
/
