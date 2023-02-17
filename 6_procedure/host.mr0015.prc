SET DEFINE OFF;
CREATE OR REPLACE PROCEDURE "MR0015" (
   PV_REFCURSOR      IN OUT   PKG_REPORT.REF_CURSOR,
   p_OPT             IN       VARCHAR2,
   p_BRID            IN       VARCHAR2,
   TLGOUPS        IN       VARCHAR2,
   TLSCOPE        IN       VARCHAR2,
   p_DATE            IN       VARCHAR2,
   p_CUSTODYCD       IN       VARCHAR2,
   CODEID            IN       VARCHAR2,
   p_AFACCTNO        IN       VARCHAR2,
   P_MNEMONIC        IN       VARCHAR2
   )
IS
--

-- PURPOSE: BRIEFLY EXPLAIN THE FUNCTIONALITY OF THE PROCEDURE
--
-- MODIFICATION HISTORY
-- PERSON      DATE    COMMENTS
-- NAMNT   12-APR-2012  CREATE
-- ---------   ------  -------------------------------------------

    l_OPT varchar2(10);
    l_BRID varchar2(1000);
    l_BRID_FILTER varchar2(1000);
    l_CUSTODYCD varchar2(10);
    V_STRAFACCTNO           VARCHAR2(20);
    V_STRSYMBOL           VARCHAR2(50);
    v_INDATE        DATE;
    V_CURRDATE      DATE;
    V_STR_MNEMONIC      VARCHAR2(100);
BEGIN

-- Prepare Parameters

    l_OPT := p_OPT;

    IF (l_OPT = 'A') THEN
      l_BRID_FILTER := '%';
    ELSE if (l_OPT = 'B') then
            select brgrp.mapid into l_BRID_FILTER from brgrp where brgrp.brid = p_BRID;
        else
            l_BRID_FILTER := p_BRID;
        end if;
    END IF;

    IF P_MNEMONIC IS NULL OR UPPER(P_MNEMONIC) = 'ALL' THEN
        V_STR_MNEMONIC := '%';
    ELSE
        V_STR_MNEMONIC := UPPER(P_MNEMONIC);
    END IF;

    if upper(p_CUSTODYCD) = 'ALL' or p_CUSTODYCD is null then
        l_CUSTODYCD:= '%';
    else
        l_CUSTODYCD:= p_CUSTODYCD;
    end if;

    if upper(CODEID) = 'ALL' or CODEID is null then
        V_STRSYMBOL:= '%';
    else
        V_STRSYMBOL:= CODEID;
    end if;

    if (p_AFACCTNO = 'ALL' or p_AFACCTNO is null) then
        V_STRAFACCTNO:= '%';
    else
        V_STRAFACCTNO:= p_AFACCTNO;
    end if;

    v_INDATE := to_date(p_DATE,'dd/mm/rrrr');
    select to_date(VARVALUE,'DD/MM/RRRR') into V_CURRDATE from sysvar where grname='SYSTEM' and varname='CURRDATE';

