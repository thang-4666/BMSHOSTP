SET DEFINE OFF;
CREATE OR REPLACE FUNCTION FN_GETDEPOLASTDT(strACCTNO IN VARCHAR2,txdate IN VARCHAR2)
  RETURN  DATE
  IS

  v_Result      DATE;
  v_depolastdt DATE;
  v_depolastdttemp DATE;

BEGIN
  SELECT to_Date(depolastdt,'DD/MM/RRRR') INTO v_depolastdt from cimast WHERE acctno= replace((strACCTNO),'.');
  select last_day(trunc(to_date(txdate,'DD/MM/RRRR'),'MM')-1) INTO v_depolastdttemp from dual;
  v_result:=NVL (v_depolastdt,to_Date(v_depolastdttemp,'DD/MM/RRRR'));

    RETURN v_result;
EXCEPTION
   WHEN OTHERS THEN
    RETURN NULL;
END;

 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
/
