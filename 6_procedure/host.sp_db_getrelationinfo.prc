SET DEFINE OFF;
CREATE OR REPLACE PROCEDURE "SP_DB_GETRELATIONINFO" (
   PV_REFCURSOR   IN OUT   PKG_REPORT.REF_CURSOR,
   PV_AFACCTNO    IN       VARCHAR2
)
IS
--

   V_AFACCTNO       VARCHAR2 (10);

    BEGIN

        V_AFACCTNO :=  PV_AFACCTNO;

           -- CA NHAN, CHI LAY TRONG CFAUTH
            OPEN PV_REFCURSOR FOR
               SELECT AU.AUTOID, 'A' TYP, AU.CUSTID,
                    au.licenseno idcode,
                    au.lniddate iddate,
                    au.lnplace idplace,
                    au.fullname fullname, A1.CDCONTENT REF,
                    AF.ACCTNO,TO_CHAR(AU.ACDATE,'DD/MM/YYYY') ACDATE,
                    au.address address
                FROM cfrelation AU, CFMAST CF1, AFMAST AF,  ALLCODE A1
                WHERE trim(AU.CUSTID) = CF1.CUSTID AND CF1.CUSTID= AF.CUSTID
                        AND TRIM(AF.ACCTNO)=V_AFACCTNO AND AU.ACTIVES='Y'
                    AND A1.CDTYPE = 'CF' AND A1.CDNAME = 'RETYPE' and a1.cdval = au.retype;

 EXCEPTION
   WHEN OTHERS
   THEN
      RETURN;
END;                                                              -- PROCEDURE

 
 
 
 
/
