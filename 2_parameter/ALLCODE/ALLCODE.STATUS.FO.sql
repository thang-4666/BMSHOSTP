SET DEFINE OFF;DELETE FROM ALLCODE WHERE 1 = 1 AND NVL(CDNAME,'NULL') = NVL('STATUS','NULL') AND NVL(CDTYPE,'NULL') = NVL('FO','NULL');Insert into ALLCODE   (CDTYPE, CDNAME, CDVAL, CDCONTENT, LSTODR, CDUSER, EN_CDCONTENT, CHSTATUS) Values   ('FO', 'STATUS', 'P', 'Chờ xử lý', 0, 'Y', 'Chờ xử lý', 'C');Insert into ALLCODE   (CDTYPE, CDNAME, CDVAL, CDCONTENT, LSTODR, CDUSER, EN_CDCONTENT, CHSTATUS) Values   ('FO', 'STATUS', 'I', 'Không hoạt động', 0, 'Y', 'Không hoạt động', 'C');Insert into ALLCODE   (CDTYPE, CDNAME, CDVAL, CDCONTENT, LSTODR, CDUSER, EN_CDCONTENT, CHSTATUS) Values   ('FO', 'STATUS', 'A', 'Hoạt động', 2, 'Y', 'Hoạt động', 'C');Insert into ALLCODE   (CDTYPE, CDNAME, CDVAL, CDCONTENT, LSTODR, CDUSER, EN_CDCONTENT, CHSTATUS) Values   ('FO', 'STATUS', 'R', 'Hủy bỏ', 3, 'Y', 'Hủy bỏ', 'C');Insert into ALLCODE   (CDTYPE, CDNAME, CDVAL, CDCONTENT, LSTODR, CDUSER, EN_CDCONTENT, CHSTATUS) Values   ('FO', 'STATUS', 'E', 'Hết hạn', 4, 'Y', 'Hết hạn', 'C');Insert into ALLCODE   (CDTYPE, CDNAME, CDVAL, CDCONTENT, LSTODR, CDUSER, EN_CDCONTENT, CHSTATUS) Values   ('FO', 'STATUS', 'C', 'Đóng', 5, 'Y', 'Đóng', 'C');Insert into ALLCODE   (CDTYPE, CDNAME, CDVAL, CDCONTENT, LSTODR, CDUSER, EN_CDCONTENT, CHSTATUS) Values   ('FO', 'STATUS', 'W', 'Chờ ký quỹ ngân hàng', 6, 'Y', 'Chờ ký quỹ ngân hàng', 'C');COMMIT;