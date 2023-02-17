SET DEFINE OFF;
CREATE OR REPLACE PROCEDURE "CF0070" (
   PV_REFCURSOR     IN OUT   PKG_REPORT.REF_CURSOR,
   OPT              IN       VARCHAR2,
   pv_BRID             IN       VARCHAR2,
   TLGOUPS        IN       VARCHAR2,
   TLSCOPE        IN       VARCHAR2,
   PV_CUSTODYCD     IN       VARCHAR2,
   PV_AFACCTNO      IN       VARCHAR2
)
IS

    V_BRID          VARCHAR2(4);
    V_STROPTION     VARCHAR2 (5);            -- A: ALL; B: BRANCH; S: SUB-BRANCH
   V_STRBRID        VARCHAR2 (40);            -- USED WHEN V_NUMOPTION > 0
   V_INBRID         VARCHAR2 (5);
    V_IDATE         DATE;
    V_CUSTODYCD     varchar2(10);
    v_COUNT         number;
    V_STRAFACCTNO   varchar2(10);

    V_BALANCE       number(10,0);

BEGIN

   V_STROPTION := upper(OPT);
   V_INBRID := pv_BRID;
   v_COUNT :=0;

   if(V_STROPTION = 'A') then
        V_STRBRID := '%';
    else
        if(V_STROPTION = 'B') then
            select br.mapid into V_STRBRID from brgrp br where  br.brid = V_INBRID;
        else
            V_STRBRID := pv_BRID;
        end if;
    end if;
   SELECT TO_DATE(varvalue,'DD/MM/RRRR') INTO V_IDATE FROM SYSVAR WHERE VARNAME = 'CURRDATE'
    AND GRNAME = 'SYSTEM';

   V_CUSTODYCD := upper(PV_CUSTODYCD);
   IF(UPPER(PV_AFACCTNO) ='ALL' ) THEN
        V_STRAFACCTNO := '%';
   ELSE
        V_STRAFACCTNO := PV_AFACCTNO;
   END IF;

   SELECT SUM(greatest(nvl(adv.avladvance,0) + ci.balance - ci.ovamt - ci.dueamt - ci.dfdebtamt - ci.dfintdebtamt -
    NVL (overamt, 0) - nvl(b.secureamt,0)  - ci.trfbuyamt- ramt-nvl(pd.dealpaidamt,0) - ci.depofeeamt-CI.CIDEPOFEEACR,0)) INTO V_BALANCE
    FROM CFMAST CF, AFMAST AF, cimast ci
    left join (select * from v_getbuyorderinfo where afacctno LIKE V_STRAFACCTNO) b
    on ci.acctno = b.afacctno
    LEFT JOIN (select aamt,depoamt avladvance, advamt advanceamount,afacctno, paidamt
            from v_getAccountAvlAdvance where afacctno LIKE V_STRAFACCTNO) adv
    on adv.afacctno = ci.acctno
    LEFT JOIN(select * from v_getdealpaidbyaccount p where p.afacctno LIKE V_STRAFACCTNO) pd
    on pd.afacctno = ci.acctno
    WHERE CF.custid = AF.custid AND CI.afacctno=AF.acctno AND CF.custodycd  = V_CUSTODYCD
        AND AF.acctno like V_STRAFACCTNO
    ;

   V_BALANCE := NVL(V_BALANCE,0);

OPEN PV_REFCURSOR FOR
        SELECT UPPER(PV_AFACCTNO) AFACCTNO, V_BALANCE CIBALANCE,  MAIN.BRID, V_IDATE TXDATE, main.fullname, main.idcode, main.iddate, main.idplace, main.address,
            MAIN.custodycd, main.wft_symbol SYMBOL, MAIN.tradeplace , MAIN.mobileSMS,
            sum(CASE WHEN instr(symbol,'_WFT') = 0 THEN nvl(trade,0) + NVL(B.BUYQTTY,0)- nvl(b.SELLQTTY,0) ELSE 0 END) trade,
            sum(CASE WHEN instr(symbol,'_WFT') = 0 THEN blocked ELSE 0 END) blocked,
            sum(CASE WHEN instr(symbol,'_WFT') <> 0 THEN nvl(trade,0) + NVL(B.BUYQTTY,0)- nvl(b.SELLQTTY,0) ELSE 0 END) trade_WFT,
            sum(CASE WHEN instr(symbol,'_WFT') <> 0 THEN blocked ELSE 0 END) blocked_WFT
        FROM (
                SELECT BR.BRID, BRNAME,cf.fullname, DECODE(SUBSTR(CF.CUSTODYCD,4,1),'F',CF.TRADINGCODE,CF.IDCODE) idcode,
                    DECODE(SUBSTR(CF.CUSTODYCD,4,1),'F',CF.TRADINGCODEDT,CF.IDDATE) iddate,
                             cf.idplace, cf.address, CF.phone, cf.mobileSMS ,cf.custodycd,
                    nvl(sb.symbol,'') symbol, nvl(sb_wft.symbol,'') wft_symbol,
                         nvl(sb_wft.sectype,'') sectype, nvl(sb_wft.issuerid,'') issuerid ,
                         nvl(se.trade,0) trade, nvl(se.blocked,0) blocked, SE.receiving,
                       CASE WHEN sb.markettype = '001' AND sb.sectype IN ('003','006','222','333','444') THEN utf8nums.c_const_df_marketname
                          WHEN  nvl(sb_wft.tradeplace,'') = '001' THEN 'HOSE'
                          WHEN  nvl(sb_wft.tradeplace,'') = '002' THEN 'HNX'
                          WHEN  nvl(sb_wft.tradeplace,'') = '005' THEN 'UPCOM'  END tradeplace
                  FROM  BRGRP BR, (SELECT * FROM CFMAST WHERE FNC_VALIDATE_SCOPE(BRID, CAREBY, TLSCOPE, pv_BRID, TLGOUPS)=0) cf, afmast af,semast se, sbsecurities sb,
                       sbsecurities sb_wft
                  WHERE af.custid = cf.custid
                  and sb.sectype not in ('111','222','333','444','004')
                  AND BR.BRID = SUBSTR(CF.CUSTID,1,4)
                  AND af.acctno =  se.afacctno (+)
                  AND cf.custodycd = V_CUSTODYCD
                  AND AF.ACCTNO LIKE V_STRAFACCTNO
                  AND se.codeid = sb.codeid (+)
                  AND nvl(sb.refcodeid, sb.codeid) = sb_wft.codeid (+)
              ) main left join
                (
                    SELECT CUSTODYCD,CODEID,SYMBOL SYMBOLL, SUM(CASE WHEN BORS = 'S' THEN QTTY ELSE 0 END) SELLQTTY,
                        SUM(CASE WHEN BORS = 'B' THEN QTTY ELSE 0 END) BUYQTTY
                    FROM IOD WHERE DELTD <> 'Y'
                    GROUP BY CUSTODYCD, CODEID,SYMBOL
                ) b
                on main.custodycd=b.custodycd and main.symbol=b.symboll
            GROUP BY MAIN.BRID, main.fullname, main.idcode, main.iddate, main.idplace, main.address,
            MAIN.custodycd, main.wft_symbol, MAIN.tradeplace, MAIN.mobileSMS
        ;

EXCEPTION
   WHEN OTHERS
   THEN
      RETURN;
END;

 
 
 
 
/
