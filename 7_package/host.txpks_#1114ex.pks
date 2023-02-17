SET DEFINE OFF;
CREATE OR REPLACE PACKAGE txpks_#1114ex
/**----------------------------------------------------------------------------------------------------
 ** Package: TXPKS_#1114EX
 ** and is copyrighted by FSS.
 **
 **    All rights reserved.  No part of this work may be reproduced, stored in a retrieval system,
 **    adopted or transmitted in any form or by any means, electronic, mechanical, photographic,
 **    graphic, optic recording or otherwise, translated in any language or computer language,
 **    without the prior written permission of Financial Software Solutions. JSC.
 **
 **  MODIFICATION HISTORY
 **  Person      Date           Comments
 **  System      19/07/2014     Created
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


CREATE OR REPLACE PACKAGE BODY txpks_#1114ex
IS
   pkgctx   plog.log_ctx;
   logrow   tlogdebug%ROWTYPE;

   c_txdate           CONSTANT CHAR(2) := '06';
   c_acctno           CONSTANT CHAR(2) := '03';
   c_custname         CONSTANT CHAR(2) := '90';
   c_address          CONSTANT CHAR(2) := '91';
   c_license          CONSTANT CHAR(2) := '92';
   c_bankid           CONSTANT CHAR(2) := '05';
   c_benefbank        CONSTANT CHAR(2) := '80';
   c_benefcustname    CONSTANT CHAR(2) := '82';
   c_benefacct        CONSTANT CHAR(2) := '81';
   c_citybank         CONSTANT CHAR(2) := '84';
   c_cityef           CONSTANT CHAR(2) := '85';
   c_ioro             CONSTANT CHAR(2) := '09';
   c_amt              CONSTANT CHAR(2) := '10';
   c_vatamt           CONSTANT CHAR(2) := '12';
   c_feeamt           CONSTANT CHAR(2) := '11';
   c_txnum            CONSTANT CHAR(2) := '07';
   c_refkey           CONSTANT CHAR(2) := '67';
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
v_cistatus varchar2(1);
v_crbstatus varchar2(1);
BEGIN
    plog.setbeginsection (pkgctx, 'fn_txPreAppUpdate');
    plog.debug (pkgctx, '<<BEGIN OF fn_txPreAppUpdate');
   /***************************************************************************************************
    ** PUT YOUR SPECIFIC PROCESS HERE. . DO NOT COMMIT/ROLLBACK HERE, THE SYSTEM WILL DO IT
    ***************************************************************************************************/
    --Check trang thai truoc khi huy
    begin
        select rmstatus into v_cistatus from CIREMITTANCE
        where TXDATE=TO_DATE(p_txmsg.txfields('06').value,'dd/mm/rrrr') AND TXNUM= p_txmsg.txfields('07').value ;
    EXCEPTION
    WHEN OTHERS
       THEN
       v_cistatus := '';
    end;

    begin
        select status into v_crbstatus from CRBTXREQ
        where TXDATE=TO_DATE(p_txmsg.txfields('06').value,'dd/mm/rrrr') AND OBJKEY=p_txmsg.txfields('07').value ;
    EXCEPTION
    WHEN OTHERS
       THEN
       v_crbstatus := '';
    end;

    IF v_cistatus='R' or v_crbstatus='R' THEN
        p_err_code := '-400201';
        plog.setendsection (pkgctx, 'fn_txAppAutoCheck');
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
BEGIN
    plog.setbeginsection (pkgctx, 'fn_txAftAppUpdate');
    plog.debug (pkgctx, '<<BEGIN OF fn_txAftAppUpdate');
   /***************************************************************************************************
    ** PUT YOUR SPECIFIC AFTER PROCESS HERE. DO NOT COMMIT/ROLLBACK HERE, THE SYSTEM WILL DO IT
    ***************************************************************************************************/

    IF p_txmsg.deltd <> 'Y' THEN

        UPDATE CIREMITTANCE SET RMSTATUS='R' WHERE TXDATE=TO_DATE(p_txmsg.txfields('06').value,'dd/mm/rrrr') AND TXNUM= p_txmsg.txfields('07').value ;
        UPDATE CRBTXREQ SET STATUS='R' WHERE TXDATE=TO_DATE(p_txmsg.txfields('06').value,'dd/mm/rrrr') AND OBJKEY=p_txmsg.txfields('07').value ;

        -- HaiLT them Insert lai~ moi' vao CIINTTRAN, gd tang tien nen + so tien
        if to_date(p_txmsg.busdate,systemnums.c_date_format) < to_date(p_txmsg.txdate,systemnums.c_date_format) then
            cspks_ciproc.pr_CalBackdateFeeAmt(p_txmsg.busdate, p_txmsg.txfields('03').value, p_txmsg.txfields('10').value, p_err_code);
            if p_err_code <> 0 then
                p_err_code := '-400050';
                RETURN errnums.C_BIZ_RULE_INVALID;
            end if;

        end if;
    else

        UPDATE CIREMITTANCE SET RMSTATUS='P' WHERE TXDATE=TO_DATE(p_txmsg.txfields('06').value,'dd/mm/rrrr') AND TXNUM= p_txmsg.txfields('07').value ;
        UPDATE CRBTXREQ SET STATUS='P' WHERE TXDATE=TO_DATE(p_txmsg.txfields('06').value,'dd/mm/rrrr') AND OBJKEY=p_txmsg.txfields('07').value ;

        -- HaiLT them Insert lai~ moi' vao CIINTTRAN, gd xoa nen - so tien
        if to_date(p_txmsg.busdate,systemnums.c_date_format) < to_date(p_txmsg.txdate,systemnums.c_date_format) then
            cspks_ciproc.pr_CalBackdateFeeAmt(p_txmsg.busdate, p_txmsg.txfields('03').value, -p_txmsg.txfields('10').value, p_err_code);
            if p_err_code <> 0 then
                p_err_code := '-400050';
                RETURN errnums.C_BIZ_RULE_INVALID;
            end if;

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
         plog.init ('TXPKS_#1114EX',
                    plevel => NVL(logrow.loglevel,30),
                    plogtable => (NVL(logrow.log4table,'N') = 'Y'),
                    palert => (NVL(logrow.log4alert,'N') = 'Y'),
                    ptrace => (NVL(logrow.log4trace,'N') = 'Y')
            );
END TXPKS_#1114EX;
/
