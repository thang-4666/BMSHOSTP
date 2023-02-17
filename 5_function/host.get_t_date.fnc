SET DEFINE OFF;
CREATE OR REPLACE FUNCTION get_t_date (f_indate date, cldrday number)
return date
-------------------------------------------------
-----Lay ngay truoc ngay f_indate la cldrday ngay
-------------------------------------------------
is
    v_tdate date;
begin
 /*  select sbdate into v_tdate from (select rownum a,SBDATE from (
        select * from sbcldr where sbdate<=f_indate and holiday='N' and cldrtype='000' order by SBDATE desc
        )) where a=cldrday+1;
    return v_tdate;*/
    -- SUA THEO CACH CUA GIANHVG -- 12-MAR-2012
   select sbdate into v_tdate from sbcurrdate where numday=(
        select numday from sbcurrdate
        where sbdate= f_indate and sbtype='B'
        ) - cldrday
    and sbtype='B';
    return v_tdate;
exception
when others then
return f_indate;
end;
 
 
 
 
 
 
 
 
 
 
 
 
 
/
