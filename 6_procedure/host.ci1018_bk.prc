SET DEFINE OFF;
CREATE OR REPLACE PROCEDURE ci1018_bk (
   PV_REFCURSOR     IN OUT   PKG_REPORT.REF_CURSOR,
   OPT              IN       VARCHAR2,
   BRID             IN       VARCHAR2,
   TYPEDATE         IN       VARCHAR2,
   F_DATE           IN       VARCHAR2,
   T_DATE           IN       VARCHAR2,
   TLTXCD           IN       VARCHAR2,
   MAKER            IN       VARCHAR2,
   CHECKER          IN       VARCHAR2,
   corebank         IN       VARCHAR2,
   PV_CUSTODYCD     IN       VARCHAR2,
   PV_AFACCTNO      IN       VARCHAR2,
   TYPEBRID         IN       VARCHAR2,
   TLID            IN       VARCHAR2,
   pv_ALTERNATEACCT         IN       VARCHAR2
        )
   IS
--
-- To modify this template, edit file PROC.TXT in TEMPLATE
-- directory of SQL Navigator
-- BAO CAO DANH SACH GIAO DICH LUU KY
-- Purpose: Briefly explain the functionality of the procedure
-- DANH SACH GIAO DICH LUU KY
-- MODIFICATION HISTORY
-- Person      Date    Comments
-- NAMNT   11-APR-2012  MODIFIED
-- ---------   ------  -------------------------------------------

    V_STROPTION     VARCHAR2 (5);            -- A: ALL; B: BRANCH; S: SUB-BRANCH

    V_STRTLTXCD         VARCHAR (900);
    V_STRSYMBOL         VARCHAR (20);
    V_STRTYPEDATE       VARCHAR(5);
    V_STRCHECKER        VARCHAR(20);
    V_STRMAKER          VARCHAR(20);
    V_STRCOREBANK          VARCHAR(20);
    V_STROPT       VARCHAR2 (5);            -- A: ALL; B: BRANCH; S: SUB-BRANCH
    V_STRBRID      VARCHAR2 (100);                   -- USED WHEN V_NUMOPTION > 0
    V_INBRID       VARCHAR2 (5);
    v_strIBRID     VARCHAR2 (4);
    vn_BRID        varchar2(50);
    V_STRPV_CUSTODYCD   varchar2(50);
    V_STRPV_AFACCTNO   varchar2(50);
    V_STRTLID           VARCHAR2(6);
    v_STRALTERNATEACCT varchar2(5);
   -- Declare program variables as shown above
BEGIN
    -- GET REPORT'S PARAMETERS
   V_STRTLID:= TLID;

 V_STROPT := upper(OPT);
    V_INBRID := BRID;
    if(V_STROPT = 'A') then
        V_STRBRID := '%';
    else
        if(V_STROPT = 'B') then
            --select br.mapid into V_STRBRID from brgrp br where  br.brid = V_INBRID;
            V_STRBRID := substr(BRID,1,2) || '__' ;
        else
            V_STRBRID := BRID;
        end if;
    end if;

  V_STRTYPEDATE := TYPEDATE;

   IF(TLTXCD <> 'ALL')
   THEN
        V_STRTLTXCD := TLTXCD||'%';
      ELSE
        V_STRTLTXCD := '%%';
   END IF;

   IF(CHECKER <> 'ALL')
   THEN
        V_STRCHECKER := CHECKER;
   ELSE
        V_STRCHECKER := '%%';
   END IF;

   IF(MAKER <> 'ALL')
   THEN
        V_STRMAKER  := MAKER;
   ELSE
        V_STRMAKER  := '%%';
   END IF;

   IF(COREBANK <> 'ALL')
   THEN
        V_STRCOREBANK  := COREBANK;
   ELSE
        V_STRCOREBANK  := '%%';
   END IF;

    IF(PV_CUSTODYCD <> 'ALL')
   THEN
        V_STRPV_CUSTODYCD  := PV_CUSTODYCD;
   ELSE
        V_STRPV_CUSTODYCD  := '%%';
   END IF;

    IF(PV_AFACCTNO <> 'ALL')
   THEN
        V_STRPV_AFACCTNO  := PV_AFACCTNO;
   ELSE
        V_STRPV_AFACCTNO := '%%';
   END IF;

   IF (pv_ALTERNATEACCT = 'ALL')
    THEN
         v_STRALTERNATEACCT := '%';
    ELSE
         v_STRALTERNATEACCT := substr(pv_ALTERNATEACCT,1,1);
    END IF;

