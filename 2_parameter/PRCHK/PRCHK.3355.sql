SET DEFINE OFF;DELETE FROM PRCHK WHERE 1 = 1 AND NVL(TLTXCD,'NULL') = NVL('3355','NULL');Insert into PRCHK   (TLTXCD, CHKTYPE, TYPE, TYPEID, BRIDTYPE, PRTYPE, ACCFLDCD, TYPEFLDCD, DORC, AMTEXP, ODRNUM, UDPTYPE, DELTD, LNACCFLDCD, LNTYPEFLDCD) Values   ('3355', 'I', 'AFTYPE', '02', '0', 'R', '05', '', 'D', '10', 0, 'I', 'N', '', '');COMMIT;