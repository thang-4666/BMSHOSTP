SET DEFINE OFF;
CREATE OR REPLACE PACKAGE txpks_#6685ex
/**----------------------------------------------------------------------------------------------------
 ** Package: TXPKS_#6685EX
 ** and is copyrighted by FSS.
 **
 **    All rights reserved.  No part of this work may be reproduced, stored in a retrieval system,
 **    adopted or transmitted in any form or by any means, electronic, mechanical, photographic,
 **    graphic, optic recording or otherwise, translated in any language or computer language,
 **    without the prior written permission of Financial Software Solutions. JSC.
 **
 **  MODIFICATION HISTORY
 **  Person      Date           Comments
 **  System      02/03/2012     Created
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


CREATE OR REPLACE PACKAGE BODY txpks_#6685ex
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
    l_version varchar2(100);
    l_trfcode varchar2(100);
    l_txdate varchar2(100);
    l_bankque varchar2(100);
    l_refholdid varchar2(100);
    l_orgholdid varchar2(100);
    l_orgholdamount number(20,0);
    l_unhold varchar2(20);
BEGIN
    plog.setbeginsection (pkgctx, 'fn_txAftAppUpdate');
    plog.debug (pkgctx, '<<BEGIN OF fn_txAftAppUpdate');
   /***************************************************************************************************
    ** PUT YOUR SPECIFIC AFTER PROCESS HERE. DO NOT COMMIT/ROLLBACK HERE, THE SYSTEM WILL DO IT
    ***************************************************************************************************/
    --Cap nhat lai crbtrflog va crbtrflogdtl sang trang thai O
    --Neu bang ke co holdid thi cap nhat holdid co san sang O
    --con ko thi phai split tu holdid goc ra , va ghi offline
    l_version:=p_txmsg.txfields(c_version).VALUE;
    l_trfcode:=p_txmsg.txfields(c_trfcode).VALUE;
    l_txdate:=p_txmsg.txfields(c_txdate).VALUE;
    l_bankque:=p_txmsg.txfields(c_bankque).VALUE;

    BEGIN
        SELECT CRA.REFUNHOLD INTO l_unhold
        FROM CRBTRFLOG LG,CRBDEFACCT CRA
        WHERE LG.REFBANK=CRA.REFBANK AND LG.TRFCODE=CRA.TRFCODE
        AND LG.VERSION=l_version AND LG.TRFCODE=l_trfcode AND LG.REFBANK=l_bankque
        AND LG.TXDATE=TO_DATE(l_txdate,'DD/MM/RRRR');
    EXCEPTION
        WHEN OTHERS THEN
            plog.error(pkgctx,'Loi tai buoc lay ra thong tin bang ke, khong lay duoc trang thai unhold cua bang ke');
            RAISE errnums.E_SYSTEM_ERROR;
    END;

    IF l_unhold='Y' THEN
        BEGIN
            FOR rec IN
            (
                SELECT DTL.AUTOID,DTL.VERSION,DTL.TRFCODE,DTL.TXDATE,DTL.REFREQID,
                DTL.AFACCTNO,AF.BANKACCTNO,DTL.AMT,DTL.REFHOLDID
                FROM CRBTRFLOGDTL DTL,AFMAST AF
                WHERE DTL.AFACCTNO=AF.ACCTNO AND DTL.VERSION=l_version AND DTL.TRFCODE=l_trfcode
                AND DTL.BANKCODE=l_bankque
                AND DTL.TXDATE=TO_DATE(l_txdate,'DD/MM/RRRR')
            )
            LOOP
                IF rec.REFHOLDID IS NULL THEN
                    BEGIN
                        cspks_rmproc.pr_GetBankRef(l_bankque, l_txdate, l_refholdid, p_err_code);

                        --Xem co holdid goc ko, neu co thi tien hanh tru di va split ra
                        BEGIN
                            SELECT REFNO,HOLDAMOUNT INTO l_orgholdid,l_orgholdamount
                            FROM CRBHOLDLIST WHERE BANKCODE=l_bankque
                            AND BANKACCTNO=rec.BANKACCTNO AND STATUS='A';
                        EXCEPTION
                            WHEN OTHERS THEN
                                l_orgholdid:='';
                                l_orgholdamount:=0;
                        END;

                        --Neu tim thay holdid goc thi giam tien
                        IF l_orgholdid<>'' THEN
                            BEGIN
                                INSERT INTO CRBHOLDLIST (AUTOID,REFNO,BANKCODE,BANKACCTNO,HOLDAMOUNT,
                                BANKAMOUNT,CREATEDATE,LASTDATE,ORGREFNO,STATUS)
                                VALUES (SEQ_CRBHOLDLIST.NEXTVAL,l_refholdid,l_bankque,rec.BANKACCTNO,
                                rec.AMT,rec.AMT,TRUNC(SYSDATE),TRUNC(SYSDATE),l_orgholdid,'O');

                                UPDATE CRBHOLDLIST SET HOLDAMOUNT=HOLDAMOUNT-rec.AMT,BANKAMOUNT=BANKAMOUNT-rec.AMT
                                WHERE REFNO=l_orgholdid AND BANKCODE=l_bankque AND BANKACCTNO=rec.BANKACCTNO;
                            END;
                        END IF;
                    END;
                ELSE
                    l_refholdid:=rec.REFHOLDID;
                END IF;
            END LOOP;
        END;
    END IF;

    --Cap nhat lai trang thai cua bang ke
    UPDATE CRBTRFLOGDTL SET STATUS='O' WHERE VERSION=l_version AND BANKCODE=l_bankque AND TRFCODE=l_trfcode AND TXDATE=TO_DATE(l_txdate,'DD/MM/RRRR');
    UPDATE CRBTRFLOG SET STATUS='O' WHERE VERSION=l_version AND REFBANK=l_bankque AND TRFCODE=l_trfcode AND TXDATE=TO_DATE(l_txdate,'DD/MM/RRRR');

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
         plog.init ('TXPKS_#6685EX',
                    plevel => NVL(logrow.loglevel,30),
                    plogtable => (NVL(logrow.log4table,'N') = 'Y'),
                    palert => (NVL(logrow.log4alert,'N') = 'Y'),
                    ptrace => (NVL(logrow.log4trace,'N') = 'Y')
            );
END TXPKS_#6685EX;
/
