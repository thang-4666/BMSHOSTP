SET DEFINE OFF;DELETE FROM CRBTXMAPEXT WHERE 1 = 1 AND NVL(OBJNAME,'NULL') = NVL('1181','NULL');Insert into CRBTXMAPEXT   (OBJTYPE, OBJNAME, TRFCODE, FLDNAME, FLDTYPE, AMTEXP, CMDSQL) Values   ('T', '1181', 'TRFSEFEE', 'CUSTODYCD', 'C', '$88', '');Insert into CRBTXMAPEXT   (OBJTYPE, OBJNAME, TRFCODE, FLDNAME, FLDTYPE, AMTEXP, CMDSQL) Values   ('T', '1181', 'TRFSEFEE', 'ACCTNO', 'C', '$03', '');Insert into CRBTXMAPEXT   (OBJTYPE, OBJNAME, TRFCODE, FLDNAME, FLDTYPE, AMTEXP, CMDSQL) Values   ('T', '1181', 'TRFSEFEE', 'CUSTNAME', 'C', '$90', '');COMMIT;