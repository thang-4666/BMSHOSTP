SET DEFINE OFF;DELETE FROM PRCHK WHERE 1 = 1 AND NVL(TLTXCD,'NULL') = NVL('2685','NULL');Insert into PRCHK   (TLTXCD, CHKTYPE, TYPE, TYPEID, BRIDTYPE, PRTYPE, ACCFLDCD, TYPEFLDCD, DORC, AMTEXP, ODRNUM, UDPTYPE, DELTD, LNACCFLDCD, LNTYPEFLDCD) Values   ('2685', 'L', 'AFTYPE', '03', '0', 'R', '05', '', 'C', '12++22++13++23--60--61--62--63', 0, 'I', 'Y', '', '');COMMIT;