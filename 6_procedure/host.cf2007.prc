SET DEFINE OFF;
CREATE OR REPLACE PROCEDURE "CF2007" (
   PV_REFCURSOR   IN OUT   PKG_REPORT.REF_CURSOR,
   OPT            IN       VARCHAR2,
   pv_BRID           IN       VARCHAR2,
   TLGOUPS        IN       VARCHAR2,
   TLSCOPE        IN       VARCHAR2,
   F_DATE         IN       VARCHAR2,
   T_DATE         IN       VARCHAR2
 )
IS
--

   V_STROPTION    VARCHAR2 (5);            -- A: ALL; B: BRANCH; S: SUB-BRANCH
   V_STRBRID      VARCHAR2 (40);            -- USED WHEN V_NUMOPTION > 0
   V_INBRID     VARCHAR2 (5);      -- USED WHEN V_NUMOPTION > 0

   V_TODATE     DATE;
   V_FROMDATE   DATE;

   V_TO_6MONTH   DATE;
   V_FR_6MONTH   DATE;

BEGIN

   V_STROPTION := upper(OPT);
   V_INBRID := pv_BRID;

   if(V_STROPTION = 'A') then
        V_STRBRID := '%';
    else
        if(V_STROPTION = 'B') then
            select br.mapid into V_STRBRID from brgrp br where  br.brid = V_INBRID;
        else
            V_STRBRID := pv_BRID;
        end if;
    end if;

    V_FROMDATE := to_date(F_DATE,'DD/MM/RRRR');
    V_TODATE := to_date(T_DATE,'DD/MM/RRRR');

    IF V_FROMDATE > TO_DATE ('31/05/' || SUBSTR(F_DATE,7,4),'DD/MM/RRRR') THEN
        V_FR_6MONTH:= to_date('01/06/'|| SUBSTR(F_DATE,7,4),'DD/MM/RRRR');
    ELSE
        V_FR_6MONTH:= to_date('01/01/'|| SUBSTR(F_DATE,7,4),'DD/MM/RRRR');
    END IF;

    IF SUBSTR(T_DATE,4,2) IN ('06','12') THEN
       V_TO_6MONTH:= V_TODATE;
    ELSE
       V_TO_6MONTH:=  to_date('01/01/1900','DD/MM/RRRR');
    END IF;





OPEN PV_REFCURSOR FOR

