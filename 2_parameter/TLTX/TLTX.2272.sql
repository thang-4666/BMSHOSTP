SET DEFINE OFF;DELETE FROM TLTX WHERE 1 = 1 AND NVL(TLTXCD,'NULL') = NVL('2272','NULL');Insert into TLTX   (TLTXCD, TXDESC, EN_TXDESC, LIMIT, OFFLINEALLOW, IBT, OVRRQD, LATE, OVRLEV, PRN, LOCAL, CHAIN, DIRECT, HOSTACNO, BACKUP, TXTYPE, NOSUBMIT, DELALLOW, FEEAPP, MSQRQR, VOUCHER, MNEM, MSG_AMT, MSG_ACCT, WITHACCT, ACCTENTRY, BGCOLOR, DISPLAY, BKDATE, ADJALLOW, GLGP, VOUCHERID, CCYCD, RUNMOD, RESTRICTALLOW, REFOBJ, REFKEYFLD, MSGTYPE, CHKBKDATE, CFCUSTODYCD, CFFULLNAME, VISIBLE, CHGTYPEALLOW, NUMBKDATE, CHKSINGLE, AFREGSCHD, ENBKDATE, STATUS, PSTATUS) Values   ('2272', 'Tra cứu lịch sử tài khoản chứng khoán', 'SE Account History', 0, 'Y', 'Y', 'Y', '0', 2, 'Y', 'N', 'N', 'Y', ' ', 'Y', 'I', '1', 'N', 'N', 'N', 'CF01', 'CIHIST', ' ', '03', ' ', '', 0, 'Y', 'N', 'Y', 'N', '', '01', 'NET', 'N', '', '', '', 'N', '##', '##', 'Y', 'Y', 0, 'N', 'N', 'Y', '', 'P');COMMIT;