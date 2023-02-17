SET DEFINE OFF;
CREATE OR REPLACE PROCEDURE "CF0016" (
   PV_REFCURSOR   IN OUT   PKG_REPORT.REF_CURSOR,
   OPT            IN       VARCHAR2,
   pv_BRID           IN       VARCHAR2,
   TLGOUPS        IN       VARCHAR2,
   TLSCOPE        IN       VARCHAR2,
   F_DATE         IN       VARCHAR2,
   T_DATE         IN       VARCHAR2,
   FROM_DATE         IN       VARCHAR2,
   TO_DATE         IN       VARCHAR2,
   BRGID          IN       VARCHAR2,
   REFNAME        IN       VARCHAR2
)
IS
--
-- PURPOSE: BRIEFLY EXPLAIN THE FUNCTIONALITY OF THE PROCEDURE
--
-- MODIFICATION HISTORY
-- PERSON      DATE    COMMENTS
-- NAMNT   21-NOV-06  CREATED
-- ---------   ------  -------------------------------------------
   V_STROPTION        VARCHAR2 (5);       -- A: ALL; B: BRANCH; S: SUB-BRANCH
   V_STRAFACCTNO     VARCHAR2 (16);
   V_STRBRGID           VARCHAR2 (10);
   V_STRREFNAME         VARCHAR2 (2000);
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
   -- GET REPORT'S PARAMETERS

  IF (BRGID  <> 'ALL')
   THEN
      V_STRBRGID  := BRGID;
   ELSE
      V_STRBRGID := '%%';
   END IF;

    IF (REFNAME  <> 'ALL')
   THEN
      V_STRREFNAME  := REFNAME;
   ELSE
      V_STRREFNAME := '%%';
   END IF;

   -- END OF GETTING REPORT'S PARAMETERS

   -- GET REPORT'S DATA
    OPEN PV_REFCURSOR
        FOR
        SELECT DISTINCT
         (CASE WHEN length(AUTH1) > 0 AND length(AUTH2) > 0 AND length(AUTH3) > 0
             THEN 'IV'
           ELSE
          trim(AUTH1
          || case when length(AUTH1) > 0 and length(AUTH2) > 0 then ',' else '' end
          || AUTH2
          || case when length(AUTH1||AUTH2) > 0 and length(AUTH3) > 0 then ',' else '' end
          || AUTH3
          )
          END )
           LINKAUTH,FULLNAME ,CUSTODYCD  ,IDCODE ,ADDRESS ,FULLNAMEAUTH ,LICENSENO ,VALDATE ,EXPDATE,ADDRESSAUT,
           custtype, country, to_date(T_DATE,'dd/mm/yyyy') todate, PV_BRID PV_BRID
   FROM(
        SELECT
         (CASE WHEN CF.AUT4='4'or CF.AUT5='5' then 'I' end) AUTH1,
         (CASE WHEN CF.AUT3='3' then 'II' end) AUTH2,
         (CASE WHEN CF.AUT9='9' then 'III' end) AUTH3,
         (CASE WHEN CF.AUT10='10' then 'IV' end)AUTH4,
         (CASE WHEN CF.AUT11='11' then 'V' end) AUTH5,
         (CASE WHEN CF.AUT1='1'and CF.AUT2='2' and CF.AUT1='1'and CF.AUT3='3'
               and CF.AUT4='4'and CF.AUT5='5' and CF.AUT6='6'and CF.AUT7='7'
               and CF.AUT8='8'and CF.AUT9='9' and CF.AUT10='10'and CF.AUT11='11'
               then 'VI' end) AUTH6,
         (CASE WHEN CF.AUT1='1'or CF.AUT2='2' or CF.AUT6='6' then '' end) AUTH7,
               CF.FULLNAME ,CF.CUSTODYCD  ,CF.IDCODE ,CF.ADDRESS ,
               CF.FULLNAMEAUTH  FULLNAMEAUTH ,CF.LICENSENO ,CF.VALDATE ,CF.EXPDATE, CF.ADDRESSAUT,
               cf.custtype, cf.country
        FROM ( SELECT
             ( CASE WHEN SUBSTR(CFA.LINKAUTH,1,1) ='Y' THEN '1'END)AUT1,
             ( CASE WHEN SUBSTR(CFA.LINKAUTH,2,1) ='Y' THEN '2'END)AUT2,
             ( CASE WHEN SUBSTR(CFA.LINKAUTH,3,1) ='Y' THEN '3'END)AUT3,
             ( CASE WHEN SUBSTR(CFA.LINKAUTH,4,1) ='Y' THEN '4'END)AUT4,
             ( CASE WHEN SUBSTR(CFA.LINKAUTH,5,1) ='Y' THEN '5'END)AUT5,
             ( CASE WHEN SUBSTR(CFA.LINKAUTH,6,1) ='Y' THEN '6'END)AUT6,
             ( CASE WHEN SUBSTR(CFA.LINKAUTH,7,1) ='Y' THEN '7'END)AUT7,
             ( CASE WHEN SUBSTR(CFA.LINKAUTH,8,1) ='Y' THEN '8'END)AUT8,
             ( CASE WHEN SUBSTR(CFA.LINKAUTH,9,1) ='Y' THEN '9'END)AUT9,
             ( CASE WHEN SUBSTR(CFA.LINKAUTH,10,1) ='Y' THEN '10'END)AUT10,
             ( CASE WHEN SUBSTR(CFA.LINKAUTH,11,1) ='Y' THEN '11'END)AUT11,
             CF1.FULLNAME ,AF.ACCTNO ,CF1.CUSTODYCD  ,CF1.IDCODE ,CF1.IDDATE , CF1.ADDRESS,
                   case when cfa.custid is null then CFA.FULLNAME else cf2.fullname end FULLNAMEAUTH,
                   case when cfa.custid is null then cfa.LICENSENO else cf2.idcode end LICENSENO,
                   CFA.VALDATE ,CFA.EXPDATE,
                   case when cfa.custid is null then cfa.ADDRESS else cf2.address end ADDRESSAUT,
                cf1.custtype, cf1.country
             FROM (SELECT * FROM CFMAST WHERE FNC_VALIDATE_SCOPE(BRID, CAREBY, TLSCOPE, pv_BRID, TLGOUPS)=0) CF1,
                  afmast af, CFAUTH CFA, (SELECT * FROM CFMAST WHERE FNC_VALIDATE_SCOPE(BRID, CAREBY, TLSCOPE, pv_BRID, TLGOUPS)=0) CF2
             WHERE  CF1.CUSTID = CFA.CFCUSTID and cf1.custid = af.custid
             AND CFA.CUSTID = CF2.CUSTID(+)
             AND CFA.VALDATE <=TO_DATE(T_DATE ,'DD/MM/YYYY')
             AND CFA.VALDATE >=TO_DATE(F_DATE ,'DD/MM/YYYY')
             AND CFA.EXPDATE <=TO_DATE(TO_DATE ,'DD/MM/YYYY')
             AND CFA.EXPDATE >=TO_DATE(FROM_DATE ,'DD/MM/YYYY')
             AND AF.custid like V_STRREFNAME
             AND (af.brid LIKE V_STRBRID or instr(V_STRBRID,af.brid) <> 0 )
             ORDER BY CF1.SHORTNAME
             )
             CF)
             ;

 EXCEPTION
   WHEN OTHERS
   THEN
      RETURN;
END;                                                              -- PROCEDURE
 
 
 
 
/
