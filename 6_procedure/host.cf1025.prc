SET DEFINE OFF;
CREATE OR REPLACE PROCEDURE "CF1025" (
   PV_REFCURSOR           IN OUT   PKG_REPORT.REF_CURSOR,
   OPT                    IN       VARCHAR2,
   pv_BRID                   IN       VARCHAR2,
   TLGOUPS        IN       VARCHAR2,
   TLSCOPE        IN       VARCHAR2,
   F_DATE                 IN       VARCHAR2,
   T_DATE                 IN       VARCHAR2

  )
IS
--


   CUR            PKG_REPORT.REF_CURSOR;
   V_STROPTION    VARCHAR2 (5);            -- A: ALL; B: BRANCH; S: SUB-BRANCH
   V_STRBRID      VARCHAR2 (4);                   -- USED WHEN V_NUMOPTION > 0
   v_FromDate     date;
   v_ToDate       date;
   v_CurrDate     date;
   v_CustodyCD    varchar2(20);
   v_AFAcctno     varchar2(20);
   v_TLID         varchar2(4);
   V_TRADELOG CHAR(2);
   V_AUTOID NUMBER;

BEGIN


   V_STROPTION := OPT;

   IF V_STROPTION = 'A' then
      V_STRBRID := '%';
   ELSIF V_STROPTION = 'B' then
      V_STRBRID := substr(pv_BRID,1,2) || '__' ;
   else
    V_STRBRID:=pv_BRID;
   END IF;

   v_FromDate  :=     TO_DATE(F_DATE, SYSTEMNUMS.C_DATE_FORMAT);
   v_ToDate    :=     TO_DATE(T_DATE, SYSTEMNUMS.C_DATE_FORMAT);


   select TO_DATE(VARVALUE, SYSTEMNUMS.C_DATE_FORMAT) into v_CurrDate from SYSVAR where grname='SYSTEM' and varname='CURRDATE';


OPEN PV_REFCURSOR FOR


