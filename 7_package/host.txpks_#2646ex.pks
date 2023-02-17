SET DEFINE OFF;
CREATE OR REPLACE PACKAGE txpks_#2646ex
/**----------------------------------------------------------------------------------------------------
 ** Package: TXPKS_#2646EX
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


CREATE OR REPLACE PACKAGE BODY txpks_#2646ex
IS
   pkgctx   plog.log_ctx;
   logrow   tlogdebug%ROWTYPE;

   c_afacctno         CONSTANT CHAR(2) := '03';
   c_groupid          CONSTANT CHAR(2) := '20';
   c_strdata          CONSTANT CHAR(2) := '06';
   c_sumpaid          CONSTANT CHAR(2) := '26';
   c_amtpaid          CONSTANT CHAR(2) := '34';
   c_intpaid          CONSTANT CHAR(2) := '35';
   c_feepaid          CONSTANT CHAR(2) := '36';
   c_desc             CONSTANT CHAR(2) := '30';
FUNCTION fn_txPreAppCheck(p_txmsg in tx.msg_rectype,p_err_code out varchar2)
RETURN NUMBER
IS
    l_cimastcheck_arr txpks_check.cimastcheck_arrtype;
    l_status apprules.field%TYPE;
    l_afacctno varchar2(10);
    l_ciwithdraw number;
    V_STRXML  varchar2(30000);
    l_ORGAMT number;
    v_isvsd varchar2(1);
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

      IF to_char(p_txmsg.txfields('20').value) <> '0' THEN

        V_STRXML:= p_txmsg.txfields('06').VALUE;
        plog.error('V_STRXML:' || V_STRXML) ;
        l_ORGAMT := substr( V_STRXML,instr(V_STRXML,'|',1,10) + 1,instr (V_STRXML,'|',1,11)-instr (V_STRXML,'|',1,10)-1);

        select afacctno into l_afacctno from dfgroup where groupid=to_char(p_txmsg.txfields('20').value);

        l_CIMASTcheck_arr := txpks_check.fn_CIMASTcheck(l_afacctno,'CIMAST','ACCTNO');

        l_STATUS := l_CIMASTcheck_arr(0).STATUS;

        IF NOT ( INSTR('ANT',l_STATUS) > 0) THEN
            p_err_code := '-400100';
            RETURN errnums.C_BIZ_RULE_INVALID;
        END IF;

        select greatest(getbaldefovd(l_afacctno),getbaldefovd(l_afacctno)) into l_ciwithdraw from dual;
        if l_ORGAMT > l_ciwithdraw then
            p_err_code := '-400005';
            RETURN errnums.c_CI_CIMAST_BALANCE_NOTENOUGHT;
        end if;

    END IF;



    IF to_number(p_txmsg.txfields('26').value) > fn_getamt4grpdeal(p_txmsg.txfields('20').value,0,5) THEN

       p_err_code := '-260028';
       plog.error('txfields(26).value' || p_txmsg.txfields('26').value) ;
       plog.error('fn_getamt4grpdeal' || fn_getamt4grpdeal(p_txmsg.txfields('20').value,0,5)) ;
       plog.setendsection (pkgctx, 'fn_txPreAppCheck');
       RETURN errnums.C_BIZ_RULE_INVALID;
    end if;

    select dft.isvsd into v_isvsd from dftype dft, dfgroup df where df.actype = dft.actype and df.groupid = p_txmsg.txfields('20').value;
    if v_isvsd = 'Y' then
        p_err_code := '-260050';
        plog.setendsection (pkgctx, 'fn_txPreAppCheck');
        RETURN errnums.C_BIZ_RULE_INVALID;
    end if;


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

l_ORGAMT number ;
V_STRXML varchar2(3200);
l_AFACCTNODRD varchar2(20);
l_AFACCTNO varchar2(20);
l_ACTYPE varchar2(20);
l_mrcrlimitmax number;
L_LIMITCHK  varchar2(20);
l_AUTODRAWNDOWN number;
l_ISAPPROVE  varchar2(20);

BEGIN
    plog.setbeginsection (pkgctx, 'fn_txAftAppUpdate');
    plog.debug (pkgctx, '<<BEGIN OF fn_txAftAppUpdate');
   /***************************************************************************************************
    ** PUT YOUR SPECIFIC AFTER PROCESS HERE. DO NOT COMMIT/ROLLBACK HERE, THE SYSTEM WILL DO IT
    ***************************************************************************************************/

     V_STRXML:= p_txmsg.txfields('06').VALUE;
    -- goi ham de xu ly mang va tao giao dich 2647
    cspks_dfproc.pr_AddCIToReleaseSecu(p_txmsg  ,p_err_code );

    SELECT limitchk into l_limitchk FROM DFTYPE WHERE ACTYPE IN (
            SELECT ACTYPE fROM DFGROUP WHERE GROUPID= p_txmsg.txfields('20').value);

      if l_limitchk = 'Y' then
         UPDATE CIMAST SET DFODAMT = DFODAMT - (ROUND(p_txmsg.txfields('34').value,0)) WHERE ACCTNO=p_txmsg.txfields('03').value;

         INSERT INTO CITRAN(TXNUM,TXDATE,ACCTNO,TXCD,NAMT,CAMT,ACCTREF,DELTD,REF,AUTOID,TLTXCD,BKDATE,TRDESC)
            VALUES (p_txmsg.txnum, TO_DATE (p_txmsg.txdate, systemnums.C_DATE_FORMAT),p_txmsg.txfields ('03').value,'0071',ROUND(p_txmsg.txfields('34').value,0),NULL,p_txmsg.txfields ('03').value,p_txmsg.deltd,p_txmsg.txfields ('03').value,seq_CITRAN.NEXTVAL,p_txmsg.tltxcd,p_txmsg.busdate,'' || '' || '');
      end if;

    plog.debug (pkgctx, '<<END OF fn_txAftAppUpdate');
    plog.setendsection (pkgctx, 'fn_txAftAppUpdate');
    --RETURN systemnums.C_SUCCESS;
   RETURN p_err_code;
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
         plog.init ('TXPKS_#2646EX',
                    plevel => NVL(logrow.loglevel,30),
                    plogtable => (NVL(logrow.log4table,'N') = 'Y'),
                    palert => (NVL(logrow.log4alert,'N') = 'Y'),
                    ptrace => (NVL(logrow.log4trace,'N') = 'Y')
            );
END TXPKS_#2646EX;

/
