SET DEFINE OFF;
CREATE OR REPLACE PACKAGE txpks_#2248ex
/**----------------------------------------------------------------------------------------------------
 ** Package: TXPKS_#2248EX
 ** and is copyrighted by FSS.
 **
 **    All rights reserved.  No part of this work may be reproduced, stored in a retrieval system,
 **    adopted or transmitted in any form or by any means, electronic, mechanical, photographic,
 **    graphic, optic recording or otherwise, translated in any language or computer language,
 **    without the prior written permission of Financial Software Solutions. JSC.
 **
 **  MODIFICATION HISTORY
 **  Person      Date           Comments
 **  System      09/07/2012     Created
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


CREATE OR REPLACE PACKAGE BODY txpks_#2248ex
IS
   pkgctx   plog.log_ctx;
   logrow   tlogdebug%ROWTYPE;

   c_codeid           CONSTANT CHAR(2) := '01';
   c_afacctno         CONSTANT CHAR(2) := '02';
   c_acctno           CONSTANT CHAR(2) := '03';
   c_qtty             CONSTANT CHAR(2) := '10';
   c_parvalue         CONSTANT CHAR(2) := '11';
   c_rightoffqtty     CONSTANT CHAR(2) := '14';
   c_caqttyreceiv     CONSTANT CHAR(2) := '15';
   c_caqttydb         CONSTANT CHAR(2) := '16';
   c_caamtreceiv      CONSTANT CHAR(2) := '17';
   c_rightqtty        CONSTANT CHAR(2) := '18';
   c_desc             CONSTANT CHAR(2) := '30';
FUNCTION fn_txPreAppCheck(p_txmsg in tx.msg_rectype,p_err_code out varchar2)
RETURN NUMBER
IS
l_count NUMBER;
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

    SELECT COUNT(*)INTO l_count
    FROM SEMAST
    WHERE afacctno=p_txmsg.txfields('02').value AND acctno=p_txmsg.txfields('03').value
    AND DTOCLOSE + BLOCKDTOCLOSE <to_number(p_txmsg.txfields('10').value);
    IF (l_count > 0) THEN
        p_err_code:='-900032';
        plog.setendsection(pkgctx, 'fn_txPreAppCheck');
        RETURN errnums.C_BIZ_RULE_INVALID;
    END IF;

    --check k thuc hien 1 gd 2 lan

    select count(1) into l_count from trfdtoclose where deltd = 'N' and frafacctno || codeid = p_txmsg.txfields('03').value;

    if L_COUNT > 0 then
        p_err_code := '-100778'; -- Pre-defined in DEFERROR table
        plog.setendsection (pkgctx, 'fn_txPreAppCheck');
        RETURN errnums.C_BIZ_RULE_INVALID;
    end if;
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
l_RIGHTQTTY NUMBER;
l_RIGHTOFFQTTY NUMBER;
l_CAQTTYRECEIV NUMBER;
l_CAQTTYDB NUMBER;
l_CAAMTRECEIV NUMBER;
l_COUNT number;
l_seacctno varchar2(30);
l_strSETYPE varchar2(30);
l_CUSTID varchar2(30);
L_STATUS    VARCHAR2(2);
BEGIN
    plog.setbeginsection (pkgctx, 'fn_txAftAppUpdate');
    plog.debug (pkgctx, '<<BEGIN OF fn_txAftAppUpdate');
   /***************************************************************************************************
    ** PUT YOUR SPECIFIC AFTER PROCESS HERE. DO NOT COMMIT/ROLLBACK HERE, THE SYSTEM WILL DO IT
    ***************************************************************************************************/
    -- ghi jam so luong CA cho ve theo thu tu uu tien
    l_RIGHTQTTY :=to_number(p_txmsg.txfields('18').value);
    l_RIGHTOFFQTTY :=to_number(p_txmsg.txfields('14').value);
    l_CAQTTYRECEIV :=to_number(p_txmsg.txfields('15').value);
    l_CAQTTYDB :=to_number(p_txmsg.txfields('16').value);
    l_CAAMTRECEIV :=to_number(p_txmsg.txfields('17').value);
    l_seacctno:=p_txmsg.txfields('03').value;

   ---- IF p_txmsg.deltd <> 'Y' THEN -- Normal transaction

     /* INSERT INTO SETRAN(TXNUM,TXDATE,ACCTNO,TXCD,NAMT,CAMT,ACCTREF,DELTD,REF,AUTOID,TLTXCD,BKDATE,TRDESC)
            VALUES (p_txmsg.txnum, TO_DATE (p_txmsg.txdate, systemnums.C_DATE_FORMAT),p_txmsg.txfields ('03').value,'0071',ROUND(p_txmsg.txfields('10').value,0),NULL,'',p_txmsg.deltd,'',seq_SETRAN.NEXTVAL,p_txmsg.tltxcd,p_txmsg.busdate,'' || '' || '');

*/

      /*UPDATE SEMAST
         SET
           DTOCLOSE = DTOCLOSE - (ROUND(p_txmsg.txfields('10').value,0)), LAST_CHANGE = SYSTIMESTAMP
        WHERE ACCTNO=p_txmsg.txfields('03').value;*/

