SET DEFINE OFF;DELETE FROM ALLCODE WHERE 1 = 1 AND NVL(CDNAME,'NULL') = NVL('TERMCD','NULL') AND NVL(CDTYPE,'NULL') = NVL('LN','NULL');Insert into ALLCODE   (CDTYPE, CDNAME, CDVAL, CDCONTENT, LSTODR, CDUSER, EN_CDCONTENT, CHSTATUS) Values   ('LN', 'TERMCD', 'Y', 'Năm', 0, 'Y', 'Năm', 'C');Insert into ALLCODE   (CDTYPE, CDNAME, CDVAL, CDCONTENT, LSTODR, CDUSER, EN_CDCONTENT, CHSTATUS) Values   ('LN', 'TERMCD', 'M', 'Tháng', 1, 'Y', 'Tháng', 'C');Insert into ALLCODE   (CDTYPE, CDNAME, CDVAL, CDCONTENT, LSTODR, CDUSER, EN_CDCONTENT, CHSTATUS) Values   ('LN', 'TERMCD', 'D', 'Ngày', 2, 'Y', 'Ngày', 'C');COMMIT;