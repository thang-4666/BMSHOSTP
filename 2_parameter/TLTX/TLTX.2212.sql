SET DEFINE OFF;DELETE FROM TLTX WHERE 1 = 1 AND NVL(TLTXCD,'NULL') = NVL('2212','NULL');Insert into TLTX   (TLTXCD, TXDESC, EN_TXDESC, LIMIT, OFFLINEALLOW, IBT, OVRRQD, LATE, OVRLEV, PRN, LOCAL, CHAIN, DIRECT, HOSTACNO, BACKUP, TXTYPE, NOSUBMIT, DELALLOW, FEEAPP, MSQRQR, VOUCHER, MNEM, MSG_AMT, MSG_ACCT, WITHACCT, ACCTENTRY, BGCOLOR, DISPLAY, BKDATE, ADJALLOW, GLGP, VOUCHERID, CCYCD, RUNMOD, RESTRICTALLOW, REFOBJ, REFKEYFLD, MSGTYPE, CHKBKDATE, CFCUSTODYCD, CFFULLNAME, VISIBLE, CHGTYPEALLOW, NUMBKDATE, CHKSINGLE, AFREGSCHD, ENBKDATE, STATUS, PSTATUS) Values   ('2212', 'Xác nhận GD lệnh trái phiếu', 'Confirm bond order', 0, 'Y', 'Y', 'N', '0', 2, 'Y', 'N', 'N', 'N', ' ', 'Y', 'M', '2', 'N', 'N', 'N', 'SE01', 'SEDEPO', '10', '02', ' ', '', 0, 'Y', 'N', 'Y', 'N', 'SE09LK', '01', 'NET', 'N', '', '', '', 'N', '##', '##', 'Y', 'Y', 0, '', 'N', 'Y', '', 'P');COMMIT;