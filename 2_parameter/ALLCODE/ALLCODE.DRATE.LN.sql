SET DEFINE OFF;DELETE FROM ALLCODE WHERE 1 = 1 AND NVL(CDNAME,'NULL') = NVL('DRATE','NULL') AND NVL(CDTYPE,'NULL') = NVL('LN','NULL');Insert into ALLCODE   (CDTYPE, CDNAME, CDVAL, CDCONTENT, LSTODR, CDUSER, EN_CDCONTENT, CHSTATUS) Values   ('LN', 'DRATE', 'D1', '30 ngày/tháng', 0, 'Y', '30 days/month', 'C');Insert into ALLCODE   (CDTYPE, CDNAME, CDVAL, CDCONTENT, LSTODR, CDUSER, EN_CDCONTENT, CHSTATUS) Values   ('LN', 'DRATE', 'D2', 'Số ngày thực tế', 1, 'Y', 'Actual month day', 'C');Insert into ALLCODE   (CDTYPE, CDNAME, CDVAL, CDCONTENT, LSTODR, CDUSER, EN_CDCONTENT, CHSTATUS) Values   ('LN', 'DRATE', 'Y1', '360 ngày/năm', 2, 'Y', '360 days/year', 'C');Insert into ALLCODE   (CDTYPE, CDNAME, CDVAL, CDCONTENT, LSTODR, CDUSER, EN_CDCONTENT, CHSTATUS) Values   ('LN', 'DRATE', 'Y2', 'Số ngày thực tế/năm', 3, 'Y', 'Actual year day', 'C');Insert into ALLCODE   (CDTYPE, CDNAME, CDVAL, CDCONTENT, LSTODR, CDUSER, EN_CDCONTENT, CHSTATUS) Values   ('LN', 'DRATE', 'Y3', '365 ngày/năm', 4, 'Y', '365 days/year', 'C');COMMIT;