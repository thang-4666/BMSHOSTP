SET DEFINE OFF;
CREATE OR REPLACE FUNCTION fn_gettaxamt_ca (pv_afacctno IN VARCHAR2, pv_codeid IN VARCHAR2, pv_qtty IN VARCHAR2, pv_price IN VARCHAR2)
RETURN NUMBER
iS
    v_result NUMBER(20);
    v_caqtty number;
BEGIN

        v_caqtty    := to_number(pv_qtty);
        v_result    := 0;
        for rec in (
            SELECT se.afacctno, se.codeid, se.pitrate, sec.parvalue, se.qtty-se.mapqtty qtty
            FROM sepitlog se, sbsecurities sec
                WHERE se.afacctno = pv_afacctno AND se.codeid = sec.codeid AND se.codeid = pv_codeid AND SE.PITRATE > 0
                    and se.deltd <> 'Y'
            order by se.txdate
        ) loop
            v_result    := v_result + GREATEST( LEAST(v_caqtty,rec.qtty),0)*LEAST(to_number(pv_price),rec.parvalue)*rec.pitrate/100;
            v_caqtty    := v_caqtty - LEAST(v_caqtty,rec.qtty);
            exit when v_caqtty<=0;
        end loop;
    v_result := nvl(v_result,0);
    RETURN v_result;
EXCEPTION WHEN OTHERS THEN
    RETURN 0;
END;
 
/
