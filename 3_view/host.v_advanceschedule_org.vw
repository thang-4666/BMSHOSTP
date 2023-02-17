SET DEFINE OFF;
CREATE OR REPLACE FORCE VIEW V_ADVANCESCHEDULE_ORG
(AFACCTNO, EXECAMT, AMT, FAMT, AAMT, 
 PAIDAMT, PAIDFEEAMT, ACTYPE, CUSTID, CLEARDATE, 
 TXDATE, VATRATE, FEERATE, CURRDATE, ADVRATE, 
 ADVMINAMT, ADVBANKRATE, ADVMINFEEBANK, ADVMINBANK, AVATRATE, 
 ADVMAXAMT, ADVMINFEE, ADVMAXFEE, RRTYPE, CUSTBANK, 
 CIACCTNO, EXFEEAMT, AINTRATE, AFEEBANK, AMINBAL, 
 AMINFEEBANK, DAYS)
BEQUEATH DEFINER
AS 
(
select mta.afacctno, mta.execamt, mta.amt, mta.famt, mta.aamt, mta.paidamt, mta.paidfeeamt, aft.actype,
       cf.custid, mta.cleardate, MTA.TXDATE, mta.vatrate, mta.feerate, TO_DATE(SYS1.varvalue,'DD/MM/YYYY') CURRDATE,
       adt.advrate, adt.advminamt, adt.advbankrate, adt.advminfeebank, adt.ADVMINBANK,
       adt.vatrate avatrate, adt.advmaxamt, adt.advminfee, adt.advmaxfee, adt.rrtype, adt.custbank, adt.ciacctno,
       mta.EXFEEAMT, adt.advrate AINTRATE, adt.advbankrate AFEEBANK, adt.advminfee AMINBAL, adt.ADVMINBANK AMINFEEBANK,
       --,SYS2.varvalue AINTRATE, SYS3.varvalue AMINBAL,SYS4.varvalue AFEEBANK , SYS5.varvalue AMINFEEBANK,
       (CASE WHEN mta.CLEARDATE - TO_DATE(SYS1.varvalue,'DD/MM/YYYY') =0 THEN 1 ELSE   CLEARDATE -TO_DATE(SYS1.varvalue,'DD/MM/YYYY') END) DAYS
from (select mt.afacctno, mt.cleardate, MT.TXDATE, round((sum(case when mt.feeacr <= 0 then (mt.deffeerate/100)*mt.execamt
                                                        else mt.feeacr end)/sum(execamt))*100,4) feerate,
             sum(case when (mt.feeacr <= 0 AND MT.TXDATE=TO_DATE(SYS.VARVALUE,'DD/MM/RRRR'))
                      then ((mt.deffeerate + mt.vatrate)/100)*mt.execamt
                      else (mt.feeacr + (mt.vatrate/100)*mt.execamt) end)  exfeeamt, sum(mt.execamt) execamt, sum(mt.amt) amt,
             sum(mt.aamt) aamt, sum(mt.paidamt) paidamt, sum(mt.paidfeeamt) paidfeeamt, sum(mt.famt) famt,
             max(mt.vatrate) vatrate
      from  (SELECT STS.AFACCTNO,STS.CLEARDATE, MST.ACTYPE, STS.TXDATE,
                SUM(STS.AMT) EXECAMT,SUM(STS.AMT-STS.AAMT-STS.FAMT+STS.PAIDAMT+STS.PAIDFEEAMT) AMT,SUM(STS.FAMT) FAMT,SUM(STS.AAMT) AAMT,
                SUM(STS.PAIDAMT) PAIDAMT,SUM(STS.PAIDFEEAMT) PAIDFEEAMT,
                max(odt.deffeerate) DEFFEERATE, max(to_number(sys.varvalue)) VATRATE, SUM(MST.FEEACR) FEEACR
             FROM STSCHD STS,ODMAST MST, SYSVAR SYS, ODTYPE ODT
             WHERE STS.orgorderid=MST.orderid
                    AND STS.DELTD <> 'Y' AND STS.STATUS='N' AND STS.DUETYPE='RM'
                    and sys.varname = 'ADVSELLDUTY' and sys.grname = 'SYSTEM'
                    and mst.actype = odt.actype
             GROUP BY STS.AFACCTNO,STS.CLEARDATE,mst.ACTYPE, STS.TXDATE) MT,
             (SELECT * FROM SYSVAR WHERE VARNAME='CURRDATE' AND GRNAME='SYSTEM') SYS
      group by mt.afacctno, mt.cleardate, MT.TXDATE) mta, afmast af, cfmast cf, aftype aft,
      sysvar sys1, ADTYPE ADT
      --sysvar sys2, sysvar sys3, sysvar sys4, sysvar sys5
where mta.afacctno =  af.acctno and af.custid = cf.custid and af.actype = aft.actype
      AND AFT.ADTYPE = ADT.ACTYPE
      --AND aft.actype = map.aftype and adt.actype = map.actype and map.objname ='AD.ADTYPE' and adt.autoadv ='Y'
       and cf.custatcom='Y' --Loai di nhung tai khoan luu ky ben ngoai
      and af.autoadv='Y'
      AND SYS1.VARNAME='CURRDATE' AND SYS1.GRNAME='SYSTEM'
      /*
      AND SYS2.VARNAME='AINTRATE' AND SYS2.GRNAME='SYSTEM'
      AND SYS3.VARNAME='AMINBAL' AND SYS3.GRNAME='SYSTEM'
      AND SYS4.VARNAME='AFEEBANK' AND SYS4.GRNAME='SYSTEM'
      AND SYS5.VARNAME='AMINFEEBANK' AND SYS5.GRNAME='SYSTEM'
      */
)
/
