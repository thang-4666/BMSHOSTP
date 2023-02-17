SET DEFINE OFF;
CREATE OR REPLACE PROCEDURE "CF0062" (
   PV_REFCURSOR   IN OUT   PKG_REPORT.REF_CURSOR,
   OPT            IN       VARCHAR2,
   PV_BRID        IN       VARCHAR2,
   TLGOUPS        IN       VARCHAR2,
   TLSCOPE        IN       VARCHAR2,
   I_DATE         IN       VARCHAR2,
   PV_CUSTODYCD         IN       VARCHAR2

)
IS
--
-- ---------   ------  -------------------------------------------
   V_STROPTION        VARCHAR2 (5);       -- A: ALL; B: BRANCH; S: SUB-BRANCH
   V_STRBRID          VARCHAR2 (4);              -- USED WHEN V_NUMOPTION > 0

   V_STRCUSTODYCD        VARCHAR2 (100);
   V_INDATE              DATE;
   V_I_DATE              DATE;
   V_CURR                 DATE;

-- DECLARE PROGRAM VARIABLES AS SHOWN ABOVE
BEGIN
   V_STROPTION := OPT;

   IF (V_STROPTION <> 'A') AND (PV_BRID <> 'ALL')
   THEN
      V_STRBRID := PV_BRID;
   ELSE
      V_STRBRID := '%%';
   END IF;

   -- GET REPORT'S PARAMETERS

     V_STRCUSTODYCD   := UPPER(PV_CUSTODYCD);
     V_INDATE:= TO_DATE(I_DATE,'DD/MM/YYYY');
     SELECT V_INDATE-1 INTO V_I_DATE FROM DUAL;
     select to_date(varvalue,'DD/MM/RRRR') into V_CURR from sysvar where varname = 'CURRDATE' and grname = 'SYSTEM';
   -- END OF GETTING REPORT'S PARAMETERS
   -- GET REPORT'S DATA

      OPEN PV_REFCURSOR
       FOR

