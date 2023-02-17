SET DEFINE OFF;
CREATE OR REPLACE PROCEDURE "CA0012" (
   PV_REFCURSOR   IN OUT   PKG_REPORT.REF_CURSOR,
   OPT            IN       VARCHAR2,
   BRID           IN       VARCHAR2,
   TLGOUPS        IN       VARCHAR2,
   TLSCOPE        IN       VARCHAR2,
   F_DATE         IN       VARCHAR2,
   T_DATE         IN       VARCHAR2,
   CACODE         IN       VARCHAR2,
   PLSENT         in       varchar2  -- MA SU KIEM
   )
IS
--
-- PURPOSE: DANH SACH TONG HOP CHUYEN NHUONG QUYEN MUA CK
--creted by CHaunh at 29/02/2012
-- ---------   ------  -------------------------------------------

    CUR             PKG_REPORT.REF_CURSOR;
    V_STROPTION    VARCHAR2 (5);            -- A: ALL; B: BRANCH; S: SUB-BRANCH
    V_STRBRID      VARCHAR2 (4);
    V_FRDATE       DATE;
    V_TODATE       DATE;
    V_STRCACODE   VARCHAR2 (20);
    v_secname  varchar2(100);
    v_secid varchar2(10);
    v_endate varchar2(10);
    v_tvlk varchar2(5);

BEGIN
   V_STROPTION := OPT;

   IF (V_STROPTION <> 'A') AND (BRID <> 'ALL')
   THEN
      V_STRBRID := BRID;
   ELSE
      V_STRBRID := '%%';
   END IF;

   V_FRDATE    := TO_DATE(F_DATE,'DD/MM/RRRR');
   V_TODATE    := TO_DATE(T_DATE,'DD/MM/RRRR');
   V_STRCACODE := CACODE;
/*   select issuers.fullname, sb.codeid, camast.todatetransfer,'005' into v_secname, v_secid, v_endate, v_tvlk
   from camast, sbsecurities sb, ISSUERS
   where camast.codeid = sb.codeid and issuers.issuerid = sb.issuerid and camast.catype = '014'
   and camast.camastid = V_STRCACODE ;*/



   -- GET REPORT'S PARAMETERS

OPEN PV_REFCURSOR
   FOR
select  case when substr(main.tk_doiung,4,1) = 'P' then 'Tu doanh' else 'Moi gioi' end loai_hinh,
        case when substr(main.tk_doiung,4,1) = 'C' then 'Trong nuoc'
             when substr(main.tk_doiung,4,1) = 'F' then 'Nuoc ngoai' end trong_ngoai_nuoc,
        case when cfmast.custtype = 'I'  then 'Ca nhan'
             else 'To chuc' end loai_kh,
        issuers.fullname v_secname, sb.symbol v_secid,
        iss.fullname toissname, sb2.symbol tosymbol,
        camast.reportdate v_endate, '006' v_tvlk, PLSENT sendto,
        main.tk_doiung, main.ho_ten, main.idcode, main.address, main.quoc_tich, main.so_TaiKLK,
        main.SLQM_pb -SLQM_nhan SLQM_pb,
        main.SLQM_chuyen - ( case when sn.txtype = 'C' then nvl(sn.namt,0) else 0 end) SLQM_chuyen,
        main.SLQM_nhan - ( case when sn.txtype = 'D' then nvl(sn.namt,0) else 0 end) SLQM_nhan,
        main.ghi_chu, main.custodycd
