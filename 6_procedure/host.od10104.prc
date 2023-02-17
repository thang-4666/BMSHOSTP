SET DEFINE OFF;
CREATE OR REPLACE PROCEDURE od10104 (
   PV_REFCURSOR             IN OUT   PKG_REPORT.REF_CURSOR,
   OPT                      IN       VARCHAR2,
   pv_BRID                     IN       VARCHAR2,
   TLGOUPS        IN       VARCHAR2,
   TLSCOPE        IN       VARCHAR2,
   F_DATE                   IN       VARCHAR2,
   T_DATE                   IN       VARCHAR2
   )
IS
-- MODIFICATION HISTORY
-- KET QUA KHOP LENH CUA KHACH HANG
-- PERSON      DATE    COMMENTS
-- NAMNT   15-JUN-08  CREATED
-- DUNGNH  08-SEP-09  MODIFIED
-- THENN    27-MAR-2012 MODIFIED    SUA LAI TINH PHI, THUE DUNG
-- ---------   ------  -------------------------------------------
   V_STROPTION      VARCHAR2 (5);            -- A: ALL; B: BRANCH; S: SUB-BRANCH
   V_STRBRID        VARCHAR2 (4);            -- USED WHEN V_NUMOPTION > 0

   V_NUMBUY         NUMBER (20,2);

   l_MRAMT_BG               NUMBER(20,0);
   l_ODAMT_BG               NUMBER(20,0);
   l_ADDAMT_BG              NUMBER(20,0);
   l_ADD_TO_MRCRATE         number(20,0);
   l_NML                    number(20,0);
   l_QTTYAMT                number(20,0);

   --V_TRADELOG CHAR(2);
   --V_AUTOID NUMBER;
   V_FRDATE DATE ;
   V_TODATE DATE ;
   V_currdate date;
   v_next_indate    date;

