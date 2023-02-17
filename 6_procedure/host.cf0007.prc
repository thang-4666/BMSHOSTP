SET DEFINE OFF;
CREATE OR REPLACE PROCEDURE "CF0007" (
   PV_REFCURSOR   IN OUT   PKG_REPORT.REF_CURSOR,
   OPT            IN       VARCHAR2,
   PV_BRID           IN       VARCHAR2,
   TLGOUPS        IN       VARCHAR2,
   TLSCOPE        IN       VARCHAR2,
   F_DATE         IN       VARCHAR2,
   T_DATE         IN       VARCHAR2,
   PV_CUSTODYCD   IN       VARCHAR2,
   PV_AFACCTNO    IN       VARCHAR2,
   TLID            IN       VARCHAR2
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
   V_STRPV_AFACCTNO VARCHAR2(20);
   V_INBRID        VARCHAR2(4);
   V_STRBRID      VARCHAR2 (50);
   V_STRTLID           VARCHAR2(6);
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
   IF(TLID <> 'ALL' AND TLID IS NOT NULL)
   THEN
        V_STRTLID:=TLID;
   ELSE
        V_STRTLID:='ZZZZZZZZZ';
   END IF;

    V_STROPTION := upper(OPT);
    V_INBRID := PV_BRID;
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

    IF(PV_AFACCTNO <> 'ALL')
   THEN
        V_STRPV_AFACCTNO  := PV_AFACCTNO;
   ELSE
        V_STRPV_AFACCTNO := '%%';
   END IF;

OPEN PV_REFCURSOR
  FOR

SELECT * FROM
  (/*SELECT  action_flag, cf.custodycd, af.acctno ,'AFMAST' ID,tl1.tlfullname maker_id, to_date(ma.maker_dt,'dd/mm/yyyy') maker_dt,
         tl2.tlfullname approve_id,ma.approve_dt, caption column_name, from_value, to_value
  FROM maintain_log ma, afmast af,tlprofiles tl1,tlprofiles tl2,fldmaster FLD ,cfmast cf
  WHERE
        ma.table_name='AFMAST'
    and ma.action_flag='EDIT'
    and af.acctno=substr(trim(ma.record_key),11,10)
    and tl1.tlid(+)=ma.maker_id
    and tl2.tlid(+)=ma.approve_id
    AND FLD.fldname = ma.column_name
    AND FLD.objname ='CF.AFMAST'
    and af.custid = cf.custid
    AND ma.maker_dt <= to_date(T_DATE,'DD/MM/YYYY' )
    AND ma.maker_dt >= to_date(F_DATE,'DD/MM/YYYY' )
    AND AF.ACCTNO LIKE V_STRPV_AFACCTNO
    and cf.custodycd like V_STRPV_CUSTODYCD
--  ORDER BY ma.approve_dt
--  )
    --order by af.acctno
  UNION ALL*/
--  SELECT * FROM
--  (
  SELECT DISTINCT action_flag, cf.custodycd, 'CFMAST' ID,tl1.tlname maker_id, to_char(ma.maker_dt,'DD/MM/YYYY') maker_dt,
         tl2.tlname approve_id,ma.approve_dt, caption column_name, from_value, to_value
  FROM maintain_log  ma, (SELECT * FROM CFMAST WHERE FNC_VALIDATE_SCOPE(BRID, CAREBY, TLSCOPE, V_INBRID, TLGOUPS)=0) cf,tlprofiles tl1,tlprofiles tl2,fldmaster FLD ,afmast af
  WHERE
        ma.table_name='CFMAST'
    and ma.action_flag='EDIT'
    and cf.custid=substr(trim(ma.record_key),11,10)
    and tl1.tlid(+)=ma.maker_id
    and tl2.tlid(+)=ma.approve_id
    AND FLD.fldname = ma.column_name
---    AND FLD.objname ='CF.CFMAST'
    AND FLD.objname  like case when length(child_table_name)>0 then '%' || child_table_name || '%' else 'CF.CFMAST' end
    AND ma.maker_dt <= to_date(T_DATE,'DD/MM/YYYY' )
    AND ma.maker_dt >= to_date(F_DATE,'DD/MM/YYYY' )
      and af.custid = cf.custid
     AND AF.ACCTNO LIKE V_STRPV_AFACCTNO
    and cf.custodycd like V_STRPV_CUSTODYCD

--    ORDER BY ma.approve_dt
    )
    ORDER BY  ID, approve_dt
    --order by cf.custid
;

EXCEPTION
   WHEN OTHERS
   THEN

      RETURN;
End;
 
/
