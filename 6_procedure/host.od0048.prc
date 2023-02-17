SET DEFINE OFF;
CREATE OR REPLACE PROCEDURE "OD0048" (
   PV_REFCURSOR   IN OUT   PKG_REPORT.REF_CURSOR,
   OPT            IN       VARCHAR2,
   pv_BRID           IN       VARCHAR2,
   TLGOUPS        IN       VARCHAR2,
   TLSCOPE        IN       VARCHAR2,
   F_DATE         IN       VARCHAR2,
   T_DATE         IN       VARCHAR2,
   CUSTODYCD      IN       VARCHAR2,
   PV_AFACCTNO    IN       VARCHAR2,
   TLID IN VARCHAR2
   )
IS
-- MODIFICATION HISTORY
-- BAO CAO GDCK THEO TK KIEM CHI PHI MOI GIOI PS
-- PERSON   DATE  COMMENTS
-- PHUONGNN 22-APR-09  CREATED
-- QuyetKD  26/04/2011 -- bo xung them dk afacctno
-- ---------   ------  -------------------------------------------
   V_CUSTODYCD      VARCHAR2 (20);
   v_CurrDate       DATE;
   CurrDate         VARCHAR2 (20);
   V_AFACCTNO       VARCHAR2(20);
   v_TLID varchar2(4);

   V_STROPTION      VARCHAR2 (5);            -- A: ALL; B: BRANCH; S: SUB-BRANCH
   V_STRBRID        VARCHAR2 (40);            -- USED WHEN V_NUMOPTION > 0
   v_brid               VARCHAR2(4);

BEGIN

    v_TLID := TLID;
    V_STROPTION := OPT;
    v_brid := pv_brid;

    IF  V_STROPTION = 'A' and v_brid = '0001' then
    V_STRBRID := '%';
    elsif V_STROPTION = 'B' then
        select br.mapid into V_STRBRID from brgrp br where br.brid = v_brid;
    else V_STRBRID := v_brid;

    END IF;
/*

BEGIN
    V_STROPTION := OPT;

    v_TLID := TLID;



   IF (V_STROPTION <> 'A') AND (BRID <> 'ALL')
   THEN
      V_STRBRID := BRID;
   ELSE
      V_STRBRID := '%%';
   END IF;
*/


   IF (CUSTODYCD <> 'ALL')
   THEN
      V_CUSTODYCD := CUSTODYCD;
   ELSE
      V_CUSTODYCD := '%';
   END IF;

      IF (PV_AFACCTNO <> 'ALL')
   THEN
      V_AFACCTNO := PV_AFACCTNO;
   ELSE
      V_AFACCTNO := '%';
   END IF;


  -- select c.sbdate into v_CurrDate  from sbcldr c where c.sbbusday = 'Y';
 select varvalue into CurrDate  from sysvar  where varname='CURRDATE';
