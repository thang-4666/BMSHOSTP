SET DEFINE OFF;
CREATE OR REPLACE PROCEDURE "PRC_HO_RECREATEJOB" IS
          v_err NVARCHAR2 (300);
          v_jobid   NUMBER;
          v_Count NUMBER;

-- PURPOSE: RECREATE JOBS PROCESS MESSAGE HOSE
-- MODIFICATION HISTORY
-- PERSON      DATE    COMMENTS
-- QUYETKD   21-JAN-12 CREATED

BEGIN
        -- dung tat ca cac tien trinh xu ly message
        update ordersys set sysvalue='N' where sysname in('ISPROCESS','PROCESSINGPRS','PROCESSINGCTCI');
        commit;

----===================================**************==========================================
   BEGIN
   Select count(*) into v_Count from  user_scheduler_jobs where  Upper(job_name) like '%PRC_PROCESS_HO_CTCI_SCHEDULER%';

        If v_Count=0 then

            DBMS_SCHEDULER.CREATE_JOB (
                     job_name         =>  'PRC_PROCESS_HO_CTCI_SCHEDULER',
                     job_type           =>  'PLSQL_BLOCK',
                     job_action       =>  'BEGIN PRC_PROCESS_HO_CTCI(); END;',
                     start_date       =>  sysdate,
                     repeat_interval  =>  'freq=SECONDLY;interval=10',
                     enabled           => TRUE,
                     comments         => 'Job PRC_PROCESS_HO_CTCI.',
                     job_class =>'FSS_DEFAULT_JOB_CLASS');
             --------------
             COMMIT;

        else

             DBMS_SCHEDULER.DISABLE(name => 'PRC_PROCESS_HO_CTCI_SCHEDULER', force =>  true);
             DBMS_SCHEDULER.DROP_JOB(job_name => 'PRC_PROCESS_HO_CTCI_SCHEDULER', force =>  true);

             commit;

             DBMS_SCHEDULER.CREATE_JOB (
                     job_name         =>  'PRC_PROCESS_HO_CTCI_SCHEDULER',
                     job_type           =>  'PLSQL_BLOCK',
                     job_action       =>  'BEGIN PRC_PROCESS_HO_CTCI(); END;',
                     start_date       =>  sysdate,
                     repeat_interval  =>  'freq=SECONDLY;interval=10',
                     enabled           => TRUE,
                     comments         => 'Job PRC_PROCESS_HO_CTCI.',
                     job_class =>'FSS_DEFAULT_JOB_CLASS');
              --------------
              COMMIT;
        End if;

    EXCEPTION WHEN OTHERS THEN
        v_err := SUBSTR ('PRC_PROCESS_HO_CTCI_SCHEDULER' || SQLERRM, 1, 200);
        INSERT INTO log_err
                  (id,date_log, POSITION, text)
        VALUES ( seq_log_err.NEXTVAL,SYSDATE, 'PRC_HO_RECREATEJOB',v_err);
    END;

----====================================@@@@@@@@@@@@@@@@@=========================================


----===================================**************==========================================
    BEGIN
   Select count(*) into v_Count from  user_scheduler_jobs where  Upper(job_name) like '%PRC_PROCESS_HO_PRS_SCHEDULER%';

        If v_Count=0 then

             DBMS_SCHEDULER.CREATE_JOB (
                     job_name         =>  'PRC_PROCESS_HO_PRS_SCHEDULER',
                     job_type           =>  'PLSQL_BLOCK',
                     job_action       =>  'BEGIN PRC_PROCESS_HO_PRS(); END;',
                     start_date       =>  sysdate,
                     repeat_interval  =>  'freq=SECONDLY;interval=10',
                     enabled           => TRUE,
                     comments         => 'Job PRC_PROCESS_HO_PRS.',
                     job_class =>'FSS_DEFAULT_JOB_CLASS');
             --------------
             COMMIT;

        else

             DBMS_SCHEDULER.DISABLE(name => 'PRC_PROCESS_HO_PRS_SCHEDULER', force =>  true);
             DBMS_SCHEDULER.DROP_JOB(job_name => 'PRC_PROCESS_HO_PRS_SCHEDULER', force =>  true);

             commit;

              DBMS_SCHEDULER.CREATE_JOB (
                     job_name         =>  'PRC_PROCESS_HO_PRS_SCHEDULER',
                     job_type           =>  'PLSQL_BLOCK',
                     job_action       =>  'BEGIN PRC_PROCESS_HO_PRS(); END;',
                     start_date       =>  sysdate,
                     repeat_interval  =>  'freq=SECONDLY;interval=10',
                     enabled           => TRUE,
                     comments         => 'Job PRC_PROCESS_HO_PRS.',
                     job_class =>'FSS_DEFAULT_JOB_CLASS');
              --------------
              COMMIT;
        End if;

    EXCEPTION WHEN OTHERS THEN
        v_err := SUBSTR ('PRC_PROCESS_HO_PRS_SCHEDULER' || SQLERRM, 1, 200);
        INSERT INTO log_err
                  (id,date_log, POSITION, text)
        VALUES ( seq_log_err.NEXTVAL,SYSDATE, 'PRC_HO_RECREATEJOB',v_err);
    END;
----====================================@@@@@@@@@@@@@@@@@=========================================
 END;

 
 
 
 
/
