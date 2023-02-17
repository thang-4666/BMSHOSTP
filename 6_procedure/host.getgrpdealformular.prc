SET DEFINE OFF;
CREATE OR REPLACE PROCEDURE getgrpdealformular (PV_REFCURSOR IN OUT PKG_REPORT.REF_CURSOR, p_GROUPID IN VARCHAR2, p_Mortage IN varchar2, p_DFMAST IN varchar2, p_STSCHD IN varchar2, p_EXAMT IN NUMBER, p_TYPE in varchar2)
  IS

    v_strTemp clob;
    v_groupid VARCHAR2(20);
    v_strMORTAGE varchar2(10000);
    v_strDFMAST varchar2(10000);
    v_strSTSCHD varchar2(10000);
    v_strACCTNO varchar2(20);
    v_strSYMBOL varchar2(20);
    v_strDEALTYPE varchar2(1);
    v_lQtty number;
    v_EXAMT number;
    v_strSE varchar2(3000);


BEGIN
    v_groupid:=p_GROUPID;
    v_strMORTAGE:=p_Mortage;
    v_strDFMAST:=p_DFMAST;
    v_strSTSCHD:= p_STSCHD;
    SELECT EXAMT INTO v_EXAMT FROM DFGROUP WHERE GROUPID = v_groupid;
    if p_TYPE = 'EX' then
        v_EXAMT:=p_EXAMT;
    END IF;

