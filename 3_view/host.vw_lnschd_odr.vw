SET DEFINE OFF;
CREATE OR REPLACE FORCE VIEW VW_LNSCHD_ODR
(ODR, AUTOID, ACCTNO, REFTYPE, OVERDUEDATE, 
 RLSDATE, RATE2, RATE3, PAID, INTPAID, 
 TOTAL, OVD, INDUENML, INTOVD, INTOVDPRIN, 
 FEEOVD, FEEINTOVDACR, FEEINTNMLOVD, INTDUE, FEEDUE, 
 FEEINTDUE, INTNMLACR, FEE, FEEINTNMLACR, NML)
BEQUEATH DEFINER
AS 
select odr.cdval odr, ln.autoid,ln.acctno,ln.reftype,ln.overduedate,ln.rlsdate,ln.rate2, ln.rate3,ln.paid,ln.intpaid,
       nml+ovd+intovd+intovdprin+feeovd+feeintovdacr+feeintnmlovd+intdue+feedue+feeintdue+intnmlacr+fee+feeintnmlacr total,

       (case when odr.cdval='1' then ovd else 0 end) ovd, --Goc qua han

       (case when odr.cdval='2' and ln.overduedate = to_date(varvalue,'dd/mm/rrrr') then nml else 0 end) induenml, --Goc den han

       (case when odr.cdval='3' then intovd else 0 end) intovd, --Lai qua han
       (case when odr.cdval='3' then intovdprin else 0 end) intovdprin, --Lai qua han
       (case when odr.cdval='3' then feeovd else 0 end) feeovd, --Lai qua han
       (case when odr.cdval='3' then feeintovdacr else 0 end) feeintovdacr, --Lai qua han
       (case when odr.cdval='3' then feeintnmlovd else 0 end) feeintnmlovd, --Lai qua han

       (case when odr.cdval='4' then intdue else 0 end) intdue,--Lai den han
       (case when odr.cdval='4' then feedue else 0 end) feedue,--Lai den han
       (case when odr.cdval='4' then feeintdue else 0 end) feeintdue,--Lai den han

       (case when odr.cdval='5' then intnmlacr else 0 end) intnmlacr, --Lai trong han
       (case when odr.cdval='5' then fee else 0 end) fee, --Lai trong han
       (case when odr.cdval='5' then feeintnmlacr else 0 end) feeintnmlacr, --Lai trong han

       (case when odr.cdval='6' and ln.overduedate > to_date(varvalue,'dd/mm/rrrr') then nml else 0 end) nml --Goc trong han

from lnschd ln, allcode odr, sysvar sy
where odr.cdname ='LNPAIDORDER' and odr.cdtype ='LN'
and sy.grname ='SYSTEM' and sy.varname='CURRDATE'
/
