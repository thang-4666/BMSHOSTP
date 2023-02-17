SET DEFINE OFF;
CREATE OR REPLACE PACKAGE txpks_#8839ex
/**----------------------------------------------------------------------------------------------------
 ** Package: TXPKS_#8839EX
 ** and is copyrighted by FSS.
 **
 **    All rights reserved.  No part of this work may be reproduced, stored in a retrieval system,
 **    adopted or transmitted in any form or by any means, electronic, mechanical, photographic,
 **    graphic, optic recording or otherwise, translated in any language or computer language,
 **    without the prior written permission of Financial Software Solutions. JSC.
 **
 **  MODIFICATION HISTORY
 **  Person      Date           Comments
 **  System      03/11/2016     Created
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


CREATE OR REPLACE PACKAGE BODY txpks_#8839ex
IS
   pkgctx   plog.log_ctx;
   logrow   tlogdebug%ROWTYPE;

   c_codeid           CONSTANT CHAR(2) := '01';
   c_ismortage        CONSTANT CHAR(2) := '60';
   c_actype           CONSTANT CHAR(2) := '02';
   c_seacctno         CONSTANT CHAR(2) := '06';
   c_afacctno         CONSTANT CHAR(2) := '03';
   c_custname         CONSTANT CHAR(2) := '50';
   c_custodycd        CONSTANT CHAR(2) := '08';
   c_timetype         CONSTANT CHAR(2) := '20';
   c_expdate          CONSTANT CHAR(2) := '21';
   c_effdate          CONSTANT CHAR(2) := '19';
   c_exectype         CONSTANT CHAR(2) := '22';
   c_nork             CONSTANT CHAR(2) := '23';
   c_outpriceallow    CONSTANT CHAR(2) := '34';
   c_matchtype        CONSTANT CHAR(2) := '24';
   c_via              CONSTANT CHAR(2) := '25';
   c_clearday         CONSTANT CHAR(2) := '10';
   c_clearcd          CONSTANT CHAR(2) := '26';
   c_puttype          CONSTANT CHAR(2) := '72';
   c_pricetype        CONSTANT CHAR(2) := '27';
   c_quoteprice       CONSTANT CHAR(2) := '11';
   c_orderqtty        CONSTANT CHAR(2) := '12';
   c_quoteqtty        CONSTANT CHAR(2) := '80';
   c_tradestatus      CONSTANT CHAR(2) := '90';
   c_ptdeal           CONSTANT CHAR(2) := '81';
   c_bratio           CONSTANT CHAR(2) := '13';
   c_limitprice       CONSTANT CHAR(2) := '14';
   c_feeamt           CONSTANT CHAR(2) := '40';
   c_voucher          CONSTANT CHAR(2) := '28';
   c_consultant       CONSTANT CHAR(2) := '29';
   c_orderid          CONSTANT CHAR(2) := '04';
   c_dealid           CONSTANT CHAR(2) := '95';
   c_ssafacctno       CONSTANT CHAR(2) := '94';
   c_parvalue         CONSTANT CHAR(2) := '15';
   c_grporder         CONSTANT CHAR(2) := '55';
   c_hundred          CONSTANT CHAR(2) := '99';
   c_desc             CONSTANT CHAR(2) := '30';
   c_tradeunit        CONSTANT CHAR(2) := '98';
   c_tradeunit        CONSTANT CHAR(2) := '96';
   c_mode             CONSTANT CHAR(2) := '97';
   c_isbondtransact   CONSTANT CHAR(2) := '85';
   c_bondinfo         CONSTANT CHAR(2) := '86';
   c_contrafirm       CONSTANT CHAR(2) := '73';
   c_traderid         CONSTANT CHAR(2) := '32';
   c_contrafirm       CONSTANT CHAR(2) := '31';
   c_advidref         CONSTANT CHAR(2) := '35';
   c_contracus        CONSTANT CHAR(2) := '71';
   c_isdisposal       CONSTANT CHAR(2) := '74';
   c_clientid         CONSTANT CHAR(2) := '33';
FUNCTION fn_txPreAppCheck(p_txmsg in tx.msg_rectype,p_err_code out varchar2)
RETURN NUMBER
IS
    l_err_code      varchar2(50);
    l_err_message   varchar2(200);
    l_strSymbol     varchar2(20);
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
    select max(symbol) into l_strSymbol from sbsecurities where codeid = p_txmsg.txfields(c_codeid).value;
    --Ngay 07/3/2017 CW NamTv them check chung quyen dao han
        if fn_check_cwsecurities(l_strSYMBOL) <> 0 then
            p_err_code:=-100128;                                
            plog.setendsection (pkgctx, 'fn_txAftAppCheck');
            return errnums.C_BIZ_RULE_INVALID;
        end if;
    --NamTv End
        
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
    l_err_code      varchar2(50);
    l_err_message   varchar2(200);
    l_strSymbol     varchar2(20);
BEGIN
    plog.setbeginsection (pkgctx, 'fn_txAftAppUpdate');
    plog.debug (pkgctx, '<<BEGIN OF fn_txAftAppUpdate');
   /***************************************************************************************************
    ** PUT YOUR SPECIFIC AFTER PROCESS HERE. DO NOT COMMIT/ROLLBACK HERE, THE SYSTEM WILL DO IT
    ***************************************************************************************************/
    select max(symbol) into l_strSymbol from sbsecurities where codeid = p_txmsg.txfields(c_codeid).value;
    fopks_api.pr_placeorder ('PLACEORDERDISPOSAL',
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
                                    'N' ,
                                    '' ,
                                    '' ,
                                    p_txmsg.tlid,
                                    0,
                                    0,
                                    l_err_code,
                                    l_err_message,
                                    '',
                                    ''
                                    );
            if l_err_code <> '0' then
                p_err_code := l_err_code; -- Pre-defined in DEFERROR table
                plog.setendsection (pkgctx, 'fn_txPreAppCheck');
                RETURN errnums.C_BIZ_RULE_INVALID;
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
         plog.init ('TXPKS_#8839EX',
                    plevel => NVL(logrow.loglevel,30),
                    plogtable => (NVL(logrow.log4table,'N') = 'Y'),
                    palert => (NVL(logrow.log4alert,'N') = 'Y'),
                    ptrace => (NVL(logrow.log4trace,'N') = 'Y')
            );
END TXPKS_#8839EX;
/
