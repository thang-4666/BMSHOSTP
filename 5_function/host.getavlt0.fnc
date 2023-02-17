SET DEFINE OFF;
CREATE OR REPLACE FUNCTION getavlt0(pv_afacctno IN varchar2)
  RETURN number
  IS
    v_Result number(18,5);
    v_margintype char(1);
    v_actype varchar2(4);
    v_groupleader varchar2(10);

BEGIN
v_Result:=0;
SELECT MR.MRTYPE,af.actype,mst.groupleader
            into v_margintype,v_actype,v_groupleader
        from afmast mst,aftype af, mrtype mr
        where mst.actype=af.actype and af.mrtype=mr.actype and mst.acctno=pv_afacctno;
if v_margintype in ('N','L') then
    select least(T0,avllimit) AVLT0 into v_Result  from
            (SELECT cimast.afacctno,af.T0AMT, af.mrirate,nvl(af.advanceline,0) T0,
                       nvl(adv.avladvance,0) + af.advanceline + balance- odamt  - dfdebtamt - dfintdebtamt- nvl (advamt, 0)-nvl(secureamt,0) - ramt avllimit
                   FROM cimast inner join afmast af on af.acctno = cimast.afacctno and af.acctno =pv_afacctno
                               inner join aftype aft on af.actype = aft.actype
                               inner join mrtype mrt on aft.mrtype = mrt.actype  and mrt.mrtype in ('N','L')
                   left join
                    (select * from v_getbuyorderinfo where afacctno =pv_afacctno) b
                    on  cimast.acctno = b.afacctno
                   left join
                    (select sum(depoamt) avladvance,afacctno
                        from v_getAccountAvlAdvance where afacctno = pv_afacctno group by afacctno) adv
                    on adv.afacctno=cimast.acctno
                    )
                    WHERE T0>0;
elsif v_margintype in ('S','T') and (length(v_groupleader)=0 or  v_groupleader is null) then

        select T0-LEAST(greatest(least(T0, T0-PP),0),BUYAMT) AVLT0 into v_Result  from
            (SELECT cimast.afacctno,af.T0AMT, af.mrirate,nvl(af.advanceline,0) T0,
                       --nvl(af.MRCRLIMIT,0) + nvl(se.SEASS,0)  + nvl(se.trfass,0)  NAVACCOUNT,
                      /* nvl(af.MRCRLIMIT,0) +*/ nvl(se.SEASS,0)   NAVACCOUNT,
                       nvl(b.secureamt,0) BUYAMT,
                       nvl(adv.avladvance,0) + balance+least(nvl(af.MRCRLIMIT,0),nvl(secureamt,0)) - odamt - dfdebtamt - dfintdebtamt- NVL (advamt, 0)-nvl(secureamt,0) - ramt OUTSTANDING,
/*                       greatest(least((nvl(se.MRCRLIMIT,0) + nvl(se.SEAMT,0)+
                                    nvl(se.receivingamt,0)) + nvl(se.trfamt,0)
                            ,nvL(se.MRCRLIMITMAX,0)) +
                       balance- odamt -nvl(secureamt,0) - ramt,0) PP*/
                       --greatest(cimast.balance - nvl(secureamt,0) + nvl(adv.avladvance,0) + af.advanceline + least(nvl(af.mrcrlimitmax,0),nvl(af.mrcrlimit,0) + nvl(se.seamt,0)+nvl(se.trfamt,0)) - nvl(cimast.odamt,0) - cimast.dfdebtamt - cimast.dfintdebtamt,0) pp
                       greatest(cimast.balance - nvl(secureamt,0) + nvl(adv.avladvance,0) + af.advanceline + least(nvl(af.mrcrlimitmax,0)+nvl(af.mrcrlimit,0),nvl(af.mrcrlimit,0) + nvl(se.seamt,0)) - nvl(cimast.odamt,0) - cimast.dfdebtamt - cimast.dfintdebtamt,0) pp

                   FROM cimast inner join afmast af on af.acctno = cimast.afacctno and af.acctno =pv_afacctno
                               inner join aftype aft on af.actype = aft.actype
                               inner join mrtype mrt on aft.mrtype = mrt.actype  and mrt.mrtype in ('S','T')
                   left join
                    (select * from v_getbuyorderinfo where afacctno =pv_afacctno) b
                    on  cimast.acctno = b.afacctno

                    LEFT JOIN
                    (select * from v_getsecmargininfo where afacctno =pv_afacctno) SE
                    on se.afacctno=cimast.acctno
                    left join
                    (select sum(depoamt) avladvance,afacctno
                        from v_getAccountAvlAdvance where afacctno = pv_afacctno group by afacctno) adv
                    on adv.afacctno=cimast.acctno
                    )
                    WHERE T0>0;
