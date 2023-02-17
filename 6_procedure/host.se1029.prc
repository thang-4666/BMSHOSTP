SET DEFINE OFF;
CREATE OR REPLACE PROCEDURE se1029 (
   PV_REFCURSOR           IN OUT   PKG_REPORT.REF_CURSOR,
   OPT            IN       VARCHAR2,
   PV_BRID           IN       VARCHAR2,
   TLGOUPS        IN       VARCHAR2,
   TLSCOPE        IN       VARCHAR2,
   I_DATE         IN       VARCHAR2,
   PV_TRADEPLACE  IN       VARCHAR2,
   PV_SYMBOL      IN       VARCHAR2
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


IF  (PV_TRADEPLACE <> 'ALL')
THEN
      v_TRADEPLACE := upper(PV_TRADEPLACE);
ELSE
   v_TRADEPLACE := '%';
END IF;


v_OnDate:= to_date(I_DATE,'DD/MM/RRRR');

SELECT getprevdate(v_OnDate,3) INTO V_FDATE  FROM DUAL ;

DELETE FROM se_total_flex ;
INSERT INTO se_total_flex
SELECT replace (SB.symbol,'_WFT','') SYMBOL,
CASE WHEN substr(cf.custodycd,4,1) = 'P' THEN 'TDTN'
  WHEN substr(cf.custodycd,4,1) = 'F' THEN 'MGNN'
  ELSE 'MGTN' END "ACTYPE",
sum ( case when  sb.TRADEPLACE<>'006' THEN   TRADE+MORTAGE+STANDING+WITHDRAW+DTOCLOSE+EMKQTTY+ nvl(senetting.NETTING,0) + nvl(se_RETAIL_move_amt,0) -
                                                  ( NVL(se_TRADE_move_amt,0)+ NVL(se_MORTAGE_move_amt,0)+ NVL(se_STANDING_move_amt,0)+
                                                    NVL(se_WITHDRAW_move_amt,0)+ NVL(se_DTOCLOSE_move_amt,0)+ NVL(se_EMKQTTY_move_amt,0)

                                                    )
     ELSE 0 END )+
sum ( case when  sb.TRADEPLACE<>'006' THEN   -STANDING+ NVL(se_STANDING_move_amt,0)
    ELSE 0 END ) +
sum ( case when  sb.TRADEPLACE<>'006' THEN  BLOCKDTOCLOSE+BLOCKWITHDRAW+ BLOCKED -
                                                                              ( NVL(se_BLOCKED_move_amt,0)+ NVL(se_BLOCKDTOCLOSE_move_amt,0)+ NVL(se_BLOCKWITHDRAW_move_amt,0))
    ELSE 0 END ) +
SUM ( case WHEN  sb.TRADEPLACE = '006' THEN   TRADE+MORTAGE+STANDING+WITHDRAW+DTOCLOSE+EMKQTTY + nvl(senetting.NETTING,0)
                                   -    ( NVL(se_TRADE_move_amt,0)+ NVL(se_MORTAGE_move_amt,0)+ NVL(se_STANDING_move_amt,0)+
                                        NVL(se_WITHDRAW_move_amt,0)+ NVL(se_DTOCLOSE_move_amt,0)+ NVL(se_EMKQTTY_move_amt,0)  )
    ELSE 0 END ) +
SUM ( case WHEN  sb.TRADEPLACE = '006' THEN    BLOCKDTOCLOSE+BLOCKWITHDRAW+ BLOCKED
                                   -    (  NVL(se_BLOCKED_move_amt,0)+ NVL(se_BLOCKDTOCLOSE_move_amt,0)+ NVL(se_BLOCKWITHDRAW_move_amt,0)  )
    ELSE 0 END ) "QTTY"
from semast se, sbsecurities sb , (SELECT * FROM CFMAST  WHERE custatcom ='Y' AND  FNC_VALIDATE_SCOPE(BRID, CAREBY, TLSCOPE, pv_BRID, TLGOUPS)=0) cf, afmast af,
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
    and af.custid = cf.custid
    group by replace (SB.symbol,'_WFT','') ,
      CASE WHEN substr(cf.custodycd,4,1) = 'P' THEN 'TDTN'
        WHEN substr(cf.custodycd,4,1) = 'F' THEN 'MGNN'
        ELSE 'MGTN' END
      HAVING
    sum ( case when  sb.TRADEPLACE<>'006' THEN   TRADE+MORTAGE+STANDING+WITHDRAW+DTOCLOSE+EMKQTTY+ nvl(senetting.NETTING,0) + nvl(se_RETAIL_move_amt,0) -
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
SELECT I_DATE idate, symbol, SUM (MGTN_FLEX) MGTN_FLEX,
        sum(MGNN_FLEX) MGNN_FLEX,
       sum(TDTN_FLEX) TDTN_FLEX,
        sum(MGTN_TT) MGTN_TT,
        sum(MGNN_TT) MGNN_TT,
        sum(TDTN_TT) TDTN_TT
FROM
(
SELECT t.symbol,
       sum(CASE WHEN t.actype = 'MGTN' THEN t.qtty ELSE 0 END) MGTN_FLEX,
       sum(CASE WHEN t.actype = 'MGNN' THEN t.qtty ELSE 0 END) MGNN_FLEX,
       sum(CASE WHEN t.actype = 'TDTN' THEN t.qtty ELSE 0 END) TDTN_FLEX,
       0 MGTN_TT,
       0 MGNN_TT,
       0 TDTN_TT
FROM se_total_flex t, sbsecurities sb
WHERE t.symbol = sb.symbol AND sb.sectype <> '004'
AND sb.tradeplace LIKE v_TRADEPLACE AND sb.symbol LIKE v_Symbol
GROUP BY t.symbol
UNION ALL
SELECT t.symbol,
        0 MGTN_FLEX,
       0 MGNN_FLEX,
       0 TDTN_FLEX,
       sum(CASE WHEN t.actype = 'MGTN' THEN t.qtty ELSE 0 END) MGTN_TT,
       sum(CASE WHEN t.actype = 'MGNN' THEN t.qtty ELSE 0 END) MGNN_TT,
       sum(CASE WHEN t.actype = 'TDTN' THEN t.qtty ELSE 0 END) TDTN_TT
FROM tmptotaLSEVSD t, sbsecurities sb
WHERE t.symbol = sb.symbol AND sb.sectype <> '004'
AND sb.tradeplace LIKE v_TRADEPLACE AND sb.symbol LIKE v_Symbol
GROUP BY t.symbol
)
GROUP BY symbol
HAVING
      SUM (MGTN_FLEX) <>sum(MGTN_TT) OR
        sum(MGNN_FLEX) <>sum(MGNN_TT) OR
       sum(TDTN_FLEX) <>sum(TDTN_TT)
ORDER BY symbol

      ;

EXCEPTION
  WHEN OTHERS
   THEN
   dbms_output.put_line('12233');
      RETURN;
END;

 
 
 
 
/
