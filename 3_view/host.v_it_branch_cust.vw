SET DEFINE OFF;
CREATE OR REPLACE FORCE VIEW V_IT_BRANCH_CUST
(BRID, BRNAME, TLID, TLNAME, TLFULLNAME, 
 GRPID, GRPNAME, CUSTODYCD)
BEQUEATH DEFINER
AS 
select tl.brid,br.brname, tl.tlid, tl.tlname, tl.tlfullname, tg.grpid, tg.grpname, cf.custodycd
from  cfmast cf
    left join tlprofiles tl on cf.tlid=tl.tlid
    left join brgrp br on br.brid=tl.brid
    left join tlgroups tg on cf.careby=tg.grpid
order by brid, tlname, tg.grpname, cf.custodycd
/
