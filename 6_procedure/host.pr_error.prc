SET DEFINE OFF;
CREATE OR REPLACE PROCEDURE "PR_ERROR" (p_errmsg varchar2, p_logdetail varchar2) is
begin
    insert into errors values (seq_errors.nextval, p_errmsg, p_logdetail, systimestamp);
end;

 
 
 
 
/
