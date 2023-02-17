SET DEFINE OFF;
CREATE OR REPLACE PROCEDURE "MR0023" (
   PV_REFCURSOR   IN OUT   PKG_REPORT.REF_CURSOR,
   pv_OPT         IN       VARCHAR2,
   pv_BRID        IN       VARCHAR2,
   TLGOUPS        IN       VARCHAR2,
   TLSCOPE        IN       VARCHAR2,
   F_DATE         IN       VARCHAR2,
   T_DATE         IN       VARCHAR2,
   PV_CUSTODYCD   IN       VARCHAR2,
   I_BRID         IN       VARCHAR2
)
IS
--
-- PURPOSE: BRIEFLY EXPLAIN THE FUNCTIONALITY OF THE PROCEDURE
--
-- MODIFICATION HISTORY
-- PERSON      DATE    COMMENTS
-- LINHLNB   11-Apr-2012  CREATED

-- ---------   ------  -------------------------------------------
   l_STROPTION        VARCHAR2 (5);       -- A: ALL; B: BRANCH; S: SUB-BRANCH
   l_STRBRID          VARCHAR2 (4);

   V_IDATE           DATE; --ngay lam viec gan ngay indate nhat
   v_CurrDate        DATE;
   V_INBRID         VARCHAR2(4);
   V_STRBRID        VARCHAR2 (50);
   V_STROPTION      VARCHAR2(10);

   v_strcustodycd   VARCHAR2(20);
   v_BRID           VARCHAR2(20);
   v_strAFTYPE      VARCHAR2(20);
   V_FROM_DATE      DATE;
   V_TO_DATE        DATE;
   V_STRTLTXTYPE    VARCHAR2(20);

   v_strbrname      VARCHAR2(100);
   V_STRTK          VARCHAR2(50);

-- DECLARE PROGRAM VARIABLES AS SHOWN ABOVE

BEGIN

   V_STROPTION := upper(pv_OPT);
   V_INBRID := pv_BRID;

 -- END OF GETTING REPORT'S PARAMETERS


    if(upper(PV_CUSTODYCD) = 'ALL' or PV_CUSTODYCD is null) then
        v_strcustodycd := '%';
        V_STRTK := 'ALL';
    else
        v_strcustodycd := UPPER(PV_CUSTODYCD);
        V_STRTK := v_strcustodycd;
    end if ;
    if(upper(I_BRID) = 'ALL' or I_BRID is null) then
        v_BRID := '%';
        v_strbrname := 'ALL';
    else
        v_BRID := UPPER(I_BRID);
        SELECT MAX(brname) INTO v_strbrname FROM brgrp WHERE brid = v_BRID;
    end if ;
    V_FROM_DATE := TO_DATE(F_DATE,'DD/MM/RRRR');
    V_TO_DATE   := TO_DATE(T_DATE,'DD/MM/RRRR');
---    SELECT max(sbdate) V_IDATE V_FDATE  FROM sbcurrdate WHERE sbtype ='B' AND sbdate <= to_date(F_DATE,'DD/MM/RRRR');
---   SELECT max(sbdate) INTO v_TDATE  FROM sbcurrdate WHERE sbtype ='B' AND sbdate <= to_date(T_DATE,'DD/MM/RRRR');
----   select to_date(varvalue,'DD/MM/RRRR') into v_CurrDate from sysvar where varname = 'CURRDATE' and grname = 'SYSTEM';

   ----
