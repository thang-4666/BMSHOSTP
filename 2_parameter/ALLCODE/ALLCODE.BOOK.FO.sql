SET DEFINE OFF;DELETE FROM ALLCODE WHERE 1 = 1 AND NVL(CDNAME,'NULL') = NVL('BOOK','NULL') AND NVL(CDTYPE,'NULL') = NVL('FO','NULL');Insert into ALLCODE   (CDTYPE, CDNAME, CDVAL, CDCONTENT, LSTODR, CDUSER, EN_CDCONTENT, CHSTATUS) Values   ('FO', 'BOOK', 'I', 'Không hoạt động', 0, 'Y', 'Không hoạt động', 'C');Insert into ALLCODE   (CDTYPE, CDNAME, CDVAL, CDCONTENT, LSTODR, CDUSER, EN_CDCONTENT, CHSTATUS) Values   ('FO', 'BOOK', 'A', 'Hoạt động', 1, 'Y', 'Hoạt động', 'C');COMMIT;