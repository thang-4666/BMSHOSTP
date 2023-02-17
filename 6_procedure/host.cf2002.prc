SET DEFINE OFF;
CREATE OR REPLACE PROCEDURE "CF2002" (
   PV_REFCURSOR   IN OUT   PKG_REPORT.REF_CURSOR,
   OPT            IN       VARCHAR2,
   pv_BRID           IN       VARCHAR2,
   TLGOUPS        IN       VARCHAR2,
   TLSCOPE        IN       VARCHAR2,
   I_DATE         IN       VARCHAR2,
   PV_CUSTODYCD   IN       VARCHAR2,
     PV_SYMBOL      IN       VARCHAR2
 )
IS
--
-- PURPOSE: BRIEFLY EXPLAIN THE FUNCTIONALITY OF THE PROCEDURE
--
-- MODIFICATION HISTORY
-- PERSON      DATE       COMMENTS
-- Diennt      30/09/2011 Create
-- ---------   ------     -------------------------------------------
   V_STROPTION        VARCHAR2 (5);       -- A: ALL; B: BRANCH; S: SUB-BRANCH
   -- DECLARE PROGRAM VARIABLES AS SHOWN ABOVE
   V_STRPV_CUSTODYCD  VARCHAR2(20);
   V_STRPV_AFACCTNO   VARCHAR2(20);
   V_INBRID           VARCHAR2(4);
   V_STRBRID        VARCHAR2 (50);
   V_STRTLID        VARCHAR2(6);
   V_BALANCE        number;
   V_BALDEFOVD      number;
   V_NBAMT          number;
   V_IN_DATE        date;
   V_CURRDATE       date;
    v_Symbol varchar2(20);
   V_CICAST                 number;
   V_CICAST_KIQUY           number;
   V_TOTALSEAMT_KIQUY       number;
   V_TOTALODAMT_KIQUY       number;

BEGIN
/*
   V_STROPTION := OPT;

   IF (V_STROPTION <> 'A') AND (BRID <> 'ALL')
   THEN
      V_STRBRID := BRID;
   ELSE
      V_STRBRID := '%%';
   END IF;*/

--   V_STRTLID:=TLID;
   /*IF(TLID <> 'ALL' AND TLID IS NOT NULL)
   THEN
        V_STRTLID := TLID;
   ELSE
        V_STRTLID := 'ZZZZZZZZZ';
   END IF;
*/
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


IF  (PV_SYMBOL <> 'ALL')
THEN
      v_Symbol := upper(REPLACE (PV_SYMBOL,' ','_'));
ELSE
   v_Symbol := '%';
