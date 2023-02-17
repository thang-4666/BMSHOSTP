SET DEFINE OFF;
CREATE OR REPLACE PROCEDURE se0073 (
   PV_REFCURSOR   IN OUT   PKG_REPORT.REF_CURSOR,
   OPT            IN       VARCHAR2,
   PV_BRID           IN       VARCHAR2,
   TLGOUPS        IN       VARCHAR2,
   TLSCOPE        IN       VARCHAR2,
   --I_BRIDGD       IN       VARCHAR2,
   F_DATE         IN       VARCHAR2,
   T_DATE         IN       VARCHAR2
)
IS
--
-- PHIEU TINH LAI TOAN CONG TY
--created by CHaunh at 29/02/2012
-- ---------   ------  -------------------------------------------

   V_STROPTION         VARCHAR2 (5);            -- A: ALL; B: BRANCH; S: SUB-BRANCH
   V_STRBRID           VARCHAR2 (4);            -- USED WHEN V_NUMOPTION > 0
   --V_I_BRIDGD          VARCHAR2(100);
   --V_BRNAME            NVARCHAR2(400);
   V_FROMDATE          DATE;
   V_TODATE            DATE;
   V_TRRATE           varchar2(10);
   V_MAXTRVALUE          varchar2(10);


BEGIN

    V_STROPTION := OPT;

IF V_STROPTION = 'A' then
    V_STRBRID := '%';
ELSIF V_STROPTION = 'B' then
    V_STRBRID := substr(PV_BRID,1,2) || '__' ;
else
    V_STRBRID:=PV_BRID;
END IF;

-- GET REPORT'S PARAMETERS

    select varvalue into V_TRRATE from sysvar where grname = 'SYSTEM' and varname = 'VSDNETTRFRATE';
    select varvalue into V_MAXTRVALUE from sysvar where grname = 'SYSTEM' and varname = 'VSDMAXTRFAMT';
    V_FROMDATE        := TO_DATE(F_DATE, SYSTEMNUMS.C_DATE_FORMAT);
    V_TODATE          := TO_DATE(T_DATE, SYSTEMNUMS.C_DATE_FORMAT);

-- GET REPORT'S DATA
      OPEN PV_REFCURSOR
      FOR
/*select  case when sb.sectype = '006' then '02' else '01' end tieu_de,
        sum(case when substr(cf.custodycd,4,1) = 'P' then
            depo.qtty else 0
            end) tu_doanh,
        sum(case when substr(cf.custodycd,4,1) = 'C' then
            depo.qtty    else 0
            end) mg_trongnuoc,
        sum(case when substr(cf.custodycd,4,1) = 'F' then
            depo.qtty  else 0
            end) mg_nuocngoai, 0 CKBBT, 0 CKTT_TK

from sedepobal depo, sbsecurities sb, cfmast cf, afmast af--, allcode a2 , allcode a1
where substr(depo.acctno, 11,6) = sb.codeid
--and a1.cdname = 'SECTYPE' and a1.cdval = sb.sectype and a1.cdtype = 'SA'
and cf.custid = af.custid and substr(depo.acctno, 1,10) = af.acctno
--and a2.cdtype = 'SA' and a2.cdname = 'TYPEAF' and a2.cdval = substr(cf.custodycd,4,1)
and depo.txdate + days  > V_FROMDATE and depo.txdate <= V_TODATE
and substr(cf.custid,1,4) like V_STRBRID
group by case when sb.sectype = '006' then '02' else '01' end*/

SELECT --se.sbdate,
        case when se.sectype in ('006','003') then '02' else '01' end tieu_de,
        sum(case when substr(se.custodycd,4,1) = 'P' then
            se.amt - nvl(main.amt,0) else 0
            end) tu_doanh,
        sum(case when substr(se.custodycd,4,1) NOT IN  ('P','F') then
            se.amt - nvl(main.amt,0)    else 0
            end) mg_trongnuoc,
        sum(case when substr(se.custodycd,4,1) = 'F' then
            se.amt - nvl(main.amt,0)  else 0
            end) mg_nuocngoai, 0 CKBBT, 0 CKTT_TK, 0 SUA_LOI
