SET DEFINE OFF;
CREATE OR REPLACE PROCEDURE PRC_PROCESS_HO is

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
    Where SYSNAME ='PROCESSING';
  Exception 
    When others then
      v_Process:='N';
  End;

  If v_Process='N' Then

    Update Ordersys
       Set SYSVALUE ='Y'
     Where SYSNAME ='PROCESSING';
    COMMIT;
    While v_IsProcess ='Y'
    Loop
      PCK_HOGW.PRC_PROCESS;
      --DBMS_LOCK.sleep(0.1);
      Begin
          Select SYSVALUE Into v_IsProcess From Ordersys
          Where SYSNAME ='ISPROCESS';
          if v_IsProcess='Y' THEN
            Select DECODE(count(1),0,'N','Y') into v_IsProcess
            From MSGRECEIVETEMP
            WHERE PROCESS ='N';
           end if;
      Exception 
        When others then
          v_IsProcess:='N';
      End;
    End loop;
    Update Ordersys
    Set SYSVALUE ='N'
    Where SYSNAME ='PROCESSING';
    COMMIT;
  End if;

EXCEPTION
  WHEN OTHERS THEN
    UPDATE Ordersys
    Set SYSVALUE ='N'
    Where SYSNAME ='PROCESSING';
    commit;
END prc_process_ho;
/
