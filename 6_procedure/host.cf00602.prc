SET DEFINE OFF;
CREATE OR REPLACE PROCEDURE "CF00602" (
   PV_REFCURSOR   IN OUT   PKG_REPORT.REF_CURSOR,
   OPT            IN       VARCHAR2,
   pv_BRID           IN       VARCHAR2,
   TLGOUPS        IN       VARCHAR2,
   TLSCOPE        IN       VARCHAR2,
   F_DATE         IN       VARCHAR2,
   T_DATE         IN       VARCHAR2
 )
IS
--

   V_STROPTION    VARCHAR2 (5);            -- A: ALL; B: BRANCH; S: SUB-BRANCH
   V_STRBRID      VARCHAR2 (40);            -- USED WHEN V_NUMOPTION > 0
   V_INBRID     VARCHAR2 (5);      -- USED WHEN V_NUMOPTION > 0

   V_TODATE     DATE;
   V_FROMDATE   DATE;
-- DECLARE PROGRAM VARIABLES AS SHOWN ABOVE

BEGIN
-- INSERT INTO TEMP_BUG(TEXT) VALUES('CF0001');COMMIT;
   V_STROPTION := upper(OPT);
   V_INBRID := pv_BRID;

   if(V_STROPTION = 'A') then
        V_STRBRID := '%';
    else
        if(V_STROPTION = 'B') then
            select br.mapid into V_STRBRID from brgrp br where  br.brid = V_INBRID;
        else
            V_STRBRID := pv_BRID;
        end if;
    end if;

    V_FROMDATE := to_date(F_DATE,'DD/MM/RRRR');
    V_TODATE := to_date(T_DATE,'DD/MM/RRRR');


