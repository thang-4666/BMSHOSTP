SET DEFINE OFF;
CREATE OR REPLACE PROCEDURE "SP_SBS_UPDATE_LNSCHD" IS
  v_code  NUMBER;
  v_errm  VARCHAR2(64);
  pv_errmsg varchar(250);
  v_ref_acctno varchar(50);
  v_ref_duedate date;
  CURSOR pv_refcursor IS
    select mst.acctno, getduedate(mst.rlsdate,typ.lncldr,'000',mst.prinTfrq3)
    from lnmast mst, lntype typ
    where typ.actype=mst.actype and typ.NINTCD='001'; --lai bac thang tung thoi ky
BEGIN
  OPEN pv_refcursor;
  LOOP
    FETCH pv_refcursor INTO v_ref_acctno, v_ref_duedate;
    EXIT WHEN pv_refcursor%NOTFOUND;
    UPDATE LNSCHD SET DUEDATE=v_ref_duedate, OVERDUEDATE=v_ref_duedate WHERE REFTYPE='P' AND acctno=v_ref_acctno;
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
