SET DEFINE OFF;DELETE FROM TLTX WHERE 1 = 1 AND NVL(TLTXCD,'NULL') = NVL('8882','NULL');Insert into TLTX   (TLTXCD, TXDESC, EN_TXDESC, LIMIT, OFFLINEALLOW, IBT, OVRRQD, LATE, OVRLEV, PRN, LOCAL, CHAIN, DIRECT, HOSTACNO, BACKUP, TXTYPE, NOSUBMIT, DELALLOW, FEEAPP, MSQRQR, VOUCHER, MNEM, MSG_AMT, MSG_ACCT, WITHACCT, ACCTENTRY, BGCOLOR, DISPLAY, BKDATE, ADJALLOW, GLGP, VOUCHERID, CCYCD, RUNMOD, RESTRICTALLOW, REFOBJ, REFKEYFLD, MSGTYPE, CHKBKDATE, CFCUSTODYCD, CFFULLNAME, VISIBLE, CHGTYPEALLOW, NUMBKDATE, CHKSINGLE, AFREGSCHD, ENBKDATE, STATUS, PSTATUS) Values   ('8882', 'Hủy lệnh mua thông thường', 'Cancel buy order', 0, 'Y', 'Y', 'N', '0', 2, 'Y', 'N', 'N', 'N', ' ', 'Y', 'M', '2', 'N', 'N', 'N', 'OD01', 'ODNB', '12**11**98', '03', ' ', '', 0, 'N', 'N', 'Y', 'N', '', '##', 'DB', 'N', '', '', '', 'N', '##', '##', 'N', 'Y', 0, 'N', 'N', 'Y', '', '');COMMIT;