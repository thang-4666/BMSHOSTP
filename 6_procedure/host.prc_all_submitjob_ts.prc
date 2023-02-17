SET DEFINE OFF;
CREATE OR REPLACE PROCEDURE prc_all_submitjob_ts is
 v_job integer;
 v_Count number(20);
 v_jobID integer;

begin
--Ngay 13/01/2017 NamTv bo khong dung Job nay gen bang ke tu dong nua
/*BEGIN
    DBMS_SCHEDULER.DROP_JOB (job_name         =>  'JBPKS_AUTO#GEN_RM_TRANSFER',force => true);
exception when others then
    null;
END;
    DBMS_SCHEDULER.CREATE_JOB (
    job_name         =>  'JBPKS_AUTO#GEN_RM_TRANSFER',
    job_type           =>  'STORED_PROCEDURE',
    job_action       =>  'jbpks_auto.pr_gen_rm_transfer',
    start_date       =>  sysdate,
    repeat_interval  =>  'FREQ=SECONDLY;INTERVAL=3',
    enabled           => TRUE,
    comments         => 'Process fo online order',
    job_class =>'FSS_DEFAULT_JOB_CLASS');
    -------------*/
BEGIN
                  DBMS_SCHEDULER.DROP_JOB (
                         job_name         =>  'TXPKS_AUTO#FO2ODSYNC',
                         force => true);
exception when others then
    null;
END;
                  DBMS_SCHEDULER.CREATE_JOB (
                     job_name         =>  'TXPKS_AUTO#FO2ODSYNC',
                     job_type           =>  'STORED_PROCEDURE',
                     job_action       =>  'txpks_auto.pr_fo2od',
                     start_date       =>  sysdate,
                     repeat_interval  =>  'FREQ=SECONDLY;INTERVAL=3',
                     enabled           => TRUE,
                     comments         => 'Process fo online order',
                     job_class =>'FSS_DEFAULT_JOB_CLASS');
                 -------------
BEGIN
DBMS_SCHEDULER.DROP_JOB (
                         job_name         =>  'TXPKS_AUTO#FOBANKSYNC',
                         force => true);

exception when others then
    null;
END;
                  DBMS_SCHEDULER.CREATE_JOB (
                     job_name         =>  'TXPKS_AUTO#FOBANKSYNC',
                     job_type           =>  'STORED_PROCEDURE',
                     job_action       =>  'txpks_auto.pr_fobanksyn',
                     start_date       =>  sysdate,
                     repeat_interval  =>  'FREQ=SECONDLY;INTERVAL=3',
                     enabled           => TRUE,
                     comments         => 'Process fo order gen hold request for bank account',
                     job_class =>'FSS_DEFAULT_JOB_CLASS');
                 --------------
BEGIN
DBMS_SCHEDULER.DROP_JOB (
                         job_name         =>  'TXPKS_AUTO#GTC2OD_HA',
                         force => true);
exception when others then
    null;
END;
                 DBMS_SCHEDULER.CREATE_JOB (
                     job_name         =>  'TXPKS_AUTO#GTC2OD_HA',
                     job_type           =>  'PLSQL_BLOCK',
                     job_action       =>  'begin    TXPKS_AUTO.pr_gtc2od(''GTC-HA''); end;  ',
                     start_date       =>  sysdate,
                     repeat_interval  =>  'FREQ=SECONDLY; INTERVAL=5',
                     enabled           => TRUE,
                     comments         => 'Process put GTC order from FOMAST to ODMAST',
                     job_class =>'FSS_DEFAULT_JOB_CLASS');
                 --------------
BEGIN
                 DBMS_SCHEDULER.DROP_JOB (
                         job_name         =>  'TXPKS_AUTO#GTC2OD_HO',
                         force => true);
exception when others then
    null;
