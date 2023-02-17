SET DEFINE OFF;DELETE FROM ALLCODE WHERE 1 = 1 AND NVL(CDNAME,'NULL') = NVL('HOSEMSG','NULL') AND NVL(CDTYPE,'NULL') = NVL('MS','NULL');Insert into ALLCODE   (CDTYPE, CDNAME, CDVAL, CDCONTENT, LSTODR, CDUSER, EN_CDCONTENT, CHSTATUS) Values   ('MS', 'HOSEMSG', '2I', 'Xác nhận khớp lệnh của khách hàng cùng công ty', 1, 'Y', 'Xác nhận khớp lệnh của khách hàng cùngcông ty', 'C');Insert into ALLCODE   (CDTYPE, CDNAME, CDVAL, CDCONTENT, LSTODR, CDUSER, EN_CDCONTENT, CHSTATUS) Values   ('MS', 'HOSEMSG', '2G', 'Thông tin từ chối từ HOSE', 1, 'Y', 'Thông tin từ chối từ HOSE', 'C');Insert into ALLCODE   (CDTYPE, CDNAME, CDVAL, CDCONTENT, LSTODR, CDUSER, EN_CDCONTENT, CHSTATUS) Values   ('MS', 'HOSEMSG', 'SC', 'Thông tin chuyển phiên', 1, 'Y', 'Thông tin chuyển phiên', 'C');Insert into ALLCODE   (CDTYPE, CDNAME, CDVAL, CDCONTENT, LSTODR, CDUSER, EN_CDCONTENT, CHSTATUS) Values   ('MS', 'HOSEMSG', 'GA', 'Thông tin thông báo từ Hose', 1, 'Y', 'Thông tin thông báo từ Hose', 'C');Insert into ALLCODE   (CDTYPE, CDNAME, CDVAL, CDCONTENT, LSTODR, CDUSER, EN_CDCONTENT, CHSTATUS) Values   ('MS', 'HOSEMSG', 'TR', 'Room của đầu tư nước ngoài', 1, 'Y', 'Room của đầu tư nước ngoài', 'C');Insert into ALLCODE   (CDTYPE, CDNAME, CDVAL, CDCONTENT, LSTODR, CDUSER, EN_CDCONTENT, CHSTATUS) Values   ('MS', 'HOSEMSG', 'IU', 'Cập nhật chỉ số', 1, 'Y', 'cập nhật chỉ số', 'C');Insert into ALLCODE   (CDTYPE, CDNAME, CDVAL, CDCONTENT, LSTODR, CDUSER, EN_CDCONTENT, CHSTATUS) Values   ('MS', 'HOSEMSG', 'OS', 'Thông tin xác định giá mở cửa', 1, 'Y', 'Thông tin xác định giá mở cửa', 'C');Insert into ALLCODE   (CDTYPE, CDNAME, CDVAL, CDCONTENT, LSTODR, CDUSER, EN_CDCONTENT, CHSTATUS) Values   ('MS', 'HOSEMSG', 'SS', 'Thông báo thay đổi trạng thái của một mã chứng khoán', 1, 'Y', 'Thông báo thay đổi trạng thái của một mã chứng khoán', 'C');Insert into ALLCODE   (CDTYPE, CDNAME, CDVAL, CDCONTENT, LSTODR, CDUSER, EN_CDCONTENT, CHSTATUS) Values   ('MS', 'HOSEMSG', 'SU', 'Cập nhật mã chứng khoán cuối ngày', 1, 'Y', 'Cập nhật mã chứng khoán cuối ngày', 'C');Insert into ALLCODE   (CDTYPE, CDNAME, CDVAL, CDCONTENT, LSTODR, CDUSER, EN_CDCONTENT, CHSTATUS) Values   ('MS', 'HOSEMSG', 'TS', 'Thông tin thời gian từ sở', 1, 'Y', 'Thông tin thời gian từ sở', 'C');Insert into ALLCODE   (CDTYPE, CDNAME, CDVAL, CDCONTENT, LSTODR, CDUSER, EN_CDCONTENT, CHSTATUS) Values   ('MS', 'HOSEMSG', 'AA', 'Thông tin các lệnh quảng cáo', 1, 'Y', 'Thông tin các lệnh quảng cáo', 'C');Insert into ALLCODE   (CDTYPE, CDNAME, CDVAL, CDCONTENT, LSTODR, CDUSER, EN_CDCONTENT, CHSTATUS) Values   ('MS', 'HOSEMSG', 'PO', 'Thông báo giá mở cửa dự kiến', 1, 'Y', 'Thông báo giá mở cửa dự kiến', 'C');Insert into ALLCODE   (CDTYPE, CDNAME, CDVAL, CDCONTENT, LSTODR, CDUSER, EN_CDCONTENT, CHSTATUS) Values   ('MS', 'HOSEMSG', 'PD', 'Thông báo về khớp lệnh của giao dịch thỏa thuận', 1, 'Y', 'Thông báo về khớp lệnh của giao dịch thỏa thuận', 'C');Insert into ALLCODE   (CDTYPE, CDNAME, CDVAL, CDCONTENT, LSTODR, CDUSER, EN_CDCONTENT, CHSTATUS) Values   ('MS', 'HOSEMSG', '3D', 'Thông tin trả lời yêu cầu hủy lệnh của bên mua hoặc HOSE', 1, 'Y', 'Thông tin trả lời yêu cầu hủy lệnh của bên mua hoặc HOSE', 'C');Insert into ALLCODE   (CDTYPE, CDNAME, CDVAL, CDCONTENT, LSTODR, CDUSER, EN_CDCONTENT, CHSTATUS) Values   ('MS', 'HOSEMSG', 'DC', 'Thông báo hủy một giao dịch thỏa thuận đã khớp', 1, 'Y', 'Thông báo hủy một giao dịch thỏa thuận đã khớp', 'C');Insert into ALLCODE   (CDTYPE, CDNAME, CDVAL, CDCONTENT, LSTODR, CDUSER, EN_CDCONTENT, CHSTATUS) Values   ('MS', 'HOSEMSG', 'BS', 'Thông báo thay đổi trạng thái của broker', 1, 'Y', 'Thông báo thay đổi trạng thái của broker', 'C');Insert into ALLCODE   (CDTYPE, CDNAME, CDVAL, CDCONTENT, LSTODR, CDUSER, EN_CDCONTENT, CHSTATUS) Values   ('MS', 'HOSEMSG', '2D', 'Xác nhận thay đổi lệnh', 1, 'Y', 'Xác nhận thay đổi lệnh', 'C');Insert into ALLCODE   (CDTYPE, CDNAME, CDVAL, CDCONTENT, LSTODR, CDUSER, EN_CDCONTENT, CHSTATUS) Values   ('MS', 'HOSEMSG', 'TC', 'Thông báo thay đổi trạng thái của trader', 1, 'Y', 'Thông báo thay đổi trạng thái của trader', 'C');Insert into ALLCODE   (CDTYPE, CDNAME, CDVAL, CDCONTENT, LSTODR, CDUSER, EN_CDCONTENT, CHSTATUS) Values   ('MS', 'HOSEMSG', '2B', 'Xác nhận lệnh đặt', 1, 'Y', 'Xác nhận lệnh đặt', 'C');Insert into ALLCODE   (CDTYPE, CDNAME, CDVAL, CDCONTENT, LSTODR, CDUSER, EN_CDCONTENT, CHSTATUS) Values   ('MS', 'HOSEMSG', '2C', 'Xác nhận lệnh thường hủy', 1, 'Y', 'Xác nhận lệnh thường hủy', 'C');Insert into ALLCODE   (CDTYPE, CDNAME, CDVAL, CDCONTENT, LSTODR, CDUSER, EN_CDCONTENT, CHSTATUS) Values   ('MS', 'HOSEMSG', '2E', 'Xác nhận khớp lệnh của khách hàng khác công ty', 1, 'Y', 'Xác nhận khớp lệnh của khách hàng khác công ty', 'C');Insert into ALLCODE   (CDTYPE, CDNAME, CDVAL, CDCONTENT, LSTODR, CDUSER, EN_CDCONTENT, CHSTATUS) Values   ('MS', 'HOSEMSG', '2F', 'Thông tin lệnh GDTT cho bên mua', 1, 'Y', 'Thông tin lệnh GDTT cho bên mua', 'C');Insert into ALLCODE   (CDTYPE, CDNAME, CDVAL, CDCONTENT, LSTODR, CDUSER, EN_CDCONTENT, CHSTATUS) Values   ('MS', 'HOSEMSG', '2L', 'Xác nhận khớp GDTT', 1, 'Y', 'Xác nhận khớp GDTT', 'C');COMMIT;