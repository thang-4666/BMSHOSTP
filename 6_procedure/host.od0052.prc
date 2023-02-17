SET DEFINE OFF;
CREATE OR REPLACE PROCEDURE "OD0052" (
   PV_REFCURSOR   IN OUT   PKG_REPORT.REF_CURSOR,
   OPT            IN       VARCHAR2,
   pv_BRID           IN       VARCHAR2,
   TLGOUPS        IN       VARCHAR2,
   TLSCOPE        IN       VARCHAR2,
   F_DATE         IN       VARCHAR2,
   T_DATE         IN       VARCHAR2,
   CUSTODYCD      IN       VARCHAR2,
   PV_AFACCTNO    IN       VARCHAR2,
   TLID            IN       VARCHAR2

   )
IS
-- MODIFICATION HISTORY
-- BAO CAO TINH HINH GIAO DICH CHO QUY DAU TU
-- PERSON   DATE  COMMENTS
-- THANHNNM 29-MAY-12  CREATED
-- ---------   ------  -------------------------------------------
   V_CUSTODYCD      VARCHAR2 (20);
   V_AFACCTNO       VARCHAR2(20);
   V_STROPTION      VARCHAR2 (5);            -- A: ALL; B: BRANCH; S: SUB-BRANCH
   v_brid           VARCHAR2(4);
   V_INBRID        VARCHAR2(4);
   V_STRBRID      VARCHAR2 (50);
   V_STRTLID           VARCHAR2(6);


BEGIN

   /* V_STROPTION := OPT;
    v_brid := brid;

    IF  V_STROPTION = 'A' and v_brid = '0001' then
    V_STRBRID := '%';
    elsif V_STROPTION = 'B' then
        select br.mapid into V_STRBRID from brgrp br where br.brid = v_brid;
    else V_STRBRID := v_brid;

    END IF;
*/
   V_STRTLID:= TLID;
   V_STROPTION := upper(OPT);
   V_INBRID := pv_BRID;
    if(V_STROPTION = 'A') then
        V_STRBRID := '%%';
    else
        if(V_STROPTION = 'B') then
            select br.mapid into V_STRBRID from brgrp br where  br.brid = V_INBRID;
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

       SELECT  PV_AFACCTNO ACCTNO,OD.CUSTODYCD,IO.SYMBOL,OD.TXDATE,
           TO_CHAR(OD.TXDATE,'DDMMYYYY')  C_TXDATE ,
           OD.FULLNAME,OD.ADDRESS,OD.TRADINGCODE,
           IO.BORS,TO_CHAR(getduedate(OD.TXDATE,'B','001',OD.CLEARDAY),'DDMMYYYY') C_DUEDATE,
           NVL(SUM(IO.QTTY),0)  QTTY,
           NVL(SUM(IO.AMT),0)  AMT,
           NVL(SUM (CASE  WHEN  OD.FEEACR>0
                          THEN  OD.FEEACR
                          ELSE --IO.AMT*(OD.BRATIO -100)/100
                            floor(od.deffeerate* od.execamt/100)* io.amt / od.execamt
                          END)
               ,0) FEEAMT,
           NVL(SUM (CASE WHEN  OD.EXECTYPE IN('NS','SS','MS')   THEN
           (CASE WHEN OD.TAXSELLAMT>0 THEN OD.TAXSELLAMT + NVL(ST.ARIGHT,0) ELSE
           OD.TAXRATE*IO.AMT/100 + NVL(ST.ARIGHT,0)  END)  ELSE 0 END ),0) SELLTAXAMT
       FROM
             (
             SELECT OD.ORDERID,OD.EXECTYPE,OD.BRATIO, OD.FEEACR,OD.TAXSELLAMT,OD.TAXRATE,
             AF.ACCTNO , CF.CUSTODYCD,OD.TXDATE,OD.CLEARDAY, CF.FULLNAME,CF.ADDRESS, CF.TRADINGCODE ,
             OD.EXECAMT, ODT.deffeerate
             FROM
              (SELECT * FROM ODMAST WHERE DELTD='N'
              UNION ALL SELECT * FROM ODMASTHIST WHERE DELTD='N') OD, (SELECT * FROM CFMAST WHERE FNC_VALIDATE_SCOPE(BRID, CAREBY, TLSCOPE, pv_BRID, TLGOUPS)=0) CF, AFMAST AF, ODTYPE ODT
              WHERE CF.CUSTID  = AF.CUSTID AND OD.AFACCTNO = AF.ACCTNO
                   AND AF.ACTYPE NOT IN ('0000')
                   AND OD.ACTYPE =ODT.ACTYPE
                   AND OD.TXDATE >= TO_DATE(F_DATE , 'DD/MM/YYYY')
                   AND OD.TXDATE <= TO_DATE(T_DATE , 'DD/MM/YYYY')
                   AND CF.CUSTODYCD  LIKE V_CUSTODYCD
                   AND AF.ACCTNO LIKE V_AFACCTNO
                   and exists (select gu.grpid from tlgrpusers gu where af.careby = gu.grpid and gu.tlid = V_STRTLID )
             ) OD,
             (SELECT BORS,ORGORDERID, SYMBOL,SUM (MATCHQTTY) QTTY, SUM(MATCHQTTY*MATCHPRICE) AMT
              FROM IOD WHERE DELTD <> 'Y' GROUP BY ORGORDERID,SYMBOL,BORS
              UNION ALL
              SELECT BORS,ORGORDERID, SYMBOL,SUM (MATCHQTTY) QTTY, SUM(MATCHQTTY*MATCHPRICE) AMT
              FROM IODHIST WHERE DELTD <> 'Y' GROUP BY ORGORDERID,SYMBOL,BORS) IO,
              (SELECT ORGORDERID, SUM(ARIGHT) ARIGHT
                FROM (SELECT * FROM  STSCHD  UNION SELECT * FROM STSCHDHIST) ST
                GROUP BY ORGORDERID) ST

       WHERE
             OD.ORDERID=IO.ORGORDERID
             AND IO.ORGORDERID = ST.ORGORDERID(+)
             AND IO.QTTY> 0
       GROUP BY OD.CUSTODYCD,OD.FULLNAME,OD.ADDRESS,OD.TRADINGCODE,OD.TXDATE,IO.SYMBOL,IO.BORS,OD.CLEARDAY ;

EXCEPTION
   WHEN OTHERS
   THEN
      RETURN;
END;

 
 
 
 
/
