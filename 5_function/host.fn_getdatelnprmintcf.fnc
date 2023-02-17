SET DEFINE OFF;
CREATE OR REPLACE FUNCTION fn_getdatelnprmintcf(p_AUTOID IN VARCHAR2, p_TYPE IN NUMBER)
return VARCHAR2
is
    l_prevdate VARCHAR2 (20);
    L_CURRDATE VARCHAR2(20);
    V_NUMVALDAY NUMBER(20);
    V_STRVALDATE VARCHAR2(30);
    V_STREXPDATE VARCHAR2(30);
    V_STRDATETYPE VARCHAR2(30);

BEGIN
    SELECT VARVALUE INTO L_CURRDATE
    FROM SYSVAR WHERE GRNAME = 'SYSTEM' AND VARNAME ='CURRDATE';

    SELECT VALDAY, TO_CHAR(VALDATE,'DD/MM/RRRR'), TO_CHAR(EXPDATE,'DD/MM/RRRR'), DATETYPE
        INTO V_NUMVALDAY, V_STRVALDATE, V_STREXPDATE, V_STRDATETYPE
    FROM lnprminmast WHERE autoid = p_AUTOID;

    If V_STRDATETYPE = 'F' Then
        IF p_TYPE = 1 THEN
           l_prevdate := L_CURRDATE;
        ELSE
           l_prevdate := TO_CHAR(TO_DATE(TO_DATE(L_CURRDATE,'DD/MM/RRRR') + V_NUMVALDAY,'DD/MM/RRRR'),'DD/MM/RRRR');
        END IF;
    Else
        IF p_TYPE = 1 THEN
           l_prevdate := V_STRVALDATE;
        ELSE
           l_prevdate := V_STREXPDATE;
        END IF;
    End If;
    return l_prevdate;
exception when others then
    return '01/01/1945';
end;

 
 
 
 
/