END;
                 DBMS_SCHEDULER.CREATE_JOB (
                     job_name         =>  'TXPKS_AUTO#GTC2OD_HO',
                     job_type           =>  'PLSQL_BLOCK',
                     job_action       =>  'begin   TXPKS_AUTO.pr_gtc2od(''GTC-HO''); end;  ',
                     start_date       =>  sysdate,
                     repeat_interval  =>  'FREQ=SECONDLY; INTERVAL=5',
                     enabled           => TRUE,
                     comments         => 'Process put GTC order from FOMAST to ODMAST',
                     job_class =>'FSS_DEFAULT_JOB_CLASS');
                 ----------------
BEGIN
DBMS_SCHEDULER.DROP_JOB (
                         job_name         =>  'TXPKS_AUTO#ROR2BO',
                         force => true);
exception when others then
    null;
END;
                  DBMS_SCHEDULER.CREATE_JOB (
                     job_name         =>  'TXPKS_AUTO#ROR2BO',
                     job_type           =>  'STORED_PROCEDURE',
                     job_action       =>  'fopks_api.pr_RORSyn2BO',
                     start_date       =>  sysdate,
                     repeat_interval  =>  'FREQ=SECONDLY;INTERVAL=10',
                     enabled           => TRUE,
                     comments         => 'Process put Right off register after hold enough money',
                     job_class =>'FSS_DEFAULT_JOB_CLASS');
                  -----------------
BEGIN                  DBMS_SCHEDULER.DROP_JOB (
                         job_name         =>  'JBPKS_AUTO#GEN_CI_BUFFER',
                         force => true);
exception when others then
    null;
END;
                  DBMS_SCHEDULER.CREATE_JOB (
                     job_name         =>  'JBPKS_AUTO#GEN_CI_BUFFER',
                     job_type           =>  'STORED_PROCEDURE',
                     job_action       =>  'jbpks_auto.pr_gen_ci_buffer',
                     start_date       =>  sysdate,
                     repeat_interval  =>  'FREQ=SECONDLY;INTERVAL=3',
                     enabled           => TRUE,
                     comments         => 'Gen buf_ci_account job',
                     job_class =>'FSS_DEFAULT_JOB_CLASS');
                   -----------------------------
BEGIN                   DBMS_SCHEDULER.DROP_JOB (
                         job_name         =>  'JBPKS_AUTO#GEN_OD_BUFFER',
                         force => true);
exception when others then
    null;
END;
                   DBMS_SCHEDULER.CREATE_JOB (
                     job_name         =>  'JBPKS_AUTO#GEN_OD_BUFFER',
                     job_type           =>  'STORED_PROCEDURE',
                     job_action       =>  'jbpks_auto.pr_gen_od_buffer',
                     start_date       =>  sysdate,
                     repeat_interval  =>  'FREQ=SECONDLY;INTERVAL=3',
                     enabled           => TRUE,
                     comments         => 'Gen buf_od_account job',
                     job_class =>'FSS_DEFAULT_JOB_CLASS');
                   -------------------------------
BEGIN                   DBMS_SCHEDULER.DROP_JOB (
                         job_name         =>  'JBPKS_AUTO#GEN_SE_BUFFER',
                         force => true);
exception when others then
    null;
END;
                   DBMS_SCHEDULER.CREATE_JOB (
                     job_name         =>  'JBPKS_AUTO#GEN_SE_BUFFER',
                     job_type           =>  'STORED_PROCEDURE',
                     job_action       =>  'jbpks_auto.pr_gen_se_buffer',
                     start_date       =>  sysdate,
                     repeat_interval  =>  'FREQ=SECONDLY;INTERVAL=3',
                     enabled           => TRUE,
                     comments         => 'Gen buf_se_account job',
                     job_class =>'FSS_DEFAULT_JOB_CLASS');
                   -------------------------------
BEGIN                   DBMS_SCHEDULER.DROP_JOB (
                         job_name         =>  'PRC_PROCESS_HA_8_SCHEDULER',
                         force => true);
exception when others then
    null;
