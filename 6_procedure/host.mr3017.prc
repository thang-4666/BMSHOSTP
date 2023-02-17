SET DEFINE OFF;
CREATE OR REPLACE PROCEDURE "MR3017" (
   PV_REFCURSOR   IN OUT   PKG_REPORT.REF_CURSOR,
   pv_OPT            IN       VARCHAR2,
   pv_BRID           IN       VARCHAR2,
   TLGOUPS        IN       VARCHAR2,
   TLSCOPE        IN       VARCHAR2,
     F_DATE IN VARCHAR2,
     T_DATE IN VARCHAR2,
   pv_CUSTDYCD       IN       VARCHAR2,
   pv_AFACCTNO       IN       VARCHAR2,
	 TLID            IN       VARCHAR2,
     pv_aftype IN      VARCHAR2,
		 pv_BRGID  IN VARCHAR2

)
IS
--
-- PURPOSE: BRIEFLY EXPLAIN THE FUNCTIONALITY OF THE PROCEDURE
--
-- MODIFICATION HISTORY
-- PERSON      DATE    COMMENTS
-- LINHLNB   11-Apr-2012  CREATED

-- ---------   ------  -------------------------------------------
   l_STROPTION        VARCHAR2 (5);       -- A: ALL; B: BRANCH; S: SUB-BRANCH
   l_STRBRID          VARCHAR2 (4);
   l_AFACCTNO         VARCHAR2 (20);
   v_IDATE           DATE; --ngay lam viec gan ngay idate nhat
   v_CurrDate        DATE;
   V_INBRID        VARCHAR2(4);
   V_STRBRID      VARCHAR2 (50);
   V_STROPTION VARCHAR2(10);
   V_STRTLID           VARCHAR2(6);
   v_custodycd            VARCHAR2 (20);
     v_FRDATE DATE;
     v_TODATE DATE;
     v_aftype VARCHAR2(4);
     v_recustid VARCHAR2(10);
		 v_BRGID VARCHAR2(4);


-- DECLARE PROGRAM VARIABLES AS SHOWN ABOVE
BEGIN




   V_STRTLID:= TLID;
   V_STROPTION := upper(pv_OPT);
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
   l_AFACCTNO  := replace(pv_AFACCTNO,'.','');


   IF (pv_AFACCTNO <> 'ALL')
   THEN
      l_AFACCTNO := pv_AFACCTNO;
   ELSE
      l_AFACCTNO := '%%';
   END IF;
     IF (pv_CUSTDYCD <> 'ALL')
   THEN
      v_custodycd := pv_CUSTDYCD;
   ELSE
      v_custodycd := '%%';
   END IF;

     IF pv_aftype <> 'ALL' THEN v_aftype := pv_aftype;
     ELSE v_aftype:= '%%';
     END IF;


		 IF pv_BRGID <> 'ALL' THEN v_BRGID:= pv_BRGID;
		 ELSE v_BRGID:= '%%';
		 END IF;

 -- END OF GETTING REPORT'S PARAMETERS

   --SELECT max(sbdate) INTO v_IDATE  FROM sbcurrdate WHERE sbtype ='B' AND sbdate <= to_date(I_DATE,'DD/MM/RRRR');
   select to_date(varvalue,'DD/MM/RRRR') into v_CurrDate from sysvar where varname = 'CURRDATE' and grname = 'SYSTEM';
   v_FRDATE:= to_date(F_DATE,'DD/MM/RRRR');
     v_TODATE:= to_date(T_DATE,'DD/MM/RRRR');


  -- GET REPORT'S DATA
