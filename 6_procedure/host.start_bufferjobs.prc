SET DEFINE OFF;
CREATE OR REPLACE PROCEDURE start_bufferjobs is
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

  pkgctx := plog.init('Startjobs',

                      plevel => logrow.loglevel,

                      plogtable => (logrow.log4table = 'Y'),

                      palert => (logrow.log4alert = 'Y'),

                      ptrace => (logrow.log4trace = 'Y'));

  plog.setbeginsection(pkgctx, 'Startjobs');

  plog.error(pkgctx, 'Init Startjobs');

for rec in
(
    select job_name, next_run_date, job_type, job_action, enabled, state, start_date, end_date, repeat_interval, job_creator 
    from user_scheduler_JOBS
    where job_name in ('JBPKS_AUTO#GEN_SE_BUFFER','JBPKS_AUTO#GEN_CI_BUFFER','JBPKS_AUTO#GEN_OD_BUFFER','JBPKS_AUTO#MARKEDAFPRALLOC') 
)
loop

  begin
  plog.error(pkgctx, 'Enable ' || rec.job_name);
  dbms_scheduler.enable(name => rec.job_name);
  exception when others then
        plog.error(pkgctx, sqlerrm);
  end;

end loop;

  plog.setendsection(pkgctx, 'start_bufferjobs');
end start_bufferjobs;
 
 
 
 
/
