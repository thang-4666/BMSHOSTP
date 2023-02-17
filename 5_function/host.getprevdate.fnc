SET DEFINE OFF;
CREATE OR REPLACE FUNCTION getprevdate(p_date date, p_prevnum number)
return date
is
l_prevdate date;
begin
    /*select min(sbdate)
        into l_prevdate
    from (
             select sb.sbdate from sbcldr sb
             where sb.cldrtype = '000' and sb.holiday = 'N' and sb.sbdate <= p_date
             order by sb.sbdate desc)
     where rownum <= p_prevnum;
     return l_prevdate;*/
     -- SUA THEO CACH CUA GIANHVG -- 12-MAR-2012
     select sbdate into l_prevdate from sbcurrdate where numday=(
        select numday from sbcurrdate
        where sbdate= p_date and sbtype='B'
        ) - p_prevnum + 1
    and sbtype='B';
    return l_prevdate;
exception when others then
return p_date;
end;

 
 
 
 
 
 
 
 
 
 
 
 
 
/
