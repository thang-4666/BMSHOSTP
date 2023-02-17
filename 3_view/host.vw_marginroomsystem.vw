SET DEFINE OFF;
CREATE OR REPLACE FORCE VIEW VW_MARGINROOMSYSTEM
(CODEID, ROOMLIMIT, SYROOMLIMIT, SYROOMUSED)
BEQUEATH DEFINER
AS 
select se.codeid, case when rsk.ismarginallow = 'Y' then least(se.roomlimit,se.roomlimitmax) else 10000000000 end roomlimit,
se.syroomlimit, se.syroomused
from securities_info se, securities_risk rsk
where se.codeid = rsk.codeid(+)
/
