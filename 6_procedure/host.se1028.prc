SET DEFINE OFF;
CREATE OR REPLACE PROCEDURE "SE1028" (
   PV_REFCURSOR           IN OUT   PKG_REPORT.REF_CURSOR,
   OPT            IN       VARCHAR2,
   PV_BRID           IN       VARCHAR2,
   TLGOUPS        IN       VARCHAR2,
   TLSCOPE        IN       VARCHAR2,
   I_DATE         IN       VARCHAR2,
   PV_TRADEPLACE  IN       VARCHAR2,
   PV_SYMBOL      IN       VARCHAR2,
   PV_CUSTODYCD   IN       VARCHAR2,
   PV_AFACCTNO    IN       VARCHAR2
  )
IS
--
   CUR            PKG_REPORT.REF_CURSOR;
   V_STROPT       VARCHAR2 (5);            -- A: ALL; B: BRANCH; S: SUB-BRANCH
   V_STRBRID      VARCHAR2 (100);                   -- USED WHEN V_NUMOPTION > 0
   V_INBRID       VARCHAR2 (5);
   v_strIBRID     VARCHAR2 (4);
   vn_BRID        varchar2(50);
   vn_TRADEPLACE varchar2(50);
   v_TRADEPLACE VARCHAR2 (4);
   v_OnDate date;
   v_CurrDate date;
   v_CustodyCD varchar2(20);
   v_AFAcctno varchar2(20);
   v_Symbol varchar2(20);
   V_STRTLID           VARCHAR2(6);
   V_FDATE  date;
BEGIN

IF  (PV_SYMBOL <> 'ALL')
THEN
      v_Symbol := upper(REPLACE (PV_SYMBOL,' ','_'));
ELSE
   v_Symbol := '%';
END IF;

IF  (PV_CUSTODYCD <> 'ALL')
THEN
      v_CustodyCD := upper(PV_CUSTODYCD);
ELSE
   v_CustodyCD := '%';
END IF;

IF  (PV_AFACCTNO <> 'ALL')
THEN
      v_AFAcctno := upper(PV_AFACCTNO);
ELSE
   v_AFAcctno := '%';
END IF;

IF  (PV_TRADEPLACE <> 'ALL')
THEN
      v_TRADEPLACE := upper(PV_TRADEPLACE);
ELSE
   v_TRADEPLACE := '%';
END IF;


v_OnDate:= to_date(I_DATE,'DD/MM/RRRR');

SELECT getprevdate(v_OnDate,3) INTO V_FDATE  FROM DUAL ;

DELETE FROM SEMAST_TEMP_FLEX ;
INSERT INTO SEMAST_TEMP_FLEX
select cf.custodycd||NVL( sb.refcodeid, sb.codeid) acctno,cf.custodycd, replace (SB.symbol,'_WFT','') SYMBOL,
sum ( case when  sb.TRADEPLACE<>'006' THEN   TRADE+MORTAGE+STANDING+WITHDRAW+DTOCLOSE+EMKQTTY+ nvl(senetting.NETTING,0)+ nvl(se_RETAIL_move_amt,0) -
                                                  ( NVL(se_TRADE_move_amt,0)+ NVL(se_MORTAGE_move_amt,0)+ NVL(se_STANDING_move_amt,0)+
                                                    NVL(se_WITHDRAW_move_amt,0)+ NVL(se_DTOCLOSE_move_amt,0)+ NVL(se_EMKQTTY_move_amt,0)

                                                    )
     ELSE 0 END ) TRADE ,
sum ( case when  sb.TRADEPLACE<>'006' THEN   -STANDING+ NVL(se_STANDING_move_amt,0)
    ELSE 0 END ) STANDING,
sum ( case when  sb.TRADEPLACE<>'006' THEN  BLOCKDTOCLOSE+BLOCKWITHDRAW+ BLOCKED -
                                                                              ( NVL(se_BLOCKED_move_amt,0)+ NVL(se_BLOCKDTOCLOSE_move_amt,0)+ NVL(se_BLOCKWITHDRAW_move_amt,0))
    ELSE 0 END ) BLOCKED,
