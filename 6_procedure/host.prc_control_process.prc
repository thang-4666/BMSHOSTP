SET DEFINE OFF;
CREATE OR REPLACE PROCEDURE "PRC_CONTROL_PROCESS" is
        CURSOR c_job
          IS SELECT job, what, INTERVAL
              FROM user_jobs
              where what in ('PRC_FO2BO;','PRC_OL_PROCESS;');
          v_job     c_job%ROWTYPE;
          v_jobid   NUMBER;
begin
    if (sysdate > trunc(sysdate) + 20/24) and    (sysdate < trunc(sysdate) + 22/24)then
              update ordersys set sysvalue='N' where sysname in('ISPROCESSOL','PROCESSINGOL','ISSENDFO2BO','SENDINGFO2BO');
              commit;

     end if;

     if (sysdate > trunc(sysdate) + 6/24) and    (sysdate < trunc(sysdate) + 8/24)then
        /* update ordersys set sysvalue='N' where sysname in('ISPROCESSOL','PROCESSINGOL','ISSENDFO2BO','SENDINGFO2BO');
        commit;
        FOR v_job IN c_job
          LOOP
             DBMS_JOB.remove (v_job.job);
             DBMS_JOB.submit (v_jobid, v_job.what, SYSDATE, v_job.INTERVAL);
          END LOOP;
          COMMIT;
          */
           update ordersys set sysvalue='Y' where sysname in('ISPROCESSOL','ISSENDFO2BO');
         commit;
     end if;
end;

 
 
 
 
/
