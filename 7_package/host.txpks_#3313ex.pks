SET DEFINE OFF;
CREATE OR REPLACE PACKAGE txpks_#3313ex
/**----------------------------------------------------------------------------------------------------
 ** Package: TXPKS_#3313EX
 ** and is copyrighted by FSS.
 **
 **    All rights reserved.  No part of this work may be reproduced, stored in a retrieval system,
 **    adopted or transmitted in any form or by any means, electronic, mechanical, photographic,
 **    graphic, optic recording or otherwise, translated in any language or computer language,
 **    without the prior written permission of Financial Software Solutions. JSC.
 **
 **  MODIFICATION HISTORY
 **  Person      Date           Comments
 **  System      10/07/2021     Created
 **  
 ** (c) 2008 by Financial Software Solutions. JSC.
 ** ----------------------------------------------------------------------------------------------------*/
IS
FUNCTION fn_txPreAppCheck(p_txmsg in tx.msg_rectype,p_err_code out varchar2)
RETURN NUMBER;
FUNCTION fn_txAftAppCheck(p_txmsg in tx.msg_rectype,p_err_code out varchar2)
RETURN NUMBER;
FUNCTION fn_txPreAppUpdate(p_txmsg in tx.msg_rectype,p_err_code out varchar2)
RETURN NUMBER;
FUNCTION fn_txAftAppUpdate(p_txmsg in tx.msg_rectype,p_err_code out varchar2)
RETURN NUMBER;
END;
/


CREATE OR REPLACE PACKAGE BODY txpks_#3313ex
IS
   pkgctx   plog.log_ctx;
   logrow   tlogdebug%ROWTYPE;

   c_reqid            CONSTANT CHAR(2) := '06';
   c_catype           CONSTANT CHAR(2) := '02';
   c_vsdcaid          CONSTANT CHAR(2) := '03';
   c_reportdate       CONSTANT CHAR(2) := '05';
   c_status           CONSTANT CHAR(2) := '09';
   c_reqtype          CONSTANT CHAR(2) := '08';
   c_desc             CONSTANT CHAR(2) := '30';
FUNCTION fn_txPreAppCheck(p_txmsg in tx.msg_rectype,p_err_code out varchar2)
RETURN NUMBER
IS
    v_count   NUMBER;
    v_status  camast.status%TYPE;
    v_catype  camast.catype%TYPE;
BEGIN
   plog.setbeginsection (pkgctx, 'fn_txPreAppCheck');
   plog.debug(pkgctx,'BEGIN OF fn_txPreAppCheck');
   /***************************************************************************************************
    * PUT YOUR SPECIFIC RULE HERE, FOR EXAMPLE:
    * IF NOT <<YOUR BIZ CONDITION>> THEN
    *    p_err_code := '<<ERRNUM>>'; -- Pre-defined in DEFERROR table
    *    plog.setendsection (pkgctx, 'fn_txPreAppCheck');
    *    RETURN errnums.C_BIZ_RULE_INVALID;
    * END IF;
    ***************************************************************************************************/
    SELECT COUNT(1) INTO v_count FROM vsdtxreq
    WHERE REQID = p_txmsg.txfields(c_reqid).value AND STATUS NOT IN ('C', 'E','W');

    IF v_count = 0 THEN
       p_err_code := '-300081'; -- Pre-defined in DEFERROR table
       plog.setendsection (pkgctx, 'fn_txPreAppCheck');
       RETURN errnums.C_BIZ_RULE_INVALID;
    END IF;

    IF p_txmsg.txfields(c_reqtype).value IN ('REPL', 'CANC', 'FIN') THEN
       BEGIN
          SELECT status, catype INTO v_status, v_catype FROM camast ca WHERE vsdid = p_txmsg.txfields(c_vsdcaid).value;

          IF p_txmsg.txfields(c_reqtype).value = 'REPL' AND INSTR('PN', v_status) = 0 THEN
             p_err_code := '-300080'; -- Pre-defined in DEFERROR table
             plog.setendsection (pkgctx, 'fn_txPreAppCheck');
             RETURN errnums.C_BIZ_RULE_INVALID;
          END IF;

          IF p_txmsg.txfields(c_reqtype).value = 'CANC' AND INSTR('PNIAVS', v_status) = 0 THEN
             p_err_code := '-300080'; -- Pre-defined in DEFERROR table
             plog.setendsection (pkgctx, 'fn_txPreAppCheck');
             RETURN errnums.C_BIZ_RULE_INVALID;
          END IF;

          IF p_txmsg.txfields(c_reqtype).value = 'FIN' THEN
             IF v_catype <> '005' AND INSTR('J', v_status) = 0 THEN
                p_err_code := '-300080'; -- Pre-defined in DEFERROR table
                plog.setendsection (pkgctx, 'fn_txPreAppCheck');
                RETURN errnums.C_BIZ_RULE_INVALID;
             END IF;

             IF v_catype = '005' AND INSTR('S', v_status) = 0 THEN
                p_err_code := '-300080'; -- Pre-defined in DEFERROR table
                plog.setendsection (pkgctx, 'fn_txPreAppCheck');
                RETURN errnums.C_BIZ_RULE_INVALID;
             END IF;
          END IF;
       EXCEPTION WHEN OTHERS THEN
          p_err_code := '-300080'; -- Pre-defined in DEFERROR table
          plog.setendsection (pkgctx, 'fn_txPreAppCheck');
          RETURN errnums.C_BIZ_RULE_INVALID;
       END;
    END IF;
    plog.debug (pkgctx, '<<END OF fn_txPreAppCheck');
    plog.setendsection (pkgctx, 'fn_txPreAppCheck');
    RETURN systemnums.C_SUCCESS;
EXCEPTION
WHEN OTHERS
   THEN
      p_err_code := errnums.C_SYSTEM_ERROR;
      plog.error (pkgctx, SQLERRM || dbms_utility.format_error_backtrace);
      plog.setendsection (pkgctx, 'fn_txPreAppCheck');
      RAISE errnums.E_SYSTEM_ERROR;
END fn_txPreAppCheck;

FUNCTION fn_txAftAppCheck(p_txmsg in tx.msg_rectype,p_err_code out varchar2)
RETURN NUMBER
IS
BEGIN
   plog.setbeginsection (pkgctx, 'fn_txAftAppCheck');
   plog.debug (pkgctx, '<<BEGIN OF fn_txAftAppCheck>>');
   /***************************************************************************************************
    * PUT YOUR SPECIFIC RULE HERE, FOR EXAMPLE:
    * IF NOT <<YOUR BIZ CONDITION>> THEN
    *    p_err_code := '<<ERRNUM>>'; -- Pre-defined in DEFERROR table
    *    plog.setendsection (pkgctx, 'fn_txAftAppCheck');
    *    RETURN errnums.C_BIZ_RULE_INVALID;
    * END IF;
    ***************************************************************************************************/
   plog.debug (pkgctx, '<<END OF fn_txAftAppCheck>>');
   plog.setendsection (pkgctx, 'fn_txAftAppCheck');
   RETURN systemnums.C_SUCCESS;
EXCEPTION
WHEN OTHERS
   THEN
      p_err_code := errnums.C_SYSTEM_ERROR;
      plog.error (pkgctx, SQLERRM || dbms_utility.format_error_backtrace);
      plog.setendsection (pkgctx, 'fn_txAftAppCheck');
      RAISE errnums.E_SYSTEM_ERROR;
END fn_txAftAppCheck;

