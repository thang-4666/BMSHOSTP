SET DEFINE OFF;DELETE FROM APPMAP WHERE 1 = 1 AND NVL(TLTXCD,'NULL') = NVL('2873','NULL');Insert into APPMAP   (TLTXCD, APPTYPE, APPTXCD, ACFLD, AMTEXP, COND, ACFLDREF, APPTYPEREF, FLDKEY, ISRUN, TRDESC, ODRNUM) Values   ('2873', 'FN', '9001', '03', '04', '', '', '', 'ACCTNO', '@1', '', 0);COMMIT;