SET DEFINE OFF;
CREATE OR REPLACE PROCEDURE "OD0065" (
   PV_REFCURSOR   IN OUT   PKG_REPORT.REF_CURSOR,
   OPT            IN       VARCHAR2,
   pv_BRID           IN       VARCHAR2,
   TLGOUPS        IN       VARCHAR2,
   TLSCOPE        IN       VARCHAR2,
   F_DATE         IN       VARCHAR2,
   T_DATE         IN       VARCHAR2,
   I_BRID         IN       VARCHAR2,
   CUSTODYCD      IN       VARCHAR2,
   PV_AFACCTNO    IN       VARCHAR2,
   TLID            IN       VARCHAR2
   )
IS
--
-- PURPOSE: BRIEFLY EXPLAIN THE FUNCTIONALITY OF THE PROCEDURE
-- BAO CAO GIAO DICH CUA KHACH HANG THEO TUNG MOI GIOI DOC LAP THEO CHI NHANH HOAC TOAN CONG TY
-- MODIFICATION HISTORY
-- PERSON      DATE    COMMENTS
-- QUYETKD   28-04-2011  CREATED
--
-- ---------   ------  -------------------------------------------
   V_STROPTION      VARCHAR2 (5);            -- A: ALL; B: BRANCH; S: SUB-BRANCH
   V_STRINBRID      VARCHAR2 (40);
   V_INBRID         VARCHAR2 (4);

   V_STRBRID        VARCHAR2 (4);            -- USED WHEN V_NUMOPTION > 0
   V_STRACCTNO      VARCHAR2 (10);
   V_STRREMISER     VARCHAR2 (10);
   V_NUMTRADE       NUMBER   (20, 2);
   V_STRCAREBY      VARCHAR2 (4);
   V_STRCAREBYNAME  VARCHAR2 (50);
   V_CUSTODYCD      VARCHAR2 (20);
   V_brname_name  VARCHAR2 (80);
   V_STRTLID           VARCHAR2(6);

-- DECLARE PROGRAM VARIABLES AS SHOWN ABOVE
BEGIN
   V_STRTLID:= TLID;
   V_STROPTION := upper(OPT);
   V_INBRID := pv_BRID;
   if(V_STROPTION = 'A') then
        V_STRINBRID := '%';
    else if (V_STROPTION = 'B') then
            select brgrp.mapid into V_STRINBRID from brgrp where brgrp.brid = V_INBRID;
         else
            V_STRINBRID := pv_BRID;
         end if;
   end if;


   IF (I_BRID <> 'ALL') THEN
      V_STRBRID := I_BRID;
      Select brname into V_brname_name from brgrp  where brid =I_BRID;
   ELSE
      V_STRBRID := '%';
      V_brname_name:='%';
   END IF;
   --

IF (CUSTODYCD <> 'ALL')
   THEN
      V_CUSTODYCD := CUSTODYCD;
   ELSE
      V_CUSTODYCD := '%';
   END IF;

   IF (PV_AFACCTNO <> 'ALL')
   THEN
      V_STRACCTNO := PV_AFACCTNO;
   ELSE
      V_STRACCTNO := '%';
   END IF;


OPEN PV_REFCURSOR
       FOR
SELECT  A.ACCTNO ACCTNO ,
A.CUSTODYCD CUSTODYCD ,A.TXDATE,A.ORDERID,A.contraorderid,A.EXECTYPE, A.SYMBOL,A.MATCHTYPE,A.EXECTYPENAME,
              (CASE  WHEN A.EXECTYPE IN('NB','NS','SS','BC')  THEN   NVL(A.matchprice,0)  END) MATCHPRICENBS,
              (CASE  WHEN A.EXECTYPE IN('NB','NS','SS','BC')  THEN   NVL(A.matchqtty,0) END) matchqttyBS,
              (CASE  WHEN A.EXECTYPE IN('NB','NS','SS','BC')  THEN   NVL(A.quoteprice,0)  END) quotepriceNBS,
              (CASE  WHEN A.EXECTYPE IN('NB','NS','SS','BC')  THEN   NVL(A.orderqtty,0) END) orderqttyNBS,

              (CASE  WHEN A.EXECTYPE IN('CB','CS')  THEN   NVL(A.quoteprice,0)  END) quotepriceCBS,
              (CASE  WHEN A.EXECTYPE IN('CB','CS')  THEN   NVL(A.orderqtty,0) END) orderqttyCBS,

               (CASE  WHEN A.EXECTYPE IN('AB','AS')  THEN   NVL(A.quoteprice,0)  END) quotepriceABS,
               (CASE  WHEN A.EXECTYPE IN('AB','AS')  THEN   NVL(A.orderqtty,0) END) orderqttyABS,
                V_CUSTODYCD V_CUSTODYCD , V_STRACCTNO V_STRACCTNO , V_brname_name V_brname_name



               FROM
