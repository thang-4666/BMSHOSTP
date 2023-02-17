SET DEFINE OFF;
CREATE OR REPLACE PACKAGE txpks_#0088ex
/**----------------------------------------------------------------------------------------------------
 ** Package: TXPKS_#0088EX
 ** and is copyrighted by FSS.
 **
 **    All rights reserved.  No part of this work may be reproduced, stored in a retrieval system,
 **    adopted or transmitted in any form or by any means, electronic, mechanical, photographic,
 **    graphic, optic recording or otherwise, translated in any language or computer language,
 **    without the prior written permission of Financial Software Solutions. JSC.
 **
 **  MODIFICATION HISTORY
 **  Person      Date           Comments
 **  System      16/09/2011     Created
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


CREATE OR REPLACE PACKAGE BODY txpks_#0088ex
IS
   pkgctx   plog.log_ctx;
   logrow   tlogdebug%ROWTYPE;

   c_acctno           CONSTANT CHAR(2) := '02';
   c_setacctno        CONSTANT CHAR(2) := '03';
   c_custodycd        CONSTANT CHAR(2) := '88';
   c_name             CONSTANT CHAR(2) := '31';
   c_idcode           CONSTANT CHAR(2) := '32';
   c_balance          CONSTANT CHAR(2) := '10';
   c_crintacr         CONSTANT CHAR(2) := '04';
   c_odamt            CONSTANT CHAR(2) := '06';
   c_odintacr         CONSTANT CHAR(2) := '05';
   c_ciwithdrawal     CONSTANT CHAR(2) := '07';
   c_blocked          CONSTANT CHAR(2) := '08';
   c_withdraw         CONSTANT CHAR(2) := '09';
   c_deposit          CONSTANT CHAR(2) := '11';
   c_mrcrlimitmax     CONSTANT CHAR(2) := '12';
   c_mrcrlimit        CONSTANT CHAR(2) := '13';
   c_t0amt            CONSTANT CHAR(2) := '14';
   c_ca_qtty          CONSTANT CHAR(2) := '15';
   c_groupleader      CONSTANT CHAR(2) := '16';
   c_cidepofeeacr     CONSTANT CHAR(2) := '66';
   c_datefeeac        CONSTANT CHAR(2) := '18';
   c_cidatefeeacr     CONSTANT CHAR(2) := '17';
   c_chk_qtty         CONSTANT CHAR(2) := '67';
   c_trfee            CONSTANT CHAR(2) := '68';
   c_desc             CONSTANT CHAR(2) := '30';
   c_closetype        CONSTANT CHAR(2) := '80';
   c_desttype         CONSTANT CHAR(2) := '81';

FUNCTION fn_txPreAppCheck(p_txmsg in out tx.msg_rectype,p_err_code out varchar2)
RETURN NUMBER
IS

v_EMKAMT number;
v_withdraw number;
v_deposit number;
v_blocked number;

v_sumse number;
v_sumci number;
v_mrcount number;
V_OUTSTANDING NUMBER;
V_MRCRLIMITMAX NUMBER;
V_MRCRLIMIT NUMBER;
v_T0AMT NUMBER;
v_CHK_QTTY NUMBER;
V_STANDING NUMBER;
v_DF_QTTY NUMBER;
v_depofeeamt NUMBER ;
v_cidepofeeacr NUMBER ;
    l_leader_license varchar2(100);
    l_leader_idexpired date;
    l_count number;

    l_CURRDATE date;


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
    --- check con su kien chua phan bo thi canh bao.

    IF (p_txmsg.txfields('80').value = '001')THEN
        SELECT COUNT(1) INTO l_count
        FROM caschd ca, afmast af, cfmast cf
        WHERE ca.deltd = 'N' AND ca.isexec = 'Y'
            AND ((ca.isse = 'N' AND ca.qtty>0)or(ca.isci = 'N' AND ca.amt > 0))
            and ca.afacctno = af.acctno and cf.custid = af.custid
            and cf.custodycd = p_txmsg.txfields('88').value;
    ELSE
        SELECT COUNT(1) INTO l_count
        FROM caschd ca, afmast af, cfmast cf
        WHERE ca.deltd = 'N' AND ca.isexec = 'Y'
            AND ((ca.isse = 'N' AND ca.qtty>0)or(ca.isci = 'N' AND ca.amt > 0))
            and ca.afacctno = af.acctno and cf.custid = af.custid
            and ca.afacctno = p_txmsg.txfields('02').value;
    END IF;

    if l_count >= 1 then
        p_txmsg.txWarningException('-2004141').value:= cspks_system.fn_get_errmsg('-200414');
        p_txmsg.txWarningException('-2004141').errlev:= '1';
    end if;

    -- Check neu Loai dong la Tai khoan. Bat buoc, So tieu khoan phai chon ALL.
    if (p_txmsg.txfields('80').value = '001' and instr(p_txmsg.txfields('02').value,'ALL') = 0)
            or (p_txmsg.txfields('80').value <> '001' and instr(p_txmsg.txfields('02').value,'ALL') <> 0)
            or (p_txmsg.txfields('80').value <> '001' and p_txmsg.txfields('03').value <> p_txmsg.txfields('02').value) then
        p_err_code := '-200408'; -- Pre-defined in DEFERROR table
        plog.setendsection (pkgctx, 'fn_txPreAppCheck');
        RETURN errnums.C_BIZ_RULE_INVALID;
    end if;
    -- Check trang thai tieu khoan.
    for rec in
    (
        select af.acctno, af.status, ci.odamt, ci.ODINTACR, ci.depofeeamt, ci.cidepofeeacr
        from afmast af, cfmast cf, cimast ci
        where af.custid = cf.custid and af.acctno = ci.acctno and cf.custodycd = p_txmsg.txfields('88').value and af.status not in ('N','C')
        and (p_txmsg.txfields('80').value = '001' or (p_txmsg.txfields('80').value = '002' and p_txmsg.txfields('02').value = af.acctno))
    )
    loop
        if rec.status not in ('A','G') then
            p_err_code := '-200010'; -- Pre-defined in DEFERROR table
            plog.setendsection (pkgctx, 'fn_txPreAppCheck');
            RETURN errnums.C_BIZ_RULE_INVALID;
        end if;

        --Kiem tra neu tai khoan la margin co ky han thi neu ODINT + ODAMT > 0 thi khong cho lam.
        --Bat phai tra no het theo ky han thi moi duoc lam
        if(rec.odamt +rec.ODINTACR)>0 then
            Begin
                SELECT count(1) INTO v_mrcount FROM AFMAST AF, AFTYPE AT, MRTYPE MT
                where AF.ACCTNO=rec.acctno
                AND AF.ACTYPE =AT.ACTYPE AND AT.MRTYPE = MT.ACTYPE AND MT.MRTYPE ='T';
            EXCEPTION
                WHEN OTHERS   THEN
                v_mrcount :=0;
            END;

            if v_mrcount>0 then
                p_err_code := '-200070'; -- Pre-defined in DEFERROR table
                plog.setendsection (pkgctx, 'fn_txAftAppUpdate');
                RETURN errnums.C_BIZ_RULE_INVALID;
            end if;
        end if;
        --HaiLT them
/*        -- Tien luu ky con thi ko cho chuyen
        if rec.depofeeamt + rec.cidepofeeacr >0 then
            p_err_code := '-100430';
            plog.setendsection (pkgctx, 'fn_txAftAppUpdate');
            RETURN errnums.C_BIZ_RULE_INVALID;
        end if;*/

        -- Con so du chung khoan cho luu ky thi ko cho chuyen
        select count(1) INTO v_mrcount from semast where afacctno =rec.acctno and nvl(SENDDEPOSIT,0) > 0;
        if v_mrcount>0 then
            p_err_code := '-200064'; -- Pre-defined in DEFERROR table
            plog.setendsection (pkgctx, 'fn_txAftAppUpdate');
            RETURN errnums.C_BIZ_RULE_INVALID;
        end if;

        -- Con so du Cho` rut CK thi ko cho chuyen
        select count(1) INTO v_mrcount from SEWITHDRAWDTL where afacctno =rec.acctno and status='A';
        if v_mrcount>0 then
            p_err_code := '-900026'; -- Pre-defined in DEFERROR table
            plog.setendsection (pkgctx, 'fn_txAftAppUpdate');
            RETURN errnums.C_BIZ_RULE_INVALID;
        end if;

        -- Con so du CK LO LE thi ko cho chuyen
        select count(1) INTO v_mrcount from SERETAIL where acctno LIKE rec.acctno || '%' and status NOT IN ('C','R');
        if v_mrcount>0 then
            p_err_code := '-201182'; -- Pre-defined in DEFERROR table
            plog.setendsection (pkgctx, 'fn_txAftAppUpdate');
            RETURN errnums.C_BIZ_RULE_INVALID;
        end if;

        -- Con CK cho` chuyen khoan thi ko cho chuyen
        select count(1) INTO v_mrcount from SESENDOUT where acctno LIKE rec.acctno || '%' and status='S';
        if v_mrcount>0 then
            p_err_code := '-201181'; -- Pre-defined in DEFERROR table
            plog.setendsection (pkgctx, 'fn_txAftAppUpdate');
            RETURN errnums.C_BIZ_RULE_INVALID;
        end if;

        -- End of HaiLT them

    end loop;

    -- Neu co Can chuyen CK la Y, bat buoc nhap ma thanh vien chuyen di va so tai khoan luu ky chuyen di.
    if(p_txmsg.txfields('45').value ='Y') THEN
         if((LENGTH(nvl(p_txmsg.txfields('48').value,'X'))<3) or(LENGTH(nvl(p_txmsg.txfields('47').value,'X'))<10)) THEN
          p_err_code:='-260163';
          plog.setendsection (pkgctx, 'fn_txPreAppCheck');
          RETURN errnums.C_BIZ_RULE_INVALID;
         END IF;
    END IF;

    BEGIN
        select idcode, idexpired into l_leader_license, l_leader_idexpired
        from cfmast cf
        where cf.custodycd = p_txmsg.txfields('88').value;
    EXCEPTION WHEN OTHERS THEN
        p_err_code:='-900096';
        plog.setendsection (pkgctx, 'fn_txPreAppCheck');
        RETURN errnums.C_BIZ_RULE_INVALID;
    END;

    IF l_leader_idexpired < p_txmsg.txdate THEN --leader expired
            p_txmsg.txWarningException('-2002081').value:= cspks_system.fn_get_errmsg('-200208');
            p_txmsg.txWarningException('-2002081').errlev:= '1';
    END IF;


    SELECT TO_DATE (varvalue, systemnums.c_date_format)
               INTO l_CURRDATE
               FROM sysvar
               WHERE grname = 'SYSTEM' AND varname = 'CURRDATE';

    begin
        if p_txmsg.txfields('80').value = '001' then
            Begin
                SELECT sum(EMKAMT) EMKAMT,sum(OUTSTANDING) OUTSTANDING,sum(MRCRLIMITMAX) MRCRLIMITMAX,
                sum(MRCRLIMIT) MRCRLIMIT,sum(T0AMT) T0AMT,sum(NB_CHK_QTTY+NS_CHK_QTTY) CHK_QTTY,sum(EMKQTTY) EMKQTTY /*sum(BLOCKED) BLOCKED*/,sum(DF_QTTY) DF_QTTY,sum(STANDING) STANDING,
                       ROUND(sum(depofeeamt),0),round(sum(cidepofeeacr),0)
                INTO v_EMKAMT,V_OUTSTANDING,V_MRCRLIMITMAX,V_MRCRLIMIT,v_T0AMT,v_CHK_QTTY,v_blocked,v_DF_QTTY,V_STANDING,
                       v_depofeeamt, v_cidepofeeacr
                FROM VW_AFMAST_FOR_CLOSE_ACCOUNT
                WHERE CUSTODYCD=p_txmsg.txfields('88').value
                group by custodycd;
            EXCEPTION
                WHEN OTHERS   THEN
                v_EMKAMT:=0;
                V_OUTSTANDING:=0;
                V_MRCRLIMITMAX:=0;
                v_MRCRLIMIT:=0;
                v_T0AMT:=0;
                v_CHK_QTTY:=0;
                v_blocked:=0;
                v_DF_QTTY:=0;
                V_STANDING:=0;
                v_depofeeamt:=0;
                v_cidepofeeacr:=0;

            end;
        else
            Begin
                SELECT EMKAMT,OUTSTANDING,MRCRLIMITMAX,MRCRLIMIT,T0AMT,(NB_CHK_QTTY+NS_CHK_QTTY)CHK_QTTY, EMKQTTY, /*BLOCKED,*/ DF_QTTY,STANDING,
                       round(depofeeamt,0),round(cidepofeeacr,0)
                INTO v_EMKAMT,V_OUTSTANDING,V_MRCRLIMITMAX,V_MRCRLIMIT,v_T0AMT,v_CHK_QTTY,v_blocked,v_DF_QTTY,V_STANDING,
                       v_depofeeamt, v_cidepofeeacr
                FROM VW_AFMAST_FOR_CLOSE_ACCOUNT
                WHERE AFACCTNO=p_txmsg.txfields('03').value;
            EXCEPTION
                WHEN OTHERS   THEN
                v_EMKAMT:=0;
                V_OUTSTANDING:=0;
                V_MRCRLIMITMAX:=0;
                v_MRCRLIMIT:=0;
                v_T0AMT:=0;
                v_CHK_QTTY:=0;
                v_blocked:=0;
                v_DF_QTTY:=0;
                V_STANDING:=0;
                v_depofeeamt:=0;
                v_cidepofeeacr:=0;
            end;
        end if;

        if v_EMKAMT <>0 then
            p_err_code:='-400205';
            plog.setendsection(pkgctx, 'fn_txPreAppCheck');
            RETURN errnums.C_BIZ_RULE_INVALID;
        end if;

        if V_OUTSTANDING <>0 then
            p_err_code:='-400206';
            plog.setendsection(pkgctx, 'fn_txPreAppCheck');
            RETURN errnums.C_BIZ_RULE_INVALID;
        end if;

        if V_STANDING <>0 then
            p_err_code:='-260156';
            plog.setendsection(pkgctx, 'fn_txPreAppCheck');
            RETURN errnums.C_BIZ_RULE_INVALID;
        end if;

        if v_MRCRLIMIT <>0 then
            p_err_code:='-260157';
            plog.setendsection(pkgctx, 'fn_txPreAppCheck');
            RETURN errnums.C_BIZ_RULE_INVALID;
        end if;
