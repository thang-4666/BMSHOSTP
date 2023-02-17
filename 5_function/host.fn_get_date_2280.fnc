SET DEFINE OFF;
CREATE OR REPLACE FUNCTION fn_get_date_2280(p_currval varchar2,p_date varchar2, p_prevnum number, p_REPOACCTNO varchar2)
return VARCHAR2
is
    l_prevdate VARCHAR2 (20);
    l_termnum   number(10);
BEGIN
    select max(term) into l_termnum from bondrepo where repoacctno = p_REPOACCTNO;
    if l_termnum <> p_prevnum then
        select TO_CHAR(sbdate,'DD/MM/RRRR') into l_prevdate from sbcurrdate where numday=(
            select numday from sbcurrdate
            where sbdate = to_date(p_date,'dd/mm/rrrr') and sbtype='N'
            ) + p_prevnum
        and sbtype='N';
        return nvl(l_prevdate,p_date);
    else
        return p_currval;
    end if;
/*
    select TO_CHAR(MIN(sbdate),'dd/mm/rrrr') into l_prevdate
    from sbcldr where cldrtype = '001' and holiday = 'N' and sbdate >= p_date+p_prevnum;
*/
exception when others then
return p_date ;
end;

 
 
 
 
/