IF   TYPEBRID ='002' THEN
    if V_STRTYPEDATE='002' then

        OPEN PV_REFCURSOR
          FOR

          select * from (
        select af.careby, tl.tltxcd,tltx.txdesc ,tl.txnum,tl.busdate ,tl.txdate,cf.custodycd,af.acctno, cfc.custodycd custodycdc,afc.acctno acctnoc,tl.msgamt amt,nvl(mk.tlname,'') mk,nvl(ck.tlname,'')  ck,nvl(AF.brid,'') brid,nvl(tl.tlid,'') tlid,nvl(tl.OFFID,'') OFFID,
        ''bankid,af.corebank,decode(af.bankname,'---',cspks_system.fn_get_sysvar('SYSTEM','COMPANYSHORTNAME'),af.bankname) bankname,ci.trdesc
        from vw_tllog_all TL ,vw_citran_gen ci,afmast af,cfmast cf, afmast afc,cfmast cfc ,tltx  , tlprofiles mk,tlprofiles ck
        where tl.txnum =ci.txnum and tl.txdate =ci.txdate and ci.acctno= af.acctno and cf.custid =af.custid
        and ci.ref =afc.acctno and afc.custid =cfc.custid
        and af.ALTERNATEACCT like v_strALTERNATEACCT
        and tltx.tltxcd = tl.tltxcd
        and  tl.tlid = mk.tlid(+)
        and  tl.OFFID =ck.tlid(+)
        and tl.tltxcd in ('1120','1130','1134') and ci.field ='BALANCE'
        --and decode (V_STRTYPEDATE,'002',TL.busdate,TL.txdate)>=to_date(F_DATE,'DD/MM/YYYY')
        --AND decode (V_STRTYPEDATE,'002',TL.busdate,TL.txdate)<=to_date(T_DATE,'DD/MM/YYYY')
        and TL.busdate  >=to_date(F_DATE,'DD/MM/YYYY')
        and TL.busdate  <=to_date(T_DATE,'DD/MM/YYYY')
        AND TL.TLTXCD LIKE V_STRTLTXCD
        and  nvl(AF.brid,V_STRBRID) like V_STRBRID
        AND NVL( TL.TLID,'-') LIKE V_STRMAKER
        AND NVL( TL.OFFID,'-') LIKE V_STRCHECKER
        AND AF.COREBANK LIKE V_STRCOREBANK
        AND CF.custodycd LIKE V_STRPV_CUSTODYCD
        AND AF.acctno LIKE V_STRPV_AFACCTNO
        --and exists (select gu.grpid from tlgrpusers gu where af.careby = gu.grpid and gu.tlid = V_STRTLID )
        union
        SELECT af.careby, case when  tl.tltxcd in ('3350','3354') then '3342' else  tl.tltxcd end  tltxcd ,tltx.txdesc ,tl.txnum,tl.busdate ,tl.txdate,cf.custodycd,af.acctno, '' custodycdc,'' acctnoc,tl.msgamt amt,nvl(mk.tlname,'') mk,nvl(ck.tlname,'')  ck,nvl(AF.brid,'') brid,nvl(tl.tlid,'') tlid,nvl(tl.OFFID,'') OFFID,
        ''bankid,af.corebank,decode(af.bankname,'---',cspks_system.fn_get_sysvar('SYSTEM','COMPANYSHORTNAME'),af.bankname) bankname , tl.txdesc trdesc
        FROM vw_tllog_all TL,afmast af,cfmast cf ,tltx, tlprofiles mk,tlprofiles ck
        where substr(tl.msgacct,0,10)=af.acctno and af.custid = cf.custid
        and tltx.tltxcd = tl.tltxcd
        and af.ALTERNATEACCT like v_strALTERNATEACCT
        and  tl.tlid = mk.tlid(+)
        and  tl.OFFID =ck.tlid(+)
        and tl.tltxcd in ('1140','1100','1107','1101'
        ,'1104','1108','1111','1114','1104','1112','1145','1144'
        ,'1123','1124','1126','1127','1162','1180','1182','6613','1105','1198','1199','8866'
        ,'8856','0066','8889','8894','8851','5541','3386') --Chaunh bo 3384
        --and decode (V_STRTYPEDATE,'002',TL.busdate,TL.txdate)>=to_date(F_DATE,'DD/MM/YYYY')
        --AND decode (V_STRTYPEDATE,'002',TL.busdate,TL.txdate)<=to_date(T_DATE,'DD/MM/YYYY')
        and TL.busdate  >=to_date(F_DATE,'DD/MM/YYYY')
        and TL.busdate  <=to_date(T_DATE,'DD/MM/YYYY')
        AND  case when  tl.tltxcd in ('3350','3354') then '3342' else  tl.tltxcd end  LIKE V_STRTLTXCD
        and  nvl(AF.brid,V_STRBRID) like V_STRBRID
        AND NVL( TL.TLID,'-') LIKE V_STRMAKER
        AND NVL( TL.OFFID,'-') LIKE V_STRCHECKER
        AND AF.COREBANK LIKE V_STRCOREBANK
        AND CF.custodycd LIKE V_STRPV_CUSTODYCD
        AND AF.acctno LIKE V_STRPV_AFACCTNO
        --and exists (select gu.grpid from tlgrpusers gu where af.careby = gu.grpid and gu.tlid = V_STRTLID )
        union
        SELECT  af.careby,  tl.tltxcd||'T'|| '0'  tltxcd ,tltx.txdesc ,tl.txnum,tl.busdate ,tl.txdate,cf.custodycd,af.acctno, '' custodycdc,'' acctnoc,tl.msgamt amt,nvl(mk.tlname,'') mk,nvl(ck.tlname,'')  ck,nvl(AF.brid,'') brid,nvl(tl.tlid,'') tlid,nvl(tl.OFFID,'') OFFID,
        ''bankid,af.corebank,decode(af.bankname,'---',cspks_system.fn_get_sysvar('SYSTEM','COMPANYSHORTNAME'),af.bankname) bankname,ci.trdesc
        FROM vw_tllog_all TL,afmast af,cfmast cf ,tltx, tlprofiles mk,tlprofiles ck,vw_citran_gen CI, vw_stschd_all sts
        where tl.msgacct=af.acctno and af.custid = cf.custid
        and tltx.tltxcd = tl.tltxcd
        and af.ALTERNATEACCT like v_strALTERNATEACCT
        and  tl.tlid = mk.tlid(+)
        and  tl.OFFID =ck.tlid(+)
        AND TL.TXDATE = CI.TXDATE
        AND TL.TXNUM = CI.TXNUM
        AND CI.field ='BALANCE'
        and tl.tltxcd ='8855'
        and ci.ref = sts.orgorderid
        and sts.duetype ='SM'
        --and decode (V_STRTYPEDATE,'002',TL.busdate,TL.txdate)>=to_date(F_DATE,'DD/MM/YYYY')
        --AND decode (V_STRTYPEDATE,'002',TL.busdate,TL.txdate)<=to_date(T_DATE,'DD/MM/YYYY')
        and TL.busdate  >=to_date(F_DATE,'DD/MM/YYYY')
        and TL.busdate  <=to_date(T_DATE,'DD/MM/YYYY')
        AND  tl.tltxcd||'T'|| '0'  LIKE V_STRTLTXCD
        and  nvl(AF.brid,V_STRBRID) like V_STRBRID
        AND NVL( TL.TLID,'-') LIKE V_STRMAKER
        AND NVL( TL.OFFID,'-') LIKE V_STRCHECKER
        AND AF.COREBANK LIKE V_STRCOREBANK
        AND CF.custodycd LIKE V_STRPV_CUSTODYCD
        AND AF.acctno LIKE V_STRPV_AFACCTNO
        --and exists (select gu.grpid from tlgrpusers gu where af.careby = gu.grpid and gu.tlid = V_STRTLID )
        union
        SELECT af.careby, case when  tl.tltxcd in ('3350','3354') then '3342' else  tl.tltxcd end  tltxcd ,tltx.txdesc ,tl.txnum,tl.busdate ,tl.txdate,cf.custodycd,af.acctno, '' custodycdc,'' acctnoc,ci.namt amt,nvl(mk.tlname,'') mk,nvl(ck.tlname,'')  ck,nvl(AF.brid,'') brid,nvl(tl.tlid,'') tlid,nvl(tl.OFFID,'') OFFID,
        ''bankid,af.corebank,decode(af.bankname,'---',cspks_system.fn_get_sysvar('SYSTEM','COMPANYSHORTNAME'),af.bankname) bankname,ci.trdesc
        FROM vw_tllog_all TL,afmast af,cfmast cf ,tltx, tlprofiles mk,tlprofiles ck,vw_citran_gen CI
        where tl.msgacct=af.acctno and af.custid = cf.custid
        and tltx.tltxcd = tl.tltxcd
        and af.ALTERNATEACCT like v_strALTERNATEACCT
        and  tl.tlid = mk.tlid(+)
        and  tl.OFFID =ck.tlid(+)
        AND TL.TXDATE = CI.TXDATE
        AND TL.TXNUM = CI.TXNUM
        AND CI.TXCD ='0012'
        and tl.tltxcd IN('3350','3354')
        --and decode (V_STRTYPEDATE,'002',TL.busdate,TL.txdate)>=to_date(F_DATE,'DD/MM/YYYY')
        --AND decode (V_STRTYPEDATE,'002',TL.busdate,TL.txdate)<=to_date(T_DATE,'DD/MM/YYYY')
        and TL.busdate  >=to_date(F_DATE,'DD/MM/YYYY')
        and TL.busdate  <=to_date(T_DATE,'DD/MM/YYYY')
        AND case when  tl.tltxcd in ('3350','3354') then '3342' else  tl.tltxcd end  LIKE V_STRTLTXCD
        and  nvl(AF.brid,V_STRBRID) like V_STRBRID
        AND NVL( TL.TLID,'-') LIKE V_STRMAKER
        AND NVL( TL.OFFID,'-') LIKE V_STRCHECKER
        AND AF.COREBANK LIKE V_STRCOREBANK
        AND CF.custodycd LIKE V_STRPV_CUSTODYCD
        AND AF.acctno LIKE V_STRPV_AFACCTNO
        --and exists (select gu.grpid from tlgrpusers gu where af.careby = gu.grpid and gu.tlid = V_STRTLID )
        UNION
        SELECT  af.careby, tl.tltxcd ,tltx.txdesc ,tl.txnum,tl.busdate ,tl.txdate,cf.custodycd,af.acctno, '' custodycdc,'' acctnoc,CI.NAMT amt,nvl(mk.tlname,'') mk,nvl(ck.tlname,'')  ck,nvl(AF.brid,'') brid,nvl(tl.tlid,'') tlid,nvl(tl.OFFID,'') OFFID,
        ''bankid,af.corebank,decode(af.bankname,'---',cspks_system.fn_get_sysvar('SYSTEM','COMPANYSHORTNAME'),af.bankname) bankname,ci.trdesc
        FROM vw_tllog_all TL,afmast af,cfmast cf ,tltx, tlprofiles mk,tlprofiles ck,vw_citran_gen CI
        where tl.msgacct=af.acctno and af.custid = cf.custid
        and tltx.tltxcd = tl.tltxcd
        and af.ALTERNATEACCT like v_strALTERNATEACCT
        and  tl.tlid = mk.tlid(+)
        and  tl.OFFID =ck.tlid(+)
        AND TL.TXDATE = CI.TXDATE
        AND TL.TXNUM = CI.TXNUM
        AND CI.field ='BALANCE'
        and tl.tltxcd in('1153','8865','1139')
        --and decode (V_STRTYPEDATE,'002',TL.busdate,TL.txdate)>=to_date(F_DATE,'DD/MM/YYYY')
        --AND decode (V_STRTYPEDATE,'002',TL.busdate,TL.txdate)<=to_date(T_DATE,'DD/MM/YYYY')
        and TL.busdate  >=to_date(F_DATE,'DD/MM/YYYY')
        and TL.busdate  <=to_date(T_DATE,'DD/MM/YYYY')
        AND TL.TLTXCD LIKE V_STRTLTXCD
        and  nvl(AF.brid,V_STRBRID) like V_STRBRID
        AND NVL( TL.TLID,'-') LIKE V_STRMAKER
        AND NVL( TL.OFFID,'-') LIKE V_STRCHECKER
        AND AF.COREBANK LIKE V_STRCOREBANK
        AND CF.custodycd LIKE V_STRPV_CUSTODYCD
        AND AF.acctno LIKE V_STRPV_AFACCTNO
        --and exists (select gu.grpid from tlgrpusers gu where af.careby = gu.grpid and gu.tlid = V_STRTLID )
        --1178
        union
        SELECT af.careby, tl.tltxcd,tltx.txdesc ,tl.txnum,tl.busdate ,tl.txdate,cf.custodycd,af.acctno, '' custodycdc,'' acctnoc,ads.amt amt,nvl(mk.tlname,'') mk,nvl(ck.tlname,'')  ck,nvl(AF.brid,'') brid,nvl(tl.tlid,'') tlid,nvl(tl.OFFID,'') OFFID,
        '' bankid,af.corebank,decode(af.bankname,'---',cspks_system.fn_get_sysvar('SYSTEM','COMPANYSHORTNAME'),af.bankname) bankname, tl.txdesc trdesc
        FROM vw_tllog_all TL,adschd ads ,afmast af,cfmast cf,tltx, tlprofiles mk,tlprofiles ck
        where tl.msgamt =ads.autoid
        and TL.msgacct = af.acctno and af.custid = cf.custid
        and tltx.tltxcd = tl.tltxcd
        and af.ALTERNATEACCT like v_strALTERNATEACCT
        and  tl.tlid = mk.tlid(+)
        and  tl.OFFID =ck.tlid(+)
        and tl.tltxcd in ('1178')
        --and decode (V_STRTYPEDATE,'002',TL.busdate,TL.txdate)>=to_date(F_DATE,'DD/MM/YYYY')
        --AND decode (V_STRTYPEDATE,'002',TL.busdate,TL.txdate)<=to_date(T_DATE,'DD/MM/YYYY')
        and TL.busdate  >=to_date(F_DATE,'DD/MM/YYYY')
        and TL.busdate  <=to_date(T_DATE,'DD/MM/YYYY')
        AND TL.TLTXCD LIKE V_STRTLTXCD
        and  nvl(AF.brid,V_STRBRID) like V_STRBRID
        AND NVL( TL.TLID,'-') LIKE V_STRMAKER
        AND NVL( TL.OFFID,'-') LIKE V_STRCHECKER
        AND AF.COREBANK LIKE V_STRCOREBANK
        AND CF.custodycd LIKE V_STRPV_CUSTODYCD
        AND AF.acctno LIKE V_STRPV_AFACCTNO
        --and exists (select gu.grpid from tlgrpusers gu where af.careby = gu.grpid and gu.tlid = V_STRTLID )
        --nhom bank
        --'1131','1132','1136','1141'
        union

        SELECT   af.careby, tl.tltxcd ,tltx.txdesc ,tl.txnum,tl.busdate ,tl.txdate,cf.custodycd,af.acctno, '' custodycdc,'' acctnoc,tl.msgamt amt,nvl(mk.tlname,'') mk,nvl(ck.tlname,'')  ck,nvl(AF.brid,'') brid,nvl(tl.tlid,'') tlid,nvl(tl.OFFID,'') OFFID
        ,nvl(bank.fullname,' ') bankid,af.corebank,decode(af.bankname,'---',cspks_system.fn_get_sysvar('SYSTEM','COMPANYSHORTNAME'),af.bankname) bankname, tl.txdesc trdesc
        FROM vw_tllog_all TL,afmast af,cfmast cf ,tltx, tlprofiles mk,tlprofiles ck,vw_tllogfld_all tlfld,banknostro bank
        where tl.msgacct=af.acctno and af.custid = cf.custid
        and tltx.tltxcd = tl.tltxcd
        and  tl.tlid = mk.tlid(+)
        and af.ALTERNATEACCT like v_strALTERNATEACCT
        and  tl.OFFID =ck.tlid(+)
        and tlfld.txdate = tl.txdate
        and tlfld.txnum = tl.txnum
        and tlfld.fldcd='02'
        and tlfld.cvalue=bank.shortname(+)
        and tl.tltxcd in ('1131','1132','1136','1141')
        --and decode (V_STRTYPEDATE,'002',TL.busdate,TL.txdate)>=to_date(F_DATE,'DD/MM/YYYY')
        --AND decode (V_STRTYPEDATE,'002',TL.busdate,TL.txdate)<=to_date(T_DATE,'DD/MM/YYYY')
        and TL.busdate  >=to_date(F_DATE,'DD/MM/YYYY')
        and TL.busdate  <=to_date(T_DATE,'DD/MM/YYYY')
        AND TL.TLTXCD LIKE V_STRTLTXCD
        and  nvl(AF.brid,V_STRBRID) like V_STRBRID
        AND NVL( TL.TLID,'-') LIKE V_STRMAKER
        AND NVL( TL.OFFID,'-') LIKE V_STRCHECKER
        AND AF.COREBANK LIKE V_STRCOREBANK
        AND CF.custodycd LIKE V_STRPV_CUSTODYCD
        AND AF.acctno LIKE V_STRPV_AFACCTNO
        --and exists (select gu.grpid from tlgrpusers gu where af.careby = gu.grpid and gu.tlid = V_STRTLID )
        -- dfgroup
        union
        SELECT af.careby, tl.tltxcd,tltx.txdesc ,tl.txnum,tl.busdate ,tl.txdate,cf.custodycd,af.acctno, '' custodycdc,'' acctnoc,CI.NAMT amt,nvl(mk.tlname,'') mk,nvl(ck.tlname,'')  ck,nvl(AF.brid,'') brid,nvl(tl.tlid,'') tlid,nvl(tl.OFFID,'') OFFID,
        nvl(CFB.shortname,'') bankid ,af.corebank,decode(af.bankname,'---',cspks_system.fn_get_sysvar('SYSTEM','COMPANYSHORTNAME'),af.bankname) bankname, CI.trdesc trdesc
        FROM vw_tllog_all TL,dfgroup dfg ,afmast af,cfmast cf,tltx, tlprofiles mk,tlprofiles ck,
         lnmast ln,lntype , CFMAST CFB,vw_citran_gen CI
        where tl.msgacct= dfg.groupid and dfg.afacctno = af.acctno and af.custid = cf.custid
        and tltx.tltxcd = tl.tltxcd
        and dfg.lnacctno =ln.acctno
        and af.ALTERNATEACCT like v_strALTERNATEACCT
        and ln.actype =lntype.actype
        AND LN.actype= LNTYPE.actype
        AND LN.custbank = CFB.custid(+)
        and tl.tlid = mk.tlid(+)
        and tl.OFFID =ck.tlid(+)
        AND CI.ref =LN.acctno
        AND CI.txnum = TL.txnum
        AND CI.txdate =TL.txdate
        and tl.tltxcd in ('2646','2648','2665','2636')
        AND CI.field ='BALANCE'
        --and decode (V_STRTYPEDATE,'002',TL.busdate,TL.txdate)>=to_date(F_DATE,'DD/MM/YYYY')
        --AND decode (V_STRTYPEDATE,'002',TL.busdate,TL.txdate)<=to_date(T_DATE,'DD/MM/YYYY')
        and TL.busdate  >=to_date(F_DATE,'DD/MM/YYYY')
        and TL.busdate  <=to_date(T_DATE,'DD/MM/YYYY')
        AND TL.TLTXCD LIKE V_STRTLTXCD
        and  nvl(AF.brid,V_STRBRID) like V_STRBRID
        AND NVL( TL.TLID,'-') LIKE V_STRMAKER
        AND NVL( TL.OFFID,'-') LIKE V_STRCHECKER
        AND AF.COREBANK LIKE V_STRCOREBANK
        AND CF.custodycd LIKE V_STRPV_CUSTODYCD
        AND AF.acctno LIKE V_STRPV_AFACCTNO
        --and exists (select gu.grpid from tlgrpusers gu where af.careby = gu.grpid and gu.tlid = V_STRTLID )
        union
        SELECT  af.careby,  tl.tltxcd ,tltx.txdesc ,tl.txnum,tl.busdate ,tl.txdate,cf.custodycd,af.acctno, '' custodycdc,'' acctnoc,ci.NAMT amt,nvl(mk.tlname,'') mk,nvl(ck.tlname,'')  ck,nvl(AF.brid,'') brid,nvl(tl.tlid,'') tlid,nvl(tl.OFFID,'') OFFID,
        nvl(CFB.shortname,'') bankid ,af.corebank,decode(af.bankname,'---',cspks_system.fn_get_sysvar('SYSTEM','COMPANYSHORTNAME'),af.bankname) bankname,ci.trdesc
        FROM vw_tllog_all TL,afmast af,cfmast cf ,tltx, tlprofiles mk,tlprofiles ck,
         vw_citran_gen ci,
         lnmast ln,lntype , CFMAST CFB
        where tl.msgacct=af.acctno and af.custid = cf.custid
        and tltx.tltxcd = tl.tltxcd
        and  tl.tlid = mk.tlid(+)
        and af.ALTERNATEACCT like v_strALTERNATEACCT
        and  tl.OFFID =ck.tlid(+)
        and tl.txnum= ci.txnum
        and tl.txdate = ci.txdate
        and ci.ref = ln.acctno and ci.field ='BALANCE'
        AND LN.actype= LNTYPE.actype
        AND LN.custbank = CFB.custid(+)
        and tl.tltxcd in ('5540','5566','5567')
        --and decode (V_STRTYPEDATE,'002',TL.busdate,TL.txdate)>=to_date(F_DATE,'DD/MM/YYYY')
        --AND decode (V_STRTYPEDATE,'002',TL.busdate,TL.txdate)<=to_date(T_DATE,'DD/MM/YYYY')
        and TL.busdate  >=to_date(F_DATE,'DD/MM/YYYY')
        and TL.busdate  <=to_date(T_DATE,'DD/MM/YYYY')
        AND TL.TLTXCD LIKE V_STRTLTXCD
        and  nvl(AF.brid,V_STRBRID) like V_STRBRID
        AND NVL( TL.TLID,'-') LIKE V_STRMAKER
        AND NVL( TL.OFFID,'-') LIKE V_STRCHECKER
        AND AF.COREBANK LIKE V_STRCOREBANK
        AND CF.custodycd LIKE V_STRPV_CUSTODYCD
        AND AF.acctno LIKE V_STRPV_AFACCTNO
        --and exists (select gu.grpid from tlgrpusers gu where af.careby = gu.grpid and gu.tlid = V_STRTLID )
        union
        SELECT   af.careby, tl.tltxcd ,tltx.txdesc ,tl.txnum,tl.busdate ,tl.txdate,cf.custodycd,af.acctno, '' custodycdc,'' acctnoc,tl.msgamt amt,nvl(mk.tlname,'') mk,nvl(ck.tlname,'')  ck,nvl(AF.brid,'') brid,nvl(tl.tlid,'') tlid,nvl(tl.OFFID,'') OFFID,
        nvl(CFB.shortname,'') bankid ,af.corebank,decode(af.bankname,'---',cspks_system.fn_get_sysvar('SYSTEM','COMPANYSHORTNAME'),af.bankname) bankname, tl.txdesc trdesc
        FROM vw_tllog_all TL,afmast af,cfmast cf ,tltx, tlprofiles mk,tlprofiles ck,  vw_tllogfld_all tlfld, lnmast ln,lntype , CFMAST CFB
        where tl.msgacct=af.acctno and af.custid = cf.custid
        and tltx.tltxcd = tl.tltxcd
        and  tl.tlid = mk.tlid(+)
        and  tl.OFFID =ck.tlid(+)
        and af.ALTERNATEACCT like v_strALTERNATEACCT
        and tl.txnum= tlfld.txnum
        and tl.txdate = tlfld.txdate
        and tlfld.fldcd ='21'
        and tlfld.cvalue = ln.acctno(+)
        AND LN.actype= LNTYPE.actype
        AND LN.custbank = CFB.custid(+)
        AND LN.actype= LNTYPE.actype
        AND LN.custbank = CFB.custid(+)
        and tl.tltxcd ='2674'
        --and decode (V_STRTYPEDATE,'002',TL.busdate,TL.txdate)>=to_date(F_DATE,'DD/MM/YYYY')
        --AND decode (V_STRTYPEDATE,'002',TL.busdate,TL.txdate)<=to_date(T_DATE,'DD/MM/YYYY')
        and TL.busdate  >=to_date(F_DATE,'DD/MM/YYYY')
        and TL.busdate  <=to_date(T_DATE,'DD/MM/YYYY')
        AND TL.TLTXCD LIKE V_STRTLTXCD
        and  nvl(AF.brid,V_STRBRID) like V_STRBRID
        AND NVL( TL.TLID,'-') LIKE V_STRMAKER
        AND NVL( TL.OFFID,'-') LIKE V_STRCHECKER
        AND AF.COREBANK LIKE V_STRCOREBANK
        AND CF.custodycd LIKE V_STRPV_CUSTODYCD
        AND AF.acctno LIKE V_STRPV_AFACCTNO
        --and exists (select gu.grpid from tlgrpusers gu where af.careby = gu.grpid and gu.tlid = V_STRTLID )
        union
        SELECT  af.careby, tl.tltxcd   tltxcd ,tltx.txdesc ,tl.txnum,tl.busdate ,tl.txdate,cf.custodycd,af.acctno, '' custodycdc,'' acctnoc,ci.namt amt,nvl(mk.tlname,'') mk,nvl(ck.tlname,'')  ck,nvl(AF.brid,'') brid,nvl(tl.tlid,'') tlid,nvl(tl.OFFID,'') OFFID,
        ''bankid,af.corebank,decode(af.bankname,'---',cspks_system.fn_get_sysvar('SYSTEM','COMPANYSHORTNAME'),af.bankname) bankname,CI.trdesc
        FROM vw_tllog_all TL,afmast af,cfmast cf ,tltx, tlprofiles mk,tlprofiles ck,
         vw_citran_gen   ci
        where ci.acctno=af.acctno and af.custid = cf.custid
        and tltx.tltxcd = tl.tltxcd
        and  tl.tlid = mk.tlid(+)
        and af.ALTERNATEACCT like v_strALTERNATEACCT
        and  tl.OFFID =ck.tlid(+)
        and tl.txdate = ci.txdate
        and tl.txnum = ci.txnum
        and tl.tltxcd  IN ('0088','1670','1610','1600','1620','1137','1138','3384') --chaunh add 3384
        and ci.field ='BALANCE'
        --and decode (V_STRTYPEDATE,'002',TL.busdate,TL.txdate)>=to_date(F_DATE,'DD/MM/YYYY')
        --AND decode (V_STRTYPEDATE,'002',TL.busdate,TL.txdate)<=to_date(T_DATE,'DD/MM/YYYY')
        and TL.busdate  >=to_date(F_DATE,'DD/MM/YYYY')
        and TL.busdate  <=to_date(T_DATE,'DD/MM/YYYY')
        AND TL.TLTXCD LIKE V_STRTLTXCD
        and  nvl(AF.brid,V_STRBRID) like V_STRBRID
        AND NVL( TL.TLID,'-') LIKE V_STRMAKER
        AND NVL( TL.OFFID,'-') LIKE V_STRCHECKER
        AND AF.COREBANK LIKE V_STRCOREBANK
        AND CF.custodycd LIKE V_STRPV_CUSTODYCD
        AND AF.acctno LIKE V_STRPV_AFACCTNO
        --and exists (select gu.grpid from tlgrpusers gu where af.careby = gu.grpid and gu.tlid = V_STRTLID )
        )A where exists (select gu.grpid from tlgrpusers gu where a.careby = gu.grpid and gu.tlid = V_STRTLID )
        ORDER BY A.TLTXCD ,a.busdate,A.TXNUM
        ;
    else    --Lay theo txdate
        OPEN PV_REFCURSOR
          FOR

          select * from (
        select af.careby, tl.tltxcd,tltx.txdesc ,tl.txnum,tl.busdate ,tl.txdate,cf.custodycd,af.acctno, cfc.custodycd custodycdc,afc.acctno acctnoc,tl.msgamt amt,nvl(mk.tlname,'') mk,nvl(ck.tlname,'')  ck,nvl(AF.brid,'') brid,nvl(tl.tlid,'') tlid,nvl(tl.OFFID,'') OFFID,
        ''bankid,af.corebank,decode(af.bankname,'---',cspks_system.fn_get_sysvar('SYSTEM','COMPANYSHORTNAME'),af.bankname) bankname,ci.trdesc
        from vw_tllog_all TL ,vw_citran_gen ci,afmast af,cfmast cf, afmast afc,cfmast cfc ,tltx  , tlprofiles mk,tlprofiles ck
        where tl.txnum =ci.txnum and tl.txdate =ci.txdate and ci.acctno= af.acctno and cf.custid =af.custid
        and ci.ref =afc.acctno and afc.custid =cfc.custid
        and tltx.tltxcd = tl.tltxcd
        and  tl.tlid = mk.tlid(+)
        and  tl.OFFID =ck.tlid(+)
        and tl.tltxcd in ('1120','1130','1134') and ci.field ='BALANCE'
        --and decode (V_STRTYPEDATE,'002',TL.busdate,TL.txdate)>=to_date(F_DATE,'DD/MM/YYYY')
        --AND decode (V_STRTYPEDATE,'002',TL.busdate,TL.txdate)<=to_date(T_DATE,'DD/MM/YYYY')
        and TL.txdate  >=to_date(F_DATE,'DD/MM/YYYY')
        and TL.txdate  <=to_date(T_DATE,'DD/MM/YYYY')
        AND TL.TLTXCD LIKE V_STRTLTXCD
        and af.ALTERNATEACCT like v_strALTERNATEACCT
        and  nvl(AF.brid,V_STRBRID) like V_STRBRID
        AND NVL( TL.TLID,'-') LIKE V_STRMAKER
        AND NVL( TL.OFFID,'-') LIKE V_STRCHECKER
        AND AF.COREBANK LIKE V_STRCOREBANK
        AND CF.custodycd LIKE V_STRPV_CUSTODYCD
        AND AF.acctno LIKE V_STRPV_AFACCTNO
        --and exists (select gu.grpid from tlgrpusers gu where af.careby = gu.grpid and gu.tlid = V_STRTLID )
        union
        SELECT af.careby, case when  tl.tltxcd in ('3350','3354') then '3342' else  tl.tltxcd end  tltxcd ,tltx.txdesc ,tl.txnum,tl.busdate ,tl.txdate,cf.custodycd,af.acctno, '' custodycdc,'' acctnoc,tl.msgamt amt,nvl(mk.tlname,'') mk,nvl(ck.tlname,'')  ck,nvl(AF.brid,'') brid,nvl(tl.tlid,'') tlid,nvl(tl.OFFID,'') OFFID,
        ''bankid,af.corebank,decode(af.bankname,'---',cspks_system.fn_get_sysvar('SYSTEM','COMPANYSHORTNAME'),af.bankname) bankname , tl.txdesc trdesc
        FROM vw_tllog_all TL,afmast af,cfmast cf ,tltx, tlprofiles mk,tlprofiles ck
        where substr(tl.msgacct,0,10)=af.acctno and af.custid = cf.custid
        and tltx.tltxcd = tl.tltxcd
        and  tl.tlid = mk.tlid(+)
        and af.ALTERNATEACCT like v_strALTERNATEACCT
        and  tl.OFFID =ck.tlid(+)
        and tl.tltxcd in ('1140','1100','1107','1101'
        ,'1104','1108','1111','1114','1104','1112','1145','1144'
        ,'1123','1124','1126','1127','1162','1180','1182','6613','1105','1198','1199','8866'
        ,'8856','0066','8889','8894','8851','5541','3386') --Chaunh bo 3384
        --and decode (V_STRTYPEDATE,'002',TL.busdate,TL.txdate)>=to_date(F_DATE,'DD/MM/YYYY')
        --AND decode (V_STRTYPEDATE,'002',TL.busdate,TL.txdate)<=to_date(T_DATE,'DD/MM/YYYY')
        and TL.txdate  >=to_date(F_DATE,'DD/MM/YYYY')
        and TL.txdate  <=to_date(T_DATE,'DD/MM/YYYY')
        AND  case when  tl.tltxcd in ('3350','3354') then '3342' else  tl.tltxcd end  LIKE V_STRTLTXCD
        and  nvl(AF.brid,V_STRBRID) like V_STRBRID
        AND NVL( TL.TLID,'-') LIKE V_STRMAKER
        AND NVL( TL.OFFID,'-') LIKE V_STRCHECKER
        AND AF.COREBANK LIKE V_STRCOREBANK
        AND CF.custodycd LIKE V_STRPV_CUSTODYCD
        AND AF.acctno LIKE V_STRPV_AFACCTNO
        --and exists (select gu.grpid from tlgrpusers gu where af.careby = gu.grpid and gu.tlid = V_STRTLID )
        union
        SELECT   af.careby, tl.tltxcd||'T'|| '0'  tltxcd ,tltx.txdesc ,tl.txnum,tl.busdate ,tl.txdate,cf.custodycd,af.acctno, '' custodycdc,'' acctnoc,tl.msgamt amt,nvl(mk.tlname,'') mk,nvl(ck.tlname,'')  ck,nvl(AF.brid,'') brid,nvl(tl.tlid,'') tlid,nvl(tl.OFFID,'') OFFID,
        ''bankid,af.corebank,decode(af.bankname,'---',cspks_system.fn_get_sysvar('SYSTEM','COMPANYSHORTNAME'),af.bankname) bankname,ci.trdesc
        FROM vw_tllog_all TL,afmast af,cfmast cf ,tltx, tlprofiles mk,tlprofiles ck,vw_citran_gen CI, vw_stschd_all sts
        where tl.msgacct=af.acctno and af.custid = cf.custid
        and tltx.tltxcd = tl.tltxcd
        and  tl.tlid = mk.tlid(+)
        and  tl.OFFID =ck.tlid(+)
        and af.ALTERNATEACCT like v_strALTERNATEACCT
        AND TL.TXDATE = CI.TXDATE
        AND TL.TXNUM = CI.TXNUM
        AND CI.field ='BALANCE'
        and tl.tltxcd ='8855'
        and ci.ref = sts.orgorderid
        and sts.duetype ='SM'
        --and decode (V_STRTYPEDATE,'002',TL.busdate,TL.txdate)>=to_date(F_DATE,'DD/MM/YYYY')
        --AND decode (V_STRTYPEDATE,'002',TL.busdate,TL.txdate)<=to_date(T_DATE,'DD/MM/YYYY')
        and TL.txdate  >=to_date(F_DATE,'DD/MM/YYYY')
        and TL.txdate  <=to_date(T_DATE,'DD/MM/YYYY')
        AND  tl.tltxcd||'T'|| '0'  LIKE V_STRTLTXCD
        and  nvl(AF.brid,V_STRBRID) like V_STRBRID
        AND NVL( TL.TLID,'-') LIKE V_STRMAKER
        AND NVL( TL.OFFID,'-') LIKE V_STRCHECKER
        AND AF.COREBANK LIKE V_STRCOREBANK
        AND CF.custodycd LIKE V_STRPV_CUSTODYCD
        AND AF.acctno LIKE V_STRPV_AFACCTNO
        --and exists (select gu.grpid from tlgrpusers gu where af.careby = gu.grpid and gu.tlid = V_STRTLID )
        union
        SELECT af.careby, case when  tl.tltxcd in ('3350','3354') then '3342' else  tl.tltxcd end  tltxcd ,tltx.txdesc ,tl.txnum,tl.busdate ,tl.txdate,cf.custodycd,af.acctno, '' custodycdc,'' acctnoc,ci.namt amt,nvl(mk.tlname,'') mk,nvl(ck.tlname,'')  ck,nvl(AF.brid,'') brid,nvl(tl.tlid,'') tlid,nvl(tl.OFFID,'') OFFID,
        ''bankid,af.corebank,decode(af.bankname,'---',cspks_system.fn_get_sysvar('SYSTEM','COMPANYSHORTNAME'),af.bankname) bankname,ci.trdesc
        FROM vw_tllog_all TL,afmast af,cfmast cf ,tltx, tlprofiles mk,tlprofiles ck,vw_citran_gen CI
        where tl.msgacct=af.acctno and af.custid = cf.custid
        and tltx.tltxcd = tl.tltxcd
        and  tl.tlid = mk.tlid(+)
        and af.ALTERNATEACCT like v_strALTERNATEACCT
        and  tl.OFFID =ck.tlid(+)
        AND TL.TXDATE = CI.TXDATE
        AND TL.TXNUM = CI.TXNUM
        AND CI.TXCD ='0012'
        and tl.tltxcd IN('3350','3354')
        --and decode (V_STRTYPEDATE,'002',TL.busdate,TL.txdate)>=to_date(F_DATE,'DD/MM/YYYY')
        --AND decode (V_STRTYPEDATE,'002',TL.busdate,TL.txdate)<=to_date(T_DATE,'DD/MM/YYYY')
        and TL.txdate  >=to_date(F_DATE,'DD/MM/YYYY')
        and TL.txdate  <=to_date(T_DATE,'DD/MM/YYYY')
        AND case when  tl.tltxcd in ('3350','3354') then '3342' else  tl.tltxcd end  LIKE V_STRTLTXCD
        and  nvl(AF.brid,V_STRBRID) like V_STRBRID
        AND NVL( TL.TLID,'-') LIKE V_STRMAKER
        AND NVL( TL.OFFID,'-') LIKE V_STRCHECKER
        AND AF.COREBANK LIKE V_STRCOREBANK
        AND CF.custodycd LIKE V_STRPV_CUSTODYCD
        AND AF.acctno LIKE V_STRPV_AFACCTNO
        --and exists (select gu.grpid from tlgrpusers gu where af.careby = gu.grpid and gu.tlid = V_STRTLID )
        UNION
        SELECT  af.careby, tl.tltxcd ,tltx.txdesc ,tl.txnum,tl.busdate ,tl.txdate,cf.custodycd,af.acctno, '' custodycdc,'' acctnoc,CI.NAMT amt,nvl(mk.tlname,'') mk,nvl(ck.tlname,'')  ck,nvl(AF.brid,'') brid,nvl(tl.tlid,'') tlid,nvl(tl.OFFID,'') OFFID,
        ''bankid,af.corebank,decode(af.bankname,'---',cspks_system.fn_get_sysvar('SYSTEM','COMPANYSHORTNAME'),af.bankname) bankname,ci.trdesc
        FROM vw_tllog_all TL,afmast af,cfmast cf ,tltx, tlprofiles mk,tlprofiles ck,vw_citran_gen CI
        where tl.msgacct=af.acctno and af.custid = cf.custid
        and tltx.tltxcd = tl.tltxcd
        and  tl.tlid = mk.tlid(+)
        and  tl.OFFID =ck.tlid(+)
        AND TL.TXDATE = CI.TXDATE
        AND TL.TXNUM = CI.TXNUM
        and af.ALTERNATEACCT like v_strALTERNATEACCT
        AND CI.field ='BALANCE'
        and tl.tltxcd in('1153','8865','1139')
        --and decode (V_STRTYPEDATE,'002',TL.busdate,TL.txdate)>=to_date(F_DATE,'DD/MM/YYYY')
        --AND decode (V_STRTYPEDATE,'002',TL.busdate,TL.txdate)<=to_date(T_DATE,'DD/MM/YYYY')
        and TL.txdate  >=to_date(F_DATE,'DD/MM/YYYY')
        and TL.txdate  <=to_date(T_DATE,'DD/MM/YYYY')
        AND TL.TLTXCD LIKE V_STRTLTXCD
        and  nvl(AF.brid,V_STRBRID) like V_STRBRID
        AND NVL( TL.TLID,'-') LIKE V_STRMAKER
        AND NVL( TL.OFFID,'-') LIKE V_STRCHECKER
        AND AF.COREBANK LIKE V_STRCOREBANK
        AND CF.custodycd LIKE V_STRPV_CUSTODYCD
        AND AF.acctno LIKE V_STRPV_AFACCTNO
        --and exists (select gu.grpid from tlgrpusers gu where af.careby = gu.grpid and gu.tlid = V_STRTLID )
        --1178
        union
        SELECT af.careby, tl.tltxcd,tltx.txdesc ,tl.txnum,tl.busdate ,tl.txdate,cf.custodycd,af.acctno, '' custodycdc,'' acctnoc,ads.amt amt,nvl(mk.tlname,'') mk,nvl(ck.tlname,'')  ck,nvl(AF.brid,'') brid,nvl(tl.tlid,'') tlid,nvl(tl.OFFID,'') OFFID,
        '' bankid,af.corebank,decode(af.bankname,'---',cspks_system.fn_get_sysvar('SYSTEM','COMPANYSHORTNAME'),af.bankname) bankname, tl.txdesc trdesc
        FROM vw_tllog_all TL,adschd ads ,afmast af,cfmast cf,tltx, tlprofiles mk,tlprofiles ck
        where tl.msgamt =ads.autoid
        and TL.msgacct = af.acctno and af.custid = cf.custid
        and tltx.tltxcd = tl.tltxcd
        and  tl.tlid = mk.tlid(+)
        and af.ALTERNATEACCT like v_strALTERNATEACCT
        and  tl.OFFID =ck.tlid(+)
        and tl.tltxcd in ('1178')
        --and decode (V_STRTYPEDATE,'002',TL.busdate,TL.txdate)>=to_date(F_DATE,'DD/MM/YYYY')
        --AND decode (V_STRTYPEDATE,'002',TL.busdate,TL.txdate)<=to_date(T_DATE,'DD/MM/YYYY')
        and TL.txdate  >=to_date(F_DATE,'DD/MM/YYYY')
        and TL.txdate  <=to_date(T_DATE,'DD/MM/YYYY')
        AND TL.TLTXCD LIKE V_STRTLTXCD
        and  nvl(AF.brid,V_STRBRID) like V_STRBRID
        AND NVL( TL.TLID,'-') LIKE V_STRMAKER
        AND NVL( TL.OFFID,'-') LIKE V_STRCHECKER
        AND AF.COREBANK LIKE V_STRCOREBANK
        AND CF.custodycd LIKE V_STRPV_CUSTODYCD
        AND AF.acctno LIKE V_STRPV_AFACCTNO
        --and exists (select gu.grpid from tlgrpusers gu where af.careby = gu.grpid and gu.tlid = V_STRTLID )
        --nhom bank
        --'1131','1132','1136','1141'
        union

        SELECT   af.careby, tl.tltxcd ,tltx.txdesc ,tl.txnum,tl.busdate ,tl.txdate,cf.custodycd,af.acctno, '' custodycdc,'' acctnoc,tl.msgamt amt,nvl(mk.tlname,'') mk,nvl(ck.tlname,'')  ck,nvl(AF.brid,'') brid,nvl(tl.tlid,'') tlid,nvl(tl.OFFID,'') OFFID
        ,nvl(bank.fullname,' ') bankid,af.corebank,decode(af.bankname,'---',cspks_system.fn_get_sysvar('SYSTEM','COMPANYSHORTNAME'),af.bankname) bankname, tl.txdesc trdesc
        FROM vw_tllog_all TL,afmast af,cfmast cf ,tltx, tlprofiles mk,tlprofiles ck,vw_tllogfld_all tlfld,banknostro bank
        where tl.msgacct=af.acctno and af.custid = cf.custid
        and tltx.tltxcd = tl.tltxcd
        and  tl.tlid = mk.tlid(+)
        and af.ALTERNATEACCT like v_strALTERNATEACCT
        and  tl.OFFID =ck.tlid(+)
        and tlfld.txdate = tl.txdate
        and tlfld.txnum = tl.txnum
        and tlfld.fldcd='02'
        and tlfld.cvalue=bank.shortname(+)
        and tl.tltxcd in ('1131','1132','1136','1141')
        --and decode (V_STRTYPEDATE,'002',TL.busdate,TL.txdate)>=to_date(F_DATE,'DD/MM/YYYY')
        --AND decode (V_STRTYPEDATE,'002',TL.busdate,TL.txdate)<=to_date(T_DATE,'DD/MM/YYYY')
        and TL.txdate  >=to_date(F_DATE,'DD/MM/YYYY')
        and TL.txdate  <=to_date(T_DATE,'DD/MM/YYYY')
        AND TL.TLTXCD LIKE V_STRTLTXCD
        and  nvl(AF.brid,V_STRBRID) like V_STRBRID
        AND NVL( TL.TLID,'-') LIKE V_STRMAKER
        AND NVL( TL.OFFID,'-') LIKE V_STRCHECKER
        AND AF.COREBANK LIKE V_STRCOREBANK
        AND CF.custodycd LIKE V_STRPV_CUSTODYCD
        AND AF.acctno LIKE V_STRPV_AFACCTNO
        --and exists (select gu.grpid from tlgrpusers gu where af.careby = gu.grpid and gu.tlid = V_STRTLID )
        -- dfgroup
        union
        SELECT af.careby, tl.tltxcd,tltx.txdesc ,tl.txnum,tl.busdate ,tl.txdate,cf.custodycd,af.acctno, '' custodycdc,'' acctnoc,CI.NAMT amt,nvl(mk.tlname,'') mk,nvl(ck.tlname,'')  ck,nvl(AF.brid,'') brid,nvl(tl.tlid,'') tlid,nvl(tl.OFFID,'') OFFID,
        nvl(CFB.shortname,'') bankid ,af.corebank,decode(af.bankname,'---',cspks_system.fn_get_sysvar('SYSTEM','COMPANYSHORTNAME'),af.bankname) bankname, CI.trdesc trdesc
        FROM vw_tllog_all TL,dfgroup dfg ,afmast af,cfmast cf,tltx, tlprofiles mk,tlprofiles ck,
         lnmast ln,lntype , CFMAST CFB,vw_citran_gen CI
        where tl.msgacct= dfg.groupid and dfg.afacctno = af.acctno and af.custid = cf.custid
        and tltx.tltxcd = tl.tltxcd
        and dfg.lnacctno =ln.acctno
        and ln.actype =lntype.actype
        AND LN.actype= LNTYPE.actype
        AND LN.custbank = CFB.custid(+)
        and af.ALTERNATEACCT like v_strALTERNATEACCT
        and tl.tlid = mk.tlid(+)
        and tl.OFFID =ck.tlid(+)
        AND CI.ref =LN.acctno
        AND CI.txnum = TL.txnum
        AND CI.txdate =TL.txdate
        and tl.tltxcd in ('2646','2648','2665','2636')
        AND CI.field ='BALANCE'
        --and decode (V_STRTYPEDATE,'002',TL.busdate,TL.txdate)>=to_date(F_DATE,'DD/MM/YYYY')
        --AND decode (V_STRTYPEDATE,'002',TL.busdate,TL.txdate)<=to_date(T_DATE,'DD/MM/YYYY')
        and TL.txdate  >=to_date(F_DATE,'DD/MM/YYYY')
        and TL.txdate  <=to_date(T_DATE,'DD/MM/YYYY')
        AND TL.TLTXCD LIKE V_STRTLTXCD
        and  nvl(AF.brid,V_STRBRID) like V_STRBRID
        AND NVL( TL.TLID,'-') LIKE V_STRMAKER
        AND NVL( TL.OFFID,'-') LIKE V_STRCHECKER
        AND AF.COREBANK LIKE V_STRCOREBANK
        AND CF.custodycd LIKE V_STRPV_CUSTODYCD
        AND AF.acctno LIKE V_STRPV_AFACCTNO
        --and exists (select gu.grpid from tlgrpusers gu where af.careby = gu.grpid and gu.tlid = V_STRTLID )
        union
        SELECT  af.careby,  tl.tltxcd ,tltx.txdesc ,tl.txnum,tl.busdate ,tl.txdate,cf.custodycd,af.acctno, '' custodycdc,'' acctnoc,ci.NAMT amt,nvl(mk.tlname,'') mk,nvl(ck.tlname,'')  ck,nvl(AF.brid,'') brid,nvl(tl.tlid,'') tlid,nvl(tl.OFFID,'') OFFID,
        nvl(CFB.shortname,'') bankid ,af.corebank,decode(af.bankname,'---',cspks_system.fn_get_sysvar('SYSTEM','COMPANYSHORTNAME'),af.bankname) bankname,ci.trdesc
        FROM vw_tllog_all TL,afmast af,cfmast cf ,tltx, tlprofiles mk,tlprofiles ck,
         vw_citran_gen ci,
         lnmast ln,lntype , CFMAST CFB
        where tl.msgacct=af.acctno and af.custid = cf.custid
        and tltx.tltxcd = tl.tltxcd
        and  tl.tlid = mk.tlid(+)
        and  tl.OFFID =ck.tlid(+)
        and af.ALTERNATEACCT like v_strALTERNATEACCT
        and tl.txnum= ci.txnum
        and tl.txdate = ci.txdate
        and ci.ref = ln.acctno and ci.field ='BALANCE'
        AND LN.actype= LNTYPE.actype
        AND LN.custbank = CFB.custid(+)
        and tl.tltxcd in ('5540','5566','5567')
        --and decode (V_STRTYPEDATE,'002',TL.busdate,TL.txdate)>=to_date(F_DATE,'DD/MM/YYYY')
        --AND decode (V_STRTYPEDATE,'002',TL.busdate,TL.txdate)<=to_date(T_DATE,'DD/MM/YYYY')
        and TL.txdate  >=to_date(F_DATE,'DD/MM/YYYY')
        and TL.txdate  <=to_date(T_DATE,'DD/MM/YYYY')
        AND TL.TLTXCD LIKE V_STRTLTXCD
        and  nvl(AF.brid,V_STRBRID) like V_STRBRID
        AND NVL( TL.TLID,'-') LIKE V_STRMAKER
        AND NVL( TL.OFFID,'-') LIKE V_STRCHECKER
        AND AF.COREBANK LIKE V_STRCOREBANK
        AND CF.custodycd LIKE V_STRPV_CUSTODYCD
        AND AF.acctno LIKE V_STRPV_AFACCTNO
        --and exists (select gu.grpid from tlgrpusers gu where af.careby = gu.grpid and gu.tlid = V_STRTLID )
        union
        SELECT  af.careby,  tl.tltxcd ,tltx.txdesc ,tl.txnum,tl.busdate ,tl.txdate,cf.custodycd,af.acctno, '' custodycdc,'' acctnoc,tl.msgamt amt,nvl(mk.tlname,'') mk,nvl(ck.tlname,'')  ck,nvl(AF.brid,'') brid,nvl(tl.tlid,'') tlid,nvl(tl.OFFID,'') OFFID,
        nvl(CFB.shortname,'') bankid ,af.corebank,decode(af.bankname,'---',cspks_system.fn_get_sysvar('SYSTEM','COMPANYSHORTNAME'),af.bankname) bankname, tl.txdesc trdesc
        FROM vw_tllog_all TL,afmast af,cfmast cf ,tltx, tlprofiles mk,tlprofiles ck,  vw_tllogfld_all tlfld, lnmast ln,lntype , CFMAST CFB
        where tl.msgacct=af.acctno and af.custid = cf.custid
        and tltx.tltxcd = tl.tltxcd
        and  tl.tlid = mk.tlid(+)
        and  tl.OFFID =ck.tlid(+)
        and af.ALTERNATEACCT like v_strALTERNATEACCT
        and tl.txnum= tlfld.txnum
        and tl.txdate = tlfld.txdate
        and tlfld.fldcd ='21'
        and tlfld.cvalue = ln.acctno(+)
        AND LN.actype= LNTYPE.actype
        AND LN.custbank = CFB.custid(+)
        AND LN.actype= LNTYPE.actype
        AND LN.custbank = CFB.custid(+)
        and tl.tltxcd ='2674'
        --and decode (V_STRTYPEDATE,'002',TL.busdate,TL.txdate)>=to_date(F_DATE,'DD/MM/YYYY')
        --AND decode (V_STRTYPEDATE,'002',TL.busdate,TL.txdate)<=to_date(T_DATE,'DD/MM/YYYY')
        and TL.txdate  >=to_date(F_DATE,'DD/MM/YYYY')
        and TL.txdate  <=to_date(T_DATE,'DD/MM/YYYY')
        AND TL.TLTXCD LIKE V_STRTLTXCD
        and  nvl(AF.brid,V_STRBRID) like V_STRBRID
        AND NVL( TL.TLID,'-') LIKE V_STRMAKER
        AND NVL( TL.OFFID,'-') LIKE V_STRCHECKER
        AND AF.COREBANK LIKE V_STRCOREBANK
        AND CF.custodycd LIKE V_STRPV_CUSTODYCD
        AND AF.acctno LIKE V_STRPV_AFACCTNO
        --and exists (select gu.grpid from tlgrpusers gu where af.careby = gu.grpid and gu.tlid = V_STRTLID )
        union
        SELECT af.careby,  tl.tltxcd   tltxcd ,tltx.txdesc ,tl.txnum,tl.busdate ,tl.txdate,cf.custodycd,af.acctno, '' custodycdc,'' acctnoc,ci.namt amt,nvl(mk.tlname,'') mk,nvl(ck.tlname,'')  ck,nvl(AF.brid,'') brid,nvl(tl.tlid,'') tlid,nvl(tl.OFFID,'') OFFID,
        ''bankid,af.corebank,decode(af.bankname,'---',cspks_system.fn_get_sysvar('SYSTEM','COMPANYSHORTNAME'),af.bankname) bankname,CI.trdesc
        FROM vw_tllog_all TL,afmast af,cfmast cf ,tltx, tlprofiles mk,tlprofiles ck,
         vw_citran_gen   ci
        where ci.acctno=af.acctno and af.custid = cf.custid
        and tltx.tltxcd = tl.tltxcd
        and af.ALTERNATEACCT like v_strALTERNATEACCT
        and  tl.tlid = mk.tlid(+)
        and  tl.OFFID =ck.tlid(+)
        and tl.txdate = ci.txdate
        and tl.txnum = ci.txnum
        and tl.tltxcd  IN ('0088','1670','1610','1600','1620','1137','1138','3384') --chaunh add 3384
        and ci.field ='BALANCE'
        --and decode (V_STRTYPEDATE,'002',TL.busdate,TL.txdate)>=to_date(F_DATE,'DD/MM/YYYY')
        --AND decode (V_STRTYPEDATE,'002',TL.busdate,TL.txdate)<=to_date(T_DATE,'DD/MM/YYYY')
        and TL.txdate  >=to_date(F_DATE,'DD/MM/YYYY')
        and TL.txdate  <=to_date(T_DATE,'DD/MM/YYYY')
        AND TL.TLTXCD LIKE V_STRTLTXCD
        and  nvl(AF.brid,V_STRBRID) like V_STRBRID
        AND NVL( TL.TLID,'-') LIKE V_STRMAKER
        AND NVL( TL.OFFID,'-') LIKE V_STRCHECKER
        AND AF.COREBANK LIKE V_STRCOREBANK
        AND CF.custodycd LIKE V_STRPV_CUSTODYCD
        AND AF.acctno LIKE V_STRPV_AFACCTNO
        --and exists (select gu.grpid from tlgrpusers gu where af.careby = gu.grpid and gu.tlid = V_STRTLID )
        )A where exists (select gu.grpid from tlgrpusers gu where a.careby = gu.grpid and gu.tlid = V_STRTLID )
        ORDER BY A.TLTXCD ,a.busdate,A.TXNUM
        ;
    end if;