-- DECLARE PROGRAM VARIABLES AS SHOWN ABOVE
BEGIN
   V_STROPTION := OPT;
   V_FRDATE := TO_DATE(F_DATE ,'DD/MM/YYYY');
   V_TODATE := TO_DATE(T_DATE ,'DD/MM/YYYY');
    SELECT fn_get_nextdate(V_TODATE,1) into v_next_indate
    FROM DUAL;
   select to_date(varvalue,'dd/mm/rrrr') into V_currdate from sysvar where varname = 'CURRDATE';


   select sum(lnprin+lnprovd) into l_MRAMT_BG
    from
    (
        select cf.custodycd, af.acctno afacctno, ls.rlsdate, ls.overduedate,
            ls.nml - nvl(lg.nml,0) lnprin,
            ls.ovd - nvl(lg.ovd,0) lnprovd,
            cf.fullname, ln.acctno lnacctno, aft.mnemonic, cf.brid
        from vw_lnmast_all ln, vw_lnschd_all ls, CFMAST cf, afmast af,aftype aft, cfmast cfb,
            (select autoid, sum(nml) nml, sum(ovd) ovd
            from (select * from lnschdlog union all select * from lnschdloghist) lg
            where lg.txdate > V_TODATE
            group by autoid) lg, mrtype mrt
        where ln.acctno = ls.acctno and instr(ls.reftype,'P') <> 0
            and ln.trfacctno = af.acctno and af.custid = cf.custid
            and ln.custbank = cfb.custid(+) and ls.autoid = lg.autoid(+)
            AND LN.FTYPE <> 'DF' and af.actype = aft.actype and af.actype <> '0000'
            and ls.rlsdate <= V_TODATE
            and aft.mrtype = mrt.actype(+) and nvl(mrt.mrtype,'N') <> 'N'
    );

    select sum(execamt) into l_ODAMT_BG
    from vw_odmast_all
    where deltd <> 'Y' and isdisposal = 'Y' and execamt <> 0
        and txdate between V_FRDATE and V_TODATE;


    if V_currdate = V_TODATE then
        --MR0063
        SELECT sum(
            case when aft.mnemonic <> 'T3' then
            round((case when nvl(ci.marginrate,0) * af.mrmrate = 0 then - nvl(ci.se_outstanding,0) else
            greatest( 0,- nvl(ci.se_outstanding,0) - nvl(ci.se_navaccount,0) *100/AF.MRCRATE) end),0)
            else 0 end) into l_ADD_TO_MRCRATE
        FROM CFMAST CF, AFMAST AF, BRGRP BR, BUF_CI_ACCOUNT CI,AFTYPE AFT, CIMAST CIM
            WHERE AF.CUSTID=CF.CUSTID
                AND CF.BRID=BR.BRID(+)
                AND CI.AFACCTNO=AF.ACCTNO
                AND AF.ACCTNO=CIM.ACCTNO(+)
                AND AF.ACTYPE=AFT.ACTYPE
                AND AF.ACTYPE<>'0000'
                and ((aft.mnemonic <>'T3' and
                ((ci.marginrate<af.mrlrate and af.mrlrate <> 0)
                OR (ci.marginrate<AF.MRCRATE AND (AF.CALLDAY >= 1 ))
                OR  (ci.marginrate<AF.MRMRATE )))
                );
        -- end MR0063
        --MR0058
        SELECT sum(round(LNS.NML+LNS.OVD)+round(LNS.INTNMLACR+LNS.INTOVD+LNS.INTOVDPRIN+LNS.FEEINTNMLACR+LNS.FEEDUE+LNS.INTDUE +LNS.FEEOVD+LNS.FEEINTOVDACR
            +LNS.FEEINTNMLOVD+LNS.FEEINTDUE+LNS.OVDFEEINT+LNS.FEEINTNML+LNS.FEEINTOVD)) into l_NML
        FROM lnmast  lnm, CFMAST cf,  afmast af, brgrp br, lnschd lns
        WHERE  af.custid=cf.custid
            AND LNM.ACCTNO=LNS.ACCTNO
            AND af.acctno =lnm.trfacctno
            AND br.brid=cf.brid
            and lnm.rlsamt > 0
            AND LNM.FTYPE='AF'
            and lns.RLSDATE is not null
            AND LNM.STATUS<>'Y'
            AND LNS.OVERDUEDATE <= V_currdate
            and round(LNS.NML+LNS.OVD)+round(LNS.INTNMLACR+LNS.INTOVD+LNS.INTOVDPRIN+LNS.FEEINTNMLACR+LNS.FEEDUE+LNS.INTDUE +LNS.FEEOVD+LNS.FEEINTOVDACR
            +LNS.FEEINTNMLOVD+LNS.FEEINTDUE+LNS.OVDFEEINT+LNS.FEEINTNML+LNS.FEEINTOVD) > 0;
        -- end MR0058
        l_ADDAMT_BG := NVL(l_ADD_TO_MRCRATE,0)+NVL(l_NML,0);
    else
        --MR0063
        select sum(nvl(ADD_TO_MRCRATE,0)) into l_ADD_TO_MRCRATE FROM TBL_MR0063 where indate = v_next_indate;
        -- end MR0063
        --MR0058
        SELECT sum(nvl(NML,0)+nvl(LAI_DUKIEN,0)) into l_NML FROM TBL_MR0058 where indate = v_next_indate;
        -- end MR0058
        l_ADDAMT_BG := NVL(l_ADD_TO_MRCRATE,0)+NVL(l_NML,0);
    end if;

    /*select sum(ROUND(greatest(round((case when nvl(ci.marginrate,0) * af.mrmrate =0 then - ci.outstanding else
    greatest( 0,- ci.outstanding - ci.navaccount *100/af.mrmrate) end),0),
        greatest(mst.dueamt+mst.ovamt+ci.OVDCIDEPOFEE - ci.balance - nvl(ci.avladvance,0),0)))) into l_ADDAMT_BG
    from CFMAST cf, afmast af, cimast mst, aftype aft,  mrtype mrt,
        buf_ci_account ci
    where cf.custid = af.custid and aft.mrtype = mrt.actype(+) and nvl(mrt.mrtype,'N') <> 'N'
    and cf.custatcom = 'Y'
    and af.actype = aft.actype
    and af.acctno = ci.afacctno
    and af.acctno = mst.afacctno
    AND cf.status <> 'C';*/
