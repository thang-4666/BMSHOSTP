SET DEFINE OFF;
CREATE OR REPLACE PROCEDURE sp_jobs_check_per_hours
IS
l_hour varchar2(30);
p_err_code varchar2(100);
BEGIN

select TO_CHAR(SYSDATE,'hh.AM') into l_hour from dual;

     --if l_hour = '04.PM' then
     nmpks_ems.CheckKLCuoiNgay();
    -- end if ;

commit;

EXCEPTION
   WHEN OTHERS  THEN
   ROLLBACK;
   RETURN;
 RETURN;
END;

 
 
 
 
/
