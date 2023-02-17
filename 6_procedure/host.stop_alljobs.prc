SET DEFINE OFF;
CREATE OR REPLACE PROCEDURE stop_alljobs is

  pkgctx     plog.log_ctx;
  logrow     tlogdebug%ROWTYPE;

  job_is_running exception;
  PRAGMA EXCEPTION_INIT(job_is_running, -27366);
begin

  --Init log
  SELECT *
    INTO logrow
    FROM tlogdebug
   WHERE rownum <= 1;

  pkgctx := plog.init('stop_alljobs',

                      plevel => logrow.loglevel,

                      plogtable => (logrow.log4table = 'Y'),

                      palert => (logrow.log4alert = 'Y'),

                      ptrace => (logrow.log4trace = 'Y'));

  plog.setbeginsection(pkgctx, 'stop_alljobs');

  plog.error(pkgctx, 'Init stop_alljobs');
for rec in
(
select * from user_scheduler_JOBS
)
loop

    BEGIN
    plog.error(pkgctx, 'STOP ' || rec.job_name);
    dbms_scheduler.stop_job(job_name => rec.job_name, force =>  true);
    dbms_scheduler.disable(name => rec.job_name, force =>  true);
    EXCEPTION WHEN OTHERS THEN
        plog.error(pkgctx, sqlerrm);
        plog.error(pkgctx, 'Disable ' || rec.job_name);
        dbms_scheduler.disable(name => rec.job_name, force =>  true);
    END;

end loop;
  plog.setendsection(pkgctx, 'stop_alljobs');

end stop_alljobs;
 
 
 
 
/
