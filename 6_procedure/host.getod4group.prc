SET DEFINE OFF;
CREATE OR REPLACE PROCEDURE "GETOD4GROUP"
   (
     PV_REFCURSOR   IN OUT PKG_REPORT.REF_CURSOR,
     pv_GROUPID    IN number,
     pv_BORS  in varchar2,
     pv_SYMBOL in varchar2,
     pv_PRICE in number,
     pv_RATE in number,
     pv_ROUND in varchar2,
     pv_TRADEUNIT in number,--tradelot : HA 100 ; Ho 10
     pv_PRICETYPE varchar2 default 'AA'
   )
   IS
   v_txDate DATE;
BEGIN -- Proc
select to_date(varvalue,'dd/MM/yyyy') into v_txDate from sysvar where upper(varname) = 'CURRDATE' AND GRNAME='SYSTEM';
--insert into temp(t) values(pv_GROUPID||pv_BORS||pv_SYMBOL||pv_PRICE||pv_RATE||pv_ROUND||pv_TRADEUNIT);
--commit;
If pv_BORS ='NB' then
    OPEN PV_REFCURSOR FOR
    SELECT gd.acctno, cf.custodycd, cf.fullname, ci.balance +af.advanceline balance,
           pv_symbol sec_code,
           least((case pv_round
            when 'CEIL' then  CEIL(pv_rate * (ci.balance + af.advanceline)/ (pv_price * se.tradeunit * se.tradelot*(1+ot.deffeerate/100)))* se.tradelot
            when 'TRUNC' then trunc(pv_rate *(ci.balance + af.advanceline) / (pv_price * se.tradeunit * se.tradelot*(1+ot.deffeerate/100)))* se.tradelot
            end
            ), -- DK: Balance + Advanline - Odamt - Secure -Overamt >= P*Q*(1+deffee)/100
            (case pv_round
            when 'CEIL' then
             decode(ot.bratio,0,999999999,
                    CEIL(pv_rate * (ci.realbalance)
                     / (pv_price * se.tradeunit * se.tradelot*
                      (least(greatest(ot.bratio+af.bratio,se.securedratiomin),se.securedratiomax)
                        +ot.deffeerate+0.000000001)/100)
                      )* se.tradelot)
            when 'TRUNC' then
             decode(ot.bratio,0,999999999,
                     trunc(pv_rate *(ci.realbalance)
                      / (pv_price * se.tradeunit * se.tradelot*
                       (least(greatest(ot.bratio+af.bratio,se.securedratiomin),se.securedratiomax)+
                        ot.deffeerate+0.000000001)/100))* se.tradelot)
            end
            ))quantity, --Dk: Blance - secure >= P*Q*(bratio+deffeerate)/100
           pv_price price/*,
           ot.bratio,
           ot.minfeeamt,
           ot.deffeerate,
           reg.aftype*/
      FROM afgroupheader gh,
           afgroupdetail gd,
          (select  ci.acctno, ci.balance-ci.odamt-nvl(od.secureamt,0)- NVL(ABO.absecured,0) -nvl(od.overamt,0) balance,
                   greatest (ci.balance-nvl(od.secureamt,0)- NVL(ABO.absecured,0)-ci.odamt,0) realbalance
            from cimast ci,
            (SELECT  od.afacctno,
                 SUM ( quoteprice* remainqtty * (od.bratio/100) + execamt * (od.bratio/100) )
                        secureamt,
                 SUM (    quoteprice* remainqtty*(1 + typ.deffeerate/100 - od.bratio / 100)
                                 +   execamt*    (1 + typ.deffeerate/100 - od.bratio / 100)
                               ) overamt
            FROM odmast od, odtype typ
            WHERE  od.actype = typ.actype
                   AND od.txdate=v_txDate
                   AND od.deltd <> 'Y'
                   AND od.exectype IN ('NB', 'BC')
            group by     od.afacctno
            ) OD,
            (SELECT   od.afacctno,
                         SUM
                            (GREATEST
                                (    od.quoteprice
                                   * od.orderqtty
                                   * od.bratio
                                   / 100
                                 -   org.quoteprice
                                   * org.orderqtty
                                   * org.bratio
                                   / 100,
                                 0
                                )
                            ) absecured
                    FROM odmast od,
                         odmast org,
                         ood
                   WHERE od.orderid =
                                    ood.orgorderid
                     AND od.reforderid =
                                       org.orderid
                     AND oodstatus = 'N'
                     AND od.exectype = 'AB'
                     AND od.deltd <> 'Y'
                     AND org.deltd <> 'Y'
                GROUP BY od.afacctno) ABO
            where ci.acctno=od.afacctno(+)
               and ci.acctno=Abo.afacctno(+)
            ) ci,
             afmast af,
              cfmast cf,
              securities_info se,
              odtype ot,
               regtype reg,
               sbsecurities sb
     WHERE (gh.autoid = pv_groupid)
       AND gh.autoid = gd.groupid
       AND gd.acctno = ci.acctno
       AND af.custid = cf.custid
       AND gd.acctno = af.acctno
       and se.symbol=pv_symbol
       and sb.symbol=pv_symbol
        and reg.aftype=af.actype
        and reg.modcode='OD'
        and ot.status = 'Y'
        and reg.actype=ot.actype
        and (ot.via = 'B' or ot.via ='A')
        and (ot.clearcd='B')
        and (ot.EXECTYPE=pv_BORS OR ot.EXECTYPE='AA')
        AND (ot.TIMETYPE='T' OR ot.TIMETYPE='A' )
        AND (ot.PRICETYPE=pv_pricetype  OR ot.PRICETYPE='AA')
        AND (ot.MATCHTYPE='N' OR ot.MATCHTYPE='A')
        and (ot.TRADEPLACE=sb.tradeplace OR ot.TRADEPLACE='000')
        AND (ot.SECTYPE=sb.SECTYPE OR ot.SECTYPE='000')
        AND (ot.NORK='N' OR ot.NORK ='A')
        and  (reg.aftype,ot.bratio)
        	in(select  r.aftype, max(o.bratio)
        	   from odtype o, regtype r, sbsecurities s
               where o.actype=r.actype
               and r.modcode='OD'
               and o.status = 'Y'
               and s.symbol=pv_symbol
               and (o.via = 'B' or ot.via ='A')
                and (o.clearcd='B')
                and (o.EXECTYPE=pv_BORS OR o.EXECTYPE='AA')
                AND (o.TIMETYPE='T' OR o.TIMETYPE='A' )
                AND (o.PRICETYPE=pv_pricetype  OR o.PRICETYPE='AA')
                AND (o.MATCHTYPE='N' OR o.MATCHTYPE='A')
                and (o.TRADEPLACE=s.tradeplace OR o.TRADEPLACE='000')
                AND (o.SECTYPE=s.SECTYPE OR o.SECTYPE='000')
                AND (o.NORK='N' OR o.NORK ='A')
               group by r.aftype)
        and least((case pv_round
            when 'CEIL' then  CEIL(pv_rate * (ci.balance + af.advanceline)/ (pv_price * se.tradeunit * se.tradelot*(1+ot.deffeerate/100)))* se.tradelot
            when 'TRUNC' then trunc(pv_rate *(ci.balance + af.advanceline) / (pv_price * se.tradeunit * se.tradelot*(1+ot.deffeerate/100)))* se.tradelot
            end
            ), -- DK: Balance + Advanline - Odamt - Secure -Overamt >= P*Q*(1+deffee)/100
            (case pv_round
            when 'CEIL' then
             decode(ot.bratio,0,999999999,
                    CEIL(pv_rate * (ci.realbalance)
                     / (pv_price * se.tradeunit * se.tradelot*
                      (least(greatest(ot.bratio+af.bratio,se.securedratiomin),se.securedratiomax)
                        +ot.deffeerate+0.000000001)/100)
                      )* se.tradelot)
            when 'TRUNC' then
             decode(ot.bratio,0,999999999,
                     trunc(pv_rate *(ci.realbalance)
                      / (pv_price * se.tradeunit * se.tradelot*
                       (least(greatest(ot.bratio+af.bratio,se.securedratiomin),se.securedratiomax)+
                        ot.deffeerate+0.000000001)/100))* se.tradelot)
            end
            ))>0;


