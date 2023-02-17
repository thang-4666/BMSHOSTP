SET DEFINE OFF;
CREATE OR REPLACE PACKAGE cspks_cfproc
IS
    /*----------------------------------------------------------------------------------------------------
     ** Module   : COMMODITY SYSTEM
     ** and is copyrighted by FSS.
     **
     **    All rights reserved.  No part of this work may be reproduced, stored in a retrieval system,
     **    adopted or transmitted in any form or by any means, electronic, mechanical, photographic,
     **    graphic, optic recording or otherwise, translated in any language or computer language,
     **    without the prior written permission of Financial Software Solutions. JSC.
     **
     **  MODIFICATION HISTORY
     **  Person      Date           Comments
     **  FSS      20-mar-2010    Created
     ** (c) 2008 by Financial Software Solutions. JSC.
     ----------------------------------------------------------------------------------------------------*/

    FUNCTION fn_ApplyTypeToMast(p_err_code in out varchar2)
    RETURN boolean;
    FUNCTION fn_ChangeCftype4expdate(p_err_code in out varchar2)
    RETURN boolean;
    FUNCTION fn_func_getcflimit (v_bankid in varchar2, v_custid in varchar2, v_subtype in varchar2, v_amt in number)
    RETURN NUMBER;
    FUNCTION fn_get_bank_outstanding (v_bankid in varchar2, v_defsubtyp in varchar2)
    return number;
    FUNCTION fn_getavlcflimit (v_bankid in varchar2, v_custid in varchar2, v_subtype in varchar2) RETURN NUMBER;
    FUNCTION fn_getavlbanklimit (v_bankid in varchar2, v_subtype in varchar2) RETURN NUMBER;
    FUNCTION fn_checkNonCustody (v_strCustodycd in varchar2) RETURN NUMBER;
  FUNCTION fn_getavlcflimitDFMR (p_lntype in varchar2, p_afacctno in varchar2) RETURN NUMBER;

  PROCEDURE pr_AllocMarginLimit (p_tlid in varchar2, p_afacctno in varchar2, p_amt in number, p_desc in varchar2, p_err_code in out varchar2);

  PROCEDURE pr_AFMAST_ChangeTypeCheck (p_afacctno in varchar2,p_actype in varchar2, p_err_code in out varchar2);

  FUNCTION fn_0088checkAFACCTNO (p_closetype in varchar2, p_afacctno in varchar2, p_setafacctno in varchar2) RETURN NUMBER;

  FUNCTION fn_0088checkAFCOUNT (p_closetype in varchar2, p_custodycd in varchar2) RETURN NUMBER;

  FUNCTION fn_0088getAFACCTNO (p_closetype in varchar2, p_custodycd in varchar2, p_afacctno in varchar2) RETURN varchar2;

  FUNCTION fn_0088getFEEDATE (p_closetype in varchar2) RETURN NUMBER;

  FUNCTION fn_0088getNEEDTRFSE (p_closetype in varchar2, p_custodycd in varchar2, p_afacctno in varchar2) RETURN varchar2;

    FUNCTION fn_getCustIDByCustodyCD(p_custodycd in varchar2)
    RETURN varchar2;
 PROCEDURE pr_DailyLogCFIfno(p_err_code in out varchar2);
 PROCEDURE Pr_Cfreview_Result(p_cfrvid in VARCHAR2,p_err_code in out varchar2);
 PROCEDURE pr_CFMAST_ChangeTypeCheck (p_CUSTID in varchar2,p_actype in varchar2, p_err_code in out varchar2);
 PROCEDURE pr_ChangeCFType(p_CUSTID in varchar2,p_actype in varchar2,p_err_code in out varchar2);
 PROCEDURE pr_Execute_CFreview(p_err_code in out varchar2);
 PROCEDURE pr_AutoOpenNormalAccount(p_CUSTID in varchar2,p_FirstTIme in varchar2, p_err_code in out varchar2);
 PROCEDURE     pr_AutoOpenMQAccount(p_CUSTID in varchar2,p_FirstTIme in varchar2, p_err_code in out varchar2);
 FUNCTION PR_CHECK_ACCOUNT_CALL(P_CUSTODYCD VARCHAR2) RETURN BOOLEAN;
 FUNCTION PR_CHECK_WARNING_RATE_LISTING(P_CUSTODYCD VARCHAR2, P_SYMBOL VARCHAR2, P_QTTY NUMBER ) RETURN BOOLEAN;
 FUNCTION FN_CHECK_ACCOUNT_MRIRATE(P_ACCTNO VARCHAR2,P_CODEID VARCHAR2,P_QTTY NUMBER , P_AMT NUMBER  ) RETURN BOOLEAN;
  PROCEDURE pr_AutoAddDomain(p_CUSTID in varchar2, p_err_code in out varchar2);
END;
/


CREATE OR REPLACE PACKAGE BODY cspks_cfproc
IS
   -- declare log context
   pkgctx   plog.log_ctx;
   logrow   tlogdebug%ROWTYPE;

---------------------------------pr_OpenLoanAccount------------------------------------------------
  FUNCTION fn_ApplyTypeToMast(p_err_code in out varchar2)
  RETURN boolean
  IS
  BEGIN
    plog.setendsection(pkgctx, 'fn_ApplyTypeToMast');
    --Cap nhat he so Margin tuan thu tu loai hinh xuong
    --aft.k1days,aft.k2days,mrt.mrcrate,mrt.mrwrate,mrt.mrexrate
    begin
        for rec in (
            select mrt.mriratio ,mrt.mrmratio ,mrt.mrlratio,
                   mrt.mrcrate,mrt.mrwrate,mrt.mrexrate,
                   af.acctno,aft.k1days,aft.k2days


            from afmast af, aftype aft , mrtype mrt
            where af.actype = aft.actype  and aft.mrtype = mrt.actype
            and (af.mriratio <> trunc(mrt.mriratio) or af.mrmratio <> mrt.mrmratio or af.mrlratio <> mrt.mrlratio
                 or af.k1days <> aft.k1days or af.k2days<>aft.k2days
                 or af.mrcrate <> mrt.mrcrate
                 or af.mrwrate <> mrt.mrwrate
                 or af.mrexrate <> mrt.mrexrate )
        )
        loop
            update afmast
            set mriratio = rec.mriratio ,
                mrmratio = rec.mrmratio ,
                mrlratio = rec.mrlratio,
                k1days = rec.k1days,
                k2days = rec.k2days,
                mrcrate= rec.mrcrate,
                mrwrate = rec.mrwrate,
                mrexrate =rec.mrexrate
            where acctno = rec.acctno;
        end loop;

        For vc in(
                SELECT ci.acctno, aft.citype
                FROM cimast ci, afmast af ,aftype aft
                Where ci.acctno=af.acctno
                   and af.actype=aft.actype
                   and ci.actype <> aft.citype )
        Loop
                update cimast set actype= vc.citype where acctno= vc.acctno;
        End loop;

    end;

    --Cap nhat he so Margin he thong tu loai hinh xuong
    begin
        for rec in (
            select mrt.mrirate ,mrt.mrmrate ,mrt.mrlrate,af.acctno
            from afmast af, aftype aft , mrtype mrt
            where af.actype = aft.actype  and aft.mrtype = mrt.actype
            and (af.mrirate <> mrt.mrirate or af.mrmrate <> mrt.mrmrate or af.mrlrate <> mrt.mrlrate)
        )
        loop
            update afmast
            set mrirate = rec.mrirate ,
                mrmrate = rec.mrmrate ,
                mrlrate = rec.mrlrate
            where acctno = rec.acctno;
        end loop;
    end;
    plog.setendsection(pkgctx, 'fn_ApplyTypeToMast');
    return true;
  EXCEPTION
  WHEN OTHERS
   THEN
      plog.error (pkgctx, SQLERRM);
      plog.setendsection (pkgctx, 'fn_ApplyTypeToMast');
      RAISE errnums.E_SYSTEM_ERROR;
      return false;
  END fn_ApplyTypeToMast;

  FUNCTION fn_getCustIDByCustodyCD(p_custodycd in varchar2)
  RETURN varchar2
  IS
    l_custid varchar2(10);
  BEGIN
    select custid into l_custid from cfmast where custodycd = p_custodycd;
    return l_custid;
  EXCEPTION
  WHEN OTHERS
   THEN
      plog.error (pkgctx, SQLERRM);
      return '';
  END fn_getCustIDByCustodyCD;

FUNCTION fn_get_bank_outstanding (v_bankid in varchar2, v_defsubtyp in varchar2)
return number
is
v_alloutstanding number;
v_shortname varchar2(300);
v_count NUMBER;
v_indayDFPOOLall NUMBER ;
begin
    plog.setbeginsection(pkgctx, 'fn_get_bank_outstanding');
    v_alloutstanding:=0;
    IF v_defsubtyp='ADV' THEN

/*    SELECT  NVL( shortname,'####') INTO v_shortname  FROM CFMAST WHERE CUSTID =v_bankid;

    SELECT nvl(count(custbank),0) INTO v_count
        FROM adtype ad  ,aftype af
        WHERE ad.actype= af.adtype
        AND ad.custbank = v_bankid;

        IF  v_shortname ='VCBS' THEN

            select nvl(sum(amt),0) into v_alloutstanding
            from adschd mst, adtype typ
            where mst.adtype=typ.actype and paidamt=0 and typ.rrtype = 'C' AND status <>'C'
            and mst.deltd <> 'Y';
            plog.setendsection(pkgctx, 'fn_get_bank_outstanding');
            return v_alloutstanding;

        ELSIF v_count <> 0 THEN
           SELECT nvl(sum(amt),0) into v_alloutstanding FROM adschd WHERE status <>'C'  ;

          return v_alloutstanding;
        ELSE


            --Kiem tra du no UTTB cua toan bo khach hang theo du no bank
            select nvl(sum(amt),0) into v_alloutstanding
            from adschd mst, adtype typ
            where mst.adtype=typ.actype and paidamt=0 and typ.rrtype = 'B' and typ.custbank=v_bankid
            and mst.deltd <> 'Y';
            plog.setendsection(pkgctx, 'fn_get_bank_outstanding');
            return v_alloutstanding;
        END IF;*/
        SELECT SUM(AMT) INTO v_alloutstanding FROM ADVRESLOG WHERE CUSTBANK=V_BANKID;
        plog.setendsection(pkgctx, 'fn_get_bank_outstanding');
        RETURN V_ALLOUTSTANDING;
    end if;

    IF v_defsubtyp='DFMR' THEN
        --Kiem tra du no DF cua toan bo khach hang theo du no bank
   /*     select nvl(sum(prinnml + prinovd),0) amt  into v_alloutstanding
                from lnmast ln
                where rrtype = 'B'
                and custbank=v_bankid
                and prinnml + prinovd>0;
        plog.setendsection(pkgctx, 'fn_get_bank_outstanding');*/

     BEGIN
    SELECT NVL(SUM (prinused),0) INTO v_indayDFPOOLall FROM prinusedlog WHERE prcode =v_bankid;
    Exception when others then
    v_indayDFPOOLall:=0;
    END;
        return v_indayDFPOOLall;
    end if;

       IF v_defsubtyp='TD' THEN
        --Kiem tra du no TD cua toan bo khach hang theo du no bank
       select nvl(sum(balance ),0) amt  into v_alloutstanding
       from TDMAST
       where  custbank=v_bankid AND FRDATE <= GETCURRDATE;
        plog.setendsection(pkgctx, 'fn_get_bank_outstanding');
        return v_alloutstanding;
       end if;

    plog.setendsection(pkgctx, 'fn_get_bank_outstanding');
RETURN 0;
EXCEPTION
   WHEN others THEN
   plog.error (pkgctx, SQLERRM || dbms_utility.format_error_backtrace);
   plog.setendsection (pkgctx, 'fn_get_bank_outstanding');
   return 0;
end fn_get_bank_outstanding;


FUNCTION fn_func_getcflimit (v_bankid in varchar2, v_custid in varchar2, v_subtype in varchar2, v_amt in number) RETURN NUMBER IS
    v_count         NUMBER;
    v_allmaxlimit   NUMBER;
    v_avllimit      NUMBER;
    v_outstanding   NUMBER;
    v_alloutstanding    NUMBER;
    v_checktyp      CHAR(1);
    v_defsubtyp     VARCHAR2(4);
    v_return        NUMBER;
