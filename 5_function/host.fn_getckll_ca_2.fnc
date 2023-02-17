SET DEFINE OFF;
CREATE OR REPLACE FUNCTION fn_getckll_ca_2 (pv_afacctno IN VARCHAR2, pv_codeid IN VARCHAR2, pv_qtty IN VARCHAR2)
RETURN NUMBER
iS
    v_result NUMBER(20);
BEGIN
        SELECT GREATEST(LEAST(SUM(se.qtty-nvl(se.mapqtty,0)),to_number(pv_qtty)),0)
                INTO v_result
        FROM sepitlog se, securities_info sec
            WHERE se.afacctno = pv_afacctno AND se.codeid = sec.codeid AND se.codeid = pv_codeid AND SE.PITRATE > 0
                and se.deltd <> 'Y'
            ;
    v_result := nvl(v_result,0);
    RETURN v_result;
EXCEPTION WHEN OTHERS THEN
    RETURN 0;
END;
 
/
