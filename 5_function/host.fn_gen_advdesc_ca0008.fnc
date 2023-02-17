SET DEFINE OFF;
CREATE OR REPLACE FUNCTION FN_GEN_ADVDESC_CA0008(pv_RATE In VARCHAR2, pv_SECTYPE IN VARCHAR2,pv_RATE2 IN VARCHAR2,pv_SECTYPE2 IN VARCHAR2)
    RETURN VARCHAR2 IS
    v_Result  VARCHAR2(250);
    v_strLeft VARCHAR2(250);
    v_strRight VARCHAR2(250);

    V_SECTYPE1   VARCHAR2(100);
    V_SECTYPE2   VARCHAR2(100);
BEGIN
    SELECT (CASE WHEN pv_SECTYPE IN ('003','006','222') THEN ' Trái phiếu ' ELSE ' Cổ phiếu ' END) INTO V_SECTYPE1 FROM DUAL;
    SELECT (CASE WHEN pv_SECTYPE2 IN ('003','006','222') THEN ' Trái phiếu ' ELSE ' Cổ phiếu ' END) INTO V_SECTYPE2 FROM DUAL;

    v_strLeft:= substr(pv_RATE,0,instr(pv_RATE,'/') - 1);
    v_strRight:= substr(pv_RATE,instr(pv_RATE,'/') + 1,length(pv_RATE));
    v_Result:= v_strLeft || V_SECTYPE1 ||' sở hữu được hưởng ' ||  v_strRight || ' quyền, ';

    v_strLeft:= substr(pv_RATE2,0,instr(pv_RATE2,'/') - 1);
    v_strRight:= substr(pv_RATE2,instr(pv_RATE2,'/') + 1,length(pv_RATE2));
    v_Result:= v_Result || v_strLeft || ' quyền được mua ' ||  v_strRight || V_SECTYPE2 ||' mới ';

    RETURN v_Result;

EXCEPTION
   WHEN OTHERS THEN
    RETURN '';
END;

 
 
 
 
/
