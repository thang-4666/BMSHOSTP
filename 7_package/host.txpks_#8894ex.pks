SET DEFINE OFF;
CREATE OR REPLACE PACKAGE txpks_#8894ex
/**----------------------------------------------------------------------------------------------------
 ** Package: TXPKS_#8894EX
 ** and is copyrighted by FSS.
 **
 **    All rights reserved.  No part of this work may be reproduced, stored in a retrieval system,
 **    adopted or transmitted in any form or by any means, electronic, mechanical, photographic,
 **    graphic, optic recording or otherwise, translated in any language or computer language,
 **    without the prior written permission of Financial Software Solutions. JSC.
 **
 **  MODIFICATION HISTORY
 **  Person      Date           Comments
 **  System      29/08/2012     Created
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


CREATE OR REPLACE PACKAGE BODY txpks_#8894ex
IS
   pkgctx   plog.log_ctx;
   logrow   tlogdebug%ROWTYPE;

   c_codeid           CONSTANT CHAR(2) := '01';
   c_afacctno         CONSTANT CHAR(2) := '02';
   c_seacctno         CONSTANT CHAR(2) := '03';
   c_afacctno2        CONSTANT CHAR(2) := '07';
   c_seacctno2        CONSTANT CHAR(2) := '08';
   c_txdate           CONSTANT CHAR(2) := '04';
   c_txnum            CONSTANT CHAR(2) := '05';
   c_orderqtty        CONSTANT CHAR(2) := '10';
   c_quoteprice       CONSTANT CHAR(2) := '11';
   c_tax              CONSTANT CHAR(2) := '14';
   c_taxamt           CONSTANT CHAR(2) := '15';
   c_pitqtty          CONSTANT CHAR(2) := '18';
   c_pitamt           CONSTANT CHAR(2) := '19';
   c_parvalue         CONSTANT CHAR(2) := '12';
   c_iscorebank       CONSTANT CHAR(2) := '60';
   c_feeamt           CONSTANT CHAR(2) := '22';
   c_desc             CONSTANT CHAR(2) := '30';
FUNCTION fn_txPreAppCheck(p_txmsg in tx.msg_rectype,p_err_code out varchar2)
RETURN NUMBER
IS
l_date DATE;
l_status varchar2(10) ;
l_baldefovd apprules.field%TYPE;
l_cimastcheck_arr txpks_check.cimastcheck_arrtype;
l_count number;
l_afacctnosell varchar2(10);
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
    SELECT sdate,status INTO l_date,l_status
    FROM seretail
    WHERE txdate=TO_DATE( p_txmsg.txfields('04').VALUE,'DD/MM/RRRR')
    AND txnum=p_txmsg.txfields('05').VALUE;
    IF (p_txmsg.busdate < l_date ) THEN
          p_err_code := '-200405'; -- Pre-defined in DEFERROR table
          plog.setendsection (pkgctx, 'fn_txPreAppCheck');
          RETURN errnums.C_BIZ_RULE_INVALID;
    END IF;
    if  l_status <> 'I' then
          p_err_code := -901204;
          plog.error (pkgctx, p_err_code );
          RETURN errnums.C_BIZ_RULE_INVALID;
    end if;
    IF p_txmsg.deltd = 'Y' THEN
    /*Add by ManhTV, check balance tai khoan ban co du tien hoan lai ko*/
      l_afacctnosell := p_txmsg.txfields('02').value;
      If txpks_check.fn_aftxmapcheck(l_afacctnosell,'CIMAST','02','8894')<>'TRUE' then
         p_err_code := errnums.C_SA_TLTX_NOT_ALLOW_BY_ACCTNO;
         plog.setendsection (pkgctx, 'fn_txAftAppUpdate');
         RETURN errnums.C_BIZ_RULE_INVALID;
      End if;

      l_CIMASTcheck_arr := txpks_check.fn_CIMASTcheck(l_afacctnosell,'CIMAST','ACCTNO');
      l_BALDEFOVD := l_CIMASTcheck_arr(0).BALDEFOVD;
      plog.debug(pkgctx, 'l_BALDEFOVD := ' || l_BALDEFOVD);
      IF NOT (to_number(l_BALDEFOVD) >= to_number(p_txmsg.txfields('10').value*p_txmsg.txfields('11').value - p_txmsg.txfields('14').value - p_txmsg.txfields('15').value - p_txmsg.txfields('22').value)) THEN
         p_err_code := '-400110';
         plog.setendsection (pkgctx, 'fn_txAppAutoCheck');
         RETURN errnums.C_BIZ_RULE_INVALID;
      END IF;

      --check k thuc hien 1 gd 2 lan
    SELECT COUNT(1) into L_COUNT FROM SERETAIL WHERE TXDATE = TO_DATE(p_txmsg.txfields('04').value,'DD/MM/RRRR') AND TRIM(TXNUM) =p_txmsg.txfields('05').value and STATUS = 'C';
    if L_COUNT > 0 then
       p_err_code := '-100778'; -- Pre-defined in DEFERROR table
       plog.setendsection (pkgctx, 'fn_txPreAppCheck');
       RETURN errnums.C_BIZ_RULE_INVALID;
    end if;

    END IF;
    /*End add*/
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
l_qtty NUMBER;
l_baldefovd apprules.field%TYPE;
l_cimastcheck_arr txpks_check.cimastcheck_arrtype;