BEGIN
    plog.setbeginsection(pkgctx, 'fn_func_getcflimit');
    v_outstanding:=0;
    v_alloutstanding:=0;
    v_allmaxlimit:=0;
    if v_bankid is null or length(v_bankid)<=0 OR v_bankid='AUTO' then
        plog.setendsection(pkgctx, 'fn_func_getcflimit');
        return 0;
    end if;
    plog.info(pkgctx, 'Input Param: fn_func_getcflimit(' || v_bankid || ',' || v_custid || ',' || v_subtype || ',' || v_amt || ')');
    --Lay han muc khach hang: Uu tien quy dinh nghiep vu truoc roi moi set den All
    SELECT COUNT(LMAMT) INTO v_count
    FROM CFLIMITEXT WHERE BANKID=v_bankid AND CUSTID=v_custid AND STATUS='A' and lmsubtype = v_subtype ;
    IF v_count>0 THEN
        --Kiem tra neu khach hang co quy dinh rieng
        SELECT LMAMT, LMCHKTYP, LMSUBTYPE INTO v_avllimit, v_checktyp, v_defsubtyp
        FROM (SELECT LMAMT, LMCHKTYP, LMSUBTYPE, DECODE(LMSUBTYPE,v_subtype,0,1) PRIORITYORD
        FROM CFLIMITEXT WHERE BANKID=v_bankid AND CUSTID=v_custid AND STATUS='A' AND (LMSUBTYPE='ALL' OR LMSUBTYPE=v_subtype)
        ORDER BY DECODE(LMSUBTYPE,v_subtype,0,1)) WHERE ROWNUM=1;
    ELSE
        --Neu bank khong quy dinh thi khong can kiem tr
        SELECT COUNT(LMAMT) INTO v_count
        FROM CFLIMIT WHERE BANKID=v_bankid AND STATUS='A' AND (LMSUBTYPE=v_subtype OR LMSUBTYPE='ALL');
        IF v_count>0 THEN
            --Theo quydinh chung cua bank
            SELECT LMAMT, LMCHKTYP, LMSUBTYPE INTO v_avllimit, v_checktyp, v_defsubtyp
            FROM (SELECT LMAMT, LMCHKTYP, LMSUBTYPE, DECODE(LMSUBTYPE,v_subtype,0,1) PRIORITYORD
            FROM CFLIMIT WHERE BANKID=v_bankid AND STATUS='A' AND (LMSUBTYPE='ALL' OR LMSUBTYPE=v_subtype)
            ORDER BY DECODE(LMSUBTYPE,v_subtype,0,1)) WHERE ROWNUM=1;
        ELSE
            --Khong kiem tra
            plog.setendsection(pkgctx, 'fn_func_getcflimit');
            RETURN -100424;
        END IF;
    END IF;


    plog.debug(pkgctx, 'v_defsubtyp:' || v_defsubtyp);
    --Lay du no cua khach hang theo ngan hang
    IF v_defsubtyp='ADV' THEN -- UTTB
        BEGIN
            --Kiem tra du no UTTB cua khach hang
            SELECT NVL(SUM(AMT),0) INTO v_outstanding
            FROM ADSCHD MST, ADTYPE TYP, AFMAST AF
            WHERE MST.ADTYPE=TYP.ACTYPE AND MST.ACCTNO=AF.ACCTNO
            AND AF.CUSTID=v_custid AND PAIDAMT=0 AND TYP.RRTYPE = 'B' AND TYP.CUSTBANK=v_bankid
            AND MST.DELTD <> 'Y';

            v_alloutstanding:=fn_get_bank_outstanding (v_bankid, v_defsubtyp);

            --Xac dinh han muc tong toi da do ngan hang quy dinh
            SELECT NVL(LMAMTMAX,0) INTO v_allmaxlimit
            FROM (SELECT LMAMTMAX, DECODE(LMSUBTYPE,v_subtype,0,1) PRIORITYORD
                    FROM CFLIMIT WHERE BANKID=v_bankid AND STATUS='A' AND (LMSUBTYPE='ALL' OR LMSUBTYPE=v_subtype)
                    ORDER BY DECODE(LMSUBTYPE,v_subtype,0,1))
            WHERE ROWNUM=1;
        END;

        --Kiem tra han muc hop le
        plog.debug(pkgctx, 'v_avllimit:' || v_avllimit);
        plog.debug(pkgctx, 'v_outstanding:' || v_outstanding);
        plog.debug(pkgctx, 'v_allmaxlimit:' || v_allmaxlimit);
        plog.debug(pkgctx, 'v_alloutstanding:' || v_alloutstanding);
        IF v_avllimit-v_outstanding>=v_amt AND v_allmaxlimit-v_alloutstanding>=v_amt THEN
          v_return := 0;
        ELSIF v_avllimit-v_outstanding<=v_amt then
          v_return := -100423;   -- Ma loi vuot han muc vay cua khach hang
        ELSE
          v_return := -100424;   -- Ma loi vuot han muc cho vay cua ngan hang
        END IF;
    END IF;


    --Lay du no cua khach hang theo ngan hang
    IF v_defsubtyp='DFMR' THEN
        BEGIN
            --Kiem tra du no DF cua khach hang
            if v_checktyp='C' then --Check theo han muc hien tai
                begin
                    select nvl(sum(prinnml + prinovd),0) amt into v_outstanding
                    from lnmast ln , afmast af
                    where ln.trfacctno = af.acctno and af.custid=v_custid
                    and rrtype ='B'
                    and custbank=v_bankid;
                exception when others then
                    v_outstanding:=0;
                end;
            else --Check theo han muc dau ngay
                begin
                    select nvl(sum(ln.prinnml + ln.prinovd + nvl(tr.dayrlsamt,0)),0) amt into v_outstanding
                    from lnmast ln , afmast af ,
                    (
                        select tr.acctno, sum(namt) Dayrlsamt
                        from lntran tr, apptx tx
                        where tr.txcd= tx.txcd and tx.apptype ='LN'
                        and tx.field in('PRINNML','PRINOVD')
                        and tx.txtype='D'
                        and tr.deltd <> 'Y'
                        group by tr.acctno
                    ) tr
                    where ln.trfacctno = af.acctno
                    and ln.acctno = tr.acctno(+)
                    and af.custid=v_custid
                    and rrtype ='B'
                    and custbank=v_bankid;
                exception when others then
                    v_outstanding:=0;
                end;
            end if;

            v_alloutstanding:=fn_get_bank_outstanding (v_bankid, v_defsubtyp);

            --Xac dinh han muc tong toi da do ngan hang quy dinh
            select nvl(lmamtmax,0) into v_allmaxlimit
                    from (select lmamtmax, decode(lmsubtype,v_subtype,0,1) priorityord
                            from cflimit where bankid=v_bankid and status='A' and (lmsubtype='ALL' or lmsubtype=v_subtype)
                            order by decode(lmsubtype,v_subtype,0,1)
                         ) where rownum=1;
        END;

        --Kiem tra han muc hop le
        plog.debug(pkgctx, 'v_avllimit:' || v_avllimit);
        plog.debug(pkgctx, 'v_outstanding:' || v_outstanding);
        plog.debug(pkgctx, 'v_allmaxlimit:' || v_allmaxlimit);
        plog.debug(pkgctx, 'v_alloutstanding:' || v_alloutstanding);
        IF v_avllimit-v_outstanding>=v_amt AND v_allmaxlimit-v_alloutstanding>=v_amt THEN
          v_return := 0;
        ELSIF v_avllimit-v_outstanding<=v_amt then
          v_return := -100423;   -- Ma loi vuot han muc vay cua khach hang
        ELSE
          v_return := -100424;   -- Ma loi vuot han muc cho vay cua ngan hang
        END IF;
    END IF;



    plog.setendsection(pkgctx, 'fn_func_getcflimit');

    RETURN v_return;
EXCEPTION
   WHEN others THEN
   plog.error (pkgctx, SQLERRM || dbms_utility.format_error_backtrace);
   plog.setendsection (pkgctx, 'fn_func_getcflimit');
   return errnums.C_SYSTEM_ERROR;
END;



FUNCTION fn_getavlcflimit (v_bankid in varchar2, v_custid in varchar2, v_subtype in varchar2) RETURN NUMBER IS
    v_count         NUMBER;
    v_allmaxlimit   NUMBER;
    v_avllimit      NUMBER;
    v_outstanding   NUMBER;
    v_alloutstanding    NUMBER;
    v_checktyp      CHAR(1);
    v_defsubtyp     VARCHAR2(4);
    v_return        NUMBER;
    v_indayDFPOOL   NUMBER;
    v_indayDFPOOLALL   NUMBER;
BEGIN
    plog.setbeginsection(pkgctx, 'fn_getavlcflimit');
    v_outstanding:=0;
    v_alloutstanding:=0;
    v_allmaxlimit:=0;
    plog.info(pkgctx, 'Input Param: fn_getavlcflimit(' || v_bankid || ',' || v_custid || ',' || v_subtype || ')');
    --Lay han muc khach hang: Uu tien quy dinh nghiep vu truoc roi moi set den All
    SELECT COUNT(LMAMT) INTO v_count
    FROM CFLIMIT WHERE BANKID=v_bankid AND STATUS='A' AND (LMSUBTYPE=v_subtype OR LMSUBTYPE='ALL');
    if v_count > 0 then
        select min(nvl(b.lmamt, a.lmamt)) lmamt, min(nvl(b.lmchktyp,a.lmchktyp)) lmchktyp, min(nvl(b.LMSUBTYPE,a.LMSUBTYPE)) LMSUBTYPE
                INTO v_avllimit, v_checktyp, v_defsubtyp
          from cflimit a, (select bankid, LMSUBTYPE, LMTYP, lmamt, lmchktyp
                            from cflimitext
                            where custid = v_custid) b
          where a.bankid = b.bankid(+) and a.LMTYP ='LN'
                and a.LMSUBTYPE = b.LMSUBTYPE(+) and a.LMTYP = b.LMTYP(+) and a.bankid = v_bankid
                AND (a.LMSUBTYPE=v_subtype OR a.LMSUBTYPE='ALL')
          group by a.bankid;
    else
        plog.setendsection(pkgctx, 'fn_getavlcflimit');
        return 0;
    end if;

    plog.debug(pkgctx, 'v_defsubtyp:' || v_defsubtyp);
    --Lay du no cua khach hang theo ngan hang
    IF v_defsubtyp='ADV' THEN -- UTTB
        BEGIN
            --Kiem tra du no UTTB cua khach hang
            SELECT NVL(SUM(AMT),0) INTO v_outstanding
            FROM ADSCHD MST, ADTYPE TYP, AFMAST AF
            WHERE MST.ADTYPE=TYP.ACTYPE AND MST.ACCTNO=AF.ACCTNO
            AND AF.CUSTID=v_custid AND PAIDAMT=0 AND TYP.RRTYPE = 'B' AND TYP.CUSTBANK=v_bankid
            AND MST.DELTD <> 'Y';

            v_alloutstanding:=fn_get_bank_outstanding (v_bankid, v_defsubtyp);

            --Xac dinh han muc tong toi da do ngan hang quy dinh
            SELECT NVL(LMAMTMAX,0) INTO v_allmaxlimit
            FROM (SELECT LMAMTMAX, DECODE(LMSUBTYPE,v_subtype,0,1) PRIORITYORD
                    FROM CFLIMIT WHERE BANKID=v_bankid AND STATUS='A' AND (LMSUBTYPE='ALL' OR LMSUBTYPE=v_subtype)
                    ORDER BY DECODE(LMSUBTYPE,v_subtype,0,1))
            WHERE ROWNUM=1;
        END;

        --Kiem tra han muc hop le
        plog.debug(pkgctx, 'v_avllimit:' || v_avllimit);
        plog.debug(pkgctx, 'v_outstanding:' || v_outstanding);
        plog.debug(pkgctx, 'v_allmaxlimit:' || v_allmaxlimit);
        plog.debug(pkgctx, 'v_alloutstanding:' || v_alloutstanding);

        plog.setendsection(pkgctx, 'fn_getavlcflimit');
        return least(v_avllimit-v_outstanding,v_allmaxlimit-v_alloutstanding);
    END IF;


    --Lay du no cua khach hang theo ngan hang
    IF v_defsubtyp='DFMR' THEN -- CL + Margin

    BEGIN
    SELECT NVL(SUM (prinused),0) INTO v_indayDFPOOLall FROM prinusedlog WHERE prcode =v_bankid;
    Exception when others then
    v_indayDFPOOL:=0;
    END;

    BEGIN
    SELECT NVL(SUM (prinused),0) INTO v_indayDFPOOL FROM prinusedlog pr, afmast af
    WHERE prcode =v_bankid
    and pr.afacctno = af.acctno
    and af.custid = v_custid
    ;
    Exception when others then
    v_indayDFPOOLALL:=0;
    END;



        BEGIN
            --Kiem tra du no DF cua khach hang
            if v_checktyp='C' then --Check theo han muc hien tai
                begin
                    select nvl(sum(prinnml + prinovd),0) amt into v_outstanding
                    from lnmast ln , afmast af
                    where ln.trfacctno = af.acctno and af.custid=v_custid
                    and rrtype ='B'
                    and custbank=v_bankid;
                exception when others then
                    v_outstanding:=0;
                end;
            else --Check theo han muc dau ngay
                begin
                    select nvl(sum(ln.prinnml + ln.prinovd + nvl(tr.dayrlsamt,0)),0) amt into v_outstanding
                    from lnmast ln , afmast af ,
                    (
                        select tr.acctno, sum(namt) Dayrlsamt
                        from lntran tr, apptx tx
                        where tr.txcd= tx.txcd and tx.apptype ='LN'
                        and tx.field in('PRINNML','PRINOVD')
                        and tx.txtype='D'
                        and tr.deltd <> 'Y'
                        group by tr.acctno
                    ) tr
                    where ln.trfacctno = af.acctno
                    and ln.acctno = tr.acctno(+)
                    and af.custid=v_custid
                    and rrtype ='B'
                    and custbank=v_bankid;
                exception when others then
                    v_outstanding:=0;
                end;
            end if;

            v_alloutstanding:=fn_get_bank_outstanding (v_bankid, v_defsubtyp);

            --Xac dinh han muc tong toi da do ngan hang quy dinh
            select nvl(lmamtmax,0) into v_allmaxlimit
                    from (select lmamtmax, decode(lmsubtype,v_subtype,0,1) priorityord
                            from cflimit where bankid=v_bankid and status='A' and (lmsubtype='ALL' or lmsubtype=v_subtype)
                            order by decode(lmsubtype,v_subtype,0,1)
                         ) where rownum=1;
        END;

        --Kiem tra han muc hop le
        plog.debug(pkgctx, 'v_avllimit:' || v_avllimit);
        plog.debug(pkgctx, 'v_outstanding:' || v_outstanding);
        plog.debug(pkgctx, 'v_allmaxlimit:' || v_allmaxlimit);
        plog.debug(pkgctx, 'v_alloutstanding:' || v_alloutstanding);
        plog.debug(pkgctx, 'v_indayDFPOOL:' || v_indayDFPOOL);

        plog.setendsection(pkgctx, 'fn_getavlcflimit');
        return least(v_avllimit-v_outstanding-v_indayDFPOOL,v_allmaxlimit-v_alloutstanding-v_indayDFPOOLall);
    END IF;



    plog.setendsection(pkgctx, 'fn_getavlcflimit');

    RETURN v_return;
EXCEPTION
   WHEN others THEN
   plog.error (pkgctx, SQLERRM || dbms_utility.format_error_backtrace);
   plog.setendsection (pkgctx, 'fn_getavlcflimit');
   return 0;
END;



FUNCTION fn_getavlcflimitDFMR (p_lntype in varchar2, p_afacctno in varchar2) RETURN NUMBER IS
    l_avlamt number(20,0);
    l_rrtype varchar2(1);
    l_custbank varchar2(100);
    l_custid varchar2(100);
BEGIN
    plog.setbeginsection(pkgctx, 'fn_getavlcflimitDFMR');
    l_avlamt:= 0;
    select custid into l_custid from afmast where acctno = p_afacctno;
    begin
        select rrtype, custbank into l_rrtype, l_custbank from lntype where actype = p_lntype;
    exception when others then
        l_rrtype:= 'X';
        l_custbank:= 'XXXXXXXXXXXX';
    end;
    if l_rrtype = 'B' then
        begin
            l_avlamt:= cspks_cfproc.fn_getavlcflimit(l_custbank, l_custid, 'DFMR');
        exception when others then
            l_avlamt:= 0;
        end;
    end if;
    plog.setendsection(pkgctx, 'fn_getavlcflimitDFMR');
    RETURN l_avlamt;
EXCEPTION
   WHEN others THEN
   plog.error (pkgctx, SQLERRM || dbms_utility.format_error_backtrace);
   plog.setendsection (pkgctx, 'fn_getavlcflimitDFMR');
   return 0;
END;


FUNCTION fn_getavlbanklimit (v_bankid in varchar2, v_subtype in varchar2) RETURN NUMBER IS
    v_allmaxlimit   NUMBER;
    v_alloutstanding    NUMBER;
    v_defsubtyp     VARCHAR2(4);
