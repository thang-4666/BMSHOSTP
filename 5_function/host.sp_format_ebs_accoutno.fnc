SET DEFINE OFF;
CREATE OR REPLACE FUNCTION SP_FORMAT_EBS_ACCOUTNO (pv_acctno in VARCHAR) RETURN VARCHAR IS
  v_return varchar2(50);
  v_format varchar2(50);
BEGIN
  v_format := '0000.00.000.0000000.000.0000.000';
  IF LENGTH(pv_acctno)=LENGTH(REPLACE(v_format,'.','')) THEN
      v_return := v_return || SUBSTR(pv_acctno, 7,3) || '.';
      v_return := v_return || SUBSTR(pv_acctno, 10,7) || '.';
      v_return := v_return || SUBSTR(pv_acctno, 17,3) || '.';
      v_return := v_return || SUBSTR(pv_acctno, 20,4) || '.';
      v_return := v_return || SUBSTR(pv_acctno, 24,3);-- || '.';
      v_return := '10.' || v_return;
    ELSE
          v_return:=pv_acctno;
    END IF;
    RETURN v_return;
END;
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
/
