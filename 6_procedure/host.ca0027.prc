SET DEFINE OFF;
CREATE OR REPLACE PROCEDURE "CA0027" (
   PV_REFCURSOR   IN OUT   PKG_REPORT.REF_CURSOR,
   OPT            IN       VARCHAR2,
   pv_BRID           IN       VARCHAR2,
   TLGOUPS        IN       VARCHAR2,
   TLSCOPE        IN       VARCHAR2,
   CACODE         IN       VARCHAR2,
   PLSENT         IN       VARCHAR2
 )
IS
--
-- PURPOSE: BAO CAO DANH SACH NGUOI SO HUU CHUNG KHOAN LUU KY
-- MODIFICATION HISTORY
-- PERSON      DATE      COMMENTS
-- QUOCTA   28-02-2012   CREATED
-- ---------   ------  -------------------------------------------

   V_STROPTION         VARCHAR2  (5);
   V_STRBRID           VARCHAR2  (4);
   V_CACODE            VARCHAR2(100);


BEGIN
   V_STROPTION := OPT;

   IF (V_STROPTION <> 'A') AND (pv_BRID <> 'ALL')
   THEN
      V_STRBRID := pv_BRID;
   ELSE
      V_STRBRID := '%%';
   END IF;

   -- GET REPORT'S PARAMETERS
   IF (CACODE <> 'ALL' OR CACODE <> '')
   THEN
      V_CACODE :=  CACODE;
   ELSE
      V_CACODE := '%';
   END IF;

    -- GET REPORT'S DATA
OPEN PV_REFCURSOR
FOR
     SELECT ISS.FULLNAME ISS_NAME, SB.SYMBOL, SB.PARVALUE, MST.REPORTDATE, PLSENT PLSENT,
       AL.CDCONTENT CA_NAME, MST.CAMASTID, MST.ACTIONDATE, MST.CATYPE, MST.FRDATETRANSFER, MST.TODATETRANSFER,
       (DECODE(MST.CATYPE, '001', DEVIDENTRATE || '%',
                           '002', DEVIDENTSHARES,
                           '003', RIGHTOFFRATE ,
                           '004', SPLITRATE ,
                           '005', DEVIDENTSHARES ,
                           '006', DEVIDENTSHARES ,
                           '007', INTERESTRATE ,
                           '008', EXRATE ,
                           '010', (case when devidentvalue = 0 and DEVIDENTRATE <> '0' then DEVIDENTRATE || '%' else to_char(devidentvalue) || ' d?ng/CP' end),
                           '011', DEVIDENTSHARES ,
                           '012', SPLITRATE ,
                           '014', RIGHTOFFRATE ,
                           '015', INTERESTRATE || '%',
                           '016', INTERESTRATE || '%',
                           '017', EXRATE ,
                           '020', DEVIDENTSHARES ,
                           '021', EXRATE ,
                           '022', DEVIDENTSHARES)) PCENT

FROM   (SELECT * FROM CAMAST UNION ALL SELECT * FROM CAMASTHIST) MST,
       ALLCODE AL, SBSECURITIES SB, ISSUERS ISS
WHERE  MST.CATYPE      =    AL.CDVAL
AND    AL.CDNAME       =    'CATYPE'
AND    AL.CDTYPE       =    'CA'
AND    MST.CODEID      =    SB.CODEID
AND    SB.ISSUERID     =    ISS.ISSUERID
AND    MST.DELTD       <>   'Y'
AND    MST.CAMASTID    LIKE V_CACODE
AND    MST.STATUS      NOT IN ('C', 'N')

;
EXCEPTION
   WHEN OTHERS
   THEN
      RETURN;
END;

 
 
 
 
/
