SET DEFINE OFF;DELETE FROM APPMAP WHERE 1 = 1 AND NVL(TLTXCD,'NULL') = NVL('8842','NULL');Insert into APPMAP   (TLTXCD, APPTYPE, APPTXCD, ACFLD, AMTEXP, COND, ACFLDREF, APPTYPEREF, FLDKEY, ISRUN, TRDESC, ODRNUM) Values   ('8842', 'CI', '0011', '03', '10', '', '01', 'OD', 'ACCTNO', '@1', 'Hoàn trả ứng trước tiền bán lệnh bán lỗi', 0);Insert into APPMAP   (TLTXCD, APPTYPE, APPTXCD, ACFLD, AMTEXP, COND, ACFLDREF, APPTYPEREF, FLDKEY, ISRUN, TRDESC, ODRNUM) Values   ('8842', 'CI', '0012', '03', '11', '', '01', 'OD', 'ACCTNO', '@1', 'Hoàn trả phí ứng trước tiền bán lệnh bán lỗi', 0);Insert into APPMAP   (TLTXCD, APPTYPE, APPTXCD, ACFLD, AMTEXP, COND, ACFLDREF, APPTYPEREF, FLDKEY, ISRUN, TRDESC, ODRNUM) Values   ('8842', 'CI', '0032', '03', '10', '', '01', 'OD', 'ACCTNO', '@1', '', 0);Insert into APPMAP   (TLTXCD, APPTYPE, APPTXCD, ACFLD, AMTEXP, COND, ACFLDREF, APPTYPEREF, FLDKEY, ISRUN, TRDESC, ODRNUM) Values   ('8842', 'CI', '0013', '03', '10--11', '', '01', 'OD', 'ACCTNO', '@1', '', 0);COMMIT;