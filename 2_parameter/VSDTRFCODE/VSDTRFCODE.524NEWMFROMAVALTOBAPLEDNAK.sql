SET DEFINE OFF;DELETE FROM VSDTRFCODE WHERE 1 = 1 AND NVL(TRFCODE,'NULL') = NVL('524.NEWM.FROM//AVAL.TOBA//PLED.NAK','NULL');Insert into VSDTRFCODE   (TRFCODE, DESCRIPTION, VSDMT, STATUS, TYPE, TLTXCD, SEARCHCODE, FILTERNAME, REQTLTXCD, AUTOCONF, EN_DESCRIPTION) Values   ('524.NEWM.FROM//AVAL.TOBA//PLED.NAK', 'Yêu cầu phong tỏa chứng khoán bị NAK', '524', 'Y', 'CFN', '2236', '', '', '2235', 'Y', 'Request for blockade of stock was NAK');COMMIT;