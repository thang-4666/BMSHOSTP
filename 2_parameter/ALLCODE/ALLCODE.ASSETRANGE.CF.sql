SET DEFINE OFF;DELETE FROM ALLCODE WHERE 1 = 1 AND NVL(CDNAME,'NULL') = NVL('ASSETRANGE','NULL') AND NVL(CDTYPE,'NULL') = NVL('CF','NULL');Insert into ALLCODE   (CDTYPE, CDNAME, CDVAL, CDCONTENT, LSTODR, CDUSER, EN_CDCONTENT, CHSTATUS) Values   ('CF', 'ASSETRANGE', '000', 'Khác', 0, 'Y', 'Khác', 'C');Insert into ALLCODE   (CDTYPE, CDNAME, CDVAL, CDCONTENT, LSTODR, CDUSER, EN_CDCONTENT, CHSTATUS) Values   ('CF', 'ASSETRANGE', '001', '< 1 tỷ', 1, 'Y', '< 1 tỷ', 'C');Insert into ALLCODE   (CDTYPE, CDNAME, CDVAL, CDCONTENT, LSTODR, CDUSER, EN_CDCONTENT, CHSTATUS) Values   ('CF', 'ASSETRANGE', '002', 'Từ 1 - 3 tỷ', 2, 'Y', 'Từ 1 - 3 tỷ', 'C');Insert into ALLCODE   (CDTYPE, CDNAME, CDVAL, CDCONTENT, LSTODR, CDUSER, EN_CDCONTENT, CHSTATUS) Values   ('CF', 'ASSETRANGE', '003', 'Từ 3 - 5 tỷ', 3, 'Y', 'Từ 3 - 5 tỷ', 'C');Insert into ALLCODE   (CDTYPE, CDNAME, CDVAL, CDCONTENT, LSTODR, CDUSER, EN_CDCONTENT, CHSTATUS) Values   ('CF', 'ASSETRANGE', '004', '> 5 tỷ', 4, 'Y', '> 5 tỷ', 'C');COMMIT;