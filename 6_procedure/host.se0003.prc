SET DEFINE OFF;
CREATE OR REPLACE PROCEDURE se0003 (
   PV_REFCURSOR   IN OUT   PKG_REPORT.REF_CURSOR,
   OPT            IN       VARCHAR2,
   pv_BRID           IN       VARCHAR2,
   TLGOUPS        IN       VARCHAR2,
   TLSCOPE        IN       VARCHAR2,
   I_DATE         IN       VARCHAR2,
   PV_SYMBOL       IN       VARCHAR2
)
IS
--Bao cao tong hop so du ck lo le
--created by chaunh at 11/02/2012

   V_STROPTION     VARCHAR2 (5);            -- A: ALL; B: BRANCH; S: SUB-BRANCH
   V_SYMBOL        varchar2 (20);
   V_DATE          date;
   V_CURRDATE      date;
   V_INBRID        VARCHAR2(4);
   V_STRBRID      VARCHAR2 (50);

BEGIN
   V_STROPTION := upper(OPT);
   V_INBRID := pv_BRID;
    if(V_STROPTION = 'A') then
        V_STRBRID := '%%';
    else
        if(V_STROPTION = 'B') then
            select br.mapid into V_STRBRID from brgrp br where  br.brid = V_INBRID;
        else
            V_STRBRID := V_INBRID;
        end if;
    end if;

   If (PV_SYMBOL = 'ALL')
   then
        V_SYMBOL := '%';
   else
        V_SYMBOL := replace(PV_SYMBOL,' ', '_');
   end if;
    select to_date(varvalue,'DD/MM/RRRR') into V_CURRDATE from sysvar where varname = 'CURRDATE';
    V_DATE := to_date(I_DATE,'DD/MM/RRRR');


OPEN PV_REFCURSOR FOR
select case when sb.tradeplace = '001' then 'HOSE'
            when sb.tradeplace = '002' then 'HNX'
            else 'UPCOM' end san, main.symbol, to_date(V_DATE,'DD/MM/RRRR') busdate,
        sum(case when sb.tradeplace = '001' and main.amt >= 10 and REMAINDER(amt,10) < 0 then REMAINDER(amt,10) + 10
              when sb.tradeplace = '001' and main.amt >= 10 and REMAINDER(amt,10) > 0 then REMAINDER(amt,10)
             when sb.tradeplace = '001' and main.amt < 10 then amt
             when sb.tradeplace <> '001' and main.amt >= 100 and REMAINDER(amt,100) < 0 then remainder(amt,100) + 100
             when sb.tradeplace <> '001' and main.amt >= 100 and REMAINDER(amt,100) > 0 then remainder(amt,100)
             when sb.tradeplace <> '001' and main.amt < 100 then amt
             end ) SL
from sbsecurities sb,
    (select trade_today.custodycd, trade_today.codeid, trade_today.symbol, sum(trade_today.amt  - nvl(trade_sell_today.amt,0) - nvl(trade_mov.amt,0)) amt
            from
----SL ck tu do giao dich hien tai
            (select se.acctno , nvl(sb.refcodeid, sb.codeid) codeid, sb.symbol,se.afacctno, cf.custodycd,  sum(trade) amt
                from (SELECT * FROM CFMAST WHERE FNC_VALIDATE_SCOPE(BRID, CAREBY, TLSCOPE, pv_BRID, TLGOUPS)=0) cf,
                 afmast af, semast se, sbsecurities sb
                where af.custid = cf.custid and se.codeid = sb.codeid
                and se.afacctno = af.acctno and sb.sectype <> '004'
                and sb.symbol like V_SYMBOL
                AND (af.brid LIKE V_STRBRID or instr(V_STRBRID,af.brid) <> 0 )
                group by se.acctno, nvl(sb.refcodeid, sb.codeid), sb.symbol,se.afacctno, cf.custodycd) trade_today
            left join
----Phat sinh ban chung khoan hom nay
            (select se.acctno,
                    case when V_CURRDATE = V_DATE then sum(info.secureamt) else 0 end amt
                from v_getsellorderinfo info, semast se, sbsecurities sb
                where info.secureamt <> 0 and se.acctno = info.seacctno
                and sb.codeid = se.codeid and sb.sectype <> '004'
                group by se.acctno) trade_sell_today
            on trade_today.acctno = trade_sell_today.acctno
            left join
----Phat sinh ck
            (select tran.acctno, sum( case when tran.txtype = 'D' then -tran.namt else tran.namt end) amt
                from vw_setran_gen tran
                where tran.busdate >  V_DATE and tran.busdate <= V_CURRDATE
                and tran.sectype <> '004' and tran.field = 'TRADE'
                group by tran.acctno) trade_mov
            on trade_today.acctno = trade_mov.acctno
         group by trade_today.custodycd, trade_today.codeid, trade_today.symbol) main
