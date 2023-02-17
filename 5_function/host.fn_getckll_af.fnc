SET DEFINE OFF;
CREATE OR REPLACE FUNCTION fn_getckll_af (pv_afacctno IN VARCHAR2, pv_codeid IN VARCHAR2)
RETURN NUMBER
iS
    v_result NUMBER(20);
BEGIN
    /*SELECT  SUM(mod(se.trade,sec.tradelot))
                INTO v_result
        FROM semast se, afmast af, securities_info sec
            WHERE se.afacctno = af.acctno  AND se.codeid = sec.codeid
                    AND af.acctno = pv_afacctno  AND se.codeid = pv_codeid;*/
    SELECT mod(sum(greatest(se.trade - NVL (b.secureamt, 0) + NVL(b.sereceiving,0),0)),max(tradelot))
                INTO v_result
        FROM semast se, afmast af, securities_info sec,
            v_getsellorderinfo b
            WHERE se.afacctno = af.acctno
                AND se.acctno = b.seacctno(+)
                AND se.codeid = sec.codeid AND af.acctno = pv_afacctno
                AND se.codeid = pv_codeid;
    RETURN v_result;
EXCEPTION WHEN OTHERS THEN
    RETURN 0;
END;

 
 
 
 
 
 
 
 
 
 
 
/
