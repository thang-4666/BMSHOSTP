SET DEFINE OFF;DELETE FROM ALLCODE WHERE 1 = 1 AND NVL(CDNAME,'NULL') = NVL('BALTYPE','NULL') AND NVL(CDTYPE,'NULL') = NVL('GL','NULL');Insert into ALLCODE   (CDTYPE, CDNAME, CDVAL, CDCONTENT, LSTODR, CDUSER, EN_CDCONTENT, CHSTATUS) Values   ('GL', 'BALTYPE', 'B', 'Cả hai', 0, 'Y', 'Cả hai', 'C');Insert into ALLCODE   (CDTYPE, CDNAME, CDVAL, CDCONTENT, LSTODR, CDUSER, EN_CDCONTENT, CHSTATUS) Values   ('GL', 'BALTYPE', 'D', 'Dư nợ', 1, 'Y', 'Dư nợ', 'C');Insert into ALLCODE   (CDTYPE, CDNAME, CDVAL, CDCONTENT, LSTODR, CDUSER, EN_CDCONTENT, CHSTATUS) Values   ('GL', 'BALTYPE', 'C', 'Dư có', 2, 'Y', 'Dư có', 'C');COMMIT;