SET DEFINE OFF;
CREATE OR REPLACE PROCEDURE "CI2001_TODAY" (
   PV_REFCURSOR   IN OUT   PKG_REPORT.REF_CURSOR,
   OPT            IN       VARCHAR2,
   BRID           IN       VARCHAR2,
   TLGOUPS        IN       VARCHAR2,
   TLSCOPE        IN       VARCHAR2,
   F_DATE         IN       VARCHAR2,
   T_DATE         IN       VARCHAR2,
   GLACCOUNT      IN       VARCHAR2
)
IS

    V_STROPTION         VARCHAR2  (5);
    V_STRBRID           VARCHAR2(100);
    V_IN_DATE           DATE;
    V_F_DATE            DATE;
    V_T_DATE            DATE;
    V_BRID              VARCHAR2(4);
    V_GLACCOUNT         VARCHAR2(50);
    V_OW_BEBAL          NUMBER;
    V_DO_BEBAL          NUMBER;
    V_FR_BEBAL          NUMBER;
    v_lnCount           number;

BEGIN
    -- GET REPORT'S PARAMETERS
    V_STROPTION := OPT;
    V_BRID := BRID;
    V_GLACCOUNT:= GLACCOUNT;

    IF V_STROPTION = 'A' THEN
        V_STRBRID := '%%';
    ELSIF V_STROPTION = 'B' AND V_BRID <> 'ALL' AND V_BRID IS NOT NULL THEN
        SELECT MAPID INTO V_STRBRID FROM BRGRP WHERE BRID = V_BRID;
    ELSIF V_STROPTION = 'S' AND V_BRID <> 'ALL' AND V_BRID IS NOT NULL THEN
        V_STRBRID := V_BRID;
    ELSE
        V_STRBRID := V_BRID;
    END IF;

    IF V_GLACCOUNT = 'ALL' THEN
        V_GLACCOUNT:= '%%';
    END IF;

    -- LAY NGAY DAU KY
    V_IN_DATE := TO_DATE(F_DATE,'DD/MM/YYYY');
    V_F_DATE := TO_DATE(F_DATE,'DD/MM/YYYY');
    V_T_DATE := TO_DATE(T_DATE,'DD/MM/YYYY');


--DELETE FROM CI2001_GL_DAUKY;



-- LAY DU LIEU CHUNG KHOAN
OPEN PV_REFCURSOR FOR



