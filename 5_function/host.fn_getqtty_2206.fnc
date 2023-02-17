SET DEFINE OFF;
CREATE OR REPLACE FUNCTION fn_getqtty_2206(PV_SEACCTNO VARCHAR2, pv_OPNFBORS VARCHAR2)
return number is
    v_return    number(20);
BEGIN

    ---l_feecode := SUBSTR(pv_feecode,);
    --l_feecode := SUBSTR(pv_feecode,0,INSTR(pv_feecode,'-')-1);
---- OPFSEL OPFSWP
    if pv_OPNFBORS in ('OPFSEL','OPFSWP') then
        select nvl(max(semast.trade),0) into v_return from semast where acctno = PV_SEACCTNO;
        return v_return;
    else
        return 0;
    end if;
exception when others then
    return 0;
end;
 
 
 
 
/
