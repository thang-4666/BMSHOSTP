SET DEFINE OFF;DELETE FROM TLTX WHERE 1 = 1 AND NVL(TLTXCD,'NULL') = NVL('2239','NULL');Insert into TLTX   (TLTXCD, TXDESC, EN_TXDESC, LIMIT, OFFLINEALLOW, IBT, OVRRQD, LATE, OVRLEV, PRN, LOCAL, CHAIN, DIRECT, HOSTACNO, BACKUP, TXTYPE, NOSUBMIT, DELALLOW, FEEAPP, MSQRQR, VOUCHER, MNEM, MSG_AMT, MSG_ACCT, WITHACCT, ACCTENTRY, BGCOLOR, DISPLAY, BKDATE, ADJALLOW, GLGP, VOUCHERID, CCYCD, RUNMOD, RESTRICTALLOW, REFOBJ, REFKEYFLD, MSGTYPE, CHKBKDATE, CFCUSTODYCD, CFFULLNAME, VISIBLE, CHGTYPEALLOW, NUMBKDATE, CHKSINGLE, AFREGSCHD, ENBKDATE, STATUS, PSTATUS) Values   ('2239', 'Chuyển đổi chứng khoán nội bộ cùng khách hàng thành tiền', 'Transfer between two SE account', 0, 'Y', 'Y', 'Y', '0', 2, 'Y', 'N', 'N', 'N', ' ', 'Y', 'M', '2', 'Y', 'N', 'N', 'SE01', 'SETRFSE', '10', '05', ' ', '', 0, 'Y', 'N', 'Y', 'N', '', '01', 'DB', 'N', '', '', 'SE.CREDIT', 'N', '##', '##', 'Y', 'Y', 0, 'Y', 'N', 'Y', '', 'P');COMMIT;