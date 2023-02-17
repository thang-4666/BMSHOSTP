SET DEFINE OFF;
CREATE OR REPLACE FUNCTION SP_FORMAT_COMMON10CHARACTERS (pv_data in VARCHAR) RETURN VARCHAR IS
  v_return varchar2(50);
  v_format varchar2(50);
  v_length int;
BEGIN
  v_format := '0000.000.000';
  v_format := replace(v_format,'.','');
  v_length := length(v_format);
  v_format := v_format || pv_data;
  v_format := SUBSTR(v_format, length(v_format)-v_length+1,v_length);
  v_return := v_return || SUBSTR(v_format, 1,4) || '.';
  v_return := v_return || SUBSTR(v_format, 5,3) || '.';
  v_return := v_return || SUBSTR(v_format, 8,3);
  RETURN v_return;
END;
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
/
