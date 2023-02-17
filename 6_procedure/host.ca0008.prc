SET DEFINE OFF;
CREATE OR REPLACE PROCEDURE "CA0008" (
   PV_REFCURSOR   IN OUT   PKG_REPORT.REF_CURSOR,
   OPT            IN       VARCHAR2,
   pv_BRID        IN       VARCHAR2,
   TLGOUPS        IN       VARCHAR2,
   TLSCOPE        IN       VARCHAR2,
   F_DATE         IN       VARCHAR2,
   T_DATE         IN       VARCHAR2,
   CACODE         IN       VARCHAR2,
   PV_CUSTODYCD   IN       VARCHAR2,
   PV_AFACCTNO    IN       VARCHAR2,
   I_BRID         IN       VARCHAR2
   )
IS

--
-- PURPOSE: THONG BAO V/V SO HUU QUYEN MUA CK
-- PERSON      DATE    COMMENTS
-- NGOCVTT 07/05/2015
-- ---------   ------  -------------------------------------------

    CUR             PKG_REPORT.REF_CURSOR;
    V_STROPTION         VARCHAR2 (5);            -- A: ALL; B: BRANCH; S: SUB-BRANCH
    V_STRBRID           VARCHAR2 (40);            -- USED WHEN V_NUMOPTION > 0
    V_INBRID            VARCHAR2 (40);
    V_STRAFACCTNO     VARCHAR2 (20);
    V_STRCUSTODYCD     VARCHAR2 (20);
    V_STRCACODE     VARCHAR2 (20);
    V_BRID          VARCHAR2(100);
BEGIN
   V_STROPTION := UPPER(OPT);
    V_INBRID := pv_BRID;
  -- V_STRBRID := V_INBRID;

    IF (V_STROPTION = 'A') THEN
         V_STRBRID := '%';
    ELSE IF (V_STROPTION = 'B') THEN
            SELECT BRGRP.BRID INTO V_STRBRID FROM BRGRP WHERE BRGRP.BRID = V_INBRID;
        ELSE
            V_STRBRID := V_INBRID;
        END IF;
    END IF;

    IF (PV_AFACCTNO <> 'ALL')
   THEN
      V_STRAFACCTNO := PV_AFACCTNO;
   ELSE
      V_STRAFACCTNO := '%%';
   END IF;

     IF (PV_CUSTODYCD <> 'ALL')
   THEN
      V_STRCUSTODYCD := PV_CUSTODYCD;
   ELSE
      V_STRCUSTODYCD := '%%';
   END IF;


        IF (CACODE <> 'ALL')
   THEN
      V_STRCACODE := CACODE;
   ELSE
      V_STRCACODE := '%%';
   END IF;

    if(upper(I_BRID) = 'ALL' or I_BRID is null) then
        v_BRID := '%%';
    else
        v_BRID := UPPER(I_BRID);
    end if ;

   --GET REPORT'S PARAMETERS

