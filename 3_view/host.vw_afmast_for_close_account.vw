SET DEFINE OFF;
CREATE OR REPLACE FORCE VIEW VW_AFMAST_FOR_CLOSE_ACCOUNT
(CUSTODYCD, FULLNAME, IDCODE, IDDATE, IDPLACE, 
 ADDRESS, PHONE, AFACCTNO, TYPENAME, STATUS, 
 BALANCE, OUTSTANDING, BLOCKED, WITHDRAW, DEPOSIT, 
 CRINTACR, ODINTACR, CIWITHDRAWAL, TRADE_QTTY, TRADE_LIMIT_QTTY, 
 LOAN_QTTY, RS_QTTY, SS_QTTY, RM_AMT, SM_AMT, 
 MRCRLIMITMAX, MRCRLIMIT, T0AMT, CA_QTTY, CIDEPOFEEACR, 
 DEPOFEEAMT, NB_CHK_QTTY, NS_CHK_QTTY, EXTENDDAYS, DEPOAMT, 
 WAIT_QTTY, SERETAIL_QTTY, STANDING, DF_QTTY, EMKAMT, 
 GROUPLEADER, TDAMT, DFBLOCKAMT, RPPTSTATUS, FEEDR, 
 VSDDEP, EMKQTTY)
BEQUEATH DEFINER
AS 
SELECT CF.CUSTODYCD, CF.FULLNAME, CF.IDCODE, CF.IDDATE, CF.idplace, cf.address, cf.mobilesms phone, AF.ACCTNO AFACCTNO, TYP.TYPENAME, A0.CDCONTENT STATUS,
              NVL(CI.BALANCE,0) BALANCE, (NVL(LN.LNOUTSTANDING,0) + NVL(DF.FEE,0) + NVL(CI.AMT,0)) OUTSTANDING, NVL(SE.BLOCKED/*-sedtl.qtty*/,0) BLOCKED,
              NVL(SE.WITHDRAW,0) WITHDRAW, NVL(SE.DEPOSIT,0) DEPOSIT, NVL(CI.CRINTACR,0) CRINTACR, NVL(CI.ODINTACR,0) ODINTACR ,
              NVL(CI.BALANCE,0)-(NVL(CI.OVAMT,0)+NVL(CI.DUEAMT,0)+NVL(CI.T0ODAMT,0)+NVL(CI.ODAMT,0)) CIWITHDRAWAL,
              NVL(SE.TRADE_QTTY,0)TRADE_QTTY,/*nvl(sedtl.qtty,0)*/ nvl(se.BLOCKED,0) trade_limit_qtty,
              NVL(SE.LOAN_QTTY,0) LOAN_QTTY, nvl(ST.RS_QTTY,0) RS_QTTY, nvl(ST.SS_QTTY,0) SS_QTTY,
              nvl(ST.RM_AMT,0) RM_AMT, nvl(ST.SM_AMT,0) SM_AMT, AF.MRCRLIMITMAX, AF.MRCRLIMIT, nvl(usl.acclimit,0) AS T0AMT,
              NVL(CA_QTTY,0) CA_QTTY,NVL( CI.CIDEPOFEEACR,0) CIDEPOFEEACR,nvl(CI.DEPOFEEAMT,0) DEPOFEEAMT ,
              nvl(CI.NB_CHK_QTTY,0) NB_CHK_QTTY, nvl(CI.NS_CHK_QTTY,0) NS_CHK_QTTY,
              /*nvl(COUNT_DAYS_EXTEND(AF.ACCTNO),0)*/ 0 EXTENDDAYS, --mac dinh la 0
              nvl(sts.depoamt,0) depoamt,
              NVL(st.RS_QTTY+st.SS_QTTY,0) WAIT_QTTY,
              NVL(seretl.qtty,0) SERETAIL_QTTY,
              /*NVL(sestand.qtty,0)*/ NVL(SE.STANDING,0) standing, NVL(DF.DF_QTTY,0) DF_QTTY,CI.EMKAMT,
              (CASE WHEN mrtype.mrtype='N' THEN 'N' ELSE 'Y' END ) GROUPLEADER,
              nvl(td.balance,0) tdamt,
              NVL(dfgr.dfblockamt,0) dfblockamt,
            /*  (CASE WHEN  NVL(TBLRP.ORDERID,'0') = '0' THEN 'N' ELSE 'Y' END)*/ 'N' RPPTSTATUS,--lay trong fldval
             NVL(CIFEE.AVL_FEEDR,0) FEEDR, NVL(CIFEE.AVL_VSDDEP,0) VSDDEP, NVL(SE.EMKQTTY,0) EMKQTTY

       FROM ALLCODE A0, CFMAST CF, AFTYPE TYP, AFMAST AF, MRTYPE,
           (
              SELECT (CASE WHEN  (NVL(AMT,0) - CI.BALANCE) > 0 THEN (NVL(AMT,0) - CI.BALANCE) ELSE 0 END) AMT, NB_CHK_QTTY,NS_CHK_QTTY,
               CI.*
              FROM CIMAST CI,
               (
                  SELECT AFACCTNO, SUM(AMT) AMT, SUM(NB_CHK_QTTY) NB_CHK_QTTY, SUM(NS_CHK_QTTY) NS_CHK_QTTY
                  FROM(
                  SELECT OD.AFACCTNO, SUM((OD.ORDERQTTY) * OD.QUOTEPRICE * (1 +  (MOD(OD.BRATIO,1)/100)))  AS AMT, SUM(OD.REMAINQTTY) NB_CHK_QTTY,0 as NS_CHK_QTTY
                  FROM ODMAST OD, (SELECT TO_DATE(VARVALUE,'DD/MM/RRRR') CURRDATE FROM sysvar WHERE varname ='CURRDATE') SY
                  WHERE OD.EXECTYPE ='NB' AND OD.TXDATE = SY.CURRDATE
                  GROUP BY OD.AFACCTNO
                  UNION ALL
                  SELECT OD.AFACCTNO, 0  AS AMT, 0 AS NB_CHK_QTTY ,SUM(OD.REMAINQTTY) NS_CHK_QTTY
                  FROM ODMAST OD, (SELECT TO_DATE(VARVALUE,'DD/MM/RRRR') CURRDATE FROM sysvar WHERE varname ='CURRDATE') SY
                  WHERE OD.EXECTYPE IN ('NS','MS') AND OD.TXDATE = SY.CURRDATE
                  GROUP BY OD.AFACCTNO
                  )GROUP BY AFACCTNO
               ) OD
               WHERE CI.AFACCTNO = OD.AFACCTNO(+)
             )CI,
           (
             SELECT SEMAST.AFACCTNO, SUM(TRADE) TRADE_QTTY, SUM(MORTAGE) LOAN_QTTY, SUM(BLOCKED) BLOCKED,
                    SUM(WITHDRAW) WITHDRAW, SUM(SEMAST.DEPOSIT + SEMAST.SENDDEPOSIT) DEPOSIT,
                    SUM(standing) STANDING, SUM(SEMAST.EMKQTTY) EMKQTTY
             FROM SEMAST, SBSECURITIES SEC
             WHERE SEMAST.CODEID=SEC.CODEID
             AND SEC.SECTYPE <> '004' GROUP BY SEMAST.AFACCTNO
           ) SE,
           (
             SELECT AFACCTNO, SUM(CASE WHEN DUETYPE='RS' THEN ST_QTTY ELSE 0 END) RS_QTTY,
                    SUM(CASE WHEN DUETYPE='SS' THEN ST_QTTY ELSE 0 END) SS_QTTY,
                    SUM(CASE WHEN DUETYPE='RM' THEN ST_AMT ELSE 0 END) RM_AMT,
                    SUM(CASE WHEN DUETYPE='SM' THEN ST_AMT ELSE 0 END) SM_AMT
             FROM VW_BD_PENDING_SETTLEMENT GROUP BY AFACCTNO
             ) ST,
             (
               -- DU NO
               SELECT LNMAST.TRFACCTNO AFACCTNO, SUM(ROUND(PRINNML)+ROUND(PRINOVD)+ROUND(INTNMLACR)+ROUND(INTOVDACR)+
                      ROUND(INTNMLOVD)+ROUND(INTDUE) +
                      ROUND(OPRINNML)+ROUND(OPRINOVD)+ROUND(OINTNMLACR)+ROUND(OINTOVDACR)+ROUND(OINTNMLOVD)+
                      ROUND(OINTDUE)+ROUND(FEE)+ROUND(FEEDUE)+ROUND(FEEOVD)+
                      ROUND(FEEINTNMLACR)+ROUND(FEEINTOVDACR)+ROUND(FEEINTNMLOVD)+ROUND(FEEINTDUE)) AS LNOUTSTANDING
               FROM LNMAST GROUP BY LNMAST.TRFACCTNO
             )LN,
             (
               -- PHI
               SELECT DFMAST.AFACCTNO, SUM(greatest(INTAMTACR+FEEAMT,FEEMIN-RLSFEEAMT)) AS FEE,
               SUM(DFQTTY + BLOCKQTTY + RCVQTTY + CARCVQTTY) DF_QTTY
               FROM DFMAST GROUP BY DFMAST.AFACCTNO

             )DF,

             (
               SELECT AFACCTNO, SUM(QTTY) CA_QTTY
               FROM CASCHD WHERE
               deltd='N' AND isse='N' AND isexec='Y' AND qtty > 0
               GROUP BY AFACCTNO
             )CAS,
             (-- UTTB
                 SELECT AFACCTNO,SUM(advamt) DEPOAMT
                 FROM v_getaccountavladvance
                 GROUP BY AFACCTNO
             ) STS,
            /* ( -- CK han che chuyen nhuong

              SELECT sum(blocked) qtty ,afacctno FROM semast group by afacctno

              ) sedtl,
              ( -- CK  cam co VSD

              SELECT sum(abs(standing)) qtty ,afacctno FROM semast group by afacctno

              ) sestand,*/
             ( -- T0amt
             SELECT typereceive,SUM(acclimit) acclimit, acctno
             FROM useraflimit
             WHERE typereceive='T0'
             GROUP BY acctno,typereceive
             )usl,
              ( -- CK cho ban lo le
             SELECT SUM(qtty) qtty, afacctno
             FROM       (
                    SELECT  qtty, substr(acctno,0,10) afacctno
                    from SERETAIL
                    WHERE status <> 'C'

                       )
               GROUP BY afacctno
              ) seretl,
              (
              SELECT SUM(balance) balance, afacctno FROM TDMAST
              GROUP BY afacctno
              ) TD,
          ( SELECT SUM(dfblockamt)dfblockamt ,afacctno FROM dfgroup GROUP BY afacctno) dfgr,
         /* (
            SELECT MAX(ORDERID) ORDERID , ACCTNO FROM
            (SELECT ORDERID,
            (CASE WHEN FIRM = 2 THEN ACCTNO ELSE REF_AFACCTNO END) ACCTNO
            FROM (
            SELECT (ORDERID) ORDERID, A.ACCTNO,A.REF_AFACCTNO, B.FIRM FROM ( SELECT *  FROM (SELECT OD.ORDERID ORDERID,MAX(CF.CUSTODYCD) CUSTODYCD , MAX(AF.ACCTNO) ACCTNO , MAX(OD.TXDATE) TXDATE,
            MAX(NVL(CF2.CUSTODYCD,'')) REF_CUSTODYCD,MAX(TBL.REF_AFACCTNO) REF_AFACCTNO,
            MAX(CASE WHEN TBL.REF_CUSTODYCD IS NULL THEN '2' ELSE '1' END) FIRM,
            MAX(GREATEST(OD.EXECQTTY,FN_GET_GRP_EXEC_QTTY (OD.ORDERID))) EXECQTTY,--SOLUONG KHOP LAN 1
            MAX(GREATEST(OD2.EXECQTTY,FN_GET_GRP_EXEC_QTTY (OD2.ORDERID))) EXECQTTY2,--SOLUONG KHOP LAN 2
            MAX(NVL(OD2.QUOTEPRICE,0))  QUOTEPRICE2, MAX(NVL(OD2.ORDERQTTY,0)) ORDERQTTY2,
            MAX(CD.CDCONTENT) ORSTATUS, MAX(CD2.CDCONTENT) GRPORDER,MAX(TBL.REF_ORDERID) REF_ORDERID,
            MAX(NVL(OD2.ORDERID,0))  ORDERID2,
            MAX(CASE WHEN OD3.EXECQTTY > 0 OR (OD3.REMAINQTTY>0 AND OD3.TXDATE =TO_DATE(SYS.VARVALUE,'DD/MM/RRRR'))  THEN TBL.REF_ORDERID2 ELSE '' END) REF_ORDERID2,
            MAX(OD.REMAINQTTY) REMAINQTTY, MAX(SYS.VARVALUE) CURRDATE,
            MAX(OD2.TXDATE) OD2_TXDATE,MAX(NVL(OD2.REMAINQTTY,0)) REMAINQTTY2
            FROM  AFMAST AF, CFMAST CF,
                VW_ODMAST_ALL OD, --LENH GOC
                SBSECURITIES SB,ALLCODE CD,ALLCODE CD2,
                TBL_ODREPO TBL,
                CFMAST CF2,
                (SELECT * FROM
                   VW_ODMAST_ALL OD
                    WHERE (CASE WHEN OD.GRPORDER ='Y' THEN 'N' ELSE  OD.DELTD END )= 'N'
                    AND (CASE WHEN OD.GRPORDER ='Y' THEN 0 ELSE  OD.CANCELQTTY END )=0
                    AND OD.MATCHTYPE = 'P'
                 ) OD2,
                 (SELECT * FROM
                   VW_ODMAST_ALL OD
                    WHERE (CASE WHEN OD.GRPORDER ='Y' THEN 'N' ELSE  OD.DELTD END )= 'N'
                    AND (CASE WHEN OD.GRPORDER ='Y' THEN 0 ELSE  OD.CANCELQTTY END )=0
                    AND OD.MATCHTYPE = 'P'
                 ) OD3, SYSVAR SYS
            WHERE CF.CUSTID = AF.CUSTID
                AND OD.AFACCTNO = AF.ACCTNO
                AND OD.CODEID = SB.CODEID
                AND OD.MATCHTYPE = 'P'
                AND CD.CDNAME = 'ORSTATUS' AND CD.CDTYPE='OD'
                AND CD.CDVAL = OD.ORSTATUS
                AND  CD2.CDTYPE ='SY' AND  CD2.CDNAME ='YESNO'
                AND OD.GRPORDER = CD2.CDVAL
                AND (CASE WHEN OD.GRPORDER ='Y' THEN 'N' ELSE  OD.DELTD END )= 'N'
                AND OD.ORDERID = TBL.ORDERID
                AND TBL.REF_CUSTODYCD = CF2.CUSTODYCD(+)
                AND TBL.ORDERID2 = OD2.ORDERID(+)
                AND TBL.REF_ORDERID2 = OD3.ORDERID(+)
               AND SYS.GRNAME ='SYSTEM' AND SYS.VARNAME ='CURRDATE'
                GROUP BY OD.ORDERID ) OD WHERE 0=0
                AND (GREATEST(OD.EXECQTTY,FN_GET_GRP_EXEC_QTTY (OD.ORDERID)) > 0
                        OR (OD.REMAINQTTY>0 AND OD.TXDATE =TO_DATE(CURRDATE,'DD/MM/RRRR'))
                        OR (FN_GET_GRP_REMAIN_QTTY(OD.ORDERID) >0 AND OD.TXDATE =TO_DATE(CURRDATE,'DD/MM/RRRR'))
                    )
                AND ((NVL(EXECQTTY2,0) = 0 AND NVL(OD2_TXDATE,TO_DATE('01/01/2000','DD/MM/RRRR')) <> TO_DATE(CURRDATE,'DD/MM/RRRR'))
                        OR  (NVL(REMAINQTTY2,0) = 0 AND NVL(OD2_TXDATE,TO_DATE('01/01/2000','DD/MM/RRRR')) = TO_DATE(CURRDATE,'DD/MM/RRRR'))
                        OR (FN_GET_GRP_REMAIN_QTTY(ORDERID2) >0 AND NVL(OD2_TXDATE,TO_DATE('01/01/2000','DD/MM/RRRR')) =TO_DATE(CURRDATE,'DD/MM/RRRR'))
                    )
                    ) A,
                    (SELECT '1' FIRM FROM DUAL
                     UNION
                     SELECT '2' FIRM FROM DUAL
                    )B ) ) WHERE ACCTNO IS NOT NULL GROUP BY ACCTNO
        ) TBLRP,*/
       (SELECT AFACCTNO ,  SUM(CASE WHEN FEETYPE='FEEDR' THEN (NMLAMT -PAIDAMT) ELSE 0 END) AVL_FEEDR,
                SUM(CASE WHEN FEETYPE='VSDDEP' THEN (NMLAMT -PAIDAMT) ELSE 0 END) AVL_VSDDEP
        FROM CIFEESCHD WHERE DELTD<>'Y'
        GROUP BY AFACCTNO) CIFEE
  WHERE A0.CDTYPE='CF' AND A0.CDNAME='STATUS' AND A0.CDVAL=AF.STATUS
      AND CF.STATUS in ('A','G')
      AND AF.STATUS in ('A','G')
      AND CF.CUSTID=AF.CUSTID
      AND AF.ACTYPE=TYP.ACTYPE
      AND MRTYPE.ACTYPE=TYP.Mrtype
      AND AF.ACCTNO=CI.ACCTNO (+)
      AND AF.ACCTNO=SE.AFACCTNO (+)
      AND AF.ACCTNO=ST.AFACCTNO (+)
      AND AF.ACCTNO=LN.AFACCTNO (+)
      AND AF.ACCTNO=DF.AFACCTNO (+)
      AND AF.ACCTNO=CAS.AFACCTNO (+)
      AND af.acctno=sts.afacctno (+)
      AND af.acctno=usl.acctno   (+)
      --AND af.acctno=sedtl.afacctno (+)
      AND af.acctno=seretl.afacctno (+)
      --AND af.acctno=sestand.afacctno (+)
      AND af.acctno=td.afacctno(+)
      AND af.acctno=dfgr.afacctno(+)
      --AND af.acctno=TBLRP.ACCTNO(+)
      AND AF.ACCTNO=CIFEE.AFACCTNO(+)
/
