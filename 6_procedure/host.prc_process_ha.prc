SET DEFINE OFF;
CREATE OR REPLACE PROCEDURE prc_process_ha is

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
              if v_IsProcess='Y' THEN
                Select DECODE(count(1),0,'N','Y') into v_IsProcess
                From MSGRECEIVETEMP_HA
                WHERE PROCESS ='N';
              end if;
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
  Update Ordersys_ha
      Set SYSVALUE ='N'
      Where SYSNAME ='PROCESSING';
      COMMIT;
   RETURN;
END prc_process_ha;
/