-- SE0087
select * from (
SELECT  V_STRCUSTODYCD CUST, V_INDATE INDATE,V_CURR CURR, symbol, parvalue,dt.basicprice,
    custodycd,fullname, idcode, iddate,idplace,country,cd.cdcontent QTTY_TYPE, cd.lstodr,
    decode(cd.cdval,'TRADE', sum(end_trade_bal+end_netting_bal + camco_df +
                                end_mortage_bal + end_WITHDRAW_bal - MORTAGE_CANCEL_PENDING),
                    'BLOCKQTTY',sum(end_blocked_bal+WITHDRAW_HCCN),
                    'NETTING', sum(ck_execqtty),
                    'MORTAGE',sum( end_STANDING_bal + MORTAGE_CANCEL_PENDING) ,  ---sua lai gia tri cam co
                    'WTRADE',sum(ck_cho_gd + end_WITHDRAW_bal_cho_gd ),
                    'WITHDRAW',0,
                    'BLOCKED',0,0) QTTY

FROM
(select sebal.afacctno, sebal.acctno, sebal.parvalue,sebal.basicprice,
    sebal.custodycd,sebal.fullname, sebal.idcode, sebal.iddate, sebal.idplace,sebal.country,
    CASE WHEN instr(sebal.symbol,'_WFT') <> 0 THEN substr(sebal.symbol,1, instr(sebal.symbol,'_WFT')-1) ELSE sebal.symbol END symbol,
    CASE WHEN instr(sebal.symbol,'_WFT')<> 0 THEN 0 ELSE nvl(se_balance,0) END se_balance,
    CASE WHEN instr(sebal.symbol,'_WFT')<> 0 THEN 0 ELSE nvl(trade,0) END trade,
    CASE WHEN instr(sebal.symbol,'_WFT')<> 0 THEN 0 ELSE nvl(trade,0) - nvl(se_trade_move_amt,0) -
        nvl(trade_sell_qtty,0) + NVL(SR_QTTY.se_RETAIL_move_amt,0) END  end_trade_bal,
    CASE WHEN instr(sebal.symbol,'_WFT')<> 0 THEN 0 ELSE nvl(blocked,0) END blocked,
    CASE WHEN instr(sebal.symbol,'_WFT') <> 0 THEN 0 ELSE nvl(se_block.curr_block_qtty,0)
            - nvl(se_BLOCKED_move_HCCN,0) END end_blocked_bal, -- han che CN

    CASE WHEN instr(sebal.symbol,'_WFT') = 0 THEN 0 ELSE nvl(se_block.curr_block_qtty,0) -
            nvl(se_block_move.cr_block_amt,0) + nvl(se_block_move.dr_block_amt,0)
            - nvl(se_blocked_move_amt,0) END hccn_chogiao,

    CASE WHEN instr(sebal.symbol,'_WFT') <> 0 THEN 0 ELSE nvl(mortage,0) END mortage,
    CASE WHEN instr(sebal.symbol,'_WFT') <> 0 THEN 0 ELSE nvl(se_block.curr_block_pt,0) -
            nvl(se_block_move.cr_block_amt_pt,0) + nvl(se_block_move.dr_block_amt_pt,0)
             END  end_mortage_bal,
    CASE WHEN instr(sebal.symbol,'_WFT')<> 0 THEN 0 ELSE nvl(netting,0) END netting,
    CASE WHEN instr(sebal.symbol,'_WFT')<> 0 THEN 0 ELSE
       (case when V_CURR = V_I_DATE then
            nvl(order_today.trade_sell_qtty,0)+nvl(order_today.mtg_sell_qtty,0) -nvl(khop_today.khop_qtty,0)
            else 0 end)
            END  end_netting_bal,
    CASE WHEN instr(sebal.symbol,'_WFT')<> 0 THEN 0 ELSE nvl(khop_today.khop_qtty,0) END khop_qtty,
    CASE WHEN instr(sebal.symbol,'_WFT')<> 0 THEN 0 ELSE nvl(STANDING,0) END  standing,
    CASE WHEN instr(sebal.symbol,'_WFT')<> 0 THEN 0 ELSE abs(nvl(sebal.STANDING,0)-
        nvl(se_STANDING_move_amt,0)) END end_STANDING_bal , -- Do standing luon <=0
        nvl(SE_STAN_MOR.MORTAGE_CANCEL_PENDING,0)  MORTAGE_CANCEL_PENDING,
    CASE WHEN instr(sebal.symbol,'_WFT')<> 0 THEN 0 ELSE nvl(mortage,0)- nvl(se_mortage_move_amt,0) END end_MOTAGE_TTLK_bal,

   CASE WHEN instr(sebal.symbol,'_WFT')<> 0 THEN 0 ELSE nvl(mortage,0)- nvl(se_mortage_move_amt,0) - (- (  nvl(STANDING,0) - nvl(se_STANDING_move_amt,0) )) END camco_df,

    CASE WHEN instr(sebal.symbol,'_WFT')<> 0 THEN 0 ELSE nvl(RECEIVING,0) END receiving,
    nvl(RECEIVING,0) - nvl(se_RECEIVING_move_amt,0) +  nvl(CA_RECEIVING,0) + nvl(order_buy_today.receiving_qtty,0 ) end_RECEIVING_bal,
    CASE WHEN instr(sebal.symbol,'_WFT') = 0 THEN 0 ELSE nvl(RECEIVING,0) - nvl(se_RECEIVING_move_amt,0) +
        nvl(order_buy_today.receiving_qtty,0) END CA_RECEIVING,
    CASE WHEN instr(sebal.symbol,'_WFT')<> 0 THEN 0 ELSE nvl(WITHDRAW,0) END  WITHDRAW,

       (CASE WHEN instr(sebal.symbol,'_WFT')<> 0 THEN 0
        ELSE nvl(WITHDRAW,0)  -  NVL(WITHDRAW_HCCN.WITHDRAW_HCCN,0)-
        nvl(se_WITHDRAW_move_amt,0)  +
        nvl(sebal.blocked,0) - nvl(se_block.curr_block_pt,0) - nvl(se_block.curr_block_qtty,0) -
            nvl(se_BLOCKED_move_amt,0)
         + nvl(DTOCLOSE,0) - nvl(se_DTOCLOSE_move_amt,0)  end ) end_WITHDRAW_bal,

         --WITHDRAW_hccn
             CASE WHEN instr(sebal.symbol,'_WFT')<> 0 THEN 0 ELSE NVL(WITHDRAW_HCCN.WITHDRAW_HCCN,0) - nvl(se_WITHDRAW_move_amt_hccn,0)  END  WITHDRAW_HCCN,

           --Chung khoan cho giao dich
      (CASE WHEN instr(sebal.symbol,'_WFT')<> 0 THEN nvl(DTOCLOSE,0) - nvl(se_DTOCLOSE_move_amt,0)  ELSE 0
        END)   end_WITHDRAW_bal_cho_gd,


    CASE WHEN instr(sebal.symbol,'_WFT') <> 0 THEN (
        nvl(trade,0) - nvl(se_trade_move_amt,0) - nvl(order_today.trade_sell_qtty,0) - nvl(order_today.mtg_sell_qtty,0) +
        nvl(mortage,0) - nvl(se_mortage_move_amt,0) -
        (nvl(STANDING,0) - nvl(se_STANDING_move_amt,0)) +
        nvl(netting,0) - nvl(se_netting_move_amt,0) +
        nvl(WITHDRAW,0) - nvl(se_WITHDRAW_move_amt,0) - nvl(se_WITHDRAW_move_amt_HCCN,0) +
        nvl(DTOCLOSE,0) - nvl(se_DTOCLOSE_move_amt,0) +
        NVL(sebal.blocked,0) - nvl(se_BLOCKED_move_wft,0)
        ) ELSE 0 END ck_cho_gd,


    case when instr(sebal.symbol,'_WFT') <> 0 then 0
    else nvl(khop_qtty.execqtty,0) end ck_execqtty

from
    (
    -- Tong so du CK hien tai group by tieu khoan, Symbol
    select
        cf.custid, cf.custodycd,cf.fullname,  DECODE(SUBSTR(CF.CUSTODYCD,4,1),'F',CF.TRADINGCODE,CF.IDCODE) idcode, cf.iddate, cf.idplace,cd.cdcontent country,
        af.acctno afacctno, sb.symbol, se.acctno,
        sum(trade + blocked + mortage + netting + receiving) se_balance,
        sum(trade) trade, sum(blocked) blocked, sum(mortage) mortage, sum(netting) netting,
        sum(STANDING) STANDING, sum(RECEIVING) RECEIVING, sum(WITHDRAW) WITHDRAW, sum(DTOCLOSE) DTOCLOSE,
        max(parvalue) parvalue, SEIN.BASICPRICE
    from (SELECT * FROM CFMAST WHERE FNC_VALIDATE_SCOPE(BRID, CAREBY, TLSCOPE, pv_BRID, TLGOUPS)=0) cf, afmast af, semast se, SECURITIES_INFO SEIN,
        (select sb.*, nvl(wtf.tradeplace,sb.tradeplace) wtf_tradeplace, fn_symbol_tradeplace( nvl(wtf.codeid,sb.codeid), V_I_DATE  ) tradeplacenew
        from sbsecurities sb,sbsecurities wtf
            where sb.refcodeid = wtf.codeid(+)) sb,
            (select * from allcode where  cdname='COUNTRY' and cdtype='CF') cd
    where cf.custid = af.custid and af.acctno = se.afacctno
        and cf.custatcom = 'Y'
        and se.codeid = sb.codeid
        AND SE.CODEID=SEIN.CODEID

        and sb.sectype <> '004'

        and cd.cdval = cf.country

    group by  cf.custid, af.acctno, sb.symbol,se.acctno,cf.custodycd,cf.fullname,sein.basicprice,
     cf.idcode, cf.iddate, cf.idplace,cd.cdcontent,CF.TRADINGCODE
    ) sebal --on af.acctno = sebal.afacctno -------cf.custid=sebal.custid ---dien sua 2-10-2010

left join
(select sum(blocked+ sblocked) WITHDRAW_HCCN,acctno
 from sesendout where deltd <>'Y' group by acctno
having sum(blocked+ sblocked) >0) WITHDRAW_HCCN
ON  sebal.acctno = WITHDRAW_HCCN.acctno

left join
(
    select seacctno, sum(execqtty) execqtty
    from
    (
    select codeid, afacctno, seacctno, execqtty, txdate from odmast
    where execqtty > 0
        and exectype in ('MS','NS')
        and txdate <= V_I_DATE
    union all

   select odhist.codeid, odhist.afacctno, seacctno, execqtty, odhist.txdate from odmasthist odhist, stschdhist  sthist
     where execqtty > 0
        and odhist.txdate <= V_I_DATE
        and exectype in ('MS','NS')
        --and getduedate(txdate, clearcd, '000', clearday) > V_I_DATE
        AND sthist.orgorderid=odhist.orderid
        AND sthist.duetype='RM'
        AND sthist.cleardate>V_I_DATE
    )
    group by seacctno
) khop_qtty on sebal.acctno = khop_qtty.seacctno
left join
    (   -- Phat sinh ban chung khoan ngay hom nay
    select v.seacctno acctno,
        case when V_CURR = V_I_DATE then SUM(SECUREAMT) else 0 end trade_sell_qtty,
        case when V_CURR = V_I_DATE then SUM(SECUREMTG) else 0 end mtg_sell_qtty
    from v_getsellorderinfo v, sbsecurities sb
    where substr(v.seacctno,11,6) = sb.codeid
        and sb.sectype <>'004'
    group by v.seacctno
    ) order_today on sebal.acctno = order_today.acctno
left join
    (   -- Phat sinh mua chung khoan ngay hom nay
    select st.acctno acctno,
        case when V_CURR = V_I_DATE then SUM(qtty) else 0 end receiving_qtty
    from sbsecurities sb, stschd  st
    where st.codeid = sb.codeid and sb.sectype <>'004'
        and st.duetype = 'RS' and st.status = 'N'
        and st.txdate = V_CURR
    group by st.acctno
    ) order_buy_today on sebal.acctno = order_buy_today.acctno
left join
    (   -- Khop mua chung khoan ngay hom nay
    select st.acctno,
---        case when V_CURR = V_I_DATE) then SUM(qtty) else 0 end khop_qtty
        SUM(qtty) khop_qtty
    from sbsecurities sb,
        (select * from stschd where txdate = V_I_DATE
        union all select * from stschdhist where txdate = V_I_DATE) st
    where st.codeid = sb.codeid
        and sb.sectype <>'004'
        and st.duetype = 'SS' ---- and st.status = 'N'
    group by st.acctno
    ) khop_today on sebal.acctno = khop_today.acctno
left join
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
        (case when field = 'BLOCKED'  and nvl(tr.ref,'000') not in ('007','002')  and tr.tltxcd not in ('2203','2202')
                then
                (case when tr.txtype = 'D' then -tr.namt else tr.namt end)
            else 0
            end
         ) se_BLOCKED_move_amt,      -- Phat sinh CK tam giu
         sum
        (
            case when field = 'BLOCKED'
                then
                (case when tr.txtype = 'D' then -tr.namt else tr.namt end)
            else 0 end
         ) se_BLOCKED_move_HCCN,      -- Phat sinh CK HCCN

         sum
        (
            case when field = 'BLOCKED'
            then (case when tr.txtype = 'C' then tr.namt else -tr.namt end) else 0 end
        ) se_BLOCKED_move_wft, --CK cho giao dich
        sum
        ( case when field = 'NETTING' then
                (case when tr.txtype = 'D' then -tr.namt else tr.namt end)
            else 0
            end
        ) se_NETTING_move_amt ,         -- Phat sinh CK cho giao
        sum
        ( case when field = 'STANDING' then
                (case when tr.txtype = 'D' then -tr.namt else tr.namt end)
            else 0
            end
        ) se_STANDING_move_amt,         -- Phat sinh CK cam co len TT Luu ky
        sum
        ( case when field = 'RECEIVING' then
                (case when tr.txtype = 'D' then -tr.namt else tr.namt end)
            else 0
            end
        ) se_RECEIVING_move_amt,         -- Phat sinh CK cho nhan ve
        sum
        ( case when field = 'RECEIVING' and txcd in('3351','3350') then
                (case when tr.txtype = 'D' then -tr.namt else tr.namt end)
            else 0
            end
        ) CA_RECEIVING,
        sum
        ( case when field = 'WITHDRAW' AND NVL(TR.REF,'-')<> '002' then
                (case when tr.txtype = 'D'  then -tr.namt else tr.namt end)
            else 0
            end
        ) se_WITHDRAW_move_amt,         -- Phat sinh CK cho nhan ve
        sum
        ( case when field = 'WITHDRAW' AND TR.REF ='002' then
                (case when tr.txtype = 'D' then -tr.namt else tr.namt end)
            else 0
            end
        ) se_WITHDRAW_move_amt_HCCN,         -- Phat sinh CK cho nhan ve

        sum
        ( case when field = 'DTOCLOSE' then
                (case when tr.txtype = 'D' then -tr.namt else tr.namt end)
            else 0
            end
        ) se_DTOCLOSE_move_amt,
        sum
        ( case when field = 'BLOCKED' and tr.tltxcd = '2232'
            then (case when tr.txtype = 'C' then tr.namt else 0 end)
            else 0
            end
        ) se_BLOCKED_move_2232,
        sum
        ( case when field = 'BLOCKED' and tr.tltxcd = '2251'
            then (case when tr.txtype = 'D' then tr.namt else 0 end)
            else 0 end
        ) se_BLOCKED_move_2251
    from vw_setran_gen tr
    where tr.busdate > V_I_DATE and tr.busdate <= V_CURR
        and tr.sectype <> '004'
        and tr.field in ('EMKQTTY','TRADE','MORTAGE','BLOCKED','NETTING','STANDING','RECEIVING','WITHDRAW','DTOCLOSE')
    group by tr.acctno
    ) se_field_move on sebal.acctno = se_field_move.acctno
