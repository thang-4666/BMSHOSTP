SET DEFINE OFF;
CREATE OR REPLACE PACKAGE txpks_#0059ex
/**----------------------------------------------------------------------------------------------------
 ** Package: TXPKS_#0059EX
 ** and is copyrighted by FSS.
 **
 **    All rights reserved.  No part of this work may be reproduced, stored in a retrieval system,
 **    adopted or transmitted in any form or by any means, electronic, mechanical, photographic,
 **    graphic, optic recording or otherwise, translated in any language or computer language,
 **    without the prior written permission of Financial Software Solutions. JSC.
 **
 **  MODIFICATION HISTORY
 **  Person      Date           Comments
 **  System      11/02/2015     Created
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


CREATE OR REPLACE PACKAGE BODY txpks_#0059ex
IS
   pkgctx   plog.log_ctx;
   logrow   tlogdebug%ROWTYPE;

   c_custodycd        CONSTANT CHAR(2) := '88';
   c_custid           CONSTANT CHAR(2) := '03';
   c_desc             CONSTANT CHAR(2) := '30';
FUNCTION fn_txPreAppCheck(p_txmsg in tx.msg_rectype,p_err_code out varchar2)
RETURN NUMBER
IS

    l_count NUMBER;
    l_sumse VARCHAR2(20);
    v_count NUMBER;

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
    --Check con tien tren cac tieu khoan

    -- GW04-VSD: Chan khong dong tai khoan khi con lien ket domain
    select count(*) into v_count from cfdomain  cf
    where cf.custid = p_txmsg.txfields('03').value  and cf.vsdstatus ='C';
    if (v_count > 0) then
      p_err_code:='-260174';
      plog.setendsection(pkgctx, 'fn_txPreAppCheck');
      RETURN errnums.C_BIZ_RULE_INVALID;
    end if;
    -- chan khong cho lam khi moi huy lien ket domain trong ngay, sang ngay hom sau moi duoc dong
    -- 0103 trong ngay xac nhan Huy lien ket thanh cong
    select count(t.txnum) into v_count  from tllog t, tllogfld tl1, tllogfld tl2
    where t.tltxcd = '0103' and t.msgacct = p_txmsg.txfields('88').value
      and t.txnum = tl1.txnum and t.txdate = tl1.txdate and tl1.fldcd = '92'
      and t.txnum = tl2.txnum and t.txdate = tl2.txdate and tl2.fldcd = '93'
      and tl1.cvalue <> 'REGI' and tl2.cvalue = 'C' ;
    if (v_count > 0) then
      p_err_code:='-260175';
      plog.setendsection(pkgctx, 'fn_txPreAppCheck');
      RETURN errnums.C_BIZ_RULE_INVALID;
    end if;
    --End


    SELECT COUNT(*) INTO l_count
    FROM cimast ci, cfmast cf, afmast af
    WHERE cf.custid = af.custid AND af.acctno = ci.afacctno AND cf.custodycd=p_txmsg.txfields('88').value
        AND ci.balance >0;

    plog.setendsection(pkgctx, 'l_count'||l_count);
    plog.setendsection(pkgctx, 'p_txmsg.txfields(88).value'||p_txmsg.txfields('88').value);
    IF l_count > 0 THEN
                p_err_code:='-400026';
                plog.setendsection(pkgctx, 'fn_txPreAppCheck');
                RETURN errnums.C_BIZ_RULE_INVALID;
    END IF;
    --Check het lenh thanh toan bu tru
    SELECT COUNT(*) INTO l_count
    FROM stschd ci, cfmast cf, afmast af
    WHERE cf.custid = af.custid AND af.acctno = ci.afacctno AND cf.custodycd=p_txmsg.txfields('88').value AND ci.deltd <> 'Y';

    IF l_count > 0 THEN
                p_err_code:='-400035';
                plog.setendsection(pkgctx, 'fn_txPreAppCheck');
                RETURN errnums.C_BIZ_RULE_INVALID;
    END IF;
    BEGIN
        SELECT sum(round(trade,0)+round(mortage,0)+round(margin,0)+round(netting,0)+round(standing,0)+round(secured,0)+round(withdraw,0) +round(loan,0)+round(repo,0)+round(pending,0)+round(transfer,0)) INTO l_sumse
        FROM semast se, cfmast cf, afmast af,sbsecurities sb WHERE cf.custid = af.custid AND af.acctno = se.afacctno AND cf.custodycd=p_txmsg.txfields('88').value
         AND se.codeid =sb.codeid
         AND sb.sectype <>'004' ;
    EXCEPTION
        WHEN OTHERS THEN l_sumse := 0;
    END;

    IF l_sumse <> 0 THEN
                p_err_code:='-400049';
                plog.setendsection(pkgctx, 'fn_txPreAppCheck');
                RETURN errnums.C_BIZ_RULE_INVALID;
    END IF;

    SELECT COUNT (*) INTO l_count FROM caschd ca, cfmast cf, afmast af WHERE ca.afacctno = af.acctno
        AND ca.deltd <> 'Y' AND cf.custid = af.custid AND cf.custodycd = p_txmsg.txfields('88').value
        AND CA.status NOT IN ('C','J','O','W')
        AND  CA.qtty+ CASE WHEN CA.status IN ('M','V') THEN  CA.pqtty ELSE 0 END + CA.amt <> 0
        ;

    IF l_count > 0 THEN
                p_err_code:='-400051';
                plog.setendsection(pkgctx, 'fn_txPreAppCheck');
                RETURN errnums.C_BIZ_RULE_INVALID;
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
         plog.init ('TXPKS_#0059EX',
                    plevel => NVL(logrow.loglevel,30),
                    plogtable => (NVL(logrow.log4table,'N') = 'Y'),
                    palert => (NVL(logrow.log4alert,'N') = 'Y'),
                    ptrace => (NVL(logrow.log4trace,'N') = 'Y')
            );
END TXPKS_#0059EX;
/
