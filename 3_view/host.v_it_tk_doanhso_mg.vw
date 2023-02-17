SET DEFINE OFF;
CREATE OR REPLACE FORCE VIEW V_IT_TK_DOANHSO_MG
(TLFULLNAME, BRNAME, GROUPNAME, NGAYGD, SOHIEULENH, 
 TIEUKHOAN, LOAI, KLDAT, KLKHOP, GIAKHOP, 
 GTKHOP)
BEQUEATH DEFINER
AS 
SELECT TO_CHAR(b.tlname) tlfullname,
    TO_CHAR(c.brname) brname,
    TO_CHAR(E.grpname) grpname ,
    a.ngaygd,
    a.sohieulenh,
    a.tieukhoan,
    a.loai,
    a.kldat,
    a.klkhop,
    a.giakhop,
    a.gtkhop
  FROM sbs_sales_result a,
    tlprofiles b,
    brgrp c,
    CFMAST D,
    tlgroups E
  WHERE A.NGAYGD       =TRUNC(SYSDATE)
  AND A.NVMOIGIOI NOT IN ('ONLINE','ETS(DMSTe)')
  AND a.nvmoigioi      =b.tlid
  AND b.brid           =c.brid
  AND A.tieukhoan      =D.custid
  AND D.careby         =E.grpid
  UNION ALL
  SELECT TO_CHAR(a.nvmoigioi) tlfullname,
    'no name' brname,
    'no group' grpname,
    a.ngaygd,
    a.sohieulenh,
    a.tieukhoan,
    a.loai,
    a.kldat,
    a.klkhop,
    a.giakhop,
    a.gtkhop
  FROM sbs_sales_result a
  WHERE A.NGAYGD   =TRUNC(SYSDATE)
  AND A.NVMOIGIOI IN ('ONLINE','ETS(DMSTe)')
/
