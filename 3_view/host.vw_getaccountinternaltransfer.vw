SET DEFINE OFF;
CREATE OR REPLACE FORCE VIEW VW_GETACCOUNTINTERNALTRANSFER
(AUTOID, CIACCOUNT, CINAME, AVLCASH, CUSTODYCD, 
 CUSTODYCDR, FULLNAME, ADDRESS, IDCODE, ACCTNO, 
 BANKBALANCE, BANKAVLBAL)
BEQUEATH DEFINER
AS 
SELECT cfo.autoid,cfo.CIACCOUNT,cfo.CINAME,
getbaldefovd(AF.ACCTNO) AVLCASH, CF.CUSTODYCD, CFR.CUSTODYCD CUSTODYCDR,
CF.FULLNAME FULLNAME,CF.ADDRESS ADDRESS,CF.IDCODE IDCODE , af.acctno,
ci.bankbalance, ci.bankavlbal
FROM CFOTHERACC CFO, AFMAST AF,CIMAST CI,CFMAST CF,AFMAST AFR,CFMAST CFR
WHERE CFO.CFCUSTID = AF.CUSTID AND AF.CUSTID= CF.CUSTID AND AF.ACCTNO= CI.ACCTNO
AND CFO.TYPE='0'
And CFO.ciaccount = AFR.acctno And AFR.custid = CFR.custid
and af.custid <> afr.custid
union
select -1 autoid, afr.acctno CIACCOUNT,cf.fullname CINAME,
getbaldefovd(af.acctno) AVLCASH, cf.custodycd, cf.custodycd CUSTODYCDR,
cf.fullname, cf.address, cf.idcode, af.acctno,
ci.bankbalance, ci.bankavlbal
from cfmast cf, afmast af, CIMAST CI,afmast afr
where cf.custid = af.custid AND AF.ACCTNO= CI.ACCTNO
and cf.custid = afr.custid and afr.acctno <> af.acctno
/
