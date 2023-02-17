SET DEFINE OFF;DELETE FROM FILEMAP WHERE 1 = 1 AND NVL(FILECODE,'NULL') = NVL('I034','NULL');Insert into FILEMAP   (FILECODE, FILEROWNAME, TBLROWNAME, TBLROWTYPE, ACCTNOFLD, TBLROWMAXLENGTH, CHANGETYPE, DELTD, DISABLED, VISIBLE, LSTODR, FIELDDESC, SUMAMT) Values   ('I034', 'CUSTODYCD', 'CUSTODYCD', 'C', '', 10, 'N', 'N', 'Y', 'Y', 0, 'Số TK lưu ký', 'N');Insert into FILEMAP   (FILECODE, FILEROWNAME, TBLROWNAME, TBLROWTYPE, ACCTNOFLD, TBLROWMAXLENGTH, CHANGETYPE, DELTD, DISABLED, VISIBLE, LSTODR, FIELDDESC, SUMAMT) Values   ('I034', 'ACCTNO', 'ACCTNO', 'C', '', 16, 'N', 'N', 'Y', 'Y', 1, 'Số tiểu khoản', 'N');Insert into FILEMAP   (FILECODE, FILEROWNAME, TBLROWNAME, TBLROWTYPE, ACCTNOFLD, TBLROWMAXLENGTH, CHANGETYPE, DELTD, DISABLED, VISIBLE, LSTODR, FIELDDESC, SUMAMT) Values   ('I034', 'CUSTNAME', 'CUSTNAME', 'C', '', 50, 'N', 'N', 'Y', 'Y', 2, 'Họ tên', 'N');Insert into FILEMAP   (FILECODE, FILEROWNAME, TBLROWNAME, TBLROWTYPE, ACCTNOFLD, TBLROWMAXLENGTH, CHANGETYPE, DELTD, DISABLED, VISIBLE, LSTODR, FIELDDESC, SUMAMT) Values   ('I034', 'ADDRESS', 'ADDRESS', 'C', '', 50, 'N', 'N', 'Y', 'Y', 3, 'Địa chỉ', 'N');Insert into FILEMAP   (FILECODE, FILEROWNAME, TBLROWNAME, TBLROWTYPE, ACCTNOFLD, TBLROWMAXLENGTH, CHANGETYPE, DELTD, DISABLED, VISIBLE, LSTODR, FIELDDESC, SUMAMT) Values   ('I034', 'LICENSE', 'LICENSE', 'C', '', 50, 'N', 'N', 'Y', 'Y', 4, 'Số giấy tờ', 'N');Insert into FILEMAP   (FILECODE, FILEROWNAME, TBLROWNAME, TBLROWTYPE, ACCTNOFLD, TBLROWMAXLENGTH, CHANGETYPE, DELTD, DISABLED, VISIBLE, LSTODR, FIELDDESC, SUMAMT) Values   ('I034', 'IDDATE', 'IDDATE', 'D', '', 10, 'N', 'N', 'Y', 'Y', 5, 'Ngày cấp', 'N');Insert into FILEMAP   (FILECODE, FILEROWNAME, TBLROWNAME, TBLROWTYPE, ACCTNOFLD, TBLROWMAXLENGTH, CHANGETYPE, DELTD, DISABLED, VISIBLE, LSTODR, FIELDDESC, SUMAMT) Values   ('I034', 'IDPLACE', 'IDPLACE', 'C', '', 50, 'N', 'N', 'Y', 'Y', 6, 'Nơi cấp', 'N');Insert into FILEMAP   (FILECODE, FILEROWNAME, TBLROWNAME, TBLROWTYPE, ACCTNOFLD, TBLROWMAXLENGTH, CHANGETYPE, DELTD, DISABLED, VISIBLE, LSTODR, FIELDDESC, SUMAMT) Values   ('I034', 'AMT', 'AMT', 'N', '', 15, 'N', 'N', 'Y', 'Y', 10, 'Số tiền', 'N');Insert into FILEMAP   (FILECODE, FILEROWNAME, TBLROWNAME, TBLROWTYPE, ACCTNOFLD, TBLROWMAXLENGTH, CHANGETYPE, DELTD, DISABLED, VISIBLE, LSTODR, FIELDDESC, SUMAMT) Values   ('I034', 'REFNUM', 'REFNUM', 'C', '', 150, 'N', 'N', 'Y', 'Y', 11, 'Số chứng từ NH', 'N');Insert into FILEMAP   (FILECODE, FILEROWNAME, TBLROWNAME, TBLROWTYPE, ACCTNOFLD, TBLROWMAXLENGTH, CHANGETYPE, DELTD, DISABLED, VISIBLE, LSTODR, FIELDDESC, SUMAMT) Values   ('I034', 'DES', 'DES', 'C', '', 250, 'N', 'N', 'Y', 'Y', 12, 'Diễn giải', 'N');Insert into FILEMAP   (FILECODE, FILEROWNAME, TBLROWNAME, TBLROWTYPE, ACCTNOFLD, TBLROWMAXLENGTH, CHANGETYPE, DELTD, DISABLED, VISIBLE, LSTODR, FIELDDESC, SUMAMT) Values   ('I034', 'FILEID', 'FILEID', 'C', '', 250, 'U', 'N', 'Y', 'Y', 20, 'FILE code', 'N');COMMIT;