/*SELECT SUM (se.amt - nvl(main.amt,0))*/
FROM
(SELECT sbdate, se.custodycd, se.sectype, se.amt
FROM (SELECT DISTINCT sbdate FROM sbcldr WHERE sbdate <= V_TODATE AND sbdate >= V_FROMDATE  and cldrtype='000') sbcldr,  --ngoc.vu-Jira561
     (SELECT cf.custodycd, sb.sectype,
            sum(nvl(SE.TRADE,0) + nvl(SE.BLOCKED,0) + nvl(se.secured,0) + nvl(SE.WITHDRAW,0) + nvl(SE.MORTAGE,0) +NVL(SE.netting,0) + NVL(SE.dtoclose,0) + nvl(SE.WTRADE,0)
                + nvl(se.blockwithdraw,0) + nvl(se.blockdtoclose,0) + nvl(se.emkqtty,0)) amt
     from semast se, (SELECT * FROM CFMAST ) cf, afmast af, sbsecurities sb
     WHERE af.custid = cf.custid AND se.afacctno = af.acctno
----     AND AF.ACTYPE NOT IN '0000'
     and cf.custatcom = 'Y'
     and sb.issedepofee ='Y'
     AND sb.codeid = se.codeid AND sb.sectype <> '004' and CF.BRID like V_STRBRID
     GROUP BY cf.custodycd, sb.sectype ) se) SE
