SET DEFINE OFF;
CREATE OR REPLACE PROCEDURE "MR0065" (
   PV_REFCURSOR   IN OUT   PKG_REPORT.REF_CURSOR,
   pv_OPT         IN       VARCHAR2,
   pv_BRID        IN       VARCHAR2,
   TLGOUPS        IN       VARCHAR2,
   TLSCOPE        IN       VARCHAR2,
   F_DATE         IN       VARCHAR2,
   T_DATE         IN       VARCHAR2,
   PV_AFTYPE      IN       VARCHAR2
)
IS

--

-- ---------   ------  -------------------------------------------      -- A: ALL; B: BRANCH; S: SUB-BRANCH

   V_IDATE           DATE;
   V_INBRID         VARCHAR2(4);
   V_STRBRID        VARCHAR2 (50);
   V_STROPTION      VARCHAR2(10);
	 VF_DATE DATE;
	 VT_DATE DATE;
   V_AFTYPE         VARCHAR2(10);


BEGIN
     V_STROPTION := upper(pv_OPT);
     V_INBRID := pv_BRID;

  IF (V_STROPTION = 'A')
   THEN
      V_STRBRID := '%';
   ELSE if (V_STROPTION = 'B') then
            select brgrp.BRID into V_STRBRID from brgrp where brgrp.brid = V_INBRID;
        else
            V_STRBRID := V_INBRID;
        end if;
   END IF;
   
   IF(PV_AFTYPE IS NULL OR UPPER(PV_AFTYPE)='ALL')
   THEN V_AFTYPE := '%';
   ELSE V_AFTYPE:= PV_AFTYPE;
   END IF;
 -- END OF GETTING REPORT'S PARAMETERS

    VF_DATE:=TO_DATE(F_DATE,'DD/MM/RRRR');
		    VT_DATE:=TO_DATE(T_DATE,'DD/MM/RRRR');

   ----
