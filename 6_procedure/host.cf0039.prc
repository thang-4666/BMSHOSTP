SET DEFINE OFF;
CREATE OR REPLACE PROCEDURE "CF0039" (
   PV_REFCURSOR   IN OUT   PKG_REPORT.REF_CURSOR,
   OPT            IN       VARCHAR2,
   pv_BRID           IN       VARCHAR2,
   TLGOUPS        IN       VARCHAR2,
   TLSCOPE        IN       VARCHAR2,
   F_DATE         IN       VARCHAR2,
   T_DATE         IN       VARCHAR2,
   BRGID          IN       VARCHAR2,
   CUSTODYCD        IN       VARCHAR2
)
IS
--
-- PURPOSE: BRIEFLY EXPLAIN THE FUNCTIONALITY OF THE PROCEDURE
--
-- MODIFICATION HISTORY
-- PERSON      DATE    COMMENTS
-- NAMNT   21-NOV-06  CREATED
-- DIENNT  12-01-2012  EDIT
-- ---------   ------  -------------------------------------------
   V_STROPTION        VARCHAR2 (5);       -- A: ALL; B: BRANCH; S: SUB-BRANCH
   V_INBRID        VARCHAR2(4);
    V_STRBRID      VARCHAR2 (50);

   V_STRAFACCTNO     VARCHAR2 (16);
   V_STRBRGID           VARCHAR2 (10);
   V_STRCUSTODYCD         VARCHAR2 (20);
v_yearauth number ;
-- DECLARE PROGRAM VARIABLES AS SHOWN ABOVE
BEGIN
  /* V_STROPTION := OPT;

   IF (V_STROPTION <> 'A') AND (BRID <> 'ALL')
   THEN
      V_STRBRID := BRID;
   ELSE
      V_STRBRID := '%%';
   END IF;*/
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

    IF (CUSTODYCD  <> 'ALL')
   THEN
      V_STRCUSTODYCD  := CUSTODYCD;
   ELSE
      V_STRCUSTODYCD := '%%';
   END IF;





   -- END OF GETTING REPORT'S PARAMETERS

   -- GET REPORT'S DATA
    OPEN PV_REFCURSOR
        FOR
        SELECT DISTINCT
          (CASE WHEN length(AUTH1) > 0 AND length(AUTH2) > 0 AND length(AUTH3) > 0
           AND length(AUTH4) > 0 AND length(AUTH5) > 0  THEN '0'
           ELSE
            (trim(AUTH1
            || case when length(AUTH1) > 0 and length(AUTH2) > 0 then ',' else '' end
            || AUTH2
            || case when length(AUTH1||AUTH2) > 0 and length(AUTH3) > 0 then ',' else '' end
            || AUTH3
            || case when length(AUTH1||AUTH2||AUTH3) > 0 and length(AUTH4) > 0 then ',' else '' end
            || AUTH4
            || case when length(AUTH1||AUTH2||AUTH3||AUTH4) > 0 and length(AUTH5) > 0 then ',' else '' end
            || AUTH5)
            ) END
          )  LINKAUTH,FULLNAME ,CUSTODYCD  ,IDCODE ,ADDRESS ,FULLNAMEAUTH ,LICENSENO ,VALDATE ,EXPDATE,ADDRESSAUT,LOAI_UQ
          ,BRGID PHAM_VI
   FROM(
        SELECT
         (CASE WHEN CFK.AUT4='4'or CFK.AUT5='5' then '1' end) AUTH1,
         (CASE WHEN CFK.AUT3='3' then '2' end) AUTH2,
         (CASE WHEN CFK.AUT9='9' then '3' end) AUTH3,
         (CASE WHEN CFK.AUT10='10' then '4' end)AUTH4,
         (CASE WHEN CFK.AUT11='11' then '5' end) AUTH5,
         (CASE WHEN CFK.AUT1='1'and CFK.AUT2='2' and CFK.AUT1='1'and CFK.AUT3='3'
               and CFK.AUT4='4'and CFK.AUT5='5' and CFK.AUT6='6'and CFK.AUT7='7'
               and CFK.AUT8='8'and CFK.AUT9='9' and CFK.AUT10='10'and CFK.AUT11='11'
               then '0' end) AUTH6,
         (CASE WHEN CFK.AUT1='1'or CFK.AUT2='2' or CFK.AUT6='6' then '' end) AUTH7,
               CFK.FULLNAME ,CFK.CUSTODYCD  ,CFK.IDCODE ,CFK.ADDRESS ,
               CFK.FULLNAMEAUTH  FULLNAMEAUTH ,CFK.LICENSENO ,CFK.VALDATE , TO_DATE(CFK.EXPDATE, 'DD/MM/YYYY') EXPDATE, CFK.ADDRESSAUT,CFK.LOAI_UQ
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
                   CFA.VALDATE ,
                   case when cfa.custid is null then cfa.ADDRESS else cf2.address end ADDRESSAUT,
                   (CASE when to_number(to_char(CFA.EXPDATE,'YYYY')) < 3000 then '1' else '2' end) LOAI_UQ,
                   (CASE when  to_number(to_char(CFA.EXPDATE,'YYYY'))< 3000  then to_char(CFA.EXPDATE, 'DD/MM/YYYY') else '' end) EXPDATE
             FROM (SELECT * FROM CFMAST WHERE FNC_VALIDATE_SCOPE(BRID, CAREBY, TLSCOPE, pv_BRID, TLGOUPS)=0)  CF1, AFMAST AF , CFAUTH CFA, CFMAST CF2
             WHERE  CF1.CUSTID =AF.CUSTID
             AND cf1.CUSTID =CFA.CFCUSTID
             AND CFA.CUSTID = CF2.CUSTID(+)
             AND SUBSTR(AF.ACCTNO,1,4) LIKE  V_STRBRGID
             AND CFA.VALDATE <=TO_DATE(T_DATE ,'DD/MM/YYYY')
             AND CFA.VALDATE >=TO_DATE(F_DATE ,'DD/MM/YYYY')
             AND NVL(CF1.CUSTODYCD,'-') like V_STRCUSTODYCD
             AND (af.brid LIKE V_STRBRID or instr(V_STRBRID,af.brid) <> 0 )
             ORDER BY AF.acctno ,CF1.SHORTNAME)CFK)
             ;
 EXCEPTION
   WHEN OTHERS
   THEN
      RETURN;
END;                                                              -- PROCEDURE

 
 
 
 
/