( SELECT  T.ACCTNO ACCTNO ,T.CUSTODYCD CUSTODYCD ,T.TXDATE,T.ORDERID,T.contraorderid,T.EXECTYPE,  T.SYMBOL,
          T.quoteprice , T.orderqtty ,io.matchprice,io.matchqtty,T.MATCHTYPE ,T.EXECTYPENAME
         FROM
             (SELECT AF.ACCTNO,CF.CUSTODYCD,OD.TXDATE,OD.ORDERID, OD.contraorderid,
                     OD.EXECTYPE,  SB.SYMBOL ,od.quoteprice , od.orderqtty,
                     A2.CDCONTENT  MATCHTYPE ,A3.CDCONTENT EXECTYPENAME
               FROM
                     (SELECT * FROM ODMAST   WHERE DELTD <> 'Y'
                        UNION ALL
                      SELECT * FROM ODMASTHIST   WHERE DELTD<>'Y') OD,
                      SBSECURITIES SB,
                      AFMAST AF,
                      (SELECT * FROM CFMAST WHERE FNC_VALIDATE_SCOPE(BRID, CAREBY, TLSCOPE, pv_BRID, TLGOUPS)=0) CF,
                      --ALLCODE A1,
                      ALLCODE A2,
                      ALLCODE A3
              WHERE  OD.CODEID = SB.CODEID
                   AND OD.CIACCTNO = AF.ACCTNO
                     AND AF.ACCTNO LIKE V_STRACCTNO
                   AND OD.EXECTYPE IN ('NB','NS','SS','BC')
                   AND AF.CUSTID = CF.CUSTID
                   AND AF.ACTYPE NOT IN ('0000')
                  -- AND A1.CDNAME = 'PUTTYPE' AND A1.CDVAL = OD.PUTTYPE AND A1.CDTYPE = 'OD'
                   AND A2.CDNAME = 'MATCHTYPE' AND A2.CDVAL = OD.MATCHTYPE AND A2.CDTYPE = 'OD'
                   AND A3.CDNAME = 'EXECTYPE' AND A3.CDVAL = OD.EXECTYPE AND A3.CDTYPE = 'OD'
                   AND OD.CIACCTNO IN (SELECT vw.value CIACCTNO FROM vw_custodycd_subaccount vw WHERE vw.filtercd like V_CUSTODYCD)

                   AND af.brid  LIKE  V_STRBRID
                   and (af.brid like V_STRINBRID or INSTR(V_STRINBRID,af.brid) <> 0 )
                   AND OD.TXDATE >= to_date(F_DATE , 'DD/MM/RRRR')
                   AND OD.TXDATE <= to_date(T_DATE , 'DD/MM/RRRR')

            ) T                  ,   (SELECT * FROM IOD WHERE DELTD <> 'Y'
                        UNION ALL
                    SELECT * FROM IODHIST  WHERE DELTD <> 'Y') IO
            WHERE IO.ORGORDERID = T.ORDERID


            UNION ALL

           ( SELECT AF.ACCTNO,CF.CUSTODYCD,OD.TXDATE,OD.ORDERID, OD.contraorderid,OD.EXECTYPE,  SB.SYMBOL ,
               od.quoteprice , od.orderqtty ,NULL matchprice,NULL matchqtty,A2.CDCONTENT MATCHTYPE,A3.CDCONTENT EXECTYPENAME
               FROM
                     (SELECT * FROM ODMAST   WHERE DELTD <> 'Y'
                        UNION ALL
                      SELECT * FROM ODMASTHIST   WHERE DELTD<>'Y') OD,
                      SBSECURITIES SB, AFMAST AF, (SELECT * FROM CFMAST WHERE FNC_VALIDATE_SCOPE(BRID, CAREBY, TLSCOPE, pv_BRID, TLGOUPS)=0) CF,
                      -- ALLCODE A1,
                      ALLCODE A2, ALLCODE A3
              WHERE OD.CODEID = SB.CODEID
                   AND OD.CIACCTNO = AF.ACCTNO
                   AND AF.ACCTNO LIKE V_STRACCTNO
                   AND AF.ACTYPE NOT IN ('0000')
                   AND OD.EXECTYPE IN ('CB','CS','AB','AS')
                   AND AF.CUSTID = CF.CUSTID

                   AND OD.CIACCTNO IN (SELECT vw.value CIACCTNO FROM vw_custodycd_subaccount vw WHERE vw.filtercd like V_CUSTODYCD)
                   AND OD.TXDATE >= to_date(F_DATE , 'DD/MM/RRRR')
                   AND OD.TXDATE <= to_date(T_DATE , 'DD/MM/RRRR')
                   ---AND SUBSTR(CF.CUSTID,1,4)  LIKE  V_STRBRID
                   AND af.brid  LIKE  V_STRBRID
                   and (af.brid like V_STRINBRID or INSTR(V_STRINBRID,af.brid) <> 0 )
                   AND A3.CDNAME = 'EXECTYPE' AND A3.CDVAL = OD.EXECTYPE AND A3.CDTYPE = 'OD'
                   AND A2.CDNAME = 'MATCHTYPE' AND A2.CDVAL = OD.MATCHTYPE AND A2.CDTYPE = 'OD'

                 --  AND A1.CDNAME = 'PUTTYPE' AND A1.CDVAL = OD.PUTTYPE AND A1.CDTYPE = 'OD'
                 )
                   ) A;
EXCEPTION
   WHEN OTHERS
   THEN
      RETURN;
END;
 
 
 
 
/