BEGIN
    plog.setbeginsection(pkgctx, 'fn_getavlbanklimit');
    v_alloutstanding:=0;
    v_allmaxlimit:=0;
    v_defsubtyp:=v_subtype;
    --Lay du no cua khach hang theo ngan hang
    IF v_defsubtyp='ADV' THEN -- UTTB
        BEGIN
            v_alloutstanding:=fn_get_bank_outstanding (v_bankid, v_defsubtyp);

            --Xac dinh han muc tong toi da do ngan hang quy dinh
            SELECT NVL(LMAMTMAX,0) INTO v_allmaxlimit
            FROM (SELECT LMAMTMAX, DECODE(LMSUBTYPE,v_subtype,0,1) PRIORITYORD
                    FROM CFLIMIT WHERE BANKID=v_bankid AND STATUS='A' AND (LMSUBTYPE='ALL' OR LMSUBTYPE=v_subtype)
                    ORDER BY DECODE(LMSUBTYPE,v_subtype,0,1))
            WHERE ROWNUM=1;
        END;

        plog.setendsection(pkgctx, 'fn_getavlbanklimit');
        return v_allmaxlimit-v_alloutstanding;
    END IF;


    --Lay du no cua khach hang theo ngan hang
    IF v_defsubtyp='DFMR' THEN -- CL + Margin
        BEGIN
            v_alloutstanding:=fn_get_bank_outstanding (v_bankid, v_defsubtyp);

            --Xac dinh han muc tong toi da do ngan hang quy dinh
            select nvl(lmamtmax,0) into v_allmaxlimit
                    from (select lmamtmax, decode(lmsubtype,v_subtype,0,1) priorityord
                            from cflimit where bankid=v_bankid and status='A' and (lmsubtype='ALL' or lmsubtype=v_subtype)
                            order by decode(lmsubtype,v_subtype,0,1)
                         ) where rownum=1;
        END;

        plog.setendsection(pkgctx, 'fn_getavlbanklimit');
        return v_allmaxlimit-v_alloutstanding;
    END IF;
    plog.setendsection(pkgctx, 'fn_getavlbanklimit');

    RETURN 0;
EXCEPTION
   WHEN others THEN
   plog.error (pkgctx, SQLERRM || dbms_utility.format_error_backtrace);
   plog.setendsection (pkgctx, 'fn_getavlbanklimit');
   return 0;
END;

FUNCTION fn_checkNonCustody (v_strCustodycd in varchar2) RETURN NUMBER IS
     /*
     **  Module: Neu khach hang thuoc cong ty return 0, else return -1.
     **  MODIFICATION HISTORY
     **  Person      Date           Comments
     **  ThanhNM     26-Feb-2012    Created
     ** (c) 2012 by Financial Software Solutions. JSC.
     */
    v_result   NUMBER;
    v_strCusType    varchar2(1);
    v_count    NUMBER;
BEGIN
    v_result:=0;
    v_count:=0;
    v_strCusType:='';
    plog.setbeginsection(pkgctx, 'fn_checkNonCustody');
    --Lay noi luu ky

     select count(1) into  v_count from cfmast  where  custodycd = replace(upper(v_strCustodycd),'.','');
     if v_count>0 then
            select CUSTATCOM into v_strCusType from cfmast  where  custodycd = replace(upper(v_strCustodycd),'.','');
            if v_strCusType ='Y' then
                v_result:=0;
                plog.setendsection(pkgctx, 'fn_checkNonCustody');
                return v_result;
            else
                 v_result:=-1;
                 plog.setendsection(pkgctx, 'fn_checkNonCustody');
                 return v_result;
            end if;
     else
        v_result:=-1;
        plog.setendsection(pkgctx, 'fn_checkNonCustody');
        return v_result;
     end if;
     plog.setendsection(pkgctx, 'fn_checkNonCustody');

    RETURN 0;
EXCEPTION
   WHEN others THEN
   plog.error (pkgctx, SQLERRM || dbms_utility.format_error_backtrace);
   plog.setendsection (pkgctx, 'fn_checkNonCustody');
   return 0;
END;

PROCEDURE pr_AllocMarginLimit (p_tlid in varchar2, p_afacctno in varchar2, p_amt in number, p_desc in varchar2, p_err_code in out varchar2)
IS
    l_txmsg               tx.msg_rectype;
    l_err_param         varchar2(1000);
    l_desc              varchar2(100);
    v_CURRDATE date;
    l_LOGDATE varchar2(10);
BEGIN
    plog.setbeginsection(pkgctx, 'pr_AllocMarginLimit');
    p_err_code:= 0;

    SELECT TXDESC into l_desc FROM  TLTX WHERE TLTXCD='1813';
     SELECT TO_DATE (varvalue, systemnums.c_date_format), varvalue
               INTO v_CURRDATE, l_LOGDATE
               FROM sysvar
               WHERE grname = 'SYSTEM' AND varname = 'CURRDATE';
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
    l_txmsg.batchname   := 'DAY';
    l_txmsg.txdate:=v_CURRDATE;
    l_txmsg.busdate:=v_CURRDATE;
    l_txmsg.tltxcd:='1813';

    for rec in
    (
        select af.acctno, cf.mrloanlimit, cf.custodycd
        from afmast af, cfmast cf where af.acctno = p_afacctno and cf.custid = af.custid
    )
    loop

    SELECT systemnums.C_BATCH_PREFIXED
                             || LPAD (seq_BATCHTXNUM.NEXTVAL, 8, '0')
                      INTO l_txmsg.txnum
                      FROM DUAL;
            l_txmsg.brid        := substr(rec.ACCTNO,1,4);

            --Set cac field giao dich
                        --01   C   USERID
            l_txmsg.txfields ('01').defname   := 'USERID';
            l_txmsg.txfields ('01').TYPE      := 'C';
            l_txmsg.txfields ('01').VALUE     := p_tlid;

            --02   C   USERTYPE
            l_txmsg.txfields ('02').defname   := 'USERTYPE';
            l_txmsg.txfields ('02').TYPE      := 'C';
            l_txmsg.txfields ('02').VALUE     := 'Flex';

            --03   C   ACCTNO
            l_txmsg.txfields ('03').defname   := 'ACCTNO';
            l_txmsg.txfields ('03').TYPE      := 'C';
            l_txmsg.txfields ('03').VALUE     := rec.acctno;

            --10   N   ACCLIMIT
            l_txmsg.txfields ('10').defname   := 'ACCLIMIT';
            l_txmsg.txfields ('10').TYPE      := 'N';
            l_txmsg.txfields ('10').VALUE     := p_amt;

            --11   N   MRCRLIMITMAX
            l_txmsg.txfields ('11').defname   := 'MRCRLIMITMAX';
            l_txmsg.txfields ('11').TYPE      := 'N';
            l_txmsg.txfields ('11').VALUE     := 0;

            --14   N   LIMITMAX
            l_txmsg.txfields ('14').defname   := 'LIMITMAX';
            l_txmsg.txfields ('14').TYPE      := 'N';
            l_txmsg.txfields ('14').VALUE     := 0;

            --15   N   USERHAVE
            l_txmsg.txfields ('15').defname   := 'USERHAVE';
            l_txmsg.txfields ('15').TYPE      := 'N';
            l_txmsg.txfields ('15').VALUE     := 0;

            --16   N   CUSTAVLLIMIT
            l_txmsg.txfields ('16').defname   := 'CUSTAVLLIMIT';
            l_txmsg.txfields ('16').TYPE      := 'N';
            l_txmsg.txfields ('16').VALUE     := rec.mrloanlimit;

            --30   C   DESC
            l_txmsg.txfields ('30').defname   := 'DESC';
            l_txmsg.txfields ('30').TYPE      := 'C';
            l_txmsg.txfields ('30').VALUE     := p_desc;

            --88   C   CUSTODYCD
            l_txmsg.txfields ('88').defname   := 'CUSTODYCD';
            l_txmsg.txfields ('88').TYPE      := 'C';
            l_txmsg.txfields ('88').VALUE     := rec.custodycd;


            BEGIN
                IF txpks_#1813.fn_batchtxprocess (l_txmsg,
                                                 p_err_code,
                                                 l_err_param
                   ) <> systemnums.c_success
                THEN
                   plog.debug (pkgctx,
                               'got error 1813: ' || p_err_code
                   );
                   ROLLBACK;
                   RETURN;
                else
                    p_err_code:=0;
                END IF;
            END;
    end loop;



     plog.setendsection(pkgctx, 'fn_checkNonCustody');

EXCEPTION
   WHEN others THEN
   plog.error (pkgctx, SQLERRM || dbms_utility.format_error_backtrace);
   plog.setendsection (pkgctx, 'pr_AllocMarginLimit');
   p_err_code:=-1;
   return;
END;


PROCEDURE pr_AFMAST_ChangeTypeCheck (p_afacctno in varchar2,p_actype in varchar2, p_err_code in out varchar2)
IS
l_count number;
l_oldcorebank varchar2(10);
l_newcorebank varchar2(10);
BEGIN
    plog.setbeginsection(pkgctx, 'pr_AFMAST_ChangeTypeCheck');
    p_err_code:= '0';
    select corebank into l_oldcorebank from afmast where acctno = p_afacctno;
    select corebank into l_newcorebank from aftype where actype = p_actype;
    if l_oldcorebank <> l_newcorebank then
        /*select count(1) into l_count from stschd where status <> 'C' and afacctno = p_afacctno and duetype in ('SM','SS') and deltd <> 'Y';
        --and txdate = (select to_date(varvalue,'DD/MM/RRRR') from sysvar  where varname ='CURRDATE' and grname ='SYSTEM');
        if l_count > 0 then
            p_err_code:= '-100141';
            plog.setendsection(pkgctx, 'pr_AFMAST_ChangeTypeCheck');
            return;
        end if;*/
        select count(1) into l_count from cimast where afacctno = p_afacctno and (balance > 0 or holdbalance > 0);
        if l_count > 0 then

            p_err_code:= '-100144';

            plog.setendsection(pkgctx, 'pr_AFMAST_ChangeTypeCheck');
            return;
        end if;
        select count(1) into l_count from afmast where acctno = p_afacctno and advanceline <> 0;
        if l_count > 0 then

            p_err_code:= '-100149';

            plog.setendsection(pkgctx, 'pr_AFMAST_ChangeTypeCheck');
            return;
        end if;
        /*select count(1) into l_count from adschd where acctno = p_afacctno and status <> 'C';
        if l_count > 0 then
            p_err_code:= '-100142';
            plog.setendsection(pkgctx, 'pr_AFMAST_ChangeTypeCheck');
            return;
        end if;*/
        select count(1) into l_count from lnmast where trfacctno = p_afacctno
        and (prinnml > 1 or prinovd > 1 or intnmlacr > 1 or intdue > 1 or intovdacr > 1 or intnmlovd > 1
             or oprinnml > 1 or oprinovd >1 or ointnmlacr>1 or ointnmlovd >1 );
        if l_count > 0 then
            p_err_code:= '-100143';
            plog.setendsection(pkgctx, 'pr_AFMAST_ChangeTypeCheck');
            return;
        end if;
    end if;
    p_err_code:='0';
    plog.setendsection(pkgctx, 'pr_AFMAST_ChangeTypeCheck');
EXCEPTION
   WHEN others THEN
   plog.error (pkgctx, SQLERRM || dbms_utility.format_error_backtrace);
   plog.setendsection (pkgctx, 'pr_AFMAST_ChangeTypeCheck');
   p_err_code:='-1';
   return;
END;


FUNCTION fn_0088checkAFCOUNT (p_closetype in varchar2, p_custodycd in varchar2) RETURN NUMBER IS
    v_result   NUMBER;
    v_strCusType    varchar2(1);
    v_count    NUMBER;
BEGIN
    plog.setbeginsection(pkgctx, 'fn_checkAFCOUNT');
    --Lay noi luu ky
    select count(1) into v_count
    from afmast where custid in (
                    select custid from cfmast where custodycd = p_custodycd)
    and status not in ('N','C');
    if v_count = 1 and p_closetype = '002' then
        return -1;
    end if;

    plog.setendsection(pkgctx, 'fn_checkAFCOUNT');

    RETURN 0;
EXCEPTION
   WHEN others THEN
   plog.error (pkgctx, SQLERRM || dbms_utility.format_error_backtrace);
   plog.setendsection (pkgctx, 'fn_checkAFCOUNT');
   return 0;
END;

FUNCTION fn_0088getFEEDATE (p_closetype in varchar2) RETURN NUMBER IS
v_Result number;
BEGIN
    plog.setbeginsection(pkgctx, 'fn_getFEEDATE');
/*    if p_closetype = '002' then
        select sbdate - currdate into v_Result from sbcurrdate where numday=0 AND sbtype='B' ;
    else
        select sbdate - currdate into v_Result from sbcurrdate where numday=2 AND sbtype='B' ;
    end if;*/

select sbdate - currdate into v_Result from sbcurrdate where numday=0 AND sbtype='N' ;

    plog.setendsection(pkgctx, 'fn_getFEEDATE');
    return v_Result;
EXCEPTION
   WHEN others THEN
   plog.error (pkgctx, SQLERRM || dbms_utility.format_error_backtrace);
   plog.setendsection (pkgctx, 'fn_getFEEDATE');
   return 0;
END;

FUNCTION fn_0088getNEEDTRFSE (p_closetype in varchar2, p_custodycd in varchar2, p_afacctno in varchar2) RETURN varchar2 IS
l_count number;
BEGIN
    plog.setbeginsection(pkgctx, 'fn_getFEEDATE');

    select count(1) into l_count
    from semast se
    where se.custid in (select custid from cfmast where custodycd = p_custodycd)
    and SE.TRADE + SE.MORTAGE + SE.BLOCKED + SE.WITHDRAW
               + SE.DEPOSIT  + SE.SENDDEPOSIT > 0;

    if l_count > 0 and p_closetype = '001' then
        return 'Y';
    end if;

    select count(1) into l_count
    from caschd ca, afmast af
    where ca.afacctno = af.acctno and af.custid in (select custid from cfmast where custodycd = p_custodycd)
    and ((ca.qtty > 0 and ca.isse = 'N') or (ca.amt > 0 and ca.isci = 'N'));

    if l_count > 0 and p_closetype = '001' then
        return 'Y';
    end if;

    if p_closetype = '002' then
        select count(1) into l_count
        from semast se
        where se.afacctno = p_afacctno
            and SE.TRADE + SE.MORTAGE + SE.BLOCKED + SE.WITHDRAW
            + SE.DEPOSIT  + SE.SENDDEPOSIT > 0;
        if l_count > 0 then
            return 'Y';
        end if;

        select count(1) into l_count
        from caschd ca
        where ca.afacctno = p_afacctno
            and ((ca.qtty > 0 and ca.isse = 'N') or (ca.amt > 0 and ca.isci = 'N'));
        if l_count > 0 then
            return 'Y';
        end if;
    end if;

    plog.setendsection(pkgctx, 'fn_getFEEDATE');
    return 'N';
EXCEPTION
   WHEN others THEN
   plog.error (pkgctx, SQLERRM || dbms_utility.format_error_backtrace);
   plog.setendsection (pkgctx, 'fn_getFEEDATE');
   return 'N';
END;

FUNCTION fn_0088getAFACCTNO (p_closetype in varchar2, p_custodycd in varchar2, p_afacctno in varchar2) RETURN varchar2 IS
l_count number;
BEGIN
    plog.setbeginsection(pkgctx, 'fn_getFEEDATE');
    if p_closetype = '001' then
        return p_custodycd || '|ALL';
    else
        return p_afacctno;
    end if;
    plog.setendsection(pkgctx, 'fn_getFEEDATE');
EXCEPTION
   WHEN others THEN
   plog.error (pkgctx, SQLERRM || dbms_utility.format_error_backtrace);
   plog.setendsection (pkgctx, 'fn_getFEEDATE');
