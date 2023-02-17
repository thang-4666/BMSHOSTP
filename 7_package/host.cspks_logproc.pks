SET DEFINE OFF;
CREATE OR REPLACE PACKAGE cspks_logproc
IS
    /*----------------------------------------------------------------------------------------------------
     ** Module   : COMMODITY SYSTEM
     ** and is copyrighted by FSS.
     **
     **    All rights reserved.  No part of this work may be reproduced, stored in a retrieval system,
     **    adopted or transmitted in any form or by any means, electronic, mechanical, photographic,
     **    graphic, optic recording or otherwise, translated in any language or computer language,
     **    without the prior written permission of Financial Software Solutions. JSC.
     **
     **  MODIFICATION HISTORY
     **  Person      Date           Comments
     **  FSS      20-mar-2010    Created
     ** (c) 2008 by Financial Software Solutions. JSC.
     ----------------------------------------------------------------------------------------------------*/
    PROCEDURE pr_log_mr0002(pv_Action varchar2);
    procedure pr_log_mr3008(pv_Action varchar2);
    procedure pr_log_mr3009(pv_Action varchar2);
    procedure pr_log_MARGINRATE_LOG(pv_Action varchar2);
    procedure pr_log_mr0058(pv_Action varchar2);
    procedure pr_log_mr0060(pv_Action varchar2);
    procedure pr_log_mr0063(pv_Action varchar2);
    procedure pr_log_mr0059(pv_Action varchar2);
    procedure pr_log_mr0057(pv_Action varchar2);
    procedure pr_log_vmr0001(pv_Action varchar2);
    procedure pr_log_mr0056(pv_Action varchar2);
    procedure pr_log_mr0064(pv_Action varchar2);
END;
 
 
 
 
/


CREATE OR REPLACE PACKAGE BODY cspks_logproc
IS
   -- declare log context
   pkgctx   plog.log_ctx;
   logrow   tlogdebug%ROWTYPE;

procedure pr_log_mr0064(pv_Action varchar2)
is
    v_curdate varchar2(20);
begin
    plog.setbeginsection(pkgctx, 'pr_log_mr0064');
    v_curdate:=cspks_system.fn_get_sysvar('SYSTEM','PREVDATE');
    insert into log_mr0064
    (INDATE,BRNAME,CUSTID,CUSTODYCD,FULLNAME,ACCTNO,OPNDATE,MRTYPE,MARGINRATE,MRIRATE,MRMRATE,
    MRLRATE,MRCRATE,MRWRATE,ADD_TO_MRIRATE, SE_TO_MRIRATEUB,
    SE_TO_MRIRATE, ADVLIMIT,MRCRLIMITMAX,BALANCE,  AMT,  ORDER_AMT,PP,MAX_ADVAMT,TDAMT, EXECBUYAMT)

     SELECT    INDATE,BRNAME,CUSTID,CUSTODYCD,LN.FULLNAME,LN.ACCTNO,OPNDATE,MRTYPE,MARGINRATE,MRIRATE,MRMRATE,
            MRLRATE,MRCRATE,MRWRATE,ADD_TO_MRIRATE, SE_TO_MRIRATEUB, SE_TO_MRIRATE, ADVLIMIT,MRCRLIMITMAX,BALANCE,
             AMT,  ORDER_AMT,PP,MAX_ADVAMT,TDAMT,EXECBUYAMT
 FROM ( SELECT TO_DATE(v_curdate, systemnums.c_date_format) INDATE,MAIN.BRNAME, MAIN.CUSTID,MAIN.CUSTODYCD, MAIN.FULLNAME, MAIN.ACCTNO, MAIN.OPNDATE,MAIN.MRTYPE,MAIN.MARGINRATE,MAIN.MRIRATE,MAIN.MRMRATE,
            MAIN.MRLRATE,MAIN.MRCRATE,MAIN.MRWRATE,MAIN.ADD_TO_MRIRATE, greatest(MAIN.SE_TO_MRIRATEUB  ,0)      SE_TO_MRIRATEUB,
            greatest(case when MAIN.SE_TO_MRIRATE <0 then 0 else MAIN.SE_TO_MRIRATE end,0) SE_TO_MRIRATE,
            (MAIN.ADVLIMIT- main.DFODAMT - nvl(lai.nml,0) -fn_get_margin_execbuyamt_sec( main.ACCTNO) ) ADVLIMIT,
            MAIN.MRCRLIMITMAX,MAIN.BALANCE, NVL(LAI.AMT,0) AMT,  NVL(QTTY.AMT,0) ORDER_AMT, main.pp,
            NVL(main.MAX_ADVAMT,0)MAX_ADVAMT,MAIN.TDAMT, MAIN.EXECBUYAMT
            FROM(
                         SELECT BR.BRNAME,CF.CUSTID, CF.FULLNAME,CF.CUSTODYCD,AF.ACCTNO, AF.OPNDATE,MR.MRTYPE,
                             NVL(CI.MARGINRATE,0) MARGINRATE,AF.MRIRATE, AF.MRMRATE,AF.MRLRATE,AF.MRCRATE,AF.MRWRATE,
                                         (case when aft.mnemonic<>'T3' then
                                         round((case when nvl(ci.marginrate,0) * af.mrmrate =0 then - nvl(ci.se_outstanding,0) else greatest( 0,- nvl(ci.se_outstanding,0) - nvl(ci.se_navaccount,0) *100/AF.MRIRATE) end),0)
                                         else 0  end) ADD_TO_MRIRATE, --So tien can bo sung ve Rat
                                         af.mrirate/100 * round(-ci.se_outstanding) - ci.seass SE_TO_MRIRATE, -- se can bo sung dat Rat
                                            round((-af.mrirate/100 * ci.se_outstanding - ci.seass) / (af.mrirate/100 - 0.5),4) SE_TO_MRIRATEUB,
                                             ci.PP ,NVL(AF.mrcrlimitmax,0) ADVLIMIT,--HAN MUC CON LAI
                                             AF.MRCRLIMITMAX,--HAN MUC CAP TRONG NGAY
                                             NVL(CIMAST.BALANCE,0)/*+NVL(CI.rcvamt,0)*/ BALANCE,
                                              nvl(ci.avladvance,0) MAX_ADVAMT,
                                        NVL(TD.BALANCE,0)  TDAMT, NVL(CI.BAMT,0)EXECBUYAMT, ci.DFODAMT
                            FROM CFMAST CF, AFMAST AF, BRGRP BR, BUF_CI_ACCOUNT CI,AFTYPE AFT,MRTYPE MR , CIMAST,
                               (select AFACCTNO,SUM(CASE WHEN NVL(BUYINGPOWER,'')='Y' THEN NVL(BALANCE,0) ELSE 0 END)BALANCE from TDMAST
                                WHERE STATUS<>'C' AND DELTD<>'Y' GROUP BY AFACCTNO ) TD
                            WHERE AF.CUSTID=CF.CUSTID
                                        AND CF.BRID=BR.BRID(+)
                                        AND CI.AFACCTNO=AF.ACCTNO
                                        AND AF.ACTYPE=AFT.ACTYPE
                                        AND AFT.MRTYPE=MR.ACTYPE
                                        AND MR.MRTYPE='T'
                                        AND AF.ACCTNO=CIMAST.ACCTNO(+)
                                        AND AF.ACCTNO=TD.AFACCTNO(+)
                                        AND AF.STATUS <> 'C'
                                      ) MAIN
       LEFT JOIN
            (select trfacctno ACCTNO ,nvl(sum(case when ftype = 'AF' then prinnml+prinovd+intnmlacr+intnmlovd+intovdacr+intdue+feeintnmlacr+
            feeintnmlovd+feeintovdacr+feeintdue else 0 end),0) AMT, ROUND(SUM(PRINNML+PRINOVD)) NML
            from lnmast group by trfacctno) LAI ON MAIN.ACCTNO=LAI.ACCTNO
    LEFT JOIN

           ( SELECT MAIN.ACCTNO,SUM(main.qtty * nvl(ris.mrratiorate,0)/100 * least(main.MARGINCALLPRICE,nvl(ris.mrpricerate,0))) amt
              FROM (select af.acctno, af.actype,se.codeid ,sb.MARGINCALLPRICE,
               se.trade + nvl(sts.receiving,0)+ nvl(BUYQTTY,0)- nvl(od.EXECQTTY,0) qtty
            from semast se inner join afmast af on se.afacctno =af.acctno
            inner join securities_info sb on se.codeid=sb.codeid

            left join
            (select sum(BUYQTTY) BUYQTTY, sum(BUYINGQTTY) BUYINGQTTY, sum(EXECQTTY) EXECQTTY , AFACCTNO, CODEID
                    from (
                        SELECT (case when od.exectype IN ('NB','BC') then REMAINQTTY + EXECQTTY - DFQTTY else 0 end) BUYQTTY,
                               (case when od.exectype IN ('NB','BC') then REMAINQTTY else 0 end) BUYINGQTTY,
                               (case when od.exectype IN ('NS','MS') and od.stsstatus <> 'C' then EXECQTTY - nvl(dfexecqtty,0) else 0 end) EXECQTTY,AFACCTNO, CODEID
                        FROM odmast od, afmast af,
                            (select orderid, sum(execqtty) dfexecqtty from odmapext where type = 'D' group by orderid) dfex
                           where od.afacctno = af.acctno and od.orderid = dfex.orderid(+)
                           and od.txdate =(select to_date(VARVALUE,'DD/MM/RRRR') from sysvar where grname='SYSTEM' and varname='CURRDATE')
                           AND od.deltd <> 'Y'
                           and not(od.grporder='Y' and od.matchtype='P')
                           AND od.exectype IN ('NS', 'MS','NB','BC')
                        )
             group by AFACCTNO, CODEID
             ) OD
            on OD.afacctno =se.afacctno and OD.codeid =se.codeid
            left join
            (SELECT STS.CODEID,STS.AFACCTNO,
                    SUM(CASE WHEN DUETYPE ='RS' AND STS.TXDATE <> TO_DATE(sy.VARVALUE,'DD/MM/RRRR') THEN QTTY-AQTTY ELSE 0 END) RECEIVING
                FROM STSCHD STS, ODMAST OD, ODTYPE TYP,
                sysvar sy
                WHERE STS.DUETYPE IN ('RM','RS') AND STS.STATUS ='N'
                    and sy.grname = 'SYSTEM' and sy.varname = 'CURRDATE'
                    AND STS.DELTD <>'Y' AND STS.ORGORDERID=OD.ORDERID AND OD.ACTYPE =TYP.ACTYPE
                    GROUP BY STS.AFACCTNO,STS.CODEID
             ) sts
            on sts.afacctno =se.afacctno and sts.codeid=se.codeid) MAIN LEFT JOIN AFSERISK RIS ON MAIN.CODEID=RIS.CODEID AND MAIN.ACTYPE=RIS.ACTYPE
              group by  MAIN.ACCTNO) QTTY ON MAIN.ACCTNO=QTTY.ACCTNO
                       )LN