LEFT JOIN
(SELECT cldr.sbdate, tran.custodycd, sb.sectype,  sum(CASE WHEN tran.txtype = 'D' THEN -tran.namt ELSE tran.namt END) amt
FROM vw_setran_gen tran,sbsecurities sb,(SELECT DISTINCT sbdate FROM sbcldr WHERE sbdate <= V_TODATE AND sbdate >= V_FROMDATE  and cldrtype='000') cldr --ngoc.vu-Jira561
WHERE tran.codeid = sb.codeid AND tran.sectype <> '004' AND tran.busdate >= V_FROMDATE
AND tran.field IN ('TRADE','BLOCKED','WITHDRAW','MORTAGE','SECURED','NETTING','DTOCLOSE','WTRADE','BLOCKWITHDRAW','BLOCKDTOCLOSE','EMKQTTY')
AND tran.txtype IN ('D','C') AND tran.namt <> 0
AND SB.ISSEDEPOFEE ='Y'
AND tran.busdate > cldr.sbdate and TRAN.BRID like V_STRBRID
GROUP BY cldr.sbdate, tran.custodycd, sb.sectype) main
ON se.sbdate = main.sbdate AND se.custodycd  = main.custodycd AND se.sectype = main.sectype
GROUP BY /*se.sbdate,*/ case when se.sectype in ('006','003') then '02' else '01' end
------------line 3
union ALL
/*SELECT --se.sbdate,
        '03' tieu_de,
        round(sum(case when substr(se.custodycd,4,1) = 'P'  AND se.sectype IN ('006','003') THEN ((se.amt - nvl(main.amt,0))* 0.2/30 )
                 WHEN substr(se.custodycd,4,1) = 'P'  AND se.sectype NOT IN ('006','003') THEN ((se.amt - nvl(main.amt,0))* 0.5/30)
                 ELSE 0
            end)) tu_doanh,
        round(sum(case when substr(se.custodycd,4,1) NOT IN  ('P','F') AND se.sectype IN ('006','003') THEN ((se.amt - nvl(main.amt,0))* 0.2/30 )
                 when substr(se.custodycd,4,1) NOT IN  ('P','F') AND se.sectype NOT IN ('006','003') THEN ((se.amt - nvl(main.amt,0))* 0.5/30)
                 ELSE 0
            end)) mg_trongnuoc,
        round(sum(case when substr(se.custodycd,4,1) = 'F' AND se.sectype IN ('006','003') THEN ((se.amt - nvl(main.amt,0))* 0.2/30)
                 when substr(se.custodycd,4,1) = 'F' AND se.sectype NOT IN ('006','003') THEN ((se.amt - nvl(main.amt,0))* 0.5/30 )
                 else 0
            end)) mg_nuocngoai, 0 CKBBT, 0 CKTT_TK, 0 SUA_LOI
FROM
(SELECT sbdate, se.custodycd, se.sectype, se.amt
FROM (SELECT DISTINCT sbdate FROM sbcldr WHERE sbdate <= V_TODATE AND sbdate >= V_FROMDATE) sbcldr,
     (SELECT cf.custodycd, sb.sectype,
            sum(nvl(SE.TRADE,0) + nvl(SE.BLOCKED,0) + nvl(se.secured,0) + nvl(SE.WITHDRAW,0) + nvl(SE.MORTAGE,0) +NVL(SE.netting,0) + NVL(SE.dtoclose,0) + nvl(SE.WTRADE,0)) amt
     from semast se, cfmast cf, afmast af, sbsecurities sb
     WHERE af.custid = cf.custid AND se.afacctno = af.acctno
     and cf.custatcom = 'Y'
     AND sb.codeid = se.codeid AND sb.sectype <> '004' and substr(cf.custid,1,4) like V_STRBRID
     GROUP BY cf.custodycd, sb.sectype ) se) SE
LEFT JOIN
(SELECT cldr.sbdate, tran.custodycd, sb.sectype,  sum(CASE WHEN tran.txtype = 'D' THEN -tran.namt ELSE tran.namt END) amt
FROM vw_setran_gen tran,sbsecurities sb,(SELECT DISTINCT sbdate FROM sbcldr WHERE sbdate <= V_TODATE AND sbdate >= V_FROMDATE) cldr
WHERE tran.codeid = sb.codeid and tran.sectype <> '004' AND tran.busdate > V_FROMDATE
AND tran.field IN ('TRADE','BLOCKED','WITHDRAW','MORTAGE','SECURED','NETTING','DTOCLOSE','WTRADE')
AND tran.txtype IN ('D','C') AND tran.namt <> 0
AND tran.busdate > cldr.sbdate and substr(tran.custid,1,4) like V_STRBRID
GROUP BY cldr.sbdate, tran.custodycd, sb.sectype) main
ON se.sbdate = main.sbdate AND se.custodycd  = main.custodycd AND se.sectype = main.sectype*/
select '03' tieu_de,
    round(sum(tu_doanh_tp * fn_getDepoFeeVal('TP', sbdate)) + sum(tu_doanh_cp * fn_getDepoFeeVal('CP', sbdate))) tu_doanh,
    round(sum(mg_trongnuoc_tp * fn_getDepoFeeVal('TP', sbdate)) + sum(mg_trongnuoc_cp * fn_getDepoFeeVal('CP', sbdate))) mg_trongnuoc,
    round(sum(mg_nuocngoai_tp * fn_getDepoFeeVal('TP', sbdate)) + sum(mg_nuocngoai_cp * fn_getDepoFeeVal('CP', sbdate))) mg_nuocngoai,
    0 CKBBT, 0 CKTT_TK, 0 SUA_LOI