if V_currdate = V_TODATE then
    select
        sum((se.trade + se.receiving - se.execqtty + se.buyqtty) * nvl(sb.BASICPRICE,0)) into l_QTTYAMT
    from
    (
        select se.codeid, af.actype, af.mriratio, se.afacctno,se.acctno, se.trade, se.mortage ,
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
        and not(od.grporder='Y' and od.matchtype='P') --Lenh thoa thuan tong khong tinh vao
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
    ) se, securities_info sb, sbsecurities sbs,
    (
    SELECT distinct AF.ACCTNO afACCTNO
    FROM CFMAST CF, AFMAST AF, BRGRP BR, BUF_CI_ACCOUNT CI,AFTYPE AFT, CIMAST CIM
        WHERE AF.CUSTID=CF.CUSTID
            AND CF.BRID=BR.BRID(+)
            AND CI.AFACCTNO=AF.ACCTNO
            AND AF.ACCTNO=CIM.ACCTNO(+)
            AND AF.ACTYPE=AFT.ACTYPE
            AND AF.ACTYPE<>'0000'
            and ((aft.mnemonic <>'T3' and
            ((ci.marginrate<af.mrlrate and af.mrlrate <> 0)
            OR (ci.marginrate<AF.MRCRATE AND (AF.CALLDAY >= 1 ))
            OR  (ci.marginrate<AF.MRMRATE )))
            )
    union
    select distinct ln.trfacctno afACCTNO from lnschd lns, lnmast ln
    where lns.acctno = ln.acctno and lns.OVERDUEDATE <= getcurrdate
        and LNS.NML+LNS.OVD+round(LNS.INTNMLACR+LNS.INTOVD+LNS.INTOVDPRIN+LNS.FEEINTNMLACR+LNS.FEEDUE+LNS.INTDUE +LNS.FEEOVD+LNS.FEEINTOVDACR
            +LNS.FEEINTNMLOVD+LNS.FEEINTDUE+LNS.OVDFEEINT+LNS.FEEINTNML+LNS.FEEINTOVD) <> 0
        and  LN.FTYPE='AF' and lns.RLSDATE is not null
            AND LN.STATUS <> 'Y'
    ) MR
    where se.codeid = sb.codeid (+) and se.codeid = sbs.codeid
    and sbs.tradeplace in ('001','002','005') and se.afacctno = mr.afACCTNO and sbs.sectype <> '004'
    ;
else
    select
        sum(se.sereal) into l_QTTYAMT
    from
    (
        select lg.afacctno, sum(nvl(lg.sereal,0)) sereal
        from tbl_mr3007_log lg, sbsecurities sb
        where lg.txdate = V_TODATE
            and lg.codeid = sb.codeid and sb.sectype <> '004'
        group by lg.afacctno
    ) se,
    (
        select distinct acctno afacctno FROM TBL_MR0063 where indate = v_next_indate
        union
        SELECT distinct trfacctno afacctno FROM TBL_MR0058 where indate = v_next_indate
    ) MR
    where se.afacctno = mr.afACCTNO
    ;

end if;


-- GET REPORT'S DATA
OPEN PV_REFCURSOR FOR
select TRUNC(nvl(l_MRAMT_BG,0)/1000000,3) MRAMT, TRUNC(nvl(l_ODAMT_BG,0)/1000000,3) RLSAMT,
    TRUNC(nvl(l_ADDAMT_BG,0) /1000000,3) MR_ADDAMT, TRUNC(nvl(l_QTTYAMT,0)/1000000,3) QTTYAMT
from dual
;
EXCEPTION
   WHEN OTHERS
   THEN
      RETURN;
END;
-- PROCEDURE
 
/
