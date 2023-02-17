SET DEFINE OFF;
CREATE OR REPLACE PROCEDURE "CF7006" (
   PV_REFCURSOR   IN OUT   PKG_REPORT.REF_CURSOR,
   OPT            IN       VARCHAR2,
   pv_BRID           IN       VARCHAR2,
   TLGOUPS        IN       VARCHAR2,
   TLSCOPE        IN       VARCHAR2,
   F_DATE         IN       VARCHAR2,
   T_DATE         IN       VARCHAR2,
   PV_CUSTODYCD   IN       VARCHAR2
 )
IS
--
-- PURPOSE: BRIEFLY EXPLAIN THE FUNCTIONALITY OF THE PROCEDURE
--
-- MODIFICATION HISTORY
-- PERSON      DATE       COMMENTS
-- Diennt      30/09/2011 Create
-- ---------   ------     -------------------------------------------
   V_STROPTION        VARCHAR2 (5);       -- A: ALL; B: BRANCH; S: SUB-BRANCH

   -- DECLARE PROGRAM VARIABLES AS SHOWN ABOVE
   V_STRPV_CUSTODYCD VARCHAR2(20);
   V_INBRID        VARCHAR2(4);
   V_STRBRID      VARCHAR2 (50);

   v_fromdate   date;
   v_todate     date;

BEGIN
/*
   V_STROPTION := OPT;

   IF (V_STROPTION <> 'A') AND (BRID <> 'ALL')
   THEN
      V_STRBRID := BRID;
   ELSE
      V_STRBRID := '%%';
   END IF;*/

--   V_STRTLID:=TLID;


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

   IF(PV_CUSTODYCD <> 'ALL')
   THEN
        V_STRPV_CUSTODYCD  := PV_CUSTODYCD;
   ELSE
        V_STRPV_CUSTODYCD  := '%%';
   END IF;


   v_fromdate := to_date(F_DATE,'dd/mm/rrrr');
   v_todate   := to_date(T_DATE,'dd/mm/rrrr');

OPEN PV_REFCURSOR
  FOR

select cf.custodycd, lg.maker_dt, tlp1.tlname maker, lg.maker_time, lg.approve_dt, tlp2.tlname approve, lg.cdcontent,
    lg.column_name
from
(
    select substr(record_key,11,10) custid, maker_dt, maker_id, maker_time, approve_dt, approve_id, al.cdcontent,
        lg.column_name
    from maintain_log LG, allcode al
    where LG.table_name = 'CFMAST' AND LG.column_name = 'TRADETELEPHONE'
        and action_flag in ('EDIT','ADD') and al.cdtype = 'SY'
        and al.cdname = 'YESNO' and lg.to_value = al.cdval
        and lg.maker_dt >= v_fromdate and lg.maker_dt <= lg.maker_dt
    union all
    select substr(record_key,11,10) custid, maker_dt, maker_id, maker_time, approve_dt, approve_id, al.cdcontent,
        lg.column_name
    from maintain_log LG, allcode al
    where LG.table_name = 'CFMAST' and lg.child_table_name = 'CFOTHERACC'
        and action_flag = 'ADD' and column_name = 'TYPE'
        and al.cdtype = 'AF' and al.cdname = 'TYPE'
        and lg.to_value = al.cdval
        and lg.maker_dt >= v_fromdate and lg.maker_dt <= lg.maker_dt
    union all
    select substr(record_key,11,10) custid, maker_dt, maker_id, maker_time, approve_dt, approve_id, al.cdcontent ,
        lg.column_name
    from maintain_log LG, allcode al
    where LG.table_name = 'CFMAST' and lg.child_table_name = 'OTRIGHT'
        and action_flag = 'ADD' and column_name = 'AUTHTYPE'
        and al.cdtype = 'CF' and al.cdname = 'OTAUTHTYPE'
        and lg.to_value = al.cdval
        and lg.maker_dt >= v_fromdate and lg.maker_dt <= lg.maker_dt
) lg, (SELECT * FROM CFMAST WHERE FNC_VALIDATE_SCOPE(BRID, CAREBY, TLSCOPE, pv_BRID, TLGOUPS)=0) cf, tlprofiles tlp1, tlprofiles tlp2
where lg.custid = cf.custid
    and lg.maker_id = tlp1.tlid and lg.approve_id = tlp2.tlid(+)
    and cf.custodycd like V_STRPV_CUSTODYCD
;

EXCEPTION
   WHEN OTHERS
   THEN

      RETURN;
End;

 
 
 
 
/