from (
    SELECT se.sbdate,
            '03' tieu_de,
            round(sum(case when substr(se.custodycd,4,1) = 'P'  AND se.sectype IN ('006','003') THEN ((se.amt - nvl(main.amt,0)) )
                     --WHEN substr(se.custodycd,4,1) = 'P'  AND se.sectype NOT IN ('006','003') THEN ((se.amt - nvl(main.amt,0))* 0.5/30)
                     ELSE 0
                end)) tu_doanh_tp,
            round(sum(case --when substr(se.custodycd,4,1) = 'P'  AND se.sectype IN ('006','003') THEN ((se.amt - nvl(main.amt,0))* 0.2/30 )
                     WHEN substr(se.custodycd,4,1) = 'P'  AND se.sectype NOT IN ('006','003') THEN ((se.amt - nvl(main.amt,0)))
                     ELSE 0
                end)) tu_doanh_cp,
            round(sum(case when substr(se.custodycd,4,1) NOT IN  ('P','F') AND se.sectype IN ('006','003') THEN ((se.amt - nvl(main.amt,0)) )
                     --when substr(se.custodycd,4,1) NOT IN  ('P','F') AND se.sectype NOT IN ('006','003') THEN ((se.amt - nvl(main.amt,0))* 0.5/30)
                     ELSE 0
                end)) mg_trongnuoc_tp,
            round(sum(case --when substr(se.custodycd,4,1) NOT IN  ('P','F') AND se.sectype IN ('006','003') THEN ((se.amt - nvl(main.amt,0))* 0.2/30 )
                     when substr(se.custodycd,4,1) NOT IN  ('P','F') AND se.sectype NOT IN ('006','003') THEN ((se.amt - nvl(main.amt,0)))
                     ELSE 0
                end)) mg_trongnuoc_cp,
            round(sum(case when substr(se.custodycd,4,1) = 'F' AND se.sectype IN ('006','003') THEN ((se.amt - nvl(main.amt,0)))
                     --when substr(se.custodycd,4,1) = 'F' AND se.sectype NOT IN ('006','003') THEN ((se.amt - nvl(main.amt,0))* 0.5/30 )
                     else 0
                end)) mg_nuocngoai_tp,
            round(sum(case --when substr(se.custodycd,4,1) = 'F' AND se.sectype IN ('006','003') THEN ((se.amt - nvl(main.amt,0))* 0.2/30)
                     when substr(se.custodycd,4,1) = 'F' AND se.sectype NOT IN ('006','003') THEN ((se.amt - nvl(main.amt,0)) )
                     else 0
                end)) mg_nuocngoai_cp,
            0 CKBBT, 0 CKTT_TK, 0 SUA_LOI
    FROM
    (SELECT sbdate, se.custodycd, se.sectype, se.amt
    FROM (SELECT DISTINCT sbdate FROM sbcldr WHERE sbdate <= V_TODATE AND sbdate >= V_FROMDATE  and cldrtype='000') sbcldr, --ngoc.vu-Jira561
         (SELECT cf.custodycd, sb.sectype,
                sum(nvl(SE.TRADE,0) + nvl(SE.BLOCKED,0) + nvl(se.secured,0) + nvl(SE.WITHDRAW,0) + nvl(SE.MORTAGE,0) +NVL(SE.netting,0) + NVL(SE.dtoclose,0) + nvl(SE.WTRADE,0)
                    + nvl(se.blockwithdraw,0) + nvl(se.blockdtoclose,0) + nvl(se.emkqtty,0)) amt
         from semast se, (SELECT * FROM CFMAST ) cf, afmast af, sbsecurities sb
         WHERE af.custid = cf.custid AND se.afacctno = af.acctno
----            AND AF.ACTYPE NOT IN '0000'
         and cf.custatcom = 'Y'
         and sb.issedepofee ='Y'
         AND sb.codeid = se.codeid AND sb.sectype <> '004' and CF.BRID like V_STRBRID
         GROUP BY cf.custodycd, sb.sectype ) se) SE
    LEFT JOIN
    (SELECT cldr.sbdate, tran.custodycd, sb.sectype,  sum(CASE WHEN tran.txtype = 'D' THEN -tran.namt ELSE tran.namt END) amt
    FROM vw_setran_gen tran,sbsecurities sb,(SELECT DISTINCT sbdate FROM sbcldr WHERE sbdate <= V_TODATE AND sbdate >= V_FROMDATE  and cldrtype='000') cldr --ngoc.vu-Jira561
    WHERE tran.codeid = sb.codeid and tran.sectype <> '004' AND tran.busdate >= V_FROMDATE
    AND tran.field IN ('TRADE','BLOCKED','WITHDRAW','MORTAGE','SECURED','NETTING','DTOCLOSE','WTRADE','BLOCKWITHDRAW','BLOCKDTOCLOSE','EMKQTTY')
    AND tran.txtype IN ('D','C') AND tran.namt <> 0
    and sb.issedepofee ='Y'
    AND tran.busdate > cldr.sbdate and TRAN.BRID like V_STRBRID
    GROUP BY cldr.sbdate, tran.custodycd, sb.sectype) main
    ON se.sbdate = main.sbdate AND se.custodycd  = main.custodycd AND se.sectype = main.sectype
    group by se.sbdate
)-- group by sbdate