/*
         -- Thu hoi han muc vay
        if V_MRCRLIMITMAX <>0 then
            if p_txmsg.txfields('80').value = '001' then

                v_AccTemp:='%%';
            ELSE
                v_AccTemp:=p_txmsg.txfields('02').value;
            END IF;

            for rec1815 in (
                select cf.custodycd, cf.custid, af.acctno,AF.MRCRLIMITMAX from afmast af, cfmast cf where af.custid =cf.custid
                    and cf.custodycd = p_txmsg.txfields('88').value and af.acctno like v_AccTemp and af.status = 'A'
            )
            LOOP

                SELECT TXDESC,EN_TXDESC into l_OrgDesc, l_EN_OrgDesc FROM  TLTX WHERE TLTXCD='1815';

                l_txmsg.msgtype:='T';
                l_txmsg.local:='N';
                l_txmsg.tlid        := systemnums.c_system_userid;
                plog.debug(pkgctx, 'l_txmsg.tlid' || l_txmsg.tlid);
                SELECT SYS_CONTEXT ('USERENV', 'HOST'),
                         SYS_CONTEXT ('USERENV', 'IP_ADDRESS', 15)
                  INTO l_txmsg.wsname, l_txmsg.ipaddress
                FROM DUAL;
                l_txmsg.off_line    := 'N';
                l_txmsg.deltd       := txnums.c_deltd_txnormal;
                l_txmsg.txstatus    := txstatusnums.c_txcompleted;
                l_txmsg.msgsts      := '0';
                l_txmsg.ovrsts      := '0';
                l_txmsg.batchname   := '';
                l_txmsg.txdate:=l_CURRDATE;
                l_txmsg.busdate:=l_CURRDATE;
                l_txmsg.tltxcd:='1815';
                l_DESC:=l_OrgDesc;
                 --set txnum
                SELECT systemnums.C_BATCH_PREFIXED
                                     || LPAD (seq_BATCHTXNUM.NEXTVAL, 8, '0')
                              INTO l_txmsg.txnum
                              FROM DUAL;
                l_txmsg.brid        := substr(p_txmsg.txfields('02').value,1,4);

                --88  CUSTODYCD       C
                l_txmsg.txfields ('88').defname   := 'CUSTODYCD';
                l_txmsg.txfields ('88').TYPE      := 'C';
                l_txmsg.txfields ('88').VALUE     := rec1815.CUSTODYCD;

                --03  ACCTNO          C
                l_txmsg.txfields ('03').defname   := 'ACCTNO';
                l_txmsg.txfields ('03').TYPE      := 'C';
                l_txmsg.txfields ('03').VALUE     := rec1815.ACCTNO;

                --10  ACCLIMIT        N
                l_txmsg.txfields ('10').defname   := 'ACCTNO';
                l_txmsg.txfields ('10').TYPE      := 'N';
                l_txmsg.txfields ('10').VALUE     := rec1815.MRCRLIMITMAX;

                --11  MRCRLIMITMAX    N
                l_txmsg.txfields ('11').defname   := 'ACCTNO';
                l_txmsg.txfields ('11').TYPE      := 'N';
                l_txmsg.txfields ('11').VALUE     := rec1815.MRCRLIMITMAX;

                --30  DESC            C
                l_txmsg.txfields ('30').defname   := 'DESC';
                l_txmsg.txfields ('30').TYPE      := 'C';
                l_txmsg.txfields ('30').VALUE     := l_DESC;

                --END LOOP;

                BEGIN
                    IF txpks_#1815.fn_batchtxprocess (l_txmsg,
                                                     p_err_code,
                                                     l_err_param
                       ) <> systemnums.c_success
                    THEN
                       plog.debug (pkgctx,
                                   'got error 1815: ' || p_err_code
                       );
                       ROLLBACK;
                       RETURN errnums.C_BIZ_RULE_INVALID;
                    END IF;
                END;

            END LOOP;

        end if;


        if v_T0AMT <>0 then
            if p_txmsg.txfields('80').value = '001' then
                v_AccTemp:='%%';
            ELSE
                v_AccTemp:=p_txmsg.txfields('02').value;
            END IF;

            for rec1811 in (
                SELECT TLID , TLNAME USERNAME, ACCTNO, CUSTODYCD, FULLNAME, ACCLIMIT, USRLIMIT, T0AMT, T0ACCUSER, ADVT0AMT, ADVT0AMT AS ADVT0AMTMAX, ACCUSERHIST, ADVAMTHIST, ADVAMTHIST AS ADVAMTHISTMAX
                FROM VW_ACCOUNT_ADVT0 MST
                where MST.ADVAMTHIST + MST.ADVT0AMT > 0  and custodycd = p_txmsg.txfields('88').value and acctno like v_AccTemp
            )
            LOOP
                SELECT TXDESC,EN_TXDESC into l_OrgDesc, l_EN_OrgDesc FROM  TLTX WHERE TLTXCD='1811';

                l_txmsg.msgtype:='T';
                l_txmsg.local:='N';
                l_txmsg.tlid        := systemnums.c_system_userid;
                plog.debug(pkgctx, 'l_txmsg.tlid' || l_txmsg.tlid);
                SELECT SYS_CONTEXT ('USERENV', 'HOST'),
                         SYS_CONTEXT ('USERENV', 'IP_ADDRESS', 15)
                  INTO l_txmsg.wsname, l_txmsg.ipaddress
                FROM DUAL;
                l_txmsg.off_line    := 'N';
                l_txmsg.deltd       := txnums.c_deltd_txnormal;
                l_txmsg.txstatus    := txstatusnums.c_txcompleted;
                l_txmsg.msgsts      := '0';
                l_txmsg.ovrsts      := '0';
                l_txmsg.batchname   := '';
                l_txmsg.txdate:=l_CURRDATE;
                l_txmsg.busdate:=l_CURRDATE;
                l_txmsg.tltxcd:='1811';
                l_DESC:=l_OrgDesc;
                 --set txnum
                SELECT systemnums.C_BATCH_PREFIXED
                                     || LPAD (seq_BATCHTXNUM.NEXTVAL, 8, '0')
                              INTO l_txmsg.txnum
                              FROM DUAL;
                l_txmsg.brid        := substr(p_txmsg.txfields('02').value,1,4);



                --01  USERID      C
                l_txmsg.txfields ('01').defname   := 'USERID';
                l_txmsg.txfields ('01').TYPE      := 'C';
                l_txmsg.txfields ('01').VALUE     := rec1811.TLID;

                --03  ACCTNO      C
                l_txmsg.txfields ('03').defname   := 'ACCTNO';
                l_txmsg.txfields ('03').TYPE      := 'C';
                l_txmsg.txfields ('03').VALUE     := rec1811.ACCTNO;

                --08  ADVT0AMT    N
                l_txmsg.txfields ('08').defname   := 'ADVT0AMT';
                l_txmsg.txfields ('08').TYPE      := 'N';
                l_txmsg.txfields ('08').VALUE     := rec1811.ADVT0AMT;

                --09  ADVT0AMT    N
                l_txmsg.txfields ('09').defname   := 'ADVT0AMT';
                l_txmsg.txfields ('09').TYPE      := 'N';
                l_txmsg.txfields ('09').VALUE     := rec1811.ADVT0AMT;

                --11  ADVAMTHIST  N
                l_txmsg.txfields ('11').defname   := 'ADVAMTHIST';
                l_txmsg.txfields ('11').TYPE      := 'N';
                l_txmsg.txfields ('11').VALUE     := rec1811.ADVAMTHIST;

                --10  ADVAMTHIST  N
                l_txmsg.txfields ('10').defname   := 'ADVAMTHIST';
                l_txmsg.txfields ('10').TYPE      := 'N';
                l_txmsg.txfields ('10').VALUE     := rec1811.ADVAMTHIST;

                --30  DESC        C
                l_txmsg.txfields ('30').defname   := 'DESC';
                l_txmsg.txfields ('30').TYPE      := 'C';
                l_txmsg.txfields ('30').VALUE     := l_DESC;


                BEGIN
                    IF txpks_#1811.fn_batchtxprocess (l_txmsg,
                                                     p_err_code,
                                                     l_err_param
                       ) <> systemnums.c_success
                    THEN
                       plog.debug (pkgctx,
                                   'got error 1811: ' || p_err_code
                       );
                       ROLLBACK;
                       RETURN errnums.C_BIZ_RULE_INVALID;
                    END IF;
                END;

            END LOOP;



        end if;
*/

        if v_CHK_QTTY <>0 then
            p_err_code:='-260158';
            plog.setendsection(pkgctx, 'fn_txPreAppCheck');
            RETURN errnums.C_BIZ_RULE_INVALID;
        end if;

        if v_blocked <>0 then
            p_err_code:='-260159';
            plog.setendsection(pkgctx, 'fn_txPreAppCheck');
            RETURN errnums.C_BIZ_RULE_INVALID;
        end if;

        if v_DF_QTTY <>0 then
            p_err_code:='-260160';
            plog.setendsection(pkgctx, 'fn_txPreAppCheck');
            RETURN errnums.C_BIZ_RULE_INVALID;
        end if;
        if round(to_number(p_txmsg.txfields('65').value),0) <> v_depofeeamt then
            p_err_code:='-260165';
            plog.setendsection(pkgctx, 'fn_txPreAppCheck');
            RETURN errnums.C_BIZ_RULE_INVALID;
        end if;
        plog.error(pkgctx, 'round(to_number(p_txmsg.txfields().value),0) : ' || round(to_number(p_txmsg.txfields('66').value),0) || ' v_cidepofeeacr :' || v_cidepofeeacr);
        if round(to_number(p_txmsg.txfields('66').value),0) <> v_cidepofeeacr then
            p_err_code:='-260166';
            plog.setendsection(pkgctx, 'fn_txPreAppCheck');
            RETURN errnums.C_BIZ_RULE_INVALID;
        end if;

        BEGIN
            if p_txmsg.txfields('80').value = '001' then
                select SUMCI,SUMSE
                INTO  v_sumci,v_sumse
                from
                    (Select (ROUND(AAMT,0)+ROUND(RAMT,0)+ROUND(BAMT,0)+ROUND(NAMT,0)+ROUND(MMARGINBAL,0)+ROUND(MARGINBAL,0))SUMCI
                        from cimast ci, afmast af, cfmast cf
                        where ci.acctno = af.acctno and af.custid = cf.custid and af.status not in ('N','C')
                        and cf.custodycd =p_txmsg.txfields('88').value)CI,
                    (Select SUM(ROUND(MORTAGE,0)+ROUND(MARGIN,0)+ROUND(NETTING,0)+ROUND(STANDING,0)+ROUND(SECURED,0)+ROUND(WITHDRAW,0) +ROUND(LOAN,0)+ROUND(REPO,0)+ROUND(PENDING,0)+ROUND(TRANSFER,0)) SUMSE
                        from semast se, afmast af, cfmast cf
                        where se.afacctno = af.acctno and af.custid = cf.custid and af.status not in ('N','C')
                        and cf.custodycd =p_txmsg.txfields('88').value)SE;
            else
                select SUMCI,SUMSE
                INTO  v_sumci,v_sumse
                from
                    (Select (ROUND(AAMT,0)+ROUND(RAMT,0)+ROUND(BAMT,0)+ROUND(NAMT,0)+ROUND(MMARGINBAL,0)+ROUND(MARGINBAL,0))SUMCI
                        from cimast where AFACCTNO=p_txmsg.txfields('03').value)CI,
                    (Select SUM(ROUND(MORTAGE,0)+ROUND(MARGIN,0)+ROUND(NETTING,0)+ROUND(STANDING,0)+ROUND(SECURED,0)+ROUND(WITHDRAW,0) +ROUND(LOAN,0)+ROUND(REPO,0)+ROUND(PENDING,0)+ROUND(TRANSFER,0)) SUMSE
                        from semast where AFACCTNO=p_txmsg.txfields('03').value)SE;
            end if;
        EXCEPTION WHEN OTHERS THEN
                v_sumci:=0;
                v_sumse:=0;
        end;

        --Kiem tra neu con chung khoan cho rut thi khong cho thuc hien
        BEGIN
            if p_txmsg.txfields('80').value = '001' then
                Select SUM(ROUND(WITHDRAW,0) ) WITHDRAW, SUM(ROUND(deposit,0) ) deposit
                    into v_withdraw, v_deposit
                    from semast se, afmast af, cfmast cf
                    where se.afacctno = af.acctno and af.custid = cf.custid and af.status not in ('N','C')
                    and cf.custodycd =p_txmsg.txfields('88').value;
            else
                Select SUM(ROUND(WITHDRAW,0)) WITHDRAW, SUM(ROUND(deposit,0) ) deposit
                    into v_withdraw, v_deposit
                    from semast where AFACCTNO=p_txmsg.txfields('03').value;
            end if;
        EXCEPTION WHEN OTHERS THEN
                v_withdraw:=0;
        end;
        if v_withdraw>0 THEN
              p_err_code:='-200108';
              plog.setendsection (pkgctx, 'fn_txPreAppCheck');
              RETURN errnums.C_BIZ_RULE_INVALID;
        END IF;

        if v_deposit>0 THEN
              p_err_code:='-200064';
              plog.setendsection (pkgctx, 'fn_txPreAppCheck');
              RETURN errnums.C_BIZ_RULE_INVALID;
        END IF;
        --Kiem tra neu con chung khoan cho rut thi khong cho thuc hien

        BEGIN
            if p_txmsg.txfields('80').value = '001' then
                Select count(*) into l_count
                    from stschd sts, afmast af, cfmast cf
                    where sts.afacctno = af.acctno and af.custid = cf.custid and af.status not in ('N','C') and sts.deltd <> 'Y' and sts.status <> 'C'
                    and cf.custodycd =p_txmsg.txfields('88').value;
            else
                Select count(*) into l_count
                    from stschd sts where AFACCTNO=p_txmsg.txfields('03').value and sts.deltd <> 'Y' and sts.status <> 'C';
            end if;
        EXCEPTION WHEN OTHERS THEN
                l_count:=0;
        end;
        if l_count>0 THEN
              p_err_code:='-200109';
              plog.setendsection (pkgctx, 'fn_txPreAppCheck');
              RETURN errnums.C_BIZ_RULE_INVALID;
        END IF;
    end;

    if(p_txmsg.txfields('72').value ='Y') THEN
          p_err_code:='-260164';
          plog.setendsection (pkgctx, 'fn_txPreAppCheck');
          RETURN errnums.C_BIZ_RULE_INVALID;
    END IF;

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
    l_baldefovd apprules.field%TYPE;
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
    for rec_af in
    (
        select af.acctno, cf.custid, cf.custodycd,
            ci.odamt, ci.odintacr, ci.DEPOFEEAMT, ci.CIDEPOFEEACR, ci.crintacr
        from cfmast cf, afmast af, cimast ci
        where cf.custid = af.custid and af.acctno = ci.acctno
            and cf.custodycd = p_txmsg.txfields('88').value and af.status not in ('C','N')
            and case when p_txmsg.txfields('80').value = '001' then 1
                    when p_txmsg.txfields('80').value <> '001' and af.acctno = p_txmsg.txfields('03').value then 1
                    else 0 end = 1
    )
    loop

        l_CIMASTcheck_arr := txpks_check.fn_CIMASTcheck(rec_af.acctno,'CIMAST','ACCTNO');
        --l_BALDEFOVD := l_CIMASTcheck_arr(0).BALDEFOVD;
        l_BALDEFOVD := l_CIMASTcheck_arr(0).Baldefovd_Released_Depofee;

        if p_txmsg.txfields('03').value = rec_af.acctno then
            IF NOT round(l_BALDEFOVD +  ROUND(rec_af.crintacr,0),0)
                    >= ROUND(rec_af.DEPOFEEAMT+rec_af.CIDEPOFEEACR + p_txmsg.txfields('17').value + p_txmsg.txfields('68').value+ p_txmsg.txfields('55').value,0) then
                    -->= ROUND(rec_af.CIDEPOFEEACR + p_txmsg.txfields('17').value + p_txmsg.txfields('68').value,0) then
                    ----Bo rec_af.DEPOFEEAMT vi trong l_BALDEFOVD da tru di roi
                p_err_code := '-400110';
                plog.setendsection (pkgctx, 'fn_txPreAppUpdate');
                RETURN errnums.C_BIZ_RULE_INVALID;
            END IF;
        else
            IF NOT round(l_BALDEFOVD +  ROUND(rec_af.crintacr,0),0)
                    >= ROUND(rec_af.DEPOFEEAMT+rec_af.CIDEPOFEEACR,0) then
                    -->= ROUND(rec_af.CIDEPOFEEACR,0) then
                    ----Bo rec_af.DEPOFEEAMT vi trong l_BALDEFOVD da tru di roi
                p_err_code := '-400110';
                plog.setendsection (pkgctx, 'fn_txPreAppUpdate');
                RETURN errnums.C_BIZ_RULE_INVALID;
            END IF;
        end if;
    end loop;

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
v_feeacr NUMBER(20,4);
v_dblNumDATE NUMBER(10);
l_txdesc varchar2(500);
l_custid    varchar2(10);
TYPE v_CurTyp  IS REF CURSOR;
c0        v_CurTyp;
v_blnREVERSAL boolean;
l_lngErrCode    number(20,0);
v_strOBJTYPE    varchar2(100);
v_strTRFCODE    varchar2(100);
v_strBANK    varchar2(200);
v_strAMTEXP    varchar2(200);
v_strAFACCTNO    varchar2(100);
v_strREFCODE    varchar2(100);
v_strBANKACCT    varchar2(100);
v_strFLDAFFECTDATE    varchar2(100);
v_strAFFECTDATE    varchar2(100);
v_strNOTES    varchar2(1000);
v_strVALUE     varchar2(1000);
v_strFLDNAME     varchar2(100);
v_strFLDTYPE     varchar2(100);
v_strREFAUTOID     number;
v_strSQL     varchar2(4000);
v_strStatus char(1);
v_strCOREBANK    char(1);
v_strafbankname varchar(100);
v_strafbankacctno    varchar2(100);
BEGIN
    plog.setbeginsection (pkgctx, 'fn_txPreAppUpdate');
    plog.debug (pkgctx, '<<BEGIN OF fn_txPreAppUpdate');
   /***************************************************************************************************
    ** PUT YOUR SPECIFIC PROCESS HERE. . DO NOT COMMIT/ROLLBACK HERE, THE SYSTEM WILL DO IT
    ***************************************************************************************************/
    if(p_txmsg.txfields('18').value > 0) THEN
        v_dblNumDATE:=to_number(p_txmsg.txfields('18').value);
            for rec_af in
            (
                select af.acctno
                from cfmast cf, afmast af
                where cf.custid = af.custid
                    and cf.custodycd = p_txmsg.txfields('88').value and af.status not in ('C','N')
                    and case when p_txmsg.txfields('80').value = '001' then 1
                    when p_txmsg.txfields('80').value <> '001' and af.acctno = p_txmsg.txfields('03').value then 1
                    else 0 end = 1
            )
            loop
              /*  FOR rec IN
                (
                    SELECT se.acctno,se.TBALDT,
                        (se.trade + se.margin + se.mortage + se.blocked + se.secured + se.repo + se.netting + se.dtoclose + se.withdraw) qtty
                    FROM semast se WHERE se.afacctno=rec_af.acctno
                )
                LOOP*/
                   /* BEGIN
                        SELECT round(FEEACR,4)
                            INTO v_feeacr
                        FROM (
                            SELECT A2.AFACCTNO,
                                DECODE(A2.FORP,'P',A2.FEEAMT/100,A2.FEEAMT)*A2.SEBAL*v_dblNumDATE/(A2.LOTDAY*A2.LOTVAL) FEEACR
                            FROM (SELECT T.ACCTNO, MIN(T.ODRNUM) RFNUM FROM VW_SEMAST_VSDDEP_FEETERM T GROUP BY T.ACCTNO) A1,
                            VW_SEMAST_VSDDEP_FEETERM A2
                        WHERE A1.ACCTNO=A2.ACCTNO AND A1.RFNUM=A2.ODRNUM
                        AND a2.ACCTNO=rec.acctno ) T2;

                    EXCEPTION WHEN OTHERS THEN
                        v_feeacr:=0;
                    END;*/
                    --PhuongHT edit

                    for REC in
                      (
                      SELECT A2.TBALDT,A2.AFACCTNO,a2.ACCTNO,
                      round((v_dblNumDATE*A2.AMT_TEMP),4) FEEACR,
                      A2.AUTOID Ref, A2.TYPE,A2.SEBAL QTTY,
                      A2.FEEAMT,A2.LOTDAY,A2.LOTVAL,A2.FORP,
                      (CASE WHEN A2.ODR=A3.ODR THEN 'Y' ELSE 'N' END ) USED
                      FROM /*(SELECT T.ACCTNO, MIN(T.ODRNUM) RFNUM FROM VW_SEMAST_VSDDEP_FEETERM T GROUP BY T.ACCTNO) A1,*/
                      (SELECT T.*,ROWNUM ODR
                      FROM   (SELECT * FROM VW_SEMAST_VSDDEP_FEETERM T ORDER BY T.ACCTNO,T.ODRNUM, T.AMT_TEMP) T
                      ) A2,
                      (
                      SELECT ACCTNO,MIN(ODR) ODR
                      FROM
                      (SELECT T.*,ROWNUM ODR
                      FROM   (SELECT * FROM VW_SEMAST_VSDDEP_FEETERM T ORDER BY T.ACCTNO,T.ODRNUM, T.AMT_TEMP) T
                      )
                      GROUP BY ACCTNO
                      )A3
                      WHERE A2.ACCTNO=A3.ACCTNO
                      AND A2.AFACCTNO=rec_af.acctno
                      )
                      LOOP
                      IF REC.USED='Y' THEN
                        INSERT INTO SEDEPOBAL (AUTOID, ACCTNO, TXDATE, DAYS, QTTY, DELTD,AMT,ID,
                        Type,Ref,FEEAMT,LOTDAY,LOTVAL,FORP,USED)
                        VALUES (SEQ_SEDEPOBAL.NEXTVAL, rec.ACCTNO, rec.TBALDT,p_txmsg.txfields('18').value, rec.qtty, 'N',v_feeacr,p_txmsg.txdate||p_txmsg.txnum,
                        REC.TYPE,REC.Ref,REC.FEEAMT,REC.LOTDAY,REC.LOTVAL,REC.FORP,REC.USED);
                      ELSE
                        INSERT INTO SEDEPOBAL_HIST (AUTOID, ACCTNO, TXDATE, DAYS, QTTY, DELTD,AMT,ID,
                        Type,Ref,FEEAMT,LOTDAY,LOTVAL,FORP,USED)
                        VALUES (SEQ_SEDEPOBAL.NEXTVAL, rec.ACCTNO, rec.TBALDT,p_txmsg.txfields('18').value, rec.qtty, 'N',v_feeacr,p_txmsg.txdate||p_txmsg.txnum,
                        REC.TYPE,REC.Ref,REC.FEEAMT,REC.LOTDAY,REC.LOTVAL,REC.FORP,REC.USED);
                      END IF;
                    END LOOP;-- end rec
               /* END LOOP;-- end rec*/

            end loop;-- end rec_af
          INSERT INTO SEDEPOBAL_HIST SELECT * FROM SEDEPOBAL WHERE USED='N';
          DELETE FROM SEDEPOBAL WHERE USED='N';
          -- end of PhuongHT edit
    END IF;
    plog.debug (pkgctx, '<<END OF fn_txPreAppUpdate');
    plog.setendsection (pkgctx, 'fn_txPreAppUpdate');
    RETURN systemnums.C_SUCCESS;
