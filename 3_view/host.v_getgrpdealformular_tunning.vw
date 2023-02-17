SET DEFINE OFF;
CREATE OR REPLACE FORCE VIEW V_GETGRPDEALFORMULAR_TUNNING
(AFACCTNO, GROUPID, LNACCTNO, SUMALLVALUE, ODDF, 
 TA0DF, IRATE, MRATE, LRATE, DFBLOCKAMT, 
 EXAMT, CURAMT, CURINT, CURFEE, INTPAIDMETHOD, 
 RATE1, RATE2, CFRATE1, CFRATE2, MINTERM, 
 PRINFRQ, RLSDATE, DUEDATE, GOCPHAITRA, INTMIN, 
 FEEMIN, DUE, INTPAID, FEEPAID, TADF, 
 DFAMT, ODOVERDUEDF, ODDUEDF, ODSELLDF, MAXDEPOAMT, 
 VNDSELLDF, DDF, DOVERDUEDF, DDUEDF, RTTDF, 
 ODCALLRTTDF, ODCALLMRATE, ODCALLLRATE, ODCALLDF, VNDWITHDRAWDF, 
 ADDVALUE, ODCALLSELLDF, ODCALLSELLMRATE, ODCALLSELLRCB, ODCALLSELLRXL)
BEQUEATH DEFINER
AS 
(
SELECT A."AFACCTNO",A."GROUPID",A."LNACCTNO",A."SUMALLVALUE",A."ODDF",A."TA0DF",A."IRATE",A."MRATE",A."LRATE",A."DFBLOCKAMT",A."EXAMT",A."CURAMT",A."CURINT",A."CURFEE",A."INTPAIDMETHOD",A."RATE1",A."RATE2",A."CFRATE1",A."CFRATE2",A."MINTERM",A."PRINFRQ",A."RLSDATE",A."DUEDATE",A."GOCPHAITRA",A."INTMIN",A."FEEMIN",A."DUE",A."INTPAID",A."FEEPAID",A."TADF",A."DFAMT",A."ODOVERDUEDF",A."ODDUEDF",A."ODSELLDF",A."MAXDEPOAMT",A."VNDSELLDF",A."DDF",A."DOVERDUEDF",A."DDUEDF",A."RTTDF",A."ODCALLRTTDF",A."ODCALLMRATE",A."ODCALLLRATE", CEIL( ODcallRttDF + GREATEST(DoverdueDF + DdueDF - ODcallRttDF ,0)) ODcallDF, ROUND(LEAST ( GREATEST ( TADF/(CASE WHEN IRATE/100=0 THEN 1 ELSE IRATE/100 END) - DDF ,0 ), dfamt )) VNDwithdrawDF,
    case when FLOOR(TADF-DDF*(IRATE/100)) >0 then 0 else abs(FLOOR(TADF-DDF*(IRATE/100))) end ADDVALUE, ROUND(ODCALLRTTDF + GREATEST(DoverdueDF-ODCALLRTTDF,0)) ODCALLSELLDF,
    ODCALLMRATE + GREATEST ( DoverdueDF - ODCALLMRATE,0) ODCALLSELLMRATE,  ODCALLMRATE + GREATEST ( DoverdueDF - ODCALLMRATE + DdueDF,0) ODCALLSELLRCB,
    ODCALLLRATE + GREATEST ( DoverdueDF - ODCALLLRATE,0) ODCALLSELLRXL

FROM (
    SELECT A.*,  GREATEST ( 0 ,  ODoverdueDF - VNDSellDF - dfamt - A.DFBLOCKAMT ) DoverdueDF, ROUND(GREATEST ( 0 ,  ODdueDF - VNDSellDF - dfamt - A.DFBLOCKAMT )) DdueDF
     , CASE WHEN DDF=0 THEN 10000000 ELSE ROUND(TADF/(CASE WHEN DDF=0 THEN 1 ELSE DDF END),4) * 100  END RTTDF, CEIL(GREATEST ( DDF - TADF/ ((CASE WHEN IRATE=0 THEN 1 ELSE IRATE END)/100) ,0)) ODCALLRTTDF,
        ROUND(GREATEST ( DDF - TADF/ ((CASE WHEN MRATE=0 THEN 1 ELSE MRATE END)/100) ,0)) ODCALLMRATE, ROUND(GREATEST ( DDF - TADF/ ((CASE WHEN LRATE=0 THEN 1 ELSE LRATE END)/100) ,0)) ODCALLLRATE

         FROM (
        SELECT A.*,ROUND(NVL(B.MAXDEPOAMT,0),0) MAXDEPOAMT, CASE WHEN ROUND(LEAST(A.ODSELLDF,NVL(B.MAXDEPOAMT,0))) <=2 THEN 0 ELSE ROUND(LEAST(A.ODSELLDF,NVL(B.MAXDEPOAMT,0))) END VNDSellDF,  ROUND(GREATEST ( 0 ,  ODDF - LEAST(A.ODSELLDF,NVL(B.MAXDEPOAMT,0)) - dfamt - A.DFBLOCKAMT )) DDF FROM (

         SELECT AFACCTNO,GROUPID,LNACCTNO, SUMALLVALUE,  ODDF, TA0DF,IRATE, MRATE,LRATE,DFBLOCKAMT,EXAMT,
                   CURAMT, CURINT, CURFEE, INTPAIDMETHOD, RATE1, RATE2,CFRATE1, CFRATE2, MINTERM, PRINFRQ, RLSDATE, DUEDATE, GOCPHAITRA, INTMIN, FEEMIN, DUE,
                   INTPAID , FEEPAID,TADF,DFAMT, ODoverdueDF,ODdueDF,
                   CASE WHEN DUE='Y' THEN ODDF ELSE CEIL(GREATEST( GOCPHAITRA + INTPAID + FEEPAID, ODDF -  TADF/ (CASE WHEN IRATE/100=0 THEN 1 ELSE IRATE/100 END) ) - EXAMT) END ODSellDF
            FROM (


                SELECT AFACCTNO,GROUPID,LNACCTNO, SUMALLVALUE, ODDF, TA0DF, CURAMT, CURINT, CURFEE, INTPAIDMETHOD,DFBLOCKAMT,EXAMT,
                       RATE1, RATE2,CFRATE1, CFRATE2, MINTERM, PRINFRQ, RLSDATE, DUEDATE, GOCPHAITRA, INTMIN, FEEMIN, DUE,IRATE,MRATE,LRATE,TADF,DFAMT,  ODoverdueDF,ODdueDF,INTPENA_CUR, FEEPENA_CUR,
                       CASE WHEN INTPAIDMETHOD IN ('I','P') THEN
                            (case when CURAMT =0 then INTMIN
                                else GREATEST ( INTMIN , CEIL(GOCPHAITRA / CURAMT * CURINT) )
                             end)
                        ELSE
                            CASE WHEN GOCPHAITRA < CURAMT THEN 0 ELSE  CASE WHEN INTMIN+FEEMIN < CURINT+CURFEE THEN  GREATEST ( INTMIN, CURINT) + INTPENA_CUR  ELSE GREATEST ( INTMIN, CURINT) END  END
                        END INTPAID,

                       CASE WHEN INTPAIDMETHOD IN ('I','P') THEN
                            (case when CURAMT =0 then FEEMIN
                                else GREATEST ( FEEMIN , CEIL(GOCPHAITRA / CURAMT * CURFEE) )
                             end)
                        ELSE
                            CASE WHEN GOCPHAITRA < CURAMT THEN 0 ELSE  CASE WHEN INTMIN+FEEMIN < CURINT+CURFEE THEN GREATEST ( FEEMIN, CURFEE) + FEEPENA_CUR ELSE  GREATEST ( FEEMIN, CURFEE) END END
                        END FEEPAID

                FROM (
                    SELECT A.*, B.DFAMT, B.IRATE, B.MRATE,B.LRATE, B.DFBLOCKAMT,B.EXAMT,
                    CASE WHEN getcurrdate - TO_DATE(RLSDATE,'DD/MM/RRRR') >= MINTERM THEN 0 ELSE
                             ROUND( (GOCPHAITRA *   (LEAST(Minterm, PRINFRQ)* RATE1 + GREATEST ( 0 , MINTERM - PRINFRQ) * RATE2) ) /100/360) END INTMIN,
                    CASE WHEN getcurrdate - TO_DATE(RLSDATE,'DD/MM/RRRR') >= MINTERM THEN 0 ELSE
                             ROUND( (GOCPHAITRA *   (LEAST(Minterm, PRINFRQ)* CFRATE1 + GREATEST ( 0 , MINTERM - PRINFRQ) * CFRATE2) ) /100/360) END FEEMIN,

                    ROUND (GOCPHAITRA * RATE1 * GREATEST (least(MINTERM,PRINFRQ) - TO_NUMBER(getcurrdate - TO_DATE(RLSDATE,'DD/MM/RRRR')),0 ) /100/360
                    + GOCPHAITRA * RATE2 * GREATEST (GREATEST(MINTERM-PRINFRQ,0)-GREATEST(getcurrdate - TO_DATE(DUEDATE,'DD/MM/RRRR'),0 ),0) /100/360) INTPENA_CUR,

                    ROUND(GOCPHAITRA * CFRATE1 * GREATEST (least(MINTERM,PRINFRQ) - TO_NUMBER(getcurrdate - TO_DATE(RLSDATE,'DD/MM/RRRR')),0 ) /100/360
                    + GOCPHAITRA * CFRATE2 *  GREATEST (GREATEST(MINTERM-PRINFRQ,0)-GREATEST(getcurrdate - TO_DATE(DUEDATE,'DD/MM/RRRR'),0 ),0) /100/360) FEEPENA_CUR
                    FROM(

                        SELECT AFACCTNO, GROUPID, LNACCTNO, SUMALLVALUE, ODDF, CURAMT, CURINT, CURFEE, INTPAIDMETHOD, RATE1, RATE2,  CFRATE1, CFRATE2, MINTERM,
                            DUE, ODoverdueDF,ODdueDF, PRINFRQ, RLSDATE, DUEDATE , SUMALLVALUE - SUM(TADF) TADF , LEAST(SUM(GOCPHAITRA),CURAMT) GOCPHAITRA , SUMALLVALUE TA0DF FROM
                        (

                          SELECT B.AFACCTNO,B.GROUPID,A.LNACCTNO, B.CODEID, B.SUMALLVALUE SUMALLVALUE , B.SUMVALUE,TADF, B.RIPAYDF, B.DFTRADE, B.SUMALLVALUE TA0DF,B.DFEXECQTTY, CURAMT + CURINT + CURFEE ODDF,
                                     CURAMT, CURINT, CURFEE, INTPAIDMETHOD, RATE1, RATE2,CFRATE1, CFRATE2, DUE,
                                      ODoverdueDF,ODdueDF,
                                     LEAST(MINTERM, TO_NUMBER( TO_DATE(OVERDUEDATE,'DD/MM/RRRR') - TO_DATE(RLSDATE,'DD/MM/RRRR')) )  MINTERM,
                                     PRINFRQ, RLSDATE, DUEDATE,
                                     CASE WHEN (B.DFTRADE + B.DFEXECQTTY ) *  CURAMT * B.RIPAYDF = 0 THEN 0 ELSE
                                     ROUND(least( CURAMT + CURINT + CURFEE, round(B.DFEXECQTTY / (CASE WHEN QI = 0 THEN 1 ELSE QI END)  *  CURAMT * B.RIPAYDF) )) END  GOCPHAITRA,
                                     QI

                             FROM (  SELECT ln.trfacctno,LN.ACCTNO LNACCTNO, round(LNS.NML) + round(LNS.OVD) CURAMT,
                                         round(LNS.INTNMLACR) + round(LNS.intdue) + round(LNS.intovd) + round(LNS.intovdprin) CURINT,
                                          round(LNS.FEEINTNMLACR) + round(LNS.FEEINTOVDACR) + round(LNS.FEEINTDUE) + round(LNS.FEEINTNMLOVD) CURFEE, LN.INTPAIDMETHOD,
                                         round(LNS.OVD) + round(LNS.INTOVD) + round(LNS.INTOVDPRIN) + round(LNS.FEEINTOVDACR) + round(LNS.FEEINTNMLOVD) ODoverdueDF,
                                         CASE WHEN DUE='Y' THEN LNS.NML + LNS.intdue +  LNS.FEEINTDUE ELSE  LNS.intdue +  LNS.FEEINTDUE END ODdueDF,
                                         LNS.RATE1, LNS.RATE2, LNS.CFRATE1, LNS.CFRATE2, LN.MINTERM, TO_DATE(lns.DUEDATE,'DD/MM/RRRR') -  TO_DATE(lns.RLSDATE,'DD/MM/RRRR') PRINFRQ, LN.RLSDATE,LNS.DUEDATE,lns.OVERDUEDATE,
                                         CASE WHEN getcurrdate - TO_DATE(OVERDUEDATE,'DD/MM/RRRR') >=0 THEN 'Y' ELSE 'N' END DUE
                                     FROM lnschd LNS, LNMAST LN--, LNTYPE LNT--, DFGROUP DFG
                                     WHERE --LN.ACCTNO = DFG.LNACCTNO AND
                                     LN.ACCTNO=LNS.ACCTNO --AND LN.ACTYPE=LNT.ACTYPE
                                     and REFTYPE='P'
                                 ) A ,
                                (
                                  SELECT QI, AFACCTNO, LNACCTNO, GROUPID, CODEID,SUMALLVALUE, SUMVALUE,DFTRADE,  TA0DF, TADF,
                                        EXECQTTY DFEXECQTTY,
                                        CASE WHEN EXECQTTY>0 THEN SUMALLVALUEi / (CASE WHEN SUMALLVALUE=0 THEN 1 ELSE SUMALLVALUE END) ELSE 0 END RiPAYDF
                                          FROM
                                        (
                                         SELECT SUM(QI) QI, AFACCTNO, LNACCTNO, GROUPID, CODEID, TA0DF,
                                         SUMALLVALUE, SUM(SUMALLVALUEi) SUMALLVALUEi, SUM (SUMVALUE) SUMVALUE, SUM(DFTRADE) DFTRADE, SUM(DFEXECQTTY) EXECQTTY, SUM(TADF) TADF
                                         FROM (
                                              SELECT  NVL(CACASHQTTY,0) + NVL(DFQTTY,0) +  NVL(RCVQTTY,0) +  NVL(BLOCKQTTY,0) +  NVL(CARCVQTTY,0) QI,
                                                  DF.AFACCTNO,DF.LNACCTNO, DF.GROUPID, DF.CODEID, round(NVL(DF.DFQTTY,0) * DF.DFRATE * SBS.DFREFPRICE /100) SUMVALUE ,
                                                  NVL(DF.DFQTTY,0) - NVL(ODM.EXECQTTY,0)  DFTRADE,
                                                       DFA.SUMALLVALUE TA0DF,
                                                       NVL(CACASHQTTY,0) * (DFRATE /100)  + ( NVL(DFQTTY,0) +  NVL(RCVQTTY,0) +  NVL(BLOCKQTTY,0) +  NVL(CARCVQTTY,0)) * (DFRATE / 100) * DFREFPRICE SUMALLVALUEi,
                                                      NVL(ODM.EXECQTTY,0) DFEXECQTTY,  DFA.SUMALLVALUE,
                                                      NVL(ODM.EXECQTTY,0) * DF.DFRATE * SBS.DFREFPRICE /100 TADF
                                                      FROM DFMAST DF ,
                                                          (SELECT OD.REFID DFACCTNO, ODM.CODEID, SUM (OD.QTTY) QTTY, SUM(OD.EXECQTTY) EXECQTTY  FROM ODMAPEXT OD, ODMAST ODM
                                                              WHERE OD.ORDERID = ODM.ORDERID AND ODM.EXECTYPE='MS' AND OD.DELTD<>'Y'
                                                          GROUP BY OD.REFID, ODM.CODEID) ODM,
                                                          (
                                                              SELECT GROUPID, LNACCTNO, SUM( NVL(CACASHQTTY,0) * (DFRATE /100) ) + SUM (( NVL(DFQTTY,0) +  NVL(RCVQTTY,0) +  NVL(BLOCKQTTY,0) +  NVL(CARCVQTTY,0)) * (DFRATE / 100) * DFREFPRICE) SUMALLVALUE
                                                                  FROM DFMAST DFM, SECURITIES_INFO SBS WHERE DFM.CODEID=SBS.CODEID
                                                                  GROUP BY GROUPID, LNACCTNO

                                                          ) DFA, SECURITIES_INFO SBS
                                                 WHERE
                                                   DF.CODEID=SBS.CODEID
                                                   AND DF.GROUPID=DFA.GROUPID
                                                   AND DF.ACCTNO = ODM.DFACCTNO (+)

                                          )  GROUP BY AFACCTNO, LNACCTNO, GROUPID, CODEID,
                                          TA0DF,SUMALLVALUE
                                        )

                                ) B--, DFGROUP DF
                             WHERE A.LNACCTNO=B.LNACCTNO --AND DF.LNACCTNO = B.LNACCTNO
                             and b.afacctno = a.trfacctno
                        ) A
                        GROUP BY AFACCTNO, GROUPID, LNACCTNO, SUMALLVALUE, ODDF, CURAMT, CURINT, CURFEE, INTPAIDMETHOD, RATE1, RATE2,  CFRATE1, CFRATE2, MINTERM,
                            DUE, ODoverdueDF,ODdueDF, PRINFRQ, RLSDATE, DUEDATE




                    ) A, DFGROUP B WHERE A.GROUPID=B.GROUPID
                )
            )

        ) A, (
             select groupid , AFACCTNO, floor(sum (ADVAMT) * (1-FEERATE*DAYS/100/360)) maxdepoamt from
                (

                    SELECT C.GROUPID, A.AFACCTNO,A.AMT,A.QTTY,b.qtty execqtty,A.FAMT,A.AAMT,A.ORGORDERID,A.PAIDAMT,
                                A.PAIDFEEAMT,A.FEERATE,A.TXDATE,A.CLEARDATE,A.DAYS,
                                 GREATEST(ROUND(A.AMT/A.QTTY*B.QTTY *(100-A.DEFFEERATE-A.SECDUTY)/100),0) ADVAMT
                            FROM (
                                SELECT  1 ISMORTAGE,STSCHD.AFACCTNO,AMT,QTTY,FAMT,
                                        AAMT,ORGORDERID,PAIDAMT,PAIDFEEAMT,
                                        ADT.ADVRATE FEERATE,
                                        STSCHD.TXDATE,
                                       STSCHD.CLEARDATE,
                                       (CASE WHEN cf.VAT='Y' THEN STSCHD.SECDUTY ELSE 0 END) SECDUTY ,
                                       ODTYPE.DEFFEERATE,
                                    (CASE WHEN CLEARDATE -TO_DATE(SYSVAR.VARVALUE,'DD/MM/YYYY')=0 THEN 1 ELSE   CLEARDATE -(CASE WHEN LENGTH(SYSVAR.VARVALUE)=10 THEN TO_DATE(SYSVAR.VARVALUE,'DD/MM/YYYY') ELSE CLEARDATE END)END) DAYS

                                FROM
                                (SELECT STS.ORGORDERID,STS.TXDATE,STS.AFACCTNO, STS.CODEID CODEID,
                                        STS.CLEARDAY ,STS.CLEARCD,STS.AMT ,
                                        STS.QTTY,STS.FAMT,STS.AAMT,STS.PAIDAMT,
                                        STS.PAIDFEEAMT ,MST.actype ,MST.EXECTYPE ,
                                        sts.CLEARDATE ,
                                       --(CASE WHEN TYP.VAT='Y' THEN TO_NUMBER(SYS.VARVALUE) ELSE 0 END) SECDUTY
                                       TO_NUMBER(SYS.VARVALUE) SECDUTY
                                    FROM STSCHD STS,ODMAST MST,SYSVAR SYS
                                    WHERE STS.orgorderid=MST.orderid
                                    AND STS.DELTD <> 'Y' AND STS.STATUS='N' AND STS.DUETYPE='RM'
                                        AND SYS.VARNAME='ADVSELLDUTY' AND SYS.GRNAME='SYSTEM'
                                        AND MST.EXECTYPE='MS'
                                 ) STSCHD,SYSVAR,ODTYPE,
                                 AFMAST AFM, AFTYPE AFT, ADTYPE ADT, cfmast cf
                                WHERE AMT>0 and afm.custid = cf.custid
                                AND STSCHD.AFACCTNO=AFM.ACCTNO AND AFM.ACTYPE=AFT.ACTYPE AND AFT.ADTYPE=ADT.ACTYPE
                                AND SYSVAR.VARNAME='CURRDATE' AND SYSVAR.GRNAME='SYSTEM'
                                AND STSCHD.ACTYPE=ODTYPE.ACTYPE
                                AND STSCHD.txdate=TO_DATE(SYSVAR.VARVALUE,'DD/MM/YYYY')

                            ) A , (SELECT ORDERID, REFID, EXECQTTY QTTY FROM odmapext WHERE DELTD<>'Y' AND STATUS <> 'Y' AND EXECQTTY>0) B, DFMAST C

                            WHERE A.DAYS>0 AND GREATEST(ROUND(A.AMT*(100-A.DEFFEERATE-A.SECDUTY)/100 - FAMT),0) >0
                                AND B.ORDERID=A.ORGORDERID AND B.REFID=C.ACCTNO

                ) A GROUP BY GROUPID, AFACCTNO,(1-FEERATE*DAYS/100/360)

        )  B
        WHERE A.AFACCTNO = B.AFACCTNO (+) AND A.GROUPID = B.GROUPID (+)
    ) A
) A



)
/