ElsIF pv_BORS ='NS' then
    OPEN PV_REFCURSOR FOR
    Select  gd.acctno,cf.custodycd,cf.fullname,se.trade balance, Pv_SYMBOL sec_code,
            (case pv_round
            when 'CEIL' then  ceil( Pv_RATE  * se.trade/ Pv_tradeunit )*  Pv_tradeunit
            when 'TRUNC' then Trunc( Pv_RATE  * se.trade/ Pv_tradeunit )*  Pv_tradeunit
            end
            ) QUANTITY,
            Pv_PRICE PRICE
           from  afgroupheader gh, afgroupdetail gd,
            (select se.afacctno, se.codeid, se.trade- nvl(od.secureamt,0) trade
                from semast se,
                (SELECT     seacctno,
                        SUM (case when od.exectype IN ('NS', 'SS') then remainqtty + execqtty else 0 end)  secureamt
                FROM odmast od
                WHERE  od.txdate =v_txDate
                AND deltd <> 'Y' AND od.exectype IN ('NS', 'SS')
                group by    seacctno  ) od
                where se.acctno=od.seacctno(+)) se,
             sbsecurities sb, afmast af, cfmast cf
           where(gh.autoid =  Pv_groupid  )
            and gh.autoid=gd.groupid and gd.acctno=se.afacctno  and se.codeid=sb.codeid
            and sb.symbol =  Pv_SYMBOL
            and af.custid=cf.custid and af.acctno=se.afacctno
            and ((pv_ROUND = 'CEIL' and ceil( Pv_RATE  * se.trade/ Pv_tradeunit )*  Pv_tradeunit >0)
                 or((pv_ROUND = 'TRUNC' and TRUNC( Pv_RATE  * se.trade/ Pv_tradeunit )*  Pv_tradeunit >0)) );
