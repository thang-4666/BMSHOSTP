SET DEFINE OFF;
CREATE OR REPLACE FUNCTION fn_check_cfmast_samenamebirth(pv_custid in varchar2, pv_custodycd in varchar2, pv_fullname in varchar2, pv_birthday in varchar2)
return number
is
    --Ham kiem tra he thong da ton tai tai khoan co trung Ho ten va Ngay sinh voi tai khoan trong Flex
    --1: co trung, 0: khong trung
    v_count number;

begin
    plog.error('fn_check_cfmast_samenamebirth.pv_custid='||pv_custid||', pv_custodycd='||pv_custodycd
                ||', pv_fullname='||pv_fullname||', pv_birthday='||pv_birthday);

    if pv_custodycd like 'OTC%' then
        return 0; -- khong kiem tra tai khoan OTC
    end if;

    select count(*) into v_count
    from cfmast cf
    where cf.custid <> nvl(pv_custid,'z')
        and cf.custodycd not like 'OTC%'
        and upper(replace(cf.fullname,' ','')) = upper(replace(pv_fullname,' ','')) and cf.dateofbirth = to_date(pv_birthday,'DD/MM/RRRR')
        and cf.status <> 'C';

    if v_count>=1 then
        return 1;
    else
        return 0;
    end if;
exception when others then
    return 0;
end;
/
