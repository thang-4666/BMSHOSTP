SET DEFINE OFF;
CREATE OR REPLACE FORCE VIEW VW_LNSCHD_ALL
(AUTOID, ACCTNO, DUENO, RLSDATE, DUEDATE, 
 OVERDUEDATE, ACRDATE, OVDACRDATE, PAIDDATE, REFTYPE, 
 NML, OVD, PAID, DUESTS, PDUESTS, 
 INTNMLACR, FEE, DUE, INTOVDDUEDATE, INTDUE, 
 INTOVD, INTOVDPRIN, INTPAID, FEEDUE, FEEOVD, 
 FEEPAID, FEEPAID2, RATE1, RATE2, RATE3, 
 CFRATE1, CFRATE2, CFRATE3, FEEINTNMLACR, FEEINTOVDACR, 
 FEEINTNMLOVD, FEEINTDUE, FEEINTPREPAID, FEEINTPAID, NMLFEEINT, 
 OVDFEEINT, PAIDFEEINT, FEEINTNML, FEEINTOVD, REFAUTOID, 
 EXTIMES, EXDAYS)
BEQUEATH DEFINER
AS 
(
select AUTOID,ACCTNO,DUENO,RLSDATE,DUEDATE,OVERDUEDATE,ACRDATE,OVDACRDATE,PAIDDATE,REFTYPE,NML,OVD,PAID,DUESTS,PDUESTS,INTNMLACR,FEE,DUE,INTOVDDUEDATE,INTDUE,INTOVD,INTOVDPRIN,INTPAID,FEEDUE,FEEOVD,FEEPAID,FEEPAID2,RATE1,RATE2,RATE3,CFRATE1,CFRATE2,CFRATE3,FEEINTNMLACR,FEEINTOVDACR,FEEINTNMLOVD,FEEINTDUE,FEEINTPREPAID,FEEINTPAID,NMLFEEINT,OVDFEEINT,PAIDFEEINT,FEEINTNML,FEEINTOVD,REFAUTOID
, extimes  ,   exdays
from lnschd
union all
select AUTOID,ACCTNO,DUENO,RLSDATE,DUEDATE,OVERDUEDATE,ACRDATE,OVDACRDATE,PAIDDATE,REFTYPE,NML,OVD,PAID,DUESTS,PDUESTS,INTNMLACR,FEE,DUE,INTOVDDUEDATE,INTDUE,INTOVD,INTOVDPRIN,INTPAID,FEEDUE,FEEOVD,FEEPAID,FEEPAID2,RATE1,RATE2,RATE3,CFRATE1,CFRATE2,CFRATE3,FEEINTNMLACR,FEEINTOVDACR,FEEINTNMLOVD,FEEINTDUE,FEEINTPREPAID,FEEINTPAID,NMLFEEINT,OVDFEEINT,PAIDFEEINT,FEEINTNML,FEEINTOVD,REFAUTOID
, extimes  ,   exdays
from lnschdhist
)
/
