SET DEFINE OFF;
CREATE OR REPLACE PROCEDURE se0004 (
   PV_REFCURSOR   IN OUT   PKG_REPORT.REF_CURSOR,
   OPT            IN       VARCHAR2,
   pv_BRID           IN       VARCHAR2,
   TLGOUPS        IN       VARCHAR2,
   TLSCOPE        IN       VARCHAR2,
   I_DATE         IN       VARCHAR2,
   PV_CUSTODYCD   IN       VARCHAR2,
   PV_TRADEPLACE  in        varchar2,
   PV_SYMBOL       IN       VARCHAR2

)
IS
--Bao cao tong hop so du ck lo le
--created by chaunh at 11/02/2012

   V_STROPTION     VARCHAR2 (5);            -- A: ALL; B: BRANCH; S: SUB-BRANCH
   V_CUSTODYCD     VARCHAR2 (20);
   V_TRADEPLACE     varchar2(20);
   V_CURRDATE       date;
   V_IDATE          date;
   V_SYMBOL        varchar2 (20);
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

   IF (PV_CUSTODYCD <> 'ALL')
   THEN
       V_CUSTODYCD :=  PV_CUSTODYCD;
   ELSE
        V_CUSTODYCD := '%';
   END IF;

     IF (PV_TRADEPLACE <> 'ALL')
   THEN
       V_TRADEPLACE :=  PV_TRADEPLACE;
   ELSE
        V_TRADEPLACE := '%';
   END IF;

   select to_date(varvalue,'DD/MM/RRRR') into V_CURRDATE from sysvar where varname = 'CURRDATE';
   V_IDATE := to_date(I_DATE, 'DD/MM/RRRR');



OPEN PV_REFCURSOR FOR

select a.*, b.SL le_TK, PV_CUSTODYCD l_custodycd,I_DATE busdate  from
(select case when sb.tradeplacenew = '001' then 'HOSE'
            when sb.tradeplacenew = '002' then 'HNX'
            else 'UPCOM' end san, main.symbol,main.custodycd,main.afacctno acctno,sb.tradeplacenew, main.fullname,-- '01-Apr-2012' busdate,
        sum(case when sb.tradeplacenew = '001' and main.amt >= 10 and REMAINDER(amt,10) < 0 then REMAINDER(amt,10) + 10
              when sb.tradeplacenew = '001' and main.amt >= 10 and REMAINDER(amt,10) > 0 then REMAINDER(amt,10)
             when sb.tradeplacenew = '001' and main.amt < 10 then amt
             when sb.tradeplacenew <> '001' and main.amt >= 100 and REMAINDER(amt,100) < 0 then remainder(amt,100) + 100
             when sb.tradeplacenew <> '001' and main.amt >= 100 and REMAINDER(amt,100) > 0 then remainder(amt,100)
             when sb.tradeplacenew <> '001' and main.amt < 100 then amt
             end ) SL
from (select fn_symbol_tradeplace( sb.codeid, i_date  ) tradeplacenew, sb.*  from   sbsecurities sb )sb,
    (select trade_today.custodycd, trade_today.codeid, trade_today.symbol,trade_today.afacctno, trade_today.fullname,
            sum(trade_today.amt  - nvl(trade_sell_today.amt,0) - nvl(trade_mov.amt,0)) amt
            from
----SL ck tu do giao dich hien tai
            (select se.acctno , nvl(sb.refcodeid, sb.codeid) codeid, sb.symbol,se.afacctno, cf.custodycd,cf.fullname,  sum(trade) amt
                from cfmast cf, afmast af, semast se, sbsecurities sb
                where af.custid = cf.custid and se.codeid = sb.codeid
                and se.afacctno = af.acctno and sb.sectype <> '004'
                and sb.symbol like V_SYMBOL
                AND (af.brid LIKE V_STRBRID or instr(V_STRBRID,af.brid) <> 0 )
                group by se.acctno, nvl(sb.refcodeid, sb.codeid), sb.symbol,se.afacctno, cf.custodycd,cf.fullname) trade_today
            left join
----Phat sinh ban chung khoan hom nay
            (select se.acctno,
                    case when V_CURRDATE = V_IDATE then sum(info.secureamt) else 0 end amt
                from v_getsellorderinfo info, semast se, sbsecurities sb
                where info.secureamt <> 0 and se.acctno = info.seacctno
                and sb.codeid = se.codeid and sb.sectype <> '004'
                group by se.acctno) trade_sell_today
            on trade_today.acctno = trade_sell_today.acctno
            left join
----Phat sinh ck
            (select tran.acctno, sum( case when tran.txtype = 'D' then -tran.namt else tran.namt end) amt
                from vw_setran_gen tran
                where tran.busdate >  V_IDATE and tran.busdate <= V_CURRDATE
                and tran.sectype <> '004' and tran.field = 'TRADE'
                group by tran.acctno) trade_mov
            on trade_today.acctno = trade_mov.acctno
         group by trade_today.custodycd, trade_today.codeid, trade_today.symbol,trade_today.afacctno, trade_today.fullname) main
where main.codeid = sb.codeid
group by sb.tradeplacenew, main.symbol,main.custodycd,main.afacctno, main.fullname
having  sum(case when sb.tradeplacenew = '001' and main.amt >= 10 and REMAINDER(amt,10) < 0 then REMAINDER(amt,10) + 10
              when sb.tradeplacenew = '001' and main.amt >= 10 and REMAINDER(amt,10) > 0 then REMAINDER(amt,10)
             when sb.tradeplacenew = '001' and main.amt < 10 then amt
             when sb.tradeplacenew <> '001' and main.amt >= 100 and REMAINDER(amt,100) < 0 then remainder(amt,100) + 100
             when sb.tradeplacenew <> '001' and main.amt >= 100 and REMAINDER(amt,100) > 0 then remainder(amt,100)
             when sb.tradeplacenew <> '001' and main.amt < 100 then amt
             end ) <> 0)a
