SET DEFINE OFF;
CREATE OR REPLACE PROCEDURE "PRC_PROCESS_HA" is

  v_IsProcess Varchar2(20);
  v_Process Varchar2(20);
  BEGIN
      Begin
        Select SYSVALUE Into v_IsProcess From Ordersys_ha
        Where SYSNAME ='ISPROCESS';
      Exception When others then
        v_IsProcess:='N';
      End;

      Begin
        Select SYSVALUE Into v_Process From Ordersys_ha
        Where SYSNAME ='PROCESSING';
      Exception When others then
        v_Process:='N';
      End;

      If v_Process='N' Then

          Update Ordersys_ha
             Set SYSVALUE ='Y'
           Where SYSNAME ='PROCESSING';
          COMMIT;
          While v_IsProcess ='Y'
          Loop
            PCK_HAGW.PRC_PROCESS;
            DBMS_LOCK.sleep(0.1);
            Begin
                Select SYSVALUE Into v_IsProcess From Ordersys_ha
                Where SYSNAME ='ISPROCESS';

            Exception When others then
                v_IsProcess:='N';
            End;
          End loop;
        Update Ordersys_ha
        Set SYSVALUE ='N'
        Where SYSNAME ='PROCESSING';
        COMMIT;
      End if;

  EXCEPTION WHEN OTHERS THEN
     RETURN;
  END prc_process_ha;

 
 
 
 
/
