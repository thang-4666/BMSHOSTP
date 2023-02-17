SET DEFINE OFF;
CREATE OR REPLACE PROCEDURE od0066 (
   PV_REFCURSOR   IN OUT   PKG_REPORT.REF_CURSOR,
   OPT            IN       VARCHAR2,
   pv_BRID           IN       VARCHAR2,
   TLGOUPS        IN       VARCHAR2,
   TLSCOPE        IN       VARCHAR2,
   F_DATE         IN       VARCHAR2,
   T_DATE         IN       VARCHAR2,
   I_BRID         IN       VARCHAR2,
   SYMBOL         IN       VARCHAR2,
   EXECTYPE       IN       VARCHAR2,
   TLID           IN       VARCHAR2

   )
IS
-- MODIFICATION HISTORY
-- KET QUA KHOP LENH  KHACH HANG CUA TOAN CONG TY
-- PERSON      DATE    COMMENTS
-- QUYETKD   28/04/2011  CREATED
-----------------------------------------------------------------------

   V_STROPTION      VARCHAR2 (5);            -- A: ALL; B: BRANCH; S: SUB-BRANCH
   V_STRINBRID      VARCHAR2 (40);
   V_INBRID         VARCHAR2 (4);

   V_STRBRID        VARCHAR2 (4);            -- USED WHEN V_NUMOPTION > 0


   V_STREXECTYPE    VARCHAR2 (5);
   V_STRSYMBOL      VARCHAR2 (20);
   V_STRTRADEPLACE  VARCHAR2 (3);
   V_CIACCTNO       VARCHAR2 (20);
   V_CUSTODYCD       VARCHAR2 (20);

   V_NUMBUY         NUMBER (20,2);

   V_TRADELOG CHAR(2);
   V_AUTOID NUMBER;
   v_TLID varchar2(4);
   V_CUR_DATE DATE ;

   V_brname_name varchar2(50);

-- DECLARE PROGRAM VARIABLES AS SHOWN ABOVE
BEGIN
   V_STROPTION := upper(OPT);
   V_INBRID := pv_BRID;
   if (V_STROPTION = 'A') then
        V_STRINBRID := '%';
        V_brname_name := 'ALL';
    else if (V_STROPTION = 'B')then
            select brgrp.mapid into V_STRINBRID from brgrp where brgrp.brid = V_INBRID;
            Select brname into V_brname_name from brgrp  where brid = V_INBRID;
        else
            V_STRINBRID := V_INBRID;
            Select brname into V_brname_name from brgrp  where brid = V_INBRID;
        end if;
   end if;


   v_TLID := TLID;

    IF (I_BRID <> 'ALL') THEN
      V_STRBRID := I_BRID;
   ELSE
      V_STRBRID := '%';
   END IF;


----- GET REPORT'S PARAMETERS

    IF (SYMBOL <> 'ALL')
   THEN
      V_STRSYMBOL := SYMBOL;
   ELSE
      V_STRSYMBOL := '%%';
   END IF;
   --
   IF (EXECTYPE <> 'ALL')
   THEN
      V_STREXECTYPE := EXECTYPE;
   ELSE
      V_STREXECTYPE := '%%';
   END IF;
   --

SELECT TO_DATE (VARVALUE ,'DD/MM/YYYY') INTO V_CUR_DATE FROM SYSVAR WHERE VARNAME ='CURRDATE';


BEGIN
SELECT
SUM(CASE WHEN ODM.EXECTYPE = 'NB' OR ODM.EXECTYPE = 'BC' THEN NVL(ODM.EXECAMT,0) ELSE 0 END ) INTO V_NUMBUY
    FROM (SELECT * FROM ODMAST UNION ALL SELECT * FROM ODMASTHIST ) ODM, afmast af, (SELECT * FROM CFMAST WHERE FNC_VALIDATE_SCOPE(BRID, CAREBY, TLSCOPE, pv_BRID, TLGOUPS)=0) cf , sbsecurities sb
        WHERE ODM.TXDATE >= TO_DATE(F_DATE, 'DD/MM/YYYY')
            AND ODM.TXDATE <= TO_DATE(T_DATE, 'DD/MM/YYYY')
            AND ODM.EXECTYPE IN ('NB','CB')
            AND ODM.EXECAMT <> 0
            AND ODM.DELTD <> 'Y'
            AND af.acctno = odm.afacctno
            AND cf.custid = af.custid
            AND AF.ACTYPE NOT IN ('0000')
            AND af.brid  LIKE  V_STRBRID
            and (af.brid  LIKE V_STRINBRID or instr(V_STRINBRID,af.brid) <> 0)
            AND ODM.codeid =sb.codeid
            AND sb.symbol like V_STRSYMBOL
            AND ODM.EXECTYPE like V_STREXECTYPE;


