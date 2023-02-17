SET DEFINE OFF;
CREATE OR REPLACE PACKAGE cspks_caproc
IS
    /*----------------------------------------------------------------------------------------------------
     ** Module   : COMMODITY SYSTEM
     ** and is copyrighted by FSS.
     **
     **    All rights reserved.  No part of this work may be reproduced, stored in a retrieval system,
     **    adopted or transmitted in any form or by any means, electronic, mechanical, photographic,
     **    graphic, optic recording or otherwise, translated in any language or computer language,
     **    without the prior written permission of Financial Software Solutions. JSC.
     **
     **  MODIFICATION HISTORY
     **  Person      Date           Comments
     **  FSS      20-mar-2010    Created
     ** (c) 2008 by Financial Software Solutions. JSC.
     ----------------------------------------------------------------------------------------------------*/

PROCEDURE pr_exec_money_cop_action (p_refcursor in out pkg_report.ref_cursor,p_camastid varchar2);
PROCEDURE pr_exec_sec_cop_action (p_camastid varchar2, p_errcode in out varchar2);
PROCEDURE pr_send_cop_action (p_camastid varchar2, p_errcode in out varchar2);

procedure pr_allocate_right_stock(p_orgorderid varchar2);
PROCEDURE pr_3380_send_cop_action(p_txmsg in tx.msg_rectype,p_err_code  OUT varchar2);
PROCEDURE pr_3350_exec_money_CA(p_txmsg in tx.msg_rectype,p_err_code  OUT varchar2);
PROCEDURE pr_3351_Exec_Sec_CA(p_txmsg in tx.msg_rectype,p_err_code  OUT varchar2);
FUNCTION fn_ExecuteContractCAEvent(p_txmsg in tx.msg_rectype,p_err_code out varchar2)
RETURN NUMBER;
PROCEDURE pr_CALAUTOCA3342( p_err_code  OUT varchar2);
END;

 
 
 
 
/


CREATE OR REPLACE PACKAGE BODY cspks_caproc
IS
   -- declare log context
   pkgctx   plog.log_ctx;
   logrow   tlogdebug%ROWTYPE;


--PROCEDURE pr_exec_money_cop_action (pv_refcursor in out pkg_report.ref_cursor,p_camastid varchar2)--, p_errcode in out varchar2, p_errmessage in out varchar2)
PROCEDURE pr_exec_money_cop_action (p_refcursor in out pkg_report.ref_cursor,p_camastid varchar2)
IS
p_txmsg               tx.msg_rectype;
v_dtCURRDATE date;
v_count number;
v_numcmt number;
i number;
p_errcode number;
BEGIN
    plog.setbeginsection(pkgctx, 'pr_exec_money_cop_action');
    --open pv_refcursor for
    --    select sysdate from dual;
    --p_errcode:='0';
    --p_errmessage:='';
    select count(1) into v_count
    from camast a, sbsecurities b
    where a.codeid = b.codeid and a.status ='I' and a.deltd<>'Y'
        and (select count(1) from caschd where camastid = a.camastid and status <> 'C' and isCI ='N') >0
        and a.camastid = p_camastid;
    if v_count=0 THEN
        p_errcode:='-1';
        --p_errmessage:='Su kien quyen can thuc hien khong hop le!';
        plog.Error(pkgctx, 'Su kien quyen can thuc hien khong hop le :' || p_camastid );
        plog.setbeginsection(pkgctx, 'pr_exec_money_cop_action');
        return;
    end if;
    select count(1) into v_count from caexec_temp;
    if v_count=0 then
        --001.Tao du lieu temp de thuc hien
        plog.debug(pkgctx, 'Begin exec caaction :' || p_camastid );
        plog.debug(pkgctx, '  Begin temporary update camast status :' || p_camastid );
        UPDATE CAMAST SET STATUS='X',LASTDATE = TO_DATE(p_txmsg.txdate, systemnums.C_DATE_FORMAT) WHERE CAMASTID=p_camastid;
        --commit;
        plog.debug(pkgctx, '  End temporary update camast status :' || p_camastid );
        delete from caexec_temp where camastid =p_camastid;
        --commit;
        plog.debug(pkgctx, '  Begin log caexec_temp');
        insert into caexec_temp (TLAUTOID,txnum,autoid, balance, camastid, afacctno, catype, codeid,
               excodeid, qtty, amt, aqtty, aamt, symbol, status,
               seacctno, exseacctno, parvalue, exparvalue, reportdate,
               actiondate, postingdate, description, taskcd, dutyamt,
               fullname, idcode, custodycd,custid,TRADEPLACE, SECTYPE,CAVAT, SCHDVAT)
        SELECT seq_tllog.NEXTVAL,systemnums.C_BATCH_PREFIXED
                                 || LPAD (seq_BATCHTXNUM.NEXTVAL, 8, '0') txnum, CA.AUTOID, CA.BALANCE, ca.CAMASTID, CA.AFACCTNO,CAMAST.CATYPE, CA.CODEID,
                CA.EXCODEID, CA.QTTY, ROUND(CA.AMT) AMT, ROUND(CA.AQTTY) AQTTY,ROUND(CA.AAMT) AAMT, SYM.SYMBOL, CA.STATUS,
                CASE WHEN camast.catype = '017' THEN CA.AFACCTNO || CA.EXCODEID ELSE CA.AFACCTNO || CA.CODEID END SEACCTNO,
                CASE WHEN camast.catype = '017' THEN CA.AFACCTNO || CA.CODEID else CA.AFACCTNO || (CASE WHEN CAMAST.EXCODEID IS NULL THEN CAMAST.CODEID ELSE CAMAST.EXCODEID END) end EXSEACCTNO,
                SYM.PARVALUE PARVALUE, EXSYM.PARVALUE EXPARVALUE, CAMAST.REPORTDATE REPORTDATE, CAMAST.ACTIONDATE ,CAMAST.ACTIONDATE  POSTINGDATE,
                    camast.description, camast.taskcd,
      (CASE WHEN cf.VAT='Y' THEN ( CASE WHEN CAMAST.CATYPE IN ('016','023') THEN CAMAST.pitrate*CA.INTAMT/100 ELSE CAMAST.pitrate*CA.AMT/100 END) ELSE 0 END) DUTYAMT,
                       CF.FULLNAME, CF.IDCODE, CF.CUSTODYCD, cf.custid, SYM.TRADEPLACE, SYM.SECTYPE,
                      CAMAST.PITRATEMETHOD CAVAT,(case when CA.PITRATEMETHOD='##' then CAMAST.PITRATEMETHOD else CA.PITRATEMETHOD end) SCHDVAT
                FROM caschd CA,
                    SBSECURITIES SYM, SBSECURITIES EXSYM, CAMAST, AFMAST AF , CFMAST CF , AFTYPE TYP, SYSVAR SYS
                WHERE CA.CAMASTID = CAMAST.CAMASTID AND CAMAST.CODEID = SYM.CODEID
                and camast.camastid =p_camastid
                AND nvl(CAMAST.EXCODEID,CAMAST.CODEID)  = EXSYM.CODEID
                AND CA.AFACCTNO = AF.ACCTNO AND AF.CUSTID = CF.CUSTID
                AND CA.DELTD ='N' AND CA.STATUS ='S' and CAMAST.STATUS ='X' AND CA.ISCI ='N' --AND CA.ISSE='N'
                AND CA.AMT>0 AND CA.ISEXEC='Y'
                AND AF.ACTYPE = TYP.ACTYPE AND SYS.GRNAME='SYSTEM' AND SYS.VARNAME='CADUTY';
        --commit;
        plog.debug(pkgctx, '  End log caexec_temp');
        --002.Thuc hien quyen dua tren du lieu temp
        SELECT TO_DATE (varvalue, systemnums.c_date_format)
                   INTO v_dtCURRDATE
                   FROM sysvar
                   WHERE grname = 'SYSTEM' AND varname = 'CURRDATE';
        p_txmsg.msgtype:='T';
        p_txmsg.local:='N';
        p_txmsg.tlid        := systemnums.c_system_userid;
        SELECT SYS_CONTEXT ('USERENV', 'HOST'),
                 SYS_CONTEXT ('USERENV', 'IP_ADDRESS', 15)
          INTO p_txmsg.wsname, p_txmsg.ipaddress
        FROM DUAL;
        p_txmsg.off_line    := 'N';
        p_txmsg.deltd       := txnums.c_deltd_txnormal;
        p_txmsg.txstatus    := txstatusnums.c_txcompleted;
        p_txmsg.msgsts      := '0';
        p_txmsg.ovrsts      := '0';
        p_txmsg.batchname   := 'CAEXECBF';
        p_txmsg.txdate:=v_dtCURRDATE;
        p_txmsg.busdate:=v_dtCURRDATE;
        p_txmsg.tltxcd:='3350';

        --*1. Tao tllog
        plog.debug(pkgctx, '  Begin log tllog');
        INSERT /*+ append */ INTO tllogall(autoid, txnum, txdate, txtime, brid, tlid,
                offid, ovrrqs, chid, chkid, tltxcd, ibt, brid2, tlid2, ccyusage,off_line,
                deltd, brdate, busdate, txdesc, ipaddress,wsname, txstatus, msgsts,
                ovrsts, batchname, msgamt,msgacct, chktime, offtime)
        select
               REC.TLAUTOID,
               rec.txnum,--p_txmsg.txnum,
               TO_DATE(p_txmsg.txdate, systemnums.C_DATE_FORMAT),
               TO_CHAR(SYSDATE,systemnums.C_TIME_FORMAT),--p_txmsg.txtime,
               substr(rec.AFACCTNO,1,4),--p_txmsg.brid,
               p_txmsg.tlid,
               p_txmsg.offid,
               p_txmsg.ovrrqd,
               p_txmsg.chid,
               p_txmsg.chkid,
               p_txmsg.tltxcd,
               p_txmsg.ibt,
               p_txmsg.brid2,
               p_txmsg.tlid2,
               p_txmsg.ccyusage,
               p_txmsg.off_line,
               p_txmsg.deltd,
               TO_DATE(p_txmsg.txdate, systemnums.C_DATE_FORMAT),
               TO_DATE(p_txmsg.busdate, systemnums.C_DATE_FORMAT),
               rec.DESCRIPTION,--NVL(p_txmsg.txfields('30').value,p_txmsg.txdesc),
               p_txmsg.ipaddress,
               p_txmsg.wsname,
               p_txmsg.txstatus,
               p_txmsg.msgsts,
               p_txmsg.ovrsts,
               p_txmsg.batchname,
               rec.AMT,--p_txmsg.txfields('10').value ,
               rec.AFACCTNO,--p_txmsg.txfields('03').value ,
               decode(p_txmsg.chktime,NULL,TO_CHAR(SYSDATE,systemnums.C_TIME_FORMAT),p_txmsg.chktime),
               decode(p_txmsg.offtime,NULL,TO_CHAR(SYSDATE,systemnums.C_TIME_FORMAT),p_txmsg.offtime)
        from caexec_temp rec where camastid =p_camastid;
        --commit;
        plog.debug(pkgctx, '  End log tllog');
        --*2. Insert vao tllogall

        --*3. Insert vao cac bang tran
        plog.debug(pkgctx, '  Begin log CITRAN Dr Receiving');
        INSERT  INTO CITRANA(TXNUM,TXDATE,ACCTNO,TXCD,NAMT,CAMT,ACCTREF,DELTD,REF,AUTOID,TLTXCD,BKDATE,TRDESC)
                select rec.txnum, TO_DATE (p_txmsg.txdate, systemnums.C_DATE_FORMAT),rec.AFACCTNO,'0045',ROUND(rec.amt,0),NULL,rec.CAMASTID,p_txmsg.deltd,rec.CAMASTID,seq_CITRAN.NEXTVAL,p_txmsg.tltxcd,p_txmsg.busdate,'' || '' || ''
                from caexec_temp rec where rec.amt>0;
        --commit;
        INSERT  INTO citran_gen (CUSTODYCD,CUSTID,
                                         TXNUM,TXDATE,ACCTNO,TXCD,NAMT,CAMT,ACCTREF,DELTD,REF,AUTOID,TLTXCD,BUSDATE,TRDESC,
                                         TXTIME,BRID,TLID,OFFID,CHID,DFACCTNO,OLD_DFACCTNO,TXTYPE,FIELD,TLLOG_AUTOID,TXDESC)
        select        REC.custodycd, REC.custid,
                      rec.txnum, TO_DATE (p_txmsg.txdate, systemnums.C_DATE_FORMAT), rec.AFACCTNO, '0045', ROUND(rec.amt,0),NULL, rec.CAMASTID, p_txmsg.deltd, rec.CAMASTID,seq_CITRAN.NEXTVAL,p_txmsg.tltxcd, p_txmsg.busdate,'' || '' || '',
                      TO_CHAR(SYSDATE,systemnums.C_TIME_FORMAT), p_txmsg.brid, p_txmsg.tlid, p_txmsg.offid, p_txmsg.chid,'' dfacctno,'' old_dfacctno,'D', 'RECEIVING' ,REC.TLAUTOID, rec.DESCRIPTION trdesc
        from caexec_temp rec where rec.amt>0;

        --COMMIT;
        plog.debug(pkgctx, '  End  log CITRAN Dr receiving');

        plog.debug(pkgctx, '  Begin log CITRAN Cr balance thu thue tai TCPH');

        INSERT /*+ append */ INTO CITRANA(TXNUM,TXDATE,ACCTNO,TXCD,NAMT,CAMT,ACCTREF,DELTD,REF,AUTOID,TLTXCD,BKDATE,TRDESC)
                select rec.txnum, TO_DATE (p_txmsg.txdate, systemnums.C_DATE_FORMAT),rec.AFACCTNO,'0012',ROUND(rec.AMT-rec.DUTYAMT,0),NULL,rec.CAMASTID,p_txmsg.deltd,rec.CAMASTID,seq_CITRAN.NEXTVAL,p_txmsg.tltxcd,p_txmsg.busdate,'' || '' || ''
                from caexec_temp rec where camastid =p_camastid and rec.AMT>0 and rec.schdvat='IS';
        --commit;
        INSERT /*+ append */ INTO citran_gen (CUSTODYCD,CUSTID,
                                         TXNUM,TXDATE,ACCTNO,TXCD,NAMT,CAMT,ACCTREF,DELTD,REF,AUTOID,TLTXCD,BUSDATE,TRDESC,
                                         TXTIME,BRID,TLID,OFFID,CHID,DFACCTNO,OLD_DFACCTNO,TXTYPE,FIELD,TLLOG_AUTOID,TXDESC)
        select        REC.custodycd, REC.custid,
                      rec.txnum, TO_DATE (p_txmsg.txdate, systemnums.C_DATE_FORMAT),rec.AFACCTNO,'0012',ROUND(rec.AMT-rec.DUTYAMT,0),NULL,rec.CAMASTID,p_txmsg.deltd,rec.CAMASTID,seq_CITRAN.NEXTVAL,p_txmsg.tltxcd,p_txmsg.busdate,'' || '' || '',
                      TO_CHAR(SYSDATE,systemnums.C_TIME_FORMAT), p_txmsg.brid, p_txmsg.tlid, p_txmsg.offid, p_txmsg.chid,'' dfacctno,'' old_dfacctno,'C', 'BALANCE' ,REC.TLAUTOID, rec.DESCRIPTION trdesc
        from caexec_temp rec where camastid =p_camastid and rec.amt>0 and rec.schdvat='IS';
        --COMMIT;
        plog.debug(pkgctx, '  End log CITRAN Cr balance thu thue tai TCPH');

        plog.debug(pkgctx, '  Begin log CITRAN Cr balance thu thue tai CTy');

        INSERT /*+ append */ INTO CITRANA(TXNUM,TXDATE,ACCTNO,TXCD,NAMT,CAMT,ACCTREF,DELTD,REF,AUTOID,TLTXCD,BKDATE,TRDESC)
                select rec.txnum, TO_DATE (p_txmsg.txdate, systemnums.C_DATE_FORMAT),rec.AFACCTNO,'0012',ROUND(rec.AMT,0),NULL,rec.CAMASTID,p_txmsg.deltd,rec.CAMASTID,seq_CITRAN.NEXTVAL,p_txmsg.tltxcd,p_txmsg.busdate,'' || '' || ''
                from caexec_temp rec where camastid =p_camastid and rec.AMT>0 and rec.schdvat<>'IS';
        --commit;
        INSERT /*+ append */ INTO citran_gen (CUSTODYCD,CUSTID,
                                         TXNUM,TXDATE,ACCTNO,TXCD,NAMT,CAMT,ACCTREF,DELTD,REF,AUTOID,TLTXCD,BUSDATE,TRDESC,
                                         TXTIME,BRID,TLID,OFFID,CHID,DFACCTNO,OLD_DFACCTNO,TXTYPE,FIELD,TLLOG_AUTOID,TXDESC)
        select        REC.custodycd, REC.custid,
                      rec.txnum, TO_DATE (p_txmsg.txdate, systemnums.C_DATE_FORMAT),rec.AFACCTNO,'0012',ROUND(rec.AMT,0),NULL,rec.CAMASTID,p_txmsg.deltd,rec.CAMASTID,seq_CITRAN.NEXTVAL,p_txmsg.tltxcd,p_txmsg.busdate,'' || '' || '',
                      TO_CHAR(SYSDATE,systemnums.C_TIME_FORMAT), p_txmsg.brid, p_txmsg.tlid, p_txmsg.offid, p_txmsg.chid,'' dfacctno,'' old_dfacctno,'C', 'BALANCE' ,REC.TLAUTOID, rec.DESCRIPTION trdesc
        from caexec_temp rec where camastid =p_camastid and rec.amt>0 and rec.schdvat<>'IS';

        INSERT /*+ append */ INTO CITRANA(TXNUM,TXDATE,ACCTNO,TXCD,NAMT,CAMT,ACCTREF,DELTD,REF,AUTOID,TLTXCD,BKDATE,TRDESC)
                select rec.txnum, TO_DATE (p_txmsg.txdate, systemnums.C_DATE_FORMAT),rec.AFACCTNO,'0011',ROUND(rec.DUTYAMT,0),NULL,rec.CAMASTID,p_txmsg.deltd,rec.CAMASTID,seq_CITRAN.NEXTVAL,p_txmsg.tltxcd,p_txmsg.busdate,'' || '' || ''
                from caexec_temp rec where camastid =p_camastid and rec.DUTYAMT>0 and rec.schdvat<>'IS';
        --commit;
        INSERT /*+ append */ INTO citran_gen (CUSTODYCD,CUSTID,
                                         TXNUM,TXDATE,ACCTNO,TXCD,NAMT,CAMT,ACCTREF,DELTD,REF,AUTOID,TLTXCD,BUSDATE,TRDESC,
                                         TXTIME,BRID,TLID,OFFID,CHID,DFACCTNO,OLD_DFACCTNO,TXTYPE,FIELD,TLLOG_AUTOID,TXDESC)
        select        REC.custodycd, REC.custid,
                      rec.txnum, TO_DATE (p_txmsg.txdate, systemnums.C_DATE_FORMAT),rec.AFACCTNO,'0011',ROUND(rec.DUTYAMT,0),NULL,rec.CAMASTID,p_txmsg.deltd,rec.CAMASTID,seq_CITRAN.NEXTVAL,p_txmsg.tltxcd,p_txmsg.busdate,'' || '' || '',
                      TO_CHAR(SYSDATE,systemnums.C_TIME_FORMAT), p_txmsg.brid, p_txmsg.tlid, p_txmsg.offid, p_txmsg.chid,'' dfacctno,'' old_dfacctno,'D', 'BALANCE' ,REC.TLAUTOID, rec.DESCRIPTION trdesc
        from caexec_temp rec where camastid =p_camastid and rec.DUTYAMT>0 and rec.schdvat<>'IS';
        --COMMIT;
        plog.debug(pkgctx, '  End log CITRAN Cr balance thu thue tai CTy');

        --*3. Cap nhat vao bang mast
        plog.debug(pkgctx, '  Begin log Update master table');
        for rec in (select tmp.*, chd.isci, chd.isse from caexec_temp tmp, caschd chd where tmp.autoid = chd.autoid)
        loop
            UPDATE CIMAST
             SET
               BALANCE = BALANCE + (ROUND(rec.AMT-rec.DUTYAMT,0)),
               LASTDATE = TO_DATE(p_txmsg.txdate, systemnums.C_DATE_FORMAT),
               RECEIVING = RECEIVING - (ROUND(rec.AMT,0)),
               CRAMT = CRAMT + (ROUND(rec.AMT-rec.DUTYAMT,0)), LAST_CHANGE = SYSTIMESTAMP
            WHERE ACCTNO=rec.AFACCTNO and ROUND(rec.AMT,0)>0;

            if rec.isse='Y' or rec.qtty + rec.aqtty=0 then
                update caschd set isci='Y', status ='C' where autoid = rec.autoid;
            else
                update caschd set isci='Y' where autoid = rec.autoid;
            end if;
        end loop;


        plog.debug(pkgctx, '  End log Update master table');

        --*4. Cap nhat extention
        --Neu khong con dong lich nao can thuc hien tien hoac chung khoan thi chuyen trang thai va backup su kie nquyen
        select count(1) into v_count from caschd
        where ((isci='N' and amt+aamt>0) or (isse='N' and qtty+aqtty>0))
        and camastid = p_camastid  and deltd <>'Y' and isexec='Y'
        AND status <> 'O';
        if v_count=0 then
            UPDATE CAMAST SET STATUS='C',LASTDATE = TO_DATE(p_txmsg.txdate, systemnums.C_DATE_FORMAT) WHERE CAMASTID=p_camastid;
            --Tinh ap dung cho cac truong hop dac biet
            for rec_mt in (
                select ca.*, sb.symbol from camast ca, sbsecurities sb where ca.codeid= sb.codeid
            )
            loop
                if rec_mt.catype ='012' or rec_mt.catype ='013' then --Tach va gop co phieu
                    UPDATE SBSECURITIES SET PARVALUE = PARVALUE * rec_mt.SPLITRATE WHERE CODEID=rec_mt.codeid;
                elsif rec_mt.catype ='019' then --Chuyen doi san giao dich
                    UPDATE SBSECURITIES SET TRADEPLACE =rec_mt.TOTRADEPLACE WHERE CODEID=rec_mt.codeid;
                    DELETE SECURITIES_TICKSIZE WHERE CODEID=rec_mt.codeid;
                    if rec_mt.TOTRADEPLACE='001' then --san HCM
                        INSERT INTO SECURITIES_TICKSIZE (AUTOID,CODEID,SYMBOL,TICKSIZE,FROMPRICE,TOPRICE,STATUS)
                        VALUES (SEQ_SECURITIES_TICKSIZE.NEXTVAL,rec_mt.codeid,rec_mt.symbol,100,0,49900,'Y');
                        INSERT INTO securities_ticksize (AUTOID,CODEID,SYMBOL,TICKSIZE,FROMPRICE,TOPRICE,STATUS)
                        VALUES (SEQ_SECURITIES_TICKSIZE.NEXTVAL,rec_mt.codeid,rec_mt.symbol,500,50000,99500,'Y');
                        INSERT INTO securities_ticksize (AUTOID,CODEID,SYMBOL,TICKSIZE,FROMPRICE,TOPRICE,STATUS)
                        VALUES (SEQ_SECURITIES_TICKSIZE.NEXTVAL,rec_mt.codeid,rec_mt.symbol,1000,100000,100000000000,'Y');
                        UPDATE  SECURITIES_INFO SET  TRADELOT ='10' WHERE CODEID = rec_mt.codeid;
                    else
                        INSERT INTO securities_ticksize (AUTOID,CODEID,SYMBOL,TICKSIZE,FROMPRICE,TOPRICE,STATUS)
                        VALUES (SEQ_SECURITIES_TICKSIZE.NEXTVAL,rec_mt.codeid,rec_mt.symbol,100,0,1000000000,'Y');
                        UPDATE  SECURITIES_INFO SET  TRADELOT ='100' WHERE CODEID = rec_mt.codeid;
                    end if;
                end if;
            end loop;
            --Thuc hien backup du lieu
            insert into camasthist select * from camast where CAMASTID =p_camastid;--in (select camastid from caexec_temp) and status ='C';
            --commit;
            delete from camast where CAMASTID =p_camastid;-- in (select camastid from caexec_temp) and status ='C';
            --commit;
            insert into caschdhist select * from caschd where camastid =p_camastid;--where autoid in (select autoid from caexec_temp) and status ='C';
            --commit;
            delete from caschd where camastid =p_camastid; --where autoid in (select autoid from caexec_temp) and status ='C';
            --commit;
        else
            --Tra ve trang thai cu cho su kien quyen
            UPDATE CAMAST SET STATUS='I' WHERE CAMASTID=p_camastid;
            p_errcode:='-1';
            --commit;
        end if;
        delete from caexec_temp where camastid =p_camastid;
        --commit;
    end if;
    plog.setendsection(pkgctx, 'pr_exec_money_cop_action');
