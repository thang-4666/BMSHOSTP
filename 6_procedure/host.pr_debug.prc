SET DEFINE OFF;
CREATE OR REPLACE PROCEDURE "PR_DEBUG" (p_errmsg varchar2, p_logdetail varchar2) is
v_debug char;
begin
select varvalue into v_debug from sysvar where varname = 'DEBUG' and grname = 'GATEWAY';
if v_debug = 'Y' then
    insert into errors values (seq_errors.nextval, p_errmsg, p_logdetail, systimestamp);
end if;
end;

 
 
 
 
/
