SET DEFINE OFF;
CREATE OR REPLACE FORCE VIEW V_ADVANCESCHEDULE
(AUTOADV, AFACCTNO, EXECAMT, AMT, FAMT, 
 AAMT, PAIDAMT, PAIDFEEAMT, AFTYPE, CUSTID, 
 CLEARDATE, TXDATE, VATRATE, FEERATE, CURRDATE, 
 ADVRATE, ADVMINAMT, ADVBANKRATE, ADVMINFEEBANK, ADVMINBANK, 
 RIGHTVAT, AVATRATE, ADVMAXAMT, ADVMINFEE, ADVMAXFEE, 
 RRTYPE, CUSTBANK, CIACCTNO, EXFEEAMT, AINTRATE, 
 AFEEBANK, AMINBAL, AMINFEEBANK, DAYS, ADTYPE, 
 ADTYPENAME, AVLADVAMT, ADVPRIO)
BEQUEATH DEFINER
AS 
(
select af.autoadv,mta.afacctno, mta.execamt, mta.amt, mta.famt, mta.aamt, mta.paidamt, mta.paidfeeamt,  af.actype aftype,
       cf.custid, mta.cleardate, MTA.TXDATE, mta.vatrate, mta.feerate, MTA.CURRDATE,
       adt.advrate, adt.advminamt, adt.advbankrate, adt.advminfeebank, adt.ADVMINBANK,RIGHTVAT,
       adt.vatrate avatrate, adt.advmaxamt, adt.advminfee, adt.advmaxfee, adt.rrtype, adt.custbank, adt.ciacctno,
       --(case when cf.vat='Y' OR cf.whtax ='Y' then MTA.FEEACR + MTA.TAXSELLAMT + MTA.RIGHTVAT else MTA.FEEACR  + MTA.RIGHTVAT end) EXFEEAMT,
      CASE WHEN TAXSELLAMTOD>0 THEN TAXSELLAMTOD ELSE EXECAMT* (DECODE (CF.VAT,'Y',TAXSELLRATE,'N',0)+ DECODE (CF.WHTAX,'Y',WHTAXRATE,'N',0))/100  END  + MTA.RIGHTVAT + MTA.FEEACR EXFEEAMT,
       adt.advrate AINTRATE, adt.advbankrate AFEEBANK, adt.advminfee AMINBAL, adt.ADVMINBANK AMINFEEBANK,
       MTA.DAYS,
       adt.actype adtype, adt.typename adtypename,
       AVLODAMT - CASE WHEN TAXSELLAMTOD>0 THEN TAXSELLAMTOD ELSE EXECAMT* (DECODE (CF.VAT,'Y',TAXSELLRATE,'N',0)+ DECODE (CF.WHTAX,'Y',WHTAXRATE,'N',0))/100  END  AVLADVAMT,AFT.ADVPRIO
from (select mt.afacctno, mt.cleardate, MAX(MT.TXDATE) TXDATE,
             round((sum(case when mt.feeacr <= 0 then (mt.deffeerate/100)*mt.execamt else mt.feeacr end)/sum(execamt))*100,4) feerate,
           /*  sum(MT.FEEACR + MT.TAXSELLAMT + MT.RIGHTVAT)  exfeeamt,*/ sum(mt.execamt) execamt, sum(mt.amt) amt,
             sum(mt.aamt) aamt, sum(mt.paidamt) paidamt, sum(mt.paidfeeamt) paidfeeamt, sum(mt.famt) famt,
             max(mt.TAXSELLRATE) vatrate,MAX(MT.DAYS) DAYS, MAX(CURRDATE) CURRDATE, /*SUM(MT.AMT - MT.FEEACR - MT.TAXSELLAMT) AVLADVAMT,*/SUM(MT.AMT - MT.FEEACR) AVLODAMT,
             sum(MT.FEEACR) FEEACR,/*sum(MT.TAXSELLAMT) TAXSELLAMT,*/sum(MT.RIGHTVAT) RIGHTVAT,MAX(TAXSELLRATE) TAXSELLRATE, MAX(WHTAXRATE) WHTAXRATE, SUM (TAXSELLAMTOD) TAXSELLAMTOD
      from  (


            SELECT STS.AFACCTNO,STS.CLEARDATE,max(STS.TXDATE) TXDATE, --MST.ACTYPE,
                SUM(STS.AMT - NVL(ODM.EXECQTTY,0) * STS.AMT/STS.QTTY) EXECAMT,
                --SUM(STS.AMT - NVL(ODM.EXECQTTY,0) * STS.AMT/STS.QTTY - (STS.AAMT - NVL(ODM.AAMT,0) ) -STS.FAMT+STS.PAIDAMT+STS.PAIDFEEAMT) AMT,
                SUM(STS.AMT - NVL(ODM.EXECQTTY,0) * STS.AMT/STS.QTTY - mst.netexecamt - mst.cfnetexecamt  - (STS.AAMT - NVL(ODM.AAMT,0) ) -STS.FAMT+STS.PAIDAMT+STS.PAIDFEEAMT) AMT, --HSX04
                SUM(STS.FAMT) FAMT,SUM(STS.AAMT) AAMT,
                SUM(STS.PAIDAMT) PAIDAMT,SUM(STS.PAIDFEEAMT) PAIDFEEAMT,
                max(odt.deffeerate) DEFFEERATE, max(to_number(sys.varvalue)) TAXSELLRATE,max(to_number(sys3.varvalue)) WHTAXRATE,
             --   SUM(CASE WHEN MST.FEEACR >0  THEN MST.FEEACR ELSE round((STS.AMT - NVL(ODM.EXECQTTY,0) * STS.AMT/STS.QTTY) *ODT.DEFFEERATE/100) END) FEEACR,
                --PhuongHT them DK TXDATE cho truong hop uu duoc set uu dai bieu phi
                /*SUM(CASE WHEN (MST.FEEACR <=0 AND MST.TXDATE=TO_DATE(SYS2.VARVALUE,'DD/MM/RRRR'))
                         THEN round((STS.AMT - NVL(ODM.EXECQTTY,0) * STS.AMT/STS.QTTY) *ODT.DEFFEERATE/100)
                         ELSE MST.FEEACR  END) FEEACR,*/
                ROUND(SUM(CASE WHEN (MST.FEEACR <=0 AND MST.TXDATE=TO_DATE(SYS2.VARVALUE,'DD/MM/RRRR'))
                         THEN (STS.AMT - NVL(ODM.EXECQTTY,0) * STS.AMT/STS.QTTY) *ODT.DEFFEERATE/100
                         ELSE MST.FEEACR - MST.Feeamt END)) FEEACR, -- HSX04
                --SUM(CASE WHEN MST.TAXSELLAMT >0 THEN MST.TAXSELLAMT ELSE round((STS.AMT - NVL(ODM.EXECQTTY,0) * STS.AMT/STS.QTTY)*(TO_NUMBER(SYS.VARVALUE)+TO_NUMBER(SYS3.VARVALUE))/100) END) TAXSELLAMT,
                --SUM(sts.ARIGHT) RIGHTVAT, 
                SUM(sts.ARIGHT- DECODE(MST.NETEXECAMT+MST.CFNETEXECAMT, MST.EXECAMT, STS.ARIGHT, CEIL((MST.NETEXECAMT+MST.CFNETEXECAMT)*STS.ARIGHT/MST.EXECAMT))) RIGHTVAT, -- hsx04
                MAX(TO_DATE(SYS2.varvalue,'DD/MM/YYYY')) CURRDATE,
                (CASE WHEN STS.CLEARDATE - MAX(TO_DATE(SYS2.varvalue,'DD/MM/YYYY')) =0 THEN 1 ELSE STS.CLEARDATE - MAX(TO_DATE(SYS2.varvalue,'DD/MM/YYYY')) END) DAYS,
                --SUM(MST.TAXSELLAMT) TAXSELLAMTOD
                SUM(MST.TAXSELLAMT -DECODE(MST.NETEXECAMT + MST.CFNETEXECAMT, MST.EXECAMT, MST.TAXSELLAMT, CEIL((MST.NETEXECAMT + MST.CFNETEXECAMT)* MST.TAXSELLAMT/MST.EXECAMT))) TAXSELLAMTOD -- hsx04
                --sum(SB.PARVALUE*RIGHTQTTY*to_number(sys1.varvalue)/100) RIGHTVAT
             FROM STSCHD STS,ODMAST MST, SYSVAR SYS, ODTYPE ODT, sbsecurities SB, SYSVAR SYS1, sysvar sys2,sysvar sys3,
                    (SELECT ORDERID,SUM(EXECQTTY) EXECQTTY, SUM(AAMT) AAMT FROM ODMAPEXT WHERE ISVSD='Y' AND DELTD <> 'Y' GROUP BY ORDERID) ODM

             WHERE STS.orgorderid=MST.orderid
                    AND STS.CODEID=SB.CODEID
                    AND STS.DELTD <> 'Y' AND STS.STATUS='N' AND STS.DUETYPE='RM'
                    and sys.varname = 'ADVSELLDUTY' and sys.grname = 'SYSTEM'
                    and sys1.varname = 'ADVVATDUTY' and sys1.grname = 'SYSTEM'
                    AND SYS2.VARNAME='CURRDATE' AND SYS2.GRNAME='SYSTEM'
                    and sys3.varname = 'WHTAX' and sys3.grname = 'SYSTEM'
                    and mst.actype = odt.actype
                    and mst.grporder<>'Y'
                    AND MST.ERROD = 'N'
                    AND STS.orgorderid = ODM.ORDERID (+)
             GROUP BY STS.AFACCTNO,STS.CLEARDATE


             ) MT
      group by mt.afacctno, mt.cleardate) mta,
            afmast af, cfmast cf, aftype aft, adtype adt
where mta.afacctno =  af.acctno and af.custid = cf.custid and af.actype = aft.actype
      and aft.adtype = adt.actype
      --AND aft.actype = map.aftype and adt.actype = map.actype and map.objname ='AD.ADTYPE' and adt.autoadv = 'Y'
      and cf.custatcom='Y' --Loai di nhung tai khoan luu ky ben ngoai
)
/
