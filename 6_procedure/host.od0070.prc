SET DEFINE OFF;
CREATE OR REPLACE PROCEDURE od0070 (
   PV_REFCURSOR   IN OUT   PKG_REPORT.REF_CURSOR,
   OPT            IN       VARCHAR2,
   BRID           IN       VARCHAR2,
   TLGOUPS        IN       VARCHAR2,
   TLSCOPE        IN       VARCHAR2,
   I_DATE         IN       VARCHAR2,
   DATE_T         IN       VARCHAR2,
   TRADEPLACE     IN       VARCHAR2,
   PV_SECTYPE     IN       VARCHAR2,
   CASHPLACE      IN       VARCHAR2,
   PV_BRID        IN       VARCHAR2,
   PV_CLEARDAY    IN       VARCHAR2
  )
IS
--
-- PURPOSE: BRIEFLY EXPLAIN THE FUNCTIONALITY OF THE PROCEDURE
--
-- MODIFICATION HISTORY
-- PERSON      DATE      COMMENTS
-- QUOCTA   06/02/2012   CREATE
-- ---------   ------  -------------------------------------------

  V_STROPTION        VARCHAR2 (5);       -- A: ALL; B: BRANCH; S: SUB-BRANCH
  V_STRBRID          VARCHAR2 (40);
  V_INBRID          VARCHAR2 (4);

  V_STRTRADEPLACE    VARCHAR2 (4);
  V_SECTYPE          VARCHAR2(100);
  V_STRCASHPLACE     VARCHAR2 (100);

  TRAN_DATE          DATE;
  V_STRCLEARDAY       NUMBER;

  V_PV_STRBRID       VARCHAR2 (50);
    V_p_STRBRID      VARCHAR2 (10);
BEGIN
   V_STROPTION := upper(OPT);
   V_INBRID := BRID;


   IF (V_STROPTION = 'A') THEN
      V_STRBRID := '%';
   ELSE if (V_STROPTION = 'B') then
            select brgrp.mapid into V_STRBRID from brgrp where brgrp.brid = V_INBRID;
        else
            V_STRBRID := V_INBRID;
        end if;
   END IF;
    V_STRBRID := '%';

   -- GET REPORT'S PARAMETERS

   --ngoc.vu-Jira561
   IF  (TRADEPLACE <> 'ALL')
   THEN
      V_STRTRADEPLACE := TRADEPLACE;
      TRAN_DATE :=  getduedate(TO_DATE(I_DATE, 'DD/MM/RRRR'), 'B', TRADEPLACE, TO_NUMBER(DATE_T));
   ELSE
      V_STRTRADEPLACE := '%';
      TRAN_DATE :=  getduedate(TO_DATE(I_DATE, 'DD/MM/RRRR'), 'B', '001', TO_NUMBER(DATE_T));
   END IF;


   IF  (PV_SECTYPE <> 'ALL')
   THEN
      V_SECTYPE := PV_SECTYPE;
   ELSE
      V_SECTYPE := '%';
   END IF;


   IF  (CASHPLACE <> 'ALL')
   THEN
      V_STRCASHPLACE := CASHPLACE;
   ELSE
      V_STRCASHPLACE := '%';
   END IF;

   IF(UPPER(PV_CLEARDAY) = 'ALL') THEN
        V_STRCLEARDAY := 9;
   ELSIF (UPPER(PV_CLEARDAY) = 'T0') THEN
        V_STRCLEARDAY := 0;
   ELSE
        V_STRCLEARDAY := 2;
   END IF;


   if(upper(PV_BRID) = 'ALL' OR LENGTH(PV_BRID) <= 1) then
        V_pV_STRBRID := '%';
        V_p_STRBRID := '%';
    else
        if(upper(PV_BRID) = 'GROUP1') then
            V_pV_STRBRID := ' 0002,0001,0003 ';
            V_p_STRBRID := 'D';
        ELSE IF (upper(PV_BRID) = 'GROUP2') THEN
            V_pV_STRBRID := ' 0101,0102,0103 ';
            V_p_STRBRID := 'D';
        else
            V_pV_STRBRID := 'D';
            V_p_STRBRID := PV_BRID;
        end if;
        end if;
    end if;


IF (CASHPLACE = 'ALL') THEN

OPEN PV_REFCURSOR
FOR
SELECT
         SUM(nvl(d_bamt,0)) d_bamt, SUM (nvl(d_samt,0)) d_samt, SUM (nvl(bd_bamt,0)) bd_bamt,
         SUM (nvl(bd_samt,0)) bd_samt, SUM (nvl(bf_bamt,0)) bf_bamt, SUM (nvl(bf_samt,0)) bf_samt,
         T_CLEARDAY, BANKNAME, TRAN_DATE TRAN_DATE