select ---nvl(a.txdate,V_T_DATE) txdate ,
a.txdate,
a.txnum, a.custodycd, a.acctno,a.bankacctno, gl.GLACCOUNT TRANSSUBTYPE, a.tltxcd, a.txdesc, nvl(CI_CRAMT,0) CI_CRAMT, nvl(CI_DRAMT,0) CI_DRAMT, nvl(OW_CRAMT,0) OW_CRAMT,
nvl(OW_DRAMT,0) OW_DRAMT, (GL.DAUKY) DAUKY, (gl.fullname) fullname from
(
    SELECT cf.custodycd, a.acctno,a.bankacctno,
        A.TXDATE, A.TXNUM, a.TRANSSUBTYPE,A.TLTXCD, a.TXDESC,
        (CASE WHEN A.TLTXCD IN ('1133','1134','1135','1136','1121') AND a.TXTYPE = 'C' THEN a.NAMT ELSE 0 END) CI_CRAMT,
        (CASE WHEN A.TLTXCD IN ('1133','1134','1135','1136','1121') AND a.TXTYPE = 'D' THEN a.NAMT ELSE 0 END) CI_DRAMT,
        (CASE WHEN A.TLTXCD NOT IN ('1133','1134','1135','1136','1121') AND a.TXTYPE = 'C' THEN a.NAMT ELSE 0 END) OW_CRAMT,
        (CASE WHEN A.TLTXCD NOT IN ('1133','1134','1135','1136','1121') AND a.TXTYPE = 'D' THEN a.NAMT ELSE 0 END) OW_DRAMT

    from (

        select af.custid, af.bankacctno , ci.*

        FROM AFMAST AF,
            (

              SELECT ci.acctno, ci.tltxcd, CI.txdate, ci.txnum, ci.txcd, ci.namt, ci.field,
                   CASE
                         WHEN ci.corebank = 'N' and substr(ci.acctno,1,4) = '0001' and ci_to.corebank = 'Y' and substr(ci.acctno,1,4) = '0101' THEN 'D'
                         WHEN ci.corebank = 'N' and substr(ci.acctno,1,4) = '0101' and ci_to.corebank = 'Y' and substr(ci.acctno,1,4) = '0001' THEN 'D'
                         WHEN ci.corebank = 'Y' and substr(ci.acctno,1,4) = '0101' and ci_to.corebank = 'N' and substr(ci.acctno,1,4) = '0001' THEN 'C'
                         WHEN ci.corebank = 'Y' and substr(ci.acctno,1,4) = '0001' and ci_to.corebank = 'N' and substr(ci.acctno,1,4) = '0101' THEN 'C'

                         WHEN ci.corebank = 'N' and ci_to.corebank = 'Y' and substr(ci.acctno,1,4) = '0001' THEN 'D'
                         WHEN ci.corebank = 'Y' and ci_to.corebank = 'N' and substr(ci.acctno,1,4) = '0001' THEN 'C'
                         WHEN ci.corebank = 'N' and ci_to.corebank = 'Y' and substr(ci.acctno,1,4) = '0101' THEN 'D'
                         WHEN ci.corebank = 'Y' and ci_to.corebank = 'N' and substr(ci.acctno,1,4) = '0101' THEN 'C'
                   end
                  txtype, ci.txdesc,
                 CASE
/*                         WHEN ci.corebank = 'N' and substr(ci.acctno,1,4) = '0001' and ci_to.corebank = 'Y' and substr(ci_to.acctno,1,4) = '0101' THEN '31010000462867'
                         WHEN ci.corebank = 'N' and substr(ci.acctno,1,4) = '0101' and ci_to.corebank = 'Y' and substr(ci_to.acctno,1,4) = '0001' THEN '12312000002335'
                         WHEN ci.corebank = 'Y' and substr(ci.acctno,1,4) = '0101' and ci_to.corebank = 'N' and substr(ci_to.acctno,1,4) = '0001' THEN '12312000002335'
                         WHEN ci.corebank = 'Y' and substr(ci.acctno,1,4) = '0001' and ci_to.corebank = 'N' and substr(ci_to.acctno,1,4) = '0101' THEN '31010000462867'*/

                         WHEN ci.corebank = 'N' and substr(ci.acctno,1,4) = '0001' and ci_to.corebank = 'Y' and substr(ci_to.acctno,1,4) = '0101' THEN '31010000462867'
                         WHEN ci.corebank = 'N' and substr(ci.acctno,1,4) = '0101' and ci_to.corebank = 'Y' and substr(ci_to.acctno,1,4) = '0001' THEN '12312000002335'
                         WHEN ci.corebank = 'Y' and substr(ci.acctno,1,4) = '0101' and ci_to.corebank = 'N' and substr(ci_to.acctno,1,4) = '0001' THEN '31010000462867'
                         WHEN ci.corebank = 'Y' and substr(ci.acctno,1,4) = '0001' and ci_to.corebank = 'N' and substr(ci_to.acctno,1,4) = '0101' THEN '12312000002335'

                         WHEN ci.corebank = 'N' and ci_to.corebank = 'Y' and substr(ci.acctno,1,4) = '0001' THEN '12312000002335'
                         WHEN ci.corebank = 'Y' and ci_to.corebank = 'N' and substr(ci.acctno,1,4) = '0001' THEN '12312000002335'
                         WHEN ci.corebank = 'N' and ci_to.corebank = 'Y' and substr(ci.acctno,1,4) = '0101' THEN '31010000462867'
                         WHEN ci.corebank = 'Y' and ci_to.corebank = 'N' and substr(ci.acctno,1,4) = '0101' THEN '31010000462867'
                     else 'KHAC' END TRANSSUBTYPE
                FROM  (SELECT * FROM vw_citran WHERE tltxcd IN ('1120','1130') and txcd = '0011')   ci
                , (SELECT * FROM vw_citran WHERE tltxcd IN ('1120','1130') and txcd = '0012') ci_to
                    --,(SELECT * FROM CRBTXREQ where status = 'C' UnION ALL  SELECT * FROM CRBTXREQHIST where status = 'C') CRB
                WHERE
                --ci.txdate = CRB.txdate and ci.txnum = crb.objkey and
                ci.txdate = ci_to.txdate and ci_to.txnum = ci.txnum and ci.acctref = ci_to.acctno
                and ci.BUSDATE >= V_F_DATE AND ci.BUSDATE <= V_T_DATE

                union all

                SELECT ci.acctno, ci.tltxcd, CI.txdate, ci.txnum, ci.txcd, ci.namt, ci.field, ci.txtype,ci.txdesc,
                               CASE
                                     --WHEN CI.TLTXCD IN ('3384','3394') and substr(txnum,1,4) = '0001' THEN '12310000163777'
                                     --WHEN CI.TLTXCD IN ('3384','3394','1139') and substr(txnum,1,4) = '0101' THEN '31010000462867'
                                     WHEN CI.TLTXCD IN ('1139') and substr(txnum,1,4) = '0101' THEN '31010000462867'
                                     else 'KHAC' END TRANSSUBTYPE
                            FROM
                                vw_citran   ci
                            WHERE BUSDATE >= V_F_DATE AND BUSDATE <= V_T_DATE
                            --and tltxcd IN ('1137','1138','1139','1144','1145','3384','3324','3394','3386','3326','3387')
                            and tltxcd IN ('1139','1144','1145')
                                AND ci.field = 'BALANCE'
                union all

               /* SELECT ci.acctno, ci.tltxcd, CI.txdate, ci.txnum, ci.txcd, ci.namt, ci.field, ci.txtype, ci.txdesc,
                               CASE
                                     WHEN CI.TLTXCD IN ('1162') and substr(acctno,1,4) = '0001' THEN '12312000002335'
                                     else 'KHAC' END TRANSSUBTYPE
                            FROM
                                vw_citran   ci
                            WHERE BUSDATE >= V_F_DATE AND BUSDATE <= V_T_DATE
                            and tltxcd IN ('1162')
                                AND ci.field = 'BALANCE'
                union all*/

                SELECT ci.acctno, ci.tltxcd, CI.txdate, ci.txnum, ci.txcd, ci.namt, ci.field, 'C' txtype, ci.txdesc,
                               CASE
                                     WHEN substr(acctno,1,4) = '0001' and ci.corebank = 'Y' THEN '12310000349850'
                                     WHEN substr(acctno,1,4) = '0101' and ci.corebank = 'Y' THEN '31010000462867'
                                     else 'KHAC' END TRANSSUBTYPE
                            FROM
                                vw_citran   ci
                            WHERE BUSDATE >= V_F_DATE AND BUSDATE <= V_T_DATE
                            and tltxcd IN ('2232')
                                AND ci.field = 'BALANCE'
                union all

                 select tl.msgacct acctno, tl.tltxcd, tl.txdate, tl.txnum, '' txcd, tl.msgamt namt, 'BALANCE' FIELD , 'D' TXTYPE,  tl.txdesc,
                        case when substr(tl.txnum,1,4) = '0001' then '12310000163777'
                             when substr(tl.txnum,1,4) = '0101' then '31010000462867' else 'KHAC' END TRANSSUBTYPE
                 from tllog tl, tllogfld tla
                    where tl.tltxcd like '1133' and tl.txnum = tla.txnum and tl.txdate = tla.txdate and tla.fldcd = '09' and tla.cvalue = '001'
                        AND TL.BUSDATE >= V_F_DATE AND TL.BUSDATE <= V_T_DATE AND TL.DELTD <> 'Y'

                union all

                 select tl.msgacct acctno, tl.tltxcd, tl.txdate, tl.txnum, '' txcd, tl.msgamt namt, 'BALANCE' FIELD , 'C' TXTYPE, tl.txdesc,
                        case when substr(tl.txnum,1,4) = '0001' then '12310000163777'
                             when substr(tl.txnum,1,4) = '0101' then '31010000462867' else 'KHAC' END TRANSSUBTYPE
                 from tllog tl, tllogfld tla
                    where tl.tltxcd like '1134' and tl.txnum = tla.txnum and tl.txdate = tla.txdate and tla.fldcd = '09' and tla.cvalue = '003'
                        AND TL.BUSDATE >= V_F_DATE AND TL.BUSDATE <= V_T_DATE AND TL.DELTD <> 'Y'


                union all

/*            select tl.msgacct acctno, tl.tltxcd, tl.txdate, tl.txnum, '' txcd, tl.msgamt namt, 'BALANCE' FIELD , 'D' TXTYPE,tl.txdesc, CVALUE TRANSSUBTYPE from tllog tl, tllogfld tla
                where tl.tltxcd like '1135' and tl.txnum = tla.txnum and tl.txdate = tla.txdate and tla.fldcd = '05'
                AND TL.BUSDATE >= V_F_DATE AND TL.BUSDATE <= V_T_DATE AND TL.DELTD <> 'Y'*/

                select tl.msgacct acctno, tl.tltxcd, tl.txdate, tl.txnum, '' txcd, tl.msgamt namt, 'BALANCE' FIELD , 'D' TXTYPE,tl.txdesc, CVALUE TRANSSUBTYPE from tllog tl, tllogfld tla
                where tl.tltxcd like '3387' and tl.txnum = tla.txnum and tl.txdate = tla.txdate and tla.fldcd = '08'
                AND TL.BUSDATE >= V_F_DATE AND TL.BUSDATE <= V_T_DATE AND TL.DELTD <> 'Y'

                UNION ALL


                    select tl.msgacct acctno, tl.tltxcd, tl.txdate, tl.txnum, '' txcd,
                                    case when substr(tl.txnum,1,4) = '0001' and tl3.cvalue='1' then  tl.msgamt
                                         when substr(tl.txnum,1,4) = '0001' and tl3.cvalue='0' then  tl.msgamt - tl1.nvalue - tl2.nvalue
                                         when substr(tl.txnum,1,4) = '0101' and tl3.cvalue='1' then  tl.msgamt + tl1.nvalue + tl2.nvalue
                                         when substr(tl.txnum,1,4) = '0101' and tl3.cvalue='0' then  tl.msgamt
                                         else tl.msgamt
                                    end namt,
                        'BALANCE' FIELD , 'D' TXTYPE,tl.txdesc, tla.CVALUE TRANSSUBTYPE
                        from tllog tl, tllogfld tla, tllogfld tl1, tllogfld tl2, tllogfld tl3 --, tllogfld tla2
                            where tl.tltxcd like '1135' and tl.txnum = tla.txnum and tl.txdate = tla.txdate and tla.fldcd = '05'
                                    and tl.txdate = tl1.txdate and tl.txnum = tl1.txnum and tl1.fldcd='11'
                                    and tl.txdate = tl2.txdate and tl.txnum = tl2.txnum and tl2.fldcd='12'
                                    and tl.txdate = tl3.txdate and tl.txnum = tl3.txnum and tl3.fldcd='09'
                                    --AND tl.txdate = tla2.txdate and tl.txnum = tla2.txnum and tla2.fldcd = '79' --AND NVL(TLA2.CVALUE,'111') <> '111'
                                    --AND case when SUBSTR(tl.TXNUM,1,4) = '0001' AND NVL(TLA2.CVALUE,'111') = '111' THEN 0 ELSE 1 END > 0
                                    AND TL.BUSDATE >= V_F_DATE AND TL.BUSDATE <= V_T_DATE AND TL.DELTD <> 'Y'

            union all
            select '' acctno, tl.tltxcd, tl.txdate, tl.txnum, '' txcd, tl.msgamt namt, 'BALANCE' FIELD , 'C' TXTYPE,tl.txdesc, TLA.CVALUE TRANSSUBTYPE
                    from tllog tl, tllogfld tla, tllogfld tla1, tllogfld tla2
                       where tl.tltxcd like '1135' and tl.txnum = tla.txnum and tl.txdate = tla.txdate and tla.fldcd = '81'
                            and tl.txnum = tla1.txnum and tl.txdate = tla1.txdate and tla1.fldcd = '18' AND TLA1.CVALUE='010'
                            AND tl.txdate = tla2.txdate and tl.txnum = tla2.txnum and tla2.fldcd = '79' AND NVL(TLA2.CVALUE,'111') <> '111'
                             AND TL.BUSDATE >= V_F_DATE AND TL.BUSDATE <= V_T_DATE AND TL.DELTD <> 'Y'

             union all

            select '' acctno, tl.tltxcd,  tl.busdate txdate , tl.txnum, '' txcd, tl.msgamt namt, 'BALANCE' FIELD ,
                   'C' TXTYPE, tl.txdesc, TL.MSGACCT TRANSSUBTYPE
            from tllog tl
               where tl.tltxcd like '9950'
                     AND TL.BUSDATE >= V_F_DATE AND TL.BUSDATE <= V_T_DATE AND TL.DELTD <> 'Y'
            union all
            select '' acctno, tl.tltxcd,  tl.busdate txdate , tl.txnum, '' txcd, tl.msgamt namt, 'BALANCE' FIELD ,
                   'D' TXTYPE, tl.txdesc, TL.MSGACCT TRANSSUBTYPE
            from tllog tl
               where tl.tltxcd like '9951'
                     AND TL.BUSDATE >= V_F_DATE AND TL.BUSDATE <= V_T_DATE AND TL.DELTD <> 'Y'
            union all

            select tl.msgacct acctno, tl.tltxcd, tl.txdate, tl.txnum, '' txcd, abs(tl.msgamt) namt, 'BALANCE' FIELD ,
            case when tl.msgamt <0 then 'D' else 'C' end TXTYPE, tl.txdesc, CVALUE TRANSSUBTYPE from tllog tl, tllogfld tla
                where tl.tltxcd like '1136' and tl.txnum = tla.txnum and tl.txdate = tla.txdate and tla.fldcd = '05'
                 AND TL.BUSDATE >= V_F_DATE AND TL.BUSDATE <= V_T_DATE AND TL.DELTD <> 'Y'
            union all

                select '' acctno, tl.tltxcd, tl.txdate, tl.txnum, '' txcd, tl.msgamt namt, 'BALANCE' FIELD , 'D' TXTYPE,tl.txdesc, CVALUE TRANSSUBTYPE from tllog tl, tllogfld tla
                 where tl.tltxcd like '1121' and tl.txnum = tla.txnum and tl.txdate = tla.txdate and tla.fldcd = '05'
                 AND TL.BUSDATE >= V_F_DATE AND TL.BUSDATE <= V_T_DATE AND TL.DELTD <> 'Y'

            union all
            select '' acctno, tl.tltxcd, tl.txdate, tl.txnum, '' txcd, tl.msgamt namt, 'BALANCE' FIELD , 'C' TXTYPE,tl.txdesc, TLA.CVALUE TRANSSUBTYPE
                    from tllog tl, tllogfld tla, tllogfld tla1, tllogfld tla2
                       where tl.tltxcd like '1121' and tl.txnum = tla.txnum and tl.txdate = tla.txdate and tla.fldcd = '81'
                            and tl.txnum = tla1.txnum and tl.txdate = tla1.txdate and tla1.fldcd = '18' AND TLA1.CVALUE='010'
                            AND tl.txnum = tla2.txnum and tl.txdate = tla2.txdate and tla2.fldcd = '79' AND NVL(TLA2.CVALUE,'111') <> '111'
                             AND TL.BUSDATE >= V_F_DATE AND TL.BUSDATE <= V_T_DATE AND TL.DELTD <> 'Y'
                union all

                select tl.msgacct acctno, tl.tltxcd, tl.txdate, tl.txnum, '' txcd, tl.msgamt namt, 'BALANCE' FIELD , 'C' TXTYPE,   tl.txdesc,CVALUE TRANSSUBTYPE from tllog tl, tllogfld tla
                where tl.tltxcd in ('1131') and tl.txnum = tla.txnum and tl.txdate = tla.txdate and tla.fldcd = '69' and tla.cvalue not in ('111111','222222','333333','444444','555555','666666')
                      AND TL.BUSDATE >= V_F_DATE AND TL.BUSDATE <= V_T_DATE AND TL.DELTD <> 'Y'
                union all

                select tl.msgacct acctno, tl.tltxcd, tl.txdate, tl.txnum, '' txcd, tl.msgamt namt, 'BALANCE' FIELD ,  'D' TXTYPE, tl.txdesc, CVALUE TRANSSUBTYPE from tllog tl, tllogfld tla
                where tl.tltxcd in ('1132') and tl.txnum = tla.txnum and tl.txdate = tla.txdate and tla.fldcd = '69' and tla.cvalue not in ('111111','222222','333333','444444','555555','666666')
                      AND TL.BUSDATE >= V_F_DATE AND TL.BUSDATE <= V_T_DATE AND TL.DELTD <> 'Y'

                 union all


/*            select tl.msgacct acctno, tl.tltxcd, tl.txdate, tl.txnum, '' txcd, tl.msgamt namt, 'BALANCE' FIELD ,  'D' TXTYPE, tl.txdesc, CVALUE TRANSSUBTYPE from tllog tl, tllogfld tla
            where tl.tltxcd in ('6645','6647') and tl.txnum = tla.txnum and tl.txdate = tla.txdate and tla.fldcd = '06' and tla.cvalue not in ('111111','222222','333333','444444','555555','666666')
                  AND TL.BUSDATE >= V_F_DATE AND TL.BUSDATE <= V_T_DATE AND TL.DELTD <> 'Y'*/
            select tl.msgacct acctno, tl.tltxcd, tl.txdate, tl.txnum, '' txcd, tl.msgamt namt, 'BALANCE' FIELD ,  'D' TXTYPE, tl.txdesc, CVALUE TRANSSUBTYPE from tllog tl, tllogfld tla
            where tl.tltxcd in ('6645') and tl.txnum = tla.txnum and tl.txdate = tla.txdate and tla.fldcd = '06' and tla.cvalue not in ('111111','222222','333333','444444','555555','666666')
                  AND TL.BUSDATE >= V_F_DATE AND TL.BUSDATE <= V_T_DATE AND TL.DELTD <> 'Y'

            union all

           /* select tl.msgacct acctno, tl.tltxcd, tl.txdate, tl.txnum, '' txcd, tl.msgamt namt, 'BALANCE' FIELD ,  'C' TXTYPE, tl.txdesc, CVALUE TRANSSUBTYPE from tllog tl, tllogfld tla
            where tl.tltxcd in ('6648') and tl.txnum = tla.txnum and tl.txdate = tla.txdate and tla.fldcd = '05' and tla.cvalue not in ('111111','222222','333333','444444','555555','666666')
                  AND TL.BUSDATE >= V_F_DATE AND TL.BUSDATE <= V_T_DATE AND TL.DELTD <> 'Y'
            union all*/

/*            select tl.msgacct acctno, tl.tltxcd, tl.txdate, tl.txnum, '' txcd, tl.msgamt namt, 'BALANCE' FIELD , 'D' TXTYPE,tl.txdesc, CVALUE TRANSSUBTYPE from tllog tl, tllogfld tla
                        where tl.tltxcd like '6669' and tl.txnum = tla.txnum and tl.txdate = tla.txdate and tla.fldcd = '05'
                         AND TL.BUSDATE >= V_F_DATE AND TL.BUSDATE <= V_T_DATE AND TL.DELTD <> 'Y'*/

        --- 6669 DI BANG KE
        select tl.msgacct acctno, tl.tltxcd, tl.txdate, tl.txnum, '' txcd, tl.msgamt namt, 'BALANCE' FIELD , 'D' TXTYPE,tl.txdesc, CVALUE TRANSSUBTYPE
            from tllog tl, tllogfld tla, CRBTXREQ CRB
            where tl.tltxcd like '6669' and tl.txnum = tla.txnum and tl.txdate = tla.txdate and tla.fldcd = '05' AND TL.DELTD <> 'Y'
            AND TL.TXDATE = CRB.TXDATE AND TL.TXNUM = CRB.OBJKEY AND BANKCODE LIKE 'BIDV%'
            AND TL.BUSDATE >= V_F_DATE AND TL.BUSDATE <= V_T_DATE

        union all

        --- 6669 DI TCH
        select tl.msgacct acctno, tl.tltxcd, tl.txdate, tl.txnum, '' txcd, tl.msgamt namt, 'BALANCE' FIELD , 'D' TXTYPE,tl.txdesc,
                CASE WHEN BANKCODE= 'TCDTHN' THEN '12310000388826'
                    WHEN BANKCODE= 'TCDTHCM' THEN '12310000392049'
                ELSE 'KHAC' END
                  TRANSSUBTYPE
            from tllog tl ,CRBTXREQ CRB
            where tl.tltxcd like '6669' AND TL.DELTD <> 'Y'
            AND TL.TXDATE = CRB.TXDATE AND TL.TXNUM = CRB.OBJKEY AND BANKCODE LIKE 'TCDT%'
            AND TL.BUSDATE >= V_F_DATE AND TL.BUSDATE <= V_T_DATE



            union all

/*            SELECT ci.acctno, ci.tltxcd, CI.txdate, ci.txnum, ci.txcd, ci.namt, ci.field,
             case when ci.tltxcd in ('1182','1189') then 'C' else ci.txtype end txtype, ci.txdesc,
                           CASE
                                 WHEN CI.TLTXCD IN ('1182','1184') and aft.corebank = 'Y' and substr(ci.acctno,1,4) = '0001' THEN '12310000349850'
                                 WHEN CI.TLTXCD IN ('1189') and aft.corebank = 'Y' and substr(ci.txnum,1,4) = '0001' THEN '12310000349850'
                                 WHEN CI.TLTXCD IN ('1189','1182') and aft.corebank = 'Y' and substr(ci.acctno,1,4) = '0101' THEN '31010000637805'
                                 WHEN CI.TLTXCD IN ('1184') and aft.corebank = 'Y' and substr(ci.acctno,1,4) = '0101' THEN '31010000462867'

                                 else 'KHAC' END TRANSSUBTYPE
                        FROM
                            vw_citran   ci,aftype aft, afmast af
                    WHERE ci.acctno = af.acctno and af.actype = aft.actype
                        and BUSDATE >= V_F_DATE AND BUSDATE <= V_T_DATE
                        and tltxcd IN ('1182','1189','1184')
                            AND ci.field = 'BALANCE'*/

             SELECT ci.acctno, ci.tltxcd, CI.txdate, ci.txnum, ci.txcd, ci.namt, ci.field,
                    case when ci.tltxcd in ('1182','1189') then 'C' else ci.txtype end txtype, ci.txdesc,
                       CASE
                             WHEN CI.TLTXCD IN ('1182','1184') and ci.corebank = 'Y'  and substr(ci.acctno,1,4) = '0001' THEN '12310000349850'
                             WHEN CI.TLTXCD IN ('1189') and ci.corebank = 'Y'  and substr(ci.txnum,1,4) = '0001' THEN '12310000349850'
                             WHEN CI.TLTXCD IN ('1189','1182') and ci.corebank = 'Y' and substr(CI.acctno,1,4) = '0101' THEN '31010000637805'
                             WHEN CI.TLTXCD IN ('1184') and ci.corebank = 'Y' and substr(ci.acctno,1,4) = '0101' THEN '31010000462867'

                             else 'KHAC' END TRANSSUBTYPE
                    FROM
                        vw_citran   ci
                    WHERE BUSDATE >= V_F_DATE AND BUSDATE <= V_T_DATE
                    and tltxcd IN ('1182','1189','1184')
                        AND ci.field = 'BALANCE'

            union all

/*            SELECT ci.acctno, ci.tltxcd, CI.txdate, ci.txnum, ci.txcd, ci.namt, ci.field,
                    case when CI.TLTXCD IN ('8855','8856','8865','0066') then 'C'
                          when CI.TLTXCD IN ('8866') then 'D'
                          else ci.txtype end
                     txtype, ci.txdesc,
                       CASE
                             WHEN CI.TLTXCD IN ('8855','8856') and substr(CI.acctno,1,4) = '0001' and aft.corebank = 'Y' THEN '12310000349850'
                             WHEN CI.TLTXCD IN ('8865','8866') and substr(CI.acctno,1,4) = '0001' and aft.corebank = 'Y' THEN '12312000002335'
                             WHEN CI.TLTXCD IN ('8855','8856','8865','8866') and substr(CI.acctno,1,4) = '0101' and aft.corebank = 'Y' THEN '31010000462867'
                             WHEN CI.TLTXCD IN ('0066') and substr(CI.acctno,1,4) = '0001' and aft.corebank = 'Y' THEN '12310000349850'
                             WHEN CI.TLTXCD IN ('0066') and substr(CI.acctno,1,4) = '0101' and aft.corebank = 'Y' THEN '31010000637805'

                             else 'KHAC' END TRANSSUBTYPE
                    FROM
                        vw_citran   ci,aftype aft, afmast af
                    WHERE ci.acctno = af.acctno and af.actype = aft.actype
                    and ci.BUSDATE  >= V_F_DATE AND ci.BUSDATE <= V_T_DATE
                    and (ci.tltxcd IN ('8855','8856','8865','8866') or (ci.tltxcd in ('0066') and txcd = '0011'))
                    AND ci.field = 'BALANCE'*/

            SELECT ci.acctno, ci.tltxcd, CI.txdate, ci.txnum, ci.txcd, ci.namt, ci.field,
                    case when CI.TLTXCD IN ('8855','8856','8865','0066') then 'C'
                          when CI.TLTXCD IN ('8866') then 'D'
                          else ci.txtype end
                     txtype, ci.txdesc,
                       CASE
                             WHEN CI.TLTXCD IN ('8855','8856') and substr(CI.acctno,1,4) = '0001' and ci.corebank = 'Y' THEN '12310000349850'
                             WHEN CI.TLTXCD IN ('8865','8866') and substr(CI.acctno,1,4) = '0001' and ci.corebank = 'Y' THEN '12312000002335'
                             WHEN CI.TLTXCD IN ('8855','8856','8865','8866') and substr(CI.acctno,1,4) = '0101' and ci.corebank = 'Y' THEN '31010000462867'
                             WHEN CI.TLTXCD IN ('0066') and substr(CI.acctno,1,4) = '0001' and ci.corebank = 'Y' THEN '12310000349850'
                             WHEN CI.TLTXCD IN ('0066') and substr(CI.acctno,1,4) = '0101' and ci.corebank = 'Y' THEN '31010000637805'

                             else 'KHAC' END TRANSSUBTYPE
                    FROM
                        vw_citran   ci
                    WHERE ci.BUSDATE  >= V_F_DATE AND ci.BUSDATE <= V_T_DATE
                    and (ci.tltxcd IN ('8855','8856','8865','8866') or (ci.tltxcd in ('0066') and txcd = '0011'))
                    AND ci.field = 'BALANCE'


            union all

               /*SELECT ci.acctno, ci.tltxcd, CI.txdate, ci.txnum, ci.txcd, ci.namt, ci.field, 'D' txtype, ci.txdesc,
                               CASE
                                     WHEN substr(ci.acctno,1,4) = '0001' and aft.corebank = 'Y' THEN '12312000002335'
                                     WHEN substr(ci.acctno,1,4) = '0101' and aft.corebank = 'Y' THEN '31010000462867'
                                     else 'KHAC' END TRANSSUBTYPE
                            FROM
                                vw_citran   ci, aftype aft, afmast af
                            WHERE ci.acctno = af.acctno and af.actype = aft.actype
                            and BUSDATE >= V_F_DATE AND BUSDATE <= V_T_DATE
                            and tltxcd IN ('3350') and txcd = '0012'
                                AND ci.field = 'BALANCE'*/
                    SELECT ci.acctno, ci.tltxcd, CI.txdate, ci.txnum, ci.txcd, ci.namt, ci.field, 'D' txtype, ci.txdesc,
                               CASE
                                     WHEN substr(ci.acctno,1,4) = '0001' and ci.corebank = 'Y' THEN '12312000002335'
                                     WHEN substr(ci.acctno,1,4) = '0101' and ci.corebank = 'Y' THEN '31010000462867'
                                     else 'KHAC' END TRANSSUBTYPE
                            FROM
                                vw_citran   ci
                            WHERE BUSDATE >= V_F_DATE AND BUSDATE <= V_T_DATE
                            and tltxcd IN ('3350') and txcd = '0012'
                                AND ci.field = 'BALANCE'

                union all
/*
               SELECT ci.acctno, ci.tltxcd, CI.txdate, ci.txnum, ci.txcd, ci.namt, ci.field, 'D' txtype, ci.txdesc,
                               CASE
                                     WHEN substr(ci.acctno,1,4) = '0001' and aft.corebank = 'Y' THEN '12312000002335'
                                     WHEN substr(ci.acctno,1,4) = '0101' and aft.corebank = 'Y' THEN '31010000462867'
                                     else 'KHAC' END TRANSSUBTYPE
                            FROM
                                vw_citran   ci, aftype aft, afmast af
                            WHERE ci.acctno = af.acctno and af.actype = aft.actype
                            and BUSDATE >= V_F_DATE AND BUSDATE <= V_T_DATE
                            and tltxcd IN ('3354') and txcd = '0012'
                                AND ci.field = 'BALANCE'
*/
               SELECT ci.acctno, ci.tltxcd, CI.txdate, ci.txnum, ci.txcd, ci.namt, ci.field, 'D' txtype, ci.txdesc,
                               CASE
                                     WHEN substr(ci.acctno,1,4) = '0001' and ci.corebank = 'Y' THEN '12312000002335'
                                     WHEN substr(ci.acctno,1,4) = '0101' and ci.corebank = 'Y' THEN '31010000462867'
                                     else 'KHAC' END TRANSSUBTYPE
                            FROM
                                vw_citran   ci
                            WHERE BUSDATE >= V_F_DATE AND BUSDATE <= V_T_DATE
                            and tltxcd IN ('3354') and txcd = '0012'
                                AND ci.field = 'BALANCE'

                union all

                 /*    SELECT ci.acctno, ci.tltxcd, CI.txdate, ci.txnum, ci.txcd, ci.namt, ci.field,
                   case when ci.txcd ='0011' then 'C' else 'D' end  txtype,ci.txdesc,
                                   CASE
                                         WHEN substr(CI.txnum,1,4) = '0001' and aft.corebank = 'Y'  and txcd = '0011' THEN '12312000002335'
                                         WHEN substr(CI.txnum,1,4) = '0101' and aft.corebank = 'Y'  and txcd = '0011' THEN '31010000462867'
                                         WHEN substr(CI.txnum,1,4) = '0101' and aft.corebank = 'Y'  and txcd = '0012' THEN '31010000462867'
                                   else 'KHAC' END TRANSSUBTYPE
                                FROM
                                    vw_citran   ci,aftype aft, afmast af
                                WHERE ci.acctno = af.acctno and af.actype = aft.actype
                                and BUSDATE >= V_F_DATE AND BUSDATE <= V_T_DATE
                                and tltxcd IN ('8842') and txcd in ('0012' ,'0011')
                                    AND ci.field = 'BALANCE'*/
    SELECT ci.acctno, ci.tltxcd, CI.txdate, ci.txnum, ci.txcd, ci.namt, ci.field,
                   case when ci.txcd ='0011' then 'C' else 'D' end  txtype,ci.txdesc,
                                   CASE
                                         WHEN substr(CI.txnum,1,4) = '0001' and ci.corebank = 'Y'  and txcd = '0011' THEN '12312000002335'
                                         WHEN substr(CI.txnum,1,4) = '0101' and ci.corebank = 'Y'  and txcd = '0011' THEN '31010000462867'
                                         WHEN substr(CI.txnum,1,4) = '0101' and ci.corebank = 'Y'  and txcd = '0012' THEN '31010000462867'
                                   else 'KHAC' END TRANSSUBTYPE
                                FROM
                                    vw_citran   ci
                                WHERE BUSDATE >= V_F_DATE AND BUSDATE <= V_T_DATE
                                and tltxcd IN ('8842') and txcd in ('0012' ,'0011')
                                    AND ci.field = 'BALANCE'

                union all

                             /* SELECT ci.acctno, ci.tltxcd, CI.txdate, ci.txnum, ci.txcd, ci.namt, ci.field, 'D' txtype,ci.txdesc,
                                   CASE
                                         WHEN CI.TLTXCD IN ('8848','8849') and aft.corebank = 'Y'  AND substr(CI.txnum,1,4) = '0001' and txcd = '0012' THEN '12312000002335'
                                         WHEN CI.TLTXCD IN ('8848','8849') and aft.corebank = 'Y'  AND substr(CI.txnum,1,4) = '0101' and txcd = '0012' THEN '31010000462867'
                                   else 'KHAC' END TRANSSUBTYPE
                                FROM
                                    vw_citran   ci,aftype aft, afmast af
                                WHERE ci.acctno = af.acctno and af.actype = aft.actype
                                and BUSDATE >= V_F_DATE AND BUSDATE <= V_T_DATE
                                and tltxcd IN ('8848','8849') and txcd in ('0012')
                                    AND ci.field = 'BALANCE'*/
                    SELECT ci.acctno, ci.tltxcd, CI.txdate, ci.txnum, ci.txcd, ci.namt, ci.field, 'D' txtype,ci.txdesc,
                                   CASE
                                         WHEN CI.TLTXCD IN ('8848','8849') and ci.corebank = 'Y'  AND substr(CI.txnum,1,4) = '0001' and txcd = '0012' THEN '12312000002335'
                                         WHEN CI.TLTXCD IN ('8848','8849') and ci.corebank = 'Y'  AND substr(CI.txnum,1,4) = '0101' and txcd = '0012' THEN '31010000462867'
                                   else 'KHAC' END TRANSSUBTYPE
                                FROM
                                    vw_citran   ci
                                WHERE BUSDATE >= V_F_DATE AND BUSDATE <= V_T_DATE
                                and tltxcd IN ('8848','8849') and txcd in ('0012')
                                    AND ci.field = 'BALANCE'


                union all


      /*                      SELECT ci.acctno, ci.tltxcd, CI.txdate, ci.txnum, ci.txcd,
                                  case when substr(CI.acctno,1,4) = '0001' and tl3.cvalue='1' then  ci.namt
                                     when substr(CI.acctno,1,4) = '0001' and tl3.cvalue='0' then  ci.namt - tl1.nvalue - tl2.nvalue
                                     when substr(CI.acctno,1,4) = '0101' and tl3.cvalue='1' then  ci.namt + tl1.nvalue + tl2.nvalue
                                     when substr(CI.acctno,1,4) = '0101' and tl3.cvalue='0' then  ci.namt
                                     else ci.namt
                                end namt
                                , ci.field, ci.txtype, ci.txdesc,
                                  tl.cvalue TRANSSUBTYPE
                                FROM
                                    vw_citran   ci, tllogfld tl, tllogfld tl1, tllogfld tl2, tllogfld tl3
                                WHERE ci.txdate = tl.txdate and ci.txnum = tl.txnum and tl.fldcd='08'
                                and ci.txdate = tl1.txdate and ci.txnum = tl1.txnum and tl1.fldcd='11'
                                and ci.txdate = tl2.txdate and ci.txnum = tl2.txnum and tl2.fldcd='13'
                                and ci.txdate = tl3.txdate and ci.txnum = tl3.txnum and tl3.fldcd='09'
                                and BUSDATE >= V_F_DATE AND BUSDATE <= V_T_DATE
                                and ci.tltxcd IN ('1104')
                                    AND ci.field = 'FLOATAMT'*/

    ---Di UNC th??y 1104
 SELECT ci.acctno, ci.tltxcd, CI.txdate, ci.txnum, ci.txcd,
     case when substr(CI.acctno,1,4) = '0001' and CIR.FEETYPE='1' then  ci.namt
        when substr(CI.acctno,1,4) = '0001' and CIR.FEETYPE='0' then  ci.namt - CIR.FEEAMT - CIR.VAT
        when substr(CI.acctno,1,4) = '0101' and CIR.FEETYPE='1' then  ci.namt + CIR.FEEAMT + CIR.VAT
        when substr(CI.acctno,1,4) = '0101' and CIR.FEETYPE='0' then  ci.namt
        else ci.namt
    end namt
    , ci.field, ci.txtype, ci.txdesc,
     tl.cvalue TRANSSUBTYPE

    FROM
       vw_citran   ci, tllogfld tl, tllogfld tl5
       , tllogfld tl4 ,       CIREMITTANCE CIR
    WHERE
    ci.txdate = tl4.txdate and ci.txnum = tl4.txnum and tl4.fldcd='07'
    AND ci.txdate = tl5.txdate and ci.txnum = tl5.txnum and tl5.fldcd='06'
    AND TO_DATE(nvl(tl5.CVALUE,ci.txdate),'DD/MM/RRRR') = CIR.TXDATE AND TL4.CVALUE = CIR.TXNUM AND CIR.RMSTATUS = 'C'
    and ci.txdate = tl.txdate and ci.txnum = tl.txnum and tl.fldcd='08'
    and ci.tltxcd IN ('1104')
    AND ci.field = 'FLOATAMT'
    and CI.TXNUM LIKE '0%'
   and ci.BUSDATE >= V_F_DATE AND ci.BUSDATE <= V_T_DATE

    union all

     ---Di THCH th?ay 1101
    SELECT ci.acctno, ci.tltxcd, CI.txdate, ci.txnum, ci.txcd,
     case when CIR.FEETYPE='1' then  ci.namt
        when CIR.FEETYPE='0' then  ci.namt - CIR.FEEAMT - CIR.VAT
        else ci.namt
    end namt
    , ci.field, ci.txtype, ci.txdesc,
      case  when substr(CI.acctno,1,4) = '0001' then  '12310000388826'
            when substr(CI.acctno,1,4) = '0101' then  '12310000392049'
            else 'KHAC'
      end TRANSSUBTYPE

    FROM
       vw_citran ci,CIREMITTANCE CIR, crbtxreq CRB
    WHERE
        CI.TXDATE = CIR.TXDATE AND ci.txnum = CIR.TXNUM --AND CIR.RMSTATUS = 'C'
        AND ci.txdate = CRB.txdate and ci.txnum = CRB.OBJKEY -- AND CRB.STATUS = 'C'
        and ci.tltxcd IN ('1101') AND ci.field = 'BALANCE'
        and txcd = '0011'
        and ci.BUSDATE >= V_F_DATE AND ci.BUSDATE <= V_T_DATE

    union all

    --- lay 1111
    SELECT ci.acctno, ci.tltxcd, CI.txdate, ci.txnum, ci.txcd,
    case when CIR.FEETYPE='1' then  ci.namt
        when CIR.FEETYPE='0' then  ci.namt - CIR.FEEAMT - CIR.VAT
        else ci.namt
    end namt
    , ci.field, ci.txtype, ci.txdesc,
      case  when substr(CI.acctno,1,4) = '0001' then  '12310000388826'
            when substr(CI.acctno,1,4) = '0101' then  '12310000392049'
            else 'KHAC'
      end TRANSSUBTYPE
    FROM
       vw_citran ci, CIREMITTANCE CIR, crbtxreq CRB
    WHERE CI.TLTXCD = '1111' AND CI.FIELD = 'BALANCE'
        AND CI.TXDATE  = CIR.TXDATE AND ci.txnum = CIR.TXNUM AND CIR.RMSTATUS = 'C'
        AND ci.txdate = CRB.txdate and ci.txnum = CRB.OBJKEY AND CRB.STATUS = 'C'
        and ci.BUSDATE >= V_F_DATE AND ci.BUSDATE <= V_T_DATE

    union all

    -- 1114
    SELECT ci.acctno, ci.tltxcd, CI.txdate, ci.txnum, ci.txcd,
     case when CIR.FEETYPE='1' then  ci.namt
        when CIR.FEETYPE='0' then  ci.namt - CIR.FEEAMT - CIR.VAT
        else ci.namt
    end namt
    , ci.field, ci.txtype, ci.txdesc,
      case  when substr(CI.acctno,1,4) = '0001' then  '12310000388826'
            when substr(CI.acctno,1,4) = '0101' then  '12310000392049'
            else 'KHAC'
      end TRANSSUBTYPE
    FROM
       vw_citran ci, CIREMITTANCE CIR--, vw_crbtxreq_all CRB
    WHERE CI.TLTXCD = '1114' AND CI.FIELD = 'BALANCE'
        and length(nvl(cir.bankid,''))>0
        --AND TO_DATE(substr(CI.ref,11),'DD/MM/RRRR') = CIR.TXDATE
        AND substr(NVL(CI.ref,'000000000001/01/2001'),11) = NVL(TO_CHAR(CIR.TXDATE),'01/01/2001')
        AND substr(CI.ref,1,10) = CIR.TXNUM AND CIR.RMSTATUS <> 'C'
        and ci.BUSDATE >= V_F_DATE AND ci.BUSDATE <= V_T_DATE







                union all


               SELECT ci.acctno, ci.tltxcd, CI.txdate, ci.txnum, ci.txcd, ci.namt, ci.field, ci.txtype, ci.txdesc,
                              tl.cvalue TRANSSUBTYPE
                            FROM
                                vw_citran   ci, tllogfld tl
                            WHERE ci.txdate = tl.txdate and ci.txnum = tl.txnum and tl.fldcd='05'
                            and ci.BUSDATE >= V_F_DATE AND ci.BUSDATE <= V_T_DATE
                            and ci.tltxcd IN ('1141')
                                AND ci.field = 'BALANCE'


                union all

                    SELECT ci.acctno, ci.tltxcd, CI.txdate, ci.txnum, ci.txcd, ci.namt, ci.field, 'C' txtype, ci.txdesc,
                       CASE
                             WHEN substr(txnum,1,4) = '0001' and ci.corebank = 'Y' and nvl(trdesc,'xxx') like '%Thu phi%' THEN '12310000349850'
                             WHEN substr(txnum,1,4) = '0101' and ci.corebank = 'Y' and nvl(trdesc,'xxx') like '%Thu phi%' THEN '31010000637805'
                             WHEN substr(txnum,1,4) = '0001' and ci.corebank = 'Y' and nvl(trdesc,'xxx') not like '%Thu phi%' THEN '12312000002335'
                             WHEN substr(txnum,1,4) = '0101' and ci.corebank = 'Y' and nvl(trdesc,'xxx') not like '%Thu phi%' THEN '31010000462867'
                             else 'KHAC' END TRANSSUBTYPE

                    FROM vw_citran CI
                    WHERE  CI.TLTXCD IN ('0088')
                    and ci.BUSDATE >= V_F_DATE AND ci.BUSDATE <= V_T_DATE
                    AND  (FIELD = 'BALANCE' AND TXCD = '0011')

                union all
/*
                            SELECT ci.acctno, ci.tltxcd, CI.txdate, ci.txnum, ci.txcd, ci.namt, ci.field, 'C' txtype, ci.txdesc,
                               CASE
                                     WHEN CI.TLTXCD IN ('1190') and substr(CI.txnum,1,4) = '0001' and ci.corebank = 'Y' and tl.cvalue in('001','008') THEN '12312000002335'
                                     WHEN CI.TLTXCD IN ('1190') and substr(CI.txnum,1,4) = '0101' and ci.corebank = 'Y' and tl.cvalue in('001','008') THEN '31010000462867'
                                     WHEN CI.TLTXCD IN ('1190') and substr(CI.txnum,1,4) = '0001' and ci.corebank = 'Y' and tl.cvalue in ('002','003','004') THEN '12310000349850'
                                     WHEN CI.TLTXCD IN ('1190') and substr(CI.txnum,1,4) = '0101' and ci.corebank = 'Y' and tl.cvalue in ('002','003','004') THEN '31010000462867'
                                     WHEN CI.TLTXCD IN ('1190') and substr(CI.txnum,1,4) = '0101' and ci.corebank = 'Y' and tl.cvalue in ('005') THEN '31010000462867'
                                     else 'KHAC' END TRANSSUBTYPE
                            FROM
                                vw_citran   ci, tllogfld tl
                            WHERE ci.txdate = tl.txdate and ci.txnum = tl.txnum and tl.fldcd='09'
                            and ci.BUSDATE >= V_F_DATE AND ci.BUSDATE <= V_T_DATE
                            and ci.tltxcd IN ('1190')
                                AND ci.field = 'BALANCE'
                union all*/

                 /*SELECT ci.acctno, ci.tltxcd, CI.txdate, ci.txnum, ci.txcd, ci.namt, ci.field,
                 case when ci.tltxcd in ('1180','3384','3394') then 'C'
                      when ci.tltxcd in ('3386') then 'D'
                      else ci.txtype end txtype,
                 ci.txdesc,
                               CASE
                                     WHEN CI.TLTXCD IN ('1180') and substr(CI.txnum,1,4) = '0001' and aft.corebank = 'Y' THEN '12310000349850'
                                     WHEN CI.TLTXCD IN ('1180') and substr(CI.txnum,1,4) = '0101' and aft.corebank = 'Y' THEN '31010000637805'
    --                                 WHEN CI.TLTXCD IN ('1182') and substr(CI.acctno,1,4) = '0001' and aft.corebank = 'Y' THEN '12310000349850'
    --                                 WHEN CI.TLTXCD IN ('1182') and substr(CI.acctno,1,4) = '0101' and aft.corebank = 'Y' THEN '31010000637805'
                                     WHEN CI.TLTXCD IN ('3384','3394') and substr(CI.txnum,1,4) = '0001' and aft.corebank = 'Y' THEN '12312000002335'
                                     WHEN CI.TLTXCD IN ('3384','3394') and substr(CI.txnum,1,4) = '0101' and aft.corebank = 'Y' THEN '31010000462867'
                                     WHEN CI.TLTXCD IN ('3386') and substr(CI.txnum,1,4) = '0001' and aft.corebank = 'Y' THEN '12312000002335'
                                     WHEN CI.TLTXCD IN ('3386') and substr(CI.txnum,1,4) = '0101' and aft.corebank = 'Y' THEN '31010000462867'

                                     else 'KHAC' END TRANSSUBTYPE
                            FROM
                                vw_citran   ci,aftype aft, afmast af
                            WHERE ci.acctno = af.acctno and af.actype = aft.actype
                            and ci.BUSDATE >= V_F_DATE AND ci.BUSDATE <= V_T_DATE
                            and (ci.tltxcd IN ('1180','3384','3394') or (ci.tltxcd ='3386' and ci.txtype = 'C' ))
                                AND ci.field = 'BALANCE'*/
                SELECT ci.acctno, ci.tltxcd, CI.txdate, ci.txnum, ci.txcd, ci.namt, ci.field,
                 case when ci.tltxcd in ('1180','3384','3394') then 'C'
                      when ci.tltxcd in ('3386') then 'D'
                      else ci.txtype end txtype,
                 ci.txdesc,
                               CASE
                                     WHEN CI.TLTXCD IN ('1180') and substr(CI.acctno,1,4) = '0001' and ci.corebank = 'Y' THEN '12310000349850'
                                     WHEN CI.TLTXCD IN ('1180') and substr(CI.acctno,1,4) = '0101' and ci.corebank = 'Y' THEN '31010000637805'
                                     WHEN CI.TLTXCD IN ('3384','3394') and substr(CI.acctno,1,4) = '0001' and ci.corebank = 'Y' THEN '12312000002335'
                                     WHEN CI.TLTXCD IN ('3384','3394') and substr(CI.acctno,1,4) = '0101' and ci.corebank = 'Y' THEN '31010000462867'
                                     WHEN CI.TLTXCD IN ('3386') and substr(CI.acctno,1,4) = '0001' and ci.corebank = 'Y' THEN '12312000002335'
                                     WHEN CI.TLTXCD IN ('3386') and substr(CI.acctno,1,4) = '0101' and ci.corebank = 'Y' THEN '31010000462867'

                                     else 'KHAC' END TRANSSUBTYPE
                            FROM
                                vw_citran   ci
                            WHERE ci.BUSDATE >= V_F_DATE AND ci.BUSDATE <= V_T_DATE
                            and (ci.tltxcd IN ('1180','3384','3394') or (ci.tltxcd ='3386' and ci.txtype = 'C' ))
                                AND ci.field = 'BALANCE'
                union all

                 /*SELECT ci.acctno, ci.tltxcd, CI.txdate, ci.txnum, ci.txcd, ci.namt, ci.field,
                 case when ci.tltxcd in('1137','1138') then 'D'
                 when ci.tltxcd in('8851') then 'C'
                 else ci.txtype end txtype,
                 ci.txdesc,
                               CASE
                                     WHEN CI.TLTXCD IN ('8851') and substr(CI.acctno,1,4) = '0001' and aft.corebank = 'Y' THEN '12312000002335'
                                     WHEN CI.TLTXCD IN ('8851') and substr(CI.acctno,1,4) = '0101' and aft.corebank = 'Y' THEN '31010000462867'
                                     WHEN CI.TLTXCD IN ('1168','1169') and substr(CI.txnum,1,4) = '0001' and aft.corebank = 'Y' THEN '12312000002335'
                                     WHEN CI.TLTXCD IN ('1168','1169') and substr(CI.txnum,1,4) = '0101' and aft.corebank = 'Y' THEN '31010000462867'
                                     WHEN CI.TLTXCD IN ('1137','1138') and substr(CI.acctno,1,4) = '0001' and aft.corebank = 'Y' THEN '12310000349850'
                                     WHEN CI.TLTXCD IN ('1137') and substr(CI.txnum,1,4) = '0101' and aft.corebank = 'Y' THEN '31010000637805'
                                     WHEN CI.TLTXCD IN ('1138') and substr(CI.acctno,1,4) = '0101' and aft.corebank = 'Y' THEN '31010000462867'
                                     else 'KHAC' END TRANSSUBTYPE
                            FROM
                                vw_citran   ci,aftype aft, afmast af
                            WHERE ci.acctno = af.acctno and af.actype = aft.actype
                            and ci.BUSDATE >= V_F_DATE AND ci.BUSDATE <= V_T_DATE
                            and (ci.tltxcd IN ('8851','1168','1169') or (ci.tltxcd IN ('1137','1138') and txtype = 'C'))
                                AND ci.field = 'BALANCE'*/
                SELECT ci.acctno, ci.tltxcd, CI.txdate, ci.txnum, ci.txcd, ci.namt, ci.field,
                 case when ci.tltxcd in('1137','1138') then 'D'
                 when ci.tltxcd in('8851') then 'C'
                 else ci.txtype end txtype,
                 ci.txdesc,
                               CASE
                                     WHEN CI.TLTXCD IN ('8851') and substr(CI.acctno,1,4) = '0001' and ci.corebank = 'Y' THEN '12312000002335'
                                     WHEN CI.TLTXCD IN ('8851') and substr(CI.acctno,1,4) = '0101' and ci.corebank = 'Y' THEN '31010000462867'
                                     WHEN CI.TLTXCD IN ('1168','1169') and substr(CI.txnum,1,4) = '0001' and ci.corebank = 'Y' THEN '12312000002335'
                                     WHEN CI.TLTXCD IN ('1168','1169') and substr(CI.txnum,1,4) = '0101' and ci.corebank = 'Y' THEN '31010000462867'
                                     WHEN CI.TLTXCD IN ('1137','1138') and substr(CI.acctno,1,4) = '0001' and ci.corebank = 'Y' THEN '12310000349850'
                                     WHEN CI.TLTXCD IN ('1137') and substr(CI.txnum,1,4) = '0101' and ci.corebank = 'Y' THEN '31010000637805'
                                     WHEN CI.TLTXCD IN ('1138') and substr(CI.acctno,1,4) = '0101' and ci.corebank = 'Y' THEN '31010000462867'
                                     else 'KHAC' END TRANSSUBTYPE
                            FROM
                                vw_citran   ci
                            WHERE ci.BUSDATE >= V_F_DATE AND ci.BUSDATE <= V_T_DATE
                            and (ci.tltxcd IN ('8851','1168','1169') or (ci.tltxcd IN ('1137','1138') and txtype = 'C'))
                                AND ci.field = 'BALANCE'
               union all

                         /*SELECT ci.acctno, ci.tltxcd, CI.txdate, ci.txnum, ci.txcd, ci.namt, ci.field, ci.txtype, ci.txdesc,
                                   CASE
                                        WHEN CI.TLTXCD IN ('1153') and substr(CI.acctno,1,4) = '0001' and aft.corebank = 'Y'
                                                and (ci.txdate, ci.txnum ) in (
                                                                                    select txdate, objkey from crbtxreq where objname = '1153' and via='DIR'
                                                                                    union all
                                                                                    select txdate, objkey from crbtxreqhist where objname = '1153' and via='DIR'
                                                                              )
                                            THEN '12310000388826'
                                        WHEN CI.TLTXCD IN ('1153') and substr(CI.acctno,1,4) = '0001' and aft.corebank = 'Y'
                                                and (ci.txdate, ci.txnum ) not in (
                                                                                    select txdate, objkey from crbtxreq where objname = '1153' and via='DIR'
                                                                                    union all
                                                                                    select txdate, objkey from crbtxreqhist where objname = '1153' and via='DIR'
                                                                              )
                                            THEN '12312000002335'


                                         WHEN CI.TLTXCD IN ('1153') and substr(CI.acctno,1,4) = '0101' and aft.corebank = 'Y'
                                                and (ci.txdate, ci.txnum ) in (
                                                                                    select txdate, objkey from crbtxreq where objname = '1153' and via='DIR'
                                                                                    union all
                                                                                    select txdate, objkey from crbtxreqhist where objname = '1153' and via='DIR'
                                                                              )
                                            THEN '12310000392049'

                                         WHEN CI.TLTXCD IN ('1153') and substr(CI.acctno,1,4) = '0101' and aft.corebank = 'Y'
                                                and (ci.txdate, ci.txnum ) not in (
                                                                                    select txdate, objkey from crbtxreq where objname = '1153' and via='DIR'
                                                                                    union all
                                                                                    select txdate, objkey from crbtxreqhist where objname = '1153' and via='DIR'
                                                                              )
                                            THEN '31010000462867'

                                         else 'KHAC' END TRANSSUBTYPE
                                FROM
                                    vw_citran   ci,aftype aft, afmast af
                                WHERE ci.acctno = af.acctno and af.actype = aft.actype
                                and ci.BUSDATE >= V_F_DATE AND ci.BUSDATE <= V_T_DATE
                                and ci.tltxcd IN ('1153') and txcd in ('0011','0012')
                                and ci.acctno <> ci.acctref
                                    AND ci.field = 'BALANCE'*/
                            SELECT ci.acctno, ci.tltxcd, CI.txdate, ci.txnum, ci.txcd, ci.namt, ci.field, ci.txtype, ci.txdesc,
                                   CASE
                                        WHEN CI.TLTXCD IN ('1153') and substr(CI.acctno,1,4) = '0001' and ci.corebank = 'Y'
                                                and (ci.txdate, ci.txnum ) in (
                                                                                    select txdate, objkey from crbtxreq where objname = '1153' and via='DIR'
                                                                                    union all
                                                                                    select txdate, objkey from crbtxreqhist where objname = '1153' and via='DIR'
                                                                              )
                                            THEN '12310000388826'
                                        WHEN CI.TLTXCD IN ('1153') and substr(CI.acctno,1,4) = '0001' and ci.corebank = 'Y'
                                                and (ci.txdate, ci.txnum ) not in (
                                                                                    select txdate, objkey from crbtxreq where objname = '1153' and via='DIR'
                                                                                    union all
                                                                                    select txdate, objkey from crbtxreqhist where objname = '1153' and via='DIR'
                                                                              )
                                            THEN '12312000002335'


                                         WHEN CI.TLTXCD IN ('1153') and substr(CI.acctno,1,4) = '0101' and ci.corebank = 'Y'
                                                and (ci.txdate, ci.txnum ) in (
                                                                                    select txdate, objkey from crbtxreq where objname = '1153' and via='DIR'
                                                                                    union all
                                                                                    select txdate, objkey from crbtxreqhist where objname = '1153' and via='DIR'
                                                                              )
                                            THEN '12310000392049'

                                         WHEN CI.TLTXCD IN ('1153') and substr(CI.acctno,1,4) = '0101' and ci.corebank = 'Y'
                                                and (ci.txdate, ci.txnum ) not in (
                                                                                    select txdate, objkey from crbtxreq where objname = '1153' and via='DIR'
                                                                                    union all
                                                                                    select txdate, objkey from crbtxreqhist where objname = '1153' and via='DIR'
                                                                              )
                                            THEN '31010000462867'

                                         else 'KHAC' END TRANSSUBTYPE
                                FROM
                                    vw_citran   ci
                                WHERE ci.BUSDATE >= V_F_DATE AND ci.BUSDATE <= V_T_DATE
                                and ci.tltxcd IN ('1153') and txcd in ('0011','0012')
                                and ci.acctno <> ci.acctref
                                    AND ci.field = 'BALANCE'


                union all

/*
                        SELECT ci.acctno, ci.tltxcd, CI.txdate, ci.txnum, ci.txcd, ci.namt, ci.field, ci.txtype, 'D' txdesc,
                               CASE
                                     WHEN CI.TLTXCD IN ('1191') and substr(CI.txnum,1,4) = '0001' and ci.corebank = 'Y' and tl.fldcd in('001') THEN '12312000002335'
                                     WHEN CI.TLTXCD IN ('1191') and substr(CI.txnum,1,4) = '0101' and ci.corebank = 'Y' and tl.fldcd in('002','005','006') THEN '31010000462867'
                                     else 'KHAC' END TRANSSUBTYPE
                            FROM
                                vw_citran   ci, tllogfld tl
                            WHERE ci.txdate = tl.txdate and ci.txnum = tl.txnum and tl.fldcd='09'
                            and ci.BUSDATE >= V_F_DATE AND ci.BUSDATE <= V_T_DATE
                            and ci.tltxcd IN ('1191') and txtype = 'C'
                                AND ci.field = 'BALANCE'

                union all*/


                 SELECT ci.acctno, ci.tltxcd, CI.txdate, ci.txnum, ci.txcd, ci.namt, ci.field, ci.txtype, ci.txdesc,
                             'KHAC' TRANSSUBTYPE
                               /*CASE
                                     WHEN CI.TLTXCD IN ('5567','5540') and substr(txnum,1,4) = '0001' AND INSTR(trdesc,'BL') > 0 THEN '12312000002335'
                                     WHEN CI.TLTXCD IN ('5567','5540') and substr(txnum,1,4) = '0101' AND INSTR(trdesc,'BL') > 0 THEN '31010000462867'
                                     else 'KHAC' END TRANSSUBTYPE*/
                            FROM
                                vw_citran   ci
                            WHERE BUSDATE >= V_F_DATE AND BUSDATE <= V_T_DATE
                            --and tltxcd IN ('5567','5540','2624','2674','2648','2646','2664')
                            and tltxcd IN ('2624','2674','2648','2646','2664')
                                AND ci.field = 'BALANCE'


                     union all

                /*SELECT ci.acctno, ci.tltxcd, CI.txdate, ci.txnum, ci.txcd, ci.namt, ci.field,   CASE WHEN TXCD = '0029' THEN 'D'
                     WHEN TXCD = '0011' THEN 'C'
                ELSE 'C' END txtype, ci.txdesc,
                              CASE
                                    WHEN substr(txnum,1,4) = '0001' and txcd = '0029' and aft.corebank = 'Y'  THEN '12312000002335'
                                    WHEN substr(txnum,1,4) = '0101' and txcd = '0029' and aft.corebank = 'Y'  THEN '31010000462867'
                                    WHEN substr(txnum,1,4) = '0001' and txcd = '0011' and aft.corebank = 'Y' THEN '12310000349850'
                                    WHEN substr(txnum,1,4) = '0101' and txcd = '0011' and aft.corebank = 'Y' THEN '31010000637805'
                                    else 'KHAC' END TRANSSUBTYPE
                           FROM
                               vw_citran   ci,aftype aft, afmast af
                           WHERE ci.acctno = af.acctno and af.actype = aft.actype
                           and ci.BUSDATE >= V_F_DATE AND ci.BUSDATE <= V_T_DATE
                           and ci.tltxcd IN ('8878') and txcd in ('0029','0011')  AND NVL(CI.ACCTREF,'1')='1'
                               AND ci.field = 'BALANCE'*/

                    SELECT ci.acctno, ci.tltxcd, CI.txdate, ci.txnum, ci.txcd, ci.namt, ci.field,   CASE WHEN TXCD = '0029' THEN 'D'
                        WHEN TXCD = '0011' THEN 'C'
                            ELSE 'C' END txtype, ci.txdesc,
                                 CASE
                                    WHEN substr(txnum,1,4) = '0001' and txcd = '0029' and ci.corebank = 'Y'  THEN '12312000002335'
                                    WHEN substr(txnum,1,4) = '0101' and txcd = '0029' and ci.corebank = 'Y'  THEN '31010000462867'
                                    WHEN substr(txnum,1,4) = '0001' and txcd = '0011' and ci.corebank = 'Y' THEN '12310000349850'
                                    WHEN substr(txnum,1,4) = '0101' and txcd = '0011' and ci.corebank = 'Y' THEN '31010000637805'
                                    else 'KHAC' END TRANSSUBTYPE
                           FROM
                               vw_citran   ci
                           WHERE ci.BUSDATE >= V_F_DATE AND ci.BUSDATE <= V_T_DATE
                           and ci.tltxcd IN ('8878') and txcd in ('0029','0011')  AND NVL(CI.ACCTREF,'1')='1'
                               AND ci.field = 'BALANCE'

                     union all

                     SELECT ci.acctno, ci.tltxcd, CI.txdate, ci.txnum, ci.txcd, ci.namt, ci.field, 'C' txtype, ci.txdesc,
                                  CASE
                                         WHEN substr(CI.acctno,1,4) = '0001' and ci.corebank = 'Y' THEN '12312000002335'
                                         WHEN substr(CI.acctno,1,4) = '0101' and ci.corebank = 'Y' THEN '31010000462867'
                                         else 'KHAC' END TRANSSUBTYPE
                                FROM
                                    vw_citran   ci  ,aftype aft, afmast af
                                WHERE ci.acctno = af.acctno and af.actype = aft.actype
                               and ci.BUSDATE >= V_F_DATE AND ci.BUSDATE <= V_T_DATE
                                and tltxcd IN ('2244')
                                    AND ci.field = 'HOLDBALANCE'

                    union all

                     /*SELECT ci.acctno, ci.tltxcd, CI.txdate, ci.txnum, ci.txcd, ci.namt, ci.field,
                     CASE WHEN TXCD = '0029' THEN 'D'
                     WHEN TXCD = '0028' THEN 'C'
                        ELSE 'C' END txtype, ci.txdesc,
                                   CASE
                                         WHEN substr(txnum,1,4) = '0001' and txcd = '0029' and aft.corebank = 'Y'  THEN '12310000349850'
                                         WHEN substr(txnum,1,4) = '0101' and txcd = '0029' and aft.corebank = 'Y'  THEN '31010000637805'
                                         WHEN substr(txnum,1,4) = '0001' and txcd = '0028' and aft.corebank = 'Y' THEN '12312000002335'
                                         WHEN substr(txnum,1,4) = '0101' and txcd = '0028' and aft.corebank = 'Y' THEN '31010000462867'
                                         else 'KHAC' END TRANSSUBTYPE
                                FROM
                                    vw_citran   ci,aftype aft, afmast af
                                WHERE ci.acctno = af.acctno and af.actype = aft.actype
                                and ci.BUSDATE >= V_F_DATE AND ci.BUSDATE <= V_T_DATE
                                and ci.tltxcd IN ('8817') and txcd in ('0029','0028')
                                    AND ci.field = 'BALANCE'*/
                    SELECT ci.acctno, ci.tltxcd, CI.txdate, ci.txnum, ci.txcd, ci.namt, ci.field,
                     CASE WHEN TXCD = '0029' THEN 'D'
                     WHEN TXCD = '0028' THEN 'C'
                        ELSE 'C' END txtype, ci.txdesc,
                                   CASE
                                         WHEN substr(txnum,1,4) = '0001' and txcd = '0029' and ci.corebank = 'Y'  THEN '12310000349850'
                                         WHEN substr(txnum,1,4) = '0101' and txcd = '0029' and ci.corebank = 'Y'  THEN '31010000637805'
                                         WHEN substr(txnum,1,4) = '0001' and txcd = '0028' and ci.corebank = 'Y' THEN '12312000002335'
                                         WHEN substr(txnum,1,4) = '0101' and txcd = '0028' and ci.corebank = 'Y' THEN '31010000462867'
                                         else 'KHAC' END TRANSSUBTYPE
                                FROM
                                    vw_citran   ci
                                WHERE ci.BUSDATE >= V_F_DATE AND ci.BUSDATE <= V_T_DATE
                                and ci.tltxcd IN ('8817') and txcd in ('0029','0028')
                                    AND ci.field = 'BALANCE'


                    union all

               SELECT ci.acctno, ci.tltxcd, CI.txdate, ci.txnum, ci.txcd, ci.namt, ci.field, 'C' txtype, ci.txdesc,
                                   tl.cvalue TRANSSUBTYPE
                                FROM
                                    vw_citran   ci, tllogfld tl, aftype aft, afmast af
                                WHERE ci.txdate = tl.txdate and ci.txnum = tl.txnum and tl.fldcd='05'
                                and ci.acctno = af.acctno and af.actype = aft.actype
                                and ci.BUSDATE >= V_F_DATE AND ci.BUSDATE <= V_T_DATE
                                and ci.tltxcd IN ('6668') and txtype = 'D'
                                    AND ci.field = 'HOLDBALANCE'

                   union all

               SELECT ci.acctno, ci.tltxcd, CI.txdate, ci.txnum, ci.txcd, ci.namt, ci.field, 'C' txtype, ci.txdesc,
                                   tl.cvalue TRANSSUBTYPE
                                FROM
                                    vw_citran   ci, tllogfld tl, aftype aft, afmast af
                                WHERE ci.txdate = tl.txdate and ci.txnum = tl.txnum and tl.fldcd='05'
                                and ci.acctno = af.acctno and af.actype = aft.actype
                                and ci.BUSDATE >= V_F_DATE AND ci.BUSDATE <= V_T_DATE
                                and ci.tltxcd IN ('6642') and CI.field = 'HOLDBALANCE'

            ) CI
           WHERE CI.ACCTNO = AF.acctno (+)
               AND (SUBSTR(ci.txnum,1,4) LIKE '%' OR INSTR('%',SUBSTR(ci.txnum,1,4)) >0)
               and LENGTH(TRANSSUBTYPE) > 0

    ) a, cfmast cf, TLTX TL
    where A.TLTXCD = TL.TLTXCD
    and a.custid = cf.custid (+)
) a, CI2001_GL_DAUKY GL
where gl.GLACCOUNT = A.TRANSSUBTYPE (+)
    AND gl.GLACCOUNT LIKE V_GLACCOUNT
    and gl.txdate = V_F_DATE
    and nvl(CI_CRAMT,0) + nvl(CI_DRAMT,0) + nvl(OW_CRAMT,0) + nvl(OW_DRAMT,0) <> 0
ORDER BY TXDATE, GLACCOUNT, txnum
;


EXCEPTION
   WHEN OTHERS
   THEN
      RETURN;
END;

 
 
 
 
/
