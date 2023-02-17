SET DEFINE OFF;
CREATE OR REPLACE PROCEDURE "CF0037" (
   PV_REFCURSOR   IN OUT   PKG_REPORT.REF_CURSOR,
   OPT            IN       VARCHAR2,
   pv_BRID           IN       VARCHAR2,
   TLGOUPS        IN       VARCHAR2,
   TLSCOPE        IN       VARCHAR2,
   F_DATE         IN       VARCHAR2,
   T_DATE         IN       VARCHAR2,
   I_DATE         IN       VARCHAR2,
   I_BRID         IN       VARCHAR2,
   PV_CUSTODYCD      IN       VARCHAR2
)
IS

-- PURPOSE: DANH SACH KHACH HANG MO TAI KHOAN LUU KY
-- MODIFICATION HISTORY
-- PERSON      DATE    COMMENTS
-- QUYETKD     29/05/20111   DANH SACH KHACH HANG MO TAI KHOAN
-- ---------   ------  -------------------------------------------
   V_STROPTION        VARCHAR2 (10);
   V_STRBRID          VARCHAR2 (10);
   V_STRCUSTODYCD     VARCHAR2 (20);

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

OPEN PV_REFCURSOR
    FOR
    SELECT to_date(I_DATE,'dd/mm/yyyy') I_DATE , cf.fullname , cf.idtype ,
        case when substr(cf.custodycd,4,1) = 'F' then 'Trading Code' else A1.cdcontent end ID_TYPE_NAME,
        case when substr(cf.custodycd,4,1) = 'F' then cf.tradingcode else to_char(cf.idcode) end idcode,
        case when substr(cf.custodycd,4,1) = 'F' then cf.tradingcodedt else cf.iddate end iddate,
        cf.idplace, '' Loai_Hinh_CD, cf.country, A2.cdval Country_NAME, cf.address,
        nvl(decode(phone,'',mobile,phone),'') phone , nvl(email,'') Email, cf.custodycd
    from (SELECT * FROM CFMAST WHERE FNC_VALIDATE_SCOPE(BRID, CAREBY, TLSCOPE, pv_BRID, TLGOUPS)=0) CF , ALLCODE A1 ,ALLCODE A2
    WHERE A1.cdval =CF.idtype
        AND A1.cdname ='IDTYPE'
        AND A2.cdval = CF.country
        AND A2.cdname ='COUNTRY'
        AND cf.custodycd is not null
        AND CF.STATUS ='A'
        AND CF.OPNDATE BETWEEN to_date(F_Date,'dd/mm/yyyy') and to_date(T_Date,'dd/mm/yyyy')
        AND cf.custodycd  like V_STRCUSTODYCD
        AND substr(cf.Custid ,0,4) like V_STRBRID
 ;

 EXCEPTION
   WHEN OTHERS
   THEN

      RETURN;
END;

 
 
 
 
/
