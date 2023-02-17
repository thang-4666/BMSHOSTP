SET DEFINE OFF;
CREATE OR REPLACE PROCEDURE "SE0074" (
   PV_REFCURSOR   IN OUT   PKG_REPORT.REF_CURSOR,
   OPT            IN       VARCHAR2,
   PV_BRID           IN       VARCHAR2,
   TLGOUPS        IN       VARCHAR2,
   TLSCOPE        IN       VARCHAR2,
   F_DATE         IN       VARCHAR2,
   T_DATE         IN       VARCHAR2,
   PV_CUSTODYCD       IN       VARCHAR2, --CUSTODYCD
   PV_AFACCTNO         IN       VARCHAR2,
   PV_ISCOREBANK         IN       VARCHAR2,
   BANKNAME         IN       VARCHAR2,
   PLSENT         IN       VARCHAR2
   )
IS
--Bao cao tong hop phi luu ky
--created by CHaunh at 03/03/2012

-- ---------   ------  -------------------------------------------

   V_STROPTION    VARCHAR2 (5);            -- A: ALL; B: BRANCH; S: SUB-BRANCH
   V_STRBRID      VARCHAR2 (40);            -- USED WHEN V_NUMOPTION > 0
   V_INBRID     VARCHAR2 (5);            -- USED WHEN V_NUMOPTION > 0
   V_STRCUSTODYCD  VARCHAR2 (20);
   V_STRAFACCTNO               VARCHAR2(20);
   V_ISCOREBANK               VARCHAR2(20);
   V_STRBANKNAME               VARCHAR2(100);
   V_STRPLSENT               VARCHAR2(50);
   v_FrDate                DATE;
   V_ToDate                 DATE;
   V_run            number(2);


BEGIN
   V_STROPTION := upper(OPT);
   V_INBRID := PV_BRID;

   if(V_STROPTION = 'A') then
        V_STRBRID := '%';
    else
        if(V_STROPTION = 'B') then
            select br.mapid into V_STRBRID from brgrp br where  br.brid = V_INBRID;
        else
            V_STRBRID := PV_BRID;
        end if;
    end if;

   v_FrDate := to_date(F_DATE,'DD/MM/RRRR');
   v_ToDate   := to_date(T_DATE,'DD/MM/RRRR');



   IF(PV_CUSTODYCD = 'ALL' or PV_CUSTODYCD is null )
   THEN
        V_STRCUSTODYCD := '%%';
   ELSE
        V_STRCUSTODYCD := PV_CUSTODYCD;
   END IF;

   IF(PV_AFACCTNO = 'ALL' OR PV_AFACCTNO IS NULL)
    THEN
       V_STRAFACCTNO := '%';
   ELSE
       V_STRAFACCTNO := PV_AFACCTNO;
   END IF;

   IF(PLSENT = 'ALL' OR PLSENT IS NULL)
    THEN
       V_STRPLSENT := '%';
   ELSE
       V_STRPLSENT := PLSENT;
   END IF;

   IF(PV_ISCOREBANK = 'ALL' OR PV_ISCOREBANK IS NULL)
    THEN
       V_ISCOREBANK := '%';
   ELSE
       V_ISCOREBANK := PV_ISCOREBANK;
   END IF;

   IF(BANKNAME <> 'ALL')   THEN        V_STRBANKNAME  := BANKNAME;
   ELSE        V_STRBANKNAME  := '%';
   END IF;




