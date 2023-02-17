SET DEFINE OFF;
CREATE OR REPLACE FORCE VIEW VW_LN9000
(CUSTODYCD, AFACCTNO, FULLNAME, CAREBY, LNACCTNO, 
 AUTOID, RLSDATE, OVERDUEDATE, LOANRATE, PRINAMT, 
 INTAMT, FEEAMT, ORGPAIDAMT, INTPAIDAMT, FEEPAIDAMT, 
 LOANTYPE, CUSTBANK, BANKNAME, BANKSHORTNAME, TOTALAMT, 
 TOTALPAIDAMT)
BEQUEATH DEFINER
AS 
(
    select t."CUSTODYCD",t."AFACCTNO",t."FULLNAME",t."CAREBY",t."LNACCTNO",t."AUTOID",t."RLSDATE",t."OVERDUEDATE",
    t."LOANRATE",t."PRINAMT",t."INTAMT",t."FEEAMT",t."ORGPAIDAMT",
    t."INTPAIDAMT",t."FEEPAIDAMT",t."LOANTYPE",t."CUSTBANK",
    t."BANKNAME",t."BANKSHORTNAME", t.prinamt + t.intamt + t.feeamt totalamt,
            t.ORGPAIDAMT + t.INTPAIDAMT + t.FEEPAIDAMT totalpaidamt
        from (
        SELECT CF.CUSTODYCD, cf.acctno AFACCTNO, CF.FULLNAME,cf.careby, lnt.lnacctno,ln.autoid,
                        to_char(LN.RLSDATE,'DD/MM/YYYY') RLSDATE,
                        to_char(LN.OVERDUEDATE,'DD/MM/YYYY') OVERDUEDATE,
                        LN.LOANRATE,
                        LN.prinamt prinAMT,
                        LN.intamt INTAMT,
                        LN.feeamt FEEAMT,
                        NVL(lnt.ORGPAIDAMT,0) ORGPAIDAMT,
                        NVL(lnt.INTPAIDAMT,0) INTPAIDAMT,
                        NVL(lnt.FEEPAIDAMT,0) FEEPAIDAMT,
                        (case when ln.ftype ='DF' then 'DF' else 'MR' end) LOANTYPE,
                        CASE WHEN NVL(LNT.OVDPAIDAMT,0) = 0 THEN ln.custbank ELSE 'BSC' END custbank,
                        CASE WHEN NVL(LNT.OVDPAIDAMT,0) = 0 THEN LN.BANKNAME ELSE 'BSC' END BANKNAME,
                        LN.BANKSHORTNAME
                        --ln.custbank, ln.BANKNAME
        FROM
         (
             select trfacctno afacctno, acctno lnacctno, lnschdid,
             t0prinovd+t0prindue+t0prinnml+prinovd+prindue+prinnml ORGPAIDAMT,
             t0intnmlovd+t0intovdacr+t0intdue+t0intnmlacr+intnmlovd+intovdacr+intdue+intnmlacr  INTPAIDAMT,
             feeovd+feeintnmlovd+feeintovdacr+feedue+feeintdue+feenml+feeintnmlacr FEEPAIDAMT,
             t0prinovd+t0prindue+t0prinnml+prinovd+prindue+
             t0intnmlovd+t0intovdacr+t0intdue+t0intnmlacr+intnmlovd+intovdacr+intdue+
             feeovd+feeintnmlovd+feeintovdacr+feedue+feeintdue OVDPAIDAMT
             from lnpaidalloc_dtl

         ) lnt
         INNER JOIN
         (
             SELECT lns.autoid,ln.acctno, ln.trfacctno, lns.rlsdate, lns.overduedate, lns.rate2 LOANRATE,
                 round(lns.nml + LNs.ovd) prinamt,
                 round(lns.intnmlacr + LNs.intdue + lns.intovd + lns.intovdprin) intamt,
                 round(lns.fee + LNs.feedue + lns.feeovd + lns.feeintnmlacr + lns.feeintovdacr + lns.feeintnmlovd
                        + lns.feeintdue + lns.nmlfeeint + lns.ovdfeeint + lns.feeintnml + lns.feeintovd)  feeamt,
                 DECODE(LN.RRTYPE,'C','BSC', NVL(LN.CUSTBANK,'BSC')) CUSTBANK,
                 NVL(CF.FULLNAME,'BSC') BANKNAME ,NVL(CF.shortname,'BSC') BANKSHORTNAME, ftype
             FROM lnmast LN, cfmast cf, lnschd lns
             WHERE LN.CUSTBANK = CF.CUSTID (+)
                and ln.acctno =  lns.acctno
         ) ln
         ON lnt.lnschdid = LN.autoid
         INNER JOIN
         (
             SELECT CF.custodycd, AF.acctno, CF.fullname, cf.careby
             FROM CFMAST CF, AFMAST AF
             WHERE CF.custid = AF.custid
         ) CF
         ON LN.trfacctno = CF.ACCTNO
     ) t
)
/
