SET DEFINE OFF;
CREATE OR REPLACE PROCEDURE "CF00085" (
   PV_REFCURSOR   IN OUT   PKG_REPORT.REF_CURSOR,
   OPT            IN       VARCHAR2,
   PV_BRID           IN       VARCHAR2,
   TLGOUPS        IN       VARCHAR2,
   TLSCOPE        IN       VARCHAR2,
   I_DATE         IN       VARCHAR2,
   PV_CUSTODYCD   IN       VARCHAR2,
   PV_AFACCTNO    IN       VARCHAR2,
   PV_AFTYPE      IN       VARCHAR2
 )
IS
--
-- PURPOSE: BRIEFLY EXPLAIN THE FUNCTIONALITY OF THE PROCEDURE
--
-- MODIFICATION HISTORY
-- PERSON      DATE       COMMENTS
-- Diennt      30/09/2011 Create
-- ---------   ------     -------------------------------------------
   V_STROPTION        VARCHAR2 (5);       -- A: ALL; B: BRANCH; S: SUB-BRANCH

   -- DECLARE PROGRAM VARIABLES AS SHOWN ABOVE
   V_STRPV_CUSTODYCD VARCHAR2(20);
   V_STRPV_AFACCTNO VARCHAR2(20);
   V_INBRID        VARCHAR2(4);
   V_STRBRID      VARCHAR2 (50);
   V_STRTLID           VARCHAR2(6);
   V_BALANCE        number;
   V_BALDEFOVD      number;
   V_IN_DATE        date;
   V_CURRDATE       date;
   V_STRAFTYPE      VARCHAR2(100);
BEGIN
/*
   V_STROPTION := OPT;

   IF (V_STROPTION <> 'A') AND (BRID <> 'ALL')
   THEN
      V_STRBRID := BRID;
   ELSE
      V_STRBRID := '%%';
   END IF;*/

--   V_STRTLID:=TLID;
   /*IF(TLID <> 'ALL' AND TLID IS NOT NULL)
   THEN
        V_STRTLID := TLID;
   ELSE
        V_STRTLID := 'ZZZZZZZZZ';
   END IF;
*/
    V_STROPTION := upper(OPT);
    V_INBRID := PV_BRID;
    if(V_STROPTION = 'A') then
        V_STRBRID := '%%';
    else
        if(V_STROPTION = 'B') then
            select br.brid into V_STRBRID from brgrp br where  br.brid = V_INBRID;
        else
            V_STRBRID := V_INBRID;
        end if;
    end if;


    V_STRPV_CUSTODYCD  := upper(PV_CUSTODYCD);
   IF(PV_AFACCTNO <> 'ALL' AND PV_AFACCTNO IS NOT NULL)
   THEN
        V_STRPV_AFACCTNO := PV_AFACCTNO;
   ELSE
        V_STRPV_AFACCTNO := '%';
   END IF;
    V_IN_DATE       := to_date(I_DATE,'dd/mm/rrrr');
    select to_date(varvalue,'dd/mm/rrrr') into V_CURRDATE from sysvar where varname = 'CURRDATE';

      IF (PV_AFTYPE <> 'ALL' OR PV_AFTYPE <> '')
   THEN
      V_STRAFTYPE :=  PV_AFTYPE;
   ELSE
      V_STRAFTYPE := '%%';
   END IF;