-- GET REPORT'S DATA
OPEN PV_REFCURSOR FOR

    SELECT v_strbrname BRNAME, V_STRTK STRTK, custodycd || afacctno || to_char(txdate,'YYYYDDD') txkey,
        brid, custodycd, fullname, afacctno, actype, typename, txdate, cleardate, odamt,
        trfacctno, nvl(orgamt,0) orgamt, rlsdate
    FROM
    (
            select af.brid, cf.custodycd, cf.fullname fullname, af.acctno afacctno,
                aft.actype actype, aft.typename typename,
                od.txdate,od.cleardate ,od.odamt,
                LNM.trfacctno, od.odamt - (LNM.ovd+lnm.nml) orgamt, LNM.txdate rlsdate
            from (SELECT * FROM CFMAST WHERE FNC_VALIDATE_SCOPE(BRID, CAREBY, TLSCOPE, pv_BRID, TLGOUPS)=0) cf, afmast af, aftype aft, mrtype mrt,
            (
                select od.afacctno, od.txdate,
                    fn_get_nextdate(od.txdate, od.clearday+1) cleardate,
                    sum(od.matchamt+od.feeacr) odamt
                from afmast af, aftype aft, vw_odmast_all od
                where af.acctno = od.afacctno and af.actype = aft.actype
                    and od.exectype in ('NB')
                    and aft.istrfbuy = 'Y' and od.deltd <> 'Y' and od.matchamt <> 0
                    AND OD.TXDATE >= V_FROM_DATE AND OD.TXDATE <= V_TO_DATE
                group by od.afacctno, od.txdate,
                    fn_get_nextdate(od.txdate, od.clearday+1)
            ) od
            LEFT JOIN
            (
                SELECT LNS.autoid, lnm.trfacctno, lns.rlsdate,  lg.txdate , lnm.acctno,
                    SUM(LG.nml) nml, SUM(LG.ovd) ovd
                FROM vw_lnschd_all lns, vw_lnmast_all lnm, vw_lnschdlog_all  LG
                WHERE lnm.ftype = 'AF' and lns.acctno = lnm.acctno
                    and lns.reftype in ('GI','GP') AND LNS.autoid = LG.autoid
                    AND LNS.rlsdate = LG.txdate
                GROUP BY LNS.autoid, lnm.trfacctno, lg.txdate, lnm.acctno, lns.rlsdate
            ) LNM
            ON od.afacctno = LNM.trfacctno and od.cleardate = lnm.rlsdate
            where cf.custid = af.custid and af.actype = aft.actype
                and aft.mrtype = mrt.actype and aft.istrfbuy = 'Y' and mrt.mrtype = 'T'
                and af.acctno = od.afacctno  AND CF.CUSTODYCD LIKE v_strcustodycd
                AND af.brid LIKE v_BRID
        UNION ALL
            select af.brid, cf.custodycd, cf.fullname fullname, af.acctno afacctno,
                aft.actype actype, aft.typename typename,
                od.txdate,od.cleardate ,od.odamt,
                LNM.trfacctno, LNM.paid orgamt, LNM.txdate rlsdate
            from cfmast cf, afmast af, aftype aft, mrtype mrt,
            (
                select od.afacctno, od.txdate,
                    fn_get_nextdate(od.txdate, od.clearday+1) cleardate,
                    sum(od.matchamt+od.feeacr) odamt
                from afmast af, aftype aft, vw_odmast_all od
                where af.acctno = od.afacctno and af.actype = aft.actype
                    and od.exectype in ('NB')
                    and aft.istrfbuy = 'Y' and od.deltd <> 'Y' and od.matchamt <> 0
                    AND OD.TXDATE >= V_FROM_DATE AND OD.TXDATE <= V_TO_DATE
                group by od.afacctno, od.txdate,
                    fn_get_nextdate(od.txdate, od.clearday+1)
            ) od
            inner JOIN
            (
                SELECT LNS.AUTOID, lnm.trfacctno,lns.rlsdate, lnL.TXDATE, lnm.acctno ,
                    sum(lns.ovd) ovd, sum(lns.nml) nml, sum(LNL.paid) paid
                FROM vw_lnschd_all lns, vw_lnmast_all lnm,
                    vw_lnschdlog_all LNL
                WHERE lnm.ftype = 'AF' and lns.acctno = lnm.acctno
                    and lns.reftype in ('GI','GP')
                    AND paiddate IS NOT NULL AND LNS.autoid = LNL.autoid
                    AND LNL.paid <> 0 AND LNL.deltd <> 'Y'
                group by lnm.trfacctno, lnL.TXDATE, lnm.acctno, LNS.AUTOID, lns.rlsdate
            ) LNM
            ON od.afacctno = LNM.trfacctno and od.cleardate = lnm.rlsdate
            where cf.custid = af.custid and af.actype = aft.actype
                and aft.mrtype = mrt.actype and aft.istrfbuy = 'Y' and mrt.mrtype = 'T'
                and af.acctno = od.afacctno AND CF.CUSTODYCD LIKE v_strcustodycd
                AND af.brid LIKE v_BRID
    )
    ORDER BY custodycd, afacctno, txdate, rlsdate
    ;
 EXCEPTION
   WHEN OTHERS
   THEN
        RETURN;
END;

 
 
 
 
/