/*  SELECT SECTYPE, SUM(execamt) EXEAMT FROM
(
    select CASE
        WHEN SB.SECTYPE IN ('001','002') and substr(cf.custodycd,4,1) = 'F' AND cf.custtype = 'B' and bors = 'B' THEN '1 - Co phieu nuoc ngoai to chuc mua'
        WHEN SB.SECTYPE IN ('001','002') and substr(cf.custodycd,4,1) = 'F' AND cf.custtype = 'I' and bors = 'B' THEN '11 - Co phieu nuoc ngoai ca nhan mua'
        WHEN SB.SECTYPE IN ('003','006') and substr(cf.custodycd,4,1) = 'F' AND cf.custtype = 'B' and bors = 'B' THEN '12 - Trai phieu nuoc ngoai to chuc mua'
        WHEN SB.SECTYPE IN ('003','006') and substr(cf.custodycd,4,1) = 'F' AND cf.custtype = 'I' and bors = 'B' THEN '13 - Trai phieu nuoc ngoai ca nhan mua'
        WHEN SB.SECTYPE IN ('008') and substr(cf.custodycd,4,1) = 'F' AND cf.custtype = 'B' and bors = 'B' THEN '14 - Chung chi quy nuoc ngoai to chuc mua'
        WHEN SB.SECTYPE IN ('008') and substr(cf.custodycd,4,1) = 'F' AND cf.custtype = 'I' and bors = 'B' THEN '15 - Chung chi quy nuoc ngoai ca nhan mua'
        WHEN SB.SECTYPE NOT IN ('008','001','002','003','006') and substr(cf.custodycd,4,1) = 'F' AND cf.custtype = 'B' and bors = 'B' THEN '16 - Khac nuoc ngoai to chuc mua'
        WHEN SB.SECTYPE NOT IN ('008','001','002','003','006') and substr(cf.custodycd,4,1) = 'F' AND cf.custtype = 'I' and bors = 'B' THEN '17 - Khac nuoc ngoai ca nhan mua'

        WHEN SB.SECTYPE IN ('001','002') and substr(cf.custodycd,4,1) = 'F' AND cf.custtype = 'B' and bors = 'S' THEN '2 - Co phieu nuoc ngoai to chuc ban'
        WHEN SB.SECTYPE IN ('001','002') and substr(cf.custodycd,4,1) = 'F' AND cf.custtype = 'I' and bors = 'S' THEN '21 - Co phieu nuoc ngoai ca nhan ban'
        WHEN SB.SECTYPE IN ('003','006') and substr(cf.custodycd,4,1) = 'F' AND cf.custtype = 'B' and bors = 'S' THEN '22 - Trai phieu nuoc ngoai to chuc ban'
        WHEN SB.SECTYPE IN ('003','006') and substr(cf.custodycd,4,1) = 'F' AND cf.custtype = 'I' and bors = 'S' THEN '23 - Trai phieu nuoc ngoai ca nhan ban'
        WHEN SB.SECTYPE IN ('008') and substr(cf.custodycd,4,1) = 'F' AND cf.custtype = 'B' and bors = 'S' THEN '24 - Chung chi quy nuoc ngoai to chuc ban'
        WHEN SB.SECTYPE IN ('008') and substr(cf.custodycd,4,1) = 'F' AND cf.custtype = 'I' and bors = 'S' THEN '25 - Chung chi quy nuoc ngoai ca nhan ban'
        WHEN SB.SECTYPE NOT IN ('008','001','002','003','006') and substr(cf.custodycd,4,1) = 'F' AND cf.custtype = 'B' and bors = 'S' THEN '26 - Khac nuoc ngoai to chuc ban'
        WHEN SB.SECTYPE NOT IN ('008','001','002','003','006') and substr(cf.custodycd,4,1) = 'F' AND cf.custtype = 'I' and bors = 'S' THEN '27 - Khac nuoc ngoai ca nhan ban'

        WHEN substr(cf.custodycd,4,1) <> 'F' AND bors = 'B' THEN '37 - TRONG NUOC MUA'
        WHEN substr(cf.custodycd,4,1) <> 'F' AND bors = 'S' THEN '38 - TRONG NUOC BAN'
        END SECTYPE,
        EXECAMT
    from (
        select orgorderid, txdate , CUSTODYCD,codeid,symbol, bors, matchprice, matchqtty, matchprice * matchqtty / 1000000 execamt
        from iodhist where deltd <> 'Y'
        union all
        select orgorderid, txdate, CUSTODYCD, codeid,symbol, bors, matchprice,matchqtty,  matchprice * matchqtty / 1000000 execamt
        from iod where deltd <> 'Y'
    ) od, sbsecurities sb, cfmast cf
    where OD.CODEID = SB.CODEID
    and  od.custodycd = cf.custodycd
    and TXDATE BETWEEN V_FROMDATE AND V_TODATE

    union all
    select '1 - Co phieu nuoc ngoai to chuc mua' SECTYPE, 0 EXECAMT FROM DUAL
    UNION ALL
    select '11 - Co phieu nuoc ngoai ca nhan mua' SECTYPE, 0 EXECAMT FROM DUAL
    union all
    select '12 - Trai phieu nuoc ngoai to chuc mua' SECTYPE, 0 EXECAMT FROM DUAL
    union all
    select '13 - Trai phieu nuoc ngoai ca nhan mua' SECTYPE, 0 EXECAMT FROM DUAL
    union all
    select '14 - Chung chi quy nuoc ngoai to chuc mua' SECTYPE, 0 EXECAMT FROM DUAL
    union all
    select '15 - Chung chi quy nuoc ngoai ca nhan mua' SECTYPE, 0 EXECAMT FROM DUAL
    union all
    select '2 - Co phieu nuoc ngoai to chuc ban' SECTYPE, 0 EXECAMT FROM DUAL
    union all
    select '21 - Co phieu nuoc ngoai ca nhan ban' SECTYPE, 0 EXECAMT FROM DUAL
    union all
    select '22 - Trai phieu nuoc ngoai to chuc ban' SECTYPE, 0 EXECAMT FROM DUAL
    union all
    select '23 - Trai phieu nuoc ngoai ca nhan ban' SECTYPE, 0 EXECAMT FROM DUAL
    union all
    select '24 - Chung chi quy nuoc ngoai to chuc ban' SECTYPE, 0 EXECAMT FROM DUAL
    union all
    select '25 - Chung chi quy nuoc ngoai ca nhan ban' SECTYPE, 0 EXECAMT FROM DUAL
    union all
    select '26 - Khac nuoc ngoai to chuc ban' SECTYPE, 0 EXECAMT FROM DUAL
    union all
    select '27 - Khac nuoc ngoai ca nhan ban' SECTYPE, 0 EXECAMT FROM DUAL
    union all

    select '30 - Co tuc bang tien nuoc ngoai' , NVL(sum(namt),0)/ 1000000 execamt from vw_citran_gen ci
    where tltxcd in ('3350','3354') and field = 'BALANCE' and txtype = 'C'
    and substr(custodycd,4,1) = 'F'
    and busdate BETWEEN V_FR_6MONTH AND V_TO_6MONTH

    union all

    select '31 - Co tuc bang CP nuoc ngoai' , NVL(sum(namt),0)/ 1000000 execamt from vw_citran_gen ci
    where tltxcd in ('3351') and field = 'TRADE' and txtype = 'C'
    and substr(custodycd,4,1) = 'F'
    and busdate BETWEEN V_FR_6MONTH AND V_TO_6MONTH

    union all
    select '37 - TRONG NUOC MUA' SECTYPE, 0 EXECAMT FROM DUAL
    union all
    select '38 - TRONG NUOC BAN' SECTYPE, 0 EXECAMT FROM DUAL

) GROUP BY SECTYPE

order by sectype;*/


