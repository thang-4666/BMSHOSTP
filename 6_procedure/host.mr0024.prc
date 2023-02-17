SET DEFINE OFF;
CREATE OR REPLACE PROCEDURE "MR0024" (
   PV_REFCURSOR   IN OUT   PKG_REPORT.REF_CURSOR,
   pv_OPT         IN       VARCHAR2,
   pv_BRID        IN       VARCHAR2,
   TLGOUPS        IN       VARCHAR2,
   TLSCOPE        IN       VARCHAR2,
   F_DATE         IN       VARCHAR2,
   T_DATE         IN       VARCHAR2,
   P_ACTYPE       IN       VARCHAR2
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



   V_FROM_DATE      DATE;
   V_TO_DATE        DATE;
   V_STRACTYPE      VARCHAR2(10);

-- DECLARE PROGRAM VARIABLES AS SHOWN ABOVE

BEGIN

   V_STROPTION := upper(pv_OPT);
   V_INBRID := pv_BRID;

 -- END OF GETTING REPORT'S PARAMETERS


    V_FROM_DATE := TO_DATE(F_DATE,'DD/MM/RRRR');
    V_TO_DATE   := TO_DATE(T_DATE,'DD/MM/RRRR');

    IF (P_ACTYPE IS NULL OR UPPER(P_ACTYPE) = 'ALL') THEN
        V_STRACTYPE := '%';
    ELSE
        V_STRACTYPE := P_ACTYPE;
    END IF;

   ----
-- GET REPORT'S DATA
OPEN PV_REFCURSOR FOR
    select cf.fullname, cf.custodycd, af.acctno afacctno, aft.mnemonic, ls.rlsdate, LS.duedate, ls.overduedate, LG.PAIDDATE,
            MAX(ls.nml) - SUM(nvl(lg.nml,0)) lnprin,
            MAX(ls.ovd) - SUM(nvl(lg.ovd,0)) lnprovd,
            ln.acctno lnacctno, nvl(LG.PAIDDATE,V_TO_DATE)-ls.overduedate NDATE
        from vw_lnmast_all ln, (SELECT * FROM CFMAST WHERE FNC_VALIDATE_SCOPE(BRID, CAREBY, TLSCOPE, pv_BRID, TLGOUPS)=0) cf, afmast af,aftype aft,
        vw_lnschd_all ls
        LEFT JOIN
            (
                select autoid, sum(nml) nml, sum(ovd) ovd, sum(paid) paid,
                    sum(intnmlacr) intnmlacr, sum(intdue) intdue, sum(intovd) intovd, sum(intovdprin) intovdprin,
                    sum(feeintnmlacr) feeintnmlacr, sum(feeintdue) feeintdue, sum(feeintovd) feeintnmlovd,
                    sum(feeintovdprin) feeintovdacr, sum(feeovd) feeovd,
                    MAX(CASE WHEN LG.lastpaid = 'Y' THEN LG.txdate ELSE V_TO_DATE END) PAIDDATE,
                    txdate
                from (select * from lnschdlog union all select * from lnschdloghist) lg
                ---- where lg.txdate > V_TO_DATE
                group by autoid, TXDATE
            ) lg
        ON ls.autoid = lg.autoid AND LG.TXDATE > LS.overduedate
        where ln.acctno = ls.acctno and instr(ls.reftype,'P') <> 0
            and ln.trfacctno = af.acctno and af.custid = cf.custid
----            and
            and af.actype = aft.actype and ln.ftype = 'AF'
----            AND LG.
            and aft.mnemonic LIKE V_STRACTYPE
            and ls.rlsdate <= V_TO_DATE
            AND LS.overduedate >= V_FROM_DATE
            AND LS.overduedate <= V_TO_DATE
            AND ls.ovd - nvl(lg.ovd,0) <> 0
        GROUP BY cf.fullname, cf.custodycd, af.acctno , aft.mnemonic, ls.rlsdate, LS.duedate, ls.overduedate, LG.PAIDDATE,
            ln.acctno, LG.PAIDDATE-ls.overduedate
    ;
 EXCEPTION
   WHEN OTHERS
   THEN
        RETURN;
END;

 
 
 
 
/