END;

FUNCTION fn_0088checkAFACCTNO (p_closetype in varchar2, p_afacctno in varchar2, p_setafacctno in varchar2) RETURN NUMBER IS
BEGIN
    plog.setbeginsection(pkgctx, 'fn_checkAFCOUNT');
    --Lay noi luu ky
    if p_closetype = '001' and instr(p_afacctno, 'ALL') = 0 then
        return -1;
    end if;
    if p_closetype <> '001' and instr(p_afacctno, 'ALL') <> 0 then
        return -1;
    end if;
    if p_closetype <> '001' and p_afacctno <> p_setafacctno then
        return -1;
    end if;
    plog.setendsection(pkgctx, 'fn_checkAFCOUNT');

    RETURN 0;
EXCEPTION
   WHEN others THEN
   plog.error (pkgctx, SQLERRM || dbms_utility.format_error_backtrace);
   plog.setendsection (pkgctx, 'fn_checkAFCOUNT');
   return 0;
END;



PROCEDURE pr_DailyLogCFIfno(p_err_code in out varchar2)
-- Log thong tin hang ngay
IS
    v_currdate date;
    V_NEXTDATE DATE;
    L_AUTOID NUMBER;
BEGIN
    plog.setbeginsection(pkgctx, 'pr_DailyLogCFIfno');
    p_err_code:= '0';

        Select TO_DATE (varvalue, systemnums.c_date_format) into v_currdate
    From sysvar
    Where varname='CURRDATE';

     Select TO_DATE (varvalue, systemnums.c_date_format) into v_nextdate
    From sysvar
    Where varname='NEXTDATE';
    DELETE FROM  CFreviewlog WHERE LASTDATE =v_currdate;
    For vc in(
            Select
                 CF.custid,
                 CF.actype,
                 nvl(od.tradevalue,0) tradevalue,
                 nvl(od.feeamt,0) feeamt,
                 CI.CIAMT + nvl(se.seamt,0) NAV,
                 nvl(mr.FEEAMT,0) finrevenue,
                 nvl(df.feeamt,0) DFREVENUE ,
                 nvl(ad.feeamt,0) ADREVENUE,
                 nvl(lnlog.numoverdeal,0) numoverdeal,
                 0 calldays,
                 0 OVERDUEDAY,
                 ci.odamt odamt,
                 ci.CIAMT,
                 nvl(se.seamt,0) SEAMT,
                 RE.recust recust,
                 re.rerole rerole,
                 CI.careceiving,
                 nvl(ln.mrnml,0) mrnml,
                 nvl(ln.mrfeeamt,0) mrfeeamt,
                 ci.advamt, ci.depofeeamt, ci.rcvamt,ci.crintacr

            From
                 CFMAST CF,
                 (Select
                     cf.custid,
                     sum(od.execamt) tradevalue,
                     sum(od.feeacr) feeamt
                    From CFmast cf,afmast af, odmast od
                    Where  cf.custid=af.custid
                        and af.acctno=od.afacctno
                        and od.deltd<>'Y'
                        and od.execamt>0
                        and txdate=v_currdate
                    Group by cf.custid
                  ) OD,
                  (Select ci.custodycd,SUM(nvl(careceiving,0)) careceiving,--QUYEN CHO VE
                           sum(ci.rcvadvamt) advamt,--tien no ung truoc
                           sum(ci.ovdcidepofee+ci.cidepofeeacr) depofeeamt,sum(ci.rcvamt) rcvamt,--tien ban cho ve tru phi,thue
                           sum( ci.crintacr) crintacr,--tien lai gui cong don
                      sum(
                            (ci.balance   + ci.rcvamt + ci.tdbalance + ci.crintacr + ci.tdintamt+nvl(careceiving,0) ) -
                            (ci.dfodamt + ci.t0odamt + ci.mrodamt + ci.ovdcidepofee + ci.execbuyamt + ci.trfbuyamt + ci.rcvadvamt + ci.TDODAMT+ci.cidepofeeacr)) ciamt,
                       sum (ci.dfodamt + ci.t0odamt + ci.mrodamt + ci.ovdcidepofee + ci.execbuyamt + ci.trfbuyamt + ci.rcvadvamt + ci.TDODAMT+ci.cidepofeeacr) ODAMT

                     From buf_ci_account ci,
                     /*(SELECT SUM(amt) careceiving, afacctno caacctno  FROM caschd WHERE  status IN ('I','S','H') AND ISEXEC ='Y'
                        GROUP BY afacctno) CA
                     */
                    ( SELECT  SUM( CASE WHEN CA.status ='K' THEN  (amt+sendamt)* CA.exerate/100 ELSE (amt+sendamt) END ) careceiving, afacctno caacctno
                        FROM caschd cas, camast ca
                        WHERE  cas.status IN ('I','S','H','O','K')
                        AND ISEXEC ='Y'
                        AND cas.camastid = ca.camastid
                        GROUP BY afacctno) CA
                    WHERE ci.afacctno = ca.caacctno (+)
                     group by  ci.custodycd
                   ) ci,
                  (select se.custid, sum((se.trade+ se.receiving +se.mortage+ se.standing + se.withdraw + se.dtoclose+ nvl(ca.careceiving,0) )* si.basicprice) seamt
                    from semast se, securities_info si,sbsecurities sb,
                                   ( SELECT SUM(sendqtty - sendaqtty) careceiving, cas.afacctno|| cas.codeid caacctno
                                        FROM caschd cas
                                        WHERE  cas.status ='O'
                                        AND ISEXEC ='Y'
                                        GROUP BY  cas.afacctno|| cas.codeid) CA
                    where se.codeid=si.codeid
                    AND se.acctno = ca.caacctno (+)
                    and si.codeid=sb.codeid
                    and sb.sectype in ('001','002','003','006','007','008','011','111','222','333','444') --Ngay 23/03/2017 CW NamTv chinh sua them sectype 011
                    group by custid
                  ) se,
                  (select af.custid,sum(ad.feeamt) feeamt
                     from adschd ad, afmast af
                    where ad.txdate=v_currdate
                     and ad.deltd<>'Y'
                     and ad.acctno=af.acctno
                     group by af.custid
                  ) ad,
                  (SELECT  af.custid,
                          sum(lnt.namt) FEEAMT
                    FROM lntran lnt, lnmast lm ,  afmast af
                    WHERE lnt.tltxcd IN ('2646','2648','2636','2665') AND lnt.TXCD IN ('0024','0090')
                        and lnt.deltd<>'Y'
                        and lnt.acctno=lm.acctno
                        and lm.trfacctno=af.acctno
                    GROUP BY af.custid
                   ) DF,
                   (SELECT  af.custid,
                          sum(lnt.namt) FEEAMT
                    FROM lntran lnt, lnmast lm ,  afmast af
                    WHERE lnt.tltxcd IN ('5540','5567') AND lnt.TXCD IN ('0024','0075','0090','0073')
                        and lnt.deltd<>'Y'
                        and lnt.acctno=lm.acctno
                        and lm.trfacctno=af.acctno
                    GROUP BY af.custid
                   ) MR,
                   (select af.custid, count(lm.trfacctno) numoverdeal
                    from lnschdlog log, lnschd ln, lnmast lm  , afmast af
                    where log.autoid=ln.autoid
                        and ln.acctno=lm.acctno
                        and log.txdate=getcurrdate
                        and log.ovd>0
                        and lm.trfacctno = af.acctno
                    group by af.custid
                    ) LNLOG,
                    (SELECT max(REA.reacctno) recust, max(RETYPE.rerole) rerole ,afacctno
                        FROM reaflnk rea, retype
                        WHERE substr(rea.reacctno,11) = retype.actype
                        AND retype.rerole IN ('CS','RM')
                        AND REA.status ='A'
                        GROUP BY afacctno) re,
                    (
                    select af.custid,
                        sum(ln.prinnml + ln.prinovd ) mrnml,
                        round(sum(ln.intnmlacr + ln.intovdacr + ln.intnmlovd+ln.intdue
                            + ln.fee+ln.feedue+ln.feeovd+ln.feeintnmlacr+ln.feeintovdacr+ln.feeintnmlovd
                            +ln.feeintdue+ln.feefloatamt)) mrfeeamt
                        from lnmast ln, afmast af
                        where ftype ='AF' and ln.trfacctno=af.acctno
                            and ln.prinnml + ln.prinovd +ln.intnmlacr + ln.intovdacr + ln.intnmlovd+ln.intdue
                            + ln.fee+ln.feedue+ln.feeovd+ln.feeintnmlacr+ln.feeintovdacr+ln.feeintnmlovd
                            +ln.feeintdue+ln.feefloatamt >0
                        group by  af.custid
                    ) ln
                  Where  cf.custodycd=ci.custodycd
                  And cf.custid = od.custid(+)
                  and cf.custid = se.custid(+)
                  AND CF.custid = ad.custid(+)
                  and cf.custid = df.custid(+)
                  and cf.custid = mr.custid(+)
                  and cf.custid = lnlog.custid(+)
                  AND cf.custid = re.afacctno (+)
                  and cf.custid = ln.custid(+)
             )
    Loop

                insert into CFreviewlog ( autoid,
                                         custid,
                                         cftype,
                                        tradevalue, -- gia tri giao dich
                                        nav,-- NAV
                                        feeamt,-- phi giao dich
                                        finrevenue,  --- doanh thu margin
                                        DFREVENUE , -- doanh thu cam co
                                        ADREVENUE, -- doanh thu UTTB
                                        numoverdeal, -- so mon vay qua han
                                        calldays,-- so ngay vi pham ti ly
                                        OVERDUEDAY, -- so ngay qua han
                                        odamt,
                                        status,
                                        logdays,
                                        result,
                                        LASTDATE,
                                        RECUST,
                                        REROLE,
                                        CIAMT,
                                        SEAMT,
                                        careceiving,
                                        mrnml,
                                        mrfeeamt,
                                        advamt,
                                        depofeeamt,
                                        rcvamt,
                                        crintacr
                                        )
                values(seq_CFreviewlog.nextval,
                                        vc.custid,
                                        vc.actype,
                                        vc.tradevalue,
                                        vc.nav,
                                        vc.feeamt,
                                        vc.finrevenue,
                                        vc.DFREVENUE,
                                        vc.ADREVENUE,
                                        vc.numoverdeal,
                                        vc.calldays,
                                        vc.OVERDUEDAY,
                                        vc.odamt,
                                        'A',
                                        1,
                                        0,
                                        v_currdate,
                                        vc.recust,
                                        vc.rerole,
                                        vc.ciamt,
                                        vc.seamt,
                                        vc.CARECEIVING,
                                        vc.MRNML,
                                        vc.mrfeeamt,
                                        vc.ADVAMT,
                                        vc.DEPOFEEAMT,
                                        vc.RCVAMT,
                                        vc.CRINTACR
                                         )   ;

    End loop;



    p_err_code:='0';
    plog.setendsection(pkgctx, 'pr_DailyLogCFIfno');
EXCEPTION
   WHEN others THEN
   plog.error (pkgctx, SQLERRM || dbms_utility.format_error_backtrace);
   plog.setendsection (pkgctx, 'pr_DailyLogCFIfno');
   p_err_code:='-1';
   return;
END;

PROCEDURE Pr_Cfreview_Result (p_cfrvid in varchar2, p_err_code in out varchar2)
-- Log thong tin hang ngay
IS
    V_CURRDATE  DATE;
    L_AUTOID    NUMBER;
    L_RECUST    VARCHAR2(50);
    L_NAV       NUMBER ;
    L_NAVCURR   NUMBER;
    L_FEEAMT    NUMBER;
    L_DEFACTYPE VARCHAR2 (10);
    L_CFTYPENEW VARCHAR2 (10);
    L_TNAV      NUMBER ;
    L_TNAVCURR  NUMBER ;
    L_TFEEAMT   NUMBER ;
    l_Tdate     DATE;
BEGIN
    plog.setbeginsection(pkgctx, 'Pr_Cfreview_Result');
    p_err_code:= '0';

DELETE FROM CFREVIEWRESULT WHERE CFRVID =p_cfrvid;
   FOR REC IN(
           SELECT CFV.AUTOID,CFV.FRDATE, CFV.TODATE ,CFVDTL.CFTYPE, NAV,NAVCURR,FEEAMT,TYPEREVIEW, CF.FULLNAME , CF.CUSTODYCD, CF.CUSTID
        FROM CFREVIEW CFV, CFREVIEWDTL CFVDTL, CFMAST CF
        WHERE CFV.AUTOID = CFVDTL.CFREVID
        AND CFV.STATUS ='A'
        AND CF.CUSTID IN (SELECT CUSTID FROM AFMAST)
        AND cf.status NOT IN ( 'C','E','R')
        AND CFVDTL.CFTYPE = CF.ACTYPE
        AND CFV.autoid = p_cfrvid
        )
   LOOP
    SELECT max(sbdate) INTO l_Tdate FROM sbcldr WHERE holiday ='N' AND  sbdate <= REC.TODATE AND SBDATE <getcurrdate ;

    SELECT  ROUND ( SUM (nav*logdays)/SUM(logdays)), SUM (FEEAMT) INTO  l_NAV , L_FEEAMT FROM CFreviewlog  WHERE CUSTID = REC.CUSTID AND lastdate BETWEEN rec.FRDATE AND rec.todate   ;
    SELECT sum(NVL(nav,0)), max(recust) INTO  l_NAVCURR , L_RECUST  FROM CFreviewlog  WHERE CUSTID = REC.CUSTID AND lastdate = l_Tdate   ;
    SELECT  DEFACTYPE INTO   L_DEFACTYPE FROM CFTYPE WHERE ACTYPE = rec.cftype;

     IF l_NAV < REC.NAV AND L_FEEAMT < REC.feeamt AND l_NAVCURR < REC.NAVCURR THEN
    -- xuong hang
    INSERT INTO CFREVIEWRESULT (AUTOID,CFRVID,CUSTODYCD,FULLNAME,CFTYPECURR,CFTYPENEW,ISPASS,RECUST,NAV,NAVCURR,FEEAMT,ISKEEPCF,REASONKEEP,STATUS)
    VALUES(seq_cfreviewresult.NEXTVAL, rec.autoid,rec.custodycd,rec.fullname,rec.cftype,L_DEFACTYPE ,'N',L_RECUST ,l_NAV,l_NAVCURR,L_FEEAMT,NULL,NULL,'A');

    ELSE
    -- tang hang
        L_CFTYPENEW:= REC.cftype;
        -- sap xep theo thu tu giam dan gap hang nao thoa man th?ay luon

        FOR RECDTL IN ( SELECT * FROM  CFTYPE WHERE ordnum > ( SELECT ordnum FROM CFTYPE WHERE ACTYPE = REC.CFTYPE  )  ORDER BY ordnum DESC )
        LOOP
        SELECT MAX( NVL(NAV,0)),MAX(NVL(NAVCURR,0)),MAX(NVL(FEEAMT,0)) INTO L_TNAV, l_TNAVCURR, L_TFEEAMT  FROM  CFREVIEWDTL WHERE cfrevid = REC.AUTOID AND  cftype = RECDTL.actype   ;

     /*      plog.error (pkgctx, ' REC.AUTOID'|| REC.AUTOID);

           plog.error (pkgctx, 'RECDTL.actype'||RECDTL.actype);

            plog.error (pkgctx, 'L_NAV'||L_NAV);
            plog.error (pkgctx, 'l_NAVCURR'||l_NAVCURR);
            plog.error (pkgctx, 'L_FEEAMT'||L_FEEAMT);

            plog.error (pkgctx, 'L_TNAV'||L_TNAV);
            plog.error (pkgctx, 'l_tNAVCURR'||l_tNAVCURR);
            plog.error (pkgctx, 'L_tFEEAMT'||L_tFEEAMT);*/


          IF L_TNAV <= l_NAV OR L_TFEEAMT <= L_FEEAMT  OR  l_TNAVCURR <= l_NAVCURR THEN
            L_CFTYPENEW:= RECDTL.ACTYPE;
               EXIT;
            END IF;
         END LOOP;

        INSERT INTO CFREVIEWRESULT (AUTOID,CFRVID,CUSTODYCD,FULLNAME,CFTYPECURR,CFTYPENEW,ISPASS,RECUST,NAV,NAVCURR,FEEAMT,ISKEEPCF,REASONKEEP,STATUS)
        VALUES(seq_cfreviewresult.NEXTVAL, rec.autoid,rec.custodycd,rec.fullname,rec.cftype,L_CFTYPENEW,'Y' ,L_RECUST ,l_NAV,l_NAVCURR,L_FEEAMT,NULL,NULL,'A');

    END IF;
