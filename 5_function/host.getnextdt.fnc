SET DEFINE OFF;
CREATE OR REPLACE FUNCTION getnextdt (f_indate date)
return date
-------------------------------------------------
-----Lay ngay lam viec tiep theo-----------------
-------------------------------------------------
is
    v_nextwrkdate date;
begin
    select min(sbdate) into v_nextwrkdate from sbcldr where sbdate>=f_indate and holiday='N' and cldrtype='000';
    return v_nextwrkdate;
exception
when others then
return f_indate;
end;
 
 
 
 
 
 
 
 
 
 
 
/
