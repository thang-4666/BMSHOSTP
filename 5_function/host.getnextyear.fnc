SET DEFINE OFF;
CREATE OR REPLACE function getnextyear (f_indate varchar2)
return varchar2
-------------------------------------------------
-----Lay 15 nam tiep theo-----------------
-------------------------------------------------
is
    v_nextwrkdate varchar2(10);
begin
 select to_char(add_months( to_date(f_indate,'dd/mm/rrrr'),180 ),'dd/mm/rrrr') into v_nextwrkdate from dual;
 return v_nextwrkdate;
exception
when others then
return f_indate;
end;

 
 
 
 
 
 
 
 
 
 
 
/