OPEN PV_REFCURSOR
  FOR
 select sum(CASE  WHEN substr(cf.custodycd,4,1) <> 'F'
                    THEN (balance + bamt + mblock + emkamt) - nvl(ci_move_from_cur,0) + NVL(DF.BE_DFAMT,0)
                  ELSE 0 END) DK_TN, -- dau ky trong nuoc,
       sum(CASE  WHEN substr(cf.custodycd,4,1) <> 'F' THEN nvl(ci_credit,0)  - nvl(ci_debit,0) ELSE 0 END) PS_TN,--phat sinh trong ky trong nuoc
        sum(CASE  WHEN substr(cf.custodycd,4,1) = 'F'
                    THEN (balance + bamt + mblock + emkamt) - nvl(ci_move_from_cur,0) + NVL(DF.BE_DFAMT,0)
                  ELSE 0 END) DK_NN, --dau ky nuoc ngoai ,
       sum(CASE  WHEN substr(cf.custodycd,4,1) = 'F' THEN nvl(ci_credit,0)  - nvl(ci_debit,0) ELSE 0 END) PS_NN --phat sinh trong ky nuoc ngoai

 /*sum(round(nvl(ci_credit,0),0)  - round(nvl(ci_debit,0),0)) ps_tk,
        sum((balance + bamt + mblock + emkamt) - round(nvl(ci_move_from_cur,0),0) + NVL(DF.BE_DFAMT,0)) du_dk*/
    from (SELECT * FROM CFMAST WHERE FNC_VALIDATE_SCOPE(BRID, CAREBY, TLSCOPE, pv_BRID, TLGOUPS)=0) cf, afmast af, cimast ci,

    (
        select tr.custid, tr.custodycd, tr.acctno AFAcctno,
            sum (case when tr.txtype = 'D' then - tr.namt else tr.namt end) ci_move_from_cur
        from vw_citran_gen tr
        where txtype in ('D','C')
            and field in ('BAMT','BALANCE','MBLOCK','EMKAMT')
            and tr.busdate >= V_FROMDATE

        group by tr.custid, tr.custodycd, tr.acctno
        having sum (case when tr.txtype = 'D' then - tr.namt else tr.namt end) <> 0
    )  tr_from_cur,
    (
         SELECT DF.AFACCTNO, SUM(DF.DFBLOCKAMT + DF.DFAMT - NVL(TR.DFAMT,0)) BE_DFAMT
         FROM
             (SELECT * FROM dfgroup UNION ALL SELECT * FROM dfgrouphist) df
             LEFT JOIN
             (
                 select tr.acctno,
                         sum (case when atx.txtype = 'D' then - tr.namt else tr.namt end) dfamt
                     from vw_dftran_all tr, apptx atx
                     where tr.txcd = atx.txcd AND atx.apptype = 'DF'
                         AND atx.txtype in ('D','C')
                         and atx.field IN ('DFBLOCKAMT','DFAMT')
                         and tr.TXDATE >= V_FROMDATE
                     group by tr.acctno
             ) TR
             ON TR.ACCTNO = DF.GROUPID
         GROUP BY DF.AFACCTNO
         HAVING SUM(DF.DFBLOCKAMT + DF.DFAMT - NVL(TR.DFAMT,0)) <>0
     ) DF,

    (
        SELECT tr.custid, tr.custodycd, tr.afacctno, sum(ci_debit) ci_debit, sum(ci_credit) ci_credit
        FROM
        (
            select tr.custid, tr.custodycd, tr.acctno AFAcctno,
                sum (case when tr.txtype = 'D' then tr.namt else 0 end) ci_debit,
                sum (case when tr.txtype = 'C' then tr.namt else 0 end) ci_credit
            from vw_citran_gen tr
            where tr.txtype in ('D','C')
                and tr.field in ('BAMT','BALANCE','MBLOCK','EMKAMT')
                and tr.tltxcd not in ('9100','6600','6690','2635','2651','2653','2656','2646','2648','2636','2665',
                                        '1144','1145','6601','6602')
                and tr.busdate >= V_FROMDATE and tr.busdate <= V_TODATE
            group by tr.custid, tr.custodycd, tr.acctno
            --having sum (case when tr.txtype = 'D' then - tr.namt else tr.namt end) <> 0
            UNION ALL
            -- GD VAY DF
            SELECT cf.custid, cf.custodycd, ci.acctno AFAcctno,
                sum(CASE WHEN ci.txtype = 'D' THEN ci.namt ELSE 0 end) ci_debit,
                sum(CASE WHEN ci.txtype = 'C' THEN ci.namt ELSE 0 end) ci_credit
             FROM
                 (
                 SELECT LN.trfacctno ACCTNO, LNT.TLTXCD, LNT.TXDATE, LNT.TXNUM, LNT.TXCD,
                     LNT.NAMT, APT.field FIELD, 'D' TXTYPE, LN.custbank
                 FROM (SELECT * FROM vw_lntran_all WHERE TXDATE >= V_FROMDATE AND txdate <= V_TODATE) lnt,
                    vw_lnmast_all LN, APPTX APT
                 WHERE LNT.TLTXCD IN ('2646','2648','2636','2665') AND lnt.TXCD IN ('0014','0024','0090') AND lnt.namt > 0
                     AND LN.prinnml+LN.prinovd+LN.prinpaid > 0 AND LN.FTYPE = 'DF'
                     AND LNT.txcd = APT.txcd AND APT.apptype = 'LN'
                     AND LNT.acctno = LN.acctno
                 ) CI, CFMAST CF, afmast af
             WHERE cf.custid = af.custid AND af.acctno = ci.acctno
             GROUP BY cf.custid, cf.custodycd, ci.acctno
        ) tr
        GROUP BY tr.custid, tr.custodycd, tr.afacctno
    )  tr_from_Todate

    where cf.custid = af.custid and af.acctno = ci.acctno
        and ci.acctno = tr_from_cur.afacctno (+)
        and ci.acctno = tr_from_Todate.afacctno (+)
        AND ci.acctno = df.afacctno (+)
        and
        (
        abs(round(nvl(ci_debit,0),0))
        + abs(round(nvl(ci_credit,0),0) )
        + abs((balance + bamt + mblock + emkamt) - round(nvl(ci_move_from_cur,0),0) + NVL(DF.BE_DFAMT,0))
        ) >=1
        --and cf.custodycd not like '001P%'
          and cf.custatcom='Y'
          AND AF.COREBANK='N'
          AND SUBSTR( CF.CUSTODYCD ,4,1)<>'P'
          AND (af.brid LIKE V_STRBRID or instr(V_STRBRID,af.brid) <> 0 )
    order by cf.custodycd

