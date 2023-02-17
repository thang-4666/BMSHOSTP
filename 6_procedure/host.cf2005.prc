SET DEFINE OFF;
CREATE OR REPLACE PROCEDURE cf2005 (
   PV_REFCURSOR   IN OUT   PKG_REPORT.REF_CURSOR,
   OPT            IN       VARCHAR2,
   pv_BRID           IN       VARCHAR2,
   TLGOUPS        IN       VARCHAR2,
   TLSCOPE        IN       VARCHAR2,
   F_DATE         IN       VARCHAR2,
   T_DATE         IN       VARCHAR2,
   PV_CUSTATCOM   IN       VARCHAR2
 )
IS
--

   V_STROPTION    VARCHAR2 (5);            -- A: ALL; B: BRANCH; S: SUB-BRANCH
   V_STRBRID      VARCHAR2 (40);            -- USED WHEN V_NUMOPTION > 0
   V_INBRID     VARCHAR2 (5);      -- USED WHEN V_NUMOPTION > 0

   V_TODATE     DATE;
   V_FROMDATE   DATE;

    v_DK_CN_NN NUMBER;
    v_DK_TC_NN NUMBER;
    v_DK_CN_TN NUMBER;
    v_DK_TC_TN NUMBER;
    v_TK_CN_NN_Credit NUMBER;
    v_TK_TC_NN_Credit NUMBER;
    v_TK_CN_TN_Credit NUMBER;
    v_TK_TC_TN_Credit NUMBER;
    v_TK_CN_NN_Debit NUMBER;
    v_TK_TC_NN_Debit NUMBER;
    v_TK_CN_TN_Debit NUMBER;
    v_TK_TC_TN_Debit NUMBER;
    v_CK_CN_NN NUMBER;
    v_CK_TC_NN NUMBER;
    v_CK_CN_TN NUMBER;
    v_CK_TC_TN NUMBER;

    v_strcustatcom   varchar2(10);

    V_TK_CN_NN_Trade    NUMBER;
    V_TK_TC_NN_Trade    NUMBER;
    V_TK_CN_TN_Trade    NUMBER;
    V_TK_TC_TN_Trade    NUMBER;

-- DECLARE PROGRAM VARIABLES AS SHOWN ABOVE

BEGIN
-- INSERT INTO TEMP_BUG(TEXT) VALUES('CF0001');COMMIT;
   V_STROPTION := upper(OPT);
   V_INBRID := pv_BRID;

   if(V_STROPTION = 'A') then
        V_STRBRID := '%';
    else
        if(V_STROPTION = 'B') then
            select br.BRID into V_STRBRID from brgrp br where  br.brid = V_INBRID;
        else
            V_STRBRID := pv_BRID;
        end if;
    end if;

    V_FROMDATE := to_date(F_DATE,'DD/MM/RRRR');
    V_TODATE := to_date(T_DATE,'DD/MM/RRRR');

    if PV_CUSTATCOM = 'Y' then
      V_strcustatcom := '%';
      else
        V_strcustatcom := 'Y';
        end if;


            SELECT sum( CASE WHEN ( cf.custatcom = 'Y' AND ( SUBSTR(cf.custodycd,4,1)  = 'F') or (cf.custatcom = 'N' and nvl(cf.country,'234') <> '234')) AND cf.custtype = 'I' THEN 1 ELSE 0 END) ,
               sum( CASE WHEN ( (cf.custatcom = 'Y' AND SUBSTR(cf.custodycd,4,1)  = 'F') or (cf.custatcom = 'N' and nvl(cf.country,'234') <> '234')) AND cf.custtype = 'B' THEN 1 ELSE 0 END) ,
               sum( CASE WHEN ((cf.custatcom = 'Y' AND SUBSTR(cf.custodycd,4,1)  = 'C') or (cf.custatcom = 'N' and nvl(cf.country,'234') = '234'))AND cf.custtype = 'I' THEN 1 ELSE 0 END) ,
               sum( CASE WHEN ( (cf.custatcom = 'Y' AND SUBSTR(cf.custodycd,4,1)  = 'C') or (cf.custatcom = 'N' and nvl(cf.country,'234') = '234'))AND cf.custtype = 'B' THEN 1 ELSE 0 END)
           into V_TK_CN_NN_Trade, V_TK_TC_NN_Trade, V_TK_CN_TN_Trade, V_TK_TC_TN_Trade
            FROM (select distinct cf.custid from vw_odmast_all od, afmast af,  (SELECT * FROM CFMAST WHERE FNC_VALIDATE_SCOPE(BRID, CAREBY, TLSCOPE, pv_BRID, TLGOUPS)=0 AND activests ='Y') cf
             where od.txdate BETWEEN V_FROMDATE AND V_TODATE and od.execqtty <> 0
                and od.afacctno = af.acctno and af.custid = cf.custid
                AND cf.custatcom like V_strcustatcom
             ) od,
                 (SELECT * FROM CFMAST WHERE FNC_VALIDATE_SCOPE(BRID, CAREBY, TLSCOPE, pv_BRID, TLGOUPS)=0 AND activests ='Y') cf
            WHERE od.custid = cf.custid  AND CF.CLASS<>'000' AND cf.custatcom like V_strcustatcom;


