SET DEFINE OFF;
CREATE OR REPLACE PROCEDURE "OD0049_1" (
   PV_REFCURSOR   IN OUT   PKG_REPORT.REF_CURSOR,
   OPT            IN       VARCHAR2,
   pv_BRID           IN       VARCHAR2,
   TLGOUPS        IN       VARCHAR2,
   TLSCOPE        IN       VARCHAR2,
   F_DATE         IN       VARCHAR2,
   T_DATE         IN       VARCHAR2,
   CUSTODYCD      IN       VARCHAR2,
   PV_AFACCTNO    IN       VARCHAR2,
   PV_SYMBOL      IN       VARCHAR2,
   MAKER          IN       VARCHAR2,
   PV_VIA         IN       VARCHAR2,
   TLID            IN       VARCHAR2
   )
IS

--
-- PURPOSE: BRIEFLY EXPLAIN THE FUNCTIONALITY OF THE PROCEDUREa
-- BAO CAO GIAO DICH CUA KHACH HANG THEO TUNG MOI GIOI DOC LAP
-- MODIFICATION HISTORY
-- PERSON      DATE    COMMENTS
-- DUNGNH   04-sep-09  CREATED
-- QUYETKD  04-JUL-12  MODIFY
-- ElseIf Trim(mv_arrObjFields(v_intIndex).DefaultValue) = "<$TELLERID>" Then
--                                        v_mskData.Text = Me.TellerId
-- ---------   ------  -------------------------------------------
   V_STROPTION      VARCHAR2 (5);            -- A: ALL; B: BRANCH; S: SUB-BRANCH
   V_STRACCTNO      VARCHAR2 (10);

   V_STRREMISER     VARCHAR2 (10);
   V_NUMTRADE       NUMBER (20, 2);
   V_STRCAREBY      VARCHAR2 (4);
   V_STRCAREBYNAME  VARCHAR2 (50);
   V_CUSTODYCD      VARCHAR2 (20);
   V_MAKER  VARCHAR2 (20);
   V_VIA  VARCHAR2 (20);

   v_Symbol varchar2(20);
   V_INBRID        VARCHAR2(4);
   V_STRBRID      VARCHAR2 (50);
   V_STRTLID           VARCHAR2(6);
-- DECLARE PROGRAM VARIABLES AS SHOWN ABOVE
BEGIN
   /*V_STROPTION := OPT;



   IF (V_STROPTION <> 'A') AND (BRID <> 'ALL')
   THEN
      V_STRBRID := BRID;
   ELSE
      V_STRBRID := '%';
   END IF;*/
      V_STRTLID:= TLID;
    V_STROPTION := upper(OPT);
 V_INBRID := pv_BRID;
    if(V_STROPTION = 'A') then
        V_STRBRID := '%%';
    else
        if(V_STROPTION = 'B') then
            select br.BRID into V_STRBRID from brgrp br where  br.brid = V_INBRID;
        else
            V_STRBRID := V_INBRID;
        end if;
    end if;
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

   IF (upper(PV_SYMBOL) <> 'ALL' )
   THEN
      v_Symbol := upper(REPLACE (PV_SYMBOL,' ','_'));
   ELSE
      v_Symbol := '%%';
   END IF;


   IF (MAKER <> 'ALL')
   THEN
      V_MAKER := MAKER;
   ELSE
      V_MAKER := '%';
   END IF;


      IF (PV_VIA <> 'ALL')
   THEN
      V_VIA := PV_VIA;
   ELSE
      V_VIA := '%';
   END IF;


OPEN PV_REFCURSOR
       FOR
SELECT a.txdate busdate,  A.ACCTNO ACCTNO ,A.CUSTODYCD CUSTODYCD ,to_char(A.TXDATE,'DD/MM/RRRR') TXDATE,A.ORDERID,A.contraorderid,A.EXECTYPE, A.PUTTYPE,
    A.SYMBOL,A.MATCHTYPE,A.EXECTYPENAME,A.FULLNAME, A.TXTIME,A.VIA,
     NVL(A.matchprice,0)  MATCHPRICENBS,
     NVL(A.matchqtty,0) matchqttyBS,
    /* NVL(A.quoteprice,0)   quotepriceNBS,
     NVL(A.orderqtty,0) orderqttyNBS,
    (CASE WHEN NVL(cancelqtty,0) <> 0 THEN NVL(A.quoteprice,0) ELSE 0 END) quotepriceCBS,
    NVL(cancelqtty,0) orderqttyCBS,
    quoteprice_adjust quotepriceABS,
    orderqtty_adjust orderqttyABS,*/
    (CASE  WHEN A.EXECTYPE IN('NB','NS','SS','BC')  THEN   NVL(A.quoteprice,0) ELSE 0 END) quotepriceNBS,
    (CASE  WHEN A.EXECTYPE IN('NB','NS','SS','BC')  THEN   NVL(A.orderqtty,0)  ELSE 0 END) orderqttyNBS,

    (CASE  WHEN A.EXECTYPE IN('CB','CS')  THEN   NVL(A.quoteprice,0)  ELSE 0 END) quotepriceCBS,
    (CASE  WHEN A.EXECTYPE IN('CB','CS')  THEN   NVL(A.orderqtty,0)  ELSE 0 END) orderqttyCBS,

     (CASE  WHEN A.EXECTYPE IN('AB','AS')  THEN   NVL(A.quoteprice,0)  ELSE 0 END) quotepriceABS,
     (CASE  WHEN A.EXECTYPE IN('AB','AS')  THEN   NVL(A.orderqtty,0)  ELSE 0 END) orderqttyABS,
    V_CUSTODYCD V_CUSTODYCD ,
    V_STRACCTNO V_STRACCTNO,
    A.clearday,A.MAKER,A.PRICETYPE,A.REFORDERID
