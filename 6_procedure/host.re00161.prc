SET DEFINE OFF;
CREATE OR REPLACE PROCEDURE RE00161 (
   PV_REFCURSOR   IN OUT   PKG_REPORT.REF_CURSOR,
   OPT            IN       VARCHAR2,
   PV_BRID           IN       VARCHAR2,
   TLGOUPS        IN       VARCHAR2,
   TLSCOPE        IN       VARCHAR2,
   F_DATE         IN       VARCHAR2,
   T_DATE         IN       VARCHAR2,
   PV_CUSTODYCD   IN       VARCHAR2
 )
IS
--
-- MODIFICATION HISTORY
-- PERSON      DATE       COMMENTS
-- Ngoc.vu      10/08/2016 Create
-- ---------   ------     -------------------------------------------
    V_STROPTION        VARCHAR2 (5);       -- A: ALL; B: BRANCH; S: SUB-BRANCH
   -- DECLARE PROGRAM VARIABLES AS SHOWN ABOVE
   V_STRPV_CUSTODYCD  VARCHAR2(20);

   V_INBRID           VARCHAR2(4);
   V_STRBRID        VARCHAR2 (50);
   V_STRTLID        VARCHAR2(6);

   v_fromdate        date;
   v_todate          date;
   V_CURRDATE        date;
   v_date            date;

   V_FULLNAME        VARCHAR2 (500);
   V_CUSTID          VARCHAR2 (20);



