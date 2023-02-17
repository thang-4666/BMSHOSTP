SET DEFINE OFF;
CREATE OR REPLACE PROCEDURE cf70082
   (
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
        select br.brname, sum(decode(od.via,'O',1,0)) Tong_lenh_truc_tuyen,
            sum(decode(od.via,'T',1,0)) Tong_lenh_qua_dt,
            --sum( case when od.via = 'F' and nvl(au.authtype,'C')<>'P' then 1 else 0 end) Tong_lenh_qua_san,
            sum( case when od.via = 'F' and nvl(au.authtype,'C')='P' then 1 else 0 end) Tong_lenh_qua_san,
            sum( case when od.via = 'F' and nvl(au.authtype,'C')='P' and od.custid = au.custid then 1 else 0 end) Tong_lenh_qua_uyquyen
        from VW_ODMAST_ALL od, afmast af, brgrp br, cfmast cm,
            (select ca.cfcustid, max(case when substr(nvl(cf.custodycd,'----'),4,1) = 'P' then 'P' else 'C' end) authtype
            ,ca.custid
                from cfauth ca, cfmast cf
                where ca.custid = cf.custid(+)
                group by cfcustid,ca.custid
            ) au
        where od.afacctno = af.acctno
            and af.custid = cm.custid
            and cm.brid = br.brid
            and cm.custid = au.cfcustid(+)
            and od.txdate between to_date(v_fromdate,'DD/MM/RRRR') and to_date(v_todate,'DD/MM/RRRR')
            and od.matchamt > 0
        group by br.brname;
EXCEPTION
   WHEN OTHERS
   THEN

      RETURN;
End;
/