END LOOP;

-- Sau khi su ly update ky xet duyet ve C
--UPDATE CFREVIEW SET STATUS ='C' WHERE STATUS ='A';



    p_err_code:='0';
    plog.setendsection(pkgctx, 'Pr_Cfreview_Result');
EXCEPTION
   WHEN others THEN
   plog.error (pkgctx, SQLERRM || dbms_utility.format_error_backtrace);
   plog.setendsection (pkgctx, 'Pr_Cfreview_Result');
   p_err_code:='-1';
   return;
END;




/*
PROCEDURE pr_DailyLogCFIfno(p_err_code in out varchar2)
-- Log thong tin hang ngay
IS
    v_currdate date;
    V_NEXTDATE DATE;
    L_AUTOID NUMBER;
BEGIN
    plog.setbeginsection(pkgctx, 'pr_DailyLogCFIfno');
    p_err_code:= '0';

        Select TO_DATE (varvalue, systemnums.c_date_format) into v_currdate
    From sysvar
    Where varname='CURRDATE';

     Select TO_DATE (varvalue, systemnums.c_date_format) into v_nextdate
    From sysvar
    Where varname='NEXTDATE';

    For vc in(
            Select
                 CF.custid,
                 CF.actype,
                 nvl(od.tradevalue,0) tradevalue,
                 nvl(od.feeamt,0) feeamt,
                 CI.CIAMT + nvl(se.seamt,0) NAV,
                 nvl(mr.FEEAMT,0) finrevenue,
                 nvl(df.feeamt,0) DFREVENUE ,
                 nvl(ad.feeamt,0) ADREVENUE,
                 nvl(lnlog.numoverdeal,0) numoverdeal,
                 0 calldays,
                 0 OVERDUEDAY,
                 ci.odamt odamt
            From
                 CFMAST CF,
                 (Select
                     cf.custid,
                     sum(od.execamt) tradevalue,
                     sum(od.feeacr) feeamt
                    From CFmast cf,afmast af, odmast od
                    Where  cf.custid=af.custid
                        and af.acctno=od.afacctno
                        and od.deltd<>'Y'
                        and od.execamt>0
                        and txdate=v_currdate
                    Group by cf.custid
                  ) OD,
                  ( Select ci.custodycd,
                       sum(
                            (ci.balance + ci.bamt  + ci.rcvamt + ci.tdbalance + ci.crintacr + ci.tdintamt ) -
                            (ci.dfodamt + ci.t0odamt + ci.mrodamt + ci.ovdcidepofee + ci.execbuyamt + ci.trfbuyamt + ci.rcvadvamt + ci.TDODAMT)) ciamt,
                       sum (ci.dfodamt + ci.t0odamt + ci.mrodamt + ci.ovdcidepofee + ci.execbuyamt + ci.trfbuyamt + ci.rcvadvamt + ci.TDODAMT) ODAMT

                     From buf_ci_account ci
                     group by  ci.custodycd
                   ) ci,
                  (select se.custid, sum((se.trade+ se.receiving +se.blocked +se.emkqtty+se.mortage )* si.basicprice) seamt
                    from semast se, securities_info si,sbsecurities sb
                    where se.codeid=si.codeid
                    and si.codeid=sb.codeid
                    and sb.sectype in ('001','002','003','006','007','008','111','222','333','444')
                    group by custid
                  ) se,
                  (select af.custid,sum(ad.feeamt) feeamt
                     from adschd ad, afmast af
                    where ad.txdate=v_currdate
                     and ad.deltd<>'Y'
                     and ad.acctno=af.acctno
                     group by af.custid
                  ) ad,
                  (SELECT  af.custid,
                          sum(lnt.namt) FEEAMT
                    FROM lntran lnt, lnmast lm ,  afmast af
                    WHERE lnt.tltxcd IN ('2646','2648','2636','2665') AND lnt.TXCD IN ('0024','0090')
                        and lnt.deltd<>'Y'
                        and lnt.acctno=lm.acctno
                        and lm.trfacctno=af.acctno
                    GROUP BY af.custid
                   ) DF,
                   (SELECT  af.custid,
                          sum(lnt.namt) FEEAMT
                    FROM lntran lnt, lnmast lm ,  afmast af
                    WHERE lnt.tltxcd IN ('5540','5567') AND lnt.TXCD IN ('0024','0075','0090','0073')
                        and lnt.deltd<>'Y'
                        and lnt.acctno=lm.acctno
                        and lm.trfacctno=af.acctno
                    GROUP BY af.custid
                   ) MR,
                   (select af.custid, count(lm.trfacctno) numoverdeal
                    from lnschdlog log, lnschd ln, lnmast lm  , afmast af
                    where log.autoid=ln.autoid
                        and ln.acctno=lm.acctno
                        and log.txdate=getcurrdate
                        and log.ovd>0
                        and lm.trfacctno = af.acctno
                    group by af.custid
                    ) LNLOG
                  Where  cf.custodycd=ci.custodycd
                  And cf.custid = od.custid(+)
                  and cf.custid = se.custid(+)
                  AND CF.custid = ad.custid(+)
                  and cf.custid = df.custid(+)
                  and cf.custid = mr.custid(+)
                  and cf.custid = lnlog.custid(+)
             )
    Loop

        L_AUTOID:=0;
        For rec in (select autoid from cfreviewlog l where l.custid=vc.custid and status='A' )
        Loop
            l_AUTOID:=rec.autoid;
        End loop;
        IF L_AUTOID =0 then
              insert into CFreviewlog ( autoid,
                                         custid,
                                         cftype,
                                        tradevalue, -- gia tri giao dich
                                        nav,-- NAV
                                        feeamt,-- phi giao dich
                                        finrevenue,  --- doanh thu margin
                                        DFREVENUE , -- doanh thu cam co
                                        ADREVENUE, -- doanh thu UTTB
                                        numoverdeal, -- so mon vay qua han
                                        calldays,-- so ngay vi pham ti ly
                                        OVERDUEDAY, -- so ngay qua han
                                        odamt,
                                        status,
                                        logdays,
                                        result,
                                        LASTDATE
                                        )
                values(seq_CFreviewlog.nextval,
                                        vc.custid,
                                        vc.actype,
                                        vc.tradevalue,
                                        vc.nav,
                                        vc.feeamt,
                                        vc.finrevenue,
                                        vc.DFREVENUE,
                                        vc.ADREVENUE,
                                        vc.numoverdeal,
                                        vc.calldays,
                                        vc.OVERDUEDAY,
                                        vc.odamt,
                                        'A',
                                        1,
                                        0,
                                        v_currdate
                                         )   ;
        ELSE
            update CFreviewlog
            set  cftype=vc.actype,
                 tradevalue = tradevalue + vc.tradevalue, -- gia tri giao dich
                 nav = nav + vc.nav,-- NAV
                 feeamt = feeamt + vc.feeamt,-- phi giao dich
                 finrevenue = finrevenue + vc.finrevenue,  --- doanh thu margin
                 DFREVENUE = DFREVENUE + vc.DFREVENUE, -- doanh thu cam co
                 ADREVENUE = ADREVENUE + vc.ADREVENUE, -- doanh thu UTTB
                 numoverdeal = numoverdeal + vc.numoverdeal , -- so mon vay qua han
                 calldays = calldays + vc.calldays,-- so ngay vi pham ti ly
                 OVERDUEDAY =  OVERDUEDAY + vc.OVERDUEDAY,
                 odamt = odamt + vc.odamt,
                 logdays=logdays + 1,
                 lastdate = v_currdate
             where autoid = L_AUTOID;
        End if;
    End loop;
       -- TH qua thang
       IF LAST_DAY(v_currdate) < v_nextdate then
             Update cfreviewlog
             Set nav = round(nav/logdays),
                 odamt = round(odamt/logdays),
                 status = 'C'
             Where status = 'A' and logdays>0;

            Insert into cfreviewloghist select * from cfreviewlog where status ='C';
            delete cfreviewlog  where status ='C';
        End if;


    p_err_code:='0';
    plog.setendsection(pkgctx, 'pr_DailyLogCFIfno');
EXCEPTION
   WHEN others THEN
   plog.error (pkgctx, SQLERRM || dbms_utility.format_error_backtrace);
   plog.setendsection (pkgctx, 'pr_DailyLogCFIfno');
   p_err_code:='-1';
   return;
END;*/
PROCEDURE pr_Execute_CFreview(p_err_code in out varchar2)
IS
    v_currdate date;
    L_AUTOID NUMBER;
    v_newcftype varchar2(4);
    v_newordnum number(1);
BEGIN
    plog.setbeginsection(pkgctx, 'pr_Execute_CFreview');
    p_err_code:= '0';

    Select TO_DATE (varvalue, systemnums.c_date_format) into v_currdate
    From sysvar
    Where varname='CURRDATE';
    Update cfreviewlog
    Set nav = round(nav/logdays),
        odamt = round(odamt/logdays)
    Where status = 'A' and logdays>0;

    For vc in (Select CFT.DEFACTYPE,
                      cfl.custid,
                      cfL.nav,
                      cfl.feeamt,
                      cft.ordnum orgordnum,
                      cfl.cftype
               From cfreviewlog cfL , CFTYPE CFT
               WHere cfL.status='A'
                   AND cfL.CFTYPE=CFT.ACTYPE)
    Loop
        v_newcftype:=VC.DEFACTYPE;
        v_newordnum:=0;
        For rec in(SELECT dtl.CFTYPE,
                          dtl.nav,
                          dtl.feeamt,
                          cft.ordnum
                    FROM cfreview hdr, cfreviewdtl dtl, cftype cft
                    where hdr.autoid=dtl.cfrevid
                     and dtl.cftype = cft.actype
                     order by cft.ordnum desc)
        Loop
                  IF (rec.nav >= vc.nav) and (rec.feeamt>=vc.feeamt) then
                      v_newcftype:=rec.cftype;
                      v_newordnum:=rec.ordnum;
                      Exit;
                  End if;
        End loop;
        Update cfreviewlog
        Set newcftype =v_newcftype, status='C',
            result= case
                         when vc.cftype=v_newcftype then 0 -- giu hang
                         when v_newordnum > vc.orgordnum then 1 -- len hang
                         else -1     -- xuong hang
                    end
        Where custid= vc.custid;
    End loop;

    p_err_code:='0';
    plog.setendsection(pkgctx, 'pr_Execute_CFreview');
EXCEPTION
   WHEN others THEN
   plog.error (pkgctx, SQLERRM || dbms_utility.format_error_backtrace);
   plog.setendsection (pkgctx, 'pr_Execute_CFreview');
   p_err_code:='-1';
   return;
END;


function pr_check_Account_Call(p_custodycd varchar2) return boolean
IS
    l_count number;
   v_currdate date ;
BEGIN
    plog.setbeginsection(pkgctx, 'pr_check_Account_Call');

select getcurrdate into v_currdate from dual ;

    select count(1) into l_count from cfmast where custodycd =p_custodycd and callsts ='Y';

    if l_count<=0 then
        return true;
    end if;

     select count(1) into l_count from EXLOCKCOSTODYCD where custodycd =p_custodycd  and v_currdate BETWEEN valdate and expdate  and deltd <>'Y' ;

    if l_count > 0 then
        return true;
    end if;

    select count(1) into l_count from v_getsecmarginratio a, cimast ci, cfmast cf
    where (a.marginrate < a.mrcrate or ((ci.OVAMT-GREATEST(0,CI.BALANCE+NVL(a.AVLADVANCE,0)- CI.BUYSECAMT))>1)) and a.afacctno = ci.acctno and ci.custid = cf.custid and cf.custodycd =p_custodycd;

    if l_count>0 then
        return false;
    else
        return true;
    end if;
    plog.setendsection(pkgctx, 'pr_check_Account_Call');
    return true;
EXCEPTION
   WHEN others THEN
   return true;
END;

 function pr_check_warning_rate_listing(p_custodycd VARCHAR2, p_symbol VARCHAR2, p_qtty number ) return boolean
IS
    l_count number;
    l_trade number ;
    l_listingqtty number;
    l_warning_rate number;
BEGIN
    plog.setbeginsection(pkgctx, 'pr_check_warning_rate_listing');

    SELECT TO_NUMBER( varvalue)  INTO L_warning_rate from SYSVAR where varname = 'WARNING_RATE';

   SELECT MST.SETRADE+NVL(OD.ODQTTY,0) TRADE, MST.LISTINGQTTY INTO L_TRADE,L_LISTINGQTTY
  FROM
  (SELECT SUM(SETRADE) SETRADE,  CUSTODYCD, MAX( LISTINGQTTY) LISTINGQTTY
   FROM
   (
   SELECT SUM(SE.TRADE+SE.MORTAGE+SE.WITHDRAW+SE.BLOCKED+SE.SENDPENDING+
      SE.DTOCLOSE+SE.SDTOCLOSE+SE.EMKQTTY+SE.BLOCKWITHDRAW+SE.BLOCKDTOCLOSE+SE.RECEIVING-SE.NETTING) SETRADE, CF.CUSTODYCD, MAX(SEC.LISTINGQTTY) LISTINGQTTY
     FROM SEMAST SE, SECURITIES_INFO SEC, AFMAST AF, CFMAST CF
     WHERE SE.CODEID(+) = SEC.CODEID AND SEC.SYMBOL = P_SYMBOL
      AND SE.AFACCTNO = AF.ACCTNO AND AF.CUSTID = CF.CUSTID
      AND CF.CUSTODYCD = p_CUSTODYCD
     GROUP BY CF.CUSTODYCD
   UNION ALL
   SELECT 0 SETRADE, p_CUSTODYCD CUSTODYCD, MAX(SEC.LISTINGQTTY) LISTINGQTTY
     FROM  SECURITIES_INFO SEC
     WHERE SEC.SYMBOL = P_SYMBOL
   )
   GROUP BY CUSTODYCD
  )MST,
  (SELECT SUM(CASE WHEN OD.EXECTYPE = 'NB' THEN OD.ORDERQTTY-(OD.CANCELQTTY+OD.ADJUSTQTTY)
   ELSE -OD.EXECQTTY END) ODQTTY, CF.CUSTODYCD
  FROM ODMAST OD, AFMAST AF, CFMAST CF , SECURITIES_INFO SEC
  WHERE OD.AFACCTNO = AF.ACCTNO AND AF.CUSTID = CF.CUSTID
   AND CF.CUSTODYCD = p_CUSTODYCD AND OD.CODEID = SEC.CODEID
   AND SEC.SYMBOL = P_SYMBOL AND OD.TXDATE = GETCURRDATE AND EXECTYPE IN ('NB','NS','MS')
  GROUP BY CF.CUSTODYCD)OD
  WHERE MST.CUSTODYCD =  OD.CUSTODYCD(+);

  IF L_LISTINGQTTY>0 THEN
      IF (L_TRADE+ P_QTTY)/L_LISTINGQTTY > L_warning_rate/100 THEn
      RETURN TRUE;
      END IF;
  END IF;

    plog.setendsection(pkgctx, 'pr_check_warning_rate_listing');
    return FALSE ;
