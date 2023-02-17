SET DEFINE OFF;DELETE FROM ALLCODE WHERE 1 = 1 AND NVL(CDNAME,'NULL') = NVL('CRTRANTYPE','NULL') AND NVL(CDTYPE,'NULL') = NVL('SA','NULL');Insert into ALLCODE   (CDTYPE, CDNAME, CDVAL, CDCONTENT, LSTODR, CDUSER, EN_CDCONTENT, CHSTATUS) Values   ('SA', 'CRTRANTYPE', '003', 'Phí chuyển nhượng OTC', 2, 'Y', 'Phí chuyển nhượng OTC', 'C');Insert into ALLCODE   (CDTYPE, CDNAME, CDVAL, CDCONTENT, LSTODR, CDUSER, EN_CDCONTENT, CHSTATUS) Values   ('SA', 'CRTRANTYPE', '004', 'Nộp tiền Thuế OTC', 3, 'Y', 'Nộp tiền Thuế OTC', 'C');Insert into ALLCODE   (CDTYPE, CDNAME, CDVAL, CDCONTENT, LSTODR, CDUSER, EN_CDCONTENT, CHSTATUS) Values   ('SA', 'CRTRANTYPE', '005', 'Nộp tiền đấu giá IPO', 4, 'Y', 'Nộp tiền đấu giá IPO', 'C');Insert into ALLCODE   (CDTYPE, CDNAME, CDVAL, CDCONTENT, LSTODR, CDUSER, EN_CDCONTENT, CHSTATUS) Values   ('SA', 'CRTRANTYPE', '007', 'Phí quản lý cổ đông (Đổi sổ, thay đổi thông tin)', 6, 'Y', 'Phí quản lý cổ đông (Đổi sổ, thay đổi thông tin)', 'C');Insert into ALLCODE   (CDTYPE, CDNAME, CDVAL, CDCONTENT, LSTODR, CDUSER, EN_CDCONTENT, CHSTATUS) Values   ('SA', 'CRTRANTYPE', '017', 'Điều chuyển vốn TK KH - CTY', 10, 'Y', 'Điều chuyển vốn TK KH - CTY', 'C');Insert into ALLCODE   (CDTYPE, CDNAME, CDVAL, CDCONTENT, LSTODR, CDUSER, EN_CDCONTENT, CHSTATUS) Values   ('SA', 'CRTRANTYPE', '012', 'KH chuyển tiền mua PHT', 11, 'Y', 'KH chuyển tiền mua PHT', 'C');Insert into ALLCODE   (CDTYPE, CDNAME, CDVAL, CDCONTENT, LSTODR, CDUSER, EN_CDCONTENT, CHSTATUS) Values   ('SA', 'CRTRANTYPE', '018', 'Thu phí chuyển nhượng CP không thông sàn', 17, 'Y', 'Thu phí chuyển nhượng CP không thông sàn', 'C');Insert into ALLCODE   (CDTYPE, CDNAME, CDVAL, CDCONTENT, LSTODR, CDUSER, EN_CDCONTENT, CHSTATUS) Values   ('SA', 'CRTRANTYPE', '019', 'PGD Giảng Võ test', 18, 'Y', 'PGD Giảng Võ test', 'C');Insert into ALLCODE   (CDTYPE, CDNAME, CDVAL, CDCONTENT, LSTODR, CDUSER, EN_CDCONTENT, CHSTATUS) Values   ('SA', 'CRTRANTYPE', '020', 'Nhận điều chuyển vốn', 19, 'Y', 'Nhận điều chuyển vốn', 'C');Insert into ALLCODE   (CDTYPE, CDNAME, CDVAL, CDCONTENT, LSTODR, CDUSER, EN_CDCONTENT, CHSTATUS) Values   ('SA', 'CRTRANTYPE', '021', 'Tiền KH chuyển thừa', 20, 'Y', 'Tiền KH chuyển thừa', 'C');Insert into ALLCODE   (CDTYPE, CDNAME, CDVAL, CDCONTENT, LSTODR, CDUSER, EN_CDCONTENT, CHSTATUS) Values   ('SA', 'CRTRANTYPE', '022', 'Ngân hàng hoàn lại tiền BSC chuyển', 21, 'Y', 'Ngân hàng hoàn lại tiền BSC chuyển', 'C');Insert into ALLCODE   (CDTYPE, CDNAME, CDVAL, CDCONTENT, LSTODR, CDUSER, EN_CDCONTENT, CHSTATUS) Values   ('SA', 'CRTRANTYPE', '023', 'Nhận báo có không rõ nội dung', 23, 'Y', 'Nhận báo có không rõ nội dung', 'C');Insert into ALLCODE   (CDTYPE, CDNAME, CDVAL, CDCONTENT, LSTODR, CDUSER, EN_CDCONTENT, CHSTATUS) Values   ('SA', 'CRTRANTYPE', '024', 'Thuế chuyển nhượng CP không thông sàn', 24, 'Y', 'Thuế chuyển nhượng CP không thông sàn', 'C');Insert into ALLCODE   (CDTYPE, CDNAME, CDVAL, CDCONTENT, LSTODR, CDUSER, EN_CDCONTENT, CHSTATUS) Values   ('SA', 'CRTRANTYPE', '025', 'Thu phí cầm cố phong tỏa, giải tỏa CK', 25, 'Y', 'Thu phí cầm cố phong tỏa, giải tỏa CK', 'C');Insert into ALLCODE   (CDTYPE, CDNAME, CDVAL, CDCONTENT, LSTODR, CDUSER, EN_CDCONTENT, CHSTATUS) Values   ('SA', 'CRTRANTYPE', '008', 'Lãi tiền gửi tại ngân hàng', 25, 'Y', 'Lãi tiền gửi tại ngân hàng', 'C');Insert into ALLCODE   (CDTYPE, CDNAME, CDVAL, CDCONTENT, LSTODR, CDUSER, EN_CDCONTENT, CHSTATUS) Values   ('SA', 'CRTRANTYPE', '010', 'Nhận tiền cổ tức từ TCPH', 26, 'Y', 'Nhận tiền cổ tức từ TCPH', 'C');Insert into ALLCODE   (CDTYPE, CDNAME, CDVAL, CDCONTENT, LSTODR, CDUSER, EN_CDCONTENT, CHSTATUS) Values   ('SA', 'CRTRANTYPE', '026', 'Nhận tiền vay cầm cố từ Ngân hàng', 26, 'Y', 'Nhận tiền vay cầm cố từ Ngân hàng', 'C');Insert into ALLCODE   (CDTYPE, CDNAME, CDVAL, CDCONTENT, LSTODR, CDUSER, EN_CDCONTENT, CHSTATUS) Values   ('SA', 'CRTRANTYPE', '014', 'Phí nhận cổ tức từ tổ chức phát hành', 27, 'Y', 'Phí nhận cổ tức từ tổ chức phát hành', 'C');Insert into ALLCODE   (CDTYPE, CDNAME, CDVAL, CDCONTENT, LSTODR, CDUSER, EN_CDCONTENT, CHSTATUS) Values   ('SA', 'CRTRANTYPE', '050', 'Khác', 49, 'Y', 'Khác', 'C');COMMIT;