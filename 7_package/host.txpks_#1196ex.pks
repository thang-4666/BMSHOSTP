SET DEFINE OFF;
CREATE OR REPLACE PACKAGE txpks_#1196ex
/**----------------------------------------------------------------------------------------------------
 ** Package: TXPKS_#1196EX
 ** and is copyrighted by FSS.
 **
 **    All rights reserved.  No part of this work may be reproduced, stored in a retrieval system,
 **    adopted or transmitted in any form or by any means, electronic, mechanical, photographic,
 **    graphic, optic recording or otherwise, translated in any language or computer language,
 **    without the prior written permission of Financial Software Solutions. JSC.
 **
 **  MODIFICATION HISTORY
 **  Person      Date           Comments
 **  System      20/03/2015     Created
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


CREATE OR REPLACE PACKAGE BODY txpks_#1196ex
IS
   pkgctx   plog.log_ctx;
   logrow   tlogdebug%ROWTYPE;

   c_custodycd        CONSTANT CHAR(2) := '82';
   c_autoid           CONSTANT CHAR(2) := '00';
   c_acctno           CONSTANT CHAR(2) := '03';
   c_custname         CONSTANT CHAR(2) := '90';
   c_address          CONSTANT CHAR(2) := '91';
   c_license          CONSTANT CHAR(2) := '92';
   c_iddate           CONSTANT CHAR(2) := '93';
   c_idplace          CONSTANT CHAR(2) := '94';
   c_bankid           CONSTANT CHAR(2) := '02';
   c_bankacctno       CONSTANT CHAR(2) := '05';
   c_glmast           CONSTANT CHAR(2) := '06';
   c_amt              CONSTANT CHAR(2) := '10';
   c_refnum           CONSTANT CHAR(2) := '31';
   c_desc             CONSTANT CHAR(2) := '30';
FUNCTION fn_txPreAppCheck(p_txmsg in tx.msg_rectype,p_err_code out varchar2)
RETURN NUMBER
IS
    l_count NUMBER(20);
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
    --CHECK trung so chung tu ngan hang voi cung ngay, cung ngan hang.
    --plog.error('1');
    plog.error(p_txmsg.busdate);
    if p_txmsg.txfields('31').value is not null or length(replace(p_txmsg.txfields('31').value,' ',''))>0 then
    --Neu chung tu khong bi Null thi kiem tra co bi trung ko
        SELECT count(1) INTO l_count FROM
        (
            SELECT * FROM tblcashdeposit WHERE deltd <> 'Y'
            UNION ALL
            SELECT th.* FROM tblcashdeposithist th, sysvar s
            WHERE busdate = p_txmsg.busdate AND deltd <> 'Y'
            AND s.grname = 'SYSTEM' AND s.varname = 'CURRDATE'
            AND th.txdate = to_date (s.varvalue,systemnums.c_date_format)
        )
        WHERE refnum = p_txmsg.txfields('31').value
        AND bankid = p_txmsg.txfields('02').value
        AND busdate = p_txmsg.busdate
        AND status = 'C';

        IF l_count <> 0 THEN
            p_err_code := '-400046'; -- double refnum.
            plog.setendsection (pkgctx, 'fn_txPreAppCheck');
            RETURN errnums.C_BIZ_RULE_INVALID;
        END IF;
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
BEGIN
    plog.setbeginsection (pkgctx, 'fn_txPreAppUpdate');
    plog.debug (pkgctx, '<<BEGIN OF fn_txPreAppUpdate');
   /***************************************************************************************************
    ** PUT YOUR SPECIFIC PROCESS HERE. . DO NOT COMMIT/ROLLBACK HERE, THE SYSTEM WILL DO IT
    ***************************************************************************************************/
    IF p_txmsg.deltd = 'Y' THEN
      SELECT COUNT(*) INTO l_Count
      FROM cimast
      WHERE ACCTNO=p_txmsg.txfields('03').value
      AND balance < ROUND(p_txmsg.txfields('10').value,0);
       IF l_count > 0 THEN
          p_err_code := '-400213';
          plog.setendsection (pkgctx, 'fn_txPreAppUpdate');
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
BEGIN
    plog.setbeginsection (pkgctx, 'fn_txAftAppUpdate');
    plog.debug (pkgctx, '<<BEGIN OF fn_txAftAppUpdate');
   /***************************************************************************************************
    ** PUT YOUR SPECIFIC AFTER PROCESS HERE. DO NOT COMMIT/ROLLBACK HERE, THE SYSTEM WILL DO IT
    ***************************************************************************************************/
    IF p_txmsg.deltd <> 'Y' THEN
        INSERT INTO tblcashdeposit (AUTOID,FILEID,BANKID,REFNUM,BUSDATE,CUSTODYCD,ACCTNO,AMT,DESCRIPTION,TXDATE,TLTXCD,TXNUM,STATUS,ERRORDESC,DELTD,LAST_CHANGE, BANKACCTNO,REFDATE)
        VALUES
        (   seq_tblcashdeposit.nextval,
            to_char(SYSDATE,'RRRRMMDD') || '0000',
            p_txmsg.txfields('02').value,
            p_txmsg.txfields('31').value,
            to_date(p_txmsg.busdate,systemnums.c_date_format),
            p_txmsg.txfields('82').value,
            p_txmsg.txfields('03').value,
            p_txmsg.txfields('10').value,
            p_txmsg.txfields('30').value,
            to_date(p_txmsg.txdate,systemnums.c_date_format),
            p_txmsg.tltxcd,
            p_txmsg.txnum,
            'C',
            NULL,
            'N',
            SYSTIMESTAMP,
            p_txmsg.txfields('05').value, TO_DATE(p_txmsg.txfields('32').value,systemnums.c_date_format));
        -- Insert lai~ moi' vao CIINTTRAN
        if to_date(p_txmsg.busdate,systemnums.c_date_format) < to_date(p_txmsg.txdate,systemnums.c_date_format) then
            cspks_ciproc.pr_CalBackdateFeeAmt(p_txmsg.busdate, p_txmsg.txfields('03').value, p_txmsg.txfields('10').value, p_err_code);
            if p_err_code <> 0 then
                p_err_code := '-400050';
                plog.setendsection (pkgctx, 'fn_txAftAppUpdate');
                RETURN errnums.C_BIZ_RULE_INVALID;
            end if;
        end if;

        Update crbbankrequest Set Status = 'M'
        Where trnref = p_txmsg.txfields('31').value
            And TRN_DT = p_txmsg.txfields('32').value
            And Status = 'B';

    ELSE
        UPDATE tblcashdeposit
        SET deltd = 'Y'
        WHERE txdate = to_date(p_txmsg.txdate,systemnums.c_date_format)
        AND txnum = p_txmsg.txnum
        AND refnum = p_txmsg.txfields('31').value
        AND bankid = p_txmsg.txfields('02').value
        AND fileid = to_char(SYSDATE,'RRRRMMDD') || '0000';
        -- Insert lai~ moi' vao CIINTTRAN
        if to_date(p_txmsg.busdate,systemnums.c_date_format) < to_date(p_txmsg.txdate,systemnums.c_date_format) then
            cspks_ciproc.pr_CalBackdateFeeAmt(p_txmsg.busdate, -p_txmsg.txfields('03').value, p_txmsg.txfields('10').value, p_err_code);
            if p_err_code <> 0 then
                p_err_code := '-400050';
                plog.setendsection (pkgctx, 'fn_txAftAppUpdate');
                RETURN errnums.C_BIZ_RULE_INVALID;
            end if;
        end if;
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
         plog.init ('TXPKS_#1196EX',
                    plevel => NVL(logrow.loglevel,30),
                    plogtable => (NVL(logrow.log4table,'N') = 'Y'),
                    palert => (NVL(logrow.log4alert,'N') = 'Y'),
                    ptrace => (NVL(logrow.log4trace,'N') = 'Y')
            );
END TXPKS_#1196EX;
/
