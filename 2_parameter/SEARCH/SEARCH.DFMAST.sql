SET DEFINE OFF;DELETE FROM SEARCH WHERE 1 = 1 AND NVL(SEARCHCODE,'NULL') = NVL('DFMAST','NULL');Insert into SEARCH   (SEARCHCODE, SEARCHTITLE, EN_SEARCHTITLE, SEARCHCMDSQL, OBJNAME, FRMNAME, ORDERBYCMDSQL, TLTXCD, CNTRECORD, ROWPERPAGE, AUTOSEARCH, INTERVAL, AUTHCODE, ROWLIMIT, CMDTYPE, CONDDEFFLD, BANKINQ, BANKACCT, CHKSCOPECMDSQL) Values   ('DFMAST', 'Quản lý DF', 'DF account management', '
SELECT df.acctno, df.afacctno, df.lnacctno, cf.fullname,cf.address , cf.dateofbirth, cf.idcode, cf.iddate, cf.idplace,
       df.irate, df.mrate, df.lrate, df.dfrate, df.triggerprice, ac.cdcontent calltype, dt.typename dftypename, se.symbol, cf.custodycd,
       df.dfqtty, df.rcvqtty, df.blockqtty, df.carcvqtty, df.cacashqtty , df.amt - df.rlsamt remainamt,
       df.dfqtty + df.rcvqtty + df.blockqtty + df.carcvqtty + df.cacashqtty qtty
FROM dfmast df, afmast af, cfmast cf, dftype dt, securities_info se, allcode ac
WHERE df.afacctno = af.acctno AND af.custid = cf.custid and df.ACTYPE = dt.ACtype and df.codeid = se.codeid
and df.calltype = ac.cdval and ac.cdtype = ''DF'' and ac.cdname = ''CALLTYPE''', 'DFMAST', 'frmDFMAST', '', '', NULL, 50, 'N', 30, '', 'Y', 'T', '', 'N', '', '');COMMIT;