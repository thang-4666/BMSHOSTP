SET DEFINE OFF;DELETE FROM CRBTXMAP WHERE 1 = 1 AND NVL(OBJNAME,'NULL') = NVL('1183','NULL');Insert into CRBTXMAP   (OBJTYPE, OBJNAME, TRFCODE, FLDBANK, FLDACCTNO, FLDBANKACCT, FLDREFCODE, FLDNOTES, AMTEXP, AFFECTDATE, SUBCOREBANK, AUTOGENRPT, GRPTRFCODE) Values   ('T', '1183', 'TRFSEFEE', '$95', '$03', '$93', '', '$30', '10', '', 'N', 'N', '');COMMIT;