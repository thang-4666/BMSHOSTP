SET DEFINE OFF;DELETE FROM ALLCODE WHERE 1 = 1 AND NVL(CDNAME,'NULL') = NVL('STSCFTMP','NULL') AND NVL(CDTYPE,'NULL') = NVL('CF','NULL');Insert into ALLCODE   (CDTYPE, CDNAME, CDVAL, CDCONTENT, LSTODR, CDUSER, EN_CDCONTENT, CHSTATUS) Values   ('CF', 'STSCFTMP', 'P', 'Chờ mở tài khoản', 0, 'Y', 'Pending', 'C');Insert into ALLCODE   (CDTYPE, CDNAME, CDVAL, CDCONTENT, LSTODR, CDUSER, EN_CDCONTENT, CHSTATUS) Values   ('CF', 'STSCFTMP', 'N', 'Ðã xác nhận thông tin KH', 1, 'Y', 'Confirmed', 'C');Insert into ALLCODE   (CDTYPE, CDNAME, CDVAL, CDCONTENT, LSTODR, CDUSER, EN_CDCONTENT, CHSTATUS) Values   ('CF', 'STSCFTMP', 'S', 'Ðã gửi hồ sơ', 2, 'Y', 'Send', 'C');Insert into ALLCODE   (CDTYPE, CDNAME, CDVAL, CDCONTENT, LSTODR, CDUSER, EN_CDCONTENT, CHSTATUS) Values   ('CF', 'STSCFTMP', 'R', 'Ðã hủy', 3, 'Y', 'Reject', 'C');Insert into ALLCODE   (CDTYPE, CDNAME, CDVAL, CDCONTENT, LSTODR, CDUSER, EN_CDCONTENT, CHSTATUS) Values   ('CF', 'STSCFTMP', 'W', 'Ðang chờ bổ sung hồ sơ', 4, 'Y', 'Waitting', 'C');Insert into ALLCODE   (CDTYPE, CDNAME, CDVAL, CDCONTENT, LSTODR, CDUSER, EN_CDCONTENT, CHSTATUS) Values   ('CF', 'STSCFTMP', 'C', 'Ðã xác nhận mở tài khoản', 5, 'Y', 'Completed', 'C');Insert into ALLCODE   (CDTYPE, CDNAME, CDVAL, CDCONTENT, LSTODR, CDUSER, EN_CDCONTENT, CHSTATUS) Values   ('CF', 'STSCFTMP', 'A', 'Ðã mở tài khoản', 6, 'Y', 'Actived', 'C');COMMIT;