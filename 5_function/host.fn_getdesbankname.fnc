SET DEFINE OFF;
CREATE OR REPLACE FUNCTION fn_getdesbankname (pv_REQID varchar2, pv_bankcode varchar2, pv_trfcode varchar2) return varchar2
is
v_return varchar2(100);
begin
    begin
        select  NVL(CVAL,NVAL) REFVAL into v_return from CRBTXREQdtl  where REQID = pv_REQID and fldname = 'DESACCTNAME';
        if v_return is null or length(v_return)=0 then
            select refacctname into v_return from crbdefacct where  refbank = pv_bankcode and trfcode = pv_trfcode;
        end if;
        return v_return;
    exception when others then
        select refacctname into v_return from crbdefacct where  refbank = pv_bankcode and trfcode = pv_trfcode;
        return v_return;
    end;
exception when others then
    return v_return;
end; 
 
 
 
 
 
 
 
 
 
 
 
/
