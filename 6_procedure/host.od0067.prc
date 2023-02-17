SET DEFINE OFF;
CREATE OR REPLACE PROCEDURE od0067 (
   PV_REFCURSOR   IN OUT   PKG_REPORT.REF_CURSOR,
   OPT            IN       VARCHAR2,
   pv_BRID           IN       VARCHAR2,
   TLGOUPS        IN       VARCHAR2,
   TLSCOPE        IN       VARCHAR2,
   I_DATE         IN       VARCHAR2,
   TRADEPLACE     IN       VARCHAR2,
   PV_SECTYPE     IN       VARCHAR2,
   CASHPLACE      IN       VARCHAR2,
   PV_BRGID       IN       VARCHAR2
  )
IS
--
-- PURPOSE: BRIEFLY EXPLAIN THE FUNCTIONALITY OF THE PROCEDURE
--
-- MODIFICATION HISTORY
-- PERSON      DATE    COMMENTS
-- NAMNT   21-NOV-06  CREATED
-- TruongLD 05/10/2011  Modify
-- GianhVG 03/03/2011
-- ---------   ------  -------------------------------------------
  V_STROPTION        VARCHAR2 (5);       -- A: ALL; B: BRANCH; S: SUB-BRANCH
  V_STRBRID          VARCHAR2 (40);
  V_INBRID           VARCHAR2 (4);

  V_BRID             VARCHAR2 (4);

  V_STRAFACCTNO      VARCHAR  (20);
  V_STRTRADEPLACE    VARCHAR2 (4);
  V_STRCASHPLACE     VARCHAR2 (100);
  v_I_DATE           Date ;
  v_err              varchar2(200);
  TYPEDATE           VARCHAR2(10);
  vstr_typedate      VARCHAR2(10);
  v_CashPlaceName    VARCHAR2(1000);
  V_SECTYPE          VARCHAR2(100);

  V_cleardate   Date ;
  v_cleardt  date;
V_SYSCLEARDAY NUMBER;
BEGIN
   V_STROPTION := upper(OPT);
   V_INBRID := pv_BRID;

   IF V_STROPTION = 'A' THEN     -- TOAN HE THONG
      V_STRBRID := '%';
   ELSE if V_STROPTION = 'B' THEN
            select brgrp.mapid into V_STRBRID from brgrp where brgrp.brid = V_INBRID;
        else
            V_STRBRID := V_INBRID;
        end if;
   END IF;

   -- GET REPORT'S PARAMETERS

   IF  (TRADEPLACE <> 'ALL')
   THEN
      V_STRTRADEPLACE := TRADEPLACE;
   ELSE
      V_STRTRADEPLACE := '%';
   END IF;


   IF  (CASHPLACE <> 'ALL')
   THEN
      V_STRCASHPLACE := CASHPLACE;
   ELSE
      V_STRCASHPLACE := '%';
   END IF;


   IF  (PV_SECTYPE <> 'ALL')
   THEN
      V_SECTYPE := PV_SECTYPE;
   ELSE
      V_SECTYPE := '%';
   END IF;


   If  CASHPLACE = 'ALL' Then
       v_CashPlaceName := ' Tat ca ';
   ELSIF CASHPLACE = '000' Then
       v_CashPlaceName := ' Cong ty chung khoan';
   Else
       Begin
        Select CDCONTENT Into v_CashPlaceName from Allcode Where cdval = CASHPLACE And cdname ='BANKNAME' and cdtype ='CF';
       EXCEPTION
        WHEN OTHERS THEN v_CashPlaceName := '';
       End;
   End If;

   TYPEDATE      := '001';

   vstr_typedate := TYPEDATE;

   IF(PV_BRGID <> 'ALL') THEN
     V_BRID := PV_BRGID;
   ELSE
     V_BRID := '%';
   END IF;

--select getduedate(TO_DATE (i_date, 'DD/MM/YYYY'), 'B', '000', 3) into V_cleardate from dual;
     --T2- NAMNT
    SELECT fn_getSYSCLEARDAY(i_date) INTO V_SYSCLEARDAY FROM dual;

   IF (V_STRTRADEPLACE <> '%' )
   THEN
        V_cleardate := getduedate(TO_DATE (i_date, 'DD/MM/YYYY'), 'B', TRADEPLACE, V_SYSCLEARDAY); --ngoc.vu-Jira561
        --End T2-NAMNT
        select getduedate(TO_DATE (i_date, 'DD/MM/YYYY'), 'B',TRADEPLACE, 1) into V_cleardt from dual; -- ngay thanh toan trai phieu
   ELSE
       V_cleardate := getduedate(TO_DATE (i_date, 'DD/MM/YYYY'), 'B', '001', V_SYSCLEARDAY); --ngoc.vu-Jira561
        --End T2-NAMNT
        select getduedate(TO_DATE (i_date, 'DD/MM/YYYY'), 'B','001', 1) into V_cleardt from dual; -- ngay thanh toan trai phieu

   END IF;


