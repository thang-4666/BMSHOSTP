SET DEFINE OFF;DELETE FROM SEARCH WHERE 1 = 1 AND NVL(SEARCHCODE,'NULL') = NVL('RE0002','NULL');Insert into SEARCH   (SEARCHCODE, SEARCHTITLE, EN_SEARCHTITLE, SEARCHCMDSQL, OBJNAME, FRMNAME, ORDERBYCMDSQL, TLTXCD, CNTRECORD, ROWPERPAGE, AUTOSEARCH, INTERVAL, AUTHCODE, ROWLIMIT, CMDTYPE, CONDDEFFLD, BANKINQ, BANKACCT, CHKSCOPECMDSQL) Values   ('RE0002', 'Tra cứu hoa hồng', 'View commission ', 'SELECT a.commdate, a.retype,a1.cdcontent DESC_RETYPE, a.refrecflnkid, a.custid, cf.fullname, rty.rerole,
       DECODE(RTY.RETYPE,''I'',''...'',A2.cdcontent) DESC_REROLE, RTY.typename ,A.mindrevamt,
       a.minirevamt, a.minincome, a.minratesal, a.saltype, a.reactype,
       a.isdrev, a.odrnum, a.acctno, a.directacr, a.directfeeacr,a.lmn,a.disposal,
       a.indirectacr, a.indirectfeeacr,a.inlmn,a.indisposal,
       a.odfeetype, a.odfeerate,
       a.disdirectacr, a.disrevacr,
       case when a.retype = ''I'' then a.inrfmatchamt else a.disrfmatchamt end disrfmatchamt,
       case when a.retype = ''I'' then a.inrffeeacr else a.disrffeeacr end disrffeeacr,
       a.revenue, a.commision, a.txnum,
       a.txdate, a.autoid
  FROM recommision a, cfmast cf , allcode a1, retype rty, allcode a2, recflnk rf
  where a.custid=cf.custid
  and a1.cdtype=''RE'' and a1.cdname=''RETYPE''
  and a2.cdtype=''RE'' and a2.cdname=''REROLE''
  and a.retype=a1.cdval
  and rty.rerole=a2.cdval
  and a.reactype=rty.actype
  and a.custid = rf.custid
  and rf.status = ''A'' AND (<$BRID> =''0001'' or RF.BRID = <$BRID>)', 'RE.REMAST', 'frmREMAST', '', '', 0, 50, 'N', 30, 'NYNNYYYNNN', 'Y', 'T', '', 'N', '', '');COMMIT;