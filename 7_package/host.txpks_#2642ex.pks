SET DEFINE OFF;
CREATE OR REPLACE PACKAGE txpks_#2642ex
/**----------------------------------------------------------------------------------------------------
 ** Package: TXPKS_#2642EX
 ** and is copyrighted by FSS.
 **
 **    All rights reserved.  No part of this work may be reproduced, stored in a retrieval system,
 **    adopted or transmitted in any form or by any means, electronic, mechanical, photographic,
 **    graphic, optic recording or otherwise, translated in any language or computer language,
 **    without the prior written permission of Financial Software Solutions. JSC.
 **
 **  MODIFICATION HISTORY
 **  Person      Date           Comments
 **  System      18/05/2010     Created
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


CREATE OR REPLACE PACKAGE BODY txpks_#2642ex
IS
   pkgctx   plog.log_ctx;
   logrow   tlogdebug%ROWTYPE;

   c_custodycd        CONSTANT CHAR(2) := '88';
   c_acctno           CONSTANT CHAR(2) := '02';
   c_lnacctno         CONSTANT CHAR(2) := '03';
   c_afacctno         CONSTANT CHAR(2) := '05';
   c_custname         CONSTANT CHAR(2) := '57';
   c_address          CONSTANT CHAR(2) := '58';
   c_license          CONSTANT CHAR(2) := '59';
   c_glmast           CONSTANT CHAR(2) := '08';
   c_codeid           CONSTANT CHAR(2) := '01';
   c_seacctno         CONSTANT CHAR(2) := '06';
   c_lntype           CONSTANT CHAR(2) := '07';
   c_prinovd          CONSTANT CHAR(2) := '13';
   c_prinnml          CONSTANT CHAR(2) := '15';
   c_intnmlovd        CONSTANT CHAR(2) := '23';
   c_intovdacr        CONSTANT CHAR(2) := '26';
   c_intdue           CONSTANT CHAR(2) := '31';
   c_intnmlacr        CONSTANT CHAR(2) := '35';
   c_feepaid          CONSTANT CHAR(2) := '36';
   c_dfqtty           CONSTANT CHAR(2) := '37';
   c_rcvqtty          CONSTANT CHAR(2) := '38';
   c_carcvqtty        CONSTANT CHAR(2) := '39';
   c_blockqtty        CONSTANT CHAR(2) := '40';
   c_bqtty            CONSTANT CHAR(2) := '42';
   c_secured          CONSTANT CHAR(2) := '43';
   c_rlsqtty          CONSTANT CHAR(2) := '50';
   c_rlsamt           CONSTANT CHAR(2) := '51';
   c_dealfee          CONSTANT CHAR(2) := '53';
   c_pfeepaid         CONSTANT CHAR(2) := '90';
   c_dealamt          CONSTANT CHAR(2) := '52';
   c_amt              CONSTANT CHAR(2) := '45';
   c_qtty             CONSTANT CHAR(2) := '46';
   c_odamt            CONSTANT CHAR(2) := '41';
   c_pprinovd         CONSTANT CHAR(2) := '63';
   c_pprinnml         CONSTANT CHAR(2) := '65';
   c_pintnmlovd       CONSTANT CHAR(2) := '72';
   c_pintovdacr       CONSTANT CHAR(2) := '74';
   c_pintdue          CONSTANT CHAR(2) := '77';
   c_pintnmlacr       CONSTANT CHAR(2) := '80';
   c_pdfqtty          CONSTANT CHAR(2) := '91';
   c_prcvqtty         CONSTANT CHAR(2) := '92';
   c_pcarcvqtty       CONSTANT CHAR(2) := '93';
   c_pblockqtty       CONSTANT CHAR(2) := '94';
   c_dfref            CONSTANT CHAR(2) := '29';
   c_rrid             CONSTANT CHAR(2) := '95';
   c_cidrawndown      CONSTANT CHAR(2) := '96';
   c_limitcheck       CONSTANT CHAR(2) := '99';
   c_bankdrawndown    CONSTANT CHAR(2) := '97';
   c_cmpdrawndown     CONSTANT CHAR(2) := '98';
   c_desc             CONSTANT CHAR(2) := '30';
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
      plog.error (pkgctx, SQLERRM);
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
      plog.error (pkgctx, SQLERRM);
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
      plog.error (pkgctx, SQLERRM);
       plog.setendsection (pkgctx, 'fn_txPreAppUpdate');
      RAISE errnums.E_SYSTEM_ERROR;
END fn_txPreAppUpdate;

FUNCTION fn_txAftAppUpdate(p_txmsg in tx.msg_rectype,p_err_code out varchar2)
RETURN NUMBER
IS
BEGIN
    plog.setbeginsection (pkgctx, 'fn_txAftAppUpdate');
    plog.debug (pkgctx, '<<BEGIN OF fn_txAftAppUpdate');
   /***************************************************************************************************
    ** PUT YOUR SPECIFIC AFTER PROCESS HERE. DO NOT COMMIT/ROLLBACK HERE, THE SYSTEM WILL DO IT
    ***************************************************************************************************/
    IF txpks_batch.fn_LoanPaymentScheduleAllocate(p_txmsg,p_err_code) <> systemnums.C_SUCCESS THEN
       plog.setendsection (pkgctx, 'fn_txAftAppUpdate');
       RETURN errnums.C_BIZ_RULE_INVALID;
    END IF;

    plog.debug (pkgctx, '<<END OF fn_txAftAppUpdate');
    plog.setendsection (pkgctx, 'fn_txAftAppUpdate');
    RETURN systemnums.C_SUCCESS;
EXCEPTION
WHEN OTHERS
   THEN
      p_err_code := errnums.C_SYSTEM_ERROR;
      plog.error (pkgctx, SQLERRM);
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
         plog.init ('TXPKS_#2642EX',
                    plevel => NVL(logrow.loglevel,30),
                    plogtable => (NVL(logrow.log4table,'N') = 'Y'),
                    palert => (NVL(logrow.log4alert,'N') = 'Y'),
                    ptrace => (NVL(logrow.log4trace,'N') = 'Y')
            );
END TXPKS_#2642EX;

/