IF v_INDATE = V_CURRDATE THEN
    OPEN PV_REFCURSOR
    FOR
    select p_DATE INDATE, af.brid, cf.custodycd, cf.fullname, af.acctno afacctno, se.acctno, se.codeid, sb.symbol,
        trade, receiving, buyqtty, nvl(rsk.mrratioloan,0) ratecl,
        nvl(sb.BASICPRICE,0) BASICPRICE, AFT.mnemonic
    from
        (
            select se.codeid, af.actype, af.mriratio, se.afacctno,se.acctno, se.trade, se.mortage , nvl(sts.receiving,0) receiving,nvl(BUYQTTY,0) BUYQTTY,nvl(od.EXECQTTY,0) EXECQTTY
            from semast se
            inner join afmast af on se.afacctno =af.acctno
            left join
            (
                select sum(BUYQTTY) BUYQTTY, sum(EXECQTTY) EXECQTTY , AFACCTNO, CODEID
                from (
                    SELECT (case when od.exectype IN ('NB','BC') then REMAINQTTY + EXECQTTY - DFQTTY else 0 end) BUYQTTY,
                    (case when od.exectype IN ('NS','MS') and od.stsstatus <> 'C' then EXECQTTY - nvl(dfexecqtty,0) else 0 end) EXECQTTY,AFACCTNO, CODEID
                    FROM odmast od, afmast af,
                    (select orderid, sum(execqtty) dfexecqtty from odmapext where type = 'D' group by orderid) dfex
                    where od.afacctno = af.acctno and od.orderid = dfex.orderid(+)
                        and od.txdate = V_CURRDATE
                        AND od.deltd <> 'Y'
                        and not(od.grporder='Y' and od.matchtype='P') --Lenh thoa thuan tong khong tinh vao
                        AND od.exectype IN ('NS', 'MS','NB','BC')
                )
                group by AFACCTNO, CODEID
            ) OD
            on OD.afacctno =se.afacctno and OD.codeid =se.codeid
            left join
            (
                SELECT STS.CODEID,STS.AFACCTNO,
                SUM(CASE WHEN DUETYPE ='RS' AND STS.TXDATE <> TO_DATE(sy.VARVALUE,'DD/MM/RRRR') THEN QTTY-AQTTY ELSE 0 END) RECEIVING
                FROM STSCHD STS, ODMAST OD, ODTYPE TYP, sysvar sy
                WHERE STS.DUETYPE IN ('RM','RS') AND STS.STATUS ='N'
                    and sy.grname = 'SYSTEM' and sy.varname = 'CURRDATE'
                    AND STS.DELTD <>'Y' AND STS.ORGORDERID=OD.ORDERID AND OD.ACTYPE =TYP.ACTYPE
                GROUP BY STS.AFACCTNO,STS.CODEID
            ) sts
            on sts.afacctno =se.afacctno and sts.codeid=se.codeid
        ) se, afserisk rsk, securities_info sb, (SELECT * FROM CFMAST WHERE FNC_VALIDATE_SCOPE(BRID, CAREBY, TLSCOPE, p_BRID, TLGOUPS)=0) cf, afmast af, sbsecurities SB2,
        aftype aft, mrtype mrt
    where cf.custid = af.custid and af.acctno = se.afacctno
        and se.actype = rsk.actype(+) and se.codeid=rsk.codeid(+)
        AND AF.ACTYPE = aft.actype
        AND aft.mrtype = mrt.actype
        and (mrt.mrtype in ('S', 'T') OR AFT.istrfbuy = 'Y')
        and se.codeid = sb.codeid
        AND SE.CODEID = SB2.CODEID AND SB2.SECTYPE <> '004'
        and trade + receiving - execqtty + buyqtty + mortage > 0
        and cf.custodycd like l_CUSTODYCD and sb.symbol like V_STRSYMBOL
        AND AF.ACCTNO LIKE V_STRAFACCTNO
        AND UPPER(AFT.mnemonic) LIKE V_STR_MNEMONIC
        ;
else
    OPEN PV_REFCURSOR
    FOR
    select p_DATE INDATE, af.brid, cf.custodycd, cf.fullname, af.acctno afacctno, v.acctno, v.codeid, v.symbol,
        v.trade, v.receiving, v.buyqtty, v.ratecl, round(v.sereal/(v.trade + v.receiving - v.execqtty + v.buyqtty),4)BASICPRICE,
        AFT.mnemonic
    from tbl_mr3007_log v, (SELECT * FROM CFMAST WHERE FNC_VALIDATE_SCOPE(BRID, CAREBY, TLSCOPE, p_BRID, TLGOUPS)=0) cf, afmast af , sbsecurities SB, aftype aft, mrtype mrt
    where v.trade + v.mortage + v.receiving + v.EXECQTTY + v.buyqtty > 0
        and v.custodycd = cf.custodycd and v.afacctno = af.acctno
        and v.txdate = v_INDATE and cf.custodycd like l_CUSTODYCD and v.symbol like V_STRSYMBOL
        AND AF.ACTYPE = aft.actype
        AND aft.mrtype = mrt.actype
        and (mrt.mrtype in ('S', 'T') OR AFT.istrfbuy = 'Y')
        AND V.CODEID = SB.CODEID AND SB.SECTYPE <> '004'
        AND AF.ACCTNO LIKE V_STRAFACCTNO
        AND UPPER(AFT.mnemonic) LIKE V_STR_MNEMONIC
    order by v.txdate;
end if;

EXCEPTION
   WHEN OTHERS
   THEN
      RETURN;
END;                                                              -- PROCEDURE

 
 
 
 
/