;

    plog.setendsection(pkgctx, 'pr_log_mr0064');
    EXCEPTION
  WHEN OTHERS
   THEN
      plog.debug (pkgctx,'got error on pr_log_mr0064');
      ROLLBACK;
      plog.error (pkgctx, SQLERRM || dbms_utility.format_error_backtrace);
      plog.setendsection (pkgctx, 'pr_log_mr0064');
      RAISE errnums.E_SYSTEM_ERROR;
end;

procedure pr_log_mr0056(pv_Action varchar2)
is
    v_curdate varchar2(20);
begin
    plog.setbeginsection(pkgctx, 'pr_log_mr0056');
    v_curdate:=cspks_system.fn_get_sysvar('SYSTEM','PREVDATE');
    insert into log_mr0056
    SELECT TO_DATE(v_curdate, systemnums.c_date_format) INDATE, MR.*
        FROM
               (
                 SELECT SB.CODEID,SB.SYMBOL,(NVL(MST.SELIMIT,0)+ RM.MRMAXQTTY) MRMAXQTTY,SB.BASICPRICE,
                       (NVL(MST.USERLIMIT,0)+RM.SEQTTY) SEQTTY,(NVL(MST.USERLIMIT,0)+RM.SEQTTY)*SB.BASICPRICE GIA_TRI
                FROM SECURITIES_INFO SB, V_GETMARGINROOMINFO RM,
                     (SELECT CODEID, SELIMIT, fn_getUsedSeLimitByGroup(autoid) USERLIMIT FROM SELIMITGRP ) MST
                WHERE SB.CODEID=RM.CODEID
                      and sb.CODEID=mst.codeid(+)
                      AND (RM.MRMAXQTTY+RM.SEQTTY+NVL(MST.SELIMIT,0)+NVL(MST.USERLIMIT,0))<>0
                      ORDER BY RM.SEQTTY DESC
                )MR
   ;

    plog.setendsection(pkgctx, 'pr_log_mr0056');
    EXCEPTION
  WHEN OTHERS
   THEN
      plog.debug (pkgctx,'got error on pr_log_mr0002');
      ROLLBACK;
      plog.error (pkgctx, SQLERRM || dbms_utility.format_error_backtrace);
      plog.setendsection (pkgctx, 'pr_log_mr0056');
      RAISE errnums.E_SYSTEM_ERROR;
end;

procedure pr_log_mr0002(pv_Action varchar2)
is
    v_curdate varchar2(20);
begin
    plog.setbeginsection(pkgctx, 'pr_log_mr0002');
    v_curdate:=cspks_system.fn_get_sysvar('SYSTEM','CURRDATE');
    insert into mr0002_log
    (actype, typename, co_financing, ismarginacc, custodycd,
       acctno, fullname, mobilesms, email,
       marginrate, rtnamt, addvnd,
       mrirate, mrmrate, mrlrate, totalvnd,
       advanceline, seass, mrcrlimit, mrcrlimitmax,
       dfodamt, mrcrlimitremain, status, dueamount, ovdamount,
       calldate, calltime, txdate, log_date, log_action)
    select actype, typename, '' co_financing, '' ismarginacc, custodycd,
       acctno, fullname, mobilesms, email,
       marginrate, rtnamt, addvnd,
       mrirate, mrmrate, mrlrate, totalvnd,
       advanceline, seass, mrcrlimit, mrcrlimitmax,
       dfodamt, mrcrlimitremain, status, dueamount, ovdamount,
       calldate, calltime, to_date(v_curdate,'DD/MM/RRRR'),SYSTIMESTAMP log_date, pv_Action log_action from vw_mr0002;
    plog.setendsection(pkgctx, 'pr_log_mr0002');
    EXCEPTION
  WHEN OTHERS
   THEN
      plog.debug (pkgctx,'got error on pr_log_mr0002');
      ROLLBACK;
      plog.error (pkgctx, SQLERRM || dbms_utility.format_error_backtrace);
      plog.setendsection (pkgctx, 'pr_log_mr0002');
      RAISE errnums.E_SYSTEM_ERROR;
end;

procedure pr_log_mr3008(pv_Action varchar2)
is
    v_curdate varchar2(20);
