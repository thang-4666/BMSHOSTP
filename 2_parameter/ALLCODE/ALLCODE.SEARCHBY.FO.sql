SET DEFINE OFF;DELETE FROM ALLCODE WHERE 1 = 1 AND NVL(CDNAME,'NULL') = NVL('SEARCHBY','NULL') AND NVL(CDTYPE,'NULL') = NVL('FO','NULL');Insert into ALLCODE   (CDTYPE, CDNAME, CDVAL, CDCONTENT, LSTODR, CDUSER, EN_CDCONTENT, CHSTATUS) Values   ('FO', 'SEARCHBY', 'CCD', 'Số TK lưu ký', 0, 'Y', 'Số TK lưu ký', 'C');Insert into ALLCODE   (CDTYPE, CDNAME, CDVAL, CDCONTENT, LSTODR, CDUSER, EN_CDCONTENT, CHSTATUS) Values   ('FO', 'SEARCHBY', 'CID', 'Mã khách hàng', 1, 'Y', 'Mã khách hàng', 'C');COMMIT;