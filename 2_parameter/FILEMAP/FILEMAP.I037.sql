SET DEFINE OFF;DELETE FROM FILEMAP WHERE 1 = 1 AND NVL(FILECODE,'NULL') = NVL('I037','NULL');Insert into FILEMAP   (FILECODE, FILEROWNAME, TBLROWNAME, TBLROWTYPE, ACCTNOFLD, TBLROWMAXLENGTH, CHANGETYPE, DELTD, DISABLED, VISIBLE, LSTODR, FIELDDESC, SUMAMT) Values   ('I037', 'SYMBOL', 'SYMBOL', 'C', '', 20, 'N', 'N', 'Y', 'Y', 2, 'Symbol', 'N');Insert into FILEMAP   (FILECODE, FILEROWNAME, TBLROWNAME, TBLROWTYPE, ACCTNOFLD, TBLROWMAXLENGTH, CHANGETYPE, DELTD, DISABLED, VISIBLE, LSTODR, FIELDDESC, SUMAMT) Values   ('I037', 'OUTWARD', 'OUTWARD', 'C', '', 3, 'N', 'N', 'Y', 'Y', 3, 'Chuyển từ', 'N');Insert into FILEMAP   (FILECODE, FILEROWNAME, TBLROWNAME, TBLROWTYPE, ACCTNOFLD, TBLROWMAXLENGTH, CHANGETYPE, DELTD, DISABLED, VISIBLE, LSTODR, FIELDDESC, SUMAMT) Values   ('I037', 'CUSTODYCD', 'CUSTODYCD', 'C', '', 10, 'N', 'N', 'Y', 'Y', 4, 'Số TK lưu ký', 'N');Insert into FILEMAP   (FILECODE, FILEROWNAME, TBLROWNAME, TBLROWTYPE, ACCTNOFLD, TBLROWMAXLENGTH, CHANGETYPE, DELTD, DISABLED, VISIBLE, LSTODR, FIELDDESC, SUMAMT) Values   ('I037', 'AFACCTNO', 'AFACCTNO', 'C', '', 16, 'N', 'N', 'Y', 'Y', 5, 'Số tiểu khoản ghi có', 'N');Insert into FILEMAP   (FILECODE, FILEROWNAME, TBLROWNAME, TBLROWTYPE, ACCTNOFLD, TBLROWMAXLENGTH, CHANGETYPE, DELTD, DISABLED, VISIBLE, LSTODR, FIELDDESC, SUMAMT) Values   ('I037', 'PRICE', 'PRICE', 'N', '', 11, 'N', 'N', 'Y', 'Y', 10, 'Giá chuyển khoản', 'N');Insert into FILEMAP   (FILECODE, FILEROWNAME, TBLROWNAME, TBLROWTYPE, ACCTNOFLD, TBLROWMAXLENGTH, CHANGETYPE, DELTD, DISABLED, VISIBLE, LSTODR, FIELDDESC, SUMAMT) Values   ('I037', 'CAQTTY', 'CAQTTY', 'N', '', 11, 'N', 'N', 'Y', 'Y', 11, 'Lượng chứng khoán', 'N');Insert into FILEMAP   (FILECODE, FILEROWNAME, TBLROWNAME, TBLROWTYPE, ACCTNOFLD, TBLROWMAXLENGTH, CHANGETYPE, DELTD, DISABLED, VISIBLE, LSTODR, FIELDDESC, SUMAMT) Values   ('I037', 'TRADE', 'TRADE', 'N', '', 11, 'N', 'N', 'Y', 'Y', 11, 'Lượng chứng khoán', 'N');Insert into FILEMAP   (FILECODE, FILEROWNAME, TBLROWNAME, TBLROWTYPE, ACCTNOFLD, TBLROWMAXLENGTH, CHANGETYPE, DELTD, DISABLED, VISIBLE, LSTODR, FIELDDESC, SUMAMT) Values   ('I037', 'BLOCKED', 'BLOCKED', 'N', '', 11, 'N', 'N', 'Y', 'Y', 11, 'Lượng chứng khoán', 'N');Insert into FILEMAP   (FILECODE, FILEROWNAME, TBLROWNAME, TBLROWTYPE, ACCTNOFLD, TBLROWMAXLENGTH, CHANGETYPE, DELTD, DISABLED, VISIBLE, LSTODR, FIELDDESC, SUMAMT) Values   ('I037', 'FILEID', 'FILEID', 'C', '', 250, 'U', 'N', 'Y', 'Y', 20, 'FILE code', 'N');Insert into FILEMAP   (FILECODE, FILEROWNAME, TBLROWNAME, TBLROWTYPE, ACCTNOFLD, TBLROWMAXLENGTH, CHANGETYPE, DELTD, DISABLED, VISIBLE, LSTODR, FIELDDESC, SUMAMT) Values   ('I037', 'DES', 'DES', 'C', '', 250, 'N', 'N', 'Y', 'Y', 20, 'Diễn giải', 'N');Insert into FILEMAP   (FILECODE, FILEROWNAME, TBLROWNAME, TBLROWTYPE, ACCTNOFLD, TBLROWMAXLENGTH, CHANGETYPE, DELTD, DISABLED, VISIBLE, LSTODR, FIELDDESC, SUMAMT) Values   ('I037', 'RECUSTODYCD', 'RECUSTODYCD', 'C', '', 250, 'U', 'N', 'Y', 'Y', 20, 'FILE code', 'N');Insert into FILEMAP   (FILECODE, FILEROWNAME, TBLROWNAME, TBLROWTYPE, ACCTNOFLD, TBLROWMAXLENGTH, CHANGETYPE, DELTD, DISABLED, VISIBLE, LSTODR, FIELDDESC, SUMAMT) Values   ('I037', 'RECUSTNAME', 'RECUSTNAME', 'C', '', 250, 'U', 'N', 'Y', 'Y', 20, 'FILE code', 'N');Insert into FILEMAP   (FILECODE, FILEROWNAME, TBLROWNAME, TBLROWTYPE, ACCTNOFLD, TBLROWMAXLENGTH, CHANGETYPE, DELTD, DISABLED, VISIBLE, LSTODR, FIELDDESC, SUMAMT) Values   ('I037', 'TYPE', 'TYPE', 'C', '', 6, 'U', 'N', 'Y', 'Y', 21, 'Loai chuyen san', 'N');Insert into FILEMAP   (FILECODE, FILEROWNAME, TBLROWNAME, TBLROWTYPE, ACCTNOFLD, TBLROWMAXLENGTH, CHANGETYPE, DELTD, DISABLED, VISIBLE, LSTODR, FIELDDESC, SUMAMT) Values   ('I037', 'TRTYPE', 'TRTYPE', 'C', '', 6, 'U', 'N', 'Y', 'Y', 22, 'Loai chuyen khoan', 'N');Insert into FILEMAP   (FILECODE, FILEROWNAME, TBLROWNAME, TBLROWTYPE, ACCTNOFLD, TBLROWMAXLENGTH, CHANGETYPE, DELTD, DISABLED, VISIBLE, LSTODR, FIELDDESC, SUMAMT) Values   ('I037', 'CUSTODYCD2', 'CUSTODYCD2', 'C', '', 10, 'U', 'N', 'Y', 'Y', 23, 'So TK LK', 'N');Insert into FILEMAP   (FILECODE, FILEROWNAME, TBLROWNAME, TBLROWTYPE, ACCTNOFLD, TBLROWMAXLENGTH, CHANGETYPE, DELTD, DISABLED, VISIBLE, LSTODR, FIELDDESC, SUMAMT) Values   ('I037', 'AFACCTNO2', 'AFACCTNO2', 'C', '', 16, 'U', 'N', 'Y', 'Y', 24, 'So tieu khoan ghi co', 'N');Insert into FILEMAP   (FILECODE, FILEROWNAME, TBLROWNAME, TBLROWTYPE, ACCTNOFLD, TBLROWMAXLENGTH, CHANGETYPE, DELTD, DISABLED, VISIBLE, LSTODR, FIELDDESC, SUMAMT) Values   ('I037', 'FULLNAME', 'FULLNAME', 'C', '', 50, 'U', 'N', 'Y', 'Y', 25, 'Ho ten tieu khoan ghi co', 'N');Insert into FILEMAP   (FILECODE, FILEROWNAME, TBLROWNAME, TBLROWTYPE, ACCTNOFLD, TBLROWMAXLENGTH, CHANGETYPE, DELTD, DISABLED, VISIBLE, LSTODR, FIELDDESC, SUMAMT) Values   ('I037', 'CRIDCODE', 'CRIDCODE', 'C', '', 50, 'U', 'N', 'Y', 'Y', 26, 'CMND tiểu khoản ghi có', 'N');Insert into FILEMAP   (FILECODE, FILEROWNAME, TBLROWNAME, TBLROWTYPE, ACCTNOFLD, TBLROWMAXLENGTH, CHANGETYPE, DELTD, DISABLED, VISIBLE, LSTODR, FIELDDESC, SUMAMT) Values   ('I037', 'CRIDDATE', 'CRIDDATE', 'C', '', 50, 'U', 'N', 'Y', 'Y', 27, 'Ngày cấp tiểu khoản ghi có', 'N');Insert into FILEMAP   (FILECODE, FILEROWNAME, TBLROWNAME, TBLROWTYPE, ACCTNOFLD, TBLROWMAXLENGTH, CHANGETYPE, DELTD, DISABLED, VISIBLE, LSTODR, FIELDDESC, SUMAMT) Values   ('I037', 'CRIDPLACE', 'CRIDPLACE', 'C', '', 100, 'U', 'N', 'Y', 'Y', 28, 'Nơi cấp tiểu khoản ghi có', 'N');Insert into FILEMAP   (FILECODE, FILEROWNAME, TBLROWNAME, TBLROWTYPE, ACCTNOFLD, TBLROWMAXLENGTH, CHANGETYPE, DELTD, DISABLED, VISIBLE, LSTODR, FIELDDESC, SUMAMT) Values   ('I037', 'CRIDADDRESS', 'CRIDADDRESS', 'C', '', 250, 'U', 'N', 'Y', 'Y', 29, 'Địa chỉ tiểu khoản ghi có', 'N');COMMIT;