---Gent bang ke thu phi luu ky
---TuanNH add

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
v_sentdeposit number;
v_sumdetail number;
v_acctno VARCHAR2(20);
v_mrcount VARCHAR2(10);
v_accnum number;
V_IDATE date;
v_marketname varchar2(100);
v_rightname_a varchar2(100);
v_rightname_b varchar2(100);
v_rightname_c varchar2(100);
v_rightname_d varchar2(100);
v_rightname_e varchar2(100);
v_rightname_f varchar2(100);
v_rightname_g varchar2(100);
v_rightname_h varchar2(100);
l_txdesc varchar2(500);
l_custid    varchar2(10);
TYPE v_CurTyp  IS REF CURSOR;
c0        v_CurTyp;
v_blnREVERSAL boolean;
l_lngErrCode    number(20,0);
v_strOBJTYPE    varchar2(100);
v_strTRFCODE    varchar2(100);
v_strBANK    varchar2(200);
v_strAMTEXP    varchar2(200);
v_strAFACCTNO    varchar2(100);
v_strREFCODE    varchar2(100);
v_strBANKACCT    varchar2(100);
v_strFLDAFFECTDATE    varchar2(100);
v_strAFFECTDATE    varchar2(100);
v_strNOTES    varchar2(1000);
v_strVALUE     varchar2(1000);
v_strFLDNAME     varchar2(100);
v_strFLDTYPE     varchar2(100);
v_strREFAUTOID     number;
v_strSQL     varchar2(4000);
v_strStatus char(1);
v_strCOREBANK    char(1);
v_strafbankname varchar(100);
v_strafbankacctno    varchar2(100);
v_cusid varchar2(20);
V_BALANCE           NUMBER;

V_MRCRLIMITMAX  NUMBER;
v_T0AMT         NUMBER;

    l_count number;
    l_txmsg               tx.msg_rectype;
    l_CURRDATE date;
    l_Desc varchar2(1000);
    l_EN_Desc varchar2(1000);
    l_OrgDesc varchar2(1000);
    l_EN_OrgDesc varchar2(1000);
    l_err_param varchar2(300);
    v_AccTemp varchar2(10);
L_AMT NUMBER;

BEGIN
    plog.setbeginsection (pkgctx, 'fn_txAftAppUpdate');
    plog.debug (pkgctx, '<<BEGIN OF fn_txAftAppUpdate');
   /***************************************************************************************************
    ** PUT YOUR SPECIFIC AFTER PROCESS HERE. DO NOT COMMIT/ROLLBACK HERE, THE SYSTEM WILL DO IT
    ***************************************************************************************************/

