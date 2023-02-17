SET DEFINE OFF;
CREATE OR REPLACE PROCEDURE "CF0002" (
   PV_REFCURSOR   IN OUT   PKG_REPORT.REF_CURSOR,
   OPT            IN       VARCHAR2,
   PV_BRID           IN       VARCHAR2,
   TLGOUPS        IN       VARCHAR2,
   TLSCOPE        IN       VARCHAR2,
   F_DATE         IN       VARCHAR2,
   T_DATE         IN       VARCHAR2,
   ACTYPE         IN       VARCHAR2,
   INCOMERANGE    IN       VARCHAR2,
   EDUCATION      IN       VARCHAR2,
   SECTOR         IN       VARCHAR2,
   AFTYPE         IN       VARCHAR2,
   CAREBY         IN       VARCHAR2,
   PLACE          IN       VARCHAR2,
   PV_CUSTODYCD   IN       VARCHAR2
)
IS
--
-- PURPOSE: BRIEFLY EXPLAIN THE FUNCTIONALITY OF THE PROCEDURE
--
-- MODIFICATION HISTORY
-- PERSON      DATE       COMMENTS
-- Hien.VU     07/05/2011
-- ---------   ------     -------------------------------------------
   V_STROPTION        VARCHAR2 (5);       -- A: ALL; B: BRANCH; S: SUB-BRANCH
   V_STRBRID          VARCHAR2 (4);              -- USED WHEN V_NUMOPTION > 0
   V_ACTYPE           VARCHAR2 (16);
   V_STRINCOMERANGE   VARCHAR2 (50);
   V_STREDUCATION     VARCHAR2 (50);
   V_STRSECTOR        VARCHAR2 (50);
   V_STRAFTYPE        VARCHAR2 (50);
   V_STRCAREBY        VARCHAR2 (50);
   V_STRPLACE         VARCHAR2 (50);
   V_STRREFNAME       VARCHAR2 (50);
   v_text             varchar2(1000);
-- DECLARE PROGRAM VARIABLES AS SHOWN ABOVE
BEGIN
-- insert into temp_bug(text) values('CF0001');commit;
   V_STROPTION := OPT;


   IF (V_STROPTION <> 'A') AND (PV_BRID <> 'ALL')
   THEN
      V_STRBRID := PV_BRID;
   ELSE
      V_STRBRID := '%%';
   END IF;

   -- GET REPORT'S PARAMETERS
   IF (ACTYPE <> 'ALL')
   THEN
      V_ACTYPE := ACTYPE;
   ELSE
      V_ACTYPE := '%%';
   END IF;

   IF (INCOMERANGE <> 'ALL')
   THEN
      V_STRINCOMERANGE := INCOMERANGE;
   ELSE
      V_STRINCOMERANGE := '%%';
   END IF;

   IF (EDUCATION <> 'ALL')
   THEN
      V_STREDUCATION := EDUCATION;
   ELSE
      V_STREDUCATION := '%%';
   END IF;


   IF (PV_CUSTODYCD <> 'ALL')
   THEN
      V_STRREFNAME:= PV_CUSTODYCD;
   ELSE
      V_STRREFNAME := '%%';
   END IF;

   IF (SECTOR <> 'ALL')
   THEN
      V_STRSECTOR := SECTOR;
   ELSE
      V_STRSECTOR := '%%';
   END IF;

   IF (AFTYPE <> 'ALL')
   THEN
      V_STRAFTYPE := AFTYPE;
   ELSE
      V_STRAFTYPE := '%%';
   END IF;

   IF (CAREBY <> 'ALL')
   THEN
      V_STRCAREBY := CAREBY;
   ELSE
      V_STRCAREBY := '%%';
   END IF;
   IF (PLACE <> 'ALL')
   THEN
      V_STRPLACE := PLACE;
   ELSE
      V_STRPLACE := '%%';
   END IF;



   -- END OF GETTING REPORT'S PARAMETERS
   -- GET REPORT'S DATA
