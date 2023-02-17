SET DEFINE OFF;
CREATE OR REPLACE PROCEDURE cf0111 (
   PV_REFCURSOR   IN OUT   PKG_REPORT.REF_CURSOR,
   OPT            IN       VARCHAR2,
   PV_BRID           IN       VARCHAR2,
   TLGOUPS        IN       VARCHAR2,
   TLSCOPE        IN       VARCHAR2,
   F_DATE         IN       VARCHAR2,
   T_DATE         IN       VARCHAR2,
   FACTYPE         IN       VARCHAR2,
   TACTYPE         IN       VARCHAR2,
   CUSTODYCD      IN       VARCHAR2
 )
IS
--
-- PURPOSE: BRIEFLY EXPLAIN THE FUNCTIONALITY OF THE PROCEDURE
--
-- MODIFICATION HISTORY
-- PERSON      DATE    COMMENTS
-- NgocVTT edit 23/06/15
-- ---------   ------  -------------------------------------------
   V_STROPTION        VARCHAR2 (5);       -- A: ALL; B: BRANCH; S: SUB-BRANCH
   V_STRBRID          VARCHAR2 (4);
   V_INBRID            VARCHAR2(4);            -- USED WHEN V_NUMOPTION > 0
   V_FACTYPE           VARCHAR2 (16);
   V_TACTYPE          VARCHAR2 (16);
   V_CUSTODYCD          VARCHAR2 (16);
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
   IF (FACTYPE <> 'ALL')
   THEN
      V_FACTYPE := FACTYPE;
   ELSE
      V_FACTYPE := '%%';
   END IF;

   IF (CUSTODYCD <> 'ALL')
   THEN
      V_CUSTODYCD:= CUSTODYCD;
   ELSE
      V_CUSTODYCD := '%%';
   END IF;


   IF (TACTYPE <> 'ALL')
   THEN
      V_TACTYPE := TACTYPE;
   ELSE
      V_TACTYPE := '%%';
   END IF;



      OPEN PV_REFCURSOR
       FOR
     SELECT ac.*, fcft.typename facname,tcft.typename tacname,cf.fullname
    FROM  AccCftypeLog ac, cfmast cf , cftype fcft, cftype tcft 
    WHERE ac.custid = cf.custid 
    AND ac.fractype = fcft.actype (+)
    AND ac.toactype =  tcft.actype
    AND ac.txdate BETWEEN to_date(F_DATE,'DD/MM/YYYY') AND to_date(T_DATE,'DD/MM/YYYY')
              ;
 EXCEPTION
   WHEN OTHERS
   THEN
    --insert into temp_bug(text) values('CF0001');commit;
      RETURN;
END;                                                              -- PROCEDURE
 
 
 
 
/
