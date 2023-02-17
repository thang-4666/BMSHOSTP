SET DEFINE OFF;
CREATE OR REPLACE PROCEDURE pr_lockaccountdirect(p_acctno varchar2, p_apptype  varchar2, p_err_code in out varchar2)
is
begin
    if length(nvl(p_acctno,''))>0 then
        insert into accupdate (acctno,updatetype,createdate)
        values (p_acctno, p_apptype, SYSTIMESTAMP);
    end if;
exception when others then
    p_err_code:='-100200';
end;
 
 
 
 
/
