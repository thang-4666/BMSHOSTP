SET DEFINE OFF;
CREATE OR REPLACE FUNCTION fn_get_blocked(pv_camastid varchar2 ,pv_codeid varchar2, pv_afacctno varchar2)
return number is
v_return number;
BEGIN
    select blocked - inblocked into v_return from caschd_log
    where camastid = pv_camastid
    and codeid = pv_codeid
    and afacctno = pv_afacctno
    and deltd = 'N';
    return v_return;
exception when others then
    return -1;
end;
 
/