OPEN PV_REFCURSOR FOR
SELECT * FROM (
SELECT v.txdate, v.custodycd, v.afacctno, v.symbol, v.trade + v.receiving +V.BUYQTTY-v.execqtty "trade", v.ratecl, v.seass,
 cf.fullname, a0.cdcontent aftypename, br.brname
FROM tbl_mr3007_log v, afmast af, aftype aft,ALLCODE A0,
                    (SELECT * FROM CFMAST/* WHERE FNC_VALIDATE_SCOPE(BRID, CAREBY, TLSCOPE, pv_BRID, TLGOUPS)=0*/) cf,
										brgrp br
where  v.afacctno like l_AFACCTNO
    and v.trade + v.mortage + v.receiving + v.EXECQTTY + v.buyqtty > 0
    AND af.acctno = v.afacctno
    and af.custid = cf.custid
		AND substr(cf.brid,1,4) = br.brid
    AND V.seass>0
    AND A0.CDTYPE='CF' AND A0.CDNAME='PRODUCTTYPE' AND A0.CDVAL=AFT.PRODUCTTYPE
    and cf.custodycd like v_custodycd
    AND v.txdate BETWEEN v_FRDATE AND v_TODATE
    AND af.actype = aft.actype AND aft.producttype LIKE v_aftype
		AND br.brid LIKE v_brgid

UNION ALL
select v_currdate txdate, cf.custodycd, af.acctno afacctno, sb.symbol,
    (trade + receiving - execqtty + buyqtty) trade,
    nvl(rsk.mrratioloan,0) ratecl,

   (trade + receiving - execqtty + buyqtty) * nvl(rsk.mrratiorate,0)/100 * least(sb.MARGINCALLPRICE,nvl(rsk.mrpricerate,0))
       SEASS,cf.fullname,  a0.cdcontent  aftypename, br.brname
        from
        (select se.codeid, af.actype, af.mriratio, se.afacctno,se.acctno, se.trade, se.mortage ,
        nvl(sts.receiving,0) receiving,nvl(BUYQTTY,0) BUYQTTY,nvl(BUYINGQTTY,0) BUYINGQTTY,nvl(od.EXECQTTY,0) EXECQTTY
            from semast se inner join afmast af on se.afacctno =af.acctno
            left join
            (select sum(BUYQTTY) BUYQTTY, sum(BUYINGQTTY) BUYINGQTTY, sum(EXECQTTY) EXECQTTY , AFACCTNO, CODEID
                    from (
                        SELECT (case when od.exectype IN ('NB','BC') then REMAINQTTY + EXECQTTY - DFQTTY else 0 end) BUYQTTY,
                               (case when od.exectype IN ('NB','BC') then REMAINQTTY else 0 end) BUYINGQTTY,
                               (case when od.exectype IN ('NS','MS') and od.stsstatus <> 'C' then EXECQTTY - nvl(dfexecqtty,0) else 0 end) EXECQTTY,AFACCTNO, CODEID
                        FROM odmast od, afmast af,
                            (select orderid, sum(execqtty) dfexecqtty from odmapext where type = 'D' group by orderid) dfex
                           where od.afacctno = af.acctno and od.orderid = dfex.orderid(+)
                           and od.txdate =(select to_date(VARVALUE,'DD/MM/RRRR') from sysvar where grname='SYSTEM' and varname='CURRDATE')
                           AND od.deltd <> 'Y'
                           and not(od.grporder='Y' and od.matchtype='P')
                           AND od.exectype IN ('NS', 'MS','NB','BC')
                        )
             group by AFACCTNO, CODEID
             ) OD
            on OD.afacctno =se.afacctno and OD.codeid =se.codeid
            left join
            (SELECT STS.CODEID,STS.AFACCTNO,
                    SUM(CASE WHEN DUETYPE ='RS' AND STS.TXDATE <> TO_DATE(sy.VARVALUE,'DD/MM/RRRR') THEN QTTY-AQTTY ELSE 0 END) RECEIVING
                FROM STSCHD STS, ODMAST OD, ODTYPE TYP,
                sysvar sy
                WHERE STS.DUETYPE IN ('RM','RS') AND STS.STATUS ='N'
                    and sy.grname = 'SYSTEM' and sy.varname = 'CURRDATE'
                    AND STS.DELTD <>'Y' AND STS.ORGORDERID=OD.ORDERID AND OD.ACTYPE =TYP.ACTYPE
                    GROUP BY STS.AFACCTNO,STS.CODEID
             ) sts
            on sts.afacctno =se.afacctno and sts.codeid=se.codeid
        ) se,
        afserisk rsk,
        securities_info sb,sbsecurities sbs,
        cfmast cf, afmast af, aftype aft, allcode a0, brgrp br
        where cf.custid = af.custid and af.acctno = se.afacctno
        and se.actype =rsk.actype(+) and se.codeid=rsk.codeid(+)
        and se.codeid=sb.codeid  and sb.codeid=sbs.codeid
        and trade + receiving - execqtty + buyqtty + mortage > 0
        AND af.actype = aft.actype
        and cf.brid=br.brid
        AND A0.CDTYPE='CF' AND A0.CDNAME='PRODUCTTYPE' AND A0.CDVAL=AFT.PRODUCTTYPE
        and  sbs.sectype<>'004'
        AND nvl(se.trade,0) + nvl(se.receiving,0)+nvl(se.buyqtty,0) <> 0
         and af.acctno LIKE l_AFACCTNO
        AND cf.custodycd LIKE v_custodycd
        AND v_currdate BETWEEN v_frdate AND v_todate
        AND aft.producttype LIKE v_aftype
        AND br.brid  LIKE v_brgid

/*SELECT v_currdate txdate, cf.custodycd, af.acctno afaccnto, v.symbol, v.trade + v.receiving+V.BUYQTTY "trade",
 v.ratecl, v.seass, cf.fullname,  a0.cdcontent  aftypename, br.brname
FROM
       (SELECT * FROM CFMAST \*WHERE FNC_VALIDATE_SCOPE(BRID, CAREBY, TLSCOPE, pv_BRID, TLGOUPS)=0*\) cf, (select * from afmast where acctno LIKE l_AFACCTNO) af,
       -- (select * from cimast where acctno LIKE l_AFACCTNO)ci,
       -- (select * from v_getsecmargininfo where afacctno LIKE l_AFACCTNO) sec,
        (select * from vw_getsecmargindetail where afacctno LIKE l_AFACCTNO) v,
        \*(select afacctno, sum(depoamt) AVLADVANCE
            from v_getaccountavladvance
            where afacctno LIKE l_AFACCTNO group by afacctno) adv,*\
       \* (select afacctno, nvl(sum(secureamt),0) SECUREDAMT
            from v_getbuyorderinfo
            where afacctno LIKE l_AFACCTNO group by afacctno) b,*\
       \* (select trfacctno,
                nvl(sum(case when ftype = 'DF' then prinnml+prinovd+intnmlacr+intnmlovd+intovdacr+intdue+feeintnmlacr+feeintnmlovd+feeintovdacr+feeintdue else 0 end),0) dfamt,
                nvl(sum(case when ftype = 'DF' then prinnml+prinovd else 0 end),0) dfodamt,
                nvl(sum(case when ftype = 'AF' then oprinnml+oprinovd+ointnmlacr+ointnmlovd+ointovdacr+ointdue else 0 end),0) t0amt,
                nvl(sum(case when ftype = 'AF' then prinnml+prinovd+intnmlacr+intnmlovd+intovdacr+intdue+feeintnmlacr+feeintnmlovd+feeintovdacr+feeintdue else 0 end),0) mramt
            from lnmast where trfacctno LIKE l_AFACCTNO group by trfacctno) ln,*\

                aftype aft, brgrp br, ALLCODE A0
    where cf.custid = af.custid
		--and af.acctno = ci.afacctno
		AND af.actype = aft.actype
		AND substr(cf.brid,1,4) = br.brid
    --and af.acctno = adv.afacctno(+)
    --and af.acctno = b.afacctno(+)
    --and af.acctno = ln.trfacctno(+)
    and af.acctno = v.afacctno(+)
		AND nvl(v.trade,0) + nvl(v.receiving,0) <> 0
     AND A0.CDTYPE='CF' AND A0.CDNAME='PRODUCTTYPE' AND A0.CDVAL=AFT.PRODUCTTYPE
    --and af.acctno = sec.afacctno(+)
    and af.acctno LIKE l_AFACCTNO
        AND cf.custodycd LIKE v_custodycd
        AND v_currdate BETWEEN v_frdate AND v_todate
        AND aft.producttype LIKE v_aftype
				AND br.brid  LIKE v_brgid
        */

        ) ORDER BY txdate, custodycd, afacctno, symbol

        ;

