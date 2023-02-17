SET DEFINE OFF;
CREATE OR REPLACE PROCEDURE ca0050 (
   PV_REFCURSOR   IN OUT   PKG_REPORT.REF_CURSOR,
   OPT            IN       VARCHAR2,
   pv_BRID           IN       VARCHAR2,
   TLGOUPS        IN       VARCHAR2,
   TLSCOPE        IN       VARCHAR2,
   CACODE         IN       VARCHAR2,
   PLSENT         in       varchar2
  )
IS
--
/*=={}===============>*/
---------   ------  -------------------------------------------

    CUR             PKG_REPORT.REF_CURSOR;
    V_STROPTION    VARCHAR2 (5);            -- A: ALL; B: BRANCH; S: SUB-BRANCH
    V_STRBRID      VARCHAR2 (40);
    V_INBRID       VARCHAR2 (4);

    V_STRCACODE    VARCHAR2 (20);
    V_I_BRIDGD          VARCHAR2(100);
    V_BRNAME            NVARCHAR2(400);


BEGIN
   V_STROPTION := upper(OPT);
   V_INBRID := pv_BRID;

   IF (V_STROPTION = 'A') THEN
      V_STRBRID := '%';
   ELSE if(V_STROPTION = 'B') then
            select brgrp.brid into V_STRBRID from brgrp where brgrp.brid = V_INBRID;
        else
            V_STRBRID := V_INBRID;
        end if;
   END IF;



   IF (CACODE <> 'ALL')
   THEN
      V_STRCACODE := CACODE;
   ELSE
      V_STRCACODE := '%%';
   END IF;

   -- GET REPORT'S PARAMETERS

--Tinh ngay nhan thanh toan bu tru


OPEN PV_REFCURSOR
   FOR
    SELECT ISS.FULLNAME, SB.SYMBOL , SB.SECTYPE, SB.PARVALUE, to_char(CA.REPORTDATE,'dd/MM/yyyy') REPORTDATE,
        CA.ISINCODE, CA.EXRATE,CA.RIGHTOFFRATE, CA.EXPRICE, to_char(CA.BEGINDATE,'dd/MM/yyyy') BEGINDATE, to_char(CA.DUEDATE,'dd/MM/yyyy') DUEDATE,
        PLSENT SENDTO
    FROM CAMAST CA, (SELECT CAMASTID, SUM(QTTY) QTTY
    FROM CASCHD WHERE DELTD <> 'Y' GROUP BY CAMASTID) CAS, SBSECURITIES SB,
        ISSUERS ISS
    WHERE CA.CATYPE = '014' AND CA.CAMASTID = CAS.CAMASTID
        AND CAS.QTTY = 0 AND CA.CODEID = SB.CODEID
        AND SB.ISSUERID = ISS.ISSUERID AND CA.DELTD <> 'Y'
        AND CA.CAMASTID = V_STRCACODE
  ;


EXCEPTION
   WHEN OTHERS
   THEN
      RETURN;
END;
 
 
 
 
/
