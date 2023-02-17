SET DEFINE OFF;
CREATE OR REPLACE FUNCTION SP_FORMAT_EBS_VOUCHER (pv_voucher in VARCHAR) RETURN VARCHAR IS
  v_return varchar2(50);
  v_format varchar2(50);
  v_length int;
BEGIN
  v_format := '000.000.000.000';
  v_format := replace(v_format,'.','');
  v_length := length(v_format);
  v_format := v_format || pv_voucher;
  v_format := SUBSTR(v_format, length(v_format)-v_length+1,v_length);
  v_return := v_return || SUBSTR(v_format, 1,3);-- || '.';
  v_return := v_return || SUBSTR(v_format, 4,3);-- || '.';
  v_return := v_return || SUBSTR(v_format, 7,3);-- || '.';
  v_return := v_return || SUBSTR(v_format, 10,3);
  RETURN v_return;
END;
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
/
