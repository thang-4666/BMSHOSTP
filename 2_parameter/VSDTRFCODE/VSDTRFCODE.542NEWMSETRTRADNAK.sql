SET DEFINE OFF;DELETE FROM VSDTRFCODE WHERE 1 = 1 AND NVL(TRFCODE,'NULL') = NVL('542.NEWM.SETR//TRAD..NAK','NULL');Insert into VSDTRFCODE   (TRFCODE, DESCRIPTION, VSDMT, STATUS, TYPE, TLTXCD, SEARCHCODE, FILTERNAME, REQTLTXCD, AUTOCONF, EN_DESCRIPTION, REJTLTXCD, TRFTYPE) Values   ('542.NEWM.SETR//TRAD..NAK', 'Điện chuyển chứng khoán bị NAK', '542', 'Y', 'NAK', '2265', '', '', '2255', 'Y', '', '', 'DR');Insert into VSDTRFCODE   (TRFCODE, DESCRIPTION, VSDMT, STATUS, TYPE, TLTXCD, SEARCHCODE, FILTERNAME, REQTLTXCD, AUTOCONF, EN_DESCRIPTION, REJTLTXCD, TRFTYPE) Values   ('542.NEWM.SETR//TRAD..NAK', 'Điện chuyển chứng khoán bị NAK', '542', 'Y', 'NAK', '3358NAK', '', '', '3358', 'Y', '', '', 'DR');Insert into VSDTRFCODE   (TRFCODE, DESCRIPTION, VSDMT, STATUS, TYPE, TLTXCD, SEARCHCODE, FILTERNAME, REQTLTXCD, AUTOCONF, EN_DESCRIPTION, REJTLTXCD, TRFTYPE) Values   ('542.NEWM.SETR//TRAD..NAK', 'Điện chuyển chứng khoán bị NAK', '542', 'Y', 'NAK', '2290', '', '', '2247', 'Y', '', '', 'DR');Insert into VSDTRFCODE   (TRFCODE, DESCRIPTION, VSDMT, STATUS, TYPE, TLTXCD, SEARCHCODE, FILTERNAME, REQTLTXCD, AUTOCONF, EN_DESCRIPTION, REJTLTXCD, TRFTYPE) Values   ('542.NEWM.SETR//TRAD..NAK', 'Điện Chuyển nhượng quyền mua bị NAK', '542', 'Y', 'NAK', '3353', '', '', '3383', 'Y', '', '', 'DR');COMMIT;