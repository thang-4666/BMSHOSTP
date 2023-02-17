SET DEFINE OFF;
CREATE OR REPLACE PROCEDURE "CF0054" (
   PV_REFCURSOR           IN OUT   PKG_REPORT.REF_CURSOR,
   p_OPT                    IN       VARCHAR2,
   p_BRID                   IN       VARCHAR2,
   TLGOUPS        IN       VARCHAR2,
   TLSCOPE        IN       VARCHAR2,
   P_FR_DATE                 IN       VARCHAR2,
   P_TO_DATE                 IN       VARCHAR2,
   P_CUSTODYCD                 IN       VARCHAR2,
   P_T0LOANLIMITMAX                 IN       number,
   P_MRLOANLIMITMAX                 IN       number,
   TLID            IN       VARCHAR2
  )
IS

--
-- BAO CAO DANH MUC CHUNG KHOAN THUC HIEN GIAO DICH KI QUY
-- MODIFICATION HISTORY
-- PERSON       DATE                COMMENTS
-- ---------   ------  -------------------------------------------
-- QUOCTA      17-02-2012           CREATED
--

    l_OPT varchar2(10);
    l_BRID varchar2(1000);
    l_BRID_FILTER varchar2(1000);
    l_FromDate date;
    l_ToDate date;
    l_CUSTODYCD varchar2(10);
    V_STRTLID           VARCHAR2(6);


BEGIN

 V_STRTLID:= TLID;

    l_OPT:=p_OPT;

    IF (l_OPT = 'A') THEN
      l_BRID_FILTER := '%';
    ELSE if (l_OPT = 'B') then
            select brgrp.mapid into l_BRID_FILTER from brgrp where brgrp.brid = p_BRID;
        else
            l_BRID_FILTER := p_BRID;
        end if;
    END IF;

    if P_CUSTODYCD = 'A' or P_CUSTODYCD = 'ALL' then
        l_CUSTODYCD:= '%%';
    else
        l_CUSTODYCD:= P_CUSTODYCD;
    end if;


  -- Lay ngay dau ki.
  l_FromDate:= to_date(P_FR_DATE,SYSTEMNUMS.C_DATE_FORMAT);
  l_ToDate:= to_date(P_TO_DATE,SYSTEMNUMS.C_DATE_FORMAT);



OPEN PV_REFCURSOR FOR
select to_char(case when t0.txdate is not null then t0.txdate
        when mr.txdate is not null then mr.txdate
        else null end,'DD/MM/RRRR') txdate,
       cf.custodycd, cf.fullname  ,
       nvl(t0.oldt0loanlimit,nvl(t0af.oldt0loanlimit,cf.t0loanlimit)) oldt0loanlimit,
       nvl(t0.newt0loanlimit,nvl(t0af.oldt0loanlimit,cf.t0loanlimit)) newt0loanlimit,
       nvl(mr.oldmrloanlimit,nvl(mraf.oldmrloanlimit,cf.mrloanlimit)) oldmrloanlimit,
       nvl(mr.newmrloanlimit,nvl(mraf.oldmrloanlimit,cf.mrloanlimit)) newmrloanlimit