IF (TRADEPLACE = '999') THEN
OPEN PV_REFCURSOR
       FOR
SELECT   vstr_typedate typedate, to_char(settdate,'DD/MM/RRRR') settdate, to_char(tradate,'DD/MM/RRRR') tradate,
             SUM (d_bamt) d_bamt, SUM (d_samt) d_samt, SUM (bd_bamt) bd_bamt,
             SUM (bd_samt) bd_samt, SUM (bf_bamt) bf_bamt, SUM (bf_samt) bf_samt,
             (case
              when tradeplace='002' then 'HNX'
              when tradeplace='001' then 'HOSE'
              when tradeplace='005' then 'UPCOM' else '' end)tradeplace, symbol,
              i_date i_date, v_CashPlaceName CASHPLACE
        FROM (
              SELECT V_cleardate settdate,
                       chd.txdate tradate, cf.custodycd, cf.fullname, CHD.TRADEPLACE, sb.symbol,
                   SUM (case when SUBSTR (cf.custodycd, 4, 1) = 'P' then  DECODE (chd.duetype, 'RS', chd.amt , 0) else 0 end) d_bamt,
                   SUM (case when SUBSTR (cf.custodycd, 4, 1) = 'P' then  DECODE (chd.duetype, 'RM', chd.amt , 0) else 0 end) d_samt,
                   SUM (case when SUBSTR (cf.custodycd, 4, 1) = 'C' then  DECODE (chd.duetype, 'RS', chd.amt , 0) else 0 end) bd_bamt,
                   SUM (case when SUBSTR (cf.custodycd, 4, 1) = 'C' then  DECODE (chd.duetype, 'RM', chd.amt , 0) else 0 end) bd_samt,
                   SUM (case when SUBSTR (cf.custodycd, 4, 1) = 'F' then  DECODE (chd.duetype, 'RS', chd.amt , 0) else 0 end) bf_bamt,
                   SUM (case when SUBSTR (cf.custodycd, 4, 1) = 'F' then  DECODE (chd.duetype, 'RM', chd.amt , 0) else 0 end) bf_samt
                  FROM (SELECT * FROM vw_stschd_tradeplace_all WHERE  tradeplace IN ('001','002','005')    ) chd,
                       (select * from afmast
                            where (case when CASHPLACE = 'ALL' then 'ALL'
                                                        when CASHPLACE = '000' or CASHPLACE = '---' then corebank
                                                        else corebank || bankname end)
                                                   = (case when CASHPLACE = 'ALL' then 'ALL'
                                                        when CASHPLACE = '000'  or CASHPLACE = '---' then 'N'
                                                        else 'Y' || V_STRCASHPLACE  end)
                                --and SUBSTR(acctno,1,4) like V_BRID
                                --and SUBSTR(acctno,1,4) like V_STRBRID
                                and brid like V_BRID
                                and (brid like V_STRBRID or instr(V_STRBRID,brid) <> 0)
                        ) af,
                       (SELECT * FROM CFMAST WHERE FNC_VALIDATE_SCOPE(BRID, CAREBY, TLSCOPE, pv_BRID, TLGOUPS)=0) cf,
                       (SELECT *
                          FROM sbsecurities
                         WHERE  SECTYPE LIKE V_SECTYPE AND SECTYPE IN ('001','006','008','011')) sb
                 WHERE chd.deltd <> 'Y'
                   --AND SUBSTR (chd.acctno, 1, 10) = af.acctno
                   AND chd.afacctno= af.acctno
                   AND af.custid = cf.custid
                   AND chd.duetype IN ('RS', 'RM')
                   and chd.clearday =  3
                   AND chd.txdate = TO_DATE (i_date, 'DD/MM/YYYY')
                  -- AND chd.acctno LIKE v_strafacctno
                   AND cf.custodycd LIKE '%'
                   AND sb.codeid = chd.codeid
                   and cf.custatcom = 'Y'
              GROUP BY chd.cleardate,
                       cf.custodycd,
                       cf.fullname,
                       chd.txdate,
                       CHD.TRADEPLACE,
                       sb.symbol
                       )
    GROUP BY settdate,  tradate, tradeplace, symbol;
ELSE
    OPEN PV_REFCURSOR
       FOR
