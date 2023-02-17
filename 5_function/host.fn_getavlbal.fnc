SET DEFINE OFF;
CREATE OR REPLACE FUNCTION fn_getavlbal (pv_afacctno varchar2, pv_lnschdid number) return number
is
    v_dblAVLBAL number;
    l_reftype varchar2(10);
    l_ISSTOPADV  varchar2(1);
begin

    select varvalue INTO l_ISSTOPADV  from sysvar where varname like 'ISSTOPADV' AND grname ='SYSTEM';

    select reftype into l_reftype from lnschd where autoid = pv_lnschdid;

    if l_reftype = 'GP' then
        select least(greatest(least(nvl(seamt,0),af.mrcrlimitmax-ci.dfodamt) - nvl(ln.odamt,0),0)
            + ci.balance +  decode (l_ISSTOPADV,'Y',0,'N', nvl(adv.avladvance,0)),
                 ci.balance +  decode (l_ISSTOPADV,'Y',0,'N', nvl(adv.avladvance,0)))
            into v_dblAVLBAL
        from afmast af, cimast ci,
            (select sum(depoamt) avladvance,afacctno
                from v_getAccountAvlAdvance where afacctno = pv_afacctno group by afacctno
            ) adv,
            (select * from v_getsecmargininfo where afacctno = pv_afacctno) sec,
            (select trfacctno, sum(prinnml+prinovd+intdue+intnmlacr+intnmlovd+intovdacr+feeintdue+feeintnmlacr+feeintnmlovd+feeintovdacr) odamt
            from lnmast
            where ftype <> 'DF' and trfacctno = pv_afacctno group by trfacctno) ln
        where af.acctno = ci.acctno
            and ci.acctno = adv.afacctno(+)
            and ci.acctno = sec.afacctno(+)
            and ci.acctno = ln.trfacctno(+)
            and ci.acctno =pv_afacctno;
    else
        select least(greatest(least(nvl(seamt,0),af.mrcrlimitmax-ci.dfodamt) - nvl(ln.odamt,0),0)
            + ci.balance +  decode (l_ISSTOPADV,'Y',0,'N',nvl(adv.avladvance,0)),
                 ci.balance +  decode (l_ISSTOPADV,'Y',0,'N',nvl(adv.avladvance,0)))
            into v_dblAVLBAL
        from afmast af, cimast ci,
            (select sum(depoamt) avladvance,afacctno
                from v_getAccountAvlAdvance where afacctno = pv_afacctno group by afacctno
            ) adv,
            (select * from v_getsecmargininfo where afacctno = pv_afacctno) sec,
            (select trfacctno,
                sum(prinnml+prinovd+intdue+intnmlacr+intnmlovd+intovdacr+feeintdue+feeintnmlacr+feeintnmlovd+feeintovdacr) odamt,
                sum(oprinnml+oprinovd+ointdue+ointnmlacr+ointnmlovd+ointovdacr) t0odamt
            from lnmast
            where ftype <> 'DF' and trfacctno = pv_afacctno group by trfacctno) ln
        where af.acctno = ci.acctno
            and ci.acctno = adv.afacctno(+)
            and ci.acctno = sec.afacctno(+)
            and ci.acctno = ln.trfacctno(+)
            and ci.acctno =pv_afacctno;
    end if;
    return v_dblAVLBAL;

exception when others then
    return 0;
end;
 
 
 
 
/
