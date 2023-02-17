SET DEFINE OFF;
CREATE OR REPLACE PROCEDURE "CF1001" (
   PV_REFCURSOR           IN OUT   PKG_REPORT.REF_CURSOR,
   OPT            IN       VARCHAR2,
   PV_BRID           IN       VARCHAR2,
   TLGOUPS        IN       VARCHAR2,
   TLSCOPE        IN       VARCHAR2,
   SEARCHDATE         IN       VARCHAR2,
   ---T_DATE         IN       VARCHAR2,
   PV_CUSTODYCD       IN       VARCHAR2,
   PV_AFACCTNO       IN       VARCHAR2,
   SYMBOL            IN       VARCHAR2,
   TLID             IN VARCHAR2
  )
IS
--

-- BAO CAO So du chung khoan
-- MODIFICATION HISTORY
-- PERSON       DATE                COMMENTS
-- ---------   ------  -------------------------------------------
-- TUNH        13-05-2010           CREATED
-- Chaunh      10-02-2012           gop ck cho giao dich
   CUR            PKG_REPORT.REF_CURSOR;
   V_STROPTION    VARCHAR2 (5);            -- A: ALL; B: BRANCH; S: SUB-BRANCH
   V_STRBRID      VARCHAR2 (4);                   -- USED WHEN V_NUMOPTION > 0

   v_TxDate date;
   v_CustodyCD varchar2(20);
   v_AFAcctno varchar2(20);
   v_CurrDate date;
   v_CareBy varchar2(100);
   v_GroupID varchar2(100);
   v_SYMBOL varchar2(100);
   v_TLID varchar2(4);

BEGIN

V_STROPTION := OPT;
IF V_STROPTION = 'A' then
    V_STRBRID := '%';
ELSIF V_STROPTION = 'B' then
    V_STRBRID := substr(PV_BRID,1,2) || '__' ;
else
    V_STRBRID:=PV_BRID;
END IF;



select to_date(varvalue,'DD/MM/RRRR') into v_CurrDate from sysvar where varname = 'CURRDATE' and grname = 'SYSTEM';

v_TLID := trim(tlid);
v_TxDate:= to_date(SEARCHDATE,'DD/MM/RRRR');
v_CustodyCD:= upper(replace(pv_custodycd,'.',''));
v_AFAcctno:= upper(replace(PV_AFACCTNO,'.',''));

-- select careby into v_CareBy from  (SELECT * FROM CFMAST WHERE FNC_VALIDATE_SCOPE(BRID, CAREBY, TLSCOPE, pv_BRID, TLGOUPS)=0) where custodycd = v_CustodyCD;
-- select max(gu.grpid) into v_GroupID from tlgrpusers gu where gu.tlid = TLID and grpid = v_CareBy ;

if v_AFAcctno = 'ALL' or v_AFAcctno is null then
    v_AFAcctno := '%';
else
    v_AFAcctno := v_AFAcctno;
end if;

if SYMBOL = 'ALL' then
    v_SYMBOL := '%';
else
    v_SYMBOL := SYMBOL;
end if;


--(CASE WHEN v_AFAcctno = 'ALL' THEN 'ALL' ELSE afacctno END)
-- Main report
OPEN PV_REFCURSOR FOR
SELECT v_CurrDate CurrDate, v_TxDate txdate, (CASE WHEN v_AFAcctno = '%' THEN 'ALL' ELSE afacctno END) custid,
        fullname, idcode, iddate, idplace, address, mobile, custodycd,  afacctno, symbol,BONDNAME,
        sum(se_balance) se_balance, sum(trade) trade, sum(end_trade_bal) end_trade_bal, sum(blocked) blocked,
        sum(end_blocked_bal) end_blocked_bal,
        sum(mortage) mortage,
        sum(end_mortage_bal) end_mortage_bal,
         sum(netting) netting, sum(end_netting_bal) end_netting_bal, sum(standing) standing,
       sum(end_STANDING_bal) end_STANDING_bal,
       sum(receiving) receiving,sum(end_RECEIVING_bal) end_RECEIVING_bal,sum(CA_RECEIVING) CA_RECEIVING,
       sum(WITHDRAW) WITHDRAW,sum(end_WITHDRAW_bal) end_WITHDRAW_bal,
       sum(ck_cho_gd) ck_cho_gd
