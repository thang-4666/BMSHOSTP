SET DEFINE OFF;DELETE FROM SEARCH WHERE 1 = 1 AND NVL(SEARCHCODE,'NULL') = NVL('V_CI1101','NULL');Insert into SEARCH   (SEARCHCODE, SEARCHTITLE, EN_SEARCHTITLE, SEARCHCMDSQL, OBJNAME, FRMNAME, ORDERBYCMDSQL, TLTXCD, CNTRECORD, ROWPERPAGE, AUTOSEARCH, INTERVAL, AUTHCODE, ROWLIMIT, CMDTYPE, CONDDEFFLD, BANKINQ, BANKACCT, CHKSCOPECMDSQL) Values   ('V_CI1101', 'Danh sách import giao dịch chuyển khoản tiền ra ngân hàng (1101)', 'View pending tranfer monney to bank (wait for 1101)', '
SELECT TBL.AUTOID,CF.CUSTODYCD,AF.ACCTNO,CF.FULLNAME CUSTNAME, CF.FULLNAME,
CF.ADDRESS,CF.IDCODE LICENSE, CF.IDDATE,CF.IDPLACE,GETBALDEFOVD(AF.ACCTNO) CASTBAL,
TBL.BENEFCUSTNAME,TBL.RECEIVLICENSE,TBL.RECEIVIDDATE,TBL.RECEIVIDPLACE,TBL.BENEFACCT,
TBL.BANKID,TBL.BENEFBANK,TBL.REFID,TBL.CITYBANK,TBL.CITYEF, TBL.IORO,TBL.FEECD,
TBL.AMT,TBL.FEEAMT,TBL.VATAMT, TBL.AMT +TBL.FEEAMT + TBL.VATAMT TRFAMT,TBL.DES
FROM TBLCI1101 TBL, CFMAST CF, AFMAST AF
WHERE TBL.CUSTODYCD= CF.CUSTODYCD AND TBL.ACCTNO = AF.ACCTNO
AND CF.CUSTID =AF.CUSTID AND NVL(TBL.DELTD,''0'') <>''Y''  AND TBL.AUTOID NOT IN (SELECT REFKEY FROM TLLOGEXT WHERE TLTXCD=''1101'' AND DELTD=''N'' AND STATUS IN (''0'',''1'', ''3'',''4'') ) ', 'CIMAST', 'frmCIMAST', '', '1101', NULL, 50, 'N', 30, 'NYNNYYYNNN', 'Y', 'T', '', 'N', '', '');COMMIT;