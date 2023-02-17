SET DEFINE OFF;
CREATE OR REPLACE PROCEDURE se0086 (
   PV_REFCURSOR           IN OUT   PKG_REPORT.REF_CURSOR,
   OPT            IN       VARCHAR2,
   pv_BRID           IN       VARCHAR2,
   TLGOUPS        IN       VARCHAR2,
   TLSCOPE        IN       VARCHAR2,
   I_DATE         IN       VARCHAR2,
   I_BRID         IN       VARCHAR2,
   PV_TRADEPLACE  IN       VARCHAR2,
   PV_MARKETTYPE  IN       VARCHAR2,
   PV_SYMBOL      IN       VARCHAR2,
   PV_AFTYPE      IN       VARCHAR2,
   PV_SETYPR      IN       VARCHAR2
  )
IS
--


--
   CUR            PKG_REPORT.REF_CURSOR;
   V_STROPTION    VARCHAR2 (5);            -- A: ALL; B: BRANCH; S: SUB-BRANCH
   V_STRBRID      VARCHAR2 (40);                   -- USED WHEN V_NUMOPTION > 0
   V_INBRID       VARCHAR2 (4);

   v_strIBRID     VARCHAR2 (4);
   vn_BRID        varchar2(50);
   vn_TRADEPLACE varchar2(50);
   v_strTRADEPLACE VARCHAR2 (4);
   v_Markettype     varchar2(50);
   v_OnDate date;
   v_CurrDate date;
   v_Symbol varchar2(20);
   V_STRaftype varchar2(20);
   V_SETYPR  varchar2(20);

BEGIN

V_STROPTION := upper(OPT);
V_INBRID := pv_BRID;
IF V_STROPTION = 'A' THEN
    V_STRBRID := '%';
ELSIF V_STROPTION = 'B' then
    select brgrp.mapid into V_STRBRID from brgrp where brgrp.brid = V_INBRID;
else
    V_STRBRID := PV_BRID;
END IF;



IF  (PV_SYMBOL <> 'ALL')
THEN
      v_Symbol := upper(PV_SYMBOL);
ELSE
   v_Symbol := '%%';
END IF;

IF  (upper(I_BRID) <> 'ALL')
THEN
      v_strIBRID := upper(I_BRID);
      SELECT brname INTO vn_BRID FROM brgrp WHERE brgrp.brid LIKE I_BRID;
ELSE
   v_strIBRID := '%%';
   vn_BRID := 'ALL';
END IF;

IF  (upper(PV_TRADEPLACE) <> 'ALL')
THEN
      v_strTRADEPLACE := upper(PV_TRADEPLACE);
      SELECT cdcontent INTO vn_TRADEPLACE FROM allcode WHERE cdtype = 'SE' AND cdname = 'TRADEPLACE' AND cdval like PV_TRADEPLACE ;
ELSE
   v_strTRADEPLACE := '%%';
   vn_TRADEPLACE := 'ALL';
END IF;

IF PV_MARKETTYPE <> 'ALL'
THEN
    v_Markettype := PV_MARKETTYPE;
ELSE
    v_Markettype := '%%';
END IF;

    v_OnDate:= to_date(I_DATE,'DD/MM/RRRR');
-- Get Current date
select to_date(varvalue,'DD/MM/RRRR') into v_CurrDate from sysvar where varname = 'CURRDATE' and grname = 'SYSTEM';

if v_Symbol = 'ALL' or v_Symbol is null then
    v_Symbol := '%';
else
    v_Symbol := '%'||v_Symbol||'%';
end if;

if (upper(PV_AFTYPE) = 'ALL' or PV_AFTYPE is null) then
    V_STRaftype := '%';
else
    V_STRaftype := PV_AFTYPE;
end if;

if (upper(PV_SETYPR) = 'ALL' or PV_SETYPR is null) then
    V_SETYPR := '%';
else
    V_SETYPR := PV_SETYPR;
end if;



