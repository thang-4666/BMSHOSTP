SET DEFINE OFF;
CREATE OR REPLACE PROCEDURE "SP_GENERATE_SYMBOL_UPCOM_PRICE" IS
  v_code  NUMBER;
  v_errm  VARCHAR2(64);
  pv_errmsg varchar(250);
  v_ref_tradeplace varchar(50);
  v_ref_symbol varchar(50);
  v_ref_flprice NUMBER;
  v_ref_ceprice NUMBER;
  v_ref_rfprice NUMBER;
  CURSOR pv_refcursor IS
                SELECT RTRIM(SB.SYMBOL), RTRIM(SB.TRADEPLACE), ED.FLPRICE, ED.CEPRICE, ED.RFPRICE FROM ALL_DAYPRICE ED, SBSECURITIES SB
                WHERE SB.SYMBOL=ED.SYMBOL AND ED.TRANS_DATE=TRUNC(SYSDATE) AND ED.STATUS=0;
BEGIN
  OPEN pv_refcursor;
  LOOP
    FETCH pv_refcursor INTO v_ref_symbol, v_ref_tradeplace, v_ref_flprice, v_ref_ceprice, v_ref_rfprice;
    EXIT WHEN pv_refcursor%NOTFOUND;
                UPDATE SECURITIES_INFO SET FLOORPRICE=v_ref_flprice, CEILINGPRICE=v_ref_ceprice, BASICPRICE=v_ref_rfprice  WHERE SYMBOL=v_ref_symbol;
                UPDATE ALL_DAYPRICE SET STATUS=1 WHERE TRANS_DATE=TRUNC(SYSDATE) AND STATUS=0 AND SYMBOL=v_ref_symbol;
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
