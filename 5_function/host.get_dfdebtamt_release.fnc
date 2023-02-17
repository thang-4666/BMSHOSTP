SET DEFINE OFF;
CREATE OR REPLACE FUNCTION get_dfdebtamt_release(
        f_ACCTNO IN VARCHAR2,
        f_TYPE in varchar2)
RETURN NUMBER
  IS
  V_ACCTNO VARCHAR2(30);
  v_type char(1);
  v_margintype char(1);
  v_actype varchar2(4);
  v_groupleader varchar2(10);
  v_INDATE date;
  V_AVLRelease NUMBER;
BEGIN

    V_ACCTNO:=F_ACCTNO;
    v_type:=f_TYPE;
    V_AVLRelease:=0;
    select to_date(VARVALUE,'DD/MM/YYYY') into v_INDATE from sysvar where grname ='SYSTEM' and varname ='CURRDATE';
      SELECT MR.MRTYPE,af.actype,mst.groupleader into v_margintype,v_actype,v_groupleader from afmast mst,aftype af, mrtype mr where mst.actype=af.actype and af.mrtype=mr.actype and mst.acctno=V_ACCTNO;
        if v_margintype in ('N','L') then
            --Tai khoan binh thuong khong Margin
                SELECT  greatest(nvl(adv.avladvance,0) + nvl(balance,0) - NVL (advamt, 0)-nvl(secureamt,0) - nvl(ramt,0) - nvl(pd.dealpaidamt,0),0) AVLWITHDRAW
