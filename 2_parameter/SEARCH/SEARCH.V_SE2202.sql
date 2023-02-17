SET DEFINE OFF;DELETE FROM SEARCH WHERE 1 = 1 AND NVL(SEARCHCODE,'NULL') = NVL('V_SE2202','NULL');Insert into SEARCH   (SEARCHCODE, SEARCHTITLE, EN_SEARCHTITLE, SEARCHCMDSQL, OBJNAME, FRMNAME, ORDERBYCMDSQL, TLTXCD, CNTRECORD, ROWPERPAGE, AUTOSEARCH, INTERVAL, AUTHCODE, ROWLIMIT, CMDTYPE, CONDDEFFLD, BANKINQ, BANKACCT, CHKSCOPECMDSQL) Values   ('V_SE2202', 'Danh sách import giao dịch phong tỏa chứng khoán (2202)', 'View pending securities block (wait for 2202)', 'SELECT CF.CUSTID, CF.CUSTODYCD, TB.AFACCTNO, SB.CODEID, SB.SYMBOL, SE.ACCTNO, TB.QTTY, TB.SETYPE BLOCKTYPE, A1.CDCONTENT PBLOCKTYPE,
    ''007'' QTTYTYPE,  TB.DES, CF.FULLNAME, CF.ADDRESS, CF.IDCODE, SB.PARVALUE
FROM TBLSE2202 TB, CFMAST CF, AFMAST AF, SBSECURITIES SB, SEMAST SE, allcode A1
WHERE NVL (TB.DELTD, ''N'') <> ''Y''
    AND TB.SYMBOL = SB.SYMBOL
    AND TB.AFACCTNO = AF.ACCTNO
    AND CF.CUSTID = AF.CUSTID
    AND TB.AFACCTNO = SE.AFACCTNO
    AND SB.CODEID = SE.CODEID
    AND A1.CDVAL = TB.SETYPE AND  A1.CDTYPE=''SE'' AND A1.CDNAME=''BLOCKTYPE''', 'SEMAST', 'frmSEMAST', '', '2202', NULL, 50, 'N', 30, 'NYNNYYYNNN', 'Y', 'T', '', 'N', '', '');COMMIT;