OPEN PV_REFCURSOR FOR

    SELECT ISS.FULLNAME ISS_NAME, SB.SYMBOL, tosb.PARVALUE, MST.REPORTDATE,
            NVL(MST.EXRATE, 0) PCENT_EXRATE, NVL(MST.RIGHTOFFRATE, 0) PCENT_RIGHTOFFRATE,
            NVL(MST.EXPRICE, 0) EXPRICE,TLP.TLFULLNAME,
            (CASE WHEN SB.SECTYPE IN ('003','006','222') THEN 'Tr�phi?u' ELSE 'C? phi?u' END) SYMBOL_TYPE,
            (CASE WHEN TOSB.SECTYPE IN ('003','006','222') THEN 'Tr�phi?u' ELSE 'C? phi?u' END) TOSYMBOL_TYPE,
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
            case when cf.custatcom = 'Y' then 'VCBS' else 'Noi khac' end custatcom,
           -- MST.advdesc,
            FN_GEN_ADVDESC_CA0008(MST.EXRATE,SB.SECTYPE, MST.RIGHTOFFRATE,TOSB.SECTYPE) advdesc,
            pv_BRID inbrid,
            tosb.symbol tosymbol,
            toiss.fullname toiss_name, MST.CAMASTID
    FROM
        AFMAST AF,  (SELECT * FROM CFMAST WHERE FNC_VALIDATE_SCOPE(BRID, CAREBY, TLSCOPE, pv_BRID, TLGOUPS)=0) CF, ALLCODE AL, SBSECURITIES SB, ISSUERS ISS, sbsecurities  tosb, issuers toiss,
        CAMAST  MST,TLPROFILES TLP,
        caschd ca , VW_TLLOG_ALL TL
    WHERE CA.AFACCTNO    = AF.ACCTNO
    AND   AF.CUSTID      = CF.CUSTID
    AND   CF.COUNTRY     = AL.CDVAL
    AND NVL(TL.OFFID,'000')=TLP.TLID(+)
    AND   AL.CDNAME      = 'COUNTRY'
    AND   nvl(mst.tocodeid,CA.CODEID)  = toSB.CODEID
    and   ca.codeid = sb.codeid
    AND   SB.ISSUERID    = ISS.ISSUERID
    and  tosb.issuerid = toiss.issuerid
    AND   CA.DELTD       <>'Y'
    AND   (CA.BALANCE + CA.PBALANCE) > 0
    AND   CA.CAMASTID   =  MST.CAMASTID
    and   cf.custodycd LIKE V_STRCUSTODYCD
    and   ca.camastid like V_STRCACODE
    AND AF.ACCTNO like  V_STRAFACCTNO
    AND MST.REPORTDATE BETWEEN TO_DATE(F_DATE,'DD/MM/YYYY') AND TO_DATE(T_DATE,'DD/MM/YYYY')
    AND (CF.BRID LIKE V_STRBRID OR INSTR(V_STRBRID,CF.BRID) <> 0)
    AND CF.BRID LIKE V_BRID
    AND   tl.tltxcd = '3370' AND tl.msgacct = mst.camastid AND TL.TXSTATUS IN ('1','7')
    AND   MST.CATYPE    =  '014'
  group by ISS.FULLNAME , SB.SYMBOL, tosb.PARVALUE, MST.REPORTDATE,SB.SECTYPE,TOSB.SECTYPE,
            NVL(MST.EXRATE, 0) , NVL(MST.  RIGHTOFFRATE, 0) ,
            NVL(MST.EXPRICE, 0) ,
            to_char(MST.FRDATETRANSFER,'DD/MM/YYYY') ,
            to_char( MST.TODATETRANSFER,'DD/MM/YYYY') ,
            to_char(MST.BEGINDATE,'DD/MM/YYYY') ,
            to_char(MST.DUEDATE,'DD/MM/YYYY') ,TLP.TLFULLNAME,
            SUBSTR(CF.CUSTODYCD, 4, 1) ,MST.EXRATE,SB.SECTYPE, MST.RIGHTOFFRATE,TOSB.SECTYPE,
            (case when CF.CUSTTYPE = 'I' then '1.' else '2.' end) || CF.CUSTTYPE ,
            CF.CUSTID, CF.FULLNAME,
            (case when cf.country = '234' then cf.idcode else cf.tradingcode end) ,
            (case when cf.country = '234' then cf.IDDATE else cf.tradingcodedt end) ,
            CF.IDPLACE, CF.ADDRESS, AL.CDCONTENT ,CF.CUSTODYCD,CF.mobilesms,
            case when cf.custatcom = 'Y' then 'BMSC' else 'Noi khac' end ,
            MST.advdesc,tosb.symbol ,toiss.fullname,MST.CAMASTID
order by MST.REPORTDATE,MST.CAMASTID,cf.custid
 ;

EXCEPTION
   WHEN OTHERS
   THEN
      RETURN;
END;
 
 
 
 
/
