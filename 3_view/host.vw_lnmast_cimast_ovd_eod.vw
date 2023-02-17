SET DEFINE OFF;
CREATE OR REPLACE FORCE VIEW VW_LNMAST_CIMAST_OVD_EOD
(ACCTNO, LNACCOUNT, OVAMT, PRINOVD, OPRINNML, 
 OPRINOVD, INTNMLOVD, AMT)
BEQUEATH DEFINER
AS 
select a.acctno,b.acctno lnaccount,ovamt,prinovd,oprinnml,b.oprinovd,b.intnmlovd, ovamt-b.prinovd-b.oprinnml-b.oprinovd-b.intnmlovd-b.intovdacr  amt
  from cimast a, lnmast b
  where
  ovamt-b.prinovd-b.oprinnml-b.intnmlovd-b.intovdacr-b.oprinovd<>0 and
  a.acctno=b.trfacctno
/