begin
    plog.setbeginsection(pkgctx, 'pr_log_mr3008');
    v_curdate:=cspks_system.fn_get_sysvar('SYSTEM','CURRDATE');
    insert into mr3008_log
    (ftype, custodycd, afacctno, dfgroupid, fullname,
       marginrate, mrmrate, odamt, navaccount, addvnd,
       refullname, txdate, log_date, log_action)
    select a.*, to_date(v_curdate,'DD/MM/RRRR') txdate, SYSTIMESTAMP log_date, pv_Action log_action
        from (
        select --l_OPT OPT,l_BRID BRID, l_NEXTDATE RPTDATE,
        'AF' FTYPE,cf.custodycd, af.acctno afacctno, '' dfgroupid, cf.fullname,
        round(sec.marginrate) marginrate, af.mrmrate,
            ci.odamt, sec.NAVACCOUNT,
            greatest(round((case when nvl(sec.marginrate,0) * af.mrmrate =0 then - outstanding else
                             greatest( 0,- outstanding - navaccount *100/af.mrmrate) end),0)) addvnd,
        re.refullname

        from cfmast cf, afmast af, cimast ci, aftype aft, mrtype mrt, v_getsecmarginratio sec,
        (select re.afacctno, MAX(cf.fullname) refullname
            from reaflnk re, sysvar sys, cfmast cf,RETYPE
            where to_date(varvalue,'DD/MM/RRRR') between re.frdate and re.todate
            and substr(re.reacctno,0,10) = cf.custid
            and varname = 'CURRDATE' and grname = 'SYSTEM'
            and re.status <> 'C' and re.deltd <> 'Y'
            AND   substr(re.reacctno,11) = RETYPE.ACTYPE
            AND  rerole IN ( 'RM','BM')
            GROUP BY AFACCTNO
        ) re
        where cf.custid = af.custid and af.acctno = sec.afacctno
        and af.actype = aft.actype and af.acctno = ci.acctno
        and aft.mrtype = mrt.actype and mrt.mrtype = 'T'
        and af.acctno = re.afacctno(+)
        and (af.mrlrate <= sec.marginrate AND round(sec.marginrate) < af.mrmrate)
        --and case when l_OPT = 'A' then 1 else instr(l_BRID_FILTER,substr(af.acctno,1,4)) end  <> 0

        union all

        SELECT --l_OPT OPT,l_BRID BRID, l_NEXTDATE RPTDATE,
        'DF' FTYPE,custodycd,afacctno, groupid dfgroupid,fullname, round(rtt) rtt, mrate, DDF, tadf, ODSELLDF,
        refullname
        FROM ( select al1.cdcontent DEALFLAGTRIGGER,DF.GROUPID,CF.CUSTODYCD,CF.FULLNAME,AF.ACCTNO AFACCTNO,CF.ADDRESS,CF.IDCODE,DECODE(DF.LIMITCHK,'N',0,1) LIMITCHECK ,
        DF.ORGAMT -DF.RLSAMT AMT, DF.LNACCTNO , DF.STATUS DEALSTATUS ,DF.ACTYPE ,DF.RRTYPE, DF.DFTYPE, DF.CUSTBANK, DF.CIACCTNO,DF.FEEMIN,
        DF.TAX,DF.AMTMIN,DF.IRATE,DF.MRATE,DF.LRATE,DF.RLSAMT,DF.DESCRIPTION, lns.rlsdate, lns.overduedate,
        to_date (lns.overduedate,'DD/MM/RRRR') - to_date ((SELECT VARVALUE FROM SYSVAR WHERE VARNAME='CURRDATE'),'DD/MM/RRRR') duenum,
        (case when df.ciacctno is not null then df.ciacctno when df.custbank is not null then   df.custbank else '' end )
        RRID , decode (df.RRTYPE,'O',1,0) CIDRAWNDOWN,decode (df.RRTYPE,'B',1,0) BANKDRAWNDOWN,
        decode (df.RRTYPE,'C',1,0) CMPDRAWNDOWN,dftype.AUTODRAWNDOWN,df.calltype,LN.RLSAMT AMTRLS,
        LN.RATE1,LN.RATE2,LN.RATE3,LN.CFRATE1,LN.CFRATE2,LN.CFRATE3,
        A1.CDCONTENT PREPAIDDIS,A2.CDCONTENT INTPAIDMETHODDIS,A3.CDCONTENT AUTOAPPLYDIS,TADF,DDF, RTTDF RTT, ODCALLDF, ODCALLSELLRCB,ODCALLSELLMRATE, ODCALLSELLIRATE - NVL(od.sellamount,0) ODSELLDF, ODCALLSELLRXL, ODCALLRTTDF, ODCALLRTTDF ODCALLRTTF,
        CURAMT, CURINT, CURFEE, LNS.PAID, DF.DFBLOCKAMT, vndselldf, vndwithdrawdf, tadf - ddf*(v.irate/100) vwithdrawdf,
        LEAST(ln.MInterm, TO_NUMBER( TO_DATE(lns.OVERDUEDATE,'DD/MM/RRRR') - TO_DATE(lns.RLSDATE,'DD/MM/RRRR')) )  MInterm, ln.intpaidmethod, lnt.WARNINGDAYS,
        A4.CDCONTENT RRTYPENAME, CF.MOBILESMS FAX1, CF.EMAIL, ODDF, re.refullname,
        nvl(ln.prinovd+ln.intovdacr+ln.intnmlovd+ln.feeintovdacr+ln.feeintnmlovd,0)  df_ovdamt
        from dfgroup df, dftype, lnmast ln, lntype lnt ,lnschd lns, afmast af , cfmast cf, allcode al1,
           ALLCODE A1, ALLCODE A2, ALLCODE A3, v_getgrpdealformular v , allcode A4, v_getdealsellamt od,
        (select re.afacctno, MAX(cf.fullname) refullname
            from reaflnk re, sysvar sys, cfmast cf,RETYPE
            where to_date(varvalue,'DD/MM/RRRR') between re.frdate and re.todate
            and substr(re.reacctno,0,10) = cf.custid
            and varname = 'CURRDATE' and grname = 'SYSTEM'
            and re.status <> 'C' and re.deltd <> 'Y'
            AND   substr(re.reacctno,11) = RETYPE.ACTYPE
            AND  rerole IN ( 'RM','BM')
            GROUP BY AFACCTNO
        ) re
        where df.lnacctno= ln.acctno and ln.acctno=lns.acctno and ln.actype=lnt.actype and lns.reftype='P' and df.afacctno= af.acctno and af.custid= cf.custid and df.actype=dftype.actype
        and A1.cdname = 'YESNO' and A1.cdtype ='SY' AND A1.CDVAL = LN.PREPAID
        and A2.cdname = 'INTPAIDMETHOD' and A2.cdtype ='LN' AND A2.CDVAL = LN.INTPAIDMETHOD
        and A3.cdname = 'AUTOAPPLY' and a3.cdtype ='LN' AND A3.CDVAL = LN.AUTOAPPLY
        and A4.cdname = 'RRTYPE' and A4.cdtype ='DF' AND A4.CDVAL = DF.RRTYPE
        and df.flagtrigger=al1.cdval and al1.cdname='FLAGTRIGGER' and df.groupid=v.groupid(+)
        and df.groupid=od.groupid(+) and df.afacctno=od.afacctno(+)
        and df.afacctno = re.afacctno(+)
        --and case when l_OPT = 'A' then 1 else instr(l_BRID_FILTER,substr(af.acctno,1,4)) end  <> 0
        ) WHERE ODDF>0 AND ( round(RTT) < MRATE AND RTT>= LRATE) and df_ovdamt <=0
        ) a  order by custodycd, dfgroupid;
    plog.setendsection(pkgctx, 'pr_log_mr3008');
    EXCEPTION
  WHEN OTHERS
   THEN
      plog.debug (pkgctx,'got error on pr_log_mr3008');
      ROLLBACK;
      plog.error (pkgctx, SQLERRM || dbms_utility.format_error_backtrace);
      plog.setendsection (pkgctx, 'pr_log_mr3008');
      RAISE errnums.E_SYSTEM_ERROR;
end;


procedure pr_log_mr3009(pv_Action varchar2)
is
    v_curdate varchar2(20);
