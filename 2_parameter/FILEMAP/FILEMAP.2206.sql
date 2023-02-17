SET DEFINE OFF;DELETE FROM FILEMAP WHERE 1 = 1 AND NVL(FILECODE,'NULL') = NVL('2206','NULL');Insert into FILEMAP   (FILECODE, FILEROWNAME, TBLROWNAME, TBLROWTYPE, ACCTNOFLD, TBLROWMAXLENGTH, CHANGETYPE, DELTD, DISABLED, VISIBLE, LSTODR, FIELDDESC, SUMAMT) Values   ('2206', 'TXDATE', 'TXDATE', 'D', '', 20, 'N', 'N', 'Y', 'Y', 7, 'Ngày giao dịch', 'N');Insert into FILEMAP   (FILECODE, FILEROWNAME, TBLROWNAME, TBLROWTYPE, ACCTNOFLD, TBLROWMAXLENGTH, CHANGETYPE, DELTD, DISABLED, VISIBLE, LSTODR, FIELDDESC, SUMAMT) Values   ('2206', 'CUSTODYCD', 'CUSTODYCD', 'C', '', 20, 'N', 'N', 'Y', 'Y', 7, 'Tài khoản', 'N');Insert into FILEMAP   (FILECODE, FILEROWNAME, TBLROWNAME, TBLROWTYPE, ACCTNOFLD, TBLROWMAXLENGTH, CHANGETYPE, DELTD, DISABLED, VISIBLE, LSTODR, FIELDDESC, SUMAMT) Values   ('2206', 'ACCTNO', 'ACCTNO', 'C', '', 20, 'N', 'N', 'Y', 'Y', 7, 'Tiểu khoản', 'N');Insert into FILEMAP   (FILECODE, FILEROWNAME, TBLROWNAME, TBLROWTYPE, ACCTNOFLD, TBLROWMAXLENGTH, CHANGETYPE, DELTD, DISABLED, VISIBLE, LSTODR, FIELDDESC, SUMAMT) Values   ('2206', 'RFACCTNO', 'RFACCTNO', 'C', '', 20, 'N', 'N', 'Y', 'Y', 7, 'Số tài khoản quỹ', 'N');Insert into FILEMAP   (FILECODE, FILEROWNAME, TBLROWNAME, TBLROWTYPE, ACCTNOFLD, TBLROWMAXLENGTH, CHANGETYPE, DELTD, DISABLED, VISIBLE, LSTODR, FIELDDESC, SUMAMT) Values   ('2206', 'DEALTYPE', 'DEALTYPE', 'C', '', 20, 'N', 'N', 'Y', 'Y', 7, 'Loại lệnh', 'N');Insert into FILEMAP   (FILECODE, FILEROWNAME, TBLROWNAME, TBLROWTYPE, ACCTNOFLD, TBLROWMAXLENGTH, CHANGETYPE, DELTD, DISABLED, VISIBLE, LSTODR, FIELDDESC, SUMAMT) Values   ('2206', 'SYMBOL', 'SYMBOL', 'C', '', 20, 'N', 'N', 'Y', 'Y', 7, 'Mã chứng khoán', 'N');Insert into FILEMAP   (FILECODE, FILEROWNAME, TBLROWNAME, TBLROWTYPE, ACCTNOFLD, TBLROWMAXLENGTH, CHANGETYPE, DELTD, DISABLED, VISIBLE, LSTODR, FIELDDESC, SUMAMT) Values   ('2206', 'DES', 'DES', 'C', '', 20, 'N', 'N', 'Y', 'Y', 7, 'ghi chú', 'N');Insert into FILEMAP   (FILECODE, FILEROWNAME, TBLROWNAME, TBLROWTYPE, ACCTNOFLD, TBLROWMAXLENGTH, CHANGETYPE, DELTD, DISABLED, VISIBLE, LSTODR, FIELDDESC, SUMAMT) Values   ('2206', 'PRICE', 'PRICE', 'N', '', 20, 'N', 'N', 'Y', 'Y', 7, 'Giá', 'N');Insert into FILEMAP   (FILECODE, FILEROWNAME, TBLROWNAME, TBLROWTYPE, ACCTNOFLD, TBLROWMAXLENGTH, CHANGETYPE, DELTD, DISABLED, VISIBLE, LSTODR, FIELDDESC, SUMAMT) Values   ('2206', 'MADOI', 'MADOI', 'C', '', 20, 'N', 'N', 'Y', 'Y', 7, 'Mã đổi', 'N');Insert into FILEMAP   (FILECODE, FILEROWNAME, TBLROWNAME, TBLROWTYPE, ACCTNOFLD, TBLROWMAXLENGTH, CHANGETYPE, DELTD, DISABLED, VISIBLE, LSTODR, FIELDDESC, SUMAMT) Values   ('2206', 'KLCCQ', 'KLCCQ', 'N', '', 20, 'N', 'N', 'Y', 'Y', 7, 'KLCCQ', 'N');Insert into FILEMAP   (FILECODE, FILEROWNAME, TBLROWNAME, TBLROWTYPE, ACCTNOFLD, TBLROWMAXLENGTH, CHANGETYPE, DELTD, DISABLED, VISIBLE, LSTODR, FIELDDESC, SUMAMT) Values   ('2206', 'PHIEN', 'PHIEN', 'C', '', 20, 'N', 'N', 'Y', 'Y', 7, 'PHIEN', 'N');Insert into FILEMAP   (FILECODE, FILEROWNAME, TBLROWNAME, TBLROWTYPE, ACCTNOFLD, TBLROWMAXLENGTH, CHANGETYPE, DELTD, DISABLED, VISIBLE, LSTODR, FIELDDESC, SUMAMT) Values   ('2206', 'FEEAMT', 'FEEAMT', 'N', '', 20, 'N', 'N', 'Y', 'Y', 7, 'Phí', 'N');Insert into FILEMAP   (FILECODE, FILEROWNAME, TBLROWNAME, TBLROWTYPE, ACCTNOFLD, TBLROWMAXLENGTH, CHANGETYPE, DELTD, DISABLED, VISIBLE, LSTODR, FIELDDESC, SUMAMT) Values   ('2206', 'BRFEEAMT', 'BRFEEAMT', 'N', '', 20, 'N', 'N', 'Y', 'Y', 7, 'Phí hoa hồng', 'N');Insert into FILEMAP   (FILECODE, FILEROWNAME, TBLROWNAME, TBLROWTYPE, ACCTNOFLD, TBLROWMAXLENGTH, CHANGETYPE, DELTD, DISABLED, VISIBLE, LSTODR, FIELDDESC, SUMAMT) Values   ('2206', 'QTTY', 'QTTY', 'N', '', 20, 'N', 'N', 'Y', 'Y', 7, 'Khối lượng', 'N');COMMIT;