else
        select advanceline-LEAST(greatest(least(advanceline, -PP),0),BUYAMT) into v_Result  from
                 (SELECT af.groupleader AFACCTNO,sum (nvl(af.advanceline,0)) T0,
                       --sum(nvl(af.MRCRLIMIT,0) + nvl(se.SEASS,0)  + nvl(se.trfass,0))  NAVACCOUNT,
                       sum(/*nvl(af.MRCRLIMIT,0) +*/ nvl(se.SEASS,0))  NAVACCOUNT,
                       sum(CASE WHEN af.acctno=pv_afacctno THEN  nvl(b.secureamt,0) ELSE 0 END) BUYAMT,
                       sum(balance+least(nvl(af.MRCRLIMIT,0),nvl(secureamt,0))+ nvl(adv.avladvance,0)- odamt- dfdebtamt - dfintdebtamt - NVL (advamt, 0)-nvl(secureamt,0) - ramt) OUTSTANDING,
/*                       least(SUM(nvl(se.MRCRLIMIT,0) + nvl(se.SEAMT,0)+
                                    nvl(se.receivingamt,0) + nvl(se.trfamt,0))
                            ,SUM(nvl(adv.avladvance,0) + nvL(se.MRCRLIMITMAX,0))) +
                       SUM(balance- odamt -nvl(secureamt,0) - ramt) PP*/
                       --greatest(sum(cimast.balance) - sum(nvl(secureamt,0)) + sum(nvl(adv.avladvance,0)) + sum(af.advanceline) + least(sum(nvl(af.mrcrlimitmax,0)),sum(nvl(af.mrcrlimit,0)) + sum(nvl(se.seamt,0))+sum(nvl(se.trfamt,0))) - sum(nvl(cimast.odamt,0)) - sum(cimast.dfdebtamt) - sum(cimast.dfintdebtamt),0) pp
                       greatest(sum(cimast.balance) - sum(nvl(secureamt,0)) + sum(nvl(adv.avladvance,0)) + sum(af.advanceline) + least(sum(nvl(af.mrcrlimitmax,0)+nvl(af.mrcrlimit,0)),sum(nvl(af.mrcrlimit,0)) + sum(nvl(se.seamt,0))) - sum(nvl(cimast.odamt,0)) - sum(cimast.dfdebtamt) - sum(cimast.dfintdebtamt),0) pp
                       FROM cimast inner join afmast af on af.acctno = cimast.afacctno and af.groupleader=v_groupleader
                                   inner join aftype aft on af.actype = aft.actype
                                   inner join mrtype mrt on aft.mrtype = mrt.actype  and mrt.mrtype in ('S','T')
                       LEFT JOIN
                        (select b.* from v_getbuyorderinfo b) b
                        on  cimast.acctno = b.afacctno

                       LEFT JOIN
                        (select b.* from v_getsecmargininfo b) SE
                        on se.afacctno=cimast.acctno
                       LEFT JOIN
                       (select sum(depoamt) avladvance,afacctno
                            from v_getAccountAvlAdvance b , afmast af
                            where b.afacctno =af.acctno and af.groupleader=v_groupleader
                            group by afacctno) adv
                        on adv.afacctno=cimast.acctno
                        group by af.groupleader) A, AFMAST AF
                 where AF.GROUPLEADER =A.AFACCTNO and af.acctno=pv_afacctno AND A.T0>0;
end if;
return v_Result;
exception when others then
    return 0;
END;

 
 
 
 
 
 
 
 
 
 
 
 
 
/
