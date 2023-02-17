SET DEFINE OFF;
CREATE OR REPLACE PROCEDURE "OD0049" (
   PV_REFCURSOR   IN OUT   PKG_REPORT.REF_CURSOR,
   OPT            IN       VARCHAR2,
   pv_BRID           IN       VARCHAR2,
   TLGOUPS        IN       VARCHAR2,
   TLSCOPE        IN       VARCHAR2,
   F_DATE         IN       VARCHAR2,
   T_DATE         IN       VARCHAR2,
   CUSTODYCD      IN       VARCHAR2,
   PV_AFACCTNO    IN       VARCHAR2,
   TLID           IN       VARCHAR2,
   PV_SYMBOL      IN       VARCHAR2
   )
IS
--
-- PURPOSE: BRIEFLY EXPLAIN THE FUNCTIONALITY OF THE PROCEDURE
-- BAO CAO GIAO DICH CUA KHACH HANG THEO TUNG MOI GIOI DOC LAP
-- MODIFICATION HISTORY
-- PERSON      DATE    COMMENTS
-- DUNGNH   04-sep-09  CREATED
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

   v_Symbol varchar2(20);

   v_TLID varchar2(4);
   V_INBRID        VARCHAR2(4);
   V_STRBRID      VARCHAR2 (50);
-- DECLARE PROGRAM VARIABLES AS SHOWN ABOVE
BEGIN
    V_STROPTION := upper(OPT);
    V_INBRID := pv_BRID;
    if(V_STROPTION = 'A') then
        V_STRBRID := '%%';
    else
        if(V_STROPTION = 'B') then
            select br.mapid into V_STRBRID from brgrp br where  br.brid = V_INBRID;
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

   v_TLID := TLID;


OPEN PV_REFCURSOR
       FOR
SELECT A.TXDATE busdate, a.tlname, A.ACCTNO ACCTNO ,A.CUSTODYCD CUSTODYCD ,to_char(A.TXDATE,'DD/MM/RRRR') TXDATE,A.ORDERID,A.contraorderid,A.EXECTYPE, A.PUTTYPE,
    A.SYMBOL,A.MATCHTYPE,A.EXECTYPENAME,
    (CASE  WHEN A.EXECTYPE IN('NB','NS','SS','BC','MS')  THEN   NVL(A.matchprice,0)  END) MATCHPRICENBS,
    (CASE  WHEN A.EXECTYPE IN('NB','NS','SS','BC','MS')  THEN   NVL(A.matchqtty,0) END) matchqttyBS,
    (CASE  WHEN A.EXECTYPE IN('NB','NS','SS','BC','MS')  THEN   NVL(A.quoteprice,0)  END) quotepriceNBS,
    (CASE  WHEN A.EXECTYPE IN('NB','NS','SS','BC','MS')  THEN   NVL(A.orderqtty,0) END) orderqttyNBS,

    (CASE WHEN NVL(cancelqtty,0) <> 0 THEN NVL(A.quoteprice,0) ELSE 0 END) quotepriceCBS,
    NVL(cancelqtty,0) orderqttyCBS,

    quoteprice_adjust quotepriceABS,
    orderqtty_adjust orderqttyABS,
    V_CUSTODYCD V_CUSTODYCD , V_STRACCTNO V_STRACCTNO, A.clearday
