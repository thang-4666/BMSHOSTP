SET DEFINE OFF;
CREATE OR REPLACE FORCE VIEW VW_GETUSEDADV
(ADV_SECUREAMT, ADV_EXECBUYAMT, ADV_SECUREAMT_VCBS, ADV_EXECBUYAMT_VCBS)
BEQUEATH DEFINER
AS 
SELECT (ADV_SECUREAMT+schd.amt) ADV_SECUREAMT,(ADV_EXECBUYAMT+schd.amt) ADV_EXECBUYAMT ,
(ADV_SECUREAMT_VCBS+log.amt) ADV_SECUREAMT_VCBS,(ADV_EXECBUYAMT_VCBS+log.amt) ADV_EXECBUYAMT_VCBS
FROM
(
      SELECT SUM(ADV_SECUREAMT) ADV_SECUREAMT ,SUM(ADV_EXECBUYAMT) ADV_EXECBUYAMT,
             SUM(CASE WHEN CF.ISUSEOADVRES='N' THEN ADV_SECUREAMT ELSE 0 END ) ADV_SECUREAMT_VCBS,
             SUM(CASE WHEN CF.ISUSEOADVRES='N' THEN ADV_EXECBUYAMT ELSE 0 END ) ADV_EXECBUYAMT_VCBS
           --  SUM (margin_execbuyamt )     MARGIN_EXECBUYAMT
      FROM   (SELECT AF.CUSTID,AF.ACCTNO AFACCTNO,AF.AUTOADV,
                     --1.ADV_SECUREAMT
                    (CASE     WHEN AF.AUTOADV='N' THEN 0
                              WHEN  AF.AUTOADV='Y' AND AFT.ADVPRIO <> 'Y' AND mrt.mrtype IN ('S','T')  THEN-- khong uu tien UTTB
                              LEAST(GREATEST(nvl(VW.SECUREAMT,0)+CI.DUEAMT+CI.OVAMT
                                            -- No trong han se tra
                                            + NVL((CASE WHEN LN.PREPAID='N'  THEN 0
                                                    WHEN LN.PREPAID='Y' AND LN.ADVPAY='N'
                                                            THEN GREATEST(LEAST(LN.ODAMT,
                                                                              (CASE WHEN (CI.BALANCE-nvl(VW.SECUREAMT,0)-(CI.OVAMT+CI.DUEAMT))
                                                                              >=SYS.MINLOANAUTOPAYMENT
                                                                              THEN (CI.BALANCE-nvl(VW.SECUREAMT,0)-(CI.OVAMT+CI.DUEAMT)) ELSE 0 END)
                                                                      )
                                                                        ,0)
                                                    ELSE GREATEST(LEAST(LN.ODAMT,
                                                               (        CASE WHEN (CI.BALANCE-(CI.OVAMT+CI.DUEAMT))
                                                                              >=SYS.MINLOANAUTOPAYMENT
                                                                              THEN (CI.BALANCE-(CI.OVAMT+CI.DUEAMT)) ELSE 0 END)),0)
                                                    END
                                               ),0)
                                            -- phan se giai ngan Margin
                                            -GREATEST((CI.BALANCE+NVL(TD.TDAMT,0)+LEAST(GREATEST(af.mrcrlimitmax -CI.DFODAMT
                                                              -ci.odamt- ci.dfdebtamt- ci.dfintdebtamt- CI.RAMT
                                                              -- phan nha ra do tra no qua han,den han
                                                              +LEAST(CI.OVAMT+CI.DUEAMT,
                                                                         (CASE WHEN (CI.BALANCE+BUF.Avladvance) >=SYS.MINLOANAUTOPAYMENT THEN (CI.BALANCE+BUF.Avladvance)
                                                                         ELSE 0 END))
                                                              -- phan han muc nha ra do tra no trong han
                                                                   +NVL( (CASE WHEN LN.PREPAID='N'  THEN 0
                                                                      WHEN LN.PREPAID='Y' AND LN.ADVPAY='N'
                                                                              THEN GREATEST(LEAST(LN.ODAMT,
                                                                                                (CASE WHEN (CI.BALANCE-nvl(VW.SECUREAMT,0)-(CI.OVAMT+CI.DUEAMT))
                                                                                                >=SYS.MINLOANAUTOPAYMENT
                                                                                                THEN (CI.BALANCE-nvl(VW.SECUREAMT,0)-(CI.OVAMT+CI.DUEAMT)) ELSE 0 END)
                                                                                        )
                                                                                          ,0)
                                                                      ELSE GREATEST(LEAST(LN.ODAMT,
                                                                                 (        CASE WHEN (CI.BALANCE-(CI.OVAMT+CI.DUEAMT))
                                                                                                >=SYS.MINLOANAUTOPAYMENT
                                                                                                THEN (CI.BALANCE-(CI.OVAMT+CI.DUEAMT)) ELSE 0 END)),0)
                                                                      END
                                                                      ),0)
                                                              ,0),NVL(nvl(VW.SECUREAMT,0),0)))
                                                              ,0)
                                       ,0),BUF.Avladvance)
                              -- uu tien UTTB
                              ELSE LEAST(GREATEST(nvl(VW.SECUREAMT,0)+CI.DUEAMT+CI.OVAMT
                                        -- No trong han se tra
                                            + NVL((CASE WHEN LN.PREPAID='N'  THEN 0
                                                    WHEN LN.PREPAID='Y' AND LN.ADVPAY='N'
                                                            THEN GREATEST(LEAST(LN.ODAMT,
                                                                              (CASE WHEN (CI.BALANCE-nvl(VW.SECUREAMT,0)-(CI.OVAMT+CI.DUEAMT))
                                                                              >=SYS.MINLOANAUTOPAYMENT
                                                                              THEN (CI.BALANCE-nvl(VW.SECUREAMT,0)-(CI.OVAMT+CI.DUEAMT)) ELSE 0 END)
                                                                      )
                                                                        ,0)
                                                    ELSE GREATEST(LEAST(LN.ODAMT,
                                                               (        CASE WHEN (CI.BALANCE-(CI.OVAMT+CI.DUEAMT))
                                                                              >=SYS.MINLOANAUTOPAYMENT
                                                                              THEN (CI.BALANCE-(CI.OVAMT+CI.DUEAMT)) ELSE 0 END)),0)
                                                    END
                                               ),0)- CI.BALANCE,0,0),BUF.Avladvance)
                              END) ADV_SECUREAMT,
        --2.ADV_EXECBUYAMT
                    (CASE     WHEN AF.AUTOADV='N' THEN 0

                              WHEN  AF.AUTOADV='Y' AND AFT.ADVPRIO <> 'Y'   AND mrt.mrtype IN ('S','T') THEN      -- khong uu tien UTTB
                              LEAST(GREATEST(VW.execbuyamt+CI.DUEAMT+CI.OVAMT
                                                -- No trong han se tra
                                                   +NVL( (CASE WHEN LN.PREPAID='N'  THEN 0
                                                    WHEN LN.PREPAID='Y' AND LN.ADVPAY='N'
                                                            THEN GREATEST(LEAST(LN.ODAMT,
                                                                              (CASE WHEN (CI.BALANCE-VW.EXECBUYAMT-(CI.OVAMT+CI.DUEAMT))
                                                                              >=SYS.MINLOANAUTOPAYMENT
                                                                              THEN (CI.BALANCE-VW.EXECBUYAMT-(CI.OVAMT+CI.DUEAMT)) ELSE 0 END)
                                                                      )
                                                                        ,0)
                                                    ELSE GREATEST(LEAST(LN.ODAMT,
                                                               (        CASE WHEN (CI.BALANCE-(CI.OVAMT+CI.DUEAMT))
                                                                              >=SYS.MINLOANAUTOPAYMENT
                                                                              THEN (CI.BALANCE-(CI.OVAMT+CI.DUEAMT)) ELSE 0 END)),0)
                                                    END
                                                    ),0)
                                             -- phan se giai ngan Margin
                                             -GREATEST((CI.BALANCE+NVL(TD.TDAMT,0)
                                                        +LEAST(GREATEST(af.mrcrlimitmax -CI.DFODAMT
                                                                      -CI.ODAMT
                                                                         -- phan nha ra do tra no qua han,den han
                                                                         +LEAST(CI.OVAMT+CI.DUEAMT,
                                                                         (CASE WHEN (CI.BALANCE+BUF.Avladvance) >=SYS.MINLOANAUTOPAYMENT THEN (CI.BALANCE+BUF.Avladvance)
                                                                         ELSE 0 END))
                                                                      -- phan han muc nha ra do tra no trong han
                                                                        + NVL((CASE WHEN LN.PREPAID='N'  THEN 0
                                                                          WHEN LN.PREPAID='Y' AND LN.ADVPAY='N'
                                                                                  THEN GREATEST(LEAST(LN.ODAMT,
                                                                                                    (CASE WHEN (CI.BALANCE-VW.EXECBUYAMT-(CI.OVAMT+CI.DUEAMT))
                                                                                                    >=SYS.MINLOANAUTOPAYMENT
                                                                                                    THEN (CI.BALANCE-VW.EXECBUYAMT-(CI.OVAMT+CI.DUEAMT)) ELSE 0 END)
                                                                                            )
                                                                                              ,0)
                                                                          ELSE GREATEST(LEAST(LN.ODAMT,
                                                                                     (        CASE WHEN (CI.BALANCE-(CI.OVAMT+CI.DUEAMT))
                                                                                                    >=SYS.MINLOANAUTOPAYMENT
                                                                                                    THEN (CI.BALANCE-(CI.OVAMT+CI.DUEAMT)) ELSE 0 END)),0)
                                                                          END
                                                                     ),0)

                                                                       - ci.dfdebtamt- ci.dfintdebtamt- ci.ramt,0),NVL(VW.execbuyamt,0)))
                                                      ,0)
                                       ,0),BUF.Avladvance)
                              -- uu tien UTTB
                              ELSE LEAST(GREATEST(VW.execbuyamt+CI.DUEAMT+CI.OVAMT
                                              -- No trong han se tra
                                            + NVL((CASE WHEN LN.PREPAID='N'  THEN 0
                                                    WHEN LN.PREPAID='Y' AND LN.ADVPAY='N'
                                                            THEN GREATEST(LEAST(LN.ODAMT,
                                                                              (CASE WHEN (CI.BALANCE-VW.EXECBUYAMT-(CI.OVAMT+CI.DUEAMT))
                                                                              >=SYS.MINLOANAUTOPAYMENT
                                                                              THEN (CI.BALANCE-VW.EXECBUYAMT-(CI.OVAMT+CI.DUEAMT)) ELSE 0 END)
                                                                      )
                                                                        ,0)
                                                    ELSE GREATEST(LEAST(LN.ODAMT,
                                                               (        CASE WHEN (CI.BALANCE-(CI.OVAMT+CI.DUEAMT))
                                                                              >=SYS.MINLOANAUTOPAYMENT
                                                                              THEN (CI.BALANCE-(CI.OVAMT+CI.DUEAMT)) ELSE 0 END)),0)
                                                    END
                                               ),0)
                                             - CI.BALANCE,0),BUF.Avladvance)
                              END) ADV_EXECBUYAMT
             -- 3. du tinh phat vay margin

                          /*     GREATEST(LEAST (VW.execbuyamt - (ci.balance+NVL(TD.TDAMT,0)+(CASE WHEN aft.advprio='Y' AND af.autoadv='Y' THEN buf.avladvance ELSE 0 END)
                                                                                   -- no qua han se tra
                                                                                   -LEAST(CI.OVAMT+CI.DUEAMT,
                                                                                       (CASE WHEN (CI.BALANCE+BUF.Avladvance) >=SYS.MINLOANAUTOPAYMENT THEN (CI.BALANCE+BUF.Avladvance)
                                                                                       ELSE 0 END))
                                                                                    -- no trong han se tra
                                                                                             + NVL((CASE WHEN LN.PREPAID='N'  THEN 0
                                                                                                          WHEN LN.PREPAID='Y' AND LN.ADVPAY='N'
                                                                                                                  THEN GREATEST(LEAST(LN.ODAMT,
                                                                                                                                    (CASE WHEN (CI.BALANCE-VW.EXECBUYAMT-(CI.OVAMT+CI.DUEAMT))
                                                                                                                                    >=SYS.MINLOANAUTOPAYMENT
                                                                                                                                    THEN (CI.BALANCE-VW.EXECBUYAMT-(CI.OVAMT+CI.DUEAMT)) ELSE 0 END)
                                                                                                                            )
                                                                                                                              ,0)
                                                                                                          ELSE GREATEST(LEAST(LN.ODAMT,
                                                                                                                     (        CASE WHEN (CI.BALANCE-(CI.OVAMT+CI.DUEAMT))
                                                                                                                                    >=SYS.MINLOANAUTOPAYMENT
                                                                                                                                    THEN (CI.BALANCE-(CI.OVAMT+CI.DUEAMT)) ELSE 0 END)),0)
                                                                                                          END
                                                                                                     ),0)
                                                                           )
                                                                ,-- HM con lai
                                                                GREATEST(af.mrcrlimitmax -CI.DFODAMT
                                                                      -CI.ODAMT
                                                                         -- phan nha ra do tra no qua han,den han
                                                                         +LEAST(CI.OVAMT+CI.DUEAMT,
                                                                         (CASE WHEN (CI.BALANCE+BUF.Avladvance) >=SYS.MINLOANAUTOPAYMENT THEN (CI.BALANCE+BUF.Avladvance)
                                                                         ELSE 0 END))
                                                                      -- phan han muc nha ra do tra no trong han
                                                                        + NVL((CASE WHEN LN.PREPAID='N'  THEN 0
                                                                          WHEN LN.PREPAID='Y' AND LN.ADVPAY='N'
                                                                                  THEN GREATEST(LEAST(LN.ODAMT,
                                                                                                    (CASE WHEN (CI.BALANCE-VW.EXECBUYAMT-(CI.OVAMT+CI.DUEAMT))
                                                                                                    >=SYS.MINLOANAUTOPAYMENT
                                                                                                    THEN (CI.BALANCE-VW.EXECBUYAMT-(CI.OVAMT+CI.DUEAMT)) ELSE 0 END)
                                                                                            )
                                                                                              ,0)
                                                                          ELSE GREATEST(LEAST(LN.ODAMT,
                                                                                     (        CASE WHEN (CI.BALANCE-(CI.OVAMT+CI.DUEAMT))
                                                                                                    >=SYS.MINLOANAUTOPAYMENT
                                                                                                    THEN (CI.BALANCE-(CI.OVAMT+CI.DUEAMT)) ELSE 0 END)),0)
                                                                          END
                                                                     ),0)

                                                                       - ci.dfdebtamt- ci.dfintdebtamt- ci.ramt,0)
                                                                )
                                                      ,0)  MARGIN_EXECBUYAMT      */

                     FROM AFMAST AF,AFTYPE AFT, mrtype mrt,
                              -- phan tiet kiem
                             (SELECT SUM(NVL(MST.BALANCE,0)) TDAMT,AF.ACCTNO AFACCTNO
                              FROM TDMAST MST, AFMAST AF, TDTYPE TYP, sysvar
                              WHERE MST.ACTYPE=TYP.ACTYPE AND MST.AFACCTNO=AF.ACCTNO AND SYSVAR.VARNAME='CURRDATE'
                              AND SYSVAR.GRNAME = 'SYSTEM'
                              AND MST.DELTD<>'Y' AND MST.status in ('N','A')
                              AND mst.buyingpower='Y'
                              AND (mst.breakcd='Y' OR (mst.breakcd='N' AND TO_date(SYSVAR.VARVALUE,'DD/MM/RRRRR') > mst.todate ))
                              GROUP BY AF.ACCTNO
                              )TD,
                              CIMAST CI,
                            V_GETBUYORDERINFO VW, BUF_CI_ACCOUNT Buf,
                            (SELECT TRFACCTNO,SUM(PRINNML+INTNMLACR+FEEINTNMLACR) ODAMT,PREPAID,ADVPAY
                             FROM LNMAST WHERE FTYPE='AF' AND (PRINNML+INTNMLACR+FEEINTNMLACR) > 0
                             GROUP BY TRFACCTNO,PREPAID,ADVPAY ) LN,
                             (select to_number(varvalue) MINLOANAUTOPAYMENT  from sysvar where grname ='SYSTEM' and varname = 'LOANAUTOPAYAMT') SYS
                     WHERE AF.ACTYPE=AFT.ACTYPE
                     AND aft.mrtype=mrt.actype
                     AND AF.ACCTNO=TD.AFACCTNO(+)
                     AND AF.ACCTNO=CI.ACCTNO
                     AND AF.ACCTNO=VW.AFACCTNO(+)
                     AND AF.ACCTNO=BUF.AFACCTNO
                     AND AF.Acctno=LN.TRFACCTNO(+)
                ) AF, CFMAST CF

      WHERE AF.CUSTID=CF.CUSTID
)  adv,
(SELECT NVL(SUM(amt+feeamt),0) amt  from adschd schd, (SELECT * from sysvar WHERE varname='CURRDATE') SYS
WHERE schd.txdate=to_date(sys.varvalue,'DD/MM/RRRR') AND deltd <> 'Y') schd,
(SELECT NVL(SUM(amt),0) amt  from advreslog LOG, (SELECT * from sysvar WHERE varname='CURRDATE') SYS
WHERE log.txdate=to_date(sys.varvalue,'DD/MM/RRRR') AND deltd <> 'Y' AND rrtype='C') LOG
/