-- GET REPORT'S DATA
OPEN PV_REFCURSOR FOR

      SELECT AMT.TXDATE,MAIN.CUSTID, MAIN.CUSTODYCD,MAIN.FULLNAME,MAIN.BRID, MAIN.ACCTNO, MAIN.BRNAME,main.MRCRLIMITMAX-sum(nvl(lo.AMT_ADD,0))+sum(nvl(lo.AMT_DEL,0)) MRCRLIMITMAX ,
             NVL(AMT.AMT_ADD,0) AMT_ADD, NVL(AMT.AMT_DEL,0) AMT_DEL
             
             
     FROM (SELECT CF.CUSTID, CF.CUSTODYCD,CF.FULLNAME,CF.BRID,AF.ACCTNO, BR.BRNAME,NVL(AF.MRCRLIMITMAX,0) MRCRLIMITMAX
                  FROM (SELECT * FROM CFMAST WHERE FNC_VALIDATE_SCOPE(BRID, CAREBY, TLSCOPE, pv_BRID, TLGOUPS)=0) CF,
                               AFMAST AF, BRGRP BR,AFTYPE AFT
                  WHERE AF.CUSTID=CF.CUSTID AND CF.BRID=BR.BRID(+)
                        AND AF.ACTYPE= AFT.ACTYPE
                        AND AFT.PRODUCTTYPE LIKE V_AFTYPE
          ) MAIN,
                     (
                       SELECT A.TXDATE,A.ACCTNO,SUM(DECODE(A.TXTYPE,'C', A.AMT,0)) AMT_ADD,
                       SUM(DECODE(A.TXTYPE,'C',0, A.AMT)) AMT_DEL
                       FROM AFMAST_LOG  A
                       WHERE A.TXDATE BETWEEN  vf_date AND vt_date
                       GROUP BY  A.TXDATE,A.ACCTNO
                      )AMT
          LEFT JOIN
                    (
                       SELECT A.TXDATE,A.ACCTNO,SUM(DECODE(A.TXTYPE,'C', A.AMT,0)) AMT_ADD,
                       SUM(DECODE(A.TXTYPE,'C',0, A.AMT)) AMT_DEL
                       FROM AFMAST_LOG  A
                       WHERE A.TXDATE>= vf_date
                       GROUP BY  A.TXDATE,A.ACCTNO 
                    ) lo ON amt.acctno = lo.acctno AND amt.txdate < lo.txdate

   WHERE MAIN.ACCTNO=AMT.ACCTNO
   group by AMT.TXDATE,MAIN.CUSTID, MAIN.CUSTODYCD,MAIN.FULLNAME,MAIN.BRID, MAIN.ACCTNO, MAIN.BRNAME,NVL(AMT.AMT_ADD,0), 
            NVL(AMT.AMT_DEL,0) , main.MRCRLIMITMAX
        ORDER BY AMT.TXDATE, CUSTODYCD,MAIN.ACCTNO;

  /*   SELECT AMT.TXDATE,MAIN.CUSTID, MAIN.CUSTODYCD,MAIN.FULLNAME,MAIN.BRID, MAIN.ACCTNO, MAIN.BRNAME, nvl(lo.mrcrlimitmax, MAIN.MRCRLIMITMAX) MRCRLIMITMAX ,
             NVL(AMT.AMT_ADD,0) AMT_ADD, NVL(AMT.AMT_DEL,0) AMT_DEL
     FROM (SELECT CF.CUSTID, CF.CUSTODYCD,CF.FULLNAME,CF.BRID,AF.ACCTNO, BR.BRNAME,NVL(AF.MRCRLIMITMAX,0) MRCRLIMITMAX
                  FROM (SELECT * FROM CFMAST WHERE FNC_VALIDATE_SCOPE(BRID, CAREBY, TLSCOPE, pv_BRID, TLGOUPS)=0) CF,
									             AFMAST AF, BRGRP BR,AFTYPE AFT
                  WHERE AF.CUSTID=CF.CUSTID AND CF.BRID=BR.BRID(+)
                        AND AF.ACTYPE= AFT.ACTYPE
                        AND AFT.PRODUCTTYPE LIKE V_AFTYPE
          ) MAIN,
                     (
                     SELECT A.TXDATE,A.ACCTNO, NVL(A.AMT_ADD,0) AMT_ADD, NVL(B.AMT_DEL,0) AMT_DEL
                     FROM(SELECT  TXDATE, SUM(MSGAMT) AMT_ADD,MSGACCT ACCTNO FROM VW_TLLOG_ALL
                     WHERE TLTXCD='1813' AND DELTD<>'Y' AND TXSTATUS IN ('1','7')
                            GROUP BY TXDATE, MSGACCT) A,
                    (SELECT  TXDATE, SUM(MSGAMT) AMT_DEL,MSGACCT ACCTNO FROM VW_TLLOG_ALL
                     WHERE TLTXCD='1814' AND DELTD<>'Y' AND TXSTATUS IN ('1','7')
                     GROUP BY TXDATE, MSGACCT)B
                     WHERE A.TXDATE=B.TXDATE(+)
                            AND A.ACCTNO=B.ACCTNO(+)
                     UNION
                     SELECT B.TXDATE,B.ACCTNO, NVL(A.AMT_ADD,0) AMT_ADD, NVL(B.AMT_DEL,0) AMT_DEL
                     FROM(SELECT  TXDATE, SUM(MSGAMT) AMT_ADD,MSGACCT ACCTNO FROM VW_TLLOG_ALL
                     WHERE TLTXCD='1813' AND DELTD<>'Y' AND TXSTATUS IN ('1','7')
                            GROUP BY TXDATE, MSGACCT) A,
                     (SELECT  TXDATE, SUM(MSGAMT) AMT_DEL,MSGACCT ACCTNO FROM VW_TLLOG_ALL
                     WHERE TLTXCD='1814' AND DELTD<>'Y' AND TXSTATUS IN ('1','7')
                              GROUP BY TXDATE, MSGACCT)B
                     WHERE B.TXDATE=A.TXDATE(+)
                              AND B.ACCTNO=A.ACCTNO(+)
                    )AMT
					LEFT JOIN
					(SELECT afacctno, txdate, max(mrcrlimitmax) mrcrlimitmax FROM tbl_mr3007_log WHERE txdate  BETWEEN vf_date AND vt_date
					GROUP BY txdate, afacctno ) lo ON amt.acctno = lo.afacctno AND amt.txdate = lo.txdate

   WHERE MAIN.ACCTNO=AMT.ACCTNO
        AND AMT.TXDATE BETWEEN VF_DATE AND VT_DATE
        ORDER BY AMT.TXDATE, CUSTODYCD,MAIN.ACCTNO
    ;*/
 EXCEPTION
   WHEN OTHERS
   THEN
        RETURN;
END;
 
 
 
 
/
