SET DEFINE OFF;
CREATE OR REPLACE PACKAGE txpks_#1112ex
/**----------------------------------------------------------------------------------------------------
 ** Package: TXPKS_#1112EX
 ** and is copyrighted by FSS.
 **
 **    All rights reserved.  No part of this work may be reproduced, stored in a retrieval system,
 **    adopted or transmitted in any form or by any means, electronic, mechanical, photographic,
 **    graphic, optic recording or otherwise, translated in any language or computer language,
 **    without the prior written permission of Financial Software Solutions. JSC.
 **
 **  MODIFICATION HISTORY
 **  Person      Date           Comments
 **  System      20/07/2010     Created
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


CREATE OR REPLACE PACKAGE BODY txpks_#1112ex
IS
   pkgctx   plog.log_ctx;
   logrow   tlogdebug%ROWTYPE;

   c_txdate           CONSTANT CHAR(2) := '06';
   c_txnum            CONSTANT CHAR(2) := '07';
   c_amt              CONSTANT CHAR(2) := '10';
   c_desc             CONSTANT CHAR(2) := '30';
FUNCTION fn_txPreAppCheck(p_txmsg in tx.msg_rectype,p_err_code out varchar2)
RETURN NUMBER
IS
   l_STATUS varchar(10);
BEGIN
   plog.setbeginsection (pkgctx, 'fn_txPreAppCheck');
   plog.debug(pkgctx,'BEGIN OF fn_txPreAppCheck');

   SELECT NVL(STATUS,'') INTO l_STATUS FROM POMAST WHERE TXNUM=p_txmsg.txfields('07').VALUE;

   IF p_txmsg.deltd = 'N' THEN
         IF NOT ( INSTR('A',l_STATUS) > 0) THEN
            p_err_code := '-400201';
            RETURN errnums.C_BIZ_RULE_INVALID;
         END IF;
   END IF;
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
      plog.error (pkgctx, SQLERRM);
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
      plog.error (pkgctx, SQLERRM);
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
      plog.error (pkgctx, SQLERRM);
       plog.setendsection (pkgctx, 'fn_txPreAppUpdate');
      RAISE errnums.E_SYSTEM_ERROR;
END fn_txPreAppUpdate;

FUNCTION fn_txAftAppUpdate(p_txmsg in tx.msg_rectype,p_err_code out varchar2)
RETURN NUMBER
IS
       v_POTXNUM  VARCHAR2(10);
       v_POTXDATE DATE;
BEGIN
    plog.setbeginsection (pkgctx, 'fn_txAftAppUpdate');
    plog.debug (pkgctx, '<<BEGIN OF fn_txAftAppUpdate');
   /***************************************************************************************************
    ** PUT YOUR SPECIFIC AFTER PROCESS HERE. DO NOT COMMIT/ROLLBACK HERE, THE SYSTEM WILL DO IT
    ***************************************************************************************************/
    -- 07 : POTXNUM
    v_POTXNUM := p_txmsg.txfields('07').VALUE;
    -- 06 : POTXDATE
    v_POTXDATE := TO_DATE(p_txmsg.txfields('06').VALUE,systemnums.C_DATE_FORMAT);

    IF p_txmsg.deltd <> 'Y' THEN

       BEGIN
            FOR rec IN
            (
                SELECT TL.TXNUM, TL.TXDATE, TR.ACCTNO, TR.NAMT
                FROM TLLOG TL, TLLOGFLD TLF, CITRAN TR, APPTX A
                WHERE TL.TXNUM=TLF.TXNUM AND TL.TXDATE=TLF.TXDATE
                      AND TL.TXNUM=TR.TXNUM AND TL.TXDATE=TR.TXDATE
                      AND TR.TXCD=A.TXCD AND A.FIELD='FLOATAMT'
                      AND TLF.CVALUE=v_POTXNUM
            )
           LOOP
                -- CAP NHAT TLLOG
                UPDATE TLLOG SET DELTD ='Y' WHERE TXNUM=REC.TXNUM;
                -- CAP NHAT CITRAN
                UPDATE CITRAN SET DELTD='Y' WHERE TXNUM=REC.TXNUM;
                -- UPDATE FLOATAMT TRONG CIMAST
                UPDATE CIMAST SET FLOATAMT=FLOATAMT+REC.NAMT WHERE ACCTNO=REC.ACCTNO;

           END LOOP;

           -- CAP NHAT LAI POMAST LA TU CHOI
           UPDATE POMAST SET DELTD='Y', STATUS='R' WHERE POMAST.TXDATE=v_POTXDATE AND POMAST.TXNUM=v_POTXNUM;
           -- CHUYEN CIREMITTANCE VE PENDING
           UPDATE CIREMITTANCE CI SET CI.RMSTATUS='P' WHERE CI.POTXNUM=v_POTXNUM AND CI.POTXDATE=v_POTXDATE;
       END;
    ELSE

       BEGIN
            FOR rec IN
            (
                SELECT TL.TXNUM, TL.TXDATE, TR.ACCTNO, TR.NAMT
                FROM TLLOG TL, TLLOGFLD TLF, CITRAN TR, APPTX A
                WHERE TL.TXNUM=TLF.TXNUM AND TL.TXDATE=TLF.TXDATE
                      AND TL.TXNUM=TR.TXNUM AND TL.TXDATE=TR.TXDATE
                      AND TR.TXCD=A.TXCD AND A.FIELD='FLOATAMT'
                      AND TLF.CVALUE=v_POTXNUM
            )
           LOOP
                -- CAP NHAT TLLOG
                UPDATE TLLOG SET DELTD ='N' WHERE TXNUM=REC.TXNUM;
                -- CAP NHAT CITRAN
                UPDATE CITRAN SET DELTD='N' WHERE TXNUM=REC.TXNUM;
                -- UPDATE FLOATAMT TRONG CIMAST
                UPDATE CIMAST SET FLOATAMT=FLOATAMT-REC.NAMT WHERE ACCTNO=REC.ACCTNO;

           END LOOP;

           -- CAP NHAT LAI POMAST LA TU CHOI
           UPDATE POMAST SET DELTD='N', STATUS='A' WHERE POMAST.TXDATE=v_POTXDATE AND POMAST.TXNUM=v_POTXNUM;
           -- CHUYEN CIREMITTANCE VE PENDING
           UPDATE CIREMITTANCE CI SET CI.RMSTATUS='C' WHERE CI.POTXNUM=v_POTXNUM AND CI.POTXDATE=v_POTXDATE;

       END;
    END IF;

    plog.debug (pkgctx, '<<END OF fn_txAftAppUpdate');
    plog.setendsection (pkgctx, 'fn_txAftAppUpdate');
    RETURN systemnums.C_SUCCESS;
EXCEPTION
WHEN OTHERS
   THEN
      p_err_code := errnums.C_SYSTEM_ERROR;
      plog.error (pkgctx, SQLERRM);
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
         plog.init ('TXPKS_#1112EX',
                    plevel => NVL(logrow.loglevel,30),
                    plogtable => (NVL(logrow.log4table,'N') = 'Y'),
                    palert => (NVL(logrow.log4alert,'N') = 'Y'),
                    ptrace => (NVL(logrow.log4trace,'N') = 'Y')
            );
END TXPKS_#1112EX;

/