FUNCTION fn_txPreAppUpdate(p_txmsg in tx.msg_rectype,p_err_code out varchar2)
RETURN NUMBER
IS
BEGIN
    plog.setbeginsection (pkgctx, 'fn_txPreAppUpdate');
    plog.debug (pkgctx, '<<BEGIN OF fn_txPreAppUpdate');
   /***************************************************************************************************
    ** PUT YOUR SPECIFIC PROCESS HERE. . DO NOT COMMIT/ROLLBACK HERE, THE SYSTEM WILL DO IT
    ***************************************************************************************************/
    plog.debug (pkgctx, '<<END OF fn_txPreAppUpdate');
    plog.setendsection (pkgctx, 'fn_txPreAppUpdate');
    RETURN systemnums.C_SUCCESS;
EXCEPTION
WHEN OTHERS
   THEN
      p_err_code := errnums.C_SYSTEM_ERROR;
      plog.error (pkgctx, SQLERRM || dbms_utility.format_error_backtrace);
       plog.setendsection (pkgctx, 'fn_txPreAppUpdate');
      RAISE errnums.E_SYSTEM_ERROR;
END fn_txPreAppUpdate;

FUNCTION fn_txAftAppUpdate(p_txmsg in tx.msg_rectype,p_err_code out varchar2)
RETURN NUMBER
IS
    l_txmsg           tx.msg_rectype;
    l_err_param       VARCHAR2(100);
    l_currdate        DATE;
    v_strSQL          VARCHAR2(400);
    v_vsdtxdate       DATE;
    -- thong tin su kien quyen
    v_autoid          NUMBER;
    v_codeid          VARCHAR2(10);
    v_catype          VARCHAR2(3);
    v_reportdate      DATE;
    v_duedate         DATE;
    v_actiondate      DATE;
    v_exprice         NUMBER default 0;
    v_price           NUMBER;
    v_exrate          VARCHAR2(100);
    v_rightoffrate    VARCHAR2(50);
    v_devidentrate    VARCHAR2(100);
    v_devidentshares  VARCHAR2(100);
    v_splitrate       VARCHAR2(100);
    v_interestrate    VARCHAR2(100);
    v_interestperiod  NUMBER default 0;
    v_status          VARCHAR2(1);
    v_camastid        VARCHAR2(20);
    v_description     VARCHAR2(250);
    v_excodeid        VARCHAR2(6);
    v_pstatus         VARCHAR2(50);
    v_rate            NUMBER default 0;
    v_deltd           CHAR(1) default 'N';
    v_trflimit        CHAR(1) default 'N';
    v_parvalue        NUMBER default 0;
    v_roundtype       VARCHAR2(2) default '0';
    v_optsymbol       VARCHAR2(50);
    v_optcodeid       VARCHAR2(50);
    v_tradedate       DATE;
    v_lastdate        DATE;
    v_retailshare     VARCHAR2(1) default 'N';
    v_retaildate      DATE;
    v_frdateretail    DATE;
    v_todateretail    DATE;
    v_frtradeplace    VARCHAR2(3);
    v_totradeplace    VARCHAR2(3);
    v_transfertimes   VARCHAR2(1) default '0';
    v_frdatetransfer  DATE;
    v_todatetransfer  DATE;
    v_taskcd          VARCHAR2(10);
    v_tocodeid        VARCHAR2(10);
    v_last_change     TIMESTAMP(6) default systimestamp;
    v_pitrate         NUMBER default (0);
    v_pitratemethod   VARCHAR2(2) default 'NO';
    v_iswft           VARCHAR2(1) default 'N';
    v_priceaccounting NUMBER default 0;
    v_caqtty          NUMBER(20);
    v_begindate       DATE;
    v_purposedesc     VARCHAR2(250);
    v_devidentvalue   NUMBER(20);
    v_advdesc         VARCHAR2(250);
    v_typerate        CHAR(1);
    v_ciroundtype     NUMBER default 0;
    v_cashround       NUMBER default 0;
    v_pitratese       NUMBER default 0;
    v_inactiondate    DATE;
    v_makerid         VARCHAR2(4);
    v_apprvid         VARCHAR2(4);
    v_vsdtxnum        VARCHAR2(20);
    v_refcorpid       VARCHAR2(50);
    v_vsdcaid         VARCHAR2(50);
    v_isincode        VARCHAR2(50);

    l_strSQL        varchar2(3000);
    l_strObjectName     varchar2(1000);
    l_strRecordKey      varchar2(1000);
    l_strChildObjName   varchar2(1000);
    l_strChildRecordKey varchar2(1000);
    L_MOD_NUM           number;
