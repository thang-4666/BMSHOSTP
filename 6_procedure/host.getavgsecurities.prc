SET DEFINE OFF;
CREATE OR REPLACE PROCEDURE "GETAVGSECURITIES"
   (
     PV_REFCURSOR   IN OUT PKG_REPORT.REF_CURSOR,
     frdate date,
     todate date,
     cldtype char
    )
   IS

    day number(10,0);
BEGIN -- Proc
        if cldtype='B' then
            select sum(case when HOLIDAY ='Y' then 0 else 1 end) into day from sbcldr where SBDATE>=frdate and SBDATE<=todate and CLDRTYPE='000';
        else
            select sum(case when HOLIDAY ='Y' then 1 else 1 end) into day from sbcldr where SBDATE>=frdate and SBDATE<=todate and CLDRTYPE='000';
        end if;

        OPEN PV_REFCURSOR FOR
select * from
(
select TRADEPLACE, symbol, substr(custodycd,1,4) Tai_Khoan, sum(amt) Amt
from (
SELECT sb.TRADEPLACE, SB.symbol, substr(NUM.ACCTNO,1,10) ACCTNO,NUM.AMT , cf.custodycd, af.acctno
FROM AFMAST AF, (select * from CFMAST where cfmast.custodycd like '%C%') CF,
(SELECT * from  SBSECURITIES where tradeplace in ('001','002') ) SB,ALLCODE AL, ISSUERS ISS,
(
SELECT SE.ACCTNO , (SE.TRADE + SE.BLOCKED + se.secured + SE.WITHDRAW + SE.MORTAGE +NVL(SE.netting,0) + NVL(SE.dtoclose,0)   - NVL(NUM.AMT,0)) + NVL(AV.AVGAMT,0)  AMT
 FROM  SEMAST SE
 LEFT JOIN
( SELECT NVL(SUM(AMT ),0) AMT, ACCTNO
  FROM
 ( SELECT   SUM ((CASE WHEN APP.TXTYPE = 'D'THEN -TR.NAMT WHEN
          APP.TXTYPE = 'C' THEN TR.NAMT ELSE 0  END )) AMT, TR.ACCTNO ACCTNO
          FROM APPTX APP, SETRAN TR, TLLOG TL
          WHERE TR.TXCD = APP.TXCD
               AND TL.TXNUM =TR.TXNUM
               AND APP.APPTYPE = 'SE'
               AND APP.TXTYPE IN ('C', 'D')
               AND TL.DELTD <>'Y'
               AND  TR.NAMT<>0
               AND TL.BUSDATE > frdate
               AND APP.FIELD IN   ('TRADE','BLOCKED','WITHDRAW','MORTAGE','SECURED','NETTING','DTOCLOSE')
               GROUP BY  TR.ACCTNO
  UNION ALL
         SELECT   SUM ((CASE WHEN APP.TXTYPE = 'D'THEN -TR.NAMT WHEN
         APP.TXTYPE = 'C' THEN TR.NAMT ELSE 0 END )) AMT, TR.ACCTNO ACCTNO
         FROM APPTX APP, SETRANA TR ,TLLOGALL TL
         WHERE TR.TXCD = APP.TXCD
               AND TL.TXNUM =TR.TXNUM
               AND TL.TXDATE =TR.TXDATE
               AND APP.APPTYPE = 'SE'
               AND APP.TXTYPE IN ('C', 'D')
               AND TL.DELTD <>'Y'
               AND  TR.NAMT<>0
               AND TL.BUSDATE >= frdate
               AND APP.FIELD IN    ('TRADE','BLOCKED','WITHDRAW','MORTAGE','SECURED','NETTING','DTOCLOSE')
               GROUP BY  TR.ACCTNO
                )
               GROUP BY ACCTNO
)NUM
ON NUM.ACCTNO =SE.ACCTNO


left join

(
SELECT round(NVL(SUM(AMT ),0)/day,2) AVGAMT, ACCTNO
  FROM
 ( SELECT   SUM ((CASE WHEN APP.TXTYPE = 'D'THEN -TR.NAMT WHEN
          APP.TXTYPE = 'C' THEN TR.NAMT ELSE 0  END )) AMT, TR.ACCTNO ACCTNO
          FROM APPTX APP, SETRAN TR, TLLOG TL
          WHERE TR.TXCD = APP.TXCD
               AND TL.TXNUM =TR.TXNUM
               AND APP.APPTYPE = 'SE'
               AND APP.TXTYPE IN ('C', 'D')
               AND TL.DELTD <>'Y'
               AND  TR.NAMT<>0
               AND TL.BUSDATE >= frdate
               AND TL.BUSDATE <= todate
               AND APP.FIELD IN   ('TRADE','BLOCKED','WITHDRAW','MORTAGE','SECURED','NETTING','DTOCLOSE')
               GROUP BY  TR.ACCTNO
  UNION ALL
         SELECT   SUM ((CASE WHEN APP.TXTYPE = 'D'THEN -TR.NAMT WHEN
         APP.TXTYPE = 'C' THEN TR.NAMT ELSE 0 END )) AMT, TR.ACCTNO ACCTNO
         FROM APPTX APP, SETRANA TR ,TLLOGALL TL
         WHERE TR.TXCD = APP.TXCD
               AND TL.TXNUM =TR.TXNUM
               AND TL.TXDATE =TR.TXDATE
               AND APP.APPTYPE = 'SE'
               AND APP.TXTYPE IN ('C', 'D')
               AND TL.DELTD <>'Y'
               AND  TR.NAMT<>0
               AND TL.BUSDATE >= frdate
			   AND TL.BUSDATE <= todate
               AND APP.FIELD IN    ('TRADE','BLOCKED','WITHDRAW','MORTAGE','SECURED','NETTING','DTOCLOSE')
               GROUP BY  TR.ACCTNO
                )
               GROUP BY ACCTNO
) AV
ON AV.ACCTNO =SE.ACCTNO

) NUM
WHERE SUBSTR(NUM.ACCTNO,1,10) = AF.ACCTNO
AND AF.CUSTID =CF.CUSTID
AND SUBSTR(NUM.ACCTNO,11,6)= SB.CODEID
AND AL.CDNAME= 'COUNTRY'
AND AL.CDTYPE= 'CF'
AND AL.CDVAL = CF.COUNTRY
AND  ISS.ISSUERID = SB.ISSUERID
-- ORDER BY AF.ACCTNO
)
where custodycd like '%C%'
group by TRADEPLACE, symbol, substr(custodycd,1,4)
order by TRADEPLACE, symbol, substr(custodycd,1,4)
)
AB
left join
(
select max(symbol) SYMBOL, round(sum(KL_Buy)/day,2) QTTY_BUY, round(sum(KL_Sell)/day,2) QTTY_SELL  from(
select i.bors, i.symbol, sum(i.matchqtty) KL_Khop,
case when i.bors = 'B' then sum(i.matchqtty) else 0 end KL_Buy,
case when i.bors = 'S' then sum(i.matchqtty) else 0 end KL_Sell
from iodhist i
where txdate >= frdate
and txdate <= todate
and i.deltd = 'N'
and i.custodycd like '%C%'
group by i.bors, i.symbol
)
group by symbol
) CD
on AB.symbol = CD.symbol
where Tradeplace in ('001','002')
and Tai_Khoan like '%C%'
order by TRADEPLACE,AB.SYMBOL;
EXCEPTION
    WHEN others THEN
        return;
END; -- Procedure

 
 
 
 
/
