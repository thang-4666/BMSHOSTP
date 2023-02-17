SET DEFINE OFF;
CREATE OR REPLACE PROCEDURE mr3003_1 (
   PV_REFCURSOR         IN OUT   PKG_REPORT.REF_CURSOR,
   p_OPT                IN       VARCHAR2,
   pv_BRID              IN       VARCHAR2,
   TLGOUPS              IN       VARCHAR2,
   TLSCOPE              IN       VARCHAR2,
   I_DATE              IN       VARCHAR2
  )
IS
--
-- BAO CAO CAC TAI KHOAN KY QUY HOAT DONG TRONG KY
-- MODIFICATION HISTORY
-- PERSON       DATE                COMMENTS
-- ---------   ------  -------------------------------------------
-- QUOCTA      17-02-2012           CREATED
-- NGOCVTT      23/07/1              EDIT

   CUR                      PKG_REPORT.REF_CURSOR;
    l_OPT varchar2(10);
    l_BRID varchar2(1000);
    l_BRID_FILTER varchar2(1000);

   V_INDATE         DATE;
   V_CURRDATE       DATE;

BEGIN

   SELECT TO_DATE(VARVALUE, SYSTEMNUMS.C_DATE_FORMAT) INTO   V_CURRDATE
   FROM   SYSVAR  WHERE  grname = 'SYSTEM' AND varname = 'CURRDATE';


   V_INDATE := TO_DATE(I_DATE,'DD/MM/RRRR');

if V_INDATE=V_CURRDATE then
  
OPEN PV_REFCURSOR FOR

        SELECT CF.CUSTODYCD,CF.FULLNAME, AF.ACCTNO,CF.BRID, AF.OPNDATE,
               CF.IDCODE,CF.IDDATE,CF.IDPLACE,CF.MOBILESMS, I_DATE indate
        FROM  AFMAST AF, CFMAST CF,AFTYPE AFT, MRTYPE MR
        WHERE AF.ACTYPE=AFT.ACTYPE AND AFT.MRTYPE=MR.ACTYPE
               AND CF.CUSTID=AF.CUSTID
               AND MR.MRTYPE='T' AND AF.OPNDATE <= V_CURRDATE
               AND      AF.status not in ('P','R','E')
               AND AF.producttype ='NM'
        ORDER BY CF.CUSTODYCD,AF.ACCTNO;
        
ELSE
    
OPEN PV_REFCURSOR FOR

        SELECT CF.CUSTODYCD,CF.FULLNAME, AF.ACCTNO,CF.BRID, AF.OPNDATE,
               CF.IDCODE,CF.IDDATE,CF.IDPLACE,CF.MOBILESMS, I_DATE indate
        FROM  AFMAST AF, CFMAST CF,
              (
              select * from (
              SELECT  af.acctno
                      FROM AFMAST AF, AFTYPE AFT, MRTYPE MR
                      WHERE AF.ACTYPE=AFT.ACTYPE AND AFT.MRTYPE=MR.ACTYPE
                      AND MR.MRTYPE='T' AND AF.OPNDATE <= V_CURRDATE
                      AND      AF.status not in ('P','R','E')
                          AND AF.producttype ='NM'
                          group by af.acctno
               MINUS  
                 select ACCTNO from (
                        SELECT ACCTNO FROM(
                              SELECT AF.ACCTNO 
                              FROM   AFMAST AF, AFTYPE AFT, MRTYPE MR
                              WHERE  AF.ACTYPE=AFT.ACTYPE AND AFT.MRTYPE=MR.ACTYPE
                                    AND MR.MRTYPE='T' AND AF.OPNDATE BETWEEN V_INDATE and  V_CURRDATE
                                    AND      AF.status not in ('P','R','E')
                                    AND AF.producttype ='NM'
                              UNION ALL
                              SELECT AF.ACCTNO 
                              FROM VW_TLLOG_ALL TL,CFMAST CF,AFMAST AF, AFTYPE AFT, MRTYPE MR
                              WHERE TL.TLTXCD = '0067'
                                    AND TL.DELTD<>'Y'
                                    AND CF.CUSTID=AF.CUSTID
                                    AND AF.ACTYPE=AFT.ACTYPE AND AFT.MRTYPE=MR.ACTYPE AND MR.MRTYPE='T'
                                    AND CF.CUSTID=TL.MSGACCT AND TL.TXDATE BETWEEN V_INDATE and  V_CURRDATE
                                    AND TL.TXSTATUS  IN ('1','7'))
                                        )
                          group by ACCTNO)
                  
                  UNION 
                  
                  SELECT af.acctno
                  FROM VW_TLLOG_ALL TL,AFMAST AF, AFTYPE AFT, MRTYPE MR
                  WHERE TL.TLTXCD = '2249'
                        AND TL.DELTD<>'Y' AND AF.ACCTNO=TL.MSGACCT
                        AND  AF.ACTYPE=AFT.ACTYPE AND AFT.MRTYPE=MR.ACTYPE
                        AND MR.MRTYPE='T' AND TL.TXDATE BETWEEN V_INDATE and  V_CURRDATE
                        AND TL.TXSTATUS  IN ('1','7')
                        group by acctno
                  
              ) A
        WHERE CF.CUSTID=AF.CUSTID
        AND A.ACCTNO=AF.ACCTNO
        ORDER BY CF.CUSTODYCD,AF.ACCTNO;
end if;

EXCEPTION
  WHEN OTHERS
   THEN
      RETURN;
END;

 
 
 
 
/