-- Main report
OPEN PV_REFCURSOR FOR
select v_OnDate currdate, sebal.symbol_g symbol, sebal.parvalue parvalue , sebal.loai_TK loai_TK,
    sum(case when instr(sebal.symbol,'_WFT') <> 0 then 0
        else trade - nvl(se_trade_move_amt,0) +
            mortage - nvl(se_MORTAGE_move_amt,0) +
            emkqtty - nvl(se_emkqtty_move_amt,0) +
            standing - nvl(se_standing_move_amt,0) +
            WITHDRAW -  nvl(se_WITHDRAW_move_amt,0) +
            DTOCLOSE - nvl(se_DTOCLOSE_move_amt,0) end
            ) end_trade_bal,
    sum(CASE WHEN instr(sebal.symbol,'_WFT') <> 0 then 0 else
         BLOCKED - nvl(se_BLOCKED_move_amt,0) +
         BLOCKWITHDRAW - nvl(se_BLOCKWITHDRAW_move_amt,0) +
         BLOCKDTOCLOSE - nvl(se_BLOCKDTOCLOSE_move_amt,0)
         end) end_blocked_bal,

    sum(CASE WHEN instr(sebal.symbol,'_WFT') <> 0 THEN 0 ELSE abs(nvl(sebal.STANDING,0)-
        nvl(se_STANDING_move_amt,0)) END) end_STANDING_bal,

    sum(CASE WHEN instr(sebal.symbol,'_WFT') = 0 THEN 0
            ELSE
         BLOCKED - nvl(se_BLOCKED_move_amt,0) +
         BLOCKWITHDRAW - nvl(se_BLOCKWITHDRAW_move_amt,0) +
         BLOCKDTOCLOSE - nvl(se_BLOCKDTOCLOSE_move_amt,0)
    END) hccn_chogiao,

    sum(CASE WHEN instr(sebal.symbol,'_WFT') <> 0 THEN
             (
            trade - nvl(se_trade_move_amt,0) +
            mortage - nvl(se_mortage_move_amt,0) +
            emkqtty - nvl(se_emkqtty_move_amt,0) +
            standing - nvl(se_standing_move_amt,0) +
            withdraw -  nvl(se_withdraw_move_amt,0) +
            dtoclose - nvl(se_dtoclose_move_amt,0) +
            blocked - nvl(se_blocked_move_amt,0) +
            blockwithdraw - nvl(se_blockwithdraw_move_amt,0) +
            blockdtoclose - nvl(se_blockdtoclose_move_amt,0)
       ) ELSE 0 END) ck_cho_gd,
    0 SL_CK_cho_rut,
    sum(case when instr(sebal.symbol,'_WFT') <> 0 then 0
        else nvl(khop_qtty.execqtty,0) end) execqtty
from
( -- Tong so du CK hien tai group by tieu khoan, Symbol
    select cf.custid, af.acctno afacctno, symbol, se.acctno, symbol_g,
        max(case when SUBSTR(cf.custodycd,4,1) = 'C' then 'MGTN'
            when SUBSTR(cf.custodycd,4,1) = 'F' then 'MGNN'
            when SUBSTR(cf.custodycd,4,1) = 'P' then 'TD'
            else '' end ) loai_TK,
        sum(trade + blocked + mortage + netting + receiving) se_balance,
        sum(trade) trade, sum(blocked) blocked, sum(mortage) mortage, sum(netting) netting,
        sum(STANDING) STANDING, sum(RECEIVING) RECEIVING, sum(WITHDRAW) WITHDRAW, sum(DTOCLOSE) DTOCLOSE,
        max(parvalue) parvalue, SUM(secured) secured,
        sum(emkqtty) emkqtty, sum(BLOCKWITHDRAW) BLOCKWITHDRAW, sum(BLOCKDTOCLOSE) BLOCKDTOCLOSE
    from (SELECT * FROM CFMAST WHERE FNC_VALIDATE_SCOPE(BRID, CAREBY, TLSCOPE, pv_BRID, TLGOUPS)=0) cf, afmast af, semast se, --sbsecurities sb
        (select sb.*, nvl(wtf.tradeplace,sb.tradeplace) wtf_tradeplace, fn_symbol_tradeplace( nvl(wtf.codeid,sb.codeid), i_date  ) tradeplacenew , nvl(wtf.symbol,sb.symbol) symbol_g
        from sbsecurities sb,sbsecurities wtf
            where sb.refcodeid = wtf.codeid(+)) sb
    where cf.custid = af.custid and af.acctno = se.afacctno
        and cf.custatcom = 'Y'
        and se.codeid = sb.codeid
        and sb.symbol like v_Symbol
        and nvl(sb.tradeplacenew,'-') like v_strTRADEPLACE
        AND nvl(sb.markettype,'-') LIKE v_Markettype
---        and af.brid like v_strIBRID
---        and af.acctno like v_AFAcctno
        and SUBSTR(cf.custodycd,4,1) like V_STRaftype
        and sb.sectype like V_SETYPR
        and sb.sectype <> '004'
        AND af.brid LIKE v_strIBRID
        AND (af.brid LIKE V_STRBRID or instr(V_STRBRID,af.brid) <> 0 )
    group by se.acctno, symbol, symbol_g, cf.custid, af.acctno
) sebal

