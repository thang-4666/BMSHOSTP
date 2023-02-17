SET DEFINE OFF;
CREATE OR REPLACE PROCEDURE "CF0036" (
   PV_REFCURSOR           IN OUT   PKG_REPORT.REF_CURSOR,
   OPT            IN       VARCHAR2,
   pv_BRID           IN       VARCHAR2,
   TLGOUPS        IN       VARCHAR2,
   TLSCOPE        IN       VARCHAR2,
   F_DATE         IN       VARCHAR2,
   T_DATE         IN       VARCHAR2,
   I_DATE         IN       VARCHAR2,
   I_BRID         IN       VARCHAR2,
   PV_CUSTODYCD   IN       VARCHAR2
  )
IS
--
-- RP NAME :DANH SACH KHACH HANG TAT TOAN TAI KHOAN THEP TVLK  (19A/LK)
-- PERSON : QUYET.KIEU
-- DATE :   09/05/2011
-- COMMENTS : CREATE NEWs
-- ---------   ------  -------------------------------------------



   CUR            PKG_REPORT.REF_CURSOR;
   V_STROPTION    VARCHAR2 (5);                   --  A: ALL; B: BRANCH; S: SUB-BRANCH
   V_STRBRID      VARCHAR2 (4);                      --  USED WHEN V_NUMOPTION > 0
   v_OnDate   date;
   v_CurrDate date;
   v_CustodyCD varchar2(20);
   v_AFAcctno varchar2(20);
   v_TRADEPLACE varchar2(20);
   v_Symbol varchar2(20);


BEGIN

V_STROPTION := upper(OPT);

IF  (I_BRID <> 'ALL') THEN
   V_STRBRID :=I_BRID ;
ELSE
   V_STRBRID := '%';
END IF;

IF  (PV_CUSTODYCD <> 'ALL')
THEN
      v_CustodyCD := replace(upper(PV_CUSTODYCD),' ','_');
ELSE
      v_CustodyCD := '%';
END IF;

v_OnDate:= to_date(I_DATE,'DD/MM/RRRR');
-- Get Current date
select to_date(varvalue,'DD/MM/RRRR') into v_CurrDate from sysvar where varname = 'CURRDATE' and grname = 'SYSTEM';


-- Main report
OPEN PV_REFCURSOR FOR
Select
v_OnDate On_Date,
CF.custodycd,
CF.fullname,
CF.idcode,
CF.iddate,
SE.SYM_ORG,

 sum(ckgd_tdcn) ckgd_tdcn,
 sum(ckgd_hccn) ckgd_hccn,
 sum(CKCGD_TDCN) CKCGD_TDCN ,
 sum(CKCGD_HCCN )CKCGD_HCCN
 from
