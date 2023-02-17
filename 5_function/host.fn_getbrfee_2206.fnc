SET DEFINE OFF;
CREATE OR REPLACE FUNCTION fn_getbrfee_2206(PV_CURVALUE NUMBER,PV_CALTYPE VARCHAR2,pv_feeamt varchar2, pv_CODEID VARCHAR2)
return number is
    v_return    number(20);
    v_feerate   number(10,4);
BEGIN
    if PV_CALTYPE = '02' then
        return PV_CURVALUE;
    end if;    
    SELECT nvl(bratio,0) into v_feerate FROM SBSECURITIES where CODEID = pv_CODEID;    
    return pv_feeamt*(v_feerate/100);
exception when others then
    return 0;
end;

 
 
 
 
/
