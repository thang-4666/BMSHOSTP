SET DEFINE OFF;DELETE FROM SEARCH WHERE 1 = 1 AND NVL(SEARCHCODE,'NULL') = NVL('MR0004','NULL');Insert into SEARCH   (SEARCHCODE, SEARCHTITLE, EN_SEARCHTITLE, SEARCHCMDSQL, OBJNAME, FRMNAME, ORDERBYCMDSQL, TLTXCD, CNTRECORD, ROWPERPAGE, AUTOSEARCH, INTERVAL, AUTHCODE, ROWLIMIT, CMDTYPE, CONDDEFFLD, BANKINQ, BANKACCT, CHKSCOPECMDSQL) Values   ('MR0004', 'Tra cứu hạn mức vay theo tiểu khoản', 'View sub account margin limit', 'select cf.custodycd, af.acctno,aft.mnemonic, aft.typename,cf.fullname ,cf.mrloanlimit, cf.t0loanlimit,
    af.mrcrlimitmax, round(ci.dfodamt) dfodamt,
        round(af.mrcrlimitmax - ci.dfodamt - nvl(mramt,0)) mrcrlimitremain,
        nvl(T0af.AFT0USED,0) AFT0USED,
    round(af.advanceline,0) advanceline,
    round(cf.mrloanlimit)-ROUND(nvl(MR.CUSTMRUSED,0)) avlmrloanlimit,round(cf.t0loanlimit)-ROUND(nvl(T0.CUSTT0USED,0)) avlt0loanlimit,
    round(nvl(dfamt,0)) dfamt, round(nvl(dfprinamt,0)) dfprinamt, round(nvl(dfintamt,0)) dfintamt,
    round(nvl(mramt,0)) mramt, round(nvl(mrprinamt,0)) mrprinamt, round(nvl(mrintamt,0)) mrintamt,
    round(nvl(ln.t0amt,0)) t0amt
from afmast af, cfmast cf, cimast ci, aftype aft, mrtype mrt,
v_getbuyorderinfo b,
(select sum(acclimit) CUSTT0USED, af.CUSTID from useraflimit us, afmast af where af.acctno = us.acctno and us.typereceive = ''T0'' group by custid) T0,
(select sum(acclimit) AFT0USED, acctno from useraflimit us where us.typereceive = ''T0'' group by acctno) T0af,
(select sum(mrcrlimitmax) CUSTMRUSED, CUSTID from afmast group by custid) MR,
(select trfacctno,
        sum(decode(ftype,''DF'',1,0)*(prinnml+prinovd+intnmlacr+intdue+intovdacr+intnmlovd+feeintnmlacr+feeintdue+feeintovdacr+feeintnmlovd)) dfamt,
        sum(decode(ftype,''DF'',1,0)*(prinnml+prinovd)) dfprinamt,
        sum(decode(ftype,''DF'',1,0)*(intnmlacr+intdue+intovdacr+intnmlovd+feeintnmlacr+feeintdue+feeintovdacr+feeintnmlovd)) dfintamt,
        sum(decode(ftype,''AF'',1,0)*(prinnml+prinovd+intnmlacr+intdue+intovdacr+intnmlovd+feeintnmlacr+feeintdue+feeintovdacr+feeintnmlovd)) mramt,
        sum(decode(ftype,''AF'',1,0)*(prinnml+prinovd)) mrprinamt,
        sum(decode(ftype,''AF'',1,0)*(intnmlacr+intdue+intovdacr+intnmlovd+feeintnmlacr+feeintdue+feeintovdacr+feeintnmlovd)) mrintamt,
        sum(decode(ftype,''AF'',1,0)*(oprinnml+oprinovd+ointnmlacr+ointdue+ointovdacr+ointnmlovd)) t0amt
    from lnmast
    group by trfacctno) ln
where af.custid=cf.custid
and af.acctno = ci.acctno
and af.actype =aft.actype
and aft.mrtype =mrt.actype
and af.acctno = T0af.acctno(+)
and cf.custid = T0.custid(+)
and cf.custid = MR.custid(+)
and af.acctno = b.afacctno(+)
and af.acctno = ln.trfacctno(+)', 'MRTYPE', '', '', '', NULL, 50, 'N', 30, 'NYNNYYYNNN', 'Y', 'T', '', 'N', '', 'CUSTODYCD');COMMIT;