from
(
SELECT
         SUM(d_bamt) d_bamt, SUM (d_samt) d_samt, SUM (bd_bamt) bd_bamt,
         SUM (bd_samt) bd_samt, SUM (bf_bamt) bf_bamt, SUM (bf_samt) bf_samt,
         T_CLEARDAY, BANKNAME
FROM     (
              SELECT
                   SUM (DECODE (chd.duetype, 'SM', chd.amt , 0)) d_bamt,
                   SUM (DECODE (chd.duetype, 'RM', chd.amt , 0)) d_samt,
                   0 bd_bamt, 0 bd_samt, 0 bf_bamt, 0 bf_samt,
                   AFB.BANKNAME, OD.T_CLEARDAY
              FROM stschd chd, afmast af, (SELECT * FROM CFMAST WHERE FNC_VALIDATE_SCOPE(BRID, CAREBY, TLSCOPE, pv_BRID, TLGOUPS)=0) cf, AFTYPE AFT,
                   (SELECT AF.ACCTNO, (CASE WHEN AFT.COREBANK = 'N' THEN cspks_system.fn_get_sysvar('SYSTEM','COMPANYSHORTNAME') ELSE AF.BANKNAME END) BANKNAME
                    FROM AFMAST AF, AFTYPE AFT
                    WHERE AF.ACTYPE = AFT.ACTYPE) AFB,
                   (SELECT *  FROM sbsecurities
                     WHERE  SECTYPE LIKE V_SECTYPE AND SECTYPE IN ('001','006','008','011')) sb, --Ngay 23/03/2017 CW NamTv them sectype 011
        /*            (select * from odmast where txdate = TO_DATE (i_date, 'DD/MM/YYYY')
                        union all select * from odmasthist where txdate = TO_DATE (i_date, 'DD/MM/YYYY')) od        */
              (
                    SELECT OD.*, STS.CLEARDATE T_CLEARDAY
                    FROM
                        (
                          SELECT * from vw_odmast_tradeplace_all where txdate = TO_DATE (i_date, 'DD/MM/YYYY')
                          and (tradeplace LIKE v_strtradeplace or (case when tradeplace = '001' or tradeplace = '002' then '999' else '888'
                            end ) like v_strtradeplace) AND tradeplace IN ('001','002','005')

                        )OD,
                    (SELECT * FROM STSCHD UNION ALL SELECT * FROM STSCHDHIST) STS
                    WHERE   OD.ORDERID = STS.ORGORDERID(+)
                        AND STS.DELTD <> 'Y'
                        AND nvl(STS.DUETYPE ,(CASE WHEN OD.EXECTYPE IN('NB','BC') THEN 'SM' ELSE 'RM' END)) =
                                    (CASE WHEN OD.EXECTYPE IN('NB','BC') THEN 'SM' ELSE 'RM' END)
                ) OD
             WHERE chd.deltd <> 'Y'
               AND SUBSTR (chd.acctno, 1, 10) = af.acctno
               AND af.custid = cf.custid
               AND AF.ACTYPE NOT IN ('0000')
               AND SUBSTR (cf.custodycd, 4, 1) = 'P'
               AND chd.duetype IN ('SM', 'RM')
               AND chd.txdate = TO_DATE (i_date, 'DD/MM/YYYY')
               AND cf.custodycd LIKE '%'
               AND sb.codeid = chd.codeid
               AND od.clearday = TO_NUMBER(DATE_T)
               AND AF.ACTYPE        =  AFT.ACTYPE
               AND AFT.COREBANK     LIKE '%'
               AND AF.BANKNAME      LIKE '%'
               AND AF.ACCTNO        = AFB.ACCTNO
               AND (af.brid like V_p_STRBRID or instr(V_pV_STRBRID,af.brid) <> 0 )
               and (af.brid like V_STRBRID or INSTR(V_STRBRID,af.brid) <> 0)
               and chd.orgorderid = od.orderid
               AND (CASE WHEN V_STRCLEARDAY = 9 OR OD.EXECTYPE IN('NS','SS','MS') THEN V_STRCLEARDAY
                ELSE (CASE WHEN OD.T_CLEARDAY = OD.TXDATE
                THEN 0 ELSE 2 END ) END) = V_STRCLEARDAY
          GROUP BY AFB.BANKNAME, OD.T_CLEARDAY
          UNION ALL
              SELECT 0 d_bamt, 0 d_samt,
                   SUM (DECODE (chd.duetype,'SM', chd.amt ,0)) bd_bamt,
                   SUM (DECODE (chd.duetype,'RM', chd.amt ,0)) bd_samt, 0 bf_bamt, 0 bf_samt, AFB.BANKNAME, OD.T_CLEARDAY
              FROM stschd chd, afmast af, (SELECT * FROM CFMAST WHERE FNC_VALIDATE_SCOPE(BRID, CAREBY, TLSCOPE, pv_BRID, TLGOUPS)=0) cf, AFTYPE AFT,
                   (SELECT AF.ACCTNO, (CASE WHEN AFT.COREBANK = 'N' THEN cspks_system.fn_get_sysvar('SYSTEM','COMPANYSHORTNAME') ELSE AF.BANKNAME END) BANKNAME
                    FROM AFMAST AF, AFTYPE AFT WHERE AF.ACTYPE = AFT.ACTYPE) AFB,
                   (SELECT * FROM sbsecurities
                     WHERE SECTYPE LIKE V_SECTYPE AND SECTYPE IN ('001','006','008','011')) sb, --Ngay 23/03/2017 CW NamTv them sectype 011
             (
                    SELECT OD.*, STS.CLEARDATE T_CLEARDAY
                    FROM
                        (
                          SELECT * from vw_odmast_tradeplace_all where txdate = TO_DATE (i_date, 'DD/MM/YYYY')
                          and (tradeplace LIKE v_strtradeplace or (case when tradeplace = '001' or tradeplace = '002' then '999' else '888'
                          end ) like v_strtradeplace) AND tradeplace IN ('001','002','005')

                        )OD,
                    (SELECT * FROM STSCHD UNION ALL SELECT * FROM STSCHDHIST) STS
                    WHERE   OD.ORDERID = STS.ORGORDERID(+)
                        AND STS.DELTD <> 'Y'
                        AND nvl(STS.DUETYPE ,(CASE WHEN OD.EXECTYPE IN('NB','BC') THEN 'SM' ELSE 'RM' END)) =
                                    (CASE WHEN OD.EXECTYPE IN('NB','BC') THEN 'SM' ELSE 'RM' END)
                ) OD
             WHERE chd.deltd <> 'Y'
               AND SUBSTR (chd.acctno, 1, 10) = af.acctno
               AND af.custid = cf.custid
               AND AF.ACTYPE NOT IN ('0000')
               AND SUBSTR (cf.custodycd, 4, 1) = 'C'
               AND chd.duetype IN ('SM', 'RM')
               AND chd.txdate = TO_DATE (i_date, 'DD/MM/YYYY')
               AND cf.custodycd LIKE '%'
               AND sb.codeid = chd.codeid
               AND AF.ACTYPE        =  AFT.ACTYPE
               AND AFT.COREBANK     LIKE '%'
               AND AF.BANKNAME      LIKE '%'
               AND AF.ACCTNO        = AFB.ACCTNO
               and chd.orgorderid = od.orderid
 ---              AND (substr(af.acctno,1,4) like V_p_STRBRID or instr((V_pV_STRBRID),substr(af.acctno,1,4)) <> 0 )
               AND (af.brid like V_p_STRBRID or instr(V_pV_STRBRID,af.brid) <> 0 )
               and (af.brid like V_STRBRID or INSTR(V_STRBRID,af.brid) <> 0)
               AND (CASE WHEN V_STRCLEARDAY = 9 OR OD.EXECTYPE IN('NS','SS','MS') THEN V_STRCLEARDAY
                ELSE (CASE WHEN OD.T_CLEARDAY = OD.TXDATE
                THEN 0 ELSE 2 END ) END) = V_STRCLEARDAY
               AND od.clearday = TO_NUMBER(DATE_T)
               AND (CASE WHEN V_STRCLEARDAY = 9 OR OD.EXECTYPE IN('NS','SS','MS') THEN V_STRCLEARDAY
                ELSE (CASE WHEN OD.T_CLEARDAY = OD.TXDATE
                THEN 0 ELSE 2 END ) END) = V_STRCLEARDAY
          GROUP BY AFB.BANKNAME, OD.T_CLEARDAY
          UNION ALL
              SELECT 0 d_bamt, 0 d_samt, 0 bd_bamt, 0 bd_samt,
                   SUM (DECODE (chd.duetype,'SM', chd.amt ,0)) bf_bamt,
                   SUM (DECODE (chd.duetype,'RM', chd.amt ,0)) bf_samt, AFB.BANKNAME, OD.T_CLEARDAY
              FROM stschd chd, afmast af, cfmast cf, AFTYPE AFT,
                   (SELECT AF.ACCTNO, (CASE WHEN AFT.COREBANK = 'N' THEN cspks_system.fn_get_sysvar('SYSTEM','COMPANYSHORTNAME') ELSE AF.BANKNAME END) BANKNAME
                    FROM AFMAST AF, AFTYPE AFT
                    WHERE AF.ACTYPE = AFT.ACTYPE) AFB,
                   (SELECT * FROM sbsecurities
                     WHERE  SECTYPE LIKE V_SECTYPE AND SECTYPE IN ('001','006','008','011')) sb, --Ngay 23/03/2017 CW NamTv them sectype 011
                  (
                    SELECT OD.*, STS.CLEARDATE T_CLEARDAY
                    FROM
                        (
                          SELECT * from vw_odmast_tradeplace_all where txdate = TO_DATE (i_date, 'DD/MM/YYYY')
                          and (tradeplace LIKE v_strtradeplace or (case when tradeplace = '001' or tradeplace = '002' then '999' else '888'
                          end ) like v_strtradeplace) AND tradeplace IN ('001','002','005')

                        )OD,
                    (SELECT * FROM STSCHD UNION ALL SELECT * FROM STSCHDHIST) STS
                    WHERE   OD.ORDERID = STS.ORGORDERID(+)
                        AND STS.DELTD <> 'Y'
                        AND nvl(STS.DUETYPE ,(CASE WHEN OD.EXECTYPE IN('NB','BC') THEN 'SM' ELSE 'RM' END)) =
                                    (CASE WHEN OD.EXECTYPE IN('NB','BC') THEN 'SM' ELSE 'RM' END)
                ) OD
              WHERE chd.deltd <> 'Y'
               AND SUBSTR (chd.acctno, 1, 10) = af.acctno
               AND af.custid = cf.custid
               AND AF.ACTYPE NOT IN ('0000')
               AND chd.duetype IN ('SM', 'RM')
               AND SUBSTR (cf.custodycd, 4, 1) = 'F'
               AND chd.txdate = TO_DATE (i_date, 'DD/MM/YYYY')
               AND cf.custodycd LIKE '%'
               AND sb.codeid = chd.codeid
               AND AF.ACTYPE        =  AFT.ACTYPE
               AND AFT.COREBANK     LIKE '%'
               AND AF.BANKNAME      LIKE '%'
               AND AF.ACCTNO        = AFB.ACCTNO
---               AND (substr(af.acctno,1,4) like V_p_STRBRID or instr((V_pV_STRBRID),substr(af.acctno,1,4)) <> 0 )
               AND (af.brid like V_p_STRBRID or instr(V_pV_STRBRID,af.brid) <> 0 )
               and (af.brid like V_STRBRID or INSTR(V_STRBRID,af.brid) <> 0)
               and chd.orgorderid = od.orderid
               AND od.clearday = TO_NUMBER(DATE_T)
               AND (CASE WHEN V_STRCLEARDAY = 9 OR OD.EXECTYPE IN('NS','SS','MS') THEN V_STRCLEARDAY
                ELSE (CASE WHEN OD.T_CLEARDAY = OD.TXDATE
                THEN 0 ELSE 2 END ) END) = V_STRCLEARDAY
          GROUP BY AFB.BANKNAME, OD.T_CLEARDAY
          )
GROUP BY BANKNAME,T_CLEARDAY

UNION ALL

SELECT SUM (d_bamt) d_bamt, SUM (d_samt) d_samt, SUM (bd_bamt) bd_bamt,
         SUM (bd_samt) bd_samt, SUM (bf_bamt) bf_bamt, SUM (bf_samt) bf_samt,
         T_CLEARDAY, BANKNAME
FROM (
              SELECT
                   SUM (DECODE (chd.duetype, 'SM', chd.amt , 0)) d_bamt,
                   SUM (DECODE (chd.duetype, 'RM', chd.amt , 0)) d_samt,
                   0 bd_bamt, 0 bd_samt, 0 bf_bamt, 0 bf_samt, AFB.BANKNAME, OD.T_CLEARDAY
              FROM stschdhist chd, afmast af, (SELECT * FROM CFMAST WHERE FNC_VALIDATE_SCOPE(BRID, CAREBY, TLSCOPE, pv_BRID, TLGOUPS)=0) cf, AFTYPE AFT,
                   (SELECT AF.ACCTNO, (CASE WHEN AFT.COREBANK = 'N' THEN cspks_system.fn_get_sysvar('SYSTEM','COMPANYSHORTNAME') ELSE AF.BANKNAME END) BANKNAME
                    FROM AFMAST AF, AFTYPE AFT
                    WHERE AF.ACTYPE = AFT.ACTYPE) AFB,
                   (SELECT * FROM sbsecurities
                     WHERE  SECTYPE LIKE V_SECTYPE AND SECTYPE IN ('001','006','008','011')) sb, --Ngay 23/03/2017 CW NamTv them sectype 011
                   (
                    SELECT OD.*, STS.CLEARDATE T_CLEARDAY
                    FROM
                        (
                          SELECT * from vw_odmast_tradeplace_all where txdate = TO_DATE (i_date, 'DD/MM/YYYY')
                          and (tradeplace LIKE v_strtradeplace or (case when tradeplace = '001' or tradeplace = '002' then '999' else '888'
                          end ) like v_strtradeplace) AND tradeplace IN ('001','002','005')

                        )OD,
                    (SELECT * FROM STSCHD UNION ALL SELECT * FROM STSCHDHIST) STS
                    WHERE   OD.ORDERID = STS.ORGORDERID(+)
                        AND STS.DELTD <> 'Y'
                        AND nvl(STS.DUETYPE ,(CASE WHEN OD.EXECTYPE IN('NB','BC') THEN 'SM' ELSE 'RM' END)) =
                                    (CASE WHEN OD.EXECTYPE IN('NB','BC') THEN 'SM' ELSE 'RM' END)
                ) OD
             WHERE chd.deltd <> 'Y'
               AND SUBSTR (chd.acctno, 1, 10) = af.acctno
               AND af.custid = cf.custid
               AND AF.ACTYPE NOT IN ('0000')
               AND SUBSTR (cf.custodycd, 4, 1) = 'P'
               AND chd.duetype IN ('SM', 'RM')
               AND chd.txdate = TO_DATE (i_date, 'DD/MM/YYYY')
               AND cf.custodycd LIKE '%'
               AND sb.codeid = chd.codeid
               AND AF.ACTYPE        =  AFT.ACTYPE
               AND AFT.COREBANK     LIKE '%'
               AND AF.BANKNAME      LIKE '%'
               AND AF.ACCTNO        = AFB.ACCTNO
               and chd.orgorderid = od.orderid
               --AND (substr(af.acctno,1,4) like V_p_STRBRID or instr((V_pV_STRBRID),substr(af.acctno,1,4)) <> 0)
               AND (af.brid like V_p_STRBRID or instr(V_pV_STRBRID,af.brid) <> 0 )
               and (af.brid like V_STRBRID or INSTR(V_STRBRID,af.brid) <> 0)
               AND od.clearday = TO_NUMBER(DATE_T)
               AND (CASE WHEN V_STRCLEARDAY = 9 OR OD.EXECTYPE IN('NS','SS','MS') THEN V_STRCLEARDAY
                ELSE (CASE WHEN OD.T_CLEARDAY = OD.TXDATE
                THEN 0 ELSE 2 END ) END) = V_STRCLEARDAY
               GROUP BY AFB.BANKNAME, OD.T_CLEARDAY
          UNION ALL
              SELECT 0 d_bamt, 0 d_samt,
                   SUM (DECODE (chd.duetype,'SM', chd.amt ,0)) bd_bamt,
                   SUM (DECODE (chd.duetype, 'RM', chd.amt , 0)) bd_samt, 0 bf_bamt, 0 bf_samt, AFB.BANKNAME, OD.T_CLEARDAY
              FROM stschdhist chd, afmast af, (SELECT * FROM CFMAST WHERE FNC_VALIDATE_SCOPE(BRID, CAREBY, TLSCOPE, pv_BRID, TLGOUPS)=0) cf, AFTYPE AFT,
                   (SELECT AF.ACCTNO, (CASE WHEN AFT.COREBANK = 'N' THEN cspks_system.fn_get_sysvar('SYSTEM','COMPANYSHORTNAME') ELSE AF.BANKNAME END) BANKNAME
                    FROM AFMAST AF, AFTYPE AFT WHERE AF.ACTYPE = AFT.ACTYPE) AFB,
                   (SELECT * FROM sbsecurities
                     WHERE  SECTYPE LIKE V_SECTYPE AND SECTYPE IN ('001','006','008','011')) sb, --Ngay 23/03/2017 CW NamTv them sectype 011
                    (
                    SELECT OD.*, STS.CLEARDATE T_CLEARDAY
                    FROM
                        (
                        SELECT * from vw_odmast_tradeplace_all where txdate = TO_DATE (i_date, 'DD/MM/YYYY')
                          and (tradeplace LIKE v_strtradeplace or (case when tradeplace = '001' or tradeplace = '002' then '999' else '888'
                          end ) like v_strtradeplace) AND tradeplace IN ('001','002','005')

                        )OD,
                    (SELECT * FROM STSCHD UNION ALL SELECT * FROM STSCHDHIST) STS
                    WHERE   OD.ORDERID = STS.ORGORDERID(+)
                        AND STS.DELTD <> 'Y'
                        AND nvl(STS.DUETYPE ,(CASE WHEN OD.EXECTYPE IN('NB','BC') THEN 'SM' ELSE 'RM' END)) =
                                    (CASE WHEN OD.EXECTYPE IN('NB','BC') THEN 'SM' ELSE 'RM' END)
                ) OD
             WHERE chd.deltd <> 'Y'
               AND SUBSTR (chd.acctno, 1, 10) = af.acctno
               AND af.custid = cf.custid
               AND AF.ACTYPE NOT IN ('0000')
               AND SUBSTR (cf.custodycd, 4, 1) = 'C'
               AND chd.duetype IN ('SM', 'RM')
               AND chd.txdate = TO_DATE (i_date, 'DD/MM/YYYY')
               AND cf.custodycd LIKE '%'
               AND sb.codeid = chd.codeid
               AND AF.ACTYPE        =  AFT.ACTYPE
               AND AFT.COREBANK     LIKE '%'
               AND AF.BANKNAME      LIKE '%'
               AND AF.ACCTNO        = AFB.ACCTNO
               and chd.orgorderid = od.orderid
               ---AND (substr(af.acctno,1,4) like V_p_STRBRID or instr((V_pV_STRBRID),substr(af.acctno,1,4)) <> 0)
               AND (af.brid like V_p_STRBRID or instr(V_pV_STRBRID,af.brid) <> 0 )
               and (af.brid like V_STRBRID or INSTR(V_STRBRID,af.brid) <> 0)
               AND od.clearday = TO_NUMBER(DATE_T)
               AND (CASE WHEN V_STRCLEARDAY = 9 OR OD.EXECTYPE IN('NS','SS','MS') THEN V_STRCLEARDAY
                ELSE (CASE WHEN OD.T_CLEARDAY = OD.TXDATE
                THEN 0 ELSE 2 END ) END) = V_STRCLEARDAY
          GROUP BY AFB.BANKNAME, OD.T_CLEARDAY
          UNION ALL
               SELECT 0 d_bamt, 0 d_samt, 0 bd_bamt, 0 bd_samt,
                   SUM (DECODE (chd.duetype,'SM', chd.amt ,0)) bf_bamt,
                   SUM (DECODE (chd.duetype,'RM', chd.amt ,0)) bf_samt, AFB.BANKNAME, OD.T_CLEARDAY
              FROM stschdhist chd, afmast af, (SELECT * FROM CFMAST WHERE FNC_VALIDATE_SCOPE(BRID, CAREBY, TLSCOPE, pv_BRID, TLGOUPS)=0) cf, AFTYPE AFT,
                   (SELECT AF.ACCTNO, (CASE WHEN AFT.COREBANK = 'N' THEN cspks_system.fn_get_sysvar('SYSTEM','COMPANYSHORTNAME') ELSE AF.BANKNAME END) BANKNAME
                    FROM AFMAST AF, AFTYPE AFT WHERE AF.ACTYPE = AFT.ACTYPE) AFB,
                   (SELECT * FROM sbsecurities
                     WHERE  SECTYPE LIKE V_SECTYPE AND SECTYPE IN ('001','006','008','011')) sb, --Ngay 23/03/2017 CW NamTv them sectype 011
                   (
                    SELECT OD.*, STS.CLEARDATE T_CLEARDAY
                    FROM
                        (
                     SELECT * from vw_odmast_tradeplace_all where txdate = TO_DATE (i_date, 'DD/MM/YYYY')
                          and (tradeplace LIKE v_strtradeplace or (case when tradeplace = '001' or tradeplace = '002' then '999' else '888'
                          end ) like v_strtradeplace) AND tradeplace IN ('001','002','005')

                        )OD,
                    (SELECT * FROM STSCHD UNION ALL SELECT * FROM STSCHDHIST) STS
                    WHERE   OD.ORDERID = STS.ORGORDERID(+)
                        AND STS.DELTD <> 'Y'
                        AND nvl(STS.DUETYPE ,(CASE WHEN OD.EXECTYPE IN('NB','BC') THEN 'SM' ELSE 'RM' END)) =
                                    (CASE WHEN OD.EXECTYPE IN('NB','BC') THEN 'SM' ELSE 'RM' END)
                ) OD
             WHERE chd.deltd <> 'Y'
               AND SUBSTR (chd.acctno, 1, 10) = af.acctno
               AND af.custid = cf.custid
               AND AF.ACTYPE NOT IN ('0000')
               AND chd.duetype IN ('SM', 'RM')
               AND SUBSTR (cf.custodycd, 4, 1) = 'F'
               AND chd.txdate = TO_DATE (i_date, 'DD/MM/YYYY')
               AND cf.custodycd LIKE '%'
               AND sb.codeid = chd.codeid
               AND AF.ACTYPE =  AFT.ACTYPE
               AND AFT.COREBANK LIKE '%'
               AND AF.BANKNAME LIKE '%'
               AND AF.ACCTNO = AFB.ACCTNO
               and chd.orgorderid = od.orderid
               ---AND (substr(af.acctno,1,4) like V_p_STRBRID or instr((V_pV_STRBRID),substr(af.acctno,1,4)) <> 0)
               AND (af.brid like V_p_STRBRID or instr(V_pV_STRBRID,af.brid) <> 0 )
               and (af.brid like V_STRBRID or INSTR(V_STRBRID,af.brid) <> 0)
               AND od.clearday = TO_NUMBER(DATE_T)
               AND (CASE WHEN V_STRCLEARDAY = 9 OR OD.EXECTYPE IN('NS','SS','MS') THEN V_STRCLEARDAY
                ELSE (CASE WHEN OD.T_CLEARDAY = OD.TXDATE
                THEN 0 ELSE 2 END ) END) = V_STRCLEARDAY
          GROUP BY AFB.BANKNAME, OD.T_CLEARDAY
         )
GROUP BY BANKNAME,T_CLEARDAY
)
GROUP BY BANKNAME,T_CLEARDAY


