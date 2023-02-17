SET DEFINE OFF;
CREATE OR REPLACE PROCEDURE "SE0010" (
   PV_REFCURSOR   IN OUT   PKG_REPORT.REF_CURSOR,
   OPT            IN       VARCHAR2,
   PV_BRID           IN       VARCHAR2,
   TLGOUPS        IN       VARCHAR2,
   TLSCOPE        IN       VARCHAR2,
   I_DATE         IN       VARCHAR2,
   PV_CUSTODYCD   IN       VARCHAR2,
   PV_TRADEPLACE  in        varchar2

)
IS
--Bao cao tong hop so du ck lo le tren tieu khoan nhung ko le tren tai khoan
--created by chaunh at 11/02/2012

   V_STROPTION     VARCHAR2 (5);            -- A: ALL; B: BRANCH; S: SUB-BRANCH
   V_CUSTODYCD     VARCHAR2 (20);
   V_TRADEPLACE     varchar2(20);
   V_INBRID        VARCHAR2(4);
   V_STRBRID      VARCHAR2 (50);

BEGIN
    V_STROPTION := upper(OPT);
    V_INBRID := PV_BRID;
    if(V_STROPTION = 'A') then
        V_STRBRID := '%%';
    else
        if(V_STROPTION = 'B') then
            select br.mapid into V_STRBRID from brgrp br where  br.brid = V_INBRID;
        else
            V_STRBRID := V_INBRID;
        end if;
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




OPEN PV_REFCURSOR FOR
select a.*,PV_CUSTODYCD l_custodycd, b.sl slTT from
(select sb.symbol,cf.custodycd, af.acctno,cf.fullname,I_DATE busdate,--sb.tradeplace,
        (case when sbtmp.tradeplaceNEW='001' then 'HOSE'
                when sbtmp.tradeplaceNEW='002' then 'HNX'
                else 'UPCOM' end) SAN,
        sum(CASE WHEN sbtmp.tradeplaceNEW = '001' THEN substr(se.trade,length(trade), length(trade))
            ELSE substr(se.trade,length(trade) - 1, length(trade)) END) SL
        from semast se,sbsecurities sb, (SELECT * FROM CFMAST WHERE FNC_VALIDATE_SCOPE(BRID, CAREBY, TLSCOPE, pv_BRID, TLGOUPS)=0) cf,
         afmast af, (select fn_symbol_tradeplace( sb.codeid, i_date  ) tradeplacenew, sb.*  from   sbsecurities sb) sbtmp
        where
            sb.codeid= se.codeid
            and sbtmp.codeid = nvl(sb.refcodeid, sb.codeid)
            AND cf.custid = af.custid
            AND sb.sectype <> '004'
            AND se.afacctno = af.acctno
            AND cf.custodycd LIKE V_CUSTODYCD
            and sbtmp.tradeplaceNEW like V_TRADEPLACE
            AND (af.brid LIKE V_STRBRID or instr(V_STRBRID,af.brid) <> 0 )
        group by sb.symbol, sbtmp.tradeplaceNEW, cf.custodycd, cf.fullname, af.acctno
        ORDER BY san, symbol, sbtmp.tradeplaceNEW, custodycd, fullname, acctno) a
left join
(select sb.symbol,cf.custodycd, --I_DATE busdate,--sb.tradeplace,
        (case when sbtmp.tradeplaceNEW='001' then 'HOSE'
                when sbtmp.tradeplaceNEW='002' then 'HNX'
                else 'UPCOM' end) SAN,
        sum(CASE WHEN sbtmp.tradeplaceNEW = '001' THEN substr(se.trade,length(trade), length(trade))
            ELSE substr(se.trade,length(trade) - 1, length(trade)) END) SL
        from semast se,sbsecurities sb, (SELECT * FROM CFMAST WHERE FNC_VALIDATE_SCOPE(BRID, CAREBY, TLSCOPE, pv_BRID, TLGOUPS)=0) cf, afmast af,( select fn_symbol_tradeplace( sb.codeid, i_date  ) tradeplacenew, sb.*  from   sbsecurities sb) sbtmp
        where
            sb.codeid= se.codeid
            and sbtmp.codeid = nvl(sb.refcodeid, sb.codeid)
            AND cf.custid = af.custid
            AND se.afacctno = af.acctno
            AND cf.custodycd LIKE V_CUSTODYCD
            and sbtmp.tradeplaceNEW like V_TRADEPLACE
            AND (af.brid LIKE V_STRBRID or instr(V_STRBRID,af.brid) <> 0 )
        group by sb.symbol, sbtmp.tradeplaceNEW, cf.custodycd
        ORDER BY san, symbol, sbtmp.tradeplaceNEW, custodycd) b
on a.symbol = b.symbol and a.custodycd = b.custodycd
where a.sl <> 0
and (case when a.SAN = 'HOSE' then remainder(b.SL,10) else remainder(b.SL,100) end) = 0
;

EXCEPTION
   WHEN OTHERS
   THEN
      RETURN;
END;                                                              -- PROCEDURE
 
 
 
 
/
