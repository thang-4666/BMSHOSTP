SET DEFINE OFF;
CREATE OR REPLACE PACKAGE txpks_#1813ex
/**----------------------------------------------------------------------------------------------------
 ** Package: TXPKS_#1813EX
 ** and is copyrighted by FSS.
 **
 **    All rights reserved.  No part of this work may be reproduced, stored in a retrieval system,
 **    adopted or transmitted in any form or by any means, electronic, mechanical, photographic,
 **    graphic, optic recording or otherwise, translated in any language or computer language,
 **    without the prior written permission of Financial Software Solutions. JSC.
 **
 **  MODIFICATION HISTORY
 **  Person      Date           Comments
 **  System      02/01/2012     Created
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


CREATE OR REPLACE PACKAGE BODY txpks_#1813ex
IS
   pkgctx   plog.log_ctx;
   logrow   tlogdebug%ROWTYPE;

   c_custodycd        CONSTANT CHAR(2) := '88';
   c_acctno           CONSTANT CHAR(2) := '03';
   c_usertype         CONSTANT CHAR(2) := '02';
   c_userid           CONSTANT CHAR(2) := '01';
   c_acclimit         CONSTANT CHAR(2) := '10';
   c_limitmax         CONSTANT CHAR(2) := '14';
   c_mrcrlimitmax     CONSTANT CHAR(2) := '11';
   c_userhave         CONSTANT CHAR(2) := '15';
   c_custavllimit     CONSTANT CHAR(2) := '16';
   c_desc             CONSTANT CHAR(2) := '30';
FUNCTION fn_txPreAppCheck(p_txmsg in tx.msg_rectype,p_err_code out varchar2)
RETURN NUMBER
IS
l_count number(20,0);
l_allocatelimmit number(20,0);
l_usedlimit number(20,0);
l_acctlimit number(20,0);
l_remainlimit number(20,0);
l_remainaflimit number(20,0);
l_usedaflimit number(20,0);
l_mrloanlimit number(20,0);
l_MaxDebtCF number(20,0);
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
    ------------------------------------So hop dong phai active -----------
    Select count(1) into l_count from AFMAST AF, aftype a where AF.actype=a.actype and ACCTNO =p_txmsg.txfields(c_acctno).value and AF.status = 'A';

    if l_count = 0 then
        p_err_code := '-100606'; -- Pre-defined in DEFERROR table
        plog.setendsection (pkgctx, 'fn_txPreAppCheck');
        RETURN errnums.C_BIZ_RULE_INVALID;
    end if;
    ------------------------------------Kien tra han muc cap phai nho hon han muc con lai cua user---------------
 /*   begin
        select min(ul.allocatelimmit), min(ul.acctlimit)
            into l_allocatelimmit, l_acctlimit
        from userlimit ul
        where ul.usertype = p_txmsg.txfields(c_usertype).value and ul.TLIDUSER = p_txmsg.txfields(c_userid).value;

        select l_allocatelimmit - nvl(sum(decode(ual.typereceive,'MR',acclimit, 0)),0), nvl(sum(decode(ual.typereceive,'MR',acclimit, 0)),0)
            into l_remainlimit, l_usedlimit
        from useraflimit ual
        where ual.typeallocate = p_txmsg.txfields(c_usertype).value and ual.TLIDUSER = p_txmsg.txfields(c_userid).value and ual.typereceive = 'MR';

        select l_acctlimit - nvl(sum(decode(ual.typereceive,'MR',acclimit, 0)),0), nvl(sum(decode(ual.typereceive,'MR',acclimit, 0)),0)
            into l_remainaflimit, l_usedaflimit
        from useraflimit ual
        where ual.typeallocate = p_txmsg.txfields(c_usertype).value and ual.TLIDUSER = p_txmsg.txfields(c_userid).value and ual.typereceive = 'MR'
        and ual.acctno = p_txmsg.txfields(c_acctno).value;
    exception
    when others then
        p_err_code := '-100601'; -- Pre-defined in DEFERROR table
        plog.setendsection (pkgctx, 'fn_txPreAppCheck');
        RETURN errnums.C_BIZ_RULE_INVALID;
    end;*/
   /* if to_number(p_txmsg.txfields(c_acclimit).value) > l_remainlimit then
        p_err_code := '-100602'; -- Pre-defined in DEFERROR table
        plog.setendsection (pkgctx, 'fn_txPreAppCheck');
        RETURN errnums.C_BIZ_RULE_INVALID;
    end if;*/
    ------------------------------------Kiem tra  han muc cap them + han muc da cap < han muc toi da cua 1 user cap cho hop dong -----------

