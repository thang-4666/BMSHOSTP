SET DEFINE OFF;DELETE FROM ALLCODE WHERE 1 = 1 AND NVL(CDNAME,'NULL') = NVL('VSDTRFLOGSTS','NULL') AND NVL(CDTYPE,'NULL') = NVL('ST','NULL');Insert into ALLCODE   (CDTYPE, CDNAME, CDVAL, CDCONTENT, LSTODR, CDUSER, EN_CDCONTENT, CHSTATUS) Values   ('ST', 'VSDTRFLOGSTS', 'P', 'Chờ xử lý', 0, 'Y', 'Chờ xử lý', 'C');Insert into ALLCODE   (CDTYPE, CDNAME, CDVAL, CDCONTENT, LSTODR, CDUSER, EN_CDCONTENT, CHSTATUS) Values   ('ST', 'VSDTRFLOGSTS', 'A', 'Đang xử lý', 2, 'Y', 'Đang xử lý', 'C');Insert into ALLCODE   (CDTYPE, CDNAME, CDVAL, CDCONTENT, LSTODR, CDUSER, EN_CDCONTENT, CHSTATUS) Values   ('ST', 'VSDTRFLOGSTS', 'C', 'Hoàn tất', 3, 'Y', 'Hoàn tất', 'C');Insert into ALLCODE   (CDTYPE, CDNAME, CDVAL, CDCONTENT, LSTODR, CDUSER, EN_CDCONTENT, CHSTATUS) Values   ('ST', 'VSDTRFLOGSTS', 'E', 'Xử lý bị lỗi tại FLEX', 6, 'Y', 'Xử lý bị lỗi tại FLEX', 'C');COMMIT;