IF p_txmsg.deltd <> 'Y' then

  -- begin binhvt
      select cf.custid into v_cusid from cfmast cf where cf.custodycd =  p_txmsg.txfields('88').value;
        insert into SETYPETRF(AUTOID,NAMT,TXNUM,TXDATE,TLTXCD,DELTD,Afacctno,Custid,Busdate,Rcustodycd,INFULLNAME,INWARDNAME) valueS
        (SEQ_SETYPETRF.Nextval, p_txmsg.txfields('68').value,p_txmsg.txnum,p_txmsg.txdate,'0088','N',p_txmsg.txfields('03').value,v_cusid,p_txmsg.BUSDATE,p_txmsg.txfields('47').value,p_txmsg.txfields('97').value,p_txmsg.txfields('98').value);
        --- end binhvt

 SELECT TO_DATE (varvalue, systemnums.c_date_format)
               INTO l_CURRDATE
               FROM sysvar
               WHERE grname = 'SYSTEM' AND varname = 'CURRDATE';

        if p_txmsg.txfields('80').value = '001' then
            Begin
                SELECT sum(MRCRLIMITMAX) MRCRLIMITMAX, sum(T0AMT) T0AMT
                    INTO V_MRCRLIMITMAX,v_T0AMT
                FROM VW_AFMAST_FOR_CLOSE_ACCOUNT
                WHERE CUSTODYCD=p_txmsg.txfields('88').value
                group by custodycd;
            EXCEPTION
                WHEN OTHERS   THEN
                V_MRCRLIMITMAX:=0;
                v_T0AMT:=0;

            end;
        else
            Begin
                SELECT MRCRLIMITMAX,T0AMT
                    INTO V_MRCRLIMITMAX,v_T0AMT
                FROM VW_AFMAST_FOR_CLOSE_ACCOUNT
                WHERE AFACCTNO=p_txmsg.txfields('03').value;
            EXCEPTION
                WHEN OTHERS   THEN
                V_MRCRLIMITMAX:=0;
                v_T0AMT:=0;

            end;
        end if;

      /*   -- Thu hoi han muc vay
        if V_MRCRLIMITMAX <>0 then
            if p_txmsg.txfields('80').value = '001' then
\*                p_err_code:='-400207';
                plog.setendsection(pkgctx, 'fn_txPreAppCheck');
                RETURN errnums.C_BIZ_RULE_INVALID;*\
                v_AccTemp:='%%';
            ELSE
                v_AccTemp:=p_txmsg.txfields('02').value;
            END IF;

            for rec1815 in (
                select cf.custodycd, cf.custid, af.acctno,AF.MRCRLIMITMAX from afmast af, cfmast cf where af.custid =cf.custid
                    and cf.custodycd = p_txmsg.txfields('88').value and af.acctno like v_AccTemp and af.status = 'A'
            )
            LOOP

                SELECT TXDESC,EN_TXDESC into l_OrgDesc, l_EN_OrgDesc FROM  TLTX WHERE TLTXCD='1815';

               \* for rec1815 in (
                    SELECT CUSTODYCD, ACCTNO, AF.MRCRLIMITMAX FROM AFMAST AF, CFMAST CF WHERE AF.CUSTID = CF.CUSTID AND AF.ACCTNO = recall.acctno
                )
                LOOP*\
                l_txmsg.msgtype:='T';
                l_txmsg.local:='N';
                l_txmsg.tlid        := systemnums.c_system_userid;
                plog.debug(pkgctx, 'l_txmsg.tlid' || l_txmsg.tlid);
                SELECT SYS_CONTEXT ('USERENV', 'HOST'),
                         SYS_CONTEXT ('USERENV', 'IP_ADDRESS', 15)
                  INTO l_txmsg.wsname, l_txmsg.ipaddress
                FROM DUAL;
                l_txmsg.off_line    := 'N';
                l_txmsg.deltd       := txnums.c_deltd_txnormal;
                l_txmsg.txstatus    := txstatusnums.c_txcompleted;
                l_txmsg.msgsts      := '0';
                l_txmsg.ovrsts      := '0';
                l_txmsg.batchname   := '';
                l_txmsg.txdate:=l_CURRDATE;
                l_txmsg.busdate:=l_CURRDATE;
                l_txmsg.tltxcd:='1815';
                l_DESC:=l_OrgDesc;
                 --set txnum
                SELECT systemnums.C_BATCH_PREFIXED
                                     || LPAD (seq_BATCHTXNUM.NEXTVAL, 8, '0')
                              INTO l_txmsg.txnum
                              FROM DUAL;
                l_txmsg.brid        := substr(p_txmsg.txfields('02').value,1,4);

                --88  CUSTODYCD       C
                l_txmsg.txfields ('88').defname   := 'CUSTODYCD';
                l_txmsg.txfields ('88').TYPE      := 'C';
                l_txmsg.txfields ('88').VALUE     := rec1815.CUSTODYCD;

                --03  ACCTNO          C
                l_txmsg.txfields ('03').defname   := 'ACCTNO';
                l_txmsg.txfields ('03').TYPE      := 'C';
                l_txmsg.txfields ('03').VALUE     := rec1815.ACCTNO;

                --10  ACCLIMIT        N
                l_txmsg.txfields ('10').defname   := 'ACCTNO';
                l_txmsg.txfields ('10').TYPE      := 'N';
                l_txmsg.txfields ('10').VALUE     := rec1815.MRCRLIMITMAX;

                --11  MRCRLIMITMAX    N
                l_txmsg.txfields ('11').defname   := 'ACCTNO';
                l_txmsg.txfields ('11').TYPE      := 'N';
                l_txmsg.txfields ('11').VALUE     := rec1815.MRCRLIMITMAX;

                --30  DESC            C
                l_txmsg.txfields ('30').defname   := 'DESC';
                l_txmsg.txfields ('30').TYPE      := 'C';
                l_txmsg.txfields ('30').VALUE     := l_DESC;

                --END LOOP;

                BEGIN
                    IF txpks_#1815.fn_batchtxprocess (l_txmsg,
                                                     p_err_code,
                                                     l_err_param
                       ) <> systemnums.c_success
                    THEN
                       plog.debug (pkgctx,
                                   'got error 1815: ' || p_err_code
                       );
                       ROLLBACK;
                       RETURN errnums.C_BIZ_RULE_INVALID;
                    END IF;
                END;

            END LOOP;

        end if;*/


        if v_T0AMT <>0 then
            if p_txmsg.txfields('80').value = '001' then
               /* p_err_code:='-400208';
                plog.setendsection(pkgctx, 'fn_txPreAppCheck');
                RETURN errnums.C_BIZ_RULE_INVALID;*/
                v_AccTemp:='%%';
            ELSE
                v_AccTemp:=p_txmsg.txfields('02').value;
            END IF;

            for rec1811 in (
                SELECT TLID , TLNAME USERNAME, ACCTNO, CUSTODYCD, FULLNAME, ACCLIMIT, USRLIMIT, T0AMT, T0ACCUSER, ADVT0AMT, ADVT0AMT AS ADVT0AMTMAX, ACCUSERHIST, ADVAMTHIST, ADVAMTHIST AS ADVAMTHISTMAX
                FROM VW_ACCOUNT_ADVT0 MST
                where MST.ADVAMTHIST + MST.ADVT0AMT > 0  and custodycd = p_txmsg.txfields('88').value and acctno like v_AccTemp
            )
            LOOP
                SELECT TXDESC,EN_TXDESC into l_OrgDesc, l_EN_OrgDesc FROM  TLTX WHERE TLTXCD='1811';

                l_txmsg.msgtype:='T';
                l_txmsg.local:='N';
                l_txmsg.tlid        := systemnums.c_system_userid;
                plog.debug(pkgctx, 'l_txmsg.tlid' || l_txmsg.tlid);
                SELECT SYS_CONTEXT ('USERENV', 'HOST'),
                         SYS_CONTEXT ('USERENV', 'IP_ADDRESS', 15)
                  INTO l_txmsg.wsname, l_txmsg.ipaddress
                FROM DUAL;
                l_txmsg.off_line    := 'N';
                l_txmsg.deltd       := txnums.c_deltd_txnormal;
                l_txmsg.txstatus    := txstatusnums.c_txcompleted;
                l_txmsg.msgsts      := '0';
                l_txmsg.ovrsts      := '0';
                l_txmsg.batchname   := '';
                l_txmsg.txdate:=l_CURRDATE;
                l_txmsg.busdate:=l_CURRDATE;
                l_txmsg.tltxcd:='1811';
                l_DESC:=l_OrgDesc;
                 --set txnum
                SELECT systemnums.C_BATCH_PREFIXED
                                     || LPAD (seq_BATCHTXNUM.NEXTVAL, 8, '0')
                              INTO l_txmsg.txnum
                              FROM DUAL;
                l_txmsg.brid        := substr(p_txmsg.txfields('02').value,1,4);



                --01  USERID      C
                l_txmsg.txfields ('01').defname   := 'USERID';
                l_txmsg.txfields ('01').TYPE      := 'C';
                l_txmsg.txfields ('01').VALUE     := rec1811.TLID;

                --03  ACCTNO      C
                l_txmsg.txfields ('03').defname   := 'ACCTNO';
                l_txmsg.txfields ('03').TYPE      := 'C';
                l_txmsg.txfields ('03').VALUE     := rec1811.ACCTNO;

                --08  ADVT0AMT    N
                l_txmsg.txfields ('08').defname   := 'ADVT0AMT';
                l_txmsg.txfields ('08').TYPE      := 'N';
                l_txmsg.txfields ('08').VALUE     := rec1811.ADVT0AMT;

                --09  ADVT0AMT    N
                l_txmsg.txfields ('09').defname   := 'ADVT0AMT';
                l_txmsg.txfields ('09').TYPE      := 'N';
                l_txmsg.txfields ('09').VALUE     := rec1811.ADVT0AMT;

                --11  ADVAMTHIST  N
                l_txmsg.txfields ('11').defname   := 'ADVAMTHIST';
                l_txmsg.txfields ('11').TYPE      := 'N';
                l_txmsg.txfields ('11').VALUE     := rec1811.ADVAMTHIST;

                --10  ADVAMTHIST  N
                l_txmsg.txfields ('10').defname   := 'ADVAMTHIST';
                l_txmsg.txfields ('10').TYPE      := 'N';
                l_txmsg.txfields ('10').VALUE     := rec1811.ADVAMTHIST;

                --30  DESC        C
                l_txmsg.txfields ('30').defname   := 'DESC';
                l_txmsg.txfields ('30').TYPE      := 'C';
                l_txmsg.txfields ('30').VALUE     := l_DESC;


                BEGIN
                    IF txpks_#1811.fn_batchtxprocess (l_txmsg,
                                                     p_err_code,
                                                     l_err_param
                       ) <> systemnums.c_success
                    THEN
                       plog.debug (pkgctx,
                                   'got error 1811: ' || p_err_code
                       );
                       ROLLBACK;
                       RETURN errnums.C_BIZ_RULE_INVALID;
                    END IF;
                END;

            END LOOP;



        end if;








    -- Gen bang ke 01 TRFSECLSFEE.
       l_lngErrCode:=0;
       v_blnREVERSAL:=case when p_txmsg.deltd ='Y' then true else false end;

       if not v_blnREVERSAL then
           v_strAFACCTNO:=p_txmsg.txfields('03').value;
           --Kiem tra neu la TK corebank thi tiep tuc
           select corebank,bankname,bankacctno into v_strCOREBANK, v_strafbankname, v_strafbankacctno from afmast where acctno =  v_strAFACCTNO;
           if v_strCOREBANK ='Y' then

               --Begin Gen yeu cau sang ngan hang 0088-TRFNML
               v_strOBJTYPE:='T';
               v_strTRFCODE:='TRFSECLSFEE';
               v_strREFCODE:= to_char(p_txmsg.txdate,'DD/MM/RRRR') || p_txmsg.txnum;
               v_strAFFECTDATE:= to_char(p_txmsg.txdate,'DD/MM/RRRR');
               v_strBANK:=v_strafbankname;
               v_strBANKACCT:=v_strafbankacctno;
               v_strNOTES:=p_txmsg.txfields('30').value;
               v_strVALUE:=to_number(p_txmsg.txfields('68').value+p_txmsg.txfields('55').value);
               if length(v_strBANK)>0 and length(v_strBANKACCT)>0 and v_strVALUE >0 then
                   --Ghi nhan vao CRBTXREQ
                   select seq_CRBTXREQ.nextval into v_strREFAUTOID from dual;
                   INSERT INTO CRBTXREQ (REQID, OBJTYPE, OBJNAME, OBJKEY, TRFCODE, REFCODE, TXDATE, AFFECTDATE, AFACCTNO, TXAMT, BANKCODE, BANKACCT, STATUS, REFVAL, NOTES)
                       VALUES (v_strREFAUTOID, 'T', p_txmsg.tltxcd,p_txmsg.txnum, v_strTRFCODE,v_strREFCODE, TO_DATE(p_txmsg.txdate, 'dd/mm/rrrr'), TO_DATE(v_strAFFECTDATE , 'dd/mm/rrrr'),
                               v_strAFACCTNO , v_strVALUE , v_strBANK,v_strBANKACCT, 'P', NULL,v_strNOTES);

                 update cimast
                 set HOLDBALANCE = HOLDBALANCE - to_number(p_txmsg.txfields('68').value+p_txmsg.txfields('55').value)
                where acctno = p_txmsg.txfields('03').value;
               ---UPDATE CITRAN

                  INSERT INTO CITRAN(TXNUM,TXDATE,ACCTNO,TXCD,NAMT,CAMT,ACCTREF,DELTD,REF,AUTOID,TLTXCD,BKDATE,TRDESC)
                  VALUES (p_txmsg.txnum, TO_DATE (p_txmsg.txdate, systemnums.C_DATE_FORMAT),p_txmsg.txfields('03').value,'0051', ROUND(to_number(p_txmsg.txfields('68').value+p_txmsg.txfields('55').value),0),NULL,'',p_txmsg.deltd,'',seq_CITRAN.NEXTVAL, p_txmsg.tltxcd,p_txmsg.busdate,utf8nums.c_const_TLTX_TXDESC_0088_FEE);

                   v_strFLDNAME:='CUSTODYCD';
                   v_strFLDTYPE:='C';
                   v_strAMTEXP:='$88';
                   v_strSQL:='';
                   v_strVALUE := substr(v_strAMTEXP, 2);
                   v_strVALUE := p_txmsg.txfields(v_strVALUE).value;

                   INSERT INTO CRBTXREQDTL (AUTOID, REQID, FLDNAME, CVAL, NVAL)
                   select SEQ_CRBTXREQDTL.NEXTVAL,v_strREFAUTOID,v_strFLDNAME,
                       case when v_strFLDTYPE='N' then '' else to_char(v_strVALUE) end,
                       case when v_strFLDTYPE<>'N' then 0 else to_number(v_strVALUE) end
                       from dual;

                   v_strFLDNAME:='ACCTNO';
                   v_strFLDTYPE:='C';
                   v_strAMTEXP:='$02';
                   v_strSQL:='';
                   v_strVALUE := substr(v_strAMTEXP, 2);
                   v_strVALUE := p_txmsg.txfields(v_strVALUE).value;

                   INSERT INTO CRBTXREQDTL (AUTOID, REQID, FLDNAME, CVAL, NVAL)
                   select SEQ_CRBTXREQDTL.NEXTVAL,v_strREFAUTOID,v_strFLDNAME,
                       case when v_strFLDTYPE='N' then '' else to_char(v_strVALUE) end,
                       case when v_strFLDTYPE<>'N' then 0 else to_number(v_strVALUE) end
                       from dual;

                   v_strFLDNAME:='NAME';
                   v_strFLDTYPE:='C';
                   v_strAMTEXP:='$31';
                   v_strSQL:='';
                   v_strVALUE := substr(v_strAMTEXP, 2);
                   v_strVALUE := p_txmsg.txfields(v_strVALUE).value;

                   INSERT INTO CRBTXREQDTL (AUTOID, REQID, FLDNAME, CVAL, NVAL)
                   select SEQ_CRBTXREQDTL.NEXTVAL,v_strREFAUTOID,v_strFLDNAME,
                       case when v_strFLDTYPE='N' then '' else to_char(v_strVALUE) end,
                       case when v_strFLDTYPE<>'N' then 0 else to_number(v_strVALUE) end
                       from dual;

               End if;
           else

               begin
                   SELECT STATUS into v_strStatus FROM CRBTXREQ MST WHERE MST.OBJNAME=p_txmsg.tltxcd AND MST.OBJKEY=p_txmsg.txnum AND MST.TXDATE=TO_DATE(p_txmsg.txdate, 'DD/MM/RRRR');
                   if  v_strStatus = 'P' then
                       update CRBTXREQ set status ='D' WHERE OBJNAME=p_txmsg.tltxcd AND OBJKEY=p_txmsg.txnum AND TXDATE=TO_DATE(p_txmsg.txdate, 'DD/MM/RRRR');
                       update cimast
                         set HOLDBALANCE = HOLDBALANCE + to_number(p_txmsg.txfields('68').value+p_txmsg.txfields('55').value)
                         where acctno = p_txmsg.txfields('03').value;
                   else
                       plog.setendsection (pkgctx, 'fn_txAppUpdate');
                       p_err_code:=-670101;--Trang thai bang ke khong hop le
                       Return errnums.C_BIZ_RULE_INVALID;
                   end if;
               exception when others then
                   null; --Khong co bang ke can xoa
               end;
           End if;
    end if;

    --End gent bang ke
    -- Gen bang ke 02 TRFSEFEE.
       l_lngErrCode:=0;
       v_blnREVERSAL:=case when p_txmsg.deltd ='Y' then true else false end;

       if not v_blnREVERSAL then
           v_strAFACCTNO:=p_txmsg.txfields('03').value;
           --Kiem tra neu la TK corebank thi tiep tuc
           select corebank,bankname,bankacctno into v_strCOREBANK, v_strafbankname, v_strafbankacctno from afmast where acctno =  v_strAFACCTNO;
           if v_strCOREBANK ='Y' then

               --Begin Gen yeu cau sang ngan hang 0088-TRFNML
               v_strOBJTYPE:='T';
               v_strTRFCODE:='TRFSEFEE';
               v_strREFCODE:= to_char(p_txmsg.txdate,'DD/MM/RRRR') || p_txmsg.txnum;
               v_strAFFECTDATE:= to_char(p_txmsg.txdate,'DD/MM/RRRR');
               v_strBANK:=v_strafbankname;
               v_strBANKACCT:=v_strafbankacctno;
               v_strNOTES:=p_txmsg.txfields('30').value;
               v_strVALUE:=p_txmsg.txfields('17').value;
               if length(v_strBANK)>0 and length(v_strBANKACCT)>0 and v_strVALUE >0 then
                   --Ghi nhan vao CRBTXREQ
                   select seq_CRBTXREQ.nextval into v_strREFAUTOID from dual;
                   INSERT INTO CRBTXREQ (REQID, OBJTYPE, OBJNAME, OBJKEY, TRFCODE, REFCODE, TXDATE, AFFECTDATE, AFACCTNO, TXAMT, BANKCODE, BANKACCT, STATUS, REFVAL, NOTES)
                       VALUES (v_strREFAUTOID, 'T', p_txmsg.tltxcd,p_txmsg.txnum, v_strTRFCODE,v_strREFCODE, TO_DATE(p_txmsg.txdate, 'dd/mm/rrrr'), TO_DATE(v_strAFFECTDATE , 'dd/mm/rrrr'),
                               v_strAFACCTNO , v_strVALUE , v_strBANK,v_strBANKACCT, 'P', NULL,v_strNOTES);

                 update cimast
                    set HOLDBALANCE = HOLDBALANCE - ROUND(p_txmsg.txfields('17').value,0)
                    where acctno = p_txmsg.txfields('03').value;
                --update citran
                  INSERT INTO CITRAN(TXNUM,TXDATE,ACCTNO,TXCD,NAMT,CAMT,ACCTREF,DELTD,REF,AUTOID,TLTXCD,BKDATE,TRDESC)
                  VALUES (p_txmsg.txnum, TO_DATE (p_txmsg.txdate, systemnums.C_DATE_FORMAT),p_txmsg.txfields('03').value,'0051',ROUND(p_txmsg.txfields('17').value,0),NULL,'',p_txmsg.deltd,'',seq_CITRAN.NEXTVAL,p_txmsg.tltxcd,p_txmsg.busdate,'' || '' || '');

                    --Dr HoldBalance transfer amount
                   v_strFLDNAME:='CUSTODYCD';
                   v_strFLDTYPE:='C';
                   v_strAMTEXP:='$88';
                   v_strSQL:='';
                   v_strVALUE := substr(v_strAMTEXP, 2);
                   v_strVALUE := p_txmsg.txfields(v_strVALUE).value;

                   INSERT INTO CRBTXREQDTL (AUTOID, REQID, FLDNAME, CVAL, NVAL)
                   select SEQ_CRBTXREQDTL.NEXTVAL,v_strREFAUTOID,v_strFLDNAME,
                       case when v_strFLDTYPE='N' then '' else to_char(v_strVALUE) end,
                       case when v_strFLDTYPE<>'N' then 0 else to_number(v_strVALUE) end
                       from dual;

                   v_strFLDNAME:='ACCTNO';
                   v_strFLDTYPE:='C';
                   v_strAMTEXP:='$02';
                   v_strSQL:='';
                   v_strVALUE := substr(v_strAMTEXP, 2);
                   v_strVALUE := p_txmsg.txfields(v_strVALUE).value;

                   INSERT INTO CRBTXREQDTL (AUTOID, REQID, FLDNAME, CVAL, NVAL)
                   select SEQ_CRBTXREQDTL.NEXTVAL,v_strREFAUTOID,v_strFLDNAME,
                       case when v_strFLDTYPE='N' then '' else to_char(v_strVALUE) end,
                       case when v_strFLDTYPE<>'N' then 0 else to_number(v_strVALUE) end
                       from dual;

                   v_strFLDNAME:='NAME';
                   v_strFLDTYPE:='C';
                   v_strAMTEXP:='$31';
                   v_strSQL:='';
                   v_strVALUE := substr(v_strAMTEXP, 2);
                   v_strVALUE := p_txmsg.txfields(v_strVALUE).value;

                   INSERT INTO CRBTXREQDTL (AUTOID, REQID, FLDNAME, CVAL, NVAL)
                   select SEQ_CRBTXREQDTL.NEXTVAL,v_strREFAUTOID,v_strFLDNAME,
                       case when v_strFLDTYPE='N' then '' else to_char(v_strVALUE) end,
                       case when v_strFLDTYPE<>'N' then 0 else to_number(v_strVALUE) end
                       from dual;

               End if;
           else

               begin
                   SELECT STATUS into v_strStatus FROM CRBTXREQ MST WHERE MST.OBJNAME=p_txmsg.tltxcd AND MST.OBJKEY=p_txmsg.txnum AND MST.TXDATE=TO_DATE(p_txmsg.txdate, 'DD/MM/RRRR');
                   if  v_strStatus = 'P' then
                       update CRBTXREQ set status ='D' WHERE OBJNAME=p_txmsg.tltxcd AND OBJKEY=p_txmsg.txnum AND TXDATE=TO_DATE(p_txmsg.txdate, 'DD/MM/RRRR');
                       update cimast
                        set HOLDBALANCE = HOLDBALANCE + ROUND(p_txmsg.txfields('17').value,0)
                        where acctno = p_txmsg.txfields('03').value;
                   else
                       plog.setendsection (pkgctx, 'fn_txAppUpdate');
                       p_err_code:=-670101;--Trang thai bang ke khong hop le
                       Return errnums.C_BIZ_RULE_INVALID;
                   end if;
               exception when others then
                   null; --Khong co bang ke can xoa
               end;
           End if;
    end if;

    --End gent bang ke
    /* Thu phi chuyen khoan chung khoan. Thu phi luu ky truoc */


    update cimast
    set DRAMT = DRAMT + p_txmsg.txfields('68').value,
        BALANCE = BALANCE - p_txmsg.txfields('68').value - ROUND(p_txmsg.txfields('17').value,0),
        CIDEPOFEEACR = CIDEPOFEEACR - ROUND(p_txmsg.txfields('17').value,0) + ROUND(p_txmsg.txfields('17').value,0)
    where acctno = p_txmsg.txfields('03').value;
    --insert citran
    INSERT INTO CITRAN(TXNUM,TXDATE,ACCTNO,TXCD,NAMT,CAMT,ACCTREF,DELTD,REF,AUTOID,TLTXCD,BKDATE,TRDESC)
    VALUES (p_txmsg.txnum, TO_DATE (p_txmsg.txdate, systemnums.C_DATE_FORMAT),p_txmsg.txfields('03').value,'0011', ROUND(p_txmsg.txfields('68').value,0),NULL,'',p_txmsg.deltd,'',seq_CITRAN.NEXTVAL, p_txmsg.tltxcd,p_txmsg.busdate,utf8nums.c_const_TLTX_TXDESC_0088_FEE);
    INSERT INTO CITRAN(TXNUM,TXDATE,ACCTNO,TXCD,NAMT,CAMT,ACCTREF,DELTD,REF,AUTOID,TLTXCD,BKDATE,TRDESC)
    VALUES (p_txmsg.txnum, TO_DATE (p_txmsg.txdate, systemnums.C_DATE_FORMAT),p_txmsg.txfields('03').value,'0016', ROUND(p_txmsg.txfields('68').value,0),NULL,'',p_txmsg.deltd,'',seq_CITRAN.NEXTVAL, p_txmsg.tltxcd,p_txmsg.busdate,'' || '' || '');

    l_txdesc:= 'Thu phi luu ky dong tai khoan';
    INSERT INTO CITRAN(TXNUM,TXDATE,ACCTNO,TXCD,NAMT,CAMT,ACCTREF,DELTD,REF,AUTOID,TLTXCD,BKDATE,TRDESC)
        VALUES (p_txmsg.txnum, TO_DATE (p_txmsg.txdate, systemnums.C_DATE_FORMAT),p_txmsg.txfields('03').value,'0011',ROUND(p_txmsg.txfields('17').value,0),NULL,'',p_txmsg.deltd,'',seq_CITRAN.NEXTVAL,p_txmsg.tltxcd,p_txmsg.busdate,'' || l_txdesc || '');
    INSERT INTO CITRAN(TXNUM,TXDATE,ACCTNO,TXCD,NAMT,CAMT,ACCTREF,DELTD,REF,AUTOID,TLTXCD,BKDATE,TRDESC)
        VALUES (p_txmsg.txnum, TO_DATE (p_txmsg.txdate, systemnums.C_DATE_FORMAT),p_txmsg.txfields('03').value,'0080',ROUND(p_txmsg.txfields('17').value,4),NULL,'',p_txmsg.deltd,'',seq_CITRAN.NEXTVAL,p_txmsg.tltxcd,p_txmsg.busdate,'' || '' || '');
    INSERT INTO CITRAN(TXNUM,TXDATE,ACCTNO,TXCD,NAMT,CAMT,ACCTREF,DELTD,REF,AUTOID,TLTXCD,BKDATE,TRDESC)
        VALUES (p_txmsg.txnum, TO_DATE (p_txmsg.txdate, systemnums.C_DATE_FORMAT),p_txmsg.txfields('03').value,'0081',ROUND(p_txmsg.txfields('17').value,4),NULL,'',p_txmsg.deltd,'',seq_CITRAN.NEXTVAL,p_txmsg.tltxcd,p_txmsg.busdate,'' || '' || '');
    /* Thu phi chuyen khoan chung khoan. END */

       -- phi dong tk
       INSERT INTO CITRAN(TXNUM,TXDATE,ACCTNO,TXCD,NAMT,CAMT,ACCTREF,DELTD,REF,AUTOID,TLTXCD,BKDATE,TRDESC)
            VALUES (p_txmsg.txnum, TO_DATE (p_txmsg.txdate, systemnums.C_DATE_FORMAT),p_txmsg.txfields ('03').value,'0011',ROUND(p_txmsg.txfields('55').value,0),NULL,'',p_txmsg.deltd,'',seq_CITRAN.NEXTVAL,p_txmsg.tltxcd,p_txmsg.busdate,'' || '' || '');

      INSERT INTO CITRAN(TXNUM,TXDATE,ACCTNO,TXCD,NAMT,CAMT,ACCTREF,DELTD,REF,AUTOID,TLTXCD,BKDATE,TRDESC)
            VALUES (p_txmsg.txnum, TO_DATE (p_txmsg.txdate, systemnums.C_DATE_FORMAT),p_txmsg.txfields ('03').value,'0016',ROUND(p_txmsg.txfields('55').value,0),NULL,'',p_txmsg.deltd,'',seq_CITRAN.NEXTVAL,p_txmsg.tltxcd,p_txmsg.busdate,'' || '' || '');



      UPDATE CIMAST
         SET
           BALANCE = BALANCE - (ROUND(p_txmsg.txfields('55').value,0)),
           DRAMT = DRAMT + (ROUND(p_txmsg.txfields('55').value,0)),
           LASTDATE = to_date(TO_DATE(p_txmsg.txdate, systemnums.C_DATE_FORMAT), 'DD/MM/RRRR'), LAST_CHANGE = SYSTIMESTAMP
        WHERE ACCTNO=p_txmsg.txfields('03').value;


     -- Log SENDSETOCLOSE neu can chuyen chung khoan ra ngoai
    select custid into l_custid from cfmast where custodycd = p_txmsg.txfields('88').value;
    if(p_txmsg.txfields('45').value ='Y') THEN
        UPDATE SENDSETOCLOSE SET deltd='Y' WHERE  CUSTID=l_custid;

        INSERT INTO SENDSETOCLOSE (AUTOID,CUSTID,REFCUSTODYCD,REFINWARD,DELTD,txnum,txdate,desttype,REFAFACCTNO)
        VALUES(seq_SENDSETOCLOSE.nextval,l_custid, p_txmsg.txfields('47').value ,p_txmsg.txfields('48').value ,'N',p_txmsg.txnum,to_DAte(p_txmsg.txdate,'DD/MM/RRRR'),p_txmsg.txfields('81').value,p_txmsg.txfields('50').value);
    END IF;

    for rec_af in
    (
        select af.acctno, cf.custid, cf.custodycd,
            ci.odamt, ci.odintacr, ci.DEPOFEEAMT, ci.CIDEPOFEEACR, ci.crintacr,
            NVL(CIFEE.AVL_FEEDR,0) AVL_FEEDR, NVL(CIFEE.AVL_VSDDEP,0) AVL_VSDDEP
        from cfmast cf, afmast af, cimast ci,
              (SELECT AFACCTNO ,  SUM(CASE WHEN FEETYPE='FEEDR' THEN (NMLAMT -PAIDAMT) ELSE 0 END) AVL_FEEDR,
                      SUM(CASE WHEN FEETYPE='VSDDEP' THEN (NMLAMT -PAIDAMT) ELSE 0 END) AVL_VSDDEP
              FROM CIFEESCHD WHERE DELTD<>'Y'
              GROUP BY AFACCTNO) CIFEE
        where cf.custid = af.custid and af.acctno = CI.ACCTNO
              AND AF.ACCTNO=CIFEE.AFACCTNO(+)
            and cf.custodycd = p_txmsg.txfields('88').value and af.status not in ('C','N')
            and case when p_txmsg.txfields('80').value = '001' then 1
                    when p_txmsg.txfields('80').value <> '001' and af.acctno = p_txmsg.txfields('03').value then 1
                    else 0 end = 1
    )
    loop
        -- Gen bang ke in Loop
       v_blnREVERSAL:=case when p_txmsg.deltd ='Y' then true else false end;
       if not v_blnREVERSAL then
           v_strAFACCTNO:=rec_af.acctno;
           --Kiem tra neu la TK corebank thi tiep tuc
           select corebank,bankname,bankacctno into v_strCOREBANK, v_strafbankname, v_strafbankacctno from afmast where acctno = rec_af.acctno;
           if v_strCOREBANK ='Y' then
               --Begin Gen yeu cau sang ngan hang 0088-TRFNML
               v_strOBJTYPE:='T';
               v_strTRFCODE:='TRFSEFEE';
               v_strREFCODE:= to_char(p_txmsg.txdate,'DD/MM/RRRR') || p_txmsg.txnum;
               v_strAFFECTDATE:= to_char(p_txmsg.txdate,'DD/MM/RRRR');
               v_strBANK:=v_strafbankname;
               v_strBANKACCT:=v_strafbankacctno;
               v_strNOTES:=p_txmsg.txfields('30').value;
               v_strVALUE:= ROUND(rec_af.DEPOFEEAMT+rec_af.CIDEPOFEEACR,0);
                --plog.error (pkgctx, SQLERRM);
               if length(v_strBANK)>0 and length(v_strBANKACCT)>0 and v_strVALUE >0 then
                   --Ghi nhan vao CRBTXREQ
                   select seq_CRBTXREQ.nextval into v_strREFAUTOID from dual;
                   INSERT INTO CRBTXREQ (REQID, OBJTYPE, OBJNAME, OBJKEY, TRFCODE, REFCODE, TXDATE, AFFECTDATE, AFACCTNO, TXAMT, BANKCODE, BANKACCT, STATUS, REFVAL, NOTES)
                       VALUES (v_strREFAUTOID, 'T', p_txmsg.tltxcd,p_txmsg.txnum, v_strTRFCODE,v_strREFCODE, TO_DATE(p_txmsg.txdate, 'dd/mm/rrrr'), TO_DATE(v_strAFFECTDATE , 'dd/mm/rrrr'),
                               v_strAFACCTNO , v_strVALUE , v_strBANK,v_strBANKACCT, 'P', NULL,v_strNOTES);

                    --Dr HoldBalance transfer amount
                   UPDATE CIMAST
                   SET
                   HOLDBALANCE = HOLDBALANCE  - (ROUND(rec_af.DEPOFEEAMT+rec_af.CIDEPOFEEACR,0))
                   WHERE ACCTNO=rec_af.acctno;

                   l_txdesc:= 'Thu phi luu ky dong tai khoan';
                   INSERT INTO CITRAN(TXNUM,TXDATE,ACCTNO,TXCD,NAMT,CAMT,ACCTREF,DELTD,REF,AUTOID,TLTXCD,BKDATE,TRDESC)
                   VALUES (p_txmsg.txnum, TO_DATE (p_txmsg.txdate, systemnums.C_DATE_FORMAT),rec_af.acctno,'0051',ROUND(rec_af.DEPOFEEAMT+rec_af.CIDEPOFEEACR,0),NULL,'',p_txmsg.deltd,'',seq_CITRAN.NEXTVAL,p_txmsg.tltxcd,p_txmsg.busdate,'' || l_txdesc || '');


                   --Group bang ke theo tung ngan hang.(Nhom vao bang ke sinh ra cuoi cung)
                   update crbtxreq set grpreqid= (select nvl(max(reqid),'') from crbtxreq where objkey = p_txmsg.txnum and txdate =  TO_DATE(p_txmsg.txdate, 'dd/mm/rrrr') and  BANKCODE=v_strBANK)
                   where objkey = p_txmsg.txnum and txdate =  TO_DATE(p_txmsg.txdate, 'dd/mm/rrrr') and BANKCODE=v_strBANK;

                   v_strFLDNAME:='CUSTODYCD';
                   v_strFLDTYPE:='C';
                   v_strAMTEXP:='$88';
                   v_strSQL:='';
                   v_strVALUE := substr(v_strAMTEXP, 2);
                   v_strVALUE := p_txmsg.txfields(v_strVALUE).value;

                   INSERT INTO CRBTXREQDTL (AUTOID, REQID, FLDNAME, CVAL, NVAL)
                   select SEQ_CRBTXREQDTL.NEXTVAL,v_strREFAUTOID,v_strFLDNAME,
                       case when v_strFLDTYPE='N' then '' else to_char(v_strVALUE) end,
                       case when v_strFLDTYPE<>'N' then 0 else to_number(v_strVALUE) end
                       from dual;

                   v_strFLDNAME:='ACCTNO';
                   v_strFLDTYPE:='C';
                   v_strAMTEXP:='$02';
                   v_strSQL:='';
                   v_strVALUE := substr(v_strAMTEXP, 2);
                   v_strVALUE := p_txmsg.txfields(v_strVALUE).value;

                   INSERT INTO CRBTXREQDTL (AUTOID, REQID, FLDNAME, CVAL, NVAL)
                   select SEQ_CRBTXREQDTL.NEXTVAL,v_strREFAUTOID,v_strFLDNAME,
                       case when v_strFLDTYPE='N' then '' else to_char(v_strVALUE) end,
                       case when v_strFLDTYPE<>'N' then 0 else to_number(v_strVALUE) end
                       from dual;

                   v_strFLDNAME:='NAME';
                   v_strFLDTYPE:='C';
                   v_strAMTEXP:='$31';
                   v_strSQL:='';
                   v_strVALUE := substr(v_strAMTEXP, 2);
                   v_strVALUE := p_txmsg.txfields(v_strVALUE).value;

                   INSERT INTO CRBTXREQDTL (AUTOID, REQID, FLDNAME, CVAL, NVAL)
                   select SEQ_CRBTXREQDTL.NEXTVAL,v_strREFAUTOID,v_strFLDNAME,
                       case when v_strFLDTYPE='N' then '' else to_char(v_strVALUE) end,
                       case when v_strFLDTYPE<>'N' then 0 else to_number(v_strVALUE) end
                       from dual;

               End if;
           end if;
       else

           begin
               SELECT STATUS into v_strStatus FROM CRBTXREQ MST WHERE MST.OBJNAME=p_txmsg.tltxcd AND MST.OBJKEY=p_txmsg.txnum AND MST.TXDATE=TO_DATE(p_txmsg.txdate, 'DD/MM/RRRR');
               if  v_strStatus = 'P' then
                   update CRBTXREQ set status ='D' WHERE OBJNAME=p_txmsg.tltxcd AND OBJKEY=p_txmsg.txnum AND TXDATE=TO_DATE(p_txmsg.txdate, 'DD/MM/RRRR');
                   UPDATE CIMAST
                   SET HOLDBALANCE = HOLDBALANCE  + (ROUND(rec_af.DEPOFEEAMT+rec_af.CIDEPOFEEACR,0))
                   WHERE ACCTNO=rec_af.acctno;
               else
                   plog.setendsection (pkgctx, 'fn_txAppUpdate');
                   p_err_code:=-670101;--Trang thai bang ke khong hop le
                   Return errnums.C_BIZ_RULE_INVALID;
               end if;
           exception when others then
               null; --Khong co bang ke can xoa
           end;
       End if;


        --cspks_rmproc.sp_exec_create_crbtrflog_auto(TO_char(p_txmsg.txdate, 'dd/mm/rrrr'), p_txmsg.txnum,p_err_code);

        INSERT INTO AFTRAN(TXNUM,TXDATE,ACCTNO,TXCD,NAMT,CAMT,ACCTREF,DELTD,REF,AUTOID,TLTXCD,BKDATE,TRDESC)
            VALUES (p_txmsg.txnum, TO_DATE (p_txmsg.txdate, systemnums.C_DATE_FORMAT),rec_af.acctno,'0001',0,'N','',p_txmsg.deltd,'',seq_AFTRAN.NEXTVAL,p_txmsg.tltxcd,p_txmsg.busdate,'' || '' || '');

        l_txdesc:= 'Thu phi luu ky dong tai khoan';
        INSERT INTO CITRAN(TXNUM,TXDATE,ACCTNO,TXCD,NAMT,CAMT,ACCTREF,DELTD,REF,AUTOID,TLTXCD,BKDATE,TRDESC)
            VALUES (p_txmsg.txnum, TO_DATE (p_txmsg.txdate, systemnums.C_DATE_FORMAT),rec_af.acctno,'0011',ROUND(REC_AF.AVL_VSDDEP+rec_af.CIDEPOFEEACR,0),NULL,'',p_txmsg.deltd,'',seq_CITRAN.NEXTVAL,p_txmsg.tltxcd,p_txmsg.busdate,'' || l_txdesc || '');
        l_txdesc:= 'Thu phi chuyen khoan CK con no';
          INSERT INTO CITRAN(TXNUM,TXDATE,ACCTNO,TXCD,NAMT,CAMT,ACCTREF,DELTD,REF,AUTOID,TLTXCD,BKDATE,TRDESC)
            VALUES (p_txmsg.txnum, TO_DATE (p_txmsg.txdate, systemnums.C_DATE_FORMAT),rec_af.acctno,'0011',ROUND(REC_AF.AVL_FEEDR,0),NULL,'',p_txmsg.deltd,'',seq_CITRAN.NEXTVAL,p_txmsg.tltxcd,p_txmsg.busdate,'' || l_txdesc || '');

        l_txdesc:= 'Lai tien gui thang ' || to_char(p_txmsg.txdate,'MM/RRRR');
        INSERT INTO CITRAN(TXNUM,TXDATE,ACCTNO,TXCD,NAMT,CAMT,ACCTREF,DELTD,REF,AUTOID,TLTXCD,BKDATE,TRDESC)
            VALUES (p_txmsg.txnum, TO_DATE (p_txmsg.txdate, systemnums.C_DATE_FORMAT),rec_af.acctno,'0012',ROUND(rec_af.crintacr,0),NULL,'',p_txmsg.deltd,'',seq_CITRAN.NEXTVAL,p_txmsg.tltxcd,p_txmsg.busdate,'' || l_txdesc || '');

        INSERT INTO CITRAN(TXNUM,TXDATE,ACCTNO,TXCD,NAMT,CAMT,ACCTREF,DELTD,REF,AUTOID,TLTXCD,BKDATE,TRDESC)
            VALUES (p_txmsg.txnum, TO_DATE (p_txmsg.txdate, systemnums.C_DATE_FORMAT),rec_af.acctno,'0080',ROUND(rec_af.CIDEPOFEEACR,0),NULL,'',p_txmsg.deltd,'',seq_CITRAN.NEXTVAL,p_txmsg.tltxcd,p_txmsg.busdate,'' || '' || '');

        INSERT INTO CITRAN(TXNUM,TXDATE,ACCTNO,TXCD,NAMT,CAMT,ACCTREF,DELTD,REF,AUTOID,TLTXCD,BKDATE,TRDESC)
            VALUES (p_txmsg.txnum, TO_DATE (p_txmsg.txdate, systemnums.C_DATE_FORMAT),rec_af.acctno,'0014',ROUND(rec_af.crintacr,0),NULL,'',p_txmsg.deltd,'',seq_CITRAN.NEXTVAL,p_txmsg.tltxcd,p_txmsg.busdate,'' || '' || '');

        INSERT INTO CITRAN(TXNUM,TXDATE,ACCTNO,TXCD,NAMT,CAMT,ACCTREF,DELTD,REF,AUTOID,TLTXCD,BKDATE,TRDESC)
            VALUES (p_txmsg.txnum, TO_DATE (p_txmsg.txdate, systemnums.C_DATE_FORMAT),rec_af.acctno,'0023',ROUND(rec_af.crintacr,4),NULL,rec_af.acctno,p_txmsg.deltd,rec_af.acctno,seq_CITRAN.NEXTVAL,p_txmsg.tltxcd,p_txmsg.busdate,'' || '' || '');

        INSERT INTO CITRAN(TXNUM,TXDATE,ACCTNO,TXCD,NAMT,CAMT,ACCTREF,DELTD,REF,AUTOID,TLTXCD,BKDATE,TRDESC)
            VALUES (p_txmsg.txnum, TO_DATE (p_txmsg.txdate, systemnums.C_DATE_FORMAT),rec_af.acctno,'0088',ROUND(rec_af.DEPOFEEAMT,4),NULL,'',p_txmsg.deltd,'',seq_CITRAN.NEXTVAL,p_txmsg.tltxcd,p_txmsg.busdate,'' || '' || '');

        INSERT INTO CITRAN(TXNUM,TXDATE,ACCTNO,TXCD,NAMT,CAMT,ACCTREF,DELTD,REF,AUTOID,TLTXCD,BKDATE,TRDESC)
            VALUES (p_txmsg.txnum, TO_DATE (p_txmsg.txdate, systemnums.C_DATE_FORMAT),rec_af.acctno,'0034',ROUND(rec_af.odamt+rec_af.odintacr,0),NULL,'',p_txmsg.deltd,'',seq_CITRAN.NEXTVAL,p_txmsg.tltxcd,p_txmsg.busdate,'' || '' || '');

        INSERT INTO CITRAN(TXNUM,TXDATE,ACCTNO,TXCD,NAMT,CAMT,ACCTREF,DELTD,REF,AUTOID,TLTXCD,BKDATE,TRDESC)
            VALUES (p_txmsg.txnum, TO_DATE (p_txmsg.txdate, systemnums.C_DATE_FORMAT),rec_af.acctno,'0035',ROUND(rec_af.odintacr,0),NULL,'',p_txmsg.deltd,'',seq_CITRAN.NEXTVAL,p_txmsg.tltxcd,p_txmsg.busdate,'' || '' || '');

        INSERT INTO CITRAN(TXNUM,TXDATE,ACCTNO,TXCD,NAMT,CAMT,ACCTREF,DELTD,REF,AUTOID,TLTXCD,BKDATE,TRDESC)
            VALUES (p_txmsg.txnum, TO_DATE (p_txmsg.txdate, systemnums.C_DATE_FORMAT),rec_af.acctno,'0021',ROUND(rec_af.odintacr,4),NULL,rec_af.acctno,p_txmsg.deltd,rec_af.acctno,seq_CITRAN.NEXTVAL,p_txmsg.tltxcd,p_txmsg.busdate,'' || '' || '');

        INSERT INTO CITRAN(TXNUM,TXDATE,ACCTNO,TXCD,NAMT,CAMT,ACCTREF,DELTD,REF,AUTOID,TLTXCD,BKDATE,TRDESC)
            VALUES (p_txmsg.txnum, TO_DATE (p_txmsg.txdate, systemnums.C_DATE_FORMAT),rec_af.acctno,'0001',0,'N','',p_txmsg.deltd,'',seq_CITRAN.NEXTVAL,p_txmsg.tltxcd,p_txmsg.busdate,'' || '' || '');

        UPDATE CIMAST
         SET
           ODAMT = ODAMT - (ROUND(rec_af.odamt+rec_af.odintacr,0)) + (ROUND(rec_af.odintacr,0)),
           BALANCE = BALANCE + (ROUND(rec_af.crintacr,0)) - (ROUND(rec_af.DEPOFEEAMT+rec_af.CIDEPOFEEACR,0)),
           PSTATUS=PSTATUS||STATUS,STATUS='N',
           ODINTACR = ODINTACR - (ROUND(rec_af.odintacr,4)),
           CRINTACR = CRINTACR - (ROUND(rec_af.crintacr,4)),
           CIDEPOFEEACR = CIDEPOFEEACR - (ROUND(rec_af.CIDEPOFEEACR,0)),
           LASTDATE = TO_DATE(p_txmsg.txdate, systemnums.C_DATE_FORMAT),
           CRAMT = CRAMT + (ROUND(rec_af.crintacr,0)),
           DEPOFEEAMT = DEPOFEEAMT - (ROUND(rec_af.DEPOFEEAMT,4)), LAST_CHANGE = SYSTIMESTAMP
        WHERE ACCTNO=rec_af.acctno;

        UPDATE AFMAST
         SET
           PSTATUS=PSTATUS||STATUS,STATUS='N',
           LASTDATE = TO_DATE(p_txmsg.txdate, systemnums.C_DATE_FORMAT), LAST_CHANGE = SYSTIMESTAMP
        WHERE ACCTNO=rec_af.acctno;


        -- update CIDEPOFEEACR, DEPOFEEAMT cua CIMAST =0 cho TK sai so nen nhan ja tri am hoac le
        UPDATE cimast SET cidepofeeacr=0, depofeeamt=0 WHERE acctno = rec_af.acctno;-- p_txmsg.txfields('03').value;
        UPDATE cifeeschd SET paidamt=nmlamt,paidtxnum=p_txmsg.txnum,paidtxdate=p_txmsg.busdate
        WHERE afacctno = rec_af.acctno AND paidamt<> nmlamt; --p_txmsg.txfields('03').value;
        Update cidepofeetran set status='C' where status<>'C' and afacctno=rec_af.acctno;


        /* Log Bao cao */
        -- HaiLT them de log cho bao cao CF0080

        SELECT SUM(greatest(nvl(adv.avladvance,0) + ci.balance - ci.ovamt - ci.dueamt - ci.dfdebtamt - ci.dfintdebtamt -
    NVL (overamt, 0) - nvl(b.secureamt,0)  - ci.trfbuyamt- ramt-nvl(pd.dealpaidamt,0) - ci.depofeeamt,0)) INTO V_BALANCE
    FROM CFMAST CF, AFMAST AF, cimast ci
    left join (select * from v_getbuyorderinfo where afacctno LIKE rec_af.acctno) b
    on ci.acctno = b.afacctno
    LEFT JOIN (select aamt,depoamt avladvance, advamt advanceamount,afacctno, paidamt
            from v_getAccountAvlAdvance where afacctno LIKE rec_af.acctno) adv
    on adv.afacctno = ci.acctno
    LEFT JOIN(select * from v_getdealpaidbyaccount p where p.afacctno LIKE rec_af.acctno) pd
    on pd.afacctno = ci.acctno
    WHERE CF.custid = AF.custid AND CI.afacctno=AF.acctno AND CF.custodycd  = rec_af.custodycd
        AND AF.acctno = rec_af.acctno
    ;

   V_BALANCE := NVL(V_BALANCE,0);

        INSERT INTO CF0080_LOG (CUSTODYCD, AFACCTNO, TXDATE, TXNUM, TLTXCD, BRID, BRNAME, FULLNAME, IDCODE, IDDATE, IDPLACE, ADDRESS,
                PHONE, MOBILE, SYMBOL, TRADEPLACE, TRADE, BLOCKED, TRADE_WFT, BLOCKED_WFT, ISCLOSED, balance )
        SELECT  rec_af.custodycd, rec_af.acctno, to_DAte(p_txmsg.txdate,'DD/MM/RRRR'),p_txmsg.txnum, p_txmsg.tltxcd,
             BRID,BRNAME, main.fullname, main.idcode, main.iddate, main.idplace, main.address, main.phone, main.mobile,
              main.wft_symbol symbol, tradeplace,
            sum(CASE WHEN instr(symbol,'_WFT') = 0 THEN nvl(trade,0) + NVL(B.BUYQTTY,0)- nvl(b.SELLQTTY,0) ELSE 0 END) trade,
             sum(CASE WHEN instr(symbol,'_WFT') = 0 THEN blocked ELSE 0 END) blocked,
             sum(CASE WHEN instr(symbol,'_WFT') <> 0 THEN nvl(trade,0) + NVL(B.BUYQTTY,0)- nvl(b.SELLQTTY,0) ELSE 0 END) trade_WFT,
             sum(CASE WHEN instr(symbol,'_WFT') <> 0 THEN blocked ELSE 0 END) blocked_WFT,
             CASE WHEN 0 >0 THEN 'N' ELSE 'Y' END ISCLOSED, V_BALANCE
        FROM (SELECT BR.BRID, BRNAME,cf.fullname, DECODE(SUBSTR(CF.CUSTODYCD,4,1),'F',CF.TRADINGCODE,CF.IDCODE) idcode,
                               DECODE(SUBSTR(CF.CUSTODYCD,4,1),'F',CF.TRADINGCODEDT,CF.IDDATE) iddate,
                             cf.idplace, cf.address, CF.phone, cf.mobile,cf.custodycd,
                  nvl(sb.symbol,'') symbol, nvl(sb_wft.symbol,'') wft_symbol,
                         nvl(sb_wft.sectype,'') sectype, nvl(sb_wft.issuerid,'') issuerid ,
                         --nvl(sb_wft.tradeplace,'') tradeplace,
                         nvl(se.trade,0) - sum(CASE WHEN tran.field = 'TRADE' AND tran.txcd = 'D' THEN - nvl(tran.namt,0)
                                          WHEN tran.field = 'TRADE' AND tran.txcd = 'C' THEN nvl(tran.namt,0)
                                          ELSE 0 END) trade,
                         nvl(se.blocked,0) - sum(CASE WHEN tran.field = 'BLOCKED' AND tran.txcd = 'D' THEN - nvl(tran.namt,0)
                                              WHEN tran.field = 'BLOCKED' AND tran.txcd = 'C' THEN nvl(tran.namt,0)
                                              ELSE 0 END) blocked,
                         SE.receiving,
                       CASE WHEN sb.markettype = '001' AND sb.sectype IN ('003','006','222','333','444') THEN utf8nums.c_const_df_marketname
                          WHEN  nvl(sb_wft.tradeplace,'') = '001' THEN 'HOSE'
                          WHEN  nvl(sb_wft.tradeplace,'') = '002' THEN 'HNX'
                          WHEN  nvl(sb_wft.tradeplace,'') = '005' THEN 'UPCOM'  END tradeplace

                  FROM BRGRP BR, cfmast cf, afmast af,semast se,
                  (SELECT * FROM vw_setran_gen WHERE txdate >= to_DAte(p_txmsg.txdate,'DD/MM/RRRR') and field in ('TRADE','BLOCKED')) tran, sbsecurities sb,
                       sbsecurities sb_wft
                  WHERE
                  cf.custodycd = rec_af.custodycd
                  AND af.custid = cf.custid AND AF.ACCTNO = rec_af.acctno
                  AND SE.afacctno = rec_af.acctno
                  and sb.sectype not in ('111','222','333','444','004')
                  AND BR.BRID = SUBSTR(CF.CUSTID,1,4)
                  AND af.acctno =  se.afacctno (+)
                  and se.acctno = tran.acctno (+)
                  AND se.codeid = sb.codeid (+)
                  AND nvl(sb.refcodeid, sb.codeid) = sb_wft.codeid (+)
                  GROUP BY BR.BRID,BRNAME,sb.markettype,sb.sectype,cf.fullname, cf.idcode, cf.iddate, cf.idplace, cf.address, cf.phone, cf.mobile,
                  cf.custodycd, se.trade, se.blocked,SE.receiving, sb.symbol, sb_wft.symbol,
                  sb_wft.sectype, sb_wft.issuerid,sb_wft.tradeplace,cf.TRADINGCODEDT,CF.TRADINGCODE--, tran.field
              ) main left join
                (SELECT CUSTODYCD,CODEID,SYMBOL SYMBOLL, SUM(CASE WHEN BORS = 'S' THEN QTTY ELSE 0 END) SELLQTTY,
                        SUM(CASE WHEN BORS = 'B' THEN QTTY ELSE 0 END) BUYQTTY
                    FROM IOD WHERE DELTD <> 'Y' AND custodycd = rec_af.custodycd
                    GROUP BY CUSTODYCD, CODEID,SYMBOL) b
                on main.custodycd=b.custodycd and main.symbol=b.symboll
            GROUP BY BRID,BRNAME,main.fullname, main.idcode, main.iddate, main.idplace, main.address,
            main.phone, main.mobile,main.custodycd, main.wft_symbol, main.tradeplace;


        -- HaiLT them de log cho bao cao CF0081
        insert into CF0081_LOG
        SELECT rec_af.custodycd, rec_af.acctno, to_DAte(p_txmsg.txdate,'DD/MM/RRRR'),p_txmsg.txnum, p_txmsg.tltxcd,
               CAMASTID, CA_GROUP, CATYPENAME, TRADEPLACE, SYMBOL, DEVIDENTSHARES, DEVIDENTRATE, RIGHTOFFRATE,
               EXPRICE, INTERESTRATE, EXRATE, REPORTDATE, CATYPE,
               SUM(TRADE) TRADE, SUM(AMT) AMT, SUM(QTTY) QTTY, SUM(RQTTY) RQTTY, SUM(PBALANCE) PBALANCE,
               SUM(BALANCE) BALANCE, CASE WHEN v_mrcount >0 THEN 'N' ELSE 'Y' END ISCLOSED
        FROM
        (
            SELECT CAS.CAMASTID,CAS.BALANCE, CAS.PBALANCE, CAS.RQTTY, CAS.QTTY, CAS.AMT, CAS.TRADE,
                CA.CATYPE , CA.REPORTDATE, CA.EXRATE,CA.INTERESTRATE, CA.EXPRICE, CA.RIGHTOFFRATE,
                CASE WHEN CA.CATYPE='010' AND CA.DEVIDENTRATE=0 THEN TO_CHAR(CA.DEVIDENTVALUE) ELSE CA.DEVIDENTRATE END DEVIDENTRATE,
                CA.DEVIDENTSHARES , SB.SYMBOL, A1.CDCONTENT TRADEPLACE,
                CASE WHEN CA.CATYPE = '011' THEN utf8nums.c_const_ca_rightname_a -- 'A. QUY?N NH?N C? T?C B?NG C? PHI?U'
                     WHEN CA.CATYPE = '010' THEN utf8nums.c_const_ca_rightname_c -- 'C. QUY?N NH?N C? T?C B?NG TI?N'
                     WHEN CA.CATYPE = '021' THEN utf8nums.c_const_ca_rightname_b -- 'B. QUY?N C? PHI?U THU?NG'
                     WHEN CA.CATYPE = '014' THEN utf8nums.c_const_ca_rightname_d -- 'D. QUY?N MUA'
                     WHEN CA.CATYPE = '020' THEN utf8nums.c_const_ca_rightname_e -- 'E. QUY?N HO?N ?I C? PHI?U'
                     WHEN CA.CATYPE in ('017','023') THEN utf8nums.c_const_ca_rightname_f --'F. QUY?N CHUY?N ?I TR?I PHI?U'
                     WHEN CA.CATYPE IN ('022','005','006') THEN utf8nums.c_const_ca_rightname_g --'G. QUY?N BI?U QUY?T'
                     ELSE v_rightname_h --'H. QUY?N KH?C'
                end CATYPENAME,
                CASE WHEN CA.CATYPE IN ('011','021') THEN 1
                     WHEN CA.CATYPE IN ('010') THEN 2
                     WHEN CA.CATYPE IN ('014') THEN 3
                     WHEN CA.CATYPE IN ('020') THEN 4
                     WHEN CA.CATYPE IN ('017','023') THEN 5
                     WHEN CA.CATYPE IN ('022','005','006')  THEN 6 ELSE 7
                END CA_GROUP
                FROM CASCHD CAS, CAMAST CA, SBSECURITIES SB, ALLCODE A1, ALLCODE A2, AFMAST AF, CFMAST CF
            WHERE CAS.CAMASTID = CA.CAMASTID AND CAS.CODEID=SB.CODEID AND CAS.AFACCTNO = AF.ACCTNO
            AND AF.CUSTID= CF.CUSTID
            AND A1.CDNAME='TRADEPLACE' AND A1.CDTYPE='SE' AND A1.CDVAL=SB.TRADEPLACE
            AND A2.CDNAME='CATYPE' AND A2.CDTYPE='CA' AND CA.CATYPE = A2.CDVAL
            AND CF.CUSTODYCD = rec_af.custodycd
            AND AF.ACCTNO = rec_af.acctno
            AND AF.STATUS='N' AND CAS.AFACCTNO = rec_af.acctno
            AND CAS.DELTD <> 'Y'
            AND (CASE WHEN CAS.STATUS IN ('C','J') THEN 0 ELSE 1 END) > 0
        ) A
        GROUP BY
          CATYPE , REPORTDATE, EXRATE,INTERESTRATE, EXPRICE, RIGHTOFFRATE, DEVIDENTRATE, DEVIDENTSHARES , SYMBOL, TRADEPLACE,
          CATYPENAME, CA_GROUP,CAMASTID
        ORDER BY A.CATYPENAME;
        -- End of HaiLT them de log cho bao cao CF0081
        /* Log Bao cao END*/
    end loop;


    --Gom bang ke tu dong
    cspks_rmproc.sp_exec_create_crbtrflog_auto(TO_char(p_txmsg.txdate, 'dd/mm/rrrr'), p_txmsg.txnum,p_err_code);