where main.codeid = sb.codeid
group by sb.tradeplace, main.symbol
having  sum(case when sb.tradeplace = '001' and main.amt >= 10 and REMAINDER(amt,10) < 0 then REMAINDER(amt,10) + 10
              when sb.tradeplace = '001' and main.amt >= 10 and REMAINDER(amt,10) > 0 then REMAINDER(amt,10)
             when sb.tradeplace = '001' and main.amt < 10 then amt
             when sb.tradeplace <> '001' and main.amt >= 100 and REMAINDER(amt,100) < 0 then remainder(amt,100) + 100
             when sb.tradeplace <> '001' and main.amt >= 100 and REMAINDER(amt,100) > 0 then remainder(amt,100)
             when sb.tradeplace <> '001' and main.amt < 100 then amt
             end ) <> 0
order by sb.tradeplace, main.symbol
/*select san, symbol, sum(SL) SL, I_DATE busdate
from (
select san, symbol, custodycd, case when san = 'HOSE' and sum(SL) >= 10 then REMAINDER(sum(SL),10)
                                    when san = 'HOSE' and sum(SL) < 10 then sum(SL)
                                    when san <> 'HOSE' and sum(SL) >= 100 then REMAINDER(sum(SL),100)
                                    when san <> 'HOSE' and sum(SL) < 100 then sum(SL)
                                    end  SL
from
  (select --sb.tradeplace,
        (case when sb.tradeplace='001' then 'HOSE'
                when sb.tradeplace='002' then 'HNX'
                else 'UPCOM' end) SAN,sb.symbol, cf.custodycd, af.acctno,

        sum(CASE WHEN sb.tradeplace = '001' THEN substr(se.trade,length(trade), length(trade))
            ELSE substr(se.trade,length(trade) - 1, length(trade)) END) SL
        from semast se,sbsecurities sb, cfmast cf, afmast af
        where
            sb.codeid= se.codeid and SE.TRADE <> 0 and cf.custid = af.custid and se.afacctno = af.acctno
        group by sb.symbol, sb.tradeplace,cf.custodycd, af.acctno
        having sum(CASE WHEN sb.tradeplace = '001' THEN substr(se.trade,length(trade), length(trade))
            ELSE substr(se.trade,length(trade) - 1, length(trade)) END) <> 0 )
  group by san, symbol, custodycd
  having case when san = 'HOSE' and sum(SL) >= 10 then REMAINDER(sum(SL),10)
                                    when san = 'HOSE' and sum(SL) < 10 then sum(SL)
                                    when san <> 'HOSE' and sum(SL) >= 100 then REMAINDER(sum(SL),100)
                                    when san <> 'HOSE' and sum(SL) < 100 then sum(SL)
                                    end  <> 0 )
group by san, symbol, I_DATE
having sum(SL) <> 0
*/
;
EXCEPTION
   WHEN OTHERS
   THEN
      RETURN;
END;                                                              -- PROCEDURE
 
/
