SET DEFINE OFF;
CREATE OR REPLACE PROCEDURE "CF00601" (
   PV_REFCURSOR   IN OUT   PKG_REPORT.REF_CURSOR,
   OPT            IN       VARCHAR2,
   pv_BRID           IN       VARCHAR2,
   TLGOUPS        IN       VARCHAR2,
   TLSCOPE        IN       VARCHAR2,
   F_DATE         IN       VARCHAR2,
   T_DATE         IN       VARCHAR2
 )
IS
--

   V_STROPTION    VARCHAR2 (5);            -- A: ALL; B: BRANCH; S: SUB-BRANCH
   V_STRBRID      VARCHAR2 (40);            -- USED WHEN V_NUMOPTION > 0
   V_INBRID     VARCHAR2 (5);      -- USED WHEN V_NUMOPTION > 0

   V_TODATE     DATE;
   V_FROMDATE   DATE;
-- DECLARE PROGRAM VARIABLES AS SHOWN ABOVE

BEGIN
-- INSERT INTO TEMP_BUG(TEXT) VALUES('CF0001');COMMIT;
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


OPEN PV_REFCURSOR
  FOR
SELECT sum(CN_TN) CN_TN, sum(TC_TN) TC_TN, sum(CN_NN) CN_NN, sum(TC_NN) TC_NN   FROM
    (
    SELECT sum( CASE WHEN substr(cf.custodycd,4,1) = 'F' AND cf.custtype = 'I' THEN 1 ELSE 0 END) CN_NN,
           sum( CASE WHEN substr(cf.custodycd,4,1) = 'F' AND cf.custtype = 'B' THEN 1 ELSE 0 END) TC_NN,
           sum( CASE WHEN substr(cf.custodycd,4,1) <> 'F' AND cf.custtype = 'I' THEN 1 ELSE 0 END) CN_TN,
           sum( CASE WHEN substr(cf.custodycd,4,1) <> 'F' AND cf.custtype = 'B' THEN 1 ELSE 0 END) TC_TN
    FROM cfmast cf  WHERE cf.opndate <= V_TODATE AND cf.custatcom = 'Y'
                    AND (cf.brid LIKE V_STRBRID or instr(V_STRBRID,cf.brid) <> 0 )

    UNION all

    SELECT sum(CASE WHEN substr(cf.custodycd,4,1) = 'F' AND  cf.custtype = 'I' THEN
                   CASE WHEN tl.tltxcd = '0059' THEN -1 ELSE 1 END
                 ELSE 0 END) CN_NN ,
           sum(CASE WHEN substr(cf.custodycd,4,1) = 'F' AND  cf.custtype = 'B' THEN
                   CASE WHEN tl.tltxcd = '0059' THEN -1 ELSE 1 END
                 ELSE 0 END) TC_NN ,
           sum(CASE WHEN substr(cf.custodycd,4,1) <> 'F' AND  cf.custtype = 'I' THEN
                   CASE WHEN tl.tltxcd = '0059' THEN -1 ELSE 1 END
                 ELSE 0 END) CN_TN ,
           sum(CASE WHEN substr(cf.custodycd,4,1) <> 'F' AND  cf.custtype = 'B' THEN
                   CASE WHEN tl.tltxcd = '0059' THEN -1 ELSE 1 END
                 ELSE 0 END) TC_NN
       FROM vw_tllog_all tl, (SELECT * FROM CFMAST WHERE FNC_VALIDATE_SCOPE(BRID, CAREBY, TLSCOPE, pv_BRID, TLGOUPS)=0) cf
       WHERE tl.tltxcd IN ('0059','0067') AND tl.busdate <= V_TODATE AND tl.deltd <> 'Y'
       AND cf.opndate <= V_TODATE AND cf.custatcom = 'Y'
       AND cf.custid = tl.msgacct
       AND (cf.brid LIKE V_STRBRID or instr(V_STRBRID,cf.brid) <> 0 )

    ) close_open

;

EXCEPTION
   WHEN OTHERS
   THEN

      RETURN;
End;

 
 
 
 
/
