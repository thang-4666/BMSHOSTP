SET DEFINE OFF;
CREATE OR REPLACE FUNCTION FN_CFGETBANKLIMIT(strACCTNO IN varchar2, strBANKID IN varchar2, strSUBTYPE IN varchar2)
  RETURN  number
  IS
  v_strCUSTID     varchar2(10);
  v_Result          number(20);
BEGIN
  v_result:=0;
  SELECT CUSTID INTO v_strCUSTID FROM AFMAST WHERE ACCTNO=strACCTNO;
    RETURN v_result;
EXCEPTION
   WHEN OTHERS THEN
    dbms_output.put_line(sqlerrm);
    RETURN -1;
END;

 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
/
