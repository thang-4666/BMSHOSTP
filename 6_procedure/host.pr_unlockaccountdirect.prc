SET DEFINE OFF;
CREATE OR REPLACE PROCEDURE pr_unlockaccountdirect(p_acctno varchar2, p_apptype  varchar2)
is
begin
    delete from accupdate where acctno= p_acctno and updatetype = p_apptype;

exception when others then
    null;
end;

 
 
 
 
/
