SET DEFINE OFF;DELETE FROM FILEMAP WHERE 1 = 1 AND NVL(FILECODE,'NULL') = NVL('I045','NULL');Insert into FILEMAP   (FILECODE, FILEROWNAME, TBLROWNAME, TBLROWTYPE, ACCTNOFLD, TBLROWMAXLENGTH, CHANGETYPE, DELTD, DISABLED, VISIBLE, LSTODR, FIELDDESC, SUMAMT) Values   ('I045', 'IDCODE', 'IDCODE', 'C', '', 10, 'N', 'N', 'Y', 'Y', 0, 'CMND/Hộ Chiếu', 'N');Insert into FILEMAP   (FILECODE, FILEROWNAME, TBLROWNAME, TBLROWTYPE, ACCTNOFLD, TBLROWMAXLENGTH, CHANGETYPE, DELTD, DISABLED, VISIBLE, LSTODR, FIELDDESC, SUMAMT) Values   ('I045', 'TRANTYPE', 'TRANTYPE', 'C', '', 16, 'N', 'N', 'Y', 'Y', 1, 'Loại giao dịch', 'N');Insert into FILEMAP   (FILECODE, FILEROWNAME, TBLROWNAME, TBLROWTYPE, ACCTNOFLD, TBLROWMAXLENGTH, CHANGETYPE, DELTD, DISABLED, VISIBLE, LSTODR, FIELDDESC, SUMAMT) Values   ('I045', 'BANKID', 'BANKID', 'C', '', 50, 'N', 'N', 'Y', 'Y', 2, 'Mã ngân hàng', 'N');Insert into FILEMAP   (FILECODE, FILEROWNAME, TBLROWNAME, TBLROWTYPE, ACCTNOFLD, TBLROWMAXLENGTH, CHANGETYPE, DELTD, DISABLED, VISIBLE, LSTODR, FIELDDESC, SUMAMT) Values   ('I045', 'IORO', 'IORO', 'C', '', 50, 'N', 'N', 'Y', 'Y', 3, 'Kiểu phí', 'N');Insert into FILEMAP   (FILECODE, FILEROWNAME, TBLROWNAME, TBLROWTYPE, ACCTNOFLD, TBLROWMAXLENGTH, CHANGETYPE, DELTD, DISABLED, VISIBLE, LSTODR, FIELDDESC, SUMAMT) Values   ('I045', 'FEECD', 'FEECD', 'C', '', 50, 'N', 'N', 'Y', 'Y', 4, 'Biểu phí', 'N');Insert into FILEMAP   (FILECODE, FILEROWNAME, TBLROWNAME, TBLROWTYPE, ACCTNOFLD, TBLROWMAXLENGTH, CHANGETYPE, DELTD, DISABLED, VISIBLE, LSTODR, FIELDDESC, SUMAMT) Values   ('I045', 'AMT', 'AMT', 'N', '', 15, 'N', 'N', 'Y', 'Y', 5, 'Số tiền', 'N');Insert into FILEMAP   (FILECODE, FILEROWNAME, TBLROWNAME, TBLROWTYPE, ACCTNOFLD, TBLROWMAXLENGTH, CHANGETYPE, DELTD, DISABLED, VISIBLE, LSTODR, FIELDDESC, SUMAMT) Values   ('I045', 'BENEFCUSTNAME', 'BENEFCUSTNAME', 'C', '', 50, 'N', 'N', 'Y', 'Y', 6, 'Tên KH thụ hưởng', 'N');Insert into FILEMAP   (FILECODE, FILEROWNAME, TBLROWNAME, TBLROWTYPE, ACCTNOFLD, TBLROWMAXLENGTH, CHANGETYPE, DELTD, DISABLED, VISIBLE, LSTODR, FIELDDESC, SUMAMT) Values   ('I045', 'BENEFACCT', 'BENEFACCT', 'C', '', 150, 'N', 'N', 'Y', 'Y', 11, 'Số TK thụ hưởng', 'N');Insert into FILEMAP   (FILECODE, FILEROWNAME, TBLROWNAME, TBLROWTYPE, ACCTNOFLD, TBLROWMAXLENGTH, CHANGETYPE, DELTD, DISABLED, VISIBLE, LSTODR, FIELDDESC, SUMAMT) Values   ('I045', 'BENEFBANK', 'BENEFBANK', 'C', '', 150, 'N', 'N', 'Y', 'Y', 11, 'Tên NH thụ hưởng', 'N');Insert into FILEMAP   (FILECODE, FILEROWNAME, TBLROWNAME, TBLROWTYPE, ACCTNOFLD, TBLROWMAXLENGTH, CHANGETYPE, DELTD, DISABLED, VISIBLE, LSTODR, FIELDDESC, SUMAMT) Values   ('I045', 'CITYBANK', 'CITYBANK', 'C', '', 50, 'N', 'N', 'Y', 'Y', 11, 'Chi nhánh', 'N');Insert into FILEMAP   (FILECODE, FILEROWNAME, TBLROWNAME, TBLROWTYPE, ACCTNOFLD, TBLROWMAXLENGTH, CHANGETYPE, DELTD, DISABLED, VISIBLE, LSTODR, FIELDDESC, SUMAMT) Values   ('I045', 'CITYEF', 'CITYEF', 'C', '', 50, 'N', 'N', 'Y', 'Y', 11, 'Thành phố', 'N');Insert into FILEMAP   (FILECODE, FILEROWNAME, TBLROWNAME, TBLROWTYPE, ACCTNOFLD, TBLROWMAXLENGTH, CHANGETYPE, DELTD, DISABLED, VISIBLE, LSTODR, FIELDDESC, SUMAMT) Values   ('I045', 'DESCRIPTION', 'DESCRIPTION', 'C', '', 250, 'N', 'N', 'Y', 'Y', 12, 'Diễn giải', 'N');Insert into FILEMAP   (FILECODE, FILEROWNAME, TBLROWNAME, TBLROWTYPE, ACCTNOFLD, TBLROWMAXLENGTH, CHANGETYPE, DELTD, DISABLED, VISIBLE, LSTODR, FIELDDESC, SUMAMT) Values   ('I045', 'FILEID', 'FILEID', 'C', '', 250, 'U', 'N', 'Y', 'Y', 20, 'FILE code', 'N');COMMIT;