select BR.brname, A.* from (

    select tci.autoid orderid, tci.custid, tci.custodycd ,
        tci.fullname,tci.acctno afacctno, tci.tllog_autoid autoid, tci.txtype,
        tci.busdate,
        nvl(tci.trdesc,tci.txdesc) txdesc,
        --CASE WHEN TLTXCD = '3350' THEN tci.txdesc ELSE nvl(tci.trdesc,tci.txdesc) END txdesc,
        '' symbol, 0 se_credit_amt, 0 se_debit_amt,
        case when tci.txtype = 'C' then namt else 0 end ci_credit_amt,
        case when tci.txtype = 'D' then namt else 0 end ci_debit_amt,
        tci.txnum, '' tltx_name, tci.tltxcd, tci.txdate, tci.txcd, tci.dfacctno dealno,
        tci.old_dfacctno description, tci.trdesc, tci.bkdate
    from   (
        SELECT 0 AUTOID, CF.custodycd, cf.custid,tla.cvalue fullname, TL.txnum, TL.txdate, TL.MSGacct acctno,'D' txcd,tl.msgamt namt,
            '' camt, '' ref, nvl(TL.deltd, 'N') deltd, TL.MSGacct acctref,
            tl.tltxcd, tl.busdate, tl.txdesc, tl.txtime, tl.brid, tl.tlid, tl.offid, tl.chid,
            '' dfacctno,' ' old_dfacctno,
            'D' txtype, 'BALANCE' field,
             tl.autoid+1 tllog_autoid,
            '' trdesc, TL.txdate bkdate
            FROM VW_TLLOG_ALL TL, (SELECT * FROM CFMAST WHERE FNC_VALIDATE_SCOPE(BRID, CAREBY, TLSCOPE, pv_BRID, TLGOUPS)=0) cf, vw_tllogfld_all tla
            where tl.txdate = tla.txdate and tl.txnum = tla.txnum and tla.fldcd = '90'
            and TL.MSGacct       =    cf.idcode (+)
            --and     ci.ref          =    df.lnacctno (+)
            and     tl.deltd        <>  'Y'
             --AND TL.TLTXCD IN ('1134','1135','1115','1108')
             AND TL.TLTXCD IN ('1134')

             union all

             SELECT 0 AUTOID, CF.custodycd, cf.custid,tla.cvalue fullname, TL.txnum, TL.txdate, TL.MSGacct acctno,'C' txcd,tl.msgamt namt,
            '' camt, '' ref, nvl(TL.deltd, 'N') deltd, TL.MSGacct acctref,
            tl.tltxcd, tl.busdate, tl.txdesc, tl.txtime, tl.brid, tl.tlid, tl.offid, tl.chid,
            '' dfacctno,' ' old_dfacctno,
            'C' txtype, 'BALANCE' field,
             tl.autoid+1 tllog_autoid,
            '' trdesc, TL.txdate bkdate
            FROM VW_TLLOG_ALL TL, (SELECT * FROM CFMAST WHERE FNC_VALIDATE_SCOPE(BRID, CAREBY, TLSCOPE, pv_BRID, TLGOUPS)=0) cf, vw_tllogfld_all tla
            where tl.txdate = tla.txdate and tl.txnum = tla.txnum and tla.fldcd = '90'
            and TL.MSGacct       =    cf.idcode (+)
            --and     ci.ref          =    df.lnacctno (+)
            and     tl.deltd        <>  'Y'
             --AND TL.TLTXCD IN ('1133','1136')
             AND TL.TLTXCD IN ('1133')

             union all

            select ci.autoid, cf.custodycd, cf.custid,cf.fullname,
            ci.txnum, ci.txdate, ci.acctno, ci.txcd, ci.namt,
            ci.camt, ci.ref, nvl(ci.deltd, 'N') deltd, ci.acctref,
            tl.tltxcd, tl.busdate, tl.txdesc, tl.txtime, tl.brid, tl.tlid, tl.offid, tl.chid,
            --(case when tl.tltxcd in ('2670') then ci.ref else df.acctno end) dfacctno,
            ci.ref dfacctno,
            --(case when df.txdate <= '31-may-2010' then nvl(df.description, ' ') else '' end) old_dfacctno,
            ' ' old_dfacctno,
            app.txtype, app.field, tl.autoid tllog_autoid, ci.trdesc, nvl(ci.bkdate, ci.txdate) bkdate
            from    (SELECT * FROM CITRAN UNION ALL SELECT * FROM CITRANA) CI,
                    VW_TLLOG_ALL TL, (SELECT * FROM CFMAST WHERE FNC_VALIDATE_SCOPE(BRID, CAREBY, TLSCOPE, pv_BRID, TLGOUPS)=0) cf, afmast af, apptx app --, VW_DFMAST_ALL df
            where   ci.txdate       =    tl.txdate
            and     ci.txnum        =    tl.txnum
            and     cf.custid       =    af.custid
            and     ci.acctno       =    af.acctno
            and     ci.txcd         =    app.txcd
            and af.corebank <> 'Y'
            and     app.apptype     =    'CI'
            and     app.txtype      in   ('D','C')
            --and     ci.ref          =    df.lnacctno (+)
            and     tl.deltd        <>  'Y'
            and     ci.deltd        <>  'Y'
            and     ci.namt         <>  0
            AND TL.TLTXCD in ('1131','1132')


            ) tci
    where  tci.bkdate between v_FromDate and v_ToDate
       and tci.field = 'BALANCE'
       AND TCI.TLTXCD NOT IN ('8855','8865','8856','8866','0066','1144','1145','8889')  -- them 2 giao dich '1144','1145' phong toa, GianhVG


) a, BRGRP BR WHERE SUBSTR(TXNUM,1,4) =  BR.brid and a.tltxcd in ('1131','1132','1133','1134')
ORDER BY BRNAME, TXDATE, TXNUM;


EXCEPTION
  WHEN OTHERS
   THEN
      Return;
End;

 
 
 
 
/
