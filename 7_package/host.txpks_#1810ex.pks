SET DEFINE OFF;
CREATE OR REPLACE PACKAGE txpks_#1810ex
/**----------------------------------------------------------------------------------------------------
 ** Package: TXPKS_#1810EX
 ** and is copyrighted by FSS.
 **
 **    All rights reserved.  No part of this work may be reproduced, stored in a retrieval system,
 **    adopted or transmitted in any form or by any means, electronic, mechanical, photographic,
 **    graphic, optic recording or otherwise, translated in any language or computer language,
 **    without the prior written permission of Financial Software Solutions. JSC.
 **
 **  MODIFICATION HISTORY
 **  Person      Date           Comments
 **  System      23/12/2011     Created
 **
 ** (c) 2008 by Financial Software Solutions. JSC.
 ** ----------------------------------------------------------------------------------------------------*/
IS
FUNCTION fn_txPreAppCheck(p_txmsg in out tx.msg_rectype,p_err_code out varchar2)
RETURN NUMBER;
FUNCTION fn_txAftAppCheck(p_txmsg in tx.msg_rectype,p_err_code out varchar2)
RETURN NUMBER;
FUNCTION fn_txPreAppUpdate(p_txmsg in tx.msg_rectype,p_err_code out varchar2)
RETURN NUMBER;
FUNCTION fn_txAftAppUpdate(p_txmsg in tx.msg_rectype,p_err_code out varchar2)
RETURN NUMBER;
END;

 
 
 
 
/


CREATE OR REPLACE PACKAGE BODY txpks_#1810ex
IS
   pkgctx   plog.log_ctx;
   logrow   tlogdebug%ROWTYPE;

   c_custodycd        CONSTANT CHAR(2) := '88';
   c_usertype         CONSTANT CHAR(2) := '02';
   c_userid           CONSTANT CHAR(2) := '01';
   c_acctno           CONSTANT CHAR(2) := '03';
   c_toamt            CONSTANT CHAR(2) := '10';
   c_rlimit           CONSTANT CHAR(2) := '12';
   c_acclimit         CONSTANT CHAR(2) := '11';
   c_custavllimit     CONSTANT CHAR(2) := '16';
   c_desc             CONSTANT CHAR(2) := '30';
FUNCTION fn_txPreAppCheck(p_txmsg in out tx.msg_rectype,p_err_code out varchar2)
RETURN NUMBER
IS