/*IF I_DATE <> v_currdate THEN
    OPEN PV_REFCURSOR
        for
    select V.AUTOID,V.TXDATE,V.CUSTODYCD,V.AFACCTNO,NVL(V.ACCTNO,'') ACCTNO, NVL(V.CODEID,'') CODEID, NVL(V.SYMBOL,'') SYMBOL,
    NVL(V.TRADE,0) TRADE, NVL(V.RECEIVING,0) RECEIVING, NVL(V.EXECQTTY,0) EXECQTTY,NVL(V.BUYQTTY,0) BUYQTTY,NVL(V.MORTAGE,0)MORTAGE,
    V.MRCRLIMITMAX,V.BALANCE,V.DEPOFEEAMT,V.TRFBUYAMT,V.AVLADVANCE,V.SECUREDAMT,V.DFAMT,V.DFODAMT,V.T0AMT,V.MRAMT,V.OUTSTANDING,V.PP0,V.RATECL,
    V.PRICECL,V.CALLPRICECL,V.CALLRATE74,V.CALLPRICE74,V.SEAMT,V.SEASS,V.SEREAL,V.MRMAXQTTY,V.SEQTTY,V.INTMRAMT,V.MARGINRATE,CF.FULLNAME
    from tbl_mr3007_log v, afmast af,(SELECT * FROM CFMAST WHERE FNC_VALIDATE_SCOPE(BRID, CAREBY, TLSCOPE, pv_BRID, TLGOUPS)=0) cf
    where txdate = v_idate AND v.afacctno like l_AFACCTNO
    and v.trade + v.mortage + v.receiving + v.EXECQTTY + v.buyqtty > 0
    AND af.acctno = v.afacctno
    and af.custid = cf.custid
    AND V.seass>0
    and cf.custodycd like v_custodycd
    AND (af.brid LIKE V_STRBRID or instr(V_STRBRID,af.brid) <> 0 )
   -- and exists (select gu.grpid from tlgrpusers gu where af.careby = gu.grpid and gu.tlid = V_STRTLID )
    order by cf.custodycd,v.symbol ;
ELSE
    OPEN PV_REFCURSOR
        for
    select af.mrcrlimitmax, ci.balance, ci.depofeeamt, ci.trfbuyamt, nvl(adv.AVLADVANCE,0) AVLADVANCE, nvl(b.SECUREDAMT,0) SECUREDAMT,
    nvl(ln.dfamt,0) dfamt, nvl(ln.dfodamt,0) dfodamt, nvl(ln.t0amt,0) t0amt, nvl(ln.mramt,0) mramt,
    round(abs(least(ci.balance + nvl(adv.AVLADVANCE,0) - nvl(b.SECUREDAMT,0) - ci.trfbuyamt - nvl(ln.t0amt,0) - nvl(ln.mramt,0) \*- ci.depofeeamt*\,0)),0) outstanding,
    round(ci.balance - nvl(b.SECUREDAMT,0) - ci.trfbuyamt + nvl(adv.avladvance,0) + af.advanceline
                            + least(nvl(af.mrcrlimitmax,0)+ nvl(af.mrcrlimit,0)  - ci.dfodamt,nvl(af.mrcrlimit,0) + nvl(sec.seamt,0))
                            - nvl(ci.odamt,0) \* - ci.depofeeamt*\,0) pp0,
    cf.custodycd, af.acctno afacctno, v.acctno, v.codeid, v.symbol, v.trade,
       v.receiving, v.execqtty, v.buyqtty, v.mortage, v.ratecl,
       v.pricecl, v.callratecl, v.callpricecl, v.callrate74,
       v.callprice74, v.seamt, v.seass, v.sereal, v.mrmaxqtty, v.seqtty,
       round((case when ci.balance + LEAST(nvl(af.MRCRLIMIT,0),nvl(b.SECUREDAMT,0) + ci.trfbuyamt)+ nvl(adv.avladvance,0) - ci.odamt -
    nvl(b.SECUREDAMT,0) - ci.trfbuyamt - ci.ramt>=0 then 100000
    else least( nvl(sec.SEASS,0), af.mrcrlimitmax - ci.dfodamt)
    / abs(ci.balance +LEAST(nvl(af.MRCRLIMIT,0),nvl(b.SECUREDAMT,0) + ci.trfbuyamt)+ nvl(adv.avladvance,0) - ci.odamt - nvl(b.SECUREDAMT,0) -
    ci.trfbuyamt - ci.ramt) end),4) * 100 MARGINRATE
    from (SELECT * FROM CFMAST WHERE FNC_VALIDATE_SCOPE(BRID, CAREBY, TLSCOPE, pv_BRID, TLGOUPS)=0) cf, (select * from afmast where acctno = l_AFACCTNO) af,
        (select * from cimast where acctno = l_AFACCTNO)ci,
        (select * from v_getsecmargininfo where afacctno = l_AFACCTNO) sec,
        (select * from vw_getsecmargindetail where afacctno = l_AFACCTNO) v,
        (select afacctno, sum(depoamt) AVLADVANCE
            from v_getaccountavladvance
            where afacctno = l_AFACCTNO group by afacctno) adv,
        (select afacctno, nvl(sum(secureamt),0) SECUREDAMT
            from v_getbuyorderinfo
            where afacctno = l_AFACCTNO group by afacctno) b,
        (select trfacctno,
                nvl(sum(case when ftype = 'DF' then prinnml+prinovd+intnmlacr+intnmlovd+intovdacr+intdue+feeintnmlacr+feeintnmlovd+feeintovdacr+feeintdue else 0 end),0) dfamt,
                nvl(sum(case when ftype = 'DF' then prinnml+prinovd else 0 end),0) dfodamt,
                nvl(sum(case when ftype = 'AF' then oprinnml+oprinovd+ointnmlacr+ointnmlovd+ointovdacr+ointdue else 0 end),0) t0amt,
                nvl(sum(case when ftype = 'AF' then prinnml+prinovd+intnmlacr+intnmlovd+intovdacr+intdue+feeintnmlacr+feeintnmlovd+feeintovdacr+feeintdue else 0 end),0) mramt
            from lnmast where trfacctno = l_AFACCTNO group by trfacctno) ln
    where cf.custid = af.custid and af.acctno = ci.afacctno
    and af.acctno = adv.afacctno(+)
    and af.acctno = b.afacctno(+)
    and af.acctno = ln.trfacctno(+)
    and af.acctno = v.afacctno(+)
    and af.acctno = sec.afacctno(+)
    and af.acctno = l_AFACCTNO
        AND cf.custodycd = v_custodycd
        AND (af.brid LIKE V_STRBRID or instr(V_STRBRID,af.brid) <> 0 )
    order by cf.custodycd,v.symbol;
END IF;*/



 EXCEPTION
   WHEN OTHERS
   THEN
        RETURN;
END;

 
 
 
 
/
