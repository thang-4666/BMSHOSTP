SET DEFINE OFF;
CREATE OR REPLACE PROCEDURE start_jobs_hose is
  pkgctx     plog.log_ctx;
  logrow     tlogdebug%ROWTYPE;

/*  job_is_running exception;
  PRAGMA EXCEPTION_INIT(job_is_running, -27366);*/
begin

    for rec in
    (
        select * from user_scheduler_jobs
        where Upper(job_name) like '%PRC_PROCESS_HO_CTCI_SCHEDULER%' 
        or Upper(job_name) like '%PRC_PROCESS_HO_PRS_SCHEDULER%'
    )
    loop

      begin
      plog.error(pkgctx, 'Enable ' || rec.job_name);
      dbms_scheduler.enable(name => rec.job_name);
      exception when others then
            plog.error(pkgctx, sqlerrm);
      end;

    end loop;
  plog.setendsection(pkgctx, 'Startjobs');
end start_jobs_hose;
 
 
/
