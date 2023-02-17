SET DEFINE OFF;
CREATE OR REPLACE TRIGGER TRG_TLLOG_AFTER
 AFTER 
 INSERT OR UPDATE
 ON TLLOG
 REFERENCING OLD AS OLDVAL NEW AS NEWVAL
 FOR EACH ROW
declare
  -- local variables here
  -- l_datasource varchar2(1000);
  l_msg_type varchar2(200);
  pkgctx     plog.log_ctx;
  logrow     tlogdebug%ROWTYPE;
  l_count   NUMBER(5);
  l_search  varchar2(100);
  l_trtype  varchar2(100);
  l_ISTRFCA  varchar2(100);
  l_autoid  number;
  l_countsymbol number;
  l_count2247 number;
  l_count2244 number;
  l_count2255 number;
  l_catype varchar2(50);
  l_SENDTOVSD varchar2(10);
  l_issendtovsd varchar2(3);
  l_status varchar2(10);
  l_NSDSTATUS varchar2(10);
begin

  FOR i IN (SELECT * FROM tlogdebug) LOOP
    logrow.loglevel  := i.loglevel;
    logrow.log4table := i.log4table;
    logrow.log4alert := i.log4alert;
    logrow.log4trace := i.log4trace;
  END LOOP;
  pkgctx := plog.init('trg_tllog_after',
                      plevel           => NVL(logrow.loglevel, 30),
                      plogtable        => (NVL(logrow.log4table, 'N') = 'Y'),
                      palert           => (NVL(logrow.log4alert, 'N') = 'Y'),
                      ptrace           => (NVL(logrow.log4trace, 'N') = 'Y'));

  plog.setbeginsection(pkgctx, 'trg_tllog_after');
  if fopks_api.fn_is_ho_active then
    if :NEWVAL.tltxcd in
       ('1100', '1108', '1109', '1111', '1132') and
       :newval.txstatus = '1' then

      --Begin TheNN Log trigger for buffer
      jbpks_auto.pr_trg_account_log(:newval.msgacct, 'CI');
      --End Log trigger for buffer

    end if;
  end if;
  ----------------------------------------------
  --plog.error(pkgctx, '[DEBUG] :newval.txstatus' || :newval.txstatus || ':oldval.txstatus' || :oldval.txstatus);
  if (
 (:newval.txstatus = '1' and (length(trim(:oldval.txstatus)) = 0 or :oldval.txstatus is null or :oldval.txstatus <> '1') )
         OR
         (:newval.txstatus = '7' AND :oldval.txstatus = '1')
         )
        and fopks_api.fn_is_ho_active

        then
    begin
      select  msgtype
        into l_msg_type
        from tltx
       where tltxcd = :newval.tltxcd;
    exception
      when NO_DATA_FOUND then
        l_msg_type := '';
    end;

    if length(l_msg_type) > 0 then

      insert into log_notify_event
        (autoid,
         msgtype,
         keyvalue,
         status,
         CommandType,
         CommandText,
         logtime)
      values
        (seq_log_notify_event.nextval,
         'TRANSACT',
         :newval.txnum,
         'A',
         'P',
         'GENERATE_TEMPLATES',
         sysdate);
    end if;
  end if;

  --------------------------------------------------------
  
  if :newval.txstatus = '1' and (:oldval.txstatus is null or :oldval.txstatus <> '1')
    THEN
      -- PHuongHT edit for VSD
    SELECT COUNT(*) INTO L_COUNT FROM VSDTRFCODE VSD WHERE VSD.TLTXCD=:NEWVAL.TLTXCD AND VSD.STATUS='Y' AND VSD.TYPE IN ('REQ','EXREQ');
    
    IF L_COUNT >0 THEN
    l_search := '%';
        -- VuTN xu ly rieng cho gd 2255
        if instr('/2255/', :newval.tltxcd) > 0 then
            select nvalue into l_autoid
            from tllogfld
            where txnum = :newval.txnum
            and txdate = :newval.txdate
            and fldcd = '18';
            
            
            select trtype,ISTRFCA into l_trtype,l_ISTRFCA from sesendout where AUTOID = l_autoid;
            -- l_trtype = '014': chuyen khoan khong tat toan tai khoan
            if l_trtype = '014' and l_ISTRFCA = 'Y' then
                select count(1) into l_count2244 from v_se2244 where custodycd = :newval.cfcustodycd;
                
                SELECT COUNT(1) into l_count2255
                FROM SESENDOUT SEO, CFMAST CF, AFMAST AF, SBSECURITIES SEC,SEMAST SE
                WHERE SUBSTR(SEO.ACCTNO,0,10)=AF.ACCTNO
                AND AF.CUSTID=CF.CUSTID
                AND SEC.CODEID=SEO.CODEID
                AND SE.ACCTNO=SEO.ACCTNO
                AND SEO.TRADE+SEO.BLOCKED+SEO.CAQTTY>0
                AND DELTD ='N' AND CF.CUSTODYCD = :newval.cfcustodycd;
                
                if l_count2244 = 0 and l_count2255 = 0 then
                    l_search:= '598.NEWM.ACCT//TWAC';
                else
                    l_search:='';
                end if;
            else
                select case
                       when instr(symbol, '_WFT') > 0 then
                        '%CLAS//PEND%'
                       else
                        '%CLAS//NORM%'
                     end
                into l_search
                from sbsecurities
               where codeid = :newval.ccyusage;
            end if;
            --31/05/2018 DieuNDA: Them truong co sinh dien gui VSD hay khong
               select SENDTOVSD into l_issendtoVSD
               from SE2255_LOG
               where txdate = :newval.txdate and txnum = :newval.txnum and deltd <> 'Y';

               if nvl(l_issendtoVSD,'N') <> 'Y' then
                    l_search := '';
               end if;
               --End 31/05/2018 DieuNDA
        -- Neu la cac giao dich Gui, Rut, Chuyen khoan CK WFT
        elsif instr('/2241/2292/8815/', :newval.tltxcd) > 0 then
            begin
              select case
                       when instr(symbol, '_WFT') > 0 then
                        '%CLAS//PEND%'
                       else
                        '%CLAS//NORM%'
                     end
                into l_search
                from sbsecurities
               where codeid = :newval.ccyusage;
            exception
              when no_data_found then
                l_search := '%CLAS//NORM%';
            end;
        elsif instr('/2247/', :newval.tltxcd) > 0 then

            --thay doi trang thai de phan biet duyet va chua duyet
            update trfdtoclose
            set deltd = 'C'
            where txnum = :newval.txnum
            and txdate = TO_DATE (:newval.txdate, systemnums.C_DATE_FORMAT);
            --so luong 2247 da duyet
            select count(1) into l_countsymbol
            from trfdtoclose
            where frcustodycd = :newval.cfcustodycd
            and deltd = 'C';
            --so luong dong da lam tren 2247
            select count(1) into l_count2247
            from V_SE2290
            where custodycd = :newval.cfcustodycd;
            
            --so luong dong con lai tren 2247
            select count(1) into l_count from v_se2247 where custodycd = :newval.cfcustodycd;
            
            if l_count2247 > 0 and l_count = 0 then
                l_search:= '598.NEWM.ACCT//TBAC';
            else
                l_search:= '';
            end if;
        /*elsif instr('/3340/', :newval.tltxcd) > 0 then
            select catype into l_catype from camast where camastid = :newval.msgacct;
            --l_catype = '014': quyen mua, neu la quyen mua thi k sinh dien xac nhan
            if l_catype = '014' then
                l_search:= '';
            end if;
        elsif instr('/3376/', :newval.tltxcd) > 0 then
            select status into l_status from camast where camastid = :newval.msgacct;
            --l_status <> 'A': da lam buoc xac nhan 3370 hoan 3340 thi luc huy khong sinh dien huy
            if l_status <> 'A' then
                l_search:= '';
            end if;*/
        elsif instr('/0059/', :newval.tltxcd) > 0 then
            SELECT CVALUE INTO L_NSDSTATUS
            FROM TLLOGFLD
            WHERE TXNUM = :NEWVAL.TXNUM
            AND TXDATE = :NEWVAL.TXDATE
            AND FLDCD = '08';
            if l_NSDSTATUS = 'N' then
                l_search:= '';
            else
                update cfmast set nsdstatus = 'S' where custodycd = :newval.msgacct;
            end if;
        end if;
        -- neu la ca giao dich mo, dong, kich hoat lai tk thi chuyen trang thai tk thanh da sinh dien
        if instr('/0035/0167/', :newval.tltxcd) > 0 then
            update cfmast set nsdstatus = 'S' where custodycd = :newval.msgacct;
        end if;
       FOR REC IN (
                  SELECT TRFCODE FROM VSDTRFCODE WHERE TLTXCD=:NEWVAL.TLTXCD AND STATUS='Y' AND (TYPE = 'REQ'
                   AND TRFCODE LIKE L_SEARCH) OR (TYPE = 'EXREQ' AND TLTXCD=:NEWVAL.TLTXCD))
       LOOP
           Insert into VSD_PROCESS_LOG(AUTOID,TRFCODE,TLTXCD,TXNUM,TXDATE,PROCESS,MSGACCT,BRID,TLID)
           values (TO_NUMBER(TO_CHAR(GETCURRDATE,'RRRRMMDD')||SEQ_VSD_PROCESS_LOG.NEXTVAL),REC.TRFCODE,:NEWVAL.TLTXCD,:NEWVAL.TXNUM,GETCURRDATE,'N',nvl(:NEWVAL.CFCUSTODYCD, :NEWVAL.MSGACCT),:NEWVAL.BRID,:NEWVAL.TLID);
       END LOOP;
    END IF;
    -- end of PhuongHT edit
    END IF;
      plog.setEndSection(pkgctx, 'trg_tllog_after');
exception
  when others then
    plog.error(pkgctx, SQLERRM);
    plog.setEndSection(pkgctx, 'trg_tllog_after');
end;
/
