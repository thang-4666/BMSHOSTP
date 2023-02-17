SET DEFINE OFF;
CREATE OR REPLACE PROCEDURE "T0CALCULATE" (frdate IN VARCHAR2, ERR_CODE out Varchar2)
  IS

  V_FRDATE VARCHAR2(10);
  v_afacctno VARCHAR2(20);
  v_TOAMT number(20,4);
  v_TOODAMT number(20,4);
  v_groupleader VARCHAR2(20);
  v_TOTALTOAMT number(20,4);
  v_TOTALTOODAMT number(20,4);
  v_rcvT0 number(20,4);
BEGIN
    V_FRDATE:=frdate;
    --1.Phan bo voi T0 khong thuoc group
    for rec in(
        select afacctno, T0,greatest(least(T0, T0-PP),0) ADDVND,BUYAMT  from
        (SELECT cimast.afacctno, af.mrirate,nvl(af.advanceline,0) T0,
                   /*nvl(af.MRCRLIMIT,0) +*/ nvl(se.SEASS,0)  NAVACCOUNT,
                   nvl(b.execbuyamt,0) BUYAMT,
                   balance+ nvl(se.receivingamt,0)- odamt - NVL (advamt, 0) - ramt OUTSTANDING, ---nvl(secureamt,0) khong tinh den vi khi chay batch da cat tien roi
                   greatest(least(nvl(af.MRCRLIMIT,0) + nvl(se.SEAMT,0)+
                                nvl(se.receivingamt,0)
                        ,nvL(af.MRCRLIMITMAX,0)+nvl(af.MRCRLIMIT,0)) +
                   nvl(af.advanceline,0) + balance- odamt  - ramt,0) PP  ---nvl(secureamt,0) khong tinh den vi khi chay batch da cat tien roi

               FROM cimast inner join afmast af on af.acctno = cimast.afacctno and length(nvl(af.groupleader,'_'))<>10
                           inner join aftype aft on af.actype = aft.actype
                           inner join mrtype mrt on aft.mrtype = mrt.actype  and mrt.mrtype IN ('S','T')
               left join
                (select * from v_getbuyorderinfoT0 ) b
                on  cimast.acctno = b.afacctno

                LEFT JOIN
                v_getsecmargininfo SE
                on se.afacctno=cimast.acctno)
                WHERE T0>0
     )
      loop
            v_afacctno:=rec.afacctno;
            v_TOODAMT:=greatest(least(rec.BUYAMT,least(rec.t0,rec.ADDVND)),0);
            v_TOAMT:=rec.t0-v_TOODAMT;
            gentransaction1159(v_afacctno, v_TOODAMT,v_TOAMT);
      end loop;

    --2.Phan bo voi T0 thuoc group
    for rec in(
            select A.afacctno, T0,greatest(least(T0, T0-PP),0) ADDVND,BUYAMT  from
             (SELECT af.groupleader AFACCTNO, sum (nvl(af.advanceline,0)) T0,
                   sum(/*nvl(af.MRCRLIMIT,0) +*/ nvl(se.SEASS,0))  NAVACCOUNT,
                   sum(nvl(b.execbuyamt,0)) BUYAMT,
                   sum(balance+ nvl(se.receivingamt,0)- odamt - NVL (advamt, 0) - ramt) OUTSTANDING, ---nvl(secureamt,0) khong tinh den vi khi chay batch da cat tien roi
                   greatest(least(SUM(nvl(af.MRCRLIMIT,0) + nvl(se.SEAMT,0)+
                                nvl(se.receivingamt,0))
                        ,SUM(nvL(af.MRCRLIMITMAX,0)+nvl(af.MRCRLIMIT,0))) +
                   SUM(nvl(af.advanceline,0) + balance- odamt  - ramt),0) PP    ---nvl(secureamt,0) khong tinh den vi khi chay batch da cat tien roi
                   FROM cimast inner join afmast af on af.acctno = cimast.afacctno and length(nvl(af.groupleader,'_'))=10
                               inner join aftype aft on af.actype = aft.actype
                               inner join mrtype mrt on aft.mrtype = mrt.actype  and mrt.mrtype IN ('S','T')
                   LEFT JOIN
                    (select b.* from v_getbuyorderinfoT0 b) b
                    on  cimast.acctno = b.afacctno

                   LEFT JOIN
                    (select b.* from v_getsecmargininfo b) SE
                    on se.afacctno=cimast.acctno
                    group by af.groupleader) A, AFMAST AF
             where A.AFACCTNO =AF.ACCTNO AND A.T0>0

       )
      loop
            v_groupleader:=rec.afacctno;
            v_TOTALTOODAMT:=greatest(least(rec.BUYAMT,least(rec.t0,rec.ADDVND)),0);
            v_TOTALTOAMT:=REC.T0-v_TOTALTOODAMT;
            for rec1 in (
                select acctno afacctno,af.advanceline T0,nvl(b.execbuyamt,0) BUYAMT from afmast af
                LEFT JOIN
                    (select b.* from v_getbuyorderinfoT0 b) b
                on  af.acctno = b.afacctno
                where af.groupleader=v_groupleader and af.advanceline>0
                order by b.secureamt desc
            )
            loop
                v_afacctno:=rec1.afacctno;
                v_rcvT0:=least(rec1.T0,rec1.BUYAMT);
                if v_TOTALTOODAMT>=v_rcvT0 then
                    v_TOTALTOODAMT:=v_TOTALTOODAMT-v_rcvT0;
                    gentransaction1159(v_afacctno, v_rcvT0,rec1.T0-v_rcvT0);
                else
                    gentransaction1159(v_afacctno, v_TOTALTOODAMT,rec1.T0-v_TOTALTOODAMT);
                    v_TOTALTOODAMT:=0;
                end if;
            end loop;
      end loop;
      ERR_CODE:='0';
EXCEPTION
    WHEN others THEN
        ERR_CODE:='-1';
        return;
END;

 
 
 
 
/