(

  select afacctno, SYM_ORG,
    sum(ckgd_tdcn) ckgd_tdcn, sum(ckgd_hccn) ckgd_hccn,
    sum(CKCGD_TDCN) CKCGD_TDCN , sum(CKCGD_HCCN )CKCGD_HCCN
    FROM
    (
-- CHUNG KHOAN GIAO DICH
SELECT * FROM
(
SELECT
sebal.afacctno,
sebal.symbol SYM_ORG,
sebal.symbol,
nvl(trade,0) - nvl(se_trade_move_amt,0) - nvl(trade_sell_qtty,0) as  CKGD_TDCN,
nvl(se_block.curr_block_qtty,0) -
nvl(se_block_move.cr_block_amt,0) + nvl(se_block_move.dr_block_amt,0) as CKGD_HCCN,  -- Han che chuyen nhuong
0 CKCGD_TDCN ,
0 CKCGD_HCCN FROM
(
    -- Tong so du CK hien tai group by tieu khoan, Symbol
    select cf.custid, se.afacctno, sb.symbol, se.acctno seacctno,
        sum(trade + blocked + mortage + netting + receiving) se_balance,
        sum(trade) trade, sum(blocked) blocked, sum(mortage) mortage, sum(netting) netting,
        sum(STANDING) STANDING, sum(RECEIVING) RECEIVING, sum(WITHDRAW) WITHDRAW
    from (SELECT * FROM CFMAST WHERE FNC_VALIDATE_SCOPE(BRID, CAREBY, TLSCOPE, I_BRID, TLGOUPS)=0) cf, afmast af, semast se, sbsecurities sb
    where cf.custid = af.custid and af.acctno = se.afacctno
        and se.codeid = sb.codeid
        and cf.custodycd like '%' -- v_CustodyCD
        and sb.sectype <>'004'
        and sb.symbol  not like '%_WFT%'--Chung khoan giao dich
    group by  cf.custid, se.afacctno, sb.symbol, se.acctno
)  sebal
left join
(   -- Phat sinh ban chung khoan ngay hom nay
    select se.afacctno, symbol, se.acctno seacctno,
        case when v_OnDate = v_CurrDate then SUM(SECUREAMT) else 0 end trade_sell_qtty,
        case when v_OnDate = v_CurrDate then SUM(SECUREMTG) else 0 end mtg_sell_qtty
    from semast se, v_getsellorderinfo v, sbsecurities sb
    where
        se.acctno = v.seacctno
        and se.codeid = sb.codeid
        and sb.symbol  not like '%_WFT%'
        group by se.afacctno, symbol, se.acctno
) order_today on sebal.seacctno = order_today.seacctno

left join
(   -- Phat sinh mua chung khoan ngay hom nay
    select se.afacctno, symbol, se.acctno seacctno,
        case when v_OnDate = v_CurrDate then SUM(qtty) else 0 end receiving_qtty
    from cfmast cf, afmast af, semast se, sbsecurities sb, stschd  st
    where cf.custid = af.custid and af.acctno = se.afacctno
        and se.codeid = sb.codeid
        and se.acctno = st.acctno and st.duetype = 'RS' and st.status = 'N'
        and st.txdate = v_CurrDate
        and sb.symbol  not like '%_WFT%'
    group by se.afacctno, symbol, se.acctno
) order_buy_today on sebal.seacctno = order_buy_today.seacctno

left join
(
    -- Tong phat sinh field cac loai so du CK tu Ondate den ngay hom nay
    select tr.afacctno, tr.symbol, tr.acctno seacctno,
        sum
        (case when field = 'TRADE' then
                case when tr.txtype = 'D' then -tr.namt else tr.namt end
            else 0
            end
        ) se_trade_move_amt -- Phat sinh CK giao dich
    from vw_setran_gen tr
    where
        tr.busdate > v_OnDate
        and tr.busdate <= v_CurrDate
        and tr.field in ('TRADE','MORTAGE','BLOCKED','NETTING','STANDING','RECEIVING','WITHDRAW')
    group by tr.afacctno, tr.symbol, tr.acctno
) se_field_move on sebal.seacctno = se_field_move.seacctno

left join   -- So du chung khoan chuyen nhuong co dieu kien
(
    select se.afacctno, sb.symbol, se.acctno seacctno,
        sum(se.blocked) curr_block_qtty
    from semast se, afmast af, sbsecurities sb
    where se.afacctno = af.acctno
        and se.codeid = sb.codeid
       -- and qttytype = '002'
        and sb.symbol  not like '%_WFT%'
       group by se.afacctno, sb.symbol, se.acctno
) se_block on sebal.seacctno = se_block.seacctno

left join   -- Phat sinh giao dich phong toa/giai toa CK chuyen nhuong co dieu kien
(
    select tr.afacctno, tr.symbol, tr.acctno seacctno,
        sum(case when tr.tltxcd = '2202' then namt else 0 end) cr_block_amt,
        sum(case when tr.tltxcd = '2203' then namt else 0 end) dr_block_amt
    from vw_setran_gen tr
    where tr.field = 'BLOCKED'

        and tr.busdate > v_OnDate
        and tr.busdate <=v_CurrDate
        and tr.tltxcd in ('2202','2203')
     --   and tr.ref = '002'
        and tr.namt <> 0
    group by tr.afacctno, tr.symbol, tr.acctno
) se_block_move on sebal.seacctno = se_block_move.seacctno

where
    (
    abs(nvl(trade,0) - nvl(se_trade_move_amt,0) )
    + abs(nvl(blocked,0))
    + abs(nvl(mortage,0))
    + abs( nvl(netting,0))
    + abs(-nvl(STANDING,0))
    + abs(nvl(RECEIVING,0)  )
    + abs(nvl(WITHDRAW,0)  )
    + abs(se_balance)
    ) > 0

    and (
    (nvl(trade,0) - nvl(se_trade_move_amt,0) - nvl(trade_sell_qtty,0) > 0) or
(nvl(se_block.curr_block_qtty,0) -nvl(se_block_move.cr_block_amt,0) + nvl(se_block_move.dr_block_amt,0))<>0
    )
order by symbol,sebal.afacctno
)CKGD

UNION ALL

-- CHUNG KHOAN CHO GIAO DICH
SELECT * FROM
(
SELECT
sebal.afacctno,
substr(sebal.SYMBOL,0,length(sebal.SYMBOL)-4) sym_org,
sebal.symbol,
0 CKGD_TDCN ,
0 CKGD_HCCN,
nvl(trade,0) - nvl(se_trade_move_amt,0) - nvl(trade_sell_qtty,0) as  CKCGD_TDCN,
nvl(se_block.curr_block_qtty,0) -
nvl(se_block_move.cr_block_amt,0) + nvl(se_block_move.dr_block_amt,0) as CKCGD_HCCN  -- Han che chuyen nhuong
 FROM
(
    -- Tong so du CK hien tai group by tieu khoan, Symbol
    select cf.custid, se.afacctno, sb.symbol, se.acctno seacctno,
        sum(trade + blocked + mortage + netting + receiving) se_balance,
        sum(trade) trade, sum(blocked) blocked, sum(mortage) mortage, sum(netting) netting,
        sum(STANDING) STANDING, sum(RECEIVING) RECEIVING, sum(WITHDRAW) WITHDRAW
    from cfmast cf, afmast af, semast se, sbsecurities sb
    where cf.custid = af.custid and af.acctno = se.afacctno
        and se.codeid = sb.codeid
        and sb.sectype <>'004'
        and sb.symbol like '%_WFT%'--v_Symbol
        group by  cf.custid, se.afacctno, sb.symbol, se.acctno
)  sebal
left join
(   -- Phat sinh ban chung khoan ngay hom nay
    select se.afacctno, symbol, se.acctno seacctno,
        case when v_OnDate = v_CurrDate then SUM(SECUREAMT) else 0 end trade_sell_qtty,
        case when v_OnDate = v_CurrDate then SUM(SECUREMTG) else 0 end mtg_sell_qtty
    from semast se, v_getsellorderinfo v, sbsecurities sb
    where
        se.acctno = v.seacctno
        and se.codeid = sb.codeid
          and sb.symbol like '%_WFT%'--v_Symbol

    group by se.afacctno, symbol, se.acctno
) order_today on sebal.seacctno = order_today.seacctno

left join
(   -- Phat sinh mua chung khoan ngay hom nay
    select se.afacctno, symbol, se.acctno seacctno,
        case when v_OnDate = v_CurrDate then SUM(qtty) else 0 end receiving_qtty
    from cfmast cf, afmast af, semast se, sbsecurities sb, stschd  st
    where cf.custid = af.custid and af.acctno = se.afacctno
        and se.codeid = sb.codeid
        and se.acctno = st.acctno and st.duetype = 'RS' and st.status = 'N'
        and st.txdate = v_CurrDate
          and sb.symbol like '%_WFT%'--v_Symbol
    group by se.afacctno, symbol, se.acctno
) order_buy_today on sebal.seacctno = order_buy_today.seacctno

left join
(
    -- Tong phat sinh field cac loai so du CK tu Ondate den ngay hom nay
    select tr.afacctno, tr.symbol, tr.acctno seacctno,
        sum
        (case when field = 'TRADE' then
                case when tr.txtype = 'D' then -tr.namt else tr.namt end
            else 0
            end
        ) se_trade_move_amt -- Phat sinh CK giao dich

    from vw_setran_gen tr
    where
        tr.busdate > v_OnDate
        and tr.busdate <= v_CurrDate
         and tr.field in ('TRADE','MORTAGE','BLOCKED','NETTING','STANDING','RECEIVING','WITHDRAW')
    group by tr.afacctno, tr.symbol, tr.acctno
) se_field_move on sebal.seacctno = se_field_move.seacctno

left join   -- So du chung khoan chuyen nhuong co dieu kien
(
    select se.afacctno, sb.symbol, se.acctno seacctno,
        sum(se.blocked) curr_block_qtty
    from semast se, afmast af, sbsecurities sb
    where se.afacctno = af.acctno
        and se.codeid = sb.codeid
     --   and qttytype = '002'
         and sb.symbol like '%_WFT%'--v_Symbol
    group by se.afacctno, sb.symbol, se.acctno
) se_block on sebal.seacctno = se_block.seacctno

left join   -- Phat sinh giao dich phong toa/giai toa CK chuyen nhuong co dieu kien
(
    select tr.afacctno, tr.symbol, tr.acctno seacctno,
        sum(case when tr.tltxcd = '2202' then namt else 0 end) cr_block_amt,
        sum(case when tr.tltxcd = '2203' then namt else 0 end) dr_block_amt
    from vw_setran_gen tr
    where tr.field = 'BLOCKED'
        and tr.afacctno like '%' --v_AFAcctno
        and tr.symbol like '%' --v_Symbol
        and tr.busdate >= v_OnDate
        and tr.busdate <= v_CurrDate
        and tr.tltxcd in ('2202','2203')
        --and tr.ref = '002'
       and tr.namt <> 0
    group by tr.afacctno, tr.symbol, tr.acctno
) se_block_move on sebal.seacctno = se_block_move.seacctno

where
    (
    abs(nvl(trade,0) - nvl(se_trade_move_amt,0) )
    + abs(nvl(blocked,0))
    + abs(nvl(mortage,0))
    + abs( nvl(netting,0))
    + abs(-nvl(STANDING,0))
    + abs(nvl(RECEIVING,0)  )
    + abs(nvl(WITHDRAW,0)  )
    + abs(se_balance)
    ) > 0

     and (
    (nvl(trade,0) - nvl(se_trade_move_amt,0) - nvl(trade_sell_qtty,0) > 0) or
   (nvl(se_block.curr_block_qtty,0) -nvl(se_block_move.cr_block_amt,0) + nvl(se_block_move.dr_block_amt,0))<>0
    )
order by symbol,sebal.afacctno
)CKCGD

)
GROUP BY   afacctno, SYM_ORG
)SE,

AFMAST AF,
(
--Danh sach lam giao dich 0088 tai ngay On date
Select msgacct afacctno from tllog where tltxcd='0088' and txdate=v_OnDate
union all
Select msgacct afacctno from tllogall  where tltxcd='0088' and txdate=v_OnDate
)GDTT,
CFMAST cf
where SE.afacctno= AF.acctno
AND af.acctno =GDTT.afacctno
And AF.custid=CF.Custid
AND SUBSTR(cf.custid,1,4) LIKE  V_STRBRID
and CF.custodycd like v_Custodycd
and CF.custodycd NOT in
(
-- Kiem tra so lk phai co it nhat 1 tieu khoan dang hoat dong
Select cf.custodycd  from
cfmast cf , afmast af
where cf.custid = af.custid and  af.status = 'A'
)
GROUP BY
CF.custodycd, -- Tinh tong cac chung khoan theo so luu ky
CF.fullname,
CF.idcode,
CF.iddate,
SE.SYM_ORG
order by
CF.custodycd,
SE.SYM_ORG
;
EXCEPTION
  WHEN OTHERS
   THEN
      RETURN;
END;

 
 
 
 
/
