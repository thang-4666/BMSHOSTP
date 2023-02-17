SET DEFINE OFF;
CREATE OR REPLACE PROCEDURE "CA0001" (
   PV_REFCURSOR   IN OUT   PKG_REPORT.REF_CURSOR,
   OPT            IN       VARCHAR2,
   pv_BRID           IN       VARCHAR2,
   TLGOUPS        IN       VARCHAR2,
   TLSCOPE        IN       VARCHAR2,
   F_DATE           IN       VARCHAR2,
   T_DATE           IN       VARCHAR2,
   PV_CUSTODYCD        IN       VARCHAR2,
   PV_AFACCTNO         IN       VARCHAR2,
   ISCOM             IN       VARCHAR2
      )
IS
--
-- PURPOSE: BRIEFLY EXPLAIN THE FUNCTIONALITY OF THE PROCEDURE
-- BAO CAO TAI KHOAN TIEN TONG HOP CUA NGUOI DAU TU
-- MODIFICATION HISTORY
-- PERSON      DATE    COMMENTS
-- NAMNT   20-DEC-06  CREATED
-- ---------   ------  -------------------------------------------

    CUR             PKG_REPORT.REF_CURSOR;
    V_STROPTION    VARCHAR2 (5);            -- A: ALL; B: BRANCH; S: SUB-BRANCH
    V_STRBRID      VARCHAR2 (4);
    V_STRACCTNO    VARCHAR2 (20);
V_STRCUSTODYCD     VARCHAR2 (20);
V_STRISCOM   VARCHAR2 (40);
BEGIN
   V_STROPTION := OPT;



   IF (V_STROPTION <> 'A') AND (pv_BRID <> 'ALL')
   THEN
      V_STRBRID := pv_BRID;
   ELSE
      V_STRBRID := '%%';
   END IF;

   IF (ISCOM = 'Y')
   THEN
   V_STRISCOM := 'JC';
   ELSIF  (ISCOM = 'N')
   THEN
   V_STRISCOM := 'MAIPNSDRGHVBEW';
   ELSE
   V_STRISCOM := 'MAIPNSCDRGHJVBEW';
   END IF;


   IF (PV_AFACCTNO <> 'ALL')
   THEN
      V_STRACCTNO := PV_AFACCTNO;
   ELSE
      V_STRACCTNO := '%%';
   END IF;



   IF (PV_CUSTODYCD <> 'ALL')
   THEN
      V_STRCUSTODYCD := PV_CUSTODYCD;
   ELSE
      V_STRCUSTODYCD := '%%';
   END IF;

   -- GET REPORT'S PARAMETERS

--TINH NGAY NHAN THANH TOAN BU TRU


OPEN PV_REFCURSOR
   FOR
SELECT ca.acctno, ca.custodycd, ca.fullname, ca.mobile, ca.idcode,
        ca.trade SLCKSH,
    TYLE,CATYPE,  STATUS, Ca.CAMASTID, CA.AMT
            ,SYMBOL, TOSYMBOL, TOCODEID, REPORTDATE, SLCKCV, STCV, ACTIONDATE, ca.CODEID, CASTATUS
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
            , SE.SYMBOL, CAM.REPORTDATE,  CAS.QTTY SLCKCV, CAS.AMT STCV, CAM.ACTIONDATE,
            SE.CODEID CODEID, NVL(SB2.SYMBOL,se.symbol) TOSYMBOL, NVL(CAM.TOCODEID,CAM.CODEID) TOCODEID,
            CAM.STATUS CASTATUS, cas.trade, cam.catype typeca
        FROM CASCHD CAS, SBSECURITIES SE, CAMAST CAM, AFMAST AF, (SELECT * FROM CFMAST WHERE FNC_VALIDATE_SCOPE(BRID, CAREBY, TLSCOPE, pv_BRID, TLGOUPS)=0) CF, ALLCODE A0, ALLCODE A1, SBSECURITIES SB2
        WHERE CAS.CODEID = SE.CODEID
        AND NVL(TOCODEID,CAM.codeid) = SB2.CODEID
        AND CAM.CAMASTID = CAS.CAMASTID
        AND CAS.AFACCTNO = AF.ACCTNO
        AND AF.CUSTID = CF.CUSTID
        AND A0.CDTYPE = 'CA' AND A0.CDNAME = 'CATYPE' AND A0.CDVAL = CAM.CATYPE
        AND A1.CDTYPE = 'CA' AND A1.CDNAME = 'CASTATUS' AND A1.CDVAL = CAS.STATUS
       -- AND CAS.STATUS <> 'C'
        AND CAM.CATYPE NOT IN ('002','019')
        AND CAS.AFACCTNO  LIKE V_STRACCTNO
        AND cf.custodycd  = V_STRCUSTODYCD
        and cas.deltd <>'Y'
        and cam.deltd <>'Y'
) CA
WHERE  CA.custodycd like V_STRCUSTODYCD
AND INSTR(V_STRISCOM, CA.CASTATUS )> 0
AND CA.REPORTDATE >= TO_DATE(F_DATE,'DD/MM/YYYY')
AND CA.REPORTDATE <= TO_DATE(T_DATE,'DD/MM/YYYY')
ORDER  BY CA.ACCTNO


  ;


EXCEPTION
   WHEN OTHERS
   THEN
      RETURN;
END;                                                              -- PROCEDURE

 
 
 
 
/
