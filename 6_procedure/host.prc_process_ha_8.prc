SET DEFINE OFF;
CREATE OR REPLACE PROCEDURE prc_process_ha_8 is

  v_IsProcess Varchar2(20);
  v_Process Varchar2(20);
BEGIN
    Begin
      Select SYSVALUE Into v_IsProcess From Ordersys_ha
      Where SYSNAME ='ISPROCESS';
    Exception 
      When others then
        v_IsProcess:='N';
    End;
      
    Begin
      Select SYSVALUE Into v_Process From Ordersys_ha
      Where SYSNAME ='PROCESSING8';
    Exception 
      When others then
        v_Process:='N';
    End;
      
    If v_Process='N' Then

        Update Ordersys_ha
           Set SYSVALUE ='Y'
         Where SYSNAME ='PROCESSING8';
        COMMIT;
        While v_IsProcess ='Y'
        Loop
          PCK_HAGW.Prc_ProcessMsg;
          --DBMS_LOCK.sleep(0.1);
          Begin
              Select SYSVALUE Into v_IsProcess From Ordersys_ha
              Where SYSNAME ='ISPROCESS';
              if v_IsProcess='Y' THEN
                Select DECODE(count(1),0,'N','Y') into v_IsProcess
                From Exec_8_Ha
                WHERE PROCESS ='N';
              end if;
          Exception 
            When others then
              v_IsProcess:='N';
          End;
        End loop;
          
      Update Ordersys_ha
      Set SYSVALUE ='N'
      Where SYSNAME ='PROCESSING8';
      COMMIT;
    End if;

EXCEPTION 
  WHEN OTHERS THEN
    Update Ordersys_ha
    Set SYSVALUE ='N'
    Where SYSNAME ='PROCESSING8';
    COMMIT;
END prc_process_ha_8;
/