from
(select  (case when se.tltxcd = '3382' then fld.tk_doiung
                                      else cf.custodycd end) tk_doiung,
        cf.fullname ho_ten,
        case when cf.country = '234' then cf.idcode else cf.tradingcode end idcode, --neu la nguoi nuoc ngoai thi lay trading code
        cf.address,cf.quoc_gia quoc_tich,
        cf.custodycd so_TaiKLK,
        max(ca.slq_ht) SLQM_pb,
        SUM(case when se.txtype = 'D' then se.namt else 0 end) SLQM_chuyen,
        SUM(case when se.txtype = 'C' then se.namt else 0 end) SLQM_nhan,
        'Mua'  ghi_chu,
        cf.custodycd
from
    (select  se.txnum, se.txdate, se.custodycd, se.namt namt , ca.camastid, se.tltxcd, se.txtype,
            sum(case when sen.txtype = 'C'  then sen.namt
                    when sen.txtype = 'D'  then -sen.namt
                     end ) so_du
        from vw_setran_gen se,
            (
                select tran.acctno, tran.namt, camastid, tran.txtype, tran.txdate, tran.txnum , tran.tltxcd
                from vw_setran_gen tran, caschd
                where  tran.tltxcd in ('3383','3398')
                and tran.txtype in ('D','C')
                and caschd.deltd <> 'Y' and camastid = V_STRCACODE AND caschd.autoid = tran.ref
            ) sen, caschd ca
        where se.acctno =  sen.acctno(+) AND ca.camastid = sen.camastid  and se.deltd <> 'Y'
            AND se.txtype in ('C','D')
            and se.tltxcd in ('3383','3398')
            and sen.txdate >= se.txdate
            and sen.txnum >= (case when sen.txdate = se.txdate then se.txnum
                            when sen.txdate <  se.txdate then '9999999999'
                            else '0'end )
        and se.txdate <= V_TODATE and se.txdate >= V_FRDATE
        and ca.camastid  = V_STRCACODE AND ca.autoid = se.REF AND ca.deltd <> 'Y'
    group by se.txdate, se.txnum, se.custodycd,se.namt,ca.camastid,se.tltxcd,se.txtype
    order by se.txdate, se.txnum
    )  se
    left join
    (select  caschd.camastid,
    sum(caschd.balance+caschd.retailbal+nvl(caschd.outbalance,0)) slq_ht, cf.custodycd
        from caschd , cfmast cf, afmast af
        where caschd.deltd = 'N'
            and caschd.afacctno = af.acctno and cf.custid = af.custid
        and caschd.camastid = V_STRCACODE
        GROUP BY caschd.camastid, cf.custodycd
        ) ca
    on se.camastid = ca.camastid and se.custodycd = ca.custodycd
    left join
    (select cfmast.*, allcode.cdcontent quoc_gia from cfmast, allcode where allcode.cdname = 'COUNTRY' and allcode.cdval = cfmast.country and allcode.cdtype = 'CF') cf
    on cf.custodycd = se.custodycd
    left join
    (select fld.txnum, fld.txdate, max(nvl(cvalue,nvalue)) tk_doiung
        from (select * from tllogfldall union all select * from tllogfld) fld  where  fld.fldcd = '36' group by fld.txnum, fld.txdate) fld
    on fld.txdate = se.txdate and fld.txnum = se.txnum
    GROUP BY (case when se.tltxcd = '3382' then fld.tk_doiung
                                      else cf.custodycd end) ,
        cf.fullname ,
        case when cf.country = '234' then cf.idcode else cf.tradingcode end , --neu la nguoi nuoc ngoai thi lay trading code
        cf.address, cf.quoc_gia ,
        cf.custodycd, cf.custodycd
) main, cfmast, camast, sbsecurities sb, ISSUERS, sbsecurities sb2, issuers iss,
    (
        select tran.custodycd, sum(tran.namt) namt, tran.txtype
            from vw_setran_gen tran, caschd
            where  tran.tltxcd in ('3353','3392')
            and tran.txtype in ('D','C')
            and caschd.deltd <> 'Y' and camastid = V_STRCACODE AND caschd.autoid = tran.ref
            and tran.txdate <= V_TODATE and tran.txdate >= V_FRDATE
            group by tran.custodycd, camastid, tran.txtype
    ) sn
    ---- on se.camastid = sn.camastid and se.custodycd = sn.custodycd
where main.tk_doiung = cfmast.custodycd
    and main.tk_doiung = sn.custodycd (+)
    and camast.codeid = sb.codeid
    and issuers.issuerid = sb.issuerid and camast.catype = '014'
    AND nvl(camast.tocodeid,camast.codeid) = sb2.codeid AND iss.issuerid = sb2.issuerid
    and camast.camastid = V_STRCACODE
union all
select null loai_hinh, null trong_ngoai_nuoc, null loai_kh,
    max(issuers.fullname) v_secname, max(sb.symbol) v_secid,
    max(iss.fullname) toissname, max(sb2.symbol) tosymbol,
    max(ca.reportdate) v_endate, max(tr.tomemcus) v_tvlk, PLSENT sendto,
    null tk_doiung, max(tr.custname2) ho_ten
    ,tr.license2 idcode, max(tr.address2) address, max(tr.country2) quoc_tich, tr.toacctno so_TaiKLK,
     0 SLQM_pb, 0 SLQM_chuyen, sum(tr.amt) SLQM_nhan, null ghi_chu, tr.toacctno custodycd
from catransfer tr, camast ca, sbsecurities sb, ISSUERS, sbsecurities sb2, issuers iss
where tr.status <> 'C' and substr(tr.toacctno,1,4) <> '002C'
    and tr.camastid = ca.camastid and  ca.codeid = sb.codeid
    and issuers.issuerid = sb.issuerid
    and tr.camastid = V_STRCACODE and ca.camastid = V_STRCACODE
    AND nvl(ca.tocodeid,ca.codeid) = sb2.codeid AND iss.issuerid = sb2.issuerid
group by tr.toacctno, tr.license2
order by SLQM_nhan , SLQM_chuyen
;
EXCEPTION
   WHEN OTHERS
   THEN
      RETURN;
END;                                                              -- PROCEDURE

 
 
 
 
/