begin
    plog.setbeginsection(pkgctx, 'pr_log_mr3009');
    v_curdate:=cspks_system.fn_get_sysvar('SYSTEM','CURRDATE');
    insert into mr3009_logall
    (ftype, custodycd, afacctno, dfgroupid, fullname,
       marginrate, mrlrate, odamt, navaccount, rtnamtcl,
       rtnamtdf, ovd, marginovd, refullname, txdate,
       log_date, log_action)
    select a.*, to_date(v_curdate,'DD/MM/RRRR') txdate, SYSTIMESTAMP log_date, pv_Action log_action
        from (
        select --l_OPT OPT,l_BRID BRID, l_NEXTDATE RPTDATE,
        'AF' FTYPE,cf.custodycd, af.acctno afacctno, '' dfgroupid, cf.fullname,
            sec.marginrate, af.mrlrate,
            greatest(-outstanding,0) odamt, sec.navaccount NAVACCOUNT,
            round(greatest(round((case when nvl(sec.marginrate,0) * af.mrmrate =0 then - outstanding else
                             greatest( 0,- outstanding - sec.navaccount*100/af.mrmrate) end),0),greatest(ci.ovamt/*+depofeeamt*/ - balance - nvl(avladvance,0),0)),0) rtnamtCL,
            0 rtnamtDF,
            nvl(lnt0.ovd,0) ovd,
            nvl(cl_ovdamt,0) MARGINOVD,
            re.refullname
        from cfmast cf, afmast af, cimast ci, aftype aft, mrtype mrt, v_getsecmarginratio sec,
        (select trfacctno,
                sum(oprinnml+oprinovd+ointnmlacr+ointdue+ointovdacr+ointnmlovd) ovd,
                sum(prinovd+intovdacr+intnmlovd+feeintovdacr+feeintnmlovd) cl_ovdamt
            from lnmast
            where ftype = 'AF' group by trfacctno) lnt0,
        (select re.afacctno, MAX(cf.fullname) refullname
            from reaflnk re, sysvar sys, cfmast cf,RETYPE
            where to_date(varvalue,'DD/MM/RRRR') between re.frdate and re.todate
            and substr(re.reacctno,0,10) = cf.custid
            and varname = 'CURRDATE' and grname = 'SYSTEM'
            and re.status <> 'C' and re.deltd <> 'Y'
            AND   substr(re.reacctno,11) = RETYPE.ACTYPE
            AND  rerole IN ( 'RM','BM')
            GROUP BY AFACCTNO
        ) re
        where cf.custid = af.custid and af.acctno = sec.afacctno
        and af.actype = aft.actype and af.acctno = ci.acctno
        and cf.custatcom = 'Y'
        and aft.mrtype = mrt.actype --and mrt.mrtype = 'T'
        and af.acctno = lnt0.trfacctno(+)
        and af.acctno = re.afacctno(+)
        and ((sec.marginrate<af.mrlrate and af.mrlrate <> 0)
              or ci.ovamt>1
              or (EXISTS (select 1 from mr3008_log lg where afacctno= af.acctno
                            and txdate = (select to_date(varvalue,'DD/MM/RRRR') from sysvar where varname ='PREVDATE' and grname ='SYSTEM')
                            and log_action ='AF-END' and FTYPE ='AF'
                            and round(lg.marginrate) < lg.mrmrate
                         )
                    and sec.marginrate >= af.mrlrate and round(sec.marginrate)<af.mrmrate  and af.mrlrate <>0 and af.mrmrate <> 0
                 )
            )


        union all

        SELECT --l_OPT OPT,l_BRID BRID, l_NEXTDATE RPTDATE,
        'DF' FTYPE, custodycd,afacctno,groupid,
        fullname,rtt,lrate,DDF, TADF,0, ODSELLDF, ovd, nvl(df_ovdamt,0) MARGINOVD, refullname
        FROM ( select al1.cdcontent DEALFLAGTRIGGER,DF.GROUPID,CF.CUSTODYCD,CF.FULLNAME,AF.ACCTNO AFACCTNO,CF.ADDRESS,CF.IDCODE,DECODE(DF.LIMITCHK,'N',0,1) LIMITCHECK ,
        DF.ORGAMT -DF.RLSAMT AMT, DF.LNACCTNO , DF.STATUS DEALSTATUS ,DF.ACTYPE ,DF.RRTYPE, DF.DFTYPE, DF.CUSTBANK, DF.CIACCTNO,DF.FEEMIN,
        DF.TAX,DF.AMTMIN,DF.IRATE,DF.MRATE,DF.LRATE,DF.RLSAMT,DF.DESCRIPTION, lns.rlsdate, lns.overduedate,
        to_date (lns.overduedate,'DD/MM/RRRR') - to_date ((SELECT VARVALUE FROM SYSVAR WHERE VARNAME='CURRDATE'),'DD/MM/RRRR') duenum,
        (case when df.ciacctno is not null then df.ciacctno when df.custbank is not null then   df.custbank else '' end )
        RRID , decode (df.RRTYPE,'O',1,0) CIDRAWNDOWN,decode (df.RRTYPE,'B',1,0) BANKDRAWNDOWN,
        decode (df.RRTYPE,'C',1,0) CMPDRAWNDOWN,dftype.AUTODRAWNDOWN,df.calltype,LN.RLSAMT AMTRLS,
        LN.RATE1,LN.RATE2,LN.RATE3,LN.CFRATE1,LN.CFRATE2,LN.CFRATE3,
        A1.CDCONTENT PREPAIDDIS,A2.CDCONTENT INTPAIDMETHODDIS,A3.CDCONTENT AUTOAPPLYDIS,TADF,DDF, RTTDF RTT, ODCALLDF, ODCALLSELLIRATE - NVL(od.sellamount,0) ODSELLDF, ODCALLRTTDF, ODCALLMRATE ODCALLRTTF,
        ODCALLSELLRCB, ODCALLSELLMRATE, ODCALLSELLMRATE - NVL(od.sellamount,0) ODCALLSELLMR, ODCALLSELLRXL,
        CURAMT, CURINT, CURFEE, LNS.PAID, DF.DFBLOCKAMT, vndselldf, vndwithdrawdf, tadf - ddf*(v.irate/100) vwithdrawdf,
        LEAST(ln.MInterm, TO_NUMBER( TO_DATE(lns.OVERDUEDATE,'DD/MM/RRRR') - TO_DATE(lns.RLSDATE,'DD/MM/RRRR')) )  MInterm, ln.intpaidmethod, lnt.WARNINGDAYS,
        A4.CDCONTENT RRTYPENAME, CF.MOBILESMS FAX1, CF.EMAIL, ODDF, nvl(avladvance,0) avladvance, balance, ovamt, depofeeamt,nvl(lnt0.ovd,0) ovd, odoverduedf, re.refullname,
        nvl(ln.prinovd+ln.intovdacr+ln.intnmlovd+ln.feeintovdacr+ln.feeintnmlovd,0) df_ovdamt
        from dfgroup df, dftype, lnmast ln, lntype lnt ,lnschd lns, afmast af, cimast ci , cfmast cf, allcode al1,
           ALLCODE A1, ALLCODE A2, ALLCODE A3, v_getgrpdealformular v , allcode A4, v_getdealsellamt od,
           (select sum(aamt) aamt,sum(depoamt) avladvance,sum(paidamt) paidamt, sum(advamt) advanceamount,afacctno from v_getAccountAvlAdvance_all group by afacctno) adv,
        (select trfacctno,
                sum(decode(ftype,'AF',1,0)*(oprinnml+oprinovd+ointnmlacr+ointdue+ointovdacr+ointnmlovd)) ovd
            from lnmast
            group by trfacctno) lnt0,
        (select re.afacctno, MAX(cf.fullname) refullname
            from reaflnk re, sysvar sys, cfmast cf,RETYPE
            where to_date(varvalue,'DD/MM/RRRR') between re.frdate and re.todate
            and substr(re.reacctno,0,10) = cf.custid
            and varname = 'CURRDATE' and grname = 'SYSTEM'
            and re.status <> 'C' and re.deltd <> 'Y'
            AND   substr(re.reacctno,11) = RETYPE.ACTYPE
            AND  rerole IN ( 'RM','BM')
            GROUP BY AFACCTNO
        ) re
        where df.lnacctno= ln.acctno and ln.acctno=lns.acctno and ln.actype=lnt.actype and lns.reftype='P' and df.afacctno= af.acctno and af.custid= cf.custid and df.actype=dftype.actype
        and A1.cdname = 'YESNO' and A1.cdtype ='SY' AND A1.CDVAL = LN.PREPAID
        and A2.cdname = 'INTPAIDMETHOD' and A2.cdtype ='LN' AND A2.CDVAL = LN.INTPAIDMETHOD
        and A3.cdname = 'AUTOAPPLY' and a3.cdtype ='LN' AND A3.CDVAL = LN.AUTOAPPLY
        and A4.cdname = 'RRTYPE' and A4.cdtype ='DF' AND A4.CDVAL = DF.RRTYPE
        and df.flagtrigger=al1.cdval and al1.cdname='FLAGTRIGGER' and df.groupid=v.groupid(+)
        and df.groupid=od.groupid(+) and df.afacctno=od.afacctno(+)
        and af.acctno = ci.acctno and af.acctno = adv.afacctno(+)
        and af.acctno = lnt0.trfacctno(+)
        and af.acctno = re.afacctno(+)

        ) MST WHERE ((ODDF>0 AND (RTT < LRATE or odoverduedf>0))
                or df_ovdamt > 0
                or (EXISTS (select 1 from mr3008_log lg
                            where afacctno= MST.afacctno and txdate = (select to_date(varvalue,'DD/MM/RRRR') from sysvar where varname ='PREVDATE' and grname ='SYSTEM')
                           and log_action ='AF-END' and FTYPE ='DF'
                           and round(lg.marginrate) < lg.mrmrate)
                and RTT >= LRATE and round(RTT) < MRATE  and LRATE <>0 and MRATE <> 0
                )
            )
        ) a order by custodycd, dfgroupid;
    plog.setendsection(pkgctx, 'pr_log_mr3009');
    EXCEPTION
  WHEN OTHERS
   THEN
      plog.debug (pkgctx,'got error on pr_log_mr3009');
      ROLLBACK;
      plog.error (pkgctx, SQLERRM || dbms_utility.format_error_backtrace);
      plog.setendsection (pkgctx, 'pr_log_mr3009');
      RAISE errnums.E_SYSTEM_ERROR;
