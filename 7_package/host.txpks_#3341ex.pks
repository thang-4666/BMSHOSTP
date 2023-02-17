SET DEFINE OFF;
CREATE OR REPLACE PACKAGE txpks_#3341ex
/**----------------------------------------------------------------------------------------------------
 ** Package: TXPKS_#3341EX
 ** and is copyrighted by FSS.
 **
 **    All rights reserved.  No part of this work may be reproduced, stored in a retrieval system,
 **    adopted or transmitted in any form or by any means, electronic, mechanical, photographic,
 **    graphic, optic recording or otherwise, translated in any language or computer language,
 **    without the prior written permission of Financial Software Solutions. JSC.
 **
 **  MODIFICATION HISTORY
 **  Person      Date           Comments
 **  System      11/10/2011     Created
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


CREATE OR REPLACE PACKAGE BODY txpks_#3341ex
IS
   pkgctx   plog.log_ctx;
   logrow   tlogdebug%ROWTYPE;

   c_camastid         CONSTANT CHAR(2) := '03';
   c_symbol           CONSTANT CHAR(2) := '04';
   c_catype           CONSTANT CHAR(2) := '05';
   c_actiondate       CONSTANT CHAR(2) := '07';
   c_contents         CONSTANT CHAR(2) := '13';
   c_desc             CONSTANT CHAR(2) := '30';
FUNCTION fn_txPreAppCheck(p_txmsg in tx.msg_rectype,p_err_code out varchar2)
RETURN NUMBER
IS
l_status varchar2(1);
l_catype varchar2(4);
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
    if p_txmsg.deltd<>'Y' then
        SELECT STATUS, catype INTO l_STATUS, l_catype
        FROM CAMAST
        WHERE CAMASTID = p_txmsg.txfields('03').value;
        if l_catype in ('023','020') then
            IF NOT(INSTR('IGHJ',l_STATUS) > 0) THEN
                p_err_code := '-300013';
                plog.setendsection (pkgctx, 'fn_txAppAutoCheck');
                RETURN errnums.C_BIZ_RULE_INVALID;
            END IF;
        else
            IF NOT(INSTR('IG',l_STATUS) > 0) THEN
                p_err_code := '-300013';
                plog.setendsection (pkgctx, 'fn_txAppAutoCheck');
                RETURN errnums.C_BIZ_RULE_INVALID;
            END IF;
        end if;
    end if;
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
l_count NUMBER;
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
      -- check neu su kien quyen da lam 3355 thi khong cho revert


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
    l_err_param varchar2(500);
    v_countCI number;
    v_countSE number;
    l_count NUMBER;
    l_catype VARCHAR2(3);
    l_codeid VARCHAR2(6);
BEGIN
    plog.setbeginsection (pkgctx, 'fn_txAftAppUpdate');
    plog.debug (pkgctx, '<<BEGIN OF fn_txAftAppUpdate');
   /***************************************************************************************************
    ** PUT YOUR SPECIFIC AFTER PROCESS HERE. DO NOT COMMIT/ROLLBACK HERE, THE SYSTEM WILL DO IT
    ***************************************************************************************************/
    --cspks_caproc.pr_exec_sec_cop_action(p_txmsg.txfields('03').value,p_err_code);
    SELECT ca.catype,
           ca.codeid
    INTO l_Catype ,l_codeid from camast ca
    WHERE camastid = p_txmsg.txfields('03').value;
    if p_txmsg.deltd<>'Y' then
        cspks_caproc.pr_3351_Exec_Sec_CA(p_txmsg,p_err_code);
        if p_err_code <> systemnums.C_SUCCESS THEN
            plog.setendsection (pkgctx, 'fn_txAftAppUpdate');
            RETURN errnums.C_BIZ_RULE_INVALID;
        end if;
        if p_txmsg.txfields('10').value = 'Y' then
            update CAMAST set camast.cancelstatus = p_txmsg.txfields('10').value
            where CAMASTID=p_txmsg.txfields('03').value;
        end if;

        SELECT count(1) into v_countCI FROM CASCHD
         WHERE  CAMASTID=p_txmsg.txfields('03').value  AND DELTD ='N'
         AND amt> 0 AND ISCI='N' AND isexec='Y';
        -- kiem tra xem co tai khoan nao chua dc phan bo CK khong
         SELECT count(1) into v_countSE FROM CASCHD
         WHERE  CAMASTID=p_txmsg.txfields('03').value  AND DELTD ='N'
         AND qtty> 0 AND ISSE='N' AND isexec='Y';
         -- update trang thai trong CAMAST

         if(v_countCI = 0 AND v_countSE = 0) THEN
         UPDATE CAMAST SET STATUS ='J'
         WHERE CAMASTID=p_txmsg.txfields('03').value
            and (case when L_CATYPE IN ('023','020') then cancelstatus else 'Y' end)= 'Y';
            ---and cancelstatus = 'Y';
         ELSIF (v_countCI> 0 AND v_countSE = 0) THEN
         UPDATE CAMAST SET STATUS ='H'
         WHERE CAMASTID=p_txmsg.txfields('03').value;
         END IF;

         -- NEU LA TRA chuyen doi TRAI PHIEU,CP: UPDATE SEMAST CUA CAC TK SE ko duoc phan bo = 0
         IF(L_CATYPE = '017') THEN
             FOR rec IN (SELECT se.acctno,se.trade
                         FROM semast se
                         WHERE codeid= l_codeid AND trade >0
                         AND afacctno NOT IN
                               (SELECT afacctno from caschd WHERE deltd='N' AND camastid=p_txmsg.txfields('03').value)
                         )
             LOOP
               INSERT INTO SETRAN(TXNUM,TXDATE,ACCTNO,TXCD,NAMT,CAMT,ACCTREF,DELTD,REF,AUTOID,TLTXCD,BKDATE,TRDESC)
               VALUES (p_txmsg.txnum, TO_DATE (p_txmsg.txdate, systemnums.C_DATE_FORMAT),rec.acctno,'0011',rec.trade,NULL,p_txmsg.txfields ('03').value,p_txmsg.deltd,NULL,seq_SETRAN.NEXTVAL,p_txmsg.tltxcd,p_txmsg.busdate,'' || '' || '');

               UPDATE semast SET trade=0 WHERE acctno=rec.acctno;

             END LOOP;
         END IF;
    ELSE
        SELECT COUNT(1) INTO l_count from caschd WHERE camastid = p_txmsg.txfields('03').value
        AND (status='W' OR INSTR(pstatus,'W') > 0 ) AND deltd <> 'Y';
          if l_count >0 then
                  p_err_code := '-300051'; -- Pre-defined in DEFERROR table
                  plog.setendsection (pkgctx, 'fn_txAftAppUpdate');
                  RETURN errnums.C_BIZ_RULE_INVALID;
          end if;


        for rec in
        (
            select * from tllog where reftxnum = p_txmsg.txnum
        )
        loop
            if rec.tltxcd = '3351' then
                if txpks_#3351.fn_txrevert(rec.txnum,to_char(rec.txdate,'dd/mm/rrrr'),p_err_code,l_err_param) <> 0 then
                    plog.error (pkgctx, 'Loi khi thuc hien xoa giao dich');
                    plog.setendsection (pkgctx, 'fn_txAftAppUpdate');
                    return errnums.C_SYSTEM_ERROR;
                end if;
            end if ;
        end loop;


        SELECT count(1) into v_countCI FROM CASCHD
         WHERE  CAMASTID=p_txmsg.txfields('03').value  AND DELTD ='N'
         AND ISCI='N' AND  isexec='Y';
        -- kiem tra xem co tai khoan nao chua dc phan bo CK khong
         SELECT count(1) into v_countSE FROM CASCHD
         WHERE  CAMASTID=p_txmsg.txfields('03').value  AND DELTD ='N'
         AND ISSE='N' AND isexec='Y';
         -- update trang thai trong CAMAST
         if(v_countCI > 0 AND v_countSE > 0) THEN
         UPDATE CAMAST SET STATUS ='I'
         WHERE CAMASTID=p_txmsg.txfields('03').value;
         ELSIF (v_countCI> 0 AND v_countSE = 0) THEN
         UPDATE CAMAST SET STATUS ='H'
         WHERE CAMASTID=p_txmsg.txfields('03').value;
         ELSIF (v_countCI= 0 AND v_countSE > 0) THEN
         UPDATE CAMAST SET STATUS ='G'
         WHERE CAMASTID=p_txmsg.txfields('03').value;
         END IF;

         if p_txmsg.txfields('10').value = 'Y' then
            update CAMAST set camast.cancelstatus = 'N'
            where CAMASTID=p_txmsg.txfields('03').value;
        end if;

         -- revert lai doi voi cac TK ko duoc chia co tuc cua su kien CD TP-CP; CP-CP
         IF(L_CATYPE = '017') THEN
         FOR  rec IN
         (SELECT acctno,namt from setran WHERE deltd='N'
         AND TXNUM = p_txmsg.txnum AND TXDATE = TO_DATE(p_txmsg.txdate, systemnums.C_DATE_FORMAT)
         ) LOOP
              UPDATE semast SET trade=trade+rec.namt WHERE acctno=rec.acctno;
         END LOOP;

         -- xoa trong setran
         UPDATE SETRAN        SET DELTD = 'Y'
         WHERE TXNUM = p_txmsg.txnum AND TXDATE = TO_DATE(p_txmsg.txdate, systemnums.C_DATE_FORMAT);
         END IF;

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
         plog.init ('TXPKS_#3341EX',
                    plevel => NVL(logrow.loglevel,30),
                    plogtable => (NVL(logrow.log4table,'N') = 'Y'),
                    palert => (NVL(logrow.log4alert,'N') = 'Y'),
                    ptrace => (NVL(logrow.log4trace,'N') = 'Y')
            );
END TXPKS_#3341EX;
/