else
    -- begin binhvt 09-2016
        UPDATE SETYPETRF set DELTD = 'Y' where txnum = P_TXMSG.TXNUM AND TXDATE=P_TXMSG.TXDATE;
        -- end binhvt
--lu0ng xoa giao dich
L_AMT:=0;
BEGIN
FOR REC IN (
SELECT  AF.ACCTNO ,
SUM(NVL(CASE WHEN TXTYPE ='C' AND FIELD ='ODAMT' THEN NAMT WHEN TXTYPE ='D' AND FIELD ='ODAMT' THEN -NAMT END,0))  ODAMT,
SUM(NVL(CASE WHEN TXTYPE ='C' AND FIELD ='BALANCE' THEN NAMT WHEN TXTYPE ='D' AND FIELD ='BALANCE' THEN -NAMT END,0))  BALANCE,
SUM(NVL(CASE WHEN TXTYPE ='C' AND FIELD ='ODINTACR' THEN NAMT WHEN TXTYPE ='D' AND FIELD ='ODINTACR' THEN -NAMT END,0))  ODINTACR,
SUM(NVL(CASE WHEN TXTYPE ='C' AND FIELD ='CRINTACR' THEN NAMT WHEN TXTYPE ='D' AND FIELD ='CRINTACR' THEN -NAMT END,0))  CRINTACR,
SUM(NVL(CASE WHEN TXTYPE ='C' AND FIELD ='CIDEPOFEEACR' THEN NAMT WHEN TXTYPE ='D' AND FIELD ='CIDEPOFEEACR' THEN -NAMT END,0))  CIDEPOFEEACR,
SUM(NVL(CASE WHEN TXTYPE ='C' AND FIELD ='CRAMT' THEN NAMT WHEN TXTYPE ='D' AND FIELD ='CRAMT' THEN -NAMT END,0))  CRAMT,
SUM(NVL(CASE WHEN TXTYPE ='C' AND FIELD ='DEPOFEEAMT' THEN NAMT WHEN TXTYPE ='D' AND FIELD ='DEPOFEEAMT' THEN -NAMT END,0))  DEPOFEEAMT,
SUM(NVL(CASE WHEN TXTYPE ='C' AND FIELD ='DRAMT' THEN NAMT WHEN TXTYPE ='D' AND FIELD ='DRAMT' THEN -NAMT END,0))  DRAMT
FROM CITRAN CI, TLLOG TL, CFMAST CF, AFMAST AF, APPTX APP
WHERE CI.TXDATE = TL.TXDATE AND CI.TXNUM = TL.TXNUM
    AND CF.CUSTID = AF.CUSTID
    AND CI.ACCTNO = AF.ACCTNO
    AND CI.TXCD = APP.TXCD AND APP.APPTYPE = 'CI' AND APP.TXTYPE IN ('D','C')
    AND CI.NAMT <> 0
    AND CI.TXNUM =p_txmsg.txnum AND CI.TXDATE =TO_DATE (p_txmsg.txdate, systemnums.C_DATE_FORMAT)
GROUP BY AF.ACCTNO
)
LOOP

      plog.error (pkgctx,' REC.ACCTNO ' ||REC.ACCTNO );
      plog.error (pkgctx,' REC.BALANCE ' ||REC.BALANCE );
      plog.error (pkgctx,' p_txmsg.txnum ' ||p_txmsg.txnum );
     plog.error (pkgctx,' TO_DATE (p_txmsg.txdate, systemnums.C_DATE_FORMAT) ' ||TO_DATE (p_txmsg.txdate, systemnums.C_DATE_FORMAT) );