EXCEPTION
WHEN no_data_found THEN
V_NUMBUY:=0;
END;

   -- GET REPORT'S DATA


 OPEN PV_REFCURSOR
       FOR
   SELECT DT.*,
   NVL(V_NUMBUY,0) TOTALBUY,
   V_brname_name V_brname_name,
   V_STRSYMBOL V_STRSYMBOL,
   V_STREXECTYPE V_STREXECTYPE
    FROM
     ( SELECT  ROWNUM ROWN,
               T.*,
               NVL(IO.MATCHQTTY,0) MATCHQTTY,
               NVL(IO.MATCHPRICE,0) MATCHPRICE,
               NVL(IO.MATCHQTTY,0)*NVL(IO.MATCHPRICE,0) VAL_IOD ,
               (CASE  WHEN T.EXECTYPE IN('NS','SS','MS')
                 then  NVL(IO.MATCHQTTY,0)*NVL(IO.MATCHPRICE,0) * case when  t.vat ='Y' or t.whtax ='Y' then  T.taxrate else 0 end /100 /*nvl((select to_number(varvalue) from sysvar where varname = 'ADVSELLDUTY' and grname = 'SYSTEM'),0)/100*/ else 0 end) FREE_TNCN,
               round((CASE  WHEN  NVL(T.EXECAMT,0)= 0   THEN 0 ELSE T.FEEACR *100/NVL(T.EXECAMT,0) END ),4) PERFEE
       FROM (SELECT CF.VAT,AF.ACCTNO,CF.WHTAX,
                    AF.actype,
                    OD.ORDERID,
                    OD.TXDATE, od.taxrate,
                   (CASE  WHEN OD.EXECTYPE IN('NB','BC','NS','SS') AND OD.REFORDERID IS NOT NULL AND OD.CORRECTIONNUMBER = 0 THEN 'C'  ELSE OD.EXECTYPE END) EXECTYPE
                   ,SB.SYMBOL,
                    (CASE WHEN OD.PRICETYPE IN ('ATO','ATC') THEN  OD.PRICETYPE  ELSE  TO_CHAR(OD.QUOTEPRICE) END )QUOTEPRICE ,
                    OD.ORDERQTTY, OD.CIACCTNO, CF.FULLNAME, CF.CUSTODYCD,
                    (CASE WHEN OD.TXDATE  = V_CUR_DATE THEN (CASE WHEN OD.EXECAMT > OD.MATCHAMT THEN OD.EXECAMT ELSE OD.MATCHAMT END  )*ODTYPE.deffeerate/100 ELSE OD.FEEACR END ) FEEACR ,
                    SB.TRADEPLACE TRADEPLACE,
                    ( CASE WHEN OD.EXECAMT > OD.MATCHAMT THEN OD.EXECAMT ELSE OD.MATCHAMT END  ) EXECAMT
               FROM
                    (SELECT* FROM ODMAST   WHERE DELTD <> 'Y'
                    UNION ALL SELECT * FROM ODMASTHIST   WHERE DELTD<>'Y' ) OD,
                    SBSECURITIES SB,AFMAST AF ,(SELECT * FROM CFMAST WHERE FNC_VALIDATE_SCOPE(BRID, CAREBY, TLSCOPE, pv_BRID, TLGOUPS)=0) CF,ODTYPE, AFTYPE AFT
                WHERE  OD.CODEID = SB.CODEID
                   AND ODTYPE.actype = OD.ACTYPE
                   AND AF.ACTYPE = AFT.ACTYPE
                   AND AF.ACTYPE NOT IN ('0000')
                   AND OD.CIACCTNO = AF.ACCTNO
                   AND AF.CUSTID = CF.CUSTID
                   AND OD.TXDATE >= TO_DATE (F_DATE, 'DD/MM/YYYY')
                   AND OD.TXDATE <= TO_DATE (T_DATE, 'DD/MM/YYYY')
                   AND SB.SYMBOL like V_STRSYMBOL
                   AND OD.EXECTYPE like V_STREXECTYPE
                   AND af.brid  LIKE  V_STRBRID
                   and (af.brid  LIKE V_STRINBRID or instr(V_STRINBRID,af.brid) <> 0)

              ORDER BY  UPPER(FULLNAME) DESC, UPPER(SYMBOL), TXDATE, ORDERID ) T
              INNER JOIN
                  (SELECT * FROM IOD WHERE DELTD<>'Y'UNION ALL  SELECT * FROM IODHIST  WHERE DELTD<>'Y' ) IO
             ON IO.ORGORDERID=T.ORDERID
             )DT
 WHERE    0=0 ;


END;
 
/
