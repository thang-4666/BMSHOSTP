SET DEFINE OFF;
CREATE OR REPLACE PROCEDURE "SP_GENERATE_EXPORTGL" (
  v_txdate in VARCHAR,
  v_tltxcd in VARCHAR) IS
  v_code  NUMBER;
  v_errm  VARCHAR2(64);
  pv_errmsg varchar(4000);
  v_ref_txnum varchar(20);
  v_ref_txdate varchar(20);
  v_prev_workingdate DATE;
  CURSOR pv_refcursor IS
  SELECT TXNUM, TO_CHAR(TXDATE,'DD/MM/YYYY')
  FROM TLLOG TL, (SELECT DISTINCT TLTXCD FROM EXTPOSTMAP) RFTX WHERE TL.TLTXCD=RFTX.TLTXCD
  AND TL.TXDATE=TO_DATE(v_txdate,'DD/MM/RRRR') AND TL.DELTD<>'Y' AND TL.TLTXCD LIKE v_tltxcd --AND TL.TLTXCD <> '8865'
  UNION ALL
  SELECT TXNUM, TO_CHAR(TXDATE,'DD/MM/YYYY')
  FROM TLLOGALL TL, (SELECT DISTINCT TLTXCD FROM EXTPOSTMAP) RFTX WHERE TL.TLTXCD=RFTX.TLTXCD
  AND TL.TXDATE=TO_DATE(v_txdate,'DD/MM/RRRR') AND TL.DELTD<>'Y' AND TL.TLTXCD LIKE v_tltxcd --AND TL.TLTXCD <> '8865'
 /* UNION ALL
  SELECT TXNUM, TXDATE
  FROM TLLOGALL TL, (SELECT DISTINCT TLTXCD FROM EXTPOSTMAP) RFTX WHERE TL.TLTXCD=RFTX.TLTXCD
  AND TL.TXDATE=(select sbdate from (
                    select sbdate from sbcldr where cldrtype = '000' and holiday = 'N' and sbdate < to_date(v_txdate,'dd/mm/yyyy')
                order by sbdate desc) where rownum=1)
  AND TL.DELTD<>'Y' AND TL.TLTXCD = '8865'*/
--AND TXNUM = '8000016328'
  ;
BEGIN
  OPEN pv_refcursor;
  LOOP
  FETCH pv_refcursor INTO v_ref_txnum, v_ref_txdate;
  EXIT WHEN pv_refcursor%NOTFOUND;
  DBMS_OUTPUT.PUT_LINE(v_txdate || '.' || v_ref_txnum || ': ' || pv_errmsg);
  pv_errmsg:='';
  SP_GENERATE_TXPOSTMAP(v_ref_txdate, v_ref_txnum, pv_errmsg);
  IF pv_errmsg<>'' THEN
    DBMS_OUTPUT.PUT_LINE(v_txdate || '.' || v_ref_txnum || ': ' || pv_errmsg);
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
