SET DEFINE OFF;
CREATE OR REPLACE PROCEDURE "SP_GENERATE_SYMBOL_ALL_PRICE" IS
begin
null;
end;
/*  v_code  NUMBER;
  v_errm  VARCHAR2(64);
  pv_errmsg varchar(250);
  v_ref_tradeplace varchar(50);
  v_ref_symbol varchar(50);
  v_ref_flprice NUMBER;
  v_ref_ceprice NUMBER;
  v_ref_rfprice NUMBER;
  timeCURRENT   VARCHAR2(8);
  CURSOR pv_refcursor_upcom IS
                SELECT RTRIM(SB.SYMBOL), RTRIM(SB.TRADEPLACE), ED.FLPRICE, ED.CEPRICE, ED.RFPRICE FROM ALL_DAYPRICE ED, SBSECURITIES SB
                WHERE SB.SYMBOL=ED.SYMBOL AND ED.TRANS_DATE=TRUNC(SYSDATE) AND ED.STATUS=0;
  CURSOR pv_refcursor_both IS
                SELECT SE.SYMBOL,SE.floorprice,SE.ceilingprice,SE.currprice FROM SECURITIES_INFO SE
                WHERE SE.symbol IN (SELECT sb.symbol FROM sbsecurities sb where sb.tradeplace in ('001','002'));-- Lay gia HOSe va HNX
BEGIN
  SELECT to_char(SYSDATE, 'HH24:MI:SS') INTO timeCURRENT FROM DUAL;
--  IF ( timeCURRENT >= '07:30:00' AND timeCURRENT <= '11:00:00' ) THEN
    OPEN pv_refcursor_upcom;
    LOOP
        FETCH pv_refcursor_upcom INTO v_ref_symbol, v_ref_tradeplace, v_ref_flprice, v_ref_ceprice, v_ref_rfprice;
        EXIT WHEN pv_refcursor_upcom%NOTFOUND;
                UPDATE SECURITIES_INFO SET FLOORPRICE=v_ref_flprice, CEILINGPRICE=v_ref_ceprice, BASICPRICE=v_ref_rfprice  WHERE SYMBOL=v_ref_symbol;
                UPDATE BDS.SECURITIES_INFO@LNKBDS_HS SET FLOORPRICE=v_ref_flprice, CEILINGPRICE=v_ref_ceprice, currprice=v_ref_rfprice  WHERE SYMBOL=v_ref_symbol;
                UPDATE BDS.SECURITIES_INFO@LNKBDS_HV SET FLOORPRICE=v_ref_flprice, CEILINGPRICE=v_ref_ceprice, currprice=v_ref_rfprice  WHERE SYMBOL=v_ref_symbol;
                UPDATE BDS.SECURITIES_INFO@LNKBDS_SG SET FLOORPRICE=v_ref_flprice, CEILINGPRICE=v_ref_ceprice, currprice=v_ref_rfprice  WHERE SYMBOL=v_ref_symbol;
                UPDATE BDS.SECURITIES_INFO@LNKBDS_VT SET FLOORPRICE=v_ref_flprice, CEILINGPRICE=v_ref_ceprice, currprice=v_ref_rfprice  WHERE SYMBOL=v_ref_symbol;
                UPDATE BDS.SECURITIES_INFO@LNKBDS_DN SET FLOORPRICE=v_ref_flprice, CEILINGPRICE=v_ref_ceprice, currprice=v_ref_rfprice  WHERE SYMBOL=v_ref_symbol;
                UPDATE BDS.SECURITIES_INFO@LNKBDS_CT SET FLOORPRICE=v_ref_flprice, CEILINGPRICE=v_ref_ceprice, currprice=v_ref_rfprice  WHERE SYMBOL=v_ref_symbol;
                UPDATE ALL_DAYPRICE SET STATUS=1 WHERE TRANS_DATE=TRUNC(SYSDATE) AND STATUS=0 AND SYMBOL=v_ref_symbol;
        END LOOP;
        CLOSE pv_refcursor_upcom;
--  ELSE
    OPEN pv_refcursor_both;
    LOOP
        FETCH pv_refcursor_both INTO v_ref_symbol,v_ref_flprice, v_ref_ceprice, v_ref_rfprice;
        EXIT WHEN pv_refcursor_both%NOTFOUND;
                UPDATE SECURITIES_INFO SET FLOORPRICE=v_ref_flprice, CEILINGPRICE=v_ref_ceprice, currprice=v_ref_rfprice  WHERE SYMBOL=v_ref_symbol;
                UPDATE BDS.SECURITIES_INFO@LNKBDS_HS SET FLOORPRICE=v_ref_flprice, CEILINGPRICE=v_ref_ceprice, currprice=v_ref_rfprice  WHERE SYMBOL=v_ref_symbol;
                UPDATE BDS.SECURITIES_INFO@LNKBDS_HV SET FLOORPRICE=v_ref_flprice, CEILINGPRICE=v_ref_ceprice, currprice=v_ref_rfprice  WHERE SYMBOL=v_ref_symbol;
                UPDATE BDS.SECURITIES_INFO@LNKBDS_SG SET FLOORPRICE=v_ref_flprice, CEILINGPRICE=v_ref_ceprice, currprice=v_ref_rfprice  WHERE SYMBOL=v_ref_symbol;
                UPDATE BDS.SECURITIES_INFO@LNKBDS_VT SET FLOORPRICE=v_ref_flprice, CEILINGPRICE=v_ref_ceprice, currprice=v_ref_rfprice  WHERE SYMBOL=v_ref_symbol;
                UPDATE BDS.SECURITIES_INFO@LNKBDS_DN SET FLOORPRICE=v_ref_flprice, CEILINGPRICE=v_ref_ceprice, currprice=v_ref_rfprice  WHERE SYMBOL=v_ref_symbol;
                UPDATE BDS.SECURITIES_INFO@LNKBDS_CT SET FLOORPRICE=v_ref_flprice, CEILINGPRICE=v_ref_ceprice, currprice=v_ref_rfprice  WHERE SYMBOL=v_ref_symbol;
                UPDATE ALL_DAYPRICE SET STATUS=1 WHERE TRANS_DATE=TRUNC(SYSDATE) AND STATUS=0 AND SYMBOL=v_ref_symbol;
        END LOOP;
        CLOSE pv_refcursor_both;
--  END IF;
  INSERT INTO errors (code, message, logdetail, happened) VALUES (v_code, v_errm, 'Load Price sucessfull', SYSTIMESTAMP);
  COMMIT;
EXCEPTION
  WHEN OTHERS THEN
    v_code := SQLCODE;
    v_errm := SUBSTR(SQLERRM, 1, 64);
    INSERT INTO errors (code, message, logdetail, happened) VALUES (v_code, v_errm, 'Load Price failed', SYSTIMESTAMP);
END;*/

 
 
 
 
/
