SET DEFINE OFF;DELETE FROM CRBTXMAPEXT WHERE 1 = 1 AND NVL(OBJNAME,'NULL') = NVL('2664','NULL');Insert into CRBTXMAPEXT   (OBJTYPE, OBJNAME, TRFCODE, FLDNAME, FLDTYPE, AMTEXP, CMDSQL) Values   ('T', '2664', 'TRFDFPAYMENT', 'CUSTODYCD', 'C', '$88', '');Insert into CRBTXMAPEXT   (OBJTYPE, OBJNAME, TRFCODE, FLDNAME, FLDTYPE, AMTEXP, CMDSQL) Values   ('T', '2664', 'TRFDFPAYMENT', 'AFACCTNO', 'C', '$03', '');Insert into CRBTXMAPEXT   (OBJTYPE, OBJNAME, TRFCODE, FLDNAME, FLDTYPE, AMTEXP, CMDSQL) Values   ('T', '2664', 'TRFDFPAYMENT', 'CUSTNAME', 'C', '$90', '');COMMIT;