SELECT   vstr_typedate typedate, to_char(settdate,'DD/MM/RRRR') settdate, to_char(tradate,'DD/MM/RRRR') tradate,
             SUM (d_bamt) d_bamt, SUM (d_samt) d_samt, SUM (bd_bamt) bd_bamt,
             SUM (bd_samt) bd_samt, SUM (bf_bamt) bf_bamt, SUM (bf_samt) bf_samt,
             (case
              when tradeplace='002' then 'HNX'
              when tradeplace='001' then 'HOSE'
              when tradeplace='005' then 'UPCOM'
                 when tradeplace='007' then 'TRAI PHIEU CHUYEN BIET'
                    when tradeplace='008' then 'TIN PHIEU'
               else '' end)tradeplace, symbol,
              i_date i_date, v_CashPlaceName CASHPLACE
        FROM (
              SELECT (case when V_STRTRADEPLACE in ('007','008') then v_cleardt else V_cleardate end) settdate,
                       chd.txdate tradate, cf.custodycd, cf.fullname, CHD.TRADEPLACE, sb.symbol,
                   SUM (case when SUBSTR (cf.custodycd, 4, 1) = 'P' then  DECODE (chd.duetype, 'RS', chd.amt , 0) else 0 end) d_bamt,
                   SUM (case when SUBSTR (cf.custodycd, 4, 1) = 'P' then  DECODE (chd.duetype, 'RM', chd.amt , 0) else 0 end) d_samt,
                   SUM (case when SUBSTR (cf.custodycd, 4, 1) = 'C' then  DECODE (chd.duetype, 'RS', chd.amt , 0) else 0 end) bd_bamt,
                   SUM (case when SUBSTR (cf.custodycd, 4, 1) = 'C' then  DECODE (chd.duetype, 'RM', chd.amt , 0) else 0 end) bd_samt,
                   SUM (case when SUBSTR (cf.custodycd, 4, 1) = 'F' then  DECODE (chd.duetype, 'RS', chd.amt , 0) else 0 end) bf_bamt,
                   SUM (case when SUBSTR (cf.custodycd, 4, 1) = 'F' then  DECODE (chd.duetype, 'RM', chd.amt , 0) else 0 end) bf_samt
                  FROM (SELECT * FROM  vw_stschd_TRADEPLACE_all WHERE  TRADEPLACE like V_STRTRADEPLACE and  tradeplace IN ('001','002','005','007','008') ) chd,
                       (select * from afmast
                            where (case when CASHPLACE = 'ALL' then 'ALL'
                                                        when CASHPLACE = '000' or CASHPLACE = '---' then corebank
                                                        else corebank || bankname end)
                                                   = (case when CASHPLACE = 'ALL' then 'ALL'
                                                        when CASHPLACE = '000'  or CASHPLACE = '---' then 'N'
                                                        else 'Y' || V_STRCASHPLACE  end)
                                --and SUBSTR(acctno,1,4) like V_BRID
                                --and SUBSTR(acctno,1,4) like V_STRBRID
                                and brid like V_BRID
                                and (brid like V_STRBRID or instr(V_STRBRID,brid) <> 0)
                        ) af,
                       (SELECT * FROM CFMAST WHERE FNC_VALIDATE_SCOPE(BRID, CAREBY, TLSCOPE, pv_BRID, TLGOUPS)=0) cf,
                       (SELECT *
                          FROM sbsecurities
                         WHERE  SECTYPE LIKE V_SECTYPE AND SECTYPE IN ('001','006','008','011')) sb
                 WHERE chd.deltd <> 'Y'
                   --AND SUBSTR (chd.acctno, 1, 10) = af.acctno
                   AND chd.afacctno= af.acctno
                   AND af.custid = cf.custid
                   AND chd.duetype IN ('RS', 'RM')
                 --  and chd.clearday = 3
                   AND chd.txdate = TO_DATE (i_date, 'DD/MM/YYYY')
                  -- AND chd.acctno LIKE v_strafacctno
                   AND cf.custodycd LIKE '%'
                   AND sb.codeid = chd.codeid
                   and cf.custatcom = 'Y'
              GROUP BY chd.cleardate,
                       cf.custodycd,
                       cf.fullname,
                       chd.txdate,
                       CHD.TRADEPLACE,
                       sb.symbol
        )
    GROUP BY settdate,  tradate, tradeplace, symbol;
END IF;


EXCEPTION
   WHEN OTHERS
   THEN
   v_err:=substr(sqlerrm,1,199);
          /*   INSERT INTO log_err
                  (id,date_log, POSITION, text
                  )
           VALUES ( seq_log_err.NEXTVAL,SYSDATE, ' OD0021 ', v_err
                  );

       COMMIT;*/
END;
 
/
