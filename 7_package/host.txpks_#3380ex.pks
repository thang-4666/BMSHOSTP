SET DEFINE OFF;
CREATE OR REPLACE PACKAGE txpks_#3380ex
/**----------------------------------------------------------------------------------------------------
 ** Package: TXPKS_#3380EX
 ** and is copyrighted by FSS.
 **
 **    All rights reserved.  No part of this work may be reproduced, stored in a retrieval system,
 **    adopted or transmitted in any form or by any means, electronic, mechanical, photographic,
 **    graphic, optic recording or otherwise, translated in any language or computer language,
 **    without the prior written permission of Financial Software Solutions. JSC.
 **
 **  MODIFICATION HISTORY
 **  Person      Date           Comments
 **  System      20/10/2011     Created
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


CREATE OR REPLACE PACKAGE BODY txpks_#3380ex
IS
   pkgctx   plog.log_ctx;
   logrow   tlogdebug%ROWTYPE;

   c_autoid           CONSTANT CHAR(2) := '01';
   c_camastid         CONSTANT CHAR(2) := '02';
   c_afacctno         CONSTANT CHAR(2) := '03';
   c_symbol           CONSTANT CHAR(2) := '04';
   c_symboldis        CONSTANT CHAR(2) := '20';
   c_catype           CONSTANT CHAR(2) := '05';
   c_reportdate       CONSTANT CHAR(2) := '06';
   c_actiondate       CONSTANT CHAR(2) := '07';
   c_seacctno         CONSTANT CHAR(2) := '08';
   c_exseacctno       CONSTANT CHAR(2) := '09';
   c_amt              CONSTANT CHAR(2) := '10';
   c_qtty             CONSTANT CHAR(2) := '11';
   c_aamt             CONSTANT CHAR(2) := '12';
   c_aqtty            CONSTANT CHAR(2) := '13';
   c_parvalue         CONSTANT CHAR(2) := '14';
   c_exparvalue       CONSTANT CHAR(2) := '15';
   c_description      CONSTANT CHAR(2) := '30';
   c_status           CONSTANT CHAR(2) := '40';
   c_isrightoff       CONSTANT CHAR(2) := '66';
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
    l_count number;
    l_CATYPE varchar2(10);
    l_codeid varchar2(50);
    v_countCI number;
    v_countSE number;
BEGIN
    plog.setbeginsection (pkgctx, 'fn_txAftAppUpdate');
    plog.debug (pkgctx, '<<BEGIN OF fn_txAftAppUpdate');
   /***************************************************************************************************
    ** PUT YOUR SPECIFIC AFTER PROCESS HERE. DO NOT COMMIT/ROLLBACK HERE, THE SYSTEM WILL DO IT
    ***************************************************************************************************/
    if p_txmsg.deltd ='N' then
        --Chieu xuoi giao dich
        for rec in (
            SELECT CASCHD.*,CAMAST.CATYPE
            FROM CASCHD,CAMAST
            WHERE CASCHD.camastid=CAMAST.camastid
                AND CASCHD.AUTOID=p_txmsg.txfields('01').value
                AND CASCHD.DELTD ='N'
        )
        loop
            UPDATE CASCHD SET STATUS='S'
                WHERE AUTOID=p_txmsg.txfields('01').value AND DELTD ='N';
            --UPDATE CAMAST SET STATUS='S'
            --    WHERE  CAMASTID=p_txmsg.txfields('02').value AND DELTD ='N';
        end loop;
    else
        --Xoa giao dich
        UPDATE CASCHD SET STATUS=p_txmsg.txfields('40').value
            WHERE AUTOID=p_txmsg.txfields('01').value AND DELTD ='N';
    end if;
    l_count:=0;
    if p_txmsg.deltd ='N' then
        if not length(trim(p_txmsg.reftxnum))=10 then
            SELECT count(1) into l_count FROM CASCHD
            WHERE STATUS=p_txmsg.txfields('40').value  AND CAMASTID=p_txmsg.txfields('02').value  AND DELTD ='N';
            if l_count=0 then
                UPDATE CAMAST SET STATUS='S' WHERE CAMASTID=p_txmsg.txfields('02').value;
                select catype, codeid into l_CATYPE, l_codeid from camast where camastid =p_txmsg.txfields('02').value;
                if l_CATYPE= '002' then --Halt chung khoan
                    UPDATE SBSECURITIES SET HALT ='Y'
                    WHERE CODEID=l_codeid;
                end if;
            end if;
        end if;


           -- HaiLT them neu khong phan bo chung khoan thi ko can lam 3341
         SELECT count(1) into v_countCI FROM CASCHD WHERE  CAMASTID=p_txmsg.txfields('02').value  AND DELTD ='N'
             AND amt> 0 AND ISCI='N' AND isexec='Y';
        -- kiem tra xem co tai khoan nao chua dc phan bo CK khong
         SELECT count(1) into v_countSE FROM CASCHD WHERE  CAMASTID=p_txmsg.txfields('02').value  AND DELTD ='N'
            AND qtty> 0 AND ISSE='N' AND isexec='Y';
         -- update trang thai trong CAMAST

         if(v_countCI = 0 AND v_countSE = 0) THEN
                UPDATE CAMAST SET STATUS ='J' WHERE CAMASTID=p_txmsg.txfields('02').value
                    and (case when L_CATYPE IN ('023','020') then cancelstatus else 'Y' end)= 'Y';
            ---and cancelstatus = 'Y';
         ELSIF (v_countCI> 0 AND v_countSE = 0) THEN
                UPDATE CAMAST SET STATUS ='H' WHERE CAMASTID=p_txmsg.txfields('02').value;
         END IF;

        -- End of HaiLT

    else
        if not length(trim(p_txmsg.reftxnum))=10 then
            SELECT count(1) into l_count FROM CASCHD
            WHERE STATUS='S' AND CAMASTID=p_txmsg.txfields('02').value AND DELTD ='N';
            if l_count=0 then
                UPDATE CAMAST SET STATUS=p_txmsg.txfields('40').value WHERE CAMASTID=p_txmsg.txfields('02').value;
                select catype, codeid into l_CATYPE, l_codeid from camast where camastid =p_txmsg.txfields('02').value;
                if l_CATYPE= '002' then --Halt chung khoan
                    UPDATE SBSECURITIES SET HALT ='N'
                    WHERE CODEID=l_codeid;
                end if;
            end if;
        end if;

         -- HaiLT them neu khong phan bo chung khoan thi ko can lam 3341
            SELECT count(1) into v_countCI FROM CASCHD WHERE  CAMASTID=p_txmsg.txfields('02').value  AND DELTD ='N'
                AND ISCI='N' AND  isexec='Y';
        -- kiem tra xem co tai khoan nao chua dc phan bo CK khong
            SELECT count(1) into v_countSE FROM CASCHD WHERE  CAMASTID=p_txmsg.txfields('02').value  AND DELTD ='N'
                AND ISSE='N' AND isexec='Y';

        -- update trang thai trong CAMAST
         if(v_countCI > 0 AND v_countSE > 0) THEN
            UPDATE CAMAST SET STATUS ='I' WHERE CAMASTID=p_txmsg.txfields('02').value;
         ELSIF (v_countCI> 0 AND v_countSE = 0) THEN
            UPDATE CAMAST SET STATUS ='H' WHERE CAMASTID=p_txmsg.txfields('02').value;
         ELSIF (v_countCI= 0 AND v_countSE > 0) THEN
            UPDATE CAMAST SET STATUS ='G' WHERE CAMASTID=p_txmsg.txfields('02').value;
         END IF;
        -- End of HaiLT


    end if;

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
         plog.init ('TXPKS_#3380EX',
                    plevel => NVL(logrow.loglevel,30),
                    plogtable => (NVL(logrow.log4table,'N') = 'Y'),
                    palert => (NVL(logrow.log4alert,'N') = 'Y'),
                    ptrace => (NVL(logrow.log4trace,'N') = 'Y')
            );
END TXPKS_#3380EX;

/
