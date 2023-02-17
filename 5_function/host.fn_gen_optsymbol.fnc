SET DEFINE OFF;
CREATE OR REPLACE FUNCTION FN_GEN_OPTSYMBOL(pv_codeid In VARCHAR2, pv_reportdate IN VARCHAR2,pv_optsymbol IN VARCHAR2)
    RETURN VARCHAR2 IS
    v_Result  VARCHAR2(250);
    v_autoid VARCHAR2(250);
    v_symbol VARCHAR2(250);

BEGIN
  SELECT symbol INTO v_symbol FROM sbsecurities WHERE codeid=pv_codeid;

    if( (
          nvl(pv_optsymbol,'0')= '0'
         OR
          (SUBSTR(pv_optsymbol,0,greatest(( INSTR(pv_optsymbol,'_')+4 ),0))
                                            <> (v_symbol||'_'||to_char(to_date(pv_reportdate,'DD/MM/YYYY'),'MMYY')))
        )
        AND nvl(pv_codeid,'0') <> '0') THEN
    SELECT seq_optsymbol.nextval INTO v_autoid FROM dual;
                        v_result:=v_symbol||'_' || to_char(TO_date(pv_reportdate,'DD/MM/YYYY'),'MMYY')||'_'||v_autoid;
                        ELSE
                          v_Result:=pv_optsymbol;
                          END IF;
    RETURN v_Result;

EXCEPTION
   WHEN OTHERS THEN
    RETURN 0;
END;

 
 
 
 
 
 
 
 
 
 
 
 
 
/
