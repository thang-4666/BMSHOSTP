SET DEFINE OFF;DELETE FROM VSDTRFCODE WHERE 1 = 1 AND NVL(TRFCODE,'NULL') = NVL('598.707.NEWM.REJT','NULL');Insert into VSDTRFCODE   (TRFCODE, DESCRIPTION, VSDMT, STATUS, TYPE, TLTXCD, SEARCHCODE, FILTERNAME, REQTLTXCD, AUTOCONF, EN_DESCRIPTION, REJTLTXCD, TRFTYPE) Values   ('598.707.NEWM.REJT', 'Từ chối mở tài khoản', '598', 'Y', 'CFN', 'CFREJ', '', '', '0035', 'Y', '', '', 'DR');Insert into VSDTRFCODE   (TRFCODE, DESCRIPTION, VSDMT, STATUS, TYPE, TLTXCD, SEARCHCODE, FILTERNAME, REQTLTXCD, AUTOCONF, EN_DESCRIPTION, REJTLTXCD, TRFTYPE) Values   ('598.707.NEWM.REJT', 'Từ chối đăng ký thông tin khách hàng nước ngoài', '598', 'Y', 'CFN', 'CFREJ', '', '', '0136', 'Y', '', '', 'DR');Insert into VSDTRFCODE   (TRFCODE, DESCRIPTION, VSDMT, STATUS, TYPE, TLTXCD, SEARCHCODE, FILTERNAME, REQTLTXCD, AUTOCONF, EN_DESCRIPTION, REJTLTXCD, TRFTYPE) Values   ('598.707.NEWM.REJT', 'Từ chối cấp tradingcode khách hàng nước ngoài', '598', 'Y', 'CFN', 'CFREJ', '', '', '0137', 'Y', '', '', 'DR');Insert into VSDTRFCODE   (TRFCODE, DESCRIPTION, VSDMT, STATUS, TYPE, TLTXCD, SEARCHCODE, FILTERNAME, REQTLTXCD, AUTOCONF, EN_DESCRIPTION, REJTLTXCD, TRFTYPE) Values   ('598.707.NEWM.REJT', 'Từ chối thay đổi thông tin khách hàng', '598', 'Y', 'CFN', '0004', '', '', '0017', 'Y', '', '', 'DR');COMMIT;