L_AMT:=L_AMT+ rec.DEPOFEEAMT;
L_AMT:=abs(L_AMT);
  plog.error (pkgctx,' L_AMT ' ||L_AMT );

UPDATE CIMAST SET BALANCE =BALANCE - REC.BALANCE,ODAMT =ODAMT - REC.ODAMT,ODINTACR =ODINTACR - REC.ODINTACR
,CRINTACR =CRINTACR - REC.CRINTACR,CIDEPOFEEACR =CIDEPOFEEACR - REC.CIDEPOFEEACR,CRAMT =CRAMT - REC.CRAMT,
DEPOFEEAMT =DEPOFEEAMT - REC.DEPOFEEAMT,DRAMT =DRAMT - REC.DRAMT
WHERE ACCTNO = REC.ACCTNO ;
END LOOP ;
END ;

update citran set deltd ='Y' WHERE TXNUM =p_txmsg.txnum AND TXDATE = TO_DATE (p_txmsg.txdate, systemnums.C_DATE_FORMAT);
update aftran set deltd ='Y' WHERE TXNUM =p_txmsg.txnum AND TXDATE = TO_DATE (p_txmsg.txdate, systemnums.C_DATE_FORMAT);

     -- Log SENDSETOCLOSE neu can chuyen chung khoan ra ngoai
