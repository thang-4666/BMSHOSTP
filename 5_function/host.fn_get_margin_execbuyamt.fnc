SET DEFINE OFF;
CREATE OR REPLACE FUNCTION fn_get_margin_execbuyamt(pv_AFACCTNO In VARCHAR2)
    RETURN number IS
    v_Result  number;
BEGIN
    v_Result := 0;
                SELECT
                        least( GREATEST(LEAST (nvl(VW.secureamt,0) - (ci.balance+(CASE WHEN aft.advprio='Y' AND af.autoadv='Y' THEN +NVL(TD.TDAMT,0)+buf.avladvance ELSE 0 END)
                                                                             -- no qua han se tra
                                                                             -LEAST(CI.OVAMT+CI.DUEAMT,
                                                                                 (CASE WHEN (CI.BALANCE+BUF.Avladvance) >=SYS.MINLOANAUTOPAYMENT THEN (CI.BALANCE+BUF.Avladvance)
                                                                                 ELSE 0 END))
                                                                              -- no trong han se tra
                                                                                       - NVL((CASE WHEN LN.PREPAID='N'  THEN 0
                                                                                                    WHEN LN.PREPAID='Y' AND LN.ADVPAY='N'
                                                                                                            THEN GREATEST(LEAST(/*LN.ODAMT*/LN.ODAMT-CI.DUEAMT,
                                                                                                                              (CASE WHEN (CI.BALANCE-nvl(VW.secureamt,0)-(CI.OVAMT+CI.DUEAMT))
                                                                                                                              >=SYS.MINLOANAUTOPAYMENT
                                                                                                                              THEN (CI.BALANCE-nvl(VW.secureamt,0)-(CI.OVAMT+CI.DUEAMT)) ELSE 0 END)
                                                                                                                      )
                                                                                                                        ,0)
                                                                                                    ELSE GREATEST(LEAST(/*LN.ODAMT*/LN.ODAMT-CI.DUEAMT,
                                                                                                               (        CASE WHEN (CI.BALANCE-(CI.OVAMT+CI.DUEAMT))
                                                                                                                              >=SYS.MINLOANAUTOPAYMENT
                                                                                                                              THEN (CI.BALANCE-(CI.OVAMT+CI.DUEAMT)) ELSE 0 END)),0)
                                                                                                    END
                                                                                               ),0)
                                                                     )
                                                          ,-- HM con lai
                                                      LEAST (    GREATEST(af.mrcrlimitmax -CI.DFODAMT
                                                                -CI.ODAMT
                                                                   -- phan nha ra do tra no qua han,den han
                                                                   +LEAST(CI.OVAMT+CI.DUEAMT,
                                                                   (CASE WHEN (CI.BALANCE+BUF.Avladvance) >=SYS.MINLOANAUTOPAYMENT THEN (CI.BALANCE+BUF.Avladvance)
                                                                   ELSE 0 END))
                                                                -- phan han muc nha ra do tra no trong han
                                                                  + NVL((CASE WHEN LN.PREPAID='N'  THEN 0
                                                                    WHEN LN.PREPAID='Y' AND LN.ADVPAY='N'
                                                                            THEN GREATEST(LEAST(/*LN.ODAMT*/LN.ODAMT-CI.DUEAMT,
                                                                                              (CASE WHEN (CI.BALANCE-nvl(VW.secureamt,0)-(CI.OVAMT+CI.DUEAMT))
                                                                                              >=SYS.MINLOANAUTOPAYMENT
                                                                                              THEN (CI.BALANCE-nvl(VW.secureamt,0)-(CI.OVAMT+CI.DUEAMT)) ELSE 0 END)
                                                                                      )
                                                                                        ,0)
                                                                    ELSE GREATEST(LEAST(/*LN.ODAMT*/LN.ODAMT-CI.DUEAMT,
                                                                               (        CASE WHEN (CI.BALANCE-(CI.OVAMT+CI.DUEAMT))
                                                                                              >=SYS.MINLOANAUTOPAYMENT
                                                                                              THEN (CI.BALANCE-(CI.OVAMT+CI.DUEAMT)) ELSE 0 END)),0)
                                                                    END
                                                               ),0)

                                                                 - ci.dfdebtamt- ci.dfintdebtamt- ci.ramt,0), buf.seamt)
                                                          )
                                                ,0)
                                          ,nvl(VW.secureamt,0))  MARGIN_EXECBUYAMT    INTO V_Result
             FROM AFMAST AF,AFTYPE AFT,
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
                      (SELECT TRFACCTNO,SUM(PRINNML+INTNMLACR+FEEINTNMLACR+INTDUE) ODAMT,PREPAID,ADVPAY
                       FROM LNMAST WHERE FTYPE='AF' AND (PRINNML+INTNMLACR+FEEINTNMLACR+INTDUE) > 0
                       GROUP BY TRFACCTNO,PREPAID,ADVPAY ) LN,
                       (select to_number(varvalue) MINLOANAUTOPAYMENT  from sysvar where grname ='SYSTEM' and varname = 'LOANAUTOPAYAMT') SYS
               WHERE AF.ACTYPE=AFT.ACTYPE

               AND AF.ACCTNO=TD.AFACCTNO(+)
               AND AF.ACCTNO=CI.ACCTNO
               AND AF.ACCTNO=VW.AFACCTNO(+)
               AND AF.ACCTNO=BUF.AFACCTNO
               AND AF.Acctno=LN.TRFACCTNO(+)
               AND AF.ACCTNO=PV_AFACCTNO;
    RETURN v_Result;
EXCEPTION
   WHEN OTHERS THEN
    RETURN 0;
END;

-- Start of DDL Script for Procedure HOST.INQUIRYACCOUNT
-- Generated 17/10/2011 10:42:25 from HOST@BVSUAT

 
 
 
 
/