Elsif pv_BORS ='MS' then
        OPEN PV_REFCURSOR FOR
    Select  gd.acctno,cf.custodycd,cf.fullname,se.mortage balance, Pv_SYMBOL sec_code,
            (case pv_round
            when 'CEIL' then  ceil( Pv_RATE  * se.mortage/ Pv_tradeunit )*  Pv_tradeunit
            when 'TRUNC' then Trunc( Pv_RATE  * se.mortage/ Pv_tradeunit )*  Pv_tradeunit
            end
            ) QUANTITY,
            Pv_PRICE PRICE
           from  afgroupheader gh, afgroupdetail gd,
            (select se.afacctno, se.codeid, se.mortage- nvl(od.securemtg,0) mortage
                from semast se,
                (SELECT     seacctno,
                        SUM (case when od.exectype IN ('MS') then remainqtty + execqtty else 0 end)  securemtg
                FROM odmast od
                WHERE  od.txdate =v_txDate
                AND deltd <> 'Y' AND od.exectype IN ('MS')
                group by    seacctno  ) od
                where se.acctno=od.seacctno(+)) se,
             sbsecurities sb, afmast af, cfmast cf
           where(gh.autoid =  Pv_groupid  )
            and gh.autoid=gd.groupid and gd.acctno=se.afacctno  and se.codeid=sb.codeid
            and sb.symbol =  Pv_SYMBOL
            and af.custid=cf.custid and af.acctno=se.afacctno
            and ((pv_ROUND = 'CEIL' and ceil( Pv_RATE  * se.mortage/ Pv_tradeunit )*  Pv_tradeunit >0)
                 or((pv_ROUND = 'TRUNC' and TRUNC( Pv_RATE  * se.mortage/ Pv_tradeunit )*  Pv_tradeunit >0)) );
End if;

EXCEPTION
    WHEN others THEN
        return;
END;

 
 
 
 
/
