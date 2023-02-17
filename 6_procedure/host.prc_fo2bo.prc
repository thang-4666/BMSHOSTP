SET DEFINE OFF;
CREATE OR REPLACE PROCEDURE "PRC_FO2BO" is   --V_MSGGROUP: CTCI, PRS

  v_IsProcess Varchar2(20);
  v_Process Varchar2(20);
  BEGIN
      Begin
        Select SYSVALUE Into v_IsProcess From Ordersys
        Where SYSNAME ='ISSENDFO2BO';
      Exception When others then
        v_IsProcess:='N';
      End;

      Begin
        Select SYSVALUE Into v_Process From Ordersys
        Where SYSNAME ='SENDINGFO2BO';
      Exception When others then
        v_Process:='N';
      End;

      If v_Process='N' Then

          Update Ordersys
             Set SYSVALUE ='Y'
           Where SYSNAME ='SENDINGFO2BO';
          COMMIT;
          While v_IsProcess ='Y'
          Loop
            txpks_auto.pr_fo2od;
            DBMS_LOCK.sleep(0.1);
            Begin
                Select SYSVALUE Into v_IsProcess From Ordersys
                Where SYSNAME ='ISSENDFO2BO';

            Exception When others then
                v_IsProcess:='N';
            End;
          End loop;
        Update Ordersys
        Set SYSVALUE ='N'
        Where SYSNAME ='SENDINGFO2BO';
        COMMIT;
      End if;

  EXCEPTION WHEN OTHERS THEN
     RETURN;
  END prc_fo2bo;

 
 
 
 
/
