SET DEFINE OFF;
CREATE OR REPLACE PACKAGE TXPKS_#3323EX
/**----------------------------------------------------------------------------------------------------
 ** Package: TXPKS_#3323EX
 ** and is copyrighted by FSS.
 **
 **    All rights reserved.  No part of this work may be reproduced, stored in a retrieval system,
 **    adopted or transmitted in any form or by any means, electronic, mechanical, photographic,
 **    graphic, optic recording or otherwise, translated in any language or computer language,
 **    without the prior written permission of Financial Software Solutions. JSC.
 **
 **  MODIFICATION HISTORY
 **  Person      Date           Comments
 **  System      09/11/2013     Created
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


CREATE OR REPLACE PACKAGE BODY TXPKS_#3323EX
IS
   pkgctx   plog.log_ctx;
   logrow   tlogdebug%ROWTYPE;

   c_custodycd        CONSTANT CHAR(2) := '96';
   c_trfafacctno      CONSTANT CHAR(2) := '03';
   c_autoid           CONSTANT CHAR(2) := '01';
   c_rcvafacctno      CONSTANT CHAR(2) := '83';
   c_camastid         CONSTANT CHAR(2) := '02';
   c_codeid           CONSTANT CHAR(2) := '24';
   c_symbol_org       CONSTANT CHAR(2) := '71';
   c_symbol           CONSTANT CHAR(2) := '04';
   c_exprice          CONSTANT CHAR(2) := '05';
   c_exfrate          CONSTANT CHAR(2) := '11';
   c_rightoffrate     CONSTANT CHAR(2) := '12';
   c_maxqtty          CONSTANT CHAR(2) := '20';
   c_orgqtty          CONSTANT CHAR(2) := '21';
   c_reportdate       CONSTANT CHAR(2) := '23';
   c_description      CONSTANT CHAR(2) := '30';
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
       V_codeid VARCHAR2(20);
BEGIN
    plog.setbeginsection (pkgctx, 'fn_txAftAppUpdate');
    plog.debug (pkgctx, '<<BEGIN OF fn_txAftAppUpdate');
   /***************************************************************************************************
    ** PUT YOUR SPECIFIC AFTER PROCESS HERE. DO NOT COMMIT/ROLLBACK HERE, THE SYSTEM WILL DO IT
    ***************************************************************************************************/
     plog.error(pkgctx, 'p_txmsg.deltd '||p_txmsg.deltd);
      plog.error(pkgctx, 'f01 '|| p_txmsg.txfields('01').value);
       plog.error(pkgctx, 'f03 '|| p_txmsg.txfields('03').value);

      SELECT min(codeid) into V_codeid FROM caschd WHERE autoid = p_txmsg.txfields('01').value 
      AND afacctno = p_txmsg.txfields('03').value;

    
    IF p_txmsg.deltd <> 'Y' THEN
        FOR REC IN
        (
            SELECT * FROM caschd WHERE autoid = p_txmsg.txfields('01').value AND afacctno = p_txmsg.txfields('03').value
        )
        LOOP
            plog.error(pkgctx, 'rec.autoid '||rec.autoid);
            INSERT INTO caschd
            (
                autoid, camastid, balance, qtty, amt, aqtty,
                aamt, status, afacctno, codeid, excodeid, deltd,
                pstatus, refcamastid, retailshare, deposit, reqtty, reaqtty,
                retailbal, pbalance, pqtty, paamt, corebank, iscise,
                dfqtty, isci, isse, isro, tqtty, trade,
                inbalance, outbalance, pitratemethod,isexec, nmqtty, dfamt,
                intamt, rqtty, roretailbal, sendpbalance, sendqtty, sendaqtty,
                sendamt, isreceive, inqtty, cutpbalance, cutqtty, cutaqtty,
                cutamt, pafacctno, orgpbalance
            )
                VALUES
                (
                    seq_caschd.nextval, rec.camastid, rec.balance, rec.qtty, rec.amt, rec.aqtty,
                    rec.aamt, rec.status, p_txmsg.txfields('83').value, rec.codeid, rec.excodeid, 'N',
                    rec.pstatus, rec.refcamastid, rec.retailshare, rec.deposit, rec.reqtty,rec.reaqtty,
                    rec.retailbal, rec.pbalance, rec.pqtty, rec.paamt, rec.corebank, rec.iscise,
                    rec.dfqtty, rec.isci, rec.isse, rec.isro, rec.tqtty, rec.trade,
                    rec.inbalance, rec.outbalance, rec.pitratemethod, rec.isexec, rec.nmqtty, rec.dfamt,
                    rec.intamt, rec.rqtty, rec.roretailbal, rec.sendpbalance, rec.sendqtty, rec.sendaqtty,
                    rec.sendamt, rec.isreceive, rec.inqtty, rec.cutpbalance, rec.cutqtty, rec.cutaqtty,
                    rec.cutamt, rec.pafacctno, rec.orgpbalance
                );
        END LOOP;
        UPDATE caschd SET deltd = 'Y' WHERE autoid = p_txmsg.txfields('01').value AND afacctno = p_txmsg.txfields('03').value;

     INSERT INTO catrflog (AUTOID,TXDATE,TXNUM,CAMASTID,OPTSEACCTNOCR,OPTSEACCTNODR,CODEID,OPTCODEID,balance,AMT,qtty,CUSTODYCDCR,CUSTODYCDDR,STATUS)
     VALUES(seq_catrflog.NEXTVAL, TO_DATE (p_txmsg.txdate, systemnums.C_DATE_FORMAT),p_txmsg.txnum,p_txmsg.txfields('02').value,p_txmsg.txfields('83').value||V_codeid,p_txmsg.txfields('03').value||V_codeid,
     V_codeid,NULL,to_number(p_txmsg.txfields('21').value),0,
          to_number(p_txmsg.txfields('20').value),null,p_txmsg.txfields('96').value,'N');


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
         plog.init ('TXPKS_#3323EX',
                    plevel => NVL(logrow.loglevel,30),
                    plogtable => (NVL(logrow.log4table,'N') = 'Y'),
                    palert => (NVL(logrow.log4alert,'N') = 'Y'),
                    ptrace => (NVL(logrow.log4trace,'N') = 'Y')
            );
END TXPKS_#3323EX;
/