/*---------------line 4
union all
select a.tieu_de, tu_doanh, mg_trongnuoc, mg_nuocngoai, CKBBT, nvl(b.CKTT_TK,0) CKTT_TK, so_loi SUA_LOI from (
(select '04' tieu_de, 0 tu_doanh,0 mg_trongnuoc,0 mg_nuocngoai,
    amt CKBBT ,  0 CKTT_TK
    from
    (
    SELECT sum(nvl(SAMT,0)) amt --sum( CASE  WHEN SAMT - BAMT > 0 THEN SAMT - BAMT ELSE 0 END ) amt
    FROM (
        SELECT CLEARDATE SETTDATE, CHD.TXDATE TRADATE,SB.symbol,sb.tradeplace,
                SUM (CASE WHEN CHD.DUETYPE = 'RS' THEN (CHD.qtty) ELSE 0 END )BAMT,
                SUM (case WHEN CHD.DUETYPE = 'RM' THEN (CHD.qtty) ELSE 0 END )SAMT
            FROM vw_stschd_all CHD, (SELECT * FROM CFMAST ) CF, AFMAST AF, SBSECURITIES SB, SEMAST SE, AFTYPE AFT
            WHERE CF.CUSTID = AF.CUSTID AND AF.ACCTNO = SE.AFACCTNO AND SB.CODEID = SE.CODEID
                AND (case WHEN CHD.DUETYPE = 'RS' THEN CHD.ACCTNO ELSE CHD.AFACCTNO || CHD.CODEID END )  = SE.ACCTNO
                AND CHD.DUETYPE IN ( 'RS','RM') AND cf.custatcom ='Y' and CHD.deltd <> 'Y'
                AND CHD.CLEARDATE <= to_date(V_TODATE,'DD/MM/RRRR')
                AND CHD.CLEARDATE >= to_date(V_FROMDATE,'DD/MM/RRRR')
                AND SB.ISSEDEPOFEE ='Y'
-----                     AND AF.ACTYPE NOT IN '0000'
                --AND CHD.TXDATE >= to_date(V_FROMDATE,'DD/MM/RRRR') - chd.clearday
                --AND CHD.TXDATE <= to_date(V_TODATE,'DD/MM/RRRR') - chd.clearday
                AND SB.TRADEPLACE IN ('001','002','005')
                AND SB.SECTYPE IN ('001','006','008')
                AND AF.ACTYPE   =    AFT.ACTYPE
                and CF.BRID like V_STRBRID
                --AND CHD.CLEARDAY = 3 --v_Clearday
            GROUP BY CLEARDATE, CHD.TXDATE, SB.symbol, sb.tradeplace
        )

    )
)a
left join
(select '04' tieu_de, sum(msgamt) CKTT_TK from vw_tllog_all tl where tltxcd = '2248' and deltd <> 'Y' and busdate >= V_FROMDATE and busdate <=V_TODATE and tl.brid like V_STRBRID ) b
 on a.tieu_de = b.tieu_de
 LEFT JOIN
 (SELECT '04' tieu_de, count(msgacct) so_loi FROM vw_tllog_all tl WHERE tltxcd in ('8846','8843') AND deltd <> 'Y' AND busdate >= V_FROMDATE and busdate <=V_TODATE and tl.brid like V_STRBRID ) c
 ON a.tieu_de = c.tieu_de
    )
    */
  -----------------------------line 4
  union all