;
ELSIF (CASHPLACE = '000') THEN
OPEN PV_REFCURSOR
FOR
select SUM (nvl(d_bamt,0)) d_bamt, SUM (nvl(d_samt,0)) d_samt, SUM (nvl(bd_bamt,0)) bd_bamt,
         SUM (nvl(bd_samt,0)) bd_samt, SUM (nvl(bf_bamt,0)) bf_bamt, SUM (nvl(bf_samt,0)) bf_samt,
         T_CLEARDAY, BANKNAME, TRAN_DATE TRAN_DATE
from
(
SELECT
         SUM (d_bamt) d_bamt, SUM (d_samt) d_samt, SUM (bd_bamt) bd_bamt,
         SUM (bd_samt) bd_samt, SUM (bf_bamt) bf_bamt, SUM (bf_samt) bf_samt,
         T_CLEARDAY, BANKNAME
FROM     (
              SELECT
                   SUM (DECODE (chd.duetype, 'SM', chd.amt , 0)) d_bamt,
                   SUM (DECODE (chd.duetype, 'RM', chd.amt , 0)) d_samt,
                   0 bd_bamt, 0 bd_samt, 0 bf_bamt, 0 bf_samt,AFB.BANKNAME, OD.T_CLEARDAY
              FROM stschd chd, afmast af,(SELECT * FROM CFMAST WHERE FNC_VALIDATE_SCOPE(BRID, CAREBY, TLSCOPE, pv_BRID, TLGOUPS)=0) cf,AFTYPE AFT,
                   (SELECT AF.ACCTNO, (CASE WHEN AFT.COREBANK = 'N' THEN cspks_system.fn_get_sysvar('SYSTEM','COMPANYSHORTNAME') ELSE AF.BANKNAME END) BANKNAME
                    FROM AFMAST AF, AFTYPE AFT
                    WHERE AF.ACTYPE = AFT.ACTYPE) AFB,
                   (SELECT *
                    FROM sbsecurities
                     WHERE  SECTYPE LIKE V_SECTYPE AND SECTYPE IN ('001','006','008','011')) sb, --Ngay 23/03/2017 CW NamTv them sectype 011
                    (
                    SELECT OD.*, STS.CLEARDATE T_CLEARDAY
                    FROM
                        (
                        SELECT * from vw_odmast_tradeplace_all where txdate = TO_DATE (i_date, 'DD/MM/YYYY')
                          and (tradeplace LIKE v_strtradeplace or (case when tradeplace = '001' or tradeplace = '002' then '999' else '888'
                          end ) like v_strtradeplace) AND tradeplace IN ('001','002','005')

                        )OD,
                    (SELECT * FROM STSCHD UNION ALL SELECT * FROM STSCHDHIST) STS
                    WHERE   OD.ORDERID = STS.ORGORDERID(+)
                        AND STS.DELTD <> 'Y'
                        AND nvl(STS.DUETYPE ,(CASE WHEN OD.EXECTYPE IN('NB','BC') THEN 'SM' ELSE 'RM' END)) =
                                    (CASE WHEN OD.EXECTYPE IN('NB','BC') THEN 'SM' ELSE 'RM' END)
                ) OD
             WHERE chd.deltd <> 'Y'
               AND SUBSTR (chd.acctno, 1, 10) = af.acctno
               AND af.custid = cf.custid
               AND AF.ACTYPE NOT IN ('0000')
               AND SUBSTR (cf.custodycd, 4, 1) = 'P'
               AND chd.duetype IN ('SM', 'RM')
               AND chd.txdate = TO_DATE (i_date, 'DD/MM/YYYY')
               AND cf.custodycd LIKE '%'
               AND sb.codeid = chd.codeid
               and chd.orgorderid = od.orderid
               AND od.clearday = TO_NUMBER(DATE_T)
               AND AF.ACTYPE        =  AFT.ACTYPE
               AND AFT.COREBANK     LIKE 'N'
               AND AF.BANKNAME      LIKE '%'
               ----AND (substr(af.acctno,1,4) like V_p_STRBRID or instr((V_pV_STRBRID),substr(af.acctno,1,4)) <> 0)
               AND (af.brid like V_p_STRBRID or instr(V_pV_STRBRID,af.brid) <> 0 )
               and (af.brid like V_STRBRID or INSTR(V_STRBRID,af.brid) <> 0)
               AND AF.ACCTNO        = AFB.ACCTNO
               AND (CASE WHEN V_STRCLEARDAY = 9 OR OD.EXECTYPE IN('NS','SS','MS') THEN V_STRCLEARDAY
                ELSE (CASE WHEN OD.T_CLEARDAY = OD.TXDATE
                THEN 0 ELSE 2 END ) END) = V_STRCLEARDAY
          GROUP BY AFB.BANKNAME, OD.T_CLEARDAY

          UNION ALL

              SELECT
                   0 d_bamt, 0 d_samt,
                   SUM (DECODE (chd.duetype,
                                'SM', chd.amt ,
                                0
                               )) bd_bamt,
                   SUM (DECODE (chd.duetype,
                                'RM', chd.amt ,
                                0
                               )) bd_samt, 0 bf_bamt, 0 bf_samt,
                               AFB.BANKNAME, OD.T_CLEARDAY
              FROM stschd chd,
                   afmast af,
                   (SELECT * FROM CFMAST WHERE FNC_VALIDATE_SCOPE(BRID, CAREBY, TLSCOPE, pv_BRID, TLGOUPS)=0) cf,
                   AFTYPE AFT,
                   (SELECT AF.ACCTNO, (CASE WHEN AFT.COREBANK = 'N' THEN cspks_system.fn_get_sysvar('SYSTEM','COMPANYSHORTNAME') ELSE AF.BANKNAME END) BANKNAME
                    FROM AFMAST AF, AFTYPE AFT
                    WHERE AF.ACTYPE = AFT.ACTYPE) AFB,

                   (SELECT *
                      FROM sbsecurities
                     WHERE  SECTYPE LIKE V_SECTYPE AND SECTYPE IN ('001','006','008','011')) sb, --Ngay 23/03/2017 CW NamTv them sectype 011
                     (
                    SELECT OD.*, STS.CLEARDATE T_CLEARDAY
                    FROM
                        (
                            SELECT * from vw_odmast_tradeplace_all where txdate = TO_DATE (i_date, 'DD/MM/YYYY')
                          and (tradeplace LIKE v_strtradeplace or (case when tradeplace = '001' or tradeplace = '002' then '999' else '888'
                          end ) like v_strtradeplace) AND tradeplace IN ('001','002','005')

                        )OD,
                    (SELECT * FROM STSCHD UNION ALL SELECT * FROM STSCHDHIST) STS
                    WHERE   OD.ORDERID = STS.ORGORDERID(+)
                        AND STS.DELTD <> 'Y'
                        AND nvl(STS.DUETYPE ,(CASE WHEN OD.EXECTYPE IN('NB','BC') THEN 'SM' ELSE 'RM' END)) =
                                    (CASE WHEN OD.EXECTYPE IN('NB','BC') THEN 'SM' ELSE 'RM' END)
                ) OD
             WHERE chd.deltd <> 'Y'
               AND SUBSTR (chd.acctno, 1, 10) = af.acctno
               AND af.custid = cf.custid
               AND AF.ACTYPE NOT IN ('0000')
               AND SUBSTR (cf.custodycd, 4, 1) = 'C'
               AND chd.duetype IN ('SM', 'RM')
               AND chd.txdate = TO_DATE (i_date, 'DD/MM/YYYY')
               AND cf.custodycd LIKE '%'
               AND sb.codeid = chd.codeid
               AND AF.ACTYPE        =  AFT.ACTYPE
               AND AFT.COREBANK     LIKE 'N'
               AND AF.BANKNAME      LIKE '%'
               ----AND (substr(af.acctno,1,4) like V_p_STRBRID or instr((V_pV_STRBRID),substr(af.acctno,1,4)) <> 0)
               AND (af.brid like V_p_STRBRID or instr(V_pV_STRBRID,af.brid) <> 0 )
               and (af.brid like V_STRBRID or INSTR(V_STRBRID,af.brid) <> 0)
               AND AF.ACCTNO        = AFB.ACCTNO
          AND chd.orgorderid = od.orderid
               AND od.clearday = TO_NUMBER(DATE_T)
               AND (CASE WHEN V_STRCLEARDAY = 9 OR OD.EXECTYPE IN('NS','SS','MS') THEN V_STRCLEARDAY
                ELSE (CASE WHEN OD.T_CLEARDAY = OD.TXDATE
                THEN 0 ELSE 2 END ) END) = V_STRCLEARDAY
          GROUP BY AFB.BANKNAME, OD.T_CLEARDAY
          UNION ALL
              SELECT
                   0 d_bamt, 0 d_samt,
                   0 bd_bamt, 0 bd_samt,
                   SUM (DECODE (chd.duetype,
                                'SM', chd.amt ,
                                0
                               )) bf_bamt,
                   SUM (DECODE (chd.duetype,
                                'RM', chd.amt ,
                                0
                               )) bf_samt, AFB.BANKNAME, OD.T_CLEARDAY
              FROM stschd chd,
                   afmast af,
                   (SELECT * FROM CFMAST WHERE FNC_VALIDATE_SCOPE(BRID, CAREBY, TLSCOPE, pv_BRID, TLGOUPS)=0) cf,
                   AFTYPE AFT,

                   (SELECT AF.ACCTNO, (CASE WHEN AFT.COREBANK = 'N' THEN cspks_system.fn_get_sysvar('SYSTEM','COMPANYSHORTNAME') ELSE AF.BANKNAME END) BANKNAME
                    FROM AFMAST AF, AFTYPE AFT
                    WHERE AF.ACTYPE = AFT.ACTYPE) AFB,

                   (SELECT *
                      FROM sbsecurities
                     WHERE  SECTYPE LIKE V_SECTYPE AND SECTYPE IN ('001','006','008','011')) sb, --Ngay 23/03/2017 CW NamTv them sectype 011
                     (
                    SELECT OD.*, STS.CLEARDATE T_CLEARDAY
                    FROM
                        (
                        SELECT * from vw_odmast_tradeplace_all where txdate = TO_DATE (i_date, 'DD/MM/YYYY')
                          and (tradeplace LIKE v_strtradeplace or (case when tradeplace = '001' or tradeplace = '002' then '999' else '888'
                          end ) like v_strtradeplace) AND tradeplace IN ('001','002','005')

                        )OD,
                    (SELECT * FROM STSCHD UNION ALL SELECT * FROM STSCHDHIST) STS
                    WHERE   OD.ORDERID = STS.ORGORDERID(+)
                        AND STS.DELTD <> 'Y'
                        AND nvl(STS.DUETYPE ,(CASE WHEN OD.EXECTYPE IN('NB','BC') THEN 'SM' ELSE 'RM' END)) =
                                    (CASE WHEN OD.EXECTYPE IN('NB','BC') THEN 'SM' ELSE 'RM' END)
                ) OD
              WHERE chd.deltd <> 'Y'
               AND SUBSTR (chd.acctno, 1, 10) = af.acctno
               AND af.custid = cf.custid
               AND AF.ACTYPE NOT IN ('0000')
               AND chd.duetype IN ('SM', 'RM')
               AND SUBSTR (cf.custodycd, 4, 1) = 'F'
               AND chd.txdate = TO_DATE (i_date, 'DD/MM/YYYY')
               AND cf.custodycd LIKE '%'
               AND sb.codeid = chd.codeid
               AND AF.ACTYPE        =  AFT.ACTYPE
               AND AFT.COREBANK     LIKE 'N'
               AND AF.BANKNAME      LIKE '%'
               ---AND (substr(af.acctno,1,4) like V_p_STRBRID or instr((V_pV_STRBRID),substr(af.acctno,1,4)) <> 0)
               AND (af.brid like V_p_STRBRID or instr(V_pV_STRBRID,af.brid) <> 0 )
               and (af.brid like V_STRBRID or INSTR(V_STRBRID,af.brid) <> 0)
               AND chd.orgorderid = od.orderid
               AND od.clearday = TO_NUMBER(DATE_T)
               AND AF.ACCTNO        = AFB.ACCTNO
               AND (CASE WHEN V_STRCLEARDAY = 9 OR OD.EXECTYPE IN('NS','SS','MS') THEN V_STRCLEARDAY
                ELSE (CASE WHEN OD.T_CLEARDAY = OD.TXDATE
                THEN 0 ELSE 2 END ) END) = V_STRCLEARDAY
          GROUP BY AFB.BANKNAME, OD.T_CLEARDAY
          )

GROUP BY BANKNAME,T_CLEARDAY

UNION ALL

SELECT
         SUM (d_bamt) d_bamt, SUM (d_samt) d_samt, SUM (bd_bamt) bd_bamt,
         SUM (bd_samt) bd_samt, SUM (bf_bamt) bf_bamt, SUM (bf_samt) bf_samt,
         T_CLEARDAY, BANKNAME

FROM     (
              SELECT
                   SUM (DECODE (chd.duetype, 'SM', chd.amt , 0)) d_bamt,
                   SUM (DECODE (chd.duetype, 'RM', chd.amt , 0)) d_samt,
                   0 bd_bamt, 0 bd_samt, 0 bf_bamt, 0 bf_samt, AFB.BANKNAME, OD.T_CLEARDAY
              FROM stschdhist chd,
                   afmast af,
                   (SELECT * FROM CFMAST WHERE FNC_VALIDATE_SCOPE(BRID, CAREBY, TLSCOPE, pv_BRID, TLGOUPS)=0) cf,
                   AFTYPE AFT,

                   (SELECT AF.ACCTNO, (CASE WHEN AFT.COREBANK = 'N' THEN cspks_system.fn_get_sysvar('SYSTEM','COMPANYSHORTNAME') ELSE AF.BANKNAME END) BANKNAME
                    FROM AFMAST AF, AFTYPE AFT
                    WHERE AF.ACTYPE = AFT.ACTYPE) AFB,

                   (SELECT *
                      FROM sbsecurities
                     WHERE  SECTYPE LIKE V_SECTYPE AND SECTYPE IN ('001','006','008','011')) sb, --Ngay 23/03/2017 CW NamTv them sectype 011
                     (
                    SELECT OD.*, STS.CLEARDATE T_CLEARDAY
                    FROM
                        (
                     SELECT * from vw_odmast_tradeplace_all where txdate = TO_DATE (i_date, 'DD/MM/YYYY')
                          and (tradeplace LIKE v_strtradeplace or (case when tradeplace = '001' or tradeplace = '002' then '999' else '888'
                          end ) like v_strtradeplace) AND tradeplace IN ('001','002','005')

                        )OD,
                    (SELECT * FROM STSCHD UNION ALL SELECT * FROM STSCHDHIST) STS
                    WHERE   OD.ORDERID = STS.ORGORDERID(+)
                        AND STS.DELTD <> 'Y'
                        AND nvl(STS.DUETYPE ,(CASE WHEN OD.EXECTYPE IN('NB','BC') THEN 'SM' ELSE 'RM' END)) =
                                    (CASE WHEN OD.EXECTYPE IN('NB','BC') THEN 'SM' ELSE 'RM' END)
                ) OD
             WHERE chd.deltd <> 'Y'
               AND SUBSTR (chd.acctno, 1, 10) = af.acctno
               AND af.custid = cf.custid
               AND AF.ACTYPE NOT IN ('0000')
               AND SUBSTR (cf.custodycd, 4, 1) = 'P'
               AND chd.duetype IN ('SM', 'RM')
               AND chd.txdate = TO_DATE (i_date, 'DD/MM/YYYY')
               AND cf.custodycd LIKE '%'
               AND sb.codeid = chd.codeid
               AND AF.ACTYPE        =  AFT.ACTYPE
               AND AFT.COREBANK     LIKE 'N'
               AND AF.BANKNAME      LIKE '%'
               ---AND (substr(af.acctno,1,4) like V_p_STRBRID or instr((V_pV_STRBRID),substr(af.acctno,1,4)) <> 0)
               AND (af.brid like V_p_STRBRID or instr(V_pV_STRBRID,af.brid) <> 0 )
               and (af.brid like V_STRBRID or INSTR(V_STRBRID,af.brid) <> 0)
               AND AF.ACCTNO        = AFB.ACCTNO
               AND chd.orgorderid = od.orderid
               AND od.clearday = TO_NUMBER(DATE_T)
               AND (CASE WHEN V_STRCLEARDAY = 9 OR OD.EXECTYPE IN('NS','SS','MS') THEN V_STRCLEARDAY
                ELSE (CASE WHEN OD.T_CLEARDAY = OD.TXDATE
                THEN 0 ELSE 2 END ) END) = V_STRCLEARDAY
               GROUP BY AFB.BANKNAME, OD.T_CLEARDAY

          UNION ALL
              SELECT
                   0 d_bamt, 0 d_samt,
                   SUM (DECODE (chd.duetype,
                                'SM', chd.amt ,
                                0
                               )) bd_bamt,
                   SUM (DECODE (chd.duetype,
                                'RM', chd.amt ,
                                0
                               )) bd_samt, 0 bf_bamt, 0 bf_samt, AFB.BANKNAME, OD.T_CLEARDAY
              FROM stschdhist chd,
                   afmast af,
                   (SELECT * FROM CFMAST WHERE FNC_VALIDATE_SCOPE(BRID, CAREBY, TLSCOPE, pv_BRID, TLGOUPS)=0) cf,
                   AFTYPE AFT,

                   (SELECT AF.ACCTNO, (CASE WHEN AFT.COREBANK = 'N' THEN cspks_system.fn_get_sysvar('SYSTEM','COMPANYSHORTNAME') ELSE AF.BANKNAME END) BANKNAME
                    FROM AFMAST AF, AFTYPE AFT
                    WHERE AF.ACTYPE = AFT.ACTYPE) AFB,

                   (SELECT *
                      FROM sbsecurities
                     WHERE  SECTYPE LIKE V_SECTYPE AND SECTYPE IN ('001','006','008','011')) sb, --Ngay 23/03/2017 CW NamTv them sectype 011
                     (
                    SELECT OD.*, STS.CLEARDATE T_CLEARDAY
                    FROM
                        (
                         SELECT * from vw_odmast_tradeplace_all where txdate = TO_DATE (i_date, 'DD/MM/YYYY')
                          and (tradeplace LIKE v_strtradeplace or (case when tradeplace = '001' or tradeplace = '002' then '999' else '888'
                          end ) like v_strtradeplace) AND tradeplace IN ('001','002','005')

                        )OD,
                    (SELECT * FROM STSCHD UNION ALL SELECT * FROM STSCHDHIST) STS
                    WHERE   OD.ORDERID = STS.ORGORDERID(+)
                        AND STS.DELTD <> 'Y'
                        AND nvl(STS.DUETYPE ,(CASE WHEN OD.EXECTYPE IN('NB','BC') THEN 'SM' ELSE 'RM' END)) =
                                    (CASE WHEN OD.EXECTYPE IN('NB','BC') THEN 'SM' ELSE 'RM' END)
                ) OD
             WHERE chd.deltd <> 'Y'
               AND SUBSTR (chd.acctno, 1, 10) = af.acctno
               AND af.custid = cf.custid
               AND AF.ACTYPE NOT IN ('0000')
               AND SUBSTR (cf.custodycd, 4, 1) = 'C'
               AND chd.duetype IN ('SM', 'RM')
               AND chd.txdate = TO_DATE (i_date, 'DD/MM/YYYY')
               AND cf.custodycd LIKE '%'
               AND sb.codeid = chd.codeid
               ----AND (substr(af.acctno,1,4) like V_p_STRBRID or instr((V_pV_STRBRID),substr(af.acctno,1,4)) <> 0)
               AND (af.brid like V_p_STRBRID or instr(V_pV_STRBRID,af.brid) <> 0 )
               and (af.brid like V_STRBRID or INSTR(V_STRBRID,af.brid) <> 0)
               AND AF.ACTYPE        =  AFT.ACTYPE
               AND AFT.COREBANK     LIKE 'N'
               AND AF.BANKNAME      LIKE '%'
               AND AF.ACCTNO        = AFB.ACCTNO
            AND chd.orgorderid = od.orderid
               AND od.clearday = TO_NUMBER(DATE_T)
               AND (CASE WHEN V_STRCLEARDAY = 9 OR OD.EXECTYPE IN('NS','SS','MS') THEN V_STRCLEARDAY
                ELSE (CASE WHEN OD.T_CLEARDAY = OD.TXDATE
                THEN 0 ELSE 2 END ) END) = V_STRCLEARDAY
          GROUP BY AFB.BANKNAME, OD.T_CLEARDAY


          UNION ALL
               SELECT
                   0 d_bamt, 0 d_samt, 0 bd_bamt, 0 bd_samt,
                   SUM (DECODE (chd.duetype,
                                'SM', chd.amt ,
                                0
                               )) bf_bamt,
                   SUM (DECODE (chd.duetype,
                                'RM', chd.amt ,
                                0
                               )) bf_samt, AFB.BANKNAME, OD.T_CLEARDAY
              FROM stschdhist chd,
                   afmast af,
                   (SELECT * FROM CFMAST WHERE FNC_VALIDATE_SCOPE(BRID, CAREBY, TLSCOPE, pv_BRID, TLGOUPS)=0) cf,
                   AFTYPE AFT,

                   (SELECT AF.ACCTNO, (CASE WHEN AFT.COREBANK = 'N' THEN cspks_system.fn_get_sysvar('SYSTEM','COMPANYSHORTNAME') ELSE AF.BANKNAME END) BANKNAME
                    FROM AFMAST AF, AFTYPE AFT
                    WHERE AF.ACTYPE = AFT.ACTYPE) AFB,
                   (SELECT *
                      FROM sbsecurities
                     WHERE  SECTYPE LIKE V_SECTYPE AND SECTYPE IN ('001','006','008','011')) sb, --Ngay 23/03/2017 CW NamTv them sectype 011
                     (
                    SELECT OD.*, STS.CLEARDATE T_CLEARDAY
                    FROM
                        (
                           SELECT * from vw_odmast_tradeplace_all where txdate = TO_DATE (i_date, 'DD/MM/YYYY')
                          and (tradeplace LIKE v_strtradeplace or (case when tradeplace = '001' or tradeplace = '002' then '999' else '888'
                          end ) like v_strtradeplace) AND tradeplace IN ('001','002','005')
                        )OD,
                    (SELECT * FROM STSCHD UNION ALL SELECT * FROM STSCHDHIST) STS
                    WHERE   OD.ORDERID = STS.ORGORDERID(+)
                        AND STS.DELTD <> 'Y'
                        AND nvl(STS.DUETYPE ,(CASE WHEN OD.EXECTYPE IN('NB','BC') THEN 'SM' ELSE 'RM' END)) =
                                    (CASE WHEN OD.EXECTYPE IN('NB','BC') THEN 'SM' ELSE 'RM' END)
                ) OD
             WHERE chd.deltd <> 'Y'
               AND SUBSTR (chd.acctno, 1, 10) = af.acctno
               AND af.custid = cf.custid
               AND AF.ACTYPE NOT IN ('0000')
               AND chd.duetype IN ('SM', 'RM')
               AND SUBSTR (cf.custodycd, 4, 1) = 'F'
               AND chd.txdate = TO_DATE (i_date, 'DD/MM/YYYY')
               AND cf.custodycd LIKE '%'
               AND sb.codeid = chd.codeid
               AND AF.ACTYPE        =  AFT.ACTYPE
               AND AFT.COREBANK     LIKE 'N'
               ----AND (substr(af.acctno,1,4) like V_p_STRBRID or instr((V_pV_STRBRID),substr(af.acctno,1,4)) <> 0)
               AND (af.brid like V_p_STRBRID or instr(V_pV_STRBRID,af.brid) <> 0 )
               and (af.brid like V_STRBRID or INSTR(V_STRBRID,af.brid) <> 0)
               AND AF.BANKNAME      LIKE '%'
               AND AF.ACCTNO        = AFB.ACCTNO
          AND chd.orgorderid = od.orderid
               AND od.clearday = TO_NUMBER(DATE_T)
               AND (CASE WHEN V_STRCLEARDAY = 9 OR OD.EXECTYPE IN('NS','SS','MS') THEN V_STRCLEARDAY
                ELSE (CASE WHEN OD.T_CLEARDAY = OD.TXDATE
                THEN 0 ELSE 2 END ) END) = V_STRCLEARDAY
          GROUP BY AFB.BANKNAME, OD.T_CLEARDAY
         )
GROUP BY BANKNAME,T_CLEARDAY
) GROUP BY BANKNAME,T_CLEARDAY