left join
(select sum(blocked+ sblocked) WITHDRAW_HCCN,acctno
 from sesendout where deltd <>'Y' group by acctno
having sum(blocked+ sblocked) >0) WITHDRAW_HCCN
ON  sebal.acctno = WITHDRAW_HCCN.acctno

left join
(    -- Tong phat sinh field cac loai so du CK tu Txdate den ngay hom nay
    select tr.acctno,
        sum
        (
            case when field = 'TRADE' then case when tr.txtype = 'D' then -tr.namt else tr.namt end else 0 end
        ) se_trade_move_amt,            -- Phat sinh CK giao dich
        sum
        (
            case when field = 'MORTAGE' then case when tr.txtype = 'D' then -tr.namt else tr.namt end else 0 end
        ) se_MORTAGE_move_amt ,         -- Phat sinh CK Phong toa gom ca STANDING
        sum
        (
            case when field = 'EMKQTTY'
                then
                (case when tr.txtype = 'D' then -tr.namt else tr.namt end)
            else 0
            end
         ) se_EMKQTTY_move_amt,      -- Phat sinh CK tam giu
         sum
        (
            case when field = 'BLOCKED'
                then
                (case when tr.txtype = 'D' then -tr.namt else tr.namt end)
            else 0
            end
         ) se_BLOCKED_move_AMT,      -- Phat sinh CK tam giu

        sum
        ( case when field = 'NETTING' then
                (case when tr.txtype = 'D' then -tr.namt else tr.namt end)
            else 0
            end
        ) se_NETTING_move_amt ,         -- Phat sinh CK cho giao
        sum
        ( case when field = 'STANDING' then
                (case when tr.txtype = 'D' then -tr.namt else tr.namt end)
            else 0 end
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
        ( case when field = 'WITHDRAW'  then
                (case when tr.txtype = 'D'  then -tr.namt else tr.namt end)
            else 0
            end
        ) se_WITHDRAW_move_amt,         -- Phat sinh CK cho nhan ve
        sum
        ( case when field = 'DTOCLOSE' then
                (case when tr.txtype = 'D' then -tr.namt else tr.namt end)
            else 0
            end
        ) se_DTOCLOSE_move_amt,

       sum
        ( case when field = 'BLOCKWITHDRAW' THEN
                (case when tr.txtype = 'D' then -tr.namt else tr.namt end)
            else 0
            end
        ) se_BLOCKWITHDRAW_move_amt

        ,
        sum
        ( case when field = 'BLOCKDTOCLOSE' then
                (case when tr.txtype = 'D' then -tr.namt else tr.namt end)
            else 0
            end
        ) se_BLOCKDTOCLOSE_move_amt,
        sum
        ( case when field = 'SECURED' then
                (case when tr.txtype = 'D' then -tr.namt else tr.namt end)
            else 0
            end
        ) se_SECURED_move_amt
    from vw_setran_gen tr
    where tr.sectype <> '004'
        AND TR.deltd <> 'Y'
        and tr.busdate > v_OnDate and tr.busdate <= v_CurrDate
        and tr.field in ('EMKQTTY','TRADE','MORTAGE','BLOCKED','NETTING','STANDING','RECEIVING','WITHDRAW','DTOCLOSE','SECURED')
--                        ('TRADE','MORTAGE','BLOCKED','NETTING','WITHDRAW','SECURED','DTOCLOSE','WTRADE')
    group by tr.acctno
) se_field_move on sebal.acctno = se_field_move.acctno
left join
(--- so luong chung khoan ban cho giao
    select seacctno, sum(execqtty) execqtty
    from
    (
    select codeid, afacctno, seacctno, execqtty, txdate from odmast
    where execqtty > 0
        and exectype in ('MS','NS')
        and txdate <= v_OnDate
    union all
    select odhist.codeid, odhist.afacctno, seacctno, execqtty, odhist.txdate from odmasthist odhist, stschdhist  sthist
    where execqtty > 0
        and odhist.txdate <= v_OnDate
        and exectype in ('MS','NS')
        AND sthist.orgorderid = odhist.orderid
        AND sthist.duetype = 'RM'
        AND sthist.cleardate > v_OnDate
    )
    group by seacctno
) khop_qtty on sebal.acctno = khop_qtty.seacctno
left join   -- So du chung khoan han che chuyen nhuong
(
    select se.acctno, se.blocked curr_block_qtty, se.emkqtty curr_block_pt
    from semast se, sbsecurities sb
    where se.codeid = sb.codeid
        and sb.sectype <> '004'
        and sb.tradeplace <> '005'
) se_block on sebal.acctno = se_block.acctno
left join
(   -- Phat sinh ban chung khoan ngay hom nay
    SELECT SEACCTNO, SUM(case when v_OnDate = v_CurrDate then SECUREAMT else 0 end) trade_sell_qtty,
        SUM(case when v_OnDate = v_CurrDate then SECUREMTG else 0 end) mtg_sell_qtty,
        SUM(case when v_OnDate = v_CurrDate then RECEIVING else 0 end) SERECEIVING,
        SUM(case when v_OnDate = v_CurrDate then EXECQTTY else 0 end) khop_qtty
     FROM (
        SELECT OD.SEACCTNO,
               CASE WHEN OD.EXECTYPE IN ('NS', 'SS') THEN to_number(nvl(varvalue,0))* REMAINQTTY + EXECQTTY ELSE 0 END SECUREAMT,
               CASE WHEN OD.EXECTYPE = 'MS'  THEN to_number(nvl(varvalue,0)) * REMAINQTTY + EXECQTTY ELSE 0 END SECUREMTG,
               0 RECEIVING, CASE WHEN OD.EXECTYPE IN ('NS', 'SS') THEN OD.EXECQTTY ELSE 0 END EXECQTTY
           FROM ODMAST OD, ODTYPE TYP, SYSVAR SY
           WHERE OD.EXECTYPE IN ('NS', 'SS','MS')
               and sy.grname='SYSTEM' and sy.varname='HOSTATUS'
               And OD.ACTYPE = TYP.ACTYPE
               AND OD.TXDATE = v_CurrDate
               AND NVL(OD.GRPORDER,'N') <> 'Y'
        )
    GROUP BY SEACCTNO
) order_today on sebal.acctno = order_today.SEACCTNO
LEFT JOIN
(   -- SO LUONG CK LO LE CHO BAN'
    /*SELECT TR.acctno, SUM(case when tr.txtype = 'D' then -tr.namt else tr.namt end) se_RETAIL_move_amt
    FROM vw_setran_gen TR
    WHERE TR.TLTXCD IN ('8878','8879') AND TR.field = 'NETTING'
        AND TR.busdate > v_OnDate
    GROUP BY TR.ACCTNO*/
    SELECT TR.acctno, SUM(tr.qtty) se_RETAIL_move_amt
    FROM seretail TR
    WHERE tr.txdate <= v_OnDate
        AND nvl(tr.sdate,getcurrdate+1) >  v_OnDate
        --AND tr.status NOT IN ('C','I')
        AND tr.txdate <> nvl(tr.sdate,getcurrdate+1)
    GROUP BY TR.ACCTNO
) SR_QTTY ON SEBAL.ACCTNO = SR_QTTY.ACCTNO
group by sebal.symbol_g, sebal.loai_TK, sebal.parvalue;

EXCEPTION
  WHEN OTHERS
   THEN
        dbms_output.put_line('12233');
    RETURN;
END;

 
 
 
 
/
