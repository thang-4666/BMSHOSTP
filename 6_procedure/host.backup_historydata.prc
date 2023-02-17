SET DEFINE OFF;
CREATE OR REPLACE PROCEDURE "BACKUP_HISTORYDATA" (p_indate IN VARCHAR2,p_strerrnum out varchar2)
  IS


 v_strFRTABLE   varchar2(100);
 v_strTOTABLE   varchar2(100);
 v_strSQL       varchar2(2000);
 v_err          varchar2(200);
 v_count number(10);
 v_indate date;
BEGIN
    dbms_output.put_line('v_indate ' || v_indate);
    INSERT INTO log_err
                  (id,date_log, POSITION, text)
           VALUES ( seq_log_err.NEXTVAL,SYSDATE, ' BACKUPDATA ', to_char(v_indate));
    --'Xoa cac bang __TRAN cua cac phan he nghiep vu
    for rec in (
        SELECT FRTABLE, TOTABLE FROM TBLBACKUP WHERE TYPBK='T'
    )
    loop
        v_strFRTABLE:=rec.FRTABLE;
        v_strTOTABLE:=rec.TOTABLE;
        v_strSQL := 'DELETE FROM ' || v_strTOTABLE || ' WHERE (TXNUM, TXDATE) IN (SELECT TXNUM,TXDATE FROM ' || v_strFRTABLE || ' WHERE TXDATE<= to_date(''' || p_indate || ''',''DD/MM/RRRR''))';
        execute immediate v_strSQL;
        v_strSQL := 'INSERT INTO ' || v_strTOTABLE || ' SELECT * FROM ' || v_strFRTABLE ||
                ' WHERE TXDATE<= to_date(''' || p_indate|| ''',''DD/MM/RRRR'')';

        INSERT INTO log_err
                  (id,date_log, POSITION, text)
           VALUES ( seq_log_err.NEXTVAL,SYSDATE, ' BACKUPDATA ', v_strSQL);
        execute immediate v_strSQL;
        commit;
        v_strSQL := ' delete ' || v_strFRTABLE || ' where TXDATE<= to_date(''' || p_indate|| ''',''DD/MM/RRRR'')' ;
        INSERT INTO log_err
                  (id,date_log, POSITION, text)
           VALUES ( seq_log_err.NEXTVAL,SYSDATE, ' BACKUPDATA ', v_strSQL);
        execute immediate v_strSQL;
    end loop;

     INSERT INTO TLLOGALL SELECT TLLOG.* FROM TLLOG WHERE TXDATE<=to_date(p_indate,'DD/MM/RRRR');
     commit;
     INSERT INTO TLLOGFLDALL SELECT DTL.* FROM TLLOGFLD DTL, TLLOG, TLTX
     WHERE TLLOG.TLTXCD=TLTX.TLTXCD AND TLTX.BACKUP='Y'
     AND TLLOG.TXNUM=DTL.TXNUM AND TLLOG.TXDATE=DTL.TXDATE and TLLOG.TXDATE<=to_date(p_indate,'DD/MM/RRRR')
     AND (TLLOG.TXSTATUS='3' OR TLLOG.TXSTATUS='1' OR TLLOG.TXSTATUS='7');
     commit;
     delete from tllog where TXDATE<=to_date(p_indate,'DD/MM/RRRR');
     delete from tllogfld where TXDATE<=to_date(p_indate,'DD/MM/RRRR');


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
     INSERT INTO log_err
                  (id,date_log, POSITION, text
                      )
                   VALUES ( seq_log_err.NEXTVAL,SYSDATE, ' BACKUPDATA ', 'COMPLETE'
                      );


      Commit;
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
