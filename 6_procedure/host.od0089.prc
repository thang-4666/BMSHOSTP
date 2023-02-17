SET DEFINE OFF;
CREATE OR REPLACE PROCEDURE od0089 (
   PV_REFCURSOR             IN OUT   PKG_REPORT.REF_CURSOR,
   OPT                      IN       VARCHAR2,
   pv_BRID                     IN       VARCHAR2,
   TLGOUPS        IN       VARCHAR2,
   TLSCOPE        IN       VARCHAR2,
   I_DATE                   IN       VARCHAR2,
   PV_CUSTODYCD             IN       VARCHAR2,
   PV_AFACCTNO              IN       VARCHAR2,
   PV_CASHPLACE             IN       VARCHAR2,
   PV_TRADEPLACE            IN       VARCHAR2,
   PV_SECTYPE               IN       VARCHAR2,
   PV_CUSTODYPLACE          IN       VARCHAR2
---   PV_BRID                  IN       VARCHAR2
   )
IS
-- MODIFICATION HISTORY
-- KET QUA KHOP LENH CUA KHACH HANG
-- PERSON      DATE    COMMENTS
-- DUNGNH   14-May-12  CREATED
-- ---------   ------  -------------------------------------------
   V_STROPTION      VARCHAR2 (5);            -- A: ALL; B: BRANCH; S: SUB-BRANCH
   V_STRBRID        VARCHAR2 (40);            -- USED WHEN V_NUMOPTION > 0
   V_INBRID         VARCHAR2 (4);

   V_CURRDATE       DATE;
   V_INDATE         DATE;

--   V_T0_DATE        DATE;
--   V_T1_DATE        DATE;
--   V_T2_DATE        DATE;
--   V_T3_DATE        DATE;

   V_STRCUSTODYCD   VARCHAR2 (20);
   V_STRAFACCTNO    VARCHAR2 (20);
   V_STRCASHPLACE   VARCHAR2 (50);
   V_STRTRADEPLACE  VARCHAR2 (10);
   V_STRSECTYPE     VARCHAR2 (10);

   V_CUSTODYPLACE   VARCHAR2(100);
   V_STRBRNAME      VARCHAR2 (500);

-- DECLARE PROGRAM VARIABLES AS SHOWN ABOVE
BEGIN

   V_STROPTION := OPT;
   V_INBRID := pv_BRID;

   IF (V_STROPTION = 'A') THEN
         V_STRBRID := '%';
         V_STRBRNAME := 'ALL';
   ELSE if (V_STROPTION = 'B') then
            select brgrp.mapid into V_STRBRID from brgrp where brgrp.brid = V_INBRID;
            select nvl(description,brname) into V_STRBRNAME From BRGRP where brid = V_INBRID;
        else
            V_STRBRID := V_INBRID;
            select brname into V_STRBRNAME From BRGRP where brid = V_INBRID;
        end if;
   END IF;

   select to_date(varvalue,'dd/mm/rrrr') into V_CURRDATE from sysvar where grname = 'SYSTEM' and varname = 'CURRDATE';
   V_INDATE := to_date(I_DATE,'dd/mm/rrrr');