OPEN PV_REFCURSOR
  FOR
    SELECT ca.acctno, ca.custodycd, ca.fullname, ca.mobile, ca.idcode,
        ca.trade SLCKSH,
        TYLE,CATYPE,  STATUS, Ca.CAMASTID, CA.AMT
        ,SYMBOL, TOSYMBOL, TOCODEID, REPORTDATE, SLCKCV, STCV, to_char(ACTIONDATE,'DD/MM/RRRR') ACTIONDATE, ca.CODEID, CASTATUS, CA.exprice, CA.duedate
    FROM
    (SELECT AF.ACCTNO, CF.CUSTODYCD, CF.FULLNAME, CF.MOBILE, CF.IDCODE, CAS.BALANCE ,
                (DECODE(CAM.CATYPE, '001',DEVIDENTRATE,
                                    '010',(case when devidentvalue = 0 and DEVIDENTRATE <> '0' then DEVIDENTRATE || '%' else to_char(devidentvalue) end),
                                    '002',DEVIDENTSHARES,
                                    '011',DEVIDENTSHARES,
                                    '003',RIGHTOFFRATE,
                                    '014',RIGHTOFFRATE,
                                    '004',SPLITRATE,
                                    '012',SPLITRATE,
                                    '006',DEVIDENTSHARES,
                                    '005',devidentshares,
                                    '022',DEVIDENTSHARES,
                                    '021',EXRATE,
                                    '023',EXRATE,
                                    '007',INTERESTRATE,
                                    '008',EXRATE,
                                    '017',EXRATE,
                                    '015',interestrate || '%',
                                    '016',interestrate || '%',
                                    '020',devidentshares
                                    )
                    ) TYLE,
                A0.CDCONTENT CATYPE,  A1.CDCONTENT STATUS, CAM.CAMASTID, CAS.AMT
                , SE.SYMBOL, CAM.REPORTDATE,  CAS.QTTY SLCKCV,
                -- ROUND((CAS.AMT-CAS.AMT*CAM.EXERATE/100),4)  STCV,
               (CASE WHEN CAM.STATUS = 'K' THEN  ROUND((CAS.AMT-CAS.AMT*CAM.EXERATE/100),4)
                --when  CAM.STATUS = 'I' THEN  ROUND((CAS.AMT-CAS.AMT*CAM.EXERATE/100),4)
                WHEN  CAM.STATUS IN ('J','C','G') THEN 0 ELSE  CAS.AMT END)  STCV,

                CAM.ACTIONDATE,
                SE.CODEID CODEID, NVL(SB2.SYMBOL,se.symbol) TOSYMBOL, NVL(CAM.TOCODEID,CAM.CODEID) TOCODEID,
                CAM.STATUS CASTATUS, cas.trade, cam.catype typeca, CAM.exprice,
                (case when cam.catype = '014' then CAM.duedate else cam.actiondate end) duedate
            FROM CASCHD CAS, SBSECURITIES SE, CAMAST CAM, AFMAST AF,AFTYPE AFT,
             (SELECT * FROM CFMAST WHERE FNC_VALIDATE_SCOPE(BRID, CAREBY, TLSCOPE, pv_BRID, TLGOUPS)=0) CF, ALLCODE A0, ALLCODE A1, SBSECURITIES SB2
            WHERE CAS.CODEID = SE.CODEID
            AND NVL(TOCODEID,CAM.codeid) = SB2.CODEID
            AND CAM.CAMASTID = CAS.CAMASTID
            AND CAS.AFACCTNO = AF.ACCTNO
            AND AF.CUSTID = CF.CUSTID
            AND A0.CDTYPE = 'CA' AND A0.CDNAME = 'CATYPE' AND A0.CDVAL = CAM.CATYPE
            AND A1.CDTYPE = 'CA' AND A1.CDNAME = 'CASTATUS' AND A1.CDVAL = CAS.STATUS
           -- AND CAS.STATUS <> 'C'
            AND CAM.CATYPE NOT IN ('002','019')
            AND AF.ACTYPE=AFT.ACTYPE
            AND AFT.PRODUCTTYPE LIKE V_STRAFTYPE
            AND CAS.AFACCTNO  LIKE V_STRPV_AFACCTNO
            AND cf.custodycd  = V_STRPV_CUSTODYCD
            and cas.deltd <>'Y'
            and cam.deltd <>'Y'
    ) CA
    WHERE  CA.custodycd like V_STRPV_CUSTODYCD
    AND CA.REPORTDATE <= V_IN_DATE
   AND (CA.STCV<>0 or ca.SLCKCV <>0)
    and NVL(CA.ACTIONDATE,V_IN_DATE) >= V_IN_DATE
    ORDER  BY CA.ACCTNO
;

EXCEPTION
   WHEN OTHERS
   THEN

      RETURN;
End;

 
 
 
 
/
