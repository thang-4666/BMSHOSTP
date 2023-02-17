SET DEFINE OFF;
CREATE OR REPLACE PROCEDURE cf0001 (
   PV_REFCURSOR   IN OUT   PKG_REPORT.REF_CURSOR,
   OPT            IN       VARCHAR2,
   PV_BRID           IN       VARCHAR2,
   TLGOUPS        IN       VARCHAR2,
   TLSCOPE        IN       VARCHAR2,
   F_DATE         IN       VARCHAR2,
   T_DATE         IN       VARCHAR2,
   ACTYPE         IN       VARCHAR2,
   AFTYPE         IN       VARCHAR2,
   CAREBY         IN       VARCHAR2,
   PLACE          IN       VARCHAR2,
   CUSTODYCD      IN       VARCHAR2,
   PV_AFTYPE      IN       VARCHAR2,
   PV_STATUSVSD   IN       VARCHAR2  ,
   MAKER            IN       VARCHAR2,
   CHECKER         IN       VARCHAR2,
   PV_CLASS             IN       VARCHAR2,
   PV_CUSTATCOM         IN       VARCHAR2,
   PV_OPENVIA         IN       VARCHAR2,
   STATUS         IN       VARCHAR2
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
   V_STRBRID          VARCHAR2 (60);
   V_INBRID            VARCHAR2(4);            -- USED WHEN V_NUMOPTION > 0
   V_ACTYPE           VARCHAR2 (16);
   V_STRAFTYPE        VARCHAR2 (50);
   V_STRCAREBY        VARCHAR2 (50);
   V_STRPLACE         VARCHAR2 (50);
   V_STRREFNAME       VARCHAR2 (50);
   v_text             varchar2(1000);
   L_STRAFTYPE        varchar2(20);

   V_MAKER           VARCHAR2 (50);
   V_CHECKER          VARCHAR2 (50);
   V_STRCLASS        VARCHAR2 (50);
   V_STRCUSTATCOM    VARCHAR2 (10);
   v_STROPENVIA      varchar2(10);
   v_strcust         varchar2(10);

   v_strstatus    VARCHAR2 (10);

   v_STRSTATUSVSD        VARCHAR2(100);
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

   if PV_OPENVIA = 'A' then
    v_STROPENVIA := '%';
   else
    v_STROPENVIA := PV_OPENVIA;
   end if;
   -- GET REPORT'S PARAMETERS
   IF (ACTYPE <> 'ALL')
   THEN
      V_ACTYPE := ACTYPE;
   ELSE
      V_ACTYPE := '%%';
   END IF;

   IF (CUSTODYCD <> 'ALL')
   THEN
      V_STRREFNAME:= CUSTODYCD;
   ELSE
      V_STRREFNAME := '%%';
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


    IF (PV_AFTYPE IS NULL OR UPPER(PV_AFTYPE) = 'ALL')
   THEN
      L_STRAFTYPE := '%';
   ELSE
      L_STRAFTYPE := PV_AFTYPE;
   END IF;


       IF (MAKER IS NULL OR UPPER(MAKER) = 'ALL')
   THEN
      V_MAKER := '%';
   ELSE
      V_MAKER := MAKER;
   END IF;

       IF (CHECKER IS NULL OR UPPER(CHECKER) = 'ALL')
   THEN
      V_CHECKER := '%';
   ELSE
      V_CHECKER := CHECKER;
   END IF;

          IF (PV_CLASS IS NULL OR UPPER(PV_CLASS) = 'ALL')
   THEN
      V_STRCLASS := '%';
   ELSE
      V_STRCLASS := PV_CLASS;
   END IF;

   IF PV_CUSTATCOM = 'Y' THEN
      V_STRCUSTATCOM := '%';
      v_strcust      := '%';
   ELSE
      V_STRCUSTATCOM := 'Y';
      v_strcust      := systemnums.C_COMPANYCD||'%';
   END IF;

 IF (PV_STATUSVSD IS NULL OR UPPER(PV_STATUSVSD) = 'ALL')
   THEN
      v_STRSTATUSVSD := '%';
   ELSE
      v_STRSTATUSVSD := PV_STATUSVSD;
   END IF;

     IF STATUS is null or upper(STATUS) = 'ALL' THEN
        v_strstatus := '%';
    ELSE
        v_strstatus := upper(STATUS);
    END IF;
    v_strstatus := nvl(v_strstatus,'%');

      OPEN PV_REFCURSOR
       FOR
          SELECT   OPNDATE, FULLNAME,DATEOFBIRTH,IDCODE,ADDRESS,IDPLACE,CUSTID, ACCTNO,
                   ACTYPE,BRID,CAREBY, CUSTTYPE, CUSTODYCD,IDDATE
                   ,COUNTRY,AFTYPE, nvl(REFNAME,'') REFNAME, mnemonic,MAKER,
                   CHECKER,FATCA,TRADETELEPHONE,TRADEONLINE,FEE,MG,status, openvia
            FROM (

                  SELECT   AF.OPNDATE OPNDATE, CF.FULLNAME FULLNAME,
                           CF.DATEOFBIRTH DATEOFBIRTH,CF.IDCODE IDCODE,
                           CF.ADDRESS ADDRESS,CF.IDPLACE IDPLACE,CF.IDDATE IDDATE,
                           CF.CUSTID CUSTID, AF.ACCTNO ACCTNO,
                           AF.ACTYPE ACTYPE,CF.BRID BRID,CF.CAREBY CAREBY,
                           CF.CUSTTYPE CUSTTYPE,CF.CUSTODYCD CUSTODYCD,
                           CTRY.CDCONTENT COUNTRY,ATYPE.CDCONTENT AFTYPE , cf.REFNAME, AL.CDCONTENT mnemonic,
                           NVL(USER_ID.MAKER,'') MAKER, NVL(USER_ID.CHECKER,'') CHECKER
                            ,MAX(CASE WHEN FA.CUSTID IS NULL THEN 'N' ELSE 'Y' END) FATCA
                            , CF.TRADETELEPHONE,CF.TRADEONLINE,NVL(FEE.ACTYPE,'') FEE,NVL(MG.REAUTOID,'')MG,
                            af.status, cf.openvia
                   FROM   (SELECT * FROM CFMAST ) CF, AFMAST AF,
                          ALLCODE CTRY, ALLCODE ATYPE, AFTYPE AFT, ALLCODE AL,FATCA FA,
                          (SELECT MAX(CI.ACTYPE)ACTYPE,CF.CUSTID
                                  FROM CIFEEDEF_EXTLNK CI,AFMAST AF, CFMAST CF WHERE CI.STATUS='A'
                                  AND AF.ACCTNO=CI.AFACCTNO AND CF.CUSTID=AF.CUSTID GROUP BY CF.CUSTID)   FEE,
                          (SELECT MAX(REFAUTOID)REAUTOID,CF.CUSTID
                                  FROM ODPROBRKAF OD,AFMAST AF, CFMAST CF
                                  WHERE  OD.STATUS='A'
                                  AND AF.ACCTNO=OD.AFACCTNO AND CF.CUSTID=AF.CUSTID GROUP BY CF.CUSTID) MG,
                          (   SELECT MA.TO_VALUE, MA.CUSTID, MA.MAKER_DT, MA.MAKER_ID, MA.APPROVE_ID,
                                       NVL(TLP.TLNAME,'') MAKER,NVL(TLP1.TLNAME,'') CHECKER
                               FROM
                               (
                                   SELECT MA.TO_VALUE,MIN(MA.MAKER_ID) MAKER_ID,MIN(MA.APPROVE_ID) APPROVE_ID,
                                           SUBSTR(MA.RECORD_KEY,11,10) CUSTID, MIN(MA.MAKER_DT) MAKER_DT
                                   FROM MAINTAIN_LOG MA
                                   WHERE MA.TABLE_NAME='CFMAST' AND MA.ACTION_FLAG='ADD'
                                         AND MA.CHILD_TABLE_NAME='AFMAST' AND MA.COLUMN_NAME='ACCTNO'
                                         AND NVL(MA.MAKER_ID,'000') LIKE V_MAKER
                                         AND NVL(MA.APPROVE_ID,'000') LIKE V_CHECKER
                                         GROUP BY MA.TO_VALUE,SUBSTR(MA.RECORD_KEY,11,10)
                               ) MA, TLPROFILES TLP, TLPROFILES TLP1
                              WHERE MA.MAKER_ID=TLP.TLID(+)
                               AND MA.APPROVE_ID=TLP1.TLID(+)
                          ) USER_ID-- THEM NGUOI TAO, NGUOI DUYET

                   WHERE            AF.CUSTID = CF.CUSTID
                           AND      CF.CUSTID=FA.CUSTID(+)
                           AND      AF.ACCTNO=USER_ID.TO_VALUE(+)
                           AND      af.custid = user_id.custid (+)
                           AND      CF.CUSTID=FEE.CUSTID(+)
                           AND      CF.CUSTID=MG.CUSTID(+)
                           AND      ATYPE.CDTYPE='CF' AND      ATYPE.CDNAME='CUSTTYPE'  AND      CF.custtype = ATYPE.CDVAL
                           AND      CTRY.CDTYPE='CF' AND      CTRY.CDNAME='COUNTRY' AND      CF.COUNTRY=CTRY.CDVAL
                           AND      AF.status not in ('P','R','E')


                           AND      nvl(AF.OPNDATE,TO_DATE('01/01/2010','dd/MM/yyyy')) >= TO_DATE (F_DATE, 'DD/MM/YYYY')
                           AND      nvl(AF.OPNDATE,TO_DATE('01/01/2010','dd/MM/yyyy')) <= TO_DATE (T_DATE, 'DD/MM/YYYY')
                           AND      nvl(AF.clsdate,CASE WHEN AF.status='C' THEN  TO_DATE('01/01/2000','dd/MM/yyyy') ELSE TO_DATE('01/01/9000','dd/MM/yyyy') END)>TO_DATE (T_DATE, 'DD/MM/YYYY')
                            AND      nvl(CF.CFclsdate, CASE WHEN cf.status='C' THEN  TO_DATE('01/01/2000','dd/MM/yyyy') ELSE TO_DATE('01/01/9000','dd/MM/yyyy') END)>TO_DATE (T_DATE, 'DD/MM/YYYY')
                           AND      (CASE WHEN CF.CLASS='000' THEN 'Y' ELSE 'N' END) LIKE V_STRCLASS
                           AND      NVL(USER_ID.MAKER_ID,'000') LIKE V_MAKER
                           AND      NVL(USER_ID.APPROVE_ID,'000') LIKE V_CHECKER
                           AND      AF.ACTYPE=AFT.ACTYPE
                           AND      AL.CDTYPE='CF' AND      AL.CDVAL=AFT.PRODUCTTYPE AND      AL.CDNAME='PRODUCTTYPE'


                           and      cf.custodycd   LIKE   v_strcust

                           AND      CF.ACTIVESTS LIKE v_STRSTATUSVSD  --check vs bao cao CF0009 issiu 215
                           AND      CF.STATUS LIKE v_strstatus  --check vs bao cao CF0009 isssiu 215


                           and cf.openvia like v_STROPENVIA
                           AND      CF.CAREBY      LIKE  V_STRCAREBY
                           AND      AF.ACTYPE      LIKE  V_ACTYPE
                           AND      CF.custtype      LIKE  V_STRAFTYPE
                           AND      CF.BRID  LIKE  V_STRPLACE
                           AND      CF.Custodycd   LIKE  V_STRREFNAME
                           AND      AFT.PRODUCTTYPE LIKE L_STRAFTYPE

                           GROUP BY  AF.OPNDATE , CF.FULLNAME ,CF.DATEOFBIRTH ,CF.IDCODE , CF.ADDRESS ,CF.IDPLACE ,CF.IDDATE ,
                           CF.CUSTID , AF.ACCTNO ,AF.ACTYPE ,CF.BRID ,CF.CAREBY ,CF.CUSTTYPE ,CF.CUSTODYCD ,
                           CTRY.CDCONTENT ,ATYPE.CDCONTENT  , cf.REFNAME, AL.CDCONTENT ,NVL(FEE.ACTYPE,''),NVL(MG.REAUTOID,''),
                           NVL(USER_ID.MAKER,'') , NVL(USER_ID.CHECKER,'') , CF.TRADETELEPHONE,CF.TRADEONLINE,af.status, cf.openvia
                           ORDER BY AF.OPNDATE , cf.CUSTODYCD
                           );
 EXCEPTION
   WHEN OTHERS
   THEN
    plog.error('CF0001: '||SQLERRM || dbms_utility.format_error_backtrace);
      RETURN;
END;                                                              -- PROCEDURE
 
/