/*   V_T0_DATE := getduedate(V_INDATE, 'B', '000', 0);
   V_T1_DATE := getduedate(V_INDATE, 'B', '000', 1);
   V_T2_DATE := getduedate(V_INDATE, 'B', '000', 2);
   V_T3_DATE := getduedate(V_INDATE, 'B', '000', 3);*/


   if(upper(PV_CUSTODYCD) = 'ALL' or PV_CUSTODYCD is null)then
        V_STRCUSTODYCD := '%';
   else
        V_STRCUSTODYCD := upper(PV_CUSTODYCD);
   end if;

   if(upper(PV_AFACCTNO) = 'ALL' or PV_AFACCTNO is null)then
        V_STRAFACCTNO := '%';
   else
        V_STRAFACCTNO := upper(PV_AFACCTNO);
   end if;

   IF (PV_CASHPLACE <> 'ALL') THEN
        V_STRCASHPLACE := PV_CASHPLACE;
   ELSE
        V_STRCASHPLACE := '%';
   END IF;

   IF (PV_TRADEPLACE <> 'ALL' OR PV_TRADEPLACE <> '') THEN
        V_STRTRADEPLACE := PV_TRADEPLACE;
   ELSE
        V_STRTRADEPLACE := '%';
   END IF;


   IF (PV_SECTYPE = '000') THEN
        V_STRSECTYPE := '%';
   ELSE
        V_STRSECTYPE := PV_SECTYPE;
   END IF;

   IF (PV_CUSTODYPLACE <> 'ALL' OR PV_CUSTODYPLACE <> '')
    THEN
         V_CUSTODYPLACE    :=    CASE WHEN PV_CUSTODYPLACE='001' then 'Y' else 'N' end;
    ELSE
         V_CUSTODYPLACE    :=    '%';
    END IF;

-- GET REPORT'S DATA

OPEN PV_REFCURSOR
FOR
select 'DDD' suborder, od.clearday, od.txdate,
    sum(case when od.exectype = 'NB' then od.execamt else 0 end) tt_mua,

    sum(case when od.exectype = 'NB' then (case when od.txdate = V_CURRDATE and od.feeacr = 0 then
            ROUND(od.execamt * odt.deffeerate / 100, 2)
            else od.feeacr end) else 0 end) tt_phi_mua,

    sum(case when od.exectype in ('NS','SS','MS') then od.execamt else 0 end)tt_ban,

    sum(case when od.exectype in ('NS','SS','MS') then (case when od.txdate = V_CURRDATE and od.feeacr = 0 then
            ROUND(od.execamt * odt.deffeerate / 100, 2)
            else od.feeacr end) else 0 end) tt_phi_ban,

    sum(CASE WHEN cf.vat = 'Y' or cf.whtax ='Y' then od.taxsellamt else 0 end) tt_tncn,

    V_CURRDATE currdate, V_INDATE indate,

    (case when V_STRCUSTODYCD = '%' then 'ALL' else V_STRCUSTODYCD end) STRCUSTODYCD,
    (case when V_STRAFACCTNO = '%' then 'ALL' else V_STRAFACCTNO end) STRAFACCTNO,
    (case when V_STRCASHPLACE = '%' then 'ALL' else V_STRCASHPLACE end) STRCASHPLACE,
    (case when V_STRTRADEPLACE = '%' then 'ALL' else V_STRTRADEPLACE end) STRTRADEPLACE,
    (case when V_STRSECTYPE = '%' then 'ALL' else V_STRSECTYPE end) STRSECTYPE, V_STRBRNAME STRBRID

    from vw_odmast_tradeplace_all od, odtype odt,
        (select * from afmast
        where (case when PV_CASHPLACE = 'ALL' then 'ALL'
                when PV_CASHPLACE = '000' or PV_CASHPLACE = '---' then corebank
                when PV_CASHPLACE = '111' then corebank
                else corebank || bankname end)
                = (case when PV_CASHPLACE = 'ALL' then 'ALL'
                when PV_CASHPLACE = '000'  or PV_CASHPLACE = '---' then 'N'
                when PV_CASHPLACE = '111'  then 'Y'
                else 'Y' || V_STRTRADEPLACE  end )) af, aftype aft,  (SELECT * FROM CFMAST WHERE FNC_VALIDATE_SCOPE(BRID, CAREBY, TLSCOPE, pv_BRID, TLGOUPS)=0) cf,
        vw_stschd_all sts, sbsecurities sb
    where od.deltd <> 'Y'
        and od.execamt > 0
        and OD.ACTYPE = ODT.ACTYPE
        and od.afacctno = af.acctno
        and af.actype = aft.actype
        and af.custid = cf.custid
        and od.exectype in ('NS','SS','MS','NB')
        and sts.duetype in ('RM','SM')
        and sts.orgorderid = od.orderid
        and od.codeid = sb.codeid
        and sts.cleardate = V_INDATE
        and cf.custatcom like V_CUSTODYPLACE
        and (af.brid like V_STRBRID or instr(V_STRBRID,af.brid) <> 0)
        and sb.sectype like V_STRSECTYPE
        and (case when V_STRTRADEPLACE = '999' and od.tradeplace in ('001','002') then '999'
                        else od.tradeplace end ) like V_STRTRADEPLACE
        and cf.custodycd like V_STRCUSTODYCD
        and af.acctno like V_STRAFACCTNO