left join   -- So du chung khoan chuyen nhuong co dieu kien
    (
    select se.acctno, se.blocked curr_block_qtty, se.emkqtty curr_block_pt
    from semast se, sbsecurities sb
    where se.codeid = sb.codeid
        and sb.sectype <>'004'
    ) se_block on sebal.acctno = se_block.acctno
LEFT JOIN --THEM DOAN NAY CHO CHUNG KHOAN CAM CO VOI VSD. TINH LUONG CK DANG YEU CAU GIAI TOA NHUNG CHUA XAC NHAN
    (
        SELECT ACCTNO,SUM (CASE WHEN TLTXCD = '2233' THEN  NAMT ELSE - NAMT END ) MORTAGE_CANCEL_PENDING
        FROM VW_SETRAN_GEN
        WHERE TLTXCD IN ( '2233','2253')
        AND DELTD='N' AND FIELD IN ('STANDING','TRADE')
        AND BUSDATE <= V_I_DATE  GROUP BY ACCTNO
     )  SE_STAN_MOR  ON SEBAL.ACCTNO = SE_STAN_MOR.ACCTNO    --SE_STAN_MOR.MORTAGE_CANCEL_PENDING

left join   -- Phat sinh giao dich phong toa/giai toa CK chuyen nhuong co dieu kien
    (
    select tr.acctno,

        sum(case when  (tr.tltxcd = '2202' OR ( tr.tltxcd = '9902' AND TXTYPE='C')) and tr.ref = '002' then namt else 0 end) cr_block_amt,
        sum(case when (tr.tltxcd = '2203' OR ( tr.tltxcd = '9902' AND TXTYPE='D')) and tr.ref = '002' then namt else 0 end) dr_block_amt,
        sum(case when (tr.tltxcd = '2202' OR ( tr.tltxcd = '9902' AND TXTYPE='C')) and tr.ref = '007' then namt else 0 end) cr_block_amt_pt,
        sum(case when (tr.tltxcd = '2203' OR ( tr.tltxcd = '9902' AND TXTYPE='D')) and tr.ref = '007' then namt else 0 end) dr_block_amt_pt
    from vw_setran_gen tr
    where tr.field = 'BLOCKED'
        and tr.tltxcd in ('2202','2203','9902') and tr.ref in ('002','007') and tr.namt <> 0
        and tr.busdate > V_I_DATE and tr.busdate <= V_CURR
    group by tr.acctno
    ) se_block_move on sebal.acctno = se_block_move.acctno
