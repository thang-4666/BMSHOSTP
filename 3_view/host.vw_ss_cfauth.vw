SET DEFINE OFF;
CREATE OR REPLACE FORCE VIEW VW_SS_CFAUTH
(CUSTODYCD, FULLNAME, IDCODE, IDDATE, IDPLACE, 
 VALDATE, EXPDATE, LINKAUTH)
BEQUEATH DEFINER
AS 
SELECT sbs."CUSTODYCD",sbs."FULLNAME",sbs."IDCODE",sbs."IDDATE",sbs."IDPLACE",sbs."VALDATE",sbs."EXPDATE",sbs."LINKAUTH" FROM cfauth flex, cfmast cf ,cfauthcv sbs
WHERE flex.cfcustid = cf.custid
AND cf.custodycd = sbs.custodycd(+)
AND sbs.custodycd IS NULL
/
