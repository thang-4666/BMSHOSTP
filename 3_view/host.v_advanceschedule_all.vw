SET DEFINE OFF;
CREATE OR REPLACE FORCE VIEW V_ADVANCESCHEDULE_ALL
(AUTOADV, AFACCTNO, EXECAMT, AMT, FAMT, 
 AAMT, PAIDAMT, PAIDFEEAMT, AFTYPE, CUSTID, 
 CLEARDATE, TXDATE, VATRATE, FEERATE, CURRDATE, 
 ADVRATE, ADVMINAMT, ADVBANKRATE, ADVMINFEEBANK, ADVMINBANK, 
 RIGHTVAT, AVATRATE, ADVMAXAMT, ADVMINFEE, ADVMAXFEE, 
 RRTYPE, CUSTBANK, CIACCTNO, EXFEEAMT, AINTRATE, 
 AFEEBANK, AMINBAL, AMINFEEBANK, DAYS, ADTYPE, 
 ADTYPENAME)
BEQUEATH DEFINER
AS 
(
select af.autoadv,mta.afacctno, mta.execamt, mta.amt, mta.famt, mta.aamt, mta.paidamt, mta.paidfeeamt, typ.aftype,
       cf.custid, mta.cleardate, MTA.TXDATE, mta.vatrate, mta.feerate, TO_DATE(SYS1.varvalue,'DD/MM/YYYY') CURRDATE,
       typ.advrate, typ.advminamt, typ.advbankrate, typ.advminfeebank, typ.ADVMINBANK,RIGHTVAT,
       typ.vatrate avatrate, typ.advmaxamt, typ.advminfee, typ.advmaxfee, typ.rrtype, typ.custbank, typ.ciacctno,
       mta.EXFEEAMT, typ.advrate AINTRATE, typ.advbankrate AFEEBANK, typ.advminfee AMINBAL, typ.ADVMINBANK AMINFEEBANK,
       (CASE WHEN mta.CLEARDATE - TO_DATE(SYS1.varvalue,'DD/MM/YYYY') =0 THEN 1 ELSE CLEARDATE -TO_DATE(SYS1.varvalue,'DD/MM/YYYY') END) DAYS,
       typ.actype adtype, typ.typename adtypename
from (select mt.afacctno, mt.cleardate, MT.TXDATE, round((sum(case when mt.feeacr <= 0 then (mt.deffeerate/100)*mt.execamt
                                                        else mt.feeacr end)/sum(execamt))*100,4) feerate,
             sum(case WHEN ( mt.feeacr <= 0 AND MT.TXDATE=TO_DATE(SYS.VARVALUE,'DD/MM/RRRR'))
                      then ((mt.deffeerate + mt.vatrate)/100)*mt.execamt + mt.rightvat
                      else (mt.feeacr + (mt.vatrate/100)*mt.execamt) + mt.rightvat end)  exfeeamt, sum(mt.execamt) execamt, sum(mt.amt) amt,
             sum(mt.aamt) aamt, sum(mt.paidamt) paidamt, sum(mt.paidfeeamt) paidfeeamt, sum(mt.famt) famt,sum(rightvat) rightvat,
             max(mt.vatrate) vatrate
      from  (SELECT STS.AFACCTNO,STS.CLEARDATE, MST.ACTYPE, STS.TXDATE,
                SUM(STS.AMT) EXECAMT,SUM(STS.AMT-STS.AAMT-STS.FAMT+STS.PAIDAMT+STS.PAIDFEEAMT) AMT,SUM(STS.FAMT) FAMT,SUM(STS.AAMT) AAMT,
                SUM(STS.PAIDAMT) PAIDAMT,SUM(STS.PAIDFEEAMT) PAIDFEEAMT,
                max(odt.deffeerate) DEFFEERATE, max(to_number(sys.varvalue)) VATRATE, SUM(MST.FEEACR) FEEACR,
                SUM(STS.ARIGHT) RIGHTVAT
                --sum(SB.PARVALUE*RIGHTQTTY*to_number(sys1.varvalue)/100) RIGHTVAT
             FROM STSCHD STS,ODMAST MST, SYSVAR SYS, ODTYPE ODT, sbsecurities SB, SYSVAR SYS1
             WHERE STS.orgorderid=MST.orderid
                    AND STS.CODEID=SB.CODEID
                    AND STS.DELTD <> 'Y' AND STS.STATUS='N' AND STS.DUETYPE='RM'
                    and sys.varname = 'ADVSELLDUTY' and sys.grname = 'SYSTEM'
                    and sys1.varname = 'ADVVATDUTY' and sys.grname = 'SYSTEM'
                    and mst.actype = odt.actype
             GROUP BY STS.AFACCTNO,STS.CLEARDATE, MST.ACTYPE, STS.TXDATE) MT,
             (SELECT * FROm SYSVAR WHERE VARNAME='CURRDATE' AND GRNAME='SYSTEM') SYS
      group by mt.afacctno, mt.cleardate, MT.TXDATE) mta,
            afmast af, cfmast cf,
            (
                Select aft.actype aftype, adt.* from adtype adt, aftype aft
                where aft.adtype = adt.actype --and aft.actype='0013'
                UNION all
                Select aft.actype, adt.* from adtype adt, aftype aft, afidtype map
                where aft.actype = map.aftype AND adt.actype = map.actype AND map.objname ='AD.ADTYPE' --and aft.actype='0013'
            )typ,
            sysvar sys1
where mta.afacctno =  af.acctno and af.custid = cf.custid and af.actype = typ.aftype
      AND cf.custatcom='Y'
      AND SYS1.VARNAME='CURRDATE' AND SYS1.GRNAME='SYSTEM'
)
/