BEGIN
    plog.setbeginsection (pkgctx, 'fn_txAftAppUpdate');
    plog.debug (pkgctx, '<<BEGIN OF fn_txAftAppUpdate');
   /***************************************************************************************************
    ** PUT YOUR SPECIFIC AFTER PROCESS HERE. DO NOT COMMIT/ROLLBACK HERE, THE SYSTEM WILL DO IT
    ***************************************************************************************************/
    plog.debug (pkgctx, '<<END OF fn_txAftAppUpdate');
    plog.setendsection (pkgctx, 'fn_txAftAppUpdate');
    l_currdate := getcurrdate;
    IF p_txmsg.deltd <> 'Y' THEN
        IF p_txmsg.txfields(c_reqtype).value = 'CANC' THEN
            for rec in (
                select ca.*, sb.symbol, sb1.symbol symbol_org
                from camast ca, sbsecurities sb, sbsecurities sb1
                where ca.codeid = sb.codeid
                  and nvl(ca.tocodeid, ca.codeid) = sb1.codeid
                  and vsdid = p_txmsg.txfields(c_vsdcaid).value
           ) LOOP
                Begin
                    l_strSQL := 'SELECT ''R'' status, ''D'' vsdstatus '
                                ||' WHERE CAMASTID = ''' || rec.camastid || '''';
                    l_strObjectName := 'CAMAST';
                    l_strRecordKey  := 'CAMASTID';
                    l_strChildObjName := '';
                    l_strChildRecordKey  := '';
                    prc_maintainlog(l_strSQL, l_strObjectName, l_strRecordKey, rec.camastid, l_strChildObjName,l_strChildRecordKey,'', p_txmsg.TLID,'EDIT');
                End;

                UPDATE camast SET pstatus = pstatus || status, status = 'R', vsdstatus = 'D'
                WHERE camastid = rec.camastid;

                UPDATE caschd SET pstatus = pstatus || status, status = 'R'
                WHERE camastid = rec.camastid;
            END LOOP;
           /*-- Auto call 3388
           l_txmsg.tltxcd    := '3388';
           l_txmsg.msgtype   := 'T';
           l_txmsg.local     := 'N';
           l_txmsg.tlid      := p_txmsg.tlid;
           l_txmsg.off_line  := 'N';
           l_txmsg.deltd     := txnums.c_deltd_txnormal;
           l_txmsg.txstatus  := txstatusnums.c_txcompleted;
           l_txmsg.msgsts    := '0';
           l_txmsg.ovrsts    := '0';
           l_txmsg.batchname := 'DAY';
           l_txmsg.busdate   := l_currdate;
           l_txmsg.txdate    := l_currdate;
           l_txmsg.brid      := '0000';
           l_txmsg.reftxnum  := p_txmsg.txnum;

           select sys_context('USERENV', 'HOST'), sys_context('USERENV', 'IP_ADDRESS', 15)
           into l_txmsg.wsname, l_txmsg.ipaddress from dual;

           for rec in (
                select ca.*, sb.symbol, sb1.symbol symbol_org
                from camast ca, sbsecurities sb, sbsecurities sb1
                where ca.codeid = sb.codeid
                  and nvl(ca.tocodeid, ca.codeid) = sb1.codeid
                  and vsdid = p_txmsg.txfields(c_vsdcaid).value
           ) LOOP
              select systemnums.c_batch_prefixed || lpad(seq_batchtxnum.nextval, 8, '0')
              into l_txmsg.txnum from dual;

              select to_char(sysdate, 'hh24:mi:ss') into l_txmsg.txtime from dual;
              --03    CAMASTID     C
              l_txmsg.txfields('03').defname := 'CAMASTID';
              l_txmsg.txfields('03').type := 'C';
              l_txmsg.txfields('03').value := rec.CAMASTID;
              --04    SYMBOL     C
              l_txmsg.txfields('04').defname := 'SYMBOL';
              l_txmsg.txfields('04').type := 'C';
              l_txmsg.txfields('04').value := rec.SYMBOL;
              --05    CATYPE     C
              l_txmsg.txfields('05').defname := 'CATYPE';
              l_txmsg.txfields('05').type := 'C';
              l_txmsg.txfields('05').value := rec.CATYPE;
              --06    REPORTDATE     C
              l_txmsg.txfields('06').defname := 'REPORTDATE';
              l_txmsg.txfields('06').type := 'D';
              l_txmsg.txfields('06').value := rec.REPORTDATE;
              --07    ACTIONDATE     C
              l_txmsg.txfields('07').defname := 'ACTIONDATE';
              l_txmsg.txfields('07').type := 'C';
              l_txmsg.txfields('07').value := rec.ACTIONDATE;
              --10    RATE     C
              l_txmsg.txfields('10').defname := 'RATE';
              l_txmsg.txfields('10').type := 'C';
              l_txmsg.txfields('10').value := rec.RATE;
              --20    STATUS     C
              l_txmsg.txfields('20').defname := 'STATUS';
              l_txmsg.txfields('20').type := 'C';
              l_txmsg.txfields('20').value := rec.STATUS;
              --71    SYMBOL_ORG     C
              l_txmsg.txfields('71').defname := 'SYMBOL_ORG';
              l_txmsg.txfields('71').type := 'C';
              l_txmsg.txfields('71').value := rec.SYMBOL_ORG;
              --30    DESC     C
              l_txmsg.txfields('30').defname := 'DESC';
              l_txmsg.txfields('30').type := 'C';
              l_txmsg.txfields('30').value := 'VSD huy dot thuc hien quyen';

              BEGIN
                 if txpks_#3388.fn_batchtxprocess(l_txmsg, p_err_code, l_err_param) <> systemnums.c_success then
                    plog.setendsection (pkgctx, 'fn_txAftAppUpdate');
                    RETURN errnums.C_BIZ_RULE_INVALID;
                 end if;
              END;
           END LOOP;
           */
           /*ELSIF p_txmsg.txfields(c_reqtype).value = 'FDTRAD' THEN
           SELECT effdate INTO v_vsdtxdate FROM msgcareceived WHERE reqid = p_txmsg.txfields(c_reqid).value;
           -- Auto call 3356
           l_txmsg.tltxcd    := '3356';
           l_txmsg.msgtype   := 'T';
           l_txmsg.local     := 'N';
           l_txmsg.tlid      := systemnums.c_system_userid;
           l_txmsg.off_line  := 'N';
           l_txmsg.deltd     := txnums.c_deltd_txnormal;
           l_txmsg.txstatus  := txstatusnums.c_txcompleted;
           l_txmsg.msgsts    := '0';
           l_txmsg.ovrsts    := '0';
           l_txmsg.batchname := 'DAY';
           l_txmsg.busdate   := v_vsdtxdate;
           l_txmsg.txdate    := l_currdate;
           l_txmsg.brid      := systemnums.c_system_userid;

           SELECT sys_context('USERENV', 'HOST'), sys_context('USERENV', 'IP_ADDRESS', 15)
           INTO l_txmsg.wsname, l_txmsg.ipaddress FROM dual;

           --Lay thong tin dien
           FOR rec IN (SELECT * FROM v_ca3356 WHERE vsdcaid = p_txmsg.txfields(c_vsdcaid).value) LOOP
              SELECT systemnums.c_batch_prefixed || lpad(seq_batchtxnum.nextval, 8, '0')
              INTO l_txmsg.txnum FROM dual;

              select to_char(sysdate, 'hh24:mi:ss') into l_txmsg.txtime from dual;

              l_txmsg.txfields('03').defname := 'CAMASTID';
              l_txmsg.txfields('03').TYPE    := 'C';
              l_txmsg.txfields('03').value   := rec.camastid;

              l_txmsg.txfields('04').defname := 'SYMBOL';
              l_txmsg.txfields('04').TYPE    := 'C';
              l_txmsg.txfields('04').value   := rec.symbol;

              l_txmsg.txfields('08').defname := 'CODEID';
              l_txmsg.txfields('08').TYPE    := 'C';
              l_txmsg.txfields('08').value   := rec.codeid;

              l_txmsg.txfields('05').defname := 'CATYPE';
              l_txmsg.txfields('05').TYPE    := 'C';
              l_txmsg.txfields('05').value   := rec.catype;

              l_txmsg.txfields('13').defname := 'CONTENTS';
              l_txmsg.txfields('13').TYPE    := 'C';
              l_txmsg.txfields('13').value   := rec.DESCRIPTION;

              l_txmsg.txfields('21').defname := 'CAQTTY';
              l_txmsg.txfields('21').TYPE    := 'N';
              l_txmsg.txfields('21').value   := rec.CAQTTY;

              l_txmsg.txfields('10').defname := 'TRADE';
              l_txmsg.txfields('10').TYPE    := 'N';
              l_txmsg.txfields('10').value   := rec.TRADE;

              l_txmsg.txfields('19').defname := 'BLOCKED';
              l_txmsg.txfields('19').TYPE    := 'N';
              l_txmsg.txfields('19').value   := rec.BLOCKED;

              l_txmsg.txfields('20').defname := 'REALQTTY';
              l_txmsg.txfields('20').TYPE    := 'N';
              l_txmsg.txfields('20').value   := rec.REALQTTY;

              l_txmsg.txfields('22').defname := 'QTTY';
              l_txmsg.txfields('22').TYPE    := 'N';
              l_txmsg.txfields('22').value   := '';

              l_txmsg.txfields('23').defname := 'DIFFQTTY';
              l_txmsg.txfields('23').TYPE    := 'N';
              l_txmsg.txfields('23').value   := rec.DIFFQTTY;

              l_txmsg.txfields('07').defname := 'TRADEDATE';
              l_txmsg.txfields('07').TYPE    := 'C';
              l_txmsg.txfields('07').value   := rec.TRADEDATE;

              l_txmsg.txfields('09').defname := 'PRICE';
              l_txmsg.txfields('09').TYPE    := 'N';
              l_txmsg.txfields('09').value   := rec.PRICE;

              l_txmsg.txfields('30').defname := 'DESC';
              l_txmsg.txfields('30').TYPE    := 'C';
              l_txmsg.txfields('30').value   := '';

              BEGIN
                 IF txpks_#3356.fn_batchtxprocess(l_txmsg, p_err_code, l_err_param) <> systemnums.c_success then
                      plog.setendsection (pkgctx, 'fn_txAftAppUpdate');
                      RETURN errnums.C_BIZ_RULE_INVALID;
                 END IF;
              END;
           END LOOP;*/
            ELSIF p_txmsg.txfields(c_reqtype).value = 'STINST' THEN
               SELECT trunc(txdate) INTO v_vsdtxdate
               FROM msgcareceived WHERE reqid = p_txmsg.txfields(c_reqid).value;

               select max(camastid) into v_camastid from camast where vsdid = p_txmsg.txfields(c_vsdcaid).value;

               select MAX(MOD_NUM) INTO L_MOD_NUM from maintain_log where TABLE_NAME = 'CAMAST' and RECORD_KEY = 'CAMASTID = ''' || v_camastid || '''';
                L_MOD_NUM:= nvl(L_MOD_NUM,-1) + 1;

               INSERT INTO maintain_log (TABLE_NAME,RECORD_KEY,MAKER_ID,MAKER_DT,APPROVE_RQD,APPROVE_ID,APPROVE_DT,MOD_NUM,
               COLUMN_NAME,FROM_VALUE,TO_VALUE,ACTION_FLAG,CHILD_TABLE_NAME,CHILD_RECORD_KEY,MAKER_TIME)
               SELECT 'CAMAST' TABLE_NAME,'CAMASTID = ''' || ca.camastid || '''' RECORD_KEY,'0000' MAKER_ID,l_currdate MAKER_DT,'Y' APPROVE_RQD,null APPROVE_ID,
                null APPROVE_DT, L_MOD_NUM MOD_NUM,'BEGINDATE' COLUMN_NAME , TO_CHAR(ca.BEGINDATE,'DD/MM/RRRR') FROM_VALUE, TO_CHAR(v_vsdtxdate,'DD/MM/RRRR') TO_VALUE,'EDIT' ACTION_FLAG,
                NULL CHILD_TABLE_NAME,NULL CHILD_RECORD_KEY,to_char(sysdate,'hh24:mm:ss') MAKER_TIME
               FROM camast ca
               WHERE camastid = v_camastid;

               UPDATE camast SET begindate = v_vsdtxdate WHERE camastid = v_camastid;
            ELSIF p_txmsg.txfields(c_reqtype).value = 'ENINST' THEN
               SELECT trunc(txdate) INTO v_vsdtxdate
               FROM msgcareceived WHERE reqid = p_txmsg.txfields(c_reqid).value;

               select max(camastid) into v_camastid from camast where vsdid = p_txmsg.txfields(c_vsdcaid).value;

               select MAX(MOD_NUM) INTO L_MOD_NUM from maintain_log where TABLE_NAME = 'CAMAST' and RECORD_KEY = 'CAMASTID = ''' || v_camastid || '''';
                L_MOD_NUM:= nvl(L_MOD_NUM,-1) + 1;

               INSERT INTO maintain_log (TABLE_NAME,RECORD_KEY,MAKER_ID,MAKER_DT,APPROVE_RQD,APPROVE_ID,APPROVE_DT,MOD_NUM,
               COLUMN_NAME,FROM_VALUE,TO_VALUE,ACTION_FLAG,CHILD_TABLE_NAME,CHILD_RECORD_KEY,MAKER_TIME)
               SELECT 'CAMAST' TABLE_NAME,'CAMASTID = ''' || ca.camastid || '''' RECORD_KEY,'0000' MAKER_ID,l_currdate MAKER_DT,'Y' APPROVE_RQD,null APPROVE_ID,
                null APPROVE_DT, L_MOD_NUM MOD_NUM,'DUEDATE' COLUMN_NAME , TO_CHAR(ca.DUEDATE,'DD/MM/RRRR') FROM_VALUE, TO_CHAR(v_vsdtxdate,'DD/MM/RRRR') TO_VALUE,'EDIT' ACTION_FLAG,
                NULL CHILD_TABLE_NAME,NULL CHILD_RECORD_KEY,to_char(sysdate,'hh24:mm:ss') MAKER_TIME
               FROM camast ca
               WHERE camastid = v_camastid;

               UPDATE camast SET duedate = v_vsdtxdate WHERE camastid = v_camastid;
            ELSIF p_txmsg.txfields(c_reqtype).value = 'STTRAD' THEN
               SELECT trunc(txdate) INTO v_vsdtxdate
               FROM msgcareceived WHERE reqid = p_txmsg.txfields(c_reqid).value;

               select max(camastid) into v_camastid from camast where vsdid = p_txmsg.txfields(c_vsdcaid).value;

               select MAX(MOD_NUM) INTO L_MOD_NUM from maintain_log where TABLE_NAME = 'CAMAST' and RECORD_KEY = 'CAMASTID = ''' || v_camastid || '''';
                L_MOD_NUM:= nvl(L_MOD_NUM,-1) + 1;

               INSERT INTO maintain_log (TABLE_NAME,RECORD_KEY,MAKER_ID,MAKER_DT,APPROVE_RQD,APPROVE_ID,APPROVE_DT,MOD_NUM,
               COLUMN_NAME,FROM_VALUE,TO_VALUE,ACTION_FLAG,CHILD_TABLE_NAME,CHILD_RECORD_KEY,MAKER_TIME)
               SELECT 'CAMAST' TABLE_NAME,'CAMASTID = ''' || ca.camastid || '''' RECORD_KEY,'0000' MAKER_ID,l_currdate MAKER_DT,'Y' APPROVE_RQD,null APPROVE_ID,
                null APPROVE_DT, L_MOD_NUM MOD_NUM,'FRDATETRANSFER' COLUMN_NAME , TO_CHAR(ca.FRDATETRANSFER,'DD/MM/RRRR') FROM_VALUE, TO_CHAR(v_vsdtxdate,'DD/MM/RRRR') TO_VALUE,'EDIT' ACTION_FLAG,
                NULL CHILD_TABLE_NAME,NULL CHILD_RECORD_KEY,to_char(sysdate,'hh24:mm:ss') MAKER_TIME
               FROM camast ca
               WHERE camastid = v_camastid;

               UPDATE camast SET frdatetransfer = v_vsdtxdate WHERE camastid = v_camastid;
            ELSIF p_txmsg.txfields(c_reqtype).value = 'ENTRAD' THEN
               SELECT trunc(txdate) INTO v_vsdtxdate
               FROM msgcareceived WHERE reqid = p_txmsg.txfields(c_reqid).value;

               select max(camastid) into v_camastid from camast where vsdid = p_txmsg.txfields(c_vsdcaid).value;

               select MAX(MOD_NUM) INTO L_MOD_NUM from maintain_log where TABLE_NAME = 'CAMAST' and RECORD_KEY = 'CAMASTID = ''' || v_camastid || '''';
                L_MOD_NUM:= nvl(L_MOD_NUM,-1) + 1;

               INSERT INTO maintain_log (TABLE_NAME,RECORD_KEY,MAKER_ID,MAKER_DT,APPROVE_RQD,APPROVE_ID,APPROVE_DT,MOD_NUM,
               COLUMN_NAME,FROM_VALUE,TO_VALUE,ACTION_FLAG,CHILD_TABLE_NAME,CHILD_RECORD_KEY,MAKER_TIME)
               SELECT 'CAMAST' TABLE_NAME,'CAMASTID = ''' || ca.camastid || '''' RECORD_KEY,'0000' MAKER_ID,l_currdate MAKER_DT,'Y' APPROVE_RQD,null APPROVE_ID,
                null APPROVE_DT, L_MOD_NUM MOD_NUM,'TODATETRANSFER' COLUMN_NAME , TO_CHAR(ca.TODATETRANSFER,'DD/MM/RRRR') FROM_VALUE, TO_CHAR(v_vsdtxdate,'DD/MM/RRRR') TO_VALUE,'EDIT' ACTION_FLAG,
                NULL CHILD_TABLE_NAME,NULL CHILD_RECORD_KEY,to_char(sysdate,'hh24:mm:ss') MAKER_TIME
               FROM camast ca
               WHERE camastid = v_camastid;

               UPDATE camast SET todatetransfer = v_vsdtxdate WHERE camastid = v_camastid;
            ELSIF p_txmsg.txfields(c_reqtype).value = 'PROC' THEN
               SELECT actiondate INTO v_vsdtxdate
               FROM msgcareceived WHERE reqid = p_txmsg.txfields(c_reqid).value;

               select max(camastid) into v_camastid from camast where vsdid = p_txmsg.txfields(c_vsdcaid).value;

               select MAX(MOD_NUM) INTO L_MOD_NUM from maintain_log where TABLE_NAME = 'CAMAST' and RECORD_KEY = 'CAMASTID = ''' || v_camastid || '''';
                L_MOD_NUM:= nvl(L_MOD_NUM,-1) + 1;

               INSERT INTO maintain_log (TABLE_NAME,RECORD_KEY,MAKER_ID,MAKER_DT,APPROVE_RQD,APPROVE_ID,APPROVE_DT,MOD_NUM,
               COLUMN_NAME,FROM_VALUE,TO_VALUE,ACTION_FLAG,CHILD_TABLE_NAME,CHILD_RECORD_KEY,MAKER_TIME)
               SELECT 'CAMAST' TABLE_NAME,'CAMASTID = ''' || ca.camastid || '''' RECORD_KEY,'0000' MAKER_ID,l_currdate MAKER_DT,'Y' APPROVE_RQD,null APPROVE_ID,
                null APPROVE_DT, L_MOD_NUM MOD_NUM,'ACTIONDATE' COLUMN_NAME , TO_CHAR(ca.ACTIONDATE,'DD/MM/RRRR') FROM_VALUE, TO_CHAR(v_vsdtxdate,'DD/MM/RRRR') TO_VALUE,'EDIT' ACTION_FLAG,
                NULL CHILD_TABLE_NAME,NULL CHILD_RECORD_KEY,to_char(sysdate,'hh24:mm:ss') MAKER_TIME
               FROM camast ca
               WHERE camastid = v_camastid;

               UPDATE camast SET actiondate = v_vsdtxdate WHERE camastid = v_camastid;
            ELSIF p_txmsg.txfields(c_reqtype).value = 'NEWM' THEN
               FOR rec IN (
                  SELECT ca.*, cd.cdcontent catype_desc, '0001' brid,
                         sb.codeid, sb.symbol, sb.sectype, sb1.codeid tocodeid, sb1.symbol tosymbol
                  FROM msgcareceived ca, sbsecurities sb, sbsecurities sb1, allcode cd
                  WHERE ca.reqid = p_txmsg.txfields(c_reqid).value
                    AND cd.cdtype = 'CA' AND cd.cdname = 'CATYPE' AND cd.cdval = ca.catype
                    AND ca.isincode = sb.isincode AND sb.refcodeid IS NULL
                    AND ca.toisincode = sb1.isincode(+) AND sb1.refcodeid IS NULL
                    AND NOT EXISTS (SELECT autoid FROM camast WHERE vsdid = ca.vsdcaid)
               ) LOOP
              v_autoid := seq_camast.nextval;
              v_codeid := rec.codeid;
              v_vsdcaid := rec.vsdcaid;
              v_camastid := fn_gen_camastid(rec.brid, rec.codeid, '');
              v_reportdate := rec.reportdate;
              v_status := 'N';
              v_catype := rec.catype;
              v_makerid := p_txmsg.tlid;
              v_apprvid := p_txmsg.offid;
              v_isincode:= rec.isincode;
              v_actiondate := rec.actiondate;
              begin
                select defdesc into v_description from fldmaster where objname ='CA.CAMAST' and defname ='DESCRIPTION' and fldname = v_catype||'DESCRIPTION';
                EXCEPTION WHEN OTHERS THEN
                    v_description   := '';
              end;
              CASE v_catype
                 WHEN '014' THEN
                    --v_isalloc := 'Y';
                    v_exprice := nvl(rec.exprice, v_exprice);
                    v_price := nvl(rec.price, v_price);
                    v_tocodeid := rec.codeid;
                    v_exrate := SUBSTR(rec.actionrate, 0, INSTR(rec.actionrate, '/') - 1) || '/1';
                    v_rightoffrate := '1/' || SUBSTR(rec.actionrate, INSTR(rec.actionrate, '/') + 1);
                    v_trflimit := CASE WHEN rec.trftype = 'SLLE' THEN 'Y' ELSE v_trflimit END;
                    v_transfertimes := CASE WHEN rec.trftype = 'SLLE' THEN 1 ELSE v_transfertimes END;
                    v_advdesc := fn_gen_advdesc(v_exrate, v_catype, v_rightoffrate);
                    v_iswft := 'Y';
                    v_optsymbol := rec.toisincode;
                    --v_description := '{0}, {1}, ng?y ch?t: {2}, t? l? s? h?u/quy?n: {3}, t? l? quy?n/c? phi?u: {4}';
                    v_description := REPLACE(v_description, '{0}', rec.catype_desc);
                    v_description := REPLACE(v_description, '{1}', rec.symbol);
                    v_description := REPLACE(v_description, '{2}', to_char(v_reportdate, 'DD/MM/RRRR'));
                    v_description := REPLACE(v_description, '{3}', v_exrate);
                    v_description := REPLACE(v_description, '{4}', v_rightoffrate);
                    v_frdatetransfer := rec.frdatetransfer;
                    v_todatetransfer := rec.todatetransfer;
                    v_duedate := rec.duedate;
                    v_begindate :=  rec.begindate;
                 WHEN '028' THEN NULL;
                    IF rec.actionrate IS NOT NULL THEN
                       v_typerate := 'R';
                       v_devidentrate := rec.actionrate;
                    ELSE
                       v_typerate := 'V';
                       v_devidentvalue := rec.actionvalue;
                    END IF;
                    v_exprice := nvl(rec.exprice, v_exprice);
                    v_description := fn_gen_desc_camast_028(v_codeid, v_reportdate, v_typerate, v_devidentrate, v_devidentvalue, v_exprice);
                    -- Thieu actiondate, duedate, begindate
                 WHEN '005' THEN
                    v_devidentshares := rec.actionrate;
                    v_advdesc := fn_gen_advdesc(v_devidentshares, v_catype, 0);
                    --v_description := '{0}, {1}, ng?y ch?t: {2}, t? l?: {3}';
                    v_description := REPLACE(v_description, '{0}', rec.catype_desc);
                    v_description := REPLACE(v_description, '{1}', rec.symbol);
                    v_description := REPLACE(v_description, '{2}', to_char(v_reportdate, 'DD/MM/RRRR'));
                    v_description := REPLACE(v_description, '{3}', v_devidentshares);
                    -- Thieu actiondate
                 WHEN '010' THEN
                    v_typerate := 'R';
                    v_devidentrate := rec.actionrate;
                    --v_cashround := nvl(rec.ciroundtype, v_cashround);
                    v_exprice := nvl(rec.exprice, v_exprice);
                    v_devidentvalue := 0;
                    v_description := fn_gen_description(v_catype,rec.symbol, to_char(v_reportdate, 'DD/MM/RRRR'), v_devidentrate, v_devidentvalue, v_typerate);
                    -- Thieu actiondate
                 WHEN '021' THEN
                    v_exrate := rec.actionrate;
                    v_advdesc := fn_gen_advdesc(v_exrate, v_catype, 0);
                    v_exprice := nvl(rec.exprice, v_exprice);
                    v_optsymbol := fn_gen_optsymbol(rec.codeid, to_char(v_reportdate, 'DD/MM/RRRR'), '');
                    v_cashround := nvl(rec.cashround, v_cashround);
                    v_ciroundtype := nvl(rec.ciroundtype, v_ciroundtype);
                    v_iswft := 'Y';
                    --v_description := '{0}, {1}, ng?y ch?t: {2}, t? l?: {3}';
                    v_description := REPLACE(v_description, '{0}', rec.catype_desc);
                    v_description := REPLACE(v_description, '{1}', rec.symbol);
                    v_description := REPLACE(v_description, '{2}', to_char(v_reportdate, 'DD/MM/RRRR'));
                    v_description := REPLACE(v_description, '{3}', v_exrate);
                    -- Thieu actiondate
                 WHEN '011' THEN
                    v_devidentshares := rec.actionrate;
                    v_advdesc := fn_gen_advdesc(v_devidentshares, v_catype, 0);
                    v_exprice := nvl(rec.exprice, v_exprice);
                    v_cashround := nvl(rec.cashround, v_cashround);
                    v_ciroundtype := nvl(rec.ciroundtype, v_ciroundtype);
                    v_iswft := 'Y';
                    v_optsymbol := fn_gen_optsymbol(rec.codeid, to_char(v_reportdate, 'DD/MM/RRRR'), '');
                    --v_description := '{0}, {1}, ng?y ch?t: {2}, t? l?: {3}';
                    v_description := REPLACE(v_description, '{0}', rec.catype_desc);
                    v_description := REPLACE(v_description, '{1}', rec.symbol);
                    v_description := REPLACE(v_description, '{2}', to_char(v_reportdate, 'DD/MM/RRRR'));
                    v_description := REPLACE(v_description, '{3}', v_devidentshares);
                    -- Thieu actiondate
                 WHEN '015' THEN
                    v_interestrate := rec.actionrate;
                    --v_cashround := nvl(rec.ciroundtype, v_cashround);
                    --v_description := '{0}, {1}, ng?y ch?t: {2}, l?i su?t: {3}%/k?';
                    v_description := REPLACE(v_description, '{0}', rec.catype_desc);
                    v_description := REPLACE(v_description, '{1}', rec.symbol);
                    v_description := REPLACE(v_description, '{2}', to_char(v_reportdate, 'DD/MM/RRRR'));
                    v_description := REPLACE(v_description, '{3}', v_interestrate);
                    -- Thieu actiondate
                 WHEN '016' THEN
                    v_interestrate := rec.actionrate;
                    --v_cashround := nvl(rec.ciroundtype, v_cashround);
                    --v_description := '{0}, {1}, ng?y ch?t: {2}, l?i su?t: {3}%/k?';
                    v_description := REPLACE(v_description, '{0}', rec.catype_desc);
                    v_description := REPLACE(v_description, '{1}', rec.symbol);
                    v_description := REPLACE(v_description, '{2}', to_char(v_reportdate, 'DD/MM/RRRR'));
                    v_description := REPLACE(v_description, '{3}', v_interestrate);
                    -- Thieu actiondate
                 WHEN '020' THEN
                    v_tocodeid := rec.tocodeid;
                    v_devidentshares := rec.actionrate;
                    v_advdesc := fn_gen_advdesc(v_devidentshares, v_catype, 0);
                    v_exprice := nvl(rec.exprice, v_exprice);
                    v_cashround := nvl(rec.cashround, v_cashround);
                    v_ciroundtype := nvl(rec.ciroundtype, v_ciroundtype);
                    v_iswft := 'Y';
                    --v_description := '{0}, chuy?n t? {1} th?nh {2}, ng?y ch?t: {3}, t? l? chuy?n: {4}';
                    v_description := REPLACE(v_description, '{0}', rec.catype_desc);
                    v_description := REPLACE(v_description, '{1}', rec.symbol);
                    v_description := REPLACE(v_description, '{2}', rec.tosymbol);
                    v_description := REPLACE(v_description, '{3}', to_char(v_reportdate, 'DD/MM/RRRR'));
                    v_description := REPLACE(v_description, '{4}', v_devidentshares);
                    -- Thieu actiondate, canceldate, receivedate
                 WHEN '017' THEN
                    v_tocodeid := rec.tocodeid;
                    v_exrate := rec.actionrate;
                    v_advdesc := fn_gen_advdesc(v_exrate, v_catype, 0);
                    v_exprice := nvl(rec.exprice, v_exprice);
                    v_ciroundtype := nvl(rec.ciroundtype, v_ciroundtype);
                    v_cashround := nvl(rec.cashround, v_cashround);
                    v_iswft := 'Y';
                    --v_description := '{0}, chuy?n t? {1} th?nh {2}, ng?y ch?t: {3}, t? l? chuy?n: {4}';
                    v_description := REPLACE(v_description, '{0}', rec.catype_desc);
                    v_description := REPLACE(v_description, '{1}', rec.symbol);
                    v_description := REPLACE(v_description, '{2}', rec.tosymbol);
                    v_description := REPLACE(v_description, '{3}', to_char(v_reportdate, 'DD/MM/RRRR'));
                    v_description := REPLACE(v_description, '{4}', v_exrate);
                    -- Thieu actiondate
                 WHEN '023' THEN
                    v_exrate := rec.actionrate;
                    v_advdesc := fn_gen_advdesc(v_exrate, v_catype, 0);
                    v_tocodeid := rec.tocodeid;
                    v_iswft := 'Y';
                    v_ciroundtype := nvl(rec.ciroundtype, v_ciroundtype);
                    v_cashround := nvl(rec.cashround, v_cashround);
                    --v_cashround := nvl(rec.ciroundtype, v_cashround);
                    v_interestrate := nvl(rec.interestrate, v_interestrate);
                    --v_description := '{0}, chuy?n t? {1} th?nh {2}, ng?y ch?t: {3}, t? l? chuy?n: {4}';
                    v_description := REPLACE(v_description, '{0}', rec.catype_desc);
                    v_description := REPLACE(v_description, '{1}', rec.symbol);
                    v_description := REPLACE(v_description, '{2}', rec.tosymbol);
                    v_description := REPLACE(v_description, '{3}', to_char(v_reportdate, 'DD/MM/RRRR'));
                    v_description := REPLACE(v_description, '{4}', v_exrate);
                    -- Thieu actiondate, begindate, duedate, canceldate, receivedate
                 ELSE NULL;
              END CASE;

              v_purposedesc := v_description;

              INSERT INTO camast(autoid, codeid, catype, reportdate, duedate, actiondate, exprice, price, exrate, rightoffrate,
                          devidentrate, devidentshares, splitrate, interestrate, interestperiod, status, camastid, description,
                          excodeid, pstatus, rate, deltd, trflimit, parvalue, roundtype, optsymbol, optcodeid, tradedate,
                          lastdate, retailshare, retaildate, frdateretail, todateretail, frtradeplace, totradeplace, transfertimes,
                          frdatetransfer, todatetransfer, taskcd, tocodeid, last_change, pitrate, pitratemethod, iswft,
                          priceaccounting, caqtty, begindate, purposedesc, devidentvalue, advdesc, typerate, cashround, ciroundtype, pitratese,
                          inactiondate, makerid, apprvid, refcorpid, vsdid,isincode)
              VALUES(v_autoid, v_codeid, v_catype, v_reportdate, v_duedate, v_actiondate, v_exprice, v_price, v_exrate,
              v_rightoffrate, v_devidentrate, v_devidentshares, v_splitrate, v_interestrate, v_interestperiod, v_status, v_camastid, v_description,
              v_excodeid, v_pstatus, v_rate, v_deltd, v_trflimit, v_parvalue, v_roundtype, v_optsymbol, v_optcodeid, v_tradedate,
              v_lastdate, v_retailshare, v_retaildate, v_frdateretail, v_todateretail, v_frtradeplace, v_totradeplace, v_transfertimes,
              v_frdatetransfer, v_todatetransfer, v_taskcd, v_tocodeid, v_last_change, v_pitrate, v_pitratemethod, v_iswft,
              v_priceaccounting, v_caqtty, v_begindate, v_purposedesc, v_devidentvalue, v_advdesc, v_typerate, v_cashround,v_ciroundtype, v_pitratese,
              v_inactiondate, v_makerid, v_apprvid,v_refcorpid,v_vsdcaid,v_isincode);
           END LOOP;
        ELSE
           FOR rec IN (
              SELECT ca.*, vsd.reportdate vsd_reportdate, vsd.actionrate actionrate, vsd.trftype,
                     vsd.ciroundtype vsd_ciroundtype, vsd.exprice vsd_exprice, vsd.price vsd_price,
                     vsd.actionvalue, cd.cdcontent catype_desc, sb.symbol, sb.symbol tosymbol,
                     vsd.cashround vsd_cashround, vsd.toisincode
              FROM msgcareceived vsd, camast ca, allcode cd, sbsecurities sb, sbsecurities sb1
              WHERE vsd.reqid = p_txmsg.txfields(c_reqid).value
                AND cd.cdtype = 'CA' AND cd.cdname = 'CATYPE' AND cd.cdval = ca.catype
                AND vsd.vsdcaid = ca.vsdid
                AND vsd.isincode = sb.isincode AND sb.refcodeid IS NULL
                AND vsd.toisincode = sb1.isincode(+) AND sb1.refcodeid IS NULL
           ) LOOP
              v_reportdate := nvl(rec.vsd_reportdate, rec.reportdate);
              v_catype := rec.catype;
              v_devidentshares := rec.devidentshares;
              v_advdesc := rec.advdesc;
              v_typerate := rec.typerate;
              v_devidentrate := rec.devidentrate;
              v_devidentvalue := rec.devidentvalue;
              v_exprice := rec.exprice;
              v_optsymbol := rec.optsymbol;
              v_begindate := rec.begindate;
              v_interestrate := rec.interestrate;
              v_rightoffrate := rec.rightoffrate;
              v_cashround := rec.cashround;
              v_ciroundtype := rec.ciroundtype;
              begin
                select defdesc into v_description from fldmaster where objname ='CA.CAMAST' and defname ='DESCRIPTION' and fldname = v_catype||'DESCRIPTION';
                EXCEPTION WHEN OTHERS THEN
                    v_description   := '';
              end;
              CASE v_catype
                 WHEN '014' THEN
                    --v_isalloc := 'Y';
                    v_exprice := nvl(rec.exprice, v_exprice);
                    v_price := nvl(rec.price, v_price);
                    v_tocodeid := rec.codeid;
                    v_exrate := SUBSTR(rec.actionrate, 0, INSTR(rec.actionrate, '/') - 1) || '/1';
                    v_rightoffrate := '1/' || SUBSTR(rec.actionrate, INSTR(rec.actionrate, '/') + 1);
                    v_trflimit := CASE WHEN rec.trftype = 'SLLE' THEN 'Y' ELSE v_trflimit END;
                    v_transfertimes := CASE WHEN rec.trftype = 'SLLE' THEN 1 ELSE v_transfertimes END;
                    v_advdesc := fn_gen_advdesc(v_exrate, v_catype, v_rightoffrate);
                    v_iswft := 'Y';
                    v_optsymbol := rec.toisincode;
                    --v_description := '{0}, {1}, ng?y ch?t: {2}, t? l? s? h?u/quy?n: {3}, t? l? quy?n/c? phi?u: {4}';
                    v_description := REPLACE(v_description, '{0}', rec.catype_desc);
                    v_description := REPLACE(v_description, '{1}', rec.symbol);
                    v_description := REPLACE(v_description, '{2}', to_char(v_reportdate, 'DD/MM/RRRR'));
                    v_description := REPLACE(v_description, '{3}', v_exrate);
                    v_description := REPLACE(v_description, '{4}', v_rightoffrate);
                    v_frdatetransfer := rec.frdatetransfer;
                    v_todatetransfer := rec.todatetransfer;
                    v_duedate := rec.duedate;
                    v_begindate :=  rec.begindate;
                 WHEN '028' THEN NULL;
                    IF rec.actionrate IS NOT NULL THEN
                       v_typerate := 'R';
                       v_devidentrate := rec.actionrate;
                    ELSE
                       v_typerate := 'V';
                       v_devidentvalue := rec.actionvalue;
                    END IF;
                    v_exprice := nvl(rec.vsd_exprice, v_exprice);
                    v_description := fn_gen_desc_camast_028(rec.codeid, v_reportdate, v_typerate, v_devidentrate, v_devidentvalue, v_exprice);
                 WHEN '005' THEN
                    v_devidentshares := nvl(rec.actionrate, v_devidentshares);
                    v_advdesc := fn_gen_advdesc(v_devidentshares, v_catype, 0);
                    --v_description := '{0}, {1}, ng?y ch?t: {2}, t? l?: {3}';
                    v_description := REPLACE(v_description, '{0}', rec.catype_desc);
                    v_description := REPLACE(v_description, '{1}', rec.symbol);
                    v_description := REPLACE(v_description, '{2}', to_char(v_reportdate, 'DD/MM/RRRR'));
                    v_description := REPLACE(v_description, '{3}', v_devidentshares);
                    -- Thieu actiondate
                 WHEN '010' THEN
                    v_typerate := 'R';
                    v_devidentrate := nvl(rec.actionrate, v_devidentrate);
                    --v_cashround := nvl(rec.ciroundtype, v_cashround);
                    v_exprice := nvl(rec.exprice, v_exprice);
                    v_devidentvalue := 0;
                    v_description := fn_gen_description(v_catype,rec.symbol, to_char(v_reportdate, 'DD/MM/RRRR'), v_devidentrate, v_devidentvalue, v_typerate);
                    -- Thieu actiondate
                 WHEN '021' THEN
                    v_exrate := nvl(rec.actionrate, v_exrate);
                    v_advdesc := fn_gen_advdesc(v_exrate, v_catype, 0);
                    v_exprice := nvl(rec.exprice, v_exprice);
                    v_optsymbol := fn_gen_optsymbol(rec.codeid, to_char(v_reportdate, 'DD/MM/RRRR'), v_optsymbol);
                    v_cashround := nvl(rec.vsd_cashround, v_cashround);
                    v_ciroundtype := nvl(rec.vsd_ciroundtype, v_ciroundtype);
                    --v_description := '{0}, {1}, ng?y ch?t: {2}, t? l?: {3}';
                    v_description := REPLACE(v_description, '{0}', rec.catype_desc);
                    v_description := REPLACE(v_description, '{1}', rec.symbol);
                    v_description := REPLACE(v_description, '{2}', to_char(v_reportdate, 'DD/MM/RRRR'));
                    v_description := REPLACE(v_description, '{3}', v_exrate);
                    -- Thieu actiondate
                 WHEN '011' THEN
                    v_devidentshares := nvl(rec.actionrate, v_devidentshares);
                    v_advdesc := fn_gen_advdesc(v_devidentshares, v_catype, 0);
                    v_exprice := nvl(rec.exprice, v_exprice);
                    v_cashround := nvl(rec.vsd_cashround, v_cashround);
                    v_ciroundtype := nvl(rec.vsd_ciroundtype, v_ciroundtype);
                    v_optsymbol := fn_gen_optsymbol(rec.codeid, to_char(v_reportdate, 'DD/MM/RRRR'), v_optsymbol);
                    --v_description := '{0}, {1}, ng?y ch?t: {2}, t? l?: {3}';
                    v_description := REPLACE(v_description, '{0}', rec.catype_desc);
                    v_description := REPLACE(v_description, '{1}', rec.symbol);
                    v_description := REPLACE(v_description, '{2}', to_char(v_reportdate, 'DD/MM/RRRR'));
                    v_description := REPLACE(v_description, '{3}', v_devidentshares);
                    -- Thieu actiondate
                 WHEN '015' THEN
                    v_interestrate := nvl(rec.actionrate, v_interestrate);
                    --v_cashround := nvl(rec.ciroundtype, v_cashround);
                    --v_description := '{0}, {1}, ng?y ch?t: {2}, l?i su?t: {3}%/k?';
                    v_description := REPLACE(v_description, '{0}', rec.catype_desc);
                    v_description := REPLACE(v_description, '{1}', rec.symbol);
                    v_description := REPLACE(v_description, '{2}', to_char(v_reportdate, 'DD/MM/RRRR'));
                    v_description := REPLACE(v_description, '{3}', v_interestrate);
                    -- Thieu actiondate
                 WHEN '016' THEN
                    v_interestrate := nvl(rec.actionrate, v_interestrate);
                    --v_cashround := nvl(rec.ciroundtype, v_cashround);
                    --v_description := '{0}, {1}, ng?y ch?t: {2}, l?i su?t: {3}%/k?';
                    v_description := REPLACE(v_description, '{0}', rec.catype_desc);
                    v_description := REPLACE(v_description, '{1}', rec.symbol);
                    v_description := REPLACE(v_description, '{2}', to_char(v_reportdate, 'DD/MM/RRRR'));
                    v_description := REPLACE(v_description, '{3}', v_interestrate);
                    -- Thieu actiondate
                 WHEN '020' THEN
                    v_tocodeid := rec.tocodeid;
                    v_devidentshares := nvl(rec.actionrate, v_devidentshares);
                    v_advdesc := fn_gen_advdesc(v_devidentshares, v_catype, 0);
                    v_exprice := nvl(rec.exprice, v_exprice);
                    v_cashround := nvl(rec.vsd_cashround, v_cashround);
                    v_ciroundtype := nvl(rec.vsd_ciroundtype, v_ciroundtype);
                    --v_description := '{0}, chuy?n t? {1} th?nh {2}, ng?y ch?t: {3}, t? l? chuy?n: {4}';
                    v_description := REPLACE(v_description, '{0}', rec.catype_desc);
                    v_description := REPLACE(v_description, '{1}', rec.symbol);
                    v_description := REPLACE(v_description, '{2}', rec.tosymbol);
                    v_description := REPLACE(v_description, '{3}', to_char(v_reportdate, 'DD/MM/RRRR'));
                    v_description := REPLACE(v_description, '{4}', v_devidentshares);
                    -- Thieu actiondate, canceldate, receivedate
                 WHEN '017' THEN
                    v_tocodeid := rec.tocodeid;
                    v_exrate := nvl(rec.actionrate, v_exrate);
                    v_advdesc := fn_gen_advdesc(v_exrate, v_catype, 0);
                    v_exprice := nvl(rec.exprice, v_exprice);
                    v_cashround := nvl(rec.vsd_cashround, v_cashround);
                    v_ciroundtype := nvl(rec.vsd_ciroundtype, v_ciroundtype);
                    --v_description := '{0}, chuy?n t? {1} th?nh {2}, ng?y ch?t: {3}, t? l? chuy?n: {4}';
                    v_description := REPLACE(v_description, '{0}', rec.catype_desc);
                    v_description := REPLACE(v_description, '{1}', rec.symbol);
                    v_description := REPLACE(v_description, '{2}', rec.tosymbol);
                    v_description := REPLACE(v_description, '{3}', to_char(v_reportdate, 'DD/MM/RRRR'));
                    v_description := REPLACE(v_description, '{4}', v_exrate);
                    -- Thieu actiondate
                 WHEN '023' THEN
                    v_exrate := nvl(rec.actionrate, v_exrate);
                    v_advdesc := fn_gen_advdesc(v_exrate, v_catype, 0);
                    v_tocodeid := rec.tocodeid;
                    v_cashround := nvl(rec.vsd_cashround, v_cashround);
                    v_ciroundtype := nvl(rec.vsd_ciroundtype, v_ciroundtype);
                    v_interestrate := nvl(rec.interestrate, v_interestrate);
                    --v_description := '{0}, chuy?n t? {1} th?nh {2}, ng?y ch?t: {3}, t? l? chuy?n: {4}';
                    v_description := REPLACE(v_description, '{0}', rec.catype_desc);
                    v_description := REPLACE(v_description, '{1}', rec.symbol);
                    v_description := REPLACE(v_description, '{2}', rec.tosymbol);
                    v_description := REPLACE(v_description, '{3}', to_char(v_reportdate, 'DD/MM/RRRR'));
                    v_description := REPLACE(v_description, '{4}', v_exrate);
                    -- Thieu actiondate, begindate, duedate, canceldate, receivedate
                 ELSE NULL;
              END CASE;

              Begin
                l_strSQL := 'SELECT v_reportdate reportdate, v_actiondate actiondate, v_devidentshares devidentshares, v_advdesc advdesc, '
                            ||'v_typerate typerate, v_devidentrate devidentrate, v_cashround cashround, v_devidentvalue devidentvalue, '
                            ||'v_exprice exprice, v_optsymbol optsymbol, v_rightoffrate rightoffrate, v_exrate exrate, v_description description, '
                            || '''E'' vsdstatus '
                            ||' WHERE CAMASTID = ''' || rec.camastid || '''';
                l_strObjectName := 'CAMAST';
                l_strRecordKey  := 'CAMASTID';
                l_strChildObjName := '';
                l_strChildRecordKey  := '';
                prc_maintainlog(l_strSQL, l_strObjectName, l_strRecordKey, rec.camastid, l_strChildObjName,l_strChildRecordKey,'', p_txmsg.TLID,'EDIT');
              End;

              -- Update CAMAST
              UPDATE camast SET reportdate = v_reportdate, actiondate = v_actiondate,
                                devidentshares = v_devidentshares, advdesc = v_advdesc,
                                typerate = v_typerate, devidentrate = v_devidentrate,
                                cashround = v_cashround, devidentvalue = v_devidentvalue,
                                exprice = v_exprice, optsymbol = v_optsymbol, rightoffrate = v_rightoffrate,
                                begindate = v_begindate, interestrate = v_interestrate,
                                exrate = v_exrate, description = v_description,
                                vsdstatus = 'E'
              WHERE camastid = rec.camastid;


           END LOOP;
        END IF;
        IF p_txmsg.txfields(c_reqid).value IS NOT NULL THEN
          IF p_txmsg.txfields(c_reqtype).value <> 'PROC' THEN
                    UPDATE vsdtxreq SET status = 'C', msgstatus = 'F' WHERE reqid =  p_txmsg.txfields(c_reqid).value;
                    UPDATE msgcareceived SET msgstatus = 'F' WHERE reqid = p_txmsg.txfields(c_reqid).value;
                    UPDATE vsdtrflog SET status = 'C', timeprocess = systimestamp WHERE referenceid = p_txmsg.txfields(c_reqid).value;
                  ELSE
                    UPDATE vsdtxreq SET status = 'W', msgstatus = 'W' WHERE reqid =  p_txmsg.txfields(c_reqid).value;
                    UPDATE msgcareceived SET msgstatus = 'F' WHERE reqid = p_txmsg.txfields(c_reqid).value;
                    UPDATE vsdtrflog SET status = 'C', timeprocess = systimestamp WHERE referenceid = p_txmsg.txfields(c_reqid).value;
          END IF;
        END IF;

    END IF;
    RETURN systemnums.C_SUCCESS;
EXCEPTION
WHEN OTHERS
   THEN
      p_err_code := errnums.C_SYSTEM_ERROR;
      plog.error (pkgctx, SQLERRM || dbms_utility.format_error_backtrace);
       plog.setendsection (pkgctx, 'fn_txAftAppUpdate');
      RAISE errnums.E_SYSTEM_ERROR;
END fn_txAftAppUpdate;

BEGIN
      FOR i IN (SELECT *
                FROM tlogdebug)
      LOOP
         logrow.loglevel    := i.loglevel;
         logrow.log4table   := i.log4table;
         logrow.log4alert   := i.log4alert;
         logrow.log4trace   := i.log4trace;
      END LOOP;
      pkgctx    :=
         plog.init ('TXPKS_#3313EX',
                    plevel => NVL(logrow.loglevel,30),
                    plogtable => (NVL(logrow.log4table,'N') = 'Y'),
                    palert => (NVL(logrow.log4alert,'N') = 'Y'),
                    ptrace => (NVL(logrow.log4trace,'N') = 'Y')
            );
END TXPKS_#3313EX;
/