--                greatest(mst.balance - nvl(al.secureamt,0) - mst.odamt - NVL (al.advamt, 0),0) avlwithdraw
                        INTO V_AVLRelease
                  FROM cimast mst inner join afmast af on af.acctno = mst.afacctno AND mst.acctno = V_ACCTNO
                       inner join sbcurrency ccy on ccy.ccycd = mst.ccycd
                       left join
                       (select * from v_getbuyorderinfo where afacctno = V_ACCTNO) al
                        on mst.acctno = al.afacctno
                       left join
                       (select sum(depoamt) avladvance,afacctno
                            from v_getAccountAvlAdvance where afacctno = V_ACCTNO group by afacctno) adv
                        on adv.afacctno=mst.acctno
                        left join (select * from v_getdealpaidbyaccount p where p.afacctno = V_ACCTNO) pd
                        on pd.afacctno = mst.afacctno
                         ;
        elsif v_margintype in ('S','T') and (length(v_groupleader)=0 or v_groupleader is null) then
                        --Tai khoan margin khong tham gia group
            SELECT
                --TRUNC(GREATEST((CASE WHEN MRIRATE>0 THEN greatest(least(NAVACCOUNT*100/MRIRATE + OUTSTANDING,AVLLIMIT-advanceline),0) ELSE NAVACCOUNT + OUTSTANDING END),0),0) AVLWITHDRAW
                TRUNC(GREATEST((CASE WHEN MRIRATE>0 THEN least(NAVACCOUNT*100/MRIRATE + (OUTSTANDING-ADVANCELINE),AVLLIMIT-ADVANCELINE) ELSE NAVACCOUNT + OUTSTANDING END),0),0) AVLWITHDRAW
                INTO V_AVLRelease
            FROM (
            SELECT AF.advanceline,
                   af.mrirate,
                   --af.advanceline + nvl(af.mrcrlimitmax,0) + mst.balance- mst.odamt - nvl (al.overamt, 0)-nvl(al.secureamt,0) - mst.ramt avllimit,
                   nvl(adv.avladvance,0) +
                   nvl(af.advanceline,0) + nvl(AF.mrcrlimitmax,0)+nvl(af.MRCRLIMIT,0)- dfodamt + balance- odamt - nvl(secureamt,0) - ramt avllimit,
                   --nvl(af.MRCRLIMIT,0) +  nvl(se.SEASS,0) + nvl(se.trfass,0)  NAVACCOUNT,
                  /* nvl(af.MRCRLIMIT,0) +*/  nvl(se.SEASS,0) NAVACCOUNT,
                   nvl(af.advanceline,0) + mst.balance+least(nvl(af.MRCRLIMIT,0),nvl(al.secureamt,0))+ nvl(adv.avladvance,0)- mst.odamt- NVL (al.advamt, 0)-nvl(al.secureamt,0) - mst.ramt OUTSTANDING
              FROM cimast mst inner join afmast af on af.acctno = mst.afacctno AND mst.acctno = V_ACCTNO
                   inner join sbcurrency ccy on ccy.ccycd = mst.ccycd
                   left join
                   (select * from v_getbuyorderinfo where afacctno = V_ACCTNO) al
                    on mst.acctno = al.afacctno
                    LEFT JOIN
                   (select * from v_getsecmargininfo where afacctno = V_ACCTNO) SE
                   on se.afacctno=MST.acctno
                   left join
                   (select sum(depoamt) avladvance,afacctno
                        from v_getAccountAvlAdvance where afacctno = V_ACCTNO group by afacctno) adv
                    on adv.afacctno=mst.acctno
                   ) ;
        else
            --Tai khoan margin join theo group
            if v_type='U' then
                SELECT
                --TRUNC(GREATEST((CASE WHEN MRIRATE>0 THEN greatest(least(NAVACCOUNT*100/MRIRATE + OUTSTANDING,AVLLIMIT-advanceline),0) ELSE NAVACCOUNT + OUTSTANDING END),0),0) AVLWITHDRAW
                TRUNC(GREATEST((CASE WHEN MRIRATE>0 THEN least(NAVACCOUNT*100/MRIRATE + (OUTSTANDING-ADVANCELINE),AVLLIMIT-ADVANCELINE) ELSE NAVACCOUNT + OUTSTANDING END),0),0) AVLWITHDRAW

                INTO V_AVLRelease
            FROM (
            SELECT AF.advanceline,
                   af.mrirate,
                   --af.advanceline + nvl(af.mrcrlimitmax,0) + mst.balance- mst.odamt - nvl (al.overamt, 0)-nvl(al.secureamt,0) - mst.ramt avllimit,
                   nvl(adv.avladvance,0) +
                   nvl(af.advanceline,0) + nvl(AF.mrcrlimitmax,0)- dfodamt + balance- odamt - nvl(secureamt,0) - ramt avllimit,
                   -- nvl(af.MRCRLIMIT,0) +  nvl(se.SEASS,0) + nvl(se.trfass,0)  NAVACCOUNT,
                   /*nvl(af.MRCRLIMIT,0) + */ nvl(se.SEASS,0) NAVACCOUNT,
                   nvl(af.advanceline,0) + mst.balance+least(nvl(af.mrcrlimit,0),nvl(al.secureamt,0)) +nvl(adv.avladvance,0)- mst.odamt -  NVL (al.advamt, 0)-nvl(al.secureamt,0) - mst.ramt OUTSTANDING
              FROM cimast mst inner join afmast af on af.acctno = mst.afacctno AND mst.acctno = V_ACCTNO
                   inner join sbcurrency ccy on ccy.ccycd = mst.ccycd
                   left join
                   (select * from v_getbuyorderinfo where afacctno = V_ACCTNO) al
                    on mst.acctno = al.afacctno
                    LEFT JOIN
                   (select * from v_getsecmargininfo where afacctno = V_ACCTNO) SE
                   on se.afacctno=MST.acctno
                   left join
                   (select sum(depoamt) avladvance,afacctno
                        from v_getAccountAvlAdvance where afacctno = V_ACCTNO group by afacctno) adv
                    on adv.afacctno=mst.acctno
                   ) ;
            else
                select TRUNC(GREATEST((CASE WHEN mst.mstmrirate>0 THEN greatest(least(NAVACCOUNT*100/mst.mstmrirate + (OUTSTANDING),AVLLIMIT),0) ELSE NAVACCOUNT + OUTSTANDING END),0),0) AVLWITHDRAW INTO V_AVLRelease
                from
                (SELECT V_ACCTNO afacctno,
                                   --sum(nvl(af.mrcrlimitmax,0) + mst.balance- mst.odamt - nvl (al.overamt, 0)-nvl(al.secureamt,0) - mst.ramt) avllimit,
                                   greatest(sum(nvl(adv.avladvance,0) + nvl(AF.mrcrlimitmax,0)+nvl(af.mrcrlimit,0)- dfodamt + balance- odamt -  nvl(secureamt,0) - ramt),0) avllimit,
                                   -- sum(nvl(af.MRCRLIMIT,0) +  nvl(se.SEASS,0)  + nvl(se.trfass,0))  NAVACCOUNT,
                                   sum(/*nvl(af.MRCRLIMIT,0) +*/  nvl(se.SEASS,0))  NAVACCOUNT,
                                   sum(mst.balance+least(nvl(af.mrcrlimit,0),nvl(al.secureamt,0))+ nvl(adv.avladvance,0)- mst.odamt -  NVL (al.advamt, 0)-nvl(al.secureamt,0) - mst.ramt) OUTSTANDING,
                                                   sum(case when af.acctno <> v_groupleader then 0 else af.mrirate end) mstmrirate
                               FROM cimast mst inner join afmast af on af.acctno = mst.afacctno AND af.groupleader=v_groupleader
                                   left join
                                   (select b.* from v_getbuyorderinfo  b, afmast af where b.afacctno =af.acctno and af.groupleader=v_groupleader) al
                                    on mst.acctno = al.afacctno
                                   LEFT JOIN
                                   (select b.* from v_getsecmargininfo b, afmast af where b.afacctno =af.acctno and af.groupleader=v_groupleader) se
                                   on se.afacctno=MST.acctno
                                   left join
                                    (select sum(depoamt) avladvance,afacctno
                                        from v_getAccountAvlAdvance b , afmast af where b.afacctno =af.acctno and af.groupleader=v_groupleader group by afacctno) adv
                                    on adv.afacctno=mst.acctno
                ) MST, afmast af, cfmast cf,cimast ci,
                                   sbcurrency ccy
                where mst.afacctno =af.acctno and af.custid=cf.custid
                and mst.afacctno=ci.afacctno and ccy.ccycd = ci.ccycd
                ;
            end if;

        end if;
   RETURN V_AVLRelease;
   EXCEPTION
    WHEN others THEN
        return 0;
END;

 
 
 
 
 
 
 
 
 
 
 
 
 
/
