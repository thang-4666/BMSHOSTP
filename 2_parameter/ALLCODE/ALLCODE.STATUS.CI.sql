SET DEFINE OFF;DELETE FROM ALLCODE WHERE 1 = 1 AND NVL(CDNAME,'NULL') = NVL('STATUS','NULL') AND NVL(CDTYPE,'NULL') = NVL('CI','NULL');Insert into ALLCODE   (CDTYPE, CDNAME, CDVAL, CDCONTENT, LSTODR, CDUSER, EN_CDCONTENT, CHSTATUS) Values   ('CI', 'STATUS', 'D', 'Ngủ', 0, 'Y', 'Ngủ', 'C');Insert into ALLCODE   (CDTYPE, CDNAME, CDVAL, CDCONTENT, LSTODR, CDUSER, EN_CDCONTENT, CHSTATUS) Values   ('CI', 'STATUS', 'B', 'Phong tỏa', 1, 'Y', 'Phong tỏa', 'C');Insert into ALLCODE   (CDTYPE, CDNAME, CDVAL, CDCONTENT, LSTODR, CDUSER, EN_CDCONTENT, CHSTATUS) Values   ('CI', 'STATUS', 'C', 'Đóng', 2, 'Y', 'Đóng', 'C');Insert into ALLCODE   (CDTYPE, CDNAME, CDVAL, CDCONTENT, LSTODR, CDUSER, EN_CDCONTENT, CHSTATUS) Values   ('CI', 'STATUS', 'A', 'Hoạt động', 3, 'Y', 'Hoạt động', 'C');Insert into ALLCODE   (CDTYPE, CDNAME, CDVAL, CDCONTENT, LSTODR, CDUSER, EN_CDCONTENT, CHSTATUS) Values   ('CI', 'STATUS', 'P', 'Chờ duyệt', 4, 'Y', 'Chờ duyệt', 'C');Insert into ALLCODE   (CDTYPE, CDNAME, CDVAL, CDCONTENT, LSTODR, CDUSER, EN_CDCONTENT, CHSTATUS) Values   ('CI', 'STATUS', 'N', 'Chờ đóng', 5, 'Y', 'Chờ đóng', 'C');Insert into ALLCODE   (CDTYPE, CDNAME, CDVAL, CDCONTENT, LSTODR, CDUSER, EN_CDCONTENT, CHSTATUS) Values   ('CI', 'STATUS', 'T', 'Chờ thay đổi', 7, 'Y', 'Chờ thay đổi', 'C');Insert into ALLCODE   (CDTYPE, CDNAME, CDVAL, CDCONTENT, LSTODR, CDUSER, EN_CDCONTENT, CHSTATUS) Values   ('CI', 'STATUS', 'G', 'Thừa kế', 8, 'Y', 'Thừa kế', 'C');COMMIT;