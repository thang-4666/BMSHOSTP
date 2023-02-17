SET DEFINE OFF;
CREATE OR REPLACE PACKAGE txpks_#2254ex
/**----------------------------------------------------------------------------------------------------
 ** Package: TXPKS_#2254EX
 ** and is copyrighted by FSS.
 **
 **    All rights reserved.  No part of this work may be reproduced, stored in a retrieval system,
 **    adopted or transmitted in any form or by any means, electronic, mechanical, photographic,
 **    graphic, optic recording or otherwise, translated in any language or computer language,
 **    without the prior written permission of Financial Software Solutions. JSC.
 **
 **  MODIFICATION HISTORY
 **  Person      Date           Comments
 **  System      27/08/2012     Created
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


CREATE OR REPLACE PACKAGE BODY txpks_#2254ex
IS
   pkgctx   plog.log_ctx;
   logrow   tlogdebug%ROWTYPE;

   c_autoid           CONSTANT CHAR(2) := '18';
   c_custodycd        CONSTANT CHAR(2) := '05';
   c_afacctno         CONSTANT CHAR(2) := '02';
   c_acctno           CONSTANT CHAR(2) := '03';
   c_custname         CONSTANT CHAR(2) := '90';
   c_symbol           CONSTANT CHAR(2) := '07';
   c_trade            CONSTANT CHAR(2) := '10';
   c_blocked          CONSTANT CHAR(2) := '06';
   c_caqtty           CONSTANT CHAR(2) := '13';
   c_qtty             CONSTANT CHAR(2) := '12';
   c_recustodycd      CONSTANT CHAR(2) := '23';
   c_recustname       CONSTANT CHAR(2) := '24';
   c_desc             CONSTANT CHAR(2) := '30';
   c_codeid           CONSTANT CHAR(2) := '01';
FUNCTION fn_txPreAppCheck(p_txmsg in tx.msg_rectype,p_err_code out varchar2)
RETURN NUMBER
IS

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
l_count NUMBER(20);
l_trade NUMBER(20);
l_blocked NUMBER(20);
l_caqtty NUMBER(20);
v_blockqtty NUMBER(20);
BEGIN
    plog.setbeginsection (pkgctx, 'fn_txPreAppUpdate');
    plog.debug (pkgctx, '<<BEGIN OF fn_txPreAppUpdate');
   /***************************************************************************************************
    ** PUT YOUR SPECIFIC PROCESS HERE. . DO NOT COMMIT/ROLLBACK HERE, THE SYSTEM WILL DO IT
    ***************************************************************************************************/
    l_trade:=p_txmsg.txfields('10').value;
    l_blocked:=p_txmsg.txfields('06').value;
    l_caqtty:=p_txmsg.txfields('13').value;
    if(p_txmsg.deltd <> 'Y') THEN
        BEGIN
                 SELECT COUNT(*) INTO L_count
                 FROM sesendout
                 WHERE autoid=p_txmsg.txfields('18').value
                 AND ((trade < l_trade) OR(blocked<l_blocked) OR(caqtty<l_caqtty))
                 AND deltd='N';
        EXCEPTION WHEN OTHERS THEN
                  p_err_code:='-200403';
                  plog.setendsection (pkgctx, 'fn_txPreAppUpdate');
                  RETURN errnums.C_BIZ_RULE_INVALID;
        END;
         IF(l_count >0) THEN
            p_err_code := '-200403'; -- Pre-defined in DEFERROR table
            plog.setendsection (pkgctx, 'fn_txPreAppUpdate');
            RETURN errnums.C_BIZ_RULE_INVALID;
         END IF;
    ELSE-- check khi xoa jao dich

       --
       BEGIN
                 SELECT COUNT(*) INTO L_count
                 FROM sesendout
                 WHERE autoid=p_txmsg.txfields('18').value
                 AND strade+sblocked+scaqtty+ctrade+cblocked+ccaqtty>0
                 AND deltd='N';
        EXCEPTION WHEN OTHERS THEN
                  p_err_code:='-200404';
                  plog.setendsection (pkgctx, 'fn_txPreAppUpdate');
                  RETURN errnums.C_BIZ_RULE_INVALID;
        END;
         IF(l_count >0) THEN
            p_err_code := '-200404'; -- Pre-defined in DEFERROR table
            plog.setendsection (pkgctx, 'fn_txPreAppUpdate');
            RETURN errnums.C_BIZ_RULE_INVALID;
         END IF;

    END IF;
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
l_trade NUMBER(20);
l_blocked NUMBER(20);
l_caqtty NUMBER(20);
 v_ourward VARCHAR2(3);
 v_feesv NUMBER;
