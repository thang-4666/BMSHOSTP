SET DEFINE OFF;
CREATE OR REPLACE PACKAGE txpks_#1104ex
/**----------------------------------------------------------------------------------------------------
 ** Package: TXPKS_#1104EX
 ** and is copyrighted by FSS.
 **
 **    All rights reserved.  No part of this work may be reproduced, stored in a retrieval system,
 **    adopted or transmitted in any form or by any means, electronic, mechanical, photographic,
 **    graphic, optic recording or otherwise, translated in any language or computer language,
 **    without the prior written permission of Financial Software Solutions. JSC.
 **
 **  MODIFICATION HISTORY
 **  Person      Date           Comments
 **  System      12/09/2011     Created
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


CREATE OR REPLACE PACKAGE BODY txpks_#1104ex
IS
   pkgctx   plog.log_ctx;
   logrow   tlogdebug%ROWTYPE;

   c_acctno           CONSTANT CHAR(2) := '03';
   c_custname         CONSTANT CHAR(2) := '90';
   c_license          CONSTANT CHAR(2) := '92';
   c_address          CONSTANT CHAR(2) := '91';
   c_iddate           CONSTANT CHAR(2) := '67';
   c_glmast           CONSTANT CHAR(2) := '15';
   c_bankacc          CONSTANT CHAR(2) := '08';
   c_bankname         CONSTANT CHAR(2) := '85';
   c_bankaccname      CONSTANT CHAR(2) := '86';
   c_bankid           CONSTANT CHAR(2) := '05';
   c_benefbank        CONSTANT CHAR(2) := '80';
   c_benefacct        CONSTANT CHAR(2) := '81';
   c_benefcustname    CONSTANT CHAR(2) := '82';
   c_receivlicense    CONSTANT CHAR(2) := '83';
   c_receividdate     CONSTANT CHAR(2) := '95';
   c_amt              CONSTANT CHAR(2) := '10';
   c_txdate           CONSTANT CHAR(2) := '06';
   c_txnum            CONSTANT CHAR(2) := '07';
   c_potxdate         CONSTANT CHAR(2) := '98';
   c_potxnum          CONSTANT CHAR(2) := '99';
   c_desc             CONSTANT CHAR(2) := '30';
   c_ioro             CONSTANT CHAR(2) := '09';
   c_potype           CONSTANT CHAR(2) := '17';
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
l_count NUMBER;
v_postatus varchar2(2);
v_rmstatus varchar2(2);
BEGIN
    plog.setbeginsection (pkgctx, 'fn_txPreAppUpdate');
    plog.debug (pkgctx, '<<BEGIN OF fn_txPreAppUpdate');
   /***************************************************************************************************
    ** PUT YOUR SPECIFIC PROCESS HERE. . DO NOT COMMIT/ROLLBACK HERE, THE SYSTEM WILL DO IT
    ***************************************************************************************************/
      -- check khi xoa: chua dc lam 1112
    IF  (p_txmsg.deltd = 'Y') THEN
      BEGIN
          SELECT COUNT(*) INTO l_count FROM CIREMITTANCE
          WHERE  TXDATE=to_date(p_txmsg.txfields('06').VALUE, systemnums.C_DATE_FORMAT)
          AND TXNUM=p_txmsg.txfields('07').VALUE
          AND rmstatus = 'C' AND deltd='N';
      EXCEPTION WHEN OTHERS THEN
                p_err_code:='-400448';
                plog.setendsection (pkgctx, 'fn_txPreAppCheck');
                RETURN errnums.C_BIZ_RULE_INVALID;
      END;

      if(l_count <= 0) THEN
                p_err_code:='-400448';
                plog.setendsection (pkgctx, 'fn_txPreAppCheck');
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
      plog.error (pkgctx, SQLERRM);
       plog.setendsection (pkgctx, 'fn_txPreAppUpdate');
      RAISE errnums.E_SYSTEM_ERROR;
END fn_txPreAppUpdate;

FUNCTION fn_txAftAppUpdate(p_txmsg in tx.msg_rectype,p_err_code out varchar2)
RETURN NUMBER
IS
     v_postatus varchar2(2);
     v_rmstatus varchar2(2);
     v_count NUMBER;
