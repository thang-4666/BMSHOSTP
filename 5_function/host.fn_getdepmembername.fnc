SET DEFINE OFF;
CREATE OR REPLACE FUNCTION fn_getdepmembername(strMEMBERID varchar2)
  RETURN  VARCHAR2
  IS
  v_Result  VARCHAR2 (150);
  v_strMemID varchar2(100);
BEGIN
    --GET NAME
    v_strMemID:=strMEMBERID;
    SELECT DEPOSITID || ' - ' || FULLNAME into v_Result
    FROM deposit_member WHERE DEPOSITID=v_strMemID;

    RETURN v_Result;
EXCEPTION
   WHEN OTHERS THEN
    RETURN 0;
END;

 
 
 
 
 
 
 
 
 
 
 
 
 
/