--   IF (V_STROPTION <> 'A') AND (BRID <> 'ALL')
--   THEN
      OPEN PV_REFCURSOR
       FOR
          SELECT DISTINCT  OPNDATE, FULLNAME,DATEOFBIRTH,IDCODE,ADDRESS,IDPLACE,CUSTID, ACCTNO,
                   ACTYPE,BRID,CAREBY, CUSTTYPE, CUSTODYCD,IDDATE
                   ,COUNTRY, AFTYPE, NVL(REFNAME,' ') REFNAME
            FROM (
                  SELECT AF.OPNDATE OPNDATE, CF.FULLNAME FULLNAME,
                        CF.DATEOFBIRTH DATEOFBIRTH,CF.IDCODE IDCODE,
                   CF.ADDRESS ADDRESS,CF.IDPLACE IDPLACE,CF.IDDATE IDDATE,
                   CF.CUSTID CUSTID, AF.ACCTNO ACCTNO,
                   AF.ACTYPE ACTYPE,CF.BRID BRID,CF.CAREBY CAREBY,
                   CF.CUSTTYPE CUSTTYPE,CF.CUSTODYCD CUSTODYCD,
                   CTRY.CDCONTENT COUNTRY,ATYPE.CDCONTENT AFTYPE , TO_CHAR(tl.busdate,'DD/MM/YYYY') REFNAME
                   FROM (SELECT * FROM CFMAST WHERE FNC_VALIDATE_SCOPE(BRID, CAREBY, TLSCOPE, pv_BRID, TLGOUPS)=0) CF, AFMAST AF, ALLCODE CTRY,ALLCODE ATYPE,
                        (
                            select msgacct, busdate
                            from tllog where tltxcd = '0088'
                                and txdate >= TO_DATE (F_DATE, 'DD/MM/YYYY')
                                and txdate <= TO_DATE (T_DATE, 'DD/MM/YYYY')
                            union all
                            select msgacct, busdate from tllogall where tltxcd = '0088'
                                and txdate >= TO_DATE (F_DATE, 'DD/MM/YYYY')
                                and txdate <= TO_DATE (T_DATE, 'DD/MM/YYYY')
                        ) tl
                   WHERE    AF.CUSTID = CF.CUSTID
                   AND AF.ACCTNO = TL.MSGACCT
                   AND      ATYPE.CDTYPE='CF'
                   AND      ATYPE.CDNAME='AFTYPE'
                   AND      AF.aftype=ATYPE.CDVAL
                   AND      CTRY.CDTYPE='CF'
                   AND      CTRY.CDNAME='COUNTRY'
                   AND      CF.COUNTRY=CTRY.CDVAL
                   AND      AF.status IN ('C','N')
                   AND      CF.Custodycd   LIKE  V_STRREFNAME
                   AND      AF.ACTYPE      LIKE  V_ACTYPE
                   AND      CF.INCOMERANGE LIKE  V_STRINCOMERANGE
                   AND      CF.EDUCATION   LIKE  V_STREDUCATION
                   AND      CF.SECTOR      LIKE  V_STRSECTOR
                   AND      AF.aftype      LIKE  V_STRAFTYPE
                   AND      CF.CAREBY      LIKE  V_STRCAREBY
                   AND      SUBSTR(CF.CUSTID,1,4)  LIKE  V_STRBRID
                   AND      SUBSTR(AF.acctno,1,2) LIKE  SUBSTR(V_STRPLACE,1,2)
                   ORDER BY AF.OPNDATE , AF.CUSTID
                   )
                   ;
--           v_text:='1 ';
--   ELSE
 --           v_text:='2 ';
--      OPEN PV_REFCURSOR
--      FOR
/*          SELECT   OPNDATE, FULLNAME,DATEOFBIRTH,IDCODE,ADDRESS,IDPLACE,CUSTID, ACCTNO,
                   ACTYPE,BRID,CAREBY, CUSTTYPE, CUSTODYCD,IDDATE
                   ,COUNTRY,AFTYPE, nvl(REFNAME,'') REFNAME
            FROM (

                  SELECT   AF.OPNDATE OPNDATE, CF.FULLNAME FULLNAME,
                   CF.DATEOFBIRTH DATEOFBIRTH,CF.IDCODE IDCODE,
                   CF.ADDRESS ADDRESS,CF.IDPLACE IDPLACE,CF.IDDATE IDDATE,
                   CF.CUSTID CUSTID, AF.ACCTNO ACCTNO,
                   AF.ACTYPE ACTYPE,CF.BRID BRID,CF.CAREBY CAREBY,
                   CF.CUSTTYPE CUSTTYPE,CF.CUSTODYCD CUSTODYCD,
                   CTRY.CDCONTENT COUNTRY,ATYPE.CDCONTENT AFTYPE, cf.refname
                   FROM     CFMAST CF, AFMAST AF,
                            ALLCODE CTRY,ALLCODE ATYPE
                   WHERE    AF.CUSTID = CF.CUSTID
                   AND      ATYPE.CDTYPE='CF'
                   AND      ATYPE.CDNAME='AFTYPE'
                   AND      AF.aftype=ATYPE.CDVAL
                   AND      CTRY.CDTYPE='CF'
                   AND      CTRY.CDNAME='COUNTRY'
                   AND      CF.COUNTRY=CTRY.CDVAL
                   AND      AF.status not in ('P','R','E')
                   AND      AF.OPNDATE >= TO_DATE (F_DATE, 'DD/MM/YYYY')
                   AND      AF.OPNDATE <= TO_DATE (T_DATE, 'DD/MM/YYYY')
                   and      nvl(CF.refname,'-') like V_STRREFNAME
                   AND      AF.ACTYPE      LIKE  V_ACTYPE
                   AND      CF.INCOMERANGE LIKE  V_STRINCOMERANGE
                   AND      CF.EDUCATION   LIKE  V_STREDUCATION
                   AND      CF.SECTOR      LIKE  V_STRSECTOR
                   AND      AF.aftype      LIKE  V_STRAFTYPE
                   AND      CF.CAREBY      LIKE  V_STRCAREBY
                   AND      SUBSTR(AF.acctno,1,4)  LIKE  V_STRPLACE
                   ORDER BY AF.OPNDATE , AF.CUSTID
                  );
*/
--   END IF;


 EXCEPTION
   WHEN OTHERS
   THEN
    --insert into temp_bug(text) values('CF0001');commit;
      RETURN;
END;                                                              -- PROCEDURE

 
 
 
 
/
