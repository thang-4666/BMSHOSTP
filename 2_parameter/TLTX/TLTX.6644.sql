SET DEFINE OFF;DELETE FROM TLTX WHERE 1 = 1 AND NVL(TLTXCD,'NULL') = NVL('6644','NULL');Insert into TLTX   (TLTXCD, TXDESC, EN_TXDESC, LIMIT, OFFLINEALLOW, IBT, OVRRQD, LATE, OVRLEV, PRN, LOCAL, CHAIN, DIRECT, HOSTACNO, BACKUP, TXTYPE, NOSUBMIT, DELALLOW, FEEAPP, MSQRQR, VOUCHER, MNEM, MSG_AMT, MSG_ACCT, WITHACCT, ACCTENTRY, BGCOLOR, DISPLAY, BKDATE, ADJALLOW, GLGP, VOUCHERID, CCYCD, RUNMOD, RESTRICTALLOW, REFOBJ, REFKEYFLD, MSGTYPE, CHKBKDATE, CFCUSTODYCD, CFFULLNAME, VISIBLE, CHGTYPEALLOW, NUMBKDATE, CHKSINGLE, AFREGSCHD, ENBKDATE, STATUS, PSTATUS) Values   ('6644', 'Giao dịch chuyển tiền qua tài khoản ngân hàng', 'Transfer balance other account', 0, 'Y', 'Y', 'Y', '0', 2, 'Y', 'N', 'Y', 'N', ' ', 'Y', 'T', '2', 'Y', 'N', 'N', 'RM01', 'TRF', '10', '03', ' ', '', 0, 'Y', 'Y', 'Y', 'N', '', '##', 'DB', 'N', '', '', '', 'N', '##', '##', 'Y', 'Y', 0, 'N', 'N', 'Y', '', 'P');COMMIT;