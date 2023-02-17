SET DEFINE OFF;
CREATE OR REPLACE PROCEDURE "OD1020" (
   PV_REFCURSOR   IN OUT   PKG_REPORT.REF_CURSOR,
   OPT            IN       VARCHAR2,
   pv_BRID           IN       VARCHAR2,
   TLGOUPS        IN       VARCHAR2,
   TLSCOPE        IN       VARCHAR2,
   F_DATE         IN       VARCHAR2,
   T_DATE         IN       VARCHAR2
)
IS
    V_STROPTION    VARCHAR2 (5);            -- A: ALL; B: BRANCH; S: SUB-BRANCH
   V_STRBRID      VARCHAR2 (40);            -- USED WHEN V_NUMOPTION > 0
   V_INBRID     VARCHAR2 (5);

   V_FROMDATE DATE;
   V_TODATE DATE;

BEGIN
-- GET REPORT'S PARAMETERS
   V_STROPTION := upper(OPT);
   V_INBRID := pv_BRID;

   if(V_STROPTION = 'A') then
        V_STRBRID := '%';
    else
        if(V_STROPTION = 'B') then
            select br.mapid into V_STRBRID from brgrp br where  br.brid = V_INBRID;
        else
            V_STRBRID := pv_BRID;
        end if;
    end if;

   V_FROMDATE := to_date(F_DATE,'DD/MM/RRRR');
   V_TODATE := to_date(T_DATE,'DD/MM/RRRR');


-- GET REPORT'S DATA
 OPEN PV_REFCURSOR
 FOR
select A.* ,
       round(So_Lenh_Online/decode(So_Lenh,0,0.000001,So_Lenh) * 100,2) TyLe_Lenh_Online,
       round(Gia_Tri_Lenh_Online/decode(Gia_Tri_Lenh,0,0.000001,Gia_Tri_Lenh) * 100,2) TyLe_Gia_tri_Lenh_Online,
       round(Gia_Tri_khop_Lenh_Online/decode(Gia_Tri_Lenh_Online,0,0.000001,Gia_Tri_Lenh_Online) * 100,2) TyLe_Khop_Lenh_Tren_Online,
       round(Gia_Tri_khop_Lenh_Online/decode(Gia_Tri_khop_Lenh,0,0.000001,Gia_Tri_khop_Lenh) * 100,2) TyLe_Khop_Lenh_Online,
       round(Gia_Tri_khop_Lenh/decode(Gia_Tri_Lenh,0,0.000001,Gia_Tri_Lenh) * 100,2) TyLe_Khop_Lenh,
       round(So_Lenh_HUY_SUA/decode(So_Lenh,0,0.000001,So_Lenh) * 100,2) TyLe_Lenh_HuySua,
       round(So_Lenh_Dat/decode(So_Lenh,0,0.000001,So_Lenh) * 100,2) TyLe_Lenh_Dat

from (
    select
    sum(case when OD.via ='O' then 1 else 0 end) So_Lenh_Online,
    sum(case when OD.via ='O' then orderqtty * quoteprice else 0 end) Gia_Tri_Lenh_Online,
    sum(case when OD.via ='O' then execamt else 0 end) Gia_Tri_khop_Lenh_Online,
    count(1) So_Lenh,
    sum(orderqtty * quoteprice) Gia_Tri_Lenh,
    sum(execamt) Gia_Tri_khop_Lenh,
    sum(case when exectype in ('CB','CS','AB','AS') then 1 else 0 end) So_Lenh_HUY_SUA,
    sum(case when exectype in ('CB','CS','AB','AS') then orderqtty * quoteprice else 0 end) Gia_Tri_Lenh_HUY_SUA,
    sum(case when exectype in ('CB','CS','AB','AS') then 0 else 1 end) So_Lenh_DAT,
    sum(case when exectype in ('CB','CS','AB','AS') then 0 else orderqtty * quoteprice end) Gia_Tri_Lenh_DAT,
    sum(case when exectype in ('CB','CS','AB','AS') and OD.via='O' then 1 else 0 end) So_Lenh_HUYSUA_Online,
    sum(case when exectype in ('CB','CS','AB','AS') and OD.via='O' then orderqtty * quoteprice else 0 end) Gia_Tri_Lenh_HUYSUA_Online,
    sum(case when exectype in ('NB','NS','MS') and OD.via='O' then 1 else 0 end) So_Lenh_DAT_Online,
    sum(case when exectype in ('NB','NS','MS') AND OD.via = 'O' then orderqtty * quoteprice ELSE 0 end) Gia_Tri_Lenh_DAT_Online
    from vw_odmast_all od, AFMAST AF,(SELECT * FROM CFMAST WHERE FNC_VALIDATE_SCOPE(BRID, CAREBY, TLSCOPE, pv_BRID, TLGOUPS)=0) cf
    where txdate >= V_FROMDATE AND txdate <= V_TODATE
       and af.custid = cf.custid
    AND OD.AFACCTNO = AF.ACCTNO AND AF.ACTYPE NOT IN ('0000')
    --and txdate <(select to_date(varvalue,'DD/MM/RRRR') from sysvar where varname ='CURRDATE')
    and deltd <> 'Y'
) A


;


EXCEPTION
   WHEN OTHERS
   THEN
      RETURN;
END;

 
 
 
 
/