exception when others then
    p_errcode:='-1';
    --p_errmessage:='Co loi he thong xay ra';
    plog.setendsection(pkgctx, 'pr_exec_money_cop_action');
   --rollback;
    UPDATE CAMAST SET STATUS='I' WHERE CAMASTID=p_camastid;
    --commit;
end;


--PROCEDURE pr_exec_sec_cop_action (pv_refcursor in out pkg_report.ref_cursor,p_camastid varchar2)--, p_errcode in out varchar2, p_errmessage in out varchar2)
PROCEDURE pr_exec_sec_cop_action (p_camastid varchar2, p_errcode in out varchar2)
IS
p_txmsg               tx.msg_rectype;
v_dtCURRDATE date;
v_count number;
v_numcmt number;
i number;
v_RightVATDuty varchar2(100);
v_codeid varchar2(6);
v_tocodeid varchar2(6);
v_righttype varchar2(50);
v_RightConvType number;
v_dblCARATE number;
BEGIN
    plog.setbeginsection(pkgctx, 'pr_exec_sec_cop_action');
    --open pv_refcursor for
    --    select sysdate from dual;
    --p_errcode:='0';
    --p_errmessage:='';
    select count(1) into v_count
    from camast a, sbsecurities b where a.codeid = b.codeid and a.status ='I' and a.deltd<>'Y'
        and (select count(1) from caschd where camastid = a.camastid and status <> 'C' and isSE ='N') >0
        and a.camastid = p_camastid;
    if v_count=0 THEN
        p_errcode:='-1';
        --p_errmessage:='Su kien quyen can thuc hien khong hop le!';
        plog.Error(pkgctx, 'Su kien quyen can thuc hien khong hop le :' || p_camastid );
        plog.setbeginsection(pkgctx, 'pr_exec_sec_cop_action');
        return;
    end if;
    select count(1) into v_count from caexec_temp where camastid = p_camastid;
    if v_count=0 then
        --001.Tao du lieu temp de thuc hien
        plog.debug(pkgctx, 'Begin exec caaction :' || p_camastid );
        --plog.debug(pkgctx, '  Begin temporary update camast status :' || p_camastid );
        --UPDATE CAMAST SET STATUS='X',LASTDATE = TO_DATE(p_txmsg.txdate, systemnums.C_DATE_FORMAT) WHERE CAMASTID=p_camastid;
        --commit;
        plog.debug(pkgctx, '  End temporary update camast status :' || p_camastid );
        delete from caexec_temp where camastid =p_camastid;
        --commit;
        plog.debug(pkgctx, '  Begin log caexec_temp');
        insert into caexec_temp (TLAUTOID,txnum,autoid, balance, camastid, afacctno, catype, codeid,
               excodeid, qtty, amt, aqtty, aamt, symbol, status,
               seacctno, exseacctno, parvalue, exparvalue, reportdate,
               actiondate, postingdate, description, taskcd, dutyamt,
               fullname, idcode, custodycd,custid,TRADEPLACE, SECTYPE, PITRATE, TOCODEID)
        /*SELECT seq_tllog.NEXTVAL,systemnums.C_BATCH_PREFIXED
                                 || LPAD (seq_BATCHTXNUM.NEXTVAL, 8, '0') txnum, CA.AUTOID, CA.BALANCE, ca.CAMASTID, CA.AFACCTNO,CAMAST.CATYPE, CA.CODEID,
                CA.EXCODEID, CA.QTTY, ROUND(CA.AMT) AMT, ROUND(CA.AQTTY) AQTTY,ROUND(CA.AAMT) AAMT, SYM.SYMBOL, CA.STATUS,
                CASE WHEN camast.catype = '017' THEN CA.AFACCTNO || CA.EXCODEID ELSE CA.AFACCTNO || CA.CODEID END SEACCTNO,
                CASE WHEN camast.catype = '017' THEN CA.AFACCTNO || CA.CODEID else CA.AFACCTNO || (CASE WHEN CAMAST.EXCODEID IS NULL THEN CAMAST.CODEID ELSE CAMAST.EXCODEID END) end EXSEACCTNO,
                SYM.PARVALUE PARVALUE, EXSYM.PARVALUE EXPARVALUE, CAMAST.REPORTDATE REPORTDATE, CAMAST.ACTIONDATE ,CAMAST.ACTIONDATE  POSTINGDATE,
                      (CASE WHEN SUBSTR(CF.custodycd,4,1) = 'F' AND CAMAST.catype ='010'
                            THEN to_char( 'Cash dividend, '||SYM.SYMBOL ||', exdate on ' || to_char (camast.reportdate,'DD/MM/YYYY')||', yield ' ||camast.DEVIDENTRATE ||'%, '|| cf.fullname )
                      WHEN NVL(SUBSTR(CF.custodycd,4,1),'C') in('C','P') AND CAMAST.catype ='010'
                            THEN to_char( 'Co tuc bang tien, '||SYM.SYMBOL ||', ngay chot ' || to_char (camast.reportdate,'DD/MM/YYYY')||', ty le ' ||camast.DEVIDENTRATE ||'%, '|| cf.fullname )
                      WHEN SUBSTR(CF.custodycd,4,1) = 'F' AND CAMAST.catype ='011'
                            THEN to_char( 'Dividend in kind, '||SYM.SYMBOL ||' , exdate on ' || to_char (camast.reportdate,'DD/MM/YYYY')||', ratio ' ||camast.DEVIDENTSHARES ||', '|| cf.fullname )
                      WHEN NVL(SUBSTR(CF.custodycd,4,1),'C') in('C','P') AND CAMAST.catype ='011'
                            THEN to_char( 'Co tuc bang co phieu, '||SYM.SYMBOL ||', ngay chot ' || to_char (camast.reportdate,'DD/MM/YYYY')||', ty le ' ||camast.DEVIDENTSHARES ||', '|| cf.fullname )
                      WHEN SUBSTR(CF.custodycd,4,1) = 'F' AND CAMAST.catype ='014'
                            THEN  to_char('Secondary offer shares, '||SYM.SYMBOL ||', Exdate on ' || to_char (camast.reportdate,'DD/MM/YYYY')||', ratio ' ||camast.RIGHTOFFRATE ||', '|| cf.fullname  )
                      WHEN NVL(SUBSTR(CF.custodycd,4,1),'C')  in('C','P') AND CAMAST.catype ='014'
                            THEN  to_char('Co phieu mua them, '||SYM.SYMBOL ||', ngay chot ' || to_char (camast.reportdate,'DD/MM/YYYY')||', ty le ' ||camast.RIGHTOFFRATE ||', '|| cf.fullname  )
                      WHEN NVL(SUBSTR(CF.custodycd,4,1),'C')  in('C','P') AND CAMAST.catype ='021'
                            THEN  to_char('Co phieu thuong, '||SYM.SYMBOL ||', ngay chot ' || to_char (camast.reportdate,'DD/MM/YYYY')||', ty le ' ||camast.DEVIDENTSHARES ||', '|| cf.fullname  )
                      WHEN NVL(SUBSTR(CF.custodycd,4,1),'C')  = 'F' AND CAMAST.catype ='021'
                            THEN  to_char('Bonus share, '||SYM.SYMBOL ||', exdate on ' || to_char (camast.reportdate,'DD/MM/YYYY')||', Rate ' ||camast.DEVIDENTSHARES ||', '|| cf.fullname  )
                      WHEN SUBSTR(CF.custodycd,4,1) = 'F' AND CAMAST.catype ='012'  THEN  to_char('Stock split, '||SYM.SYMBOL ||', exdate on ' || to_char (camast.reportdate,'DD/MM/YYYY')||', ratio ' ||camast.SPLITRATE ||', '|| cf.fullname  )
                      WHEN SUBSTR(CF.custodycd,4,1) = 'F' AND CAMAST.catype ='013'  THEN  to_char('Stock merge, '||SYM.SYMBOL ||', exdate on ' || to_char (camast.reportdate,'DD/MM/YYYY')||', ratio ' ||camast.SPLITRATE ||', '|| cf.fullname  )
                      WHEN NVL(SUBSTR(CF.custodycd,4,1),'C')  in ('C','P') AND CAMAST.catype ='013'  THEN  to_char('Gop co phieu, '||SYM.SYMBOL ||', ngay chot ' || to_char (camast.reportdate,'DD/MM/YYYY')||', ty le ' ||camast.SPLITRATE ||', '|| cf.fullname  )
                      else  camast.description END)description, camast.taskcd,
                      (CASE WHEN TYP.VAT='Y' THEN SYS.VARVALUE*CA.AMT/100 ELSE 0 END) DUTYAMT, CF.FULLNAME, CF.IDCODE, CF.CUSTODYCD, cf.custid, SYM.TRADEPLACE, SYM.SECTYPE
                FROM caschd CA,
                    SBSECURITIES SYM, SBSECURITIES EXSYM, CAMAST, AFMAST AF , CFMAST CF , AFTYPE TYP, SYSVAR SYS
                WHERE CA.CAMASTID = CAMAST.CAMASTID AND CAMAST.CODEID = SYM.CODEID
                and camast.camastid =p_camastid
                AND nvl(CAMAST.EXCODEID,CAMAST.CODEID)  = EXSYM.CODEID
                AND CA.AFACCTNO = AF.ACCTNO AND AF.CUSTID = CF.CUSTID
                AND CA.DELTD ='N' AND CA.STATUS ='S' and CAMAST.STATUS ='X' --AND CA.ISCI ='N'
                AND CA.ISSE='N' AND CA.QTTY>0
                AND AF.ACTYPE = TYP.ACTYPE AND SYS.GRNAME='SYSTEM' AND SYS.VARNAME='CADUTY';*/
        SELECT seq_tllog.NEXTVAL,systemnums.C_BATCH_PREFIXED
                                 || LPAD (seq_BATCHTXNUM.NEXTVAL, 8, '0') txnum,
               CA.AUTOID, CA.BALANCE, replace(ca.CAMASTID,'.','') CAMASTID, CA.AFACCTNO,ca.catypevalue CATYPE, CA.CODEID,
               CA.EXCODEID, CA.QTTY, ROUND(CA.AMT) AMT, ROUND(CA.AQTTY) AQTTY,ROUND(CA.AAMT) AAMT, CA.SYMBOL, mst.status,
               CA.SEACCTNO,CA.EXSEACCTNO,CA.PARVALUE, CA.EXPARVALUE, CA.REPORTDATE ,CA.ACTIONDATE ,CA.POSTINGDATE,
               CA.description, CA.taskcd,
               CA.DUTYAMT, CA.FULLNAME, CA.IDCODE, CA.CUSTODYCD, cf.custid, SYM.TRADEPLACE, SYM.SECTYPE, CA.PITRATE,
               CASE WHEN NVL(CA.TOCODEID,'A')='A' THEN CA.CODEID ELSE CA.TOCODEID END TOCODEID
        FROM v_ca3351 ca,caschd mst, cfmast cf,sbsecurities sym
        where ca.codeid = sym.codeid and ca.autoid = mst.autoid
              and replace(ca.CAMASTID,'.','')= p_camastid
              and ca.custodycd = cf.custodycd;
        --commit;
        plog.debug(pkgctx, '  End log caexec_temp');
        --002.Thuc hien quyen dua tren du lieu temp
        SELECT TO_DATE (varvalue, systemnums.c_date_format)
                   INTO v_dtCURRDATE
                   FROM sysvar
                   WHERE grname = 'SYSTEM' AND varname = 'CURRDATE';
        p_txmsg.msgtype:='T';
        p_txmsg.local:='N';
        p_txmsg.tlid        := systemnums.c_system_userid;
        SELECT SYS_CONTEXT ('USERENV', 'HOST'),
                 SYS_CONTEXT ('USERENV', 'IP_ADDRESS', 15)
          INTO p_txmsg.wsname, p_txmsg.ipaddress
        FROM DUAL;
        p_txmsg.off_line    := 'N';
        p_txmsg.deltd       := txnums.c_deltd_txnormal;
        p_txmsg.txstatus    := txstatusnums.c_txcompleted;
        p_txmsg.msgsts      := '0';
        p_txmsg.ovrsts      := '0';
        p_txmsg.batchname   := 'CAEXECBF';
        p_txmsg.txdate:=v_dtCURRDATE;
        p_txmsg.busdate:=v_dtCURRDATE;
        p_txmsg.tltxcd:='3351';

        --*1. Tao tllog
        plog.debug(pkgctx, '  Begin log tllog');
        INSERT /*+ append */ INTO tllogall(autoid, txnum, txdate, txtime, brid, tlid,
                offid, ovrrqs, chid, chkid, tltxcd, ibt, brid2, tlid2, ccyusage,off_line,
                deltd, brdate, busdate, txdesc, ipaddress,wsname, txstatus, msgsts,
                ovrsts, batchname, msgamt,msgacct, chktime, offtime)
        select
               REC.TLAUTOID,
               rec.txnum,--p_txmsg.txnum,
               TO_DATE(p_txmsg.txdate, systemnums.C_DATE_FORMAT),
               TO_CHAR(SYSDATE,systemnums.C_TIME_FORMAT),--p_txmsg.txtime,
               substr(rec.AFACCTNO,1,4),--p_txmsg.brid,
               p_txmsg.tlid,
               p_txmsg.offid,
               p_txmsg.ovrrqd,
               p_txmsg.chid,
               p_txmsg.chkid,
               p_txmsg.tltxcd,
               p_txmsg.ibt,
               p_txmsg.brid2,
               p_txmsg.tlid2,
               p_txmsg.ccyusage,
               p_txmsg.off_line,
               p_txmsg.deltd,
               TO_DATE(p_txmsg.txdate, systemnums.C_DATE_FORMAT),
               TO_DATE(p_txmsg.busdate, systemnums.C_DATE_FORMAT),
               rec.DESCRIPTION,--NVL(p_txmsg.txfields('30').value,p_txmsg.txdesc),
               p_txmsg.ipaddress,
               p_txmsg.wsname,
               p_txmsg.txstatus,
               p_txmsg.msgsts,
               p_txmsg.ovrsts,
               p_txmsg.batchname,
               rec.AMT,--p_txmsg.txfields('10').value ,
               rec.AFACCTNO,--p_txmsg.txfields('03').value ,
               decode(p_txmsg.chktime,NULL,TO_CHAR(SYSDATE,systemnums.C_TIME_FORMAT),p_txmsg.chktime),
               decode(p_txmsg.offtime,NULL,TO_CHAR(SYSDATE,systemnums.C_TIME_FORMAT),p_txmsg.offtime)
        from caexec_temp rec where camastid =p_camastid;
        --commit;
        plog.debug(pkgctx, '  End log tllog');
        --*2. Insert vao tllogall

        --*3. Insert vao cac bang tran
        plog.debug(pkgctx, '  Begin log SETRAN cr Trade');
        INSERT INTO SETRANA(TXNUM,TXDATE,ACCTNO,TXCD,NAMT,CAMT,ACCTREF,DELTD,REF,AUTOID,TLTXCD,BKDATE,TRDESC)
                select rec.txnum, TO_DATE (p_txmsg.txdate, systemnums.C_DATE_FORMAT),rec.SEACCTNO,'0012',ROUND(rec.QTTY,0),NULL,rec.CAMASTID,p_txmsg.deltd,rec.CAMASTID,seq_SETRAN.NEXTVAL,p_txmsg.tltxcd,p_txmsg.busdate,'' || '' || ''
                from caexec_temp rec where camastid =p_camastid and  rec.QTTY>0;
        --commit;
        INSERT INTO setran_gen (CUSTODYCD,CUSTID,
                            TXNUM,TXDATE,ACCTNO,TXCD,NAMT,CAMT,ACCTREF,DELTD,REF,AUTOID,TLTXCD,BUSDATE,TRDESC,
                            TXTIME,BRID,TLID,OFFID,CHID,AFACCTNO,SYMBOL,
                            SECTYPE,TRADEPLACE,TXTYPE,FIELD,CODEID,TLLOG_AUTOID,TXDESC)
        select REC.custodycd, REC.custid,
                      rec.txnum, TO_DATE (p_txmsg.txdate, systemnums.C_DATE_FORMAT),rec.SEACCTNO,'0012',ROUND(rec.QTTY,0),NULL,rec.CAMASTID,p_txmsg.deltd,rec.CAMASTID,seq_SETRAN.NEXTVAL,p_txmsg.tltxcd,p_txmsg.busdate,'' || '' || '',
            TO_CHAR(SYSDATE,systemnums.C_TIME_FORMAT), p_txmsg.brid, p_txmsg.tlid, p_txmsg.offid, p_txmsg.chid,REC.afacctno, REC.symbol,
            REC.sectype, REC.tradeplace, 'C', 'TRADE', REC.codeid ,REC.TLAUTOID, rec.DESCRIPTION trdesc
        from caexec_temp rec where camastid =p_camastid and  rec.QTTY>0;
        --commit;
        plog.debug(pkgctx, '  End  log SETRAN cr trade');
        plog.debug(pkgctx, '  Begin log SETRAN dr receiving');
        INSERT INTO SETRANA(TXNUM,TXDATE,ACCTNO,TXCD,NAMT,CAMT,ACCTREF,DELTD,REF,AUTOID,TLTXCD,BKDATE,TRDESC)
                select rec.txnum, TO_DATE (p_txmsg.txdate, systemnums.C_DATE_FORMAT),rec.SEACCTNO,'0015',ROUND(rec.QTTY,0),NULL,rec.CAMASTID,p_txmsg.deltd,rec.CAMASTID,seq_SETRAN.NEXTVAL,p_txmsg.tltxcd,p_txmsg.busdate,'' || '' || ''
                from caexec_temp rec where rec.QTTY>0;
        --commit;
        INSERT INTO setran_gen (CUSTODYCD,CUSTID,
                            TXNUM,TXDATE,ACCTNO,TXCD,NAMT,CAMT,ACCTREF,DELTD,REF,AUTOID,TLTXCD,BUSDATE,TRDESC,
                            TXTIME,BRID,TLID,OFFID,CHID,AFACCTNO,SYMBOL,
                            SECTYPE,TRADEPLACE,TXTYPE,FIELD,CODEID,TLLOG_AUTOID,TXDESC)
        select REC.custodycd, REC.custid,
                      rec.txnum, TO_DATE (p_txmsg.txdate, systemnums.C_DATE_FORMAT),rec.SEACCTNO,'0015',ROUND(rec.QTTY,0),NULL,rec.CAMASTID,p_txmsg.deltd,rec.CAMASTID,seq_SETRAN.NEXTVAL,p_txmsg.tltxcd,p_txmsg.busdate,'' || '' || '',
            TO_CHAR(SYSDATE,systemnums.C_TIME_FORMAT), p_txmsg.brid, p_txmsg.tlid, p_txmsg.offid, p_txmsg.chid,REC.afacctno, REC.symbol,
            REC.sectype, REC.tradeplace, 'D', 'RECEIVING', REC.codeid ,REC.TLAUTOID, rec.DESCRIPTION trdesc
        from caexec_temp rec where rec.QTTY>0;
        --commit;
        plog.debug(pkgctx, '  End  log SETRAN dr receiving');
        plog.debug(pkgctx, '  Begin log SETRAN dr trade aqtty');
        INSERT INTO SETRANA(TXNUM,TXDATE,ACCTNO,TXCD,NAMT,CAMT,ACCTREF,DELTD,REF,AUTOID,TLTXCD,BKDATE,TRDESC)
                select rec.txnum, TO_DATE (p_txmsg.txdate, systemnums.C_DATE_FORMAT),rec.EXSEACCTNO,'0040',ROUND(rec.AQTTY,0),NULL,rec.CAMASTID,p_txmsg.deltd,rec.CAMASTID,seq_SETRAN.NEXTVAL,p_txmsg.tltxcd,p_txmsg.busdate,'' || '' || ''
                from caexec_temp rec where camastid =p_camastid and  rec.AQTTY>0;
        --commit;
        INSERT INTO setran_gen (CUSTODYCD,CUSTID,
                            TXNUM,TXDATE,ACCTNO,TXCD,NAMT,CAMT,ACCTREF,DELTD,REF,AUTOID,TLTXCD,BUSDATE,TRDESC,
                            TXTIME,BRID,TLID,OFFID,CHID,AFACCTNO,SYMBOL,
                            SECTYPE,TRADEPLACE,TXTYPE,FIELD,CODEID,TLLOG_AUTOID,TXDESC)
        select REC.custodycd, REC.custid,
                      rec.txnum, TO_DATE (p_txmsg.txdate, systemnums.C_DATE_FORMAT),rec.EXSEACCTNO,'0040',ROUND(rec.AQTTY,0),NULL,rec.CAMASTID,p_txmsg.deltd,rec.CAMASTID,seq_SETRAN.NEXTVAL,p_txmsg.tltxcd,p_txmsg.busdate,'' || '' || '',
            TO_CHAR(SYSDATE,systemnums.C_TIME_FORMAT), p_txmsg.brid, p_txmsg.tlid, p_txmsg.offid, p_txmsg.chid,REC.afacctno, REC.symbol,
            REC.sectype, REC.tradeplace, 'D', 'TRADE', REC.codeid ,REC.TLAUTOID, rec.DESCRIPTION trdesc
        from caexec_temp rec where camastid =p_camastid and  rec.AQTTY>0;
        --commit;
        plog.debug(pkgctx, '  End  log SETRAN dr trade aqtty');

        --- HaiLT them de cap nhap vao SEPITLOG de phan bo chung khoan quyen su dung cho tinh thue TNCN
        --- doi voi CATYPE is gc_CA_CATYPE_STOCK_DIVIDEND OR gc_CA_CATYPE_KIND_STOCK

        SELECT VARVALUE INTO v_RightVATDuty FROM sysvar WHERE GRNAME='SYSTEM' AND VARNAME='RIGHTVATDUTY';

        INSERT INTO SEPITLOG(AUTOID,TXDATE,TXNUM,QTTY,MAPQTTY,CODEID,CAMASTID,ACCTNO,MODIFIEDDATE,AFACCTNO,PRICE,PITRATE,CATYPE)
                select SEQ_SEPITLOG.NEXTVAL, TO_DATE (p_txmsg.txdate, systemnums.C_DATE_FORMAT), rec.txnum,ROUND(rec.QTTY,0),0,
                --case when rec.catype='009' then rec.tocodeid else rec.codeid end codeid,
                 rec.tocodeid codeid,
                    rec.camastid, rec.afacctno||rec.tocodeid, TO_DATE (p_txmsg.txdate, systemnums.C_DATE_FORMAT), rec.afacctno,0, rec.pitrate, REC.CATYPE
                from caexec_temp rec, afmast af, cfmast cf
                where rec.afacctno = af.acctno and af.custid = cf.custid and cf.vat = 'Y'
                    and rec.camastid =p_camastid and  INSTR(v_RightVATDuty,rec.catype) > 0 ;

        --- End of HaiLT them de cap nhap vao SEPITLOG de phan bo chung khoan quyen su dung cho tinh thue TNCN

        --HaiLT them de update trong SEPITLOG doi voi nhung quyen chuyen co phieu sang co phieu khac

        SELECT nvl(instr((SELECT VARVALUE FROM sysvar WHERE GRNAME='SYSTEM' AND VARNAME='RIGHTCONVERTTYPE'),catype),0) into v_RightConvType  FROM CAMAST WHERE CAMASTID= p_camastid;