;
ELSE
OPEN PV_REFCURSOR
FOR
SELECT
         SUM (nvl(d_bamt,0)) d_bamt, SUM (nvl(d_samt,0)) d_samt, SUM (nvl(bd_bamt,0)) bd_bamt,
         SUM (nvl(bd_samt,0)) bd_samt, SUM (nvl(bf_bamt,0)) bf_bamt, SUM (nvl(bf_samt,0)) bf_samt,
         T_CLEARDAY, BANKNAME, TRAN_DATE TRAN_DATE
from
(
SELECT
         SUM (d_bamt) d_bamt, SUM (d_samt) d_samt, SUM (bd_bamt) bd_bamt,
         SUM (bd_samt) bd_samt, SUM (bf_bamt) bf_bamt, SUM (bf_samt) bf_samt,
         T_CLEARDAY, BANKNAME
FROM     (
              SELECT
                   SUM (DECODE (chd.duetype, 'SM', chd.amt , 0)) d_bamt,
                   SUM (DECODE (chd.duetype, 'RM', chd.amt , 0)) d_samt,
                   0 bd_bamt, 0 bd_samt, 0 bf_bamt, 0 bf_samt,
                   AFB.BANKNAME, OD.T_CLEARDAY

              FROM stschd chd,
                   afmast af,
                   (SELECT * FROM CFMAST WHERE FNC_VALIDATE_SCOPE(BRID, CAREBY, TLSCOPE, pv_BRID, TLGOUPS)=0) cf,
                   AFTYPE AFT,

                   (SELECT AF.ACCTNO, (CASE WHEN AFT.COREBANK = 'N' THEN cspks_system.fn_get_sysvar('SYSTEM','COMPANYSHORTNAME') ELSE AF.BANKNAME END) BANKNAME
                    FROM AFMAST AF, AFTYPE AFT
                    WHERE AF.ACTYPE = AFT.ACTYPE) AFB,

                   (SELECT *
                    FROM sbsecurities
                     WHERE SECTYPE LIKE V_SECTYPE AND SECTYPE IN ('001','006','008','011')) sb, --Ngay 23/03/2017 CW NamTv them sectype 011
                   (
                    SELECT OD.*, STS.CLEARDATE T_CLEARDAY
                    FROM
                        (
                         SELECT * from vw_odmast_tradeplace_all where txdate = TO_DATE (i_date, 'DD/MM/YYYY')
                          and (tradeplace LIKE v_strtradeplace or (case when tradeplace = '001' or tradeplace = '002' then '999' else '888'
                          end ) like v_strtradeplace) AND tradeplace IN ('001','002','005')                         )OD,
                    (SELECT * FROM STSCHD UNION ALL SELECT * FROM STSCHDHIST) STS
                    WHERE   OD.ORDERID = STS.ORGORDERID(+)
                        AND STS.DELTD <> 'Y'
                        AND nvl(STS.DUETYPE ,(CASE WHEN OD.EXECTYPE IN('NB','BC') THEN 'SM' ELSE 'RM' END)) =
                                    (CASE WHEN OD.EXECTYPE IN('NB','BC') THEN 'SM' ELSE 'RM' END)
                ) OD
             WHERE chd.deltd <> 'Y'
               AND SUBSTR (chd.acctno, 1, 10) = af.acctno
               AND af.custid = cf.custid
               AND AF.ACTYPE NOT IN ('0000')
               AND SUBSTR (cf.custodycd, 4, 1) = 'P'
               AND chd.duetype IN ('SM', 'RM')
               AND chd.txdate = TO_DATE (i_date, 'DD/MM/YYYY')
               AND cf.custodycd LIKE '%'
               AND sb.codeid = chd.codeid
               AND chd.orgorderid = od.orderid
               AND od.clearday = TO_NUMBER(DATE_T)
               AND AF.ACTYPE        =  AFT.ACTYPE
               AND AFT.COREBANK     LIKE 'Y'
               ----AND (substr(af.acctno,1,4) like V_p_STRBRID or instr((V_pV_STRBRID),substr(af.acctno,1,4)) <> 0 )
               AND (af.brid like V_p_STRBRID or instr(V_pV_STRBRID,af.brid) <> 0 )
               and (af.brid like V_STRBRID or INSTR(V_STRBRID,af.brid) <> 0)
               AND AF.BANKNAME      LIKE V_STRCASHPLACE
               AND AF.ACCTNO        = AFB.ACCTNO
               AND (CASE WHEN V_STRCLEARDAY = 9 OR OD.EXECTYPE IN('NS','SS','MS') THEN V_STRCLEARDAY
                ELSE (CASE WHEN OD.T_CLEARDAY = OD.TXDATE
                THEN 0 ELSE 2 END ) END) = V_STRCLEARDAY
          GROUP BY AFB.BANKNAME, OD.T_CLEARDAY
          UNION ALL
              SELECT
                   0 d_bamt, 0 d_samt,
                   SUM (DECODE (chd.duetype,
                                'SM', chd.amt ,
                                0
                               )) bd_bamt,
                   SUM (DECODE (chd.duetype,
                                'RM', chd.amt ,
                                0
                               )) bd_samt, 0 bf_bamt, 0 bf_samt,
                               AFB.BANKNAME, OD.T_CLEARDAY
              FROM stschd chd,
                   afmast af,
                   (SELECT * FROM CFMAST WHERE FNC_VALIDATE_SCOPE(BRID, CAREBY, TLSCOPE, pv_BRID, TLGOUPS)=0) cf,
                   AFTYPE AFT,

                   (SELECT AF.ACCTNO, (CASE WHEN AFT.COREBANK = 'N' THEN cspks_system.fn_get_sysvar('SYSTEM','COMPANYSHORTNAME') ELSE AF.BANKNAME END) BANKNAME
                    FROM AFMAST AF, AFTYPE AFT
                    WHERE AF.ACTYPE = AFT.ACTYPE) AFB,

                   (SELECT *
                      FROM sbsecurities
                     WHERE SECTYPE LIKE V_SECTYPE AND SECTYPE IN ('001','006','008','011')) sb, --Ngay 23/03/2017 CW NamTv them sectype 011
                     (
                    SELECT OD.*, STS.CLEARDATE T_CLEARDAY
                    FROM
                        (
                          SELECT * from vw_odmast_tradeplace_all where txdate = TO_DATE (i_date, 'DD/MM/YYYY')
                          and (tradeplace LIKE v_strtradeplace or (case when tradeplace = '001' or tradeplace = '002' then '999' else '888'
                          end ) like v_strtradeplace) AND tradeplace IN ('001','002','005')
                        )OD,
                    (SELECT * FROM STSCHD UNION ALL SELECT * FROM STSCHDHIST) STS
                    WHERE   OD.ORDERID = STS.ORGORDERID(+)
                        AND STS.DELTD <> 'Y'
                        AND nvl(STS.DUETYPE ,(CASE WHEN OD.EXECTYPE IN('NB','BC') THEN 'SM' ELSE 'RM' END)) =
                                    (CASE WHEN OD.EXECTYPE IN('NB','BC') THEN 'SM' ELSE 'RM' END)
                ) OD
             WHERE chd.deltd <> 'Y'
               AND SUBSTR (chd.acctno, 1, 10) = af.acctno
               AND af.custid = cf.custid
               AND AF.ACTYPE NOT IN ('0000')
               AND SUBSTR (cf.custodycd, 4, 1) = 'C'
               AND chd.duetype IN ('SM', 'RM')
               AND chd.txdate = TO_DATE (i_date, 'DD/MM/YYYY')
               AND cf.custodycd LIKE '%'
               AND sb.codeid = chd.codeid
               ----AND (substr(af.acctno,1,4) like V_p_STRBRID or instr((V_pV_STRBRID),substr(af.acctno,1,4)) <> 0)
               AND (af.brid like V_p_STRBRID or instr(V_pV_STRBRID,af.brid) <> 0 )
               and (af.brid like V_STRBRID or INSTR(V_STRBRID,af.brid) <> 0)
               AND AF.ACTYPE        =  AFT.ACTYPE
               AND AFT.COREBANK     LIKE 'Y'
               AND AF.BANKNAME      LIKE V_STRCASHPLACE
               AND AF.ACCTNO        = AFB.ACCTNO
               AND chd.orgorderid = od.orderid
               AND od.clearday = TO_NUMBER(DATE_T)
               AND (CASE WHEN V_STRCLEARDAY = 9 OR OD.EXECTYPE IN('NS','SS','MS') THEN V_STRCLEARDAY
                ELSE (CASE WHEN OD.T_CLEARDAY = OD.TXDATE
                THEN 0 ELSE 2 END ) END) = V_STRCLEARDAY
          GROUP BY AFB.BANKNAME, OD.T_CLEARDAY
          UNION ALL
              SELECT
                   0 d_bamt, 0 d_samt,
                   0 bd_bamt, 0 bd_samt,
                   SUM (DECODE (chd.duetype,
                                'SM', chd.amt ,
                                0
                               )) bf_bamt,
                   SUM (DECODE (chd.duetype,
                                'RM', chd.amt ,
                                0
                               )) bf_samt, AFB.BANKNAME, OD.T_CLEARDAY
              FROM stschd chd,
                   afmast af,
                   (SELECT * FROM CFMAST WHERE FNC_VALIDATE_SCOPE(BRID, CAREBY, TLSCOPE, pv_BRID, TLGOUPS)=0) cf,
                   AFTYPE AFT,
                   (SELECT AF.ACCTNO, (CASE WHEN AFT.COREBANK = 'N' THEN cspks_system.fn_get_sysvar('SYSTEM','COMPANYSHORTNAME') ELSE AF.BANKNAME END) BANKNAME
                    FROM AFMAST AF, AFTYPE AFT
                    WHERE AF.ACTYPE = AFT.ACTYPE) AFB,
                   (SELECT *
                      FROM sbsecurities
                     WHERE SECTYPE LIKE V_SECTYPE AND SECTYPE IN ('001','006','008','011')) sb, --Ngay 23/03/2017 CW NamTv them sectype 011
                     (
                    SELECT OD.*, STS.CLEARDATE T_CLEARDAY
                    FROM
                        (
                            SELECT * from vw_odmast_tradeplace_all where txdate = TO_DATE (i_date, 'DD/MM/YYYY')
                          and (tradeplace LIKE v_strtradeplace or (case when tradeplace = '001' or tradeplace = '002' then '999' else '888'
                          end ) like v_strtradeplace) AND tradeplace IN ('001','002','005')
                        )OD,
                    (SELECT * FROM STSCHD UNION ALL SELECT * FROM STSCHDHIST) STS
                    WHERE   OD.ORDERID = STS.ORGORDERID(+)
                        AND STS.DELTD <> 'Y'
                        AND nvl(STS.DUETYPE ,(CASE WHEN OD.EXECTYPE IN('NB','BC') THEN 'SM' ELSE 'RM' END)) =
                                    (CASE WHEN OD.EXECTYPE IN('NB','BC') THEN 'SM' ELSE 'RM' END)
                ) OD
              WHERE chd.deltd <> 'Y'
               AND SUBSTR (chd.acctno, 1, 10) = af.acctno
               AND af.custid = cf.custid
               AND AF.ACTYPE NOT IN ('0000')
               AND chd.duetype IN ('SM', 'RM')
               AND SUBSTR (cf.custodycd, 4, 1) = 'F'
               AND chd.txdate = TO_DATE (i_date, 'DD/MM/YYYY')
               AND cf.custodycd LIKE '%'
               AND sb.codeid = chd.codeid
               ----AND (substr(af.acctno,1,4) like V_p_STRBRID or instr((V_pV_STRBRID),substr(af.acctno,1,4)) <> 0)
               AND (af.brid like V_p_STRBRID or instr(V_pV_STRBRID,af.brid) <> 0 )
               and (af.brid like V_STRBRID or INSTR(V_STRBRID,af.brid) <> 0)
               AND AF.ACTYPE        =  AFT.ACTYPE
               AND AFT.COREBANK     LIKE 'Y'
               AND AF.BANKNAME      LIKE V_STRCASHPLACE
               AND AF.ACCTNO        = AFB.ACCTNO
                AND chd.orgorderid = od.orderid
               AND od.clearday = TO_NUMBER(DATE_T)
               AND (CASE WHEN V_STRCLEARDAY = 9 OR OD.EXECTYPE IN('NS','SS','MS') THEN V_STRCLEARDAY
                ELSE (CASE WHEN OD.T_CLEARDAY = OD.TXDATE
                THEN 0 ELSE 2 END ) END) = V_STRCLEARDAY
          GROUP BY AFB.BANKNAME, OD.T_CLEARDAY
          )

GROUP BY BANKNAME,T_CLEARDAY

UNION ALL

SELECT
         SUM (d_bamt) d_bamt, SUM (d_samt) d_samt, SUM (bd_bamt) bd_bamt,
         SUM (bd_samt) bd_samt, SUM (bf_bamt) bf_bamt, SUM (bf_samt) bf_samt,
         T_CLEARDAY, BANKNAME

FROM     (
              SELECT
                   SUM (DECODE (chd.duetype, 'SM', chd.amt , 0)) d_bamt,
                   SUM (DECODE (chd.duetype, 'RM', chd.amt , 0)) d_samt,
                   0 bd_bamt, 0 bd_samt, 0 bf_bamt, 0 bf_samt, AFB.BANKNAME, OD.T_CLEARDAY
              FROM stschdhist chd,
                   afmast af,
                   (SELECT * FROM CFMAST WHERE FNC_VALIDATE_SCOPE(BRID, CAREBY, TLSCOPE, pv_BRID, TLGOUPS)=0) cf,
                   AFTYPE AFT,

                   (SELECT AF.ACCTNO, (CASE WHEN AFT.COREBANK = 'N' THEN cspks_system.fn_get_sysvar('SYSTEM','COMPANYSHORTNAME') ELSE AF.BANKNAME END) BANKNAME
                    FROM AFMAST AF, AFTYPE AFT
                    WHERE AF.ACTYPE = AFT.ACTYPE) AFB,
                   (SELECT *
                      FROM sbsecurities
                     WHERE  SECTYPE LIKE V_SECTYPE AND SECTYPE IN ('001','006','008','011')) sb, --Ngay 23/03/2017 CW NamTv them sectype 011
                     (
                    SELECT OD.*, STS.CLEARDATE T_CLEARDAY
                    FROM
                        (
                            SELECT * from vw_odmast_tradeplace_all where txdate = TO_DATE (i_date, 'DD/MM/YYYY')
                          and (tradeplace LIKE v_strtradeplace or (case when tradeplace = '001' or tradeplace = '002' then '999' else '888'
                          end ) like v_strtradeplace) AND tradeplace IN ('001','002','005')
                        )OD,
                    (SELECT * FROM STSCHD UNION ALL SELECT * FROM STSCHDHIST) STS
                    WHERE   OD.ORDERID = STS.ORGORDERID(+)
                        AND STS.DELTD <> 'Y'
                        AND nvl(STS.DUETYPE ,(CASE WHEN OD.EXECTYPE IN('NB','BC') THEN 'SM' ELSE 'RM' END)) =
                                    (CASE WHEN OD.EXECTYPE IN('NB','BC') THEN 'SM' ELSE 'RM' END)
                ) OD
             WHERE chd.deltd <> 'Y'
               AND SUBSTR (chd.acctno, 1, 10) = af.acctno
               AND af.custid = cf.custid
               AND AF.ACTYPE NOT IN ('0000')
               AND SUBSTR (cf.custodycd, 4, 1) = 'P'
               AND chd.duetype IN ('SM', 'RM')
               AND chd.txdate = TO_DATE (i_date, 'DD/MM/YYYY')
               AND cf.custodycd LIKE '%'
               AND sb.codeid = chd.codeid
               ----AND (substr(af.acctno,1,4) like V_p_STRBRID or instr((V_pV_STRBRID),substr(af.acctno,1,4)) <> 0)
               AND (af.brid like V_p_STRBRID or instr(V_pV_STRBRID,af.brid) <> 0 )
               and (af.brid like V_STRBRID or INSTR(V_STRBRID,af.brid) <> 0)
               AND AF.ACTYPE        =  AFT.ACTYPE
               AND AFT.COREBANK     LIKE 'Y'
               AND AF.BANKNAME      LIKE V_STRCASHPLACE
               AND AF.ACCTNO        = AFB.ACCTNO
               AND chd.orgorderid = od.orderid
               AND od.clearday = TO_NUMBER(DATE_T)
               AND (CASE WHEN V_STRCLEARDAY = 9 OR OD.EXECTYPE IN('NS','SS','MS') THEN V_STRCLEARDAY
                ELSE (CASE WHEN OD.T_CLEARDAY = OD.TXDATE
                THEN 0 ELSE 2 END ) END) = V_STRCLEARDAY
               GROUP BY AFB.BANKNAME, OD.T_CLEARDAY
          UNION ALL
              SELECT
                   0 d_bamt, 0 d_samt,
                   SUM (DECODE (chd.duetype,
                                'SM', chd.amt ,
                                0
                               )) bd_bamt,
                   SUM (DECODE (chd.duetype,
                                'RM', chd.amt ,
                                0
                               )) bd_samt, 0 bf_bamt, 0 bf_samt, AFB.BANKNAME, OD.T_CLEARDAY
              FROM stschdhist chd,
                   afmast af,
                   (SELECT * FROM CFMAST WHERE FNC_VALIDATE_SCOPE(BRID, CAREBY, TLSCOPE, pv_BRID, TLGOUPS)=0) cf,
                   AFTYPE AFT,
                   (SELECT AF.ACCTNO, (CASE WHEN AFT.COREBANK = 'N' THEN cspks_system.fn_get_sysvar('SYSTEM','COMPANYSHORTNAME') ELSE AF.BANKNAME END) BANKNAME
                    FROM AFMAST AF, AFTYPE AFT
                    WHERE AF.ACTYPE = AFT.ACTYPE) AFB,
                   (SELECT *
                      FROM sbsecurities
                     WHERE SECTYPE LIKE V_SECTYPE AND SECTYPE IN ('001','006','008','011')) sb, --Ngay 23/03/2017 CW NamTv them sectype 011
                    (
                    SELECT OD.*, STS.CLEARDATE T_CLEARDAY
                    FROM
                        (
                          SELECT * from vw_odmast_tradeplace_all where txdate = TO_DATE (i_date, 'DD/MM/YYYY')
                          and (tradeplace LIKE v_strtradeplace or (case when tradeplace = '001' or tradeplace = '002' then '999' else '888'
                          end ) like v_strtradeplace) AND tradeplace IN ('001','002','005')
                        )OD,
                    (SELECT * FROM STSCHD UNION ALL SELECT * FROM STSCHDHIST) STS
                    WHERE   OD.ORDERID = STS.ORGORDERID(+)
                        AND STS.DELTD <> 'Y'
                        AND nvl(STS.DUETYPE ,(CASE WHEN OD.EXECTYPE IN('NB','BC') THEN 'SM' ELSE 'RM' END)) =
                                    (CASE WHEN OD.EXECTYPE IN('NB','BC') THEN 'SM' ELSE 'RM' END)
                ) OD
             WHERE chd.deltd <> 'Y'
               AND SUBSTR (chd.acctno, 1, 10) = af.acctno
               AND af.custid = cf.custid
               AND AF.ACTYPE NOT IN ('0000')
               AND SUBSTR (cf.custodycd, 4, 1) = 'C'
               AND chd.duetype IN ('SM', 'RM')
               AND chd.txdate = TO_DATE (i_date, 'DD/MM/YYYY')
               AND cf.custodycd LIKE '%'
               AND sb.codeid = chd.codeid
               ----AND (substr(af.acctno,1,4) like V_p_STRBRID or instr((V_pV_STRBRID),substr(af.acctno,1,4)) <> 0)
               AND (af.brid like V_p_STRBRID or instr(V_pV_STRBRID,af.brid) <> 0 )
               and (af.brid like V_STRBRID or INSTR(V_STRBRID,af.brid) <> 0)
               AND AF.ACTYPE        =  AFT.ACTYPE
               AND AFT.COREBANK     LIKE 'Y'
               AND AF.BANKNAME      LIKE V_STRCASHPLACE
               AND AF.ACCTNO        = AFB.ACCTNO
                AND chd.orgorderid = od.orderid
               AND od.clearday = TO_NUMBER(DATE_T)
               AND (CASE WHEN V_STRCLEARDAY = 9 OR OD.EXECTYPE IN('NS','SS','MS') THEN V_STRCLEARDAY
                ELSE (CASE WHEN OD.T_CLEARDAY = OD.TXDATE
                THEN 0 ELSE 2 END ) END) = V_STRCLEARDAY
          GROUP BY AFB.BANKNAME, OD.T_CLEARDAY
          UNION ALL
               SELECT
                   0 d_bamt, 0 d_samt, 0 bd_bamt, 0 bd_samt,
                   SUM (DECODE (chd.duetype,
                                'SM', chd.amt ,
                                0
                               )) bf_bamt,
                   SUM (DECODE (chd.duetype,
                                'RM', chd.amt ,
                                0
                               )) bf_samt, AFB.BANKNAME, OD.T_CLEARDAY
              FROM stschdhist chd,
                   afmast af,
                   (SELECT * FROM CFMAST WHERE FNC_VALIDATE_SCOPE(BRID, CAREBY, TLSCOPE, pv_BRID, TLGOUPS)=0) cf,
                   AFTYPE AFT,
                   (SELECT AF.ACCTNO, (CASE WHEN AFT.COREBANK = 'N' THEN cspks_system.fn_get_sysvar('SYSTEM','COMPANYSHORTNAME') ELSE AF.BANKNAME END) BANKNAME
                    FROM AFMAST AF, AFTYPE AFT
                    WHERE AF.ACTYPE = AFT.ACTYPE) AFB,
                   (SELECT *
                      FROM sbsecurities
                     WHERE  SECTYPE LIKE V_SECTYPE AND SECTYPE IN ('001','006','008','011')) sb, --Ngay 23/03/2017 CW NamTv them sectype 011
                     (
                    SELECT OD.*, STS.CLEARDATE T_CLEARDAY
                    FROM
                        (
                           SELECT * from vw_odmast_tradeplace_all where txdate = TO_DATE (i_date, 'DD/MM/YYYY')
                          and (tradeplace LIKE v_strtradeplace or (case when tradeplace = '001' or tradeplace = '002' then '999' else '888'
                          end ) like v_strtradeplace) AND tradeplace IN ('001','002','005')
                        )OD,
                    (SELECT * FROM STSCHD UNION ALL SELECT * FROM STSCHDHIST) STS
                    WHERE   OD.ORDERID = STS.ORGORDERID(+)
                        AND STS.DELTD <> 'Y'
                        AND nvl(STS.DUETYPE ,(CASE WHEN OD.EXECTYPE IN('NB','BC') THEN 'SM' ELSE 'RM' END)) =
                                    (CASE WHEN OD.EXECTYPE IN('NB','BC') THEN 'SM' ELSE 'RM' END)
                ) OD
             WHERE chd.deltd <> 'Y'
               AND SUBSTR (chd.acctno, 1, 10) = af.acctno
               AND af.custid = cf.custid
               AND AF.ACTYPE NOT IN ('0000')
               AND chd.duetype IN ('SM', 'RM')
               AND SUBSTR (cf.custodycd, 4, 1) = 'F'
               AND chd.txdate = TO_DATE (i_date, 'DD/MM/YYYY')
               AND cf.custodycd LIKE '%'
               AND sb.codeid = chd.codeid
               ----AND (substr(af.acctno,1,4) like V_p_STRBRID or instr((V_pV_STRBRID),substr(af.acctno,1,4)) <> 0)
               AND (af.brid like V_p_STRBRID or instr(V_pV_STRBRID,af.brid) <> 0 )
               and (af.brid like V_STRBRID or INSTR(V_STRBRID,af.brid) <> 0)
               AND AF.ACTYPE        =  AFT.ACTYPE
               AND AFT.COREBANK     LIKE 'Y'
               AND AF.BANKNAME      LIKE V_STRCASHPLACE
               AND AF.ACCTNO        = AFB.ACCTNO
            AND chd.orgorderid = od.orderid
               AND od.clearday = TO_NUMBER(DATE_T)
               AND (CASE WHEN V_STRCLEARDAY = 9 OR OD.EXECTYPE IN('NS','SS','MS') THEN V_STRCLEARDAY
                ELSE (CASE WHEN OD.T_CLEARDAY = OD.TXDATE
                THEN 0 ELSE 2 END ) END) = V_STRCLEARDAY
          GROUP BY AFB.BANKNAME, OD.T_CLEARDAY
         )
GROUP BY BANKNAME,T_CLEARDAY
) GROUP BY BANKNAME,T_CLEARDAY
;

END IF;

EXCEPTION
   WHEN OTHERS
   THEN
        RETURN;
END;
 
/