SUM ( case WHEN  sb.TRADEPLACE = '006' THEN   TRADE+MORTAGE+STANDING+WITHDRAW+DTOCLOSE+EMKQTTY + nvl(senetting.NETTING,0)
                                   -    ( NVL(se_TRADE_move_amt,0)+ NVL(se_MORTAGE_move_amt,0)+ NVL(se_STANDING_move_amt,0)+
                                        NVL(se_WITHDRAW_move_amt,0)+ NVL(se_DTOCLOSE_move_amt,0)+ NVL(se_EMKQTTY_move_amt,0)  )
    ELSE 0 END ) WTDCN,
SUM ( case WHEN  sb.TRADEPLACE = '006' THEN    BLOCKDTOCLOSE+BLOCKWITHDRAW+ BLOCKED
                                   -    (  NVL(se_BLOCKED_move_amt,0)+ NVL(se_BLOCKDTOCLOSE_move_amt,0)+ NVL(se_BLOCKWITHDRAW_move_amt,0)  )
    ELSE 0 END ) WHCCN
from semast se, sbsecurities sb , (SELECT * FROM CFMAST WHERE custatcom ='Y'  ) cf, afmast af,
  (/*select sum( execqtty) netting,od.seacctno acctno
        from vw_odmast_all od
        where od.txdate <= v_OnDate and od.txdate >= getprevdate(v_OnDate,OD.clearday)
        and od.exectype ='NS'
        group by od.seacctno
        having sum( execqtty)>0*/

        select SUM(QTTY) netting, AFACCTNO||CODEID acctno  from vw_stschd_all STS
        where duetype ='RM'
        AND STS.TXDATE  <=v_OnDate AND STS.CLEARDATE > v_OnDatE
        AND DELTD <>'Y'
        GROUP BY AFACCTNO||CODEID
        ) senetting,
    (   -- SO LUONG CK LO LE CHO BAN'
        SELECT TR.acctno, SUM(tr.qtty) se_RETAIL_move_amt
        FROM seretail TR
        WHERE tr.txdate <> nvl(tr.sdate,getcurrdate+1)
            and tr.txdate <= v_OnDate
            AND nvl(tr.sdate,getcurrdate+1) >  v_OnDate
        GROUP BY TR.ACCTNO
    ) SR_QTTY,
 (
    -- Tong phat sinh field cac loai so du CK tu Txdate den ngay hom nay
    select tr.acctno,
        sum
        (case when field = 'TRADE' then
                case when tr.txtype = 'D' then -tr.namt else tr.namt end
            else 0
            end
        ) se_trade_move_amt,            -- Phat sinh CK giao dich
        sum
        (case when field = 'MORTAGE' then
                case when tr.txtype = 'D' then -tr.namt else tr.namt end
             else 0
             end
        ) se_MORTAGE_move_amt ,         -- Phat sinh CK Phong toa gom ca STANDING
        sum
        (case when field = 'BLOCKED'
                then
                (case when tr.txtype = 'D' then -tr.namt else tr.namt end)
            else 0
            end
         ) se_BLOCKED_move_amt,      -- Phat sinh CK tam giu
       sum
        ( case when field = 'STANDING'
                then
                (case when tr.txtype = 'D' then -tr.namt else tr.namt end)
            else 0 end
         ) se_STANDING_move_amt,
       sum
        ( case when field = 'NETTING' then
                (case when tr.txtype = 'D' then -tr.namt else tr.namt end)
            else 0
            end
        ) se_NETTING_move_amt ,
       sum
        ( case when field = 'WITHDRAW' then
                (case when tr.txtype = 'D' then -tr.namt else tr.namt end)
            else 0
            end
        ) se_WITHDRAW_move_amt ,
       sum
        ( case when field = 'DTOCLOSE' then
                (case when tr.txtype = 'D' then -tr.namt else tr.namt end)
            else 0
            end
        ) se_DTOCLOSE_move_amt ,
       sum
        ( case when field = 'EMKQTTY' then
                (case when tr.txtype = 'D' then -tr.namt else tr.namt end)
            else 0
            end
        ) se_EMKQTTY_move_amt,
         sum
        ( case when field = 'BLOCKWITHDRAW' then
                (case when tr.txtype = 'D' then -tr.namt else tr.namt end)
            else 0
            end
        ) se_BLOCKWITHDRAW_move_amt,
         sum
        ( case when field = 'BLOCKDTOCLOSE' then
                (case when tr.txtype = 'D' then -tr.namt else tr.namt end)
            else 0
            end
        ) se_BLOCKDTOCLOSE_move_amt
    from vw_setran_gen tr
    where tr.busdate > v_OnDate
        and tr.sectype <> '004'
        and tr.field in ('TRADE','MORTAGE','BLOCKED','STANDING','NETTING','WITHDRAW','DTOCLOSE','EMKQTTY','BLOCKWITHDRAW','BLOCKDTOCLOSE')
    group by tr.acctno
    ) se_field_move
    WHERE  se.codeid =sb.codeid
    and se.acctno = se_field_move.acctno(+)
    and se.acctno = senetting.acctno(+)
    and se.acctno = SR_QTTY.acctno(+)
    and se.afacctno = af.acctno
    and sb.sectype <> '004'
    and sb.tradeplace like v_TRADEPLACE
    AND replace (SB.symbol,'_WFT','')  LIKE v_Symbol
    and af.custid = cf.custid
    group by cf.custodycd,NVL( sb.refcodeid, sb.codeid),replace (SB.symbol,'_WFT','')
      HAVING
    sum ( case when  sb.TRADEPLACE<>'006' THEN   TRADE+MORTAGE+STANDING+WITHDRAW+DTOCLOSE+EMKQTTY+ nvl(senetting.NETTING,0)+ nvl(se_RETAIL_move_amt,0) -
     ( NVL(se_TRADE_move_amt,0)+ NVL(se_MORTAGE_move_amt,0)+ NVL(se_STANDING_move_amt,0)+
     NVL(se_WITHDRAW_move_amt,0)+ NVL(se_DTOCLOSE_move_amt,0)+ NVL(se_EMKQTTY_move_amt,0)
    ) ELSE 0 END )+
     sum ( case when  sb.TRADEPLACE<>'006' THEN   -STANDING+ NVL(se_STANDING_move_amt,0)  ELSE 0 END ) +
     sum ( case when  sb.TRADEPLACE<>'006' THEN  BLOCKDTOCLOSE+BLOCKWITHDRAW+ BLOCKED -
     ( NVL(se_BLOCKED_move_amt,0)+ NVL(se_BLOCKDTOCLOSE_move_amt,0)+ NVL(se_BLOCKWITHDRAW_move_amt,0))  ELSE 0 END ) +