/*
        if v_RightConvType>0 then
            select codeid, tocodeid into v_codeid, v_tocodeid from caexec_temp where camastid =p_camastid;
            UPDATE SEPITLOG SET PCAMASTID=CAMASTID, CAMASTID= p_camastid, CODEID = v_tocodeid WHERE CODEID= v_codeid;
        end if;

*/
        begin
          select codeid, tocodeid into v_codeid, v_tocodeid from caexec_temp where camastid =p_camastid;

          SELECT VARVALUE into v_righttype FROM SYSVAR WHERE VARNAME='RIGHTCONVERTTYPE';


            if v_RightConvType>0 then

                for rec in (
                    SELECT * FROM SEPITLOG WHERE  CAMASTID=p_camastid AND
                        CAMASTID IN (SELECT CAMASTID  FROM CAMAST WHERE INSTR(v_righttype,CATYPE)>0 )
                    )
                loop
                    SELECT to_number(substr(DEVIDENTSHARES,0,instr(DEVIDENTSHARES,'/')-1)) / to_number(substr(DEVIDENTSHARES,instr(DEVIDENTSHARES,'/')+1)) into v_dblCARATE FROM CAMAST WHERE CAMASTID=p_camastid;

                    if rec.MAPQTTY>0 then
                        --- v_CARATE Ti le chia moi khi chuyen sang co phieu khac, de tinh lai so co phieu ban dau
                        --- Co phieu chua phan bo = co phieu chua phan bo x ti le chia (v_dblCARATE)
                        insert into sepitlog (AUTOID,TXDATE,TXNUM,QTTY,MAPQTTY,CODEID,PCAMASTID,CAMASTID,ACCTNO,MODIFIEDDATE,AFACCTNO,PRICE,PITRATE,CARATE,CATYPE)
                          values(SEQ_SEPITLOG.NEXTVAL, TO_DATE (rec.txdate, 'DD/MM/RRRR'),'', to_number(rec.QTTY-rec.MAPQTTY) * v_dblCARATE,0, v_tocodeid, rec.CAMASTID,p_txmsg.txfields('02').value,
                              rec.ACCTNO, TO_DATE (p_txmsg.txdate, 'DD/MM/RRRR'), rec.AFACCTNO, rec.PRICE, rec.PITRATE,to_number(nvl(rec.CARATE,1)) * v_dblCARATE,REC.CATYPE) ;

                        UPDATE SEPITLOG SET QTTY=MAPQTTY
                            WHERE AUTOID=rec.AUTOID;

                    else

                        UPDATE SEPITLOG SET PCAMASTID=CAMASTID, QTTY= to_number(QTTY*v_dblCARATE),
                                CAMASTID= p_txmsg.txfields('02').value,
                                CODEID = v_tocodeid, CARATE=to_number(nvl(rec.CARATE,1)) * v_dblCARATE
                            WHERE AUTOID=rec.AUTOID;
                    end if;

                end loop;

            end if;
        exception when others then
            null;
        end;







        --END of HaiLT them de update trong SEPITLOG doi voi nhung quyen chuyen co phieu sang co phieu khac

        --*3. Cap nhat vao bang mast
        plog.debug(pkgctx, '  Begin log Update master table');
        for rec in (select tmp.*, chd.isci, chd.isse from caexec_temp tmp, caschd chd where tmp.autoid = chd.autoid)
        loop
            UPDATE SEMAST
             SET
               TRADE = TRADE - (ROUND(rec.AQTTY,0)), LAST_CHANGE = SYSTIMESTAMP
            WHERE ACCTNO=rec.EXSEACCTNO and rec.aqtty>0;

            UPDATE SEMAST
             SET
               TRADE = TRADE + (ROUND(rec.QTTY,0)),
               RECEIVING = RECEIVING - (ROUND(rec.QTTY,0)), LAST_CHANGE = SYSTIMESTAMP
            WHERE ACCTNO=rec.SEACCTNO and rec.QTTY>0;

            if rec.isci='Y' or rec.amt + rec.aamt=0 then
                update caschd set isse='Y', status ='C' where autoid = rec.autoid;
            else
                update caschd set isse='Y' where autoid = rec.autoid;
            end if;
        end loop;


        plog.debug(pkgctx, '  End log Update master table');

        --*4. Cap nhat extention
        --Neu khong con dong lich nao can thuc hien tien hoac chung khoan thi chuyen trang thai va backup su kie nquyen
        select count(1) into v_count from caschd
        where ((isci='N' and amt+aamt>0) or (isse='N' and qtty+aqtty>0))
        and camastid = p_camastid  and deltd <>'Y'
        AND status <> 'O';
        if v_count=0 then
            UPDATE CAMAST SET STATUS='C',LASTDATE = TO_DATE(p_txmsg.txdate, systemnums.C_DATE_FORMAT) WHERE CAMASTID=p_camastid;
            --Tinh ap dung cho cac truong hop dac biet
            for rec_mt in (
                select ca.*, sb.symbol from camast ca, sbsecurities sb where ca.codeid= sb.codeid
            )
            loop
                if rec_mt.catype ='012' or rec_mt.catype ='013' then --Tach va gop co phieu
                    UPDATE SBSECURITIES SET PARVALUE = PARVALUE * rec_mt.SPLITRATE WHERE CODEID=rec_mt.codeid;
                elsif rec_mt.catype ='019' then --Chuyen doi san giao dich
                    UPDATE SBSECURITIES SET TRADEPLACE =rec_mt.TOTRADEPLACE WHERE CODEID=rec_mt.codeid;
                    DELETE SECURITIES_TICKSIZE WHERE CODEID=rec_mt.codeid;
                    if rec_mt.TOTRADEPLACE='001' then --san HCM
                        INSERT INTO SECURITIES_TICKSIZE (AUTOID,CODEID,SYMBOL,TICKSIZE,FROMPRICE,TOPRICE,STATUS)
                        VALUES (SEQ_SECURITIES_TICKSIZE.NEXTVAL,rec_mt.codeid,rec_mt.symbol,100,0,49900,'Y');
                        INSERT INTO securities_ticksize (AUTOID,CODEID,SYMBOL,TICKSIZE,FROMPRICE,TOPRICE,STATUS)
                        VALUES (SEQ_SECURITIES_TICKSIZE.NEXTVAL,rec_mt.codeid,rec_mt.symbol,500,50000,99500,'Y');
                        INSERT INTO securities_ticksize (AUTOID,CODEID,SYMBOL,TICKSIZE,FROMPRICE,TOPRICE,STATUS)
                        VALUES (SEQ_SECURITIES_TICKSIZE.NEXTVAL,rec_mt.codeid,rec_mt.symbol,1000,100000,100000000000,'Y');
                        UPDATE  SECURITIES_INFO SET  TRADELOT ='10' WHERE CODEID = rec_mt.codeid;
                    else
                        INSERT INTO securities_ticksize (AUTOID,CODEID,SYMBOL,TICKSIZE,FROMPRICE,TOPRICE,STATUS)
                        VALUES (SEQ_SECURITIES_TICKSIZE.NEXTVAL,rec_mt.codeid,rec_mt.symbol,100,0,1000000000,'Y');
                        UPDATE  SECURITIES_INFO SET  TRADELOT ='100' WHERE CODEID = rec_mt.codeid;
                    end if;
                end if;
            end loop;
            --Thuc hien backup du lieu
            insert into camasthist select * from camast where CAMASTID =p_camastid;-- in (select camastid from caexec_temp) and status ='C';
            --commit;
            delete from camast where CAMASTID  =p_camastid;--in (select camastid from caexec_temp) and status ='C';
            --commit;
            insert into caschdhist select * from caschd where camastid  =p_camastid;--autoid in (select autoid from caexec_temp) and status ='C';
            --commit;
            delete from caschd where camastid =p_camastid;--autoid in (select autoid from caexec_temp) and status ='C';
            --commit;
        else
            --Tra ve trang thai cu cho su kien quyen
            --UPDATE CAMAST SET STATUS='I' WHERE CAMASTID=p_camastid;
            plog.debug(pkgctx,'Dang chay su kien khac');
            p_errcode:='-1';
            --commit;
        end if;
        delete from caexec_temp where camastid =p_camastid;
        --commit;
    end if;
    plog.setendsection(pkgctx, 'pr_exec_sec_cop_action');
exception when others then
    p_errcode:='-1';
    --p_errmessage:='Co loi he thong xay ra';
    plog.setendsection(pkgctx, 'pr_exec_sec_cop_action');
   --rollback;
    UPDATE CAMAST SET STATUS='I' WHERE CAMASTID=p_camastid;
    --commit;
end;

