SET DEFINE OFF;
CREATE OR REPLACE PACKAGE txpks_#6638ex
/**----------------------------------------------------------------------------------------------------
 ** Package: TXPKS_#6638EX
 ** and is copyrighted by FSS.
 **
 **    All rights reserved.  No part of this work may be reproduced, stored in a retrieval system,
 **    adopted or transmitted in any form or by any means, electronic, mechanical, photographic,
 **    graphic, optic recording or otherwise, translated in any language or computer language,
 **    without the prior written permission of Financial Software Solutions. JSC.
 **
 **  MODIFICATION HISTORY
 **  Person      Date           Comments
 **  System      04/07/2021     Created
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


CREATE OR REPLACE PACKAGE BODY txpks_#6638ex
IS
   pkgctx   plog.log_ctx;
   logrow   tlogdebug%ROWTYPE;

   c_reqid            CONSTANT CHAR(2) := '01';
   c_trdcode          CONSTANT CHAR(2) := '02';
   c_txnum            CONSTANT CHAR(2) := '03';
   c_txdate           CONSTANT CHAR(2) := '04';
   c_custodycd        CONSTANT CHAR(2) := '05';
   c_custname         CONSTANT CHAR(2) := '06';
   c_afacctno         CONSTANT CHAR(2) := '07';
   c_codeid           CONSTANT CHAR(2) := '08';
   c_qtty             CONSTANT CHAR(2) := '09';
   c_txid             CONSTANT CHAR(2) := '10';
   c_msgstatus        CONSTANT CHAR(2) := '11';
   c_vsdreqtxsts      CONSTANT CHAR(2) := '12';
   c_isautocomfirm    CONSTANT CHAR(2) := '13';
   c_desc             CONSTANT CHAR(2) := '30';
FUNCTION fn_txPreAppCheck(p_txmsg in tx.msg_rectype,p_err_code out varchar2)
RETURN NUMBER
IS
    v_tltxcd       vsdtxreq.objname%TYPE;
    v_reqmsgsts    vsdtxreq.msgstatus%TYPE;
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
    IF p_txmsg.deltd <> 'Y' THEN
        -- Kiem tra trang thai dien
        SELECT msgstatus INTO v_reqmsgsts
        FROM vsdtxreq WHERE reqid = p_txmsg.txfields(c_reqid).value;

        IF v_reqmsgsts NOT IN ('P', 'S', 'C', 'A') THEN
           p_err_code := '-300081'; -- Pre-defined in DEFERROR table
           plog.error(pkgctx,'Error: p_err_code='||p_err_code||', reqid='||p_txmsg.txfields(c_reqid).value||', v_reqmsgsts='||v_reqmsgsts);
           plog.setendsection (pkgctx, 'fn_txPreAppCheck');
           RETURN errnums.C_BIZ_RULE_INVALID;
        END IF;

        SELECT objname INTO v_tltxcd FROM vsdtxreq WHERE reqid = p_txmsg.txfields(c_reqid).value;

        -- Khong cho phep doi trang thai hoan tat voi GD 2245
        IF v_tltxcd = '2295' AND p_txmsg.txfields(c_vsdreqtxsts).value <> 'R' THEN
           p_err_code := '-670101'; -- Pre-defined in DEFERROR table
           plog.error(pkgctx,'Error: p_err_code='||p_err_code||', reqid='||p_txmsg.txfields(c_reqid).value||', v_tltxcd='||v_tltxcd||', v_reqmsgsts='||p_txmsg.txfields(c_vsdreqtxsts).value);
           plog.setendsection (pkgctx, 'fn_txPreAppCheck');
           RETURN errnums.C_BIZ_RULE_INVALID;
        END IF;
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
    v_tltxcd   vsdtxreq.objname%TYPE;
    v_errcode  vsdtxreq.boprocess_err%TYPE;
BEGIN
    plog.setbeginsection (pkgctx, 'fn_txAftAppUpdate');
    plog.debug (pkgctx, '<<BEGIN OF fn_txAftAppUpdate');
   /***************************************************************************************************
    ** PUT YOUR SPECIFIC AFTER PROCESS HERE. DO NOT COMMIT/ROLLBACK HERE, THE SYSTEM WILL DO IT
    ***************************************************************************************************/
    IF p_txmsg.deltd <> 'Y' THEN
        SELECT tltxcd INTO v_tltxcd
         FROM (SELECT distinct trf.tltxcd, CASE WHEN trf.type in ('CFO') THEN 'F' ELSE 'R' END STATUS
            FROM vsdtrfcode trf, vsdtxreq req
            WHERE req.reqid = p_txmsg.txfields(c_reqid).value
              AND trf.status = 'Y'
              AND nvl(req.objname, 'a') = nvl(trf.reqtltxcd, 'a')
              AND trf.type in ('CFO','CFN','NAK'))
         WHERE STATUS=p_txmsg.txfields(c_vsdreqtxsts).value;

        IF p_txmsg.txfields(c_isautocomfirm).value = 'N' THEN
           -- Cap nhat trang thai dien
           UPDATE vsdtxreq SET msgstatus = p_txmsg.txfields(c_vsdreqtxsts).value,
                               status = decode(p_txmsg.txfields(c_vsdreqtxsts).value, 'R', 'R', 'C')
           WHERE reqid = p_txmsg.txfields(c_reqid).value;
        ELSE
           BEGIN
              SELECT nvl(boprocess_err, '-670073') INTO v_errcode
              FROM vsdtxreq
              WHERE status = 'E' AND reqid = p_txmsg.txfields(c_reqid).value;
           EXCEPTION WHEN OTHERS THEN
              NULL;
           END;

           IF v_errcode IS NOT NULL THEN
              p_err_code := v_errcode; -- Pre-defined in DEFERROR table
              plog.error(pkgctx,'Error from v_errcode: p_err_code='||p_err_code||', reqid='||p_txmsg.txfields(c_reqid).value);
              plog.setendsection (pkgctx, 'fn_txAftAppUpdate');
              RETURN errnums.C_BIZ_RULE_INVALID;
           END IF;
           -- tu dong goi giao dich
           cspks_vsd.auto_complete_confirm_msg(p_txmsg.txfields(c_reqid).value,v_tltxcd,NULL,p_err_code);

           IF p_err_code IS NOT NULL THEN
             p_err_code := p_err_code; -- Pre-defined in DEFERROR table
             plog.error(pkgctx,'Error call cspks_vsd.auto_complete_confirm_msg: p_err_code='||p_err_code||', reqid='||p_txmsg.txfields(c_reqid).value||', tltxcd='||v_tltxcd);
             plog.setendsection (pkgctx, 'fn_txAftAppUpdate');
             RETURN errnums.C_BIZ_RULE_INVALID;
           ELSE

           UPDATE vsdtxreq SET msgstatus = p_txmsg.txfields(c_vsdreqtxsts).value,
                               status = CASE WHEN p_txmsg.txfields(c_vsdreqtxsts).value='R' THEN 'R' ELSE 'C' END
                    WHERE reqid = p_txmsg.txfields(c_reqid).value;
           END IF;
        END IF;
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
         plog.init ('TXPKS_#6638EX',
                    plevel => NVL(logrow.loglevel,30),
                    plogtable => (NVL(logrow.log4table,'N') = 'Y'),
                    palert => (NVL(logrow.log4alert,'N') = 'Y'),
                    ptrace => (NVL(logrow.log4trace,'N') = 'Y')
            );
END TXPKS_#6638EX;
/
