SET DEFINE OFF;
CREATE OR REPLACE PACKAGE txpks_#8811ex
/**----------------------------------------------------------------------------------------------------
 ** Package: TXPKS_#8811EX
 ** and is copyrighted by FSS.
 **
 **    All rights reserved.  No part of this work may be reproduced, stored in a retrieval system,
 **    adopted or transmitted in any form or by any means, electronic, mechanical, photographic,
 **    graphic, optic recording or otherwise, translated in any language or computer language,
 **    without the prior written permission of Financial Software Solutions. JSC.
 **
 **  MODIFICATION HISTORY
 **  Person      Date           Comments
 **  System      17/04/2012     Created
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


CREATE OR REPLACE PACKAGE BODY txpks_#8811ex
IS
   pkgctx   plog.log_ctx;
   logrow   tlogdebug%ROWTYPE;

   c_orgorderid       CONSTANT CHAR(2) := '03';
   c_codeid           CONSTANT CHAR(2) := '80';
   c_exorstatus       CONSTANT CHAR(2) := '15';
   c_symbol           CONSTANT CHAR(2) := '81';
   c_custodycd        CONSTANT CHAR(2) := '82';
   c_ciacctno         CONSTANT CHAR(2) := '05';
   c_seacctno         CONSTANT CHAR(2) := '06';
   c_afacctno         CONSTANT CHAR(2) := '07';
   c_avlcancelqtty    CONSTANT CHAR(2) := '10';
   c_avlcancelamt     CONSTANT CHAR(2) := '11';
   c_parvalue         CONSTANT CHAR(2) := '12';
   c_exprice          CONSTANT CHAR(2) := '13';
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
    IF cspks_odproc.fn_OD_ClearOrder(p_txmsg,p_err_code) <> systemnums.C_SUCCESS THEN
        RETURN errnums.C_BIZ_RULE_INVALID;
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
v_dblAVLCANCELQTTY NUMBER(20,4);
v_strORGORDERID VARCHAR2(20);

v_blnReversal boolean;
v_strAFACCTNO varchar2(20);
v_strCOREBANK char(1);
v_strALTERNATEACCT char(1);
BEGIN
    plog.setbeginsection (pkgctx, 'fn_txAftAppUpdate');
    plog.debug (pkgctx, '<<BEGIN OF fn_txAftAppUpdate');
   /***************************************************************************************************
    ** PUT YOUR SPECIFIC AFTER PROCESS HERE. DO NOT COMMIT/ROLLBACK HERE, THE SYSTEM WILL DO IT
    ***************************************************************************************************/
    /*v_strORGORDERID:=p_txmsg.txfields ('03').VALUE;
    v_dblAVLCANCELQTTY:=TO_NUMBER(p_txmsg.txfields ('10').VALUE);

    cspks_odproc.pr_RM_UnholdCancelOD( v_strORGORDERID ,v_dblAVLCANCELQTTY ,p_err_code) ;
    if p_err_code <> '0' then
        plog.error (pkgctx, 'Loi khi thuc hien Unhold 6600 p_err_code=' || p_err_code);
        plog.setendsection (pkgctx, 'fn_OD_ClearOrder');
        RETURN errnums.C_BIZ_RULE_INVALID;
    end if;*/
    if p_txmsg.deltd='Y' then
        v_blnReversal:=true;
    else
        v_blnReversal:=false;
    end if;
    v_strAFACCTNO:=p_txmsg.txfields ('05').VALUE;
    If Not v_blnREVERSAL Then
       SELECT af.corebank ,af.alternateacct INTO v_strCOREBANK, v_strALTERNATEACCT FROM AFMAST af WHERE ACCTNO=v_strAFACCTNO;
       IF v_strCOREBANK='Y' THEN
           --Unhold thuan tuy tai khoan corebank
           BEGIN
               v_strORGORDERID:=p_txmsg.txfields ('03').VALUE;
               v_dblAVLCANCELQTTY:=TO_NUMBER(p_txmsg.txfields ('10').VALUE);
               plog.debug(pkgctx,'Begin call pr_RM_UnholdCancelOD');
               cspks_odproc.pr_RM_UnholdCancelOD( v_strORGORDERID ,v_dblAVLCANCELQTTY ,p_err_code) ;
               plog.debug(pkgctx,'End call pr_RM_UnholdCancelOD, Return error code : ' || p_err_code);
           END;
       elsif v_strALTERNATEACCT ='Y' then
           --Unhold thuan tai khoan co tai khoan phu corebank
           BEGIN
               plog.debug(pkgctx,'Begin call pr_RM_UnholdAccount');
               cspks_rmproc.pr_RM_UnholdAccount(v_strAFACCTNO,p_err_code);
               plog.debug(pkgctx,'End call pr_RM_UnholdAccount, Return error code : ' || p_err_code);
           END;
       END IF;
       if p_err_code <> '0' then
            plog.error (pkgctx, 'Loi khi thuc hien Unhold 6600 p_err_code=' || p_err_code);
            plog.setendsection (pkgctx, 'fn_OD_ClearOrder');
            RETURN errnums.C_BIZ_RULE_INVALID;
       end if;
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
         plog.init ('TXPKS_#8811EX',
                    plevel => NVL(logrow.loglevel,30),
                    plogtable => (NVL(logrow.log4table,'N') = 'Y'),
                    palert => (NVL(logrow.log4alert,'N') = 'Y'),
                    ptrace => (NVL(logrow.log4trace,'N') = 'Y')
            );
END TXPKS_#8811EX;

/