--if PLSENT = 'ALL' then
OPEN PV_REFCURSOR
FOR
     select V_STRCUSTODYCD rpt_custodycd, V_STRAFACCTNO rpt_afacctno, a.fullname, a.custodycd,
    a.afacctno, a.amt no_ky_nay,
    CASE WHEN nvl(b.amt,0) - nvl(c.namt,0) < 2 and nvl(b.amt,0) - nvl(c.namt,0) > -2 THEN 0 ELSE round(nvl(b.amt,0) - nvl(c.namt,0)) END  no_ky_truoc, --lam tron so
    round(nvl(d.namt,0),4) no_da_tra_today,
    CASE WHEN a.amt + nvl(b.amt,0) - nvl(c.namt,0) - nvl(d.namt,0) < 2 and a.amt + nvl(b.amt,0) - nvl(c.namt,0) - nvl(d.namt,0) > -2 THEN 0 ELSE round(a.amt + nvl(b.amt,0) - nvl(c.namt,0) - nvl(d.namt,0)) END con_no --lam tron so
    from
    --tong no ky nay
    (
    select af.acctno afacctno, cf.fullname, cf.custodycd,
            round(sum(case  when v_FrDate = V_ToDate then depo.amt/depo.days
                            WHEN V_todate - V_frdate < days THEN (V_todate - V_frdate + 1)/depo.days * depo.amt
                            ELSE (CASE when depo.txdate = V_ToDate then depo.amt/depo.days
                                when depo.txdate + depo.days > V_ToDate and txdate < V_ToDate then (V_ToDate - depo.txdate + 1)/depo.days * depo.amt
                                when depo.txdate < v_FrDate and depo.txdate + days > v_FrDate then (depo.txdate + depo.days - v_FrDate)* depo.amt/depo.days
                                else depo.amt end)
                        END ),4) amt
    from sedepobal depo,  (SELECT * FROM CFMAST WHERE FNC_VALIDATE_SCOPE(BRID, CAREBY, TLSCOPE, pv_BRID, TLGOUPS)=0) cf, afmast af
    where  cf.custid = af.custid and af.acctno = substr(depo.acctno,1,10)
    AND depo.deltd <> 'Y'
    and cf.custodycd like V_STRCUSTODYCD
    and af.acctno like V_STRAFACCTNO
    AND af.corebank LIKE V_ISCOREBANK
    AND AF.bankname LIKE V_STRBANKNAME
    AND (substr(cf.custid,1,4) LIKE V_STRBRID OR instr(V_STRBRID,substr(cf.custid,1,4))<> 0)
    AND AF.ACTYPE NOT IN ('0000')
    and depo.days <> 0
    and depo.txdate + days > v_FrDate and depo.txdate <= V_ToDate
    group by af.acctno,  cf.fullname, cf.custodycd
    ) a
    left join
    --tinh tong no ky truoc
    (select substr(depo.acctno,1,10) afacctno,
        round(sum(case --when txdate =  v_FrDate then  round(depo.amt/depo.days)
                 when txdate + days >   v_FrDate then ((v_FrDate - depo.txdate )/depo.days * depo.amt)
                 else depo.amt
                 end),4) amt
    from sedepobal depo
    where   substr(depo.acctno,1,10) like V_STRAFACCTNO AND  depo.deltd <> 'Y'
    and depo.txdate   < v_FrDate
    and depo.days <> 0
    group by substr(depo.acctno,1,10)) b
    on b.afacctno = a.afacctno
    left join --tinh so da tra den ngay from date
    (
    SELECT acctno, sum(namt) namt FROM
        (
        select tran.msgacct acctno, sum(nvl(tran.msgamt,0))  namt
        from vw_tllog_all tran, afmast af, (SELECT * FROM CFMAST WHERE FNC_VALIDATE_SCOPE(BRID, CAREBY, TLSCOPE, pv_BRID, TLGOUPS)=0) cf
        where cf.custid = af.custid
        and tran.msgacct =  af.acctno
        AND tran.tltxcd IN ('1180','1182')
        and af.acctno like V_STRAFACCTNO
        AND cf.custodycd LIKE V_STRCUSTODYCD
        AND tran.busdate < v_FrDate
        group by tran.msgacct

        UNION ALL

        SELECT acctno,sum(nvl(namt,0)) namt
        FROM vw_citran_gen
        WHERE tltxcd = '0088' AND field in ('DEPOFEEAMT','CIDEPOFEEACR')AND txtype = 'D' AND busdate < v_FrDate
        and acctno like V_STRAFACCTNO
        AND custodycd LIKE V_STRCUSTODYCD
        GROUP BY  acctno
        )
    GROUP BY acctno
    ) c
    on a.afacctno = c.acctno


    left join --tinh so da tra tu ngay from date den ngay to date
    (
    SELECT acctno, sum(namt) namt FROM
        (
         select tran.msgacct acctno, sum(nvl(tran.msgamt,0))  namt
         from vw_tllog_all tran, afmast af, (SELECT * FROM CFMAST WHERE FNC_VALIDATE_SCOPE(BRID, CAREBY, TLSCOPE, pv_BRID, TLGOUPS)=0) cf
         where cf.custid = af.custid
         and tran.msgacct =  af.acctno
         AND tran.tltxcd IN ('1180','1182')
         and af.acctno like V_STRAFACCTNO
         AND cf.custodycd LIKE V_STRCUSTODYCD
         AND tran.busdate <= V_ToDate AND tran.busdate >= v_FrDate
         group by tran.msgacct

         UNION ALL

         SELECT acctno,sum(nvl(namt,0)) namt
         FROM vw_citran_gen
         WHERE tltxcd = '0088' AND field in ('DEPOFEEAMT','CIDEPOFEEACR') AND txtype = 'D'
         AND busdate <= V_ToDate AND busdate >= v_FrDate
         and acctno like V_STRAFACCTNO
         AND custodycd LIKE V_STRCUSTODYCD
         GROUP BY acctno
         )
    GROUP BY acctno
    ) d
    on a.afacctno = d.acctno

    WHERE case WHEN PLSENT = 'ALL' THEN 1
               WHEN PLSENT = '01' AND round(a.amt + nvl(b.amt,0) - nvl(c.namt,0) - nvl(d.namt,0)) > 0 THEN 1
               WHEN PLSENT = '02' AND round(a.amt + nvl(b.amt,0) - nvl(c.namt,0) - nvl(d.namt,0)) = 0 THEN 1
          ELSE 0 END = 1
    order by a.custodycd, a.afacctno;

EXCEPTION
   WHEN OTHERS
   THEN
      RETURN;
END;                                                              -- PROCEDURE
 
 
 
 
/
