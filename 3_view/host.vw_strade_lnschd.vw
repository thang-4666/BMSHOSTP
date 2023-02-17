SET DEFINE OFF;
CREATE OR REPLACE FORCE VIEW VW_STRADE_LNSCHD
(CUSTODYCD, SYMBOL, DFTYP, FEEAMT, INDUEAMT, 
 OVERDUEAMT, DUEAMT, DFQTTY, DFTRADE, RLSDATE, 
 FLAGRATIO, INDUERATIO, OVERDUERATIO, DUEDATE, DFPRICE, 
 TRIGGERPRICE, DESCRIPTION, DFACCTNO, REFPRICE, INDUEINTAMT, 
 OVERDUEINTAMT)
BEQUEATH DEFINER
AS 
SELECT custodycd,
    symbol,
    dftyp,
    feeamt,
    indueamt,
    overdueamt,
    dueamt,
    dfqtty,
    dftrade,
    TO_CHAR (dfrlsdate, 'DD/MM/RRRR') rlsdate,
    flagratio,
    indueratio,
    overdueratio,
    TO_CHAR (dfduedate, 'DD/MM/RRRR') duedate,
    dfprice,
    triggerprice,
    description,
    dfacctno,
    CASE
      WHEN qtty IS NOT NULL
      THEN ROUND (amt / qtty)
      WHEN dcrqtty    + prevqtty <> 0
      THEN ((prevqtty * costprice) + dcramt) / ( prevqtty + dcrqtty)
      ELSE costprice
    END refprice,
    indueintamt,
    overdueintamt
  FROM
    (SELECT cf.custodycd,
      df.symbol,
      df.cdval dftyp,
      (
      CASE
        WHEN lntype.nintcd = '001'
        THEN 1
        ELSE 0
      END) flagratio,
      indueratio,
      overdueratio,
      NVL ( GREATEST (df.intamtacr + df.feeamt, df.feemin - df.rlsfeeamt), 0) feeamt,
      LN.intnmlacr                 + LN.intdue + LN.oprinnml + LN.prinnml + LN.ointnmlacr + LN.ointovdacr + LN.ointdue + LN.fee + LN.feedue indueamt,
      LN.prinovd                   + LN.oprinovd + LN.intovdacr + LN.intnmlovd + LN.ointnmlovd + LN.feeovd overdueamt,
      LN.oprinnml + LN.prinnml + LN.prinovd + LN.oprinovd  dueamt,
      NVL ( df.dfqtty              + df.rcvqtty + df.carcvqtty + df.blockqtty + df.bqtty, 0) dfqtty,
      NVL (dfqtty                  - NVL (v.secureamt, 0), 0) dftrade,
      df.rlsdate dfrlsdate,
      df.duedate dfduedate,
      df.dfprice,
      df.triggerprice,
      df.duedate,
      df.description,
      NVL (df.acctno, '----------------') dfacctno,
      df.dfref,
      st.amt,
      st.qtty,
      se.costprice,
      se.prevqtty,
      se.dcramt,
      se.dcrqtty,
      LN.intovdacr + LN.intnmlacr + LN.intdue + LN.ointnmlacr + LN.ointovdacr + ointdue + LN.fee + LN.feedue indueintamt,
      LN.intnmlovd + LN.ointnmlovd + LN.feeovd overdueintamt
    FROM
      (SELECT dfmast.*,
        lnschd.rlsdate,
        lnschd.overduedate duedate,
        sb.symbol,
        a0.cdval,
        a0.cdcontent desc_dftype
      FROM dfmast,
        sbsecurities sb,
        allcode a0,
        lnschd
      WHERE sb.codeid     = dfmast.codeid
      AND a0.cdtype       = 'DF'
      AND a0.cdname       = 'DFTYPE'
      AND a0.cdval        = dfmast.dftype
      AND lnschd.acctno   = dfmast.lnacctno
      AND lnschd.reftype IN ('P', 'GP')
      ) df,
      (SELECT TO_DATE (varvalue, 'DD/MM/RRRR') currdate
      FROM sysvar
      WHERE varname = 'CURRDATE'
      ) dt,
      lntype,
      lnmast LN,
      v_getdealsellorderinfo v,
      allcode a1,
      afmast af,
      cfmast cf,
      semast se,
      (SELECT ( TO_CHAR (txdate,'DD/MM/RRRR')
        || afacctno
        || codeid
        || clearday) txtautoid,
       sum(amt) amt ,sum (qtty) qtty
      FROM stschd
      GROUP by txdate, afacctno, codeid , clearday
      ) st
    WHERE lntype.actype = LN.actype
    AND LN.acctno       = df.lnacctno(+)
    AND df.acctno       = v.dfacctno(+)
    AND af.acctno       = LN.trfacctno
    AND af.acctno       = se.afacctno
    AND df.codeid       = se.codeid
    AND st.txtautoid(+) = df.dfref
    AND af.custid       = cf.custid
    AND a1.cdtype       = 'LN'
    AND a1.cdname       = 'FTYPE'
    AND a1.cdval        = LN.ftype
    AND symbol         IS NOT NULL
    )
/
