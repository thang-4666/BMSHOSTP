SET DEFINE OFF;
CREATE OR REPLACE PROCEDURE cf7008(
   PV_REFCURSOR   IN OUT   PKG_REPORT.REF_CURSOR,
   OPT            IN       VARCHAR2,
   pv_BRID           IN       VARCHAR2,
   TLGOUPS        IN       VARCHAR2,
   TLSCOPE        IN       VARCHAR2,
   F_DATE         IN       VARCHAR2,
   T_DATE         IN       VARCHAR2,
   IPADDRESS      IN       VARCHAR2)
   IS
       V_STROPTION        VARCHAR2 (5);       -- A: ALL; B: BRANCH; S: SUB-BRANCH

   -- DECLARE PROGRAM VARIABLES AS SHOWN ABOVE
   V_STRPV_CUSTODYCD VARCHAR2(20);
   V_INBRID        VARCHAR2(4);
   V_STRBRID      VARCHAR2 (50);


   v_fromdate   date;
   v_todate     date;
BEGIN
    V_STROPTION := upper(OPT);
    V_INBRID := pv_BRID;
    if(V_STROPTION = 'A') then
        V_STRBRID := '%%';
    else
        if(V_STROPTION = 'B') then
            select br.mapid into V_STRBRID from brgrp br where  br.brid = V_INBRID;
        else
            V_STRBRID := V_INBRID;
        end if;
    end if;

   v_fromdate := to_date(F_DATE,'dd/mm/rrrr');
   v_todate   := to_date(T_DATE,'dd/mm/rrrr');


   OPEN PV_REFCURSOR
  FOR
      select mst.brname,sum(decode(mst.authtype,'P',1,0)) So_TK_UQ_BMS, sum(decode(mst.authtype,'P',0,1)) So_TK_Khong_UQ_BMS,
        sum(mst.matchamt) Tong_gtri_gd
    from
    (   --DS cac tai khoan co phat sinh GD trong thoi gian tao bao cao
        select br.brname, af.custid, au.authtype, sum(od.matchamt) matchamt
        from vw_odmast_all od, afmast af,
            (select ca.cfcustid, max(case when substr(nvl(cf.custodycd,'----'),4,1) = 'P' then 'P' else 'C' end) authtype
                from cfauth ca, cfmast cf
                where ca.custid = cf.custid(+)
                group by cfcustid
            ) au, cfmast cm, brgrp br
        where od.afacctno = af.acctno
            and af.custid = au.cfcustid
            and af.custid = cm.custid
            and cm.brid = br.brid
            and txdate between to_date(v_fromdate,'DD/MM/RRRR') and to_date(v_todate,'DD/MM/RRRR')
        group by br.brname,af.custid, au.authtype
    )mst, (
        select cf.custid, max(nvl(od.txdate, cf.opndate)) lasttradingdate
        from afmast af, cfmast cf, vw_odmast_all od
        where af.custid = cf.custid and af.acctno = od.afacctno (+)
            and nvl(od.txdate, cf.opndate) < to_date(v_fromdate,'DD/MM/RRRR')
        group by cf.custid
    )ld
    where mst.custid = ld.custid
        and ld.lasttradingdate <= ADD_MONTHS(to_date(v_fromdate,'DD/MM/RRRR'),-1)
    group by mst.brname
    ;
EXCEPTION
   WHEN OTHERS
   THEN
    PLOG.ERROR('CF7008.ERROR:'||SQLERRM || dbms_utility.format_error_backtrace);
      RETURN;
End;
/
