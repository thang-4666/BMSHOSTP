SET DEFINE OFF;
CREATE OR REPLACE FORCE VIEW VW_TYPE
(TYPE, ACTYPE, TYPENAME)
BEQUEATH DEFINER
AS 
SELECT 'AFTYPE' TYPE, to_char(actype) actype, to_char(typename) typename FROM aftype
UNION ALL
SELECT 'CITYPE' TYPE, to_char(actype) actype, to_char(typename) typename FROM CITYPE
UNION ALL
SELECT 'SETYPE' TYPE, to_char(actype) actype, to_char(typename) typename FROM SETYPE
UNION ALL
SELECT 'ODTYPE' TYPE, to_char(actype) actype, to_char(typename) typename FROM ODTYPE
UNION ALL
SELECT 'MRTYPE' TYPE, to_char(actype) actype, to_char(typename) typename FROM MRTYPE
UNION ALL
SELECT 'CLTYPE' TYPE, to_char(actype) actype, to_char(typename) typename FROM CLTYPE
UNION ALL
SELECT 'LNTYPE' TYPE, to_char(actype) actype, to_char(typename) typename FROM LNTYPE
UNION ALL
SELECT 'DFTYPE' TYPE, to_char(actype) actype, to_char(typename) typename FROM DFTYPE
UNION ALL
SELECT 'ADTYPE' TYPE, to_char(actype) actype, to_char(typename) typename FROM ADTYPE
union all
SELECT 'AFTYPE' TYPE, 'ALL' actype, 'Tat ca' typename FROM dual
UNION ALL
SELECT 'CITYPE' TYPE, 'ALL' actype, 'Tat ca' typename FROM dual
UNION ALL
SELECT 'SETYPE' TYPE, 'ALL' actype, 'Tat ca' typename FROM dual
UNION ALL
SELECT 'ODTYPE' TYPE, 'ALL' actype, 'Tat ca' typename FROM dual
UNION ALL
SELECT 'MRTYPE' TYPE, 'ALL' actype, 'Tat ca' typename FROM dual
UNION ALL
SELECT 'CLTYPE' TYPE, 'ALL' actype, 'Tat ca' typename FROM dual
UNION ALL
SELECT 'LNTYPE' TYPE, 'ALL' actype, 'Tat ca' typename FROM dual
UNION ALL
SELECT 'DFTYPE' TYPE, 'ALL' actype, 'Tat ca' typename FROM dual
UNION ALL
SELECT 'ADTYPE' TYPE, 'ALL' actype, 'Tat ca' typename FROM dual
UNION ALL
SELECT 'SYSTEM' TYPE, 'ALL' actype, 'Tat ca' typename FROM dual
/
