SET DEFINE OFF;
CREATE OR REPLACE PROCEDURE "SP_BD_GETACCOUNTLOANINFO" (PV_REFCURSOR IN OUT PKG_REPORT.REF_CURSOR, AFACCTNO IN VARCHAR2)
  IS
  V_PARAFILTER VARCHAR2(10);
BEGIN
    V_PARAFILTER:=AFACCTNO;
    OPEN PV_REFCURSOR FOR
/*  SELECT SYMBOL, MAX(DFTYP) DFTYP, SUM(FEEAMT) FEEAMT, SUM(INDUEAMT) INDUEAMT, SUM(OVERDUEAMT) OVERDUEAMT,
        SUM(DFQTTY) DFQTTY, SUM(DFTRADE) DFTRADE, TO_CHAR(MAX(DFRLSDATE),'DD/MM/RRRR') RLSDATE,
        TO_CHAR(MAX(DFDUEDATE),'DD/MM/RRRR') DUEDATE, MAX(DFPRICE) DFPRICE,  MAX(TRIGGERPRICE) TRIGGERPRICE,  MAX(DESCRIPTION) DESCRIPTION, DFACCTNO
  FROM (    SELECT NVL(DF.SYMBOL,A2.CDCONTENT) SYMBOL ,
                CF.CUSTODYCD, AF.ACCTNO, A1.CDCONTENT  || '. ' || DF.DESC_DFTYPE DFTYP,
                NVL(GREATEST(DF.INTAMTACR+DF.FEEAMT,DF.FEEMIN-DF.RLSFEEAMT),0) FEEAMT,
                LN.INTNMLACR+LN.INTDUE + LN.OPRINNML+LN.PRINNML + LN.OINTNMLACR+LN.OINTOVDACR+ LN.OINTDUE+LN.FEE+LN.FEEDUE INDUEAMT,
                LN.PRINOVD + LN.OPRINOVD+ LN.INTOVDACR+LN.INTNMLOVD + LN.OINTNMLOVD +LN.FEEOVD OVERDUEAMT,
                NVL(DF.DFQTTY + DF.RCVQTTY + DF.CARCVQTTY + DF.BLOCKQTTY + DF.BQTTY,0) DFQTTY, NVL(DFQTTY-NVL(V.SECUREAMT,0),0) DFTRADE,
                DF.RLSDATE DFRLSDATE, DF.DUEDATE DFDUEDATE, DF.DFPRICE, DF.TRIGGERPRICE, DF.DUEDATE, DF.DESCRIPTION, NVL(DF.ACCTNO,'----------------') DFACCTNO
            FROM (  SELECT DFMAST.*, LNSCHD.RLSDATE, LNSCHD.OVERDUEDATE DUEDATE, SB.SYMBOL, A0.CDCONTENT DESC_DFTYPE FROM DFMAST, SBSECURITIES SB, ALLCODE A0, LNSCHD
            WHERE SB.CODEID=DFMAST.CODEID AND A0.CDTYPE='DF' AND A0.CDNAME='DFTYPE' AND A0.CDVAL=DFMAST.DFTYPE AND LNSCHD.ACCTNO=DFMAST.LNACCTNO AND LNSCHD.REFTYPE IN ('P','GP')) DF,
        LNMAST LN, V_GETDEALSELLORDERINFO V, ALLCODE A1, ALLCODE A2, AFMAST AF, CFMAST CF, AFTYPE, MRTYPE
  WHERE LN.ACCTNO=DF.LNACCTNO  (+) AND DF.ACCTNO = V.DFACCTNO (+)
    AND AF.ACCTNO=LN.TRFACCTNO AND AF.CUSTID=CF.CUSTID AND AF.ACCTNO=V_PARAFILTER
    AND AF.ACTYPE=AFTYPE.ACTYPE AND AFTYPE.MRTYPE=MRTYPE.ACTYPE
    AND A2.CDTYPE='SA' AND A2.CDNAME='MARGINTYPE' AND A2.CDVAL=MRTYPE.MRTYPE
    AND A1.CDTYPE='LN' AND A1.CDNAME='FTYPE' AND A1.CDVAL=LN.FTYPE)
  GROUP BY ROLLUP(SYMBOL,DFACCTNO);*/

 /* SELECT   symbol,
           MAX (dftyp) dftyp,
           SUM (feeamt) feeamt,
           SUM (indueamt) indueamt,
           SUM (overdueamt) overdueamt,
           SUM (dfqtty) dfqtty,
           SUM (dftrade) dftrade,
           TO_CHAR (MAX (dfrlsdate), 'DD/MM/RRRR') rlsdate,
           TO_CHAR (MAX (dfduedate), 'DD/MM/RRRR') duedate,
           MAX (dfprice) dfprice,
           MAX (triggerprice) triggerprice,
           MAX (description) description,
           dfacctno
    FROM   (SELECT   NVL (df.symbol, a2.cdcontent) symbol,
                     cf.custodycd,
                     af.acctno,
                     a1.cdcontent || '. ' || df.desc_dftype dftyp,
                     NVL ( GREATEST (df.intamtacr + df.feeamt, df.feemin - df.rlsfeeamt), 0) feeamt,
                     --LN.INTNMLACR+LN.INTDUE + LN.OPRINNML+LN.PRINNML + LN.OINTNMLACR+LN.OINTOVDACR+ LN.OINTDUE+LN.FEE+LN.FEEDUE INDUEAMT,
                     ls.nml + ls.intnmlacr + ls.fee + ls.intdue + ls.feedue indueamt,
                     --LN.PRINOVD + LN.OPRINOVD+ LN.INTOVDACR+LN.INTNMLOVD + LN.OINTNMLOVD +LN.FEEOVD OVERDUEAMT,
                     ls.ovd + ls.intovd + ls.intovdprin + ls.feeovd overdueamt,
                     NVL ( df.dfqtty + df.rcvqtty + df.carcvqtty + df.blockqtty + df.bqtty, 0) dfqtty,
                     NVL (dfqtty - NVL (v.secureamt, 0), 0) dftrade,
                     CASE WHEN ls.reftype = 'P' THEN ls.rlsdate  ELSE NULL END dfrlsdate,
                     CASE WHEN ls.reftype = 'P' THEN ls.overduedate ELSE NULL END   dfduedate,
                     df.dfprice,
                     df.triggerprice,
                     df.duedate,
                     df.description,
                     CASE WHEN ln.ftype = 'DF' THEN  NVL (df.acctno, '----------------') ELSE lpad(to_char(ls.autoid),12,'-') end dfacctno
              FROM   (SELECT   dfmast.*,
                               lnschd.rlsdate,
                               lnschd.overduedate duedate,
                               sb.symbol,
                               a0.cdcontent desc_dftype
                        FROM   dfmast,
                               sbsecurities sb,
                               allcode a0,
                               lnschd
                       WHERE       sb.codeid = dfmast.codeid
                               AND a0.cdtype = 'DF'
                               AND a0.cdname = 'DFTYPE'
                               AND a0.cdval = dfmast.dftype
                               AND lnschd.acctno = dfmast.lnacctno
                               AND lnschd.reftype IN ('P', 'GP')) df,
                     lnmast LN,
                     v_getdealsellorderinfo v,
                     allcode a1,
                     allcode a2,
                     afmast af,
                     cfmast cf,
                     aftype,
                     mrtype,
                     lnschd ls
             WHERE       LN.acctno = df.lnacctno(+)
                     AND df.acctno = v.dfacctno(+)
                     AND af.acctno = LN.trfacctno
                     AND af.custid = cf.custid
                     AND af.acctno = V_PARAFILTER
                     AND af.actype = aftype.actype
                     AND aftype.mrtype = mrtype.actype
                     AND LN.acctno = ls.acctno
                     AND ls.reftype IN ('GP', 'P')
                     AND a2.cdtype = 'SA'
                     AND a2.cdname = 'MARGINTYPE'
                     AND a2.cdval = mrtype.mrtype
                     AND a1.cdtype = 'LN'
                     AND a1.cdname = 'FTYPE'
                     AND a1.cdval = LN.ftype)
GROUP BY   ROLLUP (symbol,dfacctno);*/

 SELECT   symbol,
           nvl(MAX (dftyp),0) dftyp,
            round( nvl(SUM (feeamt),0),0)  feeamt,
           round(  nvl(SUM (indueamt),0),0)  indueamt,
          round(   nvl(SUM (overdueamt),0),0)  overdueamt,
           round(  nvl(SUM (dfqtty),0),0)  dfqtty,
         round(    nvl(SUM (dftrade),0),0)  dftrade,
           TO_CHAR (MAX (dfrlsdate), 'DD/MM/RRRR') rlsdate,
           TO_CHAR (MAX (dfduedate), 'DD/MM/RRRR') duedate,
           nvl(MAX (dfprice),0) dfprice,
           nvl(MAX (triggerprice),0) triggerprice,
           MAX (description) description,
           dfacctno,max(custodycd) custodycd
    FROM   (SELECT   NVL (df.symbol, a2.cdcontent) symbol,
                     cf.custodycd,
                     af.acctno,
                     a1.cdcontent || '. ' || df.desc_dftype dftyp,
                     NVL ( GREATEST (df.intamtacr + df.feeamt, df.feemin - df.rlsfeeamt), 0) feeamt,
                     --LN.INTNMLACR+LN.INTDUE + LN.OPRINNML+LN.PRINNML + LN.OINTNMLACR+LN.OINTOVDACR+ LN.OINTDUE+LN.FEE+LN.FEEDUE INDUEAMT,
                    case when  df.groupid is null then ls.nml + ls.intnmlacr + ls.fee + ls.intdue + ls.feedue   else
                     ( ls.nml + ls.intnmlacr + ls.fee + ls.intdue + ls.feedue  )*(df.amt-df.rlsamt)/(df.orgamtdfg -df.orgrlsamt) end indueamt
                    ,
                     --LN.PRINOVD + LN.OPRINOVD+ LN.INTOVDACR+LN.INTNMLOVD + LN.OINTNMLOVD +LN.FEEOVD OVERDUEAMT,
                   --  ls.ovd + ls.intovd + ls.intovdprin + ls.feeovd overdueamt,
                    case when  df.groupid is null then ls.ovd + ls.intovd + ls.intovdprin + ls.feeovd   else
                     ( ls.ovd + ls.intovd + ls.intovdprin + ls.feeovd   )*(df.amt-df.rlsamt)/(df.orgamtdfg -df.orgrlsamt) end  overdueamt,

                     NVL ( df.dfqtty + df.rcvqtty + df.carcvqtty + df.blockqtty + df.bqtty, 0) dfqtty,
                     NVL (dfqtty - NVL (v.secureamt, 0), 0) dftrade,
                     CASE WHEN ls.reftype = 'P' THEN ls.rlsdate  ELSE NULL END dfrlsdate,
                     CASE WHEN ls.reftype = 'P' THEN ls.overduedate ELSE NULL END   dfduedate,
                     df.dfprice,
                     df.triggerprice,
                     df.duedate,
                     df.description,
                     CASE WHEN ln.ftype = 'DF' THEN  NVL (df.acctno, '----------------') ELSE lpad(to_char(ls.autoid),12,'-') end dfacctno
              FROM   (SELECT   dfmast.*,dfg.orgamt orgamtdfg,dfg.rlsamt orgrlsamt,
                               lnschd.rlsdate,
                               lnschd.overduedate duedate,
                               sb.symbol,
                               a0.cdcontent desc_dftype
                        FROM   dfmast,
                               sbsecurities sb,
                               allcode a0,
                               lnschd,dfgroup dfg
                       WHERE       sb.codeid = dfmast.codeid
                               AND a0.cdtype = 'DF'
                               AND a0.cdname = 'DFTYPE'
                               AND a0.cdval = dfmast.dftype
                               AND lnschd.acctno = dfmast.lnacctno
                               AND lnschd.reftype IN ('P', 'GP')
                               and dfmast.groupid= dfg.groupid(+)
                               ) df,
                     lnmast LN,
                     v_getdealsellorderinfo v,
                     allcode a1,
                     allcode a2,
                     afmast af,
                     cfmast cf,
                     aftype,
                     mrtype,
                     lnschd ls
             WHERE       LN.acctno = df.lnacctno(+)
                     AND df.acctno = v.dfacctno(+)
                     AND af.acctno = nvl( df.afacctno,LN.trfacctno)
                     AND af.custid = cf.custid
                     AND af.acctno = V_PARAFILTER
                     AND af.actype = aftype.actype
                     AND aftype.mrtype = mrtype.actype
                     AND LN.acctno = ls.acctno
                     AND ls.reftype IN ('GP', 'P')
                     AND a2.cdtype = 'SA'
                     AND a2.cdname = 'MARGINTYPE'
                     AND a2.cdval = mrtype.mrtype
                     AND a1.cdtype = 'LN'
                     AND a1.cdname = 'FTYPE'
                     AND a1.cdval = LN.ftype)
GROUP BY   ROLLUP (symbol,dfacctno);


EXCEPTION
    WHEN others THEN
        return;
END;

 
 
 
 
/