LEFT JOIN
(
    SELECT TR.acctno, SUM(tr.qtty) se_RETAIL_move_amt
   FROM seretail TR
    WHERE tr.txdate <= V_I_DATE
        AND nvl(tr.sdate,getcurrdate+1) >  V_I_DATE
        AND tr.txdate <> nvl(tr.sdate,getcurrdate+1)
    GROUP BY TR.ACCTNO
) SR_QTTY ON SEBAL.ACCTNO = SR_QTTY.ACCTNO
where V_I_DATE <= V_CURR
order by sebal.symbol, sebal.afacctno
) dt, (select * from allcode where cdname='TRADETYPE' and cdtype='SE') CD
where CD.CDVAL is not null
AND DT.CUSTODYCD=V_STRCUSTODYCD
group by symbol, parvalue,custodycd,fullname, idcode, iddate,idplace,country, cd.cdval,cd.cdcontent,cd.lstodr,dt.basicprice
having sum(end_trade_bal+end_mortage_bal+camco_df+end_netting_bal+end_WITHDRAW_bal) <> 0 or
    sum(end_blocked_bal)  <> 0 or
    sum(end_STANDING_bal)  <> 0 or
    sum(hccn_chogiao) <> 0 or
    sum(ck_cho_gd)  <> 0 or
    sum(ck_execqtty)  <> 0 ) where  QTTY >0
order by symbol

         ;

 EXCEPTION
   WHEN OTHERS
   THEN
      RETURN;
END;
 
 
 
 
/