END IF;

    V_STRPV_CUSTODYCD  := upper(PV_CUSTODYCD);
    V_IN_DATE       := to_date(I_DATE,'dd/mm/rrrr');
    select to_date(varvalue,'dd/mm/rrrr') into V_CURRDATE from sysvar where varname = 'CURRDATE';

    /* ThangNV: Cap nhat 16/01/2014 */

    ------------ TONG SO DU TIEN TREN TAT CA CAC TAI KHOAN ---------
    select sum(round(ci.balance + ci.bamt  + ci.rcvamt + ci.tdbalance + ci.crintacr + ci.tdintamt )) into V_CICAST from buf_ci_account ci where ci.custodycd = V_STRPV_CUSTODYCD;
    ------------ TONG SO DU TIEN CUA LOAI KI QUY-----------
    select sum(round(ci.balance + ci.bamt  + ci.rcvamt + ci.tdbalance + ci.crintacr + ci.tdintamt )) into V_CICAST_KIQUY
        from buf_ci_account ci,cfmast cf, afmast af, aftype aft, mrtype mr where af.custid = cf.custid and af.acctno = ci.afacctno and af.actype = aft.actype and aft.mrtype = mr.actype and mr.actype = '0002' and ci.custodycd = V_STRPV_CUSTODYCD;
    ------------ TONG GIA TRI CHUNG KHOAN CUA LOAI KY QUY -----------
    select sum(nvl((v.trade-v.execqtty+v.receiving+v.buyqtty - v.buyingqtty)*v.basicprice,0)) into V_TOTALSEAMT_KIQUY from (select * from vw_getsecmargindetail dt, sbsecurities sb, afmast af, cfmast cf, aftype aft, mrtype mr where dt.codeid= sb.codeid and sb.sectype <> '004' and af.custid = cf.custid and af.acctno = dt.afacctno and af.actype = aft.actype and aft.mrtype = mr.actype and mr.actype = '0002' and cf.custodycd = V_STRPV_CUSTODYCD) v;

    ------------ TONG CAC KHOAN VAY CUA LOAI KI QUY ----------
    select sum(nvl(ln.dfamt,0) + nvl(ln.t0amt,0) + nvl(ln.mramt,0) /*+ ci.depofeeamt*/ + ci.trfbuyamt + nvl(b.SECUREDAMT,0) + nvl(odadv.rcvadv,0)) into V_TOTALODAMT_KIQUY from
        (select trfacctno,
                    nvl(sum(case when ftype = 'DF' then prinnml+prinovd+intnmlacr+intnmlovd+intovdacr+intdue+feeintnmlacr+feeintnmlovd+feeintovdacr+feeintdue else 0 end),0) dfamt,
                    nvl(sum(case when ftype = 'DF' then prinnml+prinovd else 0 end),0) dfodamt,
                    nvl(sum(case when ftype = 'AF' then oprinnml+oprinovd+ointnmlacr+ointnmlovd+ointovdacr+ointdue else 0 end),0) t0amt,
                    nvl(sum(case when ftype = 'AF' then prinnml+prinovd+intnmlacr+intnmlovd+intovdacr+intdue+feeintnmlacr+feeintnmlovd+feeintovdacr+feeintdue else 0 end),0) mramt
                from lnmast group by trfacctno) ln,
        (select afacctno, nvl(sum(secureamt),0) SECUREDAMT, nvl(sum(overamt),0) OVERAMT
                from v_getbuyorderinfo
                group by afacctno) b,
        (select acctno, sum(amt + feeamt) odadv,sum(amt) rcvadv from adschd where deltd <> 'Y' and status <> 'C' group by acctno) odadv, afmast af, cfmast cf, cimast ci, aftype aft, mrtype mr
    where af.custid = cf.custid and af.acctno = ci.afacctno(+) and af.acctno = b.afacctno(+)
        and af.acctno = ln.trfacctno(+)
        and af.acctno = odadv.acctno(+)
        and af.actype = aft.actype and aft.mrtype = mr.actype and mr.actype = '0002'
        and cf.custodycd = V_STRPV_CUSTODYCD;

OPEN PV_REFCURSOR
  FOR

