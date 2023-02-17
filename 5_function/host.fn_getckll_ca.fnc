SET DEFINE OFF;
CREATE OR REPLACE FUNCTION fn_getckll_ca (pv_afacctno IN VARCHAR2, pv_codeid IN VARCHAR2)
RETURN NUMBER
iS
    v_result NUMBER(20);
BEGIN
        SELECT SUM(mod(se.qtty-nvl(se.mapqtty,0),sec.tradelot))
                INTO v_result
        FROM sepitlog se, securities_info sec
            WHERE se.afacctno = pv_afacctno AND se.codeid = sec.codeid AND se.codeid = pv_codeid
                and se.status = 'P'
            ;
    v_result := nvl(v_result,0);
    RETURN v_result;
EXCEPTION WHEN OTHERS THEN
    RETURN 0;
END;

 
 
 
 
 
 
 
 
 
 
 
/
