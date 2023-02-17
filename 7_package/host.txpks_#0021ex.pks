SET DEFINE OFF;
CREATE OR REPLACE PACKAGE txpks_#0021ex
/**----------------------------------------------------------------------------------------------------
 ** Package: TXPKS_#0021EX
 ** and is copyrighted by FSS.
 **
 **    All rights reserved.  No part of this work may be reproduced, stored in a retrieval system,
 **    adopted or transmitted in any form or by any means, electronic, mechanical, photographic,
 **    graphic, optic recording or otherwise, translated in any language or computer language,
 **    without the prior written permission of Financial Software Solutions. JSC.
 **
 **  MODIFICATION HISTORY
 **  Person      Date           Comments
 **  System      06/09/2014     Created
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


CREATE OR REPLACE PACKAGE BODY txpks_#0021ex
IS
   pkgctx   plog.log_ctx;
   logrow   tlogdebug%ROWTYPE;

   c_custid           CONSTANT CHAR(2) := '03';
   c_custodycd        CONSTANT CHAR(2) := '88';
   c_fullname         CONSTANT CHAR(2) := '28';
   c_actype           CONSTANT CHAR(2) := '45';
   c_nactype          CONSTANT CHAR(2) := '46';
FUNCTION fn_txPreAppCheck(p_txmsg in tx.msg_rectype,p_err_code out varchar2)
RETURN NUMBER
IS

BEGIN
   plog.setbeginsection (pkgctx, 'fn_txPreAppCheck');
   plog.debug(pkgctx,'BEGIN OF fn_txPreAppCheck');
   cspks_cfproc.pr_CFMAST_ChangeTypeCheck(p_txmsg.txfields('03').value,p_txmsg.txfields('46').value,p_err_code);
   If p_err_code<>'0' then
        plog.setendsection (pkgctx, 'fn_txPreAppCheck');
        RETURN errnums.C_BIZ_RULE_INVALID;
    plog.setendsection (pkgctx, 'fn_txPreAppCheck');
    End if;

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
BEGIN
    plog.setbeginsection (pkgctx, 'fn_txAftAppUpdate');
    plog.debug (pkgctx, '<<BEGIN OF fn_txAftAppUpdate');
   cspks_cfproc.pr_ChangeCFType(p_txmsg.txfields('03').value,p_txmsg.txfields('46').value,p_err_code);
   If p_err_code<>'0' then
        plog.setendsection (pkgctx, 'fn_txPreAppCheck');
        RETURN errnums.C_BIZ_RULE_INVALID;
        plog.setendsection (pkgctx, 'fn_txPreAppCheck');
    End if;

   FOR I IN (  select   lnt.*
               from cftype cft, aftype aft,lntype lnt,cfaftype cfaf
               where cft.actype = cfaf.cftype
               and cfaf.aftype = aft.actype
               and aft.lntype = lnt.actype
               and cft.actype =p_txmsg.txfields('46').value
                  ) LOOP
      UPDATE LNMAST
         SET LNTYPE         = I.LNTYPE,
             LNCLDR         = I.LNCLDR,
             PRINFRQ        = I.PRINFRQ,
             PRINPERIOD     = I.PRINPERIOD,
             INTFRGCD       = I.INTFRQCD,
             INTDAY         = I.INTDAY,
             INTPERIOD      = I.INTPERIOD,
             NINTCD         = I.NINTCD,
             OINTCD         = I.OINTCD,
             RATE1          = I.RATE1,
             RATE2          = I.RATE2,
             RATE3          = I.RATE3,
             OPRINFRQ       = I.OPRINFRQ,
             OPRINPERIOD    = I.OPRINPERIOD,
             OINTFRQCD      = I.OINTFRQCD,
             OINTDAY        = I.OINTDAY,
             ORATE1         = I.ORATE1,
             ORATE2         = I.ORATE2,
             ORATE3         = I.ORATE3,
             DRATE          = I.DRATE,
             ADVPAY         = I.ADVPAY,
             PREPAID        = I.PREPAID,
             ADVPAYFEE      = I.ADVPAYFEE,
             MINTERM        = I.MINTERM,
             CFRATE1        = I.CFRATE1,
             CFRATE2        = I.CFRATE2,
             CFRATE3        = I.CFRATE3,
             INTOVDCD       = I.INTOVDCD,
             BANKPAIDMETHOD = I.BANKPAIDMETHOD
       WHERE LNMAST.ACTYPE = I.ACTYPE
         AND AUTOAPPLY IN ('A', 'L')
         and trfacctno in (select  acctno  from afmast where  custid =p_txmsg.txfields('03').value )
                  ;
    END LOOP;


    IF p_txmsg.deltd ='Y' THEN
       UPDATE changecftype_log SET deltd = 'Y' WHERE p_txmsg.txdate = txdate AND p_txmsg.txnum = txnums;
    ELSE
       INSERT INTO changecftype_log (autoid, custid, txdate, txnums, oldactype, Newactype, makerid, checkerid, deltd)
       VALUES ( seq_changecftype_log.nextval,p_txmsg.txfields('03').value , p_txmsg.txdate, p_txmsg.txnum, p_txmsg.txfields('45').value, p_txmsg.txfields('46').value, p_txmsg.tlid, p_txmsg.offid,'N');
    END IF;
---    cspks_cfproc.pr_ChangeCFType(p_txmsg.txfields('03').value,p_txmsg.txfields('46').value,p_err_code);

    FOR rec IN (
        SELECT AF.ACCTNO, MAX(MST.AMT) AMT, max(AFT.MRCRLIMITMAX) AFTMRCRLIMITMAX
        FROM MRPRMLIMITCF MRCF, MRPRMLIMITMST MST, AFMAST AF, AFTYPE AFT, MRTYPE MRT
        WHERE MRCF.PROMOTIONID = MST.AUTOID
            AND MRCF.AFACCTNO = AF.ACCTNO AND AF.ACTYPE = AFT.ACTYPE
            AND AFT.MRTYPE = MRT.ACTYPE AND MRT.MRTYPE IN ('T','S')
            AND Getcurrdate BETWEEN MRCF.VALDATE AND MRCF.EXPDATE
            AND MRCF.STATUS = 'A' and MRCF.CUSTID = p_txmsg.txfields('03').value
        GROUP BY AF.ACCTNO
    ) LOOP
        UPDATE AFMAST AF
        SET AF.MRCRLIMITMAX = GREATEST(AF.MRCRLIMITMAX,NVL(REC.AMT,0), NVL(rec.AFTMRCRLIMITMAX,0))
        WHERE AF.ACCTNO = REC.ACCTNO;
    END LOOP;

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
         plog.init ('TXPKS_#0021EX',
                    plevel => NVL(logrow.loglevel,30),
                    plogtable => (NVL(logrow.log4table,'N') = 'Y'),
                    palert => (NVL(logrow.log4alert,'N') = 'Y'),
                    ptrace => (NVL(logrow.log4trace,'N') = 'Y')
            );
END TXPKS_#0021EX;

/
