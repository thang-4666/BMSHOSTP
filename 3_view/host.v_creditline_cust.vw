SET DEFINE OFF;
CREATE OR REPLACE FORCE VIEW V_CREDITLINE_CUST
(CUSTODYCD)
BEQUEATH DEFINER
AS 
SELECT cf.custodycd
FROM cfmast cf, afmast af, aftype aft, mrtype mrt
WHERE aft.actype = af.actype
AND aft.mrtype = mrt.actype
AND cf.custid = af.custid
AND mrt.mrtype IN ('S','T')
/
