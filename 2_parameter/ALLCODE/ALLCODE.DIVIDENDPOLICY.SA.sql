SET DEFINE OFF;DELETE FROM ALLCODE WHERE 1 = 1 AND NVL(CDNAME,'NULL') = NVL('DIVIDENDPOLICY','NULL') AND NVL(CDTYPE,'NULL') = NVL('SA','NULL');Insert into ALLCODE   (CDTYPE, CDNAME, CDVAL, CDCONTENT, LSTODR, CDUSER, EN_CDCONTENT, CHSTATUS) Values   ('SA', 'DIVIDENDPOLICY', '0', 'Trả vào tài khoản', 0, 'Y', 'Trả vào tài khoản', 'C');Insert into ALLCODE   (CDTYPE, CDNAME, CDVAL, CDCONTENT, LSTODR, CDUSER, EN_CDCONTENT, CHSTATUS) Values   ('SA', 'DIVIDENDPOLICY', '1', 'Tái đầu tư', 1, 'Y', 'Tái đầu tư', 'C');COMMIT;