SET DEFINE OFF;
CREATE OR REPLACE PROCEDURE "SP_GETSECUSTINFO" (pv_refcursor in out pkg_report.ref_cursor, p_custodycd varchar2, p_afacctno varchar2, p_codeid varchar2)
is
begin
open pv_refcursor for
SELECT CASE WHEN AFACCTNO=P_AFACCTNO THEN 0 ELSE 1 END ORD1,
    A.ORD2, SB.SYMBOL,A.CODEID,A.AFACCTNO, A.STATUS, A.QTTY, A.REFID, A.TYPE,
    0 ALLOCQTTY
FROM (
    --Trading
    SELECT 0 ORD2, se.CODEID,se.AFACCTNO,'Giao dịch' STATUS,
                    greatest(se.trade - nvl(b.secureamt,0) + nvl(b.sereceiving,0),0) QTTY,
                    se.ACCTNO REFID,'S' TYPE
    FROM semast se,afmast af, cfmast cf, v_getsellorderinfo b
    WHERE se.afacctno = af.acctno and af.custid = cf.custid
    AND se.acctno = b.seacctno(+)
    and cf.CUSTODYCD=p_custodycd AND se.CODEID=p_codeid
    and se.trade - nvl(b.secureamt,0) + nvl(b.sereceiving,0) >0
    union
    --Mortgage
    select 1 ORD2, df.CODEID,df.AFACCTNO,'Cầm cố' STATUS,df.DFTRADING QTTY, df.acctno REFID,'D' TYPE
    from v_getdealinfo df
    where df.CUSTODYCD=p_custodycd AND df.CODEID=p_codeid
    and df.dftrading>0
    union
    --Trading dat lenh
    SELECT 2 ORD2, od.CODEID,od.AFACCTNO,'Giao dịch bán' STATUS,od.remainqtty -nvl(ext.qtty,0)  QTTY, od.orderid REFID, 'O' TYPE
    from odmast od, afmast af, cfmast cf,
    (select refid, sum(qtty) qtty from odmapext where deltd<>'Y' and type ='O' group by refid) ext,
    (SELECT '001' TRADEPLACE, SYSVALUE FROM ordersys where SYSNAME='CONTROLCODE' ) S,
    (SELECT '002' TRADEPLACE, SYSVALUE FROM ordersys where SYSNAME='HNXCONTROLCODE' ) S1, SBSECURITIES SB
    where od.afacctno = af.acctno and af.custid = cf.custid
    and OD.EXECTYPE='NS'
    AND SB.CODEID=OD.CODEID
    and od.remainqtty -nvl(ext.qtty,0)>0 and deltd <> 'Y'
    and od.matchtype <> 'P' and od.grporder <> 'Y'
    and od.orderid = ext.refid(+)
    and cf.CUSTODYCD=p_custodycd AND od.CODEID=p_codeid
    AND S.SYSVALUE NOT IN ('P','O','A') AND S1.SYSVALUE IN ('13','15')
    union
    --Mortgage dat lenh
    SELECT 3 ORD2, od.CODEID,od.AFACCTNO,'Cầm cố bán' STATUS,od.remainqtty-nvl(ext.qtty,0)  QTTY, od.orderid REFID, 'M' TYPE
    from odmast od, afmast af, cfmast cf,
    (select refid, sum(qtty) qtty from odmapext where deltd<>'Y' and type ='O' group by refid) ext,
    (SELECT '001' TRADEPLACE, SYSVALUE FROM ordersys where SYSNAME='CONTROLCODE' ) S,
    (SELECT '002' TRADEPLACE, SYSVALUE FROM ordersys where SYSNAME='HNXCONTROLCODE' ) S1, SBSECURITIES SB
    where od.afacctno = af.acctno and af.custid = cf.custid
    and OD.EXECTYPE='MS'
    AND SB.CODEID=OD.CODEID
    and od.remainqtty-nvl(ext.qtty,0)>0 and deltd <> 'Y'
    and od.matchtype <> 'P' and od.grporder <> 'Y'
    and od.orderid = ext.refid(+)
    and cf.CUSTODYCD=p_custodycd AND od.CODEID=p_codeid
    AND S.SYSVALUE NOT IN ('P','O','A')  AND S1.SYSVALUE IN ('13','15')
) A, sbsecurities sb
where a.codeid= sb.codeid
ORDER BY ORD1, ORD2, AFACCTNO;

end;

 
 
 
 
/
