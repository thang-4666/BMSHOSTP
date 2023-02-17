SET DEFINE OFF;
CREATE OR REPLACE FUNCTION FN_CREATE_OPTSYMBOL (pv_codeid IN VARCHAR2, pv_reportdate IN VARCHAR2)
RETURN VARCHAR2
IS
    l_symbol    VARCHAR2(20);
    l_optsymbol VARCHAR2(30);
BEGIN
    SELECT symbol INTO l_symbol FROM sbsecurities WHERE codeid = pv_codeid;
    l_optsymbol := l_symbol 
                    || '_q' 
                    || TO_CHAR(TO_DATE(pv_reportdate,'dd/mm/rrrr'),'ddmmyy') 
                    || '_'
                    ||LPAD(seq_optsymbol.NEXTVAL,3,'000');
    RETURN l_optsymbol;    
END;
 
/
