SET DEFINE OFF;
CREATE OR REPLACE FUNCTION checkgtcbuyordernew(
        f_acctno IN  varchar,
        f_quantity in number,
        f_price in number,
        f_actype in number,
        f_codeid in varchar
        )
    return number
IS
    p_err_code varchar2(100);
    v_Result number(30,5);
    l_mrratiorate number(20,4);
    l_marginprice number(20,4);
    l_marginrefprice number(20,4);
    l_mrpriceloan number(20,4);
    l_chksysctrl varchar2(1);
    l_ismarginallow varchar2(1);

    l_margintype            CHAR (1);
    l_actype                VARCHAR2 (4);
    l_istrfbuy char(1);
    l_remainamt number;
    l_PPMax number(20,0);
    l_seclimit number;

    l_deffeerate number(10,6);

    l_PP number(20,4);
    l_PPse number(20,4);
    l_AVLLIMIT number(20,4);
    V_ADVAMT        NUMBER;
    l_cimastcheck_arr txpks_check.cimastcheck_arrtype;
BEGIN
    v_Result:=0;

    --Check Room
    if txpks_prchk.fn_RoomLimitCheck(f_acctno, f_codeid, f_quantity, p_err_code) <> 0 then
        v_Result:=-1; --Loi
        return v_Result;
    end if;

    select nvl(rsk.mrratioloan,0),nvl(rsk.mrpriceloan,0), nvl(lnt.chksysctrl,'N'), nvl(rsk.ismarginallow,'N')
            into l_mrratiorate,l_mrpriceloan, l_chksysctrl, l_ismarginallow
        from afmast af, aftype aft, lntype lnt,
            (select * from afserisk where codeid = f_codeid) rsk,
            (select * from v_getbuyorderinfo where afacctno = f_acctno) b
        where af.actype = aft.actype
        and aft.lntype = lnt.actype(+)
        and af.actype = rsk.actype(+)
        and af.acctno = b.afacctno(+)
        and af.acctno = f_acctno;

    SELECT mr.mrtype, af.actype, af.istrfbuy
            INTO l_margintype, l_actype,  l_istrfbuy
        FROM afmast mst, aftype af, mrtype mr
        WHERE mst.actype = af.actype
            AND af.mrtype = mr.actype
            AND mst.acctno = f_acctno;


     l_CIMASTcheck_arr := txpks_check.fn_CIMASTcheck(f_acctno,'CIMAST','ACCTNO');
     l_PP := l_CIMASTcheck_arr(0).PP;
     l_AVLLIMIT := l_CIMASTcheck_arr(0).AVLLIMIT;
     V_ADVAMT:=l_CIMASTcheck_arr(0).AVLADVANCE;
     select marginrefprice, marginprice into l_marginrefprice, l_marginprice from securities_info where codeid = f_codeid;

     --Begin Lay thong tin Ham muc chung khoan con lai
     begin
        select nvl(selm.afmaxamt, case when l_istrfbuy ='N' then rsk.afmaxamt else rsk.afmaxamtt3 end) into l_seclimit
        from securities_risk rsk,
            (select * from afselimit where afacctno = f_acctno) selm
        where rsk.codeid = selm.codeid(+)
        and rsk.codeid = f_codeid;
     exception when others then
        l_seclimit:=0;
     end;
     if l_seclimit>0 then
         begin
             select l_seclimit - nvl(aclm.seqtty,0)*  l_mrratiorate/100 * least(l_marginrefprice, l_mrpriceloan) into l_remainamt
             from v_getaccountseclimit aclm where afacctno = f_acctno and codeid = f_codeid;
         exception when others then
             l_remainamt:=l_seclimit;
         end;
     end if;
     l_remainamt:= greatest(l_remainamt,0);
     l_PPMax:= floor(l_PP + least(l_remainamt,f_quantity * l_mrratiorate/100 * least(l_marginrefprice, l_mrpriceloan)));

     select deffeerate/100 into l_deffeerate from odtype where actype = f_actype;
     if l_margintype not in ('S','T') then
         IF NOT (ceil(to_number(l_PP)) >= to_number(f_quantity * f_price * 1000 * (1+l_deffeerate))) THEN
            v_Result:=-1; --Loi
            return v_Result;
         END IF;
     else

         if (l_chksysctrl = 'Y' and l_ismarginallow = 'N') then
             l_PPse:=l_PP;
             IF NOT ceil(l_PPse) >= to_number(f_quantity * f_price * 1000 * (1+l_deffeerate)) THEN
                 v_Result:=-1; --Loi
                 return v_Result;
             END IF;
         else
             if l_chksysctrl = 'Y' then
                 if l_PP > 0 then
                     l_PPse:= l_PP / ((1+l_deffeerate)- l_mrratiorate/100 * least(l_marginrefprice, l_mrpriceloan) /(f_price * 1000));
                 else
                     l_PPse:=l_PP;
                 end if;
             else
                 if l_PP > 0 then
                     l_PPse:= l_PP / ((1+l_deffeerate)- l_mrratiorate/100 * least(l_marginprice, l_mrpriceloan) /(f_price * 1000));
                 else
                     l_PPse:=l_PP;
                 end if;
             end if;
             l_PPse:= least(l_PPMax,l_PPse);
             IF NOT ceil(l_PPse) >= to_number(f_quantity * f_price * 1000 * (1+l_deffeerate)) THEN
                 v_Result:=-1; --Loi
                 return v_Result;

             end if;
         end if;
    end if;
    --Check ko du han mua thi khong day lenh
    IF NOT (to_number(l_AVLLIMIT) >= to_number(f_quantity * f_price * 1000 * (1+l_deffeerate))) THEN
        v_Result:=-1; --Loi
        return v_Result;
    END IF;
    return v_Result;
EXCEPTION
    WHEN others THEN
        return -1;
END;

 
 
 
 
/