--PROCEDURE pr_send_cop_action (pv_refcursor in out pkg_report.ref_cursor,p_camastid varchar2)--, p_errcode in out varchar2, p_errmessage in out varchar2)
PROCEDURE pr_send_cop_action (p_camastid varchar2, p_errcode in out varchar2)
IS
p_txmsg               tx.msg_rectype;
v_dtCURRDATE date;
v_count number;
v_numcmt number;
i number;
BEGIN
    plog.setbeginsection(pkgctx, 'pr_send_cop_action');
    --open pv_refcursor for
    --    select sysdate from dual;
    --p_errcode:='0';
    --p_errmessage:='';
    select count(1) into v_count
    from camast a, sbsecurities b where a.codeid = b.codeid and a.status IN ('A','S','M') and a.deltd='N'
        and a.camastid = p_camastid;
    if v_count=0 THEN
        p_errcode:='-1';
        --p_errmessage:='Su kien quyen can xac nhan khong hop le!';
        plog.Error(pkgctx, 'Su kien quyen can xac nhan khong hop le :' || p_camastid );
        plog.setbeginsection(pkgctx, 'pr_send_cop_action');
        return;
    end if;
    select count(1) into v_count from casend_temp;
    if v_count=0 then
        --001.Tao du lieu temp de thuc hien
        plog.debug(pkgctx, 'Begin send caaction :' || p_camastid );
        plog.debug(pkgctx, '  Begin temporary update camast status :' || p_camastid );
        --UPDATE CAMAST SET STATUS='X',LASTDATE = TO_DATE(p_txmsg.txdate, systemnums.C_DATE_FORMAT) WHERE CAMASTID=p_camastid;
        --commit;
        plog.debug(pkgctx, '  End temporary update camast status :' || p_camastid );
        delete from casend_temp where camastid =p_camastid;
        --commit;
        plog.debug(pkgctx, '  Begin log casend_temp');
       insert into casend_temp (tlautoid, txnum, autoid, balance, camastid, afacctno,
       catype, codeid, excodeid, qtty, amt, aqtty, aamt,
       symbol, status, statuscd, seacctno, exseacctno,
       parvalue, exparvalue, reportdate, actiondate,
       description, custodycd, fullname, idcode, isrightoff,custid,TRADEPLACE, SECTYPE)
       SELECT seq_tllog.NEXTVAL,systemnums.C_BATCH_PREFIXED
                                 || LPAD (seq_BATCHTXNUM.NEXTVAL, 8, '0') txnum,
               ca.autoid, ca.balance, replace(ca.camastid,'.','') camastid, ca.afacctno,
               ca.catype, ca.codeid, ca.excodeid, ca.qtty, ca.amt, ca.aqtty, ca.aamt,
               ca.symbol, ca.status, ca.statuscd, ca.seacctno, ca.exseacctno,
               ca.parvalue, ca.exparvalue, ca.reportdate, ca.actiondate,
               ca.description, ca.custodycd, ca.fullname, ca.idcode, ca.isrightoff, af.custid, sb.tradeplace, sb.sectype
        FROM v_ca3380 CA, afmast af, sbsecurities sb where ca.afacctno = af.acctno and replace(ca.camastid,'.','') =p_camastid
            and ca.codeid = sb.codeid;
        --commit;
        plog.debug(pkgctx, '  End log casend_temp');
        --002.Thuc hien quyen dua tren du lieu temp
        SELECT TO_DATE (varvalue, systemnums.c_date_format)
                   INTO v_dtCURRDATE
                   FROM sysvar
                   WHERE grname = 'SYSTEM' AND varname = 'CURRDATE';
        p_txmsg.msgtype:='T';
        p_txmsg.local:='N';
        p_txmsg.tlid        := systemnums.c_system_userid;
        SELECT SYS_CONTEXT ('USERENV', 'HOST'),
                 SYS_CONTEXT ('USERENV', 'IP_ADDRESS', 15)
          INTO p_txmsg.wsname, p_txmsg.ipaddress
        FROM DUAL;
        p_txmsg.off_line    := 'N';
        p_txmsg.deltd       := txnums.c_deltd_txnormal;
        p_txmsg.txstatus    := txstatusnums.c_txcompleted;
        p_txmsg.msgsts      := '0';
        p_txmsg.ovrsts      := '0';
        p_txmsg.batchname   := 'CAEXECBF';
        p_txmsg.txdate:=v_dtCURRDATE;
        p_txmsg.busdate:=v_dtCURRDATE;
        p_txmsg.tltxcd:='3380';

        --*1. Tao tllog
        plog.debug(pkgctx, '  Begin log tllog');
        INSERT /*+ append */ INTO tllogall(autoid, txnum, txdate, txtime, brid, tlid,
                offid, ovrrqs, chid, chkid, tltxcd, ibt, brid2, tlid2, ccyusage,off_line,
                deltd, brdate, busdate, txdesc, ipaddress,wsname, txstatus, msgsts,
                ovrsts, batchname, msgamt,msgacct, chktime, offtime)
        select
               REC.TLAUTOID,
               rec.txnum,--p_txmsg.txnum,
               TO_DATE(p_txmsg.txdate, systemnums.C_DATE_FORMAT),
               TO_CHAR(SYSDATE,systemnums.C_TIME_FORMAT),--p_txmsg.txtime,
               substr(rec.AFACCTNO,1,4),--p_txmsg.brid,
               p_txmsg.tlid,
               p_txmsg.offid,
               p_txmsg.ovrrqd,
               p_txmsg.chid,
               p_txmsg.chkid,
               p_txmsg.tltxcd,
               p_txmsg.ibt,
               p_txmsg.brid2,
               p_txmsg.tlid2,
               p_txmsg.ccyusage,
               p_txmsg.off_line,
               p_txmsg.deltd,
               TO_DATE(p_txmsg.txdate, systemnums.C_DATE_FORMAT),
               TO_DATE(p_txmsg.busdate, systemnums.C_DATE_FORMAT),
               rec.DESCRIPTION,--NVL(p_txmsg.txfields('30').value,p_txmsg.txdesc),
               p_txmsg.ipaddress,
               p_txmsg.wsname,
               p_txmsg.txstatus,
               p_txmsg.msgsts,
               p_txmsg.ovrsts,
               p_txmsg.batchname,
               rec.AMT,--p_txmsg.txfields('10').value ,
               rec.AFACCTNO,--p_txmsg.txfields('03').value ,
               decode(p_txmsg.chktime,NULL,TO_CHAR(SYSDATE,systemnums.C_TIME_FORMAT),p_txmsg.chktime),
               decode(p_txmsg.offtime,NULL,TO_CHAR(SYSDATE,systemnums.C_TIME_FORMAT),p_txmsg.offtime)
        from casend_temp rec where camastid =p_camastid;
        --commit;
        plog.debug(pkgctx, '  End log tllog');
        --*2. Insert vao tllogall

        --*3. Insert vao cac bang tran
        plog.debug(pkgctx, '  Begin log CITRAN Cr Receiving');
        INSERT  INTO CITRANA(TXNUM,TXDATE,ACCTNO,TXCD,NAMT,CAMT,ACCTREF,DELTD,REF,AUTOID,TLTXCD,BKDATE,TRDESC)
                select rec.txnum, TO_DATE (p_txmsg.txdate, systemnums.C_DATE_FORMAT),rec.AFACCTNO,'0046',ROUND(rec.amt,0),NULL,rec.CAMASTID,p_txmsg.deltd,rec.CAMASTID,seq_CITRAN.NEXTVAL,p_txmsg.tltxcd,p_txmsg.busdate,'' || '' || ''
                from casend_temp rec where rec.amt>0;
        --commit;
        INSERT  INTO citran_gen (CUSTODYCD,CUSTID,
                                         TXNUM,TXDATE,ACCTNO,TXCD,NAMT,CAMT,ACCTREF,DELTD,REF,AUTOID,TLTXCD,BUSDATE,TRDESC,
                                         TXTIME,BRID,TLID,OFFID,CHID,DFACCTNO,OLD_DFACCTNO,TXTYPE,FIELD,TLLOG_AUTOID,TXDESC)
        select        REC.custodycd, REC.custid,
                      rec.txnum, TO_DATE (p_txmsg.txdate, systemnums.C_DATE_FORMAT), rec.AFACCTNO, '0046', ROUND(rec.amt,0),NULL, rec.CAMASTID, p_txmsg.deltd, rec.CAMASTID,seq_CITRAN.NEXTVAL,p_txmsg.tltxcd, p_txmsg.busdate,'' || '' || '',
                      TO_CHAR(SYSDATE,systemnums.C_TIME_FORMAT), p_txmsg.brid, p_txmsg.tlid, p_txmsg.offid, p_txmsg.chid,'' dfacctno,'' old_dfacctno,'C', 'RECEIVING' ,REC.TLAUTOID, rec.DESCRIPTION trdesc
        from casend_temp rec where rec.amt>0;

        --COMMIT;
        plog.debug(pkgctx, '  End  log CITRAN Cr receiving');

        plog.debug(pkgctx, '  Begin log SETRAN cr receiving');
        INSERT INTO SETRANA(TXNUM,TXDATE,ACCTNO,TXCD,NAMT,CAMT,ACCTREF,DELTD,REF,AUTOID,TLTXCD,BKDATE,TRDESC)
                select rec.txnum, TO_DATE (p_txmsg.txdate, systemnums.C_DATE_FORMAT),rec.SEACCTNO,'0016',ROUND(rec.QTTY,0),NULL,rec.CAMASTID,p_txmsg.deltd,rec.CAMASTID,seq_SETRAN.NEXTVAL,p_txmsg.tltxcd,p_txmsg.busdate,'' || '' || ''
                from casend_temp rec where rec.QTTY>0;
        --commit;
        INSERT INTO setran_gen (CUSTODYCD,CUSTID,
                            TXNUM,TXDATE,ACCTNO,TXCD,NAMT,CAMT,ACCTREF,DELTD,REF,AUTOID,TLTXCD,BUSDATE,TRDESC,
                            TXTIME,BRID,TLID,OFFID,CHID,AFACCTNO,SYMBOL,
                            SECTYPE,TRADEPLACE,TXTYPE,FIELD,CODEID,TLLOG_AUTOID,TXDESC)
        select REC.custodycd, REC.custid,
                      rec.txnum, TO_DATE (p_txmsg.txdate, systemnums.C_DATE_FORMAT),rec.SEACCTNO,'0016',ROUND(rec.QTTY,0),NULL,rec.CAMASTID,p_txmsg.deltd,rec.CAMASTID,seq_SETRAN.NEXTVAL,p_txmsg.tltxcd,p_txmsg.busdate,'' || '' || '',
            TO_CHAR(SYSDATE,systemnums.C_TIME_FORMAT), p_txmsg.brid, p_txmsg.tlid, p_txmsg.offid, p_txmsg.chid,REC.afacctno, REC.symbol,
            REC.sectype, REC.tradeplace, 'C', 'RECEIVING', REC.codeid ,REC.TLAUTOID, rec.DESCRIPTION trdesc
        from casend_temp rec where rec.QTTY>0;
        --commit;
        plog.debug(pkgctx, '  End  log SETRAN cr receiving');

        plog.debug(pkgctx, '  Begin log SETRAN cr netting');
        INSERT INTO SETRANA(TXNUM,TXDATE,ACCTNO,TXCD,NAMT,CAMT,ACCTREF,DELTD,REF,AUTOID,TLTXCD,BKDATE,TRDESC)
                select rec.txnum, TO_DATE (p_txmsg.txdate, systemnums.C_DATE_FORMAT),rec.EXSEACCTNO,'0019',ROUND(rec.AQTTY,0),NULL,rec.CAMASTID,p_txmsg.deltd,rec.CAMASTID,seq_SETRAN.NEXTVAL,p_txmsg.tltxcd,p_txmsg.busdate,'' || '' || ''
                from casend_temp rec where rec.AQTTY>0;
        --commit;
        INSERT INTO setran_gen (CUSTODYCD,CUSTID,
                            TXNUM,TXDATE,ACCTNO,TXCD,NAMT,CAMT,ACCTREF,DELTD,REF,AUTOID,TLTXCD,BUSDATE,TRDESC,
                            TXTIME,BRID,TLID,OFFID,CHID,AFACCTNO,SYMBOL,
                            SECTYPE,TRADEPLACE,TXTYPE,FIELD,CODEID,TLLOG_AUTOID,TXDESC)
        select REC.custodycd, REC.custid,
                      rec.txnum, TO_DATE (p_txmsg.txdate, systemnums.C_DATE_FORMAT),rec.EXSEACCTNO,'0019',ROUND(rec.AQTTY,0),NULL,rec.CAMASTID,p_txmsg.deltd,rec.CAMASTID,seq_SETRAN.NEXTVAL,p_txmsg.tltxcd,p_txmsg.busdate,'' || '' || '',
            TO_CHAR(SYSDATE,systemnums.C_TIME_FORMAT), p_txmsg.brid, p_txmsg.tlid, p_txmsg.offid, p_txmsg.chid,REC.afacctno, REC.symbol,
            REC.sectype, REC.tradeplace, 'C', 'NETTING', REC.codeid ,REC.TLAUTOID, rec.DESCRIPTION trdesc
        from casend_temp rec where rec.AQTTY>0;
        --commit;
        plog.debug(pkgctx, '  End  log SETRAN cr netting');

        --*3. Cap nhat vao bang mast
        plog.debug(pkgctx, '  Begin log Update master table');
        for rec in (
            --select * from caschd where camastid=p_camastid and status ='A' and deltd <> 'Y'
            select * from casend_temp where camastid=p_camastid
        )
        loop
            update cimast set receiving = receiving + ROUND(rec.amt,0) where acctno = rec.afacctno;
            update semast set receiving = receiving + ROUND(rec.QTTY,0) where acctno =rec.SEACCTNO;--afacctno = rec.afacctno and  codeid = rec.codeid;
            update semast set NETTING = NETTING + ROUND(rec.AQTTY,0) where acctno =rec.EXSEACCTNO;--afacctno = rec.afacctno and codeid = rec.excodeid;
        end loop;

        update caschd set status ='S' where camastid = p_camastid and deltd <> 'Y';-- and status ='A';
        update camast set status ='S' where camastid = p_camastid and deltd <> 'Y';-- and status ='X';
    end if;
    delete from casend_temp where camastid =p_camastid;
    --commit;
    plog.setendsection(pkgctx, 'pr_exec_money_cop_action');

exception when others then
    p_errcode:='-1';
    --p_errmessage:='Co loi he thong xay ra';
    plog.setendsection(pkgctx, 'pr_exec_money_cop_action');
   --rollback;
    --UPDATE CAMAST SET STATUS='A' WHERE CAMASTID=p_camastid;
    --commit;
end;


/*PROCEDURE pr_allocate_right_stock(p_orgorderid varchar2)
   IS
   v_dtCURRDATE DATE;
   v_parvalue number(20,4);
   v_dblPrice number(20,4);
   v_dblDelPrice number(20,4);
   v_dblDelMatchQtty number(20,4);
   v_deltd varchar2(1);
   v_recSTSCHD number(20,4);
   v_rec number(20,4);
BEGIN
---
    plog.setbeginsection(pkgctx, 'pr_allocate_right_stock');

    SELECT TO_DATE (varvalue, systemnums.c_date_format)
                   INTO v_dtCURRDATE
                   FROM sysvar
                   WHERE grname = 'SYSTEM' AND varname = 'CURRDATE';

    plog.debug (pkgctx, 'begin pr_allocate_right_stock ' ||v_dtCURRDATE );


    SELECT DELTD,MATCHPRICE,MATCHQTTY into v_deltd,v_dblDelPrice,v_dblDelMatchQtty FROM
        (SELECT * FROM IOD WHERE ORGORDERID=p_orgorderid ORDER BY TXTIME DESC) WHERE ROWNUM=1 ;
        plog.debug (pkgctx, 'pr_allocate_right_stock, DELTD= ' ||v_deltd );
    ---Xoa lenh khop thi cap nhap lai ARIGHT va RIGHTQTTY
    if v_deltd<>'N' then

        for recSTSCHD in (
            SELECT * FROM (
                SELECT * FROM STSCHD WHERE DUETYPE='RM' AND TXDATE= v_dtCURRDATE and orgorderid=p_orgorderid ORDER BY AUTOID DESC ) WHERE ROWNUM=1
        )
        LOOP
            SELECT PARVALUE INTO v_parvalue from sbsecurities where codeid=recSTSCHD.codeid;

            if v_dblDelPrice < v_parvalue then
                v_parvalue := v_dblDelPrice;
            end if;

            for rec in (
                SELECT * FROM SEPITLOG WHERE AFACCTNO=recSTSCHD.afacctno AND CODEID=recSTSCHD.codeid AND MAPQTTY>0 ORDER BY TXDATE, AUTOID
            )
            loop
                --- Neu so luong da phan bo > so luong xoa' khop
                if v_dblDelMatchQtty <= rec.MAPQTTY then
                    UPDATE STSCHD SET RIGHTQTTY= RIGHTQTTY - v_dblDelMatchQtty, ARIGHT=ARIGHT - v_dblDelMatchQtty * rec.CARATE * v_parvalue * rec.PITRATE/100
                        WHERE AUTOID=recSTSCHD.AUTOID;

                    UPDATE SEPITLOG SET MAPQTTY= MAPQTTY - v_dblDelMatchQtty, STATUS='N'  WHERE AUTOID=rec.AUTOID;

                    DELETE FROM SEPITALLOCATE WHERE CAMASTID = rec.CAMASTID AND AFACCTNO = rec.AFACCTNO AND CODEID = rec.CODEID AND
                        ORGORDERID = p_orgorderid AND QTTY= v_dblDelMatchQtty AND TXNUM = rec.TXNUM;

                    exit;

                else

                    UPDATE STSCHD SET RIGHTQTTY= RIGHTQTTY- rec.MAPQTTY, ARIGHT=ARIGHT - rec.MAPQTTY * rec.CARATE * v_parvalue * rec.PITRATE/100
                        WHERE AUTOID=recSTSCHD.AUTOID;

                    UPDATE SEPITLOG SET MAPQTTY= MAPQTTY - rec.MAPQTTY, STATUS='N'  WHERE AUTOID=rec.AUTOID;

                    DELETE FROM SEPITALLOCATE WHERE CAMASTID = rec.CAMASTID AND AFACCTNO = rec.AFACCTNO AND CODEID = rec.CODEID AND
                        ORGORDERID = p_orgorderid AND QTTY= rec.MAPQTTY AND TXNUM = rec.TXNUM;

                    v_dblDelMatchQtty:=v_dblDelMatchQtty - rec.MAPQTTY;

                end if;

            end loop;

        END LOOP;


    else -- lenh khop

        for recSTSCHD in (
            SELECT * FROM STSCHD WHERE DUETYPE='RM' AND STATUS='N' AND TXDATE= v_dtCURRDATE  AND
                AFACCTNO IN (SELECT AFACCTNO FROM SEPITLOG WHERE STATUS <>'C' AND DELTD <>'Y') and orgorderid=p_orgorderid
                 --   ORDER BY AFACCTNO,CODEID,ORGORDERID
        )
        LOOP

            plog.debug (pkgctx, 'LOOP recSTSCHD' || recSTSCHD.orgorderid);

            SELECT PARVALUE INTO v_parvalue from sbsecurities where codeid=recSTSCHD.codeid;


            SELECT MATCHPRICE INTO v_dblPrice FROM (
                SELECT * FROM IOD WHERE ORGORDERID=p_orgorderid ORDER BY TXTIME DESC) WHERE ROWNUM=1 ;
            plog.debug (pkgctx, 'MATCH: ' || v_dblPrice);

            --Lay them gia khop
            --if recSTSCHD.amt/recSTSCHD.qtty < v_parvalue then
            plog.debug (pkgctx, 'v_parvalue: ' || v_parvalue);
            if v_dblPrice<v_parvalue then
                --v_parvalue:=recSTSCHD.amt/recSTSCHD.qtty;
                v_parvalue:=v_dblPrice;
            end if;

            v_recSTSCHD:=recSTSCHD.QTTY - recSTSCHD.RIGHTQTTY;

            for rec in (
                SELECT * FROM SEPITLOG WHERE AFACCTNO=recSTSCHD.afacctno AND CODEID=recSTSCHD.codeid AND QTTY-MAPQTTY>0 ORDER BY TXDATE, AUTOID
                    --AND STATUS <> 'C' AND DELTD <> 'Y'

            )
            loop
                 plog.debug (pkgctx, 'LOOP rec KL Khop : ' || recSTSCHD.QTTY || ' - ' || recSTSCHD.RIGHTQTTY ||
                 '        KL REC: ' || rec.QTTY || ' - ' ||rec.MAPQTTY);

--                 v_rec:=rec.QTTY-rec.MAPQTTY;

                IF v_recSTSCHD < rec.QTTY-rec.MAPQTTY then

                    plog.debug (pkgctx, 'LOOP rec 1' || recSTSCHD.orgorderid || ' KL Khop: ' || recSTSCHD.QTTY || ' - ' || recSTSCHD.RIGHTQTTY);

                    UPDATE STSCHD SET RIGHTQTTY= RIGHTQTTY + v_recSTSCHD,
                        ARIGHT = ARIGHT + v_recSTSCHD * rec.CARATE * v_parvalue * rec.PITRATE/100
                        WHERE DUETYPE='RM' AND ORGORDERID=recSTSCHD.orgorderid AND AFACCTNO=rec.afacctno AND CODEID=rec.codeid AND
                        DELTD <> 'Y' AND STATUS='N';

                    UPDATE SEPITLOG SET MAPQTTY= MAPQTTY + v_recSTSCHD
                        WHERE AFACCTNO=rec.afacctno AND CODEID=rec.codeid AND TXDATE= rec.txdate AND TXNUM=rec.txnum;

                    INSERT INTO SEPITALLOCATE (CAMASTID,AFACCTNO,CODEID,PITRATE,QTTY,PRICE,ARIGHT,ORGORDERID,TXNUM,TXDATE,CARATE) VALUES(
                            rec.CAMASTID, rec.AFACCTNO, rec.CODEID, rec.PITRATE,v_recSTSCHD, v_parvalue, v_recSTSCHD * rec.CARATE * v_parvalue * rec.PITRATE/100,
                            recSTSCHD.orgorderid, rec.TXNUM,recSTSCHD.TXDATE,rec.CARATE);

                    EXIT;

                else --recSTSCHD.QTTY  - recSTSCHD.RIGHTQTTY >= rec.QTTY-rec.MAPQTTY then
                    plog.debug (pkgctx, 'LOOP rec 2  KL Khop: ' || rec.qtty || ' - ' || rec.mapqtty);

                    UPDATE STSCHD SET RIGHTQTTY = RIGHTQTTY + rec.qtty - rec.mapqtty,
                        ARIGHT = ARIGHT + (rec.qtty - rec.mapqtty) * rec.CARATE * v_parvalue * rec.PITRATE/100
                        WHERE DUETYPE='RM' AND ORGORDERID=recSTSCHD.orgorderid AND AFACCTNO=rec.afacctno AND CODEID=rec.codeid AND
                        DELTD <> 'Y' AND STATUS='N';

                    UPDATE SEPITLOG SET MAPQTTY = MAPQTTY + rec.qtty - rec.mapqtty, STATUS='C' WHERE
                        AFACCTNO=rec.afacctno AND CODEID=rec.codeid AND TXDATE= rec.txdate AND TXNUM=rec.txnum;

                    INSERT INTO SEPITALLOCATE (CAMASTID,AFACCTNO,CODEID,PITRATE,QTTY,PRICE,ARIGHT,ORGORDERID,TXNUM,TXDATE,CARATE) VALUES(
                            rec.CAMASTID, rec.AFACCTNO, rec.CODEID, rec.PITRATE,rec.qtty - rec.mapqtty, v_parvalue, (rec.qtty - rec.mapqtty) * rec.CARATE * v_parvalue * rec.PITRATE/100,
                            recSTSCHD.orgorderid, rec.TXNUM,recSTSCHD.TXDATE,rec.CARATE);

                    v_recSTSCHD:=v_recSTSCHD- (rec.qtty - rec.mapqtty);

                end if;


            End loop;



        --UPDATE STSCHD SET RIGHTQTTY= DECODE(SIGN(QTTY-rec.qtty-rec.mapqtty), 1, rec.qtty-rec.mapqtty,0,rec.qtty-rec.mapqtty,-, QTTY)
        --WHERE DUETYPE='RM' AND AFACCTNO=rec.afacctno AND CODEID=rec.codeid AND DELTD <> 'Y' AND STATUS='N';
       End loop;
    end if;
   --commit;

   EXCEPTION WHEN OTHERS THEN
    plog.debug(pkgctx,'pr_allocate_right_stock: ' || dbms_utility.format_error_backtrace);
    plog.setendsection(pkgctx, 'pr_allocate_right_stock');
   --rollback;

END;*/


PROCEDURE pr_allocate_right_stock(p_orgorderid varchar2)
   IS
   v_dtCURRDATE DATE;
   v_parvalue number(20,4);
   v_dblPrice number(20,4);
   v_dblDelPrice number(20,4);
   v_dblDelMatchQtty number(20,4);
   v_deltd varchar2(1);
   v_recSTSCHD number(20,4);
   v_costprice number;
