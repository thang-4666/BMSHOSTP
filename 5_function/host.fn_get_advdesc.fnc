SET DEFINE OFF;
CREATE OR REPLACE FUNCTION FN_GET_ADVDESC(pv_CAMASTID In VARCHAR2,pv_ISCANCEL in VARCHAR2)
    RETURN VARCHAR2 IS
    v_Result  VARCHAR2(250);

BEGIN
   SELECT description INTO v_Result FROM camast WHERE camastid= pv_CAMASTID AND deltd='N';
   if pv_ISCANCEL = 'N' then  v_Result := 'Nhập '||v_Result;
   else v_Result := 'Hủy '||v_Result;
   end if;
    RETURN v_Result;

EXCEPTION
   WHEN OTHERS THEN
    RETURN '';
END;
 
 
 
 
/
