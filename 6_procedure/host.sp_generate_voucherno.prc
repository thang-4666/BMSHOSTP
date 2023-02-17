SET DEFINE OFF;
CREATE OR REPLACE PROCEDURE "SP_GENERATE_VOUCHERNO" (
  v_txdate in VARCHAR,
  v_tltxcd in VARCHAR) IS
  v_code  NUMBER;
  v_errm  VARCHAR2(64);
  pv_errmsg varchar(250);
  v_gen_voucherno varchar(50);
  v_ref_txnum varchar(10);
  v_ref_isgroup varchar(10);
  v_ref_trans_type varchar(10);
  v_ref_modcode varchar(10);
  v_ref_glgrp varchar(10);
  v_ref_brid varchar2(10);
  v_date date;
  CURSOR pv_refcursor IS
    SELECT 'GRTXNUM' TXNUM, TLTXCD, GLGP, MODCODE, GLGRP, 'ALL' BRID
    FROM VW_EBS_GENTX_VOUCHER WHERE GLGP='Y' AND TXDATE=v_date AND TLTXCD LIKE v_tltxcd
    GROUP BY TLTXCD, GLGP, MODCODE, GLGRP, TXDATE
    UNION ALL
    SELECT TXNUM, TLTXCD, GLGP, MODCODE, GLGRP, BRID
    FROM VW_EBS_GENTX_VOUCHER WHERE GLGP='N' AND TXDATE=v_date AND TLTXCD LIKE v_tltxcd
    UNION ALL
    SELECT 'GRTXNUM' TXNUM, TLTXCD, GLGP, MODCODE, 'ALL' GLGRP, BRID
    FROM VW_EBS_GENTX_VOUCHER WHERE GLGP='A' AND TXDATE=v_date AND TLTXCD LIKE v_tltxcd
    GROUP BY TLTXCD, GLGP, MODCODE, BRID, TXDATE
    UNION ALL
    SELECT 'GRTXNUM' TXNUM, 'ALL' TLTXCD, GLGP, MODCODE, GLGRP, BRID
    FROM VW_EBS_GENTX_VOUCHER WHERE GLGP='B' AND TXDATE=v_date AND TLTXCD LIKE v_tltxcd
    GROUP BY GLGRP, GLGP, MODCODE, BRID, TXDATE;
BEGIN
    v_date:= TO_DATE(v_txdate,'DD/MM/RRRR');
  --N?u TLTX.GLGP=N l??o s? ch?ng t? EBS chi ti?t cho t?ng giao d?ch.
  --N?u TLTX.GLGP=Y l??o s? ch?ng t? EBS t?ng theo TLTXCD v?LGRP tuong ?ng v?i ph?h? nghi?p v?.
  --N?u TLTX.GLGP=B l??o s? ch?ng t? EBS t?ng theo BRID v?LTXCD.
  --N?u TLTX.GLGP=A l??o s? ch?ng t? EBS t?ng theo GLGRP v?RID.
  OPEN pv_refcursor;
  LOOP
    FETCH pv_refcursor INTO v_ref_txnum, v_ref_trans_type, v_ref_isgroup, v_ref_modcode, v_ref_glgrp, v_ref_brid;
    EXIT WHEN pv_refcursor%NOTFOUND;
    pv_errmsg:=v_ref_txnum || '.' || v_ref_trans_type || ': ' || v_ref_isgroup || ': ' || v_ref_modcode || ': ' || v_ref_glgrp;
    SELECT SEQ_EBS_VOUCHERNUMBER.NEXTVAL INTO v_gen_voucherno FROM DUAL;
    IF v_ref_isgroup='Y' THEN
        --DBMS_OUTPUT.PUT_LINE(pv_errmsg || '-Y' || v_gen_voucherno);
        INSERT INTO GLLOGVOUCHER (TXDATE, TXNUM, VOUCHER, POST)
        SELECT DISTINCT TXDATE, TXNUM, v_gen_voucherno, 'N'
        FROM GLLOGHIST WHERE TXDATE=v_date AND TRANS_TYPE=v_ref_trans_type
        AND ACMODULE=v_ref_modcode AND GLGRP=v_ref_glgrp;
    ELSIF v_ref_isgroup='N' THEN
        --DBMS_OUTPUT.PUT_LINE(pv_errmsg || '-N ' || v_gen_voucherno);
        INSERT INTO GLLOGVOUCHER (TXDATE, TXNUM, VOUCHER, POST)
        SELECT DISTINCT TXDATE, TXNUM, v_gen_voucherno, 'N'P
        FROM GLLOGHIST WHERE TXDATE=v_date AND TXNUM=v_ref_txnum;
    ELSIF v_ref_isgroup='B' THEN
        DBMS_OUTPUT.PUT_LINE(pv_errmsg || '-B ' || v_gen_voucherno);
        INSERT INTO GLLOGVOUCHER (TXDATE, TXNUM, VOUCHER, POST)
        SELECT DISTINCT TXDATE, TXNUM, v_gen_voucherno, 'N'
        FROM GLLOGHIST WHERE TXDATE=v_date AND TRANS_TYPE=v_ref_trans_type
        AND ACMODULE=v_ref_modcode AND BRID=v_ref_brid;
    ELSIF v_ref_isgroup='A' THEN
        --DBMS_OUTPUT.PUT_LINE(pv_errmsg || '-A ' || v_gen_voucherno);
        INSERT INTO GLLOGVOUCHER (TXDATE, TXNUM, VOUCHER, POST)
        SELECT DISTINCT TXDATE, TXNUM, v_gen_voucherno, 'N'
        FROM GLLOGHIST WHERE TXDATE=v_date
        AND ACMODULE=v_ref_modcode AND GLGRP=v_ref_glgrp AND BRID=v_ref_brid;
    END IF;
  COMMIT;
  END LOOP;
  CLOSE pv_refcursor;
  COMMIT;
EXCEPTION
  WHEN OTHERS THEN
    v_code := SQLCODE;
    v_errm := SUBSTR(SQLERRM, 1, 64);
    INSERT INTO errors (code, message, logdetail, happened) VALUES (v_code, v_errm, 'SP_GENERATE_EXPORTGL:' || v_txdate, SYSTIMESTAMP);
END;

 
 
 
 
/
