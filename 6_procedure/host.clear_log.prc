SET DEFINE OFF;
CREATE OR REPLACE PROCEDURE clear_log
  IS
strsql varchar2(1000);
BEGIN

    -- xoa du lieu log truoc do 15 ngay


     commit;

EXCEPTION
    WHEN others THEN
    plog.error ( SQLERRM || dbms_utility.format_error_backtrace);
    Rollback;
END;
 
/
