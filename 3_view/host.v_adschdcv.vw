SET DEFINE OFF;
CREATE OR REPLACE FORCE VIEW V_ADSCHDCV
(CUSTODYCD, AMT, TXDATE, CLEARDAY, FEEAMT, 
 BRID)
BEQUEATH DEFINER
AS 
select cf.custodycd,round(amt) amt ,to_char( txdate,'dd-mm-yyyy') txdate,to_char( cleardt,'dd-mm-yyyy') CLEARDAY ,
round(feeamt)feeamt,CF.BRID 
 from adschd ads,afmast af, cfmast cf
where ads.acctno=af.acctno and af.custid=cf.custid
order by  txdate,cf.custodycd,amt,feeamt
/
