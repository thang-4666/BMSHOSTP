SET DEFINE OFF;
CREATE OR REPLACE FORCE VIEW VW_CRBTXREQDTL_ALL
(AUTOID, REQID, FLDNAME, CVAL, NVAL)
BEQUEATH DEFINER
AS 
(
SELECT autoid, reqid, fldname, cval, nval  FROM crbtxreqdtl
UNION ALL
SELECT autoid, reqid, fldname, cval, nval  FROM crbtxreqdtlHIST)
/
