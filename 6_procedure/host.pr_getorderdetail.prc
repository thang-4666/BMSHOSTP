SET DEFINE OFF;
CREATE OR REPLACE PROCEDURE PR_GETORDERDETAIL(PV_REFCURSOR IN OUT PKG_REPORT.REF_CURSOR,
                                            F_ORDERID  IN VARCHAR2
                                            ) IS
  BEGIN


  OPEN PV_REFCURSOR FOR

    SELECT OD.ORDERID ORDERID,
           OD.AFACCTNO || ' - ' || AFT.TYPENAME AFACCTNO,
           OD.TXDATE,
           CASE
             WHEN IOD.BORS = 'S' THEN
              'Bán'
             ELSE
              'Mua'
           END EXECTYPE,
           SB.SYMBOL,
          IOD.MATCHQTTY EXECQTTY,
          IOD.MATCHPRICE EXECPRICE,
          IOD.TXTIME TIMEMATCH
    FROM VW_IOD_ALL    IOD,
           ODTYPE        ODT,
           VW_ODMAST_ALL OD,
           AFMAST        AF,
           AFTYPE        AFT,
           CFMAST        CF,
           SBSECURITIES  SB
     WHERE IOD.ORGORDERID = OD.ORDERID
       AND OD.ACTYPE = ODT.ACTYPE
       AND CF.CUSTID = AF.CUSTID
       AND SB.CODEID = OD.CODEID
       AND AF.ACCTNO = OD.AFACCTNO
       AND AFT.ACTYPE = AF.ACTYPE
       AND IOD.MATCHQTTY > 0
       AND OD.DELTD <> 'Y'
       AND IOD.DELTD <> 'Y'
       AND OD.ORDERID LIKE F_ORDERID
       ORDER BY IOD.TXTIME

     ;

EXCEPTION
  WHEN OTHERS THEN
    RETURN;
END;

 
 
 
 
 
 
 
 
 
 
 
/
