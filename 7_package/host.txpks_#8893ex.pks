SET DEFINE OFF;
CREATE OR REPLACE PACKAGE txpks_#8893ex
/**----------------------------------------------------------------------------------------------------
 ** Package: TXPKS_#8893EX
 ** and is copyrighted by FSS.
 **
 **    All rights reserved.  No part of this work may be reproduced, stored in a retrieval system,
 **    adopted or transmitted in any form or by any means, electronic, mechanical, photographic,
 **    graphic, optic recording or otherwise, translated in any language or computer language,
 **    without the prior written permission of Financial Software Solutions. JSC.
 **
 **  MODIFICATION HISTORY
 **  Person      Date           Comments
 **  System      11/09/2016     Created
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


CREATE OR REPLACE PACKAGE BODY txpks_#8893ex
IS
   pkgctx   plog.log_ctx;
   logrow   tlogdebug%ROWTYPE;

   c_codeid           CONSTANT CHAR(2) := '01';
   c_actype           CONSTANT CHAR(2) := '02';
   c_custname         CONSTANT CHAR(2) := '50';
   c_afacctno         CONSTANT CHAR(2) := '03';
   c_custodycd        CONSTANT CHAR(2) := '08';
   c_exectype         CONSTANT CHAR(2) := '22';
   c_via              CONSTANT CHAR(2) := '25';
   c_pricetype        CONSTANT CHAR(2) := '27';
   c_quoteprice       CONSTANT CHAR(2) := '11';
   c_orderqtty        CONSTANT CHAR(2) := '12';
   c_orderid          CONSTANT CHAR(2) := '04';
   c_desc             CONSTANT CHAR(2) := '30';
   c_tradeunit        CONSTANT CHAR(2) := '98';
FUNCTION fn_txPreAppCheck(p_txmsg in tx.msg_rectype,p_err_code out varchar2)
RETURN NUMBER
IS
    l_strStatus     varchar2(10);
    l_remainqtty    number(20);
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
    select max(STATUS), min (remainqtty) into l_strStatus, l_remainqtty
    from bl_odmast where blorderid = p_txmsg.txfields(c_orderid).value;
    if l_strStatus = 'C' then
        p_err_code := '-700135'; -- Pre-defined in DEFERROR table
        plog.setendsection (pkgctx, 'fn_txPreAppCheck');
        RETURN errnums.C_BIZ_RULE_INVALID;
    end if;
    if l_remainqtty <= 0  then
        p_err_code := '-700136'; -- Pre-defined in DEFERROR table
        plog.setendsection (pkgctx, 'fn_txPreAppCheck');
        RETURN errnums.C_BIZ_RULE_INVALID;
    end if;

    if p_txmsg.txfields(c_orderqtty).value > l_remainqtty then
        p_err_code := '-700137'; -- Pre-defined in DEFERROR table
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
    l_strStatus     varchar2(10);
    l_remainqtty    number(20);
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
    select max(STATUS), min (remainqtty) into l_strStatus, l_remainqtty
    from bl_odmast where blorderid = p_txmsg.txfields(c_orderid).value;
    if l_strStatus = 'C' then
        p_err_code := '-700135'; -- Pre-defined in DEFERROR table
        plog.setendsection (pkgctx, 'fn_txPreAppCheck');
        RETURN errnums.C_BIZ_RULE_INVALID;
    end if;
    if l_remainqtty <= 0  then
        p_err_code := '-700136'; -- Pre-defined in DEFERROR table
        plog.setendsection (pkgctx, 'fn_txPreAppCheck');
        RETURN errnums.C_BIZ_RULE_INVALID;
    end if;

    if p_txmsg.txfields(c_orderqtty).value > l_remainqtty then
        p_err_code := '-700137'; -- Pre-defined in DEFERROR table
        plog.setendsection (pkgctx, 'fn_txPreAppCheck');
        RETURN errnums.C_BIZ_RULE_INVALID;
    end if;

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
    l_err_code      varchar2(50);
    l_err_message   varchar2(200);
    l_strSymbol     varchar2(20);
BEGIN
    plog.setbeginsection (pkgctx, 'fn_txAftAppUpdate');
    plog.debug (pkgctx, '<<BEGIN OF fn_txAftAppUpdate');
   /***************************************************************************************************
    ** PUT YOUR SPECIFIC AFTER PROCESS HERE. DO NOT COMMIT/ROLLBACK HERE, THE SYSTEM WILL DO IT
    ***************************************************************************************************/
/*    c_codeid           CONSTANT CHAR(2) := '01';
   c_actype           CONSTANT CHAR(2) := '02';
   c_custname         CONSTANT CHAR(2) := '50';
   c_afacctno         CONSTANT CHAR(2) := '03';
   c_custodycd        CONSTANT CHAR(2) := '08';
   c_exectype         CONSTANT CHAR(2) := '22';
   c_via              CONSTANT CHAR(2) := '25';
   c_pricetype        CONSTANT CHAR(2) := '27';
   c_quoteprice       CONSTANT CHAR(2) := '11';
   c_orderqtty        CONSTANT CHAR(2) := '12';
   c_orderid          CONSTANT CHAR(2) := '04';
   c_desc             CONSTANT CHAR(2) := '30';
   c_tradeunit        CONSTANT CHAR(2) := '98';*/
   select max(symbol) into l_strSymbol from sbsecurities where codeid = p_txmsg.txfields(c_codeid).value;
    fopks_api.pr_placeorder_bl ('BLBPLACEORDER',
                                    p_txmsg.txfields(c_custodycd).value,
                                    '' ,
                                    p_txmsg.txfields(c_afacctno).value,
                                    p_txmsg.txfields(c_exectype).value,
                                    l_strSymbol ,
                                    p_txmsg.txfields(c_orderqtty).value,
                                    p_txmsg.txfields(c_quoteprice).value,
                                    p_txmsg.txfields(c_pricetype).value,
                                    'T' ,
                                    'A' ,
                                    p_txmsg.txfields(c_via).value,
                                    '' ,
                                    'Y' ,
                                    '' ,
                                    '' ,
                                    p_txmsg.tlid,
                                    0,
                                    0,
                                    l_err_code,
                                    l_err_message,
                                    '',
                                    p_txmsg.txfields(c_orderid).value
                                    );
            if l_err_code <> '0' then
                p_err_code := l_err_code; -- Pre-defined in DEFERROR table
                plog.setendsection (pkgctx, 'fn_txPreAppCheck');
                RETURN errnums.C_BIZ_RULE_INVALID;
            else
                update bl_odmast set status = 'F', feedbackmsg = 'Order is sent to Flex',
                    last_change = SYSTIMESTAMP, ---sentqtty = sentqtty + p_txmsg.txfields(c_orderqtty).value,
                    ----remainqtty = remainqtty-p_txmsg.txfields(c_orderqtty).value,
                    pstatus = pstatus || status
                where blorderid = p_txmsg.txfields(c_orderid).value;
            end if;
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
         plog.init ('TXPKS_#8893EX',
                    plevel => NVL(logrow.loglevel,30),
                    plogtable => (NVL(logrow.log4table,'N') = 'Y'),
                    palert => (NVL(logrow.log4alert,'N') = 'Y'),
                    ptrace => (NVL(logrow.log4trace,'N') = 'Y')
            );
END TXPKS_#8893EX;
/