ELSE
    if V_STRTYPEDATE ='002' then --Lay theo busdate
        OPEN PV_REFCURSOR
        FOR
          select * from (
        select af.careby, tl.tltxcd,tltx.txdesc ,tl.txnum,tl.busdate ,tl.txdate,cf.custodycd,af.acctno, cfc.custodycd custodycdc,afc.acctno acctnoc,tl.msgamt amt,nvl(mk.tlname,'') mk,nvl(ck.tlname,'')  ck,nvl(tl.brid,'') brid,nvl(tl.tlid,'') tlid,nvl(tl.OFFID,'') OFFID,
        ''bankid,af.corebank,decode(af.bankname,'---',cspks_system.fn_get_sysvar('SYSTEM','COMPANYSHORTNAME'),af.bankname) bankname,ci.trdesc
        from vw_tllog_all TL ,vw_citran_gen ci,afmast af,cfmast cf, afmast afc,cfmast cfc ,tltx  , tlprofiles mk,tlprofiles ck
        where tl.txnum =ci.txnum and tl.txdate =ci.txdate and ci.acctno= af.acctno and cf.custid =af.custid
        and ci.ref =afc.acctno and afc.custid =cfc.custid
        and tltx.tltxcd = tl.tltxcd
        and  tl.tlid = mk.tlid(+)
        and  tl.OFFID =ck.tlid(+)
        and tl.tltxcd in ('1120','1130','1134') and ci.field ='BALANCE'
        --and decode (V_STRTYPEDATE,'002',TL.busdate,TL.txdate)>=to_date(F_DATE,'DD/MM/YYYY')
        --AND decode (V_STRTYPEDATE,'002',TL.busdate,TL.txdate)<=to_date(T_DATE,'DD/MM/YYYY')
        and TL.busdate  >=to_date(F_DATE,'DD/MM/YYYY')
        and TL.busdate  <=to_date(T_DATE,'DD/MM/YYYY')
        and af.ALTERNATEACCT like v_strALTERNATEACCT
        AND TL.TLTXCD LIKE V_STRTLTXCD
        and  nvl(tl.brid,V_STRBRID) like V_STRBRID
        AND NVL( TL.TLID,'-') LIKE V_STRMAKER
        AND NVL( TL.OFFID,'-') LIKE V_STRCHECKER
        AND AF.COREBANK LIKE V_STRCOREBANK
        AND CF.custodycd LIKE V_STRPV_CUSTODYCD
        AND AF.acctno LIKE V_STRPV_AFACCTNO
        --and exists (select gu.grpid from tlgrpusers gu where af.careby = gu.grpid and gu.tlid = V_STRTLID )

        union
        SELECT af.careby, case when  tl.tltxcd in ('3350','3354') then '3342' else  tl.tltxcd end  tltxcd ,tltx.txdesc ,tl.txnum,tl.busdate ,tl.txdate,cf.custodycd,af.acctno, '' custodycdc,'' acctnoc,tl.msgamt amt,nvl(mk.tlname,'') mk,nvl(ck.tlname,'')  ck,nvl(tl.brid,'') brid,nvl(tl.tlid,'') tlid,nvl(tl.OFFID,'') OFFID,
        ''bankid,af.corebank,decode(af.bankname,'---',cspks_system.fn_get_sysvar('SYSTEM','COMPANYSHORTNAME'),af.bankname) bankname , tl.txdesc trdesc
        FROM vw_tllog_all TL,afmast af,cfmast cf ,tltx, tlprofiles mk,tlprofiles ck
        where substr(tl.msgacct,0,10)=af.acctno and af.custid = cf.custid
        and tltx.tltxcd = tl.tltxcd
        and af.ALTERNATEACCT like v_strALTERNATEACCT
        and  tl.tlid = mk.tlid(+)
        and  tl.OFFID =ck.tlid(+)
        and tl.tltxcd in ('1140','1100','1107','1101'
        ,'1104','1108','1111','1114','1104','1112','1145','1144'
        ,'1123','1124','1126','1127','1162','1180','1182','6613','1105','1198','1199','8866'
        ,'8856','0066','8889','8894','8851','5541','3386') --Chaunh bo 3384
        --and decode (V_STRTYPEDATE,'002',TL.busdate,TL.txdate)>=to_date(F_DATE,'DD/MM/YYYY')
        --AND decode (V_STRTYPEDATE,'002',TL.busdate,TL.txdate)<=to_date(T_DATE,'DD/MM/YYYY')
        and TL.busdate  >=to_date(F_DATE,'DD/MM/YYYY')
        and TL.busdate  <=to_date(T_DATE,'DD/MM/YYYY')AND TL.TLTXCD LIKE V_STRTLTXCD
        and  nvl(tl.brid,V_STRBRID) like V_STRBRID
        AND NVL( TL.TLID,'-') LIKE V_STRMAKER
        AND NVL( TL.OFFID,'-') LIKE V_STRCHECKER
        AND AF.COREBANK LIKE V_STRCOREBANK
        AND CF.custodycd LIKE V_STRPV_CUSTODYCD
        AND AF.acctno LIKE V_STRPV_AFACCTNO
        --and exists (select gu.grpid from tlgrpusers gu where af.careby = gu.grpid and gu.tlid = V_STRTLID )
        union
        SELECT   af.careby, tl.tltxcd||'T'|| '0' tltxcd ,tltx.txdesc ,tl.txnum,tl.busdate ,tl.txdate,cf.custodycd,af.acctno, '' custodycdc,'' acctnoc,tl.msgamt amt,nvl(mk.tlname,'') mk,nvl(ck.tlname,'')  ck,nvl(tl.brid,'') brid,nvl(tl.tlid,'') tlid,nvl(tl.OFFID,'') OFFID,
        ''bankid,af.corebank,decode(af.bankname,'---',cspks_system.fn_get_sysvar('SYSTEM','COMPANYSHORTNAME'),af.bankname) bankname,ci.trdesc
        FROM vw_tllog_all TL,afmast af,cfmast cf ,tltx, tlprofiles mk,tlprofiles ck,vw_citran_gen CI, vw_stschd_all sts
        where tl.msgacct=af.acctno and af.custid = cf.custid
        and tltx.tltxcd = tl.tltxcd
        and  tl.tlid = mk.tlid(+)
        and  tl.OFFID =ck.tlid(+)
        and af.ALTERNATEACCT like v_strALTERNATEACCT
        AND TL.TXDATE = CI.TXDATE
        AND TL.TXNUM = CI.TXNUM
        AND CI.field ='BALANCE'
        and tl.tltxcd ='8855'
        and ci.ref = sts.orgorderid
        and sts.duetype ='SM'
        --and decode (V_STRTYPEDATE,'002',TL.busdate,TL.txdate)>=to_date(F_DATE,'DD/MM/YYYY')
        --AND decode (V_STRTYPEDATE,'002',TL.busdate,TL.txdate)<=to_date(T_DATE,'DD/MM/YYYY')
        and TL.busdate  >=to_date(F_DATE,'DD/MM/YYYY')
        and TL.busdate  <=to_date(T_DATE,'DD/MM/YYYY')
        AND TL.TLTXCD LIKE V_STRTLTXCD
        and  nvl(tl.brid,V_STRBRID) like V_STRBRID
        AND NVL( TL.TLID,'-') LIKE V_STRMAKER
        AND NVL( TL.OFFID,'-') LIKE V_STRCHECKER
        AND AF.COREBANK LIKE V_STRCOREBANK
        AND CF.custodycd LIKE V_STRPV_CUSTODYCD
        AND AF.acctno LIKE V_STRPV_AFACCTNO
        --and exists (select gu.grpid from tlgrpusers gu where af.careby = gu.grpid and gu.tlid = V_STRTLID )
        union
        SELECT af.careby, case when  tl.tltxcd in ('3350','3354') then '3342' else  tl.tltxcd end  tltxcd ,tltx.txdesc ,tl.txnum,tl.busdate ,tl.txdate,cf.custodycd,af.acctno, '' custodycdc,'' acctnoc,tl.msgamt amt,nvl(mk.tlname,'') mk,nvl(ck.tlname,'')  ck,nvl(tl.brid,'') brid,nvl(tl.tlid,'') tlid,nvl(tl.OFFID,'') OFFID,
        ''bankid,af.corebank,decode(af.bankname,'---',cspks_system.fn_get_sysvar('SYSTEM','COMPANYSHORTNAME'),af.bankname) bankname,ci.trdesc
        FROM vw_tllog_all TL,afmast af,cfmast cf ,tltx, tlprofiles mk,tlprofiles ck,vw_citran_gen CI
        where tl.msgacct=af.acctno and af.custid = cf.custid
        and tltx.tltxcd = tl.tltxcd
        and  tl.tlid = mk.tlid(+)
        and  tl.OFFID =ck.tlid(+)
        and af.ALTERNATEACCT like v_strALTERNATEACCT
        AND TL.TXDATE = CI.TXDATE
        AND TL.TXNUM = CI.TXNUM
        AND CI.TXCD ='0012'
        and tl.tltxcd IN('3350','3354')
        --and decode (V_STRTYPEDATE,'002',TL.busdate,TL.txdate)>=to_date(F_DATE,'DD/MM/YYYY')
        --AND decode (V_STRTYPEDATE,'002',TL.busdate,TL.txdate)<=to_date(T_DATE,'DD/MM/YYYY')
        and TL.busdate  >=to_date(F_DATE,'DD/MM/YYYY')
        and TL.busdate  <=to_date(T_DATE,'DD/MM/YYYY')
        AND case when  tl.tltxcd in ('3350','3354') then '3342' else  tl.tltxcd end  LIKE V_STRTLTXCD
        and  nvl(tl.brid,V_STRBRID) like V_STRBRID
        AND NVL( TL.TLID,'-') LIKE V_STRMAKER
        AND NVL( TL.OFFID,'-') LIKE V_STRCHECKER
        AND AF.COREBANK LIKE V_STRCOREBANK
        AND CF.custodycd LIKE V_STRPV_CUSTODYCD
        AND AF.acctno LIKE V_STRPV_AFACCTNO
        --and exists (select gu.grpid from tlgrpusers gu where af.careby = gu.grpid and gu.tlid = V_STRTLID )
        UNION
        SELECT af.careby,  tl.tltxcd ,tltx.txdesc ,tl.txnum,tl.busdate ,tl.txdate,cf.custodycd,af.acctno, '' custodycdc,'' acctnoc,CI.NAMT amt,nvl(mk.tlname,'') mk,nvl(ck.tlname,'')  ck,nvl(tl.brid,'') brid,nvl(tl.tlid,'') tlid,nvl(tl.OFFID,'') OFFID,
        ''bankid,af.corebank,decode(af.bankname,'---',cspks_system.fn_get_sysvar('SYSTEM','COMPANYSHORTNAME'),af.bankname) bankname,ci.trdesc
        FROM vw_tllog_all TL,afmast af,cfmast cf ,tltx, tlprofiles mk,tlprofiles ck,vw_citran_gen CI
        where tl.msgacct=af.acctno and af.custid = cf.custid
        and tltx.tltxcd = tl.tltxcd
        and  tl.tlid = mk.tlid(+)
        and  tl.OFFID =ck.tlid(+)
        and af.ALTERNATEACCT like v_strALTERNATEACCT
        AND TL.TXDATE = CI.TXDATE
        AND TL.TXNUM = CI.TXNUM
        AND CI.field ='BALANCE'
        and tl.tltxcd in('1153','8865','1139')
        --and decode (V_STRTYPEDATE,'002',TL.busdate,TL.txdate)>=to_date(F_DATE,'DD/MM/YYYY')
        --AND decode (V_STRTYPEDATE,'002',TL.busdate,TL.txdate)<=to_date(T_DATE,'DD/MM/YYYY')
        and TL.busdate  >=to_date(F_DATE,'DD/MM/YYYY')
        and TL.busdate  <=to_date(T_DATE,'DD/MM/YYYY')
        AND TL.TLTXCD LIKE V_STRTLTXCD
        and  nvl(tl.brid,V_STRBRID) like V_STRBRID
        AND NVL( TL.TLID,'-') LIKE V_STRMAKER
        AND NVL( TL.OFFID,'-') LIKE V_STRCHECKER
        AND AF.COREBANK LIKE V_STRCOREBANK
        AND CF.custodycd LIKE V_STRPV_CUSTODYCD
        AND AF.acctno LIKE V_STRPV_AFACCTNO
        --and exists (select gu.grpid from tlgrpusers gu where af.careby = gu.grpid and gu.tlid = V_STRTLID )

        --1178
        union
        SELECT af.careby, tl.tltxcd,tltx.txdesc ,tl.txnum,tl.busdate ,tl.txdate,cf.custodycd,af.acctno, '' custodycdc,'' acctnoc,ads.amt amt,nvl(mk.tlname,'') mk,nvl(ck.tlname,'')  ck,nvl(tl.brid,'') brid,nvl(tl.tlid,'') tlid,nvl(tl.OFFID,'') OFFID,
        '' bankid,af.corebank,decode(af.bankname,'---',cspks_system.fn_get_sysvar('SYSTEM','COMPANYSHORTNAME'),af.bankname) bankname, tl.txdesc trdesc
        FROM vw_tllog_all TL,adschd ads ,afmast af,cfmast cf,tltx, tlprofiles mk,tlprofiles ck
        where tl.msgamt =ads.autoid
        and TL.msgacct = af.acctno and af.custid = cf.custid
        and tltx.tltxcd = tl.tltxcd
        and  tl.tlid = mk.tlid(+)
        and af.ALTERNATEACCT like v_strALTERNATEACCT
        and  tl.OFFID =ck.tlid(+)
        and tl.tltxcd in ('1178')
        --and decode (V_STRTYPEDATE,'002',TL.busdate,TL.txdate)>=to_date(F_DATE,'DD/MM/YYYY')
        --AND decode (V_STRTYPEDATE,'002',TL.busdate,TL.txdate)<=to_date(T_DATE,'DD/MM/YYYY')
        and TL.busdate  >=to_date(F_DATE,'DD/MM/YYYY')
        and TL.busdate  <=to_date(T_DATE,'DD/MM/YYYY')
        AND TL.TLTXCD LIKE V_STRTLTXCD
        and  nvl(tl.brid,V_STRBRID) like V_STRBRID
        AND NVL( TL.TLID,'-') LIKE V_STRMAKER
        AND NVL( TL.OFFID,'-') LIKE V_STRCHECKER
        AND AF.COREBANK LIKE V_STRCOREBANK
        AND CF.custodycd LIKE V_STRPV_CUSTODYCD
        AND AF.acctno LIKE V_STRPV_AFACCTNO
        --and exists (select gu.grpid from tlgrpusers gu where af.careby = gu.grpid and gu.tlid = V_STRTLID )
        --nhom bank
        --'1131','1132','1136','1141'
        union

        SELECT  af.careby,  tl.tltxcd ,tltx.txdesc ,tl.txnum,tl.busdate ,tl.txdate,cf.custodycd,af.acctno, '' custodycdc,'' acctnoc,tl.msgamt amt,nvl(mk.tlname,'') mk,nvl(ck.tlname,'')  ck,nvl(tl.brid,'') brid,nvl(tl.tlid,'') tlid,nvl(tl.OFFID,'') OFFID
        ,nvl(bank.fullname,' ') bankid,af.corebank,decode(af.bankname,'---',cspks_system.fn_get_sysvar('SYSTEM','COMPANYSHORTNAME'),af.bankname) bankname, tl.txdesc trdesc
        FROM vw_tllog_all TL,afmast af,cfmast cf ,tltx, tlprofiles mk,tlprofiles ck,vw_tllogfld_all tlfld,banknostro bank
        where tl.msgacct=af.acctno and af.custid = cf.custid
        and tltx.tltxcd = tl.tltxcd
        and af.ALTERNATEACCT like v_strALTERNATEACCT
        and  tl.tlid = mk.tlid(+)
        and  tl.OFFID =ck.tlid(+)
        and tlfld.txdate = tl.txdate
        and tlfld.txnum = tl.txnum
        and tlfld.fldcd='02'
        and tlfld.cvalue=bank.shortname(+)
        and tl.tltxcd in ('1131','1132','1136','1141')
        --and decode (V_STRTYPEDATE,'002',TL.busdate,TL.txdate)>=to_date(F_DATE,'DD/MM/YYYY')
        --AND decode (V_STRTYPEDATE,'002',TL.busdate,TL.txdate)<=to_date(T_DATE,'DD/MM/YYYY')
        and TL.busdate  >=to_date(F_DATE,'DD/MM/YYYY')
        and TL.busdate  <=to_date(T_DATE,'DD/MM/YYYY')
        AND TL.TLTXCD LIKE V_STRTLTXCD
        and  nvl(tl.brid,V_STRBRID) like V_STRBRID
        AND NVL( TL.TLID,'-') LIKE V_STRMAKER
        AND NVL( TL.OFFID,'-') LIKE V_STRCHECKER
        AND AF.COREBANK LIKE V_STRCOREBANK
        AND CF.custodycd LIKE V_STRPV_CUSTODYCD
        AND AF.acctno LIKE V_STRPV_AFACCTNO
        --and exists (select gu.grpid from tlgrpusers gu where af.careby = gu.grpid and gu.tlid = V_STRTLID )
        -- dfgroup
        union
        SELECT af.careby, tl.tltxcd,tltx.txdesc ,tl.txnum,tl.busdate ,tl.txdate,cf.custodycd,af.acctno, '' custodycdc,'' acctnoc,CI.NAMT amt,nvl(mk.tlname,'') mk,nvl(ck.tlname,'')  ck,nvl(tl.brid,'') brid,nvl(tl.tlid,'') tlid,nvl(tl.OFFID,'') OFFID,
        nvl(CFB.shortname,'') bankid ,af.corebank,decode(af.bankname,'---',cspks_system.fn_get_sysvar('SYSTEM','COMPANYSHORTNAME'),af.bankname) bankname, CI.trdesc trdesc
        FROM vw_tllog_all TL,dfgroup dfg ,afmast af,cfmast cf,tltx, tlprofiles mk,tlprofiles ck,
         lnmast ln,lntype , CFMAST CFB,vw_citran_gen CI
        where tl.msgacct= dfg.groupid and dfg.afacctno = af.acctno and af.custid = cf.custid
        and tltx.tltxcd = tl.tltxcd
        and dfg.lnacctno =ln.acctno
        and af.ALTERNATEACCT like v_strALTERNATEACCT
        and ln.actype =lntype.actype
        AND LN.actype= LNTYPE.actype
        AND LN.custbank = CFB.custid(+)
        and tl.tlid = mk.tlid(+)
        and tl.OFFID =ck.tlid(+)
        AND CI.ref =LN.acctno
        AND CI.txnum = TL.txnum
        AND CI.txdate =TL.txdate
        and tl.tltxcd in ('2646','2648','2665','2636')
        AND CI.field ='BALANCE'
        --and decode (V_STRTYPEDATE,'002',TL.busdate,TL.txdate)>=to_date(F_DATE,'DD/MM/YYYY')
        --AND decode (V_STRTYPEDATE,'002',TL.busdate,TL.txdate)<=to_date(T_DATE,'DD/MM/YYYY')
        and TL.busdate  >=to_date(F_DATE,'DD/MM/YYYY')
        and TL.busdate  <=to_date(T_DATE,'DD/MM/YYYY')
        AND TL.TLTXCD LIKE V_STRTLTXCD
        and  nvl(tl.brid,V_STRBRID) like V_STRBRID
        AND NVL( TL.TLID,'-') LIKE V_STRMAKER
        AND NVL( TL.OFFID,'-') LIKE V_STRCHECKER
        AND AF.COREBANK LIKE V_STRCOREBANK
        AND CF.custodycd LIKE V_STRPV_CUSTODYCD
        AND AF.acctno LIKE V_STRPV_AFACCTNO
        --and exists (select gu.grpid from tlgrpusers gu where af.careby = gu.grpid and gu.tlid = V_STRTLID )

        union
        SELECT  af.careby,  tl.tltxcd ,tltx.txdesc ,tl.txnum,tl.busdate ,tl.txdate,cf.custodycd,af.acctno, '' custodycdc,'' acctnoc,ci.NAMT amt,nvl(mk.tlname,'') mk,nvl(ck.tlname,'')  ck,nvl(tl.brid,'') brid,nvl(tl.tlid,'') tlid,nvl(tl.OFFID,'') OFFID,
        nvl(CFB.shortname,'') bankid ,af.corebank,decode(af.bankname,'---',cspks_system.fn_get_sysvar('SYSTEM','COMPANYSHORTNAME'),af.bankname) bankname,ci.trdesc
        FROM vw_tllog_all TL,afmast af,cfmast cf ,tltx, tlprofiles mk,tlprofiles ck,
         vw_citran_gen ci,
         lnmast ln,lntype , CFMAST CFB
        where tl.msgacct=af.acctno and af.custid = cf.custid
        and tltx.tltxcd = tl.tltxcd
        and af.ALTERNATEACCT like v_strALTERNATEACCT
        and  tl.tlid = mk.tlid(+)
        and  tl.OFFID =ck.tlid(+)
        and tl.txnum= ci.txnum
        and tl.txdate = ci.txdate
        and ci.ref = ln.acctno and ci.field ='BALANCE'
        AND LN.actype= LNTYPE.actype
        AND LN.custbank = CFB.custid(+)
        and tl.tltxcd in ('5540','5566','5567')
        --and decode (V_STRTYPEDATE,'002',TL.busdate,TL.txdate)>=to_date(F_DATE,'DD/MM/YYYY')
        --AND decode (V_STRTYPEDATE,'002',TL.busdate,TL.txdate)<=to_date(T_DATE,'DD/MM/YYYY')
        and TL.busdate  >=to_date(F_DATE,'DD/MM/YYYY')
        and TL.busdate  <=to_date(T_DATE,'DD/MM/YYYY')
        AND TL.TLTXCD LIKE V_STRTLTXCD
        and  nvl(tl.brid,V_STRBRID) like V_STRBRID
        AND NVL( TL.TLID,'-') LIKE V_STRMAKER
        AND NVL( TL.OFFID,'-') LIKE V_STRCHECKER
        AND AF.COREBANK LIKE V_STRCOREBANK
        AND CF.custodycd LIKE V_STRPV_CUSTODYCD
        AND AF.acctno LIKE V_STRPV_AFACCTNO
        --and exists (select gu.grpid from tlgrpusers gu where af.careby = gu.grpid and gu.tlid = V_STRTLID )

        union
        SELECT  af.careby,  tl.tltxcd ,tltx.txdesc ,tl.txnum,tl.busdate ,tl.txdate,cf.custodycd,af.acctno, '' custodycdc,'' acctnoc,tl.msgamt amt,nvl(mk.tlname,'') mk,nvl(ck.tlname,'')  ck,nvl(tl.brid,'') brid,nvl(tl.tlid,'') tlid,nvl(tl.OFFID,'') OFFID,
        nvl(CFB.shortname,'') bankid ,af.corebank,decode(af.bankname,'---',cspks_system.fn_get_sysvar('SYSTEM','COMPANYSHORTNAME'),af.bankname) bankname, tl.txdesc trdesc
        FROM vw_tllog_all TL,afmast af,cfmast cf ,tltx, tlprofiles mk,tlprofiles ck,  vw_tllogfld_all tlfld, lnmast ln,lntype , CFMAST CFB
        where tl.msgacct=af.acctno and af.custid = cf.custid
        and tltx.tltxcd = tl.tltxcd
        and  tl.tlid = mk.tlid(+)
        and  tl.OFFID =ck.tlid(+)
        and tl.txnum= tlfld.txnum
        and tl.txdate = tlfld.txdate
        and tlfld.fldcd ='21'
        and af.ALTERNATEACCT like v_strALTERNATEACCT
        and tlfld.cvalue = ln.acctno(+)
        AND LN.actype= LNTYPE.actype
        AND LN.custbank = CFB.custid(+)
        AND LN.actype= LNTYPE.actype
        AND LN.custbank = CFB.custid(+)
        and tl.tltxcd ='2674'
        --and decode (V_STRTYPEDATE,'002',TL.busdate,TL.txdate)>=to_date(F_DATE,'DD/MM/YYYY')
        --AND decode (V_STRTYPEDATE,'002',TL.busdate,TL.txdate)<=to_date(T_DATE,'DD/MM/YYYY')
        and TL.busdate  >=to_date(F_DATE,'DD/MM/YYYY')
        and TL.busdate  <=to_date(T_DATE,'DD/MM/YYYY')
        AND TL.TLTXCD LIKE V_STRTLTXCD
        and  nvl(tl.brid,V_STRBRID) like V_STRBRID
        AND NVL( TL.TLID,'-') LIKE V_STRMAKER
        AND NVL( TL.OFFID,'-') LIKE V_STRCHECKER
        AND AF.COREBANK LIKE V_STRCOREBANK
        AND CF.custodycd LIKE V_STRPV_CUSTODYCD
        AND AF.acctno LIKE V_STRPV_AFACCTNO
        --and exists (select gu.grpid from tlgrpusers gu where af.careby = gu.grpid and gu.tlid = V_STRTLID )

        union
        SELECT af.careby,  tl.tltxcd   tltxcd ,tltx.txdesc ,tl.txnum,tl.busdate ,tl.txdate,cf.custodycd,af.acctno, '' custodycdc,'' acctnoc,ci.namt amt,nvl(mk.tlname,'') mk,nvl(ck.tlname,'')  ck,nvl(tl.brid,'') brid,nvl(tl.tlid,'') tlid,nvl(tl.OFFID,'') OFFID,
        ''bankid,af.corebank,decode(af.bankname,'---',cspks_system.fn_get_sysvar('SYSTEM','COMPANYSHORTNAME'),af.bankname) bankname,CI.trdesc
        FROM vw_tllog_all TL,afmast af,cfmast cf ,tltx, tlprofiles mk,tlprofiles ck,
         vw_citran_gen   ci
        where ci.acctno=af.acctno and af.custid = cf.custid
        and tltx.tltxcd = tl.tltxcd
        and  tl.tlid = mk.tlid(+)
        and  tl.OFFID =ck.tlid(+)
        and af.ALTERNATEACCT like v_strALTERNATEACCT
        and tl.txdate = ci.txdate
        and tl.txnum = ci.txnum
        and tl.tltxcd  IN ('0088','1670','1610','1600','1620','1137','1138','3384') --chaunh add 3384
        and ci.field ='BALANCE'
        --and decode (V_STRTYPEDATE,'002',TL.busdate,TL.txdate)>=to_date(F_DATE,'DD/MM/YYYY')
        --AND decode (V_STRTYPEDATE,'002',TL.busdate,TL.txdate)<=to_date(T_DATE,'DD/MM/YYYY')
        and TL.busdate  >=to_date(F_DATE,'DD/MM/YYYY')
        and TL.busdate  <=to_date(T_DATE,'DD/MM/YYYY')
        AND TL.TLTXCD LIKE V_STRTLTXCD
        and  nvl(tl.brid,V_STRBRID) like V_STRBRID
        AND NVL( TL.TLID,'-') LIKE V_STRMAKER
        AND NVL( TL.OFFID,'-') LIKE V_STRCHECKER
        AND AF.COREBANK LIKE V_STRCOREBANK
        AND CF.custodycd LIKE V_STRPV_CUSTODYCD
        AND AF.acctno LIKE V_STRPV_AFACCTNO
        --and exists (select gu.grpid from tlgrpusers gu where af.careby = gu.grpid and gu.tlid = V_STRTLID )
        )a where exists (select gu.grpid from tlgrpusers gu where a.careby = gu.grpid and gu.tlid = V_STRTLID )
        ORDER BY A.TLTXCD ,a.busdate,A.TXNUM
        ;
    else
        OPEN PV_REFCURSOR
        FOR
          select * from (
        select af.careby, tl.tltxcd,tltx.txdesc ,tl.txnum,tl.busdate ,tl.txdate,cf.custodycd,af.acctno, cfc.custodycd custodycdc,afc.acctno acctnoc,tl.msgamt amt,nvl(mk.tlname,'') mk,nvl(ck.tlname,'')  ck,nvl(tl.brid,'') brid,nvl(tl.tlid,'') tlid,nvl(tl.OFFID,'') OFFID,
        ''bankid,af.corebank,decode(af.bankname,'---',cspks_system.fn_get_sysvar('SYSTEM','COMPANYSHORTNAME'),af.bankname) bankname,ci.trdesc
        from vw_tllog_all TL ,vw_citran_gen ci,afmast af,cfmast cf, afmast afc,cfmast cfc ,tltx  , tlprofiles mk,tlprofiles ck
        where tl.txnum =ci.txnum and tl.txdate =ci.txdate and ci.acctno= af.acctno and cf.custid =af.custid
        and ci.ref =afc.acctno and afc.custid =cfc.custid
        and tltx.tltxcd = tl.tltxcd
        and  tl.tlid = mk.tlid(+)
        and  tl.OFFID =ck.tlid(+)
        and tl.tltxcd in ('1120','1130','1134') and ci.field ='BALANCE'
        --and decode (V_STRTYPEDATE,'002',TL.busdate,TL.txdate)>=to_date(F_DATE,'DD/MM/YYYY')
        --AND decode (V_STRTYPEDATE,'002',TL.busdate,TL.txdate)<=to_date(T_DATE,'DD/MM/YYYY')
        and TL.txdate  >=to_date(F_DATE,'DD/MM/YYYY')
        and TL.txdate  <=to_date(T_DATE,'DD/MM/YYYY')
        AND TL.TLTXCD LIKE V_STRTLTXCD
        and  nvl(tl.brid,V_STRBRID) like V_STRBRID
        and af.ALTERNATEACCT like v_strALTERNATEACCT
        AND NVL( TL.TLID,'-') LIKE V_STRMAKER
        AND NVL( TL.OFFID,'-') LIKE V_STRCHECKER
        AND AF.COREBANK LIKE V_STRCOREBANK
        AND CF.custodycd LIKE V_STRPV_CUSTODYCD
        AND AF.acctno LIKE V_STRPV_AFACCTNO
        --and exists (select gu.grpid from tlgrpusers gu where af.careby = gu.grpid and gu.tlid = V_STRTLID )

        union
        SELECT af.careby, case when  tl.tltxcd in ('3350','3354') then '3342' else  tl.tltxcd end  tltxcd ,tltx.txdesc ,tl.txnum,tl.busdate ,tl.txdate,cf.custodycd,af.acctno, '' custodycdc,'' acctnoc,tl.msgamt amt,nvl(mk.tlname,'') mk,nvl(ck.tlname,'')  ck,nvl(tl.brid,'') brid,nvl(tl.tlid,'') tlid,nvl(tl.OFFID,'') OFFID,
        ''bankid,af.corebank,decode(af.bankname,'---',cspks_system.fn_get_sysvar('SYSTEM','COMPANYSHORTNAME'),af.bankname) bankname , tl.txdesc trdesc
        FROM vw_tllog_all TL,afmast af,cfmast cf ,tltx, tlprofiles mk,tlprofiles ck
        where substr(tl.msgacct,0,10)=af.acctno and af.custid = cf.custid
        and tltx.tltxcd = tl.tltxcd
        and  tl.tlid = mk.tlid(+)
        and af.ALTERNATEACCT like v_strALTERNATEACCT
        and  tl.OFFID =ck.tlid(+)
        and tl.tltxcd in ('1140','1100','1107','1101'
        ,'1104','1108','1111','1114','1104','1112','1145','1144'
        ,'1123','1124','1126','1127','1162','1180','1182','6613','1105','1198','1199','8866'
        ,'8856','0066','8889','8894','8851','5541','3386') --Chaunh bo 3384
        --and decode (V_STRTYPEDATE,'002',TL.busdate,TL.txdate)>=to_date(F_DATE,'DD/MM/YYYY')
        --AND decode (V_STRTYPEDATE,'002',TL.busdate,TL.txdate)<=to_date(T_DATE,'DD/MM/YYYY')
        and TL.txdate  >=to_date(F_DATE,'DD/MM/YYYY')
        and TL.txdate  <=to_date(T_DATE,'DD/MM/YYYY')
        AND TL.TLTXCD LIKE V_STRTLTXCD
        AND TL.TLTXCD LIKE V_STRTLTXCD
        and  nvl(tl.brid,V_STRBRID) like V_STRBRID
        AND NVL( TL.TLID,'-') LIKE V_STRMAKER
        AND NVL( TL.OFFID,'-') LIKE V_STRCHECKER
        AND AF.COREBANK LIKE V_STRCOREBANK
        AND CF.custodycd LIKE V_STRPV_CUSTODYCD
        AND AF.acctno LIKE V_STRPV_AFACCTNO
        --and exists (select gu.grpid from tlgrpusers gu where af.careby = gu.grpid and gu.tlid = V_STRTLID )
        union
        SELECT   af.careby, tl.tltxcd||'T'|| '0' tltxcd ,tltx.txdesc ,tl.txnum,tl.busdate ,tl.txdate,cf.custodycd,af.acctno, '' custodycdc,'' acctnoc,tl.msgamt amt,nvl(mk.tlname,'') mk,nvl(ck.tlname,'')  ck,nvl(tl.brid,'') brid,nvl(tl.tlid,'') tlid,nvl(tl.OFFID,'') OFFID,
        ''bankid,af.corebank,decode(af.bankname,'---',cspks_system.fn_get_sysvar('SYSTEM','COMPANYSHORTNAME'),af.bankname) bankname,ci.trdesc
        FROM vw_tllog_all TL,afmast af,cfmast cf ,tltx, tlprofiles mk,tlprofiles ck,vw_citran_gen CI, vw_stschd_all sts
        where tl.msgacct=af.acctno and af.custid = cf.custid
        and tltx.tltxcd = tl.tltxcd
        and  tl.tlid = mk.tlid(+)
        and  tl.OFFID =ck.tlid(+)
        and af.ALTERNATEACCT like v_strALTERNATEACCT
        AND TL.TXDATE = CI.TXDATE
        AND TL.TXNUM = CI.TXNUM
        AND CI.field ='BALANCE'
        and tl.tltxcd ='8855'
        and ci.ref = sts.orgorderid
        and sts.duetype ='SM'
        --and decode (V_STRTYPEDATE,'002',TL.busdate,TL.txdate)>=to_date(F_DATE,'DD/MM/YYYY')
        --AND decode (V_STRTYPEDATE,'002',TL.busdate,TL.txdate)<=to_date(T_DATE,'DD/MM/YYYY')
        and TL.txdate  >=to_date(F_DATE,'DD/MM/YYYY')
        and TL.txdate  <=to_date(T_DATE,'DD/MM/YYYY')
        AND TL.TLTXCD LIKE V_STRTLTXCD
        AND TL.TLTXCD LIKE V_STRTLTXCD
        and  nvl(tl.brid,V_STRBRID) like V_STRBRID
        AND NVL( TL.TLID,'-') LIKE V_STRMAKER
        AND NVL( TL.OFFID,'-') LIKE V_STRCHECKER
        AND AF.COREBANK LIKE V_STRCOREBANK
        AND CF.custodycd LIKE V_STRPV_CUSTODYCD
        AND AF.acctno LIKE V_STRPV_AFACCTNO
        --and exists (select gu.grpid from tlgrpusers gu where af.careby = gu.grpid and gu.tlid = V_STRTLID )
        union
        SELECT af.careby, case when  tl.tltxcd in ('3350','3354') then '3342' else  tl.tltxcd end  tltxcd ,tltx.txdesc ,tl.txnum,tl.busdate ,tl.txdate,cf.custodycd,af.acctno, '' custodycdc,'' acctnoc,tl.msgamt amt,nvl(mk.tlname,'') mk,nvl(ck.tlname,'')  ck,nvl(tl.brid,'') brid,nvl(tl.tlid,'') tlid,nvl(tl.OFFID,'') OFFID,
        ''bankid,af.corebank,decode(af.bankname,'---',cspks_system.fn_get_sysvar('SYSTEM','COMPANYSHORTNAME'),af.bankname) bankname,ci.trdesc
        FROM vw_tllog_all TL,afmast af,cfmast cf ,tltx, tlprofiles mk,tlprofiles ck,vw_citran_gen CI
        where tl.msgacct=af.acctno and af.custid = cf.custid
        and tltx.tltxcd = tl.tltxcd
        and  tl.tlid = mk.tlid(+)
        and  tl.OFFID =ck.tlid(+)
        and af.ALTERNATEACCT like v_strALTERNATEACCT
        AND TL.TXDATE = CI.TXDATE
        AND TL.TXNUM = CI.TXNUM
        AND CI.TXCD ='0012'
        and tl.tltxcd IN('3350','3354')
        --and decode (V_STRTYPEDATE,'002',TL.busdate,TL.txdate)>=to_date(F_DATE,'DD/MM/YYYY')
        --AND decode (V_STRTYPEDATE,'002',TL.busdate,TL.txdate)<=to_date(T_DATE,'DD/MM/YYYY')
        and TL.txdate  >=to_date(F_DATE,'DD/MM/YYYY')
        and TL.txdate  <=to_date(T_DATE,'DD/MM/YYYY')
        AND TL.TLTXCD LIKE V_STRTLTXCD
        AND case when  tl.tltxcd in ('3350','3354') then '3342' else  tl.tltxcd end  LIKE V_STRTLTXCD
        and  nvl(tl.brid,V_STRBRID) like V_STRBRID
        AND NVL( TL.TLID,'-') LIKE V_STRMAKER
        AND NVL( TL.OFFID,'-') LIKE V_STRCHECKER
        AND AF.COREBANK LIKE V_STRCOREBANK
        AND CF.custodycd LIKE V_STRPV_CUSTODYCD
        AND AF.acctno LIKE V_STRPV_AFACCTNO
        --and exists (select gu.grpid from tlgrpusers gu where af.careby = gu.grpid and gu.tlid = V_STRTLID )
        UNION
        SELECT af.careby,  tl.tltxcd ,tltx.txdesc ,tl.txnum,tl.busdate ,tl.txdate,cf.custodycd,af.acctno, '' custodycdc,'' acctnoc,CI.NAMT amt,nvl(mk.tlname,'') mk,nvl(ck.tlname,'')  ck,nvl(tl.brid,'') brid,nvl(tl.tlid,'') tlid,nvl(tl.OFFID,'') OFFID,
        ''bankid,af.corebank,decode(af.bankname,'---',cspks_system.fn_get_sysvar('SYSTEM','COMPANYSHORTNAME'),af.bankname) bankname,ci.trdesc
        FROM vw_tllog_all TL,afmast af,cfmast cf ,tltx, tlprofiles mk,tlprofiles ck,vw_citran_gen CI
        where tl.msgacct=af.acctno and af.custid = cf.custid
        and tltx.tltxcd = tl.tltxcd
        and  tl.tlid = mk.tlid(+)
        and  tl.OFFID =ck.tlid(+)
        AND TL.TXDATE = CI.TXDATE
        and af.ALTERNATEACCT like v_strALTERNATEACCT
        AND TL.TXNUM = CI.TXNUM
        AND CI.field ='BALANCE'
        and tl.tltxcd in('1153','8865','1139')
        --and decode (V_STRTYPEDATE,'002',TL.busdate,TL.txdate)>=to_date(F_DATE,'DD/MM/YYYY')
        --AND decode (V_STRTYPEDATE,'002',TL.busdate,TL.txdate)<=to_date(T_DATE,'DD/MM/YYYY')
        and TL.txdate  >=to_date(F_DATE,'DD/MM/YYYY')
        and TL.txdate  <=to_date(T_DATE,'DD/MM/YYYY')
        AND TL.TLTXCD LIKE V_STRTLTXCD
        AND TL.TLTXCD LIKE V_STRTLTXCD
        and  nvl(tl.brid,V_STRBRID) like V_STRBRID
        AND NVL( TL.TLID,'-') LIKE V_STRMAKER
        AND NVL( TL.OFFID,'-') LIKE V_STRCHECKER
        AND AF.COREBANK LIKE V_STRCOREBANK
        AND CF.custodycd LIKE V_STRPV_CUSTODYCD
        AND AF.acctno LIKE V_STRPV_AFACCTNO
        --and exists (select gu.grpid from tlgrpusers gu where af.careby = gu.grpid and gu.tlid = V_STRTLID )

        --1178
        union
        SELECT af.careby, tl.tltxcd,tltx.txdesc ,tl.txnum,tl.busdate ,tl.txdate,cf.custodycd,af.acctno, '' custodycdc,'' acctnoc,ads.amt amt,nvl(mk.tlname,'') mk,nvl(ck.tlname,'')  ck,nvl(tl.brid,'') brid,nvl(tl.tlid,'') tlid,nvl(tl.OFFID,'') OFFID,
        '' bankid,af.corebank,decode(af.bankname,'---',cspks_system.fn_get_sysvar('SYSTEM','COMPANYSHORTNAME'),af.bankname) bankname, tl.txdesc trdesc
        FROM vw_tllog_all TL,adschd ads ,afmast af,cfmast cf,tltx, tlprofiles mk,tlprofiles ck
        where tl.msgamt =ads.autoid
        and TL.msgacct = af.acctno and af.custid = cf.custid
        and tltx.tltxcd = tl.tltxcd
        and  tl.tlid = mk.tlid(+)
        and af.ALTERNATEACCT like v_strALTERNATEACCT
        and  tl.OFFID =ck.tlid(+)
        and tl.tltxcd in ('1178')
        --and decode (V_STRTYPEDATE,'002',TL.busdate,TL.txdate)>=to_date(F_DATE,'DD/MM/YYYY')
        --AND decode (V_STRTYPEDATE,'002',TL.busdate,TL.txdate)<=to_date(T_DATE,'DD/MM/YYYY')
        and TL.txdate  >=to_date(F_DATE,'DD/MM/YYYY')
        and TL.txdate  <=to_date(T_DATE,'DD/MM/YYYY')
        AND TL.TLTXCD LIKE V_STRTLTXCD
        AND TL.TLTXCD LIKE V_STRTLTXCD
        and  nvl(tl.brid,V_STRBRID) like V_STRBRID
        AND NVL( TL.TLID,'-') LIKE V_STRMAKER
        AND NVL( TL.OFFID,'-') LIKE V_STRCHECKER
        AND AF.COREBANK LIKE V_STRCOREBANK
        AND CF.custodycd LIKE V_STRPV_CUSTODYCD
        AND AF.acctno LIKE V_STRPV_AFACCTNO
        --and exists (select gu.grpid from tlgrpusers gu where af.careby = gu.grpid and gu.tlid = V_STRTLID )
        --nhom bank
        --'1131','1132','1136','1141'
        union

        SELECT  af.careby,  tl.tltxcd ,tltx.txdesc ,tl.txnum,tl.busdate ,tl.txdate,cf.custodycd,af.acctno, '' custodycdc,'' acctnoc,tl.msgamt amt,nvl(mk.tlname,'') mk,nvl(ck.tlname,'')  ck,nvl(tl.brid,'') brid,nvl(tl.tlid,'') tlid,nvl(tl.OFFID,'') OFFID
        ,nvl(bank.fullname,' ') bankid,af.corebank,decode(af.bankname,'---',cspks_system.fn_get_sysvar('SYSTEM','COMPANYSHORTNAME'),af.bankname) bankname, tl.txdesc trdesc
        FROM vw_tllog_all TL,afmast af,cfmast cf ,tltx, tlprofiles mk,tlprofiles ck,vw_tllogfld_all tlfld,banknostro bank
        where tl.msgacct=af.acctno and af.custid = cf.custid
        and tltx.tltxcd = tl.tltxcd
        and  tl.tlid = mk.tlid(+)
        and af.ALTERNATEACCT like v_strALTERNATEACCT
        and  tl.OFFID =ck.tlid(+)
        and tlfld.txdate = tl.txdate
        and tlfld.txnum = tl.txnum
        and tlfld.fldcd='02'
        and tlfld.cvalue=bank.shortname(+)
        and tl.tltxcd in ('1131','1132','1136','1141')
        --and decode (V_STRTYPEDATE,'002',TL.busdate,TL.txdate)>=to_date(F_DATE,'DD/MM/YYYY')
        --AND decode (V_STRTYPEDATE,'002',TL.busdate,TL.txdate)<=to_date(T_DATE,'DD/MM/YYYY')
        and TL.txdate  >=to_date(F_DATE,'DD/MM/YYYY')
        and TL.txdate  <=to_date(T_DATE,'DD/MM/YYYY')
        AND TL.TLTXCD LIKE V_STRTLTXCD
        AND TL.TLTXCD LIKE V_STRTLTXCD
        and  nvl(tl.brid,V_STRBRID) like V_STRBRID
        AND NVL( TL.TLID,'-') LIKE V_STRMAKER
        AND NVL( TL.OFFID,'-') LIKE V_STRCHECKER
        AND AF.COREBANK LIKE V_STRCOREBANK
        AND CF.custodycd LIKE V_STRPV_CUSTODYCD
        AND AF.acctno LIKE V_STRPV_AFACCTNO
        --and exists (select gu.grpid from tlgrpusers gu where af.careby = gu.grpid and gu.tlid = V_STRTLID )
        -- dfgroup
        union
        SELECT af.careby, tl.tltxcd,tltx.txdesc ,tl.txnum,tl.busdate ,tl.txdate,cf.custodycd,af.acctno, '' custodycdc,'' acctnoc,CI.NAMT amt,nvl(mk.tlname,'') mk,nvl(ck.tlname,'')  ck,nvl(tl.brid,'') brid,nvl(tl.tlid,'') tlid,nvl(tl.OFFID,'') OFFID,
        nvl(CFB.shortname,'') bankid ,af.corebank,decode(af.bankname,'---',cspks_system.fn_get_sysvar('SYSTEM','COMPANYSHORTNAME'),af.bankname) bankname, CI.trdesc trdesc
        FROM vw_tllog_all TL,dfgroup dfg ,afmast af,cfmast cf,tltx, tlprofiles mk,tlprofiles ck,
         lnmast ln,lntype , CFMAST CFB,vw_citran_gen CI
        where tl.msgacct= dfg.groupid and dfg.afacctno = af.acctno and af.custid = cf.custid
        and tltx.tltxcd = tl.tltxcd
        and dfg.lnacctno =ln.acctno
        and af.ALTERNATEACCT like v_strALTERNATEACCT
        and ln.actype =lntype.actype
        AND LN.actype= LNTYPE.actype
        AND LN.custbank = CFB.custid(+)
        and tl.tlid = mk.tlid(+)
        and tl.OFFID =ck.tlid(+)
        AND CI.ref =LN.acctno
        AND CI.txnum = TL.txnum
        AND CI.txdate =TL.txdate
        and tl.tltxcd in ('2646','2648','2665','2636')
        AND CI.field ='BALANCE'
        --and decode (V_STRTYPEDATE,'002',TL.busdate,TL.txdate)>=to_date(F_DATE,'DD/MM/YYYY')
        --AND decode (V_STRTYPEDATE,'002',TL.busdate,TL.txdate)<=to_date(T_DATE,'DD/MM/YYYY')
        and TL.txdate  >=to_date(F_DATE,'DD/MM/YYYY')
        and TL.txdate  <=to_date(T_DATE,'DD/MM/YYYY')
        AND TL.TLTXCD LIKE V_STRTLTXCD
        AND TL.TLTXCD LIKE V_STRTLTXCD
        and  nvl(tl.brid,V_STRBRID) like V_STRBRID
        AND NVL( TL.TLID,'-') LIKE V_STRMAKER
        AND NVL( TL.OFFID,'-') LIKE V_STRCHECKER
        AND AF.COREBANK LIKE V_STRCOREBANK
        AND CF.custodycd LIKE V_STRPV_CUSTODYCD
        AND AF.acctno LIKE V_STRPV_AFACCTNO
        --and exists (select gu.grpid from tlgrpusers gu where af.careby = gu.grpid and gu.tlid = V_STRTLID )

        union
        SELECT  af.careby,  tl.tltxcd ,tltx.txdesc ,tl.txnum,tl.busdate ,tl.txdate,cf.custodycd,af.acctno, '' custodycdc,'' acctnoc,ci.NAMT amt,nvl(mk.tlname,'') mk,nvl(ck.tlname,'')  ck,nvl(tl.brid,'') brid,nvl(tl.tlid,'') tlid,nvl(tl.OFFID,'') OFFID,
        nvl(CFB.shortname,'') bankid ,af.corebank,decode(af.bankname,'---',cspks_system.fn_get_sysvar('SYSTEM','COMPANYSHORTNAME'),af.bankname) bankname,ci.trdesc
        FROM vw_tllog_all TL,afmast af,cfmast cf ,tltx, tlprofiles mk,tlprofiles ck,
         vw_citran_gen ci,
         lnmast ln,lntype , CFMAST CFB
        where tl.msgacct=af.acctno and af.custid = cf.custid
        and tltx.tltxcd = tl.tltxcd
        and  tl.tlid = mk.tlid(+)
        and af.ALTERNATEACCT like v_strALTERNATEACCT
        and  tl.OFFID =ck.tlid(+)
        and tl.txnum= ci.txnum
        and tl.txdate = ci.txdate
        and ci.ref = ln.acctno and ci.field ='BALANCE'
        AND LN.actype= LNTYPE.actype
        AND LN.custbank = CFB.custid(+)
        and tl.tltxcd in ('5540','5566','5567')
        --and decode (V_STRTYPEDATE,'002',TL.busdate,TL.txdate)>=to_date(F_DATE,'DD/MM/YYYY')
        --AND decode (V_STRTYPEDATE,'002',TL.busdate,TL.txdate)<=to_date(T_DATE,'DD/MM/YYYY')
        and TL.txdate  >=to_date(F_DATE,'DD/MM/YYYY')
        and TL.txdate  <=to_date(T_DATE,'DD/MM/YYYY')
        AND TL.TLTXCD LIKE V_STRTLTXCD
        AND TL.TLTXCD LIKE V_STRTLTXCD
        and  nvl(tl.brid,V_STRBRID) like V_STRBRID
        AND NVL( TL.TLID,'-') LIKE V_STRMAKER
        AND NVL( TL.OFFID,'-') LIKE V_STRCHECKER
        AND AF.COREBANK LIKE V_STRCOREBANK
        AND CF.custodycd LIKE V_STRPV_CUSTODYCD
        AND AF.acctno LIKE V_STRPV_AFACCTNO
        --and exists (select gu.grpid from tlgrpusers gu where af.careby = gu.grpid and gu.tlid = V_STRTLID )

        union
        SELECT  af.careby,  tl.tltxcd ,tltx.txdesc ,tl.txnum,tl.busdate ,tl.txdate,cf.custodycd,af.acctno, '' custodycdc,'' acctnoc,tl.msgamt amt,nvl(mk.tlname,'') mk,nvl(ck.tlname,'')  ck,nvl(tl.brid,'') brid,nvl(tl.tlid,'') tlid,nvl(tl.OFFID,'') OFFID,
        nvl(CFB.shortname,'') bankid ,af.corebank,decode(af.bankname,'---',cspks_system.fn_get_sysvar('SYSTEM','COMPANYSHORTNAME'),af.bankname) bankname, tl.txdesc trdesc
        FROM vw_tllog_all TL,afmast af,cfmast cf ,tltx, tlprofiles mk,tlprofiles ck,  vw_tllogfld_all tlfld, lnmast ln,lntype , CFMAST CFB
        where tl.msgacct=af.acctno and af.custid = cf.custid
        and tltx.tltxcd = tl.tltxcd
        and  tl.tlid = mk.tlid(+)
        and  tl.OFFID =ck.tlid(+)
        and af.ALTERNATEACCT like v_strALTERNATEACCT
        and tl.txnum= tlfld.txnum
        and tl.txdate = tlfld.txdate
        and tlfld.fldcd ='21'
        and tlfld.cvalue = ln.acctno(+)
        AND LN.actype= LNTYPE.actype
        AND LN.custbank = CFB.custid(+)
        AND LN.actype= LNTYPE.actype
        AND LN.custbank = CFB.custid(+)
        and tl.tltxcd ='2674'
        --and decode (V_STRTYPEDATE,'002',TL.busdate,TL.txdate)>=to_date(F_DATE,'DD/MM/YYYY')
        --AND decode (V_STRTYPEDATE,'002',TL.busdate,TL.txdate)<=to_date(T_DATE,'DD/MM/YYYY')
        and TL.txdate  >=to_date(F_DATE,'DD/MM/YYYY')
        and TL.txdate  <=to_date(T_DATE,'DD/MM/YYYY')
        AND TL.TLTXCD LIKE V_STRTLTXCD
        AND TL.TLTXCD LIKE V_STRTLTXCD
        and  nvl(tl.brid,V_STRBRID) like V_STRBRID
        AND NVL( TL.TLID,'-') LIKE V_STRMAKER
        AND NVL( TL.OFFID,'-') LIKE V_STRCHECKER
        AND AF.COREBANK LIKE V_STRCOREBANK
        AND CF.custodycd LIKE V_STRPV_CUSTODYCD
        AND AF.acctno LIKE V_STRPV_AFACCTNO
        --and exists (select gu.grpid from tlgrpusers gu where af.careby = gu.grpid and gu.tlid = V_STRTLID )

        union
        SELECT af.careby,  tl.tltxcd   tltxcd ,tltx.txdesc ,tl.txnum,tl.busdate ,tl.txdate,cf.custodycd,af.acctno, '' custodycdc,'' acctnoc,ci.namt amt,nvl(mk.tlname,'') mk,nvl(ck.tlname,'')  ck,nvl(tl.brid,'') brid,nvl(tl.tlid,'') tlid,nvl(tl.OFFID,'') OFFID,
        ''bankid,af.corebank,decode(af.bankname,'---',cspks_system.fn_get_sysvar('SYSTEM','COMPANYSHORTNAME'),af.bankname) bankname,CI.trdesc
        FROM vw_tllog_all TL,afmast af,cfmast cf ,tltx, tlprofiles mk,tlprofiles ck,
         vw_citran_gen   ci
        where ci.acctno=af.acctno and af.custid = cf.custid
        and tltx.tltxcd = tl.tltxcd
        and  tl.tlid = mk.tlid(+)
        and  tl.OFFID =ck.tlid(+)
        and tl.txdate = ci.txdate
        and af.ALTERNATEACCT like v_strALTERNATEACCT
        and tl.txnum = ci.txnum
        and tl.tltxcd  IN ('0088','1670','1610','1600','1620','1137','1138','3384') --chaunh add 3384
        and ci.field ='BALANCE'
        --and decode (V_STRTYPEDATE,'002',TL.busdate,TL.txdate)>=to_date(F_DATE,'DD/MM/YYYY')
        --AND decode (V_STRTYPEDATE,'002',TL.busdate,TL.txdate)<=to_date(T_DATE,'DD/MM/YYYY')
        and TL.txdate  >=to_date(F_DATE,'DD/MM/YYYY')
        and TL.txdate  <=to_date(T_DATE,'DD/MM/YYYY')
        AND TL.TLTXCD LIKE V_STRTLTXCD
        AND TL.TLTXCD LIKE V_STRTLTXCD
        and  nvl(tl.brid,V_STRBRID) like V_STRBRID
        AND NVL( TL.TLID,'-') LIKE V_STRMAKER
        AND NVL( TL.OFFID,'-') LIKE V_STRCHECKER
        AND AF.COREBANK LIKE V_STRCOREBANK
        AND CF.custodycd LIKE V_STRPV_CUSTODYCD
        AND AF.acctno LIKE V_STRPV_AFACCTNO
        --and exists (select gu.grpid from tlgrpusers gu where af.careby = gu.grpid and gu.tlid = V_STRTLID )
        )a where exists (select gu.grpid from tlgrpusers gu where a.careby = gu.grpid and gu.tlid = V_STRTLID )
        ORDER BY A.TLTXCD ,a.busdate,A.TXNUM
        ;
    end if;

END IF ;


EXCEPTION
    WHEN OTHERS
   THEN
      RETURN;
END; -- Procedure
 
 
 
 
 
 
 
/