left join
(select case when sb.tradeplacenew = '001' then 'HOSE'
            when sb.tradeplacenew = '002' then 'HNX'
            else 'UPCOM' end san, main.symbol,main.custodycd,-- '01-Apr-2012' busdate,
        sum(case when sb.tradeplacenew = '001' and main.amt >= 10 and REMAINDER(amt,10) < 0 then REMAINDER(amt,10) + 10
              when sb.tradeplacenew = '001' and main.amt >= 10 and REMAINDER(amt,10) > 0 then REMAINDER(amt,10)
             when sb.tradeplacenew = '001' and main.amt < 10 then amt
             when sb.tradeplacenew <> '001' and main.amt >= 100 and REMAINDER(amt,100) < 0 then remainder(amt,100) + 100
             when sb.tradeplacenew <> '001' and main.amt >= 100 and REMAINDER(amt,100) > 0 then remainder(amt,100)
             when sb.tradeplacenew <> '001' and main.amt < 100 then amt
             end ) SL
from (select fn_symbol_tradeplace( sb.codeid, i_date  ) tradeplacenew, sb.*  from   sbsecurities sb )sb,
    (select trade_today.custodycd, trade_today.codeid, trade_today.symbol, sum(trade_today.amt  - nvl(trade_sell_today.amt,0) - nvl(trade_mov.amt,0)) amt
            from
----SL ck tu do giao dich hien tai
            (select se.acctno , nvl(sb.refcodeid, sb.codeid) codeid, sb.symbol,se.afacctno, cf.custodycd,  sum(trade) amt
                from (SELECT * FROM CFMAST WHERE FNC_VALIDATE_SCOPE(BRID, CAREBY, TLSCOPE, pv_BRID, TLGOUPS)=0) cf,
                 afmast af, semast se, sbsecurities sb
                where af.custid = cf.custid and se.codeid = sb.codeid
                and se.afacctno = af.acctno and sb.sectype <> '004'
                and sb.symbol like V_SYMBOL
                and sb.symbol like '%'
                AND (af.brid LIKE V_STRBRID or instr(V_STRBRID,af.brid) <> 0 )
                group by se.acctno, nvl(sb.refcodeid, sb.codeid), sb.symbol,se.afacctno, cf.custodycd) trade_today
            left join
----Phat sinh ban chung khoan hom nay
            (select se.acctno,
                    case when V_CURRDATE = V_IDATE then sum(info.secureamt) else 0 end amt
                from v_getsellorderinfo info, semast se, sbsecurities sb
                where info.secureamt <> 0 and se.acctno = info.seacctno
                and sb.codeid = se.codeid and sb.sectype <> '004'
                group by se.acctno) trade_sell_today
            on trade_today.acctno = trade_sell_today.acctno
            left join
----Phat sinh ck
            (select tran.acctno, sum( case when tran.txtype = 'D' then -tran.namt else tran.namt end) amt
                from vw_setran_gen tran
                where tran.busdate >  V_IDATE and tran.busdate <= V_CURRDATE
                and tran.sectype <> '004' and tran.field = 'TRADE'
                group by tran.acctno) trade_mov
            on trade_today.acctno = trade_mov.acctno
         group by trade_today.custodycd, trade_today.codeid, trade_today.symbol) main
where main.codeid = sb.codeid
group by sb.tradeplacenew, main.symbol,main.custodycd
having  sum(case when sb.tradeplacenew = '001' and main.amt >= 10 and REMAINDER(amt,10) < 0 then REMAINDER(amt,10) + 10
              when sb.tradeplacenew = '001' and main.amt >= 10 and REMAINDER(amt,10) > 0 then REMAINDER(amt,10)
             when sb.tradeplacenew = '001' and main.amt < 10 then amt
             when sb.tradeplacenew <> '001' and main.amt >= 100 and REMAINDER(amt,100) < 0 then remainder(amt,100) + 100
             when sb.tradeplacenew <> '001' and main.amt >= 100 and REMAINDER(amt,100) > 0 then remainder(amt,100)
             when sb.tradeplacenew <> '001' and main.amt < 100 then amt
             end ) <> 0)b