select a.tieu_de, tu_doanh, mg_trongnuoc, mg_nuocngoai, CKBBT, nvl(b.CKTT_TK,0) CKTT_TK, so_loi SUA_LOI from (
(select '04' tieu_de, 0 tu_doanh,0 mg_trongnuoc,0 mg_nuocngoai,
    SUM(amt) CKBBT ,  0 CKTT_TK
    from
    (
         SELECT  OD.CLEARDATE, od.TXDATE,iod.SYMBOL,
                SUM(NVL(IOD.MATCHQTTY,0)) AMT

          FROM VW_IOD_ALL IOD, CFMAST CF, vw_stschd_all OD
          WHERE IOD.CUSTODYCD=CF.CUSTODYCD
                AND IOD.BORS='S' AND IOD.ORGORDERID=OD.ORGORDERID AND OD.DUETYPE='RM'
                AND CF.custatcom ='Y' AND OD.DELTD<>'Y'
                AND OD.CLEARDATE BETWEEN V_FROMDATE AND V_TODATE
                AND CF.BRID LIKE V_STRBRID
               GROUP BY  OD.CLEARDATE, od.TXDATE,iod.SYMBOL
    )
)a
left join
(SELECT  '04' tieu_de,SUM(NAMT)CKTT_TK FROM(
   SELECT  (SE.namt) namt
        FROM VW_SETRAN_GEN_ALL SE,AFMAST AF
        WHERE SE.TLTXCD='2248' AND SE.AFACCTNO=AF.ACCTNO
              AND INSTR(AF.PSTATUS,'G')<=0 AND TXTYPE='D'
              AND SE.BUSDATE BETWEEN to_date(F_DATE,'DD/MM/YYYY') AND to_date(T_DATE,'DD/MM/YYYY')
              AND se.BRID  like V_STRBRID
        UNION ALL
      /* SELECT sum(NVL(SE.NAMT,0)) namt
        FROM SESENDOUT SEDE, VW_SETRAN_GEN_ALL SE,
              (SELECT * FROM TLLOGFLD WHERE TXDATE BETWEEN  V_FROMDATE AND V_TODATE
               AND FLDCD='18' AND NVALUE>0 UNION ALL SELECT * FROM TLLOGFLDALL WHERE TXDATE BETWEEN V_FROMDATE AND V_TODATE
               AND FLDCD='18'  AND NVALUE>0 )FLD
        WHERE  SE.TLTXCD in ('2266') AND SE.TXNUM=FLD.TXNUM AND SE.TXDATE=FLD.TXDATE
              AND SEDE.AUTOID=FLD.NVALUE AND SEDE.TRTYPE='014'
              AND SE.TXTYPE='D' AND SEDE.DELTD<>'Y'
              AND SE.BUSDATE BETWEEN V_FROMDATE AND V_TODATE
              AND SE.BRID LIKE V_STRBRID*/

   SELECT  nvl( SUM(ctrade+cblocked+ccaqtty),0) FROM sesendout WHERE  id2266 IS NOT NULL
-- AND substr(id2266,1,length(id2266)-10) BETWEEN V_FROMDATE AND V_TODATE
  AND TO_DATE( substr(id2266,1,length(id2266)-10),'DD/MM/YYYY') BETWEEN V_FROMDATE AND V_TODATE
 AND DELTD <>'Y'
  AND TRTYPE in ('014','017')

              )) b
 on a.tieu_de = b.tieu_de
 LEFT JOIN
 (SELECT '04' tieu_de, count(msgacct) so_loi FROM vw_tllog_all tl WHERE tltxcd in ('8846','8843') AND deltd <> 'Y' AND busdate >= V_FROMDATE and busdate <=V_TODATE and tl.brid like V_STRBRID ) c
 ON a.tieu_de = c.tieu_de
    )