BEGIN

   V_STROPTION := OPT;

   IF (V_STROPTION <> 'A') AND (PV_BRID <> 'ALL')
   THEN
      V_STRBRID := PV_BRID;
   ELSE
      V_STRBRID := '%%';
   END IF;

    V_STRPV_CUSTODYCD  := upper(PV_CUSTODYCD);

    v_fromdate       := to_date(F_DATE,'dd/mm/rrrr');
    v_todate       := to_date(T_DATE,'dd/mm/rrrr');
    select to_date(varvalue,'dd/mm/rrrr') into V_CURRDATE from sysvar where varname = 'CURRDATE';


      --neu lay ngay hien tai thi CFREVIEWLOG chua co, lay ngay hien tai -1

  select max(TXDATE) into v_date from TBL_MR3007_LOG
                        where TXDATE <= v_todate and CUSTODYCD=V_STRPV_CUSTODYCD;


    OPEN PV_REFCURSOR
      FOR
          SELECT  SB.SYMBOL, CUSTODYCD,SUM(TRADE+ODRECEIVING+ CARECEIVING+WITHDRAW+ MORTAGE_NAV+DTOCLOSE-EXECQTTY) TOTAL,
                  SUM(TRADE)TRADE,SUM(ODRECEIVING)receiving_OD ,SUM(DTOCLOSE) DTOCLOSE,SUM(MORTAGE_NAV) MORTAGE,
                  SUM((TRADE+ODRECEIVING+ CARECEIVING+WITHDRAW+ MORTAGE_NAV+DTOCLOSE-EXECQTTY)*COSTPRICE) AMT,SUM(WITHDRAW) WITHDRAW,
                  SUM(CARECEIVING) receiving_right,MAX(BASICPRICE) BASICPRICE  , MAX(COSTPRICE) COSTPRICE,
                  SUM((TRADE+ODRECEIVING+ CARECEIVING+WITHDRAW+ MORTAGE_NAV+DTOCLOSE-EXECQTTY)*BASICPRICE) marketamt,
                  sum(DECODE(round(COSTPRICE),0,0, ROUND((BASICPRICE- round(COSTPRICE))*100/(round(COSTPRICE)+0.00001),2))) PCPL,
                  round(sum((basicprice - costprice)*(TRADE+ODRECEIVING+ CARECEIVING+WITHDRAW+ MORTAGE_NAV+DTOCLOSE-EXECQTTY))) PC, '' CATYPE

          FROM TBL_MR3007_LOG, SBSECURITIES sb
          WHERE CUSTODYCD=V_STRPV_CUSTODYCD
                AND TXDATE=v_date
                AND SB.CODEID=TBL_MR3007_LOG.CODEID
                AND SB.SECTYPE <>'004'
                GROUP BY CUSTODYCD,SB.SYMBOL
                ORDER BY SYMBOL;

       /* SELECT SYMBOL, MST.CUSTODYCD, round(sum(TOTAL)) TOTAL, round(sum(trade)) trade,round(sum(receiving_OD)) receiving_OD ,
        round(sum(BLOCKED)) BLOCKED,round(sum(MORTAGE)) MORTAGE,
        round(sum(TOTAL*costprice)) amt,round(sum(receiving_right)) receiving_right,
        round(max(basicprice)) basicprice,round(max(COSTPRICE)) costprice, round(sum(TOTAL*basicprice)) marketamt,
        sum(DECODE(round(COSTPRICE),0,0, ROUND((BASICPRICE- round(COSTPRICE))*100/(round(COSTPRICE)+0.00001),2))) PCPL,
        round(sum((basicprice - costprice)*TOTAL)) PC, max(catype)
          FROM (
              SELECT SB.SYMBOL, SDTL.CUSTODYCD ,SDTL.AFACCTNO,
                    sdtl.TOTAL_QTTY-sdtl.SECURED TOTAL,
                    SDTL.TRADE, SDTL.BLOCKED,SDTL.MORTAGE,
                    SDTL.receiving,
                    SDTL.SECURITIES_RECEIVING_T0 + SDTL.SECURITIES_RECEIVING_T1 + SDTL.SECURITIES_RECEIVING_T2 RECEIVING_OD ,
                    SEC.BASICPRICE  , sdtl.COSTPRICE,
                    SDTL.RECEIVING - SDTL.SECURITIES_RECEIVING_T0 - SDTL.SECURITIES_RECEIVING_T1 - SDTL.SECURITIES_RECEIVING_T2 RECEIVING_RIGHT
                    , listagg( CATYPE, '|') within group(order by CATYPE) catype
                FROM BUF_SE_ACCOUNT SDTL, SBSECURITIES SB,
                    SECURITIES_INFO SEC,
                   (select DISTINCT  A.CDCONTENT CATYPE,sb.symbol, CHD.AFACCTNO
                    from camast ca, caschd chd, SBSECURITIES sb, allcode a
                    where ca.camastid=chd.camastid
                          and ca.codeid=sb.codeid
                          and a.cdtype='CA' and a.cdname='CATYPE' AND A.CDVAL=CA.CATYPE) CA
              WHERE  SB.CODEID = SDTL.CODEID
              and SDTL.custodycd= V_STRPV_CUSTODYCD
              AND SDTL.AFACCTNO=CA.AFACCTNO AND INSTR(SB.SYMBOL,CA.SYMBOL)>0
                AND SDTL.CODEID = SEC.CODEID
                and SDTL.TRADE + SDTL.DFTRADING + SDTL.RESTRICTQTTY + SDTL.ABSTANDING + SDTL.BLOCKED + SDTL.receiving+SDTL.SECURITIES_RECEIVING_T0+SDTL.SECURITIES_RECEIVING_T1+SDTL.SECURITIES_RECEIVING_T2>0
              group by SB.SYMBOL, SDTL.CUSTODYCD ,SDTL.AFACCTNO,
                    sdtl.TOTAL_QTTY-sdtl.SECURED ,
                    SDTL.TRADE, SDTL.BLOCKED,SDTL.MORTAGE,
                    SDTL.receiving,
                    SDTL.SECURITIES_RECEIVING_T0 + SDTL.SECURITIES_RECEIVING_T1 + SDTL.SECURITIES_RECEIVING_T2  ,
                    SEC.BASICPRICE  , sdtl.COSTPRICE,
                    SDTL.RECEIVING - SDTL.SECURITIES_RECEIVING_T0 - SDTL.SECURITIES_RECEIVING_T1 - SDTL.SECURITIES_RECEIVING_T2

              ) MST
              group by      SYMBOL, MST.CUSTODYCD
              order by symbol

    ;*/

EXCEPTION
   WHEN OTHERS
   THEN

      RETURN;
End;

 
 
 
 
/