sum ( case when  sb.TRADEPLACE = '006' THEN   TRADE+MORTAGE+STANDING+WITHDRAW+DTOCLOSE+EMKQTTY + nvl(senetting.NETTING,0)
     + BLOCKDTOCLOSE+BLOCKWITHDRAW+ BLOCKED
-    ( NVL(se_TRADE_move_amt,0)+ NVL(se_MORTAGE_move_amt,0)+ NVL(se_STANDING_move_amt,0)+
     NVL(se_WITHDRAW_move_amt,0)+ NVL(se_DTOCLOSE_move_amt,0)+ NVL(se_EMKQTTY_move_amt,0)+
     NVL(se_BLOCKED_move_amt,0)+ NVL(se_BLOCKDTOCLOSE_move_amt,0)+ NVL(se_BLOCKWITHDRAW_move_amt,0)  ) ELSE 0 END ) >0;

COMMIT;

-- Main report
OPEN PV_REFCURSOR FOR
SELECT
     sum( trade_TT) tt_trade ,
     sum(  STANDING_TT) tt_standing,
     sum(  BLOCKED_TT) tt_blocked,
     sum(  WHCCN_TT) tt_whccn,
     SUM(  WTDCN_TT) tt_wtdcn,
     SUM( trade_flex) flex_trade,
     SUM( standing_flex) flex_standing,
     SUM( blocked_flex) flex_blocked,
     SUM( whccn_flex) flex_whccn,
     SUM( wtdcn_flex) flex_wtdcn,
     custodycd, SYMBOL, I_DATE idate
