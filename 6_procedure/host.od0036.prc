SET DEFINE OFF;
CREATE OR REPLACE PROCEDURE "OD0036" (
   PV_REFCURSOR   IN OUT   PKG_REPORT.REF_CURSOR,
   OPT            IN       VARCHAR2,
   pv_BRID           IN       VARCHAR2,
   TLGOUPS        IN       VARCHAR2,
   TLSCOPE        IN       VARCHAR2,
   I_DATE         IN       VARCHAR2,
   PV_CUSTODYCD      IN       VARCHAR2,
   KHOP             IN       VARCHAR2
 )
IS

-- ---------   ------  -------------------------------------------
   V_STROPTION        VARCHAR2 (5);       -- A: ALL; B: BRANCH; S: SUB-BRANCH
   V_STRBRID          VARCHAR2 (40);        -- USED WHEN V_NUMOPTION > 0
   V_INBRID           VARCHAR2 (4);

   V_STRCUSTODYCD           VARCHAR2 (20);
   V_STRKHOP                VARCHAR2(30);


BEGIN
   V_STROPTION := upper(OPT);
   V_INBRID := pv_BRID;
   IF (V_STROPTION = 'A') THEN
      V_STRBRID := '%';
   ELSE if (V_STROPTION = 'B') then
            select brgrp.brid into V_STRBRID from brgrp where brgrp.brid = V_INBRID;
        else
            V_STRBRID := V_INBRID;
        end if;
   END IF;
   V_STRCUSTODYCD:=UPPER(PV_CUSTODYCD);
     V_STRKHOP:=UPPER(KHOP);
OPEN PV_REFCURSOR
  FOR

  SELECT CF.CUSTODYCD, CF.FULLNAME, CF.IDCODE,SB.SYMBOL,OD.ORDERID,OD.TXDATE, AB.TXTIME,OD.EXECTYPE,
              OD.PRICETYPE, (CASE WHEN OD.MATCHTYPE='N' THEN 'N' ELSE 'P' END) MATCHTYPE,OD.ORSTATUS, OD.QUOTEPRICE, OD.ORDERQTTY,OD.LIMITPRICE,TL.TLNAME MAKER,
               OD.FEEACR, MR.MRTYPE, AB.ORDERID ORDER_AB, AB.QUOTEPRICE PRICE_AB,
               /*AB.ORDERQTTY*/(CASE WHEN OD.ADJUSTQTTY>0 AND AB.ORDERQTTY=OD.ADJUSTQTTY  THEN OD.ADJUSTQTTY
               ELSE AB.ORDERQTTY-OD.EXECQTTY END) QTTY_AB,AB.PRICETYPE TYPE_AB

       FROM VW_ODMAST_ALL OD, VW_ODMAST_ALL AB,
       (SELECT * FROM CFMAST WHERE FNC_VALIDATE_SCOPE(BRID, CAREBY, TLSCOPE, pv_BRID, TLGOUPS)=0) CF, AFMAST AF,
        SBSECURITIES SB, TLPROFILES TL, AFTYPE AFT, MRTYPE MR,CONFIRMODRSTS CON
       WHERE OD.AFACCTNO=AF.ACCTNO
             AND CF.CUSTID=AF.CUSTID
             AND OD.CODEID=SB.CODEID
             AND OD.EXECTYPE IN ('NB','NS','BC','MS','SS')
             AND AB.REFORDERID=OD.ORDERID
              AND AB.ORDERID=CON.ORDERID(+)
             AND NVL(CON.CONFIRMED,'N')='N'
             AND AB.EXECTYPE IN ('AB','AS')
             AND OD.TLID=TL.TLID(+)
             AND CF.CUSTTYPE='B'
             AND OD.DELTD<>'Y'
             AND AF.ACTYPE=AFT.ACTYPE
             AND AFT.MRTYPE=MR.ACTYPE
             AND CF.CUSTODYCD LIKE V_STRCUSTODYCD
             AND MR.MRTYPE LIKE V_STRKHOP
             AND OD.TXDATE=TO_DATE(I_DATE,'DD/MM/YYYY')

ORDER BY OD.TXTIME
;



EXCEPTION
   WHEN OTHERS
   THEN

      RETURN;
End;

 
 
 
 
/
