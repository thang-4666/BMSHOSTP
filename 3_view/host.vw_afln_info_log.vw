SET DEFINE OFF;
CREATE OR REPLACE FORCE VIEW VW_AFLN_INFO_LOG
(CUSTODYCD, ACCTNO, LNTYPE, BANKLIMIT, DFAMT, 
 DFPRINAMT, DFINTAMT, MRAMT, MRPRINAMT, MRINTAMT, 
 MR74AMT, MR74PRINAMT, MR74INTAMT, T0AMT, MRCRLIMITMAX, 
 MRCRLIMITREMAIN)
BEQUEATH DEFINER
AS 
select cf.custodycd, af.acctno, ln.actype lntype,
max(case when ln.rrtype = 'B' then cspks_cfproc.fn_getavlcflimit(ln.custbank, af.custid, 'DFMR') else 0 end) banklimit,
sum(decode(ftype,'DF',1,0)*(prinnml+prinovd+intnmlacr+intdue+intovdacr+intnmlovd+feeintnmlacr+feeintdue+feeintovdacr+feeintnmlovd)) dfamt,
sum(decode(ftype,'DF',1,0)*(prinnml+prinovd)) dfprinamt,
sum(decode(ftype,'DF',1,0)*(intnmlacr+intdue+intovdacr+intnmlovd+feeintnmlacr+feeintdue+feeintovdacr+feeintnmlovd)) dfintamt,
sum(decode(ftype,'AF',1,0)*(prinnml+prinovd+intnmlacr+intdue+intovdacr+intnmlovd+feeintnmlacr+feeintdue+feeintovdacr+feeintnmlovd)) mramt,
sum(decode(ftype,'AF',1,0)*(prinnml+prinovd)) mrprinamt,
sum(decode(ftype,'AF',1,0)*(intnmlacr+intdue+intovdacr+intnmlovd+feeintnmlacr+feeintdue+feeintovdacr+feeintnmlovd)) mrintamt,
sum(decode(ftype,'AF',1,0)*decode(lnt.chksysctrl,'Y',1,0)*(prinnml+prinovd+intnmlacr+intdue+intovdacr+intnmlovd+feeintnmlacr+feeintdue+feeintovdacr+feeintnmlovd)) mr74amt,
sum(decode(ftype,'AF',1,0)*decode(lnt.chksysctrl,'Y',1,0)*(prinnml+prinovd)) mr74prinamt,
sum(decode(ftype,'AF',1,0)*decode(lnt.chksysctrl,'Y',1,0)*(intnmlacr+intdue+intovdacr+intnmlovd+feeintnmlacr+feeintdue+feeintovdacr+feeintnmlovd)) mr74intamt,
sum(decode(ftype,'AF',1,0)*(oprinnml+oprinovd+ointnmlacr+ointdue+ointovdacr+ointnmlovd)) t0amt,
max(af.mrcrlimitmax) mrcrlimitmax,
greatest(max(af.mrcrlimitmax)
    -  sum(decode(ftype,'DF',1,0)*(prinnml+prinovd))
    -  sum(decode(ftype,'AF',1,0)*(prinnml+prinovd+intnmlacr+intdue+intovdacr+intnmlovd+feeintnmlacr+feeintdue+feeintovdacr+feeintnmlovd))
    ,0)
    mrcrlimitremain
from lnmast ln, lntype lnt, afmast af, cfmast cf
where ln.actype = lnt.actype
and ln.trfacctno = af.acctno
and af.custid = cf.custid
group by cf.custodycd, af.acctno, ln.actype
/