FROM
(

SELECT sum( case when ( ACCTYPE = 'Giao dịch' OR  ACCTYPE ='Chờ thanh toán' OR ACCTYPE ='Chờ rút' ) then  SETE.QTTY else 0 end ) trade_TT,
     sum( case when  ACCTYPE = 'Cầm cố'  then  SETE.QTTY else 0 end ) STANDING_TT,
     sum( case when  ACCTYPE =  'Hạn chế CN'  then  SETE.QTTY else 0 end ) BLOCKED_TT,
     sum( case when  ACCTYPE = 'Chờ GD HCCN' then  SETE.QTTY else 0 end ) WHCCN_TT,
     SUM( CASE WHEN acctype = 'Chờ GD TDCN'  THEN sete.qtty ELSE 0 END) WTDCN_TT,
     0 trade_flex,
     0 standing_flex,
     0 blocked_flex,
     0 whccn_flex,
     0 wtdcn_flex,
     cf.custodycd,SB.SYMBOL
FROM tmpSEMASTVSD SETE ,(SELECT * FROM CFMAST WHERE custatcom ='Y' AND  FNC_VALIDATE_SCOPE(BRID, CAREBY, TLSCOPE, pv_BRID, TLGOUPS)=0) CF, SBSECURITIES SB
WHERE  SETE.CUSTODYCD = CF.CUSTODYCD
AND CF.CUSTODYCD LIKE v_CustodyCD
AND SETE.SYMBOL = SB.SYMBOL
and sb.tradeplace like v_TRADEPLACE
and sb.sectype <>'004'
group by  SB.CODEID,cf.custodycd,sb.symbol
UNION ALL
SELECT 0 trade_TT,
     0 STANDING_TT,
     0 BLOCKED_TT,
     0 WHCCN_TT,
     0 WTDCN_TT,
     f.trade trade_flex,
     f.standing standing_flex,
     f.blocked blocked_flex,
     f.whccn whccn_flex,
     f.wtdcn wtdcn_flex,
     f.custodycd,f.SYMBOL
FROM SEMAST_TEMP_FLEX f, sbsecurities sb
WHERE f.symbol = sb.symbol AND f.CUSTODYCD LIKE v_CustodyCD AND f.SYMBOL LIKE  v_Symbol  AND sb.tradeplace LIKE v_TRADEPLACE
)
GROUP BY custodycd, SYMBOL
HAVING
sum( trade_TT) <>  SUM( trade_flex) OR
     sum(  STANDING_TT) <>  SUM( standing_flex) OR
     sum(  BLOCKED_TT)  <> SUM( blocked_flex) OR
     sum(  WHCCN_TT) <> SUM( whccn_flex) OR
     SUM(  WTDCN_TT) <> SUM( wtdcn_flex)



