SET DEFINE OFF;
CREATE OR REPLACE FUNCTION FN_GEN_CAMASTID(pv_brid In VARCHAR2, pv_codeid IN VARCHAR2,pv_camastid IN VARCHAR2)
    RETURN VARCHAR2 IS
    v_Result  VARCHAR2(250);
    v_autoid VARCHAR2(250);
BEGIN

    if( (nvl(pv_camastid,'0')= '0' OR (SUBSTR(pv_camastid,5,6) <> pv_codeid )) AND nvl(pv_codeid,'0') <> '0') THEN
    SELECT seq_camastid.nextval INTO v_autoid FROM dual;
    v_autoid:=lpad(v_autoid,6,0);
                        v_result:=pv_brid||pv_codeid||v_autoid;
                        ELSE
                          v_Result:=pv_camastid;
                          END IF;
    RETURN v_Result;

EXCEPTION
   WHEN OTHERS THEN
    RETURN 0;
END;
 
 
 
 
 
 
 
 
 
 
 
 
 
/
