SET DEFINE OFF;
CREATE OR REPLACE function fn_get_location(pv_brid in varchar2) return varchar2
is
begin

    return case when instr('0101,0102,0103',pv_brid)> 0 then
        'HCM'
    else
        'HN'
    end;
end;

 
 
 
 
 
 
 
 
 
 
 
 
 
/
