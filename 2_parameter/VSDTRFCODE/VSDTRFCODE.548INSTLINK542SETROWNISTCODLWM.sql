SET DEFINE OFF;DELETE FROM VSDTRFCODE WHERE 1 = 1 AND NVL(TRFCODE,'NULL') = NVL('548.INST.LINK//542.SETR//OWNI.STCO//DLWM','NULL');Insert into VSDTRFCODE   (TRFCODE, DESCRIPTION, VSDMT, STATUS, TYPE, TLTXCD, SEARCHCODE, FILTERNAME, REQTLTXCD, AUTOCONF, EN_DESCRIPTION) Values   ('548.INST.LINK//542.SETR//OWNI.STCO//DLWM', 'Từ chối chuyển khoản quyển mua cùng TVLK', '548', 'Y', 'CFN', '3358', '', '', '3358', 'Y', 'Reject the right transfer requests');Insert into VSDTRFCODE   (TRFCODE, DESCRIPTION, VSDMT, STATUS, TYPE, TLTXCD, SEARCHCODE, FILTERNAME, REQTLTXCD, AUTOCONF, EN_DESCRIPTION) Values   ('548.INST.LINK//542.SETR//OWNI.STCO//DLWM', 'Từ chối chuyển khoản chứng khoán', '546', 'Y', 'CFN', '2265', '', '', '2255', 'Y', 'Refusal to transfer securities');COMMIT;