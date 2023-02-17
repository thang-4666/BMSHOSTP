SET DEFINE OFF;
CREATE OR REPLACE PROCEDURE "PRC_ANALYZE_TABLE"
IS
 v_strSQL VARCHAR2(200);
 v_err varchar2(150);
 v_Sql1 varchar2(200);
 v_Sql2 varchar2(1000);
 v_count number(10);

BEGIN

--If (to_char(sysdate,'hh24mi') > '0100' and  to_char(sysdate,'hh24mi') < '0230') then

    Select count(*) into v_count from user_sequences where sequence_name like '%ORDERMAP%';
    if v_count >0 Then
     v_Sql1:='DROP SEQUENCE seq_ordermap';
     Execute immediate v_Sql1;
    End if;
     v_Sql2:='CREATE SEQUENCE seq_ordermap
      INCREMENT BY 1
      START WITH 1
      MINVALUE 1
      MAXVALUE 999999999999999999999999999
      NOCYCLE
      NOORDER
      CACHE 300';
     Execute immediate v_Sql2;

   INSERT INTO log_err
                      (id,date_log, POSITION, text
                      )
               VALUES ( seq_log_err.NEXTVAL,SYSDATE, ' ANALYZE TABLE: ', ' CREATE SEQUENCE '
                      );
        Commit;

--End if;
Exception when others then
    v_err:=substr(sqlerrm,1,150);
    INSERT INTO log_err
                      (id,date_log, POSITION, text
                      )
               VALUES ( seq_log_err.NEXTVAL,SYSDATE, ' CREATE SEQUENCE : ',v_err
                      );
        Commit;
End;

 
 
 
 
/
