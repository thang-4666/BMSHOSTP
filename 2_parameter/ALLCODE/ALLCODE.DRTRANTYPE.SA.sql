SET DEFINE OFF;DELETE FROM ALLCODE WHERE 1 = 1 AND NVL(CDNAME,'NULL') = NVL('DRTRANTYPE','NULL') AND NVL(CDTYPE,'NULL') = NVL('SA','NULL');Insert into ALLCODE   (CDTYPE, CDNAME, CDVAL, CDCONTENT, LSTODR, CDUSER, EN_CDCONTENT, CHSTATUS) Values   ('SA', 'DRTRANTYPE', '001', 'Lĩnh tiền cổ tức', 0, 'Y', 'Lĩnh tiền cổ tức', 'C');Insert into ALLCODE   (CDTYPE, CDNAME, CDVAL, CDCONTENT, LSTODR, CDUSER, EN_CDCONTENT, CHSTATUS) Values   ('SA', 'DRTRANTYPE', '002', 'Rút tiền cọc đấu giá', 1, 'Y', 'Rút tiền cọc đấu giá', 'C');Insert into ALLCODE   (CDTYPE, CDNAME, CDVAL, CDCONTENT, LSTODR, CDUSER, EN_CDCONTENT, CHSTATUS) Values   ('SA', 'DRTRANTYPE', '003', 'Xuất quỹ cuối ngày', 2, 'Y', 'Xuất quỹ cuối ngày', 'C');Insert into ALLCODE   (CDTYPE, CDNAME, CDVAL, CDCONTENT, LSTODR, CDUSER, EN_CDCONTENT, CHSTATUS) Values   ('SA', 'DRTRANTYPE', '004', 'Chuyển tiền PHT', 3, 'Y', 'Chuyển tiền PHT', 'C');Insert into ALLCODE   (CDTYPE, CDNAME, CDVAL, CDCONTENT, LSTODR, CDUSER, EN_CDCONTENT, CHSTATUS) Values   ('SA', 'DRTRANTYPE', '005', 'Chuyển tiền đấu giá', 4, 'Y', 'Chuyển tiền đấu giá', 'C');Insert into ALLCODE   (CDTYPE, CDNAME, CDVAL, CDCONTENT, LSTODR, CDUSER, EN_CDCONTENT, CHSTATUS) Values   ('SA', 'DRTRANTYPE', '006', 'Chuyển tiền phí chuyển nhượng cho VSD', 5, 'Y', 'Chuyển tiền phí chuyển nhượng cho VSD', 'C');Insert into ALLCODE   (CDTYPE, CDNAME, CDVAL, CDCONTENT, LSTODR, CDUSER, EN_CDCONTENT, CHSTATUS) Values   ('SA', 'DRTRANTYPE', '007', 'Chuyển tiền TTBT giữa hội sở và chi nhánh  ', 6, 'Y', 'Chuyển tiền TTBT giữa hội sở và chi nhánh  ', 'C');Insert into ALLCODE   (CDTYPE, CDNAME, CDVAL, CDCONTENT, LSTODR, CDUSER, EN_CDCONTENT, CHSTATUS) Values   ('SA', 'DRTRANTYPE', '008', 'Bù trừ PHT giữa hộ sở và chi nhánh', 7, 'Y', 'Bù trừ PHT giữa hộ sở và chi nhánh', 'C');Insert into ALLCODE   (CDTYPE, CDNAME, CDVAL, CDCONTENT, LSTODR, CDUSER, EN_CDCONTENT, CHSTATUS) Values   ('SA', 'DRTRANTYPE', '009', 'Bù trừ tiền cổ tức giữa hội sở và chi nhánh', 8, 'Y', 'Bù trừ tiền cổ tức giữa hội sở và chi nhánh', 'C');Insert into ALLCODE   (CDTYPE, CDNAME, CDVAL, CDCONTENT, LSTODR, CDUSER, EN_CDCONTENT, CHSTATUS) Values   ('SA', 'DRTRANTYPE', '010', 'Chi phí dịch vụ NH cho hoạt động môi giới', 9, 'Y', 'Chi phí dịch vụ NH cho hoạt động môi giới', 'C');Insert into ALLCODE   (CDTYPE, CDNAME, CDVAL, CDCONTENT, LSTODR, CDUSER, EN_CDCONTENT, CHSTATUS) Values   ('SA', 'DRTRANTYPE', '011', 'Chuyển tiền từ tk tiền gửi tự động sang tk tiền tửi thanh toán', 10, 'Y', 'Chuyển tiền từ tk tiền gửi tự động sang tk tiền tửi thanh toán', 'C');Insert into ALLCODE   (CDTYPE, CDNAME, CDVAL, CDCONTENT, LSTODR, CDUSER, EN_CDCONTENT, CHSTATUS) Values   ('SA', 'DRTRANTYPE', '012', 'Chuyển tiền từ tk tiền gửi thanh toán sang tk tiền gửi tự động', 11, 'Y', 'Chuyển tiền từ tk tiền gửi thanh toán sang tk tiền gửi tự động', 'C');Insert into ALLCODE   (CDTYPE, CDNAME, CDVAL, CDCONTENT, LSTODR, CDUSER, EN_CDCONTENT, CHSTATUS) Values   ('SA', 'DRTRANTYPE', '014', 'Bù trừ tiền đấu giá giữa hội sở và chi nhánh', 12, 'Y', 'Bù trừ tiền đấu giá giữa hội sở và chi nhánh', 'C');Insert into ALLCODE   (CDTYPE, CDNAME, CDVAL, CDCONTENT, LSTODR, CDUSER, EN_CDCONTENT, CHSTATUS) Values   ('SA', 'DRTRANTYPE', '013', 'Bù trừ tiền mua', 12, 'Y', 'Bù trừ tiền mua', 'C');Insert into ALLCODE   (CDTYPE, CDNAME, CDVAL, CDCONTENT, LSTODR, CDUSER, EN_CDCONTENT, CHSTATUS) Values   ('SA', 'DRTRANTYPE', '015', 'Bù trừ phí chuyển nhượng trả VSD giữa hội sở và chi nhánh', 13, 'Y', 'Bù trừ phí chuyển nhượng trả VSD giữa hội sở và chi nhánh', 'C');Insert into ALLCODE   (CDTYPE, CDNAME, CDVAL, CDCONTENT, LSTODR, CDUSER, EN_CDCONTENT, CHSTATUS) Values   ('SA', 'DRTRANTYPE', '016', 'Chi phí dịch vụ NH cho hoạt động môi giới', 14, 'Y', 'Chi phí dịch vụ NH cho hoạt động môi giới', 'C');Insert into ALLCODE   (CDTYPE, CDNAME, CDVAL, CDCONTENT, LSTODR, CDUSER, EN_CDCONTENT, CHSTATUS) Values   ('SA', 'DRTRANTYPE', '030', 'Khác', 20, 'Y', 'Khác', 'C');COMMIT;