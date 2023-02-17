SET DEFINE OFF;
CREATE OR REPLACE PROCEDURE "SP_BD_GETCUSTOMERPOSITION" (PV_REFCURSOR IN OUT PKG_REPORT.REF_CURSOR,
                                                      CUSTODYCD    IN VARCHAR2) IS
  V_PARAFILTER VARCHAR2(10);
  V_CUSTID     VARCHAR2(10);

BEGIN
  V_PARAFILTER := CUSTODYCD;
  SELECT CUSTID INTO V_CUSTID FROM CFMAST WHERE CUSTODYCD = V_PARAFILTER;
  OPEN PV_REFCURSOR FOR
    SELECT ITEM, MST.ACCTNO SUBACCTNO, MAX(TYPENAME) SUBACNAME, SUM(VAL) VAL,
           SUM(AMT) AMT,(CASE WHEN sum(val)<>0 THEN ROUND(SUM(COSTPRICEAMT)/SUM(VAL),0) ELSE 0 END  )COSTPRICE,
           SUM(PROFITANDLOSS) PROFITANDLOSS
      FROM (
             /*SELECT V_PARAFILTER CUSTODYCD, AF.ACCTNO, TO_CHAR('PURCHASINGPOWER') ITEM,
                fn_get_account_pp(AF.ACCTNO,'U') VAL,
                aft.TYPENAME
                 from afmast af ,aftype aft, mrtype mrt
                 WHERE af.custid=V_CUSTID
                 and af.actype = aft.actype
                 and aft.mrtype = mrt.actype

             UNION ALL*/
             SELECT V_PARAFILTER CUSTODYCD, AF.ACCTNO,
                     TO_CHAR('CASHONHAND') ITEM,
                     --DTL.BALANCE - NVL(V.SECUREAMT,0) VAL,
                     -- Ducnv sua - nvl(v.advamt,0)
                     0 VAL, TYP.TYPENAME, 0 COSTPRICE,0 COSTPRICEAMT,
                     Greatest(DTL.BALANCE - NVL(V.SECUREAMT, 0) -
                               nvl(v.advamt, 0),
                               0) AMT, 0 PROFITANDLOSS
               FROM CIMAST DTL, AFMAST AF, AFTYPE TYP, V_GETBUYORDERINFO V
              WHERE DTL.AFACCTNO = AF.ACCTNO
                AND AF.ACCTNO = V.AFACCTNO(+)
                AND AF.CUSTID = V_CUSTID
                AND TYP.ACTYPE = AF.ACTYPE

             UNION ALL
             SELECT V_PARAFILTER CUSTODYCD, AF.ACCTNO, TO_CHAR('DEBIT') ITEM,
                    0 VAL, TYP.Typename, 0 COSTPRICE,0 COSTPRICEAMT,
                    - (ls.debt) AMT,
                    0 PROFITANDLOSS
               FROM LNMAST LN, AFMAST AF, AFTYPE TYP, (SELECT ln.trfacctno,
                             SUM(ls.nml + ls.intnmlacr + ls.fee + ls.intdue +
                                  ls.feedue + ls.ovd + ls.intovd + ls.intovdprin +
                                  ls.feeovd) debt
                        FROM lnschd ls, lnmast ln
                       WHERE ln.acctno = ls.acctno
                       GROUP BY ln.trfacctno) ls
              WHERE ls.TRFACCTNO = AF.ACCTNO
                AND AF.CUSTID = V_CUSTID
                AND TYP.ACTYPE = AF.ACTYPE


             UNION ALL
             SELECT V_PARAFILTER CUSTODYCD, AF.ACCTNO, TO_CHAR(SB.SYMBOL) ITEM,
                    DTL.TRADE + DTL.MORTAGE + DTL.BLOCKED + DTL.NETTING VAL,
                    TYP.TYPENAME, DTL.COSTPRICE,
                    DTL.COSTPRICE*(DTL.TRADE + DTL.MORTAGE + DTL.BLOCKED + DTL.NETTING) COSTPRICEAMT,
                    (SEC.basicprice *
                     (DTL.TRADE + DTL.MORTAGE + DTL.BLOCKED + DTL.NETTING)) AMT,
                    (( SEC.basicprice- DTL.COSTPRICE) *
                     (DTL.TRADE + DTL.MORTAGE + DTL.BLOCKED + DTL.NETTING)) PROFITANDLOSS
               FROM SEMAST DTL, AFMAST AF, AFTYPE TYP, SBSECURITIES SB,
                    SECURITIES_INFO SEC
              WHERE DTL.AFACCTNO = AF.ACCTNO
                AND AF.CUSTID = V_CUSTID
                AND TYP.ACTYPE = AF.ACTYPE
                AND SB.CODEID = DTL.CODEID
                AND DTL.Codeid = SEC.Codeid

             ) MST
     GROUP BY ROLLUP(ITEM, MST.ACCTNO)
    HAVING SUM(AMT) <> 0;
EXCEPTION
  WHEN OTHERS THEN
    RETURN;
END;

 
 
 
 
/
