SET DEFINE OFF;DELETE FROM SEARCH WHERE 1 = 1 AND NVL(SEARCHCODE,'NULL') = NVL('RE0003','NULL');Insert into SEARCH   (SEARCHCODE, SEARCHTITLE, EN_SEARCHTITLE, SEARCHCMDSQL, OBJNAME, FRMNAME, ORDERBYCMDSQL, TLTXCD, CNTRECORD, ROWPERPAGE, AUTOSEARCH, INTERVAL, AUTHCODE, ROWLIMIT, CMDTYPE, CONDDEFFLD, BANKINQ, BANKACCT, CHKSCOPECMDSQL) Values   ('RE0003', 'Tra cứu lương MG ', 'View salary', 'SELECT a.commdate, a.retype,a1.cdcontent DESC_RETYPE,  a.custid, cf.fullname,
      A.mindrevamt,
       a.minirevamt, a.minincome, a.minratesal, a.saltype,
        a.directacr, a.directfeeacr,
       a.indirectacr, a.indirectfeeacr,
         a.revenue, a.commision, a.autoid, A.SALARY,
        a.commision + A.SALARY totalsal,
        a.tax, a.isdg
  FROM resalary a, cfmast cf , allcode a1, recflnk rf
  where a.custid=cf.custid
  and a1.cdtype=''RE'' and a1.cdname=''RETYPE''
  and a.retype=a1.cdval
  and a.custid=rf.custid and (<$BRID> =''0001'' or RF.BRID = <$BRID>)', 'RE.REMAST', 'frmREMAST', '', '', 0, 50, 'N', 30, 'NYNNYYYNNN', 'Y', 'T', '', 'N', '', '');COMMIT;