SET DEFINE OFF;
CREATE OR REPLACE PACKAGE txpks_#2654ex
/**----------------------------------------------------------------------------------------------------
 ** Package: TXPKS_#2654EX
 ** and is copyrighted by FSS.
 **
 **    All rights reserved.  No part of this work may be reproduced, stored in a retrieval system,
 **    adopted or transmitted in any form or by any means, electronic, mechanical, photographic,
 **    graphic, optic recording or otherwise, translated in any language or computer language,
 **    without the prior written permission of Financial Software Solutions. JSC.
 **
 **  MODIFICATION HISTORY
 **  Person      Date           Comments
 **  System      23/08/2011     Created
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


CREATE OR REPLACE PACKAGE BODY txpks_#2654ex
IS
   pkgctx   plog.log_ctx;
   logrow   tlogdebug%ROWTYPE;

   c_groupid          CONSTANT CHAR(2) := '20';
   c_strdata          CONSTANT CHAR(2) := '06';
   c_desc             CONSTANT CHAR(2) := '30';
FUNCTION fn_txPreAppCheck(p_txmsg in tx.msg_rectype,p_err_code out varchar2)
RETURN NUMBER
IS
l_count number;
l_countN number;
l_ORGAMT number ;
V_STRXML varchar2(3200);
l_DFACCTNO varchar2(20);
l_AFACCTNO varchar2(20);
l_ACTYPE varchar2(20);
l_mrcrlimitmax number;
l_TA0DF number;
l_ODDF number;
l_VNDSELLDF number;

L_LIMITCHK  varchar2(20);
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


    SELECT ROUND(TA0DF), ROUND(ODDF), ROUND(VNDSELLDF) into l_TA0DF, l_ODDF, l_VNDSELLDF FROM v_getgrpdealformular where groupid = p_txmsg.txfields('20').VALUE;

    PLOG.DEBUG(pkgctx,p_txmsg.txfields('10').VALUE || ' ' || p_txmsg.txfields('11').VALUE || ' ' || p_txmsg.txfields('12').VALUE  || ' ' || ' TA0DF, ODDF, VNDSELLDF ' || l_TA0DF || ' ' || l_ODDF || ' ' || l_VNDSELLDF );

    IF l_TA0DF <>  p_txmsg.txfields('10').VALUE OR l_ODDF <> p_txmsg.txfields('11').VALUE OR l_VNDSELLDF <> p_txmsg.txfields('12').VALUE THEN
        p_err_code:= -260035;
        plog.setendsection (pkgctx, 'fn_txPreAppCheck');
        RETURN -260035;
    END IF;

/*
    V_STRXML:= p_txmsg.txfields('06').VALUE;
    l_countN:=REGEXP_COUNT(V_STRXML,'@');

    for l_count in 1.. l_countN loop

        l_ORGAMT := substr( V_STRXML,instr(V_STRXML,'|',1,2) + 1,instr(V_STRXML,'|',1,3) - instr(V_STRXML,'|',1,2) -1 );
        l_DFACCTNO := substr(V_STRXML,instr(V_STRXML,'|',1,1)+1,instr(V_STRXML,'|',1,2)-instr(V_STRXML,'|',1,1)-1 ) ;

        SELECT AFACCTNO, ACTYPE into l_AFACCTNO, l_ACTYPE from dfmast where acctno = l_DFACCTNO;

        plog.debug (pkgctx, '2654ex fn_txPreAppCheck l_AFACCTNO: ' ||l_AFACCTNO );

        select mrcrlimitmax into l_mrcrlimitmax  from afmast  where acctno = l_AFACCTNO;

       -- SELECT ACTYPE into l_ACTYPE FROM DFTYPE WHERE ACTYPE IN (SELECT ACTYPE FROM DFMAST WHERE ACCTNO=l_AFACCTNO);

        SELECT LIMITCHK into L_LIMITCHK FROM DFTYPE  where actype =l_ACTYPE ;

        IF (l_mrcrlimitmax < l_ORGAMT) and (L_LIMITCHK='Y') THEN
            p_err_code:= -400119;
            RETURN -400119;
        END IF;

        V_STRXML:= substr(V_STRXML,instr(V_STRXML,'@',1,1)+1);

    end loop;

    FOR REC IN (    SELECT * FROM dfgroup WHERE GROUPID = p_txmsg.txfields('20').VALUE )
    LOOP
        IF rec.isvsd = 'Y' then
            p_err_code:= -260022;
            plog.setendsection (pkgctx, 'fn_txPreAppCheck');
            RETURN -260022;
        end if;
    END LOOP;
*/


    plog.debug (pkgctx, '<<END OF fn_txPreAppCheck');
    plog.setendsection (pkgctx, 'fn_txPreAppCheck');
    RETURN systemnums.C_SUCCESS;
EXCEPTION
WHEN OTHERS
   THEN
      plog.debug(pkgctx,'2246EX fn_txPreAppCheck: ' || dbms_utility.format_error_backtrace);
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
    -- goi ham de xu ly mang va tao giao dich 2646
    cspks_dfproc.pr_AddSEToGRDeal(p_txmsg  ,p_err_code );

    plog.debug (pkgctx, '<<END OF fn_txAftAppUpdate');
    plog.setendsection (pkgctx, 'fn_txAftAppUpdate');
    --RETURN systemnums.C_SUCCESS;
   RETURN p_err_code;
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
         plog.init ('TXPKS_#2654EX',
                    plevel => NVL(logrow.loglevel,30),
                    plogtable => (NVL(logrow.log4table,'N') = 'Y'),
                    palert => (NVL(logrow.log4alert,'N') = 'Y'),
                    ptrace => (NVL(logrow.log4trace,'N') = 'Y')
            );
END TXPKS_#2654EX;

/
