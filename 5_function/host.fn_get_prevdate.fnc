SET DEFINE OFF;
CREATE OR REPLACE FUNCTION fn_get_prevdate(p_date date, p_prevnum number)
return date
is
    l_prevdate date;
BEGIN
    -- HAM THUC HIEN LAY NGAY GD TRUOC NGAY HIEN TAI p_prevnum NGAY
    -- DUNG CHO CAC HAM CUA THENN, :D
    /*select min(sbdate)
        into l_prevdate
    from (
             select sb.sbdate from sbcldr sb
             where sb.cldrtype = '000' and sb.holiday = 'N' and sb.sbdate < p_date
             order by sb.sbdate desc)
     where rownum <= p_prevnum;
     return l_prevdate;*/

     -- SUA THEO CACH CUA GIANHVG -- 12-MAR-2012
     select sbdate into l_prevdate from sbcurrdate where numday=(
        select min(numday) from sbcurrdate
        where sbdate >= p_date and sbtype='B'
        ) - p_prevnum
    and sbtype='B';
    return l_prevdate;
exception when others then
return p_date;
end;
 
 
 
/
