SET DEFINE OFF;
CREATE OR REPLACE PROCEDURE "CF1021" (
   PV_REFCURSOR           IN OUT   PKG_REPORT.REF_CURSOR,
   OPT            IN       VARCHAR2,
   pv_BRID           IN       VARCHAR2,
   TLGOUPS        IN       VARCHAR2,
   TLSCOPE        IN       VARCHAR2,
   pv_CODEID       IN       VARCHAR2

  )
IS
--
-- PURPOSE: BRIEFLY EXPLAIN THE FUNCTIONALITY OF THE PROCEDURE
--
-- MODIFICATION HISTORY
-- PERSON      DATE       COMMENTS
-- Diennt      28/12/2011 Create
-- ---------   ------     -------------------------------------------
   V_STROPTION        VARCHAR2 (5);       -- A: ALL; B: BRANCH; S: SUB-BRANCH
   V_STRBRGID           VARCHAR2 (10);
   V_branch  varchar2(5);
   V_INBRID        VARCHAR2(4);
   V_STRBRID      VARCHAR2 (50);
-- DECLARE PROGRAM VARIABLES AS SHOWN ABOVE

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

OPEN PV_REFCURSOR
  FOR
  Select reg.* from registeronline reg
  where reg.idcode=pv_CODEID;
EXCEPTION
   WHEN OTHERS
   THEN

      RETURN;
End;

 
 
 
 
/
