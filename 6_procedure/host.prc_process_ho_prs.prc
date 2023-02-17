SET DEFINE OFF;
CREATE OR REPLACE PROCEDURE "PRC_PROCESS_HO_PRS" is   --V_MSGGROUP: CTCI, PRS

  v_IsProcess Varchar2(20);
  v_Process Varchar2(20);
  BEGIN
      Begin
        Select SYSVALUE Into v_IsProcess From Ordersys
        Where SYSNAME ='ISPROCESS';
      Exception When others then
        v_IsProcess:='N';
      End;

      Begin
        Select SYSVALUE Into v_Process From Ordersys
        Where SYSNAME ='PROCESSINGPRS';
      Exception When others then
        v_Process:='N';
      End;

      If v_Process='N' Then

          Update Ordersys
             Set SYSVALUE ='Y'
           Where SYSNAME ='PROCESSINGPRS';
          COMMIT;
          While v_IsProcess ='Y'
          Loop
            PCK_HOGW.PRC_PROCESSMSG('PRS');
            DBMS_LOCK.sleep(0.1);
            Begin
                Select SYSVALUE Into v_IsProcess From Ordersys
                Where SYSNAME ='ISPROCESS';

            Exception When others then
                v_IsProcess:='N';
            End;
          End loop;

        Update Ordersys
        Set SYSVALUE ='N'
        Where SYSNAME ='PROCESSINGPRS';
        COMMIT;
       End if;

  EXCEPTION WHEN OTHERS THEN
     RETURN;
  END prc_process_ho_PRS;

 
 
 
 
/
