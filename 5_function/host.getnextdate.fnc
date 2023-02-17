SET DEFINE OFF;
CREATE OR REPLACE function getnextdate (f_indate varchar2)
return varchar2
-------------------------------------------------
-----Lay ngay lam viec tiep theo-----------------
-------------------------------------------------
is
    v_nextwrkdate varchar2(10);
begin
    select to_char(min(sbdate),'DD/MM/RRRR') into v_nextwrkdate from sbcldr where sbdate>to_date(f_indate,'DD/MM/RRRR') and holiday='N' and cldrtype='000';
    return v_nextwrkdate;
exception
when others then
return f_indate;
end;
 
 
 
 
 
 
 
 
 
 
 
/
