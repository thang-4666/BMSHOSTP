SET DEFINE OFF;
CREATE OR REPLACE FORCE VIEW VW_LNGROUP_ALL
(TRFACCTNO, T0AMT, MARGINAMT, MARGINOVDAMT, MARGIN74AMT, 
 MARGIN74OVDAMT)
BEQUEATH DEFINER
AS 
select trfacctno,
                 sum(oprinnml+oprinovd+ointnmlacr+ointdue+ointovdacr+ointnmlovd) t0amt,
                 sum(prinnml+prinovd+intnmlacr+intdue+intovdacr+intnmlovd+feeintnmlacr+feeintdue+feeintovdacr+feeintnmlovd) marginamt,
                 sum(prinovd+intovdacr+intnmlovd+feeintovdacr+feeintnmlovd + nvl(ls.dueamt,0) +intdue + feeintdue) marginovdamt,
                 sum(decode(lnt.chksysctrl,'Y',1,0)*(prinnml+prinovd+intnmlacr+intdue+intovdacr+intnmlovd+feeintnmlacr+feeintdue+feeintovdacr+feeintnmlovd)) margin74amt,
                 sum(decode(lnt.chksysctrl,'Y',1,0)*(prinovd+intovdacr+intnmlovd+feeintovdacr+feeintnmlovd + nvl(ls.dueamt,0) +intdue + feeintdue)) margin74ovdamt
        from lnmast ln, lntype lnt,
                (select acctno, sum(nml) dueamt
                        from lnschd
                        where reftype = 'P' and overduedate = getcurrdate
                        group by acctno) ls
        where ftype = 'AF'
                and ln.actype = lnt.actype
                and ln.acctno = ls.acctno(+)
        group by ln.trfacctno
/
