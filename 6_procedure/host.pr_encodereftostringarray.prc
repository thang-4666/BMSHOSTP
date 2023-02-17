SET DEFINE OFF;
CREATE OR REPLACE procedure pr_encodeRefToStringArray
(PV_REFCURSOR IN pkg_report.ref_cursor,maxRow IN NUMBER, maxPage IN NUMBER,vReturnArray OUT SimpleStringArrayType)
as language java
name 'DBUtil.dumpResultSetToArray(java.sql.ResultSet,int,int,oracle.sql.ARRAY[])';

 
 
 
 
/