BEGIN
---
    plog.setbeginsection(pkgctx, 'pr_allocate_right_stock');

    SELECT TO_DATE (varvalue, systemnums.c_date_format)
                   INTO v_dtCURRDATE
                   FROM sysvar
                   WHERE grname = 'SYSTEM' AND varname = 'CURRDATE';

    plog.debug (pkgctx, 'begin pr_allocate_right_stock ' ||v_dtCURRDATE );

    for recIOD in (
        SELECT *  FROM (SELECT IOD.*, od.afacctno FROM IOD,stschd od WHERE iod.orgorderid= od.orgorderid and od.duetype='RM' and iod.ORGORDERID=p_orgorderid ORDER BY iod.TXTIME DESC, iod.TXNUM DESC) WHERE ROWNUM=1
    )
    loop
        v_deltd:= recIOD.deltd;
        if v_deltd<>'N' then --Xoa lenh khop
            SELECT PARVALUE INTO v_parvalue from sbsecurities where codeid=recIOD.codeid;
            v_dblDelPrice:= recIOD.matchprice;
            if v_dblDelPrice < v_parvalue then
                v_parvalue := v_dblDelPrice;
            end if;

            for rec in (
                select * from SEPITALLOCATE where txnum= recIOD.txnum and txdate = recIOD.txdate
            )
            loop
                UPDATE STSCHD SET RIGHTQTTY= RIGHTQTTY - rec.QTTY, ARIGHT=ARIGHT - rec.ARIGHT
                WHERE  orgorderid=rec.orgorderid and duetype ='RM';
                update SEPITLOG set MAPQTTY= MAPQTTY - rec.QTTY where autoid=rec.sepitlog_id;
            end loop;
            delete from SEPITALLOCATE where txnum= recIOD.txnum and txdate = recIOD.txdate;

        else --Lenh khop
            SELECT PARVALUE INTO v_parvalue from sbsecurities where codeid=recIOD.codeid;
            plog.debug (pkgctx, 'LOOP rec iod: ' || recIOD.orgorderid);

            SELECT PARVALUE INTO v_parvalue from sbsecurities where codeid=recIOD.codeid;
            v_dblPrice:= recIOD.MATCHPRICE;

            plog.debug (pkgctx, 'MATCH: ' || v_dblPrice);
            plog.debug (pkgctx, 'v_parvalue: ' || v_parvalue);

            if v_dblPrice<v_parvalue then
                v_parvalue:=v_dblPrice;
            end if;

            v_recSTSCHD:=recIOD.matchqtty;
            for rec in (
                SELECT * FROM SEPITLOG WHERE AFACCTNO=recIOD.afacctno
                AND CODEID=recIOD.codeid AND QTTY-MAPQTTY>0 AND DELTD <> 'Y' ORDER BY TXDATE, AUTOID
            )
            loop
                 IF v_recSTSCHD < rec.QTTY-rec.MAPQTTY then

                    UPDATE STSCHD SET RIGHTQTTY= RIGHTQTTY + v_recSTSCHD,
                        ARIGHT = ARIGHT + v_recSTSCHD * rec.CARATE * v_parvalue * rec.PITRATE/100
                        WHERE DUETYPE='RM' AND ORGORDERID=reciod.orgorderid
                        AND AFACCTNO=rec.afacctno AND CODEID=rec.codeid
                        AND DELTD <> 'Y' AND STATUS='N';

                    UPDATE SEPITLOG SET MAPQTTY= MAPQTTY + v_recSTSCHD
                        WHERE AFACCTNO=rec.afacctno AND CODEID=rec.codeid AND TXDATE= rec.txdate AND TXNUM=rec.txnum;

                    INSERT INTO SEPITALLOCATE (CAMASTID,AFACCTNO,CODEID,PITRATE,QTTY,PRICE,ARIGHT,ORGORDERID,TXNUM,TXDATE,CARATE,SEPITLOG_ID) VALUES(
                            rec.CAMASTID, rec.AFACCTNO, rec.CODEID, rec.PITRATE,v_recSTSCHD, v_parvalue, v_recSTSCHD * rec.CARATE * v_parvalue * rec.PITRATE/100,
                            recIOD.orgorderid, recIOD.TXNUM,recIOD.TXDATE,rec.CARATE,rec.AUTOID);

                    EXIT;

                else
                    UPDATE STSCHD SET RIGHTQTTY = RIGHTQTTY + rec.qtty - rec.mapqtty,
                        ARIGHT = ARIGHT + (rec.qtty - rec.mapqtty) * rec.CARATE * v_parvalue * rec.PITRATE/100
                        WHERE DUETYPE='RM' AND ORGORDERID=reciod.orgorderid AND AFACCTNO=rec.afacctno AND CODEID=rec.codeid AND
                        DELTD <> 'Y' AND STATUS='N';

                    UPDATE SEPITLOG SET MAPQTTY = MAPQTTY + rec.qtty - rec.mapqtty, STATUS='C' WHERE
                        AFACCTNO=rec.afacctno AND CODEID=rec.codeid AND TXDATE= rec.txdate AND TXNUM=rec.txnum;

                    INSERT INTO SEPITALLOCATE (CAMASTID,AFACCTNO,CODEID,PITRATE,QTTY,PRICE,ARIGHT,ORGORDERID,TXNUM,TXDATE,CARATE,SEPITLOG_ID) VALUES(
                            rec.CAMASTID, rec.AFACCTNO, rec.CODEID, rec.PITRATE,rec.qtty - rec.mapqtty, v_parvalue, (rec.qtty - rec.mapqtty) * rec.CARATE * v_parvalue * rec.PITRATE/100,
                            recIOD.orgorderid, recIOD.TXNUM,recIOD.TXDATE,rec.CARATE,rec.AUTOID);

                    v_recSTSCHD:=v_recSTSCHD- (rec.qtty - rec.mapqtty);
                end if;
                exit when v_recSTSCHD<=0;
            End loop;
        end if;
   end loop;

   EXCEPTION WHEN OTHERS THEN
    plog.debug(pkgctx,'pr_allocate_right_stock: ' || dbms_utility.format_error_backtrace);
    plog.debug(pkgctx,'Error: ' || SQLERRM || dbms_utility.format_error_backtrace);
    plog.setendsection(pkgctx, 'pr_allocate_right_stock');
   --rollback;

END;

---------------------------------pr_3380_send_cop_action------------------------------------------------
  PROCEDURE pr_3380_send_cop_action(p_txmsg in tx.msg_rectype,p_err_code  OUT varchar2)
  IS
      l_txmsg               tx.msg_rectype;
      v_strCURRDATE varchar2(20);
      l_err_param varchar2(300);
      v_costprice number;

  BEGIN
    plog.setbeginsection(pkgctx, 'pr_3380_send_cop_action');
    SELECT varvalue
         INTO v_strCURRDATE
         FROM sysvar
         WHERE grname = 'SYSTEM' AND varname = 'CURRDATE';
    l_txmsg.msgtype:='T';
    l_txmsg.local:='N';
    begin
        plog.debug (pkgctx, 'p_txmsg.TLID' || p_txmsg.TLID);
        l_txmsg.tlid        := p_txmsg.TLID;
    exception when others then
        l_txmsg.tlid        := systemnums.c_system_userid;
    end;
    SELECT SYS_CONTEXT ('USERENV', 'HOST'),
             SYS_CONTEXT ('USERENV', 'IP_ADDRESS', 15)
      INTO l_txmsg.wsname, l_txmsg.ipaddress
    FROM DUAL;
    l_txmsg.off_line    := 'N';
    l_txmsg.deltd       := txnums.c_deltd_txnormal;
    l_txmsg.txstatus    := txstatusnums.c_txcompleted;
    l_txmsg.msgsts      := '0';
    l_txmsg.ovrsts      := '0';
    /*begin
        l_txmsg.batchname        := p_txmsg.txnum;
        plog.debug (pkgctx, 'p_txmsg.txnum' || p_txmsg.txnum);
    exception when others then
        l_txmsg.batchname        := 'DAY';
    end;*/
    l_txmsg.batchname        := 'DAY';
    l_txmsg.busdate:= p_txmsg.busdate;

    l_txmsg.txdate:=to_date(v_strCURRDATE,systemnums.c_date_format);
    l_txmsg.tltxcd:='3380';
    l_txmsg.reftxnum := p_txmsg.txnum;
    for rec in
    (
        select AUTOID,BALANCE,replace(CAMASTID,'.','') CAMASTID,AFACCTNO,CATYPE,CATYPEID,CODEID,EXCODEID,
            QTTY,AMT,AQTTY,AAMT,SYMBOL,SYMBOLDIS,STATUS,STATUSCD,SEACCTNO,EXSEACCTNO,
            PARVALUE,EXPARVALUE,REPORTDATE,ACTIONDATE,DESCRIPTION,CUSTODYCD,FULLNAME,
            IDCODE,ISRIGHTOFF,QTTYDIS,NMQTTY,
            ISCDCROUTAMT,ACCTNO_CR_UPDATECOST,ACCTNO_DB_UPDATECOST,AQTTY2,COSTPRICE,SEACCTNOOPT,ISOPT
        from v_ca3380
        where replace(CAMASTID,'.','') =p_txmsg.txfields('03').value
    )
    loop
        --Set txnum
        SELECT systemnums.C_BATCH_PREFIXED
                         || LPAD (seq_BATCHTXNUM.NEXTVAL, 8, '0')
                  INTO l_txmsg.txnum
                  FROM DUAL;
        --Set txtime
        select to_char(sysdate,'hh24:mi:ss') into l_txmsg.txtime from dual;
        --Set brid
        begin
            l_txmsg.brid        := p_txmsg.BRID;
        exception when others then
            l_txmsg.brid        := substr(rec.AFACCTNO,1,4);
        end;

        --Set cac field giao dich

        --01  AUTOID      C
        l_txmsg.txfields ('01').defname   := 'AUTOID';
        l_txmsg.txfields ('01').TYPE      := 'C';
        l_txmsg.txfields ('01').VALUE     := rec.AUTOID;
        --02  CAMASTID    C
        l_txmsg.txfields ('02').defname   := 'CAMASTID';
        l_txmsg.txfields ('02').TYPE      := 'C';
        l_txmsg.txfields ('02').VALUE     := rec.CAMASTID;
        --03  AFACCTNO    C
        l_txmsg.txfields ('03').defname   := 'AFACCTNO';
        l_txmsg.txfields ('03').TYPE      := 'C';
        l_txmsg.txfields ('03').VALUE     := rec.AFACCTNO;
        --04  SYMBOL      C
        l_txmsg.txfields ('04').defname   := 'SYMBOL';
        l_txmsg.txfields ('04').TYPE      := 'C';
        l_txmsg.txfields ('04').VALUE     := rec.SYMBOL;
        --05  CATYPE      C
        l_txmsg.txfields ('05').defname   := 'CATYPE';
        l_txmsg.txfields ('05').TYPE      := 'C';
        l_txmsg.txfields ('05').VALUE     := rec.CATYPE;
        --06  REPORTDATE  C
        l_txmsg.txfields ('06').defname   := 'REPORTDATE';
        l_txmsg.txfields ('06').TYPE      := 'C';
        l_txmsg.txfields ('06').VALUE     := to_char(rec.REPORTDATE,'dd/mm/rrrr');
        --07  ACTIONDATE  C
        l_txmsg.txfields ('07').defname   := 'ACTIONDATE';
        l_txmsg.txfields ('07').TYPE      := 'C';
        l_txmsg.txfields ('07').VALUE     := to_char(rec.ACTIONDATE,'dd/mm/rrrr');
        --08  SEACCTNO    C
        l_txmsg.txfields ('08').defname   := 'SEACCTNO';
        l_txmsg.txfields ('08').TYPE      := 'C';
        l_txmsg.txfields ('08').VALUE     := rec.SEACCTNO;
        --09  EXSEACCTNO  C
        l_txmsg.txfields ('09').defname   := 'EXSEACCTNO';
        l_txmsg.txfields ('09').TYPE      := 'C';
        l_txmsg.txfields ('09').VALUE     := rec.EXSEACCTNO;
        --10  AMT         N
        l_txmsg.txfields ('10').defname   := 'AMT';
        l_txmsg.txfields ('10').TYPE      := 'N';
        l_txmsg.txfields ('10').VALUE     := rec.AMT;
        --11  QTTY        N
        l_txmsg.txfields ('11').defname   := 'QTTY';
        l_txmsg.txfields ('11').TYPE      := 'N';
        l_txmsg.txfields ('11').VALUE     := rec.QTTY;
        --12  AAMT        N
        l_txmsg.txfields ('12').defname   := 'AAMT';
        l_txmsg.txfields ('12').TYPE      := 'N';
        l_txmsg.txfields ('12').VALUE     := rec.AAMT;
        --13  AQTTY       N
        l_txmsg.txfields ('13').defname   := 'AQTTY';
        l_txmsg.txfields ('13').TYPE      := 'N';
        l_txmsg.txfields ('13').VALUE     := rec.AQTTY;
        --14  PARVALUE    N
        l_txmsg.txfields ('14').defname   := 'PARVALUE';
        l_txmsg.txfields ('14').TYPE      := 'N';
        l_txmsg.txfields ('14').VALUE     := rec.PARVALUE;
        --15  EXPARVALUE  N
        l_txmsg.txfields ('15').defname   := 'EXPARVALUE';
        l_txmsg.txfields ('15').TYPE      := 'N';
        l_txmsg.txfields ('15').VALUE     := rec.EXPARVALUE;
        --19  NMQTTY        N
        l_txmsg.txfields ('19').defname   := 'NMQTTY';
        l_txmsg.txfields ('19').TYPE      := 'N';
        l_txmsg.txfields ('19').VALUE     := rec.NMQTTY;
        --20  SYMBOLDIS   C
        l_txmsg.txfields ('20').defname   := 'SYMBOLDIS';
        l_txmsg.txfields ('20').TYPE      := 'C';
        l_txmsg.txfields ('20').VALUE     := rec.SYMBOLDIS;
        --22  CODEID   C
        l_txmsg.txfields ('22').defname   := 'CODEID';
        l_txmsg.txfields ('22').TYPE      := 'C';
        l_txmsg.txfields ('22').VALUE     := rec.CODEID;
        --30  DESCRIPTION C
        l_txmsg.txfields ('30').defname   := 'DESCRIPTION';
        l_txmsg.txfields ('30').TYPE      := 'C';
        l_txmsg.txfields ('30').VALUE     := rec.DESCRIPTION;
        --36  CUSTODYCD      C
        l_txmsg.txfields ('36').defname   := 'CUSTODYCD';
        l_txmsg.txfields ('36').TYPE      := 'C';
        l_txmsg.txfields ('36').VALUE     := rec.CUSTODYCD;
        --40  STATUS      C
        l_txmsg.txfields ('40').defname   := 'STATUS';
        l_txmsg.txfields ('40').TYPE      := 'C';
        l_txmsg.txfields ('40').VALUE     := rec.STATUSCD;
        --41  NEWSTATUS      C
        l_txmsg.txfields ('41').defname   := 'NEWSTATUS';
        l_txmsg.txfields ('41').TYPE      := 'C';
        l_txmsg.txfields ('41').VALUE     := 'S';
        --66  ISRIGHTOFF  N
        l_txmsg.txfields ('66').defname   := 'ISRIGHTOFF';
        l_txmsg.txfields ('66').TYPE      := 'N';
        l_txmsg.txfields ('66').VALUE     := rec.ISRIGHTOFF;
        --21 QTTYDIS
        l_txmsg.txfields ('21').defname   := 'TRADE';
        l_txmsg.txfields ('21').TYPE      := 'N';
        l_txmsg.txfields ('21').VALUE     := rec.QTTYDIS;

             --32: COSTPRICE
        l_txmsg.txfields ('32').defname   := 'COSTPRICE';
        l_txmsg.txfields ('32').TYPE      := 'N';
        l_txmsg.txfields ('32').VALUE     := rec.COSTPRICE;
        --33  AQTTY2  N
        l_txmsg.txfields ('33').defname   := 'AQTTY2';
        l_txmsg.txfields ('33').TYPE      := 'N';
        l_txmsg.txfields ('33').VALUE     := rec.AQTTY2;
        --34 ACCTNO_CR_UPDATECOST
        l_txmsg.txfields ('34').defname   := 'ACCTNO_CR_UPDATECOST';
        l_txmsg.txfields ('34').TYPE      := 'C';
        l_txmsg.txfields ('34').VALUE     := rec.ACCTNO_CR_UPDATECOST;
          --35 ACCTNO_DB_UPDATECOST
        l_txmsg.txfields ('35').defname   := 'ACCTNO_DB_UPDATECOST';
        l_txmsg.txfields ('35').TYPE      := 'C';
        l_txmsg.txfields ('35').VALUE     := rec.ACCTNO_DB_UPDATECOST;
                  --60 ACCTNO_DB_UPDATECOST
        l_txmsg.txfields ('60').defname   := 'ISCDCROUTAMT';
        l_txmsg.txfields ('60').TYPE      := 'C';
        l_txmsg.txfields ('60').VALUE     := rec.ISCDCROUTAMT;

        --16 SEACCTNOOPT
        l_txmsg.txfields ('16').defname   := 'SEACCTNOOPT';
        l_txmsg.txfields ('16').TYPE      := 'N';
        l_txmsg.txfields ('16').VALUE     := rec.SEACCTNOOPT;

        --67ISOPT
        l_txmsg.txfields ('67').defname   := 'ISOPT';
        l_txmsg.txfields ('67').TYPE      := 'N';
        l_txmsg.txfields ('67').VALUE     := rec.ISOPT;

        BEGIN
            IF txpks_#3380.fn_batchtxprocess (l_txmsg,
                                             p_err_code,
                                             l_err_param
               ) <> systemnums.c_success
            THEN
               plog.debug (pkgctx,
                           'got error 3380: ' || p_err_code
               );
               ROLLBACK;
               RETURN;
            else
            --locpt 20180321 ghi nhan tinh gia von realtime
            plog.error (pkgctx, 'locpt log caproc quyen mua : '||rec.CATYPE);
              if  rec.CATYPEID <> '014' then  -- quyen mua tinh o giao dich 3384
                 plog.error (pkgctx, 'locpt log caproc quyen mua da vao if <> 014 : '||rec.CATYPE);
                 begin  -- tinh gia von de ghi log su kien quyen
                    if  (rec.CATYPEID in ('017','020') and rec.qtty <>0) then
                           select ((avgcostprice*rec.balance)/rec.qtty )
                           into v_costprice
                           from buf_se_account
                           where acctno = rec.EXSEACCTNO and rownum=1;
                    else
                         v_costprice:=0;
                    end if;
                  EXCEPTION
                  WHEN NO_DATA_FOUND
                  THEN v_costprice:=0;
                 end;
                   if  rec.CATYPEID = ('010') then  -- co tuc bang tien thi ghi nhan thang len ck giao dich chu k ghi nhan nhu nhung skq khac la ck wft
                     secmast_generate(l_txmsg.txnum, l_txmsg.txdate, l_txmsg.busdate, rec.AFACCTNO,
                     rec.CODEID, 'C', 'I', rec.CAMASTID, NULL,  rec.QTTY, 0 , 'Y',rec.AMT);
                   else  --- skq con lai
                     secmast_generate(l_txmsg.txnum, l_txmsg.txdate, l_txmsg.busdate, rec.AFACCTNO,
                     substr(rec.ACCTNO_CR_UPDATECOST,11,6), 'C', 'I', rec.CAMASTID, NULL,  rec.QTTY, v_costprice , 'Y',rec.AMT);
                   end if;
              end if;
            END IF;
        END;
    end loop;
    p_err_code:=0;
    plog.setendsection(pkgctx, 'pr_3380_send_cop_action');
  EXCEPTION
  WHEN OTHERS
   THEN
      plog.debug (pkgctx,'got error on pr_3380_send_cop_action');
      ROLLBACK;
      p_err_code := errnums.C_SYSTEM_ERROR;
      plog.error (pkgctx, SQLERRM|| dbms_utility.format_error_backtrace);
      plog.setendsection (pkgctx, 'pr_3380_send_cop_action');
      RAISE errnums.E_SYSTEM_ERROR;
  END pr_3380_send_cop_action;