SELECT * FROM (
select
sum(case when SB.SECTYPE IN ('001','002') and substr(cf.custodycd,4,1) = 'F' AND cf.custtype = 'B' and bors = 'B' THEN execamt else 0 end ) CP_NN_TC_MUA,
sum(case when SB.SECTYPE IN ('001','002') and substr(cf.custodycd,4,1) = 'F' AND cf.custtype = 'I' and bors = 'B' THEN execamt else 0 end ) CP_NN_CN_MUA,
sum(case when SB.SECTYPE IN ('003','006') and substr(cf.custodycd,4,1) = 'F' AND cf.custtype = 'B' and bors = 'B' THEN execamt else 0 end ) TP_NN_TC_MUA,
sum(case when SB.SECTYPE IN ('003','006') and substr(cf.custodycd,4,1) = 'F' AND cf.custtype = 'I' and bors = 'B' THEN execamt else 0 end ) TP_NN_CN_MUA,
sum(case when SB.SECTYPE IN ('008') and substr(cf.custodycd,4,1) = 'F' AND cf.custtype = 'B' and bors = 'B' THEN execamt else 0 end ) CCQ_NN_TC_MUA,
sum(case when SB.SECTYPE IN ('008') and substr(cf.custodycd,4,1) = 'F' AND cf.custtype = 'I' and bors = 'B' THEN execamt else 0 end ) CCQ_NN_CN_MUA,
sum(case when SB.SECTYPE NOT IN ('008','001','002','003','006') and substr(cf.custodycd,4,1) = 'F' AND cf.custtype = 'B' and bors = 'B' THEN execamt else 0 end ) KHAC_NN_TC_MUA,
sum(case when SB.SECTYPE NOT IN ('008','001','002','003','006') and substr(cf.custodycd,4,1) = 'F' AND cf.custtype = 'I' and bors = 'B' THEN execamt else 0 end ) KHAC_NN_CN_MUA,

sum(case when SB.SECTYPE IN ('001','002') and substr(cf.custodycd,4,1) = 'F' AND cf.custtype = 'B' and bors = 'S' THEN execamt else 0 end ) CP_NN_TC_BAN,
sum(case when SB.SECTYPE IN ('001','002') and substr(cf.custodycd,4,1) = 'F' AND cf.custtype = 'I' and bors = 'S' THEN execamt else 0 end ) CP_NN_CN_BAN,
sum(case when SB.SECTYPE IN ('003','006') and substr(cf.custodycd,4,1) = 'F' AND cf.custtype = 'B' and bors = 'S' THEN execamt else 0 end ) TP_NN_TC_BAN,
sum(case when SB.SECTYPE IN ('003','006') and substr(cf.custodycd,4,1) = 'F' AND cf.custtype = 'I' and bors = 'S' THEN execamt else 0 end ) TP_NN_CN_BAN,
sum(case when SB.SECTYPE IN ('008') and substr(cf.custodycd,4,1) = 'F' AND cf.custtype = 'B' and bors = 'S' THEN execamt else 0 end ) CCQ_NN_TC_BAN,
sum(case when SB.SECTYPE IN ('008') and substr(cf.custodycd,4,1) = 'F' AND cf.custtype = 'I' and bors = 'S' THEN execamt else 0 end ) CCQ_NN_CN_BAN,
sum(case when SB.SECTYPE NOT IN ('008','001','002','003','006') and substr(cf.custodycd,4,1) = 'F' AND cf.custtype = 'B' and bors = 'S' THEN execamt else 0 end ) KHAC_NN_TC_BAN,
sum(case when SB.SECTYPE NOT IN ('008','001','002','003','006') and substr(cf.custodycd,4,1) = 'F' AND cf.custtype = 'I' and bors = 'S' THEN execamt else 0 end ) KHAC_NN_CN_BAN

from (
    select orgorderid, txdate , CUSTODYCD,codeid,symbol, bors, matchprice, matchqtty, matchprice * matchqtty /1000000 execamt
    from iodhist where deltd <> 'Y'
    union all
    select orgorderid, txdate, CUSTODYCD, codeid,symbol, bors, matchprice,matchqtty,  matchprice * matchqtty /1000000 execamt
    from iod where deltd <> 'Y'
) od, sbsecurities sb, (SELECT * FROM CFMAST WHERE FNC_VALIDATE_SCOPE(BRID, CAREBY, TLSCOPE, pv_BRID, TLGOUPS)=0) cf
where OD.CODEID = SB.CODEID
and  od.custodycd = cf.custodycd
and TXDATE BETWEEN V_FROMDATE AND V_TODATE
),
(   select round(NVL(sum(namt),0)/1000000,1) CI_NN
    from vw_citran_gen ci
    where tltxcd in ('3350','3354') and field = 'BALANCE' and txtype = 'C'
    and substr(custodycd,4,1) = 'F'
    and (trdesc like utf8nums.C_CF2007_COPHIEU or trdesc like utf8nums.C_CF2007_LAI_TP  or trdesc like utf8nums.C_CF2007_CP_LE )
    and busdate BETWEEN V_FR_6MONTH AND V_TO_6MONTH
),
(
select round(NVL(sum(namt),0)/1000000,1) SE_NN from vw_setran_gen ci
    where tltxcd in ('3351') and field = 'TRADE' and txtype = 'C'
    and substr(custodycd,4,1) = 'F'
    and busdate BETWEEN V_FR_6MONTH AND V_TO_6MONTH
)
;



EXCEPTION
   WHEN OTHERS
   THEN

      RETURN;
End;
 
 
 
 
/