/*select I_DATE idate, dt.custodycd, dt.symbol,max(tt_trade) tt_trade,max(tt_blocked) tt_blocked,max(tt_standing) tt_standing
,max(tt_whccn) tt_whccn, max(tt_wtdcn) tt_wtdcn,max(flex_trade) flex_trade,max(flex_blocked) flex_blocked,max(flex_standing) flex_standing,
max(flex_whccn) flex_whccn, max(flex_wtdcn) flex_wtdcn
from (
select    tt.custodycd, tt.symbol,tt.trade tt_trade,tt.blocked tt_blocked, tt.standing tt_standing,tt.whccn tt_whccn, tt.wtdcn tt_wtdcn,
      flex.trade flex_trade,flex.blocked flex_blocked, flex.standing flex_standing,flex.whccn flex_whccn, flex.wtdcn flex_wtdcn
from
(
SELECT sum( case when ( ACCTYPE = 'Giao dịch' OR  ACCTYPE ='Chờ thanh toán' OR ACCTYPE ='Chờ rút' ) then  SETE.QTTY else 0 end ) trade,
     sum( case when  ACCTYPE = 'Cầm cố'  then  SETE.QTTY else 0 end ) STANDING,
     sum( case when  ACCTYPE =  'Hạn chế CN'  then  SETE.QTTY else 0 end ) BLOCKED,
     sum( case when  ACCTYPE = 'Chờ GD HCCN' then  SETE.QTTY else 0 end ) WHCCN,
     SUM( CASE WHEN acctype = 'Chờ GD TDCN'  THEN sete.qtty ELSE 0 END) WTDCN,
  cF.custodycd|| SB.CODEID acctno,cf.custodycd,SB.SYMBOL
FROM tmpSEMASTVSD SETE ,(SELECT * FROM CFMAST WHERE FNC_VALIDATE_SCOPE(BRID, CAREBY, TLSCOPE, pv_BRID, TLGOUPS)=0) CF, SBSECURITIES SB
WHERE  SETE.CUSTODYCD = CF.CUSTODYCD
AND CF.CUSTODYCD LIKE v_CustodyCD
AND SETE.SYMBOL = SB.SYMBOL
and sb.tradeplace like v_TRADEPLACE
and sb.sectype <>'004'
group by  SB.CODEID,cf.custodycd,sb.symbol
  )tt,
( SELECT * FROM SEMAST_TEMP_FLEX WHERE CUSTODYCD LIKE v_CustodyCD AND SYMBOL LIKE  v_Symbol )flex
 where  tt.acctno = flex.acctno (+)
 and( nvl (tt.trade,0)<> nvl( flex.trade,0)
      or nvl (tt.standing,0)<> nvl( flex.standing,0)
      or nvl (tt.blocked,0)<> nvl( flex.blocked,0)
       or nvl (tt.whccn,0)<> nvl( flex.whccn,0)
       or nvl (tt.wtdcn,0)<> nvl( flex.wtdcn,0)
      )

union

select   tt.custodycd, tt.symbol,tt.trade tt_trade,tt.blocked tt_blocked, tt.standing tt_standing,tt.whccn tt_whccn, tt.wtdcn tt_wtdcn,
      flex.trade flex_trade,flex.blocked flex_blocked, flex.standing flex_standing,flex.whccn flex_whccn, flex.wtdcn flex_wtdcn
from
(
SELECT sum( case when ( ACCTYPE = 'Giao dịch' OR  ACCTYPE ='Chờ thanh toán' OR ACCTYPE ='Chờ rút') then  SETE.QTTY else 0 end ) trade,
     sum( case when  ACCTYPE = 'Cầm cố'  then  SETE.QTTY else 0 end ) STANDING,
     sum( case when  ACCTYPE =  'Hạn chế CN'  then  SETE.QTTY else 0 end ) BLOCKED,
     sum( case when  ACCTYPE = 'Chờ GD HCCN' then  SETE.QTTY else 0 end ) WHCCN,
     SUM( CASE WHEN acctype = 'Chờ GD TDCN'  THEN sete.qtty ELSE 0 END) WTDCN,
  cF.custodycd|| SB.CODEID acctno,cf.custodycd,SB.SYMBOL
FROM tmpSEMASTVSD SETE ,(SELECT * FROM CFMAST WHERE FNC_VALIDATE_SCOPE(BRID, CAREBY, TLSCOPE, pv_BRID, TLGOUPS)=0) CF, SBSECURITIES SB
WHERE  SETE.CUSTODYCD = CF.CUSTODYCD
and sb.tradeplace like v_TRADEPLACE
AND CF.CUSTODYCD LIKE v_CustodyCD
AND SETE.SYMBOL = SB.SYMBOL
and sb.sectype <>'004'
group by  SB.CODEID,cf.custodycd,sb.symbol
  )tt,
( SELECT * FROM SEMAST_TEMP_FLEX WHERE CUSTODYCD LIKE v_CustodyCD AND SYMBOL LIKE  v_Symbol)flex
 where flex.acctno= tt.acctno  (+)
 and( nvl (tt.trade,0)<> nvl( flex.trade,0)
      or nvl (tt.standing,0)<> nvl( flex.standing,0)
      or nvl (tt.blocked,0)<> nvl( flex.blocked,0)
        or nvl (tt.whccn,0)<> nvl( flex.whccn,0)
             or nvl (tt.wtdcn,0)<> nvl( flex.wtdcn,0)
      )
      )dt
WHERE dt.symbol LIKE v_symbol
   group by  dt.custodycd, dt.symbol*/
      ;

EXCEPTION
  WHEN OTHERS
   THEN
   dbms_output.put_line('12233');
      RETURN;
END;

 
 
 
 
/
