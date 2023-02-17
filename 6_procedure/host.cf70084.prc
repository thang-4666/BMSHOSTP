SET DEFINE OFF;
CREATE OR REPLACE PROCEDURE cf70084
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
        select sum(case when mst.So_lan >= 5 then 1 else 0 end) Tong_So_Tk_50lan,
    sum(case when mst.So_lan >= 5 then mst.So_lan else 0 end) Tong_So_Lan_50lan,
    sum(case when mst.So_lan >= 5 then mst.Gia_Tri else 0 end) Tong_Gia_tri_50lan,
    sum(mst.So_lan) Tong_so_lan_cty
from
(
    select af.custid, count(*) So_lan, sum(tl.msgamt) Gia_Tri
    from vw_tllog_all tl, afmast af
    where tl.msgacct = af.acctno
        and tl.tltxcd in ('1131','1141')
        and tl.deltd <> 'Y'
        and tl.txdate between to_date(v_fromdate,'DD/MM/RRRR') and to_date(v_todate,'DD/MM/RRRR')
    group by af.custid
) mst;
EXCEPTION
   WHEN OTHERS
   THEN

      RETURN;
End;
/