---------------------------------pr_3350_exec_money_CA------------------------------------------------
  PROCEDURE pr_3350_exec_money_CA(p_txmsg in tx.msg_rectype,p_err_code  OUT varchar2)
  IS
      l_txmsg               tx.msg_rectype;
      v_strCURRDATE varchar2(20);
      l_err_param varchar2(300);

      l_alternateacct   char(1);
      l_autotrf         char(1);
      --T9/2019 CW_PhaseII
      l_EXERCISERATIO   number;
      l_catype          varchar2(20);
      -- End T9/2019 CW_PhaseII
  BEGIN
    plog.setbeginsection(pkgctx, 'pr_3350_exec_money_CA');
    SELECT varvalue
         INTO v_strCURRDATE
         FROM sysvar
         WHERE grname = 'SYSTEM' AND varname = 'CURRDATE';
    l_txmsg.msgtype:='T';
    l_txmsg.local:='N';
    begin
        plog.debug (pkgctx, 'p_txmsg.TLID' || p_txmsg.TLID);
        l_txmsg.tlid        := p_txmsg.TLID;
    exception when others then
        l_txmsg.tlid        := systemnums.c_system_userid;
    end;
    SELECT SYS_CONTEXT ('USERENV', 'HOST'),
             SYS_CONTEXT ('USERENV', 'IP_ADDRESS', 15)
      INTO l_txmsg.wsname, l_txmsg.ipaddress
    FROM DUAL;
    l_txmsg.off_line    := 'N';
    l_txmsg.deltd       := txnums.c_deltd_txnormal;
    l_txmsg.txstatus    := txstatusnums.c_txcompleted;
    l_txmsg.msgsts      := '0';
    l_txmsg.ovrsts      := '0';
    /*begin
        l_txmsg.batchname        := p_txmsg.txnum;
        plog.debug (pkgctx, 'p_txmsg.txnum' || p_txmsg.txnum);
    exception when others then
        l_txmsg.batchname        := 'DAY';
    end;*/
    l_txmsg.batchname        := 'DAY';
    l_txmsg.busdate:= p_txmsg.busdate;

    l_txmsg.txdate:=to_date(v_strCURRDATE,systemnums.c_date_format);
    l_txmsg.reftxnum := p_txmsg.txnum;

    --T9/2019 CW_PhaseII
    select catype into l_catype from camast where camastid = p_txmsg.txfields('03').value;
    if l_catype = '028' then
        begin
            select  to_number(SUBSTR(EXERCISERATIO,0,INSTR(EXERCISERATIO,'/') - 1))/to_number(SUBSTR(EXERCISERATIO,INSTR(EXERCISERATIO,'/')+1,LENGTH(EXERCISERATIO)))  into l_EXERCISERATIO
            from sbsecurities
            where codeid = p_txmsg.txfields('06').value;
            EXCEPTION  WHEN OTHERS THEN
                p_err_code  := -300074;
                RETURN;
        end ;
    end if;
    -- End T9/2019 CW_PhaseII

    for rec in
    (
       SELECT  af.bankname, af.bankacctno, CA.AUTOID, CA.BALANCE, ca.CAMASTID, CA.AFACCTNO,CAMAST.CATYPE, CA.CODEID, CA.EXCODEID, CA.QTTY,
                ROUND(case when camast.catype = '010' then
                    (case when camast.status = 'K' and ca.status = 'K' then ((100-camast.exerate)/100)*CA.AMT
                    else (case when ca.status not in ('K','J') then (camast.exerate/100)*CA.AMT else 0 end) end)
                    else CA.AMT end) AMT,
                ROUND(CA.AQTTY) AQTTY,ROUND(CA.AAMT) AAMT, SYM.SYMBOL, CA.STATUS,
                CASE WHEN camast.catype = '017' THEN CA.AFACCTNO || CA.EXCODEID ELSE CA.AFACCTNO || CA.CODEID END SEACCTNO,
                CASE WHEN camast.catype = '017' THEN CA.AFACCTNO || CA.CODEID else CA.AFACCTNO || (CASE WHEN CAMAST.EXCODEID IS NULL THEN CAMAST.CODEID ELSE CAMAST.EXCODEID END) end EXSEACCTNO,
                SYM.PARVALUE PARVALUE, EXSYM.PARVALUE EXPARVALUE, CAMAST.REPORTDATE REPORTDATE, CAMAST.ACTIONDATE ,CAMAST.ACTIONDATE  POSTINGDATE,
                    camast.description, camast.taskcd,
      (CASE WHEN cf.VAT='Y' THEN ( CASE WHEN CAMAST.CATYPE in ('016','023') THEN round(CAMAST.pitrate*CA.INTAMT/100)
                                    WHEN CAMAST.CATYPE = '028' then LEAST(CA.AMT,CA.balance*CAMAST.EXPRICE*CAMAST.pitrate/100/l_EXERCISERATIO) --T9/2019 CW_PhaseII
                                    ELSE(case when camast.catype = '010'
      then (
            case when camast.status = 'K' and ca.status = 'K' then round(CAMAST.pitrate*(((100-camast.exerate)/100)*CA.AMT)/100)
            else (case when ca.status not in ('K','J') then round(CAMAST.pitrate*((camast.exerate/100)*CA.AMT)/100) else 0 end) end)
        else round(CAMAST.pitrate*CA.AMT/100) end)
      END)
      ELSE 0 END) DUTYAMT,
                      CF.FULLNAME, CF.IDCODE, CF.CUSTODYCD, cf.custid, SYM.TRADEPLACE, SYM.SECTYPE,
                      CAMAST.PITRATEMETHOD CAVAT,(case when CA.PITRATEMETHOD='##' then CAMAST.PITRATEMETHOD else CA.PITRATEMETHOD end) SCHDVAT,
                      (CASE WHEN CAMAST.catype in ('016','023') THEN 1 ELSE 0 END) ISDEBITSE,
                      CASE WHEN CI.COREBANK='Y' THEN 0 ELSE 1 END ISCOREBANK,
                      CASE WHEN CI.COREBANK='Y' THEN 'Yes' ELSE 'No' END ISCOREBANKTEXT,
                       round( CA.INTAMT) INTAMT,nvl(se.trade,0) trade,round(CA.DFAMT) DFAMT,
                      (CASE WHEN CAMAST.catype IN ('016','023','015') THEN 0 ELSE 1 END) NOTINTAMT,
                      camast.exerate,
                      (CASE WHEN CAMAST.catype = '010' AND camast.exerate < 100 THEN
                        (CASE WHEN CAMAST.status = 'K' THEN ' ( ' || UTF8NUMS.C_TXDESC_3350_2 || (100-camast.exerate) || '% )'
                            ELSE ' ( ' || UTF8NUMS.C_TXDESC_3350_1 || camast.exerate || '% )' END
                            ) ELSE NULL END) TXDESC, ca.trffee TRFEEAMT --TrungNQ 13/05/2022 phi chuyen khoan
                FROM caschd CA,
                    SBSECURITIES SYM, SBSECURITIES EXSYM, CAMAST, AFMAST AF, CIMAST CI , CFMAST CF , AFTYPE TYP, SYSVAR SYS,
                    semast se
                WHERE CA.CAMASTID = CAMAST.CAMASTID AND CAMAST.CODEID = SYM.CODEID
                and camast.camastid =p_txmsg.txfields('03').value
                AND nvl(CAMAST.EXCODEID,CAMAST.CODEID)  = EXSYM.CODEID
                AND CA.AFACCTNO = AF.ACCTNO AND AF.CUSTID = CF.CUSTID and af.acctno = ci.acctno
                AND CA.DELTD = 'N' AND CA.STATUS IN ('S','H','W','K','J') and CAMAST.STATUS  IN ('K','I','H') AND CA.ISCI ='N' --AND CA.ISSE='N'
                AND CA.AMT > 0 AND CA.ISEXEC='Y'
                AND se.acctno(+)= ca.afacctno||ca.codeid
                AND AF.ACTYPE = TYP.ACTYPE AND SYS.GRNAME='SYSTEM' AND SYS.VARNAME='CADUTY'
    )
    loop
        if rec.SCHDVAT='IS' then
            --Thu thue tai TCPH
            l_txmsg.tltxcd:='3354';
        else
            --Thu thue tai Cong ty
            l_txmsg.tltxcd:='3350';
        end if;
        --Set txnum
        SELECT systemnums.C_BATCH_PREFIXED
                         || LPAD (seq_BATCHTXNUM.NEXTVAL, 8, '0')
                  INTO l_txmsg.txnum
                  FROM DUAL;
        --Set txtime
        select to_char(sysdate,'hh24:mi:ss') into l_txmsg.txtime from dual;
        --Set brid
        begin
            l_txmsg.brid        := p_txmsg.BRID;
        exception when others then
            l_txmsg.brid        := substr(rec.AFACCTNO,1,4);
        end;

        --Set cac field giao dich
        --01  AUTOID      C
        l_txmsg.txfields ('01').defname   := 'AUTOID';
        l_txmsg.txfields ('01').TYPE      := 'C';
        l_txmsg.txfields ('01').VALUE     := rec.AUTOID;
        --02  CAMASTID    C
        l_txmsg.txfields ('02').defname   := 'CAMASTID';
        l_txmsg.txfields ('02').TYPE      := 'C';
        l_txmsg.txfields ('02').VALUE     := rec.CAMASTID;
        --03  AFACCTNO    C
        l_txmsg.txfields ('03').defname   := 'AFACCTNO';
        l_txmsg.txfields ('03').TYPE      := 'C';
        l_txmsg.txfields ('03').VALUE     := rec.AFACCTNO;
        --04  SYMBOL      C
        l_txmsg.txfields ('04').defname   := 'SYMBOL';
        l_txmsg.txfields ('04').TYPE      := 'C';
        l_txmsg.txfields ('04').VALUE     := rec.SYMBOL;
        --05  CATYPE      C
        l_txmsg.txfields ('05').defname   := 'CATYPE';
        l_txmsg.txfields ('05').TYPE      := 'C';
        l_txmsg.txfields ('05').VALUE     := rec.CATYPE;
        --06  REPORTDATE  C
        l_txmsg.txfields ('06').defname   := 'REPORTDATE';
        l_txmsg.txfields ('06').TYPE      := 'C';
        l_txmsg.txfields ('06').VALUE     := to_char(rec.REPORTDATE,'dd/mm/rrrr');
        --07  ACTIONDATE  C
        l_txmsg.txfields ('07').defname   := 'ACTIONDATE';
        l_txmsg.txfields ('07').TYPE      := 'C';
        l_txmsg.txfields ('07').VALUE     := to_char(rec.ACTIONDATE,'dd/mm/rrrr');
        --08  SEACCTNO    C
        l_txmsg.txfields ('08').defname   := 'SEACCTNO';
        l_txmsg.txfields ('08').TYPE      := 'C';
        l_txmsg.txfields ('08').VALUE     := rec.SEACCTNO;
        --09  EXSEACCTNO  C
        l_txmsg.txfields ('09').defname   := 'EXSEACCTNO';
        l_txmsg.txfields ('09').TYPE      := 'C';
        l_txmsg.txfields ('09').VALUE     := rec.EXSEACCTNO;
        --10  AMT         N
        l_txmsg.txfields ('10').defname   := 'AMT';
        l_txmsg.txfields ('10').TYPE      := 'N';
        l_txmsg.txfields ('10').VALUE     := rec.AMT;
        --12  AAMT        N
        l_txmsg.txfields ('12').defname   := 'AAMT';
        l_txmsg.txfields ('12').TYPE      := 'N';
        l_txmsg.txfields ('12').VALUE     := rec.AAMT;
        --14  PARVALUE    N
        l_txmsg.txfields ('14').defname   := 'PARVALUE';
        l_txmsg.txfields ('14').TYPE      := 'N';
        l_txmsg.txfields ('14').VALUE     := rec.PARVALUE;
        --15  EXPARVALUE  N
        l_txmsg.txfields ('15').defname   := 'EXPARVALUE';
        l_txmsg.txfields ('15').TYPE      := 'N';
        l_txmsg.txfields ('15').VALUE     := rec.EXPARVALUE;
        --16  TASKCD   C
        l_txmsg.txfields ('16').defname   := 'TASKCD';
        l_txmsg.txfields ('16').TYPE      := 'C';
        l_txmsg.txfields ('16').VALUE     := '';
        --17  FULLNAME    C
        l_txmsg.txfields ('17').defname   := 'FULLNAME';
        l_txmsg.txfields ('17').TYPE      := 'C';
        l_txmsg.txfields ('17').VALUE     := rec.FULLNAME;
        --18  IDCODE      C
        l_txmsg.txfields ('18').defname   := 'IDCODE';
        l_txmsg.txfields ('18').TYPE      := 'C';
        l_txmsg.txfields ('18').VALUE     := rec.IDCODE;
        --19  CUSTODYCD   C
        l_txmsg.txfields ('19').defname   := 'CUSTODYCD';
        l_txmsg.txfields ('19').TYPE      := 'C';
        l_txmsg.txfields ('19').VALUE     := rec.CUSTODYCD;
        --20  DUTYAMT     N
        l_txmsg.txfields ('20').defname   := 'DUTYAMT';
        l_txmsg.txfields ('20').TYPE      := 'C';
        l_txmsg.txfields ('20').VALUE     := rec.DUTYAMT;
        --30  DESCRIPTION C
        l_txmsg.txfields ('30').defname   := 'DESCRIPTION';
        l_txmsg.txfields ('30').TYPE      := 'C';
        l_txmsg.txfields ('30').VALUE     := rec.DESCRIPTION;
        --60  ISCOREBANK C
        l_txmsg.txfields ('60').defname   := 'DESCRIPTION';
        l_txmsg.txfields ('60').TYPE      := 'C';
        l_txmsg.txfields ('60').VALUE     := rec.ISCOREBANK;
        --61  ISDEBITSE C
        l_txmsg.txfields ('61').defname   := 'ISDEBITSE';
        l_txmsg.txfields ('61').TYPE      := 'C';
        l_txmsg.txfields ('61').VALUE     := rec.ISDEBITSE;

        --11 BALANCE-trade     N
        l_txmsg.txfields ('11').defname   := 'BALANCE';
        l_txmsg.txfields ('11').TYPE      := 'N';
        l_txmsg.txfields ('11').VALUE     := rec.trade;

        --13 INTAMT     N
        l_txmsg.txfields ('13').defname   := 'INTAMT';
        l_txmsg.txfields ('13').TYPE      := 'N';
        l_txmsg.txfields ('13').VALUE     := rec.INTAMT;

        --22  TRFEEAMT     N
        l_txmsg.txfields ('22').defname   := 'TRFEEAMT';
        l_txmsg.txfields ('22').TYPE      := 'C';
        l_txmsg.txfields ('22').VALUE     := rec.TRFEEAMT;

          --21 DFAMT     N
        l_txmsg.txfields ('21').defname   := 'DFAMT';
        l_txmsg.txfields ('21').TYPE      := 'N';
        l_txmsg.txfields ('21').VALUE     := rec.DFAMT;

         --62  NOTINTAMT N
        l_txmsg.txfields ('62').defname   := 'NOTINTAMT';
        l_txmsg.txfields ('62').TYPE      := 'N';
        l_txmsg.txfields ('62').VALUE     := rec.NOTINTAMT;

        --24  CODEID C
        l_txmsg.txfields ('24').defname   := 'CODEID';
        l_txmsg.txfields ('24').TYPE      := 'C';
        l_txmsg.txfields ('24').VALUE     := rec.CODEID;
        IF REC.CATYPE = '010' AND REC.exerate < 100 THEN
            --30  DESC C camast.exerate , NULL TXDESC
            l_txmsg.txfields ('30').defname   := 'DESC';
            l_txmsg.txfields ('30').TYPE      := 'C';
            l_txmsg.txfields ('30').VALUE     := NVL(l_txmsg.txfields('30').value,l_txmsg.txdesc) || REC.TXDESC;
        END IF;

        if l_txmsg.tltxcd ='3350' THEN
            BEGIN
                IF txpks_#3350.fn_batchtxprocess (l_txmsg,
                                                 p_err_code,
                                                 l_err_param
                   ) <> systemnums.c_success
                THEN
                   plog.debug (pkgctx,
                               'got error 3350: ' || p_err_code
                   );
                   ROLLBACK;
                   RETURN;
                END IF;
            END;
        else
            BEGIN
                IF txpks_#3354.fn_batchtxprocess (l_txmsg,
                                                 p_err_code,
                                                 l_err_param
                   ) <> systemnums.c_success
                THEN
                   plog.debug (pkgctx,
                               'got error 3350: ' || p_err_code
                   );
                   ROLLBACK;
                   RETURN;
                END IF;
            END;
        end if;



       /* --Neu giao dich thanh cong thi chuyen thanh b?ke ra ngan hang voi tai khoan phu co dang ky chuyen tu dong sang ngan hang
        select alternateacct, autotrf into l_alternateacct, l_autotrf from afmast where acctno = rec.AFACCTNO;
        if l_alternateacct='Y' and l_autotrf='Y' then
            cspks_rmproc.pr_rmSUBReleaseBalance(rec.AFACCTNO,rec.AMT-rec.DUTYAMT,l_txmsg.tltxcd || '@@' || l_txmsg.txfields ('30').VALUE,p_err_code);
            if p_err_code <> '0' then
                --Co loi xay ra
                plog.error('Loi chuyen tien tu phu sang chinh khi nhan quyen Error:' || p_err_code);
                plog.error('Loi xay ra tai Dong:' || dbms_utility.format_error_backtrace );
            end if;
        end if;*/

    end loop;
    p_err_code:=0;
    plog.setendsection(pkgctx, 'pr_3350_exec_money_CA');
  EXCEPTION
  WHEN OTHERS
   THEN
      plog.debug (pkgctx,'got error on pr_3350_exec_money_CA');
      ROLLBACK;
      p_err_code := errnums.C_SYSTEM_ERROR;
      plog.error (pkgctx, SQLERRM|| dbms_utility.format_error_backtrace);
      plog.setendsection (pkgctx, 'pr_3350_exec_money_CA');
      RAISE errnums.E_SYSTEM_ERROR;
  END pr_3350_exec_money_CA;

