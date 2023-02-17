SET DEFINE OFF;
CREATE OR REPLACE PACKAGE txpks_#6655ex
/**----------------------------------------------------------------------------------------------------
 ** Package: TXPKS_#6655EX
 ** and is copyrighted by FSS.
 **
 **    All rights reserved.  No part of this work may be reproduced, stored in a retrieval system,
 **    adopted or transmitted in any form or by any means, electronic, mechanical, photographic,
 **    graphic, optic recording or otherwise, translated in any language or computer language,
 **    without the prior written permission of Financial Software Solutions. JSC.
 **
 **  MODIFICATION HISTORY
 **  Person      Date           Comments
 **  System      17/02/2014     Created
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


CREATE OR REPLACE PACKAGE BODY txpks_#6655ex
IS
   pkgctx   plog.log_ctx;
   logrow   tlogdebug%ROWTYPE;

   c_reqid            CONSTANT CHAR(2) := '03';
   c_bankacct         CONSTANT CHAR(2) := '05';
   c_diraccname       CONSTANT CHAR(2) := '06';
   c_status           CONSTANT CHAR(2) := '40';
   c_dirbankcode      CONSTANT CHAR(2) := '07';
   c_dirbankname      CONSTANT CHAR(2) := '10';
   c_dirbankcity      CONSTANT CHAR(2) := '11';
   c_notes            CONSTANT CHAR(2) := '30';
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
     IF p_txmsg.deltd <> 'Y' THEN -- NORMAL transaction

        for rec in (
            select * from crbtxreq where REQID=p_txmsg.txfields('03').value
            )

        loop
             --INSERT BANG LOG
            INSERT INTO crbchangelog (REQID, TXDATE, TXNUM, FLDNAME, OLDVAL, NEWVAL, OBJTYPE, TLID)
                VALUES(p_txmsg.txfields('03').value, p_txmsg.txdate, p_txmsg.txnum, 'BANKACCT', rec.BANKACCT, p_txmsg.txfields('05').value,p_txmsg.tltxcd,p_txmsg.tlid);
            INSERT INTO crbchangelog (REQID, TXDATE, TXNUM, FLDNAME, OLDVAL, NEWVAL, OBJTYPE, TLID)
                VALUES(p_txmsg.txfields('03').value, p_txmsg.txdate, p_txmsg.txnum, 'DIRACCNAME', rec.DIRACCNAME, p_txmsg.txfields('06').value,p_txmsg.tltxcd,p_txmsg.tlid);
            INSERT INTO crbchangelog (REQID, TXDATE, TXNUM, FLDNAME, OLDVAL, NEWVAL, OBJTYPE, TLID)
                VALUES(p_txmsg.txfields('03').value, p_txmsg.txdate, p_txmsg.txnum, 'STATUS', rec.STATUS, p_txmsg.txfields('40').value,'TCDT_EDIT',p_txmsg.tlid);
            INSERT INTO crbchangelog (REQID, TXDATE, TXNUM, FLDNAME, OLDVAL, NEWVAL, OBJTYPE, TLID)
                VALUES(p_txmsg.txfields('03').value, p_txmsg.txdate, p_txmsg.txnum, 'DIRBANKCODE', rec.DIRBANKCODE, p_txmsg.txfields('07').value,p_txmsg.tltxcd,p_txmsg.tlid);
            INSERT INTO crbchangelog (REQID, TXDATE, TXNUM, FLDNAME, OLDVAL, NEWVAL, OBJTYPE, TLID)
                VALUES(p_txmsg.txfields('03').value, p_txmsg.txdate, p_txmsg.txnum, 'DIRBANKNAME', rec.DIRBANKNAME, p_txmsg.txfields('10').value,p_txmsg.tltxcd,p_txmsg.tlid);
            INSERT INTO crbchangelog (REQID, TXDATE, TXNUM, FLDNAME, OLDVAL, NEWVAL, OBJTYPE, TLID)
                VALUES(p_txmsg.txfields('03').value, p_txmsg.txdate, p_txmsg.txnum, 'DIRBANKCITY', rec.DIRBANKCITY, p_txmsg.txfields('11').value,p_txmsg.tltxcd,p_txmsg.tlid);

        end loop;


      UPDATE CRBTXREQ
      SET
           DIRBANKCODE=p_txmsg.txfields('07').value,
         PSTATUS=PSTATUS||STATUS,STATUS=p_txmsg.txfields('40').value,
           DIRBANKNAME=p_txmsg.txfields('10').value,
           BANKACCT=p_txmsg.txfields('05').value,
           DIRBANKCITY=p_txmsg.txfields('11').value,
           DIRACCNAME=p_txmsg.txfields('06').value
        WHERE REQID=p_txmsg.txfields('03').value;

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
         plog.init ('TXPKS_#6655EX',
                    plevel => NVL(logrow.loglevel,30),
                    plogtable => (NVL(logrow.log4table,'N') = 'Y'),
                    palert => (NVL(logrow.log4alert,'N') = 'Y'),
                    ptrace => (NVL(logrow.log4trace,'N') = 'Y')
            );
END TXPKS_#6655EX;

/
