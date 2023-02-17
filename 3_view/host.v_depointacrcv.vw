SET DEFINE OFF;
CREATE OR REPLACE FORCE VIEW V_DEPOINTACRCV
(CUSTODYCD, DEPOINTACR, BRID)
BEQUEATH DEFINER
AS 
select cf.custodycd, round( ci.cidepofeeacr)  DEPOINTACR,CF.BRID
from  cimast ci , cfmast cf
where cf.custid = ci.custid 
and ci.cidepofeeacr >0
order by cf.custodycd
/