end;


procedure pr_log_MARGINRATE_LOG(pv_Action varchar2)
is
    v_curdate DATE;
begin
    plog.setbeginsection(pkgctx, 'pr_log_MARGINRATE_LOG');
    v_curdate:=GETCURRDATE;

    insert into MARGINRATE_LOG
    (TXDATE, AFACCTNO, MARGINRATE, MRIRATE,
     MRCRATE, MRWRATE, MRMRATE, MRLRATE,TIMES, TYPE)
     SELECT
     v_curdate, AFACCTNO, MARGINRATE, MRIRATE,
     MRCRATE, MRWRATE, MRMRATE, MRLRATE,SYSTIMESTAMP,PV_ACTION
     FROM V_GETSECMARGINRATIO;

    plog.setendsection(pkgctx, 'pr_log_MARGINRATE_LOG');
    EXCEPTION
WHEN OTHERS
   THEN
      plog.debug (pkgctx,'got error on pr_log_MARGINRATE_LOG');
      ROLLBACK;
      plog.error (pkgctx, SQLERRM || dbms_utility.format_error_backtrace);
      plog.setendsection (pkgctx, 'pr_log_MARGINRATE_LOG');
      RAISE errnums.E_SYSTEM_ERROR;
end;


procedure pr_log_MR0058(pv_Action varchar2)
is
    v_curdate DATE;
begin
    plog.setbeginsection(pkgctx, 'pr_log_MR0058');
    v_curdate:=GETCURRDATE;

    insert into TBL_MR0058
    (INDATE,BRID,AUTOID,ACCTNO,CUSTID,FULLNAME,BRNAME,CUSTODYCD,TRFACCTNO,RLSDATE,
     OVERDUEDATE,NML,PAID,TOTAL_AMT,LAI_DUKIEN,ADDRESS,MOBILE,CHI_PHI_KHAC,MG_CHINH,MG_PHU,TYPE)


       SELECT  to_date(v_curdate,'dd/mm/rrrr') INDATE, cf.brid, LNS.AUTOID,lnm.acctno,CF.CUSTID, cf.fullname, br.brname,
            cf.custodycd, lnm.trfacctno,LNS.RLSDATE,lns.overduedate,round(LNS.NML+LNS.OVD) NML,
            round(LNS.PAID+LNS.INTPAID+LNS.FEEPAID+LNS.FEEPAID2+LNS.FEEINTPAID+LNS.FEEINTPREPAID+LNS.PAIDFEEINT) PAID ,
            MR.AMT TOTAL_AMT,round(LNS.INTNMLACR+LNS.INTOVD+LNS.INTOVDPRIN+LNS.FEEINTNMLACR+LNS.FEEDUE+LNS.INTDUE +LNS.FEEOVD+LNS.FEEINTOVDACR
            +LNS.FEEINTNMLOVD+LNS.FEEINTDUE+LNS.OVDFEEINT+LNS.FEEINTNML+LNS.FEEINTOVD) LAI_DUKIEN,
            CF.ADDRESS,NVL(CF.MOBILESMS,'') MOBILE,0 CHI_PHI_KHAC,'' mg_chinh,''mg_phu,PV_ACTION
        FROM lnmast  lnm, cfmast cf,  afmast af, brgrp br, lnschd lns,
            (

                SELECT BUF.CUSTODYCD,  sum(CASE WHEN  AF.AUTOADV='N' then NVL(BUF.BALDEFOVD,0) + NVL(BUF.avladvance,0)
                       ELSE NVL(BUF.BALDEFOVD,0) END) AMT
                FROM AFMAST AF,AFTYPE AFT, MRTYPE MR, buf_ci_account buf
                WHERE  AF.ACTYPE=AFT.ACTYPE
                    AND AFT.MRTYPE=MR.ACTYPE
                    AND MR.MRTYPE='N'
                    AND AF.ACCTNO=BUF.AFACCTNO
                 GROUP BY BUF.CUSTODYCD
            ) MR
        WHERE  af.custid=cf.custid
            AND LNM.ACCTNO=LNS.ACCTNO
            AND af.acctno =lnm.trfacctno
            AND br.brid=cf.brid
            and lnm.rlsamt >0
            AND LNM.FTYPE='AF'
            and lns.RLSDATE is not null
            AND LNM.STATUS<>'Y'
            AND CF.CUSTODYCD=MR.CUSTODYCD(+)
            AND LNS.OVERDUEDATE <= to_date(v_curdate,'dd/mm/rrrr')
            and round(LNS.NML+LNS.OVD)+
            round(LNS.INTNMLACR+LNS.INTOVD+LNS.INTOVDPRIN+LNS.FEEINTNMLACR+LNS.FEEDUE+LNS.INTDUE +LNS.FEEOVD+LNS.FEEINTOVDACR
            +LNS.FEEINTNMLOVD+LNS.FEEINTDUE+LNS.OVDFEEINT+LNS.FEEINTNML+LNS.FEEINTOVD) > 0;


    plog.setendsection(pkgctx, 'pr_log_MR0058');
    EXCEPTION
WHEN OTHERS
   THEN
      plog.debug (pkgctx,'got error on pr_log_MR0058');
      ROLLBACK;
      plog.error (pkgctx, SQLERRM || dbms_utility.format_error_backtrace);
      plog.setendsection (pkgctx, 'pr_log_MR0058');
      RAISE errnums.E_SYSTEM_ERROR;
end;

procedure pr_log_MR0060(pv_Action varchar2)
is
    v_curdate DATE;
begin
    plog.setbeginsection(pkgctx, 'pr_log_MR0060');
    v_curdate:=GETCURRDATE;

    insert into TBL_MR0060
    (NGAY_IN,BRID,ACCTNO,FULLNAME,BRNAME,CUSTODYCD,TRFACCTNO,RLSDATE,
     OVERDUEDATE,GIAI_NGAN,PHAI_TRA,PAID,LAI_DUKIEN,GTGT,TYPE)

     SELECT to_date(v_curdate,'DD/MM/RRRR') NGAY_IN, cf.brid, LNS.AUTOID ACCTNO, cf.fullname, nvl(tp.tradename, br.brname), cf.custodycd,
             lnm.trfacctno,LNS.RLSDATE,lns.overduedate,ROUND(LNS.NML+LNS.OVD+LNS.PAID) GIAI_NGAN,
              ROUND(LNS.NML+LNS.OVD) PHAI_TRA,ROUND(LNS.PAID) PAID,GREATEST(ROUND(LNS.INTNMLACR+LNS.INTOVD
              +LNS.INTOVDPRIN+LNS.FEEINTNMLACR+LNS.FEEDUE+LNS.INTDUE+LNS.FEEOVD+LNS.FEEINTOVDACR+LNS.FEEINTNMLOVD
              +LNS.FEEINTDUE+LNS.OVDFEEINT+LNS.FEEINTNML+LNS.FEEINTOVD),0)/*-NVL(GL.AMT,0)*/ LAI_DUKIEN,0 GTGT,PV_ACTION
     FROM LNMAST  lnm, cfmast cf,  afmast af, brgrp br, LNSCHD lns, tradeplace tp, tradecareby tc/*,(SELECT SUM (amount) AMT,  AFACCTNO
                                                                     FROM gljournal WHERE TLTXCD ='5580' AND txdate = v_curdate
                                                                     GROUP BY AFACCTNO)GL*/
     WHERE  af.custid=cf.custid
                        AND LNM.ACCTNO=LNS.ACCTNO
                        AND af.acctno =lnm.trfacctno
                        AND cf.careby = tc.grpid(+)
                        AND tc.tradeid = tp.traid(+)
                     --   AND LNM.trfacctno= GL.AFACCTNO(+)
                        AND br.brid=cf.brid
                        and lnm.rlsamt >0
                        AND LNM.STATUS<>'Y'
                        AND LNM.FTYPE='AF'
                        AND LNS.RLSDATE IS NOT NULL;


    plog.setendsection(pkgctx, 'pr_log_MR0060');
    EXCEPTION
