SET DEFINE OFF;
CREATE OR REPLACE PROCEDURE stop_jobs_hose is

  pkgctx     plog.log_ctx;
  logrow     tlogdebug%ROWTYPE;

/*  job_is_running exception;
  PRAGMA EXCEPTION_INIT(job_is_running, -27366);*/
begin
for rec in
(
    select * from user_scheduler_JOBS
    where Upper(job_name) like '%PRC_PROCESS_HO_CTCI_SCHEDULER%' 
    or Upper(job_name) like '%PRC_PROCESS_HO_PRS_SCHEDULER%'
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
  plog.setendsection(pkgctx, 'stop_all_hose');
end stop_jobs_hose;
 
 
/
