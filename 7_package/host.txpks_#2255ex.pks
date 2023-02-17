SET DEFINE OFF;
CREATE OR REPLACE PACKAGE txpks_#2255ex
/**----------------------------------------------------------------------------------------------------
 ** Package: TXPKS_#2255EX
 ** and is copyrighted by FSS.
 **
 **    All rights reserved.  No part of this work may be reproduced, stored in a retrieval system,
 **    adopted or transmitted in any form or by any means, electronic, mechanical, photographic,
 **    graphic, optic recording or otherwise, translated in any language or computer language,
 **    without the prior written permission of Financial Software Solutions. JSC.
 **
 **  MODIFICATION HISTORY
 **  Person      Date           Comments
 **  System      24/08/2012     Created
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


CREATE OR REPLACE PACKAGE BODY txpks_#2255ex
IS
   pkgctx   plog.log_ctx;
   logrow   tlogdebug%ROWTYPE;

   c_autoid           CONSTANT CHAR(2) := '18';
   c_custodycd        CONSTANT CHAR(2) := '05';
   c_afacctno         CONSTANT CHAR(2) := '02';
   c_acctno           CONSTANT CHAR(2) := '03';
   c_custname         CONSTANT CHAR(2) := '90';
   c_symbol           CONSTANT CHAR(2) := '07';
   c_amt              CONSTANT CHAR(2) := '10';
   c_depoblock        CONSTANT CHAR(2) := '06';
   c_tradewtf         CONSTANT CHAR(2) := '13';
   c_qtty             CONSTANT CHAR(2) := '12';
   c_recustodycd      CONSTANT CHAR(2) := '23';
   c_recustname       CONSTANT CHAR(2) := '24';
   c_desc             CONSTANT CHAR(2) := '30';
   c_codeid           CONSTANT CHAR(2) := '01';
FUNCTION fn_txPreAppCheck(p_txmsg in tx.msg_rectype,p_err_code out varchar2)
RETURN NUMBER
IS
    l_count number;
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

    select count(1) into l_count from sesendout where status='S' and autoid= p_txmsg.txfields('18').value;
    if L_COUNT > 0 then
        p_err_code := '-100777'; -- Pre-defined in DEFERROR table
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
l_count NUMBER(20);
l_trade NUMBER(20);
l_blocked NUMBER(20);
l_caqtty NUMBER(20);
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
                  p_err_code:='-200401';
                  plog.setendsection (pkgctx, 'fn_txPreAppUpdate');
                  RETURN errnums.C_BIZ_RULE_INVALID;
        END;
        IF(l_count >0) THEN
          p_err_code := '-200401'; -- Pre-defined in DEFERROR table
          plog.setendsection (pkgctx, 'fn_txPreAppCheck');
          RETURN errnums.C_BIZ_RULE_INVALID;
        END IF;
    ELSE
        BEGIN
             SELECT COUNT(*) INTO L_count
             FROM sesendout
             WHERE autoid=p_txmsg.txfields('18').value
             AND ((strade < l_trade) OR(sblocked<l_blocked) OR(scaqtty<l_caqtty))
             AND deltd='N';
         EXCEPTION WHEN OTHERS THEN
                    p_err_code:='-200404';
                    plog.setendsection (pkgctx, 'fn_txPreAppUpdate');
                    RETURN errnums.C_BIZ_RULE_INVALID;
         END;
         IF(l_count >0) THEN
            p_err_code := '-200404'; -- Pre-defined in DEFERROR table
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
v_count number;
BEGIN
    plog.setbeginsection (pkgctx, 'fn_txAftAppUpdate');
    plog.debug (pkgctx, '<<BEGIN OF fn_txAftAppUpdate');
   /***************************************************************************************************
    ** PUT YOUR SPECIFIC AFTER PROCESS HERE. DO NOT COMMIT/ROLLBACK HERE, THE SYSTEM WILL DO IT
    ***************************************************************************************************/
        l_trade:=p_txmsg.txfields('10').value;
        l_blocked:=p_txmsg.txfields('06').value;
        l_caqtty:=p_txmsg.txfields('13').value;
    if(p_txmsg.deltd <> 'Y') THEN

        UPDATE sesendout
                SET trade=trade-l_trade ,blocked=blocked-l_blocked, caqtty=caqtty-l_caqtty,
                strade=strade+l_trade ,sblocked=sblocked+l_blocked, scaqtty=scaqtty+l_caqtty,
                status='S', id2255=p_txmsg.txdate||p_txmsg.txnum
        WHERE autoid= p_txmsg.txfields('18').value;


        INSERT INTO se2255_log
            (   sendoutid, afacctno, txdate, txnum, tltxcd,
                brid, codeid, trade, blocked,
                trade_wft, blocked_wft, deltd, SENDTOVSD --31/05/2018 DieuNDA: Them truong SENDTOVSD co gui VSD hay khong
            )
          VALUES
            (   p_txmsg.txfields('18').value, p_txmsg.txfields(c_afacctno).value, p_txmsg.txdate,  p_txmsg.txnum,  p_txmsg.tltxcd,
                p_txmsg.brid, p_txmsg.txfields(c_codeid).value, l_trade, l_blocked,
                l_caqtty, 0, 'N', p_txmsg.txfields('08').value
            );


    ELSE-- xoa jao dich
        SELECT count(1) into v_count FROM sesendout WHERE autoid= p_txmsg.txfields('18').value and status <> 'S';
        if v_count>0 then
            --Giao dich da lam buoc ke tiep, khong duoc xoa.
              p_err_code := '-200404'; -- Pre-defined in DEFERROR table
              plog.setendsection (pkgctx, 'fn_txPreAppUpdate');
              RETURN errnums.C_BIZ_RULE_INVALID;
        end if;

        UPDATE sesendout
                SET trade=trade+l_trade ,blocked=blocked+l_blocked, caqtty=caqtty+l_caqtty,
                strade=strade-l_trade ,sblocked=sblocked-l_blocked, scaqtty=scaqtty-l_caqtty,
                status='N',id2255=''
        WHERE autoid= p_txmsg.txfields('18').value;

        UPDATE se2255_log SET deltd = 'Y' WHERE txdate = p_txmsg.txdate AND txnum = p_txmsg.txnum;

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
         plog.init ('TXPKS_#2255EX',
                    plevel => NVL(logrow.loglevel,30),
                    plogtable => (NVL(logrow.log4table,'N') = 'Y'),
                    palert => (NVL(logrow.log4alert,'N') = 'Y'),
                    ptrace => (NVL(logrow.log4trace,'N') = 'Y')
            );
END TXPKS_#2255EX;
/
