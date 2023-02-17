SET DEFINE OFF;
CREATE OR REPLACE PROCEDURE "SP_STRADE_ADVPAYMENTHIST" (
   PV_REFCURSOR   IN OUT   PKG_REPORT.REF_CURSOR,
   I_CUSTODYCD         IN       VARCHAR2,
   F_DATE         IN       VARCHAR2,
   T_DATE         IN       VARCHAR2,
   I_AFACCTNO         IN       VARCHAR2
 )
IS

   V_STRAFACCTNO   VARCHAR2 (20);
   V_STRCUSTODYCD  VARCHAR2 (20);
   V_FROMDATE       DATE;
   V_TODATE         DATE;
   v_AdvFeeRate     NUMBER(20,6);
   V_CURRDATE       DATE;

BEGIN
    IF I_CUSTODYCD IS NULL OR I_CUSTODYCD = '' THEN
        V_STRCUSTODYCD:= '%%';
   ELSE
        V_STRCUSTODYCD:= I_CUSTODYCD;
   END IF;

   IF I_AFACCTNO IS NULL OR I_AFACCTNO = '' THEN
        V_STRAFACCTNO:= '%%';
   ELSE
        V_STRAFACCTNO:= I_AFACCTNO;
   END IF;
   V_FROMDATE := to_date(F_DATE,'DD/MM/RRRR');
   V_TODATE   := to_date(T_DATE,'DD/MM/RRRR');
   SELECT to_date(varvalue, 'DD/MM/RRRR') INTO V_CURRDATE FROM sysvar WHERE varname = 'CURRDATE'  and grname = 'SYSTEM';
    select to_number(varvalue)/360 into v_AdvFeeRate from sysvar where varname = 'AINTRATE' and grname = 'SYSTEM';
OPEN  PV_REFCURSOR FOR
SELECT * FROM
(
select ad.txdate advdate, to_char(ad.txnum) txnum , cf.custodycd custodycd, af.acctno acctno,  ad.cleardt stdate,
    sts.EXECAMT SELLAMT,
    (ad.amt + ad.feeamt) ADVAMT,
    ad.feeamt FEEAMT,
    ad.amt RCVAMT,
    (ad.cleardt - ad.txdate) advdays,
    ad.status,
    tl.txdesc description
from (
         select acctno, txdate, txnum, cleardt, amt, feeamt, paidamt, deltd, status from adschd
         union all
         select acctno, txdate, txnum, cleardt, amt, feeamt, paidamt, deltd, status from adschdhist
     ) ad, afmast af, cfmast cf, vw_tllog_all tl,
        (SELECT sts.afacctno, sts.cleardate, sum(CASE WHEN sts.status <> 'C' AND cf.vat = 'Y' THEN (amt * (1- odt.deffeerate /100 - nvl(iccf.icrate,0)/100))
                                                  WHEN sts.status <> 'C' AND cf.vat <> 'Y' THEN (amt * (1- odt.deffeerate /100))
                                                ELSE (amt * (CASE WHEN cf.vat = 'Y' THEN 1 - nvl(iccf.icrate,0)/100 ELSE 1 END)) - (od.feeamt) END) EXECAMT
            FROM vw_stschd_all STS, vw_odmast_all od, odtype odt, aftype aft, afmast af, cfmast cf,
                (SELECT * FROM iccftypedef WHERE modcode = 'CF' AND eventcode = 'CFSELLVAT') iccf
            WHERE STS.DELTD <> 'Y' AND STS.DUETYPE='RM' AND od.EXECTYPE <> 'MS' AND od.orderid = sts.orgorderid
            AND odt.actype = od.actype AND af.acctno = od.afacctno AND af.actype = aft.actype AND iccf.actype(+) = aft.actype and af.custid = cf.custid
            GROUP BY sts.afacctno, sts.cleardate ) sts
where ad.deltd <> 'Y'
    AND tl.tltxcd = '1153'
    and af.acctno = ad.acctno
    and af.custid = cf.custid
    AND sts.afacctno = ad.acctno
    AND sts.cleardate = ad.cleardt
    and ad.txnum = tl.txnum
    and ad.txdate = tl.txdate
    and cf.custodycd = V_STRCUSTODYCD
    and af.acctno like V_STRAFACCTNO
    and tl.txdate >= V_FROMDATE AND tl.txdate <= V_TODATE

UNION ALL

select ci.txdate advdate, to_char(ci.txnum) txnum , cf.custodycd custodycd,  af.acctno acctno, sts.cleardate stdate,
    CASE WHEN sts.status <> 'C' AND cf.vat = 'Y' THEN sts.amt * (1-(odt.deffeerate/100)-nvl(iccf.icrate,0)/100)
        WHEN sts.status <> 'C' AND cf.vat <> 'Y'  THEN sts.amt * (1-(odt.deffeerate/100))
        ELSE sts.amt * (CASE WHEN cf.vat = 'Y' THEN 1 -nvl(iccf.icrate,0)/100 ELSE 1 END) - od.feeamt
    END SELLAMT,
    (ci.namt + ci.feeamt) ADVAMT,
    ci.feeamt FEEAMT,
    ci.namt RCVAMT,
    (sts.cleardate - sts.txdate) advdays,
    (CASE WHEN sts.paidamt = 0 THEN 'N' ELSE 'C' END) status,
    ci.txdesc description
from cfmast cf,
     afmast af,
     odtype odt,
     (SELECT * FROM iccftypedef WHERE modcode = 'CF' AND eventcode = 'CFSELLVAT') iccf,
     aftype aft,
     (SELECT * FROM vw_stschd_all WHERE duetype = 'RM') sts,
     vw_odmast_all od,
    (
        select ci.acctno, ci.txdate, ci.txnum, ci.txdesc,
            sum(CASE WHEN ci.field = 'AAMT' and ci.txtype = 'C' THEN ci.namt ELSE 0 END) namt ,
            sum(CASE WHEN ci.field = 'BALANCE' and ci.txtype = 'D' THEN ci.namt ELSE 0 END) feeamt,
            max(CASE WHEN ci.field = 'AAMT' and ci.txtype = 'C' THEN ci.REF ELSE '0000' END) orgorderid
        from vw_citran_gen ci
        where ci.tltxcd = '1143'
            and ci.busdate >= V_FROMDATE AND ci.busdate <= V_TODATE
            and ci.custodycd = V_STRCUSTODYCD
            and ci.acctno like V_STRAFACCTNO
            and ci.namt <> 0
        GROUP BY ci.acctno, ci.txdate, ci.txnum, ci.txdesc
    ) ci
    where cf.custid = af.custid
        and af.acctno = ci.acctno
        and ci.orgorderid = sts.orgorderid
        AND sts.orgorderid = od.orderid
        AND od.actype = odt.actype
        AND af.actype = aft.actype
        AND iccf.actype(+) = af.actype
        and cf.custodycd = V_STRCUSTODYCD
        and af.acctno like V_STRAFACCTNO
)
ORDER BY advdate DESC , stdate;

EXCEPTION
   WHEN OTHERS
   THEN
      RETURN;
END;

 
 
 
 
/
