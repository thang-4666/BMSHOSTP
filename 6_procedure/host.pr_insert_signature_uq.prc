SET DEFINE OFF;
CREATE OR REPLACE PROCEDURE pr_insert_signature_UQ(V_ACCTNO varchar2,V_SIGNATURE CLOB )
 IS
   BEGIN
      UPDATE cfauth SET signature =V_SIGNATURE WHERE cfcustid = V_ACCTNO ;
   END ;




-- End of DDL Script for Procedure HOST.PR_INSERT_SIGNATURE
 
 
 
 
 
 
 
 
 
 
 
 
 
/
