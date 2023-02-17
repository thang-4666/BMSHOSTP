SET DEFINE OFF;
CREATE OR REPLACE PROCEDURE "SP_GENERATE_SYMBOL_DAYPRICE" IS
begin
null;
end;
/*  v_code  NUMBER;
  v_errm  VARCHAR2(64);
  pv_errmsg varchar(250);
  v_ref_tradeplace varchar(50);
  v_ref_symbol varchar(50);
  v_ref_closedprice NUMBER;
  v_ref_avgprice NUMBER;
  CURSOR pv_refcursor IS
    SELECT RTRIM(SB.SYMBOL), RTRIM(SB.TRADEPLACE), ED.CLOSEDPRICE, ED.AVGPRICE FROM EOD_DAYPRICE ED, SBSECURITIES SB
    WHERE SB.SYMBOL=ED.SYMBOL AND ED.STATUS=0;
BEGIN
  pr_error('Begin load EOD Price', 'Load Price EOD');
  commit;
  OPEN pv_refcursor;
  LOOP
    FETCH pv_refcursor INTO v_ref_symbol, v_ref_tradeplace, v_ref_closedprice, v_ref_avgprice;
    EXIT WHEN pv_refcursor%NOTFOUND;
         begin
         pr_debug('Begin: ' || v_ref_symbol || ' Ref closed price: ' || v_ref_closedprice || ' Tradeplace: ' || v_ref_tradeplace, 'Load Price EOD');
         commit;
        --C?P NH?T S?N HOSE
        IF v_ref_tradeplace='001' THEN
            UPDATE SECURITIES_INFO SET MTMPRICE=BASICPRICE, BASICPRICE=v_ref_closedprice  WHERE SYMBOL=v_ref_symbol;
            UPDATE BDS.SECURITIES_INFO@LNKBDS_HS SET MTMPRICE=BASICPRICE, BASICPRICE=v_ref_closedprice  WHERE SYMBOL=v_ref_symbol;
            UPDATE BDS.SECURITIES_INFO@LNKBDS_SG SET MTMPRICE=BASICPRICE, BASICPRICE=v_ref_closedprice  WHERE SYMBOL=v_ref_symbol;
            UPDATE BDS.SECURITIES_INFO@LNKBDS_HV SET MTMPRICE=BASICPRICE, BASICPRICE=v_ref_closedprice  WHERE SYMBOL=v_ref_symbol;
            UPDATE BDS.SECURITIES_INFO@LNKBDS_DN SET MTMPRICE=BASICPRICE, BASICPRICE=v_ref_closedprice  WHERE SYMBOL=v_ref_symbol;
            UPDATE BDS.SECURITIES_INFO@LNKBDS_VT SET MTMPRICE=BASICPRICE, BASICPRICE=v_ref_closedprice  WHERE SYMBOL=v_ref_symbol;
            UPDATE BDS.SECURITIES_INFO@LNKBDS_CT SET MTMPRICE=BASICPRICE, BASICPRICE=v_ref_closedprice  WHERE SYMBOL=v_ref_symbol;
        END IF;
        --C?P NH?T S?N HNX
        IF v_ref_tradeplace='002' THEN
            UPDATE SECURITIES_INFO SET MTMPRICE=BASICPRICE, BASICPRICE=v_ref_avgprice  WHERE SYMBOL=v_ref_symbol;
            UPDATE BDS.SECURITIES_INFO@LNKBDS_HS SET MTMPRICE=BASICPRICE, BASICPRICE=v_ref_avgprice  WHERE SYMBOL=v_ref_symbol;
            UPDATE BDS.SECURITIES_INFO@LNKBDS_SG SET MTMPRICE=BASICPRICE, BASICPRICE=v_ref_avgprice  WHERE SYMBOL=v_ref_symbol;
            UPDATE BDS.SECURITIES_INFO@LNKBDS_HV SET MTMPRICE=BASICPRICE, BASICPRICE=v_ref_avgprice  WHERE SYMBOL=v_ref_symbol;
            UPDATE BDS.SECURITIES_INFO@LNKBDS_DN SET MTMPRICE=BASICPRICE, BASICPRICE=v_ref_avgprice  WHERE SYMBOL=v_ref_symbol;
            UPDATE BDS.SECURITIES_INFO@LNKBDS_VT SET MTMPRICE=BASICPRICE, BASICPRICE=v_ref_avgprice  WHERE SYMBOL=v_ref_symbol;
            UPDATE BDS.SECURITIES_INFO@LNKBDS_CT SET MTMPRICE=BASICPRICE, BASICPRICE=v_ref_avgprice  WHERE SYMBOL=v_ref_symbol;
        END IF;
        exception
        when others then
            pr_error('Load Price EOD failed ' || v_ref_symbol, 'Load Price EOD');
            --INSERT INTO errors (code, message, logdetail, happened) VALUES (seq_errors.nextval, v_ref_symbol, 'Load Price EOD failed', SYSTIMESTAMP);
        end;
    COMMIT;
  END LOOP;
    UPDATE EOD_DAYPRICE SET STATUS=1 WHERE STATUS=0;
    INSERT INTO errors (code, message, logdetail, happened) VALUES (v_code, v_errm, 'Load Price EOD sucessful', SYSTIMESTAMP);
    COMMIT;
  CLOSE pv_refcursor;

EXCEPTION
  WHEN OTHERS THEN
    begin
        v_code := SQLCODE;
        v_errm := SUBSTR(SQLERRM, 1, 64);
        INSERT INTO errors (code, message, logdetail, happened) VALUES (v_code, v_errm, 'Load Price EOD failed', SYSTIMESTAMP);
    end;
END;*/

 
 
 
 
/
