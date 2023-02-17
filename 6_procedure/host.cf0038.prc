SET DEFINE OFF;
CREATE OR REPLACE PROCEDURE cf0038 (
   PV_REFCURSOR   IN OUT   PKG_REPORT.REF_CURSOR,
   OPT            IN       VARCHAR2,
   pv_BRID           IN       VARCHAR2,
   TLGOUPS        IN       VARCHAR2,
   TLSCOPE        IN       VARCHAR2,
   F_DATE         IN       VARCHAR2,
   T_DATE         IN       VARCHAR2,
   I_DATE         IN       VARCHAR2,
   I_BRID         IN       VARCHAR2,
   PV_CUSTODYCD      IN       VARCHAR2,
   BRANCH            IN       VARCHAR2,
   PV_CUSTATCOM   IN       VARCHAR2
)
IS

-- PURPOSE: DANH SACH KHACH HANG MO TAI KHOAN LUU KY
-- MODIFICATION HISTORY
-- PERSON      DATE    COMMENTS
-- QUYETKD     29/05/20111   DANH SACH KHACH HANG MO TAI KHOAN
--NGOCVTT     02/07/2015   KHACH HANG DONG TREN VSD
-- ---------   ------  -------------------------------------------
   V_STROPTION        VARCHAR2 (10);
   V_STRBRID          VARCHAR2 (10);
   V_STRCUSTODYCD     VARCHAR2 (20);

   v_strcustatcom   varchar2(10);

-- DECLARE PROGRAM VARIABLES AS SHOWN ABOVE
BEGIN


   V_STROPTION := OPT;


   IF (I_BRID <> 'ALL')
   THEN
      V_STRBRID := I_BRID;
   ELSE
      V_STRBRID := '%%';
   END IF;




   IF (PV_CUSTODYCD <> 'ALL')
   THEN
      V_STRCUSTODYCD:= PV_CUSTODYCD;
   ELSE
      V_STRCUSTODYCD := '%%';
   END IF;

   if PV_CUSTATCOM = 'Y' then
      V_strcustatcom := '%';
      else
        V_strcustatcom := 'Y';
        end if;


OPEN PV_REFCURSOR
    FOR

  SELECT PV_BRID PV_BRID, BRANCH bran, to_date(I_DATE,'dd/mm/yyyy') I_DATE , cf.fullname ,A3.CDCONTENT CUSTTYPE,CF.CFCLSDATE,CF.OPNDATE,
     cf.idtype ,case when substr(cf.custodycd,4,1) = 'F' then 'Trading code' else A1.cdcontent end ID_TYPE_NAME,
     case when substr(cf.custodycd,4,1) = 'F' then cf.tradingcode else to_char(cf.idcode) end idcode,
     case when substr(cf.custodycd,4,1) = 'F' then cf.tradingcodedt else cf.iddate end iddate,
     cf.idplace,'' Loai_Hinh_CD, cf.country , A2.cdcontent Country_NAME,cf.address,
     nvl(decode(phone,'',mobile,phone),'') phone ,nvl(email,'') Email,cf.custodycd, to_date(T_DATE,'dd/mm/yyyy') todate
from (SELECT * FROM CFMAST WHERE FNC_VALIDATE_SCOPE(BRID, CAREBY, TLSCOPE, pv_BRID, TLGOUPS)=0) CF , ALLCODE A1 ,ALLCODE A2
       , VW_TLLOG_ALL TL, VW_TLLOGFLD_ALL FLD, ALLCODE A3
WHERE A1.cdval =CF.idtype  AND A1.cdname ='IDTYPE' AND  CF.ACTIVESTS='Y'
     AND A2.cdval = CF.country AND A2.cdname ='COUNTRY'
     AND cf.custodycd is not NULL /*AND cf.custatcom = 'Y'*/
     AND A3.CDTYPE='CF' AND A3.CDNAME='CUSTTYPE' AND A3.CDVAL=CF.CUSTTYPE
     --AND cf.status='C'
     AND cf.cfclsdate >= to_date(F_DATE,'dd/mm/yyyy')
     AND cf.cfclsdate <= to_date(T_DATE,'dd/mm/yyyy')
     AND cf.custodycd  like V_STRCUSTODYCD
     AND cf.custatcom like V_strcustatcom
     AND substr(cf.brid ,0,4) like V_STRBRID
     AND TL.MSGACCT=CF.CUSTID
     AND TL.TXDATE=CF.CFCLSDATE
     AND TL.TLTXCD='0059'
     AND TL.TXDATE=FLD.TXDATE
     AND TL.TXNUM=FLD.TXNUM
     AND FLD.FLDCD='08'
     AND FLD.CVALUE<>'N'
 ;
  EXCEPTION
   WHEN OTHERS
   THEN

      RETURN;
END;
 
 
 
 
/
