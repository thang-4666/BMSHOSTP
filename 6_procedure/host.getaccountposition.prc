SET DEFINE OFF;
CREATE OR REPLACE PROCEDURE "GETACCOUNTPOSITION" (PV_REFCURSOR IN OUT PKG_REPORT.REF_CURSOR,AFACCTNO IN VARCHAR2)
  IS
  V_AFACCTNO VARCHAR2(10);
  v_margintype char(1);
  v_margindesc VARCHAR2(200);
  v_actype varchar2(4);
  v_groupleader varchar2(10);
  v_aamt number(20,0);
  v_pp number(20,0);
  v_balance number(20,0);
  v_avllimit number(20,0);
  v_total   number(20,0);
  v_isPPUsed    number(20,0);
BEGIN
---------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------
    V_AFACCTNO:=AFACCTNO;
    SELECT MR.MRTYPE,af.actype,mst.groupleader,MR.isppused into v_margintype,v_actype,v_groupleader,v_isPPUsed from afmast mst,aftype af, mrtype mr where mst.actype=af.actype and af.mrtype=mr.actype and mst.acctno=V_AFACCTNO;
    SELECT CDCONTENT INTO v_margindesc FROM ALLCODE  WHERE  CDTYPE='SA' AND  CDNAME='MARGINTYPE' AND CDVAL=v_margintype;

    if v_margintype='N' or v_margintype='L' then
            --Tai khoan binh thuong khong Margin
            OPEN PV_REFCURSOR FOR
                SELECT --V_AFACCTNO AFACCTNO,
                greatest(nvl(adv.avladvance,0) +nvl(af.mrcrlimit,0)+ af.advanceline + balance- odamt - NVL (advamt, 0)-nvl(secureamt,0) - ramt,0) PURCHASINGPOWER,
                balance CASH_ON_HAND,
                nvl(b.secureamt,0) ORDERAMT,
                greatest(- cimast.balance-least(nvl(af.mrcrlimit,0),nvl(b.secureamt,0))- nvl(adv.avladvance,0) +  cimast.odamt + NVL (b.advamt, 0)+ nvl(b.secureamt,0) + cimast.ramt,0)+ nvl(b.overamt,0)  OUTSTANDING,
                af.advanceline ADVANCEDLINE,
                nvl(adv.avladvance,0) AVLADVANCED,
                AF.mrcrlimitmax MRCRLIMITMAX,
                --AF.mrcrlimitmax +af.advanceline + balance- odamt - nvl (overamt, 0)-nvl(secureamt,0) - ramt avllimit,
                nvl(CASH_RECEIVING_T0,0) CASH_RECEIVING_T0,
                nvl(CASH_RECEIVING_T1,0) CASH_RECEIVING_T1,
                nvl(CASH_RECEIVING_T2,0) CASH_RECEIVING_T2,
                nvl(CASH_RECEIVING_T3,0) CASH_RECEIVING_T3,
                nvl(CASH_RECEIVING_TN,0) CASH_RECEIVING_TN,
                nvl(CASH_SENDING_T0,0) CASH_SENDING_T0,
                nvl(CASH_SENDING_T1,0) CASH_SENDING_T1,
                nvl(CASH_SENDING_T2,0) CASH_SENDING_T2,
                nvl(CASH_SENDING_T3,0) CASH_SENDING_T3,
                nvl(CASH_SENDING_TN,0) CASH_SENDING_TN
                from cimast inner join afmast af on cimast.acctno=af.acctno
                left join
                (select * from v_getbuyorderinfo where afacctno = V_AFACCTNO) b
                on  cimast.acctno = b.afacctno
                LEFT JOIN
               (select * from v_getsecmargininfo where afacctno = V_AFACCTNO) SE
               on se.afacctno = cimast.acctno
                LEFT JOIN
                (select sum(aamt) aamt,sum(depoamt) avladvance,afacctno from v_getAccountAvlAdvance where afacctno = V_AFACCTNO group by afacctno) adv
                on adv.afacctno=cimast.acctno
                LEFT JOIN
                (SELECT AFACCTNO,
                        SUM(NVL(CASE WHEN ST.DUETYPE='RM' AND ST.RDAY=0 THEN ST.ST_AMT-ST.ST_AAMT-ST.ST_FAMT ELSE 0 END,0)) CASH_RECEIVING_T0,
                        SUM(NVL(CASE WHEN ST.DUETYPE='RM' AND ST.RDAY=1 THEN ST.ST_AMT-ST.ST_AAMT-ST.ST_FAMT ELSE 0 END,0)) CASH_RECEIVING_T1,
                        SUM(NVL(CASE WHEN ST.DUETYPE='RM' AND ST.RDAY=2 THEN ST.ST_AMT-ST.ST_AAMT-ST.ST_FAMT ELSE 0 END,0)) CASH_RECEIVING_T2,
                        SUM(NVL(CASE WHEN ST.DUETYPE='RM' AND ST.RDAY=3 THEN ST.ST_AMT-ST.ST_AAMT-ST.ST_FAMT ELSE 0 END,0)) CASH_RECEIVING_T3,
                        SUM(NVL(CASE WHEN ST.DUETYPE='RM' AND ST.RDAY>3 THEN ST.ST_AMT-ST.ST_AAMT-ST.ST_FAMT ELSE 0 END,0)) CASH_RECEIVING_TN,
                        SUM(NVL(CASE WHEN ST.DUETYPE='SM' AND ST.TDAY=0 THEN ST.ST_AMT-ST.ST_AAMT-ST.ST_FAMT ELSE 0 END,0)) CASH_SENDING_T0,
                        SUM(NVL(CASE WHEN ST.DUETYPE='SM' AND ST.TDAY=1 THEN ST.ST_AMT-ST.ST_AAMT-ST.ST_FAMT ELSE 0 END,0)) CASH_SENDING_T1,
                        SUM(NVL(CASE WHEN ST.DUETYPE='SM' AND ST.TDAY=2 THEN ST.ST_AMT-ST.ST_AAMT-ST.ST_FAMT ELSE 0 END,0)) CASH_SENDING_T2,
                        SUM(NVL(CASE WHEN ST.DUETYPE='SM' AND ST.TDAY=3 THEN ST.ST_AMT-ST.ST_AAMT-ST.ST_FAMT ELSE 0 END,0)) CASH_SENDING_T3,
                        SUM(NVL(CASE WHEN ST.DUETYPE='SM' AND ST.TDAY>3 THEN ST.ST_AMT-ST.ST_AAMT-ST.ST_FAMT ELSE 0 END,0)) CASH_SENDING_TN
                FROM
                    VW_BD_PENDING_SETTLEMENT ST WHERE DUETYPE='RM' OR DUETYPE='SM'
                GROUP BY AFACCTNO) ST
                on ST.AFACCTNO=cimast.acctno
                WHERE cimast.acctno = V_AFACCTNO;
        elsif v_margintype in ('S','T') and (length(v_groupleader)=0 or  v_groupleader is null) then
            --Tai khoan margin khong tham gia group
            OPEN PV_REFCURSOR FOR
                SELECT
                   /*
                   greatest(least((nvl(AF.MRCRLIMIT,0) + nvl(se.SEAMT,0)+
                                nvl(se.receivingamt,0)) + nvl(se.trfamt,0)
                        ,nvl(adv.avladvance,0) + nvL(AF.MRCRLIMITMAX,0)) +
                   nvl(af.advanceline,0) + balance- odamt -nvl(secureamt,0) - ramt,0) PURCHASINGPOWER,
                   */
                   greatest(least((nvl(AF.MRCRLIMIT,0) + nvl(se.SEAMT,0)+
                                nvl(se.receivingamt,0))
                        ,nvl(adv.avladvance,0) + nvL(AF.MRCRLIMITMAX,0)+nvl(AF.MRCRLIMIT,0)) +
                   nvl(af.advanceline,0) + balance- odamt -nvl(secureamt,0) - ramt,0) PURCHASINGPOWER,
                   balance CASH_ON_HAND,
                   nvl(b.secureamt,0) ORDERAMT,
                greatest(-(nvl(af.advanceline,0) + cimast.balance+least(nvl(af.mrcrlimit,0),nvl(b.secureamt,0))+ nvl(se.receivingamt,0)- cimast.odamt - NVL (b.advamt, 0)-nvl(b.secureamt,0) - cimast.ramt),0) OUTSTANDING,
                nvl(af.advanceline,0) ADVANCEDLINE,
                nvl(adv.avladvance,0) AVLADVANCED,
                nvl(AF.mrcrlimitmax,0) MRCRLIMITMAX,
                --nvl(af.advanceline,0) + nvl(AF.mrcrlimitmax,0) + balance- odamt - nvl(secureamt,0) - ramt avllimit,
                nvl(CASH_RECEIVING_T0,0) CASH_RECEIVING_T0,
                nvl(CASH_RECEIVING_T1,0) CASH_RECEIVING_T1,
                nvl(CASH_RECEIVING_T2,0) CASH_RECEIVING_T2,
                nvl(CASH_RECEIVING_T3,0) CASH_RECEIVING_T3,
                nvl(CASH_RECEIVING_TN,0) CASH_RECEIVING_TN,
                nvl(CASH_SENDING_T0,0) CASH_SENDING_T0,
                nvl(CASH_SENDING_T1,0) CASH_SENDING_T1,
                nvl(CASH_SENDING_T2,0) CASH_SENDING_T2,
                nvl(CASH_SENDING_T3,0) CASH_SENDING_T3,
                nvl(CASH_SENDING_TN,0) CASH_SENDING_TN
                from cimast inner join afmast af on cimast.acctno=af.acctno
                    LEFT JOIN
                    (select * from v_getbuyorderinfo where afacctno = V_AFACCTNO) b
                    on  cimast.acctno = b.afacctno
                    LEFT JOIN
                    (select * from v_getsecmargininfo SE where se.afacctno = V_AFACCTNO) se
                    on se.afacctno=cimast.acctno
                    LEFT JOIN
                    (select sum(aamt) aamt,sum(depoamt) avladvance,afacctno from v_getAccountAvlAdvance where afacctno = V_AFACCTNO group by afacctno) adv
                    on adv.afacctno=cimast.acctno
                    LEFT JOIN
                    (SELECT AFACCTNO,
                            SUM(NVL(CASE WHEN ST.DUETYPE='RM' AND ST.RDAY=0 THEN ST.ST_AMT-ST.ST_AAMT-ST.ST_FAMT ELSE 0 END,0)) CASH_RECEIVING_T0,
                            SUM(NVL(CASE WHEN ST.DUETYPE='RM' AND ST.RDAY=1 THEN ST.ST_AMT-ST.ST_AAMT-ST.ST_FAMT ELSE 0 END,0)) CASH_RECEIVING_T1,
                            SUM(NVL(CASE WHEN ST.DUETYPE='RM' AND ST.RDAY=2 THEN ST.ST_AMT-ST.ST_AAMT-ST.ST_FAMT ELSE 0 END,0)) CASH_RECEIVING_T2,
                            SUM(NVL(CASE WHEN ST.DUETYPE='RM' AND ST.RDAY=3 THEN ST.ST_AMT-ST.ST_AAMT-ST.ST_FAMT ELSE 0 END,0)) CASH_RECEIVING_T3,
                            SUM(NVL(CASE WHEN ST.DUETYPE='RM' AND ST.RDAY>3 THEN ST.ST_AMT-ST.ST_AAMT-ST.ST_FAMT ELSE 0 END,0)) CASH_RECEIVING_TN,
                            SUM(NVL(CASE WHEN ST.DUETYPE='SM' AND ST.TDAY=0 THEN ST.ST_AMT-ST.ST_AAMT-ST.ST_FAMT ELSE 0 END,0)) CASH_SENDING_T0,
                            SUM(NVL(CASE WHEN ST.DUETYPE='SM' AND ST.TDAY=1 THEN ST.ST_AMT-ST.ST_AAMT-ST.ST_FAMT ELSE 0 END,0)) CASH_SENDING_T1,
                            SUM(NVL(CASE WHEN ST.DUETYPE='SM' AND ST.TDAY=2 THEN ST.ST_AMT-ST.ST_AAMT-ST.ST_FAMT ELSE 0 END,0)) CASH_SENDING_T2,
                            SUM(NVL(CASE WHEN ST.DUETYPE='SM' AND ST.TDAY=3 THEN ST.ST_AMT-ST.ST_AAMT-ST.ST_FAMT ELSE 0 END,0)) CASH_SENDING_T3,
                            SUM(NVL(CASE WHEN ST.DUETYPE='SM' AND ST.TDAY>3 THEN ST.ST_AMT-ST.ST_AAMT-ST.ST_FAMT ELSE 0 END,0)) CASH_SENDING_TN
                    FROM
                        VW_BD_PENDING_SETTLEMENT ST WHERE DUETYPE='RM' OR DUETYPE='SM'
                    GROUP BY AFACCTNO) ST
                    on ST.AFACCTNO=cimast.acctno
                    WHERE cimast.acctno = V_AFACCTNO;
        else
            --Tai khoan margin join theo group
            OPEN PV_REFCURSOR FOR
            SELECT
                /*
                LEAST(SUM((NVL(AF.MRCRLIMIT,0) + NVL(SE.SEAMT,0)+
                                    NVL(SE.RECEIVINGAMT,0)) + nvl(se.trfamt,0))
                            ,sum(nvl(adv.avladvance,0) +NVL(AF.MRCRLIMITMAX,0)))
                       + sum(BALANCE- ODAMT - NVL (ADVAMT, 0)-NVL(SECUREAMT,0) - RAMT) PURCHASINGPOWER,
                */
                LEAST(SUM((NVL(AF.MRCRLIMIT,0) + NVL(SE.SEAMT,0)+
                                    NVL(SE.RECEIVINGAMT,0)) )
                            ,sum(nvl(adv.avladvance,0) +NVL(AF.MRCRLIMITMAX,0)+NVL(AF.MRCRLIMIT,0)))
                       + sum(BALANCE- ODAMT - NVL (ADVAMT, 0)-NVL(SECUREAMT,0) - RAMT) PURCHASINGPOWER,
                sum(BALANCE) CASH_ON_HAND,
                sum(nvl(b.secureamt,0)) ORDERAMT,
                sum(nvl(af.advanceline,0) + cimast.balance+least(nvl(af.mrcrlimit,0),nvl(b.secureamt,0))+ nvl(se.receivingamt,0)- cimast.odamt - NVL (b.advamt, 0)-nvl(b.secureamt,0) - cimast.ramt) OUTSTANDING,
                sum(nvl(af.advanceline,0)) ADVANCEDLINE,
                sum(nvl(adv.avladvance,0)) AVLADVANCED,
                sum(nvl(AF.mrcrlimitmax,0)) MRCRLIMITMAX,
                --sum(nvl(af.advanceline,0) + nvl(AF.mrcrlimitmax,0) + balance- odamt - nvl(secureamt,0) - ramt) avllimit,
                sum(nvl(CASH_RECEIVING_T0,0)) CASH_RECEIVING_T0,
                sum(nvl(CASH_RECEIVING_T1,0)) CASH_RECEIVING_T1,
                sum(nvl(CASH_RECEIVING_T2,0)) CASH_RECEIVING_T2,
                sum(nvl(CASH_RECEIVING_T3,0)) CASH_RECEIVING_T3,
                sum(nvl(CASH_RECEIVING_TN,0)) CASH_RECEIVING_TN,
                sum(nvl(CASH_SENDING_T0,0)) CASH_SENDING_T0,
                sum(nvl(CASH_SENDING_T1,0)) CASH_SENDING_T1,
                sum(nvl(CASH_SENDING_T2,0)) CASH_SENDING_T2,
                sum(nvl(CASH_SENDING_T3,0)) CASH_SENDING_T3,
                sum(nvl(CASH_SENDING_TN,0)) CASH_SENDING_TN

               from cimast inner join afmast af on cimast.acctno=af.acctno and af.groupleader=v_groupleader
               left join
                (select b.* from v_getbuyorderinfo  b, afmast af where b.afacctno =af.acctno and af.groupleader=v_groupleader) b
                on  cimast.acctno = b.afacctno
                LEFT JOIN
                (select b.* from v_getsecmargininfo b, afmast af where b.afacctno =af.acctno and af.groupleader=v_groupleader) se
                on se.afacctno=cimast.acctno
                LEFT JOIN
                (select sum(aamt) aamt,sum(depoamt) avladvance,afacctno from V_DAYADVANCESCHEDULE b, afmast af where b.afacctno =af.acctno and af.groupleader=v_groupleader group by v_groupleader) adv
                on adv.afacctno=cimast.acctno
                LEFT JOIN
                (SELECT AFACCTNO,
                        SUM(NVL(CASE WHEN ST.DUETYPE='RM' AND ST.RDAY=0 THEN ST.ST_AMT-ST.ST_AAMT-ST.ST_FAMT ELSE 0 END,0)) CASH_RECEIVING_T0,
                        SUM(NVL(CASE WHEN ST.DUETYPE='RM' AND ST.RDAY=1 THEN ST.ST_AMT-ST.ST_AAMT-ST.ST_FAMT ELSE 0 END,0)) CASH_RECEIVING_T1,
                        SUM(NVL(CASE WHEN ST.DUETYPE='RM' AND ST.RDAY=2 THEN ST.ST_AMT-ST.ST_AAMT-ST.ST_FAMT ELSE 0 END,0)) CASH_RECEIVING_T2,
                        SUM(NVL(CASE WHEN ST.DUETYPE='RM' AND ST.RDAY=3 THEN ST.ST_AMT-ST.ST_AAMT-ST.ST_FAMT ELSE 0 END,0)) CASH_RECEIVING_T3,
                        SUM(NVL(CASE WHEN ST.DUETYPE='RM' AND ST.RDAY>3 THEN ST.ST_AMT-ST.ST_AAMT-ST.ST_FAMT ELSE 0 END,0)) CASH_RECEIVING_TN,
                        SUM(NVL(CASE WHEN ST.DUETYPE='SM' AND ST.TDAY=0 THEN ST.ST_AMT-ST.ST_AAMT-ST.ST_FAMT ELSE 0 END,0)) CASH_SENDING_T0,
                        SUM(NVL(CASE WHEN ST.DUETYPE='SM' AND ST.TDAY=1 THEN ST.ST_AMT-ST.ST_AAMT-ST.ST_FAMT ELSE 0 END,0)) CASH_SENDING_T1,
                        SUM(NVL(CASE WHEN ST.DUETYPE='SM' AND ST.TDAY=2 THEN ST.ST_AMT-ST.ST_AAMT-ST.ST_FAMT ELSE 0 END,0)) CASH_SENDING_T2,
                        SUM(NVL(CASE WHEN ST.DUETYPE='SM' AND ST.TDAY=3 THEN ST.ST_AMT-ST.ST_AAMT-ST.ST_FAMT ELSE 0 END,0)) CASH_SENDING_T3,
                        SUM(NVL(CASE WHEN ST.DUETYPE='SM' AND ST.TDAY>3 THEN ST.ST_AMT-ST.ST_AAMT-ST.ST_FAMT ELSE 0 END,0)) CASH_SENDING_TN
                FROM
                    VW_BD_PENDING_SETTLEMENT ST WHERE DUETYPE='RM' OR DUETYPE='SM'
                GROUP BY AFACCTNO) ST
                on ST.AFACCTNO=cimast.acctno;
        end if;

EXCEPTION
    WHEN others THEN
        return;
END;

 
 
 
 
/
