SET DEFINE OFF;
CREATE OR REPLACE PACKAGE txpks_#3389ex
/**----------------------------------------------------------------------------------------------------
 ** Package: TXPKS_#3389EX
 ** and is copyrighted by FSS.
 **
 **    All rights reserved.  No part of this work may be reproduced, stored in a retrieval system,
 **    adopted or transmitted in any form or by any means, electronic, mechanical, photographic,
 **    graphic, optic recording or otherwise, translated in any language or computer language,
 **    without the prior written permission of Financial Software Solutions. JSC.
 **
 **  MODIFICATION HISTORY
 **  Person      Date           Comments
 **  System      25/10/2012     Created
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


CREATE OR REPLACE PACKAGE BODY txpks_#3389ex
IS
   pkgctx   plog.log_ctx;
   logrow   tlogdebug%ROWTYPE;

   c_camastid         CONSTANT CHAR(2) := '03';
   c_symbol           CONSTANT CHAR(2) := '04';
   c_catype           CONSTANT CHAR(2) := '05';
   c_isrightoff       CONSTANT CHAR(2) := '14';
   c_catypeval        CONSTANT CHAR(2) := '13';
   c_codeid           CONSTANT CHAR(2) := '22';
   c_reportdate       CONSTANT CHAR(2) := '09';
   c_begindate        CONSTANT CHAR(2) := '12';
   c_duedate          CONSTANT CHAR(2) := '06';
   c_frdatetransfer   CONSTANT CHAR(2) := '07';
   c_todatetransfer   CONSTANT CHAR(2) := '08';
   c_rate             CONSTANT CHAR(2) := '11';
   c_status           CONSTANT CHAR(2) := '20';
   c_actiondate       CONSTANT CHAR(2) := '10';
   c_trade            CONSTANT CHAR(2) := '23';
   c_begindateold     CONSTANT CHAR(2) := '45';
   c_duedateold       CONSTANT CHAR(2) := '46';
   c_frdatetransferold   CONSTANT CHAR(2) := '47';
   c_desc             CONSTANT CHAR(2) := '30';
   c_todatetransferold   CONSTANT CHAR(2) := '48';
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


   IF p_txmsg.deltd <> 'Y' THEN
    plog.error (pkgctx, 'TEST11'||p_txmsg.txfields('06').value);
    plog.error (pkgctx, 'TEST12'||p_txmsg.txfields('12').value);
    plog.error (pkgctx, 'TEST03'||p_txmsg.txfields('03').value);
   UPDATE CAMAST
      SET
           DUEDATE= to_date(p_txmsg.txfields('06').value,'DD/MM/YYYY'),
           BEGINDATE=to_date(p_txmsg.txfields('12').value,'DD/MM/YYYY'), LAST_CHANGE = SYSTIMESTAMP
        WHERE CAMASTID=p_txmsg.txfields('03').value;

      INSERT INTO CATRAN(TXNUM,TXDATE,ACCTNO,TXCD,NAMT,CAMT,DELTD,REF,AUTOID,TLTXCD,BKDATE,TRDESC)
      VALUES (p_txmsg.txnum, TO_DATE (p_txmsg.txdate, systemnums.C_DATE_FORMAT),p_txmsg.txfields ('03').value,'0034',0,p_txmsg.txfields ('12').value,p_txmsg.deltd,p_txmsg.txfields ('45').value,seq_CATRAN.NEXTVAL,p_txmsg.tltxcd,p_txmsg.busdate,'' || '' || '');


      INSERT INTO CATRAN(TXNUM,TXDATE,ACCTNO,TXCD,NAMT,CAMT,DELTD,REF,AUTOID,TLTXCD,BKDATE,TRDESC)
      VALUES (p_txmsg.txnum, TO_DATE (p_txmsg.txdate, systemnums.C_DATE_FORMAT),p_txmsg.txfields ('03').value,'0038',0,p_txmsg.txfields ('06').value,p_txmsg.deltd,p_txmsg.txfields ('46').value,seq_CATRAN.NEXTVAL,p_txmsg.tltxcd,p_txmsg.busdate,'' || '' || '');


    IF to_char(p_txmsg.txfields('14').value) <> '0' THEN
      UPDATE CAMAST
      SET
           TODATETRANSFER= to_date(p_txmsg.txfields('08').value,'DD/MM/YYYY'),
           FRDATETRANSFER= to_date(p_txmsg.txfields('07').value,'DD/MM/YYYY'), LAST_CHANGE = SYSTIMESTAMP
        WHERE CAMASTID=p_txmsg.txfields('03').value;

     INSERT INTO CATRAN(TXNUM,TXDATE,ACCTNO,TXCD,NAMT,CAMT,DELTD,REF,AUTOID,TLTXCD,BKDATE,TRDESC)
      VALUES (p_txmsg.txnum, TO_DATE (p_txmsg.txdate, systemnums.C_DATE_FORMAT),p_txmsg.txfields ('03').value,'0035',0,p_txmsg.txfields ('07').value,p_txmsg.deltd,p_txmsg.txfields ('47').value,seq_CATRAN.NEXTVAL,p_txmsg.tltxcd,p_txmsg.busdate,'' || '' || '');


      INSERT INTO CATRAN(TXNUM,TXDATE,ACCTNO,TXCD,NAMT,CAMT,DELTD,REF,AUTOID,TLTXCD,BKDATE,TRDESC)
      VALUES (p_txmsg.txnum, TO_DATE (p_txmsg.txdate, systemnums.C_DATE_FORMAT),p_txmsg.txfields ('03').value,'0036',0,p_txmsg.txfields ('08').value,p_txmsg.deltd,p_txmsg.txfields ('48').value,seq_CATRAN.NEXTVAL,p_txmsg.tltxcd,p_txmsg.busdate,'' || '' || '');

    END IF;
    ---goi ham gui email, sms
		nmpks_ems.GenTemplate0223(p_txmsg.txfields('03').value,p_txmsg.txfields('45').value,p_txmsg.txfields('46').value,p_txmsg.txfields('47').value,p_txmsg.txfields('48').value);
		-------------------------------
 ELSE

UPDATE TLLOG
 SET DELTD = 'Y'
      WHERE TXNUM = p_txmsg.txnum AND TXDATE = TO_DATE(p_txmsg.txdate, systemnums.C_DATE_FORMAT);
      UPDATE CAMAST
      SET
           DUEDATE=p_txmsg.txfields('06').value,
           BEGINDATE=p_txmsg.txfields('12').value, LAST_CHANGE = SYSTIMESTAMP
        WHERE CAMASTID=p_txmsg.txfields('03').value;

    IF to_char(p_txmsg.txfields('14').value) <> '0' THEN
      UPDATE CAMAST
      SET
           TODATETRANSFER=p_txmsg.txfields('08').value,
           FRDATETRANSFER=p_txmsg.txfields('07').value, LAST_CHANGE = SYSTIMESTAMP
        WHERE CAMASTID=p_txmsg.txfields('03').value;
    END IF;
   END IF;


--   END IF;

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
         plog.init ('TXPKS_#3389EX',
                    plevel => NVL(logrow.loglevel,30),
                    plogtable => (NVL(logrow.log4table,'N') = 'Y'),
                    palert => (NVL(logrow.log4alert,'N') = 'Y'),
                    ptrace => (NVL(logrow.log4trace,'N') = 'Y')
            );
END TXPKS_#3389EX;

/