---   ELSE -- Reversal
   IF p_txmsg.deltd <> 'N' then
    UPDATE TLLOG
    SET DELTD = 'Y'
      WHERE TXNUM = p_txmsg.txnum AND TXDATE = TO_DATE(p_txmsg.txdate, systemnums.C_DATE_FORMAT);
        UPDATE SETRAN        SET DELTD = 'Y'
        WHERE TXNUM = p_txmsg.txnum AND TXDATE = TO_DATE(p_txmsg.txdate, systemnums.C_DATE_FORMAT);




      /*UPDATE SEMAST
      SET
           DTOCLOSE=DTOCLOSE + (ROUND(p_txmsg.txfields('10').value,0)), LAST_CHANGE = SYSTIMESTAMP
        WHERE ACCTNO=p_txmsg.txfields('03').value;*/

   END IF;


    if(p_txmsg.deltd <> 'Y') THEN
          FOR rec IN (
                     SELECT schd.autoid, schd.codeid, schd.afacctno,(schd.afacctno||schd.codeid) seacctno,
                     schd.SENDPBALANCE  RIGHTOFFQTTY,
                     schd.SENDAMT CAAMTRECEIV,
                     schd.SENDAQTTY CAQTTYDB,
                     (CASE WHEN (ca.catype IN ('005','006','022')) THEN schd.SENDQTTY ELSE 0 END) RIGHTQTTY,
                     (CASE WHEN (ca.catype NOT IN ('005','006','022'))THEN schd.SENDQTTY ELSE 0 END) CAQTTYRECEIV
                    FROM (
                    SELECT schd.autoid,schd.status,camast.catype,camast.duedate,camast.status castatus,schd.afacctno,camast.codeid,
                    camast.tocodeid, schd.camastid,schd.balance,schd.qtty,schd.aqtty,schd.amt,schd.aamt,schd.pbalance,schd.pqtty ,
                    schd.isci,schd.isse ,SENDPBALANCE,SENDAMT,SENDAQTTY,
                    (CASE WHEN (catype IN ('017','020','023')) THEN 0 ELSE SENDQTTY END )SENDQTTY
                    FROM caschd schd ,camast WHERE schd.status='O' AND schd.camastid=camast.camastid AND schd.deltd='N' AND camast.deltd='N'
                    UNION ALL
                    SELECT schd.autoid,  schd.status,camast.catype,camast.duedate,camast.status castatus,schd.afacctno, camast.tocodeid codeid,
                    '',schd.camastid,0,schd.qtty,0,0,0,0,0,
                    schd.isci,schd.isse  ,0,0,0,  SENDQTTY
                    FROM caschd schd, camast
                    WHERE  schd.status='O' AND schd.camastid=camast.camastid AND camast.catype IN ('017','020','023')AND schd.deltd='N' AND camast.deltd='N'

                     ) schd, camast ca
                      WHERE schd.camastid=ca.camastid
                      AND (schd.afacctno||schd.codeid)=l_seacctno
                      ORDER BY reportdate
                   )
        LOOP


                   UPDATE caschd SET sendpbalance=sendpbalance-rec.RIGHTOFFQTTY,
                                     sendqtty=sendqtty-rec.CAQTTYRECEIV-rec.RIGHTQTTY,
                                     sendaqtty=sendaqtty-rec.CAQTTYDB,sendamt=sendamt-rec.CAAMTRECEIV,
                                     cutpbalance=cutpbalance+rec.RIGHTOFFQTTY,
                                     cutqtty=cutqtty+rec.CAQTTYRECEIV+rec.RIGHTQTTY,
                                     cutaqtty=cutaqtty+rec.CAQTTYDB,cutamt=cutamt+rec.CAAMTRECEIV
                    WHERE autoid=rec.autoid;


                    l_RIGHTQTTY :=l_RIGHTQTTY-rec.RIGHTQTTY;
                    l_RIGHTOFFQTTY :=l_RIGHTOFFQTTY-rec.RIGHTOFFQTTY;
                    l_CAQTTYRECEIV :=l_CAQTTYRECEIV-rec.CAQTTYRECEIV;
                    l_CAQTTYDB :=l_CAQTTYDB-rec.CAQTTYDB;
                    l_CAAMTRECEIV :=l_CAAMTRECEIV-rec.CAAMTRECEIV;
                    EXIT WHEN (l_RIGHTQTTY+l_RIGHTOFFQTTY+l_CAQTTYRECEIV+l_CAQTTYDB+l_CAAMTRECEIV=0);

        END LOOP;

    update trfdtoclose set deltd = 'N'
    where frafacctno || codeid = p_txmsg.txfields('03').value and deltd = 'C';
    --- Cap nhap tang ck cho TK nhan neu Cty chung khoan nhan la 009

    if substr(p_txmsg.txfields('98').value,1,3) = systemnums.C_COMPANYCD then
        select count(*) into l_COUNT from semast where acctno = p_txmsg.txfields('92').value || p_txmsg.txfields('01').value;
        if l_COUNT = 0 then
            SELECT TYP.SETYPE into l_strSETYPE FROM AFMAST AF, AFTYPE TYP WHERE AF.ACTYPE=TYP.ACTYPE AND AF.ACCTNO= p_txmsg.txfields('92').value;
            select custid into l_CUSTID from cfmast where custodycd = p_txmsg.txfields('98').value;
          INSERT INTO SEMAST (ACTYPE,CUSTID,ACCTNO,CODEID,AFACCTNO,
                            OPNDATE,LASTDATE,STATUS,IRTIED,IRCD,
                            COSTPRICE,TRADE,MORTAGE,MARGIN,NETTING,
                            STANDING,WITHDRAW,DEPOSIT,LOAN)
                      VALUES (l_strSETYPE, l_CUSTID, p_txmsg.txfields('92').value || p_txmsg.txfields('01').value , p_txmsg.txfields('01').value , p_txmsg.txfields('92').value ,
                      p_txmsg.txdate,p_txmsg.txdate,'A','Y','001',
                      0,0,0,0,0,0,0,0,0);
        end if;

        INSERT INTO SETRAN(TXNUM,TXDATE,ACCTNO,TXCD,NAMT,CAMT,ACCTREF,DELTD,REF,AUTOID,TLTXCD,BKDATE,TRDESC)
            VALUES (p_txmsg.txnum, TO_DATE (p_txmsg.txdate, systemnums.C_DATE_FORMAT),p_txmsg.txfields('92').value || p_txmsg.txfields('01').value,'0043',ROUND(p_txmsg.txfields('09').value,0),NULL,'',p_txmsg.deltd,'',seq_SETRAN.NEXTVAL,p_txmsg.tltxcd,p_txmsg.busdate,'' || '' || '');

      INSERT INTO SETRAN(TXNUM,TXDATE,ACCTNO,TXCD,NAMT,CAMT,ACCTREF,DELTD,REF,AUTOID,TLTXCD,BKDATE,TRDESC)
            VALUES (p_txmsg.txnum, TO_DATE (p_txmsg.txdate, systemnums.C_DATE_FORMAT),p_txmsg.txfields('92').value || p_txmsg.txfields('01').value,'0012',ROUND(p_txmsg.txfields('08').value,0),NULL,'',p_txmsg.deltd,'',seq_SETRAN.NEXTVAL,p_txmsg.tltxcd,p_txmsg.busdate,'' || '' || '');

        update semast set trade = trade + ROUND(p_txmsg.txfields('08').value,0), BLOCKED = BLOCKED +  ROUND(p_txmsg.txfields('09').value,0),
                LAST_CHANGE = SYSTIMESTAMP where acctno = p_txmsg.txfields('92').value || p_txmsg.txfields('01').value;
    end if;

    l_seacctno := p_txmsg.txfields('03').value;
    update SESENDCLOSE set status = 'C'
    where acctno = l_seacctno
            and deltd <> 'Y'  and status = 'P';
           /*FOR rec IN
                           (SELECT * FROM dtoclosedtl WHERE acctno= l_seacctno
                            AND DELTD <> 'Y' AND status ='N' and qtty >0
                            ORDER BY autoid )
            LOOP
                         INSERT INTO SETRAN(TXNUM,TXDATE,ACCTNO,TXCD,NAMT,CAMT,ACCTREF,DELTD,REF,AUTOID,TLTXCD,BKDATE,TRDESC)
                         VALUES (p_txmsg.txnum, TO_DATE (p_txmsg.txdate, systemnums.C_DATE_FORMAT),p_txmsg.txfields ('03').value,'0071',ROUND(rec.qtty,0),NULL,p_txmsg.txfields ('03').value,p_txmsg.deltd,rec.qttytype,seq_SETRAN.NEXTVAL,p_txmsg.tltxcd,p_txmsg.busdate,'' || '' || '');

                         update dtoclosedtl set qtty= qtty- rec.qtty where autoid = rec.autoid ;
                         update dtoclosedtl set status='C' where autoid = rec.autoid;
           end loop;*/
    ELSE -- xoa jao dich
       FOR rec IN (
                     SELECT schd.autoid, schd.codeid, schd.afacctno,(schd.afacctno||schd.codeid) seacctno,
                     schd.CUTPBALANCE  RIGHTOFFQTTY,
                     schd.CUTAMT CAAMTRECEIV,
                     schd.CUTAQTTY CAQTTYDB,
                     (CASE WHEN (ca.catype IN ('005','006','022')) THEN schd.CUTQTTY ELSE 0 END) RIGHTQTTY,
                     (CASE WHEN (ca.catype NOT IN ('005','006','022'))THEN schd.CUTQTTY ELSE 0 END) CAQTTYRECEIV
                    FROM (
                    SELECT schd.autoid,schd.status,camast.catype,camast.duedate,camast.status castatus,schd.afacctno,camast.codeid,
                    camast.tocodeid, schd.camastid,schd.balance,schd.qtty,schd.aqtty,schd.amt,schd.aamt,schd.pbalance,schd.pqtty ,
                    schd.isci,schd.isse ,CUTPBALANCE,CUTAMT,CUTAQTTY,
                    (CASE WHEN (catype IN ('017','020','023')) THEN 0 ELSE CUTQTTY END )CUTQTTY
                    FROM caschd schd ,camast WHERE schd.status='O' AND schd.camastid=camast.camastid AND schd.deltd='N' AND camast.deltd='N'
                    UNION ALL
                    SELECT schd.autoid,  schd.status,camast.catype,camast.duedate,camast.status castatus,schd.afacctno, camast.tocodeid codeid,
                    '',schd.camastid,0,schd.qtty,0,0,0,0,0,
                    schd.isci,schd.isse  ,0,0,0,  CUTQTTY
                    FROM caschd schd, camast
                    WHERE  schd.status='O' AND schd.camastid=camast.camastid AND camast.catype IN ('017','020','023')AND schd.deltd='N' AND camast.deltd='N'

                     ) schd, camast ca
                      WHERE schd.camastid=ca.camastid
                      AND  (schd.afacctno||schd.codeid)=l_seacctno
                      ORDER BY reportdate
                   )
        LOOP
                   UPDATE caschd SET sendpbalance=sendpbalance+rec.RIGHTOFFQTTY,
                                     sendqtty=sendqtty+rec.CAQTTYRECEIV+rec.RIGHTQTTY,
                                     sendaqtty=sendaqtty+rec.CAQTTYDB,sendamt=sendamt+rec.CAAMTRECEIV,
                                     cutpbalance=cutpbalance-rec.RIGHTOFFQTTY,
                                     cutqtty=cutqtty-rec.CAQTTYRECEIV-rec.RIGHTQTTY,
                                     cutaqtty=cutaqtty-rec.CAQTTYDB,cutamt=cutamt-rec.CAAMTRECEIV
                    WHERE autoid=rec.autoid;
                    l_RIGHTQTTY :=l_RIGHTQTTY-rec.RIGHTQTTY;
                    l_RIGHTOFFQTTY :=l_RIGHTOFFQTTY-rec.RIGHTOFFQTTY;
                    l_CAQTTYRECEIV :=l_CAQTTYRECEIV-rec.CAQTTYRECEIV;
                    l_CAQTTYDB :=l_CAQTTYDB-rec.CAQTTYDB;
                    l_CAAMTRECEIV :=l_CAAMTRECEIV-rec.CAAMTRECEIV;
                    EXIT WHEN (l_RIGHTQTTY+l_RIGHTOFFQTTY+l_CAQTTYRECEIV+l_CAQTTYDB+l_CAAMTRECEIV=0);

        END LOOP;
        if substr(p_txmsg.txfields('98').value,1,3) = systemnums.C_COMPANYCD then
        update semast set trade = trade - ROUND(p_txmsg.txfields('08').value,0), BLOCKED = BLOCKED -   ROUND(p_txmsg.txfields('09').value,0),
                LAST_CHANGE = SYSTIMESTAMP where acctno = p_txmsg.txfields('92').value || p_txmsg.txfields('01').value;
        end if;
        update trfdtoclose set deltd = 'C' where frafacctno || codeid = p_txmsg.txfields('03').value and deltd = 'N';
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
         plog.init ('TXPKS_#2248EX',
                    plevel => NVL(logrow.loglevel,30),
                    plogtable => (NVL(logrow.log4table,'N') = 'Y'),
                    palert => (NVL(logrow.log4alert,'N') = 'Y'),
                    ptrace => (NVL(logrow.log4trace,'N') = 'Y')
            );
END TXPKS_#2248EX;
/
