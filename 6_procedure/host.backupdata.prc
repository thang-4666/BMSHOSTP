SET DEFINE OFF;
CREATE OR REPLACE PROCEDURE "BACKUPDATA" (indate IN VARCHAR2)
  IS

 v_strSYSVAR    varchar2(100);
 v_strCURRDATE  varchar2(100);
 v_strPREVDATE  varchar2(100);
 v_strNEXTDATE  varchar2(100);
 v_strDUEDATE   varchar2(100);

 v_strFRTABLE   varchar2(100);
 v_strTOTABLE   varchar2(100);
 v_strSQL       varchar2(2000);
 v_Sql1 varchar2(1000);
 v_Sql2 varchar2(1000);
 v_err          varchar2(200);
 v_count number(10);
BEGIN

    select varvalue into v_strCURRDATE from sysvar where grname='SYSTEM' and varname ='CURRDATE';
    select varvalue into v_strNEXTDATE from sysvar where grname='SYSTEM' and varname ='NEXTDATE';
    --Cap nhat thong tin chung khoan cuoi ngay.
    ---UPDATE SEMAST SET PREVQTTY=TRADE+MORTAGE+MARGIN+SECURED+BLOCKED+WITHDRAW+RECEIVING WHERE STATUS<>'C';
    --Hien thuc hoa lai/lo khi danh muc het chung khoan.
    /*UPDATE SEMAST SET ACCUMULATEPNL=ACCUMULATEPNL + TOTALSELLAMT-TOTALBUYAMT,TOTALSELLAMT=0,TOTALBUYAMT=0,COSTPRICE=0
    WHERE PREVQTTY=0;*/
    commit;
    --'Xoa cac bang __TRAN cua cac phan he nghiep vu
    for rec in (
        SELECT FRTABLE, TOTABLE FROM TBLBACKUP WHERE TYPBK='T'
    )
    loop
        v_strFRTABLE:=rec.FRTABLE;
        v_strTOTABLE:=rec.TOTABLE;
        v_strSQL := 'INSERT INTO ' || v_strTOTABLE || ' SELECT DTL.* FROM ' || v_strFRTABLE ||
                ' DTL, TLLOG, TLTX
                 WHERE TLLOG.TLTXCD=TLTX.TLTXCD AND TRIM(TLTX.BACKUP)=''Y''
                 AND TLLOG.TXNUM=DTL.TXNUM AND TLLOG.TXDATE=DTL.TXDATE
                 AND (TRIM(TLLOG.TXSTATUS)=''3'' OR TRIM(TLLOG.TXSTATUS)=''1'')';
        execute immediate v_strSQL;
        INSERT INTO log_err
                  (id,date_log, POSITION, text)
           VALUES ( seq_log_err.NEXTVAL,SYSDATE, ' BACKUPDATA ', v_strSQL);
        commit;
        v_strSQL := ' truncate table ' || v_strFRTABLE;
        execute immediate v_strSQL;
    end loop;
    --'Sao luu du lieu bang TLLOG, TLLOGFLD Cho cac giao dichi?? BACKUP=Y
     INSERT INTO TLLOGALL SELECT TLLOG.* FROM TLLOG, TLTX
     WHERE TLLOG.TLTXCD=TLTX.TLTXCD AND TLTX.BACKUP='Y'
     AND (TLLOG.TXSTATUS='3' OR TLLOG.TXSTATUS='1' OR TLLOG.TXSTATUS='7');
     commit;
     INSERT INTO TLLOGFLDALL SELECT DTL.* FROM TLLOGFLD DTL, TLLOG, TLTX
     WHERE TLLOG.TLTXCD=TLTX.TLTXCD AND TLTX.BACKUP='Y'
     AND TLLOG.TXNUM=DTL.TXNUM AND TLLOG.TXDATE=DTL.TXDATE
     AND (TLLOG.TXSTATUS='3' OR TLLOG.TXSTATUS='1' OR TLLOG.TXSTATUS='7');
     commit;
     --'Xoa bnag TLLOG vai?? TLLOGFLD hien tai
     v_strSQL:='truncate table TLLOG';
     execute immediate v_strSQL;
     v_strSQL:='truncate table TLLOGFLD';
     execute immediate v_strSQL;
    --'Xoa cac bang khong phai bang giao dich, can backup
    for rec in (
        SELECT FRTABLE, TOTABLE FROM TBLBACKUP WHERE TYPBK='N'
    )
    loop
        v_strFRTABLE :=rec.FRTABLE;
        v_strTOTABLE := rec.TOTABLE;
        --Sao luu __HIST
        v_strSQL := 'INSERT INTO ' || v_strTOTABLE || ' SELECT * FROM ' || v_strFRTABLE;
        execute immediate v_strSQL;

        INSERT INTO log_err
                  (id,date_log, POSITION, text
                  )
           VALUES ( seq_log_err.NEXTVAL,SYSDATE, ' BACKUPDATA ', v_strSQL
                  );

        commit;
        v_strSQL := 'TRUNCATE TABLE ' || v_strFRTABLE;
        execute immediate v_strSQL;
    end loop;

    --'Xoa cac bang khong phai bang giao dich, khong backup
     for rec in (
        SELECT FRTABLE, TOTABLE FROM TBLBACKUP WHERE TYPBK='D'
     )
     loop
        v_strFRTABLE := rec.FRTABLE;
        --'Xoa bang __TRONGNGAY
        v_strSQL := 'TRUNCATE TABLE ' || v_strFRTABLE;
        execute immediate v_strSQL;
        INSERT INTO log_err
                  (id,date_log, POSITION, text
                  )
           VALUES ( seq_log_err.NEXTVAL,SYSDATE, ' BACKUPDATA ', v_strSQL
                  );

        commit;
     end loop;

     --Kiem tra tao sequence moi
     For rec in(
       SELECT FRTABLE, TOTABLE FROM TBLBACKUP WHERE TYPBK='S'
       )
       Loop
           v_strFRTABLE:= rec.FRTABLE;
           Select count(*) into v_count from user_sequences where sequence_name =v_strFRTABLE;
           If v_count >0 Then
                reset_sequence(SEQ_NAME=>v_strFRTABLE, STARTVALUE=>1);
                commit;
            ELSE

           v_Sql2:='CREATE SEQUENCE '||v_strFRTABLE ||'
              INCREMENT BY 1
              START WITH 1
              MINVALUE 1
              MAXVALUE 999999999999999999999999999
              NOCYCLE
              NOORDER
              NOCACHE';
           Execute immediate v_Sql2;

            INSERT INTO log_err
                  (id,date_log, POSITION, text
                      )
                   VALUES ( seq_log_err.NEXTVAL,SYSDATE, ' BACKUPDATA ', v_Sql2
                      );

           End if;

            commit;

       End Loop;

    Select count(*) into v_count from user_sequences where sequence_name like '%ORDERMAP%';
    If v_count >0 Then
     v_Sql1:='DROP SEQUENCE seq_ordermap';
     Execute immediate v_Sql1;

     INSERT INTO log_err
                  (id,date_log, POSITION, text
                      )
                   VALUES ( seq_log_err.NEXTVAL,SYSDATE, ' BACKUPDATA ', v_Sql1
                      );
      Commit;
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
                   VALUES ( seq_log_err.NEXTVAL,SYSDATE, ' BACKUPDATA ', v_Sql2
                      );
      Commit;

      --SAO LUU BLOOMBERG.
     INSERT INTO bl_eventhist SELECT * FROM bl_event WHERE process = 'Y';
     commit;
     delete from bl_event where process = 'Y' ;
     commit;
     INSERT INTO bl_exec_rpthist SELECT * FROM bl_exec_rpthist where process = 'Y';
     commit;
     delete from bl_exec_rpthist where process = 'Y' ;
     commit;

EXCEPTION
    WHEN others THEN
    Rollback;
    v_err:=substr(sqlerrm,1,199);
    INSERT INTO log_err
                  (id,date_log, POSITION, text
                  )
           VALUES ( seq_log_err.NEXTVAL,SYSDATE, ' BACKUPDATA ', v_err
                  );
    Commit;
END;
 
 
 
 
/