v_strTemp:= '
SELECT A.*, CEIL( ODcallRttDF + GREATEST(DoverdueDF + DdueDF - ODcallRttDF ,0)) ODcallDF, ROUND(LEAST ( GREATEST ( TADF/(CASE WHEN IRATE/100=0 THEN 1 ELSE IRATE/100 END) - DDF ,0 ), dfamt )) VNDwithdrawDF,
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
                   CASE WHEN DUE=''Y'' THEN ODDF ELSE CEIL(GREATEST( GOCPHAITRA + INTPAID + FEEPAID, ODDF -  TADF/ (CASE WHEN IRATE/100=0 THEN 1 ELSE IRATE/100 END) ) - ' || v_EXAMT || ') END ODSellDF
            FROM (


                SELECT AFACCTNO,GROUPID,LNACCTNO, SUMALLVALUE, ODDF, TA0DF, CURAMT, CURINT, CURFEE, INTPAIDMETHOD,DFBLOCKAMT,EXAMT,
                       RATE1, RATE2,CFRATE1, CFRATE2, MINTERM, PRINFRQ, RLSDATE, DUEDATE, GOCPHAITRA, INTMIN, FEEMIN, DUE,IRATE,MRATE,LRATE,TADF,DFAMT,  ODoverdueDF,ODdueDF,INTPENA_CUR, FEEPENA_CUR,
                       CASE WHEN INTPAIDMETHOD IN (''I'',''P'') THEN
                            (case when CURAMT =0 then INTMIN
                                else GREATEST ( INTMIN , CEIL(GOCPHAITRA / CURAMT * CURINT) )
                             end)
                        ELSE
                            CASE WHEN GOCPHAITRA < CURAMT THEN 0 ELSE  CASE WHEN INTMIN+FEEMIN < CURINT+CURFEE THEN  GREATEST ( INTMIN, CURINT) + INTPENA_CUR  ELSE GREATEST ( INTMIN, CURINT) END  END
                        END INTPAID,

                       CASE WHEN INTPAIDMETHOD IN (''I'',''P'') THEN
                            (case when CURAMT =0 then FEEMIN
                                else GREATEST ( FEEMIN , CEIL(GOCPHAITRA / CURAMT * CURFEE) )
                             end)
                        ELSE
                            CASE WHEN GOCPHAITRA < CURAMT THEN 0 ELSE  CASE WHEN INTMIN+FEEMIN < CURINT+CURFEE THEN GREATEST ( FEEMIN, CURFEE) + FEEPENA_CUR ELSE  GREATEST ( FEEMIN, CURFEE) END END
                        END FEEPAID

                FROM (
                    sELECT d.* ,
                    CASE WHEN getcurrdate - TO_DATE(RLSDATE,''DD/MM/RRRR'') >= MINTERM THEN 0 ELSE
                             ROUND( (GOCPHAITRA *   (LEAST(Minterm, PRINFRQ)* RATE1 + GREATEST ( 0 , MINTERM - PRINFRQ) * RATE2) ) /100/360) END INTMIN,
                    CASE WHEN getcurrdate - TO_DATE(RLSDATE,''DD/MM/RRRR'') >= MINTERM THEN 0 ELSE
                             ROUND( (GOCPHAITRA *   (LEAST(Minterm, PRINFRQ)* CFRATE1 + GREATEST ( 0 , MINTERM - PRINFRQ) * CFRATE2) ) /100/360) END FEEMIN,

                    ROUND (GOCPHAITRA * RATE1 * GREATEST (least(MINTERM,PRINFRQ) - TO_NUMBER(getcurrdate - TO_DATE(RLSDATE,''DD/MM/RRRR'')),0 ) /100/360
                    + GOCPHAITRA * RATE2 * GREATEST (GREATEST(MINTERM-PRINFRQ,0)-GREATEST(getcurrdate - TO_DATE(DUEDATE,''DD/MM/RRRR''),0 ),0) /100/360) INTPENA_CUR,

                    ROUND(GOCPHAITRA * CFRATE1 * GREATEST (least(MINTERM,PRINFRQ) - TO_NUMBER(getcurrdate - TO_DATE(RLSDATE,''DD/MM/RRRR'')),0 ) /100/360
                    + GOCPHAITRA * CFRATE2 *  GREATEST (GREATEST(MINTERM-PRINFRQ,0)-GREATEST(getcurrdate - TO_DATE(DUEDATE,''DD/MM/RRRR''),0 ),0) /100/360) FEEPENA_CUR
                    FROM (

                     SELECT  B.AFACCTNO, B.GROUPID, A.LNACCTNO, SUMALLVALUE,  CURAMT + CURINT + CURFEE ODDF, CURAMT, CURINT, CURFEE, INTPAIDMETHOD, RATE1, RATE2,  CFRATE1, CFRATE2, MINTERM,
                            DUE, ODoverdueDF,ODdueDF, PRINFRQ, RLSDATE, DUEDATE , DF.DFAMT, DF.IRATE, DF.MRATE, DF.LRATE, DF.DFBLOCKAMT, DF.EXAMT,
                            SUMALLVALUE - SUM(TADF) TADF, SUMALLVALUE TA0DF,
                             LEAST( SUM(CASE WHEN (B.DFTRADE + B.DFEXECQTTY ) *  CURAMT * B.RIPAYDF = 0 THEN 0 ELSE
                             ROUND(least( CURAMT + CURINT + CURFEE, round(B.DFEXECQTTY / (CASE WHEN QI = 0 THEN 1 ELSE QI END)  *  CURAMT * B.RIPAYDF) )) END),CURAMT)  GOCPHAITRA

                     FROM (  SELECT LN.ACCTNO LNACCTNO, round(LNS.NML) + round(LNS.OVD) CURAMT,
                                 round(LNS.INTNMLACR) + round(LNS.intdue) + round(LNS.intovd) + round(LNS.intovdprin) CURINT,
                                  round(LNS.FEEINTNMLACR) + round(LNS.FEEINTOVDACR) + round(LNS.FEEINTDUE) + round(LNS.FEEINTNMLOVD) CURFEE, LN.INTPAIDMETHOD,
                                 round(LNS.OVD) + round(LNS.INTOVD) + round(LNS.INTOVDPRIN) + round(LNS.FEEINTOVDACR) + round(LNS.FEEINTNMLOVD) ODoverdueDF,
                                 CASE WHEN DUE=''Y'' THEN LNS.NML + LNS.intdue +  LNS.FEEINTDUE ELSE  LNS.intdue +  LNS.FEEINTDUE END ODdueDF,
                                 LNS.RATE1, LNS.RATE2, LNS.CFRATE1, LNS.CFRATE2, LN.MINTERM, TO_DATE(lns.DUEDATE,''DD/MM/RRRR'') -  TO_DATE(lns.RLSDATE,''DD/MM/RRRR'') PRINFRQ, LN.RLSDATE,LNS.DUEDATE,lns.OVERDUEDATE,
                                 CASE WHEN getcurrdate - TO_DATE(OVERDUEDATE,''DD/MM/RRRR'') >=0 THEN ''Y'' ELSE ''N'' END DUE
                             FROM vw_lnschd_all LNS, LNMAST LN, LNTYPE LNT, DFGROUP DFG
                             WHERE LN.ACCTNO = DFG.LNACCTNO AND LN.ACCTNO=LNS.ACCTNO AND LN.ACTYPE=LNT.ACTYPE  and REFTYPE=''P''
                        ) A ,
                        (
                          SELECT QI, AFACCTNO, LNACCTNO, GROUPID, CODEID,SUMALLVALUE, SUMVALUE,DFTRADE,  TA0DF, TADF,  EXECQTTY DFEXECQTTY,
                                CASE WHEN EXECQTTY>0 THEN SUMALLVALUEi / (CASE WHEN SUMALLVALUE=0 THEN 1 ELSE SUMALLVALUE END) ELSE 0 END RiPAYDF
                                   FROM
                                (

                                  SELECT QI, AFACCTNO, LNACCTNO, GROUPID, CODEID, TA0DF,SUMALLVALUE, SUMALLVALUEi, SUM (SUMVALUE) SUMVALUE, SUM(DFTRADE) DFTRADE, SUM(DFEXECQTTY) EXECQTTY, SUM(TADF) TADF
                                  FROM (
                                       SELECT QI, DF.AFACCTNO,DF.LNACCTNO, DF.GROUPID, DF.CODEID, round(NVL(DF.DFQTTY,0) * DF.DFRATE * SBS.DFREFPRICE /100) SUMVALUE ,  NVL(DF.DFQTTY,0) - NVL(ODM.EXECQTTY,0)  DFTRADE,
                                                DFA.SUMALLVALUE TA0DF, SUMALLVALUEi,
                                               NVL(ODM.EXECQTTY,0) DFEXECQTTY,  DFA.SUMALLVALUE,
                                               CASE WHEN ODM.EXECQTTY>0 THEN ROUND( SUMALLVALUEi / (CASE WHEN DFA.SUMALLVALUE=0 THEN 1 ELSE DFA.SUMALLVALUE END),6) ELSE 0 END RiPAYDF,
                                               NVL(ODM.EXECQTTY,0) * DF.DFRATE * SBS.DFREFPRICE /100 TADF
                                               FROM (' || v_strDFMAST || ') DF ,
                                                   (SELECT OD.REFID DFACCTNO, ODM.CODEID, SUM (OD.QTTY) QTTY, SUM(OD.EXECQTTY) EXECQTTY  FROM (' || v_strMortage || ') OD, ODMAST ODM
                                                       WHERE OD.ORDERID = ODM.ORDERID AND ODM.GRPORDER=''N'' AND OD.DELTD<>''Y''
                                                   GROUP BY OD.REFID, ODM.CODEID) ODM,
                                                   (
                                                       SELECT GROUPID, DFM.CODEID, SUM( NVL(CACASHQTTY,0) * (DFRATE /100) ) + SUM (( NVL(DFQTTY,0) +  NVL(RCVQTTY,0) +  NVL(BLOCKQTTY,0) +  NVL(CARCVQTTY,0)) * (DFRATE / 100) * DFREFPRICE) SUMALLVALUEi,
                                                                       SUM ( NVL(CACASHQTTY,0) + NVL(DFQTTY,0) +  NVL(RCVQTTY,0) +  NVL(BLOCKQTTY,0) +  NVL(CARCVQTTY,0)) QI
                                                           FROM (' || v_strDFMAST || ') DFM, SECURITIES_INFO SBS WHERE DFM.CODEID=SBS.CODEID
                                                           GROUP BY GROUPID, DFM.CODEID

                                                   ) DFAi,

                                                   (
                                                       SELECT GROUPID, LNACCTNO, SUM( NVL(CACASHQTTY,0) * (DFRATE /100) ) + SUM (( NVL(DFQTTY,0) +  NVL(RCVQTTY,0) +  NVL(BLOCKQTTY,0) +  NVL(CARCVQTTY,0)) * (DFRATE / 100) * DFREFPRICE) SUMALLVALUE
                                                           FROM (' || v_strDFMAST || ') DFM, SECURITIES_INFO SBS WHERE DFM.CODEID=SBS.CODEID
                                                           GROUP BY GROUPID, LNACCTNO

                                                   ) DFA, SECURITIES_INFO SBS
                                          WHERE
                                            DF.CODEID=SBS.CODEID
                                            AND DF.GROUPID=DFA.GROUPID (+)
                                            AND DF.GROUPID=DFAi.GROUPID (+)
                                            AND DF.CODEID=DFAi.CODEID (+)
                                            AND DF.ACCTNO = ODM.DFACCTNO (+)

                                   )  GROUP BY QI, AFACCTNO, LNACCTNO, GROUPID, CODEID, TA0DF,SUMALLVALUE, SUMALLVALUEi


                                )

                        ) B, DFGROUP DF
                     WHERE A.LNACCTNO=B.LNACCTNO AND DF.LNACCTNO = B.LNACCTNO

                     GROUP BY B.AFACCTNO, B.GROUPID, A.LNACCTNO, SUMALLVALUE, CURAMT + CURINT + CURFEE, CURAMT, CURINT, CURFEE, INTPAIDMETHOD, RATE1, RATE2,  CFRATE1, CFRATE2, MINTERM,
                        DUE, ODoverdueDF,ODdueDF, PRINFRQ, RLSDATE, DUEDATE, DF.DFAMT, DF.IRATE, DF.MRATE, DF.LRATE, DF.DFBLOCKAMT, DF.EXAMT

                            )  d
                )
            )



        ) A, (
            SELECT C.GROUPID, A.AFACCTNO,
                 FLOOR(SUM(GREATEST(ROUND(A.AMT/A.QTTY*B.QTTY *(100-A.DEFFEERATE-A.SECDUTY)/100),0))  * (1-FEERATE*DAYS/100/360))  maxdepoamt
            FROM (

              SELECT  1 ISMORTAGE,STSCHD.AFACCTNO,AMT,QTTY,CFMAST.FULLNAME,CFMAST.ADDRESS,CFMAST.idcode LICENSE,FAMT,
                        CUSTODYCD,STSCHD.SYMBOL,AAMT,ORGORDERID,PAIDAMT,PAIDFEEAMT,
                        --SYSVAR1.VARVALUE FEERATE,
                        ADT.ADVRATE FEERATE,
                        SYSVAR2.VARVALUE MINBAL,STSCHD.TXDATE,
                       STSCHD.CLEARDATE,STSCHD.SECDUTY,ODTYPE.DEFFEERATE,
                    (CASE WHEN CLEARDATE -(CASE WHEN LENGTH(SYSVAR.VARVALUE)=10 THEN TO_DATE(SYSVAR.VARVALUE,''DD/MM/YYYY'') ELSE CLEARDATE END)=0 THEN 1 ELSE   CLEARDATE -(CASE WHEN LENGTH(SYSVAR.VARVALUE)=10 THEN TO_DATE(SYSVAR.VARVALUE,''DD/MM/YYYY'') ELSE CLEARDATE END)END) DAYS

                FROM
                (SELECT STS.ORGORDERID,STS.TXDATE,STS.AFACCTNO, STS.CODEID CODEID,
                        STS.CLEARDAY ,STS.CLEARCD,STS.AMT ,
                        STS.QTTY,STS.FAMT,STS.AAMT,STS.PAIDAMT,
                        STS.PAIDFEEAMT ,MST.actype ,MST.EXECTYPE ,
                        AF.custid ,sts.CLEARDATE ,SEC.SYMBOL,
                       (CASE WHEN TYP.VAT=''Y'' THEN TO_NUMBER(SYS.VARVALUE) ELSE 0 END) SECDUTY
                    FROM STSCHD STS,ODMAST MST,AFMAST AF,SBSECURITIES SEC, AFTYPE TYP, SYSVAR SYS
                    WHERE STS.codeid=SEC.codeid AND STS.orgorderid=MST.orderid and mst.afacctno=af.acctno
                    AND STS.DELTD <> ''Y'' AND STS.STATUS=''N'' AND STS.DUETYPE=''RM''
                        AND AF.ACTYPE=TYP.ACTYPE AND SYS.VARNAME=''ADVSELLDUTY'' AND SYS.GRNAME=''SYSTEM'' ' || v_strSTSCHD ||'
                 ) STSCHD,SYSVAR,SYSVAR SYSVAR1,SYSVAR SYSVAR2,ODTYPE,CFMAST, AFMAST AFM, AFTYPE AFT, ADTYPE ADT
                WHERE AMT>0
                AND STSCHD.AFACCTNO=AFM.ACCTNO AND AFM.ACTYPE=AFT.ACTYPE AND AFT.ADTYPE=ADT.ACTYPE
                AND SYSVAR.VARNAME=''CURRDATE'' AND SYSVAR.GRNAME=''SYSTEM''
                AND SYSVAR1.VARNAME=''AINTRATE'' AND SYSVAR1.GRNAME=''SYSTEM''
                AND SYSVAR2.VARNAME=''AMINBAL'' AND SYSVAR2.GRNAME=''SYSTEM''
                AND STSCHD.CUSTID=CFMAST.CUSTID
                AND STSCHD.ACTYPE=ODTYPE.ACTYPE
                AND STSCHD.txdate=to_date((SELECT VARVALUE FROM SYSVAR WHERE VARNAME=''CURRDATE''),''DD/MM/YYYY'')

            ) A , (SELECT ORDERID, REFID, EXECQTTY QTTY FROM (' || v_strMortage || ') WHERE DELTD<>''Y'' AND STATUS <> ''Y'' AND EXECQTTY>0) B, (' || v_strDFMAST || ') C

            WHERE A.DAYS>0 AND GREATEST(ROUND(A.AMT*(100-A.DEFFEERATE-A.SECDUTY)/100 - FAMT),0) >0
                AND B.ORDERID=A.ORGORDERID AND B.REFID=C.ACCTNO
            GROUP BY C.GROUPID, A.AFACCTNO,(1-FEERATE*DAYS/100/360)
        )  B
        WHERE A.AFACCTNO = B.AFACCTNO (+) AND A.GROUPID = B.GROUPID (+)
    ) A
) A WHERE GROUPID = ' || v_groupid ;

--insert into hailtt values(v_strTemp);
OPEN PV_REFCURSOR FOR v_strTemp;


EXCEPTION
    WHEN others THEN
        return;
END;
 
/
