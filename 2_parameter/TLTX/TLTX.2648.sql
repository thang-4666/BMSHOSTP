SET DEFINE OFF;DELETE FROM TLTX WHERE 1 = 1 AND NVL(TLTXCD,'NULL') = NVL('2648','NULL');Insert into TLTX   (TLTXCD, TXDESC, EN_TXDESC, LIMIT, OFFLINEALLOW, IBT, OVRRQD, LATE, OVRLEV, PRN, LOCAL, CHAIN, DIRECT, HOSTACNO, BACKUP, TXTYPE, NOSUBMIT, DELALLOW, FEEAPP, MSQRQR, VOUCHER, MNEM, MSG_AMT, MSG_ACCT, WITHACCT, ACCTENTRY, BGCOLOR, DISPLAY, BKDATE, ADJALLOW, GLGP, VOUCHERID, CCYCD, RUNMOD, RESTRICTALLOW, REFOBJ, REFKEYFLD, MSGTYPE, CHKBKDATE, CFCUSTODYCD, CFFULLNAME, VISIBLE, CHGTYPEALLOW, NUMBKDATE, CHKSINGLE, AFREGSCHD, ENBKDATE, STATUS, PSTATUS) Values   ('2648', 'Trả nợ Deal ưu tiên dùng tiền phong tỏa ', 'Deposit money to deal', 0, 'Y', 'Y', 'Y', '0', 2, 'N', 'N', 'N', 'N', ' ', 'Y', 'T', '2', 'N', 'N', 'N', 'CF01', 'AFCHG', '19', '05', ' ', '', 0, 'Y', 'N', 'Y', 'N', '', '##', 'DB', 'N', '', '', 'PAYMENT', 'N', '02', '57', 'Y', 'Y', 0, 'N', 'N', 'Y', '', 'P');COMMIT;