EXCEPTION
   WHEN others THEN
   return FALSE;
END;


function fn_check_Account_mrirate(p_acctno VARCHAR2,p_codeid VARCHAR2,p_qtty NUMBER, p_amt number   ) return boolean
IS
-- p_acctno : So tieu khoan
-- p_codeid : Ma chung khoan
-- p_qtty : So luwong
--P_amt : So tien tru di
    l_count number;
    l_mrrate number;
    l_marginrate number;
    l_mrirate number;
BEGIN
   select nvl(max(rsk.mrratiorate * least(rsk.mrpricerate,se.margincallprice) / 100),0)
        into l_mrrate
    from afserisk rsk, afmast af, aftype aft, mrtype mrt, securities_info se
    where af.actype = rsk.actype and af.actype = aft.actype and aft.mrtype = mrt.actype and mrt.mrtype = 'T' and aft.istrfbuy = 'N'
    and af.acctno = p_acctno and rsk.codeid = p_codeid and rsk.codeid = se.codeid;


     if l_mrrate > 0 then -- check them khi chuyen chung khoan di, tai san con lai phai dam bao ty le.
        select round((case when ci.balance +LEAST(nvl(af.MRCRLIMIT,0),nvl(sec.secureamt,0) + ci.trfbuyamt)+ nvl(sec.avladvance,0) - ci.odamt - nvl(sec.secureamt,0) - ci.trfbuyamt - ci.ramt-P_amt/*-CI.CIDEPOFEEACR-CI.DEPOFEEAMT*/>=0 then 100000
                --else least( greatest(nvl(sec.SEASS,0) - to_number(p_txmsg.txfields('10').value) * l_mrrate,0), af.mrcrlimitmax - dfodamt)
                else  greatest(nvl(sec.SEASS,0) - to_number(p_qtty) * l_mrrate,0)
                    / abs(ci.balance +LEAST(nvl(af.MRCRLIMIT,0),nvl(sec.secureamt,0) + ci.trfbuyamt)+ nvl(sec.avladvance,0) - ci.odamt - nvl(sec.secureamt,0) - ci.trfbuyamt - ci.ramt/*-CI.CIDEPOFEEACR-CI.DEPOFEEAMT*/-P_amt) end),4) * 100 MARGINRATE,
                af.mrirate
                    into l_marginrate, l_mrirate
        from afmast af, cimast ci, v_getsecmarginratio sec
        where af.acctno = ci.acctno and af.acctno = sec.afacctno(+)
        and af.acctno = p_acctno;


         IF L_MARGINRATE < L_MRIRATE THEN
         RETURN FALSE ;
         END IF;
     END IF;


    return true;
EXCEPTION
   WHEN others THEN
   return true;
END;

PROCEDURE pr_CFMAST_ChangeTypeCheck (p_CUSTID in varchar2,p_actype in varchar2, p_err_code in out varchar2)
IS
l_count number;

BEGIN
    plog.setbeginsection(pkgctx, 'pr_CFMAST_ChangeTypeCheck');
    p_err_code:= '0';
    l_count:=0;

    Select count(1)  into l_count
    From Cftype WHERE actype=p_actype
    and ( status <> 'Y' or apprv_sts <> 'A');

    If  l_count>0 then
         p_err_code:= '-201419';
         plog.setendsection(pkgctx, 'pr_CFMAST_ChangeTypeCheck');
         return;
    End if;


    Select count(1)  into l_count
    From Cftype c1,cfmast cf, cftype c2
    Where c1.actype=cf.actype
         and cf.custid=p_CUSTID
         and c2.actype=p_actype
         and cf.custtype<>c2.custtype;
    If  l_count>0 then
         p_err_code:= '-100499';
         plog.setendsection(pkgctx, 'pr_CFMAST_ChangeTypeCheck');
         return;
    End if;

    For vc in (Select cf.custid,cf.actype cftype, af.acctno, af.actype aftype,afT.producttype
               From cfmast cf, afmast af, AFTYPE AFT
               Where cf.custid=af.custid
                  AND AF.ACTYPE=AFT.ACTYPE
                  and cf.custid=p_CUSTID)
    Loop
        l_count:=0;
        Select count(1) into l_count
        From CFAFTYPE C, AFTYPE AFT
        Where C.CFTYPE= p_actype AND C.AFTYPE=AFT.ACTYPE
        AND AFT.PRODUCTTYPE=VC.producttype;
        If l_count <> 1 then
              p_err_code:= '-100499';
            plog.setendsection(pkgctx, 'pr_CFMAST_ChangeTypeCheck');
            return;
        End if;
    End loop;
    p_err_code:='0';
    plog.setendsection(pkgctx, 'pr_CFMAST_ChangeTypeCheck');
EXCEPTION
   WHEN others THEN
   plog.error (pkgctx, SQLERRM || dbms_utility.format_error_backtrace);
   plog.setendsection (pkgctx, 'pr_CFMAST_ChangeTypeCheck');
   p_err_code:='-1';
   return;
END;

PROCEDURE pr_ChangeCFType(p_CUSTID in varchar2,p_actype in varchar2,p_err_code in out varchar2)
IS
    v_currdate date;
    l_count number;
    l_newaftype varchar2(4);
    l_mrcrlimitmax number;
    l_citype varchar2(4);
    l_setype varchar2(4);
     l_k1days number;
    l_k2days number;
    l_mrcrate number;
    l_mrwrate number;
    l_mrexrate number;
    l_mriratio number;
    l_mrmratio number;
    l_mrlratio number;
BEGIN
    plog.setbeginsection(pkgctx, 'pr_ChangeCFType');
    p_err_code:= '0';
    Select count(1)  into l_count
    From Cftype c1,cfmast cf, cftype c2
    Where c1.actype=cf.actype
         and cf.custid=p_CUSTID
         and c2.actype=p_actype
         and cf.custtype<>c2.custtype;
    If  l_count>0 then
         p_err_code:= '-100499';
         plog.setendsection(pkgctx, 'pr_ChangeCFType');
         return;
    End if;

    For vc in (Select cf.custid,cf.actype cftype, af.acctno, af.actype aftype,afT.producttype
               From cfmast cf, afmast af, AFTYPE AFT
               Where cf.custid=af.custid
                  AND AF.ACTYPE=AFT.ACTYPE
                  and cf.custid=p_CUSTID)
    Loop
        l_count:=0;
        Select count(1) into l_count
        From CFAFTYPE C, AFTYPE AFT
        Where C.CFTYPE= p_actype  AND C.AFTYPE=AFT.ACTYPE
        AND AFT.PRODUCTTYPE =VC.producttype;
        If l_count <> 1 then
              p_err_code:= '-100499';
            plog.setendsection(pkgctx, 'pr_ChangeCFType');
            return;
        End if;
    End loop;

     For vc in (Select cf.custid,cf.actype cftype, af.acctno, af.actype aftype,afT.producttype
               From cfmast cf, afmast af, AFTYPE AFT
               Where cf.custid=af.custid
                  AND AF.ACTYPE=AFT.ACTYPE
                  and cf.custid=p_CUSTID)
    Loop

         Begin
             Select c.aftype,aft.citype,aft.setype, aft.mrcrlimitmax,aft.k1days,aft.k2days
                   ,mrt.mrcrate,mrt.mrwrate,mrt.mrexrate,mrt.mriratio ,mrt.mrmratio ,mrt.mrlratio
              into l_newaftype,l_citype,l_setype, l_mrcrlimitmax, l_k1days,l_k2days,
                    l_mrcrate,l_mrwrate,l_mrexrate,l_mriratio ,l_mrmratio ,l_mrlratio
             From CFAFTYPE C, AFTYPE AFT, MRtype mrt
             Where C.CFTYPE= p_actype
                   and C.AFTYPE=AFT.ACTYPE
                   AND  AFT.PRODUCTTYPE=VC.producttype
                   and aft.mrtype=mrt.actype;
         EXCEPTION
               WHEN others THEN
               plog.error (pkgctx, SQLERRM || dbms_utility.format_error_backtrace);
               plog.setendsection (pkgctx, 'pr_ChangeCFType');
               p_err_code:='-1';
               return;
         End;
         Update afmast
         Set actype= l_newaftype,
             mrcrlimitmax=l_mrcrlimitmax,
             k1days=l_k1days,
             k2days=l_k2days,
             mrcrate=l_mrcrate,
             mrwrate=l_mrwrate,
             mrexrate= l_mrexrate,
             mriratio= l_mriratio ,
             mrmratio= l_mrmratio ,
             mrlratio= l_mrlratio
         WHERE ACCTNO=VC.ACCTNO;
         Update semast
         Set actype = l_setype
         where afacctno=VC.ACCTNO;
         Update cimast
         Set actype = l_citype
         where acctno=VC.ACCTNO;

    End loop;

    p_err_code:='0';
    plog.setendsection(pkgctx, 'pr_ChangeCFType');
EXCEPTION
   WHEN others THEN
   plog.error (pkgctx, SQLERRM || dbms_utility.format_error_backtrace);
   plog.setendsection (pkgctx, 'pr_ChangeCFType');
   p_err_code:='-1';
   return;
END;

FUNCTION fn_ChangeCftype4expdate(p_err_code in out varchar2)
  RETURN boolean
  IS
  v_newactype varchar2(10);
  v_nextcftype  varchar2(10);
  v_strCURRDATE DATE;
  v_strDATEFEE DATE;
  v_strCOMPANYCD varchar2(10);
  v_Result  number(20);
  l_txmsg               tx.msg_rectype;
  v_errcode NUMBER;
  l_err_param varchar2(300);
  l_OrgDesc varchar2(100);
  l_EN_OrgDesc varchar2(100);
  l_old_actype varchar2(100);
  BEGIN
    plog.setendsection(pkgctx, 'fn_ChangeCftype4expdate');
  FOR rec IN (
    SELECT acc.autoid , acc.custid,acc.fractype,acc.toactype,acc.expdate,acc.nextcftype,acc.status,acc.deltd, cf.fullname , cf.custodycd,CF.brid
    FROM AccCftypeLog acc, cfmast cf
    WHERE NVL( expdate, TO_DATE ('01/10/9999','dd/mm/yyyy')) = getcurrdate
    AND acc.status NOT IN ('R','C') AND acc.DELTD ='N'
    AND (CF.status ='A' OR (CF.status ='P' AND INSTR( CF.pstatus,'A')>0 ))
    AND acc.custid = cf.custid
    AND nextcftype IS NOT NULL
    ORDER BY acc.autoid
   )
    LOOP
    v_nextcftype := CASE WHEN   rec.nextcftype='PREV' THEN REC.fractype ELSE  rec.nextcftype END ;
   IF  v_nextcftype IS NOT NULL THEN

     --cspks_cfproc.pr_ChangeCFType(rec.custid,v_nextcftype,p_err_code);
     -- tao giao dich 0021
     select actype into l_old_actype from cfmast where custid = rec.custid ;

      SELECT TXDESC,EN_TXDESC into l_OrgDesc, l_EN_OrgDesc FROM  TLTX WHERE TLTXCD='0021';

        SELECT TO_DATE (varvalue, systemnums.c_date_format)
               INTO v_strCURRDATE
               FROM sysvar
               WHERE grname = 'SYSTEM' AND varname = 'CURRDATE';

        l_txmsg.msgtype:='T';
        l_txmsg.local:='N';
        l_txmsg.tlid        := systemnums.c_system_userid;
        SELECT SYS_CONTEXT ('USERENV', 'HOST'),
                 SYS_CONTEXT ('USERENV', 'IP_ADDRESS', 15)
          INTO l_txmsg.wsname, l_txmsg.ipaddress
        FROM DUAL;
        l_txmsg.off_line    := 'N';
        l_txmsg.deltd       := txnums.c_deltd_txnormal;
        l_txmsg.txstatus    := txstatusnums.c_txcompleted;
        l_txmsg.msgsts      := '0';
        l_txmsg.ovrsts      := '0';
        l_txmsg.batchname   := 'DAY';
        l_txmsg.txdate:=to_date(v_strCURRDATE,systemnums.c_date_format);
        l_txmsg.busdate:=to_date(v_strCURRDATE,systemnums.c_date_format);
        l_txmsg.tltxcd:='0021';

        --Set txnum
        SELECT systemnums.C_BATCH_PREFIXED
                         || LPAD (seq_BATCHTXNUM.NEXTVAL, 8, '0')
                  INTO l_txmsg.txnum
                  FROM DUAL;
        l_txmsg.brid        := REC.BRID;


      --Set cac field giao dich
      --03  CUSTID      C
        l_txmsg.txfields ('03').defname   := 'CUSTID';
        l_txmsg.txfields ('03').TYPE      := 'C';
        l_txmsg.txfields ('03').VALUE     := rec.CUSTID;

      --88  CUSTODYCD    C
        l_txmsg.txfields ('88').defname   := 'CUSTODYCD';
        l_txmsg.txfields ('88').TYPE      := 'C';
        l_txmsg.txfields ('88').VALUE     := rec.CUSTODYCD;

        --28  FULLNAME    C
        l_txmsg.txfields ('28').defname   := 'CUSTODYCD';
        l_txmsg.txfields ('28').TYPE      := 'C';
        l_txmsg.txfields ('28').VALUE     := rec.FULLNAME;

        --45  ACTYPE       C
        l_txmsg.txfields ('45').defname   := 'ACTYPE';
        l_txmsg.txfields ('45').TYPE      := 'C';
        l_txmsg.txfields ('45').VALUE     := l_old_actype;

        --46  NACTYPE    C
        l_txmsg.txfields ('46').defname   := 'NACTYPE';
        l_txmsg.txfields ('46').TYPE      := 'C';
        l_txmsg.txfields ('46').VALUE     := v_nextcftype;

        --30  DEC    C
        l_txmsg.txfields ('30').defname   := 'DEC';
        l_txmsg.txfields ('30').TYPE      := 'C';
        l_txmsg.txfields ('30').VALUE     := l_OrgDesc;

        BEGIN
            IF txpks_#0021.fn_autotxprocess (l_txmsg,
                                             v_errcode,
                                             l_err_param
               ) <> systemnums.c_success
            THEN
               plog.debug (pkgctx,
                           'got error 0021: ' || v_errcode
               );
               p_err_code:= v_errcode;
               ROLLBACK;
                 UPDATE AccCftypeLog SET status ='R',ERR=v_errcode  WHERE autoid = rec.autoid;
                 COMMIT;
               ELSE
                UPDATE AccCftypeLog SET status ='C' WHERE autoid = rec.autoid;
               COMMIT;
            END IF;
        END;





  END IF ;
  END LOOP;

    p_err_code:='0';
    plog.setendsection(pkgctx, 'fn_ChangeCftype4expdate');
    return true;
  EXCEPTION
  WHEN OTHERS
   THEN
      plog.error (pkgctx, SQLERRM);
      plog.setendsection (pkgctx, 'fn_ChangeCftype4expdate');
      RAISE errnums.E_SYSTEM_ERROR;
      return false;
  END fn_ChangeCftype4expdate;


