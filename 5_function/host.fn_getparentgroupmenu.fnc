SET DEFINE OFF;
CREATE OR REPLACE FUNCTION fn_getparentgroupmenu(pv_cmdid IN varchar2, pv_cmdtype in varchar2, pv_module in varchar2, pv_last in varchar2)
    RETURN varchar2 IS
    l_return varchar2(1000);
    l_cmdname varchar2(100);
    l_prid  varchar2(100);
BEGIN
    if pv_cmdtype = 'T' and pv_last = 'Y' then
        select cmdid into l_prid from cmdmenu where menutype = 'T' and modcode = pv_module;
    elsif pv_cmdtype = 'R' and pv_last = 'Y' then
        select cmdid into l_prid from cmdmenu where menutype = 'R' and modcode = pv_module;
    elsif pv_cmdtype = 'S' and pv_last = 'Y' then
        select cmdid into l_prid from cmdmenu where instr(objname,'GENERALVIEW') > 1;
    else
        select nvl(max(prid),'XXXXXXXXXX') into l_prid from cmdmenu where cmdid = pv_cmdid;
    end if;
    select cmdname into l_cmdname from cmdmenu where cmdid = l_prid;

    if  l_prid <> 'XXXXXXXXXX' then
        l_return:= fn_getparentgroupmenu(l_prid, 'M', null, 'N') || '/' || l_cmdname;
    else
        l_return:= l_cmdname;
        return l_return;
    end if;
    return l_return;
EXCEPTION
   WHEN OTHERS THEN
    RETURN '';
END;
 
 
 
 
 
 
 
 
 
 
 
/
