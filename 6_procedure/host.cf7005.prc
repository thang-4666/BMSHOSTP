SET DEFINE OFF;
CREATE OR REPLACE PROCEDURE "CF7005" (
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
        V_STRBRID := V_INBRID;
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

select cf.custodycd, cf.fullname, lg.afacctno, lg.maker_dt, tlp1.tlname maker, lg.maker_time,
    lg.approve_dt, tlp2.tlname approve, lg.to_value
from
(
    select substr(child_record_key,11,10) afacctno, maker_dt, maker_id, maker_time, approve_dt, approve_id, lg.to_value
    from maintain_log lg
    where lg.table_name = 'CFMAST' and lg.child_table_name = 'AFMAST'
        and lg.column_name = 'BANKACCTNO' and to_value is not null
        and lg.maker_dt >= v_fromdate and lg.maker_dt <= v_todate
) lg, (SELECT * FROM CFMAST WHERE FNC_VALIDATE_SCOPE(BRID, CAREBY, TLSCOPE, pv_BRID, TLGOUPS)=0) cf, afmast af, tlprofiles tlp1, tlprofiles tlp2
where lg.afacctno = af.acctno and cf.custid = af.custid
    and lg.maker_id = tlp1.tlid and lg.approve_id = tlp2.tlid(+)
    and cf.custodycd like V_STRPV_CUSTODYCD
    and substr(cf.custid,1,4) like V_STRBRID
;

EXCEPTION
   WHEN OTHERS
   THEN

      RETURN;
End;

 
 
 
 
/