PROCEDURE pr_AutoOpenNormalAccount(p_CUSTID in varchar2,p_FirstTime in varchar2,p_err_code in out varchar2)
IS
    v_currdate date;
    v_count number;
    l_corebank  char(1);
    l_autoadv   char(1);

    l_aftype varchar2(10);
    l_custid varchar2(20);
    l_afacctno varchar2(20);
    v_busdate   varchar2(20);
    p_tlid varchar2(20);
    p_apptlid varchar2(20);
    l_citype  varchar2(20);

    l_balance number;
    l_isPM varchar2(1);
BEGIN
    plog.setbeginsection(pkgctx, 'pr_ChangeCFType');
    p_err_code:= '0';
    select varvalue into v_busdate from sysvar where grname ='SYSTEM' and varname ='CURRDATE';

    --------------------------- dang ky tu dong cac mau email.sms default = 'Y'
 IF p_FirstTime ='Y' THEN
                        FOR rec IN
                        (
                                SELECT code FROM templates WHERE require_register = 'Y' AND isdefault = 'Y'
                                AND code NOT IN (SELECT template_code FROM aftemplates WHERE custid = p_custid)
                        )
                        LOOP
                                INSERT INTO aftemplates (autoid,custid,template_code)
                                VALUES (seq_aftemplates.nextval, p_custid, rec.code);
                        END LOOP;
     END IF;
        -----------------------------------------------------------------------------------------------------------------------------
    --Lay ra danh sach loai hinh tieu khoan thuong can Mo
    select count(1) into v_count from afmast af, aftype aft, mrtype mrt
    where custid =p_CUSTID and af.actype = aft.actype and aft.mrtype = mrt.actype and mrt.mrtype <>'T';
    if v_count>0 then
        p_err_code:='0';
        return;
    end if;
    select count(1) into v_count from cfmast where custid =p_CUSTID and length(nvl(custodycd,'XX')) <> 10;
    if v_count>0 then
        p_err_code:='0';
        return;
    end if;
    --Neu chua co tieu khoan thi mo moi
    for rec in (
         select aft.actype, aft.AFTYPE,aft.corebank,aft.autoadv,aft.citype,aft.k1days,aft.k2days,
                aft.producttype, substr(cf.custodycd,4,1) custype,
                cf.brid,cf.careby,cf.tlid,
                mrt.MRIRATE,mrt.MRMRATE,mrt.MRLRATE,mrt.MRCRLIMIT,
                mrt.MRLMMAX,mrt.mriratio,mrt.mrmratio,mrt.mrlratio,mrt.mrcrate,mrt.mrwrate,mrt.mrexrate,
                nvl(cf.last_ofid,nvl(cf.approveid,cf.tlid)) appid
         from cfmast cf, cfaftype cfaf , aftype aft, mrtype mrt
         where cf.actype = cfaf.cftype and cfaf.aftype = aft.actype
             and aft.mrtype = mrt.actype and mrt.mrtype ='N' and PRODUCTTYPE not in ('QT','QD')
             and cf.custid =p_CUSTID

    )
    loop
        ---- Kiem tra truong hop da co CFMAST nhung chua co AFMAST thi moi sinh
         select count(1) into v_count from afmast where custid =p_CUSTID and actype = rec.actype;

         if v_count =0 then
             l_aftype:=rec.AFTYPE;
             l_corebank:=rec.corebank;
             --l_autoadv:=rec.autoadv;
             l_autoadv := 'N';
             l_custid:=p_CUSTID;
             p_tlid:=rec.tlid;
            p_apptlid := rec.appid;
            if rec.custype = 'P' then
                l_balance:= 1000000000000;
                l_isPM:= 'Y';
            else
                l_balance:=0;
                l_isPM:='N';
            end if;
             ---- SINH SO AFMAST
             begin
             SELECT SUBSTR(INVACCT,1,4) || TRIM(TO_CHAR(MAX(ODR)+1,'000000')) into l_afacctno FROM
             (SELECT ROWNUM ODR, INVACCT
             FROM (SELECT ACCTNO INVACCT FROM AFMAST WHERE SUBSTR(ACCTNO,1,4)= trim(rec.brid) ORDER BY ACCTNO) DAT
             WHERE TO_NUMBER(SUBSTR(INVACCT,5,6))=ROWNUM) INVTAB
             GROUP BY SUBSTR(INVACCT,1,4);
             exception when others then
                l_afacctno :=trim(rec.brid) || '000001';
             end;
            --- SINH TAI KHOAN AFMAST
            INSERT INTO AFMAST (ACTYPE,CUSTID,ACCTNO,AFTYPE,
            BANKACCTNO,BANKNAME,STATUS,lastdate,bratio,k1days,k2days,
            ADVANCELINE,DESCRIPTION,ISOTC,PISOTC,OPNDATE,VIA,producttype,
            MRIRATE,MRMRATE,MRLRATE,MRCRLIMIT,MRCRLIMITMAX,
            mriratio,mrmratio,mrlratio,mrcrate,mrwrate,mrexrate,
            T0AMT,BRID,CAREBY,corebank,AUTOADV,TLID,TERMOFUSE,isdebtt0,isPM)
            VALUES(rec.actype,l_custid,l_afacctno,l_aftype, '' ,'---', 'A',TO_DATE( v_busdate ,'DD/MM/RRRR'),100,rec.k1days,rec.k2days,
            0,'','Y','N',TO_DATE( v_busdate ,'DD/MM/RRRR'),'F',rec.producttype,
            rec.MRIRATE,rec.MRMRATE,rec.MRLRATE,rec.MRCRLIMIT,rec.MRLMMAX,
            rec.mriratio,rec.mrmratio,rec.mrlratio,rec.mrcrate,rec.mrwrate,rec.mrexrate,
            0,rec.brid, rec.careby,l_corebank,l_AUTOADV, rec.tlid,'001','N',l_isPM);




            -- INSERT VAO MAINTAIN_LOG AFMAST
            INSERT INTO maintain_log (TABLE_NAME,RECORD_KEY,MAKER_ID,MAKER_DT,APPROVE_RQD,APPROVE_ID,
            APPROVE_DT,MOD_NUM,COLUMN_NAME,FROM_VALUE,TO_VALUE,ACTION_FLAG,CHILD_TABLE_NAME,CHILD_RECORD_KEY,MAKER_TIME,APPROVE_TIME)
            VALUES('CFMAST','CUSTID = ''' || l_custid ||  '''',p_tlid,TO_DATE( v_busdate ,'DD/MM/RRRR'),'Y',p_apptlid,
            TO_DATE( v_busdate ,'DD/MM/RRRR'),0,'ACTYPE',NULL,rec.aftype,'ADD','AFMAST','ACCTNO = ''' || l_afacctno || '''',to_char(sysdate,'hh24:mi:ss'),to_char(sysdate,'hh24:mi:ss'));


            INSERT INTO maintain_log (TABLE_NAME,RECORD_KEY,MAKER_ID,MAKER_DT,APPROVE_RQD,APPROVE_ID,
            APPROVE_DT,MOD_NUM,COLUMN_NAME,FROM_VALUE,TO_VALUE,ACTION_FLAG,CHILD_TABLE_NAME,CHILD_RECORD_KEY,MAKER_TIME,APPROVE_TIME)
            VALUES('CFMAST','CUSTID = ''' || l_custid ||  '''',p_tlid,TO_DATE( v_busdate ,'DD/MM/RRRR'),'Y',p_apptlid,
            TO_DATE( v_busdate ,'DD/MM/RRRR'),0,'CUSTID',NULL,l_custid,'ADD','AFMAST','ACCTNO = ''' || l_afacctno || '''',to_char(sysdate,'hh24:mi:ss'),to_char(sysdate,'hh24:mi:ss'));

            INSERT INTO maintain_log (TABLE_NAME,RECORD_KEY,MAKER_ID,MAKER_DT,APPROVE_RQD,APPROVE_ID,
            APPROVE_DT,MOD_NUM,COLUMN_NAME,FROM_VALUE,TO_VALUE,ACTION_FLAG,CHILD_TABLE_NAME,CHILD_RECORD_KEY,MAKER_TIME,APPROVE_TIME)
            VALUES('CFMAST','CUSTID = ''' || l_custid ||  '''',p_tlid,TO_DATE( v_busdate ,'DD/MM/RRRR'),'Y',p_apptlid,
            TO_DATE( v_busdate ,'DD/MM/RRRR'),0,'ACCTNO',NULL,l_afacctno,'ADD','AFMAST','ACCTNO = ''' || l_afacctno || '''',to_char(sysdate,'hh24:mi:ss'),to_char(sysdate,'hh24:mi:ss'));

            INSERT INTO maintain_log (TABLE_NAME,RECORD_KEY,MAKER_ID,MAKER_DT,APPROVE_RQD,APPROVE_ID,
            APPROVE_DT,MOD_NUM,COLUMN_NAME,FROM_VALUE,TO_VALUE,ACTION_FLAG,CHILD_TABLE_NAME,CHILD_RECORD_KEY,MAKER_TIME,APPROVE_TIME)
            VALUES('CFMAST','CUSTID = ''' || l_custid ||  '''',p_tlid,TO_DATE( v_busdate ,'DD/MM/RRRR'),'Y',p_apptlid,
            TO_DATE( v_busdate ,'DD/MM/RRRR'),0,'CIACCTNO',NULL,l_afacctno,'ADD','AFMAST','ACCTNO = ''' || l_afacctno || '''',to_char(sysdate,'hh24:mi:ss'),to_char(sysdate,'hh24:mi:ss'));

            INSERT INTO maintain_log (TABLE_NAME,RECORD_KEY,MAKER_ID,MAKER_DT,APPROVE_RQD,APPROVE_ID,
            APPROVE_DT,MOD_NUM,COLUMN_NAME,FROM_VALUE,TO_VALUE,ACTION_FLAG,CHILD_TABLE_NAME,CHILD_RECORD_KEY,MAKER_TIME,APPROVE_TIME)
            VALUES('CFMAST','CUSTID = ''' || l_custid ||  '''',p_tlid,TO_DATE( v_busdate ,'DD/MM/RRRR'),'Y',p_apptlid,
            TO_DATE( v_busdate ,'DD/MM/RRRR'),0,'AFTYPE',NULL,l_aftype,'ADD','AFMAST','ACCTNO = ''' || l_afacctno || '''',to_char(sysdate,'hh24:mi:ss'),to_char(sysdate,'hh24:mi:ss'));

            INSERT INTO maintain_log (TABLE_NAME,RECORD_KEY,MAKER_ID,MAKER_DT,APPROVE_RQD,APPROVE_ID,
            APPROVE_DT,MOD_NUM,COLUMN_NAME,FROM_VALUE,TO_VALUE,ACTION_FLAG,CHILD_TABLE_NAME,CHILD_RECORD_KEY,MAKER_TIME,APPROVE_TIME)
            VALUES('CFMAST','CUSTID = ''' || l_custid ||  '''',p_tlid,TO_DATE( v_busdate ,'DD/MM/RRRR'),'Y',p_apptlid,
            TO_DATE( v_busdate ,'DD/MM/RRRR'),0,'TRADEFLOOR',NULL,'Y','ADD','AFMAST','ACCTNO = ''' || l_afacctno || '''',to_char(sysdate,'hh24:mi:ss'),to_char(sysdate,'hh24:mi:ss'));


            l_citype:=rec.citype;

           -- Sinh tai khoan CI
           INSERT INTO CIMAST (ACTYPE,ACCTNO,CCYCD,AFACCTNO,CUSTID,OPNDATE,CLSDATE,LASTDATE,DORMDATE,STATUS,PSTATUS,BALANCE,CRAMT,DRAMT,CRINTACR,CRINTDT,ODINTACR,ODINTDT,AVRBAL,MDEBIT,MCREDIT,AAMT,RAMT,BAMT,EMKAMT,MMARGINBAL,MARGINBAL,ICCFCD,ICCFTIED,ODLIMIT,ADINTACR,ADINTDT,FACRTRADE,FACRDEPOSITORY,FACRMISC,MINBAL,ODAMT,NAMT,FLOATAMT,HOLDBALANCE,PENDINGHOLD,PENDINGUNHOLD,COREBANK,RECEIVING,NETTING,MBLOCK,OVAMT,DUEAMT,T0ODAMT,MBALANCE,MCRINTDT,TRFAMT,LAST_CHANGE,DFODAMT,DFDEBTAMT,DFINTDEBTAMT,CIDEPOFEEACR,DEPOLASTDT)
           VALUES(l_citype,l_afacctno,'00',l_afacctno,l_custid,TO_DATE(v_busdate,'DD/MM/RRRR'),NULL,TO_DATE(v_busdate,'DD/MM/RRRR'),NULL,'A',NULL,l_balance,0,0,0,TO_DATE(v_busdate,'DD/MM/RRRR'),0,TO_DATE(v_busdate,'DD/MM/RRRR'),0,0,0,0,0,0,0,0,0,NULL,'Y',0,0,NULL,0,0,0,0,0,0,0,0,0,0,l_corebank,0,0,0,0,0,0,0,TO_DATE(v_busdate,'DD/MM/RRRR'),0,TO_DATE(v_busdate,'DD/MM/RRRR'),0,0,0,0,( select last_day(trunc(to_date(v_busdate,'DD/MM/RRRR'),'MM')-1)  from dual ));



         end if; ---- Kiem tra truong hop da co CFMAST nhung chua co AFMAST thi moi sinh
    end loop;
    p_err_code:='0';
    plog.setendsection(pkgctx, 'pr_ChangeCFType');
EXCEPTION
   WHEN others THEN
   plog.error (pkgctx, SQLERRM || dbms_utility.format_error_backtrace);
   plog.setendsection (pkgctx, 'pr_ChangeCFType');
   p_err_code:='-1';
   return;
END;

PROCEDURE pr_AutoOpenMQAccount(p_CUSTID in varchar2,p_FirstTime in varchar2,p_err_code in out varchar2)
IS
    v_currdate date;
    v_count number;
    l_corebank  char(1);
    l_autoadv   char(1);

    l_aftype varchar2(10);
    l_custid varchar2(20);
    l_afacctno varchar2(20);
    v_busdate   varchar2(20);
    p_tlid varchar2(20);
    p_apptlid varchar2(20);
    l_citype  varchar2(20);

    l_balance number;
    l_isPM varchar2(1);
BEGIN
    plog.setbeginsection(pkgctx, 'pr_ChangeCFType');
    p_err_code:= '0';
    select varvalue into v_busdate from sysvar where grname ='SYSTEM' and varname ='CURRDATE';

    --------------------------- dang ky tu dong cac mau email.sms default = 'Y'
 IF p_FirstTime ='Y' THEN
                        FOR rec IN
                        (
                                SELECT code FROM templates WHERE require_register = 'Y' AND isdefault = 'Y'
                                AND code NOT IN (SELECT template_code FROM aftemplates WHERE custid = p_custid)
                        )
                        LOOP
                                INSERT INTO aftemplates (autoid,custid,template_code)
                                VALUES (seq_aftemplates.nextval, p_custid, rec.code);
                        END LOOP;
     END IF;
        -----------------------------------------------------------------------------------------------------------------------------
    --Lay ra danh sach loai hinh tieu khoan thuong can Mo
   /* select count(1) into v_count from afmast af, aftype aft, mrtype mrt
    where custid =p_CUSTID and af.actype = aft.actype and aft.mrtype = mrt.actype and mrt.mrtype <>'T';
    if v_count>0 then
        p_err_code:='0';
        return;
    end if;
    select count(1) into v_count from cfmast where custid =p_CUSTID and length(nvl(custodycd,'XX')) <> 10;
    if v_count>0 then
        p_err_code:='0';
        return;
    end if;*/
    --Neu chua co tieu khoan thi mo moi
    for rec in (
         select aft.actype, aft.AFTYPE,aft.corebank,aft.autoadv,aft.citype,aft.k1days,aft.k2days,
                aft.producttype, substr(cf.custodycd,4,1) custype,
                cf.brid,cf.careby,cf.tlid,
                mrt.MRIRATE,mrt.MRMRATE,mrt.MRLRATE,mrt.MRCRLIMIT,
                mrt.MRLMMAX,mrt.mriratio,mrt.mrmratio,mrt.mrlratio,mrt.mrcrate,mrt.mrwrate,mrt.mrexrate,
                nvl(cf.last_ofid,nvl(cf.approveid,cf.tlid)) appid,aft.MRCRLIMITMAX
         from cfmast cf, cfaftype cfaf , aftype aft, mrtype mrt
         where cf.actype = cfaf.cftype and cfaf.aftype = aft.actype
             and aft.mrtype = mrt.actype and mrt.mrtype ='T'
             AND aft.producttype='QM'
             and cf.custid =p_CUSTID

    )
    loop
        ---- Kiem tra truong hop da co CFMAST nhung chua co AFMAST thi moi sinh
         select count(1) into v_count from afmast where custid =p_CUSTID and actype = rec.actype;

         if v_count =0 then
             l_aftype:=rec.AFTYPE;
             l_corebank:=rec.corebank;
             l_autoadv:=rec.autoadv;
             ---l_autoadv := 'N';
             l_custid:=p_CUSTID;
             p_tlid:=rec.tlid;
            p_apptlid := rec.appid;
            if rec.custype = 'P' then
                l_balance:= 1000000000000;
                l_isPM:= 'Y';
            else
                l_balance:=0;
                l_isPM:='N';
            end if;
             ---- SINH SO AFMAST
             begin
             SELECT SUBSTR(INVACCT,1,4) || TRIM(TO_CHAR(MAX(ODR)+1,'000000')) into l_afacctno FROM
             (SELECT ROWNUM ODR, INVACCT
             FROM (SELECT ACCTNO INVACCT FROM AFMAST WHERE SUBSTR(ACCTNO,1,4)= trim(rec.brid) ORDER BY ACCTNO) DAT
             WHERE TO_NUMBER(SUBSTR(INVACCT,5,6))=ROWNUM) INVTAB
             GROUP BY SUBSTR(INVACCT,1,4);
             exception when others then
                l_afacctno :=trim(rec.brid) || '000001';
             end;
            --- SINH TAI KHOAN AFMAST
            INSERT INTO AFMAST (ACTYPE,CUSTID,ACCTNO,AFTYPE,
            BANKACCTNO,BANKNAME,STATUS,lastdate,bratio,k1days,k2days,
            ADVANCELINE,DESCRIPTION,ISOTC,PISOTC,OPNDATE,VIA,producttype,
            MRIRATE,MRMRATE,MRLRATE,MRCRLIMIT,MRCRLIMITMAX,
            mriratio,mrmratio,mrlratio,mrcrate,mrwrate,mrexrate,
            T0AMT,BRID,CAREBY,corebank,AUTOADV,TLID,TERMOFUSE,isdebtt0,isPM)
            VALUES(rec.actype,l_custid,l_afacctno,l_aftype, '' ,'---', 'A',TO_DATE( v_busdate ,'DD/MM/RRRR'),100,rec.k1days,rec.k2days,
            0,'','Y','N',TO_DATE( v_busdate ,'DD/MM/RRRR'),'F',rec.producttype,
            rec.MRIRATE,rec.MRMRATE,rec.MRLRATE,rec.MRCRLIMIT,rec.MRCRLIMITMAX,
            rec.mriratio,rec.mrmratio,rec.mrlratio,rec.mrcrate,rec.mrwrate,rec.mrexrate,
            0,rec.brid, rec.careby,l_corebank,l_AUTOADV, rec.tlid,'001','N',l_isPM);




            -- INSERT VAO MAINTAIN_LOG AFMAST
            INSERT INTO maintain_log (TABLE_NAME,RECORD_KEY,MAKER_ID,MAKER_DT,APPROVE_RQD,APPROVE_ID,
            APPROVE_DT,MOD_NUM,COLUMN_NAME,FROM_VALUE,TO_VALUE,ACTION_FLAG,CHILD_TABLE_NAME,CHILD_RECORD_KEY,MAKER_TIME,APPROVE_TIME)
            VALUES('CFMAST','CUSTID = ''' || l_custid ||  '''',p_tlid,TO_DATE( v_busdate ,'DD/MM/RRRR'),'Y',p_apptlid,
            TO_DATE( v_busdate ,'DD/MM/RRRR'),0,'ACTYPE',NULL,rec.aftype,'ADD','AFMAST','ACCTNO = ''' || l_afacctno || '''',to_char(sysdate,'hh24:mi:ss'),to_char(sysdate,'hh24:mi:ss'));


            INSERT INTO maintain_log (TABLE_NAME,RECORD_KEY,MAKER_ID,MAKER_DT,APPROVE_RQD,APPROVE_ID,
            APPROVE_DT,MOD_NUM,COLUMN_NAME,FROM_VALUE,TO_VALUE,ACTION_FLAG,CHILD_TABLE_NAME,CHILD_RECORD_KEY,MAKER_TIME,APPROVE_TIME)
            VALUES('CFMAST','CUSTID = ''' || l_custid ||  '''',p_tlid,TO_DATE( v_busdate ,'DD/MM/RRRR'),'Y',p_apptlid,
            TO_DATE( v_busdate ,'DD/MM/RRRR'),0,'CUSTID',NULL,l_custid,'ADD','AFMAST','ACCTNO = ''' || l_afacctno || '''',to_char(sysdate,'hh24:mi:ss'),to_char(sysdate,'hh24:mi:ss'));

            INSERT INTO maintain_log (TABLE_NAME,RECORD_KEY,MAKER_ID,MAKER_DT,APPROVE_RQD,APPROVE_ID,
            APPROVE_DT,MOD_NUM,COLUMN_NAME,FROM_VALUE,TO_VALUE,ACTION_FLAG,CHILD_TABLE_NAME,CHILD_RECORD_KEY,MAKER_TIME,APPROVE_TIME)
            VALUES('CFMAST','CUSTID = ''' || l_custid ||  '''',p_tlid,TO_DATE( v_busdate ,'DD/MM/RRRR'),'Y',p_apptlid,
            TO_DATE( v_busdate ,'DD/MM/RRRR'),0,'ACCTNO',NULL,l_afacctno,'ADD','AFMAST','ACCTNO = ''' || l_afacctno || '''',to_char(sysdate,'hh24:mi:ss'),to_char(sysdate,'hh24:mi:ss'));

            INSERT INTO maintain_log (TABLE_NAME,RECORD_KEY,MAKER_ID,MAKER_DT,APPROVE_RQD,APPROVE_ID,
            APPROVE_DT,MOD_NUM,COLUMN_NAME,FROM_VALUE,TO_VALUE,ACTION_FLAG,CHILD_TABLE_NAME,CHILD_RECORD_KEY,MAKER_TIME,APPROVE_TIME)
            VALUES('CFMAST','CUSTID = ''' || l_custid ||  '''',p_tlid,TO_DATE( v_busdate ,'DD/MM/RRRR'),'Y',p_apptlid,
            TO_DATE( v_busdate ,'DD/MM/RRRR'),0,'CIACCTNO',NULL,l_afacctno,'ADD','AFMAST','ACCTNO = ''' || l_afacctno || '''',to_char(sysdate,'hh24:mi:ss'),to_char(sysdate,'hh24:mi:ss'));

            INSERT INTO maintain_log (TABLE_NAME,RECORD_KEY,MAKER_ID,MAKER_DT,APPROVE_RQD,APPROVE_ID,
            APPROVE_DT,MOD_NUM,COLUMN_NAME,FROM_VALUE,TO_VALUE,ACTION_FLAG,CHILD_TABLE_NAME,CHILD_RECORD_KEY,MAKER_TIME,APPROVE_TIME)
            VALUES('CFMAST','CUSTID = ''' || l_custid ||  '''',p_tlid,TO_DATE( v_busdate ,'DD/MM/RRRR'),'Y',p_apptlid,
            TO_DATE( v_busdate ,'DD/MM/RRRR'),0,'AFTYPE',NULL,l_aftype,'ADD','AFMAST','ACCTNO = ''' || l_afacctno || '''',to_char(sysdate,'hh24:mi:ss'),to_char(sysdate,'hh24:mi:ss'));

            INSERT INTO maintain_log (TABLE_NAME,RECORD_KEY,MAKER_ID,MAKER_DT,APPROVE_RQD,APPROVE_ID,
            APPROVE_DT,MOD_NUM,COLUMN_NAME,FROM_VALUE,TO_VALUE,ACTION_FLAG,CHILD_TABLE_NAME,CHILD_RECORD_KEY,MAKER_TIME,APPROVE_TIME)
            VALUES('CFMAST','CUSTID = ''' || l_custid ||  '''',p_tlid,TO_DATE( v_busdate ,'DD/MM/RRRR'),'Y',p_apptlid,
            TO_DATE( v_busdate ,'DD/MM/RRRR'),0,'TRADEFLOOR',NULL,'Y','ADD','AFMAST','ACCTNO = ''' || l_afacctno || '''',to_char(sysdate,'hh24:mi:ss'),to_char(sysdate,'hh24:mi:ss'));


            l_citype:=rec.citype;

           -- Sinh tai khoan CI
           INSERT INTO CIMAST (ACTYPE,ACCTNO,CCYCD,AFACCTNO,CUSTID,OPNDATE,CLSDATE,LASTDATE,DORMDATE,STATUS,PSTATUS,BALANCE,CRAMT,DRAMT,CRINTACR,CRINTDT,ODINTACR,ODINTDT,AVRBAL,MDEBIT,MCREDIT,AAMT,RAMT,BAMT,EMKAMT,MMARGINBAL,MARGINBAL,ICCFCD,ICCFTIED,ODLIMIT,ADINTACR,ADINTDT,FACRTRADE,FACRDEPOSITORY,FACRMISC,MINBAL,ODAMT,NAMT,FLOATAMT,HOLDBALANCE,PENDINGHOLD,PENDINGUNHOLD,COREBANK,RECEIVING,NETTING,MBLOCK,OVAMT,DUEAMT,T0ODAMT,MBALANCE,MCRINTDT,TRFAMT,LAST_CHANGE,DFODAMT,DFDEBTAMT,DFINTDEBTAMT,CIDEPOFEEACR,DEPOLASTDT)
           VALUES(l_citype,l_afacctno,'00',l_afacctno,l_custid,TO_DATE(v_busdate,'DD/MM/RRRR'),NULL,TO_DATE(v_busdate,'DD/MM/RRRR'),NULL,'A',NULL,l_balance,0,0,0,TO_DATE(v_busdate,'DD/MM/RRRR'),0,TO_DATE(v_busdate,'DD/MM/RRRR'),0,0,0,0,0,0,0,0,0,NULL,'Y',0,0,NULL,0,0,0,0,0,0,0,0,0,0,l_corebank,0,0,0,0,0,0,0,TO_DATE(v_busdate,'DD/MM/RRRR'),0,TO_DATE(v_busdate,'DD/MM/RRRR'),0,0,0,0,( select last_day(trunc(to_date(v_busdate,'DD/MM/RRRR'),'MM')-1)  from dual ));



         end if; ---- Kiem tra truong hop da co CFMAST nhung chua co AFMAST thi moi sinh
    end loop;
    p_err_code:='0';
    plog.setendsection(pkgctx, 'pr_ChangeCFType');
EXCEPTION
   WHEN others THEN
   plog.error (pkgctx, SQLERRM || dbms_utility.format_error_backtrace);
   plog.setendsection (pkgctx, 'pr_ChangeCFType');
   p_err_code:='-1';
   return;
END;

--HSX04: them domain mac dinh
PROCEDURE pr_AutoAddDomain(p_CUSTID in varchar2, p_err_code in out varchar2)
IS
BEGIN
   plog.setbeginsection(pkgctx, 'pr_AutoAddDomain');
   plog.error('DOMAIN:'||p_CUSTID);

       insert into cfdomain(autoid, custid, domaincode)
       select seq_cfdomain.nextval,p_CUSTID,domaincode
        from domain
        where isdefault = 'Y'
        and domaincode not in ( select domaincode from cfdomain where custid=p_CUSTID);

   p_err_code := '0';
   plog.setendsection(pkgctx, 'pr_AutoAddDomain');
EXCEPTION
   WHEN others THEN
   plog.error (pkgctx, SQLERRM || dbms_utility.format_error_backtrace);
   plog.setendsection (pkgctx, 'pr_AutoAddDomain');
   p_err_code:='-1';
   return;
END pr_AutoAddDomain;

-- initial LOG
BEGIN
   SELECT *
   INTO logrow
   FROM tlogdebug
   WHERE ROWNUM <= 1;

   pkgctx    :=
      plog.init ('cspks_cfproc',
                 plevel => logrow.loglevel,
                 plogtable => (logrow.log4table = 'Y'),
                 palert => (logrow.log4alert = 'Y'),
                 ptrace => (logrow.log4trace = 'Y')
      );
END;
/