END;
                   DBMS_SCHEDULER.CREATE_JOB (
                     job_name         =>  'PRC_PROCESS_HA_8_SCHEDULER',
                     job_type           =>  'PLSQL_BLOCK',
                     job_action       =>  'BEGIN PRC_PROCESS_HA_8(); END;',
                     start_date       =>  sysdate,
                     repeat_interval  =>  'freq=SECONDLY;interval=20',
                     enabled           => TRUE,
                     comments         => 'Job PRC_PROCESS_HA_8.',
                     job_class =>'FSS_DEFAULT_JOB_CLASS');
                    -----------------------------------
BEGIN                    DBMS_SCHEDULER.DROP_JOB (
                         job_name         =>  'PRC_PROCESS_HA_SCHEDULER',
                         force => true);
exception when others then
    null;
END;
                    DBMS_SCHEDULER.CREATE_JOB (
                     job_name         =>  'PRC_PROCESS_HA_SCHEDULER',
                     job_type           =>  'PLSQL_BLOCK',
                     job_action       =>  'BEGIN PRC_PROCESS_HA(); END;',
                     start_date       =>  sysdate,
                     repeat_interval  =>  'freq=SECONDLY;interval=20',
                     enabled           => TRUE,
                     comments         => 'Job PRC_PROCESS_HA.',
                     job_class =>'FSS_DEFAULT_JOB_CLASS');
                    -------------------------------
BEGIN                    DBMS_SCHEDULER.DROP_JOB (
                           job_name         =>  'PRC_PROCESS_HO_CTCI_SCHEDULER',
                         force => true);
exception when others then
    null;
END;
                    DBMS_SCHEDULER.CREATE_JOB (
                     job_name         =>  'PRC_PROCESS_HO_CTCI_SCHEDULER',
                     job_type           =>  'PLSQL_BLOCK',
                     job_action       =>  'BEGIN PRC_PROCESS_HO_CTCI(); END;',
                     start_date       =>  sysdate,
                     repeat_interval  =>  'freq=SECONDLY;interval=20',
                     enabled           => TRUE,
                     comments         => 'Job PRC_PROCESS_HO_CTCI.',
                     job_class =>'FSS_DEFAULT_JOB_CLASS');
                    -------------------------------
BEGIN                     DBMS_SCHEDULER.DROP_JOB (
                         job_name         =>  'PRC_PROCESS_HO_PRS_SCHEDULER',
                         force => true);
exception when others then
    null;
END;
                     DBMS_SCHEDULER.CREATE_JOB (
                     job_name         =>  'PRC_PROCESS_HO_PRS_SCHEDULER',
                     job_type           =>  'PLSQL_BLOCK',
                     job_action       =>  'BEGIN PRC_PROCESS_HO_PRS(); END;',
                     start_date       =>  sysdate,
                     repeat_interval  =>  'freq=SECONDLY;interval=20',
                     enabled           => TRUE,
                     comments         => 'Job PRC_PROCESS_HO_PRS.',
                     job_class =>'FSS_DEFAULT_JOB_CLASS');
                    -------------------------------
BEGIN                    DBMS_SCHEDULER.DROP_JOB (
                         job_name         =>  'PCK_HAGW#PRC_PROCESSMSG_ERR',
                         force => true);
exception when others then
    null;
END;

                    DBMS_SCHEDULER.CREATE_JOB (
                     job_name         =>  'PCK_HAGW#PRC_PROCESSMSG_ERR',
                     job_type           =>  'STORED_PROCEDURE',
                     job_action       =>  'PCK_HAGW.PRC_PROCESS_ERR',
                     start_date       =>  sysdate,
                     repeat_interval  =>  'FREQ=SECONDLY;INTERVAL=60',
                     enabled           => TRUE,
                     comments         => 'PCK_HAGW#PRC_PROCESS_ERR',
                     job_class =>'FSS_DEFAULT_JOB_CLASS');


BEGIN                    DBMS_SCHEDULER.DROP_JOB (
                         job_name         =>  'PCK_HOGW#PRC_PROCESSMSG_ERR',
                         force => true);
exception when others then
    null;