FROM
( SELECT t.tlname,  T.ACCTNO ACCTNO ,T.CUSTODYCD CUSTODYCD ,T.TXDATE,T.ORDERID,T.contraorderid,T.EXECTYPE, T.PUTTYPE, T.SYMBOL,
          T.quoteprice , T.orderqtty ,io.matchprice,io.matchqtty,T.MATCHTYPE ,T.EXECTYPENAME,
          T.clearday, t.cancelqtty, nvl(odab.quoteprice,0) quoteprice_adjust, nvl(odab.orderqtty,0) orderqtty_adjust
         FROM
             (SELECT AF.ACCTNO,CF.CUSTODYCD,OD.TXDATE,OD.ORDERID, OD.contraorderid,
                     OD.EXECTYPE, A1.CDCONTENT PUTTYPE, SB.SYMBOL ,od.quoteprice , od.orderqtty,
                     A2.CDCONTENT  MATCHTYPE, A3.CDCONTENT EXECTYPENAME,
                    --to_char(getduedate(od.txdate, od.clearcd, '000', od.clearday),'DD/MM/RRRR') clearday,
                    OD.TXDATE clearday,
                    OD.cancelqtty ,tlp.tlname
               FROM  SBSECURITIES SB, AFMAST AF, (SELECT * FROM CFMAST WHERE FNC_VALIDATE_SCOPE(BRID, CAREBY, TLSCOPE, pv_BRID, TLGOUPS)=0) CF, ALLCODE A1,
                      ALLCODE A2, ALLCODE A3, vw_odmast_all OD,tlprofiles tlp
              WHERE  OD.CODEID = SB.CODEID
                   and od.tlid = tlp.tlid (+)
                   AND OD.CIACCTNO = AF.ACCTNO
                   AND AF.ACCTNO LIKE V_STRACCTNO
                   AND AF.ACTYPE NOT IN ('0000')
                   and sb.symbol like v_Symbol
                   and od.deltd <> 'Y'
                   AND OD.EXECTYPE IN ('NB','NS','SS','BC','MS')
                   AND AF.CUSTID = CF.CUSTID
                   AND A1.CDNAME = 'PUTTYPE' AND A1.CDVAL = decode(od.puttype,'N','N','E','E','O','O','N') /*OD.PUTTYPE*/ AND A1.CDTYPE = 'OD'
                   AND A2.CDNAME = 'MATCHTYPE' AND A2.CDVAL = OD.MATCHTYPE AND A2.CDTYPE = 'OD'
                   AND A3.CDNAME = 'EXECTYPE' AND A3.CDVAL = OD.EXECTYPE AND A3.CDTYPE = 'OD'
                    AND exists (SELECT vw.value CIACCTNO FROM vw_custodycd_subaccount vw
                    WHERE vw.filtercd like V_CUSTODYCD
                        and OD.CIACCTNO = vw.value)
                   AND OD.TXDATE >= to_date(F_DATE , 'DD/MM/YYYY')
                   AND OD.TXDATE <= to_date(T_DATE , 'DD/MM/YYYY')
                   AND (af.brid LIKE V_STRBRID or instr(V_STRBRID,af.brid) <> 0 )

            ) T LEFT JOIN
                (SELECT * FROM IOD WHERE DELTD <> 'Y'
                        UNION ALL
                    SELECT * FROM IODHIST  WHERE DELTD <> 'Y') IO
            ON IO.ORGORDERID = T.ORDERID
            left join
            (select * from vw_odmast_all where EXECTYPE IN ('AB','AS') ) odab
            on T.orderid = odab.reforderid




            /*UNION ALL
           ( SELECT AF.ACCTNO,CF.CUSTODYCD,OD.TXDATE,OD.ORDERID, OD.contraorderid,OD.EXECTYPE, A1.CDCONTENT PUTTYPE, SB.SYMBOL,
               od.quoteprice, od.orderqtty, NULL matchprice, NULL matchqtty,A2.CDCONTENT MATCHTYPE,A3.CDCONTENT EXECTYPENAME,
               to_char(nvl(sts.cleardate,'')) clearday, 0 cancelqtty
               FROM SBSECURITIES SB,
                      AFMAST AF,
                      CFMAST CF,
                      ALLCODE A1,
                      ALLCODE A2,
                      ALLCODE A3,
                      (SELECT * FROM ODMAST   WHERE DELTD <> 'Y'
                        UNION ALL
                      SELECT * FROM ODMASTHIST   WHERE DELTD<>'Y') OD
                      left join vw_stschd_all sts
                on od.orderid = sts.orgorderid AND sts.duetype in ('RM', 'RS')
              WHERE  OD.CODEID = SB.CODEID
                   AND OD.CIACCTNO = AF.ACCTNO
                   AND AF.ACCTNO LIKE V_STRACCTNO
                   AND OD.EXECTYPE IN ('AB','AS')
                   AND AF.CUSTID = CF.CUSTID
                   AND exists (SELECT vw.value CIACCTNO FROM vw_custodycd_subaccount vw
                    WHERE vw.filtercd like V_CUSTODYCD
                        and OD.CIACCTNO = vw.value)
                   AND OD.TXDATE >= to_date(F_DATE , 'DD/MM/YYYY')
                   AND OD.TXDATE <= to_date(T_DATE , 'DD/MM/YYYY')
                   AND A3.CDNAME = 'EXECTYPE' AND A3.CDVAL = OD.EXECTYPE AND A3.CDTYPE = 'OD'
                   AND A2.CDNAME = 'MATCHTYPE' AND A2.CDVAL = OD.MATCHTYPE AND A2.CDTYPE = 'OD'
                   AND A1.CDNAME = 'PUTTYPE' AND A1.CDVAL = OD.PUTTYPE AND A1.CDTYPE = 'OD'
                   and exists (select gu.grpid from tlgrpusers gu where af.careby = gu.grpid and gu.tlid = v_TLID)   -- check careby cf.careby = gu.grpid

        )*/
    ) A;



EXCEPTION
   WHEN OTHERS
   THEN
      RETURN;
END;                                                              -- PROCEDURE

 
 
 
 
/