WHEN OTHERS
   THEN
      plog.debug (pkgctx,'got error on pr_log_MR0060');
      ROLLBACK;
      plog.error (pkgctx, SQLERRM || dbms_utility.format_error_backtrace);
      plog.setendsection (pkgctx, 'pr_log_MR0060');
      RAISE errnums.E_SYSTEM_ERROR;
end;


procedure pr_log_MR0063(pv_Action varchar2)
is
    v_curdate DATE;
begin
    plog.setbeginsection(pkgctx, 'pr_log_MR0063');
    v_curdate:=GETCURRDATE;

    insert into TBL_MR0063
    (INDATE,BRID,BRNAME,CUSTID,FULLNAME,CUSTODYCD,ACCTNO,MARGINRATE,MRIRATE,MRMRATE,
    MRLRATE,MRCRATE,MRWRATE,FIRST_CALLDATE,ADD_TO_MRCRATE,SE_TO_MRCRATE,SE_TO_MRCRATEUB,
    SELLTYPE,STATUS,AMT,TOTAL_AMT,MG_CHINH,MG_PHU,TYPE)

   SELECT MAIN.*,NVL(LAI.AMT,0)  TOTAL_AMT,'' MG_CHINH, '' MG_PHU,PV_ACTION

      FROM(SELECT to_date(v_curdate,'dd/mm/rrrr') INDATE, cf.brid, BR.BRNAME,CF.CUSTID, CF.FULLNAME,CF.CUSTODYCD,AF.ACCTNO,NVL(CI.MARGINRATE,0) MARGINRATE,
               AF.MRIRATE, AF.MRMRATE,AF.MRLRATE,AF.MRCRATE,AF.MRWRATE,fn_get_prevdate(to_date(v_curdate,'dd/mm/rrrr'),AF.CALLDAY) FIRST_CALLDATE,
               case when aft.mnemonic<>'T3' then
               round((case when nvl(ci.marginrate,0) * af.mrmrate =0 then - nvl(ci.se_outstanding,0) else greatest( 0,- nvl(ci.se_outstanding,0) - nvl(ci.se_navaccount,0) *100/AF.MRCRATE) end),0)
               else 0 end ADD_TO_MRCRATE,
               GREATEST(af.MRCRATE/100 * round(-ci.se_outstanding) - ci.seass,0) SE_TO_MRCRATE,
                GREATEST(round((-af.mrcrate/100 * ci.se_outstanding - ci.seass) / (af.MRCRATE/100 - 0.5),4),0) SE_TO_MRCRATEUB,
                (CASE WHEN AF.Callday>=AF.K2DAYS THEN UTF8NUMS.C_CONST_SELLTYPE_MR0063_BH ELSE UTF8NUMS.C_CONST_SELLTYPE_MR0063_BD
                END) SELLTYPE,
               (CASE WHEN (
               (aft.mnemonic <>'T3' and
                         ((CI.marginrate<af.mrlrate and af.mrlrate <> 0)
                         OR (CI.marginrate<AF.MRCRATE AND (AF.CALLDAY >=AF.K1DAYS  ))))
                         or (CIM.OVAMT-GREATEST(0,CIM.BALANCE+NVL(CI.AVLADVANCE,0)- CIM.BUYSECAMT))>1 ) AND AF.Callday>=AF.K2DAYS THEN  UTF8NUMS.C_CONST_SELLTYPE_MR0063_CTYBH
               WHEN ((aft.mnemonic <>'T3' and ((CI.marginrate<af.mrlrate and af.mrlrate <> 0)
               OR (CI.marginrate<AF.MRCRATE AND (AF.CALLDAY >=AF.K1DAYS  ))))
               or (CIM.OVAMT-GREATEST(0,CIM.BALANCE+NVL(CI.AVLADVANCE,0)- CIM.BUYSECAMT))>1 ) AND AF.Callday<AF.K2DAYS THEN UTF8NUMS.C_CONST_SELLTYPE_MR0063_CTYBD
               ELSE UTF8NUMS.C_CONST_SELLTYPE_MR0063_KHBD
               END ) STATUS, NVL(MR.AMT,0) AMT
        FROM CFMAST CF, AFMAST AF, BRGRP BR, BUF_CI_ACCOUNT CI,AFTYPE AFT, CIMAST CIM,
              ( SELECT CF.CUSTODYCD,
                       sum(CASE WHEN  AF.AUTOADV='N' then
                        greatest(nvl(adv.depoamt,0) + balance - ci.buysecamt - CI.ovamt - CI.dueamt - ci.dfdebtamt - ci.dfintdebtamt - NVL (overamt, 0)
                        - nvl(secureamt,0)+ LEAST(AF.Mrcrlimit,nvl(B.secureamt,0)+ci.trfbuyamt)  - ci.trfbuyamt- CI.ramt-nvl(pd.dealpaidamt,0)
                        - CI.DEPOFEEAMT-CEIL(CI.CIDEPOFEEACR),0) + NVL(ADV.advamt,0)
                        else
                         greatest(nvl(adv.depoamt,0) + balance - ci.buysecamt - CI.ovamt - CI.dueamt - ci.dfdebtamt - ci.dfintdebtamt - NVL (overamt, 0)
                          - nvl(secureamt,0)+ LEAST(AF.Mrcrlimit,nvl(B.secureamt,0)+ci.trfbuyamt)  - ci.trfbuyamt- CI.ramt-nvl(pd.dealpaidamt,0)
                          - CI.DEPOFEEAMT-CEIL(CI.CIDEPOFEEACR),0) end) AMT
                FROM CIMAST CI, CFMAST CF, AFMAST AF, v_getAccountAvlAdvance ADV, AFTYPE AFT, MRTYPE MR,v_getdealpaidbyaccount pd,v_getbuyorderinfo B
                WHERE CF.CUSTID=AF.CUSTID
                AND AF.ACCTNO=CI.ACCTNO
                    AND AF.ACTYPE=AFT.ACTYPE
                    AND AFT.MRTYPE=MR.ACTYPE
                    AND MR.MRTYPE='N'
                    AND AF.ACCTNO=ADV.AFACCTNO(+)
                    and CI.ACCTNO=pd.afacctno(+)
                    AND CI.ACCTNO=B.AFACCTNO(+)
                GROUP BY CUSTODYCD , AF.AUTOADV
                 ) MR
        WHERE AF.CUSTID=CF.CUSTID
              AND CF.BRID=BR.BRID(+)
              AND CI.AFACCTNO=AF.ACCTNO
              AND AF.ACCTNO=CIM.ACCTNO(+)
              AND AF.ACTYPE=AFT.ACTYPE
              AND AF.ACTYPE<>'0000'
              AND CF.CUSTODYCD=MR.CUSTODYCD(+)
            --  AND CI.MARGINRATE < AF.MRMRATE
            --  AND (CIM.ODAMT-GREATEST(0,CIM.BALANCE+NVL(CI.AVLADVANCE,0)- CIM.BUYSECAMT))>1
             and ( (aft.mnemonic <>'T3' and
                  ((ci.marginrate<af.mrlrate and af.mrlrate <> 0)
                  OR (ci.marginrate<AF.MRCRATE AND (AF.CALLDAY >= 1/*AF.K1DAYS */ ))
                  OR  (ci.marginrate<AF.MRMRATE )
                  )
                  )
  --   or (CIM.ODAMT-GREATEST(0,CIM.BALANCE+NVL(CI.AVLADVANCE,0)- CIM.BUYSECAMT))>1
                )

            ) MAIN
        LEFT JOIN
            (SELECT AF.ACCTNO, GREATEST(round(sum(LNS.PAID)+sum(LNS.INTPAID)+sum(LNS.FEEPAID)+sum(LNS.FEEPAID2)+
            sum(LNS.FEEINTPAID)+sum(LNS.FEEINTPREPAID)+sum(LNS.PAIDFEEINT)),0) AMT
            FROM VW_LNMAST_ALL LN, VW_LNSCHD_ALL LNS,AFMAST AF
            WHERE AF.ACCTNO=LN.TRFACCTNO
            AND LN.ACCTNO=LNS.ACCTNO AND LN.FTYPE='AF'
            AND LNS.RLSDATE IS NOT NULL
            and ln.rlsamt >0
            GROUP BY AF.ACCTNO) LAI ON MAIN.ACCTNO=LAI.ACCTNO;


    plog.setendsection(pkgctx, 'pr_log_MR0063');
    EXCEPTION
