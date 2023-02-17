SET DEFINE OFF;
CREATE OR REPLACE PROCEDURE "SP_SBS_CAL_LNMAST_INTEREST" IS
  v_code  NUMBER;
  v_errm  VARCHAR2(64);
  pv_errmsg varchar(250);
  v_ref_acctno varchar(50);
  v_ref_intdue NUMBER;
  v_ref_intovddue NUMBER;
  CURSOR pv_refcursor IS
    select mst.acctno,
    mst.prinnml*SP_SBS_CAL_INTDUE(typ.PRINTFRQ1, mst.rate1, typ.PRINTFRQ2, mst.rate2, typ.PRINTFRQ3, mst.rate3, mst.rlsdate, dt.currdate) INTDUE,
    mst.prinnml*SP_SBS_CAL_INTOVDDUE(typ.PRINTFRQ3, mst.rate3, mst.rlsdate, dt.currdate) INTOVDDUE
    from lnmast mst, lntype typ, (select TO_DATE(VARVALUE,'DD/MM/RRRR') currdate from sysvar where varname='BUSDATE') dt
    where typ.actype=mst.actype and typ.NINTCD='001' and mst.rlsdate<dt.currdate; --lai bac thang tung thoi ky
BEGIN
  OPEN pv_refcursor;
  LOOP
    FETCH pv_refcursor INTO v_ref_acctno, v_ref_intdue, v_ref_intovddue;
    EXIT WHEN pv_refcursor%NOTFOUND;
    UPDATE LNMAST SET intnmlacr=v_ref_intdue, intovdacr=v_ref_intovddue WHERE acctno=v_ref_acctno;
    UPDATE LNSCHD SET intnmlacr=v_ref_intdue, intovdPRIN=v_ref_intovddue WHERE REFTYPE='P' AND acctno=v_ref_acctno;
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
