SET DEFINE OFF;
CREATE OR REPLACE TRIGGER TRG_CAMAST_AFTER 
 AFTER
  UPDATE
 ON camast
REFERENCING NEW AS NEW OLD AS OLD
 FOR EACH ROW
declare
  -- local variables here
  L_SYMBOL VARCHAR2(100);
  L_COUNT NUMBER ;
  L_FDATE DATE;
  L_TDATE DATE;
  pkgctx     plog.log_ctx;
begin
  --Gui mau email 216
  if :new.status = 'V' and :new.status <> :old.status and :new.catype = '014' then
    insert into log_notify_event
      (autoid, msgtype, keyvalue, status, CommandType, CommandText, logtime)
    values
      (seq_log_notify_event.nextval, 'CAMAST_V', :new.camastid, 'A', 'P', 'GENERATE_TEMPLATES', sysdate);

    insert into log_notify_event
      (autoid, msgtype, keyvalue, status, CommandType, CommandText, logtime)
    values
      (seq_log_notify_event.nextval, 'CAMASTSMS_V', :new.camastid, 'A', 'P', 'GENERATE_TEMPLATES', sysdate);


  end if;

  if :new.status = 'S' and :new.status <> :old.status and :new.catype <> '014' then
    insert into log_notify_event
      (autoid, msgtype, keyvalue, status, CommandType, CommandText, logtime)
    values
      (seq_log_notify_event.nextval, 'CAMAST_S', :new.camastid, 'A', 'P', 'GENERATE_TEMPLATES', sysdate);
   /* --g?i sms chia co tuc , co phieu
     insert into log_notify_event
      (autoid, msgtype, keyvalue, status, CommandType, CommandText, logtime)
    values
      (seq_log_notify_event.nextval, 'SCHD0320', :new.camastid, 'A', 'P', 'GENERATE_TEMPLATES', sysdate);*/

  end if;
  --stt = A xong gd 3375 tao ds
  --stt = V xong gd 3370 chot ds
  if :new.status = 'V' and :new.status <> :old.status and :new.catype = '014' then
    insert into log_notify_event
      (autoid, msgtype, keyvalue, status, CommandType, CommandText, logtime)
    values
      (seq_log_notify_event.nextval, 'CAMAST_A', :new.camastid, 'A', 'P', 'GENERATE_TEMPLATES', sysdate);

   /* --g?i sms chot quyen mua CK
     insert into log_notify_event
      (autoid, msgtype, keyvalue, status, CommandType, CommandText, logtime)
    values
      (seq_log_notify_event.nextval, 'SCHD0321', :new.camastid, 'A', 'P', 'GENERATE_TEMPLATES', sysdate);*/

  end if;
  ---email gia han chot quyen
  if :new.duedate <> :old.duedate or :new.FRDATETRANSFER <> :old.FRDATETRANSFER or :new.TODATETRANSFER <> :old.TODATETRANSFER or :new.BEGINDATE <> :old.BEGINDATE then
    insert into log_notify_event
      (autoid, msgtype, keyvalue, status, CommandType, CommandText, logtime)
    values
      (seq_log_notify_event.nextval, 'CAMAST_C', :new.camastid, 'A', 'P', 'GENERATE_TEMPLATES', sysdate);
  end if;

if :new.status = 'N' AND :NEW.CATYPE IN ('010','011','014','021')  THEN

SELECT SYMBOL INTO L_SYMBOL FROM sbsecurities WHERE CODEID = :new.CODEID;

SELECT NVL( COUNT(1),0) INTO L_COUNT FROM afserisk WHERE CODEID = :new.CODEID;
    IF L_COUNT>0 THEN
    L_FDATE := get_t_date(:new.REPORTDATE,4);
    L_TDATE := get_t_date(:new.REPORTDATE,2);

  SELECT NVL( COUNT(1),0) INTO L_COUNT FROM RIGHTOFFEVENT WHERE SYMBOL =L_SYMBOL AND begindate >=L_FDATE AND enddate <=L_TDATE;

    IF L_COUNT=0 THEN
    INSERT INTO RIGHTOFFEVENT (AUTOID,SYMBOL,BEGINDATE,ENDDATE,I1,I2,I3,TTHCP,DIVCP,TTHT,DIVT,PR1,PR2,PR3,AUTOCALC,BASICPRICE,STATUS,PSTATUS)
    VALUES(seq_rightoffevent.NEXTVAL,L_SYMBOL,L_FDATE,L_TDATE,0,0,0,0,0,0,0,0,0,0,'Y',0,'P',NULL);
    END IF;

    END IF;
END IF;

exception
  when others then
    plog.error(pkgctx, SQLERRM);
    plog.setEndSection(pkgctx, 'trg_TLAUTH_after');

end TRG_CAMAST_AFTER;
/
