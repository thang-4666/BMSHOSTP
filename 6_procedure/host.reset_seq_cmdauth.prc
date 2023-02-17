SET DEFINE OFF;
CREATE OR REPLACE PROCEDURE "RESET_SEQ_CMDAUTH" (v_resetno number) is
      v_inc number;
      v_dummy number;
  begin
    select -(seq_cmdauth.nextval-v_resetno)-1 into v_inc from dual;
    execute immediate 'alter sequence seq_cmdauth increment by '||v_inc;
    select seq_cmdauth.nextval into v_dummy from dual;
    execute immediate 'alter sequence seq_cmdauth increment by 1';
end;

 
 
 
 
/
