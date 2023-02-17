SET DEFINE OFF;
CREATE OR REPLACE FUNCTION fn_get_issuerid( PV_CODEID IN VARCHAR2)
    RETURN VARCHAR2 IS
    v_Result  VARCHAR2(20);
BEGIN

    SELECT MAX(ISS.ISSUERID) INTO v_Result FROM sbsecurities SB, issuers ISS
    WHERE SB.issuerid = ISS.issuerid
        AND SB.CODEID = PV_CODEID;
    v_Result := nvl(v_Result,'');
    RETURN v_Result;
EXCEPTION
   WHEN OTHERS THEN
    RETURN ' ';
END;

 
 
 
 
/