from (SELECT * FROM CFMAST WHERE FNC_VALIDATE_SCOPE(BRID, CAREBY, TLSCOPE, p_BRID, TLGOUPS)=0) cf,
    (select tg.autoid, tf.*
    from tllogall tg,
        (select txnum, txdate, max(decode(fldcd,'88',cvalue,null)) custodycd,
            max(decode(fldcd,'14',nvalue,null)) oldt0loanlimit,
            max(decode(fldcd,'15',nvalue,null)) newt0loanlimit
        from tllogfldall
        group by txnum, txdate) tf
    where tg.txnum = tf.txnum
    and tg.txdate = tf.txdate
    and tg.tltxcd = '1809'
    and tg.txdate between l_FromDate and l_ToDate
    ) t0,
    (select t0af.*
    from
        (
        select tg.autoid, tf.*
        from tllogall tg,
            (select txnum, txdate, max(decode(fldcd,'88',cvalue,null)) custodycd,
                max(decode(fldcd,'14',nvalue,null)) oldt0loanlimit,
                max(decode(fldcd,'15',nvalue,null)) newt0loanlimit
            from tllogfldall
            group by txnum, txdate) tf
        where tg.txnum = tf.txnum
        and tg.txdate = tf.txdate
        and tg.tltxcd = '1809'
        and tg.txdate > l_ToDate
        ) t0af,
        (
        select tf.custodycd, min(autoid) minautoid
        from tllogall tg,
            (select txnum, txdate, max(decode(fldcd,'88',cvalue,null)) custodycd,
                max(decode(fldcd,'14',nvalue,null)) oldt0loanlimit,
                max(decode(fldcd,'15',nvalue,null)) newt0loanlimit
            from tllogfldall
            group by txnum, txdate) tf
        where tg.txnum = tf.txnum
        and tg.txdate = tf.txdate
        and tg.tltxcd = '1809'
        and tg.txdate > l_ToDate
        group by tf.custodycd
        ) t0afmin
    where t0af.custodycd = t0afmin.custodycd and t0af.autoid = t0afmin.minautoid
    ) t0af,
    (select tg.autoid, tf.*
    from tllogall tg,
        (select txnum, txdate, max(decode(fldcd,'88',cvalue,null)) custodycd,
            max(decode(fldcd,'14',nvalue,null)) oldmrloanlimit,
            max(decode(fldcd,'15',nvalue,null)) newmrloanlimit
        from tllogfldall
        group by txnum, txdate) tf
    where tg.txnum = tf.txnum
    and tg.txdate = tf.txdate
    and tg.tltxcd = '1802'
    and tg.txdate between l_FromDate and l_ToDate) mr,
    (select mraf.*
    from
        (
        select tg.autoid, tf.*
        from tllogall tg,
            (select txnum, txdate, max(decode(fldcd,'88',cvalue,null)) custodycd,
                max(decode(fldcd,'14',nvalue,null)) oldmrloanlimit,
                max(decode(fldcd,'15',nvalue,null)) newmrloanlimit
            from tllogfldall
            group by txnum, txdate) tf
        where tg.txnum = tf.txnum
        and tg.txdate = tf.txdate
        and tg.tltxcd = '1802'
        and tg.txdate > l_ToDate
        ) mraf,
        (
        select tf.custodycd, min(autoid) minautoid
        from tllogall tg,
            (select txnum, txdate, max(decode(fldcd,'88',cvalue,null)) custodycd,
                max(decode(fldcd,'14',nvalue,null)) oldmrloanlimit,
                max(decode(fldcd,'15',nvalue,null)) newmrloanlimit
            from tllogfldall
            group by txnum, txdate) tf
        where tg.txnum = tf.txnum
        and tg.txdate = tf.txdate
        and tg.tltxcd = '1802'
        and tg.txdate > l_ToDate
        group by tf.custodycd
        ) mrafmin
    where mraf.custodycd = mrafmin.custodycd and mraf.autoid = mrafmin.minautoid
    ) mraf
where cf.custodycd = t0.custodycd(+)
and cf.custodycd = mr.custodycd(+)
and cf.custodycd = t0af.custodycd(+)
and cf.custodycd = mraf.custodycd(+)
and cf.custodycd like l_CUSTODYCD
and case when l_OPT = 'A' then 1 else instr(l_BRID_FILTER,substr(cf.custid,1,4)) end  <> 0
and nvl(t0.oldt0loanlimit,nvl(t0af.oldt0loanlimit,cf.t0loanlimit)) +
       nvl(t0.newt0loanlimit,nvl(t0af.oldt0loanlimit,cf.t0loanlimit)) +
       nvl(mr.oldmrloanlimit,nvl(mraf.oldmrloanlimit,cf.mrloanlimit)) +
       nvl(mr.newmrloanlimit,nvl(mraf.oldmrloanlimit,cf.mrloanlimit))  <> 0
and nvl(t0.newt0loanlimit,nvl(t0af.oldt0loanlimit,cf.t0loanlimit)) >= P_T0LOANLIMITMAX
and nvl(mr.newmrloanlimit,nvl(mraf.oldmrloanlimit,cf.mrloanlimit)) >= P_MRLOANLIMITMAX
 and exists (select gu.grpid from tlgrpusers gu where cf.careby = gu.grpid and gu.tlid = V_STRTLID )
order by cf.custodycd, t0.autoid, mr.autoid;



EXCEPTION
  WHEN OTHERS
   THEN
      RETURN;
END;

 
 
 
 
/