l_afacctnosell varchar2(10);

BEGIN
    plog.setbeginsection (pkgctx, 'fn_txAftAppUpdate');
    plog.debug (pkgctx, '<<BEGIN OF fn_txAftAppUpdate');
   /***************************************************************************************************
    ** PUT YOUR SPECIFIC AFTER PROCESS HERE. DO NOT COMMIT/ROLLBACK HERE, THE SYSTEM WILL DO IT
    ***************************************************************************************************/
     l_qtty:= p_txmsg.txfields('10').VALUE;
    IF p_txmsg.deltd <> 'Y' THEN
      UPDATE SERETAIL SET
        --QTTY = QTTY - l_qtty ,
        status='C'
      WHERE TXDATE = TO_DATE( p_txmsg.txfields('04').VALUE,'DD/MM/RRRR')
      AND (TXNUM) = p_txmsg.txfields('05').VALUE;

    ELSE-- xoa jao dich
      /*Add by ManhTV, check balance tai khoan ban co du tien hoan lai ko*/
      l_afacctnosell := p_txmsg.txfields('02').value;
      If txpks_check.fn_aftxmapcheck(l_afacctnosell,'CIMAST','02','8894')<>'TRUE' then
         p_err_code := errnums.C_SA_TLTX_NOT_ALLOW_BY_ACCTNO;
         plog.setendsection (pkgctx, 'fn_txAftAppUpdate');
         RETURN errnums.C_BIZ_RULE_INVALID;
      End if;

     l_CIMASTcheck_arr := txpks_check.fn_CIMASTcheck(l_afacctnosell,'CIMAST','ACCTNO');
     l_BALDEFOVD := l_CIMASTcheck_arr(0).BALDEFOVD;
     plog.debug(pkgctx, 'l_BALDEFOVD := ' || l_BALDEFOVD);
     IF NOT (to_number(l_BALDEFOVD) >= to_number(p_txmsg.txfields('10').value*p_txmsg.txfields('11').value - p_txmsg.txfields('14').value - p_txmsg.txfields('15').value - p_txmsg.txfields('22').value)) THEN
        p_err_code := '-400110';
        plog.setendsection (pkgctx, 'fn_txAppAutoCheck');
        RETURN errnums.C_BIZ_RULE_INVALID;
     END IF;
      /*End add*/
      UPDATE SERETAIL SET
        --QTTY = QTTY + l_qtty ,
        status='I'
      WHERE TXDATE = TO_DATE( p_txmsg.txfields('04').VALUE,'DD/MM/RRRR')
      AND (TXNUM) = p_txmsg.txfields('05').VALUE;
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
         plog.init ('TXPKS_#8894EX',
                    plevel => NVL(logrow.loglevel,30),
                    plogtable => (NVL(logrow.log4table,'N') = 'Y'),
                    palert => (NVL(logrow.log4alert,'N') = 'Y'),
                    ptrace => (NVL(logrow.log4trace,'N') = 'Y')
            );
END TXPKS_#8894EX;
/