l_AVLALLOCATE   number(20,4);
l_T0MAX         number(20,4);
l_T0ALLOC       number(20,4);
l_T0            number(20,4);
l_OVAMT         number(20,4);
l_count         number(10);
l_custid        varchar2(20);
l_toamt         number(20);
l_reacctno      varchar2(20);
l_gracctno      varchar2(20);
l_grt0max       number(20);
l_grt0          number(20);
L_ISDEBTT0      VARCHAR2(1);
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
    --Check xem co tieu khoan nao bi call khong
    if not cspks_cfproc.pr_check_Account_Call(p_txmsg.txfields('88').value) then
        p_err_code := '-200900';
        RETURN errnums.C_BIZ_RULE_INVALID;
    end if;

    if p_txmsg.deltd <> 'Y' then

        SELECT COUNT(*) INTO l_count FROM AFTYPE AFT, AFMAST AF
        WHERE AFT.actype  = AF.actype
            AND AF.acctno = p_txmsg.txfields(c_acctno).value
            AND AFT.T0lntype IS NOT NULL;
        if l_count <= 0 then
            p_err_code := '-180060'; -- Pre-defined in DEFERROR table
            plog.setendsection (pkgctx, 'fn_txPreAppCheck');
            RETURN errnums.C_BIZ_RULE_INVALID;
        end if;
        l_count := 0;
        select  T0LOANLIMIT-af.advanceline
            into l_AVLALLOCATE
        from cfmast cf,
            (select  custid,  sum(advanceline) advanceline
                from afmast
                group by custid) af, afmast afc
        where afc.acctno=p_txmsg.txfields(c_acctno).value and cf.custid = af.custid and afc.custid = cf.custid;

        if l_AVLALLOCATE < to_number(p_txmsg.txfields(c_toamt).value) then
            p_err_code := '-180052'; -- Pre-defined in DEFERROR table
            plog.setendsection (pkgctx, 'fn_txPreAppCheck');
            RETURN errnums.C_BIZ_RULE_INVALID;
        end if;

        begin
            select ul.t0, ul.t0max, nvl(t0acclimit,0) t0acclimit
                into l_T0, l_T0MAX, l_T0ALLOC
            from userlimit ul, (select tliduser,sum(decode(typereceive,'T0',acclimit, 0)) t0acclimit,sum(decode(typereceive,'MR',acclimit, 0)) mracclimit
                                from useraflimit
                                where typeallocate = p_txmsg.txfields(c_usertype).value and TLIDUSER = p_txmsg.txfields(c_userid).value
                                group by tliduser
                                ) uflt
            where ul.tliduser = p_txmsg.txfields(c_userid).value and ul.usertype = p_txmsg.txfields(c_usertype).value and ul.tliduser = uflt.tliduser(+);
        exception when others then
            p_err_code := '-180030'; -- Pre-defined in DEFERROR table
            plog.setendsection (pkgctx, 'fn_txPreAppCheck');
            RETURN errnums.C_BIZ_RULE_INVALID;
        end;

        if l_T0 - l_T0ALLOC < to_number(p_txmsg.txfields(c_toamt).value) then
            p_err_code := '-180031'; -- Pre-defined in DEFERROR table
            plog.setendsection (pkgctx, 'fn_txPreAppCheck');
            RETURN errnums.C_BIZ_RULE_INVALID;
        end if;

        SELECT nvl(SUM(ACCLIMIT),0)
            into l_T0ALLOC
        FROM USERAFLIMIT L
        WHERE TYPERECEIVE='T0' AND TLIDUSER= p_txmsg.txfields(c_userid).value
        AND TYPEALLOCATE = p_txmsg.txfields(c_usertype).value and ACCTNO = p_txmsg.txfields(c_acctno).value;

        if l_T0MAX - l_T0ALLOC < to_number(p_txmsg.txfields(c_toamt).value) THEN
            p_err_code := '-180032'; -- Pre-defined in DEFERROR table
            plog.setendsection (pkgctx, 'fn_txPreAppCheck');
            RETURN errnums.C_BIZ_RULE_INVALID;
        end if;
        l_count := 0;

        --BEGIN DUNGNH

        l_toamt := 0;

        SELECT ISDEBTT0 INTO L_ISDEBTT0 FROM AFMAST
        WHERE ACCTNO = p_txmsg.txfields(c_acctno).value;

        SELECT SUM(oprinnml+oprinovd) into l_toamt
        FROM LNMAST LN, AFMAST AF, CFMAST CF
        WHERE LN.trfacctno = AF.acctno AND AF.custid = CF.custid
            AND CF.custodycd = p_txmsg.txfields(c_custodycd).value;
        if(l_toamt > 0 OR NVL(L_ISDEBTT0,'N') = 'Y') then
            p_err_code := '-180058'; -- Pre-defined in DEFERROR table
            plog.setendsection (pkgctx, 'fn_txPreAppCheck');
            RETURN errnums.C_BIZ_RULE_INVALID;
        end if;

        select MAX(custid) INTO l_custid from cfmast where custodycd = p_txmsg.txfields(c_custodycd).value;
        select COUNT(*) INTO l_count
        from recflnk reu, reaflnk rea, REMAST RE, RETYPE RET
        where reu.AUTOID = rea.refrecflnkid AND REA.STATUS = 'A'
            AND REA.REACCTNO = RE.ACCTNO AND RE.ACTYPE = RET.ACTYPE
            AND RET.retype = 'D' AND RET.rerole = 'CS'
            AND REU.TLID = p_txmsg.txfields(c_userid).value
            AND REA.afacctno = l_custid
            AND REA.frdate <= p_txmsg.TXDATE
            AND NVL(REA.clstxdate,REA.TODATE) > p_txmsg.TXDATE;

        if l_count <= 0 then
            p_err_code := '-180059'; -- Pre-defined in DEFERROR table
            plog.setendsection (pkgctx, 'fn_txPreAppCheck');
            RETURN errnums.C_BIZ_RULE_INVALID;
        end if;

        for rec in (
            select distinct REA.afacctno
        from recflnk reu, reaflnk rea, REMAST RE, RETYPE RET
        where reu.autoid = rea.refrecflnkid AND REA.STATUS = 'A'
            AND REA.REACCTNO = RE.ACCTNO AND RE.ACTYPE = RET.ACTYPE
            AND RET.retype = 'D' AND RET.rerole = 'CS'
            AND REU.TLID = p_txmsg.txfields(c_userid).value
            AND REA.frdate <= p_txmsg.TXDATE
            AND NVL(REA.clstxdate,REA.TODATE) > p_txmsg.TXDATE
        )
        loop
            l_toamt := 0;
            SELECT SUM(oprinnml+oprinovd) into l_toamt
            FROM LNMAST LN, AFMAST AF
            WHERE LN.trfacctno = AF.acctno AND AF.custid = rec.afacctno;
            l_toamt := NVL(l_toamt,0);
            L_ISDEBTT0 := 'N';
            SELECT ISDEBTT0 INTO L_ISDEBTT0 FROM AFMAST
            WHERE ACCTNO = p_txmsg.txfields(c_acctno).value;

            if(l_toamt > 0 OR NVL(L_ISDEBTT0,'N') = 'Y') then
                p_err_code := '-180057'; -- Pre-defined in DEFERROR table
                plog.setendsection (pkgctx, 'fn_txPreAppCheck');
                RETURN errnums.C_BIZ_RULE_INVALID;
            end if;
        end loop;

        select max(rea.reacctno) INTO l_reacctno
        from recflnk reu, reaflnk rea, REMAST RE, RETYPE RET
        where reu.autoid = rea.refrecflnkid AND REA.STATUS = 'A'
            AND REA.REACCTNO = RE.ACCTNO AND RE.ACTYPE = RET.ACTYPE
            AND RET.retype = 'D' AND RET.rerole = 'CS'
            AND REU.TLID = p_txmsg.txfields(c_userid).value
            AND REA.afacctno = l_custid
            AND REA.frdate <= p_txmsg.TXDATE
            AND NVL(REA.CLSTXDATE,REA.TODATE) > p_txmsg.TXDATE;
        l_count := 0;
        select count(*) into l_count from regrplnk
        where status = 'A' and reacctno = l_reacctno and frdate <=  p_txmsg.TXDATE and nvl(clstxdate,todate) > p_txmsg.TXDATE;

        if l_count >= 1 then

            select MAX(regrp.autoid), MAX(regrp.t0max) into l_gracctno, l_grt0max from regrplnk, regrp
            where regrplnk.status = 'A' and regrplnk.reacctno = l_reacctno
                and regrplnk.frdate <= p_txmsg.TXDATE and NVL(regrplnk.clstxdate,regrplnk.todate) > p_txmsg.TXDATE
                and regrplnk.refrecflnkid = regrp.autoid;

            select sum(acclimit) into l_grt0
            from useraflimit us, (
                select distinct re.afacctno
                from
                (
                    select distinct rea.reacctno, af.acctno afacctno
                    from reaflnk rea, afmast af
                    where rea.status = 'A' and frdate <= getcurrdate
                    and NVL(clstxdate,todate) > getcurrdate
                    and rea.afacctno = af.custid
                ) re, regrplnk reg
                where re.reacctno = reg.reacctno and reg.refrecflnkid = l_gracctno
                    and reg.status = 'A' and frdate <= getcurrdate
                    and NVL(clstxdate,todate) > getcurrdate
            ) re
            where us.typereceive = 'T0'
                and us.acctno = re.afacctno;
            l_grt0 := NVL(l_grt0,0);

            if l_grt0max < l_grt0 + p_txmsg.txfields(c_toamt).value then
                p_err_code := '-180055'; -- Pre-defined in DEFERROR table
                plog.setendsection (pkgctx, 'fn_txPreAppCheck');
                RETURN errnums.C_BIZ_RULE_INVALID;
            end if;


            FOR REC1 IN (
                select DISTINCT regrplnk.reacctno
                from regrplnk
                where regrplnk.status = 'A'
                    and regrplnk.frdate <= p_txmsg.TXDATE and NVL(regrplnk.clstxdate,regrplnk.todate) > p_txmsg.TXDATE
                    and regrplnk.refrecflnkid = l_gracctno
            )
            LOOP
                for rec in (
                    select distinct REA.afacctno
                    from reaflnk rea, REMAST RE, RETYPE RET
                    where REA.STATUS = 'A'
                        AND REA.REACCTNO = RE.ACCTNO AND RE.ACTYPE = RET.ACTYPE
                        AND RET.retype = 'D' AND RET.rerole = 'CS'
                        AND REA.reacctno = REC1.reacctno
                        AND REA.frdate <= p_txmsg.TXDATE
                        AND NVL(REA.clstxdate,REA.TODATE) > p_txmsg.TXDATE
                )
                loop

                    l_toamt := 0;
                    SELECT SUM(oprinnml+oprinovd) into l_toamt
                    FROM LNMAST LN, AFMAST AF
                    WHERE LN.trfacctno = AF.acctno AND AF.custid = rec.afacctno;
                    l_toamt := NVL(l_toamt,0);
                    L_ISDEBTT0 := 'N';
                    SELECT ISDEBTT0 INTO L_ISDEBTT0 FROM AFMAST
                    WHERE ACCTNO = p_txmsg.txfields(c_acctno).value;

                    if(l_toamt > 0 OR NVL(L_ISDEBTT0,'N') = 'Y') then
                        p_err_code := '-180056'; -- Pre-defined in DEFERROR table
                        plog.setendsection (pkgctx, 'fn_txPreAppCheck');
                        RETURN errnums.C_BIZ_RULE_INVALID;
                    end if;
                end loop;
            END LOOP;

        end if;
        --- END DUNGNH

