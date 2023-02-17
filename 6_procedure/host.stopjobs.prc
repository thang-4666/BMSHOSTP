SET DEFINE OFF;
CREATE OR REPLACE PROCEDURE "STOPJOBS" is

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

  pkgctx := plog.init('Stopjobs',

                      plevel => logrow.loglevel,

                      plogtable => (logrow.log4table = 'Y'),

                      palert => (logrow.log4alert = 'Y'),

                      ptrace => (logrow.log4trace = 'Y'));

  plog.setbeginsection(pkgctx, 'Stopjobs');

  plog.error(pkgctx, 'Init Stopjobs');

  UPDATE SYSVAR SET VARVALUE = 'N' WHERE GRNAME='SYSTEM' AND VARNAME='GXJBS_STATUS';
  COMMIT;

  begin
    BEGIN
    plog.error(pkgctx, 'STOP GXJBS_#EXECUTE_FO2OD');
    dbms_scheduler.stop_job(job_name => 'GXJBS_#EXECUTE_FO2OD', force =>  true);
    dbms_scheduler.disable(name => 'GXJBS_#EXECUTE_FO2OD', force =>  true);
    EXCEPTION WHEN OTHERS THEN
        plog.error(pkgctx, sqlerrm);
        plog.error(pkgctx, 'Disable GXJBS_#EXECUTE_FO2OD');
        dbms_scheduler.disable(name => 'GXJBS_#EXECUTE_FO2OD', force =>  true);
    END;

    BEGIN
    plog.error(pkgctx, 'STOP GTWJBS_#STRADE_CI');
    dbms_scheduler.stop_job(job_name => 'GTWJBS_#STRADE_CI', force =>  true);
    dbms_scheduler.disable(name => 'GTWJBS_#STRADE_CI', force =>  true);
    EXCEPTION WHEN OTHERS THEN
        plog.error(pkgctx, sqlerrm);
        plog.error(pkgctx, 'Disable GTWJBS_#STRADE_CI');
        dbms_scheduler.disable(name => 'GTWJBS_#STRADE_CI', force =>  true);
    END;

    BEGIN
    plog.error(pkgctx, 'STOP GTWJBS_#STRADE_SE');
    dbms_scheduler.stop_job(job_name => 'GTWJBS_#STRADE_SE', force =>  true);
    dbms_scheduler.disable(name => 'GTWJBS_#STRADE_SE', force =>  true);
    EXCEPTION WHEN OTHERS THEN
        plog.error(pkgctx, sqlerrm);
        plog.error(pkgctx, 'Disable GTWJBS_#STRADE_SE');
        dbms_scheduler.disable(name => 'GTWJBS_#STRADE_SE', force =>  true);
    END;

    BEGIN
    plog.error(pkgctx, 'STOP GXJBS_#CANCEL_ORDER');
    dbms_scheduler.stop_job(job_name => 'GXJBS_#CANCEL_ORDER', force =>  true);
    dbms_scheduler.disable(name => 'GXJBS_#CANCEL_ORDER', force =>  true);
    EXCEPTION WHEN OTHERS THEN
        plog.error(pkgctx, sqlerrm);
        plog.error(pkgctx, 'Disable GXJBS_#CANCEL_ORDER');
         dbms_scheduler.disable(name => 'GXJBS_#CANCEL_ORDER', force =>  true);
    END;

    BEGIN
    plog.error(pkgctx, 'STOP GXJBS_#EXECUTE_TRADE');
    dbms_scheduler.stop_job(job_name => 'GXJBS_#EXECUTE_TRADE', force =>  true);
    dbms_scheduler.disable(name => 'GXJBS_#EXECUTE_TRADE', force =>  true);
    EXCEPTION WHEN OTHERS THEN
        plog.error(pkgctx, sqlerrm);
        plog.error(pkgctx, 'Disable GXJBS_#EXECUTE_TRADE');
        dbms_scheduler.disable(name => 'GXJBS_#EXECUTE_TRADE', force =>  true);
    END;
  exception
    when job_is_running then
         plog.error(pkgctx, 'Disable GXJBS_#EXECUTE_FO2OD');
         dbms_scheduler.disable(name => 'GXJBS_#EXECUTE_FO2OD', force =>  true);
         plog.error(pkgctx, 'Disable GXJBS_#CANCEL_ORDER');
         dbms_scheduler.disable(name => 'GXJBS_#CANCEL_ORDER', force =>  true);
         plog.error(pkgctx, 'Disable GXJBS_#EXECUTE_TRADE');
         dbms_scheduler.disable(name => 'GXJBS_#EXECUTE_TRADE', force =>  true);
    when others then
        plog.error(pkgctx, sqlerrm);
  end;

  plog.setendsection(pkgctx, 'Stopjobs');

end stopjobs;

 
 
 
 
/
