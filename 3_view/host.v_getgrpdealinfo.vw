SET DEFINE OFF;
CREATE OR REPLACE FORCE VIEW V_GETGRPDEALINFO
(GROUPID, CUSTODYCD, AFACCTNO, FULLNAME, DFTYPE, 
 DFTYPENAME, LNTYPE, LNTYPENAME, ORGAMT, RLSAMT, 
 CURAMT, INTAMT, RATE1, RATE2, RATE3, 
 CFRATE1, CFRATE2, CFRATE3, RRTYPE, PREPAIDDIS, 
 INTPAIDMETHODDIS, AUTOAPPLYDIS, FEEINTAMT, FEEINTNMLACR, DFAMT, 
 COLAMT, IRATE, ARATE, ALRATE, MRATE, 
 LRATE, RTT, CIAVAI, ISADDASSET, ISINITASSET)
BEQUEATH DEFINER
AS 
(
SELECT DFG.GROUPID, CF.CUSTODYCD, DFG.AFACCTNO, CF.FULLNAME, DFG.ACTYPE DFTYPE, DFT.TYPENAME DFTYPENAME, DFT.LNTYPE,LNT.TYPENAME LNTYPENAME, DFG.ORGAMT, DFG.RLSAMT,
    LN.PRINNML + LN.PRINOVD CURAMT,
    nvl(LN.INTNMLOVD,0) + nvl(LN.INTOVDACR,0) + nvl(LN.INTDUE,0) + nvl(LN.INTNMLACR,0) INTAMT,
    LN.RATE1,LN.RATE2,LN.RATE3,LN.CFRATE1,LN.CFRATE2,LN.CFRATE3, A4.CDCONTENT RRTYPE,
     A1.CDCONTENT PREPAIDDIS,A2.CDCONTENT INTPAIDMETHODDIS,A3.CDCONTENT AUTOAPPLYDIS,
     LN.FEEINTNMLOVD + LN.FEEINTOVDACR + LN.FEEINTDUE FEEINTAMT, LN.FEEINTNMLACR,
    DFG.DFAMT, DF.COLAMT, DFG.IRATE,DFG.ARATE, DFG.ALRATE, DFG.MRATE, DFG.LRATE,
    ROUND((DF.COLAMT+ DFG.DFAMT)/ (nvl(LN.INTNMLOVD,0) + nvl(LN.INTOVDACR,0) + nvl(LN.INTDUE,0) + nvl(LN.INTNMLACR,0) +
     nvl(LN.FEEINTNMLOVD,0) + nvl(LN.FEEINTOVDACR,0) + nvl(LN.FEEINTDUE,0) + nvl(LN.FEEINTNMLACR,0) +
     DFG.ORGAMT - DFG.RLSAMT) * 100,2) RTT, greatest(getbaldefovd( DFG.AFACCTNO),getbaldefovd( DFG.AFACCTNO)) ciavai, DFT.isaddasset, DFT.isinitasset
FROM DFGROUP DFG,  AFMAST AF, CFMAST CF, LNMAST LN,
     (SELECT LNACCTNO,SUM(AMT_T* DFRATE/100 + DFRATE* (DFQTTY+BLOCKQTTY+CARCVQTTY)* SB.BASICPRICE/100) COLAMT
        FROM (SELECT CASE WHEN DEALTYPE='T' THEN DFQTTY ELSE 0 END AMT_T, CASE WHEN DEALTYPE='T' THEN 0 ELSE DFQTTY END DFQTTY, RCVQTTY, BLOCKQTTY,
    CARCVQTTY, DFRATE, LNACCTNO, ACTYPE,DEALTYPE, CODEID FROM DFMAST) DF, SECURITIES_INFO SB WHERE DF.CODEID=SB.CODEID GROUP BY LNACCTNO) DF,
      ALLCODE A1, ALLCODE A2, ALLCODE A3, ALLCODE A4, DFTYPE DFT, LNTYPE LNT
WHERE DFG.AFACCTNO=AF.ACCTNO AND AF.CUSTID=CF.CUSTID  AND DFG.LNACCTNO=LN.ACCTNO AND DF.LNACCTNO=LN.ACCTNO
    AND DFG.ACTYPE=DFT.ACTYPE AND DFT.LNTYPE=LNT.ACTYPE
and A1.cdname = 'YESNO' and A1.cdtype ='SY' AND A1.CDVAL = LN.PREPAID
      and A2.cdname = 'INTPAIDMETHOD' and A2.cdtype ='LN' AND A2.CDVAL = LN.INTPAIDMETHOD
       and A3.cdname = 'AUTOAPPLY' and a3.cdtype ='LN' AND A3.CDVAL = LN.AUTOAPPLY
       AND A4.CDTYPE = 'LN' AND A4.CDNAME = 'RRTYPE' AND A4.CDVAL=LNT.RRTYPE

)
/
