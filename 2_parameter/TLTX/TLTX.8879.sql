SET DEFINE OFF;DELETE FROM TLTX WHERE 1 = 1 AND NVL(TLTXCD,'NULL') = NVL('8879','NULL');Insert into TLTX   (TLTXCD, TXDESC, EN_TXDESC, LIMIT, OFFLINEALLOW, IBT, OVRRQD, LATE, OVRLEV, PRN, LOCAL, CHAIN, DIRECT, HOSTACNO, BACKUP, TXTYPE, NOSUBMIT, DELALLOW, FEEAPP, MSQRQR, VOUCHER, MNEM, MSG_AMT, MSG_ACCT, WITHACCT, ACCTENTRY, BGCOLOR, DISPLAY, BKDATE, ADJALLOW, GLGP, VOUCHERID, CCYCD, RUNMOD, RESTRICTALLOW, REFOBJ, REFKEYFLD, MSGTYPE, CHKBKDATE, CFCUSTODYCD, CFFULLNAME, VISIBLE, CHGTYPEALLOW, NUMBKDATE, CHKSINGLE, AFREGSCHD, ENBKDATE, STATUS, PSTATUS) Values   ('8879', 'Thanh toán chứng khoán lô lẻ', 'Match securities trade lot retail', 0, 'Y', 'Y', 'Y', '0', 2, 'Y', 'N', 'N', 'N', ' ', 'Y', 'M', '2', 'Y', 'N', 'N', 'CI01', 'CITRFCI', '10', '03', ' ', '', 0, 'Y', 'Y', 'Y', 'N', '', '01', 'DB', 'N', '', '', 'PAYMENTED', 'N', '88', '90', 'Y', 'Y', 7, 'Y', 'N', 'Y', '', 'P');COMMIT;