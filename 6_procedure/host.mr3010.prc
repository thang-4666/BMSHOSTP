SET DEFINE OFF;
CREATE OR REPLACE PROCEDURE "MR3010" (
   PV_REFCURSOR           IN OUT   PKG_REPORT.REF_CURSOR,
   p_OPT                    IN       VARCHAR2,
   pv_BRID                   IN       VARCHAR2,
   TLGOUPS        IN       VARCHAR2,
   TLSCOPE        IN       VARCHAR2,
   PV_MON_DATE                 IN       VARCHAR2,
   TLID            IN       VARCHAR2
  )
IS

--
-- BAO CAO DANH MUC CHUNG KHOAN THUC HIEN GIAO DICH KI QUY
-- MODIFICATION HISTORY
-- PERSON       DATE                COMMENTS
-- ---------   ------  -------------------------------------------
-- QUOCTA      17-02-2012           CREATED
--

   CUR                      PKG_REPORT.REF_CURSOR;
l_OPT varchar2(10);
l_BRID varchar2(1000);
l_BRID_FILTER varchar2(1000);
   l_PrevFromDate               DATE;
   l_FromDate               DATE;
   l_ToDate                 DATE;
   l_CurrDate               DATE;

   l_COUNTMRACC_BG          NUMBER(20,0);
   l_COUNTMRACC_END         NUMBER(20,0);
   l_MAXDEBT_BG                NUMBER(20,0);
   l_MAXDEBT_END                NUMBER(20,0);

   l_ODAMT_BG               NUMBER(20,0);
   l_ODAMT_END              NUMBER(20,0);

   l_SEREALASS_BG              NUMBER(20,0);
   l_SEREALASS_END              NUMBER(20,0);

   l_INTAMT_BG              NUMBER(20,0);
   l_INTAMT_END             NUMBER(20,0);

   l_FEEAMT_BG              NUMBER(20,0);
   l_FEEAMT_END             NUMBER(20,0);

   l_TOP5SYMBOL_BG             varchar2(30);
   l_TOP5SYMBOL_END             varchar2(30);
   V_STRTLID           VARCHAR2(6);


