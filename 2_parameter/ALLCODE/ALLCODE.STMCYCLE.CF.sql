SET DEFINE OFF;DELETE FROM ALLCODE WHERE 1 = 1 AND NVL(CDNAME,'NULL') = NVL('STMCYCLE','NULL') AND NVL(CDTYPE,'NULL') = NVL('CF','NULL');Insert into ALLCODE   (CDTYPE, CDNAME, CDVAL, CDCONTENT, LSTODR, CDUSER, EN_CDCONTENT, CHSTATUS) Values   ('CF', 'STMCYCLE', 'M', 'Hằng tháng', 0, 'Y', 'Hằng tháng', 'C');Insert into ALLCODE   (CDTYPE, CDNAME, CDVAL, CDCONTENT, LSTODR, CDUSER, EN_CDCONTENT, CHSTATUS) Values   ('CF', 'STMCYCLE', 'Q', 'Hằng quý', 1, 'Y', 'Hằng quý', 'C');Insert into ALLCODE   (CDTYPE, CDNAME, CDVAL, CDCONTENT, LSTODR, CDUSER, EN_CDCONTENT, CHSTATUS) Values   ('CF', 'STMCYCLE', 'Y', 'Hằng năm', 2, 'Y', 'Hằng năm', 'C');COMMIT;