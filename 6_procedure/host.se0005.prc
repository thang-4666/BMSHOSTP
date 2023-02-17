SET DEFINE OFF;
CREATE OR REPLACE PROCEDURE se0005 (
   PV_REFCURSOR   IN OUT   PKG_REPORT.REF_CURSOR,
   OPT            IN       VARCHAR2,
   pv_BRID           IN       VARCHAR2,
   TLGOUPS        IN       VARCHAR2,
   TLSCOPE        IN       VARCHAR2,
   F_DATE         IN       VARCHAR2,
   T_DATE         IN       VARCHAR2,
   PV_SYMBOL      IN       VARCHAR2,
   PV_CUSTODYCD   IN       VARCHAR2,
   PV_TLTXCD      IN       VARCHAR2
)
IS
--Bao cao tong hop so du ck lo le
--created by chaunh at 11/02/2012

   V_STROPTION      VARCHAR2 (5);            -- A: ALL; B: BRANCH; S: SUB-BRANCH

   V_INBRID         VARCHAR2(4);
   V_STRBRID        VARCHAR2 (50);

   V_CUSTODYCD      VARCHAR2 (20);
   V_CURRDATE       date;
   V_SYMBOL         varchar2 (20);
   V_TLTXCD         varchar2 (10);
   V_FROMDATE       DATE;
   V_TODATE         DATE;

BEGIN
   V_STROPTION := upper(OPT);
   V_INBRID := pv_BRID;
    if(V_STROPTION = 'A') then
        V_STRBRID := '%%';
    else
        if(V_STROPTION = 'B') then
            select br.mapid into V_STRBRID from brgrp br where  br.brid = V_INBRID;
        else
            V_STRBRID := V_INBRID;
        end if;
    end if;

   If (PV_SYMBOL IS NULL OR UPPER(PV_SYMBOL) = 'ALL')
   then
        V_SYMBOL := '%';
   else
        V_SYMBOL := replace(PV_SYMBOL,' ', '_');
   end if;

   IF (PV_CUSTODYCD IS NULL OR UPPER(PV_CUSTODYCD) = 'ALL')
   THEN
       V_CUSTODYCD := '%';
   ELSE
        V_CUSTODYCD := PV_CUSTODYCD;
   END IF;

   IF (PV_TLTXCD IS NULL OR UPPER(PV_TLTXCD) = 'ALL')
   THEN
        V_TLTXCD := '%';
   ELSE
        V_TLTXCD := PV_TLTXCD;
   END IF;

   select to_date(varvalue,'DD/MM/RRRR') into V_CURRDATE from sysvar where varname = 'CURRDATE';

   V_FROMDATE := to_date(F_DATE, 'DD/MM/RRRR');
   V_TODATE   := to_date(T_DATE, 'DD/MM/RRRR');

OPEN PV_REFCURSOR FOR

select tl.txdesc, tl.txdate, tl.Fee, tl.tax, tl.paidamt, tl.Debit_contract, tl.Debit_Fullname,
    tl.Debit_code, tl.Debit_qtty, tl.Cebit_contract, tl.Cebit_Fullname,
    sb.symbol, tl.execustodycd
from
(
select max(tl.txdesc) txdesc, tl.txdate, tl.txnum,
    sum(case when tlf.fldcd in ('45','47') then tlf.nvalue else 0 end) Fee,
    sum(case when tlf.fldcd = '46' then tlf.nvalue else 0 end) tax,
    sum(case when tlf.fldcd in ('45','47') then tlf.nvalue else 0 end) +
    sum(case when tlf.fldcd = '46' then tlf.nvalue else 0 end) paidamt,
    max(case when tlf.fldcd = '15' then tlf.cvalue else '' end) Debit_contract,
    max(case when tlf.fldcd = '90' then tlf.cvalue else '' end) Debit_Fullname,
    max(case when tlf.fldcd = '01' then tlf.cvalue else '' end) Debit_code,
    max(tl.msgamt) Debit_qtty,
    max(case when tlf.fldcd = '88' then tlf.cvalue else '' end) Cebit_contract,
    max(case when tlf.fldcd = '49' then tlf.cvalue else '' end) Cebit_Fullname,
    max(case when tlf.fldcd = '15' then tlf.cvalue else '' end) execustodycd
from vw_tllog_all tl, vw_tllogfld_all tlf
where tl.tltxcd= '2244' and tl.txnum = tlf.txnum and tl.txdate = tlf.txdate
    AND TL.TLTXCD LIKE V_TLTXCD and tl.deltd <> 'Y'
    and tlf.fldcd in ('45','46','47','15','90','01','88','49')
    and tl.txdate >= V_FROMDATE and tl.txdate <= V_TODATE
    and tlf.txdate >= V_FROMDATE and tlf.txdate <= V_TODATE
group by tl.txdate, tl.txnum
union all
select tl.txdesc, tl.txdate, tl.txnum, tlf.nmlamt Fee, 0  tax,
    (case when nvl(tlf.paidtxdate,to_date('01/01/2222','dd/mm/rrrr')) >= V_FROMDATE and
        nvl(tlf.paidtxdate,to_date('01/01/2222','dd/mm/rrrr')) <= V_TODATE then tlf.paidamt
        else 0 end) paidamt,
    '' Debit_contract, '' Debit_Fullname, substr(tl.msgacct,11) Debit_code, tl.msgamt Debit_qtty,
    cf.custodycd Cebit_contract, cf.fullname Cebit_Fullname, cf.custodycd execustodycd
from vw_tllog_all tl, CIFEESCHD tlf, (SELECT * FROM CFMAST WHERE FNC_VALIDATE_SCOPE(BRID, CAREBY, TLSCOPE, pv_BRID, TLGOUPS)=0) cf, afmast af, semast se
where tl.tltxcd= '2245' and tl.txnum = tlf.txnum and tl.txdate = tlf.txdate
    AND TL.TLTXCD LIKE V_TLTXCD
    --- and tl.cfcustodycd = cf.custodycd
    and tl.msgacct = se.acctno and af.acctno = se.afacctno
    and af.custid = cf.custid
    and tl.deltd <> 'Y' and tlf.deltd <> 'Y'
    and tl.txdate >= V_FROMDATE and tl.txdate <= V_TODATE
    and tlf.txdate >= V_FROMDATE and tlf.txdate <= V_TODATE
    and tlf.feetype = 'FEEDR'
) tl, sbsecurities sb
where tl.Debit_code = sb.codeid
    and tl.Fee+tl.tax <> 0
    AND SB.SYMBOL LIKE V_SYMBOL AND TL.execustodycd LIKE V_CUSTODYCD
order by tl.txdate, tl.txnum
;

EXCEPTION
   WHEN OTHERS
   THEN
      RETURN;
END;                                                              -- PROCEDURE
 
/
