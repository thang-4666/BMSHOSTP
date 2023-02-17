SET DEFINE OFF;
CREATE OR REPLACE FUNCTION fn_get_date_2280_1(p_currval varchar2 , p_date varchar2, p_prevnum number, p_REPOACCTNO varchar2)
return VARCHAR2
is
    l_prevdate  VARCHAR2 (20);
    l_termnum   number(10);
BEGIN
    select max(term) into l_termnum from bondrepo where repoacctno = p_REPOACCTNO;

    if l_termnum <> p_prevnum then
        select TO_CHAR(max(sbdate),'dd/mm/rrrr') into l_prevdate
        from sbcldr where cldrtype = '001' and holiday = 'N'
        and sbdate < to_date(to_date(p_date,'dd/mm/rrrr')+p_prevnum,'dd/mm/rrrr');

        return nvl(l_prevdate,p_date);
    else
        return p_currval;
    end if;

exception when others then
    return TO_CHAR(p_date,'DD/MM/RRRR') ;
end;

 
 
 
 
/
