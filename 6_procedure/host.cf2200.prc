SET DEFINE OFF;
CREATE OR REPLACE PROCEDURE "CF2200" (
   PV_REFCURSOR   IN OUT   PKG_REPORT.REF_CURSOR,
   OPT            IN       VARCHAR2,
   PV_BRID           IN       VARCHAR2,
   TLGOUPS        IN       VARCHAR2,
   TLSCOPE        IN       VARCHAR2,
   PV_IDCODE         IN       VARCHAR2
)
IS
--
-- PURPOSE: BRIEFLY EXPLAIN THE FUNCTIONALITY OF THE PROCEDURE
-- ---------   ------  -------------------------------------------
   V_STROPTION        VARCHAR2 (5);       -- A: ALL; B: BRANCH; S: SUB-BRANCH
   V_STRBRID          VARCHAR2 (4);
   V_INBRID            VARCHAR2(4);            -- USED WHEN V_NUMOPTION > 0

-- DECLARE PROGRAM VARIABLES AS SHOWN ABOVE
BEGIN
   V_STROPTION := upper(OPT);
   V_INBRID := pv_BRID;

   IF (V_STROPTION = 'A')
   THEN
      V_STRBRID := '%';
   ELSE if (V_STROPTION = 'B') then
            select brgrp.mapid into V_STRBRID from brgrp where brgrp.brid = V_INBRID;
        else
            V_STRBRID := V_INBRID;
        end if;
   END IF;

   -- GET REPORT'S PARAMETERS

   OPEN PV_REFCURSOR
       FOR
        SELECT CF.* ,
               CASE WHEN NVL(BR.BRID,'0001') = '0001' THEN 'Hà Nội'
                    ELSE nvl(br.brname,'____') END inplace
        FROM CFMASTTEMP CF, BRGRP BR
        WHERE TRIM(CF.IDCODE) = TRIM(PV_IDCODE) AND CF.AREA = BR.GLMAPID(+)
       ;
 EXCEPTION
   WHEN OTHERS
   THEN
    --insert into temp_bug(text) values('CF0001');commit;
      RETURN;
END;                                                              -- PROCEDURE

 
 
 
 
/
