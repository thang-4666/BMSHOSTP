SET DEFINE OFF;
CREATE OR REPLACE function fo_fn_encodeRefToString
(PV_REFCURSOR IN pkg_report.ref_cursor)
return VARCHAR2
as language java
name 'DBUtil.dumpResultSet(java.sql.ResultSet) return java.lang.String';
 
 
 
 
/
