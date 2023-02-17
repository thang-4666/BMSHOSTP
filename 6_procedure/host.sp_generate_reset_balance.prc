SET DEFINE OFF;
CREATE OR REPLACE PROCEDURE "SP_GENERATE_RESET_BALANCE" IS
  v_code  NUMBER;
  v_errm  VARCHAR2(64);
  pv_errmsg varchar(250);
  v_ref_account_no varchar(50);
  v_count NUMBER;
  CURSOR pv_refcursor IS
        SELECT ACCTNO FROM CFMAST CF, AFMAST AF, AFTYPE TYP
        WHERE cf.custatcom='N' AND CF.CUSTID=AF.CUSTID AND AF.ACTYPE=TYP.ACTYPE;
BEGIN
  OPEN pv_refcursor;
  LOOP
    FETCH pv_refcursor INTO v_ref_account_no;
    EXIT WHEN pv_refcursor%NOTFOUND;
  UPDATE CIMAST SET BALANCE=0 WHERE AFACCTNO=v_ref_account_no;
  UPDATE SEMAST SET TRADE=0 WHERE AFACCTNO=v_ref_account_no;
  END LOOP;
  CLOSE pv_refcursor;
  COMMIT;
EXCEPTION
  WHEN OTHERS THEN
    v_code := SQLCODE;
    v_errm := SUBSTR(SQLERRM, 1, 64);
    INSERT INTO errors (code, message, logdetail, happened) VALUES (v_code, v_errm, 'sp_generate_reset_balance', SYSTIMESTAMP);
END;

 
 
 
 
/