/*    if to_number(p_txmsg.txfields(c_acclimit).value) > l_remainaflimit then
        p_err_code := '-100603'; -- Pre-defined in DEFERROR table
        plog.setendsection (pkgctx, 'fn_txPreAppCheck');
        RETURN errnums.C_BIZ_RULE_INVALID;
    end if;
*/
    -------------------------------------Kiem tra tong han muc cua cac hop dong phai nho hon han muc cua khach hang khi da cap--------------------------------------------------
    select mrloanlimit into l_mrloanlimit from cfmast cf, afmast af where cf.custid = af.custid and af.acctno =  p_txmsg.txfields(c_acctno).value;
    if l_mrloanlimit < to_number(p_txmsg.txfields(c_acclimit).value) + l_usedaflimit then
        p_err_code := '-100607'; -- Pre-defined in DEFERROR table
        plog.setendsection (pkgctx, 'fn_txPreAppCheck');
        RETURN errnums.C_BIZ_RULE_INVALID;
    end if;

    SELECT to_number(VARVALUE) into l_MaxDebtCF FROM SYSVAR WHERE GRNAME = 'MARGIN' AND VARNAME = 'MAXDEBTCF';
    select count(1) into l_count from afmast af, aftype aft0
    where af.acctno = p_txmsg.txfields(c_acctno).value and af.actype = aft0.actype
    and (exists (select 1 from lntype lnt1 where lnt1.actype = aft0.lntype and lnt1.chksysctrl = 'Y')
        or
        exists (select 1 from afidtype afi, lntype lnt2 where afi.objname = 'LN.LNTYPE' and afi.actype = lnt2.actype and lnt2.chksysctrl = 'Y' and aft0.actype = afi.aftype));
    if l_count > 0 then
        if l_MaxDebtCF < l_usedaflimit + to_number(p_txmsg.txfields(c_acclimit).value) then
            p_err_code := '-100610'; -- Pre-defined in DEFERROR table
            plog.setendsection (pkgctx, 'fn_txPreAppCheck');
            RETURN errnums.C_BIZ_RULE_INVALID;
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
      plog.error (pkgctx, dbms_utility.format_error_backtrace);
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
l_count number(20,0);
BEGIN
    plog.setbeginsection (pkgctx, 'fn_txAftAppUpdate');
    plog.debug (pkgctx, '<<BEGIN OF fn_txAftAppUpdate');
   /***************************************************************************************************
    ** PUT YOUR SPECIFIC AFTER PROCESS HERE. DO NOT COMMIT/ROLLBACK HERE, THE SYSTEM WILL DO IT
    ***************************************************************************************************/
   -- if p_txmsg.deltd <> 'Y' then

    /*    SELECT count(1) into l_count FROM USERAFLIMIT WHERE TYPERECEIVE='MR' AND ACCTNO= p_txmsg.txfields(c_acctno).value AND TLIDUSER= p_txmsg.txfields(c_userid).value and typeallocate = p_txmsg.txfields(c_usertype).value;
        if l_count > 0 then
            update useraflimit
            set acclimit = acclimit + to_number(p_txmsg.txfields(c_acclimit).value)
            where TYPERECEIVE='MR' AND ACCTNO= p_txmsg.txfields(c_acctno).value AND TLIDUSER= p_txmsg.txfields(c_userid).value and typeallocate = p_txmsg.txfields(c_usertype).value;
        else
            INSERT INTO USERAFLIMIT(ACCTNO,ACCLIMIT,TLIDUSER,TYPEALLOCATE,TYPERECEIVE)
            VALUES(p_txmsg.txfields(c_acctno).value,to_number(p_txmsg.txfields(c_acclimit).value),
            p_txmsg.txfields(c_userid).value,p_txmsg.txfields(c_usertype).value,'MR');
        end if;*/
/*        update userlimit ul
        set ul.usedlimmit = usedlimmit + to_number(p_txmsg.txfields(c_acclimit).value)
        where TLIDUSER= p_txmsg.txfields(c_userid).value and ul.usertype = p_txmsg.txfields(c_usertype).value;

        --- Cap nhat vao bang useraflimitlog
        INSERT INTO USERAFLIMITLOG(TXDATE,TXNUM,ACCTNO,ACCLIMIT,TLIDUSER,TYPEALLOCATE,TYPERECEIVE)
        VALUES(p_txmsg.txdate,p_txmsg.txnum,p_txmsg.txfields(c_acctno).value,to_number(p_txmsg.txfields(c_acclimit).value),
        p_txmsg.txfields(c_userid).value,p_txmsg.txfields(c_usertype).value,'MR');*/

    --end if;
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
         plog.init ('TXPKS_#1813EX',
                    plevel => NVL(logrow.loglevel,30),
                    plogtable => (NVL(logrow.log4table,'N') = 'Y'),
                    palert => (NVL(logrow.log4alert,'N') = 'Y'),
                    ptrace => (NVL(logrow.log4trace,'N') = 'Y')
            );
END TXPKS_#1813EX;

/
