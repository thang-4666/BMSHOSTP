SET DEFINE OFF;
CREATE OR REPLACE PACKAGE txpks_#0041ex
/**----------------------------------------------------------------------------------------------------
 ** Package: TXPKS_#0041EX
 ** and is copyrighted by FSS.
 **
 **    All rights reserved.  No part of this work may be reproduced, stored in a retrieval system,
 **    adopted or transmitted in any form or by any means, electronic, mechanical, photographic,
 **    graphic, optic recording or otherwise, translated in any language or computer language,
 **    without the prior written permission of Financial Software Solutions. JSC.
 **
 **  MODIFICATION HISTORY
 **  Person      Date           Comments
 **  System      22/06/2013     Created
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


CREATE OR REPLACE PACKAGE BODY txpks_#0041ex
IS
   pkgctx   plog.log_ctx;
   logrow   tlogdebug%ROWTYPE;

   c_custodycd        CONSTANT CHAR(2) := '88';
   c_custid           CONSTANT CHAR(2) := '03';
   c_acctno           CONSTANT CHAR(2) := '05';
   c_blacctno         CONSTANT CHAR(2) := '01';
   c_desc             CONSTANT CHAR(2) := '30';
FUNCTION fn_txPreAppCheck(p_txmsg in tx.msg_rectype,p_err_code out varchar2)
RETURN NUMBER
IS
    l_afstatus  varchar2(1);
    l_cfstatus  varchar2(1);
    l_count     NUMBER;

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

    -- Check trang thai tai khoan
    SELECT cf.status
    INTO l_cfstatus
    FROM cfmast cf
    WHERE cf.custid = p_txmsg.txfields (c_custid).value;
    IF l_cfstatus <> 'A' THEN
        p_err_code := '-200045'; -- ERR_INVALIF_CFMAST_STATUS!
        plog.setendsection (pkgctx, 'fn_txPreAppCheck');
        RETURN errnums.C_BIZ_RULE_INVALID;
    END IF;

    SELECT af.status
    INTO l_afstatus
    FROM afmast af
    WHERE af.acctno = p_txmsg.txfields (c_acctno).value;
    IF l_afstatus <> 'A' THEN
        p_err_code := '-200010'; -- Invalid status
        plog.setendsection (pkgctx, 'fn_txPreAppCheck');
        RETURN errnums.C_BIZ_RULE_INVALID;
    END IF;

    -- Check 1 TK luu ky chi dc gan 1 tieu khoan
    /*SELECT count(*)
    INTO l_count
    FROM bl_register blr
    WHERE blr.custodycd = p_txmsg.txfields (c_custodycd).value AND blr.status = 'A';
    IF l_count > 0 THEN
        p_err_code := '-200601'; -- Invalid status
        plog.setendsection (pkgctx, 'fn_txPreAppCheck');
        RETURN errnums.C_BIZ_RULE_INVALID;
    END IF;*/

    -- Check 1 tieu khoan chi dc dang ky 1 lan
    SELECT count(*)
    INTO l_count
    FROM bl_register blr
    WHERE blr.afacctno = p_txmsg.txfields (c_acctno).value AND blr.status = 'A';
    IF l_count > 0 THEN
        p_err_code := '-200602'; -- Invalid status
        plog.setendsection (pkgctx, 'fn_txPreAppCheck');
        RETURN errnums.C_BIZ_RULE_INVALID;
    END IF;

    -- Check 1 TK dat lenh Bloomberg chi dc dang ky 1 lan
    SELECT count(*)
    INTO l_count
    FROM bl_register blr
    WHERE blr.blacctno = p_txmsg.txfields (c_blacctno).value AND blr.status = 'A';
    IF l_count > 0 THEN
        p_err_code := '-200603'; -- Invalid status
        plog.setendsection (pkgctx, 'fn_txPreAppCheck');
        RETURN errnums.C_BIZ_RULE_INVALID;
    END IF;

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
    l_afstatus  varchar2(1);
    l_cfstatus  varchar2(1);
    l_count     NUMBER;
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
    -- Check trang thai tai khoan
    SELECT cf.status
    INTO l_cfstatus
    FROM cfmast cf
    WHERE cf.custid = p_txmsg.txfields (c_custid).value;
    IF l_cfstatus <> 'A' THEN
        p_err_code := '-200045'; -- ERR_INVALIF_CFMAST_STATUS!
        plog.setendsection (pkgctx, 'fn_txAftAppCheck');
        RETURN errnums.C_BIZ_RULE_INVALID;
    END IF;

    SELECT af.status
    INTO l_afstatus
    FROM afmast af
    WHERE af.acctno = p_txmsg.txfields (c_acctno).value;
    IF l_afstatus <> 'A' THEN
        p_err_code := '-200010'; -- Invalid status
        plog.setendsection (pkgctx, 'fn_txAftAppCheck');
        RETURN errnums.C_BIZ_RULE_INVALID;
    END IF;

    -- Check 1 TK luu ky chi dc gan 1 tieu khoan
    /*SELECT count(*)
    INTO l_count
    FROM bl_register blr
    WHERE blr.custodycd = p_txmsg.txfields (c_custodycd).value AND blr.status = 'A';
    IF l_count > 0 THEN
        p_err_code := '-200601'; -- Invalid status
        plog.setendsection (pkgctx, 'fn_txAftAppCheck');
        RETURN errnums.C_BIZ_RULE_INVALID;
    END IF;*/

    -- Check 1 tieu khoan chi dc dang ky 1 lan
    SELECT count(*)
    INTO l_count
    FROM bl_register blr
    WHERE blr.afacctno = p_txmsg.txfields (c_acctno).value AND blr.status = 'A';
    IF l_count > 0 THEN
        p_err_code := '-200602'; -- Invalid status
        plog.setendsection (pkgctx, 'fn_txAftAppCheck');
        RETURN errnums.C_BIZ_RULE_INVALID;
    END IF;

    -- Check 1 TK dat lenh Bloomberg chi dc dang ky 1 lan
    SELECT count(*)
    INTO l_count
    FROM bl_register blr
    WHERE blr.blacctno = p_txmsg.txfields (c_blacctno).value AND blr.status = 'A';
    IF l_count > 0 THEN
        p_err_code := '-200603'; -- Invalid status
        plog.setendsection (pkgctx, 'fn_txAftAppCheck');
        RETURN errnums.C_BIZ_RULE_INVALID;
    END IF;

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
    -- Ghi nhan dang ky vao bang bl_register
    INSERT INTO bl_register (id,blacctno, afacctno,regdate, status,BLODTYPE,txdate,txnum)
    VALUES (bl_register_seq.nextval,p_txmsg.txfields (c_blacctno).value,p_txmsg.txfields (c_acctno).value, getcurrdate,'A','1/2/3',p_txmsg.txdate,p_txmsg.txnum);

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
         plog.init ('TXPKS_#0041EX',
                    plevel => NVL(logrow.loglevel,30),
                    plogtable => (NVL(logrow.log4table,'N') = 'Y'),
                    palert => (NVL(logrow.log4alert,'N') = 'Y'),
                    ptrace => (NVL(logrow.log4trace,'N') = 'Y')
            );
END TXPKS_#0041EX;
/
