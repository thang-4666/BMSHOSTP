SET DEFINE OFF;
CREATE OR REPLACE FUNCTION fn_check_after_batch
return number
is
    v_count number;
begin
    --return 0;
    begin
        select count(*) into v_count from sbbatchsts sts, sysvar sys
        where sts.bchdate = to_date(sys.varvalue,'dd/mm/rrrr') and sys.grname ='SYSTEM' and sys.varname='CURRDATE'
        and sts.bchsts='Y';
    exception when others then
        v_count:=0;
    end;
    if v_count>=1 then
        return 1;
    else
        return 0;
    end if;
exception when others then
    return 0;
end; 
 
 
 
 
 
 
/
