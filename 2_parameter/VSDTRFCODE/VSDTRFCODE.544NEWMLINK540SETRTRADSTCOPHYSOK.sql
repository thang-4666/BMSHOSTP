SET DEFINE OFF;DELETE FROM VSDTRFCODE WHERE 1 = 1 AND NVL(TRFCODE,'NULL') = NVL('544.NEWM.LINK//540.SETR//TRAD.STCO//PHYS.OK','NULL');Insert into VSDTRFCODE   (TRFCODE, DESCRIPTION, VSDMT, STATUS, TYPE, TLTXCD, SEARCHCODE, FILTERNAME, REQTLTXCD, AUTOCONF, EN_DESCRIPTION) Values   ('544.NEWM.LINK//540.SETR//TRAD.STCO//PHYS.OK', 'Chấp thuận lưu ký chứng khoán', '544', 'Y', 'CFO', '2246', '', '', '2241', 'Y', 'Approval of securities custody');COMMIT;