---------------------------- line 5
/*union all
select c.tieu_de, c.tu_doanh, c.mg_trongnuoc, c.mg_nuocngoai, c.CKBBT, nvl(d.CKTT_TK,0) CKTT_TK, 0 SUA_LOI from (
(select '05' tieu_de,0  tu_doanh,0 mg_trongnuoc,0 mg_nuocngoai, sum(phi) CKBBT ,  0 CKTT_TK from
    (--select codeid,txdate,LEAST((case when BT > 0 then V_TRRATE* BT else 0 end),to_number(V_MAXTRVALUE)) phi FROM
     SELECT cleardate, txdate, symbol, tradeplace, LEAST(nvl(SAMT,0) * V_TRRATE, to_number(V_MAXTRVALUE)) phi
        --LEAST((CASE  WHEN SAMT - BAMT > 0 THEN (SAMT - BAMT)* V_TRRATE ELSE 0 END),to_number(V_MAXTRVALUE))  phi
     FROM
        (

            SELECT CLEARDATE , CHD.TXDATE ,SB.symbol,sb.tradeplace,
                SUM (CASE WHEN CHD.DUETYPE = 'RS' THEN (CHD.qtty) ELSE 0 END )BAMT,
                SUM (case WHEN CHD.DUETYPE = 'RM' THEN (CHD.qtty) ELSE 0 END )SAMT
            FROM vw_stschd_all CHD, (SELECT * FROM CFMAST ) CF, AFMAST AF, SBSECURITIES SB, SEMAST SE, AFTYPE AFT
            WHERE CF.CUSTID = AF.CUSTID AND AF.ACCTNO = SE.AFACCTNO AND SB.CODEID = SE.CODEID
                AND (case WHEN CHD.DUETYPE = 'RS' THEN CHD.ACCTNO ELSE CHD.AFACCTNO || CHD.CODEID END )  = SE.ACCTNO
                AND CHD.DUETYPE IN ( 'RS','RM') AND cf.custatcom ='Y' and CHD.deltd <> 'Y'
                AND CHD.CLEARDATE <= to_date(V_TODATE,'DD/MM/RRRR')
                AND CHD.CLEARDATE >= to_date(V_FROMDATE,'DD/MM/RRRR')
                AND SB.ISSEDEPOFEE ='Y'
----                     AND AF.ACTYPE NOT IN '0000'

                --AND CHD.TXDATE >= to_date(V_FROMDATE,'DD/MM/RRRR') - chd.clearday
                --AND CHD.TXDATE <= to_date(V_TODATE,'DD/MM/RRRR') - chd.clearday
                AND SB.TRADEPLACE IN ('001','002','005')
                AND SB.SECTYPE IN ('001','006','008')
                AND AF.ACTYPE   =    AFT.ACTYPE
                and  substr(cf.custid,1,4) like V_STRBRID
                --AND CHD.CLEARDAY = 3 --v_Clearday
            GROUP BY CLEARDATE, CHD.TXDATE, SB.symbol, sb.tradeplace

        \*select od.codeid, sts.cleardate txdate, sum(case when exectype in ('NS','SS','MS') then execqtty else 0 end) - sum( case when exectype in ('NB','BC') then execqtty else 0 end) BT
        FROM (SELECT * FROM odmast WHERE deltd <> 'Y' UNION ALL SELECT * FROM odmasthist WHERE deltd <> 'Y') od,
              (SELECT * FROM stschd WHERE deltd <> 'Y' UNION ALL SELECT * FROM stschdhist WHERE deltd <> 'Y') sts,
              cfmast cf, afmast af
        WHERE od.orderid = sts.orgorderid AND od.afacctno = af.acctno AND cf.custid = af.custid
        AND sts.cleardate >= V_FROMDATE AND sts.cleardate <= V_TODATE
        and  substr(cf.custid,1,4) like V_STRBRID
        GROUP BY od.codeid, sts.cleardate*\

        ))) c
 left join
 (select '05' tieu_de,  sum(least(feemaster.feeamt*msgamt,feemaster.maxval)) CKTT_TK \* , feemaster.feeamt, feemaster.maxval*\
    from vw_tllog_all tl, feemap, feemaster where tl.tltxcd = '2248' and \*tl.tltxcd*\ '2247' = feemap.tltxcd -- khong co phi tinh cho giao dich 2248
    and feemap.feecd = feemaster.feecd and tl.deltd <> 'Y'
    and tl.busdate >= V_FROMDATE and tl.busdate <=V_TODATE and tl.brid like V_STRBRID) d
  on d.tieu_de = c.tieu_de )*/
 ----------------------line 5 NGOCVTT EIDT LINE 5
 UNION ALL
 select c.tieu_de, c.tu_doanh, c.mg_trongnuoc, c.mg_nuocngoai, c.CKBBT, nvl(d.CKTT_TK,0) CKTT_TK, 0 SUA_LOI from (
(select '05' tieu_de,0  tu_doanh,0 mg_trongnuoc,0 mg_nuocngoai, sum(FEE) CKBBT ,  0 CKTT_TK from
    (     SELECT  OD.CLEARDATE, od.TXDATE,IOD.SYMBOL,
                SUM(NVL(IOD.MATCHQTTY,0)) TOTAL_QTTY, round(LEAST(SUM(NVL(IOD.MATCHQTTY,0)*0.5),500000)) FEE

          FROM VW_IOD_ALL IOD, CFMAST CF,vw_stschd_all OD
          WHERE IOD.CUSTODYCD=CF.CUSTODYCD
                AND IOD.BORS='S' AND IOD.ORGORDERID=OD.ORGORDERID AND OD.DUETYPE='RM'
                AND CF.custatcom ='Y' AND OD.DELTD<>'Y'
                AND OD.CLEARDATE BETWEEN V_FROMDATE AND V_TODATE
                AND CF.BRID LIKE V_STRBRID
               GROUP BY  OD.CLEARDATE, od.TXDATE,IOD.SYMBOL
               )
        ) c
 left join
 (
  SELECT  '05' tieu_de,SUM(FEEVSD)CKTT_TK FROM(
   SELECT SE.TXNUM,SE.BUSDATE TXDATE,round(LEAST((sum(NVL(SE.NAMT,0))*0.5),500000)) FEEVSD
        FROM VW_SETRAN_GEN SE,AFMAST AF
        WHERE SE.TLTXCD='2248' AND SE.AFACCTNO=AF.ACCTNO
              AND INSTR(AF.PSTATUS,'G')<=0 AND TXTYPE='D'
              AND SE.BUSDATE BETWEEN   V_FROMDATE AND V_TODATE
              AND se.BRID  like V_STRBRID
              GROUP BY SE.BUSDATE,SE.TXNUM
     UNION ALL
/*      SELECT  SE.TXNUM,SE.BUSDATE TXDATE, (round(LEAST((sum(NVL(SE.NAMT,0))*0.5),500000))) FEEVSD
        FROM SESENDOUT SEDE, VW_SETRAN_GEN_ALL SE,
              (SELECT * FROM TLLOGFLD WHERE TXDATE BETWEEN  V_FROMDATE AND V_TODATE
               AND FLDCD='18' AND NVALUE>0 UNION ALL SELECT * FROM TLLOGFLDALL WHERE TXDATE BETWEEN V_FROMDATE AND V_TODATE
               AND FLDCD='18'  AND NVALUE>0 )FLD
        WHERE  SE.TLTXCD in ('2266') AND SE.TXNUM=FLD.TXNUM AND SE.TXDATE=FLD.TXDATE
              AND SEDE.AUTOID=FLD.NVALUE AND SEDE.TRTYPE='014'
              AND SE.TXTYPE='D' AND SEDE.DELTD<>'Y'
              AND SE.BUSDATE BETWEEN V_FROMDATE AND V_TODATE
              AND SE.BRID LIKE V_STRBRID
        GROUP BY SE.TXNUM,SE.BUSDATE*/

  SELECT  substr(id2266,1,length(id2266)-11) TXNUM ,TO_DATE( substr(id2266,1,length(id2266)-10),'DD/MM/YYYY') TXDATE, (round(LEAST((sum(NVL( (ctrade+cblocked+ccaqtty),0))*0.5),500000))) FEEVSD
  FROM sesendout WHERE  id2266 IS NOT NULL
 AND TO_DATE( substr(id2266,1,length(id2266)-10),'DD/MM/YYYY') BETWEEN V_FROMDATE AND V_TODATE
 AND DELTD <>'Y' AND TRTYPE in ('014','017')
 GROUP BY  substr(id2266,1,length(id2266)-11),TO_DATE( substr(id2266,1,length(id2266)-10),'DD/MM/YYYY')
        )

        ) d
  on d.tieu_de = c.tieu_de )
 ----------------------line 6
 UNION ALL
 select '06' tieu_de, 0 tu_doanh, 0 mg_trongnuoc, 0 mg_nuocngoai, 0 CKBBT, 0 CKTT_TK, count(msgacct)*500000 SUA_LOI
 FROM vw_tllog_all tl WHERE tltxcd in ('8846','8843') AND deltd <> 'Y'
 AND busdate >= V_FROMDATE and busdate <=V_TODATE and tl.brid like V_STRBRID

;



 EXCEPTION
   WHEN OTHERS
   THEN
      RETURN;
END;
 
 
 
 
/
