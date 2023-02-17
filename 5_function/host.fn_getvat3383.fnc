SET DEFINE OFF;
CREATE OR REPLACE FUNCTION fn_getvat3383(PV_RIGHTQTTY number, pv_exprice NUMBER,pv_Custodycd VARCHAR2 )
return number is
    v_return number;
    v_QTTY   NUMBER;
    V_EXPRICE         NUMBER(20);
    V_AMT             NUMBER(10,4);
BEGIN


    SELECT TO_NUMBER(MAX(VARVALUE)) INTO V_AMT FROM SYSVAR WHERE GRNAME = 'SYSTEM' AND VARNAME = 'ADVSELLDUTY';
    v_QTTY := NVL(PV_RIGHTQTTY,0);
    V_EXPRICE := NVL(pv_exprice,0);
    v_return := ROUND((V_AMT*v_QTTY*V_EXPRICE)/100,0);

    SELECT decode(cf.vat,'Y',1,'N',0)* ROUND((V_AMT*v_QTTY*V_EXPRICE)/100,0) INTO v_return  FROM CFMAST CF WHERE CF.CUSTODYCD =pv_Custodycd;
  return v_return;




exception when others THEN
    return 0;
end;

 
 
 
 
/