/*SELECT  sum(CASE  WHEN substr(cf.custodycd,4,1) <> 'F'
                    THEN (ci.balance + ci.bamt + ci.mblock + ci.emkamt) - nvl(CI_mov.amt,0) + nvl(DF_mov.amt,0)
                  ELSE 0 END) DK_TN, -- dau ky trong nuoc,
       sum(CASE  WHEN substr(cf.custodycd,4,1) <> 'F' THEN mov_indate.amt ELSE 0 END) PS_TN,--phat sinh trong ky trong nuoc
        sum(CASE  WHEN substr(cf.custodycd,4,1) = 'F'
                    THEN (ci.balance + ci.bamt + ci.mblock + ci.emkamt) - nvl(CI_mov.amt,0) + nvl(DF_mov.amt,0)
                  ELSE 0 END) DK_NN, --dau ky nuoc ngoai ,
       sum(CASE  WHEN substr(cf.custodycd,4,1) = 'F' THEN mov_indate.amt ELSE 0 END) PS_NN --phat sinh trong ky nuoc ngoai
FROM cimast ci,
     ( --phat sinh CI
     select tr.acctno AFAcctno,
                     sum (case when tr.txtype = 'D' then - tr.namt else tr.namt end) amt
     from vw_citran_gen tr
     where txtype in ('D','C')
     and field in ('BAMT','BALANCE','MBLOCK','EMKAMT')
     and tr.busdate >= V_FROMDATE
     group by tr.acctno
     having sum (case when tr.txtype = 'D' then - tr.namt else tr.namt end) <> 0
     ) CI_mov,
     (-- phat sinh DF
     SELECT DF.AFACCTNO, SUM(DF.DFBLOCKAMT + DF.DFAMT - NVL(TR.DFAMT,0)) amt
     FROM (SELECT * FROM dfgroup UNION ALL SELECT * FROM dfgrouphist) df
          LEFT JOIN
        (select tr.acctno,sum (case when atx.txtype = 'D' then - tr.namt else tr.namt end) dfamt
         from vw_dftran_all tr, apptx atx
         where tr.txcd = atx.txcd AND atx.apptype = 'DF' AND tr.deltd <> 'Y'
         AND atx.txtype in ('D','C')
         and atx.field IN ('DFBLOCKAMT','DFAMT')
         and tr.TXDATE >= V_FROMDATE
         group by tr.acctno
        ) TR
       ON TR.ACCTNO = DF.GROUPID
     GROUP BY DF.AFACCTNO
     HAVING SUM(DF.DFBLOCKAMT + DF.DFAMT - NVL(TR.DFAMT,0)) <>0
     ) DF_mov,


--phat sinh trong ky
------(phat sinh CI + DF)
    (
    SELECT  afacctno, sum(amt) amt FROM
        (
        SELECT tr.acctno afacctno, sum(CASE WHEN tr.txtype = 'D' THEN -tr.namt ELSE tr.namt END) amt
        FROM vw_citran_gen tr
        WHERE tr.txtype in ('D','C')
            and tr.field in ('BAMT','BALANCE','MBLOCK','EMKAMT')
            and tr.tltxcd not in ('9100','6600','6690','2635','2651','2653','2656','2646','2648','2636','2665','1144','1145')
            AND tr.txdate <= V_TODATE AND tr.txdate >= V_FROMDATE
        GROUP BY tr.acctno

        UNION all

        SELECT  ci.acctno AFAcctno,
               sum(CASE WHEN ci.txtype = 'D' THEN -ci.namt ELSE ci.namt end) amt
        FROM (
             SELECT LN.trfacctno ACCTNO, LNT.TLTXCD, LNT.TXDATE, LNT.TXNUM, LNT.TXCD,
                    LNT.NAMT, APT.field FIELD, 'D' TXTYPE, LN.custbank
             FROM (SELECT * FROM vw_lntran_all WHERE TXDATE >= V_FROMDATE AND txdate <= V_TODATE AND deltd <> 'Y') lnt,
                  vw_lnmast_all LN, APPTX APT
             WHERE LNT.TLTXCD IN ('2646','2648','2636','2665') AND lnt.TXCD IN ('0014','0024','0090') AND lnt.namt > 0
             AND LN.prinnml+LN.prinovd+LN.prinpaid > 0 AND LN.FTYPE = 'DF'
             AND LNT.txcd = APT.txcd AND APT.apptype = 'LN'
             AND LNT.acctno = LN.acctno
             ) ci
        GROUP BY  ci.acctno
        )
    GROUP BY  afacctno
    ) mov_indate,
    cfmast cf, afmast af

WHERE ci.afacctno = CI_mov.afacctno (+)
AND ci.afacctno = DF_mov.afacctno (+)
AND ci.afacctno = mov_indate.afacctno (+)
AND cf.custid = af.custid
AND ci.afacctno = af.acctno*/

;

EXCEPTION
   WHEN OTHERS
   THEN

      RETURN;
End;

 
 
 
 
/
