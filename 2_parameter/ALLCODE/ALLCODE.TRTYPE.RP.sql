SET DEFINE OFF;DELETE FROM ALLCODE WHERE 1 = 1 AND NVL(CDNAME,'NULL') = NVL('TRTYPE','NULL') AND NVL(CDTYPE,'NULL') = NVL('RP','NULL');Insert into ALLCODE   (CDTYPE, CDNAME, CDVAL, CDCONTENT, LSTODR, CDUSER, EN_CDCONTENT, CHSTATUS) Values   ('RP', 'TRTYPE', 'M', 'Cầm cố', 1, 'Y', 'Cầm cố', 'C');Insert into ALLCODE   (CDTYPE, CDNAME, CDVAL, CDCONTENT, LSTODR, CDUSER, EN_CDCONTENT, CHSTATUS) Values   ('RP', 'TRTYPE', 'T', 'Chuyển nhượng', 2, 'Y', 'Chuyển nhượng', 'C');COMMIT;