v_CurrDate := to_date(CurrDate,'DD/MM/RRRR');

 OPEN PV_REFCURSOR
       FOR
          SELECT  T.ACCTNO,T.CUSTODYCD,T.SYMBOL,T.ORDERID,T.contraorderid, T.TXDATE ,T.PUTTYPE, T.EXECTYPE,
          T.fullname,T.idcode,T.iddate,T.idplace,T.address,
              (CASE  WHEN T.EXECTYPE IN('NB','BC')  THEN   NVL(IO.MATCHQTTY,0)  END)MATCHQTTYB,
              (CASE  WHEN T.EXECTYPE IN('NS','SS','MS')  THEN   NVL(IO.MATCHQTTY,0) END)MATCHQTTYS,
              (CASE  WHEN T.EXECTYPE IN('NB','BC')  THEN   NVL(IO.MATCHPRICE,0)  END)MATCHPRICEB,
              (CASE  WHEN T.EXECTYPE IN('NS','SS','MS')  THEN   NVL(IO.MATCHPRICE,0) END)MATCHPRICES,
              NVL(IO.MATCHQTTY,0)* NVL(IO.MATCHPRICE,0) EXECAMT,
              case when t.txdate = v_CurrDate THEN ROUND( io.matchqtty * io.matchprice * t.deffeerate/100,2)
                else ROUND( io.matchqtty * io.matchprice/t.execamt * t.feeacr,2)
             end feeamt_detail,

              case when t.txdate = v_CurrDate  and T.EXECTYPE IN('NS','SS','MS')
                then ROUND ((io.matchqtty * io.matchprice * t.deffeerate/100 )* 100 / (IO.MATCHPRICE*IO.MATCHQTTY),2)
                when  T.EXECTYPE IN('NS','SS','MS') then

                ROUND((io.matchqtty * io.matchprice/t.execamt * t.feeacr)*100/ (IO.MATCHPRICE*IO.MATCHQTTY),2)

                 when t.txdate = v_CurrDate  and T.EXECTYPE IN('NB','BC')
                then ROUND ((io.matchqtty * io.matchprice * t.deffeerate/100 )* 100 / (IO.MATCHPRICE*IO.MATCHQTTY),2)
                when  T.EXECTYPE IN('NB','BC') then

                ROUND((io.matchqtty * io.matchprice/t.execamt * t.feeacr)*100/ (IO.MATCHPRICE*IO.MATCHQTTY),2)
             end fee_bs ,    V_CUSTODYCD V_CUSTODYCD ,  V_AFACCTNO V_AFACCTNO

         FROM
             (SELECT AF.ACCTNO,CF.CUSTODYCD,OD.TXDATE,OD.ORDERID, OD.contraorderid,CF.fullname,cf.idcode,cf.iddate,cf.idplace,cf.address,
                     OD.EXECTYPE, A1.CDCONTENT PUTTYPE, SB.SYMBOL, ODTYPE.DEFFEERATE , OD.feeacr,  od.execamt,

                     (CASE  WHEN OD.PRICETYPE IN ('ATO','ATC')AND OD.EXECTYPE IN('NB','BC')  THEN  OD.PRICETYPE
                           WHEN OD.EXECTYPE IN('NB','BC') THEN to_char( OD.QUOTEPRICE) END )QUOTEPRICEB,

                     (CASE  WHEN OD.PRICETYPE IN ('ATO','ATC')AND OD.EXECTYPE IN('NS','SS','MS')  THEN  OD.PRICETYPE
                           WHEN OD.EXECTYPE IN('NS','SS') THEN to_char( OD.QUOTEPRICE) END )QUOTEPRICES,

                     (CASE  WHEN OD.EXECTYPE IN('NB','BC')  THEN   OD.ORDERQTTY END)ORDERQTTYB,
                     (CASE  WHEN OD.EXECTYPE IN('NS','SS','MS')  THEN   OD.ORDERQTTY END)ORDERQTTYS
                 from
                     (SELECT * FROM ODMAST   WHERE DELTD <> 'Y'
                        UNION ALL
                      SELECT * FROM ODMASTHIST   WHERE DELTD<>'Y') OD,
                      SBSECURITIES SB,
                      AFMAST AF,
                      (SELECT * FROM CFMAST WHERE FNC_VALIDATE_SCOPE(BRID, CAREBY, TLSCOPE, pv_BRID, TLGOUPS)=0) CF,
                      ODTYPE,
                      ALLCODE A1
              WHERE  OD.CODEID = SB.CODEID
                   AND OD.CIACCTNO = AF.ACCTNO
                   AND AF.ACCTNO like V_AFACCTNO
                   AND OD.EXECTYPE IN ('NB','NS','SS','BC','MS')
                   AND AF.CUSTID = CF.CUSTID
                   AND AF.ACTYPE NOT IN ('0000')
                   and af.careby in (select gu.grpid from tlgrpusers gu where gu.tlid = v_TLID )
                   AND ODTYPE.ACTYPE = OD.ACTYPE
                   AND A1.CDNAME = 'PUTTYPE' AND A1.CDVAL = OD.PUTTYPE AND A1.CDTYPE = 'OD'
                   AND OD.TXDATE >= to_date(F_DATE , 'DD/MM/YYYY')
                   AND OD.TXDATE <= to_date(T_DATE , 'DD/MM/YYYY')
                   AND (af.brid like  V_STRBRID or instr(V_STRBRID,af.brid) <> 0)
                   AND OD.CIACCTNO IN (SELECT vw.value CIACCTNO FROM vw_custodycd_subaccount vw WHERE vw.filtercd like V_CUSTODYCD)
            ) T INNER JOIN
                    (SELECT * FROM IOD WHERE DELTD <> 'Y'
                        UNION ALL
                    SELECT * FROM IODHIST  WHERE DELTD <> 'Y') IO
            ON IO.ORGORDERID = T.ORDERID
            ORDER BY T.TXDATE, T.Symbol, T.ACCTNO ;
EXCEPTION
   WHEN OTHERS
   THEN
      RETURN;
END;

 
 
 
 
/
