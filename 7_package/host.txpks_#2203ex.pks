SET DEFINE OFF;
CREATE OR REPLACE PACKAGE txpks_#2203ex
/**----------------------------------------------------------------------------------------------------
 ** Package: TXPKS_#2203EX
 ** and is copyrighted by FSS.
 **
 **    All rights reserved.  No part of this work may be reproduced, stored in a retrieval system,
 **    adopted or transmitted in any form or by any means, electronic, mechanical, photographic,
 **    graphic, optic recording or otherwise, translated in any language or computer language,
 **    without the prior written permission of Financial Software Solutions. JSC.
 **
 **  MODIFICATION HISTORY
 **  Person      Date           Comments
 **  System      26/07/2013     Created
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


CREATE OR REPLACE PACKAGE BODY txpks_#2203ex
IS
   pkgctx   plog.log_ctx;
   logrow   tlogdebug%ROWTYPE;

   c_codeid           CONSTANT CHAR(2) := '01';
   c_afacctno         CONSTANT CHAR(2) := '02';
   c_acctno           CONSTANT CHAR(2) := '03';
   c_custname         CONSTANT CHAR(2) := '90';
   c_address          CONSTANT CHAR(2) := '91';
   c_license          CONSTANT CHAR(2) := '92';
   c_blocked          CONSTANT CHAR(2) := '10';
   c_emkqtty          CONSTANT CHAR(2) := '12';
   c_parvalue         CONSTANT CHAR(2) := '11';
   c_price            CONSTANT CHAR(2) := '09';
   c_desc             CONSTANT CHAR(2) := '30';
   c_contract_no      CONSTANT CHAR(2) := '55';
FUNCTION fn_txPreAppCheck(p_txmsg in tx.msg_rectype,p_err_code out varchar2)
RETURN NUMBER
IS
v_confirmqtty   NUMBER(20);
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

    -- HSX04: Check SL yeu cau giai toa tu VSD
    IF p_txmsg.txfields(c_contract_no).value IS NOT NULL THEN
       SELECT SUM(dtl.confirmqtty - dtl.execqtty) confirmqtty INTO v_confirmqtty
       FROM seblockeddtl dtl, sbsecurities sb
       WHERE dtl.contract_no = p_txmsg.txfields(c_contract_no).value
         AND sb.codeid = p_txmsg.txfields(c_codeid).value
         AND dtl.symbol = sb.symbol
         AND dtl.releaseqtty > 0 AND dtl.confirmqtty - dtl.execqtty > 0;

       IF NOT p_txmsg.txfields(c_emkqtty).value <= nvl(v_confirmqtty,0) THEN
          p_err_code := '-905554'; -- Pre-defined in DEFERROR table
          plog.setendsection (pkgctx, 'fn_txPreAppCheck');
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
      plog.error (pkgctx, SQLERRM || dbms_utility.format_error_backtrace);
      plog.setendsection (pkgctx, 'fn_txPreAppCheck');
      RAISE errnums.E_SYSTEM_ERROR;
END fn_txPreAppCheck;

FUNCTION fn_txAftAppCheck(p_txmsg in tx.msg_rectype,p_err_code out varchar2)
RETURN NUMBER
IS
  l_qtty_standing NUMBER ;
  l_semastcheck_arr txpks_check.semastcheck_arrtype;
  l_emkqtty apprules.field%TYPE;
  l_avlblocked number (20,0);
  l_avlemkqtty number (20,0);
  l_BALDEFOVD   NUMBER;
  v_bchsts    varchar2(4);
  l_cimastcheck_arr txpks_check.cimastcheck_arrtype;
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
     If txpks_check.fn_aftxmapcheck(p_txmsg.txfields('03').value,'SEMAST','03','2203')<>'TRUE' then
         p_err_code := errnums.C_SA_TLTX_NOT_ALLOW_BY_ACCTNO;
         plog.setendsection (pkgctx, 'fn_txAppAutoCheck');
         RETURN errnums.C_BIZ_RULE_INVALID;
     End if;

     l_SEMASTcheck_arr := txpks_check.fn_SEMASTcheck(p_txmsg.txfields('03').value,'SEMAST','ACCTNO');


     l_EMKQTTY := l_SEMASTcheck_arr(0).EMKQTTY;
     BEGIN
        SELECT NVL(SUM ( QTTY),0) QTTY INTO l_qtty_standing FROM SEMORTAGE WHERE STATUS ='N' AND DELTD <>'Y' AND acctno =   p_txmsg.txfields('03').value and tltxcd ='2232';
     EXCEPTION
     WHEN OTHERS
     THEN
        l_qtty_standing:=0;
     END ;
     PLOG.error(pkgctx,L_EMKQTTY ||','|| L_QTTY_STANDING ||','||p_txmsg.txfields('12').value);
      IF NOT (to_number(l_EMKQTTY)- nvl(l_qtty_standing,0) >= to_number(p_txmsg.txfields('12').value)) THEN
          p_err_code := '-900143';
          plog.setendsection (pkgctx, 'fn_txAppAutoCheck');
          RETURN errnums.C_BIZ_RULE_INVALID;
      END IF;

    --Kiem tra trong SEBLOCKED phai du so du de giai toa
    BEGIN
        select BLOCKED-RLSBLOCKED,EMKQTTY-RLSEMKQTTY into l_avlblocked, l_avlemkqtty
        from SEBLOCKED where txnum = p_txmsg.txfields('93').value and txdate = to_date (p_txmsg.txfields('94').value,'dd/mm/rrrr');
    EXCEPTION
     WHEN OTHERS
     THEN
        l_avlblocked:=0;
        l_avlemkqtty:=0;
     END ;
   IF NOT (l_avlblocked >= to_number(p_txmsg.txfields('10').value)) THEN
          p_err_code := '-900040';
          plog.setendsection (pkgctx, 'fn_txAppAutoCheck');
          RETURN errnums.C_BIZ_RULE_INVALID;
   END IF;
   IF NOT (l_avlemkqtty >= to_number(p_txmsg.txfields('12').value)) THEN
          p_err_code := '-900143';
          plog.setendsection (pkgctx, 'fn_txAppAutoCheck');
          RETURN errnums.C_BIZ_RULE_INVALID;
   END IF;

     l_CIMASTcheck_arr := txpks_check.fn_CIMASTcheck(p_txmsg.txfields('02').value,'CIMAST','AFACCTNO');
     l_BALDEFOVD := l_CIMASTcheck_arr(0).BALDEFOVD;
 --SELECT balance INTO v_balance FROM cimast ci WHERE ci.acctno = p_txmsg.txfields('02').value;
 IF  p_txmsg.txfields('41').value+p_txmsg.txfields('47').value > l_BALDEFOVD THEN
     p_err_code := '-400110';
     plog.setendsection (pkgctx, 'fn_txAppAutoCheck');
     RETURN errnums.C_BIZ_RULE_INVALID;
 END IF;


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
V_STRSEACCTNO     VARCHAR2(20);
V_DBLAMT        NUMBER(20,4);
L_COUNT         NUMBER(20);
V_AUTOID        NUMBER(20);
V_STRBLKNUM     VARCHAR2(20);
V_STRBLKDATE    VARCHAR(20);
V_DBLREAMAINDFAQTTY   NUMBER(20,4);
V_DBLEXECDFAQTTY      NUMBER(20,4);
V_STRCODEID           VARCHAR2(6);
V_DBLTRADEQTTY        NUMBER(20,4);
V_NETTRADEQTTY        NUMBER(20,4);
v_qttytype            varchar2(10);

BEGIN
    plog.setbeginsection (pkgctx, 'fn_txAftAppUpdate');
    plog.debug (pkgctx, '<<BEGIN OF fn_txAftAppUpdate');
   /***************************************************************************************************
    ** PUT YOUR SPECIFIC AFTER PROCESS HERE. DO NOT COMMIT/ROLLBACK HERE, THE SYSTEM WILL DO IT
    ***************************************************************************************************/
    IF P_TXMSG.DELTD <> 'Y' THEN
       UPDATE SEBLOCKED SET RLSBLOCKED=RLSBLOCKED+ROUND(p_txmsg.txfields('10').value,0),
                            RLSEMKQTTY=RLSEMKQTTY+ROUND(p_txmsg.txfields('12').value,0)
       WHERE txnum = p_txmsg.txfields('93').value and txdate = to_date (p_txmsg.txfields('94').value,'dd/mm/rrrr');

       --KRX04: Cap nhat so luong da giai toa
       begin
            select max(qttytype) into v_qttytype
            from semastdtl where txnum = p_txmsg.txfields('93').value and txdate = to_date (p_txmsg.txfields('94').value,'dd/mm/rrrr') ;
            EXCEPTION WHEN OTHERS THEN
                v_qttytype := '007';
       end;
        V_NETTRADEQTTY  := ROUND(p_txmsg.txfields('10').value,0)+ROUND(p_txmsg.txfields('12').value,0);
        IF P_TXMSG.TXFIELDS(C_CONTRACT_NO).VALUE IS NOT NULL THEN
            FOR REC IN
            (  SELECT DTL.* FROM SEBLOCKEDDTL DTL, SBSECURITIES SB
                WHERE DTL.CONTRACT_NO = P_TXMSG.TXFIELDS(C_CONTRACT_NO).VALUE
                  AND SB.CODEID = P_TXMSG.TXFIELDS(C_CODEID).VALUE
                  AND DTL.SYMBOL = SB.SYMBOL
                  AND DTL.RELEASEQTTY > 0 AND DTL.CONFIRMQTTY - DTL.EXECQTTY > 0
                ORDER BY DTL.AUTOID
            )
            LOOP
                UPDATE SEBLOCKEDDTL SET EXECQTTY = EXECQTTY + LEAST(V_NETTRADEQTTY,REC.CONFIRMQTTY-REC.EXECQTTY),
                                        STATUS = DECODE(EXECQTTY + LEAST(V_NETTRADEQTTY,REC.CONFIRMQTTY-REC.EXECQTTY), RELEASEQTTY, 'C', STATUS)
                WHERE AUTOID = REC.AUTOID;

                INSERT INTO SEMASTDTL (ACCTNO,QTTY,QTTYTYPE,TXDATE,TXNUM,AUTOID,CONTRACT_NO,REFID)
                VALUES (P_TXMSG.TXFIELDS(c_acctno).VALUE,
                       - LEAST(V_NETTRADEQTTY,REC.CONFIRMQTTY-REC.EXECQTTY),
                       nvl(v_qttytype,'007'),
                       P_TXMSG.TXDATE,
                       P_TXMSG.TXNUM,
                       SEQ_SEMASTDTL.NEXTVAL,
                       TRIM(P_TXMSG.TXFIELDS(c_contract_no).VALUE),
                       rec.autoid);

                UPDATE VSDTXREQ SET MSGSTATUS = 'F', STATUS = 'C'
                WHERE REQID = REC.REQID
                AND NOT EXISTS (SELECT * FROM SEBLOCKEDDTL WHERE REQID = REC.REQID AND STATUS <> 'C');

                V_NETTRADEQTTY := V_NETTRADEQTTY - LEAST(V_NETTRADEQTTY,REC.CONFIRMQTTY-REC.EXECQTTY);
                EXIT WHEN V_NETTRADEQTTY = 0;
            END LOOP;
        ELSE
            INSERT INTO SEMASTDTL (ACCTNO,QTTY,QTTYTYPE,TXDATE,TXNUM,AUTOID,CONTRACT_NO)
                VALUES (P_TXMSG.TXFIELDS(c_acctno).VALUE,
                       - (ROUND(p_txmsg.txfields('10').value,0)+ROUND(p_txmsg.txfields('12').value,0)),
                       nvl(v_qttytype,'007'),
                       P_TXMSG.TXDATE,
                       P_TXMSG.TXNUM,
                       SEQ_SEMASTDTL.NEXTVAL,
                       TRIM(P_TXMSG.TXFIELDS(c_contract_no).VALUE));
        END IF;
       --End KRX04

    ELSE -- xoa giao dich
       UPDATE SEBLOCKED SET RLSBLOCKED=RLSBLOCKED-ROUND(p_txmsg.txfields('10').value,0),
                            RLSEMKQTTY=RLSEMKQTTY-ROUND(p_txmsg.txfields('12').value,0)
       WHERE txnum = p_txmsg.txfields('93').value and txdate = to_date (p_txmsg.txfields('94').value,'dd/mm/rrrr');
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
         plog.init ('TXPKS_#2203EX',
                    plevel => NVL(logrow.loglevel,30),
                    plogtable => (NVL(logrow.log4table,'N') = 'Y'),
                    palert => (NVL(logrow.log4alert,'N') = 'Y'),
                    ptrace => (NVL(logrow.log4trace,'N') = 'Y')
            );
END TXPKS_#2203EX;
/