END;

                    DBMS_SCHEDULER.CREATE_JOB (
                     job_name         =>  'PCK_HOGW#PRC_PROCESSMSG_ERR',
                     job_type           =>  'STORED_PROCEDURE',
                     job_action       =>  'PCK_HOGW.PRC_PROCESSMSG_ERR',
                     start_date       =>  sysdate,
                     repeat_interval  =>  'FREQ=SECONDLY;INTERVAL=60',
                     enabled           => TRUE,
                     comments         => 'PCK_HOGW#PRC_PROCESS_ERR',
                     job_class =>'FSS_DEFAULT_JOB_CLASS');
------------------------------------------------------------------------------------------------

 BEGIN                     DBMS_SCHEDULER.DROP_JOB (
                         job_name         =>  'JOBS_CHECK_PER_HOURS',
                         force => true);
exception when others then
    null;
END;
                     DBMS_SCHEDULER.CREATE_JOB (
                     job_name         =>  'JOBS_CHECK_PER_HOURS',
                     job_type           =>  'PLSQL_BLOCK',
                     job_action       =>  'BEGIN SP_JOBS_CHECK_PER_HOURS(); END;',
                     start_date       =>  sysdate,
                     --repeat_interval  =>  'freq=SECONDLY;interval=60',
                     repeat_interval  =>  'freq=HOURLY;interval=1',
                     enabled           => TRUE,
                     comments         => 'Job CHECK TASKS PER HOURS',
                     job_class =>'FSS_DEFAULT_JOB_CLASS');
                    -------------------------------
BEGIN
    DBMS_SCHEDULER.DROP_JOB (
                         job_name         =>  'JBPKS_AUTO#SECMAST_GENERATE',
                         force => true);
exception when others then
    null;
END;
                  DBMS_SCHEDULER.CREATE_JOB (
                     job_name         =>  'JBPKS_AUTO#SECMAST_GENERATE',
                     job_type           =>  'STORED_PROCEDURE',
                     job_action       =>  'jbpks_auto.pr_SECMAST_GENERATE_LOG',
                     start_date       =>  sysdate,
                     repeat_interval  =>  'FREQ=SECONDLY;INTERVAL=5',
                     enabled           => TRUE,
                     comments         => 'SECMAST_GENERATE_LOG job',
                     job_class =>'FSS_DEFAULT_JOB_CLASS');
                   -----------------------------
--Xu ly dien VSD
BEGIN
        DBMS_SCHEDULER.DROP_JOB (
                                job_name           =>  'SP_AUTO_PROCESS_MESSAGE_VSD');
exception when others then
    null;
END;
BEGIN
  DBMS_SCHEDULER.CREATE_JOB (
   job_name           =>  'SP_AUTO_PROCESS_MESSAGE_VSD',
   job_type           =>  'STORED_PROCEDURE',
   job_action         =>  'CSPKS_VSD.pr_auto_process_message',
   start_date         =>   SYSDATE,
   repeat_interval    =>  'FREQ=SECONDLY; INTERVAL=10',
   auto_drop          =>   FALSE,
   enabled             =>  TRUE,
   comments           =>  'Tu dong xu ly dien cua VSD');
END;
-----------------------------------
--Sinh yeu cau gui dien
BEGIN
      DBMS_SCHEDULER.DROP_JOB (
                            job_name           =>  'AUTO_GEN_VSD_REQ');
exception when others then
    null;
END;
BEGIN
  DBMS_SCHEDULER.CREATE_JOB (
   job_name           =>  'AUTO_GEN_VSD_REQ',
   job_type           =>  'STORED_PROCEDURE',
   job_action         =>  'CSPKS_VSD.SP_AUTO_GEN_VSD_REQ',
   start_date         =>   SYSDATE,
   repeat_interval    =>  'FREQ=SECONDLY; INTERVAL=10;', /* every 10 minute*/
   auto_drop          =>   FALSE,
   enabled             =>  TRUE,
   comments           =>  'Tu dong gui yeu cau sinh dien len VSD');
END;
 -----------------------------------------------------------------------------------------------------------------
end;
 
/
