SET DEFINE OFF;
CREATE OR REPLACE PROCEDURE "CF7003" (
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

  select lg.maker_dt, lg.approve_dt, lg.maker_time, tlp1.tlname maker, tlp2.tlname approve, cf.custodycd, lg.column_name,
    lg.from_value, lg.to_value
from
(
    select lg.maker_id, lg.approve_id, lg.maker_dt, lg.approve_dt, substr(lg.record_key,11,10) custid, lg.record_key,
        lg.from_value, lg.to_value, lg.maker_time, lg.column_name
    from maintain_log lg
    where lg.table_name = 'CFMAST' and lg.action_flag = 'EDIT'
        and lg.column_name in ('IDCODE','IDDATE','MOBILESMS','DATEOFBIRTH','SEX','IDPLACE','ADDRESS')
        and lg.maker_dt >= v_fromdate and lg.maker_dt <= v_todate
) lg, (SELECT * FROM CFMAST WHERE FNC_VALIDATE_SCOPE(BRID, CAREBY, TLSCOPE, pv_BRID, TLGOUPS)=0) cf, tlprofiles tlp1, tlprofiles tlp2
where lg.custid = cf.custid and lg.maker_id = tlp1.tlid
    and nvl(lg.approve_id,'z') = tlp2.tlid(+) and cf.custodycd like V_STRPV_CUSTODYCD
;

EXCEPTION
   WHEN OTHERS
   THEN

      RETURN;
End;

 
 
 
 
/
