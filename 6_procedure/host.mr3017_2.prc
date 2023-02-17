SET DEFINE OFF;
CREATE OR REPLACE PROCEDURE "MR3017_2" (
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
/*SELECT v.txdate, v.custodycd, v.afacctno, v.symbol, v.trade + v.receiving +V.BUYQTTY "trade", v.ratecl, v.seass,
 cf.fullname, a0.cdcontent aftypename, br.brname,SE.BASICPRICE
FROM tbl_mr3007_log v, afmast af, aftype aft,ALLCODE A0,SECURITIES_INFO SE,
                    (SELECT * FROM CFMAST\* WHERE FNC_VALIDATE_SCOPE(BRID, CAREBY, TLSCOPE, pv_BRID, TLGOUPS)=0*\) cf,
                    brgrp br
where  v.afacctno like l_AFACCTNO
    and v.trade + v.mortage + v.receiving + v.EXECQTTY + v.buyqtty > 0
    AND af.acctno = v.afacctno AND V.CODEID=SE.CODEID
    and af.custid = cf.custid
    AND substr(cf.brid,1,4) = br.brid
    AND V.seass>0
    AND A0.CDTYPE='CF' AND A0.CDNAME='PRODUCTTYPE' AND A0.CDVAL=AFT.PRODUCTTYPE
    and cf.custodycd like v_custodycd
    AND v.txdate BETWEEN v_FRDATE AND v_TODATE
    AND af.actype = aft.actype AND aft.producttype LIKE v_aftype
    AND br.brid LIKE v_brgid

UNION ALL*/

select v_currdate txdate, cf.custodycd, af.acctno afacctno, sb.symbol,
    (trade + receiving - execqtty + buyqtty) trade,
    nvl(rsk.mrratioloan,0) ratecl,

   (trade + receiving - execqtty + buyqtty) * nvl(rsk.mrratiorate,0)/100 * least(sb.MARGINCALLPRICE,nvl(rsk.mrpricerate,0))
       SEASS,cf.fullname,  a0.cdcontent  aftypename, br.brname,
   nvl(sb.BASICPRICE,0) BASICPRICE
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

        ) ORDER BY txdate, custodycd,/* afacctno, */symbol

        ;


/*SELECT v_currdate txdate, cf.custodycd, af.acctno afaccnto, v.symbol, v.trade + v.receiving+V.BUYQTTY-v.execqtty "trade",
 v.ratecl, v.seass, cf.fullname,  a0.cdcontent  aftypename, br.brname,v.BASICPRICE
FROM
       (SELECT * FROM CFMAST \*WHERE FNC_VALIDATE_SCOPE(BRID, CAREBY, TLSCOPE, pv_BRID, TLGOUPS)=0*\) cf,
        (select * from afmast where acctno LIKE l_AFACCTNO) af,
       -- (select * from cimast where acctno LIKE l_AFACCTNO)ci,
       -- (select * from v_getsecmargininfo where afacctno LIKE l_AFACCTNO) sec,
        (select * from vw_getsecmargindetail where afacctno LIKE l_AFACCTNO) v,

                aftype aft, brgrp br, ALLCODE A0, sbsecurities se
    where cf.custid = af.custid
    --and af.acctno = ci.afacctno
    AND af.actype = aft.actype
    AND substr(cf.brid,1,4) = br.brid
    and v.codeid=se.codeid
    and se.sectype<>'004'
    and af.acctno = v.afacctno(+)
    AND nvl(v.trade,0) + nvl(v.receiving,0) <> 0
     AND A0.CDTYPE='CF' AND A0.CDNAME='PRODUCTTYPE' AND A0.CDVAL=AFT.PRODUCTTYPE
    --and af.acctno = sec.afacctno(+)
    and af.acctno LIKE l_AFACCTNO
        AND cf.custodycd LIKE v_custodycd
        AND v_currdate BETWEEN v_frdate AND v_todate
        AND aft.producttype LIKE v_aftype
        AND br.brid  LIKE v_brgid
        ) ORDER BY txdate, custodycd,\* afacctno, *\symbol

        ;
*/



 EXCEPTION
   WHEN OTHERS
   THEN
        RETURN;
END;

 
 
 
 
/