WHEN OTHERS
   THEN
      plog.debug (pkgctx,'got error on pr_log_MR0063');
      ROLLBACK;
      plog.error (pkgctx, SQLERRM || dbms_utility.format_error_backtrace);
      plog.setendsection (pkgctx, 'pr_log_MR0063');
      RAISE errnums.E_SYSTEM_ERROR;
end;

procedure pr_log_MR0059(pv_Action varchar2)
is
    v_curdate DATE;
begin
    plog.setbeginsection(pkgctx, 'pr_log_MR0059');
    v_curdate:=GETCURRDATE;

    insert into TBL_MR0059
    (INDATE,BRID,BRNAME,CUSTID,FULLNAME,CUSTODYCD,ACCTNO,MARGINRATE,MRIRATE, MRMRATE,MRLRATE,MRCRATE,MRWRATE,
    ADD_TO_MRIRATE,SE_TO_MRIRATE,SE_TO_MRIRATEUB,MG_CHINH,MG_PHU,TYPE )

 SELECT to_date(v_curdate,'dd/mm/rrrr') INDATE,CF.BRID,BR.BRNAME,CF.CUSTID, CF.FULLNAME,CF.CUSTODYCD,AF.ACCTNO,NVL(CI.MARGINRATE,0) MARGINRATE,
       AF.MRIRATE, AF.MRMRATE,AF.MRLRATE,AF.MRCRATE,AF.MRWRATE,
       (case when aft.mnemonic<>'T3' then
       round((case when nvl(ci.marginrate,0) * af.mrmrate =0 then - nvl(ci.se_outstanding,0) else greatest( 0,- nvl(ci.se_outstanding,0) - nvl(ci.se_navaccount,0) *100/AF.MRIRATE) end),0)
       else 0  end) ADD_TO_MRIRATE, --So tien can bo sung ve Rat
      GREATEST(af.mrirate/100 * round(-ci.se_outstanding) - ci.seass,0) SE_TO_MRIRATE, -- se can bo sung dat Rat
        GREATEST(round((-af.mrirate/100 * ci.se_outstanding - ci.seass) / (af.mrirate/100 - 0.5),4),0) SE_TO_MRIRATEUB,
        '' MG_CHINH, '' MG_PHU, PV_ACTION

FROM CFMAST CF, AFMAST AF, BRGRP BR, BUF_CI_ACCOUNT CI,AFTYPE AFT
WHERE AF.CUSTID=CF.CUSTID
      AND CF.BRID=BR.BRID(+)
      AND CI.AFACCTNO=AF.ACCTNO
      AND AF.ACTYPE=AFT.ACTYPE
      /* AND AF.ACTYPE<>'0000'
      AND CI.MARGINRATE<= AF.MRWRATE
      AND CI.MARGINRATE>=AF.MRMRATE*/
       AND  (
              (AFT.MNEMONIC <>'T3') and
                  ((ci.marginrate<AF.MRwRATE and ci.marginrate>=AF.MRCRATE)-- chi pham ti le canh bao
                  OR (ci.MARGINRATE<AF.MRCRATE AND ci.MARGINRATE>=AF.MRMRATE AND AF.Callday=0)))
       ;


    plog.setendsection(pkgctx, 'pr_log_MR0059');
    EXCEPTION
WHEN OTHERS
   THEN
      plog.debug (pkgctx,'got error on pr_log_MR0059');
      ROLLBACK;
      plog.error (pkgctx, SQLERRM || dbms_utility.format_error_backtrace);
      plog.setendsection (pkgctx, 'pr_log_MR0059');
      RAISE errnums.E_SYSTEM_ERROR;
end;


procedure pr_log_MR0057(pv_Action varchar2)
is
    v_curdate DATE;
begin
    plog.setbeginsection(pkgctx, 'pr_log_MR0057');
    v_curdate:=GETCURRDATE;

    insert into TBL_MR0057
    (INDATE,AUTOID,ACCTNO,CUSTID,FULLNAME,BRID,BRNAME,CUSTODYCD,TRFACCTNO,RLSDATE,
    OVERDUEDATE,NML,LAI_DUKIEN,ADDRESS,MOBILE,CHI_PHI_KHAC,MG_CHINH,MG_PHU,TYPE)


     SELECT fn_get_prevdate(to_date(v_curdate,'dd/mm/rrrr'),1) INDATE,LNS.AUTOID,lnm.acctno,cf.custid, cf.fullname,cf.brid, br.brname, cf.custodycd, lnm.trfacctno,LNS.RLSDATE,lns.overduedate,LNS.NML,
     (CASE WHEN LNS.ACRDATE<LNS.DUEDATE THEN
     --TY LE RATE1
     (  sum(lnS.INTNMLACR + ROUND((lnS.NML * lnS.RATE1 / 100 * TO_NUMBER(LNS.DUEDATE -lnS.acrdate)+lnS.NML * lnS.RATE2 / 100 * TO_NUMBER(LNS.OVERDUEDATE  -lnS.DUEDATE))
                            /(Case When LNM.DRATE= 'D1' then  30
                                       When LNM.DRATE= 'D2' then  TO_NUMBER(TO_CHAR(LAST_DAY(TO_DATE(LNS.OVERDUEDATE + 1,'dd/mm/rrrr')),'dd'))
                                       When LNM.DRATE= 'Y1' then  360
                                       When LNM.DRATE= 'Y2' then
                                               TO_DATE(CONCAT('31/12/',SUBSTR(LNS.OVERDUEDATE + 1,7)),'dd/mm/rrrr') - TO_DATE(CONCAT('01/01/',SUBSTR(LNS.OVERDUEDATE + 1,7)),'dd/mm/rrrr') + 1
                                       When LNM.DRATE= 'Y3' then  365
                                   End
                                   )
                           ,4))+
       sum(lnS.FEEINTNMLACR + ROUND((lnS.NML * lnS.CFRATE1 / 100 * TO_NUMBER(LNS.DUEDATE -lnS.acrdate)+lnS.NML * lnS.CFRATE2 / 100 * TO_NUMBER(LNS.OVERDUEDATE  -lnS.DUEDATE))
                / (Case When LNM.DRATE= 'D1' then  30
                                       When LNM.DRATE= 'D2' then  TO_NUMBER(TO_CHAR(LAST_DAY(TO_DATE(LNS.OVERDUEDATE + 1,'dd/mm/rrrr')),'dd'))
                                       When LNM.DRATE= 'Y1' then  360
                                       When LNM.DRATE= 'Y2' then
                                               TO_DATE(CONCAT('31/12/',SUBSTR(LNS.OVERDUEDATE + 1,7)),'dd/mm/rrrr') - TO_DATE(CONCAT('01/01/',SUBSTR(LNS.OVERDUEDATE + 1,7)),'dd/mm/rrrr') + 1
                                       When LNM.DRATE= 'Y3' then  365
                                   End
                                   )
          ,4)))
 --TY LE RATE2
 ELSE ( sum(lnS.INTNMLACR + ROUND(lnS.NML * lnS.RATE2 / 100 * TO_NUMBER(LNS.OVERDUEDATE  -lnS.acrdate)
                            /(Case When LNM.DRATE= 'D1' then  30
                                       When LNM.DRATE= 'D2' then  TO_NUMBER(TO_CHAR(LAST_DAY(TO_DATE(LNS.OVERDUEDATE + 1,'dd/mm/rrrr')),'dd'))
                                       When LNM.DRATE= 'Y1' then  360
                                       When LNM.DRATE= 'Y2' then
                                               TO_DATE(CONCAT('31/12/',SUBSTR(LNS.OVERDUEDATE + 1,7)),'dd/mm/rrrr') - TO_DATE(CONCAT('01/01/',SUBSTR(LNS.OVERDUEDATE + 1,7)),'dd/mm/rrrr') + 1
                                       When LNM.DRATE= 'Y3' then  365
                                   End
                                   )
                           ,4))+
       sum( lnS.FEEINTNMLACR + ROUND(lnS.NML * lnS.CFRATE2 / 100 * TO_NUMBER(LNS.OVERDUEDATE  -lnS.acrdate)
                / (Case When LNM.DRATE= 'D1' then  30
                                       When LNM.DRATE= 'D2' then  TO_NUMBER(TO_CHAR(LAST_DAY(TO_DATE(LNS.OVERDUEDATE + 1,'dd/mm/rrrr')),'dd'))
                                       When LNM.DRATE= 'Y1' then  360
                                       When LNM.DRATE= 'Y2' then
                                               TO_DATE(CONCAT('31/12/',SUBSTR(LNS.OVERDUEDATE + 1,7)),'dd/mm/rrrr') - TO_DATE(CONCAT('01/01/',SUBSTR(LNS.OVERDUEDATE + 1,7)),'dd/mm/rrrr') + 1
                                       When LNM.DRATE= 'Y3' then  365
                                   End
                                   ) ,4))) END)  LAI_DUKIEN,
        CF.ADDRESS,NVL(CF.MOBILESMS,'') MOBILE,0 CHI_PHI_KHAC,'' mg_chinh,'' mg_phu,PV_ACTION
   FROM lnmast  lnm, cfmast cf,  afmast af, brgrp br, lnschd lns, LNTYPE LNT
   WHERE  af.custid=cf.custid
        AND LNM.ACCTNO=LNS.ACCTNO
        AND af.acctno =lnm.trfacctno
        AND br.brid=cf.brid
        and lnm.rlsamt >0
        AND LNM.STATUS<>'Y'
        AND LNS.NML >0
        AND LNM.FTYPE='AF'
        and lns.RLSDATE is not null
         AND LNT.ACTYPE=LNM.ACTYPE
       -- AND fn_get_prevdate(LNS.OVERDUEDATE,LNT.WARNINGDAYS) <=to_date(v_curdate,'dd/mm/rrrr')
       AND fn_get_prevdate(LNS.OVERDUEDATE,LNT.WARNINGDAYS) = fn_get_prevdate(to_date(v_curdate,'dd/mm/rrrr'),1)
         AND LNS.OVERDUEDATE >to_date(v_curdate,'dd/mm/rrrr')
        GROUP BY LNS.AUTOID,lnm.acctno,cf.custid, cf.fullname, br.brname, cf.brid,cf.custodycd, lnm.trfacctno,LNS.RLSDATE,lns.overduedate,
      LNS.NML,CF.ADDRESS,NVL(CF.MOBILESMS,''),LNS.ACRDATE,LNS.DUEDATE
         ;



    plog.setendsection(pkgctx, 'pr_log_MR0057');
    EXCEPTION