select * from (
    SELECT to_char(V_CURRDATE,'DD/MM/YYYY')  currdate, cf.fullname, cf.address, cf.idcode, to_char(cf.iddate,'DD/MM/YYYY') IDDATE, cf.idplace,
        /*aft.mnemonic,*/ cf.custodycd,mr.mrtype,
        /*SE.ACCTNO SEACCTNO, SE.AFACCTNO,*/ (case when SB.REFSYMBOL is null then SB.SYMBOL else SB.REFSYMBOL end) SYMBOL,
        SB.ISSFULLNAME, SB.ISSOFFICENAME,
        SB.TRADEPLACE, a0.cdcontent TRADEPLACE_name,
        --chung khoan giao dich.
        sum(case when SB.REFSYMBOL is null then SE.TRADE-NVL(TR.TRADE_NAMT,0) else 0 end) - SUM(NVL(ODONDAY.execqttyDAY,0)) TRADE_AMT,
        --chung khoan han che chuyen nhuong.
        sum(case when SB.REFSYMBOL is null then se.BLOCKED-nvl(tr.BLOCKED_NAMT,0) else 0 end) BLOCKED_AMT,
        ---chung khoan da ban.
        sum(NVL(ODONDAY.execqtty,0)) NETTING_AMT,
        /*sum(case when SB.REFSYMBOL is null then se.NETTING-nvl(tr.NETTING_NAMT,0) else 0 end) NETTING_AMT,*/
        --- chung khoan phong toa khac.
        sum(case when SB.REFSYMBOL is null then se.EMKQTTY-nvl(tr.EMKQTTY_NAMT,0) else 0 end) EMKQTTY_AMT,
        --chung khoan cho giao dich.
        sum(case when SB.REFSYMBOL is null then 0 else SE.TRADE-NVL(TR.TRADE_NAMT,0) end) TRADE_WFT,
        --chung khoan cho giao dich HCCN.
        sum(case when SB.REFSYMBOL is null then 0 else se.BLOCKED-nvl(tr.BLOCKED_NAMT,0) end) BLOCKED_WFT,
        -- gia chung khoan tai ngay bao cao.
        max(nvl(sec.basicprice,0)) basicprice ,
        max(nvl(ci.BALANCE,0)) ciBALANCE, max(nvl(ci.BALDEFOVD,0)) ciBALDEFOVD,
        max(nvl(ln.marginamt,0) ) marginamt,
         0 DFQTTY, 0 RCVDFQTTY, max(nvl(od.AMT,0)) NBAMT, sum(buf_se.abstanding) CAMCO_VSD, V_CICAST, V_CICAST_KIQUY, V_TOTALSEAMT_KIQUY, V_TOTALODAMT_KIQUY
    FROM SEMAST SE,
    (
    SELECT SB.CODEID, SB.SYMBOL, ISS.fullname ISSFULLNAME, ISS.officename ISSOFFICENAME,    -- Them ten Tieng Anh cua Chung khoan cho bao cao CF2003
        (CASE WHEN SB.REFCODEID IS NULL THEN SB.TRADEPLACE ELSE SB1.TRADEPLACE END) TRADEPLACE,
        SB1.CODEID REFCODEID, SB1.SYMBOL REFSYMBOL
    FROM SBSECURITIES SB, SBSECURITIES SB1, issuers ISS
    WHERE SB.REFCODEID = SB1.CODEID(+)
        AND sb.issuerid =iss.issuerid and sb.sectype <> '004'   -- Bo loai chung khoan quyen
    ) SB,
    (
        SELECT ACCTNO,
            SUM(CASE WHEN FIELD = 'TRADE' THEN (CASE WHEN TXTYPE = 'D' THEN - NAMT ELSE NAMT END) ELSE 0 END) TRADE_NAMT,
            SUM(CASE WHEN FIELD = 'BLOCKED' THEN (CASE WHEN TXTYPE = 'D' THEN - NAMT ELSE NAMT END) ELSE 0 END) BLOCKED_NAMT,
            SUM(CASE WHEN FIELD = 'NETTING' THEN (CASE WHEN TXTYPE = 'D' THEN - NAMT ELSE NAMT END) ELSE 0 END) NETTING_NAMT,
            SUM(CASE WHEN FIELD = 'EMKQTTY' THEN (CASE WHEN TXTYPE = 'D' THEN - NAMT ELSE NAMT END) ELSE 0 END) EMKQTTY_NAMT
        FROM VW_SETRAN_GEN
        WHERE DELTD <> 'Y' AND FIELD IN ('TRADE','BLOCKED','NETTING','EMKQTTY')
            and txdate > V_IN_DATE
            and custodycd = V_STRPV_CUSTODYCD
        GROUP BY ACCTNO
        HAVING SUM(CASE WHEN FIELD = 'TRADE' THEN (CASE WHEN TXTYPE = 'D' THEN - NAMT ELSE NAMT END) ELSE 0 END) <> 0 or
            SUM(CASE WHEN FIELD = 'BLOCKED' THEN (CASE WHEN TXTYPE = 'D' THEN - NAMT ELSE NAMT END) ELSE 0 END) <> 0 or
            SUM(CASE WHEN FIELD = 'NETTING' THEN (CASE WHEN TXTYPE = 'D' THEN - NAMT ELSE NAMT END) ELSE 0 END) <> 0 or
            SUM(CASE WHEN FIELD = 'EMKQTTY' THEN (CASE WHEN TXTYPE = 'D' THEN - NAMT ELSE NAMT END) ELSE 0 END) <> 0
    ) TR,
    (
        select symbol, max(basicprice) basicprice
        from
        (
            select GETCURRDATE txdate, symbol, basicprice
            from securities_info
            where GETCURRDATE = V_IN_DATE
            union all
            select histdate txdate, symbol, basicprice
            from securities_info_hist
            where histdate = V_IN_DATE
        )
        group by symbol
    )sec, allcode a0, (SELECT * FROM CFMAST WHERE FNC_VALIDATE_SCOPE(BRID, CAREBY, TLSCOPE, pv_BRID, TLGOUPS)=0) cf, afmast af, aftype aft,mrtype mr, buf_se_account buf_se,
    (
        SELECT OD.AFACCTNO, SUM((OD.ORDERQTTY) * OD.QUOTEPRICE * (1 +  (MOD(OD.BRATIO,1)/100)))  AS AMT
        FROM ODMAST OD, (SELECT TO_DATE(VARVALUE,'DD/MM/RRRR') CURRDATE FROM sysvar WHERE varname ='CURRDATE'
        ) SY
        WHERE OD.EXECTYPE = 'NB' AND OD.TXDATE = SY.CURRDATE and od.deltd <> 'Y'
        GROUP BY OD.AFACCTNO
    ) OD,
    (
        select codeid, custodycd, sum(NVL(execqtty,0)) execqtty, SUM(NVL(execqttyDAY,0)) execqttyDAY
        from
        (
            select OD.codeid, CF.custodycd, OD.execqtty,
                (CASE WHEN V_CURRDATE = OD.TXDATE  THEN OD.execqtty ELSE 0 END) execqttyDAY
            from odmast OD, AFMAST AF, CFMAST CF
            where OD.execqtty > 0
                and OD.exectype in ('MS','NS')
                and OD.txdate <= V_IN_DATE
                and OD.deltd <> 'Y'
                AND OD.afacctno = AF.acctno AND AF.custid = CF.custid
                AND CF.custodycd = V_STRPV_CUSTODYCD
            union all
            select odhist.codeid, CF.custodycd, execqtty, 0 execqttyDAY
            from odmasthist odhist, stschdhist  sthist, AFMAST AF, CFMAST CF
            where execqtty > 0
                and odhist.txdate <= V_IN_DATE
                and exectype in ('MS','NS')
                AND sthist.orgorderid = odhist.orderid
                AND sthist.duetype = 'RM'
                AND sthist.cleardate > V_IN_DATE
                AND odhist.afacctno = AF.acctno AND AF.custid = CF.custid
                AND CF.custodycd = V_STRPV_CUSTODYCD
        )
        group by codeid, custodycd
    )ODONDAY,
    (
        SELECT af.ACCTNO, sum(TRUNC(CI.BALANCE) - NVL(TR.NAMT_BALANCE,0)) BALANCE,
            sum(GREATEST(CI.BALANCE - NVL(TR.NAMT_BALANCE,0) - CI.OVAMT - NVL(TR.NAMT_OVAMT,0) -
            CI.DUEAMT - NVL(TR.NAMT_DUEAMT,0) - CI.DFDEBTAMT - NVL(TR.NAMT_DFDEBTAMT,0) - NVL (B.OVERAMT, 0) -
            NVL(B.SECUREAMT,0) - CI.TRFBUYAMT - NVL(TR.NAMT_TRFBUYAMT,0) - NVL(PD.DEALPAIDAMT,0) - CI.DEPOFEEAMT -
            NVL(TR.NAMT_DEPOFEEAMT,0),0)) BALDEFOVD
        FROM afmast af, cfmast cf, CIMAST CI
        LEFT JOIN
        (SELECT AFACCTNO, sum(SECUREAMT) SECUREAMT, sum(ADVAMT) ADVAMT, sum(OVERAMT) OVERAMT
        FROM V_GETBUYORDERINFO
        group by AFACCTNO
        ) B
        ON CI.ACCTNO = B.AFACCTNO
        LEFT JOIN
        (
            SELECT AFACCTNO, sum(AAMT) AAMT, sum(DEPOAMT) AVLADVANCE, sum(ADVAMT) ADVANCEAMOUNT, sum(PAIDAMT) PAIDAMT
            FROM V_GETACCOUNTAVLADVANCE group by AFACCTNO
        ) ADV
        ON ADV.AFACCTNO=CI.ACCTNO
        LEFT JOIN
        (
            SELECT AFACCTNO, sum(DEALPAIDAMT) DEALPAIDAMT
            FROM V_GETDEALPAIDBYACCOUNT P
            group by P.AFACCTNO
        ) PD
        ON PD.AFACCTNO=CI.ACCTNO
        LEFT JOIN
        (
        SELECT ACCTNO,
            SUM(CASE WHEN FIELD = 'BALANCE' THEN (CASE WHEN TXTYPE = 'D' THEN -NAMT ELSE NAMT END) ELSE 0 END) NAMT_BALANCE,
            SUM(CASE WHEN FIELD = 'TRFBUYAMT' THEN (CASE WHEN TXTYPE = 'D' THEN -NAMT ELSE NAMT END) ELSE 0 END) NAMT_TRFBUYAMT,
            SUM(CASE WHEN FIELD = 'OVAMT' THEN (CASE WHEN TXTYPE = 'D' THEN -NAMT ELSE NAMT END) ELSE 0 END) NAMT_OVAMT,
            SUM(CASE WHEN FIELD = 'DUEAMT' THEN (CASE WHEN TXTYPE = 'D' THEN -NAMT ELSE NAMT END) ELSE 0 END) NAMT_DUEAMT,
            SUM(CASE WHEN FIELD = 'DFDEBTAMT' THEN (CASE WHEN TXTYPE = 'D' THEN -NAMT ELSE NAMT END) ELSE 0 END) NAMT_DFDEBTAMT,
            SUM(CASE WHEN FIELD = 'DEPOFEEAMT' THEN (CASE WHEN TXTYPE = 'D' THEN -NAMT ELSE NAMT END) ELSE 0 END) NAMT_DEPOFEEAMT
        FROM VW_CITRAN_GEN
        WHERE DELTD <> 'Y' AND FIELD IN ('BALANCE','TRFBUYAMT','OVAMT','DUEAMT','DFDEBTAMT','DEPOFEEAMT')
            and custodycd = V_STRPV_CUSTODYCD
            and txdate > V_IN_DATE
        GROUP BY ACCTNO
        ) TR
        ON CI.ACCTNO = TR.ACCTNO
        WHERE af.custid = cf.custid
            and cf.custodycd = V_STRPV_CUSTODYCD
            and ci.afacctno = af.acctno
        GROUP BY af.ACCTNO
    ) CI,
    (select trfacctno, trunc(sum(round(prinnml)+round(prinovd)+round(intnmlacr)+round(intdue)+round(intovdacr)+round(intnmlovd)+round(feeintnmlacr)
                                +round(feeintdue)+round(feeintovdacr)+round(feeintnmlovd)),0) marginamt,
                 trunc(sum(round(oprinnml)+round(oprinovd)+round(ointnmlacr)+round(ointdue)+round(ointovdacr)+round(ointnmlovd)),0) t0amt,
                 trunc(sum(round(prinovd)+round(intovdacr)+round(intnmlovd)+round(feeintovdacr)+round(feeintnmlovd) + round(nvl(ls.dueamt,0)) + round(feeintdue)),0) marginovdamt,
                 trunc(sum(round(oprinovd)+round(ointovdacr)+round(ointnmlovd)),0) t0ovdamt
        from lnmast ln, lntype lnt,
                (select acctno, sum(nml+intdue) dueamt
                        from lnschd, (select * from sysvar where varname = 'CURRDATE' and grname = 'SYSTEM') sy
                        where reftype = 'P' and overduedate = to_date(varvalue,'DD/MM/RRRR')
                        group by acctno) ls
        where ftype = 'AF'
                and ln.actype = lnt.actype
                and ln.acctno = ls.acctno(+)
        group by ln.trfacctno) ln

    WHERE SE.CODEID = SB.CODEID
        AND AF.acctno = OD.AFACCTNO(+)
        AND AF.acctno = CI.ACCTNO(+)
        AND AF.acctno = ln.trfacctno(+)
        AND SE.ACCTNO =  TR.ACCTNO(+)
        and se.CODEID = ODONDAY.CODEID(+)
        and se.afacctno = af.acctno
        and cf.custid = af.custid
        and cf.custodycd = V_STRPV_CUSTODYCD
        and af.actype = aft.actype
        AND AFT.MRTYPE = MR.actype
        and sb.TRADEPLACE = a0.cdval and a0.cdname = 'TRADEPLACE' and a0.cdtype = 'SE'
        and (case when sb.REFSYMBOL is null then sb.symbol else sb.REFSYMBOL end) = sec.symbol(+)
        and buf_se.custodycd = cf.custodycd and buf_se.afacctno = af.acctno and buf_se.codeid = sb.codeid
----        and exists (select gu.grpid from tlgrpusers gu where af.careby = gu.grpid and gu.tlid = V_STRTLID )
    group by cf.custodycd, cf.fullname, cf.address, cf.idcode, cf.iddate, cf.idplace,/*aft.mnemonic,*/ mr.mrtype,
        /*SE.ACCTNO, SE.AFACCTNO,*/ (case when SB.REFSYMBOL is null then SB.SYMBOL else SB.REFSYMBOL end), SB.ISSFULLNAME, SB.ISSOFFICENAME,
        SB.TRADEPLACE, a0.cdcontent
) a where A.SYMBOL LIKE v_Symbol
     AND a.TRADE_AMT+ a.BLOCKED_AMT + a.EMKQTTY_AMT + a.TRADE_WFT + a.DFQTTY > 0
        ;

EXCEPTION
   WHEN OTHERS
   THEN

      RETURN;
End;
 
 
 
 
/