on a.custodycd = b.custodycd and a.symbol = b.symbol
where a.custodycd like V_CUSTODYCD
and a.symbol like V_SYMBOL
and a.tradeplacenew like V_TRADEPLACE
order by a.custodycd, a.symbol
/*SELECT a.*, PV_CUSTODYCD l_custodycd,
            case when a.san = 'HOSE' and b.SL < 10 then b.SL
                 when a.san = 'HOSE' and b.SL >= 10 then REMAINDER(b.SL,10)
                 when a.san <> 'HOSE' and b.SL <100 then b.SL
                 when a.san <> 'HOSE' and b.SL >=100 then REMAINDER(b.SL,100)
                 end le_TK
FROM
(select sb.symbol,cf.custodycd, af.acctno,cf.fullname,I_DATE busdate,--sb.tradeplace,
        (case when sbtemp.tradeplace='001' then 'HOSE'
                when sbtemp.tradeplace='002' then 'HNX'
                else 'UPCOM' end) SAN,
        sum(CASE WHEN sb.tradeplace = '001' THEN substr(se.trade,length(trade), length(trade)) -- le 10
            ELSE substr(se.trade,length(trade) - 1, length(trade)) END) SL -- le 100
        from semast se,sbsecurities sb, cfmast cf, afmast af, sbsecurities sbtemp
        where
            sb.codeid= se.codeid
            and sbtemp.codeid = nvl(sb.refcodeid, sb.codeid)
            AND cf.custid = af.custid
            AND se.afacctno = af.acctno
            AND cf.custodycd LIKE V_CUSTODYCD
            and sbtemp.tradeplace like V_TRADEPLACE
        group by sb.symbol, sbtemp.tradeplace, cf.custodycd, cf.fullname, af.acctno
        having sum(CASE WHEN sb.tradeplace = '001' THEN substr(se.trade,length(trade), length(trade)) -- le 10
                        ELSE substr(se.trade,length(trade) - 1, length(trade)) END) <> 0
        order by sbtemp.tradeplace, sb.symbol, cf.custodycd) a
left join
    (select sb.symbol,cf.custodycd, --I_DATE busdate,--sb.tradeplace,
            (case when sbtemp.tradeplace='001' then 'HOSE'
                when sbtemp.tradeplace='002' then 'HNX'
                else 'UPCOM' end) SAN,
            sum(CASE WHEN sb.tradeplace = '001' THEN substr(se.trade,length(trade), length(trade)) -- le 10
                    ELSE substr(se.trade,length(trade) - 1, length(trade)) END) SL -- le 100
        from semast se,sbsecurities sb, cfmast cf, afmast af, sbsecurities sbtemp
        where
            sb.codeid= se.codeid
            and sbtemp.codeid = nvl(sb.refcodeid, sb.codeid)
            AND cf.custid = af.custid
            AND se.afacctno = af.acctno
            AND cf.custodycd LIKE V_CUSTODYCD
            and sbtemp.tradeplace like V_TRADEPLACE
        group by sb.symbol, sbtemp.tradeplace, cf.custodycd
        having sum(CASE WHEN sb.tradeplace = '001' THEN substr(se.trade,length(trade), length(trade)) -- le 10
                    ELSE substr(se.trade,length(trade) - 1, length(trade)) END) <> 0
        ORDER BY san, symbol, sbtemp.tradeplace, custodycd
     )b
on a.symbol = b.symbol and a.custodycd = b.custodycd and a.san = b.san
*/
;

EXCEPTION
   WHEN OTHERS
   THEN
      RETURN;
END;                                                              -- PROCEDURE
 
/
