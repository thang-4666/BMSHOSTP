SET DEFINE OFF;DELETE FROM APPMAP WHERE 1 = 1 AND NVL(TLTXCD,'NULL') = NVL('1114','NULL');Insert into APPMAP   (TLTXCD, APPTYPE, APPTXCD, ACFLD, AMTEXP, COND, ACFLDREF, APPTYPEREF, FLDKEY, ISRUN, TRDESC, ODRNUM) Values   ('1114', 'CI', '0043', '03', '10', '', '67', '', 'ACCTNO', '@1', '', 0);Insert into APPMAP   (TLTXCD, APPTYPE, APPTXCD, ACFLD, AMTEXP, COND, ACFLDREF, APPTYPEREF, FLDKEY, ISRUN, TRDESC, ODRNUM) Values   ('1114', 'CI', '0030', '03', '<$BUSDATE>', '', '', '', 'ACCTNO', '@1', '', 0);Insert into APPMAP   (TLTXCD, APPTYPE, APPTXCD, ACFLD, AMTEXP, COND, ACFLDREF, APPTYPEREF, FLDKEY, ISRUN, TRDESC, ODRNUM) Values   ('1114', 'CI', '0012', '03', '10', '', '67', '', 'ACCTNO', '@1', '', 0);Insert into APPMAP   (TLTXCD, APPTYPE, APPTXCD, ACFLD, AMTEXP, COND, ACFLDREF, APPTYPEREF, FLDKEY, ISRUN, TRDESC, ODRNUM) Values   ('1114', 'CI', '0012', '03', '11**09', '', '67', '', 'ACCTNO', '@1', 'Hoàn phí chuyển khoản tiền ra ngân hàng', 0);Insert into APPMAP   (TLTXCD, APPTYPE, APPTXCD, ACFLD, AMTEXP, COND, ACFLDREF, APPTYPEREF, FLDKEY, ISRUN, TRDESC, ODRNUM) Values   ('1114', 'CI', '0012', '03', '12**09', '', '67', '', 'ACCTNO', '@1', 'Hoàn thuế chuyển khoản tiền ra ngân hàng', 0);COMMIT;