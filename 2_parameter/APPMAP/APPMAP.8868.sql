SET DEFINE OFF;DELETE FROM APPMAP WHERE 1 = 1 AND NVL(TLTXCD,'NULL') = NVL('8868','NULL');Insert into APPMAP   (TLTXCD, APPTYPE, APPTXCD, ACFLD, AMTEXP, COND, ACFLDREF, APPTYPEREF, FLDKEY, ISRUN, TRDESC, ODRNUM) Values   ('8868', 'CI', '0047', '05', '08', '', '03', 'CI', 'ACCTNO', '@1', '', 0);Insert into APPMAP   (TLTXCD, APPTYPE, APPTXCD, ACFLD, AMTEXP, COND, ACFLDREF, APPTYPEREF, FLDKEY, ISRUN, TRDESC, ODRNUM) Values   ('8868', 'OD', '', '', '', '', '03', '', '', '@1', '', 0);Insert into APPMAP   (TLTXCD, APPTYPE, APPTXCD, ACFLD, AMTEXP, COND, ACFLDREF, APPTYPEREF, FLDKEY, ISRUN, TRDESC, ODRNUM) Values   ('8868', 'OD', '0013', '03', '08--08', '', '03', 'OD', 'ORDERID', '@1', '', 0);Insert into APPMAP   (TLTXCD, APPTYPE, APPTXCD, ACFLD, AMTEXP, COND, ACFLDREF, APPTYPEREF, FLDKEY, ISRUN, TRDESC, ODRNUM) Values   ('8868', 'SE', '0045', '06', '11', '', '03', 'SE', 'ACCTNO', '@1', '', 0);Insert into APPMAP   (TLTXCD, APPTYPE, APPTXCD, ACFLD, AMTEXP, COND, ACFLDREF, APPTYPEREF, FLDKEY, ISRUN, TRDESC, ODRNUM) Values   ('8868', 'SE', '0015', '06', '11', '', '03', 'SE', 'ACCTNO', '@1', '', 0);COMMIT;