WHEN OTHERS
   THEN
      plog.debug (pkgctx,'got error on pr_log_MR0057');
      ROLLBACK;
      plog.error (pkgctx, SQLERRM || dbms_utility.format_error_backtrace);
      plog.setendsection (pkgctx, 'pr_log_MR0057');
      RAISE errnums.E_SYSTEM_ERROR;
end;

procedure pr_log_vmr0001(pv_Action varchar2)
is
    v_curdate DATE;
    v_predate   DATE;
begin
    plog.setbeginsection(pkgctx, 'pr_log_vmr0001');
    v_curdate:=GETCURRDATE;
     v_predate:=to_date(cspks_system.fn_get_sysvar('SYSTEM','PREVDATE'), systemnums.c_date_format);

    insert into TBL_VMR0001
    (INDATE,BRID,CUSTID, fullname,custodycd,acctno, marginrate,marginamt,t0amt,marginovdamt,
     margininamt , t0ovdamt,totalvnd,careby, seass, MRCRLIMIT,AVLLIMIT_MG,AVLLIMIT,TYPE)

    select v_predate INDATE,CF.BRID,CF.CUSTID, cf.fullname,cf.custodycd,af.acctno,nvl(sec.marginrate,0) marginrate,
       ROUND(nvl(ln.marginamt,0)) marginamt, ROUND(nvl(ln.t0amt,0)) t0amt,
          ROUND(nvl(ln.marginovdamt,0)) marginovdamt,ROUND(nvl(ln.margininamt,0)) margininamt , ROUND(nvl(ln.t0ovdamt,0)) t0ovdamt,
          ROUND(ci.balance + nvl(avladvance,0)) totalvnd,  af.careby,nvl(sec.seass,0) seass,
          AF.mrcrlimitmax MRCRLIMIT, --HAN MUC BAN DAU
          NVL(AF.MRCRLIMITMAX - NVL(CI.DFODAMT,0) - NVL(LN.NML,0) -fn_get_margin_execbuyamt_sec( AF.ACCTNO),0) AVLLIMIT_MG,--HAN MUC CON LAI THEO 111108
          SEC.AVLLIMIT, --HAN MUC CON LAI TRONG BUF_CI
          PV_ACTION

   from cfmast cf, afmast af, cimast ci, aftype aft, mrtype mrt,
         (select afacctno, marginrate,se_outstanding outstanding,se_navaccount navaccount,seass, seamt,avladvance,AVLLIMIT from buf_ci_account ) sec

         ,(select trfacctno, trunc(sum(round(prinnml)+round(prinovd)+round(intnmlacr)+round(intdue)+round(intovdacr)+round(intnmlovd)+round(feeintnmlacr)
                                    +round(feeintdue)+round(feeintovdacr)+round(feeintnmlovd)),0) marginamt,
                     trunc(sum(round(oprinnml)+round(oprinovd)+round(ointnmlacr)+round(ointdue)+round(ointovdacr)+round(ointnmlovd)),0) t0amt,
                     trunc(sum(round(prinovd)+round(intovdacr)+round(intnmlovd)+round(feeintovdacr)+round(feeintnmlovd) ),0) marginovdamt,
                     trunc(sum(round(nvl(ls.dueamt,0))),0) margininamt,
                     trunc(sum(round(oprinovd)+round(ointovdacr)+round(ointnmlovd)),0) t0ovdamt,ROUND(SUM(LN.PRINNML+LN.PRINOVD)) NML
            from lnmast ln, lntype lnt,
                    (select acctno, sum(nml+intdue+feeintdue) dueamt
                            from lnschd
                            where reftype = 'P' and overduedate = to_date(v_curdate,'DD/MM/RRRR')
                            group by acctno) ls
            where ftype = 'AF'
                    and ln.actype = lnt.actype
                    and ln.acctno = ls.acctno(+)
            group by ln.trfacctno) ln
where cf.custid = af.custid and aft.mrtype = mrt.actype and mrt.mrtype in ('T','S')
      and cf.custatcom = 'Y'
      and af.actype = aft.actype
      and af.acctno = ci.acctno
      and af.acctno = sec.afacctno
      and af.acctno = ln.trfacctno(+)
      AND cf.status <> 'C'
      AND af.status <> 'C';


    plog.setendsection(pkgctx, 'pr_log_vmr0001');
    EXCEPTION
WHEN OTHERS
   THEN
      plog.debug (pkgctx,'got error on pr_log_vmr0001');
      ROLLBACK;
      plog.error (pkgctx, SQLERRM || dbms_utility.format_error_backtrace);
      plog.setendsection (pkgctx, 'pr_log_vmr0001');
      RAISE errnums.E_SYSTEM_ERROR;
end;


BEGIN
   SELECT *
   INTO logrow
   FROM tlogdebug
   WHERE ROWNUM <= 1;

   pkgctx    :=
      plog.init ('cspks_logproc',
                 plevel => logrow.loglevel,
                 plogtable => (logrow.log4table = 'Y'),
                 palert => (logrow.log4alert = 'Y'),
                 ptrace => (logrow.log4trace = 'Y')
      );
END;
/