FROM
(select cf.custid, cf.fullname, cf.idcode, cf.iddate, cf.idplace, cf.address, cf.mobile, cf.custodycd,
    sebal.afacctno,SEBAL.bondname, CASE WHEN instr(sebal.symbol,'_WFT') <> 0 THEN substr(sebal.symbol,1, instr(sebal.symbol,'_WFT')-1) ELSE sebal.symbol END symbol,
    CASE WHEN instr(sebal.symbol,'_WFT')<> 0 THEN 0 ELSE nvl(se_balance,0) END se_balance,
    CASE WHEN instr(sebal.symbol,'_WFT')<> 0 THEN 0 ELSE nvl(trade,0) END trade,
    CASE WHEN instr(sebal.symbol,'_WFT')<> 0 THEN 0 ELSE nvl(trade,0) - nvl(se_trade_move_amt,0) - nvl(trade_sell_qtty,0) END  end_trade_bal,
    CASE WHEN instr(sebal.symbol,'_WFT')<> 0 THEN 0 ELSE nvl(blocked,0) END blocked,
    CASE WHEN instr(sebal.symbol,'_WFT') <> 0 then 0 else
        nvl(se_block.curr_block_qtty,0) - nvl(se_BLOCKED_move_HCCN,0) end  end_blocked_bal,
    CASE WHEN instr(sebal.symbol,'_WFT')<> 0 THEN 0 ELSE nvl(mortage,0) END mortage,
     CASE WHEN instr(sebal.symbol,'_WFT') <> 0 then 0 else
        nvl(se_block.curr_block_pt,0) - nvl(se_BLOCKED_move_pt,0) end  end_mortage_bal,


    CASE WHEN instr(sebal.symbol,'_WFT')<> 0 THEN 0 ELSE nvl(netting,0) END netting,
    CASE WHEN instr(sebal.symbol,'_WFT')<> 0 THEN 0 ELSE nvl(netting,0) - nvl(se_netting_move_amt,0) + nvl(trade_sell_qtty,0) + nvl(mtg_sell_qtty,0) END  end_netting_bal,
    CASE WHEN instr(sebal.symbol,'_WFT')<> 0 THEN 0 ELSE nvl(STANDING,0) END  standing,
    CASE WHEN instr(sebal.symbol,'_WFT')<> 0 THEN 0 ELSE (mortage - nvl(mtg_sell_qtty,0) - nvl(se_MORTAGE_move_amt,0)) END  end_STANDING_bal, ---- hoangnd sua cam co gom DF va VSD
    CASE WHEN instr(sebal.symbol,'_WFT')<> 0 THEN 0 ELSE nvl(RECEIVING,0) END receiving,
    CASE WHEN instr(sebal.symbol,'_WFT')<> 0 THEN 0 ELSE (nvl(RECEIVING,0) - nvl(se_RECEIVING_move_amt,0) +
        nvl(order_buy_today.receiving_qtty,0)) END  end_RECEIVING_bal,------ hoangnd them mua cho ve
    CASE WHEN instr(sebal.symbol,'_WFT')<> 0 THEN 0 ELSE nvl(CA_RECEIVING,0) END CA_RECEIVING,
    CASE WHEN instr(sebal.symbol,'_WFT')<> 0 THEN 0 ELSE nvl(WITHDRAW,0) END  WITHDRAW,
    --CASE WHEN instr(sebal.symbol,'_WFT')<> 0 THEN 0 ELSE nvl(WITHDRAW,0) - nvl(se_WITHDRAW_move_amt,0) END  end_WITHDRAW_bal,

    (CASE WHEN instr(sebal.symbol,'_WFT')<> 0 THEN 0 ELSE nvl(WITHDRAW,0)  -
        nvl(se_WITHDRAW_move_amt,0)  +
        (nvl(sebal.blocked,0) - nvl(se_block.curr_block_pt,0) - nvl(se_block.curr_block_qtty,0) -
            nvl(se_BLOCKED_move_amt,0))
        END) + nvl(DTOCLOSE,0) - nvl(se_DTOCLOSE_move_amt,0)  end_WITHDRAW_bal,

    CASE WHEN instr(sebal.symbol,'_WFT')<> 0 THEN (
    nvl(trade,0) - nvl(se_trade_move_amt,0) - nvl(trade_sell_qtty,0) +
    (
        nvl(mortage,0) + nvl(STANDING,0)
        - nvl(mtg_sell_qtty,0)
        - nvl(se_mortage_move_amt,0)
        - nvl(se_STANDING_move_amt,0)
        + (
            nvl(blocked,0) - nvl(se_blocked_move_amt,0)
            - (nvl(se_block.curr_block_qtty,0) - nvl(se_block_move.cr_block_amt,0) + nvl(se_block_move.dr_block_amt,0) )
          )     -- ck bi phong toa khac
     ) +
     nvl(se_block.curr_block_qtty,0) - nvl(se_block_move.cr_block_amt,0) + nvl(se_block_move.dr_block_amt,0) +
     nvl(netting,0) - nvl(se_netting_move_amt,0) + nvl(trade_sell_qtty,0) + nvl(mtg_sell_qtty,0)
     -(  nvl(STANDING,0) - nvl(se_STANDING_move_amt,0) ) +
     --nvl(RECEIVING,0) - nvl(se_RECEIVING_move_amt,0) +
      nvl(WITHDRAW,0) - nvl(se_WITHDRAW_move_amt,0)
    ) ELSE 0 END ck_cho_gd                                            --- hoangnd loai bo quyen cho ve
from   (SELECT * FROM CFMAST WHERE FNC_VALIDATE_SCOPE(BRID, CAREBY, TLSCOPE, pv_BRID, TLGOUPS)=0)   cf,afmast af ----dien them table afmast ---2-10-2010
left join
(
    -- Tong so du CK hien tai group by tieu khoan, Symbol
    select cf.custid, af.acctno afacctno, symbol, se.acctno, NVL(a3.CDCONTENT,'') bondname,
        sum(trade + blocked + mortage + netting + receiving) se_balance,
        sum(trade) trade, sum(blocked) blocked, sum(mortage) mortage, sum(netting) netting,
        sum(STANDING) STANDING, sum(RECEIVING) RECEIVING, sum(WITHDRAW) WITHDRAW,sum(DTOCLOSE) DTOCLOSE
    from  CFMAST cf,
    afmast af, semast se, sbsecurities sb, (SELECT * FROM  allcode WHERE CDNAME = 'BONDTYPE' AND CDUSER='Y') a3
    where cf.custid = af.custid and af.acctno = se.afacctno
        and sb.bondtype = a3.cdval(+)
        and se.codeid = sb.codeid and cf.custodycd = v_CustodyCD
        and af.acctno like v_AFAcctno
        and sb.sectype <>'004'
    group by  cf.custid, af.acctno, symbol,se.acctno, a3.CDCONTENT
) sebal on af.acctno = sebal.afacctno -------cf.custid=sebal.custid ---dien sua 2-10-2010

left join
(   -- Phat sinh ban chung khoan ngay hom nay
    select se.acctno,
        case when v_CurrDate = v_TxDate then SUM(SECUREAMT) else 0 end trade_sell_qtty,
        case when v_CurrDate = v_TxDate then SUM(SECUREMTG) else 0 end mtg_sell_qtty
    from  CFMAST cf, afmast af, semast se, v_getsellorderinfo v, sbsecurities sb
    where cf.custid = af.custid and af.acctno = se.afacctno
        and se.acctno = v.seacctno
        and se.codeid = sb.codeid
        and sb.sectype <>'004'
        and cf.custodycd = v_CustodyCD
        and af.acctno like v_AFAcctno
    group by se.acctno
) order_today on sebal.acctno = order_today.acctno

left join
(   -- Phat sinh mua chung khoan ngay hom nay
    select se.acctno,
        case when v_CurrDate = v_TxDate then SUM(qtty) else 0 end receiving_qtty
    from  CFMAST cf, afmast af, semast se, sbsecurities sb, stschd  st
    where cf.custid = af.custid and af.acctno = se.afacctno
        and se.codeid = sb.codeid
         and sb.sectype <> '004'
         and st.deltd <> 'Y'
        and se.acctno = st.acctno and st.duetype = 'RS' and st.status = 'N'
        and cf.custodycd = v_CustodyCD
        and af.acctno like v_AFAcctno
        and st.txdate = v_CurrDate
    group by se.acctno
) order_buy_today on sebal.acctno = order_buy_today.acctno

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
        (case when field = 'BLOCKED' and nvl(tr.ref,' ') <> '002' and nvl(tr.ref,' ') <> '007'  then
                (case when tr.txtype = 'D' then -tr.namt else tr.namt end)
            else 0
            end
         ) se_BLOCKED_move_amt   ,      -- Phat sinh CK tam giu
       sum
        (
            case when field = 'BLOCKED'
                then
                (case when tr.txtype = 'D' then -tr.namt else tr.namt end)
            else 0 end
         ) se_BLOCKED_move_HCCN,      -- Phat sinh CK HCCN

          sum
        (
            case when field = 'EMKQTTY'
                then
                (case when tr.txtype = 'D' then -tr.namt else tr.namt end)
            else 0 end
         ) se_BLOCKED_move_pt,      -- Phat sinh CK tam giu

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
        ( case when field = 'DTOCLOSE' then
                (case when tr.txtype = 'D' then -tr.namt else tr.namt end)
            else 0
            end
        ) se_DTOCLOSE_move_amt,
        sum
        ( case when field = 'WITHDRAW' then
                (case when tr.txtype = 'D' then -tr.namt else tr.namt end)
            else 0
            end
        ) se_WITHDRAW_move_amt         -- Phat sinh CK cho nhan ve

    from vw_setran_gen tr
    where tr.busdate > v_TxDate and tr.busdate <= v_CurrDate
        and tr.custodycd = v_CustodyCD
        and tr.afacctno like v_AFAcctno
        and tr.sectype <>'004'
        and tr.field in ('EMKQTTY','TRADE','MORTAGE','BLOCKED','NETTING','STANDING','RECEIVING','WITHDRAW','DTOCLOSE')
    group by tr.acctno
) se_field_move on sebal.acctno = se_field_move.acctno

