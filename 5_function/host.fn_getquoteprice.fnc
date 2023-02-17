SET DEFINE OFF;
CREATE OR REPLACE FUNCTION fn_GetQUOTEPRICE (PV_CODEID IN VARCHAR2, pv_TRADEPLACE IN VARCHAR2)
RETURN NUMBER
iS
    v_result NUMBER(20);
    v_pricetype varchar2(3);
    v_rate  NUMBER;
BEGIN


       SELECT PRICETYPE
                INTO v_pricetype
        FROM seoddlot WHERE TRADEPLACE = pv_TRADEPLACE;

        select rate into v_rate from seoddlot WHERE TRADEPLACE = pv_TRADEPLACE;

        select case when v_pricetype = '001' then floorprice else basicprice - (basicprice * v_rate /100) end into v_result
            from securities_info where codeid = PV_CODEID;

    RETURN v_result;
EXCEPTION WHEN OTHERS THEN
    RETURN 0;
END;

 
 
 
 
/
