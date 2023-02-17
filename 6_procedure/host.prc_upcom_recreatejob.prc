SET DEFINE OFF;
CREATE OR REPLACE PROCEDURE "PRC_UPCOM_RECREATEJOB" IS

 CURSOR c_job

          IS
            SELECT job, what, INTERVAL
            FROM user_jobs where what in('PRC_PROCESS_UPCOM;','PRC_PROCESS_UPCOM_8;');

          v_job     c_job%ROWTYPE;

          v_jobid   NUMBER;

       BEGIN

        update ordersys_upcom set sysvalue='N' where sysname in('ISPROCESS','PROCESSING','PROCESSING8');

        commit;

        FOR v_job IN c_job

          LOOP

             DBMS_JOB.remove (v_job.job);

             DBMS_JOB.submit (v_jobid, v_job.what, SYSDATE, v_job.INTERVAL);

          END LOOP;

          COMMIT;

           update ordersys_upcom set sysvalue='Y' where sysname in('ISPROCESS');

         commit;

       EXCEPTION

          WHEN OTHERS

          THEN

             ROLLBACK;

       END;

 
 
 
 
/