left join   -- So du chung khoan chuyen nhuong co dieu kien
(
   select se.acctno, se.BLOCKED curr_block_qtty,
    se.EMKQTTY curr_block_pt
    from semast se, afmast af, sbsecurities sb,  CFMAST cf
    where se.afacctno = af.acctno
        and cf.custid = af.custid
        and se.codeid = sb.codeid
        and sb.sectype <> '004'
        and cf.custodycd = v_CustodyCD
        and se.afacctno like v_AFAcctno
) se_block on sebal.acctno = se_block.acctno

left join   -- Phat sinh giao dich phong toa/giai toa CK chuyen nhuong co dieu kien
(
    select tr.acctno,
        sum(case when tr.tltxcd = '2202' then namt else 0 end) cr_block_amt,
        sum(case when tr.tltxcd = '2203' then namt else 0 end) dr_block_amt
    from vw_setran_gen tr
    where tr.field = 'BLOCKED'
        and tr.afacctno like v_AFAcctno
        and tr.custodycd = v_CustodyCD
        and tr.tltxcd in ('2202','2203') and tr.namt <> 0
        and tr.busdate > v_TxDate and tr.busdate <= v_CurrDate
    group by tr.acctno
) se_block_move on sebal.acctno = se_block_move.acctno

where cf.custodycd = v_CustodyCD
      AND CF.CUSTID=AF.CUSTID
     -----------select gu.grpid from tlgrpusers gu where gu.grpid=cf.careby and gu.tlid = tlid---- dien sua 2-10-2010
    --and exists (select gu.grpid from tlgrpusers gu where af.careby=gu.grpid   and gu.tlid like v_TLID)   -- check careby
    AND v_TxDate <= v_CurrDate
    and
    (
    abs(nvl(trade,0) - nvl(se_trade_move_amt,0) )
    + abs(nvl(blocked,0) - nvl(se_blocked_move_amt,0) )
    + abs(nvl(mortage,0) - nvl(se_mortage_move_amt,0) )
    + abs( nvl(netting,0) - nvl(se_netting_move_amt,0))
    + abs(-(  nvl(STANDING,0) - nvl(se_STANDING_move_amt,0) ))
    + abs(nvl(RECEIVING,0) - nvl(se_RECEIVING_move_amt,0) )
    + abs(nvl(WITHDRAW,0) - nvl(se_WITHDRAW_move_amt,0) )
    + abs(se_balance)
   + abs(nvl(DTOCLOSE,0)) - nvl(se_DTOCLOSE_move_amt,0)

    ) <> 0

order by sebal.symbol, sebal.afacctno)
where symbol like v_SYMBOL
GROUP BY v_TxDate,custid, fullname, idcode, iddate, idplace, address, mobile, custodycd, afacctno, symbol,BONDNAME;

EXCEPTION
  WHEN OTHERS
   THEN
      RETURN;
END;

 
 
 
 
/