BEGIN
    plog.setbeginsection (pkgctx, 'fn_txAftAppUpdate');
    plog.debug (pkgctx, '<<BEGIN OF fn_txAftAppUpdate');
   /***************************************************************************************************
    ** PUT YOUR SPECIFIC AFTER PROCESS HERE. DO NOT COMMIT/ROLLBACK HERE, THE SYSTEM WILL DO IT
    ***************************************************************************************************/
    /*
    03  ACCTNO
    05  BANKID
    06  TXDATE
    07  TXNUM
    08  BANKACC
    09  IORO -- feetype
    10  AMT
    15  GLMAST
    17  POTYPE
    30  DESC
    33  AUTOPAYMENT
    80  BENEFBANK
    81  BENEFACCT
    82  BENEFCUSTNAME
    85  BANKNAME
    86  BANKACCNAME
    90  CUSTNAME
    91  ADDRESS
    92  LICENSE
    98  POTXDATE
    99  POTXNUM

    */

    --pr_error('FLD33 : ', TO_NUMBER(p_txmsg.txfields('33').VALUE));
/*
    IF TO_NUMBER(p_txmsg.txfields('33').VALUE) = 1 THEN
       v_postatus := 'N';
    ELSE
       v_postatus := 'C';
    END IF;
*/
    v_postatus:='A';
    IF p_txmsg.deltd <> 'Y' THEN

       SELECT COUNT(1) INTO v_count FROM POMAST WHERE TXNUM = p_txmsg.txfields('99').VALUE;

       IF v_count = 0 THEN
          INSERT INTO pomast (txdate, txnum, amt, brid, deltd, status, bankid, bankname, bankacc, bankaccname, glacctno, feetype, potype, description)
          VALUES (
               to_date(p_txmsg.txfields('98').VALUE, systemnums.C_DATE_FORMAT) , p_txmsg.txfields('99').VALUE,
               p_txmsg.txfields('10').VALUE, p_txmsg.brid, p_txmsg.deltd, v_postatus, p_txmsg.txfields('05').VALUE,
               p_txmsg.txfields('85').VALUE, p_txmsg.txfields('08').VALUE, p_txmsg.txfields('86').VALUE,
               p_txmsg.txfields('15').VALUE, p_txmsg.txfields('09').VALUE, p_txmsg.txfields('17').VALUE, p_txmsg.txfields('30').VALUE) ; --p_txmsg.txdesc
               --p_txmsg.txfields('81').VALUE,p_txmsg.txfields('80').VALUE,p_txmsg.txfields('82').VALUE);
       ELSE

          UPDATE POMAST
                 SET AMT = AMT + p_txmsg.txfields('10').VALUE
                 WHERE TXNUM = p_txmsg.txfields('99').VALUE
                       AND TXDATE = to_date(p_txmsg.txfields('98').VALUE, systemnums.C_DATE_FORMAT);

       END IF; -- IF v_count = 0 THEN

       UPDATE CIREMITTANCE
              SET RMSTATUS='C',
                  POTXNUM = p_txmsg.txfields('99').VALUE,
                  POTXDATE = to_date(p_txmsg.txfields('98').VALUE, systemnums.C_DATE_FORMAT)
              WHERE TXDATE=to_date(p_txmsg.txfields('06').VALUE, systemnums.C_DATE_FORMAT) AND TXNUM=p_txmsg.txfields('07').VALUE;

    ELSE --IF p_txmsg.deltd <> 'Y' THEN

     --  CAP NHAT POMAST
        UPDATE POMAST
                 SET AMT = AMT - p_txmsg.txfields('10').VALUE
                 WHERE TXNUM = p_txmsg.txfields('99').VALUE
                       AND TXDATE = to_date(p_txmsg.txfields('98').VALUE, systemnums.C_DATE_FORMAT);

       UPDATE CIREMITTANCE
              SET RMSTATUS='P',
                  POTXNUM = NULL,
                  POTXDATE = NULL
              WHERE TXDATE=to_date(p_txmsg.txfields('06').VALUE, systemnums.C_DATE_FORMAT) AND TXNUM=p_txmsg.txfields('07').VALUE;
    END IF; --IF p_txmsg.deltd <> 'Y' THEN

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
         plog.init ('TXPKS_#1104EX',
                    plevel => NVL(logrow.loglevel,30),
                    plogtable => (NVL(logrow.log4table,'N') = 'Y'),
                    palert => (NVL(logrow.log4alert,'N') = 'Y'),
                    ptrace => (NVL(logrow.log4trace,'N') = 'Y')
            );
END TXPKS_#1104EX;
/
