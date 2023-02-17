SET DEFINE OFF;
CREATE OR REPLACE PROCEDURE "SP_GENERATE_TRF2EBS" (
  v_txdate in VARCHAR) IS
  begin
  null;
  end;
/*  v_code  NUMBER;
  v_errm  VARCHAR2(64);
  pv_errmsg varchar(250);
  v_trans_date varchar2(20);
  v_curr_voucherno varchar(50);
  v_ref_txnum varchar(10);
  v_ref_trans_type varchar(10);
  v_ref_ebsvoucher varchar(50);
  v_ref_voucher varchar(50);
  v_ref_subtxno varchar(10);
  v_ref_amt float;
  v_id varchar2(10);
  v_post varchar2(10);
  v_ref_description varchar2(4000);
  v_ref_custodycd varchar(10);
  v_ref_desc varchar(250);
  v_ref_customername varchar(100);
  v_ref_dracctno varchar(50);
  v_ref_cracctno varchar(50);
  CURSOR pv_refcursor IS
select TRANS_DATE, EBSVOUCHER, VOUCHER, TRANS_TYPE, DESCRIPTION, DRACCTNO, CRACCTNO, AMT, LPAD(SEQ_EBS_ID.nextval, 7, '0') ID, POST, CUSTOMER_NUMBER, CUSTOMER_NAME
from(
    SELECT  v_txdate TRANS_DATE,
            SP_FORMAT_EBS_VOUCHER(VOUCHER) EBSVOUCHER, VOUCHER,
            TRANS_TYPE,
            TRANS_TYPE || '/' || TXNUM || '/' || NOTES DESCRIPTION,
            SP_FORMAT_EBS_ACCOUTNO(MAX(MST.DRACCTNO)) DRACCTNO,
            SP_FORMAT_EBS_ACCOUTNO(MAX(MST.CRACCTNO)) CRACCTNO,
            SUM(MST.AMOUNT) AMT,
            POST,
            MAX (CASE WHEN GLGP='Y' THEN 'GRCUSTOMER' ELSE CUSTOMER_NUMBER END) CUSTOMER_NUMBER,
            MAX (CASE WHEN GLGP='Y' THEN 'GRCUSTOMER' ELSE CUSTOMER_NAME END) CUSTOMER_NAME
    FROM VW_EBS_POSTING MST WHERE POST='N' AND TXDATE=TO_DATE(v_txdate,'DD/MM/RRRR') AND MST.DRACCTNO <> MST.CRACCTNO
    GROUP BY VOUCHER, TXDATE, TRANS_TYPE, TXNUM, SUBTXNO, GLGP, NOTES, POST
    ORDER BY VOUCHER, TXDATE, TRANS_TYPE, TXNUM, SUBTXNO, GLGP) a;
BEGIN
  v_curr_voucherno:='BEGIN';
  OPEN pv_refcursor;
  LOOP
  FETCH pv_refcursor INTO v_trans_date, v_ref_ebsvoucher, v_ref_voucher, v_ref_trans_type , v_ref_description, v_ref_dracctno, v_ref_cracctno, v_ref_amt, v_id, v_post, v_ref_custodycd, v_ref_customername;
    EXIT WHEN pv_refcursor%NOTFOUND;
    --d? d?u b? giao d?ch tru?c d? d?ong
    IF v_curr_voucherno <> v_ref_voucher and v_curr_voucherno <> 'BEGIN' THEN
        UPDATE GLLOGVOUCHER SET POST='Y', POSTEDDT=SYSDATE, POSTEDTM=SYSTIMESTAMP  WHERE VOUCHER=v_curr_voucherno;
    END IF;
  pv_errmsg:=v_ref_txnum || '.' || v_ref_desc || '.' ||  v_ref_trans_type || ': ' || v_ref_ebsvoucher || ': ' || v_ref_subtxno || ': ' || v_ref_amt;
  pv_errmsg:=pv_errmsg || '.' || v_ref_custodycd || '.' || v_ref_customername || ': ' || v_ref_dracctno || ': ' || v_ref_cracctno;
  DBMS_OUTPUT.PUT_LINE(pv_errmsg);

  --d?y sang ORACLE EBS
  --v_ref_dracctno := REPLACE(v_ref_dracctno,'.','');
  --v_ref_cracctno := REPLACE(v_ref_cracctno,'.','');
  --d? d?u giao d?ch
  --IF v_curr_voucherno<>v_ref_voucher AND v_curr_voucherno<>'BEGIN' THEN
    DELETE FROM BOSC_GL@LINKEBS.SBSC.COM.VN WHERE TRANS_DATE=v_txdate AND VOUCHER=v_curr_voucherno;
    INSERT INTO BOSC_GL@LINKEBS.SBSC.COM.VN values (to_date(v_trans_date, 'dd/mm/yyyy'), v_ref_ebsvoucher, v_ref_trans_type , v_ref_description, v_ref_dracctno, v_ref_cracctno, v_ref_amt, v_id, v_post, v_ref_custodycd, v_ref_customername,null);
  --END IF;
  v_curr_voucherno:=v_ref_voucher;
  END LOOP;
  CLOSE pv_refcursor;
/*
  --X? l? d?c bi?t cho d?ng d? li?u cu?i c?ng
  IF v_curr_voucherno<>'BEGIN' THEN
    DELETE FROM BOSC_GL@LINKEBS.SBSC.COM.VN WHERE TRANS_DATE=v_txdate AND VOUCHER=v_curr_voucherno;
    INSERT INTO BOSC_GL@LINKEBS.SBSC.COM.VN values (to_date(v_trans_date, 'dd/mm/yyyy'), v_ref_ebsvoucher, v_ref_trans_type , v_ref_description, v_ref_dracctno, v_ref_cracctno, v_ref_amt, v_id, v_post, v_ref_custodycd, v_ref_customername);
    UPDATE GLLOGVOUCHER SET POST='Y', POSTEDDT=SYSDATE, POSTEDTM=SYSTIMESTAMP  WHERE VOUCHER=v_curr_voucherno;
  END IF;
*/
 /* COMMIT;
EXCEPTION
  WHEN OTHERS THEN
    v_code := SQLCODE;
    v_errm := SUBSTR(SQLERRM, 1, 64);
    INSERT INTO errors (code, message, logdetail, happened) VALUES (v_code, v_errm, 'SP_GENERATE_EXPORTGL:' || v_txdate, SYSTIMESTAMP);
END;*/

 
 
 
 
/
