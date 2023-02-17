SET DEFINE OFF;
CREATE OR REPLACE PROCEDURE "CHECKLOCKCARD" (
        PV_REFCURSOR IN OUT PKG_REPORT.REF_CURSOR,
        f_errnum IN number
)
  IS
  l_errnum number;

BEGIN

    l_errnum:=f_errnum;
  OPEN PV_REFCURSOR FOR
    SELECT CASE WHEN l_errnum = 1 THEN '1 - User actived'  WHEN l_errnum = -2 THEN '-2 - User locked'  ELSE ' User not exist' end status from dual;

EXCEPTION
    WHEN others THEN
    pr_error('checklockcard','Error:' || SQLERRM || dbms_utility.format_error_backtrace);
        return;
END;

 
 
 
 
/
