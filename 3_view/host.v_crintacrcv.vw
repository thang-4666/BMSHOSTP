SET DEFINE OFF;
CREATE OR REPLACE FORCE VIEW V_CRINTACRCV
(CUSTODYCD, CRINTACR, BRID)
BEQUEATH DEFINER
AS 
select cf.custodycd, round( ci.CRINTACR)  CRINTACR,CF.BRID
from  cimast ci , cfmast cf
where cf.custid = ci.custid 
and ci.CRINTACR <>0
order by cf.custodycd
/