FROM
( SELECT  T.ACCTNO ACCTNO ,T.CUSTODYCD CUSTODYCD ,T.TXDATE,T.ORDERID,T.contraorderid,T.EXECTYPE, T.PUTTYPE, T.SYMBOL,
          T.quoteprice , T.orderqtty ,0 matchprice,0 matchqtty,T.MATCHTYPE ,T.EXECTYPENAME,T.FULLNAME, T.VIA, T.TXTIME,
          T.clearday, t.cancelqtty, /*nvl(odab.quoteprice,0) quoteprice_adjust, nvl(odab.orderqtty,0) orderqtty_adjust,*/
          T.MAKER,T.PRICETYPE,T.REFORDERID
         FROM
             (SELECT AF.ACCTNO,CF.CUSTODYCD,OD.TXDATE,OD.ORDERID, OD.contraorderid,
                     OD.EXECTYPE,'' PUTTYPE, SB.SYMBOL ,od.quoteprice , od.orderqtty,
                     A2.CDCONTENT  MATCHTYPE, A3.CDCONTENT EXECTYPENAME, A4.CDCONTENT VIA, OD.TXTIME, CF.FULLNAME,
                    --to_char(getduedate(od.txdate, od.clearcd, '000', od.clearday),'DD/MM/RRRR') clearday,
                     OD.TXDATE clearday,
                     OD.cancelqtty,TLP.TLNAME MAKER,OD.PRICETYPE,OD.REFORDERID,
                     (CASE WHEN OD.EXECTYPE IN ('NB','NS','SS','BC','MS') AND OD.REFORDERID IS NOT NULL THEN 'A' ELSE 'B' END) TYPE_ORDER
               FROM  SBSECURITIES SB, AFMAST AF, (SELECT * FROM CFMAST WHERE FNC_VALIDATE_SCOPE(BRID, CAREBY, TLSCOPE, pv_BRID, TLGOUPS)=0) CF,
                      ALLCODE A2, ALLCODE A3, vw_odmast_all OD, ALLCODE A4,TLPROFILES TLP
               WHERE  OD.CODEID = SB.CODEID
                     AND OD.CIACCTNO = AF.ACCTNO
                   --  AND od.deltd <> 'Y'
                    -- AND OD.EXECTYPE IN ('NB','NS','SS','BC','MS')
                     AND AF.CUSTID = CF.CUSTID
                    -- AND AF.ACTYPE NOT IN ('0000')
                     AND OD.TLID=TLP.TLID(+)
                    -- AND A1.CDNAME = 'PUTTYPE' AND A1.CDVAL = decode(od.puttype,'N','N','E','E','O','O','N') AND A1.CDTYPE = 'OD'
                     AND A2.CDNAME = 'MATCHTYPE' AND A2.CDVAL = OD.MATCHTYPE AND A2.CDTYPE = 'OD'
                     AND A3.CDNAME = 'EXECTYPE' AND A3.CDVAL = (CASE WHEN OD.EXECTYPE IN ('NB','BC','CB','AB') THEN 'NB' ELSE 'NS' END)
                     AND A3.CDTYPE = 'OD'
                      AND A4.CDNAME = 'VIA' AND A4.CDVAL = OD.VIA AND A4.CDTYPE = 'OD'
                     AND CF.CUSTODYCD like V_CUSTODYCD
                     AND AF.ACCTNO LIKE V_STRACCTNO
                     AND sb.symbol like v_Symbol
                     AND NVL(OD.TLID,'0000') LIKE V_MAKER
                     AND OD.TXDATE >= to_date(F_DATE , 'DD/MM/YYYY')
                     AND OD.TXDATE <= to_date(T_DATE , 'DD/MM/YYYY')
                    -- AND AF.careby like V_CAREBY
                     AND OD.VIA like V_VIA
                   --  AND (af.brid LIKE V_STRBRID or instr(V_STRBRID,af.brid) <> 0 )

            ) T WHERE T.TYPE_ORDER<>'A'
            /*LEFT JOIN
                (SELECT * FROM IOD WHERE DELTD <> 'Y'
                    AND TXDATE >= to_date(F_DATE , 'DD/MM/YYYY')
                    AND TXDATE <= to_date(T_DATE , 'DD/MM/YYYY')
                    AND CUSTODYCD like V_CUSTODYCD
                 UNION ALL
                 SELECT * FROM IODHIST  WHERE DELTD <> 'Y'
                    AND TXDATE >= to_date(F_DATE , 'DD/MM/YYYY')
                    AND TXDATE <= to_date(T_DATE , 'DD/MM/YYYY')
                    AND CUSTODYCD like V_CUSTODYCD
                 ) IO
            ON IO.ORGORDERID = T.ORDERID*/
       /*     left join
            ( select * from vw_odmast_all where EXECTYPE IN ('AB','AS')
                AND TXDATE >= to_date(F_DATE , 'DD/MM/YYYY')
                AND TXDATE <= to_date(T_DATE , 'DD/MM/YYYY')
                AND afacctno like V_STRACCTNO
                AND VIA like V_VIA
            ) odab
            on T.orderid = odab.reforderid*/

)A
ORDER BY  busdate, TXTIME,CUSTODYCD,ACCTNO
;



EXCEPTION
   WHEN OTHERS
   THEN
      RETURN;
END;                                                              -- PROCEDURE

 
 
 
 
/