/*
        l_count := 0;
        select count(1) into l_count
        from afmast af, tlgrpusers tlgrur, tlgroups tlgr
        where acctno = p_txmsg.txfields(c_acctno).value
        and af.careby = tlgrur.grpid
        and tlgrur.grpid = tlgr.grpid
        and tlgr.grptype = '2'
        and tlgrur.tlid = p_txmsg.txfields(c_userid).value;
        if l_count <= 0 then
            p_err_code := '-200211'; -- Pre-defined in DEFERROR table
            plog.setendsection (pkgctx, 'fn_txPreAppCheck');
            RETURN errnums.C_BIZ_RULE_INVALID;
        end if;
        SELECT OVAMT into l_OVAMT FROM CIMAST WHERE ACCTNO =p_txmsg.txfields(c_acctno).value;
        if l_OVAMT > 1 then
           p_txmsg.ovrrqd := p_txmsg.ovrrqd || '@19';
        end if;*/
    end if;

    plog.debug (pkgctx, '<<END OF fn_txPreAppCheck');
    plog.setendsection (pkgctx, 'fn_txPreAppCheck');
    RETURN systemnums.C_SUCCESS;
EXCEPTION
WHEN OTHERS
   THEN
      p_err_code := errnums.C_SYSTEM_ERROR;
      plog.error (pkgctx, SQLERRM || '--' || dbms_utility.format_error_backtrace);
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
    if p_txmsg.deltd <> 'Y' then
        SELECT count(1) into l_count
        FROM USERAFLIMIT L
        WHERE TYPERECEIVE='T0'
        AND TLIDUSER=p_txmsg.txfields(c_userid).value
        AND TYPEALLOCATE =p_txmsg.txfields(c_usertype).value  and ACCTNO =p_txmsg.txfields(c_acctno).value;

        if l_count > 0 then
            UPDATE USERAFLIMIT
            SET ACCLIMIT=ACCLIMIT+to_number(p_txmsg.txfields(c_toamt).value)
            WHERE TYPERECEIVE='T0' AND TLIDUSER=p_txmsg.txfields(c_userid).value
            AND TYPEALLOCATE =p_txmsg.txfields(c_usertype).value and ACCTNO =p_txmsg.txfields(c_acctno).value;
        else
            INSERT INTO USERAFLIMIT (ACCTNO,ACCLIMIT,TLIDUSER,TYPEALLOCATE,TYPERECEIVE)
            VALUES (p_txmsg.txfields(c_acctno).value,to_number(p_txmsg.txfields(c_toamt).value),p_txmsg.txfields(c_userid).value,
            p_txmsg.txfields(c_usertype).value,'T0');
        end if;

        INSERT INTO USERAFLIMITLOG (TXNUM,TXDATE,ACCTNO,ACCLIMIT,TLIDUSER,TYPEALLOCATE,TYPERECEIVE)
        VALUES (p_txmsg.txnum,p_txmsg.txdate,p_txmsg.txfields(c_acctno).value,to_number(p_txmsg.txfields(c_toamt).value),
        p_txmsg.txfields(c_userid).value,p_txmsg.txfields(c_usertype).value,'T0');

        INSERT INTO T0LIMITSCHD(AUTOID, TLID, TYPEALLOCATE, ACCTNO, ALLOCATEDDATE, ALLOCATEDLIMIT, RETRIEVEDLIMIT)
        VALUES(SEQ_T0LIMITSCHD.NEXTVAL, p_txmsg.txfields(c_userid).value, p_txmsg.txfields(c_usertype).value, p_txmsg.txfields(c_acctno).value,
        p_txmsg.txdate, to_number(p_txmsg.txfields(c_toamt).value), 0);
    end if;

    update t0aflimit_import
    set status = 'C'
    where afacctno = p_txmsg.txfields(c_acctno).value;

    plog.debug (pkgctx, '<<END OF fn_txAftAppUpdate');
    plog.setendsection (pkgctx, 'fn_txAftAppUpdate');
    RETURN systemnums.C_SUCCESS;
EXCEPTION
WHEN OTHERS
   THEN
      p_err_code := errnums.C_SYSTEM_ERROR;
      plog.error (pkgctx, SQLERRM || '--' || dbms_utility.format_error_backtrace);
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
         plog.init ('TXPKS_#1810EX',
                    plevel => NVL(logrow.loglevel,30),
                    plogtable => (NVL(logrow.log4table,'N') = 'Y'),
                    palert => (NVL(logrow.log4alert,'N') = 'Y'),
                    ptrace => (NVL(logrow.log4trace,'N') = 'Y')
            );
END TXPKS_#1810EX;
/
