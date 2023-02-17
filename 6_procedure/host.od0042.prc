SET DEFINE OFF;
CREATE OR REPLACE PROCEDURE "OD0042" (
   PV_REFCURSOR   IN OUT   PKG_REPORT.REF_CURSOR,
   OPT            IN       VARCHAR2,
   pv_BRID           IN       VARCHAR2,
   TLGOUPS        IN       VARCHAR2,
   TLSCOPE        IN       VARCHAR2,
   F_DATE         IN       VARCHAR2,
   T_DATE         IN       VARCHAR2,
   CUSTODYCD      IN       VARCHAR2,
   PV_AFACCTNO    IN       VARCHAR2

   )
IS
-- MODIFICATION HISTORY
-- BAO CAO PHI GIAO DICH CHO NHA DAU TU
-- PERSON   DATE  COMMENTS
-- THANHNNM 11-MAY-12  CREATED
-- ---------   ------  -------------------------------------------
   V_CUSTODYCD      VARCHAR2 (20);
   V_AFACCTNO       VARCHAR2(20);
   V_STROPTION      VARCHAR2 (5);            -- A: ALL; B: BRANCH; S: SUB-BRANCH
   v_brid           VARCHAR2(4);

   V_INBRID        VARCHAR2(4);
   V_STRBRID      VARCHAR2 (50);

BEGIN

  /*  V_STROPTION := OPT;
    v_brid := brid;

    IF  V_STROPTION = 'A' and v_brid = '0001' then
    V_STRBRID := '%';
    elsif V_STROPTION = 'B' then
        select br.mapid into V_STRBRID from brgrp br where br.brid = v_brid;
    else V_STRBRID := v_brid;

    END IF;*/
    V_STROPTION := upper(OPT);
    V_INBRID := pv_BRID;
    if(V_STROPTION = 'A') then
        V_STRBRID := '%%';
    else
        if(V_STROPTION = 'B') then
            select br.BRID into V_STRBRID from brgrp br where  br.brid = V_INBRID;
        else
            V_STRBRID := V_INBRID;
        end if;
    end if;

   IF (CUSTODYCD <> 'ALL')
   THEN
      V_CUSTODYCD := CUSTODYCD;
   ELSE
      V_CUSTODYCD := '%';
   END IF;

      IF (PV_AFACCTNO <> 'ALL')
   THEN
      V_AFACCTNO := PV_AFACCTNO;
   ELSE
      V_AFACCTNO := '%';
   END IF;


 OPEN PV_REFCURSOR
       FOR

       SELECT  PV_AFACCTNO ACCTNO,OD.CUSTODYCD,IO.SYMBOL,OD.TXDATE ,OD.FULLNAME,OD.ADDRESS,
           NVL(SUM (CASE  WHEN OD.EXECTYPE IN('NB','BC')  THEN   NVL(IO.QTTY,0)  END),0)  B_QTTY,
           NVL(SUM (CASE  WHEN OD.EXECTYPE IN('NS','SS','MS')  THEN   NVL(IO.QTTY,0) END),0)  S_QTTY,
           NVL(SUM (CASE  WHEN  OD.EXECTYPE IN('NB','BC') THEN  NVL(IO.AMT,0) END ),0)  B_AMT,
           NVL(SUM (CASE  WHEN  OD.EXECTYPE IN('NS','SS','MS') THEN  NVL(IO.AMT,0) END ),0)  S_AMT,
           NVL(SUM (CASE  WHEN  OD.FEEACR>0 THEN  OD.FEEACR
                          WHEN OD.FEEACR=0 AND OD.TXDATE<> getcurrdate THEN 0
                          ELSE IO.AMT*(OD.BRATIO -100)/100 END),0) FEEAMT,
           NVL(SUM (CASE WHEN  OD.EXECTYPE IN('NS','SS','MS')   THEN
            (CASE WHEN OD.TAXSELLAMT>0 THEN OD.TAXSELLAMT ELSE OD.TAXRATE*IO.AMT/100 END)  ELSE 0 END ),0) SELLTAXAMT
       FROM
             (SELECT OD.ORDERID,OD.EXECTYPE,OD.BRATIO, OD.FEEACR,OD.TAXSELLAMT,OD.TAXRATE,
             AF.ACCTNO , CF.CUSTODYCD,OD.TXDATE, CF.FULLNAME,CF.ADDRESS FROM
              (SELECT * FROM ODMAST WHERE DELTD='N'
              UNION ALL SELECT * FROM ODMASTHIST WHERE DELTD='N') OD, (SELECT * FROM CFMAST WHERE FNC_VALIDATE_SCOPE(BRID, CAREBY, TLSCOPE, pv_BRID, TLGOUPS)=0) CF, AFMAST AF
              WHERE
                   CF.CUSTID  = AF.CUSTID AND OD.AFACCTNO = AF.ACCTNO
                   AND AF.ACTYPE NOT IN ('0000')
                   AND OD.TXDATE >= TO_DATE(F_DATE , 'DD/MM/YYYY')
                   AND OD.TXDATE <= TO_DATE(T_DATE , 'DD/MM/YYYY')
                   AND CF.CUSTODYCD  LIKE V_CUSTODYCD
                   AND AF.ACCTNO LIKE V_AFACCTNO
                   AND (af.brid LIKE V_STRBRID or instr(V_STRBRID,af.brid) <> 0 )
             ) OD,
             (SELECT ORGORDERID, SYMBOL,SUM (MATCHQTTY) QTTY, SUM(MATCHQTTY*MATCHPRICE) AMT
              FROM IOD WHERE DELTD <> 'Y' GROUP BY ORGORDERID,SYMBOL
              UNION ALL
              SELECT ORGORDERID, SYMBOL,SUM (MATCHQTTY) QTTY, SUM(MATCHQTTY*MATCHPRICE) AMT
              FROM IODHIST WHERE DELTD <> 'Y' GROUP BY ORGORDERID,SYMBOL) IO
       WHERE
             OD.ORDERID=IO.ORGORDERID
             AND IO.QTTY> 0
       GROUP BY OD.CUSTODYCD,OD.FULLNAME,OD.ADDRESS,OD.TXDATE,IO.SYMBOL  ;

EXCEPTION
   WHEN OTHERS
   THEN
      RETURN;
END;

 
 
 
 
/
