SET DEFINE OFF;
CREATE OR REPLACE FORCE VIEW V_CFAUTHCV
(CFAAUTOID, CFACUSTID, CUSTODYCD, CFAFULLNAME, CFAIDCODE, 
 CFAIDDATE, CFAIDPLACE, VALDATE, EXPDATE, LINKAUTH, 
 BRID)
BEQUEATH DEFINER
AS 
select cfa.autoid CFAautoid, cfa.custid CFAcustid, cf1.custodycd ,
case when cf2.custid is null then cfa.fullname else cf2.fullname end CFAfullname,
case when cf2.custid is null then cfa.licenseno else cf2.idcode end CFAidcode,
case when cf2.custid is null then NVL( to_char(cfa.lniddate,'dd-mm-yyyy'),' ') else NVL( to_char(cf2.iddate,'dd-mm-yyyy'),' ') end CFAiddate,
case when cf2.custid is null then NVL(cfa.lnplace,' ') else NVL(cf2.idplace,' ') end CFAidplace,
NVL(to_char(cfa.valdate,'DD-MM-YYYY'),' ')valdate , to_char( cfa.expdate,'DD-MM-YYYY') expdate, cfa.linkauth, cf1.brid
from cfauth cfa, cfmast cf1, cfmast cf2
where cfa.cfcustid = cf1.custid
and cfa.custid = cf2.custid(+)
ORDER BY cf1.custodycd, cf2.idcode,cfa.expdate
/
