SET DEFINE OFF;
CREATE OR REPLACE PROCEDURE ca0045 (
   PV_REFCURSOR   IN OUT   PKG_REPORT.REF_CURSOR,
   OPT            IN       VARCHAR2,
   pv_BRID           IN       VARCHAR2,
   --TLGOUPS        IN       VARCHAR2,
   --TLSCOPE        IN       VARCHAR2,
   PV_CUSTODYCD   IN       VARCHAR2,
   PV_AFACCTNO    IN       VARCHAR2
 )
IS
--BAO CAO QUYEN PHUC VU GUI EMAIL DINH KEM MAU 0217
-- ---------   ------  -------------------------------------------
   V_STROPTION         VARCHAR2(5);
   V_STRBRID           VARCHAR2(40);
   V_INBRID            VARCHAR2(4);


BEGIN
   V_STROPTION := upper(OPT);
   V_INBRID := pv_BRID;

   IF (V_STROPTION = 'A')
   THEN
      V_STRBRID := '%';
   ELSif (V_STROPTION = 'B') then
        select brgrp.mapid into V_STRBRID from brgrp where brgrp.brid = V_INBRID;
   else
        V_STRBRID := V_INBRID;
   END IF;



OPEN PV_REFCURSOR
FOR

      SELECT ISS.FULLNAME ISS_NAME, SB.SYMBOL, SB.PARVALUE, MST.REPORTDATE,
            NVL(MST.EXRATE, 0) PCENT_EXRATE, NVL(MST.RIGHTOFFRATE, 0) PCENT_RIGHTOFFRATE,
            NVL(MST.EXPRICE, 0) EXPRICE,
            to_char(MST.FRDATETRANSFER,'DD/MM/YYYY')FRDATETRANSFER ,
            to_char( MST.TODATETRANSFER,'DD/MM/YYYY') TODATETRANSFER,
            to_char(MST.BEGINDATE,'DD/MM/YYYY') BEGINDATE,
            to_char(MST.DUEDATE,'DD/MM/YYYY') duedate,
            SUBSTR(CF.CUSTODYCD, 4, 1) GR_I,
            (case when CF.CUSTTYPE = 'I' then '1.' else '2.' end) || CF.CUSTTYPE AFTYPE,
            CF.CUSTID, CF.FULLNAME,
            (case when cf.country = '234' then cf.idcode else cf.tradingcode end) IDCODE,
            (case when cf.country = '234' then cf.IDDATE else cf.tradingcodedt end) IDDATE,
            CF.IDPLACE,
            CF.ADDRESS, AL.CDCONTENT COUNTRY_NAME,
            CF.CUSTODYCD,
            sum(CA.trade) TRADE,
            sum(ca.balance + ca.pbalance) balance,
            CF.mobilesms,
            case when cf.custatcom = 'Y' then 'BMSC' else 'Noi khac' end custatcom,
            MST.advdesc,
            pv_BRID inbrid,
            SA.cdcontent TOSYMBOL_TYPE,
            tosb.symbol tosymbol,
            toiss.fullname toiss_name
    FROM
        AFMAST AF,  CFMAST CF, ALLCODE AL, SBSECURITIES SB, ISSUERS ISS, sbsecurities  tosb, issuers toiss,
        CAMAST  MST,(SELECT  * FROM ALLCODE WHERE CDTYPE = 'SA' AND CDNAME = 'SECTYPE' And CDVAL NOT IN ('000','111','222','333','444') )SA,
        caschd ca , tllog tl
    WHERE CA.AFACCTNO    = AF.ACCTNO
    AND tosb.sectype = SA.cdval
    AND   AF.CUSTID      = CF.CUSTID
    AND   CF.COUNTRY     = AL.CDVAL
    AND   AL.CDNAME      = 'COUNTRY'
    AND   nvl(mst.tocodeid,CA.CODEID)  = toSB.CODEID
    and   ca.codeid = sb.codeid
    AND   SB.ISSUERID    = ISS.ISSUERID
    and  tosb.issuerid = toiss.issuerid
    AND   CA.DELTD       <>'Y'
    AND   (CA.BALANCE + CA.PBALANCE) > 0
    AND   CA.CAMASTID   =  MST.CAMASTID
    and   cf.custodycd = PV_CUSTODYCD
    and   ca.camastid like '%'||PV_AFACCTNO
    AND   tl.tltxcd = '3370' AND tl.msgacct = mst.camastid
    AND   MST.CATYPE    =  '014'
    group by ISS.FULLNAME , SB.SYMBOL, SB.PARVALUE, MST.REPORTDATE,
            NVL(MST.EXRATE, 0) , NVL(MST.RIGHTOFFRATE, 0) ,
            NVL(MST.EXPRICE, 0) ,
            to_char(MST.FRDATETRANSFER,'DD/MM/YYYY') ,
            to_char( MST.TODATETRANSFER,'DD/MM/YYYY') ,
            to_char(MST.BEGINDATE,'DD/MM/YYYY') ,
            to_char(MST.DUEDATE,'DD/MM/YYYY') ,
            SUBSTR(CF.CUSTODYCD, 4, 1) ,
            (case when CF.CUSTTYPE = 'I' then '1.' else '2.' end) || CF.CUSTTYPE ,
            CF.CUSTID, CF.FULLNAME,
            (case when cf.country = '234' then cf.idcode else cf.tradingcode end) ,
            (case when cf.country = '234' then cf.IDDATE else cf.tradingcodedt end) ,
            CF.IDPLACE, CF.ADDRESS, AL.CDCONTENT ,
            CF.CUSTODYCD,
            CF.mobilesms,
            case when cf.custatcom = 'Y' then 'BMSC' else 'Noi khac' end ,
            MST.advdesc,SA.cdcontent,
             tosb.symbol ,
            toiss.fullname
;

EXCEPTION
   WHEN OTHERS
   THEN
      RETURN;
END;
 
/
