SET DEFINE OFF;
CREATE OR REPLACE FUNCTION fn_get_account_pp (
        p_afacctno IN VARCHAR2,
        p_type in varchar2)
RETURN NUMBER
  IS
/*  V_ACCTNO VARCHAR2(30);
  v_type char(1);
  v_margintype char(1);
  v_actype varchar2(4);
  v_groupleader varchar2(10);
  v_INDATE date;
  v_ppse NUMBER;
  v_advanceline NUMBER;*/
    l_PP NUMBER(20,2);
    l_cimastcheck_arr txpks_check.cimastcheck_arrtype;
BEGIN
/*
    V_ACCTNO:=F_ACCTNO;
    v_type:=f_TYPE;
    v_ppse:=0;
    select to_date(VARVALUE,'DD/MM/YYYY') into v_INDATE from sysvar where grname ='SYSTEM' and varname ='CURRDATE';
      SELECT MR.MRTYPE,af.actype,mst.groupleader,MST.advanceline  into v_margintype,v_actype,v_groupleader,v_advanceline from afmast mst,aftype af, mrtype mr where mst.actype=af.actype and af.mrtype=mr.actype and mst.acctno=V_ACCTNO;
        if v_margintype in ('N','L') then
            --Tai khoan binh thuong khong Margin
                SELECT greatest(nvl(adv.avladvance,0) + af.advanceline + balance - mst.trfbuyamt - odamt- nvl(dfdebtamt,0) - nvl(dfintdebtamt,0) - NVL (advamt, 0)-nvl(secureamt,0) - ramt,0) INTO v_ppse
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
                        on adv.afacctno=MST.acctno;
        elsif v_margintype in ('S','T') and (length(v_groupleader)=0 or v_groupleader is null) then
                        --Tai khoan margin khong tham gia group
            SELECT
                (   case when chksysctrl = 'Y' then
                        nvl(mst.balance - mst.trfbuyamt - nvl(se.secureamt,0) + nvl(se.avladvance,0) + af.advanceline + least(nvl(se.mrcrlimitmax,0),nvl(af.mrcrlimit,0) + nvl(se.semramt,0)) - nvl(mst.odamt,0) - mst.dfdebtamt - mst.dfintdebtamt,0)
                    else
                        nvl(mst.balance - mst.trfbuyamt - nvl(se.secureamt,0) + nvl(se.avladvance,0) + af.advanceline + least(nvl(se.mrcrlimitmax,0),nvl(af.mrcrlimit,0) + nvl(se.seamt,0)) - nvl(mst.odamt,0) - mst.dfdebtamt - mst.dfintdebtamt,0)
                    end) INTO v_ppse
              FROM cimast mst inner join afmast af on af.acctno = mst.afacctno AND mst.acctno = V_ACCTNO
                   left join (select * from v_getsecmarginratio where afacctno = V_ACCTNO) se on se.afacctno = mst.acctno;
        else
            --Tai khoan margin join theo group
            if v_type='U' then
                SELECT greatest(least((nvl(AF.MRCRLIMIT,0) + nvl(se.SEAMT,0)+
                                nvl(se.receivingamt,0))
                        ,nvl(adv.avladvance,0) + greatest(nvL(AF.MRCRLIMITMAX,0)-dfodamt,0)) +
                   nvl(af.advanceline,0) + balance - mst.trfbuyamt - odamt - nvl(dfdebtamt,0) - nvl(dfintdebtamt,0)-nvl(secureamt,0) - ramt,0)  INTO v_ppse
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
                        on adv.afacctno=MST.acctno;

            else
                SELECT v_advanceline + LEAST(SUM((NVL(AF.MRCRLIMIT,0) + NVL(SE.SEAMT,0)+
                                    NVL(SE.RECEIVINGAMT,0)))
                            ,sum(nvl(adv.avladvance,0) + greatest(NVL(AF.MRCRLIMITMAX,0)- dfodamt,0)))
                       + sum(BALANCE- ODAMT - nvl(dfdebtamt,0) - nvl(dfintdebtamt,0) - NVL (ADVAMT, 0)-NVL(SECUREAMT,0) - RAMT) INTO v_ppse
                               FROM cimast mst inner join afmast af on af.acctno = mst.afacctno AND af.groupleader=v_groupleader
                                   left join
                                   (select b.* from v_getbuyorderinfo  b, afmast af where b.afacctno =af.acctno and af.groupleader=v_groupleader) al
                                    on mst.acctno = al.afacctno
                                   LEFT JOIN
                                   (select b.* from v_getsecmargininfo b, afmast af where b.afacctno =af.acctno and af.groupleader=v_groupleader) se
                                   on se.afacctno=MST.acctno
                                   left join
                                    (select sum(depoamt) avladvance,afacctno
                                        from v_getAccountAvlAdvance where afacctno = V_ACCTNO group by afacctno) adv
                                    on adv.afacctno=mst.acctno;
            end if;

        end if;
   RETURN v_ppse;*/
     l_CIMASTcheck_arr := txpks_check.fn_CIMASTcheck(p_afacctno,'CIMAST','ACCTNO');
     l_PP := l_CIMASTcheck_arr(0).PP;
    RETURN l_PP;
   EXCEPTION
    WHEN others THEN
        return 0;
END;

 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
/