group by od.clearday, od.txdate
union all
select 'TTT' suborder, 20 clearday, od.txdate,
    sum(case when od.exectype = 'NB' then od.execamt else 0 end) tt_mua,

    sum(case when od.exectype = 'NB' then (case when od.txdate = V_CURRDATE and od.feeacr = 0 then
            ROUND(od.execamt * odt.deffeerate / 100, 2)
            else od.feeacr end) else 0 end) tt_phi_mua,

    sum(case when od.exectype in ('NS','SS','MS') then od.execamt else 0 end)tt_ban,

    sum(case when od.exectype in ('NS','SS','MS') then (case when od.txdate = V_CURRDATE and od.feeacr = 0 then
            ROUND(od.execamt * odt.deffeerate / 100, 2)
            else od.feeacr end) else 0 end) tt_phi_ban,

    sum(CASE WHEN cf.vat = 'Y' or cf.whtax ='Y' then od.taxsellamt else 0 end) tt_tncn,

    V_CURRDATE currdate, V_INDATE indate,

    (case when V_STRCUSTODYCD = '%' then 'ALL' else V_STRCUSTODYCD end) STRCUSTODYCD,
    (case when V_STRAFACCTNO = '%' then 'ALL' else V_STRAFACCTNO end) STRAFACCTNO,
    (case when V_STRCASHPLACE = '%' then 'ALL' else V_STRCASHPLACE end) STRCASHPLACE,
    (case when V_STRTRADEPLACE = '%' then 'ALL' else V_STRTRADEPLACE end) STRTRADEPLACE,
    (case when V_STRSECTYPE = '%' then 'ALL' else V_STRSECTYPE end) STRSECTYPE, V_STRBRNAME STRBRID

    from vw_odmast_tradeplace_all od, odtype odt,
        (select * from afmast
        where (case when PV_CASHPLACE = 'ALL' then 'ALL'
                when PV_CASHPLACE = '000' or PV_CASHPLACE = '---' then corebank
                when PV_CASHPLACE = '111' then corebank
                else corebank || bankname end)
                = (case when PV_CASHPLACE = 'ALL' then 'ALL'
                when PV_CASHPLACE = '000'  or PV_CASHPLACE = '---' then 'N'
                when PV_CASHPLACE = '111'  then 'Y'
                else 'Y' || V_STRTRADEPLACE end )) af, aftype aft, cfmast cf,
        vw_stschd_all sts, sbsecurities sb
    where od.deltd <> 'Y'
        and sts.deltd <> 'Y'
        and od.execamt > 0
        and OD.ACTYPE = ODT.ACTYPE
        and od.afacctno = af.acctno
        and af.actype = aft.actype
        and af.custid = cf.custid
        and od.exectype in ('NS','SS','MS','NB')
        and sts.duetype in ('RM','SM')
        and sts.orgorderid = od.orderid
        and od.codeid = sb.codeid
        and sts.cleardate = V_INDATE
        and cf.custatcom like V_CUSTODYPLACE
        and (af.brid like V_STRBRID or instr(V_STRBRID,af.brid) <> 0)
        and sb.sectype like V_STRSECTYPE
        and (case when V_STRTRADEPLACE = '999' and od.tradeplace in ('001','002') then '999'
                        else od.tradeplace end ) like V_STRTRADEPLACE
        and cf.custodycd like V_STRCUSTODYCD
        and af.acctno like V_STRAFACCTNO
group by  od.txdate
;
EXCEPTION
   WHEN OTHERS
   THEN
        RETURN;
END;

 
 
 
 
/