OPEN PV_REFCURSOR FOR
SELECT --dau ky = cuoi ky - mo + dong
         nvl(TC_NN,0) - nvl(TC_NN_OPENED,0) + nvl(TC_NN_CLOSED,0) AS CF_DK_TC_NN,
         nvl(CN_TN,0) - nvl(CN_TN_OPENED,0) + nvl(CN_TN_CLOSED,0) AS CF_DK_CN_TN,
        nvl(TC_TN,0) - nvl(TC_TN_OPENED,0) + nvl(TC_TN_CLOSED,0) AS CF_DK_TC_TN,
         nvl(CN_NN,0) - nvl(CN_NN_OPENED,0) + nvl(CN_NN_CLOSED,0) AS CF_DK_CN_NN,
         nvl(TC_TN_CLOSED,0) AS CF_TK_TC_TN_Debit,
         nvl(CN_TN_CLOSED,0) AS CF_TK_CN_TN_Debit,
         nvl(TC_NN_CLOSED,0) AS CF_TK_TC_NN_Debit,
         nvl(CN_NN_CLOSED,0) AS CF_TK_CN_NN_Debit,
         nvl(TC_TN_OPENED,0) AS CF_TK_TC_TN_Credit,
         nvl(CN_TN_OPENED,0) AS CF_TK_CN_TN_Credit,
         nvl(TC_NN_OPENED,0) AS CF_TK_TC_NN_Credit,
         nvl(CN_NN_OPENED,0) AS CF_TK_CN_NN_Credit,
         nvl(TC_NN,0) AS CF_CK_TC_NN,
         nvl(CN_TN,0) AS CF_CK_CN_TN,
         nvl(TC_TN,0) AS CF_CK_TC_TN,
         nvl(CN_NN,0) AS  CF_CK_CN_NN,
                nvl(V_TK_CN_NN_Trade,0) TK_CN_NN_Trade, nvl( V_TK_TC_NN_Trade,0) TK_TC_NN_Trade,
                nvl(V_TK_CN_TN_Trade,0) TK_CN_TN_Trade, nvl(V_TK_TC_TN_Trade,0) TK_TC_TN_Trade
       -- A.CF_CK_TC_NN - A.CF_TK_TC_NN_Credit + A.CF_TK_TC_NN_Debit CF_DK_TC_NN,
        --A.CF_CK_CN_TN, A.CF_TK_CN_TN_Credit , A.CF_TK_CN_TN_Debit --CF_DK_CN_TN,
        --A.CF_CK_TC_TN - A.CF_TK_TC_TN_Credit + A.CF_TK_TC_TN_Debit CF_DK_TC_TN,
        --A.CF_TK_TC_TN_Credit, A.CF_TK_TC_TN_Debit, A.CF_TK_CN_TN_Credit, A.CF_TK_CN_TN_Debit,
        --A.CF_TK_TC_NN_Credit, A.CF_TK_TC_NN_Debit, A.CF_TK_CN_NN_Credit, A.CF_TK_CN_NN_Debit,
        --A.CF_CK_TC_TN,
        --A.CF_CK_CN_TN,
        --A.CF_CK_TC_NN,
        --A.CF_CK_CN_NN
    from
        ---  Tang giam TRONG KY
            (
                SELECT sum(CASE WHEN custtype = 'B'  and (SUBSTR(cf.custodycd,4,1)  = 'C' or (cf.custatcom = 'N' and nvl(cf.country,'234') = '234')) THEN 1 ELSE 0 END)  TC_TN_CLOSED,
                            sum(case WHEN custtype = 'I'  and (SUBSTR(cf.custodycd,4,1)  = 'C' or (cf.custatcom = 'N' and nvl(cf.country,'234') = '234')) THEN 1 ELSE 0 END) CN_TN_CLOSED,
                            sum(CASE WHEN custtype = 'B'  and (SUBSTR(cf.custodycd,4,1)  = 'F' or (cf.custatcom = 'N' and nvl(cf.country,'234') <> '234')) THEN 1 ELSE 0 END) TC_NN_CLOSED,
                            sum(CASE WHEN custtype = 'I'  and (SUBSTR(cf.custodycd,4,1)  = 'F' or (cf.custatcom = 'N' and nvl(cf.country,'234') <> '234'))THEN 1 ELSE 0 END) CN_NN_CLOSED
                FROM vw_tllog_all,VW_TLLOGFLD_ALL FLD,  (SELECT * FROM CFMAST WHERE FNC_VALIDATE_SCOPE(BRID, CAREBY, TLSCOPE, pv_BRID, TLGOUPS)=0 AND activests ='Y')  cf
                WHERE tltxcd = '0059' AND busdate >= V_FROMDATE and busdate <= V_TODATE
                    AND cf.custid = vw_tllog_all.msgacct
                    /*AND cf.custatcom = 'Y'*/ AND deltd <> 'Y' AND CF.CLASS<>'000'
                    AND cf.custodycd IS NOT NULL
                    and cf.custatcom like V_strcustatcom
                    AND vw_tllog_all.TXNUM=FLD.TXNUM
                    AND vw_tllog_all.TXDATE=FLD.TXDATE
                    AND FLD.FLDCD='08' AND FLD.CVALUE<>'N'

            ) TK_CLOSED,
            (
                SELECT sum(CASE WHEN custtype = 'B' and (SUBSTR(custodycd,4,1)  = 'C' or (custatcom = 'N' and nvl(country,'234') = '234')) THEN 1 ELSE 0 END)  TC_TN_OPENED,
                            sum(case WHEN custtype = 'I' and (SUBSTR(custodycd,4,1)  = 'C' or (custatcom = 'N' and nvl(country,'234') = '234')) THEN 1 ELSE 0 END) CN_TN_OPENED,
                            sum(CASE WHEN custtype = 'B' and (SUBSTR(custodycd,4,1)  = 'F' or (custatcom = 'N' and nvl(country,'234') <> '234')) THEN 1 ELSE 0 END)  TC_NN_OPENED,
                            sum(case WHEN custtype = 'I' and (SUBSTR(custodycd,4,1)  = 'F' or (custatcom = 'N' and nvl(country,'234') <> '234')) THEN 1 ELSE 0 END) CN_NN_OPENED
                FROM
                (
                    SELECT cf.custodycd, custtype, nvl(cf.country,'234') country, cf.custatcom FROM  (SELECT * FROM CFMAST WHERE FNC_VALIDATE_SCOPE(BRID, CAREBY, TLSCOPE, pv_BRID, TLGOUPS)=0 AND activests ='Y')  cf
                    WHERE cf.opndate >= V_FROMDATE and nvl(cf.opndate,to_date('01/01/2010','dd/mm/rrrr')) <= V_TODATE
                        AND cf.custodycd IS NOT NULL /* AND status IN ('A','P','B','N')*/ AND (INSTR(pstatus,'A') <> 0 OR status = 'A')
                        /*AND cf.custatcom = 'Y' */ AND CF.CLASS<>'000'
                        and cf.custatcom like V_strcustatcom
                    union all
                    SELECT cf.custodycd, cf.custtype, nvl(cf.country,'234') country, cf.custatcom FROM vw_tllog_all,  (SELECT * FROM CFMAST WHERE FNC_VALIDATE_SCOPE(BRID, CAREBY, TLSCOPE, pv_BRID, TLGOUPS)=0 AND activests ='Y')  cf, VW_TLLOGFLD_ALL FLD
                    WHERE tltxcd = '0067' AND busdate >= V_TODATE AND deltd <> 'Y'
                        AND cf.custid = vw_tllog_all.msgacct
                        /*AND cf.custatcom = 'Y' */AND CF.custodycd IS NOT NULL  AND CF.CLASS<>'000'
                        AND vw_tllog_all.TXNUM=FLD.TXNUM
                        AND vw_tllog_all.TXDATE=FLD.TXDATE
                        and cf.custatcom like V_strcustatcom
                        AND FLD.FLDCD='08' AND FLD.CVALUE<>'N'
                )
            ) TK_OPENED,


       --CUOI KY: hien tai - mo + dong (ke ca ngay todate)

       (
             SELECT hien_tai.CN_TN - nvl(opened.CN_TN,0) + nvl(closed.CN_TN,0) AS CN_TN,
                         hien_tai.TC_TN - nvl(opened.TC_TN,0) + nvl(closed.TC_TN,0) AS TC_TN,
                         hien_tai.CN_NN - nvl(opened.CN_NN,0) + nvl(closed.CN_NN,0) AS CN_NN,
                         hien_tai.TC_NN - nvl(opened.TC_NN,0) + nvl(closed.TC_NN,0) AS TC_NN
             FROM
                (
                    SELECT sum(CASE WHEN custtype = 'I' AND (SUBSTR(custodycd,4,1)  = 'C' or (custatcom = 'N' and nvl(country,'234') = '234')) THEN 1 ELSE 0 END) CN_TN ,
                                sum(CASE WHEN custtype = 'B' AND (SUBSTR(custodycd,4,1)  = 'C' or (custatcom = 'N' and nvl(country,'234') = '234')) THEN 1 ELSE 0 END) TC_TN ,
                                sum(CASE WHEN custtype = 'I' AND (SUBSTR(custodycd,4,1)  = 'F' or (custatcom = 'N' and nvl(country,'234') <> '234'))  THEN 1 ELSE 0 END) CN_NN ,
                                sum(CASE WHEN custtype = 'B' AND (SUBSTR(custodycd,4,1)  = 'F' or (custatcom = 'N' and nvl(country,'234') <> '234')) THEN 1 ELSE 0 END) TC_NN
                    FROM (SELECT * FROM CFMAST WHERE FNC_VALIDATE_SCOPE(BRID, CAREBY, TLSCOPE, pv_BRID, TLGOUPS)=0 AND activests ='Y')
                    WHERE status IN ('A','P','B','N','T') AND (INSTR(pstatus,'A') <> 0 OR status = 'A')
                    /*AND  custatcom = 'Y' */AND custodycd IS NOT NULL  AND CLASS<>'000'
                    and custatcom like V_strcustatcom
                ) hien_tai,
                (
                    SELECT sum(CASE WHEN custtype = 'I' AND (SUBSTR(custodycd,4,1)  = 'C' or (cf.custatcom = 'N' and nvl(cf.country,'234') = '234')) THEN 1 ELSE 0 END) CN_TN ,
                                sum(CASE WHEN custtype = 'B' AND (SUBSTR(custodycd,4,1)  = 'C' or (cf.custatcom = 'N' and nvl(cf.country,'234') = '234')) THEN 1 ELSE 0 END) TC_TN ,
                                sum(CASE WHEN custtype = 'I' AND (SUBSTR(custodycd,4,1)  = 'F' or (cf.custatcom = 'N' and nvl(cf.country,'234') <> '234')) THEN 1 ELSE 0 END) CN_NN ,
                                sum(CASE WHEN custtype = 'B' AND (SUBSTR(custodycd,4,1)  = 'F' or (cf.custatcom = 'N' and nvl(cf.country,'234') <> '234')) THEN 1 ELSE 0 END) TC_NN
                    FROM vw_tllog_all, (SELECT * FROM CFMAST WHERE FNC_VALIDATE_SCOPE(BRID, CAREBY, TLSCOPE, pv_BRID, TLGOUPS)=0 AND activests ='Y')  cf,VW_TLLOGFLD_ALL FLD
                    WHERE tltxcd = '0059' AND busdate > V_TODATE AND deltd <> 'Y'
                    AND cf.custid = vw_tllog_all.msgacct
                                        /*AND cf.custatcom = 'Y'*/ AND cf.custodycd IS NOT NULL  AND CF.CLASS<>'000'
                                        AND vw_tllog_all.TXNUM=FLD.TXNUM
                                        AND vw_tllog_all.TXDATE=FLD.TXDATE
                                        AND FLD.FLDCD='08' AND FLD.CVALUE<>'N'
                                        and cf.custatcom like V_strcustatcom
                                ) closed,
                                (
                                        SELECT sum(CASE WHEN custtype = 'I' AND (SUBSTR(custodycd,4,1)  = 'C' or (custatcom = 'N' and nvl(country,'234') = '234')) THEN 1 ELSE 0 END) CN_TN ,
                                                    sum(CASE WHEN custtype = 'B' AND (SUBSTR(custodycd,4,1)  = 'C' or (custatcom = 'N' and nvl(country,'234') = '234')) THEN 1 ELSE 0 END) TC_TN ,
                                                                sum(CASE WHEN custtype = 'I' AND (SUBSTR(custodycd,4,1)  = 'F' or (custatcom = 'N' and nvl(country,'234') <> '234')) THEN 1 ELSE 0 END) CN_NN ,
                                                                sum(CASE WHEN custtype = 'B' AND (SUBSTR(custodycd,4,1)  = 'F' or (custatcom = 'N' and nvl(country,'234') <> '234')) THEN 1 ELSE 0 END) TC_NN
                                        FROM
                                        (
                                                SELECT cf.custodycd, custtype, country, cf.custatcom  FROM  (SELECT * FROM CFMAST WHERE FNC_VALIDATE_SCOPE(BRID, CAREBY, TLSCOPE, pv_BRID, TLGOUPS)=0 AND activests ='Y')   cf
                                                WHERE nvl(cf.opndate,to_date('01/01/2010','dd/mm/rrrr')) >  V_TODATE
                                                AND cf.custodycd IS NOT NULL /*AND status IN ('A','P','B','N')*/ AND (INSTR(pstatus,'A') <> 0 OR status = 'A')
                                                /*AND cf.custatcom = 'Y'*/  AND CF.CLASS<>'000' and cf.custatcom like v_strcustatcom
                                                union all
                                                SELECT custodycd, custtype, country, cf.custatcom
                                                FROM vw_tllog_all, (SELECT * FROM CFMAST WHERE FNC_VALIDATE_SCOPE(BRID, CAREBY, TLSCOPE, pv_BRID, TLGOUPS)=0 AND activests ='Y')  cf,VW_TLLOGFLD_ALL FLD
                                                WHERE tltxcd = '0067' AND busdate >  V_TODATE  AND deltd <> 'Y'
                                                AND cf.custid = vw_tllog_all.msgacct /*AND cf.custatcom = 'Y'*/ AND CF.custodycd IS NOT NULL
                                                AND vw_tllog_all.TXNUM=FLD.TXNUM  AND CF.CLASS<>'000'
                                                AND vw_tllog_all.TXDATE=FLD.TXDATE
                                                AND FLD.FLDCD='08' AND FLD.CVALUE<>'N'
                                                and cf.custatcom like V_strcustatcom

                                        )
                                ) opened

       ) CK

    /*select
        A.CF_CK_CN_NN - A.CF_TK_CN_NN_Credit + A.CF_TK_CN_NN_Debit CF_DK_CN_NN,
        A.CF_CK_TC_NN - A.CF_TK_TC_NN_Credit + A.CF_TK_TC_NN_Debit CF_DK_TC_NN,
        A.CF_CK_CN_TN - A.CF_TK_CN_TN_Credit + A.CF_TK_CN_TN_Debit CF_DK_CN_TN,
        A.CF_CK_TC_TN - A.CF_TK_TC_TN_Credit + A.CF_TK_TC_TN_Debit CF_DK_TC_TN,
        A.CF_TK_TC_TN_Credit, A.CF_TK_TC_TN_Debit, A.CF_TK_CN_TN_Credit, A.CF_TK_CN_TN_Debit,
        A.CF_TK_TC_NN_Credit, A.CF_TK_TC_NN_Debit, A.CF_TK_CN_NN_Credit, A.CF_TK_CN_NN_Debit,
        A.CF_CK_TC_TN, A.CF_CK_CN_TN, A.CF_CK_TC_NN, A.CF_CK_CN_NN,
        B.TK_CN_NN_Trade, B.TK_TC_NN_Trade, B.TK_CN_TN_Trade, B.TK_TC_TN_Trade
    from (
        SELECT
        --- TRONG KY
            (
                SELECT count(*) amt FROM vw_tllog_all,VW_TLLOGFLD_ALL FLD,  (SELECT * FROM CFMAST WHERE FNC_VALIDATE_SCOPE(BRID, CAREBY, TLSCOPE, pv_BRID, TLGOUPS)=0) cf
                WHERE tltxcd = '0059' AND busdate >= V_FROMDATE and busdate < V_TODATE
                    AND cf.custid = vw_tllog_all.msgacct AND cf.custtype = 'B'
                    AND cf.custatcom = 'Y' AND deltd <> 'Y'
                    AND cf.custodycd IS NOT NULL
                    AND vw_tllog_all.TXNUM=FLD.TXNUM
                          AND vw_tllog_all.TXDATE=FLD.TXDATE
                           AND FLD.FLDCD='08' AND FLD.CVALUE<>'N'
                    and SUBSTR(cf.custodycd,4,1)  = 'C'
            ) CF_TK_TC_TN_Credit,
            (
                SELECT count(*) amt FROM
                (
                    SELECT cf.custid FROM  (SELECT * FROM CFMAST WHERE FNC_VALIDATE_SCOPE(BRID, CAREBY, TLSCOPE, pv_BRID, TLGOUPS)=0) cf
                    WHERE cf.opndate >= V_FROMDATE and cf.opndate < V_TODATE
                        AND cf.custtype = 'B'
                        AND cf.custodycd IS NOT NULL
                        and SUBSTR(cf.custodycd,4,1)  = 'C'
                        AND cf.custatcom = 'Y'
                    union all
                    SELECT vw_tllog_all.msgacct FROM vw_tllog_all,  (SELECT * FROM CFMAST WHERE FNC_VALIDATE_SCOPE(BRID, CAREBY, TLSCOPE, pv_BRID, TLGOUPS)=0) cf, VW_TLLOGFLD_ALL FLD
                    WHERE tltxcd = '0067' AND busdate >= V_TODATE AND deltd <> 'Y'
                        AND cf.custid = vw_tllog_all.msgacct AND cf.custtype = 'B'
                        AND cf.custatcom = 'Y' AND CF.custodycd IS NOT NULL
                        and SUBSTR(cf.custodycd,4,1)  = 'C'
                        AND vw_tllog_all.TXNUM=FLD.TXNUM
                        AND vw_tllog_all.TXDATE=FLD.TXDATE
                        AND FLD.FLDCD='08' AND FLD.CVALUE<>'N'
                )
            ) CF_TK_TC_TN_Debit,
            (
                SELECT count(*) amt FROM vw_tllog_all,  (SELECT * FROM CFMAST WHERE FNC_VALIDATE_SCOPE(BRID, CAREBY, TLSCOPE, pv_BRID, TLGOUPS)=0) cf, VW_TLLOGFLD_ALL FLD
                WHERE tltxcd = '0059' AND busdate >= V_FROMDATE and busdate < V_TODATE
                    AND deltd <> 'Y'
                    AND vw_tllog_all.TXNUM=FLD.TXNUM
                    AND vw_tllog_all.TXDATE=FLD.TXDATE
                    AND FLD.FLDCD='08' AND FLD.CVALUE<>'N'
                    AND cf.custid = vw_tllog_all.msgacct AND cf.custtype = 'I'
                    AND cf.custatcom = 'Y' AND CF.custodycd IS NOT NULL
                    and SUBSTR(custodycd,4,1)  = 'C'
            ) CF_TK_CN_TN_Credit,
            (
                 SELECT count(*) amt FROM
                (
                SELECT cf.custid FROM  (SELECT * FROM CFMAST WHERE FNC_VALIDATE_SCOPE(BRID, CAREBY, TLSCOPE, pv_BRID, TLGOUPS)=0) cf WHERE cf.opndate >= V_FROMDATE and cf.opndate < V_TODATE
                AND cf.custtype = 'I'
                AND cf.custodycd IS NOT NULL
                and SUBSTR(cf.custodycd,4,1)  = 'C'
                AND cf.custatcom = 'Y'
                union all
                SELECT vw_tllog_all.msgacct FROM vw_tllog_all,  (SELECT * FROM CFMAST WHERE FNC_VALIDATE_SCOPE(BRID, CAREBY, TLSCOPE, pv_BRID, TLGOUPS)=0) cf, VW_TLLOGFLD_ALL FLD
                WHERE tltxcd = '0067' AND busdate >= V_FROMDATE and busdate < V_TODATE AND deltd <> 'Y'
                AND cf.custid = vw_tllog_all.msgacct AND cf.custtype = 'I'
                AND cf.custatcom = 'Y' AND CF.custodycd IS NOT NULL
                AND SUBSTR(custodycd,4,1)  = 'C'
                AND vw_tllog_all.TXNUM=FLD.TXNUM
                AND vw_tllog_all.TXDATE=FLD.TXDATE
                AND FLD.FLDCD='08' AND FLD.CVALUE<>'N'
                )
            )CF_TK_CN_TN_Debit,
            (
                SELECT count(*) amt FROM vw_tllog_all,  (SELECT * FROM CFMAST WHERE FNC_VALIDATE_SCOPE(BRID, CAREBY, TLSCOPE, pv_BRID, TLGOUPS)=0) cf,VW_TLLOGFLD_ALL FLD
                WHERE tltxcd = '0059' AND busdate >= V_FROMDATE and busdate < V_TODATE  AND deltd <> 'Y'
                    AND cf.custid = vw_tllog_all.msgacct AND cf.custtype = 'B'
                    AND cf.custatcom = 'Y'
                    AND CF.custodycd IS NOT NULL
                    and SUBSTR(custodycd,4,1)  = 'F'
                    AND vw_tllog_all.TXNUM=FLD.TXNUM
                       AND vw_tllog_all.TXDATE=FLD.TXDATE
                        AND FLD.FLDCD='08' AND FLD.CVALUE<>'N'
            ) CF_TK_TC_NN_Credit,
            (
                SELECT count(*) amt FROM
                (
                SELECT cf.custid FROM  (SELECT * FROM CFMAST WHERE FNC_VALIDATE_SCOPE(BRID, CAREBY, TLSCOPE, pv_BRID, TLGOUPS)=0) cf  WHERE cf.opndate >= V_FROMDATE and cf.opndate < V_TODATE
                        AND cf.custtype = 'B'
                        AND cf.custodycd IS NOT NULL
                        and SUBSTR(cf.custodycd,4,1)  = 'F'
                        AND cf.custatcom = 'Y'
                union all
                SELECT vw_tllog_all.msgacct FROM vw_tllog_all,  (SELECT * FROM CFMAST WHERE FNC_VALIDATE_SCOPE(BRID, CAREBY, TLSCOPE, pv_BRID, TLGOUPS)=0) cf,VW_TLLOGFLD_ALL FLD
                    WHERE tltxcd = '0067' AND busdate >= V_FROMDATE and busdate < V_TODATE AND deltd <> 'Y'
                    AND cf.custid = vw_tllog_all.msgacct AND cf.custtype = 'B'
                    AND cf.custatcom = 'Y'
                    AND CF.custodycd IS NOT NULL
                    AND vw_tllog_all.TXNUM=FLD.TXNUM
                      AND vw_tllog_all.TXDATE=FLD.TXDATE
                         AND FLD.FLDCD='08' AND FLD.CVALUE<>'N'
                    and SUBSTR(custodycd,4,1)  = 'F'
                )
            )CF_TK_TC_NN_Debit,
            (
                SELECT count(*) amt FROM vw_tllog_all,  (SELECT * FROM CFMAST WHERE FNC_VALIDATE_SCOPE(BRID, CAREBY, TLSCOPE, pv_BRID, TLGOUPS)=0) cf, VW_TLLOGFLD_ALL FLD
                WHERE tltxcd = '0059' AND busdate >= V_FROMDATE and busdate < V_TODATE AND deltd <> 'Y'
                    AND cf.custid = vw_tllog_all.msgacct AND cf.custtype = 'I'
                    AND cf.custatcom = 'Y'
                    AND CF.custodycd IS NOT NULL
                    and SUBSTR(custodycd,4,1)  = 'F'
                    AND vw_tllog_all.TXNUM=FLD.TXNUM
                       AND vw_tllog_all.TXDATE=FLD.TXDATE
                         AND FLD.FLDCD='08' AND FLD.CVALUE<>'N'
            ) CF_TK_CN_NN_Credit,
            (
                SELECT count(*) amt FROM
                (
                    SELECT cf.custid FROM  (SELECT * FROM CFMAST WHERE FNC_VALIDATE_SCOPE(BRID, CAREBY, TLSCOPE, pv_BRID, TLGOUPS)=0) cf  WHERE cf.opndate >= V_FROMDATE and cf.opndate < V_TODATE
                        AND cf.custtype = 'I'
                        AND cf.custodycd IS NOT NULL
                        and SUBSTR(cf.custodycd,4,1)  = 'F'
                        AND cf.custatcom = 'Y'
                    union all
                    SELECT vw_tllog_all.msgacct FROM vw_tllog_all,  (SELECT * FROM CFMAST WHERE FNC_VALIDATE_SCOPE(BRID, CAREBY, TLSCOPE, pv_BRID, TLGOUPS)=0) cf,VW_TLLOGFLD_ALL FLD
                    WHERE tltxcd = '0067' AND busdate >= V_FROMDATE and busdate < V_TODATE AND deltd <> 'Y'
                        AND cf.custid = vw_tllog_all.msgacct AND cf.custtype = 'I'
                        AND cf.custatcom = 'Y'
                        AND CF.custodycd IS NOT NULL
                        and SUBSTR(custodycd,4,1)  = 'F'
                        AND vw_tllog_all.TXNUM=FLD.TXNUM
                         AND vw_tllog_all.TXDATE=FLD.TXDATE
                         AND FLD.FLDCD='08' AND FLD.CVALUE<>'N'
                )
            )CF_TK_CN_NN_Debit,
       --CUOI KY
        (
            SELECT a.amt + b.amt - c.amt FROM
            (
                SELECT count(*) amt FROM (
                    select DISTINCT cf.* from  (SELECT * FROM CFMAST WHERE FNC_VALIDATE_SCOPE(BRID, CAREBY, TLSCOPE, pv_BRID, TLGOUPS)=0) cf, afmast af
                    where cf.custid = af.custid
                        and af.status = 'A') cf
                WHERE cf.status = 'A' AND cf.custtype = 'B' AND cf.custatcom = 'Y'
                    AND cf.custodycd IS NOT NULL
                    and SUBSTR(cf.custodycd,4,1)  = 'C'
            ) a,
            (
                SELECT count(*) amt FROM vw_tllog_all,  (SELECT * FROM CFMAST WHERE FNC_VALIDATE_SCOPE(BRID, CAREBY, TLSCOPE, pv_BRID, TLGOUPS)=0) cf,VW_TLLOGFLD_ALL FLD
                WHERE tltxcd = '0059' AND busdate >= V_TODATE AND deltd <> 'Y'
                    AND cf.custid = vw_tllog_all.msgacct AND cf.custtype = 'B'
                    AND cf.custatcom = 'Y' AND cf.custodycd IS NOT NULL
                    and SUBSTR(cf.custodycd,4,1)  = 'C'
                    AND vw_tllog_all.TXNUM=FLD.TXNUM
                     AND vw_tllog_all.TXDATE=FLD.TXDATE
                      AND FLD.FLDCD='08' AND FLD.CVALUE<>'N'
            ) b,
            (
                SELECT count(*) amt FROM
                (
                    SELECT cf.custid FROM  (SELECT * FROM CFMAST WHERE FNC_VALIDATE_SCOPE(BRID, CAREBY, TLSCOPE, pv_BRID, TLGOUPS)=0) cf
                    WHERE cf.opndate >= V_TODATE
                        AND cf.custtype = 'B'
                        AND cf.custodycd IS NOT NULL
                        and SUBSTR(cf.custodycd,4,1)  = 'C'
                        AND cf.custatcom = 'Y'
                    union all
                    SELECT vw_tllog_all.msgacct FROM vw_tllog_all,  (SELECT * FROM CFMAST WHERE FNC_VALIDATE_SCOPE(BRID, CAREBY, TLSCOPE, pv_BRID, TLGOUPS)=0) cf,VW_TLLOGFLD_ALL FLD
                    WHERE tltxcd = '0067' AND busdate >= V_TODATE AND deltd <> 'Y'
                        AND cf.custid = vw_tllog_all.msgacct AND cf.custtype = 'B'
                        AND cf.custatcom = 'Y' AND CF.custodycd IS NOT NULL
                        and SUBSTR(cf.custodycd,4,1)  = 'C'
                        AND vw_tllog_all.TXNUM=FLD.TXNUM
                            AND vw_tllog_all.TXDATE=FLD.TXDATE
                              AND FLD.FLDCD='08' AND FLD.CVALUE<>'N'
                )
            ) c
        ) CF_CK_TC_TN,
       (SELECT a.amt + b.amt - c.amt FROM
            (
                SELECT count(*) amt FROM (
                    select DISTINCT cf.* from  (SELECT * FROM CFMAST WHERE FNC_VALIDATE_SCOPE(BRID, CAREBY, TLSCOPE, pv_BRID, TLGOUPS)=0) cf, afmast af
                    where cf.custid = af.custid
                        and af.status = 'A') cf
                WHERE cf.status = 'A' AND cf.custtype = 'I' AND cf.custatcom = 'Y'
                    AND cf.custodycd IS NOT NULL
                    and SUBSTR(cf.custodycd,4,1)  = 'C'
            ) a,
            (
                SELECT count(*) amt FROM vw_tllog_all,  (SELECT * FROM CFMAST WHERE FNC_VALIDATE_SCOPE(BRID, CAREBY, TLSCOPE, pv_BRID, TLGOUPS)=0) cf,VW_TLLOGFLD_ALL FLD
                WHERE tltxcd = '0059' AND busdate >= V_TODATE AND deltd <> 'Y'
                    AND cf.custid = vw_tllog_all.msgacct AND cf.custtype = 'I'
                    AND cf.custatcom = 'Y' AND CF.custodycd IS NOT NULL
                    and SUBSTR(custodycd,4,1)  = 'C'
                    AND vw_tllog_all.TXNUM=FLD.TXNUM
                       AND vw_tllog_all.TXDATE=FLD.TXDATE
                           AND FLD.FLDCD='08' AND FLD.CVALUE<>'N'
            ) b,
            (
                 SELECT count(*) amt FROM
                (SELECT cf.custid FROM  (SELECT * FROM CFMAST WHERE FNC_VALIDATE_SCOPE(BRID, CAREBY, TLSCOPE, pv_BRID, TLGOUPS)=0) cf WHERE cf.opndate >= V_TODATE
                        AND cf.custtype = 'I'
                        AND cf.custodycd IS NOT NULL
                        and SUBSTR(cf.custodycd,4,1)  = 'C'
                        AND cf.custatcom = 'Y'
                union all
                SELECT vw_tllog_all.msgacct FROM vw_tllog_all,  (SELECT * FROM CFMAST WHERE FNC_VALIDATE_SCOPE(BRID, CAREBY, TLSCOPE, pv_BRID, TLGOUPS)=0) cf,VW_TLLOGFLD_ALL FLD
                    WHERE tltxcd = '0067' AND busdate >= V_TODATE AND deltd <> 'Y'
                    AND cf.custid = vw_tllog_all.msgacct AND cf.custtype = 'I'
                    AND cf.custatcom = 'Y' AND CF.custodycd IS NOT NULL
                    and SUBSTR(custodycd,4,1)  = 'C'
                    AND vw_tllog_all.TXNUM=FLD.TXNUM
                      AND vw_tllog_all.TXDATE=FLD.TXDATE
                      AND FLD.FLDCD='08' AND FLD.CVALUE<>'N'
                )
            )c
       ) CF_CK_CN_TN,
       (SELECT a.amt + b.amt - c.amt FROM
            (SELECT count(*) amt FROM (
                    select DISTINCT cf.* from  (SELECT * FROM CFMAST WHERE FNC_VALIDATE_SCOPE(BRID, CAREBY, TLSCOPE, pv_BRID, TLGOUPS)=0) cf, afmast af
                    where cf.custid = af.custid
                        and af.status = 'A') cf WHERE STATUS = 'A'
                    AND cf.custtype = 'B' AND cf.custodycd IS NOT NULL
                    and SUBSTR(cf.custodycd,4,1)  = 'F' AND cf.custatcom = 'Y'
            ) a,
            (SELECT count(*) amt FROM vw_tllog_all,  (SELECT * FROM CFMAST WHERE FNC_VALIDATE_SCOPE(BRID, CAREBY, TLSCOPE, pv_BRID, TLGOUPS)=0) cf,VW_TLLOGFLD_ALL FLD
                WHERE tltxcd = '0059' AND busdate >= V_TODATE  AND deltd <> 'Y'
                AND cf.custid = vw_tllog_all.msgacct AND cf.custtype = 'B'
                AND cf.custatcom = 'Y' AND CF.custodycd IS NOT NULL
                and SUBSTR(custodycd,4,1)  = 'F'
                AND vw_tllog_all.TXNUM=FLD.TXNUM
                   AND vw_tllog_all.TXDATE=FLD.TXDATE
               AND FLD.FLDCD='08' AND FLD.CVALUE<>'N'
            ) b,
            (
                SELECT count(*) amt FROM
                (SELECT cf.custid FROM  (SELECT * FROM CFMAST WHERE FNC_VALIDATE_SCOPE(BRID, CAREBY, TLSCOPE, pv_BRID, TLGOUPS)=0) cf  WHERE cf.opndate >= V_TODATE
                        AND cf.custtype = 'B'
                        AND cf.custodycd IS NOT NULL
                        and SUBSTR(cf.custodycd,4,1)  = 'F'
                        AND cf.custatcom = 'Y'
                union all
                SELECT vw_tllog_all.msgacct FROM vw_tllog_all,  (SELECT * FROM CFMAST WHERE FNC_VALIDATE_SCOPE(BRID, CAREBY, TLSCOPE, pv_BRID, TLGOUPS)=0) cf,VW_TLLOGFLD_ALL FLD
                    WHERE tltxcd = '0067' AND busdate >= V_TODATE AND deltd <> 'Y'
                    AND cf.custid = vw_tllog_all.msgacct AND cf.custtype = 'B'
                    AND cf.custatcom = 'Y' AND CF.custodycd IS NOT NULL
                    and SUBSTR(custodycd,4,1)  = 'F'
                    AND vw_tllog_all.TXNUM=FLD.TXNUM
                      AND vw_tllog_all.TXDATE=FLD.TXDATE
                        AND FLD.FLDCD='08' AND FLD.CVALUE<>'N'
                )
            )c
       ) CF_CK_TC_NN,
       (SELECT a.amt + b.amt - c.amt FROM
            (
                SELECT count(*) amt FROM (
                    select DISTINCT cf.* from  (SELECT * FROM CFMAST WHERE FNC_VALIDATE_SCOPE(BRID, CAREBY, TLSCOPE, pv_BRID, TLGOUPS)=0) cf, afmast af
                    where cf.custid = af.custid
                        and af.status = 'A') cf WHERE STATUS = 'A'
                    AND cf.custtype = 'I'
                    AND cf.custodycd IS NOT NULL
                    and SUBSTR(cf.custodycd,4,1)  = 'F'
                    AND cf.custatcom = 'Y'
            ) a,
            (
                SELECT count(*) amt FROM vw_tllog_all,  (SELECT * FROM CFMAST WHERE FNC_VALIDATE_SCOPE(BRID, CAREBY, TLSCOPE, pv_BRID, TLGOUPS)=0) cf,VW_TLLOGFLD_ALL FLD
                WHERE tltxcd = '0059' AND busdate >= V_TODATE AND deltd <> 'Y'
                    AND cf.custid = vw_tllog_all.msgacct AND cf.custtype = 'I'
                    AND cf.custatcom = 'Y'
                    AND CF.custodycd IS NOT NULL
                    and SUBSTR(custodycd,4,1)  = 'F'
                    AND vw_tllog_all.TXNUM=FLD.TXNUM
                     AND vw_tllog_all.TXDATE=FLD.TXDATE
                      AND FLD.FLDCD='08' AND FLD.CVALUE<>'N'
            ) b,
            (
                SELECT count(*) amt FROM
                (
                    SELECT cf.custid FROM  (SELECT * FROM CFMAST WHERE FNC_VALIDATE_SCOPE(BRID, CAREBY, TLSCOPE, pv_BRID, TLGOUPS)=0) cf  WHERE cf.opndate >= V_TODATE
                        AND cf.custtype = 'I'
                        AND cf.custodycd IS NOT NULL
                        and SUBSTR(cf.custodycd,4,1)  = 'F'
                        AND cf.custatcom = 'Y'
                    union all
                    SELECT vw_tllog_all.msgacct FROM vw_tllog_all,  (SELECT * FROM CFMAST WHERE FNC_VALIDATE_SCOPE(BRID, CAREBY, TLSCOPE, pv_BRID, TLGOUPS)=0) cf,VW_TLLOGFLD_ALL FLD
                    WHERE tltxcd = '0067' AND busdate >= V_TODATE AND deltd <> 'Y'
                        AND cf.custid = vw_tllog_all.msgacct AND cf.custtype = 'I'
                        AND cf.custatcom = 'Y'
                        AND CF.custodycd IS NOT NULL
                        and SUBSTR(custodycd,4,1)  = 'F'
                        AND vw_tllog_all.TXNUM=FLD.TXNUM
                         AND vw_tllog_all.TXDATE=FLD.TXDATE
                          AND FLD.FLDCD='08' AND FLD.CVALUE<>'N'
                )
            )c
       ) CF_CK_CN_NN
    FROM DUAL ) A,
        (
            SELECT sum( CASE WHEN SUBSTR(cf.custodycd,4,1)  = 'F' AND cf.custtype = 'I' THEN 1 ELSE 0 END) TK_CN_NN_Trade,
               sum( CASE WHEN SUBSTR(cf.custodycd,4,1)  = 'F' AND cf.custtype = 'B' THEN 1 ELSE 0 END) TK_TC_NN_Trade,
               sum( CASE WHEN SUBSTR(cf.custodycd,4,1)  = 'C' AND cf.custtype = 'I' THEN 1 ELSE 0 END) TK_CN_TN_Trade,
               sum( CASE WHEN SUBSTR(cf.custodycd,4,1)  = 'C' AND cf.custtype = 'B' THEN 1 ELSE 0 END) TK_TC_TN_Trade
            FROM (select distinct cf.custid from vw_odmast_all od, afmast af,  (SELECT * FROM CFMAST WHERE FNC_VALIDATE_SCOPE(BRID, CAREBY, TLSCOPE, pv_BRID, TLGOUPS)=0) cf
             where od.txdate BETWEEN V_FROMDATE AND V_TODATE and od.execqtty <> 0
                and od.afacctno = af.acctno and af.custid = cf.custid
             ) od,
                 (SELECT * FROM CFMAST WHERE FNC_VALIDATE_SCOPE(BRID, CAREBY, TLSCOPE, pv_BRID, TLGOUPS)=0) cf
            WHERE od.custid = cf.custid
        ) B */;

EXCEPTION
   WHEN OTHERS
   THEN

      RETURN;
End;
 
 
 
 
/
