SET DEFINE OFF;
CREATE OR REPLACE PROCEDURE cfol00 (
   PV_REFCURSOR           IN OUT   PKG_REPORT.REF_CURSOR,
   OPT                    IN       VARCHAR2,
   BRID                   IN       VARCHAR2,
   TLGOUPS                IN       VARCHAR2,
   TLSCOPE                IN       VARCHAR2,
   F_DATE                 IN       VARCHAR2,
   T_DATE                 IN       VARCHAR2,
   PV_CUSTODYCD           IN       VARCHAR2,
   PV_STATUS              IN       VARCHAR2,
   PV_OPN                 IN       VARCHAR2,
   PV_CAREBY              IN       VARCHAR2,
   F_EKYC                 IN       VARCHAR2,
   T_EKYC                 IN       VARCHAR2,
   PV_TLID                IN       VARCHAR2
  )
IS
--
-- PURPOSE: BRIEFLY EXPLAIN THE FUNCTIONALITY OF THE PROCEDURE
--
-- MODIFICATION HISTORY
-- PERSON      DATE       COMMENTS
-- TanPN      30/09/2021 Create
-- ---------   ------     -------------------------------------------
   V_STROPTION        VARCHAR2 (5);       -- A: ALL; B: BRANCH; S: SUB-BRANCH
   V_STRBRID          VARCHAR2 (4);        -- USED WHEN V_NUMOPTION > 0
   V_CUSTODYCD        VARCHAR2 (20);
   V_FRDATE           DATE;
   V_TODATE           DATE;
   V_EKYCMIN          NUMBER;
   V_EKYCMAX          NUMBER;
   V_STATUS           VARCHAR2(10);
   V_OPNSOURCE        VARCHAR2(100);
   V_PCC              VARCHAR2(100);

BEGIN
   V_STROPTION := OPT;

   IF (V_STROPTION <> 'A') AND (BRID <> 'ALL')
   THEN
      V_STRBRID := BRID;
   ELSE
      V_STRBRID := '%%';
   END IF;

   IF (PV_CUSTODYCD <> 'ALL')
   THEN
      V_CUSTODYCD := PV_CUSTODYCD;
   ELSE
      V_CUSTODYCD := '%%';
   END IF;

   IF (pv_status <> 'ALL')
   THEN
      v_status := pv_status;
   ELSE
      v_status := '%%';
   END IF;

   IF (PV_OPN <> 'ALL')
   THEN
      v_opnsource := PV_OPN;
   ELSE
      v_opnsource := '%%';
   END IF;

   IF(PV_CAREBY <> 'ALL')
   THEN
        V_PCC  := PV_CAREBY;
   ELSE
        V_PCC  := '%%';
   END IF;

   V_FRDATE    := TO_DATE(F_DATE,'DD/MM/RRRR');
   V_TODATE    := TO_DATE(T_DATE,'DD/MM/RRRR');
   V_EKYCMIN   := TO_NUMBER(F_EKYC,'999.99');
   V_EKYCMAX   := TO_NUMBER(T_EKYC,'999.99');

OPEN PV_REFCURSOR
  FOR
    SELECT DISTINCT FULLNAME, CF.IDCODE, IDDATE, IDPLACE, CF.CUSTODYCD, CF.OPNDATE, CF.BRID, CF.TLID,
           DECODE(CF.STATUS,'A',PR.TLNAME,'') TLNAME, CF.STATUS, CF.ADDRESS, CF.EMAIL, cf.Filestatus,
           CF.MOBILESMS MOBILE, OPNSOURCE, EKYCAI, DESSTATUS, GR.GRPNAME, RE.REFULLNAME
    FROM
      (SELECT CF.CUSTID, CF.FULLNAME, CF.IDCODE, to_char(CF.IDDATE,'DD/MM/RRRR') IDDATE, CF.IDPLACE, CF.CUSTODYCD, to_char(CF.OPNDATE,'DD/MM/RRRR') OPNDATE,
              BRGRP.BRNAME BRID, CF.TLID, A1.CDCONTENT DESSTATUS, CF.ADDRESS, CF.EMAIL, CF.MOBILESMS,
              A2.CDCONTENT OPNSOURCE, API.EKYCAI, CF.STATUS, CF.CAREBY, RES.Filestatus
         FROM CFMAST CF, REGISTERONLINE RES, APIOPENACCOUNT API, BRGRP, ALLCODE A1, ALLCODE A2
         WHERE CF.OLAUTOID = RES.AUTOID(+) AND CF.IDCODE = API.IDCODE AND CF.BRID = BRGRP.BRID
           AND CF.STATUS = A1.CDVAL AND A1.CDNAME ='STATUS' AND A1.CDTYPE ='CF'
           --AND CF.OPENVIA ='C'
           AND OPNDATE BETWEEN V_FRDATE AND V_TODATE
           AND A2.CDTYPE = 'CF' AND A2.CDNAME = 'OPENVIA' AND A2.CDVAL = CF.OPENVIA
           --AND UPPER(REPLACE(A2.CDCONTENT(+),'-','')) = upper(replace(trim(nvl(api.OPNSOURCE,'BMS-Trade')),'-',''))
       ) CF, TLPROFILES PR, TLGROUPS GR,
       (select DISTINCT re.afacctno, MAX(cf.fullname) refullname, re.reacctno from reaflnk re, sysvar sys, cfmast cf,RETYPE
            where to_date(varvalue,'DD/MM/RRRR') between re.frdate and re.todate and substr(re.reacctno,0,10) = cf.custid
            and varname = 'CURRDATE' and grname = 'SYSTEM' and re.status <> 'C' and re.deltd <>'Y' AND substr(re.reacctno,11) = RETYPE.ACTYPE AND rerole IN ('RM','BM')
            GROUP BY AFACCTNO, reacctno) RE, AFMAST AF
    WHERE AF.CUSTID=CF.CUSTID AND AF.ACCTNO =  RE.afacctno (+)
      AND CF.TLID = PR.TLID AND CF.CAREBY = GR.GRPID
      AND CF.CUSTODYCD LIKE V_CUSTODYCD AND CF.STATUS LIKE v_status
      AND CF.CAREBY LIKE V_PCC
      AND EKYCAI BETWEEN V_EKYCMIN AND V_EKYCMAX
      AND CF.CAREBY IN (SELECT TLGRP.GRPID FROM TLGRPUSERS TLGRP WHERE TLID like PV_TLID);
EXCEPTION
   WHEN OTHERS
   THEN
      RETURN;
End;
 
/
