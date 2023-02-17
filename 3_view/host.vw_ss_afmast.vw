SET DEFINE OFF;
CREATE OR REPLACE FORCE VIEW VW_SS_AFMAST
(DESCRIPTION)
BEQUEATH DEFINER
AS 
SELECT sbs."DESCRIPTION" FROM 
(SELECT custodycd ||accounttype description FROM afmastcv )sbs,
(SELECT CF.CUSTODYCD||CASE WHEN AFTYPE.mnemonic='T3' THEN 'T' WHEN  AFTYPE.mnemonic='Margin' THEN 'M' ELSE 'C' END description
FROM afmast af, aftype ,cfmast cf 
WHERE af.actype= aftype.actype
AND af.custid = cf.custid )flex
WHERE sbs.description = flex.description(+)
AND  flex.description is NULL
/