l_semastcheck_arr txpks_check.semastcheck_arrtype;
l_sewithdrawcheck_arr txpks_check.sewithdrawcheck_arrtype;
l_avlsewithdraw apprules.field%TYPE;
l_tradeapp apprules.field%TYPE;
l_BLOCKEDapp apprules.field%TYPE;
l_cimastcheck_arr txpks_check.cimastcheck_arrtype;
l_baldefovd_released_depofee apprules.field%TYPE;
l_depofeeamt apprules.field%TYPE;
L_STRISTRFCA    VARCHAR2(1);


l_RIGHTQTTY NUMBER;
l_RIGHTOFFQTTY NUMBER;
l_CAQTTYRECEIV NUMBER;
l_CAQTTYDB NUMBER;
l_CAAMTRECEIV NUMBER;
L_SEACCTNO VARCHAR2(20);
L_CODEIDWFT   VARCHAR2(6);
l_custid varchar2(30);

BEGIN
    plog.setbeginsection (pkgctx, 'fn_txAftAppUpdate');
    plog.debug (pkgctx, '<<BEGIN OF fn_txAftAppUpdate');
   /***************************************************************************************************
    ** PUT YOUR SPECIFIC AFTER PROCESS HERE. DO NOT COMMIT/ROLLBACK HERE, THE SYSTEM WILL DO IT
    ***************************************************************************************************/
    l_trade:=p_txmsg.txfields('10').value;
    l_blocked:=p_txmsg.txfields('06').value;
    l_caqtty:=p_txmsg.txfields('13').value;
     SELECT outward, feesv, NVL(istrfca,'N') INTO v_ourward,v_feesv, L_STRISTRFCA FROM sesendout  WHERE autoid= p_txmsg.txfields('18').value;
    if(p_txmsg.deltd <> 'Y') THEN

        UPDATE sesendout
        SET trade=trade-l_trade ,blocked=blocked-l_blocked, caqtty=caqtty-l_caqtty
        WHERE autoid= p_txmsg.txfields('18').value;

        update se2244_log lg
        set deltd = 'Y'
        where lg.sendoutid = p_txmsg.txfields('18').value;
       /* IF v_ourward='009' THEN
                UPDATE CIMAST
                SET
                         BALANCE = BALANCE + v_feesv, LAST_CHANGE = SYSTIMESTAMP
                WHERE ACCTNO=p_txmsg.txfields('55').value;
                INSERT INTO CITRAN(TXNUM,TXDATE,ACCTNO,TXCD,NAMT,CAMT,ACCTREF,DELTD,REF,AUTOID,TLTXCD,BKDATE,TRDESC)
                          VALUES (p_txmsg.txnum, TO_DATE (p_txmsg.txdate, systemnums.C_DATE_FORMAT),p_txmsg.txfields ('55').value,'0029',ROUND(v_feesv,0),NULL,'',p_txmsg.deltd,'',seq_CITRAN.NEXTVAL,p_txmsg.tltxcd,p_txmsg.busdate,'' || '' || '');
          END IF; */
        -- revert lai ck quyen
        --Phuc add 05/02/2021
        for rec in (
            select se.autoid, se.mapqtty,se.status,re.sepitid, re.qtty from sepitlog se, revert_2254log re
            where se.acctno = p_txmsg.txfields('03').value
            and se.deltd <> 'Y' and  se.mapqtty >0 and  se.pitrate > 0 and se.autoid = re.sepitid
            order by txdate DESC
        )
        loop
                update sepitlog set mapqtty = rec.qtty,
                    status=(case when status='C' then 'N' else status end)
                    where autoid = rec.sepitid;

                delete from revert_2254log where sepitid = rec.autoid;
           /* if l_caqtty >  rec.mapqtty then

                update sepitlog set mapqtty = 0,
                status=(case when status='C' then 'N' else status end)
                where autoid = rec.autoid;

            else

                update sepitlog set mapqtty = mapqtty - l_caqtty,
                status =(case when status='C' then 'N' else status end)
                where autoid = rec.autoid;
            end if;
            l_caqtty:=l_caqtty-rec.mapqtty;
            exit when l_caqtty<=0;*/
        end loop;
    ELSE -- xoa jao dich

        --Kiem tra sl du cho phep xoa hay khong
             l_SEWITHDRAWcheck_arr := txpks_check.fn_SEWITHDRAWcheck( p_txmsg.txfields('03').value ,'SEWITHDRAW','ACCTNO');
             l_AVLSEWITHDRAW := l_SEWITHDRAWcheck_arr(0).AVLSEWITHDRAW;
             --Ck trade
             IF NOT (to_number(l_AVLSEWITHDRAW) >= to_number(p_txmsg.txfields('10').value)) THEN
                p_err_code := '-900017';
                plog.setendsection (pkgctx, 'fn_txAppAutoCheck');
                RETURN errnums.C_BIZ_RULE_INVALID;
             END IF;
             l_SEMASTcheck_arr := txpks_check.fn_SEMASTcheck( p_txmsg.txfields('03').value  ,'SEMAST','ACCTNO');
             l_TRADEapp := l_SEMASTcheck_arr(0).TRADE;
             IF NOT (to_number(l_TRADEapp) >= to_number(p_txmsg.txfields('10').value)) THEN
                p_err_code := '-900017';
                plog.setendsection (pkgctx, 'fn_txAppAutoCheck');
                RETURN errnums.C_BIZ_RULE_INVALID;
             END IF;
             --Ck blocked
             l_BLOCKEDapp := l_SEMASTcheck_arr(0).BLOCKED;
             IF NOT (to_number(l_BLOCKEDapp) >= to_number(p_txmsg.txfields('06').value)) THEN
                 p_err_code := '-900040';
                 plog.setendsection (pkgctx, 'fn_txAppAutoCheck');
             RETURN errnums.C_BIZ_RULE_INVALID;
             END IF;
           l_CIMASTcheck_arr := txpks_check.fn_CIMASTcheck(p_txmsg.txfields('02').value,'CIMAST','ACCTNO');

            l_BALDEFOVD_RELEASED_DEPOFEE := l_CIMASTcheck_arr(0).BALDEFOVD_RELEASED_DEPOFEE;
            l_DEPOFEEAMT := l_CIMASTcheck_arr(0).DEPOFEEAMT;

            IF NOT (to_number(l_BALDEFOVD_RELEASED_DEPOFEE) >= to_number(p_txmsg.txfields('32').value)) THEN
              p_err_code := '-400110';
              plog.setendsection (pkgctx, 'fn_txAppAutoCheck');
              RETURN errnums.C_BIZ_RULE_INVALID;
            END IF;
           IF v_ourward=systemnums.C_COMPANYCD THEN
           --Ktra tien co du xoa ko
            l_CIMASTcheck_arr := txpks_check.fn_CIMASTcheck(p_txmsg.txfields('55').value,'CIMAST','ACCTNO');

            l_BALDEFOVD_RELEASED_DEPOFEE := l_CIMASTcheck_arr(0).BALDEFOVD_RELEASED_DEPOFEE;
            l_DEPOFEEAMT := l_CIMASTcheck_arr(0).DEPOFEEAMT;

            IF NOT (to_number(l_BALDEFOVD_RELEASED_DEPOFEE) >= to_number(p_txmsg.txfields('57').value)) THEN
              p_err_code := '-400110';
              plog.setendsection (pkgctx, 'fn_txAppAutoCheck');
              RETURN errnums.C_BIZ_RULE_INVALID;
            END IF;
        end if;

        UPDATE sesendout
        SET trade=trade+l_trade ,blocked=blocked+l_blocked, caqtty=caqtty+l_caqtty
        WHERE autoid= p_txmsg.txfields('18').value;

        --Phan bo phan chung khoan quyen, chuyen sang tai khoan nhan chuyen nhuong

        for rec in (
            select * from sepitlog where acctno = p_txmsg.txfields('03').value
            and deltd <> 'Y' and qtty - mapqtty >0
            order by txdate
        )
        loop
            if l_caqtty > rec.qtty - rec.mapqtty then

                update sepitlog set mapqtty = mapqtty + rec.qtty - rec.mapqtty where autoid = rec.autoid;
                l_caqtty:=l_caqtty-(rec.qtty-rec.mapqtty);
            else

                update sepitlog set mapqtty = mapqtty + l_caqtty, status ='C' where autoid = rec.autoid;
                l_caqtty:=0;
            end if;


            exit when l_caqtty<=0;
        end loop;
    END IF;
    IF L_STRISTRFCA = 'Y' THEN


    SELECT custid into  l_custid FROM cfmast WHERE custodycd =p_txmsg.txfields('05').value;

        if(p_txmsg.deltd = 'Y') THEN -- xoa jao dich
       FOR recall  IN (SELECT acctno FROM afmast WHERE custid = l_custid )
        LOOP

            select SUM(rightoffqtty),SUM(caqttyreceiv),SUM(caqttydb),SUM(caamtreceiv),SUM(rightqtty)
                into l_RIGHTOFFQTTY, l_CAQTTYRECEIV, l_CAQTTYDB, l_CAAMTRECEIV, l_RIGHTQTTY
                from se2244_catrflog
                where sendoutid = p_txmsg.txfields('18').value AND substr( afacctno,1,10) = recall.acctno;

            FOR rec IN (
                          SELECT schd.status,autoid,camastid,reportdate,catype,
                          schd.codeid, schd.afacctno,(schd.afacctno||schd.codeid) seacctno,
                          (CASE WHEN (schd.catype='014' AND schd.castatus NOT IN ('A','P','N','C') AND schd.duedate >=GETCURRDATE )
                          THEN schd.pbalance ELSE 0 END) RIGHTOFFQTTY,
                          (CASE WHEN (schd.catype='014' AND schd.status IN ('M','S','I','G','O','W') AND isse='N') THEN schd.qtty
                          WHEN (schd.catype IN ('017','020','023') AND schd.status IN ('G','S','I','O','W')  AND isse='N' AND istocodeid='Y') THEN schd.qtty
                          WHEN (schd.catype IN ('011','021') AND schd.status  IN ('G','S','I','O','W') AND isse='N' ) THEN schd.qtty
                          ELSE 0 END) CAQTTYRECEIV,
                          (CASE WHEN (schd.catype IN ('016') AND schd.status  IN ('G','S','I','O','W') AND isse='N') THEN nvl(se.trade,0)
                                WHEN (schd.catype IN ('017','020','023') AND schd.status  IN ('G','S','I','O','W') AND isse='N') THEN schd.aqtty
                                ELSE 0 END) CAQTTYDB,
                          (CASE  WHEN (schd.catype IN ('016') AND schd.status  IN ('G','S','I','O','W') AND isse='N' ) THEN 1 ELSE 0 END) ISDBSEALL,
                          (CASE WHEN  (schd.status  IN ('H','S','I','O','W') AND isci='N' AND schd.isexec='Y') THEN SCHD.AMT
                                WHEN  SCHD.STATUS = 'K' THEN SCHD.AMT*(1-SCHD.EXERATE/100)
                                ELSE 0 END) CAAMTRECEIV,
                          (CASE WHEN (schd.catype IN ('005','006','022') AND schd.status IN ('H','G','S','I','J','O','W')) THEN schd.rqtty ELSE 0 END) RIGHTQTTY,
                          ISWFT,optcodeid
                          FROM
                                (SELECT schd.rqtty,schd.autoid,schd.status,camast.catype,camast.duedate,camast.status castatus,schd.afacctno,camast.codeid,
                                camast.tocodeid, schd.camastid,schd.balance,schd.qtty,schd.aqtty,schd.amt,schd.aamt,schd.pbalance,schd.pqtty ,
                                schd.isci,schd.isexec,reportdate ,'N' istocodeid, NVL(ISWFT,'Y') ISWFT, camast.optcodeid, SCHD.ISSE
                                ,CAMAST.EXERATE
                                FROM caschd schd ,camast WHERE schd.camastid=camast.camastid AND schd.deltd='N' AND camast.deltd='N' AND camast.status <> 'C'
                                UNION ALL
                                SELECT schd.rqtty,schd.autoid,  schd.status,camast.catype,camast.duedate,camast.status castatus,schd.afacctno, camast.tocodeid codeid,
                                '',schd.camastid,0,schd.qtty,0,0,0,0,0,
                                schd.isci,schd.isexec ,reportdate ,'Y' istocodeid, NVL(ISWFT,'Y') ISWFT, camast.optcodeid, SCHD.ISSE
                                ,CAMAST.EXERATE
                                FROM caschd schd, camast
                                WHERE schd.camastid=camast.camastid AND camast.catype IN ('017','020','023')AND schd.deltd='N' AND camast.deltd='N' AND camast.status <> 'C'
                                ) SCHD, semast se
                           WHERE schd.codeid=p_txmsg.txfields('01').value
                           AND  schd.afacctno=recall.acctno
                           AND se.acctno(+)=(schd.afacctno||schd.codeid)
                          ORDER BY reportdate
                       )
            LOOP
                     IF ( LEAST(rec.RIGHTQTTY,l_RIGHTQTTY)+LEAST(rec.RIGHTOFFQTTY,l_RIGHTOFFQTTY)+
                          LEAST(rec.CAQTTYRECEIV,l_CAQTTYRECEIV)+LEAST(rec.CAQTTYDB,l_CAQTTYDB)+
                          LEAST(rec.CAAMTRECEIV,l_CAAMTRECEIV)> 0) THEN
                        if(rec.catype <> '016') THEN
                             if(rec.status <> 'O' ) THEN
                                 UPDATE caschd SET status='O',pbalance=pbalance-least(rec.RIGHTOFFQTTY,l_RIGHTOFFQTTY),
                                                   qtty=qtty-least(rec.CAQTTYRECEIV,l_CAQTTYRECEIV),
                                                   rqtty=rqtty-least(rec.RIGHTQTTY,l_RIGHTQTTY),
                                                   aqtty=aqtty-least(rec.CAQTTYDB,l_CAQTTYDB),
                                                   amt=amt-least(rec.CAAMTRECEIV,l_CAAMTRECEIV),
                                                   SENDPBALANCE=SENDPBALANCE+least(rec.RIGHTOFFQTTY,l_RIGHTOFFQTTY),
                                                   SENDQTTY=SENDQTTY+least(rec.CAQTTYRECEIV,l_CAQTTYRECEIV)
                                                   +least(rec.RIGHTQTTY,l_RIGHTQTTY),
                                                   SENDAQTTY=SENDAQTTY+least(rec.CAQTTYDB,l_CAQTTYDB),
                                                   SENDAMT=SENDAMT+least(rec.CAAMTRECEIV,l_CAAMTRECEIV),
                                                   pstatus= pstatus||status
                                  WHERE autoid=rec.autoid;
                              ELSE
                                  UPDATE caschd SET pbalance=pbalance-least(rec.RIGHTOFFQTTY,l_RIGHTOFFQTTY),
                                                   qtty=qtty-least(rec.CAQTTYRECEIV,l_CAQTTYRECEIV),
                                                   rqtty=rqtty-least(rec.RIGHTQTTY,l_RIGHTQTTY),
                                                   aqtty=aqtty-least(rec.CAQTTYDB,l_CAQTTYDB),
                                                   amt=amt-least(rec.CAAMTRECEIV,l_CAAMTRECEIV),
                                                   SENDPBALANCE=SENDPBALANCE+least(rec.RIGHTOFFQTTY,l_RIGHTOFFQTTY),
                                                   SENDQTTY=SENDQTTY+least(rec.CAQTTYRECEIV,l_CAQTTYRECEIV)
                                                   +least(rec.RIGHTQTTY,l_RIGHTQTTY),
                                                   SENDAQTTY=SENDAQTTY+least(rec.CAQTTYDB,l_CAQTTYDB),
                                                   SENDAMT=SENDAMT+least(rec.CAAMTRECEIV,l_CAAMTRECEIV)
                                  WHERE autoid=rec.autoid;
                              END IF;
                        ELSE -- su kien tra goc lai trai phieu: khong tru o aqtty
                            if(rec.status <> 'O' ) THEN
                                 UPDATE caschd SET status='O',pbalance=pbalance-least(rec.RIGHTOFFQTTY,l_RIGHTOFFQTTY),
                                                   qtty=qtty-least(rec.CAQTTYRECEIV,l_CAQTTYRECEIV),
                                                   rqtty=rqtty-least(rec.RIGHTQTTY,l_RIGHTQTTY),
                                                   amt=amt-least(rec.CAAMTRECEIV,l_CAAMTRECEIV),
                                                   SENDPBALANCE=SENDPBALANCE+least(rec.RIGHTOFFQTTY,l_RIGHTOFFQTTY),
                                                   SENDQTTY=SENDQTTY+least(rec.CAQTTYRECEIV,l_CAQTTYRECEIV)
                                                   +least(rec.RIGHTQTTY,l_RIGHTQTTY),
                                                   SENDAQTTY=SENDAQTTY+least(rec.CAQTTYDB,l_CAQTTYDB),
                                                   SENDAMT=SENDAMT+least(rec.CAAMTRECEIV,l_CAAMTRECEIV),
                                                   pstatus= pstatus||status
                                  WHERE autoid=rec.autoid;
                              ELSE
                                  UPDATE caschd SET pbalance=pbalance-least(rec.RIGHTOFFQTTY,l_RIGHTOFFQTTY),
                                                   qtty=qtty-least(rec.CAQTTYRECEIV,l_CAQTTYRECEIV),
                                                   rqtty=rqtty-least(rec.RIGHTQTTY,l_RIGHTQTTY),
                                                   amt=amt-least(rec.CAAMTRECEIV,l_CAAMTRECEIV),
                                                   SENDPBALANCE=SENDPBALANCE+least(rec.RIGHTOFFQTTY,l_RIGHTOFFQTTY),
                                                   SENDQTTY=SENDQTTY+least(rec.CAQTTYRECEIV,l_CAQTTYRECEIV)
                                                   +least(rec.RIGHTQTTY,l_RIGHTQTTY),
                                                   SENDAQTTY=SENDAQTTY+least(rec.CAQTTYDB,l_CAQTTYDB),
                                                   SENDAMT=SENDAMT+least(rec.CAAMTRECEIV,l_CAAMTRECEIV)
                                  WHERE autoid=rec.autoid;
                              END IF;
                        END IF;
                         -- CAT RECEIVING TRONG SEMAST
                        IF(LEAST(rec.CAQTTYRECEIV,l_CAQTTYRECEIV) >0) THEN
                            IF(REC.ISWFT='Y') THEN
                               SELECT CODEID INTO L_CODEIDWFT FROM SBSECURITIES WHERE REFCODEID=REC.CODEID;
                               l_SEACCTNO:=REC.AFACCTNO||L_CODEIDWFT;
                            ELSE
                               l_SEACCTNO:=REC.AFACCTNO||REC.CODEID;
                            END IF;
                            UPDATE SEMAST SET RECEIVING=RECEIVING-LEAST(rec.CAQTTYRECEIV,l_CAQTTYRECEIV)
                            WHERE ACCTNO=l_SEACCTNO;
                             INSERT INTO SETRAN(TXNUM,TXDATE,ACCTNO,TXCD,NAMT,CAMT,ACCTREF,DELTD,REF,AUTOID,TLTXCD,BKDATE,TRDESC)
                             VALUES (p_txmsg.txnum, TO_DATE (p_txmsg.txdate, systemnums.C_DATE_FORMAT),l_SEACCTNO,
                             '0015',LEAST(rec.CAQTTYRECEIV,l_CAQTTYRECEIV),NULL,NULL,p_txmsg.deltd,NULL,seq_SETRAN.NEXTVAL,p_txmsg.tltxcd,p_txmsg.busdate,'' || '' || '');
                        END IF;
                        -- neu la sk quyen mua: tru o semast cua ck quyen
                        if(rec.catype='014') THEN
                          UPDATE semast SET trade=trade-least(rec.RIGHTOFFQTTY,l_RIGHTOFFQTTY)
                          WHERE acctno=rec.afacctno||rec.optcodeid;
                        END IF;
                        l_RIGHTQTTY :=l_RIGHTQTTY-LEAST(rec.RIGHTQTTY,l_RIGHTQTTY);
                        l_RIGHTOFFQTTY :=l_RIGHTOFFQTTY-LEAST(rec.RIGHTOFFQTTY,l_RIGHTOFFQTTY);
                        l_CAQTTYRECEIV :=l_CAQTTYRECEIV-LEAST(rec.CAQTTYRECEIV,l_CAQTTYRECEIV);
                        l_CAQTTYDB :=l_CAQTTYDB-LEAST(rec.CAQTTYDB,l_CAQTTYDB);
                        l_CAAMTRECEIV :=l_CAAMTRECEIV-LEAST(rec.CAAMTRECEIV,l_CAAMTRECEIV);
                        EXIT WHEN (l_RIGHTQTTY+l_RIGHTOFFQTTY+l_CAQTTYRECEIV+l_CAQTTYDB+l_CAAMTRECEIV=0);
                    END IF;
            END LOOP;
     END LOOP;

         DELETE FROM  catrflog WHERE TXNUM =p_txmsg.txnum AND TXDATE = TO_DATE (p_txmsg.txdate, systemnums.C_DATE_FORMAT);

        ELSE

    FOR recall  IN (SELECT acctno FROM afmast WHERE custid = l_custid )
        LOOP

            select SUM(rightoffqtty),SUM(caqttyreceiv),SUM(caqttydb),SUM(caamtreceiv),SUM(rightqtty)
                into l_RIGHTOFFQTTY, l_CAQTTYRECEIV, l_CAQTTYDB, l_CAAMTRECEIV, l_RIGHTQTTY
                from se2244_catrflog
                where sendoutid = p_txmsg.txfields('18').value AND substr( afacctno,1,10) = recall.acctno;

                FOR rec IN (
                     SELECT schd.autoid, schd.codeid, schd.afacctno,(schd.afacctno||schd.codeid) seacctno,
                     schd.SENDPBALANCE  RIGHTOFFQTTY,
                     schd.SENDAMT CAAMTRECEIV,
                     schd.SENDAQTTY CAQTTYDB,
                     (CASE WHEN (ca.catype IN ('005','006','022')) THEN schd.SENDQTTY ELSE 0 END) RIGHTQTTY,
                     (CASE WHEN (ca.catype NOT IN ('005','006','022'))THEN schd.SENDQTTY ELSE 0 END) CAQTTYRECEIV,
                     ca.catype,ISWFT,optcodeid,schd.TRADE,ca.camastid
                    FROM (
                    SELECT schd.autoid,schd.status,camast.catype,camast.duedate,camast.status castatus,schd.afacctno,camast.codeid,
                    camast.tocodeid, schd.camastid,schd.balance,schd.qtty,schd.aqtty,schd.amt,schd.aamt,schd.pbalance,schd.pqtty ,
                    schd.isci,schd.isse ,SENDPBALANCE,SENDAMT,SENDAQTTY,
                    (CASE WHEN (catype IN ('017','020','023')) THEN 0 ELSE SENDQTTY END )SENDQTTY,schd.TRADE
                    FROM caschd schd ,camast WHERE schd.status='O' AND schd.camastid=camast.camastid AND schd.deltd='N' AND camast.deltd='N' AND camast.status <> 'C'
                    UNION ALL
                    SELECT schd.autoid,  schd.status,camast.catype,camast.duedate,camast.status castatus,schd.afacctno, camast.tocodeid codeid,
                    '',schd.camastid,0,schd.qtty,0,0,0,0,0,
                    schd.isci,schd.isse  ,0,0,0,  SENDQTTY,schd.TRADE
                    FROM caschd schd, camast
                    WHERE schd.status='O' AND schd.camastid=camast.camastid AND camast.catype IN ('017','020','023')AND schd.deltd='N' AND camast.deltd='N' AND camast.status <> 'C'
                     ) schd, camast ca
                      WHERE schd.camastid=ca.camastid
                                        and schd.codeid=p_txmsg.txfields('01').value
                      AND  schd.afacctno=recall.acctno
                      ORDER BY reportdate
                   )
                LOOP
                if(rec.catype <> '016') THEN
                      UPDATE caschd SET  status=SUBSTR(pstatus,LENGTH(pstatus)),
                                         pbalance=pbalance+least(rec.RIGHTOFFQTTY,l_RIGHTOFFQTTY),
                                         qtty=qtty+least(rec.CAQTTYRECEIV,l_CAQTTYRECEIV),
                                         rqtty=rqtty+ least(rec.RIGHTQTTY,l_RIGHTQTTY),
                                         aqtty=aqtty+least(rec.CAQTTYDB,l_CAQTTYDB),
                                         amt=amt+least(rec.CAAMTRECEIV,l_CAAMTRECEIV),
                                         SENDPBALANCE=SENDPBALANCE-least(rec.RIGHTOFFQTTY,l_RIGHTOFFQTTY),
                                         SENDQTTY=SENDQTTY-least(rec.CAQTTYRECEIV,l_CAQTTYRECEIV)
                                         -least(rec.RIGHTQTTY,l_RIGHTQTTY),
                                         SENDAQTTY=SENDAQTTY-least(rec.CAQTTYDB,l_CAQTTYDB),
                                         SENDAMT=SENDAMT-least(rec.CAAMTRECEIV,l_CAAMTRECEIV),
                                         pstatus=pstatus||status
                        WHERE autoid=rec.autoid;
                  ELSE -- su kien tra goc lai trai phieu ko update o AQTTY
                         UPDATE caschd SET  status=SUBSTR(pstatus,LENGTH(pstatus)),
                                         pbalance=pbalance+least(rec.RIGHTOFFQTTY,l_RIGHTOFFQTTY),
                                         qtty=qtty+least(rec.CAQTTYRECEIV,l_CAQTTYRECEIV),
                                         rqtty=rqtty+ least(rec.RIGHTQTTY,l_RIGHTQTTY),
                                         amt=amt+least(rec.CAAMTRECEIV,l_CAAMTRECEIV),
                                         SENDPBALANCE=SENDPBALANCE-least(rec.RIGHTOFFQTTY,l_RIGHTOFFQTTY),
                                         SENDQTTY=SENDQTTY-least(rec.CAQTTYRECEIV,l_CAQTTYRECEIV)
                                         -least(rec.RIGHTQTTY,l_RIGHTQTTY),
                                         SENDAQTTY=SENDAQTTY-least(rec.CAQTTYDB,l_CAQTTYDB),
                                         SENDAMT=SENDAMT-least(rec.CAAMTRECEIV,l_CAAMTRECEIV),
                                         pstatus=pstatus||status
                        WHERE autoid=rec.autoid;
                  END IF;
                   -- CONG RECEIVING TRONG SEMAST
                        IF(LEAST(rec.CAQTTYRECEIV,l_CAQTTYRECEIV) >0) THEN
                            IF(REC.ISWFT='Y') THEN
                               SELECT CODEID INTO L_CODEIDWFT FROM SBSECURITIES WHERE REFCODEID=REC.CODEID;
                               l_SEACCTNO:=REC.AFACCTNO||L_CODEIDWFT;
                            ELSE
                               l_SEACCTNO:=REC.AFACCTNO||REC.CODEID;
                            END IF;
                            UPDATE SEMAST SET RECEIVING=RECEIVING+LEAST(rec.CAQTTYRECEIV,l_CAQTTYRECEIV)
                            WHERE ACCTNO=l_SEACCTNO;
                        END IF;
                        if(rec.catype='014') THEN
                          UPDATE semast SET trade=trade+least(rec.RIGHTOFFQTTY,l_RIGHTOFFQTTY)
                          WHERE acctno=rec.afacctno || rec.optcodeid;
                        END IF;
                    l_RIGHTQTTY :=l_RIGHTQTTY-LEAST(rec.RIGHTQTTY,l_RIGHTQTTY);
                    l_RIGHTOFFQTTY :=l_RIGHTOFFQTTY-LEAST(rec.RIGHTOFFQTTY,l_RIGHTOFFQTTY);
                    l_CAQTTYRECEIV :=l_CAQTTYRECEIV-LEAST(rec.CAQTTYRECEIV,l_CAQTTYRECEIV);
                    l_CAQTTYDB :=l_CAQTTYDB-LEAST(rec.CAQTTYDB,l_CAQTTYDB);
                    l_CAAMTRECEIV :=l_CAAMTRECEIV-LEAST(rec.CAAMTRECEIV,l_CAAMTRECEIV);

             INSERT INTO catrflog (AUTOID,TXDATE,TXNUM,CAMASTID,OPTSEACCTNOCR,OPTSEACCTNODR,CODEID,OPTCODEID,balance,AMT,qtty,CUSTODYCDCR,CUSTODYCDDR,STATUS)
             VALUES(seq_catrflog.NEXTVAL,TO_DATE (p_txmsg.txdate, systemnums.C_DATE_FORMAT),p_txmsg.txnum,rec.camastid,rec.seacctno,null,rec.codeid,rec.codeid,
                      rec.trade,rec.CAAMTRECEIV,rec.RIGHTQTTY+ rec.CAQTTYRECEIV+rec.RIGHTOFFQTTY , p_txmsg.txfields('05').value,p_txmsg.txfields('23').value,'N');

                    EXIT WHEN (l_RIGHTQTTY+l_RIGHTOFFQTTY+l_CAQTTYRECEIV+l_CAQTTYDB+l_CAAMTRECEIV=0);


             END LOOP;
      END LOOP;

        END IF;
    END IF;
    plog.debug (pkgctx, '<<END OF fn_txAftAppUpdate');
    plog.setendsection (pkgctx, 'fn_txAftAppUpdate');
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
         plog.init ('TXPKS_#2254EX',
                    plevel => NVL(logrow.loglevel,30),
                    plogtable => (NVL(logrow.log4table,'N') = 'Y'),
                    palert => (NVL(logrow.log4alert,'N') = 'Y'),
                    ptrace => (NVL(logrow.log4trace,'N') = 'Y')
            );
END TXPKS_#2254EX;
/