---------------------------------pr_3351_Exec_Sec_CA------------------------------------------------
  PROCEDURE pr_3351_Exec_Sec_CA(p_txmsg in tx.msg_rectype,p_err_code  OUT varchar2)
  IS
      l_txmsg               tx.msg_rectype;
      v_strCURRDATE varchar2(20);
      l_err_param varchar2(300);
      v_iscancel    varchar2(1);

  BEGIN
    plog.setbeginsection(pkgctx, 'pr_3351_Exec_Sec_CA');
    SELECT varvalue
         INTO v_strCURRDATE
         FROM sysvar
         WHERE grname = 'SYSTEM' AND varname = 'CURRDATE';
    l_txmsg.msgtype:='T';
    l_txmsg.local:='N';
    v_iscancel := p_txmsg.txfields ('10').VALUE ;
    begin
        plog.debug (pkgctx, 'p_txmsg.TLID' || p_txmsg.TLID);
        l_txmsg.tlid        := p_txmsg.TLID;
    exception when others then
        l_txmsg.tlid        := systemnums.c_system_userid;
    end;
    SELECT SYS_CONTEXT ('USERENV', 'HOST'),
             SYS_CONTEXT ('USERENV', 'IP_ADDRESS', 15)
      INTO l_txmsg.wsname, l_txmsg.ipaddress
    FROM DUAL;
    l_txmsg.off_line    := 'N';
    l_txmsg.deltd       := txnums.c_deltd_txnormal;
    l_txmsg.txstatus    := txstatusnums.c_txcompleted;
    l_txmsg.msgsts      := '0';
    l_txmsg.ovrsts      := '0';
    /*begin
        l_txmsg.batchname        := p_txmsg.txnum;
        plog.debug (pkgctx, 'p_txmsg.txnum' || p_txmsg.txnum);
    exception when others then
        l_txmsg.batchname        := 'DAY';
    end;*/
    l_txmsg.batchname        := 'DAY';
    l_txmsg.busdate:= p_txmsg.busdate;

    l_txmsg.txdate:=to_date(v_strCURRDATE,systemnums.c_date_format);
    l_txmsg.tltxcd:='3351';
    l_txmsg.reftxnum := p_txmsg.txnum;
    for rec in
    (
        select AUTOID, BALANCE, replace(CAMASTID,'.','') CAMASTID, AFACCTNO, CATYPE, CODEID, EXCODEID,
            (case when CATYPEVALUE IN ('023','020') then (case when v_iscancel = 'N' then QTTY else 0 end) else QTTY end) QTTY,
            (case when CATYPEVALUE IN ('023','020') then (case when v_iscancel = 'N' then AMT else 0 end) else AMT end) AMT,
            (case when CATYPEVALUE IN ('023','020') then (case when v_iscancel = 'Y' then AQTTY else 0 end) else AQTTY end) AQTTY,
            (case when CATYPEVALUE IN ('023','020') then (case when v_iscancel = 'Y' then AAMT else 0 end) else AAMT end) AAMT,
            SYMBOL, PITRATE, TOCODEID, STATUS, SEACCTNO, EXSEACCTNO, PARVALUE,
            EXPARVALUE, REPORTDATE, ACTIONDATE, POSTINGDATE, DESCRIPTION, TASKCD, DUTYAMT,
            FULLNAME, IDCODE, CUSTODYCD, PRICEACCOUNTING, CATYPEVALUE,COSTPRICE,ISCDCROUTAMT, SEACCTNOOPT, ISOPT, STATUSCD
        from v_ca3351
        where replace(CAMASTID,'.','') = p_txmsg.txfields('03').value
           AND (CASE WHEN CATYPEVALUE IN ('023','020') THEN 'N' ELSE ISSE END) <> 'Y'
           and not (v_iscancel = 'N' and statuscd='W') --Da thuc hien 3356 Chuyen doi cho GD thanh GD thi khong duoc phan Bo CA3346
    )
    loop
        --Set txnum
        SELECT systemnums.C_BATCH_PREFIXED
                         || LPAD (seq_BATCHTXNUM.NEXTVAL, 8, '0')
                  INTO l_txmsg.txnum
                  FROM DUAL;
        --Set txtime
        select to_char(sysdate,'hh24:mi:ss') into l_txmsg.txtime from dual;
        --Set brid
        begin
            l_txmsg.brid        := p_txmsg.BRID;
        exception when others then
            l_txmsg.brid        := substr(rec.AFACCTNO,1,4);
        end;
        --Set ngay hach toan giao dich
        l_txmsg.busdate:= rec.POSTINGDATE;
        --Set cac field giao dich
        --01  AUTOID      C
        l_txmsg.txfields ('01').defname   := 'AUTOID';
        l_txmsg.txfields ('01').TYPE      := 'C';
        l_txmsg.txfields ('01').VALUE     := rec.AUTOID;
        --02  CAMASTID    C
        l_txmsg.txfields ('02').defname   := 'CAMASTID';
        l_txmsg.txfields ('02').TYPE      := 'C';
        l_txmsg.txfields ('02').VALUE     := rec.CAMASTID;
        --03  AFACCTNO    C
        l_txmsg.txfields ('03').defname   := 'AFACCTNO';
        l_txmsg.txfields ('03').TYPE      := 'C';
        l_txmsg.txfields ('03').VALUE     := rec.AFACCTNO;
        --04  SYMBOL      C
        l_txmsg.txfields ('04').defname   := 'SYMBOL';
        l_txmsg.txfields ('04').TYPE      := 'C';
        l_txmsg.txfields ('04').VALUE     := rec.SYMBOL;
        --05  CATYPE      C
        l_txmsg.txfields ('05').defname   := 'CATYPE';
        l_txmsg.txfields ('05').TYPE      := 'C';
        l_txmsg.txfields ('05').VALUE     := rec.CATYPE;
        --06  REPORTDATE  C
        l_txmsg.txfields ('06').defname   := 'REPORTDATE';
        l_txmsg.txfields ('06').TYPE      := 'C';
        l_txmsg.txfields ('06').VALUE     := to_char(rec.REPORTDATE,'dd/mm/rrrr');
        --07  ACTIONDATE  C
        l_txmsg.txfields ('07').defname   := 'ACTIONDATE';
        l_txmsg.txfields ('07').TYPE      := 'C';
        l_txmsg.txfields ('07').VALUE     := to_char(rec.ACTIONDATE,'dd/mm/rrrr');
        --08  SEACCTNO    C
        l_txmsg.txfields ('08').defname   := 'SEACCTNO';
        l_txmsg.txfields ('08').TYPE      := 'C';
        l_txmsg.txfields ('08').VALUE     := rec.SEACCTNO;
        --09  EXSEACCTNO  C
        l_txmsg.txfields ('09').defname   := 'EXSEACCTNO';
        l_txmsg.txfields ('09').TYPE      := 'C';
        l_txmsg.txfields ('09').VALUE     := rec.EXSEACCTNO;
        --11  QTTY        N
        l_txmsg.txfields ('11').defname   := 'QTTY';
        l_txmsg.txfields ('11').TYPE      := 'N';
        l_txmsg.txfields ('11').VALUE     := rec.QTTY;
        --13  AQTTY       N
        l_txmsg.txfields ('13').defname   := 'AQTTY';
        l_txmsg.txfields ('13').TYPE      := 'N';
        l_txmsg.txfields ('13').VALUE     := rec.AQTTY;
        --14  PARVALUE    N
        l_txmsg.txfields ('14').defname   := 'PARVALUE';
        l_txmsg.txfields ('14').TYPE      := 'N';
        l_txmsg.txfields ('14').VALUE     := rec.PARVALUE;
        --15  EXPARVALUE  N
        l_txmsg.txfields ('15').defname   := 'EXPARVALUE';
        l_txmsg.txfields ('15').TYPE      := 'N';
        l_txmsg.txfields ('15').VALUE     := rec.EXPARVALUE;
        --16  TASKCD          C
        l_txmsg.txfields ('16').defname   := 'TASKCD';
        l_txmsg.txfields ('16').TYPE      := 'C';
        l_txmsg.txfields ('16').VALUE     := rec.TASKCD;
        --17  FULLNAME          C
        l_txmsg.txfields ('17').defname   := 'FULLNAME';
        l_txmsg.txfields ('17').TYPE      := 'C';
        l_txmsg.txfields ('17').VALUE     := rec.FULLNAME;
        --18  IDCODE          C
        l_txmsg.txfields ('18').defname   := 'IDCODE';
        l_txmsg.txfields ('18').TYPE      := 'C';
        l_txmsg.txfields ('18').VALUE     := rec.IDCODE;
        --19  CUSTODYCD          C
        l_txmsg.txfields ('19').defname   := 'CUSTODYCD';
        l_txmsg.txfields ('19').TYPE      := 'C';
        l_txmsg.txfields ('19').VALUE     := rec.CUSTODYCD;
        --20  DUTYAMT  N
        l_txmsg.txfields ('20').defname   := 'DUTYAMT';
        l_txmsg.txfields ('20').TYPE      := 'N';
        l_txmsg.txfields ('20').VALUE     := rec.DUTYAMT;
        --21  PRICEACCOUNTING N
        l_txmsg.txfields ('21').defname   := 'PRICEACCOUNTING';
        l_txmsg.txfields ('21').TYPE      := 'N';
        l_txmsg.txfields ('21').VALUE     := rec.PRICEACCOUNTING;
        --22  CATYPEVALUE     C
        l_txmsg.txfields ('22').defname   := 'CATYPEVALUE';
        l_txmsg.txfields ('22').TYPE      := 'C';
        l_txmsg.txfields ('22').VALUE     := rec.CATYPEVALUE;
        --30  DESCRIPTION C
        l_txmsg.txfields ('30').defname   := 'DESCRIPTION';
        l_txmsg.txfields ('30').TYPE      := 'C';
        l_txmsg.txfields ('30').VALUE     := rec.DESCRIPTION;
        --40  STATUS      C
        l_txmsg.txfields ('40').defname   := 'STATUS';
        l_txmsg.txfields ('40').TYPE      := 'C';
        l_txmsg.txfields ('40').VALUE     := rec.STATUSCD;
        --12  COSTPRICE  N
        l_txmsg.txfields ('12').defname   := 'COSTPRICE';
        l_txmsg.txfields ('12').TYPE      := 'N';
        l_txmsg.txfields ('12').VALUE     := rec.COSTPRICE;
        --60    ISCDCROUTAMT N
        l_txmsg.txfields ('60').defname   := 'ISCDCROUTAMT';
        l_txmsg.txfields ('60').TYPE      := 'N';
        l_txmsg.txfields ('60').VALUE     := rec.ISCDCROUTAMT;

        --10    ISCANCEL C
        l_txmsg.txfields ('10').defname   := 'ISCANCEL';
        l_txmsg.txfields ('10').TYPE      := 'C';
        l_txmsg.txfields ('10').VALUE     := v_iscancel;
        --- 24 CODEID C
        l_txmsg.txfields ('24').defname   := 'CODEID';
        l_txmsg.txfields ('24').TYPE      := 'C';
        l_txmsg.txfields ('24').VALUE     := rec.CODEID;

        --26 SEACCTNOOPT
        l_txmsg.txfields ('26').defname   := 'SEACCTNOOPT';
        l_txmsg.txfields ('26').TYPE      := 'N';
        l_txmsg.txfields ('26').VALUE     := rec.SEACCTNOOPT;

        --67ISOPT
        l_txmsg.txfields ('67').defname   := 'ISOPT';
        l_txmsg.txfields ('67').TYPE      := 'N';
        l_txmsg.txfields ('67').VALUE     := rec.ISOPT;

        BEGIN
            IF txpks_#3351.fn_batchtxprocess (l_txmsg,
                                             p_err_code,
                                             l_err_param
               ) <> systemnums.c_success
            THEN
               plog.debug (pkgctx,
                           'got error 3351: ' || p_err_code
               );
               ROLLBACK;
               RETURN;
            END IF;
        END;
    end loop;
    p_err_code:=0;
    plog.setendsection(pkgctx, 'pr_3351_Exec_Sec_CA');
  EXCEPTION
  WHEN OTHERS
   THEN
      plog.debug (pkgctx,'got error on pr_3351_Exec_Sec_CA');
      ROLLBACK;
      p_err_code := errnums.C_SYSTEM_ERROR;
      plog.error (pkgctx, SQLERRM|| dbms_utility.format_error_backtrace);
      plog.setendsection (pkgctx, 'pr_3351_Exec_Sec_CA');
      RAISE errnums.E_SYSTEM_ERROR;
  END pr_3351_Exec_Sec_CA;

PROCEDURE pr_CALAUTOCA3342( p_err_code  OUT varchar2)
  IS
  v_strCURRDATE DATE;
  v_strDATEFEE DATE;
  v_strCOMPANYCD varchar2(10);
  v_Result  number(20);
  l_txmsg               tx.msg_rectype;
  v_errcode NUMBER;
  l_err_param varchar2(300);
  v_POTXNUM varchar2(20);
  v_strAutoID varchar2(100);
  l_OrgDesc varchar2(100);
  l_EN_OrgDesc varchar2(100);

BEGIN
    plog.setbeginsection (pkgctx, 'pr_CALAUTOCA3342');
    plog.debug (pkgctx, '<<BEGIN OF pr_CALAUTOCA3342');
    p_err_code:= systemnums.C_SUCCESS;
    --GET TDMAST ATRIBUTES
    SELECT TO_DATE(VARVALUE,'DD/MM/YYYY') into v_strCURRDATE FROM SYSVAR  WHERE VARNAME='CURRDATE';
    SELECT VARVALUE || '%' into v_strCOMPANYCD FROM SYSVAR  WHERE VARNAME='COMPANYCD';

    SELECT TO_DATE(VARVALUE,'DD/MM/YYYY') into v_strCURRDATE FROM SYSVAR  WHERE VARNAME='CURRDATE';


    for rec in (

    select max(A.AUTOID) AUTOID,a.camastid, a.description, b.symbol, a.actiondate ,a.actiondate POSTINGDATE,
        sum (
            (case when a.catype = '010' then (case when chd.status = 'K' then round((100-a.exerate)/100,4) else round(a.exerate/100,4) end) else 1 end)
                *(case when (case when chd.PITRATEMETHOD <> '##' then chd.PITRATEMETHOD else a.PITRATEMETHOD end) = 'SC' or cf.vat='N'
                then chd.amt else (CASE WHEN a.catype in ('016','023')
                THEN round(chd.amt-round(chd.intamt*a.pitrate/100))
                ELSE round(chd.amt-round(chd.amt*a.pitrate/100)) end
                ) END)
        )allamt,
        sum(chd.amt) amt,
        sum (case when (case when chd.PITRATEMETHOD <>'##' then chd.PITRATEMETHOD else a.PITRATEMETHOD end)    = 'SC' and cf.vat='Y'
            then (CASE WHEN a.catype in ('016','023') THEN round (chd.intamt * a.pitrate/100) ELSE round( chd.amt * a.pitrate/100) END ) else 0 end) scvatamt,
        max(cd.cdcontent) catype,
        max(a.codeid) codeid, a.isincode,
        max(TX.txdesc)  TXDESC
    from camast a, sbsecurities b , caschd chd,allcode cd, afmast af, aftype aft, cfmast cf, TLTX TX
    where a.codeid = b.codeid and a.status  in ('I','G','H','K')
        and chd.afacctno = af.acctno and af.actype = aft.actype and af.custid = cf.custid
        and a.deltd<>'Y' AND TX.TLTXCD = '3342'
        and a.camastid = chd.camastid
        and chd.deltd <> 'Y' and chd.ISEXEC='Y'
        and chd.status <> 'C' and chd.isCI ='N'
        and ACTIONDATE =getcurrdate()
        and a.catype ='010'
        and (select count(1) from caschd where camastid = a.camastid and status <> 'C' and isCI ='N' AND ISEXEC='Y' and amt>0 and deltd='N') >0
        and cd.cdname ='CATYPE' and cd.cdtype ='CA' and cd.cdval = a.catype
        and NOT EXISTS (select 1 from tllog tl where tl.tltxcd ='3342' and tl.deltd <> 'Y' and tl.txstatus ='4' and tl.msgacct=a.camastid)
        group by a.isincode,a.camastid, a.description, b.symbol, a.actiondate
        having sum(chd.amt) <>0
    )
    loop

  SELECT TXDESC,EN_TXDESC into l_OrgDesc, l_EN_OrgDesc FROM  TLTX WHERE TLTXCD='3342';

        SELECT TO_DATE (varvalue, systemnums.c_date_format)
               INTO v_strCURRDATE
               FROM sysvar
               WHERE grname = 'SYSTEM' AND varname = 'CURRDATE';

        l_txmsg.msgtype:='T';
        l_txmsg.local:='N';
        l_txmsg.tlid        := systemnums.c_system_userid;
        SELECT SYS_CONTEXT ('USERENV', 'HOST'),
                 SYS_CONTEXT ('USERENV', 'IP_ADDRESS', 15)
          INTO l_txmsg.wsname, l_txmsg.ipaddress
        FROM DUAL;
        l_txmsg.off_line    := 'N';
        l_txmsg.deltd       := txnums.c_deltd_txnormal;
        l_txmsg.txstatus    := txstatusnums.c_txcompleted;
        l_txmsg.msgsts      := '0';
        l_txmsg.ovrsts      := '0';
        l_txmsg.batchname   := 'DAY';
        l_txmsg.txdate:=to_date(v_strCURRDATE,systemnums.c_date_format);
        l_txmsg.busdate:=to_date(v_strCURRDATE,systemnums.c_date_format);
        l_txmsg.tltxcd:='3342';

        --Set txnum
        SELECT systemnums.C_BATCH_PREFIXED
                         || LPAD (seq_BATCHTXNUM.NEXTVAL, 8, '0')
                  INTO l_txmsg.txnum
                  FROM DUAL;
        l_txmsg.brid        := '0001';


      --Set cac field giao dich
     --03  CAMASTID   C
        l_txmsg.txfields ('03').defname   := 'CAMASTID';
        l_txmsg.txfields ('03').TYPE      := 'C';
        l_txmsg.txfields ('03').VALUE     := rec.CAMASTID;

     --04  SYMBOL      C
        l_txmsg.txfields ('04').defname   := 'SYMBOL';
        l_txmsg.txfields ('04').TYPE      := 'C';
        l_txmsg.txfields ('04').VALUE     := rec.SYMBOL;

     --06  CODEID    C
        l_txmsg.txfields ('06').defname   := 'CODEID';
        l_txmsg.txfields ('06').TYPE      := 'C';
        l_txmsg.txfields ('06').VALUE     := rec.CODEID;

     --08  AMT         N
        l_txmsg.txfields ('08').defname   := 'AMT';
        l_txmsg.txfields ('08').TYPE      := 'N';
        l_txmsg.txfields ('08').VALUE     := rec.ALLAMT;

    --05  CATYPE     C
        l_txmsg.txfields ('05').defname   := 'CATYPE';
        l_txmsg.txfields ('05').TYPE      := 'C';
        l_txmsg.txfields ('05').VALUE     := rec.CATYPE;

   --07  ACTIONDATE      C
        l_txmsg.txfields ('07').defname   := 'ACTIONDATE';
        l_txmsg.txfields ('07').TYPE      := 'C';
        l_txmsg.txfields ('07').VALUE     := rec.ACTIONDATE;

    --13  CONTENTS     C
        l_txmsg.txfields ('13').defname   := 'CONTENTS';
        l_txmsg.txfields ('13').TYPE      := 'C';
        l_txmsg.txfields ('13').VALUE     := '';

   --30  DESC        C
        l_txmsg.txfields ('30').defname   := 'DESC';
        l_txmsg.txfields ('30').TYPE      := 'C';
        l_txmsg.txfields ('30').VALUE     := REC.TXDESC;



        BEGIN
            IF txpks_#3342.fn_autotxprocess (l_txmsg,
                                             v_errcode,
                                             l_err_param
               ) <> systemnums.c_success
            THEN
               plog.debug (pkgctx,
                           'got error 3342: ' || v_errcode
               );
               p_err_code:= v_errcode;
               ROLLBACK;
               RETURN;
            END IF;
        END;

    end loop;




EXCEPTION
WHEN OTHERS
   THEN
      plog.error (pkgctx, SQLERRM);
      plog.setendsection (pkgctx, 'pr_CALAUTOCA3342');
