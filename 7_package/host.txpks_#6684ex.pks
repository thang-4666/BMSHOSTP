SET DEFINE OFF;
CREATE OR REPLACE PACKAGE txpks_#6684ex
/**----------------------------------------------------------------------------------------------------
 ** Package: TXPKS_#6684EX
 ** and is copyrighted by FSS.
 **
 **    All rights reserved.  No part of this work may be reproduced, stored in a retrieval system,
 **    adopted or transmitted in any form or by any means, electronic, mechanical, photographic,
 **    graphic, optic recording or otherwise, translated in any language or computer language,
 **    without the prior written permission of Financial Software Solutions. JSC.
 **
 **  MODIFICATION HISTORY
 **  Person      Date           Comments
 **  System      11/02/2012     Created
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


CREATE OR REPLACE PACKAGE BODY txpks_#6684ex
IS
   pkgctx   plog.log_ctx;
   logrow   tlogdebug%ROWTYPE;

   c_autoid           CONSTANT CHAR(2) := '01';
   c_version          CONSTANT CHAR(2) := '03';
   c_versionlocal     CONSTANT CHAR(2) := '02';
   c_txdate           CONSTANT CHAR(2) := '04';
   c_trfcode          CONSTANT CHAR(2) := '06';
   c_bankname         CONSTANT CHAR(2) := '94';
   c_bankque          CONSTANT CHAR(2) := '95';
   c_description      CONSTANT CHAR(2) := '30';
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
   l_autoid NUMBER(20):=p_txmsg.txfields(c_autoid).VALUE;
   l_version    VARCHAR2(20):=p_txmsg.txfields(c_version).VALUE;
   l_versionlocal   VARCHAR2(20):=p_txmsg.txfields(c_versionlocal).VALUE;
   l_txdate VARCHAR2(10):=p_txmsg.txfields(c_txdate).VALUE;
   l_trfcode    VARCHAR2(20):=p_txmsg.txfields(c_trfcode).VALUE;
   l_bankname   VARCHAR2(250):=p_txmsg.txfields(c_bankname).VALUE;
   l_bankque   VARCHAR2(20):=p_txmsg.txfields(c_bankque).VALUE;
   l_description    VARCHAR2(250):=p_txmsg.txfields(c_description).VALUE;
   l_newversion VARCHAR2(20);
   v_count number;
BEGIN
    plog.setbeginsection (pkgctx, 'fn_txAftAppUpdate');
    plog.debug (pkgctx, '<<BEGIN OF fn_txAftAppUpdate');

    /*
    --Lay ma version moi
    SELECT  NVL(MAX(ODR)+1,1) INTO l_newversion FROM
    (SELECT ROWNUM ODR, INVACCT
    FROM (SELECT VERSION INVACCT
    FROM CRBTRFLOG WHERE TXDATE=TO_DATE(l_txdate,'DD/MM/RRRR') AND TRFCODE=l_trfcode
    ORDER BY TO_NUMBER(VERSION)) WHERE TO_NUMBER(INVACCT)=ROWNUM) INVTAB;

    --Tao bang ke moi, khong can duyet nua
    INSERT INTO CRBTRFLOG (AUTOID,VERSION,VERSIONLOCAL,TXDATE,CREATETST,
    SENDTST,REFBANK,TRFCODE,STATUS,PSTATUS,ERRCODE,FEEDBACK,ERRSTS,REFVERSION,NOTES,TLID,OFFID)
    SELECT SEQ_CRBTRFLOG.NEXTVAL AUTOID,l_newversion VERSION,'' VERSIONLOCAL,
    TXDATE,SYSTIMESTAMP CREATETST,SYSTIMESTAMP SENDTST,
    REFBANK,TRFCODE,'A' STATUS,'' PSTATUS,'' ERRCODE,'' FEEDBACK,'N' ERRSTS,
    VERSION REFVERSION,NOTES,TLID,OFFID
    FROM CRBTRFLOG WHERE AUTOID=l_autoid;

    --Tao lai cac dong bi loi
    for rec in (
        SELECT DTL.AUTOID,REQ.TRFCODE,DTL.REFREQID,DTL.AFACCTNO,DTL.AMT,DTL.REFNOTES,DTL.STATUS,DTL.REFTXNUM,DTL.REFTXDATE
        FROM CRBTRFLOGDTL DTL,CRBTXREQ REQ
        WHERE DTL.REFREQID=REQ.REQID AND DTL.VERSION=l_version AND REQ.TRFCODE=l_trfcode
        AND DTL.STATUS IN ('E')
    )
    LOOP
        BEGIN
            --Tao moi
            INSERT INTO CRBTRFLOGDTL (AUTOID,TRFCODE,ITEMTRANCODE,VERSION,REFREQID,AFACCTNO,AMT,
            REFNOTES,STATUS,ERRNUM,ERRMSG,DONESTS,REFTXNUM,REFTXDATE)
            VALUES (SEQ_CRBTRFLOGDTL.NEXTVAL,rec.TRFCODE,'',l_newversion,rec.REFREQID,rec.AFACCTNO,
            rec.AMT,rec.REFNOTES,'P','','','N',rec.REFTXNUM,rec.REFTXDATE);
            --Cap nhat trang thai cua ID cu
            UPDATE CRBTRFLOGDTL SET STATUS='D' WHERE AUTOID=rec.AUTOID;
            UPDATE CRBTXREQ SET STATUS='A' WHERE REQID=rec.REFREQID;
        END;
    END LOOP;
    */

    for rec in (
        SELECT DTL.AUTOID,REQ.TRFCODE,DTL.REFREQID,DTL.AFACCTNO,DTL.AMT,DTL.REFNOTES,DTL.STATUS,DTL.REFTXNUM,DTL.REFTXDATE,DTL.REFHOLDID
        FROM CRBTRFLOGDTL DTL,CRBTXREQ REQ
        WHERE DTL.REFREQID=REQ.REQID AND DTL.VERSION=l_version AND REQ.TRFCODE=l_trfcode
        AND DTL.STATUS IN ('E')
    )
    LOOP
        BEGIN
            --Cap nhat trang thai cua ID cu
            UPDATE CRBTRFLOGDTL SET STATUS='D' WHERE AUTOID=rec.AUTOID;
            UPDATE CRBTXREQ SET STATUS='P',REFVAL=rec.REFHOLDID WHERE REQID=rec.REFREQID;
        END;
    END LOOP;
    --NamTv check bang ke hoan thanh mot phan
    BEGIN
        SELECT COUNT(*) INTO V_COUNT
        FROM CRBTRFLOGDTL DTL, CRBTXREQ REQ
        WHERE DTL.REFREQID=REQ.REQID AND DTL.VERSION=l_version AND REQ.TRFCODE=l_trfcode
              AND DTL.TXDATE=p_txmsg.txfields(c_txdate).VALUE
        AND DTL.STATUS <> 'D';
    EXCEPTION
    WHEN OTHERS THEN
        V_COUNT := 0;
    END;

    IF V_COUNT=0 then
        --Cap nhat lai bang ke goc, ghi da sinh lai bang ke loi
        UPDATE CRBTRFLOG SET ERRSTS='E', STATUS='D'
        WHERE AUTOID=l_autoid;
    ELSE
        --Cap nhat lai bang ke goc, ghi da sinh lai bang ke loi
        UPDATE CRBTRFLOG SET ERRSTS='E', STATUS='H'
        WHERE AUTOID=l_autoid;
    END IF;
    --NamTv End

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
         plog.init ('TXPKS_#6684EX',
                    plevel => NVL(logrow.loglevel,30),
                    plogtable => (NVL(logrow.log4table,'N') = 'Y'),
                    palert => (NVL(logrow.log4alert,'N') = 'Y'),
                    ptrace => (NVL(logrow.log4trace,'N') = 'Y')
            );
END TXPKS_#6684EX;
/
