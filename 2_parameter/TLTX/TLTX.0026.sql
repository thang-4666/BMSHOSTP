SET DEFINE OFF;DELETE FROM TLTX WHERE 1 = 1 AND NVL(TLTXCD,'NULL') = NVL('0026','NULL');Insert into TLTX   (TLTXCD, TXDESC, EN_TXDESC, LIMIT, OFFLINEALLOW, IBT, OVRRQD, LATE, OVRLEV, PRN, LOCAL, CHAIN, DIRECT, HOSTACNO, BACKUP, TXTYPE, NOSUBMIT, DELALLOW, FEEAPP, MSQRQR, VOUCHER, MNEM, MSG_AMT, MSG_ACCT, WITHACCT, ACCTENTRY, BGCOLOR, DISPLAY, BKDATE, ADJALLOW, GLGP, VOUCHERID, CCYCD, RUNMOD, RESTRICTALLOW, REFOBJ, REFKEYFLD, MSGTYPE, CHKBKDATE, CFCUSTODYCD, CFFULLNAME, VISIBLE, CHGTYPEALLOW, NUMBKDATE, CHKSINGLE, AFREGSCHD, ENBKDATE, STATUS, PSTATUS) Values   ('0026', 'Đánh giá phân hạng khách hàng', 'Đánh giá phân hạng khách hàng', 0, 'Y', 'Y', 'Y', '0', 2, 'N', 'N', 'N', 'Y', ' ', 'Y', 'T', '2', 'Y', 'N', 'N', 'OD01', 'ODNB', '', '01', ' ', '', 0, 'Y', 'Y', 'Y', 'N', '', '07', 'DB', 'N', '', '', '', 'N', '02', '90', 'Y', 'Y', 0, 'N', 'N', 'Y', '', 'P');COMMIT;