END pr_CALAUTOCA3342 ;
FUNCTION fn_ExecuteContractCAEvent(p_txmsg in tx.msg_rectype,p_err_code out varchar2)
RETURN NUMBER
IS
v_blnREVERSAL boolean;
l_lngErrCode    number(20,0);
v_count number(20,0);
v_dblFEEAMT number(20,4);
v_strRIGHTTYPE varchar2(50);
v_catype varchar2(10);
v_codeid varchar2(50);
v_righttype varchar2(50);
v_tocodeid varchar2(50);
v_dblDFQTTY number;
v_dblCARATE number;
v_strtocodeid varchar2(50);
v_strIswtf char(1);
v_countCI NUMBER(20,0);
v_countSE NUMBER(20,0);
v_status    varchar2(10);
v_cancelstatus varchar2(1);
V_exerate   number(10,0);
V_ISSE varchar2(1);
BEGIN
    plog.setbeginsection (pkgctx, 'fn_ExecuteContractCAEvent');
    plog.debug (pkgctx, '<<BEGIN OF fn_ExecuteContractCAEvent');
   /***************************************************************************************************
    ** PUT YOUR SPECIFIC AFTER PROCESS HERE. DO NOT COMMIT/ROLLBACK HERE, THE SYSTEM WILL DO IT
    ***************************************************************************************************/
    v_blnREVERSAL:=case when p_txmsg.deltd ='Y' then true else false end;
    l_lngErrCode:= errnums.C_BIZ_RULE_INVALID;
    SELECT CAMAST.catype, camast.codeid, camast.tocodeid, camast.status, camast.cancelstatus, camast.exerate
        into v_catype, v_codeid, v_tocodeid, v_status, v_cancelstatus, V_exerate
    FROM CAMAST
    WHERE CAMASTID = p_txmsg.txfields('02').value;
    SELECT VARVALUE into v_strRIGHTTYPE FROM SYSVAR WHERE VARNAME='RIGHTCONVERTTYPE';
    if not v_blnREVERSAL then
        for rec in (
            SELECT cs.STATUS ,cs.ISCI, cs.ISSE, cs.AMT, cs.AAMT, cs.QTTY, cs.AQTTY,cs.DFQTTY,cs.DFAMT, cf.vat
            FROM CASCHD cs, afmast af, cfmast cf
            WHERE cs.afacctno = af.acctno and af.custid = cf.custid
                and cs.AUTOID=p_txmsg.txfields('01').value AND cs.DELTD ='N'
        )
        loop
            if rec.STATUS='C' THEN
                p_err_code:='-300012';
                plog.setendsection (pkgctx, 'fn_ExecuteContractCAEvent');
                return l_lngErrCode;
            else
                if p_txmsg.tltxcd='3351' then
                    --HaiLT them de phan bo vao SEPITLOG
                    insert into caexec_temp (TLAUTOID,txnum,autoid, balance, camastid, afacctno, catype, codeid,
                          excodeid, qtty, amt, aqtty, aamt, symbol, status,seacctno, exseacctno, parvalue, exparvalue, reportdate,
                          actiondate, postingdate, description, taskcd, dutyamt,
                          fullname, idcode, custodycd,custid,TRADEPLACE, SECTYPE, PITRATE, TOCODEID)
                          SELECT seq_tllog.NEXTVAL, '99' || LPAD (seq_BATCHTXNUM.NEXTVAL, 8, '0') txnum,
                          CA.AUTOID, CA.BALANCE, replace(ca.CAMASTID,'.','') CAMASTID, CA.AFACCTNO,ca.catypevalue CATYPE, CA.CODEID,
                          CA.EXCODEID, CA.QTTY, ROUND(CA.AMT) AMT, ROUND(CA.AQTTY) AQTTY,ROUND(CA.AAMT) AAMT, CA.SYMBOL, mst.status,
                          CA.SEACCTNO,CA.EXSEACCTNO,CA.PARVALUE, CA.EXPARVALUE, CA.REPORTDATE ,CA.ACTIONDATE ,CA.POSTINGDATE,
                          CA.description, CA.taskcd, CA.DUTYAMT, CA.FULLNAME, CA.IDCODE, CA.CUSTODYCD, cf.custid, SYM.TRADEPLACE, SYM.SECTYPE, CA.PITRATE,
                          CASE WHEN NVL(CA.TOCODEID,'A')='A' THEN CA.CODEID ELSE CA.TOCODEID END TOCODEID
                          FROM v_ca3351 ca,caschd mst, cfmast cf,sbsecurities sym where(CA.codeid = sym.codeid And CA.autoid = mst.autoid)
                          and replace(ca.CAMASTID,'.','')= p_txmsg.txfields('02').value and ca.custodycd = cf.custodycd AND mst.AUTOID=p_txmsg.txfields('01').value;

                    if rec.VAT = 'Y' then
                        INSERT INTO SEPITLOG(AUTOID,TXDATE,TXNUM,QTTY,MAPQTTY,CODEID,CAMASTID,ACCTNO,MODIFIEDDATE,AFACCTNO,PRICE,PITRATE,CATYPE)
                              select SEQ_SEPITLOG.NEXTVAL, TO_DATE (p_txmsg.txdate, 'DD/MM/RRRR'), rec.txnum,ROUND(rec.QTTY,0),0,
                              --case when rec.catype IN ('009','011','021') and LENGTH(nvl(rec.tocodeid,''))>0 then rec.tocodeid else rec.codeid end codeid,
                              rec.tocodeid codeid,
                              rec.camastid, rec.afacctno||rec.tocodeid, TO_DATE (p_txmsg.txdate, 'DD/MM/RRRR'), rec.afacctno,rec.parvalue, rec.pitrate,REC.CATYPE
                              from caexec_temp rec where camastid = p_txmsg.txfields('02').value and afacctno=  p_txmsg.txfields('03').value
                              and INSTR((SELECT VARVALUE FROM sysvar WHERE GRNAME='SYSTEM' AND VARNAME='RIGHTVATDUTY'),rec.catype) > 0;
                      end if;

                    delete from caexec_temp where camastid = p_txmsg.txfields('02').value ;

                    begin
                        SELECT CAMAST.catype, camast.codeid, camast.tocodeid into v_catype, v_codeid, v_tocodeid
                            FROM CAMAST
                            WHERE CAMASTID=p_txmsg.txfields('02').value;
                        SELECT VARVALUE into v_righttype FROM SYSVAR WHERE VARNAME='RIGHTCONVERTTYPE';


                        If InStr(v_righttype, v_catype) > 0 Then

                            SELECT to_number(substr(ca.DEVIDENTSHARES,0,instr(ca.DEVIDENTSHARES,'/')-1)) / to_number(substr(ca.DEVIDENTSHARES,instr(ca.DEVIDENTSHARES,'/')+1)),
                                   case when ca.iswft='Y' then nvl(sb.codeid,ca.tocodeid) else ca.tocodeid end, ca.iswft
                                into v_dblCARATE, v_strtocodeid, v_strIswtf
                            FROM CAMAST ca, sbsecurities sb
                            WHERE ca.CAMASTID=p_txmsg.txfields('02').value and ca.tocodeid= sb.refcodeid(+);
                            for rec in (
                                  SELECT * FROM SEPITLOG WHERE CODEID=v_codeid and afacctno=  p_txmsg.txfields('03').value
                                )
                            loop
                                insert into sepitlog (AUTOID,TXDATE,TXNUM,QTTY,MAPQTTY,CODEID,PCAMASTID,CAMASTID,ACCTNO,MODIFIEDDATE,AFACCTNO,PRICE,PITRATE,CARATE,CATYPE)
                                     values(SEQ_SEPITLOG.NEXTVAL, TO_DATE (rec.txdate, 'DD/MM/RRRR'),'', floor(to_number(rec.QTTY-rec.MAPQTTY) / v_dblCARATE),0, v_strtocodeid, rec.CAMASTID,p_txmsg.txfields('02').value,
                                         substr(rec.ACCTNO,1,10) || v_strtocodeid, TO_DATE (p_txmsg.txdate, 'DD/MM/RRRR'), rec.AFACCTNO, rec.PRICE, rec.PITRATE,to_number(nvl(rec.CARATE,1)) * v_dblCARATE,REC.CATYPE) ;
                                UPDATE SEPITLOG SET QTTY=MAPQTTY
                                    WHERE AUTOID=rec.AUTOID;
                            end loop;
                        end if;
                    exception when others then
                        null;
                    end;
                    --End of HaiLT them de phan bo vao SEPITLOG
                end if;
                v_dblDFQTTY:= rec.DFQTTY;
                If v_dblDFQTTY > 0 And rec.ISSE = 'N' Then
                    CSPKS_DFPROC.pr_CADealReceive(p_txmsg.txfields('01').value,v_dblDFQTTY,p_err_code);
                end if;
                if p_txmsg.tltxcd in ('3350','3352','3354') THEN
                    if(v_catype = '010') then
                        ---DungNh cap nhat trang thai cua su kien co tuc bang tien them trang thai phan bo 1 phan.
                        if(v_status = 'K' or V_exerate = 100) then
                            UPDATE CASCHD SET ISCI = 'Y', pstatus = pstatus || status, status = 'J'
                            WHERE AUTOID=p_txmsg.txfields('01').value AND DELTD ='N';
                        else
                            UPDATE CASCHD SET ISCI = 'N', pstatus = pstatus || status, status = 'K'
                            WHERE AUTOID=p_txmsg.txfields('01').value AND DELTD='N';
                        end if;
                        ---- end DungNH
                    else
                        --PhuongHT edit: doi trang thai sau khi phan bo tien
                        UPDATE CASCHD SET ISCI='Y',pstatus=pstatus||status,
                        status= (CASE WHEN (status='H' OR status='W' OR qtty= 0) THEN 'J' ELSE 'G' END)
                        WHERE AUTOID=p_txmsg.txfields('01').value AND DELTD ='N';
                    end if;
                   -- neu la caschd cuoi cung thi update trong camast
                   -- kiem tra xem co tai khoan nao chua dc phan bo tien khong
                   if not length(trim(p_txmsg.reftxnum))=10 then
                        SELECT count(1) into v_countCI FROM CASCHD
                          WHERE  CAMASTID = p_txmsg.txfields('02').value  AND DELTD ='N'
                          AND amt> 0 AND ISCI='N' AND isexec='Y'
                          AND status <> 'O';
                         -- kiem tra xem co tai khoan nao chua dc phan bo CK khong
                          SELECT count(1) into v_countSE FROM CASCHD
                          WHERE  CAMASTID=p_txmsg.txfields('02').value  AND DELTD ='N'
                          AND qtty> 0 AND ISSE='N'
                          AND status <> 'O';
                          -- update trang thai trong CAMAST
                          if(v_countCI = 0 AND v_countSE = 0) THEN
                          UPDATE CAMAST SET STATUS ='J'
                          WHERE CAMASTID=p_txmsg.txfields('02').value;

                          ELSIF (v_countCI= 0 AND v_countSE > 0) THEN
                          UPDATE CAMAST SET STATUS = 'G'
                          WHERE CAMASTID=p_txmsg.txfields('02').value;
                          END IF;

                        if(v_catype = '010' and p_txmsg.tltxcd <> '3354') then
                            ---DungNh cap nhat trang thai cua su kien co tuc bang tien them trang thai phan bo 1 phan.
                            if(v_status = 'K' or V_exerate = 100) then
                                UPDATE CAMAST SET STATUS = 'J'
                                WHERE CAMASTID=p_txmsg.txfields('02').value;
                            else
                                UPDATE CAMAST SET STATUS = 'K'
                                WHERE CAMASTID=p_txmsg.txfields('02').value;
                            end if;
                            ---- end DungNH
                        end if;

                   end if;

                    --HaiLT them de khi Tien CA ve thi giai toa trong DFMAST va chuyen vao DFAMT trong DFGROUP
                    if p_txmsg.tltxcd in ('3350') AND rec.DFAMT>0 then
                        for rec1 in (select * from dfmast where dfref = p_txmsg.txfields('01').value and DEALTYPE='T')
                            loop
                                UPDATE DFMAST SET CACASHQTTY=CACASHQTTY-rec1.CACASHQTTY where acctno=rec1.ACCTNO;
                                UPDATE DFGROUP SET DFAMT =DFAMT + rec1.CACASHQTTY WHERE GROUPID=rec1.GROUPID;
                                UPDATE CASCHD SET DFAMT=DFAMT - rec1.CACASHQTTY WHERE AUTOID= rec1.dfref;
                            end loop;
                    end if;
                    --End of HaiLT them de khi Tien CA ve thi giai toa trong DFMAST va chuyen vao DFAMT trong DFGROUP

                elsif p_txmsg.tltxcd='3351' then

                    if(v_catype IN ('023','020')) then
                        if(p_txmsg.txfields('10').value = 'N') then
                                UPDATE CASCHD SET ISSE = 'Y', pstatus = pstatus || status, status = 'J'
                                WHERE AUTOID = p_txmsg.txfields('01').value AND DELTD = 'N';
                        end if;
                        if(p_txmsg.txfields('10').value = 'Y') then
                                UPDATE CASCHD SET pstatus = pstatus||status,
                                    status = (CASE WHEN (status = 'G' OR amt = 0) THEN 'J' ELSE 'H' END)
                                WHERE AUTOID = p_txmsg.txfields('01').value AND DELTD ='N' and ISSE='Y';
                        end if;
                    else
                        UPDATE CASCHD SET ISSE='Y',  pstatus=pstatus||status,
                            status=(CASE WHEN (status='G' OR amt= 0) THEN 'J' ELSE 'H' END)
                        WHERE AUTOID=p_txmsg.txfields('01').value AND DELTD ='N';
                    end if;
                      -- neu la caschd cuoi cung thi update trong camast
                   -- kiem tra xem co tai khoan nao chua dc phan bo tien khong
                   if not length(trim(p_txmsg.reftxnum))=10 then
                     SELECT count(1) into v_countCI FROM CASCHD
                      WHERE  CAMASTID=p_txmsg.txfields('02').value  AND DELTD ='N'
                      AND amt> 0 AND ISCI='N' AND isexec='Y'
                      AND status <>'O';

                     -- kiem tra xem co tai khoan nao chua dc phan bo CK khong
                      SELECT count(1) into v_countSE FROM CASCHD
                      WHERE  CAMASTID=p_txmsg.txfields('02').value  AND DELTD ='N'
                      AND qtty> 0 AND ISSE='N'
                      AND status <> 'O';
                      -- update trang thai trong CAMAST
                          if(v_catype = '010' and v_status <> 'K') then
                                UPDATE CAMAST SET STATUS = 'K'
                                WHERE CAMASTID = p_txmsg.txfields('02').value;
                          end if;
                          if(v_countCI = 0 AND v_countSE = 0) THEN
                              UPDATE CAMAST SET STATUS ='J'
                              WHERE CAMASTID=p_txmsg.txfields('02').value
                                and (case when v_catype IN ('023','020') then cancelstatus else 'Y' end)= 'Y';
                                ----and cancelstatus = 'Y';
                              ELSIF (v_countCI> 0 AND v_countSE = 0) THEN
                              UPDATE CAMAST SET STATUS ='H'
                              WHERE CAMASTID=p_txmsg.txfields('02').value;
                          END IF;
                   end if;
                end if;
                If Not ((p_txmsg.tltxcd = '3350' Or p_txmsg.tltxcd = '3352' Or p_txmsg.tltxcd = '3351' Or p_txmsg.tltxcd = '3354')
                            And ((rec.ISCI = 'N' And rec.AMT+rec.AAMT > 0)
                             Or (rec.ISSE = 'N') And rec.QTTY + rec.AQTTY > 0)) Then
                    plog.debug(pkgctx,'GianhVG-Updatestatus');
                    --UPDATE CASCHD SET STATUS='C' WHERE AUTOID=p_txmsg.txfields('01').value AND DELTD ='N';
                end if;
            end if;
            exit when 0=0;
        end loop;
    else
        --UPDATE CASCHD SET STATUS='S' WHERE status='C' AND AUTOID=p_txmsg.txfields('01').value AND DELTD ='N';
        if p_txmsg.tltxcd in ('3350','3352','3354') then


               UPDATE CASCHD SET ISCI = 'N', PSTATUS = PSTATUS||STATUS,
                               status = (CASE WHEN (substr(PSTATUS,length(PSTATUS),1)) = 'W' THEN 'W'
                                              WHEN (substr(PSTATUS,length(PSTATUS),1)) = 'K' THEN 'K'
                                              WHEN (status = 'G' OR qtty = 0) THEN 'S'
                                              WHEN (status = 'K') THEN 'S'
                                                  ELSE 'H' END)
               WHERE AUTOID=p_txmsg.txfields('01').value AND DELTD ='N';

              -- kiem tra xem co tai khoan nao chua dc phan bo tien khong
                    if not length(trim(p_txmsg.reftxnum))=10 then
                     SELECT count(1) into v_countCI FROM CASCHD
                      WHERE  CAMASTID=p_txmsg.txfields('02').value  AND DELTD ='N'
                      AND  ISCI='N' AND isexec='Y'
                      AND status <> 'O';
                     -- kiem tra xem co tai khoan nao chua dc phan bo CK khong
                      SELECT count(1) into v_countSE FROM CASCHD
                      WHERE  CAMASTID=p_txmsg.txfields('02').value  AND DELTD ='N'
                      AND  ISSE='N'
                      AND status <> 'O';
                      -- update trang thai trong CAMAST

                      if(v_countCI > 0 AND v_countSE > 0) THEN
                      UPDATE CAMAST SET STATUS ='I'
                      WHERE CAMASTID=p_txmsg.txfields('02').value;
                      ELSIF (v_countCI> 0 AND v_countSE = 0) THEN
                      UPDATE CAMAST SET STATUS ='H'
                      WHERE CAMASTID = p_txmsg.txfields('02').value;
                      ELSIF (v_countCI = 0 AND v_countSE > 0) THEN
                      UPDATE CAMAST SET STATUS ='G'
                      WHERE CAMASTID=p_txmsg.txfields('02').value;
                      END IF;
                      if(v_catype = '010' and  p_txmsg.tltxcd <> '3354') then
                        ---DungNh cap nhat trang thai cua su kien co tuc bang tien them trang thai phan bo 1 phan.
                        if(v_status = 'K' or V_exerate = 100) then
                            UPDATE CAMAST SET STATUS = 'I'
                            WHERE CAMASTID=p_txmsg.txfields('02').value;
                        else
                            UPDATE CAMAST SET STATUS = 'K'
                            WHERE CAMASTID=p_txmsg.txfields('02').value;
                        end if;
                        ---- end DungNH
                        end if;

                    end if;


             --HaiLT them de khi Tien CA ve thi giai toa trong DFMAST va chuyen vao DFAMT trong DFGROUP
            if p_txmsg.tltxcd in ('3350') then
                for rec1 in (select * from dfmast where dfref = p_txmsg.txfields('01').value and DEALTYPE='T')
                    loop
                        UPDATE DFMAST SET CACASHQTTY= CACASHQTTY + rec1.AMT * 100 / rec1.DFRATE  where acctno=rec1.ACCTNO;
                        UPDATE DFGROUP SET DFAMT =DFAMT - rec1.AMT WHERE GROUPID=rec1.GROUPID;
                    end loop;
            end if;
            --End of HaiLT them de khi Tien CA ve thi giai toa trong DFMAST va chuyen vao DFAMT trong DFGROUP

        elsif p_txmsg.tltxcd='3351' then

                    if(v_catype  IN ('023','020') AND p_txmsg.txfields('10').value = 'N') then
                        if(p_txmsg.txfields('10').value = 'N') then
                            if(v_cancelstatus = 'Y') then
                                UPDATE CASCHD SET ISSE = 'N', pstatus = pstatus || status, status = 'I'
                                WHERE AUTOID = p_txmsg.txfields('01').value AND DELTD = 'N';
                            else
                                UPDATE CASCHD SET ISSE = 'N'
                                WHERE AUTOID = p_txmsg.txfields('01').value AND DELTD ='N';
                            end if;
                        end if;
                        if(p_txmsg.txfields('10').value = 'Y') then
                                UPDATE CASCHD SET pstatus = pstatus||status,
                                    status = 'I'
                                WHERE AUTOID = p_txmsg.txfields('01').value AND DELTD ='N';--- and ISSE='Y';
                        end if;
                    else

                -- kiem tra xem co tai khoan nao chua dc phan bo tien khong
                    if not length(trim(p_txmsg.reftxnum))=10 then
                     SELECT count(1) into v_countCI FROM CASCHD
                      WHERE  CAMASTID=p_txmsg.txfields('02').value  AND DELTD ='N'
                      AND ISCI='N' AND isexec='Y'
                      AND status <> 'O';
                     -- kiem tra xem co tai khoan nao chua dc phan bo CK khong
                      SELECT count(1) into v_countSE FROM CASCHD
                      WHERE  CAMASTID=p_txmsg.txfields('02').value  AND DELTD ='N'
                      AND ISSE='N'
                      AND status <> 'O';
                      -- update trang thai trong CAMAST
                      if(v_countCI > 0 AND v_countSE > 0) THEN
                      UPDATE CAMAST SET STATUS ='I'
                      WHERE CAMASTID=p_txmsg.txfields('02').value;
                      ELSIF (v_countCI> 0 AND v_countSE = 0) THEN
                      UPDATE CAMAST SET STATUS ='H'
                      WHERE CAMASTID=p_txmsg.txfields('02').value;
                      ELSIF (v_countCI= 0 AND v_countSE > 0) THEN
                      UPDATE CAMAST SET STATUS ='G'
                      WHERE CAMASTID=p_txmsg.txfields('02').value;
                      END IF;
                    end if;
                    end if;
        end if;
        if p_txmsg.tltxcd='3351' then
            --HaiLT them de xoa trong SEPITLOG khi xoa gd 3351
            for rec in (
                SELECT CAS.*, CAM.TOCODEID FROM CASCHD CAS, CAMAST CAM
                WHERE CAS.AUTOID = p_txmsg.txfields('01').value
                    AND CAS.CAMASTID=CAM.CAMASTID AND CAS.CAMASTID= p_txmsg.txfields('02').value
            )
            loop
                UPDATE SEPITLOG SET CAMASTID=PCAMASTID,
                        PCAMASTID= '',
                        CODEID = rec.CODEID
                    WHERE CODEID=rec.TOCODEID and afacctno=  p_txmsg.txfields('03').value;
            end loop;
            DELETE FROM SEPITLOG WHERE CAMASTID = p_txmsg.txfields('02').value and afacctno=  p_txmsg.txfields('03').value;
            --End of HaiLT de xoa trong SEPITLOG khi xoa gd 3351
        end if;
    end if;

    plog.debug (pkgctx, '<<END OF fn_ExecuteContractCAEvent');
    plog.setendsection (pkgctx, 'fn_ExecuteContractCAEvent');
    RETURN systemnums.C_SUCCESS;
EXCEPTION
WHEN OTHERS
   THEN
      p_err_code := errnums.C_SYSTEM_ERROR;
      plog.error (pkgctx, SQLERRM);
       plog.setendsection (pkgctx, 'fn_ExecuteContractCAEvent');
      RAISE errnums.E_SYSTEM_ERROR;
END fn_ExecuteContractCAEvent;
-- initial LOG
BEGIN
   SELECT *
   INTO logrow
   FROM tlogdebug
   WHERE ROWNUM <= 1;

   pkgctx    :=
      plog.init ('cspks_caproc',
                 plevel => logrow.loglevel,
                 plogtable => (logrow.log4table = 'Y'),
                 palert => (logrow.log4alert = 'Y'),
                 ptrace => (logrow.log4trace = 'Y')
      );
END;
/
