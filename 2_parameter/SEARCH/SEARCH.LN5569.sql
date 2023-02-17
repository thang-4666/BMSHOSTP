SET DEFINE OFF;DELETE FROM SEARCH WHERE 1 = 1 AND NVL(SEARCHCODE,'NULL') = NVL('LN5569','NULL');Insert into SEARCH   (SEARCHCODE, SEARCHTITLE, EN_SEARCHTITLE, SEARCHCMDSQL, OBJNAME, FRMNAME, ORDERBYCMDSQL, TLTXCD, CNTRECORD, ROWPERPAGE, AUTOSEARCH, INTERVAL, AUTHCODE, ROWLIMIT, CMDTYPE, CONDDEFFLD, BANKINQ, BANKACCT, CHKSCOPECMDSQL) Values   ('LN5569', 'Tài khoản vay', 'Customer loan account management', '
select cf.custodycd, af.acctno afacctno, ln.actype olntype, lnt.typename,
round(ls.nml+ls.ovd,0) odprin,
round(ls.intnmlacr+ls.intdue+ls.intovd+ls.intovdprin,0)+round(ls.feeintnmlacr+ls.feeintdue+ls.feeintovdacr+ls.feeintnmlovd,0) odint,
round(ls.intnmlacr+ls.intdue+ls.intovd+ls.intovdprin,0) intamt,
round(ls.feeintnmlacr+ls.feeintdue+ls.feeintovdacr+ls.feeintnmlovd,0) feeintamt,
round(ls.feeintovdacr,0) feeintovdacr,
ls.nml+ls.ovd+round(ls.intnmlacr+ls.intdue+ls.intovd+ls.intovdprin,0)+round(ls.feeintnmlacr+ls.feeintdue+ls.feeintovdacr+ls.feeintnmlovd,0) odamt,
ls.autoid lnschdid, ls.acctno lnacctno,
nvl(greatest(0,getbaldefovd( af.ACCTNO)),0) AVLBAL
from cfmast cf, afmast af, lnmast ln, lnschd ls, lntype lnt
where ln.acctno = ls.acctno
and ls.reftype in (''P'',''GP'') and ln.ftype = ''AF''
and ln.prinnml+ln.prinovd+ln.intnmlacr+ln.intdue+ln.intovdacr+ln.intnmlovd+ln.feeintnmlacr+ln.feeintdue+ln.feeintovdacr+ln.feeintnmlovd
    +ln.oprinnml+ln.oprinovd+ln.ointnmlacr+ln.ointdue+ln.ointovdacr+ln.ointnmlovd> 0
and cf.custid = af.custid and af.acctno = ln.trfacctno and ln.acctno = ls.acctno and ln.actype = lnt.actype', 'LN5569', 'frmLNMAST', '', '', NULL, 50, 'N', 0, '', 'Y', 'T', '', 'N', '', '');COMMIT;