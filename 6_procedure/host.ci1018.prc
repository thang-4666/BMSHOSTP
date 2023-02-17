SET DEFINE OFF;
CREATE OR REPLACE PROCEDURE ci1018 (
   PV_REFCURSOR     IN OUT   PKG_REPORT.REF_CURSOR,
   OPT              IN       VARCHAR2,
   PV_BRID             IN       VARCHAR2,
   TLGOUPS        IN       VARCHAR2,
   TLSCOPE        IN       VARCHAR2,
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

    V_STROPTION     VARCHAR2 (10);            -- A: ALL; B: BRANCH; S: SUB-BRANCH

    V_STRTLTXCD         VARCHAR (900);
    V_STRSYMBOL         VARCHAR (20);
    V_STRTYPEDATE       VARCHAR(5);
    V_STRCHECKER        VARCHAR(20);
    V_STRMAKER          VARCHAR(20);
    V_STRCOREBANK          VARCHAR(20);
    V_STROPT       VARCHAR2 (50);            -- A: ALL; B: BRANCH; S: SUB-BRANCH
    V_STRBRID      VARCHAR2 (100);                   -- USED WHEN V_NUMOPTION > 0
    V_INBRID       VARCHAR2 (20);
    v_strIBRID     VARCHAR2 (20);
    vn_BRID        varchar2(50);
    V_STRPV_CUSTODYCD   varchar2(50);
    V_STRPV_AFACCTNO   varchar2(50);
    V_STRTLID           VARCHAR2(10);
    v_STRALTERNATEACCT varchar2(10);
    v_time          number;
    v_currdate      date;

    V_SYSNAME     VARCHAR2(20);
   -- Declare program variables as shown above
BEGIN
    -- GET REPORT'S PARAMETERS
   V_STRTLID:= TLID;

 V_STROPT := upper(OPT);
    V_INBRID := PV_BRID;
    if(V_STROPT = 'A') then
        V_STRBRID := '%';
    else
        if(V_STROPT = 'B') then
            select br.brid into V_STRBRID from brgrp br where  br.brid = V_INBRID;
          --  V_STRBRID := substr(BRID,1,2) || '__' ;
        else
            V_STRBRID := PV_BRID;
        end if;
    end if;

  V_STRTYPEDATE := TYPEDATE;
    select to_number(to_char(sysdate,'HH24'))  into v_time
    from dual;
    v_time := nvl(v_time,0);

    select TO_DATE(VARVALUE,'DD/MM/RRRR') INTO v_currdate from sysvar where varname = 'CURRDATE';

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

 SELECT varvalue INTO V_SYSNAME  FROM sysvar WHERE varname = 'COMPANYSHORTNAME' AND grname = 'SYSTEM';

IF (v_time >= 16 AND v_time <= 15 ) THEN
    IF   TYPEBRID ='002' THEN
        if V_STRTYPEDATE='002' then

            OPEN PV_REFCURSOR
              FOR


            select  A.careby, A.tltxcd,A.txdesc ,A.txnum,A.busdate ,A.txdate, CF.CUSTODYCD,A.acctno,
            A.custodycdc,A.acctnoc,A.amt,A.mk,A.ck,
            CF.brid,A.tlid,A.OFFID, A.bankid,A.corebank ,A.bankname,A.trdesc
              from
             (SELECT * FROM CFMAST WHERE FNC_VALIDATE_SCOPE(BRID, CAREBY, TLSCOPE, pv_BRID, TLGOUPS)=0) cf,
             (
            select af.custid, af.careby, tl.tltxcd,tltx.txdesc ,tl.txnum,tl.busdate ,tl.txdate,af.acctno,
            cfc.custodycd custodycdc,afc.acctno acctnoc,tl.msgamt amt,nvl(mk.tlname,'') mk,nvl(ck.tlname,'') ck,
            NVL(AF.BRID,'') brid,nvl(tl.tlid,'') tlid,nvl(tl.OFFID,'') OFFID,
            ''bankid,ci.corebank ,decode(af.bankname,'---',V_SYSNAME,af.bankname) bankname,ci.trdesc
            from tllog TL ,
            (select ci.corebank,ci.autoid,ci.txnum, ci.txdate, ci.acctno, ci.txcd, ci.namt,
                ci.camt, ci.ref, nvl(ci.deltd,'N') deltd, ci.acctref,
                tl.tltxcd, tl.busdate,
                case when tl.tlid ='6868' then trim(tl.txdesc) || ' (Online)' else tl.txdesc end txdesc,
                tl.txtime, tl.brid, tl.tlid, tl.offid, tl.chid,
                ''  dfacctno, ''  old_dfacctno,
                app.txtype, app.field, tl.autoid tllog_autoid,
                case when ci.trdesc is not null
                        then (case when tl.tlid ='6868' then trim(ci.trdesc) || ' (Online)' else ci.trdesc end)
                        else ci.trdesc end trdesc
            from citran ci, tllog tl, afmast af, apptx app
            where ci.txdate = tl.txdate and ci.txnum = tl.txnum
                and ci.acctno = af.acctno
                and ci.txcd = app.txcd and app.apptype = 'CI' and app.txtype in ('D','C')
                and tl.deltd <> 'Y'
                and ci.namt <> 0
        ) ci,afmast af, afmast afc,cfmast cfc ,tltx  , tlprofiles mk,tlprofiles ck
            where tl.txnum =ci.txnum and tl.txdate =ci.txdate and ci.acctno= af.acctno
            and ci.ref =afc.acctno and afc.custid =cfc.custid
            and af.ALTERNATEACCT like v_strALTERNATEACCT
            and tltx.tltxcd = tl.tltxcd
            and  tl.tlid = mk.tlid(+)
            and  tl.OFFID =ck.tlid(+)
            and tl.tltxcd in ('1120','1130','1134') and ci.field ='BALANCE' and ci.txtype='D'
            and TL.busdate  = v_currdate
            AND TL.TLTXCD LIKE V_STRTLTXCD
/*            and  nvl(cf.brid,V_STRBRID) like V_STRBRID
            AND NVL( TL.TLID,'-') LIKE V_STRMAKER
            AND NVL( TL.OFFID,'-') LIKE V_STRCHECKER
            AND ci.corebank  LIKE V_STRCOREBANK
            AND AF.acctno LIKE V_STRPV_AFACCTNO*/

            union

            SELECT af.custid,af.careby, case when  tl.tltxcd in ('3350','3354') then '3342' else  tl.tltxcd end  tltxcd ,
            tltx.txdesc ,tl.txnum,tl.busdate ,tl.txdate,af.acctno, '' custodycdc,'' acctnoc,tl.msgamt amt,
            nvl(mk.tlname,'') mk,nvl(ck.tlname,'')  ck,NVL(AF.BRID,'') brid,nvl(tl.tlid,'') tlid,nvl(tl.OFFID,'') OFFID,
            ''bankid,ci.corebank ,decode(af.bankname,'---',V_SYSNAME,af.bankname) bankname , tl.txdesc trdesc
            FROM tllog TL,afmast af,tltx, tlprofiles mk,tlprofiles ck,citran ci
            where substr(tl.msgacct,0,10)=af.acctno
            and tltx.tltxcd = tl.tltxcd
            and af.ALTERNATEACCT like v_strALTERNATEACCT
            and  tl.tlid = mk.tlid(+)
            and  tl.OFFID =ck.tlid(+)
            and tl.tltxcd in ('1140','1100','1107','1101'
            ,'1104','1108','1111','1114','1104','1112','1145','1144'
            ,'1123','1124','1126','1127','1162','1180','1182','6613','1105','1198','1199','8866','1190','1191'
            ,'8856','0066','8889','8894','8851','5541','1146') --Chaunh bo 3384
            and TL.busdate  = v_currdate
            and tl.txnum = ci.txnum
            and tl.txdate = ci.txdate
            AND  case when  tl.tltxcd in ('3350','3354') then '3342' else  tl.tltxcd end  LIKE V_STRTLTXCD
           /* and  nvl(AF.brid,V_STRBRID) like V_STRBRID
            AND NVL( TL.TLID,'-') LIKE V_STRMAKER
            AND NVL( TL.OFFID,'-') LIKE V_STRCHECKER
            AND ci.corebank  LIKE V_STRCOREBANK
            AND CF.custodycd LIKE V_STRPV_CUSTODYCD
            AND AF.acctno LIKE V_STRPV_AFACCTNO*/
            union
            SELECT af.custid, af.careby,  tl.tltxcd||'T'|| '0'  tltxcd ,tltx.txdesc ,tl.txnum,tl.busdate ,
            tl.txdate,af.acctno, '' custodycdc,'' acctnoc,tl.msgamt amt,nvl(mk.tlname,'') mk,nvl(ck.tlname,'') ck,
            NVL(AF.BRID,'') brid,nvl(tl.tlid,'') tlid,nvl(tl.OFFID,'') OFFID,
            ''bankid,ci.corebank ,decode(af.bankname,'---',V_SYSNAME,af.bankname) bankname,ci.trdesc
            FROM tllog TL,afmast af,Tltx, tlprofiles mk,tlprofiles ck,
            (
                select ci.corebank, ci.autoid, ci.txnum, ci.txdate, ci.acctno, ci.txcd, ci.namt,
                ci.camt, ci.ref, nvl(ci.deltd,'N') deltd, ci.acctref,
                tl.tltxcd, tl.busdate,
                case when tl.tlid ='6868' then trim(tl.txdesc) || ' (Online)' else tl.txdesc end txdesc,
                tl.txtime, tl.brid, tl.tlid, tl.offid, tl.chid,
                ''  dfacctno,
                ''  old_dfacctno,
                app.txtype, app.field, tl.autoid tllog_autoid,
                case when ci.trdesc is not null
                        then (case when tl.tlid ='6868' then trim(ci.trdesc) || ' (Online)' else ci.trdesc end)
                        else ci.trdesc end trdesc
            from citran ci, tllog tl,  afmast af, apptx app
            where ci.txdate = tl.txdate and ci.txnum = tl.txnum
                and ci.acctno = af.acctno
                and ci.txcd = app.txcd and app.apptype = 'CI' and app.txtype in ('D','C')
                and tl.deltd <> 'Y'
                and ci.namt <> 0
            ) CI, stschd sts
            where tl.msgacct=af.acctno
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
            and TL.busdate  = v_currdate
            AND  tl.tltxcd||'T'|| '0'  LIKE V_STRTLTXCD
/*            and  nvl(AF.brid,V_STRBRID) like V_STRBRID
            AND NVL( TL.TLID,'-') LIKE V_STRMAKER
            AND NVL( TL.OFFID,'-') LIKE V_STRCHECKER
            AND ci.corebank  LIKE V_STRCOREBANK
            AND CF.custodycd LIKE V_STRPV_CUSTODYCD
            AND AF.acctno LIKE V_STRPV_AFACCTNO*/
            union
            SELECT af.custid, af.careby, case when  tl.tltxcd in ('3350','3354') then '3342' else  tl.tltxcd end  tltxcd ,
            tltx.txdesc ,tl.txnum,tl.busdate ,tl.txdate,af.acctno, '' custodycdc,'' acctnoc,ci.namt amt,
            nvl(mk.tlname,'') mk,nvl(ck.tlname,'')  ck,NVL(AF.BRID,'') brid,nvl(tl.tlid,'') tlid,nvl(tl.OFFID,'') OFFID,
            ''bankid,ci.corebank ,decode(af.bankname,'---',V_SYSNAME,af.bankname) bankname,ci.trdesc
            FROM tllog TL,afmast af,tltx, tlprofiles mk,tlprofiles ck,
            (
            select ci.corebank, ci.autoid,
                ci.txnum, ci.txdate, ci.acctno, ci.txcd, ci.namt,
                ci.camt, ci.ref, nvl(ci.deltd,'N') deltd, ci.acctref,
                tl.tltxcd, tl.busdate,
                case when tl.tlid ='6868' then trim(tl.txdesc) || ' (Online)' else tl.txdesc end txdesc,
                tl.txtime, tl.brid, tl.tlid, tl.offid, tl.chid,
                ''  dfacctno,
                ''  old_dfacctno,
                app.txtype, app.field, tl.autoid tllog_autoid,
                case when ci.trdesc is not null
                        then (case when tl.tlid ='6868' then trim(ci.trdesc) || ' (Online)' else ci.trdesc end)
                        else ci.trdesc end trdesc
            from citran ci, tllog tl,  afmast af, apptx app
            where ci.txdate = tl.txdate and ci.txnum = tl.txnum
                and ci.acctno = af.acctno
                and ci.txcd = app.txcd and app.apptype = 'CI' and app.txtype in ('D','C')
                and tl.deltd <> 'Y'
                and ci.namt <> 0
            ) CI
            where tl.msgacct=af.acctno
            and tltx.tltxcd = tl.tltxcd
            and af.ALTERNATEACCT like v_strALTERNATEACCT
            and  tl.tlid = mk.tlid(+)
            and  tl.OFFID =ck.tlid(+)
            AND TL.TXDATE = CI.TXDATE
            AND TL.TXNUM = CI.TXNUM
            AND CI.TXCD ='0012'
            and tl.tltxcd IN('3350','3354')
            and TL.busdate  = v_currdate
            AND case when  tl.tltxcd in ('3350','3354') then '3342' else  tl.tltxcd end  LIKE V_STRTLTXCD
/*            and  nvl(AF.brid,V_STRBRID) like V_STRBRID
            AND NVL( TL.TLID,'-') LIKE V_STRMAKER
            AND NVL( TL.OFFID,'-') LIKE V_STRCHECKER
            AND ci.corebank  LIKE V_STRCOREBANK
            AND CF.custodycd LIKE V_STRPV_CUSTODYCD
            AND AF.acctno LIKE V_STRPV_AFACCTNO
*/
            UNION

            SELECT af.custid, af.careby, tl.tltxcd ,tltx.txdesc ,tl.txnum,tl.busdate ,tl.txdate,af.acctno,
             '' custodycdc,'' acctnoc,CI.NAMT amt,nvl(mk.tlname,'') mk,nvl(ck.tlname,'')  ck,NVL(AF.BRID,'') brid,
             nvl(tl.tlid,'') tlid,nvl(tl.OFFID,'') OFFID,
            ''bankid,ci.corebank ,decode(af.bankname,'---',V_SYSNAME,af.bankname) bankname,ci.trdesc
            FROM tllog TL,afmast af,tltx, tlprofiles mk,tlprofiles ck,
            (
                select ci.corebank, ci.autoid,
                ci.txnum, ci.txdate, ci.acctno, ci.txcd, ci.namt,
                ci.camt, ci.ref, nvl(ci.deltd,'N') deltd, ci.acctref,
                tl.tltxcd, tl.busdate,
                case when tl.tlid ='6868' then trim(tl.txdesc) || ' (Online)' else tl.txdesc end txdesc,
                tl.txtime, tl.brid, tl.tlid, tl.offid, tl.chid,
                ''  dfacctno,
                ''  old_dfacctno,
                app.txtype, app.field, tl.autoid tllog_autoid,
                case when ci.trdesc is not null
                        then (case when tl.tlid ='6868' then trim(ci.trdesc) || ' (Online)' else ci.trdesc end)
                        else ci.trdesc end trdesc
            from citran ci, tllog tl, afmast af, apptx app
            where ci.txdate = tl.txdate and ci.txnum = tl.txnum
                and ci.acctno = af.acctno
                and ci.txcd = app.txcd and app.apptype = 'CI' and app.txtype in ('D','C')
                and tl.deltd <> 'Y'
                and ci.namt <> 0
            ) CI
            where tl.msgacct=af.acctno
            and tltx.tltxcd = tl.tltxcd
            and af.ALTERNATEACCT like v_strALTERNATEACCT
            and  tl.tlid = mk.tlid(+)
            and  tl.OFFID =ck.tlid(+)
            AND TL.TXDATE = CI.TXDATE
            AND TL.TXNUM = CI.TXNUM
            AND CI.field ='BALANCE'
            and tl.tltxcd in('1153','8865','1139','3386')
            and TL.busdate = v_currdate
            AND TL.TLTXCD LIKE V_STRTLTXCD
           /* and  nvl(AF.brid,V_STRBRID) like V_STRBRID
            AND NVL( TL.TLID,'-') LIKE V_STRMAKER
            AND NVL( TL.OFFID,'-') LIKE V_STRCHECKER
            AND ci.corebank  LIKE V_STRCOREBANK
            AND CF.custodycd LIKE V_STRPV_CUSTODYCD
            AND AF.acctno LIKE V_STRPV_AFACCTNO*/

            --1178
            union
            SELECT af.custid, af.careby, tl.tltxcd,tltx.txdesc ,tl.txnum,tl.busdate ,tl.txdate,af.acctno,
             '' custodycdc,'' acctnoc,ads.amt amt,nvl(mk.tlname,'') mk,nvl(ck.tlname,'')  ck,NVL(AF.BRID,'') brid,
             nvl(tl.tlid,'') tlid,nvl(tl.OFFID,'') OFFID,
            '' bankid,ci.corebank ,decode(af.bankname,'---',V_SYSNAME,af.bankname) bankname, tl.txdesc trdesc
            FROM tllog TL,adschd ads ,afmast af,tltx, tlprofiles mk,tlprofiles ck,citran ci
            where tl.msgamt =ads.autoid
            and ci.txnum = tl.txnum
            and ci.txdate= tl.txdate
            and TL.msgacct = af.acctno
            and tltx.tltxcd = tl.tltxcd
            and af.ALTERNATEACCT like v_strALTERNATEACCT
            and  tl.tlid = mk.tlid(+)
            and  tl.OFFID =ck.tlid(+)
            and tl.tltxcd in ('1178')
            and TL.busdate  >=to_date(F_DATE,'DD/MM/YYYY')
            and TL.busdate  <=to_date(T_DATE,'DD/MM/YYYY')
            AND TL.TLTXCD LIKE V_STRTLTXCD
           /* and  nvl(AF.brid,V_STRBRID) like V_STRBRID
            AND NVL( TL.TLID,'-') LIKE V_STRMAKER
            AND NVL( TL.OFFID,'-') LIKE V_STRCHECKER
            AND ci.corebank  LIKE V_STRCOREBANK
            AND CF.custodycd LIKE V_STRPV_CUSTODYCD
            AND AF.acctno LIKE V_STRPV_AFACCTNO*/
            --and exists (select gu.grpid from tlgrpusers gu where af.careby = gu.grpid and gu.tlid = V_STRTLID )
            --nhom bank
            --'1131','1132','1136','1141'
            union

            SELECT af.custid,  af.careby, tl.tltxcd ,tltx.txdesc ,tl.txnum,tl.busdate ,tl.txdate,af.acctno,
             '' custodycdc,'' acctnoc,tl.msgamt amt,nvl(mk.tlname,'') mk,nvl(ck.tlname,'')  ck,NVL(AF.BRID,'') brid,
             nvl(tl.tlid,'') tlid,nvl(tl.OFFID,'') OFFID
            ,nvl(bank.fullname,' ') bankid,ci.corebank ,decode(af.bankname,'---',V_SYSNAME,af.bankname) bankname, tl.txdesc trdesc
            FROM tllog TL,afmast af,tltx, tlprofiles mk,tlprofiles ck,tllogfld tlfld,banknostro bank,citran ci
            where tl.msgacct=af.acctno
            and tltx.tltxcd = tl.tltxcd
            and ci.txdate = tl.txdate
            and ci.txnum = tl.txnum
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
            and TL.busdate  = v_currdate
            AND TL.TLTXCD LIKE V_STRTLTXCD
           /* and  nvl(AF.brid,V_STRBRID) like V_STRBRID
            AND NVL( TL.TLID,'-') LIKE V_STRMAKER
            AND NVL( TL.OFFID,'-') LIKE V_STRCHECKER
            AND ci.corebank  LIKE V_STRCOREBANK
            AND CF.custodycd LIKE V_STRPV_CUSTODYCD
            AND AF.acctno LIKE V_STRPV_AFACCTNO*/
            --and exists (select gu.grpid from tlgrpusers gu where af.careby = gu.grpid and gu.tlid = V_STRTLID )
            -- dfgroup
            union
            SELECT af.custid, af.careby, tl.tltxcd,tltx.txdesc ,tl.txnum,tl.busdate ,tl.txdate,af.acctno, '' custodycdc,'' acctnoc,CI.NAMT amt,
            nvl(mk.tlname,'') mk,nvl(ck.tlname,'')  ck,NVL(AF.BRID,'') brid,nvl(tl.tlid,'') tlid,nvl(tl.OFFID,'') OFFID,
            nvl(CFB.shortname,'') bankid ,ci.corebank ,decode(af.bankname,'---',V_SYSNAME,af.bankname) bankname, CI.trdesc trdesc
            FROM tllog TL,dfgroup dfg ,afmast af,tltx, tlprofiles mk,tlprofiles ck,
             lnmast ln,lntype , CFMAST CFB,
             (
                select ci.corebank, ci.autoid,
                ci.txnum, ci.txdate, ci.acctno, ci.txcd, ci.namt,
                ci.camt, ci.ref, nvl(ci.deltd,'N') deltd, ci.acctref,
                tl.tltxcd, tl.busdate,
                case when tl.tlid ='6868' then trim(tl.txdesc) || ' (Online)' else tl.txdesc end txdesc,
                tl.txtime, tl.brid, tl.tlid, tl.offid, tl.chid,
                ''  dfacctno,
                ''  old_dfacctno,
                app.txtype, app.field, tl.autoid tllog_autoid,
                case when ci.trdesc is not null
                        then (case when tl.tlid ='6868' then trim(ci.trdesc) || ' (Online)' else ci.trdesc end)
                        else ci.trdesc end trdesc
            from citran ci, tllog tl,  afmast af, apptx app
            where ci.txdate = tl.txdate and ci.txnum = tl.txnum

                and ci.acctno = af.acctno
                and ci.txcd = app.txcd and app.apptype = 'CI' and app.txtype in ('D','C')
                and tl.deltd <> 'Y'
                and ci.namt <> 0
             ) CI
            where tl.msgacct= dfg.groupid and dfg.afacctno = af.acctno
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
            and TL.busdate  = v_currdate
            AND TL.TLTXCD LIKE V_STRTLTXCD
/*            and  nvl(AF.brid,V_STRBRID) like V_STRBRID
            AND NVL( TL.TLID,'-') LIKE V_STRMAKER
            AND NVL( TL.OFFID,'-') LIKE V_STRCHECKER
            AND ci.corebank  LIKE V_STRCOREBANK
            AND CF.custodycd LIKE V_STRPV_CUSTODYCD
            AND AF.acctno LIKE V_STRPV_AFACCTNO*/
            --and exists (select gu.grpid from tlgrpusers gu where af.careby = gu.grpid and gu.tlid = V_STRTLID )
            union
            SELECT af.custid, af.careby,  tl.tltxcd ,tltx.txdesc ,tl.txnum,tl.busdate ,tl.txdate,af.acctno, '' custodycdc,'' acctnoc,
            ci.NAMT amt,nvl(mk.tlname,'') mk,nvl(ck.tlname,'')  ck,NVL(AF.BRID,'') brid,nvl(tl.tlid,'') tlid,nvl(tl.OFFID,'') OFFID,
            nvl(CFB.shortname,'') bankid ,ci.corebank ,decode(af.bankname,'---',V_SYSNAME,af.bankname) bankname,ci.trdesc
            FROM tllog TL,afmast af,tltx, tlprofiles mk,tlprofiles ck,
            (
                select ci.corebank, ci.autoid,
                ci.txnum, ci.txdate, ci.acctno, ci.txcd, ci.namt,
                ci.camt, ci.ref, nvl(ci.deltd,'N') deltd, ci.acctref,
                tl.tltxcd, tl.busdate,
                case when tl.tlid ='6868' then trim(tl.txdesc) || ' (Online)' else tl.txdesc end txdesc,
                tl.txtime, tl.brid, tl.tlid, tl.offid, tl.chid,
                ''  dfacctno,
                ''  old_dfacctno,
                app.txtype, app.field, tl.autoid tllog_autoid,
                case when ci.trdesc is not null
                        then (case when tl.tlid ='6868' then trim(ci.trdesc) || ' (Online)' else ci.trdesc end)
                        else ci.trdesc end trdesc
            from citran ci, tllog tl, afmast af, apptx app
            where ci.txdate = tl.txdate and ci.txnum = tl.txnum

                and ci.acctno = af.acctno
                and ci.txcd = app.txcd and app.apptype = 'CI' and app.txtype in ('D','C')
                and tl.deltd <> 'Y'
                and ci.namt <> 0
            ) ci,
             lnmast ln,lntype , CFMAST CFB
            where tl.msgacct=af.acctno
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
            and TL.busdate = v_currdate
            AND TL.TLTXCD LIKE V_STRTLTXCD
           /* and  nvl(AF.brid,V_STRBRID) like V_STRBRID
            AND NVL( TL.TLID,'-') LIKE V_STRMAKER
            AND NVL( TL.OFFID,'-') LIKE V_STRCHECKER
            AND ci.corebank  LIKE V_STRCOREBANK
            AND CF.custodycd LIKE V_STRPV_CUSTODYCD
            AND AF.acctno LIKE V_STRPV_AFACCTNO*/
            --and exists (select gu.grpid from tlgrpusers gu where af.careby = gu.grpid and gu.tlid = V_STRTLID )
            union
            SELECT AF.custid , af.careby, tl.tltxcd ,tltx.txdesc ,tl.txnum,tl.busdate ,tl.txdate,af.acctno,
            '' custodycdc,'' acctnoc,tl.msgamt amt,nvl(mk.tlname,'') mk,nvl(ck.tlname,'')  ck,NVL(AF.BRID,'') brid,
            nvl(tl.tlid,'') tlid,nvl(tl.OFFID,'') OFFID,
            nvl(CFB.shortname,'') bankid ,ci.corebank ,decode(af.bankname,'---',V_SYSNAME,af.bankname) bankname,
            tl.txdesc trdesc
            FROM tllog TL,afmast af,tltx, tlprofiles mk,tlprofiles ck,  tllogfld tlfld, lnmast ln,lntype , CFMAST CFB,citran ci
            where tl.msgacct=af.acctno
            and ci.txdate = tl.txdate
            and tl.txnum = ci.txnum
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
            and TL.busdate  = v_currdate
            AND TL.TLTXCD LIKE V_STRTLTXCD
          /*  and  nvl(AF.brid,V_STRBRID) like V_STRBRID
            AND NVL( TL.TLID,'-') LIKE V_STRMAKER
            AND NVL( TL.OFFID,'-') LIKE V_STRCHECKER
            AND ci.corebank  LIKE V_STRCOREBANK
            AND CF.custodycd LIKE V_STRPV_CUSTODYCD
            AND AF.acctno LIKE V_STRPV_AFACCTNO*/
            --and exists (select gu.grpid from tlgrpusers gu where af.careby = gu.grpid and gu.tlid = V_STRTLID )

            union

            SELECT af.custid,  af.careby, tl.tltxcd   tltxcd ,tltx.txdesc ,tl.txnum,tl.busdate ,tl.txdate,af.acctno,
             '' custodycdc,'' acctnoc,ci.namt amt,nvl(mk.tlname,'') mk,nvl(ck.tlname,'')  ck,NVL(AF.BRID,'') brid,
             nvl(tl.tlid,'') tlid,nvl(tl.OFFID,'') OFFID,
            ''bankid,ci.corebank ,decode(af.bankname,'---',V_SYSNAME,af.bankname) bankname,CI.trdesc
            FROM tllog TL,afmast af,tltx, tlprofiles mk,tlprofiles ck,

            (
                select ci.corebank, ci.autoid,
                    ci.txnum, ci.txdate, ci.acctno, ci.txcd, ci.namt,
                    ci.camt, ci.ref, nvl(ci.deltd,'N') deltd, ci.acctref,
                    tl.tltxcd, tl.busdate,
                    case when tl.tlid ='6868' then trim(tl.txdesc) || ' (Online)' else tl.txdesc end txdesc,
                    tl.txtime, tl.brid, tl.tlid, tl.offid, tl.chid,
                    ''  dfacctno,
                    ''  old_dfacctno,
                    app.txtype, app.field, tl.autoid tllog_autoid,
                    case when ci.trdesc is not null
                            then (case when tl.tlid ='6868' then trim(ci.trdesc) || ' (Online)' else ci.trdesc end)
                            else ci.trdesc end trdesc
                from citran ci, tllog tl,  afmast af, apptx app
                where ci.txdate = tl.txdate and ci.txnum = tl.txnum
                    and ci.acctno = af.acctno
                    and ci.txcd = app.txcd and app.apptype = 'CI' and app.txtype in ('D','C')
                    and tl.deltd <> 'Y'
                    and ci.namt <> 0
            )   ci
            where ci.acctno=af.acctno
            and tltx.tltxcd = tl.tltxcd
            and  tl.tlid = mk.tlid(+)
            and af.ALTERNATEACCT like v_strALTERNATEACCT
            and  tl.OFFID =ck.tlid(+)
            and tl.txdate = ci.txdate
            and tl.txnum = ci.txnum
            and tl.tltxcd  IN ('0088','1670','1610','1110','1600','1620','1137','1138','3384') --chaunh add 3384
            and ci.field ='BALANCE'
            and TL.busdate = v_currdate
            AND TL.TLTXCD LIKE V_STRTLTXCD
           /* and  nvl(AF.brid,V_STRBRID) like V_STRBRID
            AND NVL( TL.TLID,'-') LIKE V_STRMAKER
            AND NVL( TL.OFFID,'-') LIKE V_STRCHECKER
            AND ci.corebank  LIKE V_STRCOREBANK
            AND CF.custodycd LIKE V_STRPV_CUSTODYCD
            AND AF.acctno LIKE V_STRPV_AFACCTNO*/
            --and exists (select gu.grpid from tlgrpusers gu where af.careby = gu.grpid and gu.tlid = V_STRTLID )
            )A
            WHERE CF.CUSTID=A.CUSTID
             and  nvl(CF.brid,V_STRBRID) like V_STRBRID
            AND NVL( A.TLID,'-') LIKE V_STRMAKER
            AND NVL( A.OFFID,'-') LIKE V_STRCHECKER
            AND A.corebank  LIKE V_STRCOREBANK
            AND CF.custodycd LIKE V_STRPV_CUSTODYCD
            AND A.acctno LIKE V_STRPV_AFACCTNO




         ORDER BY A.TLTXCD ,a.busdate,A.TXNUM
            ;
        else    --Lay theo txdate
            OPEN PV_REFCURSOR
              FOR

              select  A.careby, A.tltxcd,A.txdesc ,A.txnum,A.busdate ,A.txdate, CF.CUSTODYCD,A.acctno,
            A.custodycdc,A.acctnoc,A.amt,A.mk,A.ck,
            CF.brid,A.tlid,A.OFFID, A.bankid,A.corebank ,A.bankname,A.trdesc
              from
             (SELECT * FROM CFMAST WHERE FNC_VALIDATE_SCOPE(BRID, CAREBY, TLSCOPE, pv_BRID, TLGOUPS)=0) cf,
             (
            select AF.CUSTID, af.careby, tl.tltxcd,tltx.txdesc ,tl.txnum,tl.busdate ,tl.txdate,af.acctno,
             cfc.custodycd custodycdc,afc.acctno acctnoc,tl.msgamt amt,nvl(mk.tlname,'') mk,nvl(ck.tlname,'')  ck,
             nvl(AF.brid,'') brid,nvl(tl.tlid,'') tlid,nvl(tl.OFFID,'') OFFID,
            ''bankid,ci.corebank ,decode(af.bankname,'---',V_SYSNAME,af.bankname) bankname,ci.trdesc
            from tllog TL ,
            (
                select ci.corebank, ci.autoid,
                ci.txnum, ci.txdate, ci.acctno, ci.txcd, ci.namt,
                ci.camt, ci.ref, nvl(ci.deltd,'N') deltd, ci.acctref,
                tl.tltxcd, tl.busdate,
                case when tl.tlid ='6868' then trim(tl.txdesc) || ' (Online)' else tl.txdesc end txdesc,
                tl.txtime, tl.brid, tl.tlid, tl.offid, tl.chid,
                ''  dfacctno,
                ''  old_dfacctno,
                app.txtype, app.field, tl.autoid tllog_autoid,
                case when ci.trdesc is not null
                        then (case when tl.tlid ='6868' then trim(ci.trdesc) || ' (Online)' else ci.trdesc end)
                        else ci.trdesc end trdesc
            from citran ci, tllog tl, afmast af, apptx app
            where ci.txdate = tl.txdate and ci.txnum = tl.txnum

                and ci.acctno = af.acctno
                and ci.txcd = app.txcd and app.apptype = 'CI' and app.txtype in ('D','C')
                and tl.deltd <> 'Y'
                and ci.namt <> 0
            ) ci,afmast af, afmast afc,cfmast cfc ,tltx  , tlprofiles mk,tlprofiles ck
            where tl.txnum =ci.txnum and tl.txdate =ci.txdate and ci.acctno= af.acctno
            and ci.ref =afc.acctno and afc.custid =cfc.custid
            and tltx.tltxcd = tl.tltxcd
            and  tl.tlid = mk.tlid(+)
            and  tl.OFFID =ck.tlid(+)
            and tl.tltxcd in ('1120','1130','1134') and ci.field ='BALANCE' and ci.txtype='D'
            --and decode (V_STRTYPEDATE,'002',TL.busdate,TL.txdate)>=to_date(F_DATE,'DD/MM/YYYY')
            --AND decode (V_STRTYPEDATE,'002',TL.busdate,TL.txdate)<=to_date(T_DATE,'DD/MM/YYYY')
            and TL.txdate  = v_currdate
            AND TL.TLTXCD LIKE V_STRTLTXCD
            and af.ALTERNATEACCT like v_strALTERNATEACCT
          /*  and  nvl(AF.brid,V_STRBRID) like V_STRBRID
            AND NVL( TL.TLID,'-') LIKE V_STRMAKER
            AND NVL( TL.OFFID,'-') LIKE V_STRCHECKER
            AND ci.corebank  LIKE V_STRCOREBANK
            AND CF.custodycd LIKE V_STRPV_CUSTODYCD
            AND AF.acctno LIKE V_STRPV_AFACCTNO*/
            --and exists (select gu.grpid from tlgrpusers gu where af.careby = gu.grpid and gu.tlid = V_STRTLID )
            union
            SELECT AF.CUSTID, af.careby, case when  tl.tltxcd in ('3350','3354') then '3342' else  tl.tltxcd end  tltxcd ,
            tltx.txdesc ,tl.txnum,tl.busdate ,tl.txdate,af.acctno, '' custodycdc,'' acctnoc,tl.msgamt amt,nvl(mk.tlname,'') mk,
            nvl(ck.tlname,'')  ck,nvl(AF.brid,'') brid,nvl(tl.tlid,'') tlid,nvl(tl.OFFID,'') OFFID,
            ''bankid,ci.corebank ,decode(af.bankname,'---',V_SYSNAME,af.bankname) bankname , tl.txdesc trdesc
            FROM tllog TL,afmast af,tltx, tlprofiles mk,tlprofiles ck,citran ci
            where substr(tl.msgacct,0,10)=af.acctno
            and tltx.tltxcd = tl.tltxcd
            and ci.txnum = tl.txnum
            and ci.txdate = tl.txdate
            and  tl.tlid = mk.tlid(+)
            and af.ALTERNATEACCT like v_strALTERNATEACCT
            and  tl.OFFID =ck.tlid(+)
            and tl.tltxcd in ('1140','1100','1107','1101'
            ,'1104','1108','1111','1114','1104','1112','1145','1144'
            ,'1123','1124','1126','1127','1162','1180','1182','6613','1105','1198','1199','8866','1190','1191'
            ,'8856','0066','8889','8894','8851','5541','1146') --Chaunh bo 3384
            --and decode (V_STRTYPEDATE,'002',TL.busdate,TL.txdate)>=to_date(F_DATE,'DD/MM/YYYY')
            --AND decode (V_STRTYPEDATE,'002',TL.busdate,TL.txdate)<=to_date(T_DATE,'DD/MM/YYYY')
            and TL.txdate = v_currdate
            AND  case when  tl.tltxcd in ('3350','3354') then '3342' else  tl.tltxcd end  LIKE V_STRTLTXCD
           /* and  nvl(AF.brid,V_STRBRID) like V_STRBRID
            AND NVL( TL.TLID,'-') LIKE V_STRMAKER
            AND NVL( TL.OFFID,'-') LIKE V_STRCHECKER
            AND ci.corebank  LIKE V_STRCOREBANK
            AND CF.custodycd LIKE V_STRPV_CUSTODYCD
            AND AF.acctno LIKE V_STRPV_AFACCTNO*/
            --and exists (select gu.grpid from tlgrpusers gu where af.careby = gu.grpid and gu.tlid = V_STRTLID )
            union
            SELECT AF.CUSTID,  af.careby, tl.tltxcd||'T'|| '0'  tltxcd ,tltx.txdesc ,tl.txnum,tl.busdate ,
            tl.txdate,af.acctno, '' custodycdc,'' acctnoc,tl.msgamt amt,nvl(mk.tlname,'') mk,nvl(ck.tlname,'')  ck,
            nvl(AF.brid,'') brid,nvl(tl.tlid,'') tlid,nvl(tl.OFFID,'') OFFID,
            ''bankid,ci.corebank ,decode(af.bankname,'---',V_SYSNAME,af.bankname) bankname,ci.trdesc
            FROM tllog TL,afmast af,tltx, tlprofiles mk,tlprofiles ck,
            (
                select ci.corebank, ci.autoid,
                    ci.txnum, ci.txdate, ci.acctno, ci.txcd, ci.namt,
                    ci.camt, ci.ref, nvl(ci.deltd,'N') deltd, ci.acctref,
                    tl.tltxcd, tl.busdate,
                    case when tl.tlid ='6868' then trim(tl.txdesc) || ' (Online)' else tl.txdesc end txdesc,
                    tl.txtime, tl.brid, tl.tlid, tl.offid, tl.chid,
                    ''  dfacctno,
                    ''  old_dfacctno,
                    app.txtype, app.field, tl.autoid tllog_autoid,
                    case when ci.trdesc is not null
                            then (case when tl.tlid ='6868' then trim(ci.trdesc) || ' (Online)' else ci.trdesc end)
                            else ci.trdesc end trdesc
                from citran ci, tllog tl,  afmast af, apptx app
                where ci.txdate = tl.txdate and ci.txnum = tl.txnum

                    and ci.acctno = af.acctno
                    and ci.txcd = app.txcd and app.apptype = 'CI' and app.txtype in ('D','C')
                    and tl.deltd <> 'Y'
                    and ci.namt <> 0
            ) CI, stschd sts
            where tl.msgacct=af.acctno
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
            and TL.txdate = v_currdate
            AND  tl.tltxcd||'T'|| '0'  LIKE V_STRTLTXCD
           /* and  nvl(AF.brid,V_STRBRID) like V_STRBRID
            AND NVL( TL.TLID,'-') LIKE V_STRMAKER
            AND NVL( TL.OFFID,'-') LIKE V_STRCHECKER
            AND ci.corebank  LIKE V_STRCOREBANK
            AND CF.custodycd LIKE V_STRPV_CUSTODYCD
            AND AF.acctno LIKE V_STRPV_AFACCTNO*/
            --and exists (select gu.grpid from tlgrpusers gu where af.careby = gu.grpid and gu.tlid = V_STRTLID )
            union
            SELECT AF.CUSTID,af.careby, case when  tl.tltxcd in ('3350','3354') then '3342' else  tl.tltxcd end  tltxcd ,
            tltx.txdesc ,tl.txnum,tl.busdate ,tl.txdate,af.acctno, '' custodycdc,'' acctnoc,ci.namt amt,nvl(mk.tlname,'') mk,nvl(ck.tlname,'')  ck,nvl(AF.brid,'') brid,nvl(tl.tlid,'') tlid,nvl(tl.OFFID,'') OFFID,
            ''bankid,ci.corebank ,decode(af.bankname,'---',V_SYSNAME,af.bankname) bankname,ci.trdesc
            FROM tllog TL,afmast af,tltx, tlprofiles mk,tlprofiles ck,
            (
                    select ci.corebank, ci.autoid,

                ci.txnum, ci.txdate, ci.acctno, ci.txcd, ci.namt,
                ci.camt, ci.ref, nvl(ci.deltd,'N') deltd, ci.acctref,
                tl.tltxcd, tl.busdate,
                case when tl.tlid ='6868' then trim(tl.txdesc) || ' (Online)' else tl.txdesc end txdesc,
                tl.txtime, tl.brid, tl.tlid, tl.offid, tl.chid,
                ''  dfacctno,
                ''  old_dfacctno,
                app.txtype, app.field, tl.autoid tllog_autoid,
                case when ci.trdesc is not null
                        then (case when tl.tlid ='6868' then trim(ci.trdesc) || ' (Online)' else ci.trdesc end)
                        else ci.trdesc end trdesc
            from citran ci, tllog tl, afmast af, apptx app
            where ci.txdate = tl.txdate and ci.txnum = tl.txnum

                and ci.acctno = af.acctno
                and ci.txcd = app.txcd and app.apptype = 'CI' and app.txtype in ('D','C')
                and tl.deltd <> 'Y'
                and ci.namt <> 0
            ) CI
            where tl.msgacct=af.acctno
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
           /* and  nvl(AF.brid,V_STRBRID) like V_STRBRID
            AND NVL( TL.TLID,'-') LIKE V_STRMAKER
            AND NVL( TL.OFFID,'-') LIKE V_STRCHECKER
            AND ci.corebank  LIKE V_STRCOREBANK
            AND CF.custodycd LIKE V_STRPV_CUSTODYCD
            AND AF.acctno LIKE V_STRPV_AFACCTNO*/
            --and exists (select gu.grpid from tlgrpusers gu where af.careby = gu.grpid and gu.tlid = V_STRTLID )
            UNION
            SELECT AF.CUSTID, af.careby, tl.tltxcd ,tltx.txdesc ,tl.txnum,tl.busdate ,tl.txdate,af.acctno,
            '' custodycdc,'' acctnoc,CI.NAMT amt,nvl(mk.tlname,'') mk,nvl(ck.tlname,'')  ck,nvl(AF.brid,'') brid,nvl(tl.tlid,'') tlid,nvl(tl.OFFID,'') OFFID,
            ''bankid,ci.corebank ,decode(af.bankname,'---',V_SYSNAME,af.bankname) bankname,ci.trdesc
            FROM tllog TL,afmast af,tltx, tlprofiles mk,tlprofiles ck,
            (
                select ci.corebank, ci.autoid,
                    ci.txnum, ci.txdate, ci.acctno, ci.txcd, ci.namt,
                    ci.camt, ci.ref, nvl(ci.deltd,'N') deltd, ci.acctref,
                    tl.tltxcd, tl.busdate,
                    case when tl.tlid ='6868' then trim(tl.txdesc) || ' (Online)' else tl.txdesc end txdesc,
                    tl.txtime, tl.brid, tl.tlid, tl.offid, tl.chid,
                    ''  dfacctno,
                    ''  old_dfacctno,
                    app.txtype, app.field, tl.autoid tllog_autoid,
                    case when ci.trdesc is not null
                            then (case when tl.tlid ='6868' then trim(ci.trdesc) || ' (Online)' else ci.trdesc end)
                            else ci.trdesc end trdesc
                from citran ci, tllog tl, afmast af, apptx app
                where ci.txdate = tl.txdate and ci.txnum = tl.txnum

                    and ci.acctno = af.acctno
                    and ci.txcd = app.txcd and app.apptype = 'CI' and app.txtype in ('D','C')
                    and tl.deltd <> 'Y'
                    and ci.namt <> 0
            ) CI
            where tl.msgacct=af.acctno
            and tltx.tltxcd = tl.tltxcd
            and  tl.tlid = mk.tlid(+)
            and  tl.OFFID =ck.tlid(+)
            AND TL.TXDATE = CI.TXDATE
            AND TL.TXNUM = CI.TXNUM
            and af.ALTERNATEACCT like v_strALTERNATEACCT
            AND CI.field ='BALANCE'
            and tl.tltxcd in('1153','8865','1139','3386')
            --and decode (V_STRTYPEDATE,'002',TL.busdate,TL.txdate)>=to_date(F_DATE,'DD/MM/YYYY')
            --AND decode (V_STRTYPEDATE,'002',TL.busdate,TL.txdate)<=to_date(T_DATE,'DD/MM/YYYY')
            and TL.txdate  = v_currdate
            AND TL.TLTXCD LIKE V_STRTLTXCD
/*            and  nvl(AF.brid,V_STRBRID) like V_STRBRID
            AND NVL( TL.TLID,'-') LIKE V_STRMAKER
            AND NVL( TL.OFFID,'-') LIKE V_STRCHECKER
            AND ci.corebank  LIKE V_STRCOREBANK
            AND CF.custodycd LIKE V_STRPV_CUSTODYCD
            AND AF.acctno LIKE V_STRPV_AFACCTNO*/
            --and exists (select gu.grpid from tlgrpusers gu where af.careby = gu.grpid and gu.tlid = V_STRTLID )
            --1178
            union
            SELECT AF.CUSTID,af.careby, tl.tltxcd,tltx.txdesc ,tl.txnum,tl.busdate ,tl.txdate,af.acctno, '' custodycdc,'' acctnoc,ads.amt amt,nvl(mk.tlname,'') mk,nvl(ck.tlname,'')  ck,nvl(AF.brid,'') brid,nvl(tl.tlid,'') tlid,nvl(tl.OFFID,'') OFFID,
            '' bankid,ci.corebank ,decode(af.bankname,'---',V_SYSNAME,af.bankname) bankname, tl.txdesc trdesc
            FROM tllog   TL,adschd ads ,afmast af,tltx, tlprofiles mk,tlprofiles ck,citran ci
            where tl.msgamt =ads.autoid
            and TL.msgacct = af.acctno
            and tltx.tltxcd = tl.tltxcd
            and ci.txnum = tl.txnum
            and ci.txdate = tl.txdate
            and  tl.tlid = mk.tlid(+)
            and af.ALTERNATEACCT like v_strALTERNATEACCT
            and  tl.OFFID =ck.tlid(+)
            and tl.tltxcd in ('1178')
            --and decode (V_STRTYPEDATE,'002',TL.busdate,TL.txdate)>=to_date(F_DATE,'DD/MM/YYYY')
            --AND decode (V_STRTYPEDATE,'002',TL.busdate,TL.txdate)<=to_date(T_DATE,'DD/MM/YYYY')
            and TL.txdate  >=to_date(F_DATE,'DD/MM/YYYY')
            and TL.txdate  <=to_date(T_DATE,'DD/MM/YYYY')
            AND TL.TLTXCD LIKE V_STRTLTXCD
          /*  and  nvl(AF.brid,V_STRBRID) like V_STRBRID
            AND NVL( TL.TLID,'-') LIKE V_STRMAKER
            AND NVL( TL.OFFID,'-') LIKE V_STRCHECKER
            AND ci.corebank  LIKE V_STRCOREBANK
            AND CF.custodycd LIKE V_STRPV_CUSTODYCD
            AND AF.acctno LIKE V_STRPV_AFACCTNO*/
            --and exists (select gu.grpid from tlgrpusers gu where af.careby = gu.grpid and gu.tlid = V_STRTLID )
            --nhom bank
            --'1131','1132','1136','1141'
            union

            SELECT AF.CUSTID,  af.careby, tl.tltxcd ,tltx.txdesc ,tl.txnum,tl.busdate ,tl.txdate,af.acctno, '' custodycdc,'' acctnoc,tl.msgamt amt,nvl(mk.tlname,'') mk,nvl(ck.tlname,'')  ck,nvl(AF.brid,'') brid,nvl(tl.tlid,'') tlid,nvl(tl.OFFID,'') OFFID
            ,nvl(bank.fullname,' ') bankid,ci.corebank ,decode(af.bankname,'---',V_SYSNAME,af.bankname) bankname, tl.txdesc trdesc
            FROM tllog TL,afmast af,tltx, tlprofiles mk,tlprofiles ck,tllogfld tlfld,banknostro bank,citran ci
            where tl.msgacct=af.acctno
            and ci.txnum = tl.txnum
            and ci.txdate = tl.txdate
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
            and TL.txdate  = v_currdate
            AND TL.TLTXCD LIKE V_STRTLTXCD
         /*   and  nvl(AF.brid,V_STRBRID) like V_STRBRID
            AND NVL( TL.TLID,'-') LIKE V_STRMAKER
            AND NVL( TL.OFFID,'-') LIKE V_STRCHECKER
            AND ci.corebank  LIKE V_STRCOREBANK
            AND CF.custodycd LIKE V_STRPV_CUSTODYCD
            AND AF.acctno LIKE V_STRPV_AFACCTNO*/
            --and exists (select gu.grpid from tlgrpusers gu where af.careby = gu.grpid and gu.tlid = V_STRTLID )
            -- dfgroup
            union
            SELECT AF.CUSTID, af.careby, tl.tltxcd,tltx.txdesc ,tl.txnum,tl.busdate ,tl.txdate,af.acctno, '' custodycdc,'' acctnoc,CI.NAMT amt,nvl(mk.tlname,'') mk,nvl(ck.tlname,'')  ck,nvl(AF.brid,'') brid,nvl(tl.tlid,'') tlid,nvl(tl.OFFID,'') OFFID,
            nvl(CFB.shortname,'') bankid ,ci.corebank ,decode(af.bankname,'---',V_SYSNAME,af.bankname) bankname, CI.trdesc trdesc
            FROM tllog TL,dfgroup dfg ,afmast af,tltx, tlprofiles mk,tlprofiles ck,
             lnmast ln,lntype , CFMAST CFB,
             (
                select ci.corebank, ci.autoid,
                ci.txnum, ci.txdate, ci.acctno, ci.txcd, ci.namt,
                ci.camt, ci.ref, nvl(ci.deltd,'N') deltd, ci.acctref,
                tl.tltxcd, tl.busdate,
                case when tl.tlid ='6868' then trim(tl.txdesc) || ' (Online)' else tl.txdesc end txdesc,
                tl.txtime, tl.brid, tl.tlid, tl.offid, tl.chid,
                ''  dfacctno,
                ''  old_dfacctno,
                app.txtype, app.field, tl.autoid tllog_autoid,
                case when ci.trdesc is not null
                        then (case when tl.tlid ='6868' then trim(ci.trdesc) || ' (Online)' else ci.trdesc end)
                        else ci.trdesc end trdesc
            from citran ci, tllog tl,  afmast af, apptx app
            where ci.txdate = tl.txdate and ci.txnum = tl.txnum

                and ci.acctno = af.acctno
                and ci.txcd = app.txcd and app.apptype = 'CI' and app.txtype in ('D','C')
                and tl.deltd <> 'Y'
                and ci.namt <> 0
             ) CI
            where tl.msgacct= dfg.groupid and dfg.afacctno = af.acctno
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
            and TL.txdate  = v_currdate
            AND TL.TLTXCD LIKE V_STRTLTXCD
           /* and  nvl(AF.brid,V_STRBRID) like V_STRBRID
            AND NVL( TL.TLID,'-') LIKE V_STRMAKER
            AND NVL( TL.OFFID,'-') LIKE V_STRCHECKER
            AND ci.corebank  LIKE V_STRCOREBANK
            AND CF.custodycd LIKE V_STRPV_CUSTODYCD
            AND AF.acctno LIKE V_STRPV_AFACCTNO*/
            --and exists (select gu.grpid from tlgrpusers gu where af.careby = gu.grpid and gu.tlid = V_STRTLID )
            union
            SELECT AF.CUSTID, af.careby,  tl.tltxcd ,tltx.txdesc ,tl.txnum,tl.busdate ,tl.txdate,af.acctno, '' custodycdc,'' acctnoc,ci.NAMT amt,nvl(mk.tlname,'') mk,nvl(ck.tlname,'')  ck,nvl(AF.brid,'') brid,nvl(tl.tlid,'') tlid,nvl(tl.OFFID,'') OFFID,
            nvl(CFB.shortname,'') bankid ,ci.corebank ,decode(af.bankname,'---',V_SYSNAME,af.bankname) bankname,ci.trdesc
            FROM
            tllog TL,afmast af,tltx, tlprofiles mk,tlprofiles ck,

            (
                select ci.corebank, ci.autoid,
                    ci.txnum, ci.txdate, ci.acctno, ci.txcd, ci.namt,
                    ci.camt, ci.ref, nvl(ci.deltd,'N') deltd, ci.acctref,
                    tl.tltxcd, tl.busdate,
                    case when tl.tlid ='6868' then trim(tl.txdesc) || ' (Online)' else tl.txdesc end txdesc,
                    tl.txtime, tl.brid, tl.tlid, tl.offid, tl.chid,
                    ''  dfacctno,
                    ''  old_dfacctno,
                    app.txtype, app.field, tl.autoid tllog_autoid,
                    case when ci.trdesc is not null
                            then (case when tl.tlid ='6868' then trim(ci.trdesc) || ' (Online)' else ci.trdesc end)
                            else ci.trdesc end trdesc
                from citran ci, tllog tl, afmast af, apptx app
                where ci.txdate = tl.txdate and ci.txnum = tl.txnum

                    and ci.acctno = af.acctno
                    and ci.txcd = app.txcd and app.apptype = 'CI' and app.txtype in ('D','C')
                    and tl.deltd <> 'Y'
                    and ci.namt <> 0
            ) ci,
             lnmast ln,lntype , CFMAST CFB
            where tl.msgacct=af.acctno
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
            and TL.txdate  = v_currdate
            AND TL.TLTXCD LIKE V_STRTLTXCD
/*            and  nvl(AF.brid,V_STRBRID) like V_STRBRID
            AND NVL( TL.TLID,'-') LIKE V_STRMAKER
            AND NVL( TL.OFFID,'-') LIKE V_STRCHECKER
            AND ci.corebank  LIKE V_STRCOREBANK
            AND CF.custodycd LIKE V_STRPV_CUSTODYCD
            AND AF.acctno LIKE V_STRPV_AFACCTNO*/
            --and exists (select gu.grpid from tlgrpusers gu where af.careby = gu.grpid and gu.tlid = V_STRTLID )
            union
            SELECT AF.CUSTID, af.careby,  tl.tltxcd ,tltx.txdesc ,tl.txnum,tl.busdate ,tl.txdate,af.acctno, '' custodycdc,'' acctnoc,tl.msgamt amt,nvl(mk.tlname,'') mk,nvl(ck.tlname,'')  ck,nvl(AF.brid,'') brid,nvl(tl.tlid,'') tlid,nvl(tl.OFFID,'') OFFID,
            nvl(CFB.shortname,'') bankid ,ci.corebank ,decode(af.bankname,'---',V_SYSNAME,af.bankname) bankname, tl.txdesc trdesc
            FROM tllog TL,afmast af,tltx, tlprofiles mk,tlprofiles ck,  tllogfld tlfld, lnmast ln,lntype , CFMAST CFB,
            citran ci
            where tl.msgacct=af.acctno
            and tltx.tltxcd = tl.tltxcd
            and ci.txdate = tl.txdate
            and ci.txnum = tl.txnum
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
           /* and  nvl(AF.brid,V_STRBRID) like V_STRBRID
            AND NVL( TL.TLID,'-') LIKE V_STRMAKER
            AND NVL( TL.OFFID,'-') LIKE V_STRCHECKER
            AND ci.corebank  LIKE V_STRCOREBANK
            AND CF.custodycd LIKE V_STRPV_CUSTODYCD
            AND AF.acctno LIKE V_STRPV_AFACCTNO*/
            --and exists (select gu.grpid from tlgrpusers gu where af.careby = gu.grpid and gu.tlid = V_STRTLID )
            union
            SELECT AF.CUSTID,af.careby,  tl.tltxcd   tltxcd ,tltx.txdesc ,tl.txnum,tl.busdate ,tl.txdate,af.acctno, '' custodycdc,'' acctnoc,ci.namt amt,nvl(mk.tlname,'') mk,nvl(ck.tlname,'')  ck,nvl(AF.brid,'') brid,nvl(tl.tlid,'') tlid,nvl(tl.OFFID,'') OFFID,
            ''bankid,ci.corebank ,decode(af.bankname,'---',V_SYSNAME,af.bankname) bankname,CI.trdesc
            FROM tllog TL,afmast af,tltx, tlprofiles mk,tlprofiles ck,
             (
                select ci.corebank, ci.autoid,
                    ci.txnum, ci.txdate, ci.acctno, ci.txcd, ci.namt,
                    ci.camt, ci.ref, nvl(ci.deltd,'N') deltd, ci.acctref,
                    tl.tltxcd, tl.busdate,
                    case when tl.tlid ='6868' then trim(tl.txdesc) || ' (Online)' else tl.txdesc end txdesc,
                    tl.txtime, tl.brid, tl.tlid, tl.offid, tl.chid,
                    ''  dfacctno,
                    ''  old_dfacctno,
                    app.txtype, app.field, tl.autoid tllog_autoid,
                    case when ci.trdesc is not null
                            then (case when tl.tlid ='6868' then trim(ci.trdesc) || ' (Online)' else ci.trdesc end)
                            else ci.trdesc end trdesc
                from citran ci, tllog tl, afmast af, apptx app
                where ci.txdate = tl.txdate and ci.txnum = tl.txnum

                    and ci.acctno = af.acctno
                    and ci.txcd = app.txcd and app.apptype = 'CI' and app.txtype in ('D','C')
                    and tl.deltd <> 'Y'
                    and ci.namt <> 0
            )   ci
            where ci.acctno=af.acctno
            and tltx.tltxcd = tl.tltxcd
            and af.ALTERNATEACCT like v_strALTERNATEACCT
            and  tl.tlid = mk.tlid(+)
            and  tl.OFFID =ck.tlid(+)
            and tl.txdate = ci.txdate
            and tl.txnum = ci.txnum
            and tl.tltxcd  IN ('0088','1670','1610','1110','1600','1620','1137','1138','3384') --chaunh add 3384
            and ci.field ='BALANCE'
            --and decode (V_STRTYPEDATE,'002',TL.busdate,TL.txdate)>=to_date(F_DATE,'DD/MM/YYYY')
            --AND decode (V_STRTYPEDATE,'002',TL.busdate,TL.txdate)<=to_date(T_DATE,'DD/MM/YYYY')
            and TL.txdate  = v_currdate
            AND TL.TLTXCD LIKE V_STRTLTXCD
/*            and  nvl(AF.brid,V_STRBRID) like V_STRBRID
            AND NVL( TL.TLID,'-') LIKE V_STRMAKER
            AND NVL( TL.OFFID,'-') LIKE V_STRCHECKER
            AND ci.corebank  LIKE V_STRCOREBANK
            AND CF.custodycd LIKE V_STRPV_CUSTODYCD
            AND AF.acctno LIKE V_STRPV_AFACCTNO*/
            --and exists (select gu.grpid from tlgrpusers gu where af.careby = gu.grpid and gu.tlid = V_STRTLID )
            )A

            WHERE CF.CUSTID=A.CUSTID
             and  nvl(CF.brid,V_STRBRID) like V_STRBRID
            AND NVL( A.TLID,'-') LIKE V_STRMAKER
            AND NVL( A.OFFID,'-') LIKE V_STRCHECKER
            AND A.corebank  LIKE V_STRCOREBANK
            AND CF.custodycd LIKE V_STRPV_CUSTODYCD
            AND A.acctno LIKE V_STRPV_AFACCTNO

            ORDER BY A.TLTXCD ,a.busdate,A.TXNUM
            ;
        end if;

    ELSE
        if V_STRTYPEDATE ='002' then --Lay theo busdate
            OPEN PV_REFCURSOR
            FOR
             select  A.careby, A.tltxcd,A.txdesc ,A.txnum,A.busdate ,A.txdate, CF.CUSTODYCD,A.acctno,
            A.custodycdc,A.acctnoc,A.amt,A.mk,A.ck,
            CF.brid,A.tlid,A.OFFID, A.bankid,A.corebank ,A.bankname,A.trdesc
              from
             (SELECT * FROM CFMAST WHERE FNC_VALIDATE_SCOPE(BRID, CAREBY, TLSCOPE, pv_BRID, TLGOUPS)=0) cf,
             (
            select AF.CUSTID, af.careby, tl.tltxcd,tltx.txdesc ,tl.txnum,tl.busdate ,tl.txdate,af.acctno, cfc.custodycd custodycdc,afc.acctno acctnoc,tl.msgamt amt,nvl(mk.tlname,'') mk,nvl(ck.tlname,'')  ck,nvl(tl.brid,'') brid,nvl(tl.tlid,'') tlid,nvl(tl.OFFID,'') OFFID,
            ''bankid,ci.corebank ,decode(af.bankname,'---',V_SYSNAME,af.bankname) bankname,ci.trdesc
            from tllog TL ,(
                select ci.corebank, ci.autoid,
                    ci.txnum, ci.txdate, ci.acctno, ci.txcd, ci.namt,
                    ci.camt, ci.ref, nvl(ci.deltd,'N') deltd, ci.acctref,
                    tl.tltxcd, tl.busdate,
                    case when tl.tlid ='6868' then trim(tl.txdesc) || ' (Online)' else tl.txdesc end txdesc,
                    tl.txtime, tl.brid, tl.tlid, tl.offid, tl.chid,
                    ''  dfacctno,
                    ''  old_dfacctno,
                    app.txtype, app.field, tl.autoid tllog_autoid,
                    case when ci.trdesc is not null
                            then (case when tl.tlid ='6868' then trim(ci.trdesc) || ' (Online)' else ci.trdesc end)
                            else ci.trdesc end trdesc
                from citran ci, tllog tl, afmast af, apptx app
                where ci.txdate = tl.txdate and ci.txnum = tl.txnum

                    and ci.acctno = af.acctno
                    and ci.txcd = app.txcd and app.apptype = 'CI' and app.txtype in ('D','C')
                    and tl.deltd <> 'Y'
                    and ci.namt <> 0
            ) ci,afmast af, afmast afc,cfmast cfc ,tltx  , tlprofiles mk,tlprofiles ck
            where tl.txnum =ci.txnum and tl.txdate =ci.txdate and ci.acctno= af.acctno
            and ci.ref =afc.acctno and afc.custid =cfc.custid
            and tltx.tltxcd = tl.tltxcd
            and  tl.tlid = mk.tlid(+)
            and  tl.OFFID =ck.tlid(+)
            and tl.tltxcd in ('1120','1130','1134') and ci.field ='BALANCE' and ci.txtype='D'
            --and decode (V_STRTYPEDATE,'002',TL.busdate,TL.txdate)>=to_date(F_DATE,'DD/MM/YYYY')
            --AND decode (V_STRTYPEDATE,'002',TL.busdate,TL.txdate)<=to_date(T_DATE,'DD/MM/YYYY')
            and TL.busdate  = v_currdate
            and af.ALTERNATEACCT like v_strALTERNATEACCT
            AND TL.TLTXCD LIKE V_STRTLTXCD
            and  nvl(tl.brid,V_STRBRID) like V_STRBRID
       /*     AND NVL( TL.TLID,'-') LIKE V_STRMAKER
            AND NVL( TL.OFFID,'-') LIKE V_STRCHECKER
            AND ci.corebank  LIKE V_STRCOREBANK
            AND CF.custodycd LIKE V_STRPV_CUSTODYCD
            AND AF.acctno LIKE V_STRPV_AFACCTNO*/
            --and exists (select gu.grpid from tlgrpusers gu where af.careby = gu.grpid and gu.tlid = V_STRTLID )

            union
            SELECT  AF.CUSTID,af.careby, case when  tl.tltxcd in ('3350','3354') then '3342' else  tl.tltxcd end  tltxcd ,
            tltx.txdesc ,tl.txnum,tl.busdate ,tl.txdate,af.acctno, '' custodycdc,'' acctnoc,tl.msgamt amt,nvl(mk.tlname,'') mk,nvl(ck.tlname,'')  ck,nvl(tl.brid,'') brid,nvl(tl.tlid,'') tlid,nvl(tl.OFFID,'') OFFID,
            ''bankid,ci.corebank ,decode(af.bankname,'---',V_SYSNAME,af.bankname) bankname , tl.txdesc trdesc
            FROM tllog TL,afmast af ,tltx, tlprofiles mk,tlprofiles ck, citran ci
            where substr(tl.msgacct,0,10)=af.acctno
            and tltx.tltxcd = tl.tltxcd
            and ci.txdate = tl.txdate
            and ci.txnum = tl.txnum
            and af.ALTERNATEACCT like v_strALTERNATEACCT
            and  tl.tlid = mk.tlid(+)
            and  tl.OFFID =ck.tlid(+)
            and tl.tltxcd in ('1140','1100','1107','1101'
            ,'1104','1108','1111','1114','1104','1112','1145','1144'
            ,'1123','1124','1126','1127','1162','1180','1182','6613','1105','1198','1199','8866','1190','1191'
            ,'8856','0066','8889','8894','8851','5541','1146') --Chaunh bo 3384
            --and decode (V_STRTYPEDATE,'002',TL.busdate,TL.txdate)>=to_date(F_DATE,'DD/MM/YYYY')
            --AND decode (V_STRTYPEDATE,'002',TL.busdate,TL.txdate)<=to_date(T_DATE,'DD/MM/YYYY')
            and TL.busdate  = v_currdate AND TL.TLTXCD LIKE V_STRTLTXCD
            and  nvl(tl.brid,V_STRBRID) like V_STRBRID
        /*    AND NVL( TL.TLID,'-') LIKE V_STRMAKER
            AND NVL( TL.OFFID,'-') LIKE V_STRCHECKER
            AND ci.corebank  LIKE V_STRCOREBANK
            AND CF.custodycd LIKE V_STRPV_CUSTODYCD
            AND AF.acctno LIKE V_STRPV_AFACCTNO*/
            --and exists (select gu.grpid from tlgrpusers gu where af.careby = gu.grpid and gu.tlid = V_STRTLID )
            union
            SELECT   AF.CUSTID, af.careby, tl.tltxcd||'T'|| '0' tltxcd ,tltx.txdesc ,tl.txnum,tl.busdate ,tl.txdate,af.acctno, '' custodycdc,'' acctnoc,tl.msgamt amt,nvl(mk.tlname,'') mk,nvl(ck.tlname,'')  ck,nvl(tl.brid,'') brid,nvl(tl.tlid,'') tlid,nvl(tl.OFFID,'') OFFID,
            ''bankid,ci.corebank ,decode(af.bankname,'---',V_SYSNAME,af.bankname) bankname,ci.trdesc
            FROM tllog TL,afmast af,tltx, tlprofiles mk,tlprofiles ck,(
                select ci.corebank, ci.autoid,
                    ci.txnum, ci.txdate, ci.acctno, ci.txcd, ci.namt,
                    ci.camt, ci.ref, nvl(ci.deltd,'N') deltd, ci.acctref,
                    tl.tltxcd, tl.busdate,
                    case when tl.tlid ='6868' then trim(tl.txdesc) || ' (Online)' else tl.txdesc end txdesc,
                    tl.txtime, tl.brid, tl.tlid, tl.offid, tl.chid,
                    ''  dfacctno,
                    ''  old_dfacctno,
                    app.txtype, app.field, tl.autoid tllog_autoid,
                    case when ci.trdesc is not null
                            then (case when tl.tlid ='6868' then trim(ci.trdesc) || ' (Online)' else ci.trdesc end)
                            else ci.trdesc end trdesc
                from citran ci, tllog tl,afmast af, apptx app
                where ci.txdate = tl.txdate and ci.txnum = tl.txnum

                    and ci.acctno = af.acctno
                    and ci.txcd = app.txcd and app.apptype = 'CI' and app.txtype in ('D','C')
                    and tl.deltd <> 'Y'
                    and ci.namt <> 0
            ) CI, stschd sts
            where tl.msgacct=af.acctno
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
            and TL.busdate  = v_currdate
            AND TL.TLTXCD LIKE V_STRTLTXCD
            and  nvl(tl.brid,V_STRBRID) like V_STRBRID
          /*  AND NVL( TL.TLID,'-') LIKE V_STRMAKER
            AND NVL( TL.OFFID,'-') LIKE V_STRCHECKER
            AND ci.corebank  LIKE V_STRCOREBANK
            AND CF.custodycd LIKE V_STRPV_CUSTODYCD
            AND AF.acctno LIKE V_STRPV_AFACCTNO*/
            --and exists (select gu.grpid from tlgrpusers gu where af.careby = gu.grpid and gu.tlid = V_STRTLID )
            union
            SELECT  AF.CUSTID,af.careby, case when  tl.tltxcd in ('3350','3354') then '3342' else  tl.tltxcd end  tltxcd ,
            tltx.txdesc ,tl.txnum,tl.busdate ,tl.txdate,af.acctno, '' custodycdc,'' acctnoc,tl.msgamt amt,nvl(mk.tlname,'') mk,nvl(ck.tlname,'')  ck,nvl(tl.brid,'') brid,nvl(tl.tlid,'') tlid,nvl(tl.OFFID,'') OFFID,
            ''bankid,ci.corebank ,decode(af.bankname,'---',V_SYSNAME,af.bankname) bankname,ci.trdesc
            FROM tllog TL,afmast af,tltx, tlprofiles mk,tlprofiles ck,(
                select ci.corebank, ci.autoid,
                    ci.txnum, ci.txdate, ci.acctno, ci.txcd, ci.namt,
                    ci.camt, ci.ref, nvl(ci.deltd,'N') deltd, ci.acctref,
                    tl.tltxcd, tl.busdate,
                    case when tl.tlid ='6868' then trim(tl.txdesc) || ' (Online)' else tl.txdesc end txdesc,
                    tl.txtime, tl.brid, tl.tlid, tl.offid, tl.chid,
                    ''  dfacctno,
                    ''  old_dfacctno,
                    app.txtype, app.field, tl.autoid tllog_autoid,
                    case when ci.trdesc is not null
                            then (case when tl.tlid ='6868' then trim(ci.trdesc) || ' (Online)' else ci.trdesc end)
                            else ci.trdesc end trdesc
                from citran ci, tllog tl,  afmast af, apptx app
                where ci.txdate = tl.txdate and ci.txnum = tl.txnum

                    and ci.acctno = af.acctno
                    and ci.txcd = app.txcd and app.apptype = 'CI' and app.txtype in ('D','C')
                    and tl.deltd <> 'Y'
                    and ci.namt <> 0
            ) CI
            where tl.msgacct=af.acctno
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
            and TL.busdate  = v_currdate
            AND case when  tl.tltxcd in ('3350','3354') then '3342' else  tl.tltxcd end  LIKE V_STRTLTXCD
            and  nvl(tl.brid,V_STRBRID) like V_STRBRID
         /*   AND NVL( TL.TLID,'-') LIKE V_STRMAKER
            AND NVL( TL.OFFID,'-') LIKE V_STRCHECKER
            AND ci.corebank  LIKE V_STRCOREBANK
            AND CF.custodycd LIKE V_STRPV_CUSTODYCD
            AND AF.acctno LIKE V_STRPV_AFACCTNO*/
            --and exists (select gu.grpid from tlgrpusers gu where af.careby = gu.grpid and gu.tlid = V_STRTLID )
            UNION
            SELECT  AF.CUSTID,af.careby,  tl.tltxcd ,tltx.txdesc ,tl.txnum,tl.busdate ,tl.txdate,af.acctno, '' custodycdc,'' acctnoc,CI.NAMT amt,nvl(mk.tlname,'') mk,nvl(ck.tlname,'')  ck,nvl(tl.brid,'') brid,nvl(tl.tlid,'') tlid,nvl(tl.OFFID,'') OFFID,
            ''bankid,ci.corebank ,decode(af.bankname,'---',V_SYSNAME,af.bankname) bankname,ci.trdesc
            FROM tllog TL,afmast af,tltx, tlprofiles mk,tlprofiles ck,(
                select ci.corebank, ci.autoid,
                    ci.txnum, ci.txdate, ci.acctno, ci.txcd, ci.namt,
                    ci.camt, ci.ref, nvl(ci.deltd,'N') deltd, ci.acctref,
                    tl.tltxcd, tl.busdate,
                    case when tl.tlid ='6868' then trim(tl.txdesc) || ' (Online)' else tl.txdesc end txdesc,
                    tl.txtime, tl.brid, tl.tlid, tl.offid, tl.chid,
                    ''  dfacctno,
                    ''  old_dfacctno,
                    app.txtype, app.field, tl.autoid tllog_autoid,
                    case when ci.trdesc is not null
                            then (case when tl.tlid ='6868' then trim(ci.trdesc) || ' (Online)' else ci.trdesc end)
                            else ci.trdesc end trdesc
                from citran ci, tllog tl, afmast af, apptx app
                where ci.txdate = tl.txdate and ci.txnum = tl.txnum

                    and ci.acctno = af.acctno
                    and ci.txcd = app.txcd and app.apptype = 'CI' and app.txtype in ('D','C')
                    and tl.deltd <> 'Y'
                    and ci.namt <> 0
            ) CI
            where tl.msgacct=af.acctno
            and tltx.tltxcd = tl.tltxcd
            and  tl.tlid = mk.tlid(+)
            and  tl.OFFID =ck.tlid(+)
            and af.ALTERNATEACCT like v_strALTERNATEACCT
            AND TL.TXDATE = CI.TXDATE
            AND TL.TXNUM = CI.TXNUM
            AND CI.field ='BALANCE'
            and tl.tltxcd in('1153','8865','1139','3386')
            --and decode (V_STRTYPEDATE,'002',TL.busdate,TL.txdate)>=to_date(F_DATE,'DD/MM/YYYY')
            --AND decode (V_STRTYPEDATE,'002',TL.busdate,TL.txdate)<=to_date(T_DATE,'DD/MM/YYYY')
            and TL.busdate = v_currdate
            AND TL.TLTXCD LIKE V_STRTLTXCD
            and  nvl(tl.brid,V_STRBRID) like V_STRBRID
         /*   AND NVL( TL.TLID,'-') LIKE V_STRMAKER
            AND NVL( TL.OFFID,'-') LIKE V_STRCHECKER
            AND ci.corebank  LIKE V_STRCOREBANK
            AND CF.custodycd LIKE V_STRPV_CUSTODYCD
            AND AF.acctno LIKE V_STRPV_AFACCTNO*/
            --and exists (select gu.grpid from tlgrpusers gu where af.careby = gu.grpid and gu.tlid = V_STRTLID )

            --1178
            union
            SELECT  AF.CUSTID,af.careby, tl.tltxcd,tltx.txdesc ,tl.txnum,tl.busdate ,tl.txdate,af.acctno, '' custodycdc,'' acctnoc,ads.amt amt,nvl(mk.tlname,'') mk,nvl(ck.tlname,'')  ck,nvl(tl.brid,'') brid,nvl(tl.tlid,'') tlid,nvl(tl.OFFID,'') OFFID,
            '' bankid,ci.corebank ,decode(af.bankname,'---',V_SYSNAME,af.bankname) bankname, tl.txdesc trdesc
            FROM tllog TL,adschd ads ,afmast af,tltx, tlprofiles mk,tlprofiles ck,citran ci
            where tl.msgamt =ads.autoid
            and ci.txdate = tl.txdate
            and ci.txnum = tl.txnum
            and TL.msgacct = af.acctno
            and tltx.tltxcd = tl.tltxcd
            and  tl.tlid = mk.tlid(+)
            and af.ALTERNATEACCT like v_strALTERNATEACCT
            and  tl.OFFID =ck.tlid(+)
            and tl.tltxcd in ('1178')
            --and decode (V_STRTYPEDATE,'002',TL.busdate,TL.txdate)>=to_date(F_DATE,'DD/MM/YYYY')
            --AND decode (V_STRTYPEDATE,'002',TL.busdate,TL.txdate)<=to_date(T_DATE,'DD/MM/YYYY')
            and TL.busdate  = v_currdate
            AND TL.TLTXCD LIKE V_STRTLTXCD
            and  nvl(tl.brid,V_STRBRID) like V_STRBRID
     /*       AND NVL( TL.TLID,'-') LIKE V_STRMAKER
            AND NVL( TL.OFFID,'-') LIKE V_STRCHECKER
            AND ci.corebank  LIKE V_STRCOREBANK
            AND CF.custodycd LIKE V_STRPV_CUSTODYCD
            AND AF.acctno LIKE V_STRPV_AFACCTNO*/
            --and exists (select gu.grpid from tlgrpusers gu where af.careby = gu.grpid and gu.tlid = V_STRTLID )
            --nhom bank
            --'1131','1132','1136','1141'
            union

            SELECT  AF.CUSTID, af.careby,  tl.tltxcd ,tltx.txdesc ,tl.txnum,tl.busdate ,tl.txdate,af.acctno, '' custodycdc,'' acctnoc,tl.msgamt amt,nvl(mk.tlname,'') mk,nvl(ck.tlname,'')  ck,nvl(tl.brid,'') brid,nvl(tl.tlid,'') tlid,nvl(tl.OFFID,'') OFFID
            ,nvl(bank.fullname,' ') bankid,ci.corebank ,decode(af.bankname,'---',V_SYSNAME,af.bankname) bankname, tl.txdesc trdesc
            FROM tllog TL,afmast af,tltx, tlprofiles mk,tlprofiles ck,tllogfld tlfld,banknostro bank,citran ci
            where tl.msgacct=af.acctno
            and ci.txdate = tl.txdate
            and ci.txnum = tl.txnum
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
            and TL.busdate = v_currdate
            AND TL.TLTXCD LIKE V_STRTLTXCD
            and  nvl(tl.brid,V_STRBRID) like V_STRBRID
           /* AND NVL( TL.TLID,'-') LIKE V_STRMAKER
            AND NVL( TL.OFFID,'-') LIKE V_STRCHECKER
            AND ci.corebank  LIKE V_STRCOREBANK
            AND CF.custodycd LIKE V_STRPV_CUSTODYCD
            AND AF.acctno LIKE V_STRPV_AFACCTNO*/
            --and exists (select gu.grpid from tlgrpusers gu where af.careby = gu.grpid and gu.tlid = V_STRTLID )
            -- dfgroup
            union
            SELECT  AF.CUSTID,af.careby, tl.tltxcd,tltx.txdesc ,tl.txnum,tl.busdate ,tl.txdate,af.acctno, '' custodycdc,'' acctnoc,CI.NAMT amt,nvl(mk.tlname,'') mk,nvl(ck.tlname,'')  ck,nvl(tl.brid,'') brid,nvl(tl.tlid,'') tlid,nvl(tl.OFFID,'') OFFID,
            nvl(CFB.shortname,'') bankid ,ci.corebank ,decode(af.bankname,'---',V_SYSNAME,af.bankname) bankname, CI.trdesc trdesc
            FROM tllog TL,dfgroup dfg ,afmast af,tltx, tlprofiles mk,tlprofiles ck,
             lnmast ln,lntype , CFMAST CFB,(
                select ci.corebank, ci.autoid,
                    ci.txnum, ci.txdate, ci.acctno, ci.txcd, ci.namt,
                    ci.camt, ci.ref, nvl(ci.deltd,'N') deltd, ci.acctref,
                    tl.tltxcd, tl.busdate,
                    case when tl.tlid ='6868' then trim(tl.txdesc) || ' (Online)' else tl.txdesc end txdesc,
                    tl.txtime, tl.brid, tl.tlid, tl.offid, tl.chid,
                    ''  dfacctno,
                    ''  old_dfacctno,
                    app.txtype, app.field, tl.autoid tllog_autoid,
                    case when ci.trdesc is not null
                            then (case when tl.tlid ='6868' then trim(ci.trdesc) || ' (Online)' else ci.trdesc end)
                            else ci.trdesc end trdesc
                from citran ci, tllog tl,  afmast af, apptx app
                where ci.txdate = tl.txdate and ci.txnum = tl.txnum

                    and ci.acctno = af.acctno
                    and ci.txcd = app.txcd and app.apptype = 'CI' and app.txtype in ('D','C')
                    and tl.deltd <> 'Y'
                    and ci.namt <> 0
            ) CI
            where tl.msgacct= dfg.groupid and dfg.afacctno = af.acctno
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
            and TL.busdate  = v_currdate
            AND TL.TLTXCD LIKE V_STRTLTXCD
            and  nvl(tl.brid,V_STRBRID) like V_STRBRID
          /*  AND NVL( TL.TLID,'-') LIKE V_STRMAKER
            AND NVL( TL.OFFID,'-') LIKE V_STRCHECKER
            AND ci.corebank  LIKE V_STRCOREBANK
            AND CF.custodycd LIKE V_STRPV_CUSTODYCD
            AND AF.acctno LIKE V_STRPV_AFACCTNO*/
            --and exists (select gu.grpid from tlgrpusers gu where af.careby = gu.grpid and gu.tlid = V_STRTLID )

            union
            SELECT  AF.CUSTID, af.careby,  tl.tltxcd ,tltx.txdesc ,tl.txnum,tl.busdate ,tl.txdate,af.acctno, '' custodycdc,'' acctnoc,ci.NAMT amt,nvl(mk.tlname,'') mk,nvl(ck.tlname,'')  ck,nvl(tl.brid,'') brid,nvl(tl.tlid,'') tlid,nvl(tl.OFFID,'') OFFID,
            nvl(CFB.shortname,'') bankid ,ci.corebank ,decode(af.bankname,'---',V_SYSNAME,af.bankname) bankname,ci.trdesc
            FROM tllog TL,afmast af,tltx, tlprofiles mk,tlprofiles ck,
             (
                select ci.corebank, ci.autoid,
                    ci.txnum, ci.txdate, ci.acctno, ci.txcd, ci.namt,
                    ci.camt, ci.ref, nvl(ci.deltd,'N') deltd, ci.acctref,
                    tl.tltxcd, tl.busdate,
                    case when tl.tlid ='6868' then trim(tl.txdesc) || ' (Online)' else tl.txdesc end txdesc,
                    tl.txtime, tl.brid, tl.tlid, tl.offid, tl.chid,
                    ''  dfacctno,
                    ''  old_dfacctno,
                    app.txtype, app.field, tl.autoid tllog_autoid,
                    case when ci.trdesc is not null
                            then (case when tl.tlid ='6868' then trim(ci.trdesc) || ' (Online)' else ci.trdesc end)
                            else ci.trdesc end trdesc
                from citran ci, tllog tl, afmast af, apptx app
                where ci.txdate = tl.txdate and ci.txnum = tl.txnum

                    and ci.acctno = af.acctno
                    and ci.txcd = app.txcd and app.apptype = 'CI' and app.txtype in ('D','C')
                    and tl.deltd <> 'Y'
                    and ci.namt <> 0
            ) ci,
             lnmast ln,lntype , CFMAST CFB
            where tl.msgacct=af.acctno
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
            and TL.busdate  = v_currdate
            AND TL.TLTXCD LIKE V_STRTLTXCD
            and  nvl(tl.brid,V_STRBRID) like V_STRBRID
        /*    AND NVL( TL.TLID,'-') LIKE V_STRMAKER
            AND NVL( TL.OFFID,'-') LIKE V_STRCHECKER
            AND ci.corebank  LIKE V_STRCOREBANK
            AND CF.custodycd LIKE V_STRPV_CUSTODYCD
            AND AF.acctno LIKE V_STRPV_AFACCTNO*/
            --and exists (select gu.grpid from tlgrpusers gu where af.careby = gu.grpid and gu.tlid = V_STRTLID )

            union
            SELECT  AF.CUSTID, af.careby,  tl.tltxcd ,tltx.txdesc ,tl.txnum,tl.busdate ,tl.txdate,af.acctno, '' custodycdc,'' acctnoc,tl.msgamt amt,nvl(mk.tlname,'') mk,nvl(ck.tlname,'')  ck,nvl(tl.brid,'') brid,nvl(tl.tlid,'') tlid,nvl(tl.OFFID,'') OFFID,
            nvl(CFB.shortname,'') bankid ,ci.corebank ,decode(af.bankname,'---',V_SYSNAME,af.bankname) bankname, tl.txdesc trdesc
            FROM tllog TL,afmast af,tltx, tlprofiles mk,tlprofiles ck,  tllogfld tlfld, lnmast ln,lntype , CFMAST CFB,citran ci
            where tl.msgacct=af.acctno
            and tltx.tltxcd = tl.tltxcd
            and ci.txdate = tl.txdate
            and ci.txnum = tl.txnum
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
            and TL.busdate  = v_currdate
            AND TL.TLTXCD LIKE V_STRTLTXCD
            and  nvl(tl.brid,V_STRBRID) like V_STRBRID
  /*          AND NVL( TL.TLID,'-') LIKE V_STRMAKER
            AND NVL( TL.OFFID,'-') LIKE V_STRCHECKER
            AND ci.corebank  LIKE V_STRCOREBANK
            AND CF.custodycd LIKE V_STRPV_CUSTODYCD
            AND AF.acctno LIKE V_STRPV_AFACCTNO*/
            --and exists (select gu.grpid from tlgrpusers gu where af.careby = gu.grpid and gu.tlid = V_STRTLID )

            union
            SELECT  AF.CUSTID,af.careby,  tl.tltxcd   tltxcd ,tltx.txdesc ,tl.txnum,tl.busdate ,tl.txdate,af.acctno, '' custodycdc,'' acctnoc,ci.namt amt,nvl(mk.tlname,'') mk,nvl(ck.tlname,'')  ck,nvl(tl.brid,'') brid,nvl(tl.tlid,'') tlid,nvl(tl.OFFID,'') OFFID,
            ''bankid,ci.corebank ,decode(af.bankname,'---',V_SYSNAME,af.bankname) bankname,CI.trdesc
            FROM tllog TL,afmast af,tltx, tlprofiles mk,tlprofiles ck,
             (
                select ci.corebank, ci.autoid,
                    ci.txnum, ci.txdate, ci.acctno, ci.txcd, ci.namt,
                    ci.camt, ci.ref, nvl(ci.deltd,'N') deltd, ci.acctref,
                    tl.tltxcd, tl.busdate,
                    case when tl.tlid ='6868' then trim(tl.txdesc) || ' (Online)' else tl.txdesc end txdesc,
                    tl.txtime, tl.brid, tl.tlid, tl.offid, tl.chid,
                    ''  dfacctno,
                    ''  old_dfacctno,
                    app.txtype, app.field, tl.autoid tllog_autoid,
                    case when ci.trdesc is not null
                            then (case when tl.tlid ='6868' then trim(ci.trdesc) || ' (Online)' else ci.trdesc end)
                            else ci.trdesc end trdesc
                from citran ci, tllog tl,  afmast af, apptx app
                where ci.txdate = tl.txdate and ci.txnum = tl.txnum

                    and ci.acctno = af.acctno
                    and ci.txcd = app.txcd and app.apptype = 'CI' and app.txtype in ('D','C')
                    and tl.deltd <> 'Y'
                    and ci.namt <> 0
            )   ci
            where ci.acctno=af.acctno
            and tltx.tltxcd = tl.tltxcd
            and  tl.tlid = mk.tlid(+)
            and  tl.OFFID =ck.tlid(+)
            and af.ALTERNATEACCT like v_strALTERNATEACCT
            and tl.txdate = ci.txdate
            and tl.txnum = ci.txnum
            and tl.tltxcd  IN ('0088','1670','1610','1110','1600','1620','1137','1138','3384') --chaunh add 3384
            and ci.field ='BALANCE'
            --and decode (V_STRTYPEDATE,'002',TL.busdate,TL.txdate)>=to_date(F_DATE,'DD/MM/YYYY')
            --AND decode (V_STRTYPEDATE,'002',TL.busdate,TL.txdate)<=to_date(T_DATE,'DD/MM/YYYY')
            and TL.busdate = v_currdate
            AND TL.TLTXCD LIKE V_STRTLTXCD
            and  nvl(tl.brid,V_STRBRID) like V_STRBRID
/*            AND NVL( TL.TLID,'-') LIKE V_STRMAKER
            AND NVL( TL.OFFID,'-') LIKE V_STRCHECKER
            AND ci.corebank  LIKE V_STRCOREBANK
            AND CF.custodycd LIKE V_STRPV_CUSTODYCD
            AND AF.acctno LIKE V_STRPV_AFACCTNO*/
            --and exists (select gu.grpid from tlgrpusers gu where af.careby = gu.grpid and gu.tlid = V_STRTLID )
            )a

             WHERE CF.CUSTID=A.CUSTID
            AND NVL( A.TLID,'-') LIKE V_STRMAKER
            AND NVL( A.OFFID,'-') LIKE V_STRCHECKER
            AND A.corebank  LIKE V_STRCOREBANK
            AND CF.custodycd LIKE V_STRPV_CUSTODYCD
            AND A.acctno LIKE V_STRPV_AFACCTNO

            ORDER BY A.TLTXCD ,a.busdate,A.TXNUM
            ;
        else
            OPEN PV_REFCURSOR
            FOR
                select  A.careby, A.tltxcd,A.txdesc ,A.txnum,A.busdate ,A.txdate, CF.CUSTODYCD,A.acctno,
            A.custodycdc,A.acctnoc,A.amt,A.mk,A.ck,
            CF.brid,A.tlid,A.OFFID, A.bankid,A.corebank ,A.bankname,A.trdesc
              from
             (SELECT * FROM CFMAST WHERE FNC_VALIDATE_SCOPE(BRID, CAREBY, TLSCOPE, pv_BRID, TLGOUPS)=0) cf,
             (
            select AF.CUSTID, af.careby, tl.tltxcd,tltx.txdesc ,tl.txnum,tl.busdate ,tl.txdate,af.acctno, cfc.custodycd custodycdc,afc.acctno acctnoc,tl.msgamt amt,nvl(mk.tlname,'') mk,nvl(ck.tlname,'')  ck,nvl(tl.brid,'') brid,nvl(tl.tlid,'') tlid,nvl(tl.OFFID,'') OFFID,
            ''bankid,ci.corebank ,decode(af.bankname,'---',V_SYSNAME,af.bankname) bankname,ci.trdesc
            from tllog TL ,(
                select ci.corebank, ci.autoid,
                    ci.txnum, ci.txdate, ci.acctno, ci.txcd, ci.namt,
                    ci.camt, ci.ref, nvl(ci.deltd,'N') deltd, ci.acctref,
                    tl.tltxcd, tl.busdate,
                    case when tl.tlid ='6868' then trim(tl.txdesc) || ' (Online)' else tl.txdesc end txdesc,
                    tl.txtime, tl.brid, tl.tlid, tl.offid, tl.chid,
                    ''  dfacctno,
                    ''  old_dfacctno,
                    app.txtype, app.field, tl.autoid tllog_autoid,
                    case when ci.trdesc is not null
                            then (case when tl.tlid ='6868' then trim(ci.trdesc) || ' (Online)' else ci.trdesc end)
                            else ci.trdesc end trdesc
                from citran ci, tllog tl, afmast af, apptx app
                where ci.txdate = tl.txdate and ci.txnum = tl.txnum

                    and ci.acctno = af.acctno
                    and ci.txcd = app.txcd and app.apptype = 'CI' and app.txtype in ('D','C')
                    and tl.deltd <> 'Y'
                    and ci.namt <> 0
            ) ci,afmast af, afmast afc,cfmast cfc ,tltx  , tlprofiles mk,tlprofiles ck
            where tl.txnum =ci.txnum and tl.txdate =ci.txdate and ci.acctno= af.acctno
            and ci.ref =afc.acctno and afc.custid =cfc.custid
            and tltx.tltxcd = tl.tltxcd
            and  tl.tlid = mk.tlid(+)
            and  tl.OFFID =ck.tlid(+)
            and tl.tltxcd in ('1120','1130','1134') and ci.field ='BALANCE' and ci.txtype='D'
            --and decode (V_STRTYPEDATE,'002',TL.busdate,TL.txdate)>=to_date(F_DATE,'DD/MM/YYYY')
            --AND decode (V_STRTYPEDATE,'002',TL.busdate,TL.txdate)<=to_date(T_DATE,'DD/MM/YYYY')
            and TL.txdate  = v_currdate
            AND TL.TLTXCD LIKE V_STRTLTXCD
            and  nvl(tl.brid,V_STRBRID) like V_STRBRID
            and af.ALTERNATEACCT like v_strALTERNATEACCT
/*            AND NVL( TL.TLID,'-') LIKE V_STRMAKER
            AND NVL( TL.OFFID,'-') LIKE V_STRCHECKER
            AND ci.corebank  LIKE V_STRCOREBANK
            AND CF.custodycd LIKE V_STRPV_CUSTODYCD
            AND AF.acctno LIKE V_STRPV_AFACCTNO*/
            --and exists (select gu.grpid from tlgrpusers gu where af.careby = gu.grpid and gu.tlid = V_STRTLID )

            union
            SELECT AF.CUSTID,af.careby, case when  tl.tltxcd in ('3350','3354') then '3342' else  tl.tltxcd end  tltxcd ,
            tltx.txdesc ,tl.txnum,tl.busdate ,tl.txdate,af.acctno, '' custodycdc,'' acctnoc,tl.msgamt amt,nvl(mk.tlname,'') mk,nvl(ck.tlname,'')  ck,nvl(tl.brid,'') brid,nvl(tl.tlid,'') tlid,nvl(tl.OFFID,'') OFFID,
            ''bankid,ci.corebank ,decode(af.bankname,'---',V_SYSNAME,af.bankname) bankname , tl.txdesc trdesc
            FROM tllog TL,afmast af,tltx, tlprofiles mk,tlprofiles ck,citran ci
            where substr(tl.msgacct,0,10)=af.acctno
            and tltx.tltxcd = tl.tltxcd
            and ci.txdate = tl.txdate
            and ci.txnum = tl.txnum
            and  tl.tlid = mk.tlid(+)
            and af.ALTERNATEACCT like v_strALTERNATEACCT
            and  tl.OFFID =ck.tlid(+)
            and tl.tltxcd in ('1140','1100','1107','1101'
            ,'1104','1108','1111','1114','1104','1112','1145','1144'
            ,'1123','1124','1126','1127','1162','1180','1182','6613','1105','1198','1199','8866','1190','1191'
            ,'8856','0066','8889','8894','8851','5541','1146') --Chaunh bo 3384
            --and decode (V_STRTYPEDATE,'002',TL.busdate,TL.txdate)>=to_date(F_DATE,'DD/MM/YYYY')
            --AND decode (V_STRTYPEDATE,'002',TL.busdate,TL.txdate)<=to_date(T_DATE,'DD/MM/YYYY')
            and TL.txdate  = v_currdate
            AND TL.TLTXCD LIKE V_STRTLTXCD

            and  nvl(tl.brid,V_STRBRID) like V_STRBRID
          /*  AND NVL( TL.TLID,'-') LIKE V_STRMAKER
            AND NVL( TL.OFFID,'-') LIKE V_STRCHECKER
            AND ci.corebank  LIKE V_STRCOREBANK
            AND CF.custodycd LIKE V_STRPV_CUSTODYCD
            AND AF.acctno LIKE V_STRPV_AFACCTNO*/
            --and exists (select gu.grpid from tlgrpusers gu where af.careby = gu.grpid and gu.tlid = V_STRTLID )
            union
            SELECT  AF.CUSTID, af.careby, tl.tltxcd||'T'|| '0' tltxcd ,tltx.txdesc ,tl.txnum,tl.busdate ,tl.txdate,
            af.acctno, '' custodycdc,'' acctnoc,tl.msgamt amt,nvl(mk.tlname,'') mk,nvl(ck.tlname,'')  ck,nvl(tl.brid,'') brid,nvl(tl.tlid,'') tlid,nvl(tl.OFFID,'') OFFID,
            ''bankid,ci.corebank ,decode(af.bankname,'---',V_SYSNAME,af.bankname) bankname,ci.trdesc
            FROM tllog TL,afmast af,tltx, tlprofiles mk,tlprofiles ck,(
                select ci.corebank, ci.autoid,
                    ci.txnum, ci.txdate, ci.acctno, ci.txcd, ci.namt,
                    ci.camt, ci.ref, nvl(ci.deltd,'N') deltd, ci.acctref,
                    tl.tltxcd, tl.busdate,
                    case when tl.tlid ='6868' then trim(tl.txdesc) || ' (Online)' else tl.txdesc end txdesc,
                    tl.txtime, tl.brid, tl.tlid, tl.offid, tl.chid,
                    ''  dfacctno,
                    ''  old_dfacctno,
                    app.txtype, app.field, tl.autoid tllog_autoid,
                    case when ci.trdesc is not null
                            then (case when tl.tlid ='6868' then trim(ci.trdesc) || ' (Online)' else ci.trdesc end)
                            else ci.trdesc end trdesc
                from citran ci, tllog tl,  afmast af, apptx app
                where ci.txdate = tl.txdate and ci.txnum = tl.txnum

                    and ci.acctno = af.acctno
                    and ci.txcd = app.txcd and app.apptype = 'CI' and app.txtype in ('D','C')
                    and tl.deltd <> 'Y'
                    and ci.namt <> 0
            ) CI, stschd sts
            where tl.msgacct=af.acctno
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
            and TL.txdate  = v_currdate
            AND TL.TLTXCD LIKE V_STRTLTXCD

            and  nvl(tl.brid,V_STRBRID) like V_STRBRID
/*            AND NVL( TL.TLID,'-') LIKE V_STRMAKER
            AND NVL( TL.OFFID,'-') LIKE V_STRCHECKER
            AND ci.corebank  LIKE V_STRCOREBANK
            AND CF.custodycd LIKE V_STRPV_CUSTODYCD
            AND AF.acctno LIKE V_STRPV_AFACCTNO*/
            --and exists (select gu.grpid from tlgrpusers gu where af.careby = gu.grpid and gu.tlid = V_STRTLID )
            union
            SELECT AF.CUSTID,af.careby, case when  tl.tltxcd in ('3350','3354') then '3342' else  tl.tltxcd end  tltxcd ,
            tltx.txdesc ,tl.txnum,tl.busdate ,tl.txdate,af.acctno, '' custodycdc,'' acctnoc,tl.msgamt amt,nvl(mk.tlname,'') mk,nvl(ck.tlname,'')  ck,nvl(tl.brid,'') brid,nvl(tl.tlid,'') tlid,nvl(tl.OFFID,'') OFFID,
            ''bankid,ci.corebank ,decode(af.bankname,'---',V_SYSNAME,af.bankname) bankname,ci.trdesc
            FROM tllog TL,afmast af,tltx, tlprofiles mk,tlprofiles ck,(
                select ci.corebank, ci.autoid,
                    ci.txnum, ci.txdate, ci.acctno, ci.txcd, ci.namt,
                    ci.camt, ci.ref, nvl(ci.deltd,'N') deltd, ci.acctref,
                    tl.tltxcd, tl.busdate,
                    case when tl.tlid ='6868' then trim(tl.txdesc) || ' (Online)' else tl.txdesc end txdesc,
                    tl.txtime, tl.brid, tl.tlid, tl.offid, tl.chid,
                    ''  dfacctno,
                    ''  old_dfacctno,
                    app.txtype, app.field, tl.autoid tllog_autoid,
                    case when ci.trdesc is not null
                            then (case when tl.tlid ='6868' then trim(ci.trdesc) || ' (Online)' else ci.trdesc end)
                            else ci.trdesc end trdesc
                from citran ci, tllog tl, afmast af, apptx app
                where ci.txdate = tl.txdate and ci.txnum = tl.txnum

                    and ci.acctno = af.acctno
                    and ci.txcd = app.txcd and app.apptype = 'CI' and app.txtype in ('D','C')
                    and tl.deltd <> 'Y'
                    and ci.namt <> 0
            ) CI
            where tl.msgacct=af.acctno
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
            and TL.txdate  = v_currdate

            AND case when  tl.tltxcd in ('3350','3354') then '3342' else  tl.tltxcd end  LIKE V_STRTLTXCD
            and  nvl(tl.brid,V_STRBRID) like V_STRBRID
   /*         AND NVL( TL.TLID,'-') LIKE V_STRMAKER
            AND NVL( TL.OFFID,'-') LIKE V_STRCHECKER
            AND ci.corebank  LIKE V_STRCOREBANK
            AND CF.custodycd LIKE V_STRPV_CUSTODYCD
            AND AF.acctno LIKE V_STRPV_AFACCTNO*/
            --and exists (select gu.grpid from tlgrpusers gu where af.careby = gu.grpid and gu.tlid = V_STRTLID )
            UNION
            SELECT AF.CUSTID, af.careby,  tl.tltxcd ,tltx.txdesc ,tl.txnum,tl.busdate ,tl.txdate,af.acctno, '' custodycdc,'' acctnoc,CI.NAMT amt,nvl(mk.tlname,'') mk,nvl(ck.tlname,'')  ck,nvl(tl.brid,'') brid,nvl(tl.tlid,'') tlid,nvl(tl.OFFID,'') OFFID,
            ''bankid,ci.corebank ,decode(af.bankname,'---',V_SYSNAME,af.bankname) bankname,ci.trdesc
            FROM tllog TL,afmast af,tltx, tlprofiles mk,tlprofiles ck,(
                select ci.corebank, ci.autoid,
                    ci.txnum, ci.txdate, ci.acctno, ci.txcd, ci.namt,
                    ci.camt, ci.ref, nvl(ci.deltd,'N') deltd, ci.acctref,
                    tl.tltxcd, tl.busdate,
                    case when tl.tlid ='6868' then trim(tl.txdesc) || ' (Online)' else tl.txdesc end txdesc,
                    tl.txtime, tl.brid, tl.tlid, tl.offid, tl.chid,
                    ''  dfacctno,
                    ''  old_dfacctno,
                    app.txtype, app.field, tl.autoid tllog_autoid,
                    case when ci.trdesc is not null
                            then (case when tl.tlid ='6868' then trim(ci.trdesc) || ' (Online)' else ci.trdesc end)
                            else ci.trdesc end trdesc
                from citran ci, tllog tl,  afmast af, apptx app
                where ci.txdate = tl.txdate and ci.txnum = tl.txnum

                    and ci.acctno = af.acctno
                    and ci.txcd = app.txcd and app.apptype = 'CI' and app.txtype in ('D','C')
                    and tl.deltd <> 'Y'
                    and ci.namt <> 0
            ) CI
            where tl.msgacct=af.acctno
            and tltx.tltxcd = tl.tltxcd
            and  tl.tlid = mk.tlid(+)
            and  tl.OFFID =ck.tlid(+)
            AND TL.TXDATE = CI.TXDATE
            and af.ALTERNATEACCT like v_strALTERNATEACCT
            AND TL.TXNUM = CI.TXNUM
            AND CI.field ='BALANCE'
            and tl.tltxcd in('1153','8865','1139','3386')
            --and decode (V_STRTYPEDATE,'002',TL.busdate,TL.txdate)>=to_date(F_DATE,'DD/MM/YYYY')
            --AND decode (V_STRTYPEDATE,'002',TL.busdate,TL.txdate)<=to_date(T_DATE,'DD/MM/YYYY')
            and TL.txdate  = v_currdate
            AND TL.TLTXCD LIKE V_STRTLTXCD

            and  nvl(tl.brid,V_STRBRID) like V_STRBRID
/*            AND NVL( TL.TLID,'-') LIKE V_STRMAKER
            AND NVL( TL.OFFID,'-') LIKE V_STRCHECKER
            AND ci.corebank  LIKE V_STRCOREBANK
            AND CF.custodycd LIKE V_STRPV_CUSTODYCD
            AND AF.acctno LIKE V_STRPV_AFACCTNO*/
            --and exists (select gu.grpid from tlgrpusers gu where af.careby = gu.grpid and gu.tlid = V_STRTLID )

            --1178
            union
            SELECT AF.CUSTID,af.careby, tl.tltxcd,tltx.txdesc ,tl.txnum,tl.busdate ,tl.txdate,af.acctno, '' custodycdc,'' acctnoc,ads.amt amt,nvl(mk.tlname,'') mk,nvl(ck.tlname,'')  ck,nvl(tl.brid,'') brid,nvl(tl.tlid,'') tlid,nvl(tl.OFFID,'') OFFID,
            '' bankid,ci.corebank ,decode(af.bankname,'---',V_SYSNAME,af.bankname) bankname, tl.txdesc trdesc
            FROM tllog TL,adschd ads ,afmast af,tltx, tlprofiles mk,tlprofiles ck,citran ci
            where tl.msgamt =ads.autoid
            and ci.txdate = tl.txdate
            and ci.txnum = tl.txnum
            and TL.msgacct = af.acctno
            and tltx.tltxcd = tl.tltxcd
            and  tl.tlid = mk.tlid(+)
            and af.ALTERNATEACCT like v_strALTERNATEACCT
            and  tl.OFFID =ck.tlid(+)
            and tl.tltxcd in ('1178')
            --and decode (V_STRTYPEDATE,'002',TL.busdate,TL.txdate)>=to_date(F_DATE,'DD/MM/YYYY')
            --AND decode (V_STRTYPEDATE,'002',TL.busdate,TL.txdate)<=to_date(T_DATE,'DD/MM/YYYY')
            and TL.txdate = v_currdate
            AND TL.TLTXCD LIKE V_STRTLTXCD

            and  nvl(tl.brid,V_STRBRID) like V_STRBRID
/*            AND NVL( TL.TLID,'-') LIKE V_STRMAKER
            AND NVL( TL.OFFID,'-') LIKE V_STRCHECKER
            AND ci.corebank  LIKE V_STRCOREBANK
            AND CF.custodycd LIKE V_STRPV_CUSTODYCD
            AND AF.acctno LIKE V_STRPV_AFACCTNO*/
            --and exists (select gu.grpid from tlgrpusers gu where af.careby = gu.grpid and gu.tlid = V_STRTLID )
            --nhom bank
            --'1131','1132','1136','1141'
            union

            SELECT AF.CUSTID, af.careby,  tl.tltxcd ,tltx.txdesc ,tl.txnum,tl.busdate ,tl.txdate,af.acctno, '' custodycdc,'' acctnoc,tl.msgamt amt,nvl(mk.tlname,'') mk,nvl(ck.tlname,'')  ck,nvl(tl.brid,'') brid,nvl(tl.tlid,'') tlid,nvl(tl.OFFID,'') OFFID
            ,nvl(bank.fullname,' ') bankid,ci.corebank ,decode(af.bankname,'---',V_SYSNAME,af.bankname) bankname, tl.txdesc trdesc
            FROM tllog TL,afmast af,tltx, tlprofiles mk,tlprofiles ck,tllogfld tlfld,banknostro bank,citran ci
            where tl.msgacct=af.acctno
            and ci.txdate = tl.txdate  and ci.txnum = tl.txnum
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
            and TL.txdate = v_currdate
            AND TL.TLTXCD LIKE V_STRTLTXCD

            and  nvl(tl.brid,V_STRBRID) like V_STRBRID
/*            AND NVL( TL.TLID,'-') LIKE V_STRMAKER
            AND NVL( TL.OFFID,'-') LIKE V_STRCHECKER
            AND ci.corebank  LIKE V_STRCOREBANK
            AND CF.custodycd LIKE V_STRPV_CUSTODYCD
            AND AF.acctno LIKE V_STRPV_AFACCTNO*/
            --and exists (select gu.grpid from tlgrpusers gu where af.careby = gu.grpid and gu.tlid = V_STRTLID )
            -- dfgroup
            union
            SELECT AF.CUSTID,af.careby, tl.tltxcd,tltx.txdesc ,tl.txnum,tl.busdate ,tl.txdate,af.acctno, '' custodycdc,'' acctnoc,CI.NAMT amt,nvl(mk.tlname,'') mk,nvl(ck.tlname,'')  ck,nvl(tl.brid,'') brid,nvl(tl.tlid,'') tlid,nvl(tl.OFFID,'') OFFID,
            nvl(CFB.shortname,'') bankid ,ci.corebank ,decode(af.bankname,'---',V_SYSNAME,af.bankname) bankname, CI.trdesc trdesc
            FROM tllog TL,dfgroup dfg ,afmast af,tltx, tlprofiles mk,tlprofiles ck,
             lnmast ln,lntype , CFMAST CFB,(
                select ci.corebank, ci.autoid,
                    ci.txnum, ci.txdate, ci.acctno, ci.txcd, ci.namt,
                    ci.camt, ci.ref, nvl(ci.deltd,'N') deltd, ci.acctref,
                    tl.tltxcd, tl.busdate,
                    case when tl.tlid ='6868' then trim(tl.txdesc) || ' (Online)' else tl.txdesc end txdesc,
                    tl.txtime, tl.brid, tl.tlid, tl.offid, tl.chid,
                    ''  dfacctno,
                    ''  old_dfacctno,
                    app.txtype, app.field, tl.autoid tllog_autoid,
                    case when ci.trdesc is not null
                            then (case when tl.tlid ='6868' then trim(ci.trdesc) || ' (Online)' else ci.trdesc end)
                            else ci.trdesc end trdesc
                from citran ci, tllog tl,  afmast af, apptx app
                where ci.txdate = tl.txdate and ci.txnum = tl.txnum

                    and ci.acctno = af.acctno
                    and ci.txcd = app.txcd and app.apptype = 'CI' and app.txtype in ('D','C')
                    and tl.deltd <> 'Y'
                    and ci.namt <> 0
            ) CI
            where tl.msgacct= dfg.groupid and dfg.afacctno = af.acctno
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
            and TL.txdate = v_currdate
            AND TL.TLTXCD LIKE V_STRTLTXCD

            and  nvl(tl.brid,V_STRBRID) like V_STRBRID
         /*   AND NVL( TL.TLID,'-') LIKE V_STRMAKER
            AND NVL( TL.OFFID,'-') LIKE V_STRCHECKER
            AND ci.corebank  LIKE V_STRCOREBANK
            AND CF.custodycd LIKE V_STRPV_CUSTODYCD
            AND AF.acctno LIKE V_STRPV_AFACCTNO*/
            --and exists (select gu.grpid from tlgrpusers gu where af.careby = gu.grpid and gu.tlid = V_STRTLID )

            union
            SELECT AF.CUSTID, af.careby,  tl.tltxcd ,tltx.txdesc ,tl.txnum,tl.busdate ,tl.txdate,af.acctno, '' custodycdc,'' acctnoc,ci.NAMT amt,nvl(mk.tlname,'') mk,nvl(ck.tlname,'')  ck,nvl(tl.brid,'') brid,nvl(tl.tlid,'') tlid,nvl(tl.OFFID,'') OFFID,
            nvl(CFB.shortname,'') bankid ,ci.corebank ,decode(af.bankname,'---',V_SYSNAME,af.bankname) bankname,ci.trdesc
            FROM tllog TL,afmast af,tltx, tlprofiles mk,tlprofiles ck,
             (
                select ci.corebank, ci.autoid,
                    ci.txnum, ci.txdate, ci.acctno, ci.txcd, ci.namt,
                    ci.camt, ci.ref, nvl(ci.deltd,'N') deltd, ci.acctref,
                    tl.tltxcd, tl.busdate,
                    case when tl.tlid ='6868' then trim(tl.txdesc) || ' (Online)' else tl.txdesc end txdesc,
                    tl.txtime, tl.brid, tl.tlid, tl.offid, tl.chid,
                    ''  dfacctno,
                    ''  old_dfacctno,
                    app.txtype, app.field, tl.autoid tllog_autoid,
                    case when ci.trdesc is not null
                            then (case when tl.tlid ='6868' then trim(ci.trdesc) || ' (Online)' else ci.trdesc end)
                            else ci.trdesc end trdesc
                from citran ci, tllog tl, afmast af, apptx app
                where ci.txdate = tl.txdate and ci.txnum = tl.txnum

                    and ci.acctno = af.acctno
                    and ci.txcd = app.txcd and app.apptype = 'CI' and app.txtype in ('D','C')
                    and tl.deltd <> 'Y'
                    and ci.namt <> 0
            ) ci,
             lnmast ln,lntype , CFMAST CFB
            where tl.msgacct=af.acctno
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
            and TL.txdate = v_currdate
            AND TL.TLTXCD LIKE V_STRTLTXCD

            and  nvl(tl.brid,V_STRBRID) like V_STRBRID
  /*          AND NVL( TL.TLID,'-') LIKE V_STRMAKER
            AND NVL( TL.OFFID,'-') LIKE V_STRCHECKER
            AND ci.corebank  LIKE V_STRCOREBANK
            AND CF.custodycd LIKE V_STRPV_CUSTODYCD
            AND AF.acctno LIKE V_STRPV_AFACCTNO*/
            --and exists (select gu.grpid from tlgrpusers gu where af.careby = gu.grpid and gu.tlid = V_STRTLID )

            union
            SELECT AF.CUSTID, af.careby,  tl.tltxcd ,tltx.txdesc ,tl.txnum,tl.busdate ,tl.txdate,af.acctno, '' custodycdc,'' acctnoc,tl.msgamt amt,nvl(mk.tlname,'') mk,nvl(ck.tlname,'')  ck,nvl(tl.brid,'') brid,nvl(tl.tlid,'') tlid,nvl(tl.OFFID,'') OFFID,
            nvl(CFB.shortname,'') bankid ,ci.corebank ,decode(af.bankname,'---',V_SYSNAME,af.bankname) bankname, tl.txdesc trdesc
            FROM tllog TL,afmast af,tltx, tlprofiles mk,tlprofiles ck,  tllogfld tlfld, lnmast ln,lntype , CFMAST CFB,citran ci
            where tl.msgacct=af.acctno
            and ci.txdate = tl.txdate  and ci.txnum = tl.txnum
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
            and TL.txdate = v_currdate
            AND TL.TLTXCD LIKE V_STRTLTXCD

            and  nvl(tl.brid,V_STRBRID) like V_STRBRID
    /*        AND NVL( TL.TLID,'-') LIKE V_STRMAKER
            AND NVL( TL.OFFID,'-') LIKE V_STRCHECKER
            AND ci.corebank  LIKE V_STRCOREBANK
            AND CF.custodycd LIKE V_STRPV_CUSTODYCD
            AND AF.acctno LIKE V_STRPV_AFACCTNO*/
            --and exists (select gu.grpid from tlgrpusers gu where af.careby = gu.grpid and gu.tlid = V_STRTLID )

            union
            SELECT AF.CUSTID,af.careby,  tl.tltxcd   tltxcd ,tltx.txdesc ,tl.txnum,tl.busdate ,tl.txdate,af.acctno, '' custodycdc,'' acctnoc,ci.namt amt,nvl(mk.tlname,'') mk,nvl(ck.tlname,'')  ck,nvl(tl.brid,'') brid,nvl(tl.tlid,'') tlid,nvl(tl.OFFID,'') OFFID,
            ''bankid,ci.corebank ,decode(af.bankname,'---',V_SYSNAME,af.bankname) bankname,CI.trdesc
            FROM tllog TL,afmast af,tltx, tlprofiles mk,tlprofiles ck,
             (
                select ci.corebank, ci.autoid,
                    ci.txnum, ci.txdate, ci.acctno, ci.txcd, ci.namt,
                    ci.camt, ci.ref, nvl(ci.deltd,'N') deltd, ci.acctref,
                    tl.tltxcd, tl.busdate,
                    case when tl.tlid ='6868' then trim(tl.txdesc) || ' (Online)' else tl.txdesc end txdesc,
                    tl.txtime, tl.brid, tl.tlid, tl.offid, tl.chid,
                    ''  dfacctno,
                    ''  old_dfacctno,
                    app.txtype, app.field, tl.autoid tllog_autoid,
                    case when ci.trdesc is not null
                            then (case when tl.tlid ='6868' then trim(ci.trdesc) || ' (Online)' else ci.trdesc end)
                            else ci.trdesc end trdesc
                from citran ci, tllog tl,  afmast af, apptx app
                where ci.txdate = tl.txdate and ci.txnum = tl.txnum

                    and ci.acctno = af.acctno
                    and ci.txcd = app.txcd and app.apptype = 'CI' and app.txtype in ('D','C')
                    and tl.deltd <> 'Y'
                    and ci.namt <> 0
            )   ci
            where ci.acctno=af.acctno
            and tltx.tltxcd = tl.tltxcd
            and  tl.tlid = mk.tlid(+)
            and  tl.OFFID =ck.tlid(+)
            and tl.txdate = ci.txdate
            and af.ALTERNATEACCT like v_strALTERNATEACCT
            and tl.txnum = ci.txnum
            and tl.tltxcd  IN ('0088','1670','1610','1110','1600','1620','1137','1138','3384') --chaunh add 3384
            and ci.field ='BALANCE'
            --and decode (V_STRTYPEDATE,'002',TL.busdate,TL.txdate)>=to_date(F_DATE,'DD/MM/YYYY')
            --AND decode (V_STRTYPEDATE,'002',TL.busdate,TL.txdate)<=to_date(T_DATE,'DD/MM/YYYY')
            and TL.txdate = v_currdate
            AND TL.TLTXCD LIKE V_STRTLTXCD

            and  nvl(tl.brid,V_STRBRID) like V_STRBRID
      /*      AND NVL( TL.TLID,'-') LIKE V_STRMAKER
            AND NVL( TL.OFFID,'-') LIKE V_STRCHECKER
            AND ci.corebank  LIKE V_STRCOREBANK
            AND CF.custodycd LIKE V_STRPV_CUSTODYCD
            AND AF.acctno LIKE V_STRPV_AFACCTNO*/
            --and exists (select gu.grpid from tlgrpusers gu where af.careby = gu.grpid and gu.tlid = V_STRTLID )
            )a
            WHERE CF.CUSTID=A.CUSTID
            AND NVL( A.TLID,'-') LIKE V_STRMAKER
            AND NVL( A.OFFID,'-') LIKE V_STRCHECKER
            AND A.corebank  LIKE V_STRCOREBANK
            AND CF.custodycd LIKE V_STRPV_CUSTODYCD
            AND A.acctno LIKE V_STRPV_AFACCTNO
            ORDER BY A.TLTXCD ,a.busdate,A.TXNUM
            ;
        end if;

    END IF ;
ELSE
        IF   TYPEBRID ='002' THEN
            if V_STRTYPEDATE='002' then

                OPEN PV_REFCURSOR
                  FOR
           select  A.careby, A.tltxcd,A.txdesc ,A.txnum,A.busdate ,A.txdate, CF.CUSTODYCD,A.acctno,
             A.custodycdc,A.acctnoc,A.amt,A.mk,A.ck,
             CF.brid,A.tlid,A.OFFID, A.bankid,A.corebank ,A.bankname,A.trdesc
              from
             (SELECT * FROM CFMAST WHERE FNC_VALIDATE_SCOPE(BRID, CAREBY, TLSCOPE, pv_BRID, TLGOUPS)=0) cf,
             (
                select AF.CUSTID, af.careby, tl.tltxcd,tltx.txdesc ,tl.txnum,tl.busdate ,tl.txdate,af.acctno, cfc.custodycd custodycdc,afc.acctno acctnoc,tl.msgamt amt,nvl(mk.tlname,'') mk,nvl(ck.tlname,'')  ck,nvl(AF.brid,'') brid,nvl(tl.tlid,'') tlid,nvl(tl.OFFID,'') OFFID,
                ''bankid,ci.corebank ,decode(af.bankname,'---',V_SYSNAME,af.bankname) bankname,ci.trdesc
                from vw_tllog_all TL ,vw_citran_gen ci,afmast af, afmast afc,cfmast cfc ,tltx  , tlprofiles mk,tlprofiles ck
                where tl.txnum =ci.txnum and tl.txdate =ci.txdate and ci.acctno= af.acctno
                and ci.ref =afc.acctno and afc.custid =cfc.custid
                and af.ALTERNATEACCT like v_strALTERNATEACCT
                and tltx.tltxcd = tl.tltxcd
                and  tl.tlid = mk.tlid(+)
                and  tl.OFFID =ck.tlid(+)
                and tl.tltxcd in ('1120','1130','1134') and ci.field ='BALANCE' and ci.txtype='D'
                --and decode (V_STRTYPEDATE,'002',TL.busdate,TL.txdate)>=to_date(F_DATE,'DD/MM/YYYY')
                --AND decode (V_STRTYPEDATE,'002',TL.busdate,TL.txdate)<=to_date(T_DATE,'DD/MM/YYYY')
                and TL.busdate  >=to_date(F_DATE,'DD/MM/YYYY')
                and TL.busdate  <=to_date(T_DATE,'DD/MM/YYYY')
                AND TL.TLTXCD LIKE V_STRTLTXCD
               /* and  nvl(AF.brid,V_STRBRID) like V_STRBRID
                AND NVL( TL.TLID,'-') LIKE V_STRMAKER
                AND NVL( TL.OFFID,'-') LIKE V_STRCHECKER
                AND ci.corebank  LIKE V_STRCOREBANK
                AND CF.custodycd LIKE V_STRPV_CUSTODYCD
                AND AF.acctno LIKE V_STRPV_AFACCTNO*/
                --and exists (select gu.grpid from tlgrpusers gu where af.careby = gu.grpid and gu.tlid = V_STRTLID )
                union
                SELECT AF.CUSTID,af.careby, case when  tl.tltxcd in ('3350','3354') then '3342' else  tl.tltxcd end  tltxcd ,
                tltx.txdesc ,tl.txnum,tl.busdate ,tl.txdate,af.acctno, '' custodycdc,'' acctnoc,tl.msgamt amt,nvl(mk.tlname,'') mk,nvl(ck.tlname,'')  ck,nvl(AF.brid,'') brid,nvl(tl.tlid,'') tlid,nvl(tl.OFFID,'') OFFID,
                ''bankid,ci.corebank ,decode(af.bankname,'---',V_SYSNAME,af.bankname) bankname , tl.txdesc trdesc
                FROM vw_tllog_all TL,afmast af,tltx, tlprofiles mk,tlprofiles ck,vw_citran_all ci
                where substr(tl.msgacct,0,10)=af.acctno
                and tltx.tltxcd = tl.tltxcd
                and af.ALTERNATEACCT like v_strALTERNATEACCT
                and  tl.tlid = mk.tlid(+)
                and  tl.OFFID =ck.tlid(+)
                and ci.txdate = tl.txdate  and ci.txnum = tl.txnum
                and tl.tltxcd in ('1140','1100','1107','1101'
                ,'1104','1108','1111','1114','1104','1112','1145','1144'
                ,'1123','1124','1126','1127','1162','1180','1182','6613','1105','1198','1199','8866','1190','1191'
                ,'8856','0066','8889','8894','8851','5541','1146') --Chaunh bo 3384
                --and decode (V_STRTYPEDATE,'002',TL.busdate,TL.txdate)>=to_date(F_DATE,'DD/MM/YYYY')
                --AND decode (V_STRTYPEDATE,'002',TL.busdate,TL.txdate)<=to_date(T_DATE,'DD/MM/YYYY')
                and TL.busdate  >=to_date(F_DATE,'DD/MM/YYYY')
                and TL.busdate  <=to_date(T_DATE,'DD/MM/YYYY')
                AND  case when  tl.tltxcd in ('3350','3354') then '3342' else  tl.tltxcd end  LIKE V_STRTLTXCD
             /*   and  nvl(AF.brid,V_STRBRID) like V_STRBRID
                AND NVL( TL.TLID,'-') LIKE V_STRMAKER
                AND NVL( TL.OFFID,'-') LIKE V_STRCHECKER
                AND ci.corebank  LIKE V_STRCOREBANK
                AND CF.custodycd LIKE V_STRPV_CUSTODYCD
                AND AF.acctno LIKE V_STRPV_AFACCTNO*/
                --and exists (select gu.grpid from tlgrpusers gu where af.careby = gu.grpid and gu.tlid = V_STRTLID )
                union
                SELECT AF.CUSTID, af.careby,  tl.tltxcd||'T'|| '0'  tltxcd ,tltx.txdesc ,tl.txnum,tl.busdate ,
                tl.txdate,af.acctno, '' custodycdc,'' acctnoc,tl.msgamt amt,nvl(mk.tlname,'') mk,nvl(ck.tlname,'')  ck,nvl(AF.brid,'') brid,nvl(tl.tlid,'') tlid,nvl(tl.OFFID,'') OFFID,
                ''bankid,ci.corebank ,decode(af.bankname,'---',V_SYSNAME,af.bankname) bankname,ci.trdesc
                FROM vw_tllog_all TL,afmast af,tltx, tlprofiles mk,tlprofiles ck,vw_citran_gen CI, vw_stschd_all sts
                where tl.msgacct=af.acctno
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
         /*       and  nvl(AF.brid,V_STRBRID) like V_STRBRID
                AND NVL( TL.TLID,'-') LIKE V_STRMAKER
                AND NVL( TL.OFFID,'-') LIKE V_STRCHECKER
                AND ci.corebank  LIKE V_STRCOREBANK
                AND CF.custodycd LIKE V_STRPV_CUSTODYCD
                AND AF.acctno LIKE V_STRPV_AFACCTNO*/
                --and exists (select gu.grpid from tlgrpusers gu where af.careby = gu.grpid and gu.tlid = V_STRTLID )
                union
                SELECT AF.CUSTID,af.careby, case when  tl.tltxcd in ('3350','3354') then '3342' else  tl.tltxcd
                 end  tltxcd ,tltx.txdesc ,tl.txnum,tl.busdate ,tl.txdate,af.acctno, '' custodycdc,'' acctnoc,ci.namt amt,nvl(mk.tlname,'') mk,nvl(ck.tlname,'')  ck,nvl(AF.brid,'') brid,nvl(tl.tlid,'') tlid,nvl(tl.OFFID,'') OFFID,
                ''bankid,ci.corebank ,decode(af.bankname,'---',V_SYSNAME,af.bankname) bankname,ci.trdesc
                FROM vw_tllog_all TL,afmast af,tltx, tlprofiles mk,tlprofiles ck,vw_citran_gen CI
                where tl.msgacct=af.acctno
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
           /*     and  nvl(AF.brid,V_STRBRID) like V_STRBRID
                AND NVL( TL.TLID,'-') LIKE V_STRMAKER
                AND NVL( TL.OFFID,'-') LIKE V_STRCHECKER
                AND ci.corebank  LIKE V_STRCOREBANK
                AND CF.custodycd LIKE V_STRPV_CUSTODYCD
                AND AF.acctno LIKE V_STRPV_AFACCTNO*/
                --and exists (select gu.grpid from tlgrpusers gu where af.careby = gu.grpid and gu.tlid = V_STRTLID )
                UNION
                SELECT AF.CUSTID, af.careby, tl.tltxcd ,tltx.txdesc ,tl.txnum,tl.busdate ,tl.txdate,af.acctno, '' custodycdc,'' acctnoc,CI.NAMT amt,nvl(mk.tlname,'') mk,nvl(ck.tlname,'')  ck,nvl(AF.brid,'') brid,nvl(tl.tlid,'') tlid,nvl(tl.OFFID,'') OFFID,
                ''bankid,ci.corebank ,decode(af.bankname,'---',V_SYSNAME,af.bankname) bankname,ci.trdesc
                FROM vw_tllog_all TL,afmast af,tltx, tlprofiles mk,tlprofiles ck,vw_citran_gen CI
                where tl.msgacct=af.acctno
                and tltx.tltxcd = tl.tltxcd
                and af.ALTERNATEACCT like v_strALTERNATEACCT
                and  tl.tlid = mk.tlid(+)
                and  tl.OFFID =ck.tlid(+)
                AND TL.TXDATE = CI.TXDATE
                AND TL.TXNUM = CI.TXNUM
                AND CI.field ='BALANCE'
                and tl.tltxcd in('1153','8865','1139','3386')
                --and decode (V_STRTYPEDATE,'002',TL.busdate,TL.txdate)>=to_date(F_DATE,'DD/MM/YYYY')
                --AND decode (V_STRTYPEDATE,'002',TL.busdate,TL.txdate)<=to_date(T_DATE,'DD/MM/YYYY')
                and TL.busdate  >=to_date(F_DATE,'DD/MM/YYYY')
                and TL.busdate  <=to_date(T_DATE,'DD/MM/YYYY')
                AND TL.TLTXCD LIKE V_STRTLTXCD
              /*  and  nvl(AF.brid,V_STRBRID) like V_STRBRID
                AND NVL( TL.TLID,'-') LIKE V_STRMAKER
                AND NVL( TL.OFFID,'-') LIKE V_STRCHECKER
                AND ci.corebank  LIKE V_STRCOREBANK
                AND CF.custodycd LIKE V_STRPV_CUSTODYCD
                AND AF.acctno LIKE V_STRPV_AFACCTNO*/
                --and exists (select gu.grpid from tlgrpusers gu where af.careby = gu.grpid and gu.tlid = V_STRTLID )
                --1178
                union
                SELECT AF.CUSTID,af.careby, tl.tltxcd,tltx.txdesc ,tl.txnum,tl.busdate ,tl.txdate,af.acctno, '' custodycdc,'' acctnoc,ads.amt amt,nvl(mk.tlname,'') mk,nvl(ck.tlname,'')  ck,nvl(AF.brid,'') brid,nvl(tl.tlid,'') tlid,nvl(tl.OFFID,'') OFFID,
                '' bankid,ci.corebank ,decode(af.bankname,'---',V_SYSNAME,af.bankname) bankname, tl.txdesc trdesc
                FROM vw_tllog_all TL,adschd ads ,afmast af,tltx, tlprofiles mk,tlprofiles ck,
                vw_citran_all ci
                where tl.msgamt =ads.autoid
                and ci.txdate = tl.txdate  and ci.txnum = tl.txnum
                and TL.msgacct = af.acctno
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
          /*      and  nvl(AF.brid,V_STRBRID) like V_STRBRID
                AND NVL( TL.TLID,'-') LIKE V_STRMAKER
                AND NVL( TL.OFFID,'-') LIKE V_STRCHECKER
                AND ci.corebank  LIKE V_STRCOREBANK
                AND CF.custodycd LIKE V_STRPV_CUSTODYCD
                AND AF.acctno LIKE V_STRPV_AFACCTNO*/
                --and exists (select gu.grpid from tlgrpusers gu where af.careby = gu.grpid and gu.tlid = V_STRTLID )
                --nhom bank
                --'1131','1132','1136','1141'
                union

                SELECT  AF.CUSTID, af.careby, tl.tltxcd ,tltx.txdesc ,tl.txnum,tl.busdate ,tl.txdate,af.acctno, '' custodycdc,'' acctnoc,tl.msgamt amt,nvl(mk.tlname,'') mk,nvl(ck.tlname,'')  ck,nvl(AF.brid,'') brid,nvl(tl.tlid,'') tlid,nvl(tl.OFFID,'') OFFID
                ,nvl(bank.fullname,' ') bankid,ci.corebank ,decode(af.bankname,'---',V_SYSNAME,af.bankname) bankname, tl.txdesc trdesc
                FROM vw_tllog_all TL,afmast af,tltx, tlprofiles mk,tlprofiles ck,vw_tllogfld_all tlfld,banknostro bank,vw_citran_all ci
                where tl.msgacct=af.acctno
                and ci.txdate = tl.txdate  and ci.txnum = tl.txnum
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
          /*      and  nvl(AF.brid,V_STRBRID) like V_STRBRID
                AND NVL( TL.TLID,'-') LIKE V_STRMAKER
                AND NVL( TL.OFFID,'-') LIKE V_STRCHECKER
                AND ci.corebank  LIKE V_STRCOREBANK
                AND CF.custodycd LIKE V_STRPV_CUSTODYCD
                AND AF.acctno LIKE V_STRPV_AFACCTNO*/
                --and exists (select gu.grpid from tlgrpusers gu where af.careby = gu.grpid and gu.tlid = V_STRTLID )
                -- dfgroup
                union
                SELECT AF.CUSTID,af.careby, tl.tltxcd,tltx.txdesc ,tl.txnum,tl.busdate ,tl.txdate,af.acctno, '' custodycdc,'' acctnoc,CI.NAMT amt,nvl(mk.tlname,'') mk,nvl(ck.tlname,'')  ck,nvl(AF.brid,'') brid,nvl(tl.tlid,'') tlid,nvl(tl.OFFID,'') OFFID,
                nvl(CFB.shortname,'') bankid ,ci.corebank ,decode(af.bankname,'---',V_SYSNAME,af.bankname) bankname, CI.trdesc trdesc
                FROM vw_tllog_all TL,dfgroup dfg ,afmast af,tltx, tlprofiles mk,tlprofiles ck,
                 lnmast ln,lntype , CFMAST CFB,vw_citran_gen CI
                where tl.msgacct= dfg.groupid and dfg.afacctno = af.acctno
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
            /*    and  nvl(AF.brid,V_STRBRID) like V_STRBRID
                AND NVL( TL.TLID,'-') LIKE V_STRMAKER
                AND NVL( TL.OFFID,'-') LIKE V_STRCHECKER
                AND ci.corebank  LIKE V_STRCOREBANK
                AND CF.custodycd LIKE V_STRPV_CUSTODYCD
                AND AF.acctno LIKE V_STRPV_AFACCTNO*/
                --and exists (select gu.grpid from tlgrpusers gu where af.careby = gu.grpid and gu.tlid = V_STRTLID )
                union
                SELECT  AF.CUSTID,af.careby,  tl.tltxcd ,tltx.txdesc ,tl.txnum,tl.busdate ,tl.txdate,af.acctno, '' custodycdc,'' acctnoc,ci.NAMT amt,nvl(mk.tlname,'') mk,nvl(ck.tlname,'')  ck,nvl(AF.brid,'') brid,nvl(tl.tlid,'') tlid,nvl(tl.OFFID,'') OFFID,
                nvl(CFB.shortname,'') bankid ,ci.corebank ,decode(af.bankname,'---',V_SYSNAME,af.bankname) bankname,ci.trdesc
                FROM vw_tllog_all TL,afmast af,tltx, tlprofiles mk,tlprofiles ck,
                 vw_citran_gen ci,
                 lnmast ln,lntype , CFMAST CFB
                where tl.msgacct=af.acctno
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
      /*          and  nvl(AF.brid,V_STRBRID) like V_STRBRID
                AND NVL( TL.TLID,'-') LIKE V_STRMAKER
                AND NVL( TL.OFFID,'-') LIKE V_STRCHECKER
                AND ci.corebank  LIKE V_STRCOREBANK
                AND CF.custodycd LIKE V_STRPV_CUSTODYCD
                AND AF.acctno LIKE V_STRPV_AFACCTNO*/
                --and exists (select gu.grpid from tlgrpusers gu where af.careby = gu.grpid and gu.tlid = V_STRTLID )
                union
                SELECT  AF.CUSTID, af.careby, tl.tltxcd ,tltx.txdesc ,tl.txnum,tl.busdate ,tl.txdate,af.acctno, '' custodycdc,'' acctnoc,tl.msgamt amt,nvl(mk.tlname,'') mk,nvl(ck.tlname,'')  ck,nvl(AF.brid,'') brid,nvl(tl.tlid,'') tlid,nvl(tl.OFFID,'') OFFID,
                nvl(CFB.shortname,'') bankid ,ci.corebank ,decode(af.bankname,'---',V_SYSNAME,af.bankname) bankname, tl.txdesc trdesc
                FROM vw_tllog_all TL,afmast af,tltx, tlprofiles mk,tlprofiles ck,  vw_tllogfld_all tlfld, lnmast ln,lntype , CFMAST CFB,vw_citran_all ci
                where tl.msgacct=af.acctno
                and ci.txdate = tl.txdate  and ci.txnum = tl.txnum
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
              /*  and  nvl(AF.brid,V_STRBRID) like V_STRBRID
                AND NVL( TL.TLID,'-') LIKE V_STRMAKER
                AND NVL( TL.OFFID,'-') LIKE V_STRCHECKER
                AND ci.corebank  LIKE V_STRCOREBANK
                AND CF.custodycd LIKE V_STRPV_CUSTODYCD
                AND AF.acctno LIKE V_STRPV_AFACCTNO*/
                --and exists (select gu.grpid from tlgrpusers gu where af.careby = gu.grpid and gu.tlid = V_STRTLID )
                union
                SELECT AF.CUSTID, af.careby, tl.tltxcd   tltxcd ,tltx.txdesc ,tl.txnum,tl.busdate ,tl.txdate,af.acctno, '' custodycdc,'' acctnoc,ci.namt amt,nvl(mk.tlname,'') mk,nvl(ck.tlname,'')  ck,nvl(AF.brid,'') brid,nvl(tl.tlid,'') tlid,nvl(tl.OFFID,'') OFFID,
                ''bankid,ci.corebank ,decode(af.bankname,'---',V_SYSNAME,af.bankname) bankname,CI.trdesc
                FROM vw_tllog_all TL,afmast af,tltx, tlprofiles mk,tlprofiles ck,
                 vw_citran_gen   ci
                where ci.acctno=af.acctno
                and tltx.tltxcd = tl.tltxcd
                and  tl.tlid = mk.tlid(+)
                and af.ALTERNATEACCT like v_strALTERNATEACCT
                and  tl.OFFID =ck.tlid(+)
                and tl.txdate = ci.txdate
                and tl.txnum = ci.txnum
                and tl.tltxcd  IN ('0088','1670','1610','1110','1600','1620','1137','1138','3384') --chaunh add 3384
                and ci.field ='BALANCE'
                --and decode (V_STRTYPEDATE,'002',TL.busdate,TL.txdate)>=to_date(F_DATE,'DD/MM/YYYY')
                --AND decode (V_STRTYPEDATE,'002',TL.busdate,TL.txdate)<=to_date(T_DATE,'DD/MM/YYYY')
                and TL.busdate  >=to_date(F_DATE,'DD/MM/YYYY')
                and TL.busdate  <=to_date(T_DATE,'DD/MM/YYYY')
                AND TL.TLTXCD LIKE V_STRTLTXCD
     /*           and  nvl(AF.brid,V_STRBRID) like V_STRBRID
                AND NVL( TL.TLID,'-') LIKE V_STRMAKER
                AND NVL( TL.OFFID,'-') LIKE V_STRCHECKER
                AND ci.corebank  LIKE V_STRCOREBANK
                AND CF.custodycd LIKE V_STRPV_CUSTODYCD
                AND AF.acctno LIKE V_STRPV_AFACCTNO*/
                --and exists (select gu.grpid from tlgrpusers gu where af.careby = gu.grpid and gu.tlid = V_STRTLID )
                )A
                   WHERE CF.CUSTID=A.CUSTID
                    and  nvl(CF.brid,V_STRBRID) like V_STRBRID
                  AND NVL( A.TLID,'-') LIKE V_STRMAKER
                  AND NVL( A.OFFID,'-') LIKE V_STRCHECKER
                  AND A.corebank  LIKE V_STRCOREBANK
                  AND CF.custodycd LIKE V_STRPV_CUSTODYCD
                  AND A.acctno LIKE V_STRPV_AFACCTNO

                ORDER BY A.TLTXCD ,a.busdate,A.TXNUM
                ;
            else    --Lay theo txdate
                OPEN PV_REFCURSOR
                  FOR

             select  A.careby, A.tltxcd,A.txdesc ,A.txnum,A.busdate ,A.txdate, CF.CUSTODYCD,A.acctno,
             A.custodycdc,A.acctnoc,A.amt,A.mk,A.ck,
             CF.brid,A.tlid,A.OFFID, A.bankid,A.corebank ,A.bankname,A.trdesc
              from
             (SELECT * FROM CFMAST WHERE FNC_VALIDATE_SCOPE(BRID, CAREBY, TLSCOPE, pv_BRID, TLGOUPS)=0) cf,
             (
                select AF.CUSTID,af.careby, tl.tltxcd,tltx.txdesc ,tl.txnum,tl.busdate ,tl.txdate,af.acctno, cfc.custodycd custodycdc,afc.acctno acctnoc,tl.msgamt amt,nvl(mk.tlname,'') mk,nvl(ck.tlname,'')  ck,nvl(AF.brid,'') brid,nvl(tl.tlid,'') tlid,nvl(tl.OFFID,'') OFFID,
                ''bankid,ci.corebank ,decode(af.bankname,'---',V_SYSNAME,af.bankname) bankname,ci.trdesc
                from vw_tllog_all TL ,vw_citran_gen ci,afmast af, afmast afc,cfmast cfc ,tltx  , tlprofiles mk,tlprofiles ck
                where tl.txnum =ci.txnum and tl.txdate =ci.txdate and ci.acctno= af.acctno
                and ci.ref =afc.acctno and afc.custid =cfc.custid
                and tltx.tltxcd = tl.tltxcd
                and  tl.tlid = mk.tlid(+)
                and  tl.OFFID =ck.tlid(+)
                and tl.tltxcd in ('1120','1130','1134') and ci.field ='BALANCE' and ci.txtype='D'
                --and decode (V_STRTYPEDATE,'002',TL.busdate,TL.txdate)>=to_date(F_DATE,'DD/MM/YYYY')
                --AND decode (V_STRTYPEDATE,'002',TL.busdate,TL.txdate)<=to_date(T_DATE,'DD/MM/YYYY')
                and TL.txdate  >=to_date(F_DATE,'DD/MM/YYYY')
                and TL.txdate  <=to_date(T_DATE,'DD/MM/YYYY')
                AND TL.TLTXCD LIKE V_STRTLTXCD
                and af.ALTERNATEACCT like v_strALTERNATEACCT
          /*      and  nvl(AF.brid,V_STRBRID) like V_STRBRID
                AND NVL( TL.TLID,'-') LIKE V_STRMAKER
                AND NVL( TL.OFFID,'-') LIKE V_STRCHECKER
                AND ci.corebank  LIKE V_STRCOREBANK
                AND CF.custodycd LIKE V_STRPV_CUSTODYCD
                AND AF.acctno LIKE V_STRPV_AFACCTNO*/
                --and exists (select gu.grpid from tlgrpusers gu where af.careby = gu.grpid and gu.tlid = V_STRTLID )
                union
                SELECT AF.CUSTID,af.careby, case when  tl.tltxcd in ('3350','3354') then '3342' else  tl.tltxcd end
                  tltxcd ,tltx.txdesc ,tl.txnum,tl.busdate ,tl.txdate,af.acctno, '' custodycdc,'' acctnoc,tl.msgamt amt,nvl(mk.tlname,'') mk,nvl(ck.tlname,'')  ck,nvl(AF.brid,'') brid,nvl(tl.tlid,'') tlid,nvl(tl.OFFID,'') OFFID,
                ''bankid,ci.corebank ,decode(af.bankname,'---',V_SYSNAME,af.bankname) bankname , tl.txdesc trdesc
                FROM vw_tllog_all TL,afmast af,tltx, tlprofiles mk,tlprofiles ck,vw_citran_all ci
                where substr(tl.msgacct,0,10)=af.acctno
                and ci.txdate = tl.txdate  and ci.txnum = tl.txnum
                and tltx.tltxcd = tl.tltxcd
                and  tl.tlid = mk.tlid(+)
                and af.ALTERNATEACCT like v_strALTERNATEACCT
                and  tl.OFFID =ck.tlid(+)
                and tl.tltxcd in ('1140','1100','1107','1101'
                ,'1104','1108','1111','1114','1104','1112','1145','1144'
                ,'1123','1124','1126','1127','1162','1180','1182','6613','1105','1198','1199','8866','1190','1191'
                ,'8856','0066','8889','8894','8851','5541','1146') --Chaunh bo 3384
                --and decode (V_STRTYPEDATE,'002',TL.busdate,TL.txdate)>=to_date(F_DATE,'DD/MM/YYYY')
                --AND decode (V_STRTYPEDATE,'002',TL.busdate,TL.txdate)<=to_date(T_DATE,'DD/MM/YYYY')
                and TL.txdate  >=to_date(F_DATE,'DD/MM/YYYY')
                and TL.txdate  <=to_date(T_DATE,'DD/MM/YYYY')
                AND  case when  tl.tltxcd in ('3350','3354') then '3342' else  tl.tltxcd end  LIKE V_STRTLTXCD
                /*and  nvl(AF.brid,V_STRBRID) like V_STRBRID
                AND NVL( TL.TLID,'-') LIKE V_STRMAKER
                AND NVL( TL.OFFID,'-') LIKE V_STRCHECKER
                AND ci.corebank  LIKE V_STRCOREBANK
                AND CF.custodycd LIKE V_STRPV_CUSTODYCD
                AND AF.acctno LIKE V_STRPV_AFACCTNO*/
                --and exists (select gu.grpid from tlgrpusers gu where af.careby = gu.grpid and gu.tlid = V_STRTLID )
                union
                SELECT AF.CUSTID,  af.careby, tl.tltxcd||'T'|| '0'  tltxcd ,tltx.txdesc ,tl.txnum,tl.busdate ,
                tl.txdate,af.acctno, '' custodycdc,'' acctnoc,tl.msgamt amt,nvl(mk.tlname,'') mk,nvl(ck.tlname,'')  ck,nvl(AF.brid,'') brid,nvl(tl.tlid,'') tlid,nvl(tl.OFFID,'') OFFID,
                ''bankid,ci.corebank ,decode(af.bankname,'---',V_SYSNAME,af.bankname) bankname,ci.trdesc
                FROM vw_tllog_all TL,afmast af,tltx, tlprofiles mk,tlprofiles ck,vw_citran_gen CI, vw_stschd_all sts
                where tl.msgacct=af.acctno
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
               /* and  nvl(AF.brid,V_STRBRID) like V_STRBRID
                AND NVL( TL.TLID,'-') LIKE V_STRMAKER
                AND NVL( TL.OFFID,'-') LIKE V_STRCHECKER
                AND ci.corebank  LIKE V_STRCOREBANK
                AND CF.custodycd LIKE V_STRPV_CUSTODYCD
                AND AF.acctno LIKE V_STRPV_AFACCTNO*/
                --and exists (select gu.grpid from tlgrpusers gu where af.careby = gu.grpid and gu.tlid = V_STRTLID )
                union
                SELECT AF.CUSTID,af.careby, case when  tl.tltxcd in ('3350','3354') then '3342' else  tl.tltxcd end
                 tltxcd ,tltx.txdesc ,tl.txnum,tl.busdate ,tl.txdate,af.acctno, '' custodycdc,'' acctnoc,ci.namt amt,nvl(mk.tlname,'') mk,nvl(ck.tlname,'')  ck,nvl(AF.brid,'') brid,nvl(tl.tlid,'') tlid,nvl(tl.OFFID,'') OFFID,
                ''bankid,ci.corebank ,decode(af.bankname,'---',V_SYSNAME,af.bankname) bankname,ci.trdesc
                FROM vw_tllog_all TL,afmast af,tltx, tlprofiles mk,tlprofiles ck,vw_citran_gen CI
                where tl.msgacct=af.acctno
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
           /*     and  nvl(AF.brid,V_STRBRID) like V_STRBRID
                AND NVL( TL.TLID,'-') LIKE V_STRMAKER
                AND NVL( TL.OFFID,'-') LIKE V_STRCHECKER
                AND ci.corebank  LIKE V_STRCOREBANK
                AND CF.custodycd LIKE V_STRPV_CUSTODYCD
                AND AF.acctno LIKE V_STRPV_AFACCTNO*/
                --and exists (select gu.grpid from tlgrpusers gu where af.careby = gu.grpid and gu.tlid = V_STRTLID )
                UNION
                SELECT AF.CUSTID, af.careby, tl.tltxcd ,tltx.txdesc ,tl.txnum,tl.busdate ,tl.txdate,af.acctno, '' custodycdc,'' acctnoc,CI.NAMT amt,nvl(mk.tlname,'') mk,nvl(ck.tlname,'')  ck,nvl(AF.brid,'') brid,nvl(tl.tlid,'') tlid,nvl(tl.OFFID,'') OFFID,
                ''bankid,ci.corebank ,decode(af.bankname,'---',V_SYSNAME,af.bankname) bankname,ci.trdesc
                FROM vw_tllog_all TL,afmast af,tltx, tlprofiles mk,tlprofiles ck,vw_citran_gen CI
                where tl.msgacct=af.acctno
                and tltx.tltxcd = tl.tltxcd
                and  tl.tlid = mk.tlid(+)
                and  tl.OFFID =ck.tlid(+)
                AND TL.TXDATE = CI.TXDATE
                AND TL.TXNUM = CI.TXNUM
                and af.ALTERNATEACCT like v_strALTERNATEACCT
                AND CI.field ='BALANCE'
                and tl.tltxcd in('1153','8865','1139','3386')
                --and decode (V_STRTYPEDATE,'002',TL.busdate,TL.txdate)>=to_date(F_DATE,'DD/MM/YYYY')
                --AND decode (V_STRTYPEDATE,'002',TL.busdate,TL.txdate)<=to_date(T_DATE,'DD/MM/YYYY')
                and TL.txdate  >=to_date(F_DATE,'DD/MM/YYYY')
                and TL.txdate  <=to_date(T_DATE,'DD/MM/YYYY')
                AND TL.TLTXCD LIKE V_STRTLTXCD
              /*  and  nvl(AF.brid,V_STRBRID) like V_STRBRID
                AND NVL( TL.TLID,'-') LIKE V_STRMAKER
                AND NVL( TL.OFFID,'-') LIKE V_STRCHECKER
                AND ci.corebank  LIKE V_STRCOREBANK
                AND CF.custodycd LIKE V_STRPV_CUSTODYCD
                AND AF.acctno LIKE V_STRPV_AFACCTNO*/
                --and exists (select gu.grpid from tlgrpusers gu where af.careby = gu.grpid and gu.tlid = V_STRTLID )
                --1178
                union
                SELECT AF.CUSTID,af.careby, tl.tltxcd,tltx.txdesc ,tl.txnum,tl.busdate ,tl.txdate,af.acctno, '' custodycdc,'' acctnoc,ads.amt amt,nvl(mk.tlname,'') mk,nvl(ck.tlname,'')  ck,nvl(AF.brid,'') brid,nvl(tl.tlid,'') tlid,nvl(tl.OFFID,'') OFFID,
                '' bankid,ci.corebank ,decode(af.bankname,'---',V_SYSNAME,af.bankname) bankname, tl.txdesc trdesc
                FROM vw_tllog_all TL,adschd ads ,afmast af,tltx, tlprofiles mk,tlprofiles ck,vw_citran_all ci
                where tl.msgamt =ads.autoid
                 and ci.txdate = tl.txdate  and ci.txnum = tl.txnum
                and TL.msgacct = af.acctno
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
               /* and  nvl(AF.brid,V_STRBRID) like V_STRBRID
                AND NVL( TL.TLID,'-') LIKE V_STRMAKER
                AND NVL( TL.OFFID,'-') LIKE V_STRCHECKER
                AND ci.corebank  LIKE V_STRCOREBANK
                AND CF.custodycd LIKE V_STRPV_CUSTODYCD
                AND AF.acctno LIKE V_STRPV_AFACCTNO*/
                --and exists (select gu.grpid from tlgrpusers gu where af.careby = gu.grpid and gu.tlid = V_STRTLID )
                --nhom bank
                --'1131','1132','1136','1141'
                union

                SELECT  AF.CUSTID, af.careby, tl.tltxcd ,tltx.txdesc ,tl.txnum,tl.busdate ,tl.txdate,af.acctno, '' custodycdc,'' acctnoc,tl.msgamt amt,nvl(mk.tlname,'') mk,nvl(ck.tlname,'')  ck,nvl(AF.brid,'') brid,nvl(tl.tlid,'') tlid,nvl(tl.OFFID,'') OFFID
                ,nvl(bank.fullname,' ') bankid,ci.corebank ,decode(af.bankname,'---',V_SYSNAME,af.bankname) bankname, tl.txdesc trdesc
                FROM vw_tllog_all TL,afmast af,tltx, tlprofiles mk,tlprofiles ck,vw_tllogfld_all tlfld,banknostro bank,vw_citran_all ci
                where tl.msgacct=af.acctno
                and tltx.tltxcd = tl.tltxcd
                and ci.txdate = tl.txdate  and ci.txnum = tl.txnum
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
                /*and  nvl(AF.brid,V_STRBRID) like V_STRBRID
                AND NVL( TL.TLID,'-') LIKE V_STRMAKER
                AND NVL( TL.OFFID,'-') LIKE V_STRCHECKER
                AND ci.corebank  LIKE V_STRCOREBANK
                AND CF.custodycd LIKE V_STRPV_CUSTODYCD
                AND AF.acctno LIKE V_STRPV_AFACCTNO*/
                --and exists (select gu.grpid from tlgrpusers gu where af.careby = gu.grpid and gu.tlid = V_STRTLID )
                -- dfgroup
                union
                SELECT AF.CUSTID,af.careby, tl.tltxcd,tltx.txdesc ,tl.txnum,tl.busdate ,tl.txdate,af.acctno, '' custodycdc,'' acctnoc,CI.NAMT amt,nvl(mk.tlname,'') mk,nvl(ck.tlname,'')  ck,nvl(AF.brid,'') brid,nvl(tl.tlid,'') tlid,nvl(tl.OFFID,'') OFFID,
                nvl(CFB.shortname,'') bankid ,ci.corebank ,decode(af.bankname,'---',V_SYSNAME,af.bankname) bankname, CI.trdesc trdesc
                FROM vw_tllog_all TL,dfgroup dfg ,afmast af,tltx, tlprofiles mk,tlprofiles ck,
                 lnmast ln,lntype , CFMAST CFB,vw_citran_gen CI
                where tl.msgacct= dfg.groupid and dfg.afacctno = af.acctno
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
               /* and  nvl(AF.brid,V_STRBRID) like V_STRBRID
                AND NVL( TL.TLID,'-') LIKE V_STRMAKER
                AND NVL( TL.OFFID,'-') LIKE V_STRCHECKER
                AND ci.corebank  LIKE V_STRCOREBANK
                AND CF.custodycd LIKE V_STRPV_CUSTODYCD
                AND AF.acctno LIKE V_STRPV_AFACCTNO*/
                --and exists (select gu.grpid from tlgrpusers gu where af.careby = gu.grpid and gu.tlid = V_STRTLID )
                union
                SELECT  AF.CUSTID,af.careby,  tl.tltxcd ,tltx.txdesc ,tl.txnum,tl.busdate ,tl.txdate,af.acctno, '' custodycdc,'' acctnoc,ci.NAMT amt,nvl(mk.tlname,'') mk,nvl(ck.tlname,'')  ck,nvl(AF.brid,'') brid,nvl(tl.tlid,'') tlid,nvl(tl.OFFID,'') OFFID,
                nvl(CFB.shortname,'') bankid ,ci.corebank ,decode(af.bankname,'---',V_SYSNAME,af.bankname) bankname,ci.trdesc
                FROM vw_tllog_all TL,afmast af,tltx, tlprofiles mk,tlprofiles ck,
                 vw_citran_gen ci,
                 lnmast ln,lntype , CFMAST CFB
                where tl.msgacct=af.acctno
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
              /*  and  nvl(AF.brid,V_STRBRID) like V_STRBRID
                AND NVL( TL.TLID,'-') LIKE V_STRMAKER
                AND NVL( TL.OFFID,'-') LIKE V_STRCHECKER
                AND ci.corebank  LIKE V_STRCOREBANK
                AND CF.custodycd LIKE V_STRPV_CUSTODYCD
                AND AF.acctno LIKE V_STRPV_AFACCTNO*/
                --and exists (select gu.grpid from tlgrpusers gu where af.careby = gu.grpid and gu.tlid = V_STRTLID )
                union
                SELECT AF.CUSTID, af.careby,  tl.tltxcd ,tltx.txdesc ,tl.txnum,tl.busdate ,tl.txdate,af.acctno, '' custodycdc,'' acctnoc,tl.msgamt amt,nvl(mk.tlname,'') mk,nvl(ck.tlname,'')  ck,nvl(AF.brid,'') brid,nvl(tl.tlid,'') tlid,nvl(tl.OFFID,'') OFFID,
                nvl(CFB.shortname,'') bankid ,ci.corebank ,decode(af.bankname,'---',V_SYSNAME,af.bankname) bankname, tl.txdesc trdesc
                FROM vw_tllog_all TL,afmast af,tltx, tlprofiles mk,tlprofiles ck,  vw_tllogfld_all tlfld, lnmast ln,lntype , CFMAST CFB,vw_citran_all ci
                where tl.msgacct=af.acctno
                and ci.txdate = tl.txdate  and ci.txnum = tl.txnum
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
               /* and  nvl(AF.brid,V_STRBRID) like V_STRBRID
                AND NVL( TL.TLID,'-') LIKE V_STRMAKER
                AND NVL( TL.OFFID,'-') LIKE V_STRCHECKER
                AND ci.corebank  LIKE V_STRCOREBANK
                AND CF.custodycd LIKE V_STRPV_CUSTODYCD
                AND AF.acctno LIKE V_STRPV_AFACCTNO*/
                --and exists (select gu.grpid from tlgrpusers gu where af.careby = gu.grpid and gu.tlid = V_STRTLID )
                union
                SELECT AF.CUSTID,af.careby,  tl.tltxcd   tltxcd ,tltx.txdesc ,tl.txnum,tl.busdate ,tl.txdate,af.acctno, '' custodycdc,'' acctnoc,ci.namt amt,nvl(mk.tlname,'') mk,nvl(ck.tlname,'')  ck,nvl(AF.brid,'') brid,nvl(tl.tlid,'') tlid,nvl(tl.OFFID,'') OFFID,
                ''bankid,ci.corebank ,decode(af.bankname,'---',V_SYSNAME,af.bankname) bankname,CI.trdesc
                FROM vw_tllog_all TL,afmast af,tltx, tlprofiles mk,tlprofiles ck,
                 vw_citran_gen   ci
                where ci.acctno=af.acctno
                and tltx.tltxcd = tl.tltxcd
                and af.ALTERNATEACCT like v_strALTERNATEACCT
                and  tl.tlid = mk.tlid(+)
                and  tl.OFFID =ck.tlid(+)
                and tl.txdate = ci.txdate
                and tl.txnum = ci.txnum
                and tl.tltxcd  IN ('0088','1670','1610','1110','1600','1620','1137','1138','3384') --chaunh add 3384
                and ci.field ='BALANCE'
                --and decode (V_STRTYPEDATE,'002',TL.busdate,TL.txdate)>=to_date(F_DATE,'DD/MM/YYYY')
                --AND decode (V_STRTYPEDATE,'002',TL.busdate,TL.txdate)<=to_date(T_DATE,'DD/MM/YYYY')
                and TL.txdate  >=to_date(F_DATE,'DD/MM/YYYY')
                and TL.txdate  <=to_date(T_DATE,'DD/MM/YYYY')
                AND TL.TLTXCD LIKE V_STRTLTXCD
            /*    and  nvl(AF.brid,V_STRBRID) like V_STRBRID
                AND NVL( TL.TLID,'-') LIKE V_STRMAKER
                AND NVL( TL.OFFID,'-') LIKE V_STRCHECKER
                AND ci.corebank  LIKE V_STRCOREBANK
                AND CF.custodycd LIKE V_STRPV_CUSTODYCD
                AND AF.acctno LIKE V_STRPV_AFACCTNO*/
                --and exists (select gu.grpid from tlgrpusers gu where af.careby = gu.grpid and gu.tlid = V_STRTLID )
                )A
                  WHERE CF.CUSTID=A.CUSTID
                  and  nvl(CF.brid,V_STRBRID) like V_STRBRID
                  AND NVL( A.TLID,'-') LIKE V_STRMAKER
                  AND NVL( A.OFFID,'-') LIKE V_STRCHECKER
                  AND A.corebank  LIKE V_STRCOREBANK
                  AND CF.custodycd LIKE V_STRPV_CUSTODYCD
                  AND A.acctno LIKE V_STRPV_AFACCTNO

                ORDER BY A.TLTXCD ,a.busdate,A.TXNUM
                ;
            end if;

        ELSE
            if V_STRTYPEDATE ='002' then --Lay theo busdate
                OPEN PV_REFCURSOR
                FOR
             select  A.careby, A.tltxcd,A.txdesc ,A.txnum,A.busdate ,A.txdate, CF.CUSTODYCD,A.acctno,
                A.custodycdc,A.acctnoc,A.amt,A.mk,A.ck,
                CF.brid,A.tlid,A.OFFID, A.bankid,A.corebank ,A.bankname,A.trdesc
              from
             (SELECT * FROM CFMAST WHERE FNC_VALIDATE_SCOPE(BRID, CAREBY, TLSCOPE, pv_BRID, TLGOUPS)=0) cf,
             (
                select AF.CUSTID,af.careby, tl.tltxcd,tltx.txdesc ,tl.txnum,tl.busdate ,tl.txdate,af.acctno, cfc.custodycd custodycdc,afc.acctno acctnoc,tl.msgamt amt,nvl(mk.tlname,'') mk,nvl(ck.tlname,'')  ck,nvl(tl.brid,'') brid,nvl(tl.tlid,'') tlid,nvl(tl.OFFID,'') OFFID,
                ''bankid,ci.corebank ,decode(af.bankname,'---',V_SYSNAME,af.bankname) bankname,ci.trdesc
                from vw_tllog_all TL ,vw_citran_gen ci,afmast af, afmast afc,cfmast cfc ,tltx  , tlprofiles mk,tlprofiles ck
                where tl.txnum =ci.txnum and tl.txdate =ci.txdate and ci.acctno= af.acctno
                and ci.ref =afc.acctno and afc.custid =cfc.custid
                and tltx.tltxcd = tl.tltxcd
                and  tl.tlid = mk.tlid(+)
                and  tl.OFFID =ck.tlid(+)
                and tl.tltxcd in ('1120','1130','1134') and ci.field ='BALANCE' and ci.txtype='D'
                --and decode (V_STRTYPEDATE,'002',TL.busdate,TL.txdate)>=to_date(F_DATE,'DD/MM/YYYY')
                --AND decode (V_STRTYPEDATE,'002',TL.busdate,TL.txdate)<=to_date(T_DATE,'DD/MM/YYYY')
                and TL.busdate  >=to_date(F_DATE,'DD/MM/YYYY')
                and TL.busdate  <=to_date(T_DATE,'DD/MM/YYYY')
                and af.ALTERNATEACCT like v_strALTERNATEACCT
                AND TL.TLTXCD LIKE V_STRTLTXCD
                and  nvl(tl.brid,V_STRBRID) like V_STRBRID
           /*     AND NVL( TL.TLID,'-') LIKE V_STRMAKER
                AND NVL( TL.OFFID,'-') LIKE V_STRCHECKER
                AND ci.corebank  LIKE V_STRCOREBANK
                AND CF.custodycd LIKE V_STRPV_CUSTODYCD
                AND AF.acctno LIKE V_STRPV_AFACCTNO*/
                --and exists (select gu.grpid from tlgrpusers gu where af.careby = gu.grpid and gu.tlid = V_STRTLID )

                union
                SELECT AF.CUSTID,af.careby, case when  tl.tltxcd in ('3350','3354') then '3342' else  tl.tltxcd end
                tltxcd ,tltx.txdesc ,tl.txnum,tl.busdate ,tl.txdate,af.acctno, '' custodycdc,'' acctnoc,tl.msgamt amt,nvl(mk.tlname,'') mk,nvl(ck.tlname,'')  ck,nvl(tl.brid,'') brid,nvl(tl.tlid,'') tlid,nvl(tl.OFFID,'') OFFID,
                ''bankid,ci.corebank ,decode(af.bankname,'---',V_SYSNAME,af.bankname) bankname , tl.txdesc trdesc
                FROM vw_tllog_all TL,afmast af,tltx, tlprofiles mk,tlprofiles ck,vw_citran_all ci
                where substr(tl.msgacct,0,10)=af.acctno
                and tltx.tltxcd = tl.tltxcd
                and af.ALTERNATEACCT like v_strALTERNATEACCT
                and  tl.tlid = mk.tlid(+)
                and  tl.OFFID =ck.tlid(+)
                and tl.tltxcd in ('1140','1100','1107','1101'
                ,'1104','1108','1111','1114','1104','1112','1145','1144'
                ,'1123','1124','1126','1127','1162','1180','1182','6613','1105','1198','1199','8866','1190','1191'
                ,'8856','0066','8889','8894','8851','5541','1146') --Chaunh bo 3384
                --and decode (V_STRTYPEDATE,'002',TL.busdate,TL.txdate)>=to_date(F_DATE,'DD/MM/YYYY')
                --AND decode (V_STRTYPEDATE,'002',TL.busdate,TL.txdate)<=to_date(T_DATE,'DD/MM/YYYY')
                and TL.busdate  >=to_date(F_DATE,'DD/MM/YYYY')
                and TL.busdate  <=to_date(T_DATE,'DD/MM/YYYY')AND TL.TLTXCD LIKE V_STRTLTXCD
                and  nvl(tl.brid,V_STRBRID) like V_STRBRID
                 and ci.txdate = tl.txdate  and ci.txnum = tl.txnum
         /*       AND NVL( TL.TLID,'-') LIKE V_STRMAKER
                AND NVL( TL.OFFID,'-') LIKE V_STRCHECKER
                AND ci.corebank  LIKE V_STRCOREBANK
                AND CF.custodycd LIKE V_STRPV_CUSTODYCD
                AND AF.acctno LIKE V_STRPV_AFACCTNO*/
                --and exists (select gu.grpid from tlgrpusers gu where af.careby = gu.grpid and gu.tlid = V_STRTLID )
                union
                SELECT  AF.CUSTID, af.careby, tl.tltxcd||'T'|| '0' tltxcd ,tltx.txdesc ,tl.txnum,tl.busdate ,
                tl.txdate,af.acctno, '' custodycdc,'' acctnoc,tl.msgamt amt,nvl(mk.tlname,'') mk,nvl(ck.tlname,'')  ck,nvl(tl.brid,'') brid,nvl(tl.tlid,'') tlid,nvl(tl.OFFID,'') OFFID,
                ''bankid,ci.corebank ,decode(af.bankname,'---',V_SYSNAME,af.bankname) bankname,ci.trdesc
                FROM vw_tllog_all TL,afmast af,tltx, tlprofiles mk,tlprofiles ck,vw_citran_gen CI, vw_stschd_all sts
                where tl.msgacct=af.acctno
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
         /*       AND NVL( TL.TLID,'-') LIKE V_STRMAKER
                AND NVL( TL.OFFID,'-') LIKE V_STRCHECKER
                AND ci.corebank  LIKE V_STRCOREBANK
                AND CF.custodycd LIKE V_STRPV_CUSTODYCD
                AND AF.acctno LIKE V_STRPV_AFACCTNO*/
                --and exists (select gu.grpid from tlgrpusers gu where af.careby = gu.grpid and gu.tlid = V_STRTLID )
                union
                SELECT AF.CUSTID, af.careby, case when  tl.tltxcd in ('3350','3354') then '3342' else  tl.tltxcd end
                 tltxcd ,tltx.txdesc ,tl.txnum,tl.busdate ,tl.txdate,af.acctno, '' custodycdc,'' acctnoc,tl.msgamt amt,nvl(mk.tlname,'') mk,nvl(ck.tlname,'')  ck,nvl(tl.brid,'') brid,nvl(tl.tlid,'') tlid,nvl(tl.OFFID,'') OFFID,
                ''bankid,ci.corebank ,decode(af.bankname,'---',V_SYSNAME,af.bankname) bankname,ci.trdesc
                FROM vw_tllog_all TL,afmast af,tltx, tlprofiles mk,tlprofiles ck,vw_citran_gen CI
                where tl.msgacct=af.acctno
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
              /*  AND NVL( TL.TLID,'-') LIKE V_STRMAKER
                AND NVL( TL.OFFID,'-') LIKE V_STRCHECKER
                AND ci.corebank  LIKE V_STRCOREBANK
                AND CF.custodycd LIKE V_STRPV_CUSTODYCD
                AND AF.acctno LIKE V_STRPV_AFACCTNO*/
                --and exists (select gu.grpid from tlgrpusers gu where af.careby = gu.grpid and gu.tlid = V_STRTLID )
                UNION
                SELECT AF.CUSTID,af.careby,  tl.tltxcd ,tltx.txdesc ,tl.txnum,tl.busdate ,tl.txdate,af.acctno, '' custodycdc,'' acctnoc,CI.NAMT amt,nvl(mk.tlname,'') mk,nvl(ck.tlname,'')  ck,nvl(tl.brid,'') brid,nvl(tl.tlid,'') tlid,nvl(tl.OFFID,'') OFFID,
                ''bankid,ci.corebank ,decode(af.bankname,'---',V_SYSNAME,af.bankname) bankname,ci.trdesc
                FROM vw_tllog_all TL,afmast af,tltx, tlprofiles mk,tlprofiles ck,vw_citran_gen CI
                where tl.msgacct=af.acctno
                and tltx.tltxcd = tl.tltxcd
                and  tl.tlid = mk.tlid(+)
                and  tl.OFFID =ck.tlid(+)
                and af.ALTERNATEACCT like v_strALTERNATEACCT
                AND TL.TXDATE = CI.TXDATE
                AND TL.TXNUM = CI.TXNUM
                AND CI.field ='BALANCE'
                and tl.tltxcd in('1153','8865','1139','3386')
                --and decode (V_STRTYPEDATE,'002',TL.busdate,TL.txdate)>=to_date(F_DATE,'DD/MM/YYYY')
                --AND decode (V_STRTYPEDATE,'002',TL.busdate,TL.txdate)<=to_date(T_DATE,'DD/MM/YYYY')
                and TL.busdate  >=to_date(F_DATE,'DD/MM/YYYY')
                and TL.busdate  <=to_date(T_DATE,'DD/MM/YYYY')
                AND TL.TLTXCD LIKE V_STRTLTXCD
                and  nvl(tl.brid,V_STRBRID) like V_STRBRID
           /*     AND NVL( TL.TLID,'-') LIKE V_STRMAKER
                AND NVL( TL.OFFID,'-') LIKE V_STRCHECKER
                AND ci.corebank  LIKE V_STRCOREBANK
                AND CF.custodycd LIKE V_STRPV_CUSTODYCD
                AND AF.acctno LIKE V_STRPV_AFACCTNO*/
                --and exists (select gu.grpid from tlgrpusers gu where af.careby = gu.grpid and gu.tlid = V_STRTLID )

                --1178
                union
                SELECT AF.CUSTID,af.careby, tl.tltxcd,tltx.txdesc ,tl.txnum,tl.busdate ,tl.txdate,af.acctno, '' custodycdc,'' acctnoc,ads.amt amt,nvl(mk.tlname,'') mk,nvl(ck.tlname,'')  ck,nvl(tl.brid,'') brid,nvl(tl.tlid,'') tlid,nvl(tl.OFFID,'') OFFID,
                '' bankid,ci.corebank ,decode(af.bankname,'---',V_SYSNAME,af.bankname) bankname, tl.txdesc trdesc
                FROM vw_tllog_all TL,adschd ads ,afmast af,tltx, tlprofiles mk,tlprofiles ck,vw_citran_all ci
                where tl.msgamt =ads.autoid
                and TL.msgacct = af.acctno
                and ci.txdate = tl.txdate  and ci.txnum = tl.txnum
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
            /*    AND NVL( TL.TLID,'-') LIKE V_STRMAKER
                AND NVL( TL.OFFID,'-') LIKE V_STRCHECKER
                AND ci.corebank  LIKE V_STRCOREBANK
                AND CF.custodycd LIKE V_STRPV_CUSTODYCD
                AND AF.acctno LIKE V_STRPV_AFACCTNO*/
                --and exists (select gu.grpid from tlgrpusers gu where af.careby = gu.grpid and gu.tlid = V_STRTLID )
                --nhom bank
                --'1131','1132','1136','1141'
                union

                SELECT AF.CUSTID, af.careby,  tl.tltxcd ,tltx.txdesc ,tl.txnum,tl.busdate ,tl.txdate,af.acctno, '' custodycdc,'' acctnoc,tl.msgamt amt,nvl(mk.tlname,'') mk,nvl(ck.tlname,'')  ck,nvl(tl.brid,'') brid,nvl(tl.tlid,'') tlid,nvl(tl.OFFID,'') OFFID
                ,nvl(bank.fullname,' ') bankid,ci.corebank ,decode(af.bankname,'---',V_SYSNAME,af.bankname) bankname, tl.txdesc trdesc
                FROM vw_tllog_all TL,afmast af,tltx, tlprofiles mk,tlprofiles ck,vw_tllogfld_all tlfld,banknostro bank,vw_citran_all ci
                where tl.msgacct=af.acctno
                and tltx.tltxcd = tl.tltxcd
                and ci.txdate = tl.txdate  and ci.txnum = tl.txnum
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
                /*AND NVL( TL.TLID,'-') LIKE V_STRMAKER
                AND NVL( TL.OFFID,'-') LIKE V_STRCHECKER
                AND ci.corebank  LIKE V_STRCOREBANK
                AND CF.custodycd LIKE V_STRPV_CUSTODYCD
                AND AF.acctno LIKE V_STRPV_AFACCTNO*/
                --and exists (select gu.grpid from tlgrpusers gu where af.careby = gu.grpid and gu.tlid = V_STRTLID )
                -- dfgroup
                union
                SELECT AF.CUSTID,af.careby, tl.tltxcd,tltx.txdesc ,tl.txnum,tl.busdate ,tl.txdate,af.acctno, '' custodycdc,'' acctnoc,CI.NAMT amt,nvl(mk.tlname,'') mk,nvl(ck.tlname,'')  ck,nvl(tl.brid,'') brid,nvl(tl.tlid,'') tlid,nvl(tl.OFFID,'') OFFID,
                nvl(CFB.shortname,'') bankid ,ci.corebank ,decode(af.bankname,'---',V_SYSNAME,af.bankname) bankname, CI.trdesc trdesc
                FROM vw_tllog_all TL,dfgroup dfg ,afmast af,tltx, tlprofiles mk,tlprofiles ck,
                 lnmast ln,lntype , CFMAST CFB,vw_citran_gen CI
                where tl.msgacct= dfg.groupid and dfg.afacctno = af.acctno
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
         /*       AND NVL( TL.TLID,'-') LIKE V_STRMAKER
                AND NVL( TL.OFFID,'-') LIKE V_STRCHECKER
                AND ci.corebank  LIKE V_STRCOREBANK
                AND CF.custodycd LIKE V_STRPV_CUSTODYCD
                AND AF.acctno LIKE V_STRPV_AFACCTNO*/
                --and exists (select gu.grpid from tlgrpusers gu where af.careby = gu.grpid and gu.tlid = V_STRTLID )

                union
                SELECT AF.CUSTID, af.careby,  tl.tltxcd ,tltx.txdesc ,tl.txnum,tl.busdate ,tl.txdate,af.acctno, '' custodycdc,'' acctnoc,ci.NAMT amt,nvl(mk.tlname,'') mk,nvl(ck.tlname,'')  ck,nvl(tl.brid,'') brid,nvl(tl.tlid,'') tlid,nvl(tl.OFFID,'') OFFID,
                nvl(CFB.shortname,'') bankid ,ci.corebank ,decode(af.bankname,'---',V_SYSNAME,af.bankname) bankname,ci.trdesc
                FROM vw_tllog_all TL,afmast af,tltx, tlprofiles mk,tlprofiles ck,
                 vw_citran_gen ci,
                 lnmast ln,lntype , CFMAST CFB
                where tl.msgacct=af.acctno
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
       /*         AND NVL( TL.TLID,'-') LIKE V_STRMAKER
                AND NVL( TL.OFFID,'-') LIKE V_STRCHECKER
                AND ci.corebank  LIKE V_STRCOREBANK
                AND CF.custodycd LIKE V_STRPV_CUSTODYCD
                AND AF.acctno LIKE V_STRPV_AFACCTNO*/
                --and exists (select gu.grpid from tlgrpusers gu where af.careby = gu.grpid and gu.tlid = V_STRTLID )

                union
                SELECT AF.CUSTID, af.careby,  tl.tltxcd ,tltx.txdesc ,tl.txnum,tl.busdate ,tl.txdate,af.acctno, '' custodycdc,'' acctnoc,tl.msgamt amt,nvl(mk.tlname,'') mk,nvl(ck.tlname,'')  ck,nvl(tl.brid,'') brid,nvl(tl.tlid,'') tlid,nvl(tl.OFFID,'') OFFID,
                nvl(CFB.shortname,'') bankid ,ci.corebank ,decode(af.bankname,'---',V_SYSNAME,af.bankname) bankname, tl.txdesc trdesc
                FROM vw_tllog_all TL,afmast af,tltx, tlprofiles mk,tlprofiles ck,  vw_tllogfld_all tlfld, lnmast ln,lntype , CFMAST CFB,vw_citran_all ci
                where tl.msgacct=af.acctno
                and ci.txdate = tl.txdate  and ci.txnum = tl.txnum
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
          /*      AND NVL( TL.TLID,'-') LIKE V_STRMAKER
                AND NVL( TL.OFFID,'-') LIKE V_STRCHECKER
                AND ci.corebank  LIKE V_STRCOREBANK
                AND CF.custodycd LIKE V_STRPV_CUSTODYCD
                AND AF.acctno LIKE V_STRPV_AFACCTNO*/
                --and exists (select gu.grpid from tlgrpusers gu where af.careby = gu.grpid and gu.tlid = V_STRTLID )

                union
                SELECT AF.CUSTID,af.careby,  tl.tltxcd   tltxcd ,tltx.txdesc ,tl.txnum,tl.busdate ,tl.txdate,af.acctno, '' custodycdc,'' acctnoc,ci.namt amt,nvl(mk.tlname,'') mk,nvl(ck.tlname,'')  ck,nvl(tl.brid,'') brid,nvl(tl.tlid,'') tlid,nvl(tl.OFFID,'') OFFID,
                ''bankid,ci.corebank ,decode(af.bankname,'---',V_SYSNAME,af.bankname) bankname,CI.trdesc
                FROM vw_tllog_all TL,afmast af,tltx, tlprofiles mk,tlprofiles ck,
                 vw_citran_gen   ci
                where ci.acctno=af.acctno
                and tltx.tltxcd = tl.tltxcd
                and  tl.tlid = mk.tlid(+)
                and  tl.OFFID =ck.tlid(+)
                and af.ALTERNATEACCT like v_strALTERNATEACCT
                and tl.txdate = ci.txdate
                and tl.txnum = ci.txnum
                and tl.tltxcd  IN ('0088','1670','1610','1110','1600','1620','1137','1138','3384') --chaunh add 3384
                and ci.field ='BALANCE'
                --and decode (V_STRTYPEDATE,'002',TL.busdate,TL.txdate)>=to_date(F_DATE,'DD/MM/YYYY')
                --AND decode (V_STRTYPEDATE,'002',TL.busdate,TL.txdate)<=to_date(T_DATE,'DD/MM/YYYY')
                and TL.busdate  >=to_date(F_DATE,'DD/MM/YYYY')
                and TL.busdate  <=to_date(T_DATE,'DD/MM/YYYY')
                AND TL.TLTXCD LIKE V_STRTLTXCD
                and  nvl(tl.brid,V_STRBRID) like V_STRBRID
           /*     AND NVL( TL.TLID,'-') LIKE V_STRMAKER
                AND NVL( TL.OFFID,'-') LIKE V_STRCHECKER
                AND ci.corebank  LIKE V_STRCOREBANK
                AND CF.custodycd LIKE V_STRPV_CUSTODYCD
                AND AF.acctno LIKE V_STRPV_AFACCTNO*/
                --and exists (select gu.grpid from tlgrpusers gu where af.careby = gu.grpid and gu.tlid = V_STRTLID )
                )a
                  WHERE CF.CUSTID=A.CUSTID
                  AND NVL( A.TLID,'-') LIKE V_STRMAKER
                  AND NVL( A.OFFID,'-') LIKE V_STRCHECKER
                  AND A.corebank  LIKE V_STRCOREBANK
                  AND CF.custodycd LIKE V_STRPV_CUSTODYCD
                  AND A.acctno LIKE V_STRPV_AFACCTNO

                ORDER BY A.TLTXCD ,a.busdate,A.TXNUM
                ;
            else
                OPEN PV_REFCURSOR
                FOR
              select  A.careby, A.tltxcd,A.txdesc ,A.txnum,A.busdate ,A.txdate, CF.CUSTODYCD,A.acctno,
                A.custodycdc,A.acctnoc,A.amt,A.mk,A.ck,
                CF.brid,A.tlid,A.OFFID, A.bankid,A.corebank ,A.bankname,A.trdesc
              from
             (SELECT * FROM CFMAST WHERE FNC_VALIDATE_SCOPE(BRID, CAREBY, TLSCOPE, pv_BRID, TLGOUPS)=0) cf,
             (
                select AF.CUSTID, af.careby, tl.tltxcd,tltx.txdesc ,tl.txnum,tl.busdate ,tl.txdate,af.acctno, cfc.custodycd custodycdc,afc.acctno acctnoc,tl.msgamt amt,nvl(mk.tlname,'') mk,nvl(ck.tlname,'')  ck,nvl(tl.brid,'') brid,nvl(tl.tlid,'') tlid,nvl(tl.OFFID,'') OFFID,
                ''bankid,ci.corebank ,decode(af.bankname,'---',V_SYSNAME,af.bankname) bankname,ci.trdesc
                from vw_tllog_all TL ,vw_citran_gen ci,afmast af, afmast afc,cfmast cfc ,tltx  , tlprofiles mk,tlprofiles ck
                where tl.txnum =ci.txnum and tl.txdate =ci.txdate and ci.acctno= af.acctno
                and ci.ref =afc.acctno and afc.custid =cfc.custid
                and tltx.tltxcd = tl.tltxcd
                and  tl.tlid = mk.tlid(+)
                and  tl.OFFID =ck.tlid(+)
                and tl.tltxcd in ('1120','1130','1134') and ci.field ='BALANCE' and ci.txtype='D'
                --and decode (V_STRTYPEDATE,'002',TL.busdate,TL.txdate)>=to_date(F_DATE,'DD/MM/YYYY')
                --AND decode (V_STRTYPEDATE,'002',TL.busdate,TL.txdate)<=to_date(T_DATE,'DD/MM/YYYY')
                and TL.txdate  >=to_date(F_DATE,'DD/MM/YYYY')
                and TL.txdate  <=to_date(T_DATE,'DD/MM/YYYY')
                AND TL.TLTXCD LIKE V_STRTLTXCD
                and  nvl(tl.brid,V_STRBRID) like V_STRBRID
                and af.ALTERNATEACCT like v_strALTERNATEACCT
              /*  AND NVL( TL.TLID,'-') LIKE V_STRMAKER
                AND NVL( TL.OFFID,'-') LIKE V_STRCHECKER
                AND ci.corebank  LIKE V_STRCOREBANK
                AND CF.custodycd LIKE V_STRPV_CUSTODYCD
                AND AF.acctno LIKE V_STRPV_AFACCTNO*/
                --and exists (select gu.grpid from tlgrpusers gu where af.careby = gu.grpid and gu.tlid = V_STRTLID )

                union
                SELECT AF.CUSTID,af.careby, case when  tl.tltxcd in ('3350','3354') then '3342' else  tl.tltxcd end
                  tltxcd ,tltx.txdesc ,tl.txnum,tl.busdate ,tl.txdate,af.acctno, '' custodycdc,'' acctnoc,tl.msgamt amt,nvl(mk.tlname,'') mk,nvl(ck.tlname,'')  ck,nvl(tl.brid,'') brid,nvl(tl.tlid,'') tlid,nvl(tl.OFFID,'') OFFID,
                ''bankid,ci.corebank ,decode(af.bankname,'---',V_SYSNAME,af.bankname) bankname , tl.txdesc trdesc
                FROM vw_tllog_all TL,afmast af,tltx, tlprofiles mk,tlprofiles ck,vw_citran_all ci
                where substr(tl.msgacct,0,10)=af.acctno
                and tltx.tltxcd = tl.tltxcd
                and  tl.tlid = mk.tlid(+)
                and af.ALTERNATEACCT like v_strALTERNATEACCT
                and  tl.OFFID =ck.tlid(+)
                and tl.tltxcd in ('1140','1100','1107','1101'
                ,'1104','1108','1111','1114','1104','1112','1145','1144'
                ,'1123','1124','1126','1127','1162','1180','1182','6613','1105','1198','1199','8866','1190','1191'
                ,'8856','0066','8889','8894','8851','5541','1146') --Chaunh bo 3384
                --and decode (V_STRTYPEDATE,'002',TL.busdate,TL.txdate)>=to_date(F_DATE,'DD/MM/YYYY')
                --AND decode (V_STRTYPEDATE,'002',TL.busdate,TL.txdate)<=to_date(T_DATE,'DD/MM/YYYY')
                and TL.txdate  >=to_date(F_DATE,'DD/MM/YYYY')
                and TL.txdate  <=to_date(T_DATE,'DD/MM/YYYY')
                AND TL.TLTXCD LIKE V_STRTLTXCD
                AND TL.TLTXCD LIKE V_STRTLTXCD
                and ci.txdate = tl.txdate  and ci.txnum = tl.txnum
                and  nvl(tl.brid,V_STRBRID) like V_STRBRID
       /*         AND NVL( TL.TLID,'-') LIKE V_STRMAKER
                AND NVL( TL.OFFID,'-') LIKE V_STRCHECKER
                AND ci.corebank  LIKE V_STRCOREBANK
                AND CF.custodycd LIKE V_STRPV_CUSTODYCD
                AND AF.acctno LIKE V_STRPV_AFACCTNO*/
                --and exists (select gu.grpid from tlgrpusers gu where af.careby = gu.grpid and gu.tlid = V_STRTLID )
                union
                SELECT AF.CUSTID,  af.careby, tl.tltxcd||'T'|| '0' tltxcd ,tltx.txdesc ,tl.txnum,tl.busdate ,
                tl.txdate,af.acctno, '' custodycdc,'' acctnoc,tl.msgamt amt,nvl(mk.tlname,'') mk,nvl(ck.tlname,'')  ck,nvl(tl.brid,'') brid,nvl(tl.tlid,'') tlid,nvl(tl.OFFID,'') OFFID,
                ''bankid,ci.corebank ,decode(af.bankname,'---',V_SYSNAME,af.bankname) bankname,ci.trdesc
                FROM vw_tllog_all TL,afmast af,tltx, tlprofiles mk,tlprofiles ck,vw_citran_gen CI, vw_stschd_all sts
                where tl.msgacct=af.acctno
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
               /* AND NVL( TL.TLID,'-') LIKE V_STRMAKER
                AND NVL( TL.OFFID,'-') LIKE V_STRCHECKER
                AND ci.corebank  LIKE V_STRCOREBANK
                AND CF.custodycd LIKE V_STRPV_CUSTODYCD
                AND AF.acctno LIKE V_STRPV_AFACCTNO*/
                --and exists (select gu.grpid from tlgrpusers gu where af.careby = gu.grpid and gu.tlid = V_STRTLID )
                union
                SELECT AF.CUSTID, af.careby, case when  tl.tltxcd in ('3350','3354') then '3342' else  tl.tltxcd end
                 tltxcd ,tltx.txdesc ,tl.txnum,tl.busdate ,tl.txdate,af.acctno, '' custodycdc,'' acctnoc,tl.msgamt amt,nvl(mk.tlname,'') mk,nvl(ck.tlname,'')  ck,nvl(tl.brid,'') brid,nvl(tl.tlid,'') tlid,nvl(tl.OFFID,'') OFFID,
                ''bankid,ci.corebank ,decode(af.bankname,'---',V_SYSNAME,af.bankname) bankname,ci.trdesc
                FROM vw_tllog_all TL,afmast af,tltx, tlprofiles mk,tlprofiles ck,vw_citran_gen CI
                where tl.msgacct=af.acctno
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
          /*      AND NVL( TL.TLID,'-') LIKE V_STRMAKER
                AND NVL( TL.OFFID,'-') LIKE V_STRCHECKER
                AND ci.corebank  LIKE V_STRCOREBANK
                AND CF.custodycd LIKE V_STRPV_CUSTODYCD
                AND AF.acctno LIKE V_STRPV_AFACCTNO*/
                --and exists (select gu.grpid from tlgrpusers gu where af.careby = gu.grpid and gu.tlid = V_STRTLID )
                UNION
                SELECT AF.CUSTID,af.careby,  tl.tltxcd ,tltx.txdesc ,tl.txnum,tl.busdate ,tl.txdate,af.acctno, '' custodycdc,'' acctnoc,CI.NAMT amt,nvl(mk.tlname,'') mk,nvl(ck.tlname,'')  ck,nvl(tl.brid,'') brid,nvl(tl.tlid,'') tlid,nvl(tl.OFFID,'') OFFID,
                ''bankid,ci.corebank ,decode(af.bankname,'---',V_SYSNAME,af.bankname) bankname,ci.trdesc
                FROM vw_tllog_all TL,afmast af,tltx, tlprofiles mk,tlprofiles ck,vw_citran_gen CI
                where tl.msgacct=af.acctno
                and tltx.tltxcd = tl.tltxcd
                and  tl.tlid = mk.tlid(+)
                and  tl.OFFID =ck.tlid(+)
                AND TL.TXDATE = CI.TXDATE
                and af.ALTERNATEACCT like v_strALTERNATEACCT
                AND TL.TXNUM = CI.TXNUM
                AND CI.field ='BALANCE'
                and tl.tltxcd in('1153','8865','1139','3386')
                --and decode (V_STRTYPEDATE,'002',TL.busdate,TL.txdate)>=to_date(F_DATE,'DD/MM/YYYY')
                --AND decode (V_STRTYPEDATE,'002',TL.busdate,TL.txdate)<=to_date(T_DATE,'DD/MM/YYYY')
                and TL.txdate  >=to_date(F_DATE,'DD/MM/YYYY')
                and TL.txdate  <=to_date(T_DATE,'DD/MM/YYYY')
                AND TL.TLTXCD LIKE V_STRTLTXCD
                AND TL.TLTXCD LIKE V_STRTLTXCD
                and  nvl(tl.brid,V_STRBRID) like V_STRBRID
         /*       AND NVL( TL.TLID,'-') LIKE V_STRMAKER
                AND NVL( TL.OFFID,'-') LIKE V_STRCHECKER
                AND ci.corebank  LIKE V_STRCOREBANK
                AND CF.custodycd LIKE V_STRPV_CUSTODYCD
                AND AF.acctno LIKE V_STRPV_AFACCTNO*/
                --and exists (select gu.grpid from tlgrpusers gu where af.careby = gu.grpid and gu.tlid = V_STRTLID )

                --1178
                union
                SELECT AF.CUSTID, af.careby, tl.tltxcd,tltx.txdesc ,tl.txnum,tl.busdate ,tl.txdate,af.acctno, '' custodycdc,'' acctnoc,ads.amt amt,nvl(mk.tlname,'') mk,nvl(ck.tlname,'')  ck,nvl(tl.brid,'') brid,nvl(tl.tlid,'') tlid,nvl(tl.OFFID,'') OFFID,
                '' bankid,ci.corebank ,decode(af.bankname,'---',V_SYSNAME,af.bankname) bankname, tl.txdesc trdesc
                FROM vw_tllog_all TL,adschd ads ,afmast af,tltx, tlprofiles mk,tlprofiles ck,vw_citran_all ci
                where tl.msgamt =ads.autoid
                and ci.txdate = tl.txdate  and ci.txnum = tl.txnum
                and TL.msgacct = af.acctno
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
            /*    AND NVL( TL.TLID,'-') LIKE V_STRMAKER
                AND NVL( TL.OFFID,'-') LIKE V_STRCHECKER
                AND ci.corebank  LIKE V_STRCOREBANK
                AND CF.custodycd LIKE V_STRPV_CUSTODYCD
                AND AF.acctno LIKE V_STRPV_AFACCTNO*/
                --and exists (select gu.grpid from tlgrpusers gu where af.careby = gu.grpid and gu.tlid = V_STRTLID )
                --nhom bank
                --'1131','1132','1136','1141'
                union

                SELECT AF.CUSTID, af.careby,  tl.tltxcd ,tltx.txdesc ,tl.txnum,tl.busdate ,tl.txdate,af.acctno, '' custodycdc,'' acctnoc,tl.msgamt amt,nvl(mk.tlname,'') mk,nvl(ck.tlname,'')  ck,nvl(tl.brid,'') brid,nvl(tl.tlid,'') tlid,nvl(tl.OFFID,'') OFFID
                ,nvl(bank.fullname,' ') bankid,ci.corebank ,decode(af.bankname,'---',V_SYSNAME,af.bankname) bankname, tl.txdesc trdesc
                FROM vw_tllog_all TL,afmast af,tltx, tlprofiles mk,tlprofiles ck,vw_tllogfld_all tlfld,banknostro bank,vw_citran_all ci
                where tl.msgacct=af.acctno
                and ci.txdate = tl.txdate  and ci.txnum = tl.txnum
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
             /*   AND NVL( TL.TLID,'-') LIKE V_STRMAKER
                AND NVL( TL.OFFID,'-') LIKE V_STRCHECKER
                AND ci.corebank  LIKE V_STRCOREBANK
                AND CF.custodycd LIKE V_STRPV_CUSTODYCD
                AND AF.acctno LIKE V_STRPV_AFACCTNO*/
                --and exists (select gu.grpid from tlgrpusers gu where af.careby = gu.grpid and gu.tlid = V_STRTLID )
                -- dfgroup
                union
                SELECT AF.CUSTID,af.careby, tl.tltxcd,tltx.txdesc ,tl.txnum,tl.busdate ,tl.txdate,af.acctno, '' custodycdc,'' acctnoc,CI.NAMT amt,nvl(mk.tlname,'') mk,nvl(ck.tlname,'')  ck,nvl(tl.brid,'') brid,nvl(tl.tlid,'') tlid,nvl(tl.OFFID,'') OFFID,
                nvl(CFB.shortname,'') bankid ,ci.corebank ,decode(af.bankname,'---',V_SYSNAME,af.bankname) bankname, CI.trdesc trdesc
                FROM vw_tllog_all TL,dfgroup dfg ,afmast af,tltx, tlprofiles mk,tlprofiles ck,
                 lnmast ln,lntype , CFMAST CFB,vw_citran_gen CI
                where tl.msgacct= dfg.groupid and dfg.afacctno = af.acctno
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
            /*    AND NVL( TL.TLID,'-') LIKE V_STRMAKER
                AND NVL( TL.OFFID,'-') LIKE V_STRCHECKER
                AND ci.corebank  LIKE V_STRCOREBANK
                AND CF.custodycd LIKE V_STRPV_CUSTODYCD
                AND AF.acctno LIKE V_STRPV_AFACCTNO*/
                --and exists (select gu.grpid from tlgrpusers gu where af.careby = gu.grpid and gu.tlid = V_STRTLID )

                union
                SELECT AF.CUSTID, af.careby,  tl.tltxcd ,tltx.txdesc ,tl.txnum,tl.busdate ,tl.txdate,af.acctno, '' custodycdc,'' acctnoc,ci.NAMT amt,nvl(mk.tlname,'') mk,nvl(ck.tlname,'')  ck,nvl(tl.brid,'') brid,nvl(tl.tlid,'') tlid,nvl(tl.OFFID,'') OFFID,
                nvl(CFB.shortname,'') bankid ,ci.corebank ,decode(af.bankname,'---',V_SYSNAME,af.bankname) bankname,ci.trdesc
                FROM vw_tllog_all TL,afmast af,tltx, tlprofiles mk,tlprofiles ck,
                 vw_citran_gen ci,
                 lnmast ln,lntype , CFMAST CFB
                where tl.msgacct=af.acctno
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
      /*          AND NVL( TL.TLID,'-') LIKE V_STRMAKER
                AND NVL( TL.OFFID,'-') LIKE V_STRCHECKER
                AND ci.corebank  LIKE V_STRCOREBANK
                AND CF.custodycd LIKE V_STRPV_CUSTODYCD
                AND AF.acctno LIKE V_STRPV_AFACCTNO*/
                --and exists (select gu.grpid from tlgrpusers gu where af.careby = gu.grpid and gu.tlid = V_STRTLID )

                union
                SELECT AF.CUSTID, af.careby,  tl.tltxcd ,tltx.txdesc ,tl.txnum,tl.busdate ,tl.txdate,af.acctno, '' custodycdc,'' acctnoc,tl.msgamt amt,nvl(mk.tlname,'') mk,nvl(ck.tlname,'')  ck,nvl(tl.brid,'') brid,nvl(tl.tlid,'') tlid,nvl(tl.OFFID,'') OFFID,
                nvl(CFB.shortname,'') bankid ,ci.corebank ,decode(af.bankname,'---',V_SYSNAME,af.bankname) bankname, tl.txdesc trdesc
                FROM vw_tllog_all TL,afmast af,tltx, tlprofiles mk,tlprofiles ck,  vw_tllogfld_all tlfld, lnmast ln,lntype , CFMAST CFB,vw_citran_all ci
                where tl.msgacct=af.acctno
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
            /*    AND NVL( TL.TLID,'-') LIKE V_STRMAKER
                AND NVL( TL.OFFID,'-') LIKE V_STRCHECKER
                AND ci.corebank  LIKE V_STRCOREBANK
                AND CF.custodycd LIKE V_STRPV_CUSTODYCD
                AND AF.acctno LIKE V_STRPV_AFACCTNO*/
                --and exists (select gu.grpid from tlgrpusers gu where af.careby = gu.grpid and gu.tlid = V_STRTLID )

                union
                SELECT AF.CUSTID,af.careby,  tl.tltxcd   tltxcd ,tltx.txdesc ,tl.txnum,tl.busdate ,tl.txdate,af.acctno, '' custodycdc,'' acctnoc,ci.namt amt,nvl(mk.tlname,'') mk,nvl(ck.tlname,'')  ck,nvl(tl.brid,'') brid,nvl(tl.tlid,'') tlid,nvl(tl.OFFID,'') OFFID,
                ''bankid,ci.corebank ,decode(af.bankname,'---',V_SYSNAME,af.bankname) bankname,CI.trdesc
                FROM vw_tllog_all TL,afmast af,tltx, tlprofiles mk,tlprofiles ck,
                 vw_citran_gen   ci
                where ci.acctno=af.acctno
                and tltx.tltxcd = tl.tltxcd
                and  tl.tlid = mk.tlid(+)
                and  tl.OFFID =ck.tlid(+)
                and tl.txdate = ci.txdate
                and af.ALTERNATEACCT like v_strALTERNATEACCT
                and tl.txnum = ci.txnum
                and tl.tltxcd  IN ('0088','1670','1610','1110','1600','1620','1137','1138','3384') --chaunh add 3384
                and ci.field ='BALANCE'
                --and decode (V_STRTYPEDATE,'002',TL.busdate,TL.txdate)>=to_date(F_DATE,'DD/MM/YYYY')
                --AND decode (V_STRTYPEDATE,'002',TL.busdate,TL.txdate)<=to_date(T_DATE,'DD/MM/YYYY')
                and TL.txdate  >=to_date(F_DATE,'DD/MM/YYYY')
                and TL.txdate  <=to_date(T_DATE,'DD/MM/YYYY')
                AND TL.TLTXCD LIKE V_STRTLTXCD
                AND TL.TLTXCD LIKE V_STRTLTXCD
                and  nvl(tl.brid,V_STRBRID) like V_STRBRID
               /* AND NVL( TL.TLID,'-') LIKE V_STRMAKER
                AND NVL( TL.OFFID,'-') LIKE V_STRCHECKER
                AND ci.corebank  LIKE V_STRCOREBANK
                AND CF.custodycd LIKE V_STRPV_CUSTODYCD
                AND AF.acctno LIKE V_STRPV_AFACCTNO*/
                --and exists (select gu.grpid from tlgrpusers gu where af.careby = gu.grpid and gu.tlid = V_STRTLID )
                )a

                 WHERE CF.CUSTID=A.CUSTID
                  AND NVL( A.TLID,'-') LIKE V_STRMAKER
                  AND NVL( A.OFFID,'-') LIKE V_STRCHECKER
                  AND A.corebank  LIKE V_STRCOREBANK
                  AND CF.custodycd LIKE V_STRPV_CUSTODYCD
                  AND A.acctno LIKE V_STRPV_AFACCTNO
                ORDER BY A.TLTXCD ,a.busdate,A.TXNUM
                ;
            end if;

        END IF ;
END IF;

EXCEPTION
    WHEN OTHERS
   THEN
      RETURN;
END; -- Procedure
 
/
