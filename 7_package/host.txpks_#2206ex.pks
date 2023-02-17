SET DEFINE OFF;
CREATE OR REPLACE PACKAGE txpks_#2206ex
/**----------------------------------------------------------------------------------------------------
 ** Package: TXPKS_#2206EX
 ** and is copyrighted by FSS.
 **
 **    All rights reserved.  No part of this work may be reproduced, stored in a retrieval system,
 **    adopted or transmitted in any form or by any means, electronic, mechanical, photographic,
 **    graphic, optic recording or otherwise, translated in any language or computer language,
 **    without the prior written permission of Financial Software Solutions. JSC.
 **
 **  MODIFICATION HISTORY
 **  Person      Date           Comments
 **  System      26/11/2016     Created
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


CREATE OR REPLACE PACKAGE BODY txpks_#2206ex
IS
   pkgctx   plog.log_ctx;
   logrow   tlogdebug%ROWTYPE;

   c_custodycd        CONSTANT CHAR(2) := '88';
   c_acctno           CONSTANT CHAR(2) := '03';
   c_custname         CONSTANT CHAR(2) := '90';
   c_license          CONSTANT CHAR(2) := '92';
   c_iddate           CONSTANT CHAR(2) := '33';
   c_idplace          CONSTANT CHAR(2) := '34';
   c_address          CONSTANT CHAR(2) := '91';
   c_opnfbors         CONSTANT CHAR(2) := '08';
   c_codeid           CONSTANT CHAR(2) := '01';
   c_rfacctno         CONSTANT CHAR(2) := '06';
   c_valqtty          CONSTANT CHAR(2) := '10';
   c_valamt           CONSTANT CHAR(2) := '60';
   c_seacctno         CONSTANT CHAR(2) := '04';
   c_rfcodeid         CONSTANT CHAR(2) := '21';
   c_swapqtty         CONSTANT CHAR(2) := '36';
   c_allowsession     CONSTANT CHAR(2) := '37';
   c_caculatetype     CONSTANT CHAR(2) := '38';
   c_drfeetype        CONSTANT CHAR(2) := '39';
   c_fee              CONSTANT CHAR(2) := '40';
   c_chkqtty          CONSTANT CHAR(2) := '09';
   c_crqtty           CONSTANT CHAR(2) := '20';
   c_desc             CONSTANT CHAR(2) := '30';
FUNCTION fn_txPreAppCheck(p_txmsg in tx.msg_rectype,p_err_code out varchar2)
RETURN NUMBER
IS
    v_dblBALAVL number(20);
    v_dblBALMIN number(20);
    v_count     number(10);
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
    if p_txmsg.txfields('08').value in ('OPFSEL','OPFSWP','OPFTRO') then
        v_dblBALAVL := NVL(fn_get_semast_avl_withdraw(p_txmsg.txfields('03').value,p_txmsg.txfields('01').value),0);
        select min(nvl(iss.TRADEQTTYMIN,0)) into v_dblBALMIN
        from sbsecurities sb, issuers iss where sb.codeid = p_txmsg.txfields('01').value and sb.issuerid = iss.issuerid;

        If Not (v_dblBALAVL - p_txmsg.txfields('10').value >= v_dblBALMIN Or v_dblBALAVL - p_txmsg.txfields('10').value = 0) Then
            p_err_code := '-100891';
            plog.setendsection (pkgctx, 'fn_txPreAppCheck');
            RETURN errnums.C_BIZ_RULE_INVALID;
        End If;
    end if;
    if p_txmsg.txfields('08').value = 'OPFSWP' then
        if p_txmsg.txfields('01').value <> p_txmsg.txfields('21').value then
            SELECT count(A.SYMBOL) into v_count FROM SBSECURITIES A, SBSECURITIES B
                WHERE A.ISSUERID=B.ISSUERID AND A.CODEID=p_txmsg.txfields('01').value
                AND B.CODEID=p_txmsg.txfields('21').value;
            If nvl(v_count,0) = 0 Then
                p_err_code := '-100889';
                plog.setendsection (pkgctx, 'fn_txPreAppCheck');
                RETURN errnums.C_BIZ_RULE_INVALID;
            End If;
        else
            p_err_code := '-100890';
            plog.setendsection (pkgctx, 'fn_txPreAppCheck');
            RETURN errnums.C_BIZ_RULE_INVALID;
        end if;
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
    v_dblBALAVL number(20);
    v_dblBALMIN number(20);
    v_count     number(10);
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
    if p_txmsg.txfields('08').value in ('OPFSEL','OPFSWP','OPFTRO') then
        v_dblBALAVL := NVL(fn_get_semast_avl_withdraw(p_txmsg.txfields('03').value,p_txmsg.txfields('01').value),0);
        select min(nvl(iss.TRADEQTTYMIN,0)) into v_dblBALMIN
        from sbsecurities sb, issuers iss where sb.codeid = p_txmsg.txfields('01').value and sb.issuerid = iss.issuerid;

        If Not (v_dblBALAVL - p_txmsg.txfields('10').value >= v_dblBALMIN Or v_dblBALAVL - p_txmsg.txfields('10').value = 0) Then
            p_err_code := '-100891';
            plog.setendsection (pkgctx, 'fn_txPreAppCheck');
            RETURN errnums.C_BIZ_RULE_INVALID;
        End If;
    end if;
    if p_txmsg.txfields('08').value = 'OPFSWP' then
        if p_txmsg.txfields('01').value <> p_txmsg.txfields('21').value then
            SELECT count(A.SYMBOL) into v_count FROM SBSECURITIES A, SBSECURITIES B
                WHERE A.ISSUERID=B.ISSUERID AND A.CODEID=p_txmsg.txfields('01').value
                AND B.CODEID=p_txmsg.txfields('21').value;
            If nvl(v_count,0) = 0 Then
                p_err_code := '-100889';
                plog.setendsection (pkgctx, 'fn_txPreAppCheck');
                RETURN errnums.C_BIZ_RULE_INVALID;
            End If;
        else
            p_err_code := '-100890';
            plog.setendsection (pkgctx, 'fn_txPreAppCheck');
            RETURN errnums.C_BIZ_RULE_INVALID;
        end if;
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
BEGIN
    plog.setbeginsection (pkgctx, 'fn_txAftAppUpdate');
    plog.debug (pkgctx, '<<BEGIN OF fn_txAftAppUpdate');
   /***************************************************************************************************
    ** PUT YOUR SPECIFIC AFTER PROCESS HERE. DO NOT COMMIT/ROLLBACK HERE, THE SYSTEM WILL DO IT
    ***************************************************************************************************/
    IF p_txmsg.deltd <> 'Y' THEN -- Normal transaction
        INSERT INTO IBDEALS (TXDATE, TXNUM, AFACCTNO, CODEID, RFCODEID, DEALTYPE, QUOTEQTTY, QUOTEAMT, QUOTEPRICE, EXEQTTY, EXEAMT, SETQTTY, SETAMT, STATUS, NOTES, FEEAMT,SWAPQTTY,BRFEEAMT)
            VALUES (TO_DATE(p_txmsg.txdate, systemnums.C_DATE_FORMAT),p_txmsg.txnum,p_txmsg.txfields('03').value,p_txmsg.txfields('01').value,p_txmsg.txfields('21').value,p_txmsg.txfields('08').value,
                    p_txmsg.txfields('10').value,p_txmsg.txfields('60').value, 0, 0, 0, 0, 0,'P',p_txmsg.txfields('30').value,p_txmsg.txfields('40').value,p_txmsg.txfields('36').value,p_txmsg.txfields('42').value);
    ELSE -- Reversal
        DELETE FROM IBDEALS WHERE TXNUM = p_txmsg.txnum AND TXDATE = TO_DATE(p_txmsg.txdate, systemnums.C_DATE_FORMAT);
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
         plog.init ('TXPKS_#2206EX',
                    plevel => NVL(logrow.loglevel,30),
                    plogtable => (NVL(logrow.log4table,'N') = 'Y'),
                    palert => (NVL(logrow.log4alert,'N') = 'Y'),
                    ptrace => (NVL(logrow.log4trace,'N') = 'Y')
            );
END TXPKS_#2206EX;
/
