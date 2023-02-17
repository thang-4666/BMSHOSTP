SET DEFINE OFF;
CREATE OR REPLACE PROCEDURE "CF0031" (
   PV_REFCURSOR   IN OUT   PKG_REPORT.REF_CURSOR,
   OPT            IN       VARCHAR2,
   PV_BRID           IN       VARCHAR2,
   TLGOUPS        IN       VARCHAR2,
   TLSCOPE        IN       VARCHAR2,
   F_DATE         IN       VARCHAR2,
   T_DATE         IN       VARCHAR2,
   I_BRIDGD       IN       VARCHAR2,
   PV_CUSTATCOM   IN       VARCHAR2
 )
IS
--
-- PURPOSE: DSKH DA TAT TOAN TK (BC GUI HOSE)
-- MODIFICATION HISTORY
-- PERSON      DATE      COMMENTS
-- QUOCTA   24-12-2011   CREATED - NOEL
-- ---------   ------  -------------------------------------------

   V_STROPTION         VARCHAR2  (5);
   V_STRBRID           VARCHAR2  (40);

   V_F_DATE            DATE;
   V_T_DATE            DATE;

   V_I_BRIDGD          VARCHAR2(100);
   V_BRNAME            NVARCHAR2(400);
    V_BRID             VARCHAR2(4);
    V_STRCUSTATCOM     VARCHAR2(10);
BEGIN
   V_STROPTION := OPT;
      V_BRID := PV_BRID;


    IF  V_STROPTION = 'A' then
        V_STRBRID := '%';
        ELSIF V_STROPTION = 'B' THEN
            SELECT BR.brid INTO V_STRBRID FROM BRGRP BR WHERE BR.BRID = V_BRID;
        ELSE V_STROPTION := V_BRID;
    END IF;

   -- GET REPORT'S PARAMETERS
   V_F_DATE        := TO_DATE(F_DATE, SYSTEMNUMS.C_DATE_FORMAT);
   V_T_DATE        := TO_DATE(T_DATE, SYSTEMNUMS.C_DATE_FORMAT);

   IF (I_BRIDGD <> 'ALL' OR I_BRIDGD <> '')
   THEN
      V_I_BRIDGD :=  I_BRIDGD;
   ELSE
      V_I_BRIDGD := '%%';
   END IF;

   IF (I_BRIDGD <> 'ALL' OR I_BRIDGD <> '')
   THEN
      BEGIN
            SELECT BRNAME INTO V_BRNAME FROM BRGRP WHERE BRID LIKE I_BRIDGD;
      END;
   ELSE
      V_BRNAME   :=  ' Toàn công ty ';
   END IF;

   IF PV_CUSTATCOM = 'Y' THEN
     V_STRCUSTATCOM := '%';
     ELSE
       V_STRCUSTATCOM := 'Y';
       END IF;

   -- GET REPORT'S DATA

OPEN PV_REFCURSOR
FOR
    SELECT CF.FULLNAME, '005' TVCODE, CF.CUSTODYCD, CF.IDCODE, CF.ADDRESS, CF.IDDATE, CF.IDPLACE,
           (CASE WHEN substr(cf.custodycd,4,1) = 'F' THEN 'NN' ELSE 'TN' END) || '-' ||
    (CASE WHEN CF.CUSTTYPE = 'I' THEN 'CN' WHEN CF.CUSTTYPE = 'B' THEN 'TC' END) CUSTTYPE_NAME,
           CF.OPNDATE, AL.CDCONTENT COUNTRY_NAME, CF.CFCLSDATE, V_BRNAME BRNAME,cf.mobilesms
    FROM  (SELECT * FROM CFMAST WHERE FNC_VALIDATE_SCOPE(BRID, CAREBY, TLSCOPE, pv_BRID, TLGOUPS)=0) CF, ALLCODE AL
          , VW_TLLOG_ALL TL, VW_TLLOGFLD_ALL FLD
    WHERE CF.COUNTRY = AL.CDVAL
    AND   AL.CDNAME  = 'COUNTRY'
    AND   AL.CDTYPE  = 'CF'
    AND   CF.CFCLSDATE >= V_F_DATE AND CF.CFCLSDATE <=  V_T_DATE
    AND   CF.BRID      LIKE V_I_BRIDGD
    --AND   CF.STATUS    = 'C'
    AND TL.MSGACCT=CF.CUSTID AND tl.DELTD <> 'Y'
    AND TL.TXDATE=CF.CFCLSDATE
    AND TL.TLTXCD='0059'
    AND TL.TXDATE=FLD.TXDATE
    AND TL.TXNUM=FLD.TXNUM
    AND FLD.FLDCD='08'
    AND FLD.CVALUE<>'N'
    AND CF.CUSTATCOM LIKE V_STRCUSTATCOM

;

EXCEPTION
   WHEN OTHERS
   THEN
      RETURN;
END;



-- END OF DDL SCRIPT FOR PROCEDURE HOST.CF0031

 
 
 
 
/