select custid into l_custid from cfmast where custodycd = p_txmsg.txfields('88').value;

UPDATE SENDSETOCLOSE SET deltd='Y' WHERE  CUSTID=l_custid;

UPDATE AFMAST
         SET
           PSTATUS=PSTATUS||STATUS,STATUS='A',
           LASTDATE = TO_DATE(p_txmsg.txdate, systemnums.C_DATE_FORMAT), LAST_CHANGE = SYSTIMESTAMP
WHERE custid=l_custid;

UPDATE CIMAST
         SET
           PSTATUS=PSTATUS||STATUS,STATUS='A',
           LASTDATE = TO_DATE(p_txmsg.txdate, systemnums.C_DATE_FORMAT), LAST_CHANGE = SYSTIMESTAMP
WHERE custid=l_custid;

--UPDATE cifeeschd SET paidamt=0,paidtxnum= '' ,paidtxdate='' where paidtxnum = p_txmsg.txnum and paidtxdate=p_txmsg.busdate;

FOR rec IN (SELECT * FROM  cifeeschd where paidtxnum = p_txmsg.txnum and paidtxdate=p_txmsg.busdate ORDER BY autoid desc )
LOOP

UPDATE cifeeschd SET paidamt = paidamt- LEAST (L_AMT,rec.nmlamt) WHERE autoid = rec.autoid;
L_AMT:= L_AMT-LEAST (L_AMT,rec.nmlamt);

EXIT WHEN L_AMT<=0;

END LOOP;
-- Update cidepofeetran set status='C' where status<>'C' and afacctno=p_txmsg.txfields('03').value;
DELETE FROM CF0080_LOG WHERE TXNUM  = p_txmsg.txnum AND TXDATE = to_DAte(p_txmsg.txdate,'DD/MM/RRRR');
DELETE FROM CF0081_LOG WHERE TXNUM  = p_txmsg.txnum AND TXDATE = to_DAte(p_txmsg.txdate,'DD/MM/RRRR');
end if;

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
         plog.init ('TXPKS_#0088EX',
                    plevel => NVL(logrow.loglevel,30),
                    plogtable => (NVL(logrow.log4table,'N') = 'Y'),
                    palert => (NVL(logrow.log4alert,'N') = 'Y'),
                    ptrace => (NVL(logrow.log4trace,'N') = 'Y')
            );
END TXPKS_#0088EX;
/
