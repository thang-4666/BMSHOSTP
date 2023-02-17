SET DEFINE OFF;
CREATE OR REPLACE PROCEDURE "CF0081" (
   PV_REFCURSOR     IN OUT   PKG_REPORT.REF_CURSOR,
   OPT              IN       VARCHAR2,
   PV_BRID             IN       VARCHAR2,
   TLGOUPS        IN       VARCHAR2,
   TLSCOPE        IN       VARCHAR2,
   PV_CUSTODYCD     IN       VARCHAR2,
   PV_AFACCTNO      IN       VARCHAR2,
   PV_TXKEY         IN       VARCHAR2
)
IS

    V_BRID              VARCHAR2(4);
    V_STROPTION    VARCHAR2 (5);            -- A: ALL; B: BRANCH; S: SUB-BRANCH
   V_STRBRID      VARCHAR2 (40);            -- USED WHEN V_NUMOPTION > 0
   V_INBRID     VARCHAR2 (5);
    V_IDATE DATE;
    V_CUSTODYCD varchar2(10);
    v_COUNT  number;
        V_STRAFACCTNO VARCHAR2(10);

BEGIN

   V_STROPTION := upper(OPT);
   V_INBRID := PV_BRID;
   v_COUNT :=0;

   if(V_STROPTION = 'A') then
        V_STRBRID := '%';
    else
        if(V_STROPTION = 'B') then
            select br.mapid into V_STRBRID from brgrp br where  br.brid = V_INBRID;
        else
            V_STRBRID := PV_BRID;
        end if;
    end if;

   V_CUSTODYCD := upper(PV_CUSTODYCD);

   IF(UPPER(PV_AFACCTNO) = 'ALL') THEN
        V_STRAFACCTNO := '%';
   ELSE
        V_STRAFACCTNO := PV_AFACCTNO;
   END IF;

OPEN PV_REFCURSOR FOR
    SELECT UPPER(PV_AFACCTNO) STRAFACCTNO, catypename, SYMBOL, DEVIDENTSHARES, devidentrate, rightoffrate, exprice, interestrate, catype, reportdate,
            exrate, max(balance) balance, max(qtty) qtty, max(amt) amt, max(trade) trade,max(pbalance) pbalance,
            max(rqtty) rqtty, tradeplace
        FROM CF0081_LOG
        WHERE CUSTODYCD like V_CUSTODYCD
            AND afacctno LIKE V_STRAFACCTNO
            AND TO_CHAR(TXDATE,'DDMMRRRR') || TXNUM = PV_TXKEY
        GROUP BY  catypename, SYMBOL, DEVIDENTSHARES, devidentrate, rightoffrate, exprice, interestrate, catype, reportdate, exrate, tradeplace
       ORDER BY SYMBOL;

EXCEPTION
   WHEN OTHERS
   THEN
      RETURN;
END;

 
 
 
 
/
