SET DEFINE OFF;
CREATE OR REPLACE PROCEDURE "GL1009" (
   PV_REFCURSOR   IN OUT   PKG_REPORT.REF_CURSOR,
   OPT            IN       VARCHAR2,
   BRID           IN       VARCHAR2,
   F_DATE         IN       VARCHAR2,
   T_DATE         IN       VARCHAR2
)
IS
--
-- PURPOSE: Bao cao gia tri giao dich theo tai khoan
--

  v_FromDate date;
  v_ToDate date;
  v_UnitAmt number(20);
  v_UnitName varchar2(200);
  v_BRID     varchar2(100);

BEGIN

v_FromDate:= to_date(F_DATE,'DD/MM/RRRR');
v_ToDate := to_date(T_DATE,'DD/MM/RRRR');
v_UnitAmt:=1000000;
v_UnitName := 'Tri?u d?ng';


IF v_BRID <> 'ALL' THEN
   v_BRID := BRID;
ELSE
   v_BRID := '%';
END IF;

-- Main report
OPEN PV_REFCURSOR FOR
      select gr.grpname,cf.custodycd,cf.fullname,aft.typename,cf.mobile,
              sum(od.EXECAMT) GTGD,uf.tlname
      from cfmast cf , tlprofiles uf, brgrp br , tlgroups gr, vw_odmast_all od, sbsecurities sb,afmast af,aftype aft
      where af.tlid = uf.tlid
          and uf.brid = br.brid
          and af.careby = gr.grpid
          and cf.custid = od.afacctno
          and sb.codeid = od.codeid
          and cf.custid = af.custid
          and af.actype = aft.actype
          and od.execqtty > 0
          and gr.grpid like v_BRID
          and od.txdate between v_FromDate and v_ToDate
      group by gr.grpname, cf.custodycd, cf.fullname, aft.typename, cf.mobile, uf.tlname
      order by uf.tlname;
EXCEPTION
   WHEN OTHERS THEN
      RETURN;
END;

 
 
 
 
/
