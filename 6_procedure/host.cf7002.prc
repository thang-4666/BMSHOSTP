SET DEFINE OFF;
CREATE OR REPLACE PROCEDURE "CF7002" (
   PV_REFCURSOR   IN OUT   PKG_REPORT.REF_CURSOR,
   OPT            IN       VARCHAR2,
   pv_BRID           IN       VARCHAR2,
   TLGOUPS        IN       VARCHAR2,
   TLSCOPE        IN       VARCHAR2,
   F_DATE         IN       VARCHAR2,
   T_DATE         IN       VARCHAR2,
   PV_CUSTODYCD   IN       VARCHAR2,
   PV_AFACCTNO    IN       VARCHAR2
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

    IF(PV_AFACCTNO <> 'ALL')
   THEN
        V_STRPV_AFACCTNO  := PV_AFACCTNO;
   ELSE
        V_STRPV_AFACCTNO := '%%';
   END IF;

   v_fromdate := to_date(F_DATE,'dd/mm/rrrr');
   v_todate   := to_date(T_DATE,'dd/mm/rrrr');

OPEN PV_REFCURSOR
  FOR

  SELECT LG.maker_dt, LG.maker_time, CF.custodycd, LG.AFACCTNO,
    '1' EXECTYPE, LG.ACTYPE, to_number(LG.MRCRLIMITMAX) MRCRLIMITMAX,  TLP1.tlname maker, TLP2.tlname approve
FROM
(
    SELECT LG.maker_dt, LG.maker_time, LG.maker_id, LG.approve_id,
        MAX(CASE WHEN LG.column_name = 'ACCTNO' THEN to_value ELSE '' END) AFACCTNO,
        MAX(CASE WHEN LG.column_name = 'ACTYPE' THEN to_value ELSE '' END) ACTYPE,
        MAX(CASE WHEN LG.column_name = 'MRCRLIMITMAX' THEN to_value ELSE '' END) MRCRLIMITMAX
    FROM maintain_log LG
    WHERE LG.action_flag = 'ADD'
        AND LG.table_name = 'CFMAST' AND LG.child_table_name = 'AFMAST'
        AND LG.column_name IN ('ACTYPE','ACCTNO','MRCRLIMITMAX')
        and lg.maker_dt >= v_fromdate
        and lg.maker_dt <= v_todate
    GROUP BY LG.maker_dt, LG.maker_time, LG.maker_id, LG.approve_id
) LG, (SELECT * FROM CFMAST WHERE FNC_VALIDATE_SCOPE(BRID, CAREBY, TLSCOPE, pv_BRID, TLGOUPS)=0) CF, AFMAST AF, aftype AFT, tlprofiles TLP1, tlprofiles TLP2
WHERE LG.AFACCTNO = AF.acctno AND CF.custid = AF.custid
    AND LG.ACTYPE = AFT.actype AND LG.maker_id = TLP1.tlid
    AND LG.approve_id = TLP2.tlid AND AFT.mnemonic = 'Margin'
    and af.acctno like V_STRPV_AFACCTNO and cf.custodycd like V_STRPV_CUSTODYCD
union all
SELECT LG.maker_dt, LG.maker_time, CF.custodycd, LG.AFACCTNO,
    '2' EXECTYPE, LG.ACTYPE, LG.MRCRLIMITMAX,  TLP1.tlname maker, TLP2.tlname approve
FROM
(
    SELECT LG.maker_dt, LG.maker_time, LG.maker_id, LG.approve_id,
        substr(lg.child_record_key,11,10) AFACCTNO,
        MAX(CASE WHEN LG.column_name = 'ACTYPE' THEN to_value ELSE '' END) ACTYPE ,
        max(fn_getmrcrlimitmax(substr(lg.child_record_key,11,10), to_char(maker_dt,'dd/mm/rrrr'))) MRCRLIMITMAX
    FROM maintain_log LG, aftype aft
    WHERE LG.action_flag = 'EDIT'  AND LG.column_name = 'ACTYPE'
        AND LG.table_name = 'CFMAST' AND LG.child_table_name = 'AFMAST'
        and lg.maker_dt >= v_fromdate
        and lg.maker_dt <= v_todate
        and lg.to_value = aft.actype and aft.mnemonic = 'Margin'
    GROUP BY LG.maker_dt, LG.maker_time, LG.maker_id, LG.approve_id,substr(lg.child_record_key,11,10)
) LG, CFMAST CF, AFMAST AF, tlprofiles TLP1, tlprofiles TLP2
WHERE LG.AFACCTNO = AF.acctno AND CF.custid = AF.custid
    AND LG.maker_id = TLP1.tlid AND LG.approve_id = TLP2.tlid
    and af.acctno like V_STRPV_AFACCTNO and cf.custodycd like V_STRPV_CUSTODYCD
union all
SELECT LG.maker_dt, LG.maker_time, CF.custodycd, LG.AFACCTNO,
    '3' EXECTYPE, LG.ACTYPE, to_number(LG.MRCRLIMITMAX) MRCRLIMITMAX,  TLP1.tlname maker, TLP2.tlname approve
FROM
(
    SELECT LG.maker_dt, LG.maker_time, LG.maker_id, LG.approve_id,
        substr(lg.child_record_key,11,10) AFACCTNO,
        max(fn_get_af_actype(substr(lg.child_record_key,11,10), to_char(LG.maker_dt,'dd/mm/rrrr'))) ACTYPE ,
        MAX(CASE WHEN LG.column_name = 'MRCRLIMITMAX' THEN to_value ELSE '' END) MRCRLIMITMAX
    FROM maintain_log LG
    WHERE LG.action_flag = 'EDIT'  AND LG.column_name = 'MRCRLIMITMAX'
        AND LG.table_name = 'CFMAST' AND LG.child_table_name = 'AFMAST'
        and lg.maker_dt >= v_fromdate
        and lg.maker_dt <= v_todate
    GROUP BY LG.maker_dt, LG.maker_time, LG.maker_id, LG.approve_id,substr(lg.child_record_key,11,10)
) LG, (SELECT * FROM CFMAST WHERE FNC_VALIDATE_SCOPE(BRID, CAREBY, TLSCOPE, pv_BRID, TLGOUPS)=0) CF, AFMAST AF, tlprofiles TLP1, tlprofiles TLP2, aftype aft
WHERE LG.AFACCTNO = AF.acctno AND CF.custid = AF.custid
    AND LG.maker_id = TLP1.tlid AND LG.approve_id = TLP2.tlid
    and lg.ACTYPE = aft.actype and aft.mnemonic = 'Margin'
    and af.acctno like V_STRPV_AFACCTNO and cf.custodycd like V_STRPV_CUSTODYCD
;

EXCEPTION
   WHEN OTHERS
   THEN

      RETURN;
End;

 
 
 
 
/
