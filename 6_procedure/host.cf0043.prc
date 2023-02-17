SET DEFINE OFF;
CREATE OR REPLACE PROCEDURE "CF0043"
   (
   PV_REFCURSOR   IN OUT   PKG_REPORT.REF_CURSOR,
   OPT            IN       VARCHAR2,
   pv_BRID           IN       VARCHAR2,
   TLGOUPS        IN       VARCHAR2,
   TLSCOPE        IN       VARCHAR2,
   F_DATE         IN       VARCHAR2,
   T_DATE         IN       VARCHAR2,
   PV_CUSTODYCD    IN    VARCHAR2,
   TRADINGCODE     IN VARCHAR2,
   MAKER      IN       VARCHAR2,
   CHECKER     IN       VARCHAR2,
   I_BRIDGD       IN       VARCHAR2,
   PV_TXSTATUS    IN       VARCHAR2
   ) IS


   V_STROPT         VARCHAR2(5);
   V_STRBRID        VARCHAR2(100);
   V_INBRID         VARCHAR2(5);
   V_STRCUSTODYCD  VARCHAR2(100);


   V_F_DATE         date;
   V_T_DATE         date;



   V_STRMAKER       VARCHAR2(20);
   V_STRCHECKER     VARCHAR2(20);
   V_STRTRADINGCODE  VARCHAR2(20);


   V_I_BRIDGD          VARCHAR2(100);
   V_BRNAME            NVARCHAR2(400);
   v_strTXSTATUS        VARCHAR2(100);
BEGIN


/*    V_STROPT := upper(OPT);
    V_INBRID := pv_BRID;
    if(V_STROPT = 'A') then
        V_STRBRID := '%';
    else
        if(V_STROPT = 'B') then
            select br.mapid into V_STRBRID from brgrp br where  br.brid = V_INBRID;
        else
            V_STRBRID := pv_BRID;
        end if;
    end if;*/

      V_STROPT := OPT;

   IF (V_STROPT <> 'A') AND (pv_BRID <> 'ALL')
   THEN
      V_STRBRID := pv_BRID;
   ELSE
      V_STRBRID := '%%';
   END IF;


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


 if(upper(PV_CUSTODYCD) = 'ALL' OR LENGTH(PV_CUSTODYCD) < 1 )then
        V_STRCUSTODYCD := '%';
    else
        V_STRCUSTODYCD := UPPER(PV_CUSTODYCD);
    end if;

     if(upper(TRADINGCODE) <> 'ALL' OR  TRADINGCODE <> '' OR TRADINGCODE <> NULL)then

     V_STRTRADINGCODE := UPPER(TRADINGCODE);
    else
         V_STRTRADINGCODE := '%';
    end if;


    v_F_date := to_date(F_DATE,'dd/mm/rrrr');
    v_T_date := to_date(T_DATE,'dd/mm/rrrr');

    if(upper(MAKER) = 'ALL' OR LENGTH(MAKER) < 1 )then
        V_STRMAKER := '%';
    else
        V_STRMAKER := UPPER(MAKER);
    end if;

    if(upper(CHECKER) = 'ALL' OR LENGTH(CHECKER) < 1 )then
        V_STRCHECKER := '%';
    else
        V_STRCHECKER := UPPER(CHECKER);
    end if;


    if(upper(PV_TXSTATUS) = 'ALL' OR LENGTH(PV_TXSTATUS) < 1 )then
        v_strTXSTATUS := '%';
    else
        v_strTXSTATUS := UPPER(PV_TXSTATUS);
    end if;

     ---GET REPORT DATA:

OPEN PV_REFCURSOR
FOR

SELECT CF.CUSTODYCD,BR.BRNAME, CF.FULLNAME, NVL(CF.TRADINGCODE,'') TRADINGCODE, CF.BRID, TL.MSGAMT,
        TL.MSGACCT, TL.TXDATE, TL1.TLNAME MAKER, TL2.TLNAME APP, TL.TXTIME, AL.CDCONTENT TXSTATUS
FROM (SELECT * FROM CFMAST WHERE FNC_VALIDATE_SCOPE(BRID, CAREBY, TLSCOPE, pv_BRID, TLGOUPS)=0) CF, AFMAST AF, VW_TLLOG_FULL TL, TLPROFILES TL1, TLPROFILES TL2,brgrp br,
ALLCODE AL
WHERE CF.CUSTID=AF.CUSTID
      AND CF.BRID=BR.BRID
      AND AF.ACCTNO=TL.MSGACCT
      AND TL.TLTXCD='1187'
      AND DELTD='N'
     -- AND TL.TXSTATUS IN ('1','7')
      AND TL.txstatus = AL.cdval
      AND AL.cdname ='TXSTATUS'
      AND AL.cdtype ='SY'
      AND TL.TLID=TL1.TLID(+)
      AND TL.OFFID=TL2.TLID(+)
      AND TL.TLID LIKE V_STRMAKER
      AND TL.OFFID LIKE V_STRCHECKER
      AND TL.TXDATE <= v_T_date
      AND TL.TXDATE >= v_F_date
      AND NVL(CF.TRADINGCODE,'a') LIKE V_STRTRADINGCODE
      AND CF.CUSTODYCD LIKE V_STRCUSTODYCD
      AND TL.TXSTATUS  LIKE v_strTXSTATUS
     AND CF.BRID LIKE V_I_BRIDGD

ORDER BY CF.CUSTID, TL.TXDATE
         ;


EXCEPTION
    WHEN OTHERS THEN
        RETURN ;
END; -- Procedure

 
 
 
 
/