BEGIN

    V_STRTLID:= TLID;
    l_OPT:=p_OPT;

    IF (l_OPT = 'A') THEN
      l_BRID_FILTER := '%';
    ELSE if (l_OPT = 'B') then
            select brgrp.mapid into l_BRID_FILTER from brgrp where brgrp.brid = pv_BRID;
        else
            l_BRID_FILTER := pv_BRID;
        end if;
    END IF;

    -- Lay ngay cuoi ki.
    select max(sbdate)
    into l_ToDate
    from sbcldr where cldrtype = '000' and trunc(sbdate,'MM') = to_date('01' || substr(PV_MON_DATE,3), SYSTEMNUMS.C_DATE_FORMAT);

    -- Lay ngay dau ki.
    l_FromDate:= trunc(to_date(l_ToDate,SYSTEMNUMS.C_DATE_FORMAT),'MM');

    --- LAY NGAY HE THONG
    SELECT TO_DATE(VARVALUE, SYSTEMNUMS.C_DATE_FORMAT)
    INTO   l_CurrDate
    FROM   SYSVAR
    WHERE  grname = 'SYSTEM' AND varname = 'CURRDATE';

    OPEN PV_REFCURSOR
    FOR
        SELECT cf.custodycd, sum(nvl(lns.nml,0) + nvl(lns.ovd,0) + nvl(lns.paid,0)) prinamt,
            sum(nvl(lns.paid,0) - nvl(lg.paid,0)) paidamt,
            max(nvl(ts.prinused,0)) REREALASS,
            round(case when sum(nvl(lns.nml,0) + nvl(lns.ovd,0) - nvl(lg.nml,0) - nvl(lg.ovd,0)) = 0 then 1
            else sum(nvl(ts.prinused,0)) / sum(nvl(lns.nml,0) + nvl(lns.ovd,0) - nvl(lg.nml,0) - nvl(lg.ovd,0)) end * 100,4) KRATE
        FROM vw_lnmast_all LN, vw_lnschd_all lns, lntype lnt, afmast af, cfmast cf,
            (
            SELECT lg.autoid, sum(lg.nml) nml, sum(lg.ovd) ovd, sum(lg.paid) paid
            FROM vw_lnschdlog_all lg
            WHERE lg.txdate > l_ToDate
            GROUP BY lg.autoid
            ) lg,
            (select cf.custodycd, nvl(sum(prinused * least(sec0.marginrefprice,rsk.mrpriceloan)),0)   prinused
                from afmast af,(SELECT * FROM CFMAST WHERE FNC_VALIDATE_SCOPE(BRID, CAREBY, TLSCOPE, pv_BRID, TLGOUPS)=0) cf,
                   (
                       select codeid,afacctno, sum(prinused) prinused
                       from (
                           select * from afpralloc where txdate <= l_ToDate and restype = 'M'
                           union all
                           select * from afprallochist where txdate <= l_ToDate and restype = 'M'
                       ) group by codeid, afacctno
                   ) pr,
                   (select * from securities_info_hist where histdate = (select max(histdate) from securities_info_hist where histdate <= l_ToDate)) sec0,
                   (select * from afserisk74hist
                                where to_date(substr(BACKUPDT,1,10),'DD/MM/RRRR') = (select max(to_date(substr(BACKUPDT,1,10),'DD/MM/RRRR')) from afserisk74hist where to_date(substr(BACKUPDT,1,10),'DD/MM/RRRR') <= l_ToDate)) rsk
                where pr.codeid =  sec0.codeid
                   and pr.afacctno = af.acctno
                   and af.actype = rsk.actype
                   and rsk.codeid = sec0.codeid
                   AND af.custid = cf.custid
                group by cf.custodycd
            ) ts
        where ln.acctno = lns.acctno AND ln.trfacctno = af.acctno and af.custid = cf.custid
            and ln.ftype = 'AF' and lnt.actype = ln.actype and lnt.chksysctrl = 'Y'
            and cf.custodycd = ts.custodycd(+)
            AND lns.autoid = lg.autoid(+)
            AND lns.rlsdate <= l_ToDate
            and case when l_OPT = 'A' then 1 else instr(l_BRID_FILTER,substr(af.acctno,1,4)) end  <> 0
            and exists (select gu.grpid from tlgrpusers gu where af.careby = gu.grpid and gu.tlid = V_STRTLID )
        group BY cf.custodycd
        having sum(nvl(lns.nml,0) + nvl(lns.ovd,0) - nvl(lg.nml,0) - nvl(lg.ovd,0)) + sum(nvl(ts.prinused,0)) > 0
        order by cf.custodycd;


            /*
            SELECT cf.custodycd,
                nvl(sum(ln.prinnml + ln.prinovd + ln.prinpaid),0) - nvl(max(nvl(PRIN_TO_CR,0)),0) - nvl(max(nvl(PAID_TO_CR,0)),0) prinamt,
                nvl(sum(ln.prinpaid),0) - nvl(sum(nvl(PAID_TO_CR,0)),0) paidamt,
                nvl(sum(ts.prinused),0) REREALASS,
                round(case when (nvl(sum(ln.prinnml + ln.prinovd),0) - nvl(max(nvl(PRIN_TO_CR,0)),0)) = 0 then 1
                else nvl(sum(ts.prinused),0) / (nvl(sum(ln.prinnml + ln.prinovd),0) - nvl(max(nvl(PRIN_TO_CR,0)),0)) end * 100,4) KRATE

            FROM vw_lnmast_all LN, lntype lnt, afmast af, cfmast cf,
              (SELECT ln.trfacctno, NVL(SUM(CASE WHEN APP.TXTYPE = 'D' THEN -LNTR.NAMT ELSE LNTR.NAMT END), 0) PRIN_TO_CR
              FROM  VW_LNTRAN_ALL LNTR, APPTX APP, VW_LNMAST_ALL LN, AFMAST AF, AFTYPE AFT, MRTYPE MRT, LNTYPE LNT
              WHERE   LNTR.TXCD = APP.TXCD
                  AND APP.APPTYPE = 'LN'
                  AND APP.FIELD IN ('PRINNML','PRINOVD')
                  AND APP.TXTYPE IN ('C','D')
                  AND LNTR.ACCTNO = LN.ACCTNO
                  AND LN.FTYPE = 'AF'
                  AND LN.TRFACCTNO = AF.ACCTNO
                  AND AF.ACTYPE    = AFT.ACTYPE
                  AND AFT.MRTYPE   = MRT.ACTYPE
                  AND MRT.MRTYPE   = 'T'
                  AND LN.ACTYPE   = LNT.ACTYPE
                  AND LNT.CHKSYSCTRL = 'Y'
                  AND LNTR.NAMT <> 0
                  AND LNTR.DELTD <> 'Y'
                  --AND LNTR.BKDATE BETWEEN l_ToDate+1 AND l_CurrDate
                  AND lntr.bkdate > l_ToDate
              group by ln.trfacctno) prinmov,
              (SELECT ln.trfacctno, NVL(SUM(CASE WHEN APP.TXTYPE = 'D' THEN -LNTR.NAMT ELSE LNTR.NAMT END), 0) PAID_TO_CR
              FROM  VW_LNTRAN_ALL LNTR, APPTX APP, VW_LNMAST_ALL LN, AFMAST AF, AFTYPE AFT, MRTYPE MRT, LNTYPE LNT
              WHERE   LNTR.TXCD = APP.TXCD
                  AND APP.APPTYPE = 'LN'
                  AND APP.FIELD IN ('PRINPAID')
                  AND APP.TXTYPE IN ('C','D')
                  AND LNTR.ACCTNO = LN.ACCTNO
                  AND LN.FTYPE = 'AF'
                  AND LN.TRFACCTNO = AF.ACCTNO
                  AND AF.ACTYPE    = AFT.ACTYPE
                  AND AFT.MRTYPE   = MRT.ACTYPE
                  AND MRT.MRTYPE   = 'T'
                  AND LN.ACTYPE   = LNT.ACTYPE
                  AND LNT.CHKSYSCTRL = 'Y'
                  AND LNTR.NAMT <> 0
                  AND LNTR.DELTD <> 'Y'
                  --AND LNTR.BKDATE BETWEEN l_ToDate+1 AND l_CurrDate
                  AND lntr.bkdate > l_ToDate
              group by ln.trfacctno) paidmov,
              (select af.acctno, nvl(sum(prinused * least(sec0.marginrefprice,rsk.mrpriceloan)),0)   prinused
                       from afmast af,
                       (
                           select codeid,afacctno, sum(prinused) prinused
                           from (
                               select * from afpralloc where txdate <= l_ToDate and restype = 'M'
                               union all
                               select * from afprallochist where txdate <= l_ToDate and restype = 'M'
                           ) group by codeid, afacctno
                       ) pr,
                       (select * from securities_info_hist where histdate = (select max(histdate) from securities_info_hist where histdate <= l_ToDate)) sec0,
                       (select * from afmrseriskhist
                                    where to_date(substr(BACKUPDT,1,10),'DD/MM/RRRR') = (select max(to_date(substr(BACKUPDT,1,10),'DD/MM/RRRR')) from afmrseriskhist where to_date(substr(BACKUPDT,1,10),'DD/MM/RRRR') <= l_ToDate)) rsk
                   where pr.codeid =  sec0.codeid
                       and pr.afacctno = af.acctno
                       and af.actype = rsk.actype
                       and rsk.codeid = sec0.codeid
                group by af.acctno) ts
            where ln.trfacctno = af.acctno and af.custid = cf.custid
            and ln.ftype = 'AF' and lnt.actype = ln.actype and lnt.chksysctrl = 'Y'
            and ln.trfacctno = prinmov.trfacctno(+) and ln.trfacctno = paidmov.trfacctno(+)
            and ln.trfacctno = ts.acctno(+)
            and case when l_OPT = 'A' then 1 else instr(l_BRID_FILTER,substr(af.acctno,1,4)) end  <> 0
            and exists (select gu.grpid from tlgrpusers gu where af.careby = gu.grpid and gu.tlid = V_STRTLID )
            group by cf.custodycd
            having nvl(sum(ln.prinnml + ln.prinovd),0) - nvl(max(nvl(PRIN_TO_CR,0)),0) + nvl(sum(ts.prinused),0) > 0
            order by cf.custodycd;
                */

EXCEPTION
  WHEN OTHERS
   THEN
      RETURN;
END;

 
 
 
 
/
