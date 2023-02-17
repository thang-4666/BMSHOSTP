SET DEFINE OFF;
CREATE OR REPLACE PACKAGE txpks_#2636ex
/**----------------------------------------------------------------------------------------------------
 ** Package: TXPKS_#2636EX
 ** and is copyrighted by FSS.
 **
 **    All rights reserved.  No part of this work may be reproduced, stored in a retrieval system,
 **    adopted or transmitted in any form or by any means, electronic, mechanical, photographic,
 **    graphic, optic recording or otherwise, translated in any language or computer language,
 **    without the prior written permission of Financial Software Solutions. JSC.
 **
 **  MODIFICATION HISTORY
 **  Person      Date           Comments
 **  System      03/03/2012     Created
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


CREATE OR REPLACE PACKAGE BODY txpks_#2636ex
IS
   pkgctx   plog.log_ctx;
   logrow   tlogdebug%ROWTYPE;

   c_afacctno         CONSTANT CHAR(2) := '03';
   c_lnacctno         CONSTANT CHAR(2) := '05';
   c_prinovd          CONSTANT CHAR(2) := '10';
   c_prinpaid         CONSTANT CHAR(2) := '12';
   c_intnmlovd        CONSTANT CHAR(2) := '13';
   c_intpaid          CONSTANT CHAR(2) := '14';
   c_feeintnmlovd     CONSTANT CHAR(2) := '15';
   c_feeintpaid       CONSTANT CHAR(2) := '16';
   c_prinnml          CONSTANT CHAR(2) := '11';
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
   /***************************************************************************************************
    ** PUT YOUR SPECIFIC AFTER PROCESS HERE. DO NOT COMMIT/ROLLBACK HERE, THE SYSTEM WILL DO IT
    ***************************************************************************************************/


     update lnschd set
            PAID = PAID + (ROUND(p_txmsg.txfields('14').value,0)),
           OVD= OVD -  (ROUND(p_txmsg.txfields('14').value,0)),
           PAIDFEEINT=PAIDFEEINT+ ROUND(p_txmsg.txfields('16').value,0),
           OVDFEEINT=OVDFEEINT-ROUND(p_txmsg.txfields('16').value,0)
           where reftype='I' and ACCTNO = p_txmsg.txfields('05').value;

    update lnschd set OVD = ROUND(OVD,0) - ROUND(p_txmsg.txfields('10').value,0),
                      PAID = PAID + ROUND(p_txmsg.txfields('12').value,0),
                      INTOVD = ROUND(INTOVD,0) - ROUND(p_txmsg.txfields('13').value,0),
                      INTOVDPRIN = ROUND(INTOVDPRIN,0) - ROUND(p_txmsg.txfields('18').value,0),
                      INTPAID = ROUND(INTPAID,0) + ROUND(p_txmsg.txfields('14').value,0),
                      FEEINTNMLOVD = ROUND(FEEINTNMLOVD,0) - ROUND(p_txmsg.txfields('15').value,0),
                      FEEINTOVDACR = ROUND(FEEINTOVDACR,0) - ROUND(p_txmsg.txfields('19').value,0),
                      FEEINTPAID = ROUND(FEEINTOVDACR,0) + ROUND(p_txmsg.txfields('16').value,0)
    where reftype='P' and ACCTNO  = p_txmsg.txfields('05').value;

   -- PhuongHT edit
     INSERT INTO LNSCHDLOG (AUTOID, TXNUM, TXDATE, OVD, PAID,INTOVD,INTOVDPRIN,INTPAID,FEEINTOVD,Feeintovdprin,feeintpaid)
        SELECT AUTOID, p_txmsg.txnum, TO_DATE(p_txmsg.txdate,'DD/MM/RRRR'), -ROUND(p_txmsg.txfields('10').value,0),
               ROUND(p_txmsg.txfields('12').value,0),- ROUND(p_txmsg.txfields('13').value,0),
               - ROUND(p_txmsg.txfields('18').value,0), ROUND(p_txmsg.txfields('14').value,0),
               - ROUND(p_txmsg.txfields('15').value,0) ,- ROUND(p_txmsg.txfields('19').value,0),
               ROUND(p_txmsg.txfields('16').value,0)
        from lnschd
        where reftype='P' and ACCTNO  = p_txmsg.txfields('05').value;
     -- end of PhuongHT edit

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
         plog.init ('TXPKS_#2636EX',
                    plevel => NVL(logrow.loglevel,30),
                    plogtable => (NVL(logrow.log4table,'N') = 'Y'),
                    palert => (NVL(logrow.log4alert,'N') = 'Y'),
                    ptrace => (NVL(logrow.log4trace,'N') = 'Y')
            );
END TXPKS_#2636EX;

/
