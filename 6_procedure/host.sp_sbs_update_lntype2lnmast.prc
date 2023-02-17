SET DEFINE OFF;
CREATE OR REPLACE PROCEDURE "SP_SBS_UPDATE_LNTYPE2LNMAST" IS
  v_code  NUMBER;
  v_errm  VARCHAR2(64);
  pv_errmsg varchar(250);
  v_ref_actype varchar(50);
  v_ref_PRINTFRQ1 NUMBER;
  v_ref_PRINTFRQ2 NUMBER;
  v_ref_PRINTFRQ3 NUMBER;
  CURSOR pv_refcursor IS
    select actype, PRINTFRQ1, PRINTFRQ2, PRINTFRQ3
    from lntype typ; --lai bac thang tung thoi ky
BEGIN
  OPEN pv_refcursor;
  LOOP
    FETCH pv_refcursor INTO v_ref_actype, v_ref_PRINTFRQ1, v_ref_PRINTFRQ2, v_ref_PRINTFRQ3;
    EXIT WHEN pv_refcursor%NOTFOUND;
    UPDATE LNMAST SET PRINTFRQ1=v_ref_PRINTFRQ1, PRINTFRQ2=v_ref_PRINTFRQ2, PRINTFRQ3=v_ref_PRINTFRQ3 WHERE actype=v_ref_actype;
  END LOOP;
  CLOSE pv_refcursor;
  COMMIT;
EXCEPTION
  WHEN OTHERS THEN
    v_code := SQLCODE;
    v_errm := SUBSTR(SQLERRM, 1, 64);
    INSERT INTO errors (code, message, logdetail, happened) VALUES (v_code, v_errm, 'sp_generate_balance_confirm', SYSTIMESTAMP);
END;

 
 
 
 
/
