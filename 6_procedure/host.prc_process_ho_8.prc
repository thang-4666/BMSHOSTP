SET DEFINE OFF;
CREATE OR REPLACE PROCEDURE PRC_PROCESS_HO_8 is

  v_IsProcess Varchar2(20);
  v_Process Varchar2(20);
BEGIN
    Begin
      Select SYSVALUE Into v_IsProcess From Ordersys
      Where SYSNAME ='ISPROCESS';
    Exception 
      When others then
        v_IsProcess:='N';
    End;

    Begin
      Select SYSVALUE Into v_Process From Ordersys
      Where SYSNAME ='PROCESSING8';
    Exception 
      When others then
        v_Process:='N';
    End;

    If v_Process='N' Then

        Update ordersys
           Set SYSVALUE ='Y'
         Where SYSNAME ='PROCESSING8';
        COMMIT;
        While v_IsProcess ='Y'
        Loop
          PCK_HOGW.Prc_ProcessMsg;
          DBMS_LOCK.sleep(0.1);
          Begin
              Select SYSVALUE Into v_IsProcess From Ordersys
              Where SYSNAME ='ISPROCESS';
              if v_IsProcess='Y' THEN
                Select DECODE(count(1),0,'N','Y') into v_IsProcess
                 From Exec_8
                Where Process  ='N';
              end if;
          Exception 
             When others then
              v_IsProcess:='N';
          End;
        End loop;

      Update ordersys
      Set SYSVALUE ='N'
      Where SYSNAME ='PROCESSING8';
      COMMIT;
    End if;

EXCEPTION 
  WHEN OTHERS THEN
    Update ordersys
    Set SYSVALUE ='N'
    Where SYSNAME ='PROCESSING8';
    commit;
END PRC_PROCESS_HO_8;
/
