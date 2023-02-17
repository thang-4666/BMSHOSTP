SET DEFINE OFF;
CREATE OR REPLACE FUNCTION fn_getiswft(pv_codeid    IN     varchar2)
RETURN VARCHAR2
IS
    v_tradeplace      varchar2(10);
BEGIN
    SELECT trim(tradeplace) INTO v_tradeplace FROM sbsecurities WHERE codeid = pv_codeid;
    IF v_tradeplace IN ('001', '002', '005') THEN
        RETURN 'Y';
    ELSE
        RETURN 'N';
    END IF;
EXCEPTION WHEN OTHERS THEN
    RETURN 'N';
END;
 
/
