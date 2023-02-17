SET DEFINE OFF;DELETE FROM SEARCH WHERE 1 = 1 AND NVL(SEARCHCODE,'NULL') = NVL('V_SE2245','NULL');Insert into SEARCH   (SEARCHCODE, SEARCHTITLE, EN_SEARCHTITLE, SEARCHCMDSQL, OBJNAME, FRMNAME, ORDERBYCMDSQL, TLTXCD, CNTRECORD, ROWPERPAGE, AUTOSEARCH, INTERVAL, AUTHCODE, ROWLIMIT, CMDTYPE, CONDDEFFLD, BANKINQ, BANKACCT, CHKSCOPECMDSQL) Values   ('V_SE2245', 'Danh sách import giao dịch nhận chuyển khoản chứng khoán (2245)', 'View pending securities tranfer  (wait for 2245)', 'SELECT   tb.autoid, ''VSDDEP'' feetype, tb.codeid, tb.symbol,
         tb.inward, tb.TYPE, tb.custodycd, tb.afacctno,
         tb.afacctno || sb.codeid acctno, cf.fullname custname, cf.address,
         cf.idcode license, tb.price, tb.amt, tb.depoblock,
         tb.amt + tb.depoblock qtty, sb.parvalue parvalue, tb.qttytype, tb.trtype,
         tb.depofeeamt, tb.depofeeacr, tb.des,
         CASE WHEN tb.TYPE = ''001'' THEN ''Thông sàn'' ELSE ''Không thông sàn'' END typedesc,
         ci.depolastdt
  FROM   tblse2245 tb, sbsecurities sb, cfmast cf, afmast af, cimast ci
 WHERE   tb.custodycd = cf.custodycd AND tb.afacctno = af.acctno AND cf.custid = af.custid
         AND tb.symbol = sb.symbol AND NVL (tb.deltd, ''0'') <> ''Y''
         AND tb.autoid NOT IN (SELECT refkey FROM tllogext WHERE tltxcd = ''2245'' AND deltd = ''N'' AND status IN (''0'', ''1'', ''3'', ''4''))
         AND cf.status = ''A'' AND af.status = ''A''
         AND af.acctno = ci.acctno', 'SEMAST', 'frmSEMAST', '', '2245', NULL, 50, 'N', 30, 'NYNNYYYNNN', 'Y', 'T', '', 'N', '', '');COMMIT;