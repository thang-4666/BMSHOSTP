SET DEFINE OFF;DELETE FROM ALLCODE WHERE 1 = 1 AND NVL(CDNAME,'NULL') = NVL('DRTRATYPE','NULL') AND NVL(CDTYPE,'NULL') = NVL('SA','NULL');Insert into ALLCODE   (CDTYPE, CDNAME, CDVAL, CDCONTENT, LSTODR, CDUSER, EN_CDCONTENT, CHSTATUS) Values   ('SA', 'DRTRATYPE', '001', 'Chuyển tiền cổ tức', 0, 'Y', 'Chuyển tiền cổ tức', 'C');Insert into ALLCODE   (CDTYPE, CDNAME, CDVAL, CDCONTENT, LSTODR, CDUSER, EN_CDCONTENT, CHSTATUS) Values   ('SA', 'DRTRATYPE', '002', 'Chuyển tiền cọc không trúng đấu giá', 1, 'Y', 'Chuyển tiền cọc không trúng đấu giá', 'C');Insert into ALLCODE   (CDTYPE, CDNAME, CDVAL, CDCONTENT, LSTODR, CDUSER, EN_CDCONTENT, CHSTATUS) Values   ('SA', 'DRTRATYPE', '004', 'Chuyển tiền KH đăng ký mua PHT cho VSD', 2, 'Y', 'Chuyển tiền KH đăng ký mua PHT cho VSD', 'C');Insert into ALLCODE   (CDTYPE, CDNAME, CDVAL, CDCONTENT, LSTODR, CDUSER, EN_CDCONTENT, CHSTATUS) Values   ('SA', 'DRTRATYPE', '013', 'Chi phí dịch vụ ngân hàng cho hoạt động môi giới', 3, 'Y', 'Chi phí dịch vụ ngân hàng cho hoạt động môi giới', 'C');Insert into ALLCODE   (CDTYPE, CDNAME, CDVAL, CDCONTENT, LSTODR, CDUSER, EN_CDCONTENT, CHSTATUS) Values   ('SA', 'DRTRATYPE', '015', 'Chuyển tiền KH đấu giá IPO cho TCPH - Sở GD', 4, 'Y', 'Chuyển tiền KH đấu giá IPO cho TCPH - Sở GD', 'C');Insert into ALLCODE   (CDTYPE, CDNAME, CDVAL, CDCONTENT, LSTODR, CDUSER, EN_CDCONTENT, CHSTATUS) Values   ('SA', 'DRTRATYPE', '016', 'Chuyển tiền KH nộp thừa', 5, 'Y', 'Chuyển tiền KH nộp thừa', 'C');Insert into ALLCODE   (CDTYPE, CDNAME, CDVAL, CDCONTENT, LSTODR, CDUSER, EN_CDCONTENT, CHSTATUS) Values   ('SA', 'DRTRATYPE', '010', 'Điều chuyển vốn TK KH - KH', 9, 'Y', 'Điều chuyển vốn TK KH - KH', 'C');Insert into ALLCODE   (CDTYPE, CDNAME, CDVAL, CDCONTENT, LSTODR, CDUSER, EN_CDCONTENT, CHSTATUS) Values   ('SA', 'DRTRATYPE', '017', 'Điều chuyển vốn TK KH - CTY', 10, 'Y', 'Điều chuyển vốn TK KH - CTY', 'C');Insert into ALLCODE   (CDTYPE, CDNAME, CDVAL, CDCONTENT, LSTODR, CDUSER, EN_CDCONTENT, CHSTATUS) Values   ('SA', 'DRTRATYPE', '019', 'PGD Giảng Võ test', 12, 'Y', 'PGD Giảng Võ test', 'C');Insert into ALLCODE   (CDTYPE, CDNAME, CDVAL, CDCONTENT, LSTODR, CDUSER, EN_CDCONTENT, CHSTATUS) Values   ('SA', 'DRTRATYPE', '030', 'Khác', 13, 'Y', 'Khác', 'C');COMMIT;