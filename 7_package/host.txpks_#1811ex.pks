SET DEFINE OFF;
CREATE OR REPLACE PACKAGE txpks_#1811ex
/**----------------------------------------------------------------------------------------------------
 ** Package: TXPKS_#1811EX
 ** and is copyrighted by FSS.
 **
 **    All rights reserved.  No part of this work may be reproduced, stored in a retrieval system,
 **    adopted or transmitted in any form or by any means, electronic, mechanical, photographic,
 **    graphic, optic recording or otherwise, translated in any language or computer language,
 **    without the prior written permission of Financial Software Solutions. JSC.
 **
 **  MODIFICATION HISTORY
 **  Person      Date           Comments
 **  System      28/07/2010     Created
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


CREATE OR REPLACE PACKAGE BODY txpks_#1811ex
IS
   pkgctx   plog.log_ctx;
   logrow   tlogdebug%ROWTYPE;

   c_userid           CONSTANT CHAR(2) := '01';
   c_acctno           CONSTANT CHAR(2) := '03';
   c_advt0amt         CONSTANT CHAR(2) := '08';
   c_advt0amt         CONSTANT CHAR(2) := '09';
   c_advamthist       CONSTANT CHAR(2) := '11';
   c_advamthist       CONSTANT CHAR(2) := '10';
   c_desc             CONSTANT CHAR(2) := '30';
FUNCTION fn_txPreAppCheck(p_txmsg in tx.msg_rectype,p_err_code out varchar2)
RETURN NUMBER
IS
       l_ADVT0AMT NUMBER(30);
       l_ADVAMTHIST  NUMBER(30);
       l_ACCTNO VARCHAR2(30);
       l_TLID   VARCHAR2(30);
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
        -- 01.TLID
    l_TLID := p_txmsg.txfields('01').VALUE;
    -- 03.ACCTNO
    l_ACCTNO := p_txmsg.txfields('03').VALUE;
    IF p_txmsg.deltd = 'N' THEN
       BEGIN

           SELECT NVL(ADVT0AMT,0) ADVT0AMT, NVL(ADVAMTHIST,0) ADVAMTHIST INTO l_ADVT0AMT, l_ADVAMTHIST
           FROM VW_ACCOUNT_ADVT0
           WHERE acctno = l_ACCTNO AND tlid = l_TLID;
           EXCEPTION
           WHEN OTHERS THEN
               p_err_code := '0';
               RETURN errnums.C_BIZ_RULE_INVALID;
       END;

       IF p_txmsg.txfields('08').VALUE >  l_ADVT0AMT THEN
          p_err_code := '-180034';
          RETURN errnums.C_BIZ_RULE_INVALID;
       END IF;

       IF p_txmsg.txfields('10').VALUE >  l_ADVAMTHIST THEN
          p_err_code := '-180034';
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
       l_ADVT0AMT NUMBER(30);
       l_ADVAMTHIST  NUMBER(30);
       l_TotalRlsAmt NUMBER(30);
       l_dblTemp NUMBER(30);
       l_ACCTNO VARCHAR2(30);
       l_TLID   VARCHAR2(30);
BEGIN
    plog.setbeginsection (pkgctx, 'fn_txAftAppUpdate');
    plog.debug (pkgctx, '<<BEGIN OF fn_txAftAppUpdate');
   /***************************************************************************************************
    ** PUT YOUR SPECIFIC AFTER PROCESS HERE. DO NOT COMMIT/ROLLBACK HERE, THE SYSTEM WILL DO IT
    ***************************************************************************************************/
    -- 01.TLID
    l_TLID := p_txmsg.txfields('01').VALUE;
    -- 03.ACCTNO
    l_ACCTNO := p_txmsg.txfields('03').VALUE;
    -- 08 ADVT0AMT
    l_ADVT0AMT := p_txmsg.txfields('08').VALUE;
    -- 10 ADVT0AMTHIST
    l_ADVAMTHIST := p_txmsg.txfields('10').VALUE;

    l_TotalRlsAmt := -ABS(l_ADVT0AMT + l_ADVAMTHIST);

    IF p_txmsg.deltd <> 'Y' THEN

      UPDATE AFMAST
         SET ADVANCELINE = ADVANCELINE - ROUND(p_txmsg.txfields('08').value,0), T0AMT = T0AMT - ROUND(p_txmsg.txfields('10').value,0),
         LAST_CHANGE = SYSTIMESTAMP
        WHERE ACCTNO=p_txmsg.txfields('03').value;


       UPDATE Useraflimit SET acclimit = acclimit - (l_ADVT0AMT + l_ADVAMTHIST)
       WHERE acctno = l_ACCTNO  AND tliduser = l_TLID AND typereceive = 'T0';

       INSERT INTO USERAFLIMITLOG (TXNUM,TXDATE,ACCTNO,ACCLIMIT,TLIDUSER,TYPEALLOCATE,TYPERECEIVE)
       VALUES (p_txmsg.txnum,TO_DATE(p_txmsg.txdate,'DD/MM/RRRR'),l_ACCTNO,l_TotalRlsAmt,l_TLID,'BO','T0');
       -- xu ly cho ngay hien tai
       IF l_ADVT0AMT > 0 THEN
          BEGIN
               FOR REC IN (
                   SELECT AUTOID, (ALLOCATEDLIMIT - RETRIEVEDLIMIT) AMT FROM T0LIMITSCHD
                   WHERE ACCTNO = l_ACCTNO AND TLID = l_TLID
                        AND ALLOCATEDDATE = TO_DATE(p_txmsg.txdate, systemnums.C_DATE_FORMAT)
                        AND ALLOCATEDLIMIT - RETRIEVEDLIMIT > 0
                   ORDER BY AUTOID DESC
              ) LOOP
                   l_dblTemp := REC.AMT;
                   l_dblTemp := LEAST(l_dblTemp, l_ADVT0AMT);
                   l_ADVT0AMT := GREATEST((l_ADVT0AMT - l_dblTemp),0);
                   UPDATE T0LIMITSCHD SET RETRIEVEDLIMIT = RETRIEVEDLIMIT + l_dblTemp
                   WHERE AUTOID = REC.AUTOID;

                   INSERT INTO RETRIEVEDT0LOG(TXDATE, TXNUM, AUTOID, TLID, RETRIEVEDAMT)
                   VALUES(TO_DATE(p_txmsg.txdate,'DD/MM/RRRR'),p_txmsg.txnum, REC.AUTOID, l_TLID, l_dblTemp);
              END LOOP;
          END;
       END IF;

       -- Xu ly cho ngay qua khu
       IF l_ADVAMTHIST > 0 THEN
          BEGIN
               FOR REC IN (
                   SELECT AUTOID, Allocateddate, (ALLOCATEDLIMIT - RETRIEVEDLIMIT) AMT FROM T0LIMITSCHDHIST
                   WHERE ACCTNO = l_ACCTNO AND TLID = l_TLID
                        --AND ALLOCATEDDATE = TO_DATE(p_txmsg.txdate, systemnums.C_DATE_FORMAT)
                        AND ALLOCATEDLIMIT - RETRIEVEDLIMIT > 0
                   ORDER BY Allocateddate, AUTOID DESC
              ) LOOP
                   l_dblTemp := REC.AMT;
                   l_dblTemp := LEAST(l_dblTemp, l_ADVAMTHIST);
                   l_ADVAMTHIST := GREATEST((l_ADVAMTHIST - l_dblTemp),0);
                   UPDATE T0LIMITSCHDHIST SET RETRIEVEDLIMIT = RETRIEVEDLIMIT + l_dblTemp
                   WHERE Allocateddate = to_date(rec.allocateddate, systemnums.C_DATE_FORMAT) AND  AUTOID = REC.AUTOID;

                   INSERT INTO RETRIEVEDT0LOG(TXDATE, TXNUM, AUTOID, TLID, RETRIEVEDAMT)
                   VALUES(TO_DATE(p_txmsg.txdate,'DD/MM/RRRR'),p_txmsg.txnum, REC.AUTOID, l_TLID, l_dblTemp);
              END LOOP;
          END;
       END IF;

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
         plog.init ('TXPKS_#1811EX',
                    plevel => NVL(logrow.loglevel,30),
                    plogtable => (NVL(logrow.log4table,'N') = 'Y'),
                    palert => (NVL(logrow.log4alert,'N') = 'Y'),
                    ptrace => (NVL(logrow.log4trace,'N') = 'Y')
            );
END TXPKS_#1811EX;
/
