SET DEFINE OFF;
CREATE OR REPLACE PROCEDURE SE0119  (
   PV_REFCURSOR             IN OUT   PKG_REPORT.REF_CURSOR,
   OPT                      IN       VARCHAR2,
   PV_BRID                  IN       VARCHAR2,
   TLGOUPS                  IN       VARCHAR2,
   TLSCOPE                  IN       VARCHAR2,
   F_DATE                   IN       DATE,
   T_DATE                   IN       DATE,
   PV_SYMBOL                IN       VARCHAR2
           )
IS

    v_SHAREHOLDERSID VARCHAR2(15);
    v_currdate date;
    V_SYMBOL VARCHAR2(50);
BEGIN
    v_currdate:=getcurrdate;
    --V_SYMBOL:=PV_SYMBOL;
    IF  (upper(PV_SYMBOL) <> 'ALL' )
    THEN
          V_SYMBOL := upper(REPLACE (PV_SYMBOL,' ','_'));
    ELSE
          V_SYMBOL := '%';
    END IF;
/*
    if v_Symbol = 'ALL' or v_Symbol is null then
        v_Symbol := '%';
    else
        v_Symbol := '%'|| v_Symbol||'%';
    end if;
*/
OPEN PV_REFCURSOR
FOR
select nvl(ps.shareholdersid,dk.shareholdersid) shareholdersid,cf.fullname, cf.address,cf.idcode,cf.iddate,cf.custodycd,se.opndate,se.lastdate,to_date(ps.txdate,'dd/mm/yyyy') PS_TDATE,
case when ps.shareholdersid is not null then cf.fullname else null end oldshareholdersid,
a1.cdval custtype, a1.cdcontent custtype_desc,
--phat sinh tang
nvl(ps.PSTANG,0)*10000  PSTANG,
--phat sinh giam
nvl(ps.PSGIAM,0)*10000  PSGIAM, ps.tltxcd,
--gia tri cuoi ky
((nvl(se.trade,0) + nvl(se.mortage,0) + nvl(se.emkqtty,0) + nvl(se.blocked,0))-nvl(ck.PSTANG,0)+nvl(ck.PSGIAM,0))*10000 CUOIKY,
--gia tri dau ky
((nvl(se.trade,0) + nvl(se.mortage,0) + nvl(se.emkqtty,0) + nvl(se.blocked,0))-nvl(dk.PSTANG,0)+nvl(dk.PSGIAM,0))*10000 DAUKY
from semast se, CFMAST cf,sbsecurities sb,allcode a1,
(
--lay phat sinh
select *
from(
    select se.autoid, se.txdate, se.tltxcd, se.seacctno, se.shareholdersid,se.amount  PSTANG, 0 PSGIAM
    from seotctranlog se
    where  tltxcd='2229'
    UNION ALL
    select  se.autoid, se.txdate, se.tltxcd, se.seacctno, se.shareholdersid,se.amount  PSTANG, 0 PSGIAM
    from seotctranlog se
    where  tltxcd='2227'
    UNION ALL
    select  se.autoid, se.txdate, se.tltxcd, se.seacctno, se.shareholdersid,se.amount  PSTANG, 0 PSGIAM
    from seotctranlog se
    where  tltxcd='9902'
    union
    select se.autoid, se.txdate, se.tltxcd,  se.oldseacctno seacctno , se.oldshareholdersid oldshareholdersid ,0 PSTANG, nvl(se.amount,0)  PSGIAM
    from seotctranlog se
    where  tltxcd='2229'
    UNION ALL
    select  se.autoid, se.txdate, se.tltxcd,  se.oldseacctno seacctno , se.oldshareholdersid shareholdersid ,0 PSTANG ,nvl(se.amount,0)  PSGIAM
    from seotctranlog se
    where tltxcd='2228'
    ) where txdate >= to_date(F_DATE,'dd/mm/yyyy') and txdate <= to_date(T_DATE,'dd/mm/yyyy') --and shareholdersid =v_SHAREHOLDERSID
) ps,
--gia tri tong cuoi ky
(
select se.seacctno, se.shareholdersid, sum(PSTANG) PSTANG, SUM(PSGIAM) PSGIAM
from(
    select  se.txdate, se.tltxcd, se.seacctno, se.shareholdersid,se.amount  PSTANG, 0 PSGIAM
    from seotctranlog se
    where  tltxcd='2229'
    UNION ALL
    select  se.txdate, se.tltxcd, se.seacctno, se.shareholdersid,se.amount  PSTANG, 0 PSGIAM
    from seotctranlog se
    where  tltxcd='2227'
    UNION ALL
    select  se.txdate, se.tltxcd, se.seacctno, se.shareholdersid,se.amount  PSTANG, 0 PSGIAM
    from seotctranlog se
    where  tltxcd='9902'
    union
    select se.txdate, se.tltxcd,  se.oldseacctno seacctno , se.oldshareholdersid shareholdersid ,0 PSTANG, nvl(se.amount,0)  PSGIAM
    from seotctranlog se
    where  tltxcd='2229'
    UNION ALL
    select  se.txdate, se.tltxcd,  se.oldseacctno seacctno , se.oldshareholdersid shareholdersid ,0 PSTANG ,nvl(se.amount,0)  PSGIAM
    from seotctranlog se
    where tltxcd='2228') se
    where txdate >  to_date(T_DATE,'dd/mm/yyyy')
    --and txdate <= v_currdate --and shareholdersid =v_SHAREHOLDERSID
    group by seacctno, shareholdersid
)ck,
--gia tri tong dau ky
(
    select se.seacctno, se.shareholdersid, sum(PSTANG) PSTANG, SUM(PSGIAM) PSGIAM
from(
    select  se.txdate, se.tltxcd, se.seacctno, se.shareholdersid,se.amount  PSTANG, 0 PSGIAM
    from seotctranlog se
    where  tltxcd='2229'
    UNION ALL
    select  se.txdate, se.tltxcd, se.seacctno, se.shareholdersid,se.amount  PSTANG, 0 PSGIAM
    from seotctranlog se
    where  tltxcd='2227'
    UNION ALL
    select  se.txdate, se.tltxcd, se.seacctno, se.shareholdersid,se.amount  PSTANG, 0 PSGIAM
    from seotctranlog se
    where  tltxcd='9902'
    union
    select se.txdate, se.tltxcd,  se.oldseacctno seacctno , se.oldshareholdersid shareholdersid ,0 PSTANG, nvl(se.amount,0)  PSGIAM
    from seotctranlog se
    where  tltxcd='2229'
    UNION ALL
    select  se.txdate, se.tltxcd,  se.oldseacctno seacctno , se.oldshareholdersid shareholdersid ,0 PSTANG ,nvl(se.amount,0)  PSGIAM
    from seotctranlog se
    where tltxcd='2228') se
    where txdate >= to_date(F_DATE,'dd/mm/yyyy')
    --and txdate <= v_currdate --and shareholdersid =v_SHAREHOLDERSID
    group by seacctno, shareholdersid
) dk

where se.custid = cf.custid
and se.codeid = sb.codeid(+)
and se.acctno = ps.seacctno(+)
and se.acctno = dk.seacctno(+)
and se.acctno = ck.seacctno(+)
and a1.cdtype = 'CF'
and a1.cdname='CUSTTYPE2'
and ps.shareholdersid is not null
and a1.cdval=(case when cf.custtype='I' and cf.country='234' then '001'
               when cf.custtype='B' and cf.country='234' then '002'
               when cf.custtype='B' then '004'
               when cf.custtype='I' then '003' else '000' end)
and sb.symbol like V_SYMBOL
order by a1.cdval, shareholdersid, ps.autoid;
--and ps.shareholdersid=v_SHAREHOLDERSID;
EXCEPTION
   WHEN OTHERS
   THEN
      RETURN;
END;--thunt
 
/
