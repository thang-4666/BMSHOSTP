SET DEFINE OFF;
CREATE OR REPLACE PACKAGE cspks_dfproc
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

FUNCTION fn_OpenDealAccount(p_txmsg in tx.msg_rectype,p_err_code out varchar2)
RETURN NUMBER;
PROCEDURE pr_ADVDFPayment(p_txmsg in tx.msg_rectype,p_stschdid varchar2, p_amt number,p_err_code  OUT varchar2);
PROCEDURE pr_CADealReceive(p_refDealID varchar,p_qtty number, p_err_code  OUT varchar2);
PROCEDURE pr_DealReceive(p_orderid varchar2,p_qtty number,p_err_code  OUT varchar2);
PROCEDURE pr_DealAutoPayment(p_txmsg in tx.msg_rectype,p_dealID varchar2,p_autoid varchar2, p_qtty number, p_serls number,p_amt out number,p_err_code  OUT varchar2);
FUNCTION fn_OpenDealGrpAccount(p_txmsg in tx.msg_rectype,p_err_code out varchar2) RETURN NUMBER;
PROCEDURE pr_Opentdfgroup( p_groupid in varchar2,p_err_code out varchar2);
PROCEDURE pr_Drawndowndfgorup(groupid in varchar2 ,p_err_code  OUT varchar2);
PROCEDURE pr_AddCIToReleaseSecu(p_txmsg in tx.msg_rectype,p_err_code  OUT varchar2);
PROCEDURE pr_AddSEToGRDeal(p_txmsg in tx.msg_rectype,p_err_code  OUT varchar2);
PROCEDURE pr_Createdfgrplog(p_txmsg in tx.msg_rectype,p_err_code in out varchar2);
PROCEDURE pr_TransSEToOtherGrpDeal(p_txmsg in tx.msg_rectype ,p_err_code  OUT varchar2);
PROCEDURE pr_DFPaidDeal(p_txmsg in tx.msg_rectype, l_GROUPID varchar,l_amtpaid number, l_intpaid number, l_feepaid number, l_intpena number, l_feepena number, p_err_code  OUT varchar2);
END;
 
/


CREATE OR REPLACE PACKAGE BODY cspks_dfproc
IS
   -- declare log context
   pkgctx   plog.log_ctx;
   logrow   tlogdebug%ROWTYPE;



  PROCEDURE pr_Createdfgrplog(p_txmsg in tx.msg_rectype ,p_err_code in OUT varchar2)
  IS
    V_STRXML  varchar2(30000);
    l_ACTYPE varchar2(10);
    l_DFTYPE varchar2(20);
    l_ORGAMT NUMBER;
    l_TXTIME varchar2(20);
    l_TXDATE varchar2(20);
    l_TXNUM  varchar2(20);
    l_MAKER varchar2(4);
    l_IRATE NUMBER;
    l_MRATE NUMBER;
    l_LRATE NUMBER;
    l_AUTODRAWNDOWN NUMBER;
    l_ISAPPROVE varchar2(1);
    l_DESCRIPTION varchar2(500);
    l_AFACCTNO varchar2(10);
    l_DTYPE varchar2(4);
    l_SYMBOL varchar2(20);
    l_CODEID varchar2(6);
    l_QTTY number;
    l_DFPRICE number;
    l_AMT number;
    l_GROUPID varchar2(20);
    l_LIMITCHK varchar2(20);
    L_DFRATE NUMBER;
    l_CUSTBANK varchar2(20);
    l_RRTYPE varchar2(20);
    l_CIACCTNO varchar2(20);
    l_TAX number;
    l_FEEMIN number;
    l_FEE number;
    l_LNTYPE varchar2(20);
    l_AUTOPAID varchar2(20);
    L_countgrpid  NUMBER;
    l_AFACCTNODRD  varchar2(20);
    l_ref varchar2(500);
    l_txmsg               tx.msg_rectype;
    v_strCURRDATE varchar2(20);
    v_strPREVDATE varchar2(20);
    v_strNEXTDATE varchar2(20);
    v_strDesc varchar2(1000);
    v_strEN_Desc varchar2(1000);
    v_blnVietnamese BOOLEAN;
    l_err_param varchar2(300);
    l_MaxRow NUMBER(20,0);
    N NUMBER ;


  BEGIN
plog.debug(pkgctx,'HaiLT DFGRPLOG');
  select LENGTH( p_txmsg.txfields('06').VALUE )- LENGTH ( REPLACE( p_txmsg.txfields('06').VALUE,'$','')) into  N  from dual ;

  for i in 1..N loop
plog.debug(pkgctx,'HaiLT DFGRPLOG LOOP');
  if i=1 then
V_STRXML:=substr( p_txmsg.txfields('06').VALUE,0,instr( p_txmsg.txfields('06').VALUE,'$')-1);
  else
V_STRXML :=  substr( p_txmsg.txfields('06').VALUE,instr( p_txmsg.txfields('06').VALUE,'$',1,i-1)+1,instr( p_txmsg.txfields('06').VALUE,'$',1,i)-instr( p_txmsg.txfields('06').VALUE,'$',1,i-1)-1 ) ;
end  if ;

l_ACTYPE := substr(V_STRXML,0,instr(V_STRXML,'|')-1);
l_DFTYPE :=  substr(V_STRXML,instr(V_STRXML,'|',1,1)+1,instr(V_STRXML,'|',1,2)-instr(V_STRXML,'|',1,1)-1 ) ;
l_ORGAMT := substr(V_STRXML,instr(V_STRXML,'|',1,2)+1,instr(V_STRXML,'|',1,3)-instr(V_STRXML,'|',1,2)-1 ) ;
l_TXTIME := substr(V_STRXML,instr(V_STRXML,'|',1,3)+1,instr(V_STRXML,'|',1,4)-instr(V_STRXML,'|',1,3)-1 ) ;
--l_TXDATE := substr(V_STRXML,instr(V_STRXML,'|',1,4)+1,instr(V_STRXML,'|',1,5)-instr(V_STRXML,'|',1,4)-1 ) ;
--l_TXNUM := substr(V_STRXML,instr(V_STRXML,'|',1,5)+1,instr(V_STRXML,'|',1,6)-instr(V_STRXML,'|',1,5)-1 ) ;
l_TXDATE := p_txmsg.txdate;
l_TXNUM :=p_txmsg.txnum;
l_MAKER := substr(V_STRXML,instr(V_STRXML,'|',1,6)+1,instr(V_STRXML,'|',1,7)-instr(V_STRXML,'|',1,6)-1 ) ;
l_IRATE := substr(V_STRXML,instr(V_STRXML,'|',1,7)+1,instr(V_STRXML,'|',1,8)-instr(V_STRXML,'|',1,7)-1 ) ;
l_MRATE := substr(V_STRXML,instr(V_STRXML,'|',1,8)+1,instr(V_STRXML,'|',1,9)-instr(V_STRXML,'|',1,8)-1 ) ;
l_LRATE := substr(V_STRXML,instr(V_STRXML,'|',1,9)+1,instr(V_STRXML,'|',1,10)-instr(V_STRXML,'|',1,9)-1 ) ;
l_AUTODRAWNDOWN := substr(V_STRXML,instr(V_STRXML,'|',1,10)+1,instr(V_STRXML,'|',1,11)-instr(V_STRXML,'|',1,10)-1 ) ;
l_ISAPPROVE := substr(V_STRXML,instr(V_STRXML,'|',1,11)+1,instr(V_STRXML,'|',1,12)-instr(V_STRXML,'|',1,11)-1 ) ;
l_DESCRIPTION := substr(V_STRXML,instr(V_STRXML,'|',1,12)+1,instr(V_STRXML,'|',1,13)-instr(V_STRXML,'|',1,12)-1 ) ;
l_AFACCTNO := substr(V_STRXML,instr(V_STRXML,'|',1,13)+1,instr(V_STRXML,'|',1,14)-instr(V_STRXML,'|',1,13)-1 ) ;
l_DTYPE := substr(V_STRXML,instr(V_STRXML,'|',1,14)+1,instr(V_STRXML,'|',1,15)-instr(V_STRXML,'|',1,14)-1 ) ;
l_SYMBOL := substr(V_STRXML,instr(V_STRXML,'|',1,15)+1,instr(V_STRXML,'|',1,16)-instr(V_STRXML,'|',1,15)-1 ) ;
--l_CODEID := substr(V_STRXML,instr(V_STRXML,'|',1,16)+1,instr(V_STRXML,'|',1,17)-instr(V_STRXML,'|',1,16)-1 ) ;
l_QTTY := substr(V_STRXML,instr(V_STRXML,'|',1,17)+1,instr(V_STRXML,'|',1,18)-instr(V_STRXML,'|',1,17)-1 ) ;
l_DFPRICE := substr(V_STRXML,instr(V_STRXML,'|',1,18)+1,instr(V_STRXML,'|',1,19)-instr(V_STRXML,'|',1,18)-1 ) ;
l_DFRATE := substr(V_STRXML,instr(V_STRXML,'|',1,19)+1,instr(V_STRXML,'|',1,20)-instr(V_STRXML,'|',1,19)-1 ) ;
l_AMT := substr(V_STRXML,instr(V_STRXML,'|',1,20)+1,instr(V_STRXML,'|',1,21)-instr(V_STRXML,'|',1,20)-1 ) ;
l_GROUPID := substr(V_STRXML,instr(V_STRXML,'|',1,21)+1,instr(V_STRXML,'|',1,22)-instr(V_STRXML,'|',1,21)-1 ) ;
l_AUTODRAWNDOWN := substr(V_STRXML,instr(V_STRXML,'|',1,22)+1,instr(V_STRXML,'|',1,23)-instr(V_STRXML,'|',1,22)-1 ) ;
l_ISAPPROVE := substr(V_STRXML,instr(V_STRXML,'|',1,23)+1,instr(V_STRXML,'|',1,24)-instr(V_STRXML,'|',1,23)-1 ) ;
l_AFACCTNODRD  := substr(V_STRXML,instr(V_STRXML,'|',1,24)+1,instr(V_STRXML,'|',1,25)-instr(V_STRXML,'|',1,24)-1 ) ;
l_ref := substr(V_STRXML,instr(V_STRXML,'|',1,25)+1 ) ;

select codeid into l_CODEID from sbsecurities where symbol =l_SYMBOL;
SELECT DFTYPE. LIMITCHK,DFTYPE. CUSTBANK,DFTYPE. RRTYPE,DFTYPE. CIACCTNO,DFTYPE. TAX,DFTYPE. FEEMIN,DFTYPE. FEE,DFTYPE. LNTYPE,DFTYPE. AUTOPAID
into L_LIMITCHK,L_CUSTBANK,L_RRTYPE ,L_CIACCTNO, L_TAX,L_FEEMIN,L_FEE,L_LNTYPE,L_AUTOPAID
FROM DFTYPE  where actype =l_ACTYPE ;


select count (groupid) into L_countgrpid  from  dfgrpdtllog where groupid=l_GROUPID ;
if L_countgrpid = 0  then
    insert into DFGRPLOG (autoid,groupid,actype,afacctno, dftype, limitchk , custbank, rrtype ,ciacctno,pstatus,status,orgamt,amt,calltype,lrate,mrate,irate,amtmin,tax,feemin,fee,lntype,txtime,txdate,autopaid,maker,checker,autodrawndown,isapprove,description,AFACCTNODRD)
    VALUES (seq_dfgrplog.NEXTVAL , l_GROUPID,l_ACTYPE,l_AFACCTNO,l_DFTYPE,L_limitchk,l_custbank,l_rrtype,L_CIACCTNO,'',DECODE(l_ISAPPROVE,'N','N','P'),l_orgamt,0,'P',l_lrate,l_mrate,l_irate,0,l_TAX,l_FEEMIN,l_FEE,l_LNTYPE,l_TXTIME,l_TXDATE,l_AUTOPAID,l_MAKER,'',l_AUTODRAWNDOWN,l_isapprove,l_DESCRIPTION,l_AFACCTNODRD );
end if;

INSERT INTO DFGRPDTLLOG(autoid,groupid,afacctno,codeid ,qtty,dtype,dfprice,dfrate,amt,pstatus,status,deltd,ref)
VALUES (seq_dfgrpDTLlog.NEXTVAL,l_GROUPID,l_AFACCTNO,l_CODEID,l_QTTY,l_DTYPE,l_DFPRICE,L_DFRATE,l_AMT,'','N','N',l_ref);

 END LOOP;

    p_err_code:=0;
    plog.setendsection(pkgctx, 'pr_Createdfgrplog');
  EXCEPTION
  WHEN OTHERS
   THEN
      p_err_code := errnums.C_SYSTEM_ERROR;
      plog.error (pkgctx, SQLERRM);
      plog.error(pkgctx, dbms_utility.format_error_backtrace);
      plog.setendsection (pkgctx, 'pr_Createdfgrplog');
      RAISE errnums.E_SYSTEM_ERROR;
  END pr_Createdfgrplog;

PROCEDURE pr_Drawndowndfgorup(groupid in varchar2 ,p_err_code  OUT varchar2)
  IS

  V_STRXML  varchar2(30000);
    l_ACTYPE varchar2(10);
    l_DFTYPE varchar2(20);
    l_ORGAMT NUMBER;
    l_TXTIME varchar2(20);
    l_TXDATE varchar2(20);
    l_TXNUM  varchar2(20);
    l_MAKER varchar2(4);
    l_IRATE NUMBER;
    l_MRATE NUMBER;
    l_LRATE NUMBER;
    l_AUTODRAWNDOWN NUMBER;
    l_ISAPPROVE varchar2(1);
    l_DESCRIPTION varchar2(500);
    l_AFACCTNO varchar2(10);
    l_DTYPE varchar2(4);
    l_SYMBOL varchar2(20);
    l_CODEID varchar2(6);
    l_QTTY number;
    l_DFPRICE number;
    l_AMT number;
    l_GROUPID varchar2(20);
    l_LIMITCHK varchar2(20);
    L_DFRATE NUMBER;
    l_CUSTBANK varchar2(20);
    l_RRTYPE varchar2(20);
    l_CIACCTNO varchar2(20);
    l_TAX number;
    l_FEEMIN number;
    l_FEE number;
    l_LNTYPE varchar2(20);
    l_AUTOPAID varchar2(20);
    L_countgrpid  NUMBER;
    l_AFACCTNODRD  varchar2(20);
    l_ref varchar2(50);
      l_txmsg               tx.msg_rectype;
      v_strCURRDATE varchar2(20);
      v_strPREVDATE varchar2(20);
      v_strNEXTDATE varchar2(20);
      v_strDesc varchar2(1000);
      v_strEN_Desc varchar2(1000);
      v_blnVietnamese BOOLEAN;
      l_err_param varchar2(300);
      l_MaxRow NUMBER(20,0);
      N NUMBER ;


  BEGIN

    plog.setbeginsection(pkgctx, 'pr_Drawndowndfgorup');


    ---- Giai ngan tu dong 2674
l_GROUPID:=groupid;
    SELECT TXDESC,EN_TXDESC into v_strDesc, v_strEN_Desc FROM  TLTX WHERE TLTXCD='2674';
     SELECT TO_DATE (varvalue, systemnums.c_date_format)
               INTO v_strCURRDATE
               FROM sysvar
               WHERE grname = 'SYSTEM' AND varname = 'CURRDATE';
    l_txmsg.msgtype:='T';
    l_txmsg.local:='N';
    l_txmsg.tlid        := systemnums.c_system_userid;
    SELECT SYS_CONTEXT ('USERENV', 'HOST'),
             SYS_CONTEXT ('USERENV', 'IP_ADDRESS', 15)
      INTO l_txmsg.wsname, l_txmsg.ipaddress
    FROM DUAL;
    l_txmsg.off_line    := 'N';
    l_txmsg.deltd       := txnums.c_deltd_txnormal;
    l_txmsg.txstatus    := txstatusnums.c_txcompleted;
    l_txmsg.msgsts      := '0';
    l_txmsg.ovrsts      := '0';
    l_txmsg.batchname   := 'DAY';
    l_txmsg.txdate:=to_date(v_strCURRDATE,systemnums.c_date_format);
    l_txmsg.BUSDATE:=to_date(v_strCURRDATE,systemnums.c_date_format);
    l_txmsg.tltxcd:='2674';
       for rec in
    (
        select df.GROUPID,cf.custodycd,af.acctno afacctno, cf.fullname custname , cf.address , cf.idcode LICENSE,
        df.limitchk,df.rrtype,df.ACTYPE,df.DFTYPE, df.IRATE, df.MRATE, df.LRATE, df.orgamt-df.rlsamt amt , df.rlsamt RLSAMT,df.CALLTYPE,
        decode (df.RRTYPE,'O',df.ciacctno,'B',df.custbank,null)
        RRID ,dftype.autodrawndown, decode (df.RRTYPE,'O',1,0) CIDRAWNDOWN,decode (df.RRTYPE,'B',1,0) BANKDRAWNDOWN,
        decode (df.RRTYPE,'C',1,0) CMPDRAWNDOWN,df.description,DF.LNACCTNO,DECODE(df.LIMITCHK,'Y',1,0) LIMITCHECK,
        DECODE(dftype.isbuysec,'B',1,0) isbuysec
        from  dfgroup df, cfmast cf , afmast af,dftype
        where df.afacctno=af.acctno and af.custid =cf.custid
        and df.actype = dftype.actype and df.status='N'
        and df.groupid =l_GROUPID
    )
    loop
        --Set txnum
        SELECT systemnums.C_BATCH_PREFIXED
                         || LPAD (seq_BATCHTXNUM.NEXTVAL, 8, '0')
                  INTO l_txmsg.txnum
                  FROM DUAL;
        l_txmsg.brid        := substr(rec.AFACCTNO,1,4);
        --Xac dinh xem nha day tu trong nuoc hay nuoc ngoai


       --Set cac field giao dich
        --20   C   GROUPID
        l_txmsg.txfields ('20').defname   := 'GROUPID';
        l_txmsg.txfields ('20').TYPE      := 'C';
        l_txmsg.txfields ('20').VALUE     := rec.GROUPID ;

        --21   N   LNACCTNO
        l_txmsg.txfields ('21').defname   := 'LNACCTNO';
        l_txmsg.txfields ('21').TYPE      := 'C';
        l_txmsg.txfields ('21').VALUE     := rec.LNACCTNO ;


        --88   CUSTODYCD     C
        l_txmsg.txfields ('88').defname   := 'CUSTODYCD';
        l_txmsg.txfields ('88').TYPE      := 'C';
        l_txmsg.txfields ('88').VALUE     := rec.CUSTODYCD;

        --03   C   AFACCTNO
        l_txmsg.txfields ('03').defname   := 'AFACCTNO';
        l_txmsg.txfields ('03').TYPE      := 'C';
        l_txmsg.txfields ('03').VALUE     := rec.AFACCTNO;
        --57   CUSTNAME    C
        l_txmsg.txfields ('57').defname   := 'CUSTNAME';
        l_txmsg.txfields ('57').TYPE      := 'C';
        l_txmsg.txfields ('57').VALUE     := rec.CUSTNAME;
        --58   ADDRESS    C
        l_txmsg.txfields ('58').defname   := 'ADDRESS';
        l_txmsg.txfields ('58').TYPE      := 'C';
        l_txmsg.txfields ('58').VALUE     :=  rec.ADDRESS;
        --59   LICENSE    C
        l_txmsg.txfields ('59').defname   := 'LICENSE';
        l_txmsg.txfields ('59').TYPE      := 'C';
        l_txmsg.txfields ('59').VALUE     := rec.LICENSE;
          --99   LIMITCHECK    N
        l_txmsg.txfields ('99').defname   := 'LIMITCHECK';
        l_txmsg.txfields ('99').TYPE      := 'N';
        l_txmsg.txfields ('99').VALUE     := REC.LIMITCHECK;
          --15   RRTYPE    C
        l_txmsg.txfields ('15').defname   := 'RRTYPE';
        l_txmsg.txfields ('15').TYPE      := 'C';
        l_txmsg.txfields ('15').VALUE     := rec.RRTYPE;

          --04   ACTYPE    C
        l_txmsg.txfields ('04').defname   := 'ACTYPE';
        l_txmsg.txfields ('04').TYPE      := 'C';
        l_txmsg.txfields ('04').VALUE     := rec.ACTYPE;
          --06   DFTYPE    C
        l_txmsg.txfields ('06').defname   := 'DFTYPE';
        l_txmsg.txfields ('06').TYPE      := 'C';
        l_txmsg.txfields ('06').VALUE     := rec.DFTYPE;

          --14   IRATE   C
        l_txmsg.txfields ('14').defname   := 'IRATE';
        l_txmsg.txfields ('14').TYPE      := 'C';
        l_txmsg.txfields ('14').VALUE     := rec.IRATE;
          --08   MRATE   C
        l_txmsg.txfields ('08').defname   := 'MRATE';
        l_txmsg.txfields ('08').TYPE      := 'C';
        l_txmsg.txfields ('08').VALUE     := rec.MRATE;
          --09   LRATE    C
        l_txmsg.txfields ('09').defname   := 'LRATE';
        l_txmsg.txfields ('09').TYPE      := 'C';
        l_txmsg.txfields ('09').VALUE     := rec.LRATE;
          --41   AMT    N
        l_txmsg.txfields ('41').defname   := 'AMT';
        l_txmsg.txfields ('41').TYPE      := 'N';
        l_txmsg.txfields ('41').VALUE     := rec.AMT;
          --18   RLSAMT    N
        l_txmsg.txfields ('18').defname   := 'RLSAMT';
        l_txmsg.txfields ('18').TYPE      := 'N';
        l_txmsg.txfields ('18').VALUE     := rec.RLSAMT;
          --17   CALLTYPE    N
        l_txmsg.txfields ('17').defname   := 'CALLTYPE';
        l_txmsg.txfields ('17').TYPE      := 'C';
        l_txmsg.txfields ('17').VALUE     := rec.CALLTYPE;
          --16   AUTODRAWNDOWN    C
        l_txmsg.txfields ('16').defname   := 'AUTODRAWNDOWN';
        l_txmsg.txfields ('16').TYPE      := 'C';
        l_txmsg.txfields ('16').VALUE     := rec.AUTODRAWNDOWN;
          --51   CIDRAWNDOWN    C
        l_txmsg.txfields ('51').defname   := 'CIDRAWNDOWN';
        l_txmsg.txfields ('51').TYPE      := 'C';
        l_txmsg.txfields ('51').VALUE     := rec.CIDRAWNDOWN;

        --45   ISBUYSEC    N
        l_txmsg.txfields ('45').defname   := 'ISBUYSEC';
        l_txmsg.txfields ('45').TYPE      := 'N';
        l_txmsg.txfields ('45').VALUE     := rec.ISBUYSEC;

          --52   BANKDRAWNDOWN    C
        l_txmsg.txfields ('52').defname   := 'BANKDRAWNDOWN';
        l_txmsg.txfields ('52').TYPE      := 'C';
        l_txmsg.txfields ('52').VALUE     := rec.BANKDRAWNDOWN;
          --53   CMPDRAWNDOWN    C
        l_txmsg.txfields ('53').defname   := 'CMPDRAWNDOWN';
        l_txmsg.txfields ('53').TYPE      := 'C';
        l_txmsg.txfields ('53').VALUE     := rec.CMPDRAWNDOWN;
          --50   RRID    C
        l_txmsg.txfields ('50').defname   := 'RRID';
        l_txmsg.txfields ('50').TYPE      := 'C';
        l_txmsg.txfields ('50').VALUE     := rec.RRID;

             --30   DESC    C
        l_txmsg.txfields ('30').defname   := 'DESC';
        l_txmsg.txfields ('30').TYPE      := 'C';
        l_txmsg.txfields ('30').VALUE     := rec.description;

        BEGIN
            IF txpks_#2674.fn_batchtxprocess (l_txmsg,
                                             p_err_code,
                                             l_err_param
               ) <> systemnums.c_success
            THEN
               plog.debug (pkgctx,
                           'got error 2674: ' || p_err_code
               );
               ROLLBACK;
               RETURN;
            END IF;
        END;
    end loop;


    p_err_code:=0;
    plog.setendsection(pkgctx, 'pr_Drawndowndfgorup');
  EXCEPTION
  WHEN OTHERS
   THEN
      plog.debug (pkgctx,'got error on pr_Drawndowndfgorup');
      p_err_code := errnums.C_SYSTEM_ERROR;
      plog.error (pkgctx, SQLERRM);
      plog.setendsection (pkgctx, 'pr_Drawndowndfgorup');
      RAISE errnums.E_SYSTEM_ERROR;
  END pr_Drawndowndfgorup;
  ---pr_Opentdfgroup-----------
PROCEDURE pr_Opentdfgroup(p_groupid in varchar2 ,p_err_code  OUT varchar2)
  IS
    V_STRXML  varchar2(30000);
    l_ACTYPE varchar2(10);
    l_DFTYPE varchar2(20);
    l_ORGAMT NUMBER;
    l_TXTIME varchar2(20);
    l_TXDATE varchar2(20);
    l_TXNUM  varchar2(20);
    l_MAKER varchar2(4);
    l_IRATE NUMBER;
    l_MRATE NUMBER;
    l_LRATE NUMBER;
    l_AUTODRAWNDOWN NUMBER;
    l_ISAPPROVE varchar2(1);
    l_DESCRIPTION varchar2(500);
    l_AFACCTNO varchar2(10);
    l_DTYPE varchar2(4);
    l_SYMBOL varchar2(20);
    l_CODEID varchar2(6);
    l_QTTY number;
    l_DFPRICE number;
    l_AMT number;
    l_GROUPID varchar2(20);
    l_LIMITCHK varchar2(20);
    L_DFRATE NUMBER;
    l_CUSTBANK varchar2(20);
    l_RRTYPE varchar2(20);
    l_CIACCTNO varchar2(20);
    l_TAX number;
    l_FEEMIN number;
    l_FEE number;
    l_LNTYPE varchar2(20);
    l_AUTOPAID varchar2(20);
    L_countgrpid  NUMBER;
    l_AFACCTNODRD  varchar2(20);
    l_ref varchar2(50);
      l_txmsg               tx.msg_rectype;
      v_strCURRDATE varchar2(20);
      v_strPREVDATE varchar2(20);
      v_strNEXTDATE varchar2(20);
      v_strDesc varchar2(1000);
      v_strEN_Desc varchar2(1000);
      v_blnVietnamese BOOLEAN;
      l_err_param varchar2(300);
      l_MaxRow NUMBER(20,0);
      N NUMBER ;


  BEGIN
    plog.setbeginsection(pkgctx, 'pr_Opentdfgroup');

l_GROUPID:=p_groupid;
    SELECT TXDESC,EN_TXDESC into v_strDesc, v_strEN_Desc FROM  TLTX WHERE TLTXCD='2673';
     SELECT TO_DATE (varvalue, systemnums.c_date_format)
               INTO v_strCURRDATE
               FROM sysvar
               WHERE grname = 'SYSTEM' AND varname = 'CURRDATE';
    l_txmsg.msgtype:='T';
    l_txmsg.local:='N';
    l_txmsg.tlid        := systemnums.c_system_userid;
    SELECT SYS_CONTEXT ('USERENV', 'HOST'),
             SYS_CONTEXT ('USERENV', 'IP_ADDRESS', 15)
      INTO l_txmsg.wsname, l_txmsg.ipaddress
    FROM DUAL;
    l_txmsg.off_line    := 'N';
    l_txmsg.deltd       := txnums.c_deltd_txnormal;
    l_txmsg.txstatus    := txstatusnums.c_txcompleted;
    l_txmsg.msgsts      := '0';
    l_txmsg.ovrsts      := '0';
    l_txmsg.batchname   := 'DAY';
    l_txmsg.txdate:=v_strCURRDATE;
    l_txmsg.BUSDATE:=v_strCURRDATE;
    l_txmsg.tltxcd:='2673';

   plog.debug (pkgctx,'pr_Opentdfgroup:Begin Loop');
   plog.debug (pkgctx,'pr_Opentdfgroup:0l_GROUPID:'||l_GROUPID);

   select count(1) into L_countgrpid from dfgrplog where groupid = l_GROUPID;
   if L_countgrpid > 0 then
   plog.debug (pkgctx,'pr_Opentdfgroup:1l_GROUPID:'||l_GROUPID);
   end if;
      select count(1) into L_countgrpid from dfgrpdtllog where groupid = l_GROUPID;
   if L_countgrpid > 0 then
   plog.debug (pkgctx,'pr_Opentdfgroup:2l_GROUPID:'||l_GROUPID);
   end if;

 for rec in
    (
          select  df.groupid , cf.custodycd , nvl(DF.AFACCTNODRD,DF.AFACCTNO) AFACCTNODRD , af.acctno afacctno,cf.fullname CUSTNAME,cf.address , cf.idcode LICENSE ,df.autodrawndown,df.autopaid,df.limitchk LIMITCHECK,
          df.rrtype , DF.actype ,DF.dftype ,DFDTL.codeid , af.acctno||DFDTL.CODEID SEACCTNO ,DF.IRATE,DF.MRATE,DF.LRATE,
          DF.orgamt,DFDTL.qtty,DFDTL.dfrate , DFDTL.dfprice , DFDTL.amt ,DF.description description , df.ciacctno,df.custbank,
          decode (DFDTL.DTYPE,'P',DFDTL.QTTY,0) CARCVQTTY,decode (DFDTL.DTYPE,'R',DFDTL.QTTY,0) RCVQTTY, decode (DFDTL.DTYPE,'B',DFDTL.QTTY,0) BLOCKQTTY,
          decode (DFDTL.DTYPE,'N',DFDTL.QTTY,0) AVLQTTY,   decode (DFDTL.DTYPE,'T',DFDTL.QTTY,0) CACASHQTTY, ref,
          decode (df.RRTYPE,'O',1,0) CIDRAWNDOWN,decode (df.RRTYPE,'B',1,0) BANKDRAWNDOWN, decode (df.RRTYPE,'C',1,0) CMPDRAWNDOWN,dfdtl.dtype
         from dfgrplog  df, dfgrpdtllog dfdtl,CFMAST CF, AFMAST AF
         where df.groupid = dfdtl.groupid AND DF.AFACCTNO = AF.ACCTNO AND AF.custid = cf.custid --AND df.STATUS='N'
        and df.groupid = l_GROUPID
    )
    loop
        --Set txnum
        SELECT systemnums.C_BATCH_PREFIXED
                         || LPAD (seq_BATCHTXNUM.NEXTVAL, 8, '0')
                  INTO l_txmsg.txnum
                  FROM DUAL;
        l_txmsg.brid        := substr(rec.AFACCTNO,1,4);
        --Xac dinh xem nha day tu trong nuoc hay nuoc ngoai

   plog.debug (pkgctx,'MATRIX02'||l_GROUPID||REC.GROUPID);

       --Set cac field giao dich
        --20   C   GROUPID
        l_txmsg.txfields ('20').defname   := 'GROUPID';
        l_txmsg.txfields ('20').TYPE      := 'C';
        l_txmsg.txfields ('20').VALUE     := rec.GROUPID ;

        --88   CUSTODYCD     C
        l_txmsg.txfields ('88').defname   := 'CUSTODYCD';
        l_txmsg.txfields ('88').TYPE      := 'C';
        l_txmsg.txfields ('88').VALUE     := rec.CUSTODYCD;
        --02   ACCTNO   C
        l_txmsg.txfields ('02').defname   := 'ACCTNO';
        l_txmsg.txfields ('02').TYPE      := 'C';
        l_txmsg.txfields ('02').VALUE     := l_GROUPID;
        --03   C   AFACCTNO
        l_txmsg.txfields ('03').defname   := 'AFACCTNO';
        l_txmsg.txfields ('03').TYPE      := 'C';
        l_txmsg.txfields ('03').VALUE     := rec.AFACCTNO;
        --57   CUSTNAME    C
        l_txmsg.txfields ('57').defname   := 'CUSTNAME';
        l_txmsg.txfields ('57').TYPE      := 'C';
        l_txmsg.txfields ('57').VALUE     := rec.CUSTNAME;
        --58   ADDRESS    C
        l_txmsg.txfields ('58').defname   := 'ADDRESS';
        l_txmsg.txfields ('58').TYPE      := 'N';
        l_txmsg.txfields ('58').VALUE     :=  rec.ADDRESS;
        --59   LICENSE    C
        l_txmsg.txfields ('59').defname   := 'LICENSE';
        l_txmsg.txfields ('59').TYPE      := 'C';
        l_txmsg.txfields ('59').VALUE     := rec.LICENSE;
          --16   AUTODRAWNDOWN    C
        l_txmsg.txfields ('16').defname   := 'AUTODRAWNDOWN';
        l_txmsg.txfields ('16').TYPE      := 'C';
        l_txmsg.txfields ('16').VALUE     := rec.AUTODRAWNDOWN;
          --17   AUTOPAID    C
        l_txmsg.txfields ('17').defname   := 'AUTOPAID';
        l_txmsg.txfields ('17').TYPE      := 'C';
        l_txmsg.txfields ('17').VALUE     := rec.AUTOPAID;

          --18   DTYPE    C
        l_txmsg.txfields ('18').defname   := 'DTYPE';
        l_txmsg.txfields ('18').TYPE      := 'C';
        l_txmsg.txfields ('18').VALUE     := rec.DTYPE;

          --99   LIMITCHECK    C
        l_txmsg.txfields ('99').defname   := 'LIMITCHECK';
        l_txmsg.txfields ('99').TYPE      := 'C';
        l_txmsg.txfields ('99').VALUE     := rec.LIMITCHECK;
          --15   RRTYPE    C
        l_txmsg.txfields ('15').defname   := 'RRTYPE';
        l_txmsg.txfields ('15').TYPE      := 'C';
        l_txmsg.txfields ('15').VALUE     := rec.RRTYPE;
          --50   RRID   C
        l_txmsg.txfields ('50').defname   := 'RRID';
        l_txmsg.txfields ('50').TYPE      := 'C';
          If rec.rrtype = 'O' Then
         --Giai ngan qua CI
         l_txmsg.txfields ('50').VALUE := rec.CIACCTNO;
          Elsif  rec.rrtype  = 'B' Then
           --Giai ngan qua bank
         l_txmsg.txfields ('50').VALUE := rec.CUSTBANK;
          end if;

            --51   CIDRAWNDOWN    C
        l_txmsg.txfields ('51').defname   := 'CIDRAWNDOWN';
        l_txmsg.txfields ('51').TYPE      := 'C';
        l_txmsg.txfields ('51').VALUE     := rec.CIDRAWNDOWN;
          --52   BANKDRAWNDOWN    C
        l_txmsg.txfields ('52').defname   := 'BANKDRAWNDOWN';
        l_txmsg.txfields ('52').TYPE      := 'C';
        l_txmsg.txfields ('52').VALUE     := rec.BANKDRAWNDOWN;
          --53   CMPDRAWNDOWN    C
        l_txmsg.txfields ('53').defname   := 'CMPDRAWNDOWN';
        l_txmsg.txfields ('53').TYPE      := 'C';
        l_txmsg.txfields ('53').VALUE     := rec.CMPDRAWNDOWN;

       --13   RCVQTTY    N
        l_txmsg.txfields ('13').defname   := 'RCVQTTY';
        l_txmsg.txfields ('13').TYPE      := 'N';
        l_txmsg.txfields ('13').VALUE     := rec.RCVQTTY;

        --20   BLOCKQTTY    N
        l_txmsg.txfields ('22').defname   := 'BLOCKQTTY';
        l_txmsg.txfields ('22').TYPE      := 'N';
        l_txmsg.txfields ('22').VALUE     := rec.BLOCKQTTY;

        --23   CARCVQTTY    N
        l_txmsg.txfields ('23').defname   := 'CARCVQTTY';
        l_txmsg.txfields ('23').TYPE      := 'N';
        l_txmsg.txfields ('23').VALUE     := rec.CARCVQTTY;

        l_txmsg.txfields ('55').defname   := 'CACASHQTTY';
        l_txmsg.txfields ('55').TYPE      := 'N';
        l_txmsg.txfields ('55').VALUE     := rec.CACASHQTTY;

        --12   AVLQTTY    N
        l_txmsg.txfields ('12').defname   := 'AVLQTTY';
        l_txmsg.txfields ('12').TYPE      := 'N';
        l_txmsg.txfields ('12').VALUE     := rec.AVLQTTY;

          --04   ACTYPE   C
        l_txmsg.txfields ('04').defname   := 'ACTYPE';
        l_txmsg.txfields ('04').TYPE      := 'C';
        l_txmsg.txfields ('04').VALUE     := rec.ACTYPE;
          --06   DFTYPE    C
        l_txmsg.txfields ('06').defname   := 'DFTYPE';
        l_txmsg.txfields ('06').TYPE      := 'C';
        l_txmsg.txfields ('06').VALUE     := rec.DFTYPE;
          --01   CODEID   C
        l_txmsg.txfields ('01').defname   := 'CODEID';
        l_txmsg.txfields ('01').TYPE      := 'C';
        l_txmsg.txfields ('01').VALUE     := rec.CODEID;
          --05   SEACCTNO   C
        l_txmsg.txfields ('05').defname   := 'SEACCTNO';
        l_txmsg.txfields ('05').TYPE      := 'C';
        l_txmsg.txfields ('05').VALUE     := rec.SEACCTNO;
            --05   SEACCTNO   C
        l_txmsg.txfields ('05').defname   := 'SEACCTNO';
        l_txmsg.txfields ('05').TYPE      := 'C';
        l_txmsg.txfields ('05').VALUE     := rec.SEACCTNO;

          --14   IRATE    N
        l_txmsg.txfields ('14').defname   := 'IRATE';
        l_txmsg.txfields ('14').TYPE      := 'C';
        l_txmsg.txfields ('14').VALUE     := rec.IRATE;
          --08   MRATE    N
        l_txmsg.txfields ('08').defname   := 'MRATE';
        l_txmsg.txfields ('08').TYPE      := 'C';
        l_txmsg.txfields ('08').VALUE     := rec.MRATE;
          --09   LRATE    N
        l_txmsg.txfields ('09').defname   := 'LRATE';
        l_txmsg.txfields ('09').TYPE      := 'C';
        l_txmsg.txfields ('09').VALUE     := rec.LRATE;
          --41   ORGAMT    N
        l_txmsg.txfields ('41').defname   := 'ORGAMT';
        l_txmsg.txfields ('41').TYPE      := 'C';
        l_txmsg.txfields ('41').VALUE     := rec.ORGAMT;
          --40   QTTY    N
        l_txmsg.txfields ('40').defname   := 'QTTY';
        l_txmsg.txfields ('40').TYPE      := 'C';
        l_txmsg.txfields ('40').VALUE     := rec.QTTY;
          --07   DFRATE    N
        l_txmsg.txfields ('07').defname   := 'DFRATE';
        l_txmsg.txfields ('07').TYPE      := 'N';
        l_txmsg.txfields ('07').VALUE     := rec.DFRATE;
          --10   DFPRICE    N
        l_txmsg.txfields ('10').defname   := 'DFPRICE';
        l_txmsg.txfields ('10').TYPE      := 'N';
        l_txmsg.txfields ('10').VALUE     := rec.DFPRICE;

          --42   AMT    N
        l_txmsg.txfields ('42').defname   := 'AMT';
        l_txmsg.txfields ('42').TYPE      := 'N';
        l_txmsg.txfields ('42').VALUE     := rec.AMT;

          --29   REF   C
        l_txmsg.txfields ('29').defname   := 'REF';
        l_txmsg.txfields ('29').TYPE      := 'C';
        l_txmsg.txfields ('29').VALUE     := rec.REF;

         --21 AFACCTNODRD
        l_txmsg.txfields ('21').defname   := 'AFACCTNODRD';
        l_txmsg.txfields ('21').TYPE      := 'C';
        l_txmsg.txfields ('21').VALUE     := rec.AFACCTNODRD;

         --30   DESC    C
       l_txmsg.txfields ('30').defname   := 'DESC';
        l_txmsg.txfields ('30').TYPE      := 'C';
        l_txmsg.txfields ('30').VALUE     := rec.description;

      BEGIN
            IF txpks_#2673.fn_batchtxprocess (l_txmsg,
                                             p_err_code,
                                             l_err_param
               ) <> systemnums.c_success
            THEN
               plog.debug (pkgctx,
                           'got error 2673: ' || p_err_code
               );
               ROLLBACK;
               RETURN;
            END IF;
        END;
    end loop;

    p_err_code:=0;
    plog.setendsection(pkgctx, 'pr_Opentdfgroup');
  EXCEPTION
  WHEN OTHERS
   THEN
      plog.debug (pkgctx,'got error on pr_Opentdfgroup');
      p_err_code := errnums.C_SYSTEM_ERROR;
      plog.error (pkgctx, SQLERRM);
      plog.setendsection (pkgctx, 'pr_Opentdfgroup');
      RAISE errnums.E_SYSTEM_ERROR;
  END pr_Opentdfgroup;


  ---pr_AddCIToReleaseSecu-----------
PROCEDURE pr_AddCIToReleaseSecu(p_txmsg in tx.msg_rectype,p_err_code  OUT varchar2)
  IS
    V_STRXML  varchar2(30000);
    l_count number;
    l_countN number;
    l_ORGAMT number;
    l_AMTPAID number;
    l_INTPAID number;
    l_FEEPAID number;
    l_nTemp number;
    l_DFTRADING number;
    l_INTPENA number;
    l_FEEPENA number;
    l_ReleaseQTTY number;
    v_dblCARCVQTTY number;
    v_dblRCVQTTY number;
    v_dblBLOCKQTTY number;
    v_dblAVLQTTY NUMBER;
    v_dblCACASHQTTY number;
    l_INITQTTY number;
    l_ADDQTTY number;
    l_DFACCTNO varchar2(20);
    l_AFACCTNO varchar2(20);
    l_GROUPID  varchar2(20);
    l_INTPAIDMETHOD varchar2(1);
    l_DEALTYPE VARCHAR2(1);
    l_DFREF varchar2(50);
    l_CODEID varchar2(6);
    l_ACTYPE varchar2(4);
    v_strRLSDATE date;
    v_strDesc varchar2(100);
    v_strEN_Desc varchar2(100);
    v_strCURRDATE date;
    l_txmsg               tx.msg_rectype;
    l_err_param varchar2(300);
    v_dblRemainRCVQTTY number;
    v_dblExecRCVQTTY NUMBER;
    v_dblReleaseAMT NUMBER;
    l_EXECQTTY NUMBER;
    l_EXECQTTY_T  NUMBER;
    v_paid number;
    v_nml NUMBER;
    v_ovd NUMBER;
    v_intnmlacr NUMBER;
    v_INTOVDPRIN  NUMBER;
    v_intovd  NUMBER;
    v_intdue  NUMBER;
    v_intpaid NUMBER;
    v_FEEINTNMLOVD NUMBER;
    v_FEEINTOVDACR NUMBER;
    v_FEEINTNMLACR NUMBER;
    v_FEEDUE NUMBER;
    v_feeintpaid NUMBER;
    v_LNACCTNO varchar2(20);
    v_isvsd varchar2(1);

  BEGIN
/*
    SELECT TXDESC,EN_TXDESC into v_strDesc, v_strEN_Desc FROM  TLTX WHERE TLTXCD='2647';
     SELECT TO_DATE (varvalue, systemnums.c_date_format)
               INTO v_strCURRDATE
               FROM sysvar
               WHERE grname = 'SYSTEM' AND varname = 'CURRDATE';
    l_txmsg.msgtype:='T';
    l_txmsg.local:='N';
    l_txmsg.tlid        := systemnums.c_system_userid;
    SELECT SYS_CONTEXT ('USERENV', 'HOST'),
             SYS_CONTEXT ('USERENV', 'IP_ADDRESS', 15)
      INTO l_txmsg.wsname, l_txmsg.ipaddress
    FROM DUAL;

    l_txmsg.off_line    := 'N';
    l_txmsg.deltd       := txnums.c_deltd_txnormal;
    l_txmsg.txstatus    := txstatusnums.c_txcompleted;
    l_txmsg.msgsts      := '0';
    l_txmsg.ovrsts      := '0';
    l_txmsg.batchname   := 'DAY';
    l_txmsg.txdate:=to_date(v_strCURRDATE,systemnums.c_date_format);
    l_txmsg.BUSDATE:=to_date(v_strCURRDATE,systemnums.c_date_format);
    l_txmsg.tltxcd:='2647';
*/

    V_STRXML:= p_txmsg.txfields('06').VALUE;

    l_countN:=REGEXP_COUNT(V_STRXML,'@');

   plog.debug (pkgctx,'pr_AddCIToReleaseSecu'||V_STRXML || ' ' || l_countN);

    for l_count in 1.. l_countN loop

        --l_ORGAMT := substr( V_STRXML,instr(V_STRXML,'|',1,2) + 1,instr(V_STRXML,'|',1,3) - instr(V_STRXML,'|',1,2) -1 );
        l_GROUPID := substr(V_STRXML,1,instr(V_STRXML,'|',1,1)-1 ) ;
        l_DFACCTNO := substr(V_STRXML,instr(V_STRXML,'|',1,1)+1,instr(V_STRXML,'|',1,2)-instr(V_STRXML,'|',1,1)-1 ) ;
        l_ReleaseQTTY:= substr(V_STRXML,instr (V_STRXML,'|',1,3)+1,instr (V_STRXML,'|',1,4)-instr (V_STRXML,'|',1,3)-1);
        l_AMTPAID:=substr(V_STRXML,instr (V_STRXML,'|',1,4)+1,instr (V_STRXML,'|',1,5)-instr (V_STRXML,'|',1,4)-1);
        l_INTPAID:=substr(V_STRXML,instr (V_STRXML,'|',1,5)+1,instr (V_STRXML,'|',1,6)-instr (V_STRXML,'|',1,5)-1);
        l_FEEPAID:=substr(V_STRXML,instr (V_STRXML,'|',1,6)+1,instr (V_STRXML,'|',1,7)-instr (V_STRXML,'|',1,6)-1);
        l_INTPENA:=substr(V_STRXML,instr (V_STRXML,'|',1,7)+1,instr (V_STRXML,'|',1,8)-instr (V_STRXML,'|',1,7)-1);
        l_FEEPENA:=substr(V_STRXML,instr (V_STRXML,'|',1,8)+1,instr (V_STRXML,'|',1,9)-instr (V_STRXML,'|',1,8)-1);
        l_DEALTYPE:=substr(V_STRXML,instr (V_STRXML,'|',1,9)+1,instr (V_STRXML,'|',1,10)-instr (V_STRXML,'|',1,9)-1);
        l_ORGAMT := substr( V_STRXML,instr(V_STRXML,'|',1,10) + 1,instr (V_STRXML,'|',1,11)-instr (V_STRXML,'|',1,10)-1);
        l_INITQTTY:= substr( V_STRXML,instr(V_STRXML,'|',1,14) + 1,instr (V_STRXML,'|',1,15)-instr (V_STRXML,'|',1,14)-1);
        l_ADDQTTY:= substr( V_STRXML,instr(V_STRXML,'|',1,15) + 1,instr (V_STRXML,'|',1,16)-instr (V_STRXML,'|',1,15)-1);


        SELECT AFACCTNO, ACTYPE, CODEID into l_AFACCTNO, l_ACTYPE, l_CODEID from dfmast where acctno = l_DFACCTNO;


        if l_count=1 AND (l_AMTPAID + l_INTPAID + l_FEEPAID > 0)  then
            -- Cap nhap so tien nop vao de giai toa ck
            --update dfgroup set DFAMT = DFAMT + l_ORGAMT WHERE GROUPID=l_GROUPID;

            --INSERT INTO DFTRAN(TXNUM,TXDATE,ACCTNO,TXCD,NAMT,CAMT,ACCTREF,DELTD,REF,AUTOID,TLTXCD,BKDATE,TRDESC)
            --VALUES (p_txmsg.txnum, TO_DATE (p_txmsg.txdate, systemnums.C_DATE_FORMAT),l_GROUPID,'0018',l_ORGAMT,NULL,l_AFACCTNO,p_txmsg.deltd,l_AFACCTNO,seq_DFTRAN.NEXTVAL,p_txmsg.tltxcd,p_txmsg.busdate,'' || '' || '');
            /*
            -- Insert vao CITRAN

            INSERT INTO CITRAN (TXNUM,TXDATE,ACCTNO,TXCD,NAMT,CAMT,REF,DELTD,ACCTREF,AUTOID,TLTXCD,BKDATE,TRDESC)
            VALUES(p_txmsg.txnum ,TO_DATE(p_txmsg.txdate,'DD/MM/RRRR'),l_AFACCTNO,'0011',l_ORGAMT,NULL,NULL,'N',NULL,SEQ_CITRAN.NEXTVAL,'2646',TO_DATE(p_txmsg.txdate,'DD/MM/RRRR'),NULL);

            INSERT INTO CITRAN (TXNUM,TXDATE,ACCTNO,TXCD,NAMT,CAMT,REF,DELTD,ACCTREF,AUTOID,TLTXCD,BKDATE,TRDESC)
            VALUES(p_txmsg.txnum,TO_DATE(p_txmsg.txdate,'DD/MM/RRRR'),l_AFACCTNO,'0071',l_ORGAMT,NULL,NULL,'N',NULL,SEQ_CITRAN.NEXTVAL,'2646',TO_DATE(p_txmsg.txdate,'DD/MM/RRRR'),NULL);

            -- Cap nhap giam CI
            UPDATE CIMAST SET BALANCE = BALANCE - l_ORGAMT,DFODAMT = DFODAMT - l_ORGAMT, LAST_CHANGE = SYSTIMESTAMP
                WHERE ACCTNO=l_AFACCTNO;
            */
            ---Kiem tra xem co du CK ko thi moi cho lam

            SELECT CASE WHEN l_DEALTYPE = 'N' THEN DFQTTY
                        WHEN l_DEALTYPE = 'T' THEN CACASHQTTY
                        WHEN l_DEALTYPE = 'P' THEN CARCVQTTY
                        WHEN l_DEALTYPE = 'R' THEN RCVQTTY
                        WHEN l_DEALTYPE = 'B' THEN BLOCKQTTY  END INTO l_EXECQTTY  FROM DFMAST WHERE ACCTNO = l_DFACCTNO;

            if l_EXECQTTY <  l_ReleaseQTTY then
                p_err_code:= -400445;
                ROLLBACK;
                return;
            END IF;

            --- Cap nhap tra no.
            cspks_dfproc.pr_DFPaidDeal(p_txmsg,l_GROUPID,l_AMTPAID,l_INTPAID,l_FEEPAID,l_INTPENA,l_FEEPENA,p_err_code);

            if p_err_code <> systemnums.C_SUCCESS then
               plog.setendsection (pkgctx, 'fn_txPreAppCheck');
               RETURN;
            end if;

/*

            SELECT INTPAIDMETHOD into l_INTPAIDMETHOD from lnmast where ACCTNO IN (SELECT LNACCTNO FROM DFGROUP WHERE GROUPID= l_GROUPID );

            select ovd+nml into l_nTemp from lnschd where reftype='P' and ACCTNO IN (SELECT LNACCTNO FROM DFGROUP WHERE GROUPID= l_GROUPID );

            ---- UPDATE LNSCHD VA LNMAST
            INSERT INTO LNSCHDLOG (AUTOID, TXNUM, TXDATE, OVD, NML, PAID)
                SELECT AUTOID, p_txmsg.txnum, TO_DATE(p_txmsg.txdate,'DD/MM/RRRR'), -least(ovd, l_amtpaid), -least(l_amtpaid, greatest(l_amtpaid-ovd,0),NML),
                    - GREATEST(least(ovd, l_amtpaid), least(l_amtpaid, greatest(l_amtpaid-ovd,0),NML)) from lnschd
                    where reftype='P' and ACCTNO IN (SELECT LNACCTNO FROM DFGROUP WHERE GROUPID= l_GROUPID );

            update lnschd set ovd= ovd - least(ovd, l_amtpaid), nml=nml-least(l_amtpaid, greatest(l_amtpaid-ovd,0),NML),
                    paid=paid+ GREATEST(least(ovd, l_amtpaid), least(l_amtpaid, greatest(l_amtpaid-ovd,0),NML))
                where reftype='P' and ACCTNO IN (SELECT LNACCTNO FROM DFGROUP WHERE GROUPID= l_GROUPID );


            plog.debug (pkgctx,' END UPDATE LNSCHD l_INTPAIDMETHOD = ' || l_INTPAIDMETHOD || ', l_intpena:   '|| l_intpena || ', l_feepena:  ' || l_feepena);

            if instr('I/P', l_INTPAIDMETHOD ) > 0 then
                plog.debug (pkgctx,' ADD 1');

              SELECT (case when INTOVDPRIN>0 then least((l_intpaid - l_intpena),INTOVDPRIN) else 0 end), (CASE WHEN INTOVD > 0 THEN least(l_intpaid - l_intpena - INTOVDPRIN,INTOVD) ELSE 0 END ),
                           (CASE WHEN INTDUE > 0 THEN least(l_intpaid - l_intpena - INTOVDPRIN - INTOVD, INTDUE) ELSE 0 END ), (CASE WHEN INTNMLACR > 0 THEN least(l_intpaid - l_intpena - INTOVDPRIN - INTOVD - INTDUE, INTNMLACR ) ELSE 0 END ),
                           (CASE WHEN FEEINTNMLOVD > 0 THEN least(l_feepaid - l_feepena,FEEINTNMLOVD ) ELSE 0 END ),(CASE WHEN FEEINTOVDACR > 0 THEN least(l_feepaid - l_feepena - FEEINTNMLOVD, FEEINTOVDACR ) ELSE 0 END ),
                           (CASE WHEN FEEDUE > 0 THEN least(l_feepaid - l_feepena - FEEINTNMLOVD - FEEINTOVDACR,FEEDUE ) ELSE 0 END ),(CASE WHEN FEEINTNMLACR > 0 THEN least(l_feepaid - l_feepena - FEEINTNMLOVD - FEEINTOVDACR - FEEDUE, FEEINTNMLACR ) ELSE 0 END )
                    INTO  v_INTOVDPRIN, v_INTOVD, v_INTDUE, v_INTNMLACR, v_FEEINTNMLOVD, v_FEEINTOVDACR, v_FEEDUE, v_FEEINTNMLACR
                    FROM LNSCHD
                        WHERE reftype='P' and ACCTNO IN (SELECT LNACCTNO FROM DFGROUP WHERE GROUPID= l_GROUPID );

                    -- INSERT VAO LNSCHDLOG
                    UPDATE LNSCHDLOG SET INTOVDPRIN = - v_INTOVDPRIN , INTOVD= -  v_INTOVD,
                        INTDUE= - v_INTDUE, INTNMLACR= - v_INTNMLACR, INTPAID= l_intpaid,
                        FEEINTOVD =  -  v_FEEINTOVDACR,
                        FEEDUE =  - v_FEEDUE, FEEINTNMLACR =  - v_FEEINTNMLACR,
                        feeintpaid =  l_feepaid
                        WHERE (AUTOID, TXNUM, TXDATE) = (SELECT AUTOID, p_txmsg.txnum,TO_DATE(p_txmsg.txdate,'DD/MM/RRRR')
                    FROM LNSCHD  where reftype='P' and ACCTNO IN (SELECT LNACCTNO FROM DFGROUP WHERE GROUPID= l_GROUPID ) );

              update lnschd set
                    OVD= OVD -  (CASE WHEN INTOVD > 0 THEN least(l_intpaid - l_intpena - INTOVDPRIN,INTOVD) ELSE 0 END ),
                    NML= NML - (CASE WHEN INTDUE > 0 THEN least(l_intpaid - l_intpena - INTOVDPRIN - INTOVD, INTDUE) ELSE 0 END ),
                    PAID = PAID + (CASE WHEN INTDUE > 0 THEN least(l_intpaid - l_intpena - INTOVDPRIN - INTOVD, INTDUE) ELSE 0 END )
              where reftype='I' and ACCTNO IN (SELECT LNACCTNO FROM DFGROUP WHERE GROUPID= l_GROUPID );

                update lnschd set INTOVDPRIN = INTOVDPRIN - (case when INTOVDPRIN>0 then least((l_intpaid - l_intpena),INTOVDPRIN) else 0 end) ,
                    INTOVD=INTOVD -  (CASE WHEN INTOVD > 0 THEN least(l_intpaid - l_intpena - INTOVDPRIN,INTOVD) ELSE 0 END ),
                    INTDUE=INTDUE- (CASE WHEN INTDUE > 0 THEN least(l_intpaid - l_intpena - INTOVDPRIN - INTOVD, INTDUE) ELSE 0 END ),
                    INTNMLACR=INTNMLACR- (CASE WHEN INTNMLACR > 0 THEN least(l_intpaid - l_intpena - INTOVDPRIN - INTOVD - INTDUE, INTNMLACR ) ELSE 0 END ),
                    INTPAID=INTPAID + l_intpaid,
                    FEEINTNMLOVD = FEEINTNMLOVD - (CASE WHEN FEEINTNMLOVD > 0 THEN least(l_feepaid - l_feepena,FEEINTNMLOVD ) ELSE 0 END ),
                    FEEINTOVDACR = FEEINTOVDACR -  (CASE WHEN FEEINTOVDACR > 0 THEN least(l_feepaid - l_feepena - FEEINTNMLOVD, FEEINTOVDACR ) ELSE 0 END ),
                    FEEDUE = FEEDUE - (CASE WHEN FEEDUE > 0 THEN least(l_feepaid - l_feepena - FEEINTNMLOVD - FEEINTOVDACR,FEEDUE ) ELSE 0 END ),
                    FEEINTNMLACR = FEEINTNMLACR - (CASE WHEN FEEINTNMLACR > 0 THEN least(l_feepaid - l_feepena - FEEINTNMLOVD - FEEINTOVDACR - FEEDUE, FEEINTNMLACR ) ELSE 0 END ),
                    feeintpaid =  feeintpaid + l_feepaid
                where reftype='P' and ACCTNO IN (SELECT LNACCTNO FROM DFGROUP WHERE GROUPID= l_GROUPID );

            else
                if round(l_AMTPAID,0) < round(l_nTemp) then
                    plog.debug (pkgctx,'l_INTPAIDMETHOD = L, l_intpena:   '|| l_intpena || ', l_feepena:  ' || l_feepena);

                         SELECT TO_DATE (varvalue, systemnums.c_date_format)
                        INTO v_strCURRDATE
                        FROM sysvar
                        WHERE grname = 'SYSTEM' AND varname = 'CURRDATE';

                        select TO_DATE (rlsdate, systemnums.c_date_format) into v_strRLSDATE from lnschd   where reftype='P' and ACCTNO IN (SELECT LNACCTNO FROM DFGROUP WHERE GROUPID= l_GROUPID );

                        if v_strCURRDATE = v_strRLSDATE then
                              -- INSERT VAO LNSCHDLOG
                             UPDATE LNSCHDLOG SET INTNMLACR = l_intpena, FEEINTNMLACR = l_feepena
                                WHERE (AUTOID, TXNUM, TXDATE) = (SELECT AUTOID, p_txmsg.txnum,TO_DATE(p_txmsg.txdate,'DD/MM/RRRR')
                                    FROM LNSCHD  where reftype='P' and ACCTNO IN (SELECT LNACCTNO FROM DFGROUP WHERE GROUPID= l_GROUPID ) );

                             --update lnschd set INTNMLACR = INTNMLACR + l_intpena, FEEINTNMLACR = FEEINTNMLACR + l_feepena where reftype='P' and ACCTNO IN (SELECT LNACCTNO FROM DFGROUP WHERE GROUPID= l_GROUPID );

                        else


                            select (CASE WHEN INTNMLACR>0 THEN l_intpena ELSE 0 END), (CASE WHEN INTDUE>0 THEN l_intpena ELSE 0 END),
                                   (CASE WHEN FEEINTNMLACR>0 THEN l_feepena ELSE 0 END), (CASE WHEN feedue>0 THEN l_feepena ELSE 0 END)
                            into v_INTNMLACR, v_INTDUE, v_FEEINTNMLACR, v_feedue
                            from lnschd where reftype='P' and ACCTNO IN (SELECT LNACCTNO FROM DFGROUP WHERE GROUPID= l_GROUPID );

                          -- INSERT VAO LNSCHDLOG
                             UPDATE LNSCHDLOG SET INTNMLACR = v_INTNMLACR, INTDUE =  v_INTDUE,
                                 FEEINTNMLACR = v_FEEINTNMLACR, feedue = v_feedue
                                WHERE (AUTOID, TXNUM, TXDATE) = (SELECT AUTOID, p_txmsg.txnum,TO_DATE(p_txmsg.txdate,'DD/MM/RRRR')
                                FROM LNSCHD  where reftype='P' and ACCTNO IN (SELECT LNACCTNO FROM DFGROUP WHERE GROUPID= l_GROUPID ) );
*/
                            /* --HaiLT bo doan nay
                             update lnschd set INTNMLACR = INTNMLACR + (CASE WHEN INTNMLACR>0 THEN l_intpena ELSE 0 END),
                                 INTDUE =  INTDUE + (CASE WHEN INTDUE>0 THEN l_intpena ELSE 0 END),
                                 FEEINTNMLACR = FEEINTNMLACR +  (CASE WHEN FEEINTNMLACR>0 THEN l_feepena ELSE 0 END),
                                 feedue = feedue + (CASE WHEN feedue>0 THEN l_feepena ELSE 0 END)
                             where reftype='P' and ACCTNO IN (SELECT LNACCTNO FROM DFGROUP WHERE GROUPID= l_GROUPID );
                            */
/*
                        end if;

                else
                    plog.debug (pkgctx,' ADD 2');
                        --UPDATE LNSCHDLOG
                        UPDATE LNSCHDLOG SET INTOVDPRIN = 0 ,
                            INTOVD= 0, INTDUE=0,INTNMLACR=0,INTPAID= l_intpaid,
                            FEEDUE =0,
                            FEEINTNMLACR =0, feeintpaid= l_feepaid
                        WHERE (AUTOID, TXNUM, TXDATE) = (SELECT AUTOID, p_txmsg.txnum,TO_DATE(p_txmsg.txdate,'DD/MM/RRRR')
                                    FROM LNSCHD  where reftype='P' and ACCTNO IN (SELECT LNACCTNO FROM DFGROUP WHERE GROUPID= l_GROUPID ) );

                        update lnschd set INTOVDPRIN = 0 ,
                            INTOVD= 0, INTDUE=0,INTNMLACR=0,INTPAID=INTPAID + l_intpaid,
                            FEEINTNMLOVD = 0, FEEINTOVDACR = 0, FEEDUE =0,
                            FEEINTNMLACR =0, feeintpaid=feeintpaid+l_feepaid
                        where reftype='P' and ACCTNO IN (SELECT LNACCTNO FROM DFGROUP WHERE GROUPID= l_GROUPID );


                end if;
            end if;


            SELECT acctno, nvl(paid,0) paid, nvl(nml,0) nml, nvl(ovd,0) ovd, nvl(intnmlacr,0) intnmlacr,
                nvl(INTOVDPRIN,0) INTOVDPRIN, nvl(intovd,0) intovd, nvl(intdue,0) intdue, nvl(intpaid,0) intpaid,nvl(FEEINTNMLOVD,0) FEEINTNMLOVD,
                nvl(FEEINTOVDACR,0) FEEINTOVDACR , nvl(FEEINTNMLACR,0) FEEINTNMLACR, nvl(FEEDUE,0) FEEDUE, nvl(feeintpaid,0) feeintpaid
            into v_LNACCTNO,v_paid, v_nml, v_ovd, v_intnmlacr, v_INTOVDPRIN, v_intovd, v_intdue, v_intpaid, v_FEEINTNMLOVD, v_FEEINTOVDACR, v_FEEINTNMLACR, v_FEEDUE, v_feeintpaid
            FROM LNSCHD WHERE ACCTNO IN (SELECT LNACCTNO FROM DFGROUP WHERE GROUPID= l_GROUPID ) AND REFTYPE='P' ;


            INSERT INTO LNTRAN (AUTOID,TXNUM,TXDATE,ACCTNO,TXCD,NAMT,CAMT,REF,DELTD,ACCTREF,TLTXCD,BKDATE,TRDESC)
            VALUES(SEQ_LNTRAN.NEXTVAL,p_txmsg.txnum,TO_DATE(p_txmsg.txdate,'DD/MM/RRRR'),v_LNACCTNO,'0014',v_paid,NULL,l_AFACCTNO,'N',l_AFACCTNO,'2646',TO_DATE(p_txmsg.txdate,'DD/MM/RRRR'),NULL);

            INSERT INTO LNTRAN (AUTOID,TXNUM,TXDATE,ACCTNO,TXCD,NAMT,CAMT,REF,DELTD,ACCTREF,TLTXCD,BKDATE,TRDESC)
            VALUES(SEQ_LNTRAN.NEXTVAL,p_txmsg.txnum,TO_DATE(p_txmsg.txdate,'DD/MM/RRRR'),v_LNACCTNO,'0015',v_nml,NULL,l_AFACCTNO,'N',l_AFACCTNO,'2646',TO_DATE(p_txmsg.txdate,'DD/MM/RRRR'),NULL);

            INSERT INTO LNTRAN (AUTOID,TXNUM,TXDATE,ACCTNO,TXCD,NAMT,CAMT,REF,DELTD,ACCTREF,TLTXCD,BKDATE,TRDESC)
            VALUES(SEQ_LNTRAN.NEXTVAL,p_txmsg.txnum,TO_DATE(p_txmsg.txdate,'DD/MM/RRRR'),v_LNACCTNO,'0017',v_ovd,NULL,l_AFACCTNO,'N',l_AFACCTNO,'2646',TO_DATE(p_txmsg.txdate,'DD/MM/RRRR'),NULL);

            INSERT INTO LNTRAN (AUTOID,TXNUM,TXDATE,ACCTNO,TXCD,NAMT,CAMT,REF,DELTD,ACCTREF,TLTXCD,BKDATE,TRDESC)
            VALUES(SEQ_LNTRAN.NEXTVAL,p_txmsg.txnum,TO_DATE(p_txmsg.txdate,'DD/MM/RRRR'),v_LNACCTNO,'0042',v_intnmlacr,NULL,l_AFACCTNO,'N',l_AFACCTNO,'2646',TO_DATE(p_txmsg.txdate,'DD/MM/RRRR'),NULL);

            INSERT INTO LNTRAN (AUTOID,TXNUM,TXDATE,ACCTNO,TXCD,NAMT,CAMT,REF,DELTD,ACCTREF,TLTXCD,BKDATE,TRDESC)
            VALUES(SEQ_LNTRAN.NEXTVAL,p_txmsg.txnum,TO_DATE(p_txmsg.txdate,'DD/MM/RRRR'),v_LNACCTNO,'0043',v_INTOVDPRIN,NULL,l_AFACCTNO,'N',l_AFACCTNO,'2646',TO_DATE(p_txmsg.txdate,'DD/MM/RRRR'),NULL);

            INSERT INTO LNTRAN (AUTOID,TXNUM,TXDATE,ACCTNO,TXCD,NAMT,CAMT,REF,DELTD,ACCTREF,TLTXCD,BKDATE,TRDESC)
            VALUES(SEQ_LNTRAN.NEXTVAL,p_txmsg.txnum,TO_DATE(p_txmsg.txdate,'DD/MM/RRRR'),v_LNACCTNO,'0027',v_intovd,NULL,l_AFACCTNO,'N',l_AFACCTNO,'2646',TO_DATE(p_txmsg.txdate,'DD/MM/RRRR'),NULL);

            INSERT INTO LNTRAN (AUTOID,TXNUM,TXDATE,ACCTNO,TXCD,NAMT,CAMT,REF,DELTD,ACCTREF,TLTXCD,BKDATE,TRDESC)
            VALUES(SEQ_LNTRAN.NEXTVAL,p_txmsg.txnum,TO_DATE(p_txmsg.txdate,'DD/MM/RRRR'),v_LNACCTNO,'0025',v_intdue,NULL,l_AFACCTNO,'N',l_AFACCTNO,'2646',TO_DATE(p_txmsg.txdate,'DD/MM/RRRR'),NULL);

            INSERT INTO LNTRAN (AUTOID,TXNUM,TXDATE,ACCTNO,TXCD,NAMT,CAMT,REF,DELTD,ACCTREF,TLTXCD,BKDATE,TRDESC)
            VALUES(SEQ_LNTRAN.NEXTVAL,p_txmsg.txnum,TO_DATE(p_txmsg.txdate,'DD/MM/RRRR'),v_LNACCTNO,'0023',v_intpaid,NULL,l_AFACCTNO,'N',l_AFACCTNO,'2646',TO_DATE(p_txmsg.txdate,'DD/MM/RRRR'),NULL);

            INSERT INTO LNTRAN (AUTOID,TXNUM,TXDATE,ACCTNO,TXCD,NAMT,CAMT,REF,DELTD,ACCTREF,TLTXCD,BKDATE,TRDESC)
            VALUES(SEQ_LNTRAN.NEXTVAL,p_txmsg.txnum,TO_DATE(p_txmsg.txdate,'DD/MM/RRRR'),v_LNACCTNO,'0083',v_FEEINTNMLOVD,NULL,l_AFACCTNO,'N',l_AFACCTNO,'2646',TO_DATE(p_txmsg.txdate,'DD/MM/RRRR'),NULL);

            INSERT INTO LNTRAN (AUTOID,TXNUM,TXDATE,ACCTNO,TXCD,NAMT,CAMT,REF,DELTD,ACCTREF,TLTXCD,BKDATE,TRDESC)
            VALUES(SEQ_LNTRAN.NEXTVAL,p_txmsg.txnum,TO_DATE(p_txmsg.txdate,'DD/MM/RRRR'),v_LNACCTNO,'0085',v_FEEINTOVDACR,NULL,l_AFACCTNO,'N',l_AFACCTNO,'2646',TO_DATE(p_txmsg.txdate,'DD/MM/RRRR'),NULL);

            INSERT INTO LNTRAN (AUTOID,TXNUM,TXDATE,ACCTNO,TXCD,NAMT,CAMT,REF,DELTD,ACCTREF,TLTXCD,BKDATE,TRDESC)
            VALUES(SEQ_LNTRAN.NEXTVAL,p_txmsg.txnum,TO_DATE(p_txmsg.txdate,'DD/MM/RRRR'),v_LNACCTNO,'0078',v_FEEINTNMLACR,NULL,l_AFACCTNO,'N',l_AFACCTNO,'2646',TO_DATE(p_txmsg.txdate,'DD/MM/RRRR'),NULL);

            INSERT INTO LNTRAN (AUTOID,TXNUM,TXDATE,ACCTNO,TXCD,NAMT,CAMT,REF,DELTD,ACCTREF,TLTXCD,BKDATE,TRDESC)
            VALUES(SEQ_LNTRAN.NEXTVAL,p_txmsg.txnum,TO_DATE(p_txmsg.txdate,'DD/MM/RRRR'),v_LNACCTNO,'0081',v_FEEDUE,NULL,l_AFACCTNO,'N',l_AFACCTNO,'2646',TO_DATE(p_txmsg.txdate,'DD/MM/RRRR'),NULL);

            INSERT INTO LNTRAN (AUTOID,TXNUM,TXDATE,ACCTNO,TXCD,NAMT,CAMT,REF,DELTD,ACCTREF,TLTXCD,BKDATE,TRDESC)
            VALUES(SEQ_LNTRAN.NEXTVAL,p_txmsg.txnum,TO_DATE(p_txmsg.txdate,'DD/MM/RRRR'),v_LNACCTNO,'0089',v_feeintpaid,NULL,l_AFACCTNO,'N',l_AFACCTNO,'2646',TO_DATE(p_txmsg.txdate,'DD/MM/RRRR'),NULL);

           plog.debug (pkgctx,' UPDATE LNMAST ' || l_GROUPID);
            UPDATE LNMAST SET (prinpaid, prinnml, prinovd, intnmlacr, intovdacr, intnmlovd, intdue, intpaid, feeintnmlovd, feeintovdacr,
                feeintnmlacr, feeintdue, feeintpaid) = (SELECT nvl(paid,0) paid, nvl(nml,0) nml, nvl(ovd,0) ovd, nvl(intnmlacr,0) intnmlacr,
                nvl(INTOVDPRIN,0) INTOVDPRIN, nvl(intovd,0) intovd, nvl(intdue,0) intdue, nvl(intpaid,0) intpaid,nvl(FEEINTNMLOVD,0) FEEINTNMLOVD,
                nvl(FEEINTOVDACR,0) FEEINTOVDACR , nvl(FEEINTNMLACR,0) FEEINTOVDACR, nvl(FEEDUE,0) FEEINTOVDACR, nvl(feeintpaid,0) FEEINTOVDACR FROM LNSCHD WHERE LNMAST.ACCTNO=LNSCHD.ACCTNO AND LNSCHD.REFTYPE='P' ) WHERE LNMAST.ACCTNO IN
                    (SELECT LNACCTNO FROM DFGROUP WHERE GROUPID= l_GROUPID );

*/

        end if;

        v_dblCARCVQTTY:=0;
        v_dblRCVQTTY:=0;
        v_dblAVLQTTY:=0;
        v_dblBLOCKQTTY:=0;
        v_dblCACASHQTTY:=0;

        if l_DEALTYPE='N' then
            v_dblAVLQTTY:=l_ReleaseQTTY;
        end if;
        if l_DEALTYPE='T' then
            v_dblCACASHQTTY:=l_ReleaseQTTY;
        end if;
        if l_DEALTYPE='B' then
            v_dblBLOCKQTTY:=l_ReleaseQTTY;
        end if;
        if l_DEALTYPE='R' then
            v_dblRCVQTTY:=l_ReleaseQTTY;
        end if;
        if l_DEALTYPE='P' then
            v_dblCARCVQTTY:=l_ReleaseQTTY;
        end if;

        SELECT CASE WHEN l_DEALTYPE = 'N' THEN DFQTTY
                    WHEN l_DEALTYPE = 'T' THEN CACASHQTTY
                    WHEN l_DEALTYPE = 'P' THEN CARCVQTTY
                    WHEN l_DEALTYPE = 'R' THEN RCVQTTY
                    WHEN l_DEALTYPE = 'B' THEN BLOCKQTTY  END INTO l_EXECQTTY_T  FROM DFMAST WHERE ACCTNO = l_DFACCTNO;

        if l_EXECQTTY_T <  l_ReleaseQTTY then
            p_err_code:= -400445;
            ROLLBACK;
            return;
        END IF;


        UPDATE DFMAST
           SET
             BLOCKQTTY = BLOCKQTTY - v_dblBLOCKQTTY,
             CARCVQTTY = CARCVQTTY - v_dblCARCVQTTY,
             RCVQTTY = RCVQTTY - v_dblRCVQTTY,
             DFQTTY = DFQTTY - v_dblAVLQTTY,
             CACASHQTTY=CACASHQTTY- v_dblCACASHQTTY,
             INITASSETQTTY = INITASSETQTTY - l_INITQTTY,
             ADDASSETQTTY = ADDASSETQTTY - l_ADDQTTY,
             RLSQTTY = RLSQTTY + l_ReleaseQTTY,
             LAST_CHANGE = SYSTIMESTAMP
          WHERE ACCTNO=l_DFACCTNO;

        IF p_txmsg.deltd <> 'Y' THEN -- normal transactions
            UPDATE securities_info
            SET SYROOMUSED=NVL(SYROOMUSED,0)- l_ReleaseQTTY
            WHERE CODEID= l_codeid;
        ELSE -- reverse transactions
            UPDATE securities_info
            SET SYROOMUSED=NVL(SYROOMUSED,0)+ l_ReleaseQTTY
            WHERE CODEID= l_codeid;
        END IF;

        INSERT INTO DFTRAN(TXNUM,TXDATE,ACCTNO,TXCD,NAMT,CAMT,ACCTREF,DELTD,REF,AUTOID,TLTXCD,BKDATE,TRDESC)
        VALUES (p_txmsg.txnum, TO_DATE (p_txmsg.txdate, systemnums.C_DATE_FORMAT),l_DFACCTNO,'0043',v_dblBLOCKQTTY,NULL,l_AFACCTNO,p_txmsg.deltd,l_AFACCTNO,seq_DFTRAN.NEXTVAL,p_txmsg.tltxcd,p_txmsg.busdate,'' || '' || '');

        INSERT INTO DFTRAN(TXNUM,TXDATE,ACCTNO,TXCD,NAMT,CAMT,ACCTREF,DELTD,REF,AUTOID,TLTXCD,BKDATE,TRDESC)
        VALUES (p_txmsg.txnum, TO_DATE (p_txmsg.txdate, systemnums.C_DATE_FORMAT),l_DFACCTNO,'0045',v_dblCARCVQTTY,NULL,l_AFACCTNO,p_txmsg.deltd,l_AFACCTNO,seq_DFTRAN.NEXTVAL,p_txmsg.tltxcd,p_txmsg.busdate,'' || '' || '');

        INSERT INTO DFTRAN(TXNUM,TXDATE,ACCTNO,TXCD,NAMT,CAMT,ACCTREF,DELTD,REF,AUTOID,TLTXCD,BKDATE,TRDESC)
        VALUES (p_txmsg.txnum, TO_DATE (p_txmsg.txdate, systemnums.C_DATE_FORMAT),l_DFACCTNO,'0087',v_dblCACASHQTTY,NULL,l_AFACCTNO,p_txmsg.deltd,l_AFACCTNO,seq_DFTRAN.NEXTVAL,p_txmsg.tltxcd,p_txmsg.busdate,'' || '' || '');

        INSERT INTO DFTRAN(TXNUM,TXDATE,ACCTNO,TXCD,NAMT,CAMT,ACCTREF,DELTD,REF,AUTOID,TLTXCD,BKDATE,TRDESC)
        VALUES (p_txmsg.txnum, TO_DATE (p_txmsg.txdate, systemnums.C_DATE_FORMAT),l_DFACCTNO,'0041',v_dblRCVQTTY,NULL,l_AFACCTNO,p_txmsg.deltd,l_AFACCTNO,seq_DFTRAN.NEXTVAL,p_txmsg.tltxcd,p_txmsg.busdate,'' || '' || '');

        INSERT INTO DFTRAN(TXNUM,TXDATE,ACCTNO,TXCD,NAMT,CAMT,ACCTREF,DELTD,REF,AUTOID,TLTXCD,BKDATE,TRDESC)
        VALUES (p_txmsg.txnum, TO_DATE (p_txmsg.txdate, systemnums.C_DATE_FORMAT),l_DFACCTNO,'0011',v_dblAVLQTTY,NULL,l_AFACCTNO,p_txmsg.deltd,l_AFACCTNO,seq_DFTRAN.NEXTVAL,p_txmsg.tltxcd,p_txmsg.busdate,'' || '' || '');

        INSERT INTO DFTRAN(TXNUM,TXDATE,ACCTNO,TXCD,NAMT,CAMT,ACCTREF,DELTD,REF,AUTOID,TLTXCD,BKDATE,TRDESC)
        VALUES (p_txmsg.txnum, TO_DATE (p_txmsg.txdate, systemnums.C_DATE_FORMAT),l_DFACCTNO,'0016',v_dblCACASHQTTY,NULL,l_AFACCTNO,p_txmsg.deltd,l_AFACCTNO,seq_DFTRAN.NEXTVAL,p_txmsg.tltxcd,p_txmsg.busdate,'' || '' || '');

        INSERT INTO DFTRAN(TXNUM,TXDATE,ACCTNO,TXCD,NAMT,CAMT,ACCTREF,DELTD,REF,AUTOID,TLTXCD,BKDATE,TRDESC)
        VALUES (p_txmsg.txnum, TO_DATE (p_txmsg.txdate, systemnums.C_DATE_FORMAT),l_DFACCTNO,'0057',l_INITQTTY,NULL,l_AFACCTNO,p_txmsg.deltd,l_AFACCTNO,seq_DFTRAN.NEXTVAL,p_txmsg.tltxcd,p_txmsg.busdate,'' || '' || '');

        INSERT INTO DFTRAN(TXNUM,TXDATE,ACCTNO,TXCD,NAMT,CAMT,ACCTREF,DELTD,REF,AUTOID,TLTXCD,BKDATE,TRDESC)
        VALUES (p_txmsg.txnum, TO_DATE (p_txmsg.txdate, systemnums.C_DATE_FORMAT),l_DFACCTNO,'0095',l_ADDQTTY,NULL,l_AFACCTNO,p_txmsg.deltd,l_AFACCTNO,seq_DFTRAN.NEXTVAL,p_txmsg.tltxcd,p_txmsg.busdate,'' || '' || '');



         SELECT DFREF INTO l_DFREF FROM DFMAST WHERE ACCTNO= L_DFACCTNO;

         IF  l_DEALTYPE = 'T' THEN

               INSERT INTO CITRAN (TXNUM,TXDATE,ACCTNO,TXCD,NAMT,CAMT,REF,DELTD,ACCTREF,AUTOID,TLTXCD,BKDATE,TRDESC)
               VALUES(p_txmsg.txnum,TO_DATE(p_txmsg.txdate,'DD/MM/RRRR'),l_AFACCTNO,'0046',l_ORGAMT,NULL,NULL,'N',NULL,SEQ_CITRAN.NEXTVAL,'2646',TO_DATE(p_txmsg.txdate,'DD/MM/RRRR'),NULL);

               UPDATE caschd set dfamt= dfamt - (ROUND(l_ReleaseQTTY,0)) where autoid=l_DFREF;
               UPDATE CIMAST set receiving= receiving + (ROUND(l_ReleaseQTTY,0)) where ACCTNO=l_AFACCTNO;

         END IF;

         if l_DEALTYPE = 'P' THEN
               UPDATE caschd set dfqtty= dfqtty - ROUND(l_ReleaseQTTY,0) where autoid=l_DFREF;
         elsif l_DEALTYPE = 'R' then

                 --- Chung khoan cho ve
                v_dblRemainRCVQTTY:= v_dblRCVQTTY;
                v_dblExecRCVQTTY:=0;
                v_dblReleaseAMT:=0;
                FOR rec_rcvdf IN
                (
                SELECT * FROM stschd WHERE (to_char(txdate,'DD/MM/YYYY') || afacctno || codeid || to_char(clearday)) = l_DFREF
                and duetype ='RS' and status <> 'C' AND deltd <> 'Y'
                order BY autoid
                )
                LOOP
                    v_dblExecRCVQTTY:= least(v_dblRemainRCVQTTY, rec_rcvdf.AQTTY);
                    update odmast set dfqtty = dfqtty - v_dblExecRCVQTTY where orderid = rec_rcvdf.ORGORDERID;
                    update stschd set aqtty = aqtty - v_dblExecRCVQTTY where autoid = rec_rcvdf.autoid;
                    v_dblRemainRCVQTTY:= v_dblRemainRCVQTTY - v_dblExecRCVQTTY;
                    If v_dblRemainRCVQTTY = 0 Then
                        EXIT;
                    End IF;
                END LOOP;

         else

               INSERT INTO SETRAN(TXNUM,TXDATE,ACCTNO,TXCD,NAMT,CAMT,ACCTREF,DELTD,REF,AUTOID,TLTXCD,BKDATE,TRDESC)
               VALUES (p_txmsg.txnum, TO_DATE (p_txmsg.txdate, systemnums.C_DATE_FORMAT),l_AFACCTNO||l_CODEID,'0043',v_dblBLOCKQTTY,NULL,l_DFACCTNO,p_txmsg.deltd,l_DFACCTNO,seq_SETRAN.NEXTVAL,p_txmsg.tltxcd,p_txmsg.busdate,'' || '' || '');

               INSERT INTO SETRAN(TXNUM,TXDATE,ACCTNO,TXCD,NAMT,CAMT,ACCTREF,DELTD,REF,AUTOID,TLTXCD,BKDATE,TRDESC)
               VALUES (p_txmsg.txnum, TO_DATE (p_txmsg.txdate, systemnums.C_DATE_FORMAT),l_AFACCTNO||l_CODEID,'0012',v_dblAVLQTTY,NULL,l_DFACCTNO,p_txmsg.deltd,l_DFACCTNO,seq_SETRAN.NEXTVAL,p_txmsg.tltxcd,p_txmsg.busdate,'' || '' || '');

               INSERT INTO SETRAN(TXNUM,TXDATE,ACCTNO,TXCD,NAMT,CAMT,ACCTREF,DELTD,REF,AUTOID,TLTXCD,BKDATE,TRDESC)
               VALUES (p_txmsg.txnum, TO_DATE (p_txmsg.txdate, systemnums.C_DATE_FORMAT),l_AFACCTNO||l_CODEID,'0066',v_dblAVLQTTY+v_dblBLOCKQTTY,NULL,l_DFACCTNO,p_txmsg.deltd,l_DFACCTNO,seq_SETRAN.NEXTVAL,p_txmsg.tltxcd,p_txmsg.busdate,'' || '' || '');

               UPDATE SEMAST SET
                   BLOCKED = BLOCKED + v_dblBLOCKQTTY,
                   TRADE = TRADE + v_dblAVLQTTY,
                   MORTAGE = MORTAGE - (v_dblAVLQTTY+v_dblBLOCKQTTY), LAST_CHANGE = SYSTIMESTAMP
               WHERE ACCTNO=l_AFACCTNO||l_CODEID;

               select ISVSD into v_isvsd from dftype where actype in (select actype from dfmast where acctno like l_DFACCTNO);
               if v_isvsd = 'Y' then
                   UPDATE SEMAST SET STANDING = STANDING + (v_dblAVLQTTY+v_dblBLOCKQTTY) WHERE ACCTNO=l_AFACCTNO||l_CODEID;
                   INSERT INTO SETRAN(TXNUM,TXDATE,ACCTNO,TXCD,NAMT,CAMT,ACCTREF,DELTD,REF,AUTOID,TLTXCD,BKDATE,TRDESC)
                   VALUES (p_txmsg.txnum, TO_DATE (p_txmsg.txdate, systemnums.C_DATE_FORMAT),l_AFACCTNO||l_CODEID,'0014',v_dblAVLQTTY+v_dblBLOCKQTTY,NULL,l_DFACCTNO,p_txmsg.deltd,l_DFACCTNO,seq_SETRAN.NEXTVAL,p_txmsg.tltxcd,p_txmsg.busdate,'' || '' || '');
               end if;

         end if;

        V_STRXML:= substr(V_STRXML,instr(V_STRXML,'@',1,1)+1);

    end loop;

    p_err_code:=0;
    plog.setendsection(pkgctx, 'pr_AddCIToReleaseSecu');
EXCEPTION
    WHEN OTHERS
    THEN
      plog.debug (pkgctx,'got error on pr_AddCIToReleaseSecu');
      ROLLBACK;
      p_err_code := errnums.C_SYSTEM_ERROR;
      plog.error (pkgctx, SQLERRM);
      plog.debug(pkgctx,'pr_AddCIToReleaseSecu: ' || dbms_utility.format_error_backtrace);
      plog.setendsection (pkgctx, 'pr_AddCIToReleaseSecu');
      RAISE errnums.E_SYSTEM_ERROR;
END pr_AddCIToReleaseSecu;




---------------------------------pr_DFPaidDeal------------------------------------------------
  PROCEDURE pr_DFPaidDeal(p_txmsg in tx.msg_rectype, l_GROUPID varchar,l_amtpaid number, l_intpaid number, l_feepaid number, l_intpena number, l_feepena number, p_err_code  OUT varchar2)
  IS
    l_txmsg               tx.msg_rectype;
    v_strCURRDATE varchar2(20);
    l_INTPAIDMETHOD varchar2(1);
    l_nTemp number;
    v_paid number;
    v_nml NUMBER;
    v_ovd NUMBER;
    v_intnmlacr NUMBER;
    v_INTOVDPRIN  NUMBER;
    v_intovd  NUMBER;
    v_intdue  NUMBER;
    v_intpaid NUMBER;
    v_FEEINTNMLOVD NUMBER;
    v_FEEINTOVDACR NUMBER;
    v_FEEINTNMLACR NUMBER;
    v_FEEDUE NUMBER;
    v_feeintpaid NUMBER;
    v_LNACCTNO varchar2(20);
    v_strRLSDATE date;
    l_AFACCTNO varchar2(20);
    v_REMAINLNAMT   NUMBER;

  BEGIN
    plog.setbeginsection(pkgctx, 'pr_DFPaidDeal');

    v_paid:=0;
    v_nml:=0;
    v_ovd :=0;
    v_intnmlacr :=0;
    v_INTOVDPRIN  :=0;
    v_intovd  :=0;
    v_intdue  :=0;
    v_intpaid :=0;
    v_FEEINTNMLOVD :=0;
    v_FEEINTOVDACR :=0;
    v_FEEINTNMLACR :=0;
    v_FEEDUE :=0;
    v_feeintpaid :=0;

    update citran set ref = l_groupid where txnum = p_txmsg.txnum;

    SELECT INTPAIDMETHOD into l_INTPAIDMETHOD from lnmast where ACCTNO IN (SELECT LNACCTNO FROM DFGROUP WHERE GROUPID= l_GROUPID );

    select ovd+nml into l_nTemp from lnschd where reftype='P' and ACCTNO IN (SELECT LNACCTNO FROM DFGROUP WHERE GROUPID= l_GROUPID );

    ---- UPDATE LNSCHD VA LNMAST

   /* INSERT INTO LNSCHDLOG (AUTOID, TXNUM, TXDATE, OVD, NML, PAID)
        SELECT AUTOID, p_txmsg.txnum, TO_DATE(p_txmsg.txdate,'DD/MM/RRRR'), -least(ovd, l_amtpaid), -least(l_amtpaid, greatest(l_amtpaid-ovd,0),NML),
            - GREATEST(least(ovd, l_amtpaid), least(l_amtpaid, greatest(l_amtpaid-ovd,0),NML)) from lnschd
            where reftype='P' and ACCTNO IN (SELECT LNACCTNO FROM DFGROUP WHERE GROUPID= l_GROUPID );
*/
     -- PhuongHT edit
     INSERT INTO LNSCHDLOG (AUTOID, TXNUM, TXDATE, OVD, NML, PAID)
        SELECT AUTOID, p_txmsg.txnum, TO_DATE(p_txmsg.txdate,'DD/MM/RRRR'), -least(ovd, l_amtpaid),
              - greatest(least(nml, l_amtpaid-ovd),0),
              (least(ovd, l_amtpaid)+ greatest(least(nml, l_amtpaid-ovd),0)) from lnschd
            where reftype='P' and ACCTNO IN (SELECT LNACCTNO FROM DFGROUP WHERE GROUPID= l_GROUPID );
     -- end of PhuongHT edit

    select least(ovd, l_amtpaid), greatest(least(nml, l_amtpaid-ovd),0),
            /*GREATEST(least(ovd, l_amtpaid), greatest(least(nml, l_amtpaid-ovd),0))*/
            (least(ovd, l_amtpaid)+ greatest(least(nml, l_amtpaid-ovd),0)), ACCTNO
    into v_ovd, v_nml,v_paid, v_LNACCTNO
    from lnschd
    where reftype='P' and ACCTNO IN (SELECT LNACCTNO FROM DFGROUP WHERE GROUPID= l_GROUPID );

    v_intpaid:=l_intpaid;
    v_feeintpaid:=l_feepaid;

    update lnschd set ovd= ovd - v_ovd, nml=nml-v_nml,
            paid=paid+ v_paid
        where reftype='P' and ACCTNO IN (SELECT LNACCTNO FROM DFGROUP WHERE GROUPID= l_GROUPID );

    plog.debug (pkgctx,' END UPDATE LNSCHD l_INTPAIDMETHOD = ' || l_INTPAIDMETHOD || ', l_intpena:   '|| l_intpena || ', l_feepena:  ' || l_feepena);

    if instr('I/P/F', l_INTPAIDMETHOD ) > 0 then
        plog.debug (pkgctx,' ADD 1');

      SELECT (case when INTOVDPRIN>0 then greatest(least((l_intpaid - l_intpena),INTOVDPRIN),0) else 0 end),
                    (CASE WHEN INTOVD > 0 THEN greatest(least(l_intpaid - l_intpena - INTOVDPRIN,INTOVD),0) ELSE 0 END ),
                   (CASE WHEN INTDUE > 0 THEN greatest(least(l_intpaid - l_intpena - INTOVDPRIN - INTOVD, INTDUE),0) ELSE 0 END ),
                   (CASE WHEN INTNMLACR > 0 THEN greatest(least(l_intpaid - l_intpena - INTOVDPRIN - INTOVD - INTDUE, INTNMLACR ),0) ELSE 0 END ),
                   (CASE WHEN FEEINTOVDACR > 0 THEN greatest(least(l_feepaid - l_feepena, FEEINTOVDACR ),0) ELSE 0 END ),
                   (CASE WHEN FEEINTNMLOVD > 0 THEN greatest(least(l_feepaid - l_feepena - FEEINTOVDACR ,FEEINTNMLOVD ),0) ELSE 0 END ),
                   (CASE WHEN FEEINTDUE > 0 THEN greatest(least(l_feepaid - l_feepena - FEEINTNMLOVD - FEEINTOVDACR,FEEINTDUE ),0) ELSE 0 END ),
                   (CASE WHEN FEEINTNMLACR > 0 THEN greatest(least(l_feepaid - l_feepena - FEEINTNMLOVD - FEEINTOVDACR - FEEINTDUE, FEEINTNMLACR ),0) ELSE 0 END )
            INTO  v_INTOVDPRIN, v_INTOVD, v_INTDUE, v_INTNMLACR, v_FEEINTOVDACR, v_FEEINTNMLOVD, v_FEEDUE, v_FEEINTNMLACR
            FROM LNSCHD
                WHERE reftype='P' and ACCTNO IN (SELECT LNACCTNO FROM DFGROUP WHERE GROUPID= l_GROUPID );

            -- INSERT VAO LNSCHDLOG
            UPDATE LNSCHDLOG SET INTOVDPRIN = - v_INTOVDPRIN , INTOVD= -  v_INTOVD,
                INTDUE= - v_INTDUE, INTNMLACR= - v_INTNMLACR, INTPAID= l_intpaid,
                FEEINTOVD =  -  v_FEEINTOVDACR, FEEINTOVDPRIN= - v_FEEINTNMLOVD, --PhuongHT update them cho truong FEEINTOVDPRIN
                FEEINTDUE =  - v_FEEDUE, FEEINTNMLACR =  - v_FEEINTNMLACR,
                feeintpaid =  l_feepaid
                WHERE (AUTOID, TXNUM, TXDATE) = (SELECT AUTOID, p_txmsg.txnum,TO_DATE(p_txmsg.txdate,'DD/MM/RRRR')
            FROM LNSCHD  where reftype='P' and ACCTNO IN (SELECT LNACCTNO FROM DFGROUP WHERE GROUPID= l_GROUPID ) );

      -- update vao dong I
      update lnschd set
            OVD= OVD -  v_INTOVD,
            NML= NML - v_INTDUE ,
            PAID = PAID + v_INTOVD + v_INTDUE
      where reftype='I' and ACCTNO IN (SELECT LNACCTNO FROM DFGROUP WHERE GROUPID= l_GROUPID );
       -- PhuongHT add lnschdlog cho dong I
        INSERT INTO LNSCHDLOG (AUTOID, TXNUM, TXDATE, OVD, NML, PAID)
        SELECT AUTOID, p_txmsg.txnum, TO_DATE(p_txmsg.txdate,'DD/MM/RRRR'), -v_INTOVD, -v_INTDUE,
                v_INTOVD + v_INTDUE from lnschd
            where reftype='I' and ACCTNO IN (SELECT LNACCTNO FROM DFGROUP WHERE GROUPID= l_GROUPID );
        -- end of PhuongHT add

        update lnschd set INTOVDPRIN = INTOVDPRIN - v_INTOVDPRIN ,
            INTOVD=INTOVD -  v_INTOVD,
            INTDUE=INTDUE- v_INTDUE,
            INTNMLACR=INTNMLACR- v_INTNMLACR,
            INTPAID=INTPAID + l_intpaid,
            FEEINTOVDACR = FEEINTOVDACR -  v_FEEINTOVDACR,
            FEEINTNMLOVD = FEEINTNMLOVD - v_FEEINTNMLOVD,
            FEEINTDUE = FEEINTDUE - v_FEEDUE,
            FEEINTNMLACR = FEEINTNMLACR - v_FEEINTNMLACR,
            feeintpaid =  feeintpaid + l_feepaid
        where reftype='P' and ACCTNO IN (SELECT LNACCTNO FROM DFGROUP WHERE GROUPID= l_GROUPID );
    else
        if round(l_AMTPAID,0) < round(l_nTemp) then
            plog.debug (pkgctx,'l_INTPAIDMETHOD = L, l_intpena:   '|| l_intpena || ', l_feepena:  ' || l_feepena);

                 SELECT TO_DATE (varvalue, systemnums.c_date_format)
                INTO v_strCURRDATE
                FROM sysvar
                WHERE grname = 'SYSTEM' AND varname = 'CURRDATE';

                select TO_DATE (rlsdate, systemnums.c_date_format) into v_strRLSDATE from lnschd   where reftype='P' and ACCTNO IN (SELECT LNACCTNO FROM DFGROUP WHERE GROUPID= l_GROUPID );
                /*
                if v_strCURRDATE = v_strRLSDATE then

                      -- INSERT VAO LNSCHDLOG
                     UPDATE LNSCHDLOG SET INTNMLACR = l_intpena, FEEINTNMLACR = l_feepena
                        WHERE (AUTOID, TXNUM, TXDATE) = (SELECT AUTOID, p_txmsg.txnum,TO_DATE(p_txmsg.txdate,'DD/MM/RRRR')
                            FROM LNSCHD  where reftype='P' and ACCTNO IN (SELECT LNACCTNO FROM DFGROUP WHERE GROUPID= l_GROUPID ) );

                     --update lnschd set INTNMLACR = INTNMLACR + l_intpena, FEEINTNMLACR = FEEINTNMLACR + l_feepena where reftype='P' and ACCTNO IN (SELECT LNACCTNO FROM DFGROUP WHERE GROUPID= l_GROUPID );

                else


                    select (CASE WHEN INTNMLACR>0 THEN l_intpena ELSE 0 END), (CASE WHEN INTDUE>0 THEN l_intpena ELSE 0 END),
                           (CASE WHEN FEEINTNMLACR>0 THEN l_feepena ELSE 0 END), (CASE WHEN FEEINTDUE>0 THEN l_feepena ELSE 0 END)
                    into v_INTNMLACR, v_INTDUE, v_FEEINTNMLACR, v_feedue
                    from lnschd where reftype='P' and ACCTNO IN (SELECT LNACCTNO FROM DFGROUP WHERE GROUPID= l_GROUPID );

                  -- INSERT VAO LNSCHDLOG
                     UPDATE LNSCHDLOG SET INTNMLACR = v_INTNMLACR, INTDUE =  v_INTDUE,
                         FEEINTNMLACR = v_FEEINTNMLACR, FEEINTDUE = v_feedue
                        WHERE (AUTOID, TXNUM, TXDATE) = (SELECT AUTOID, p_txmsg.txnum,TO_DATE(p_txmsg.txdate,'DD/MM/RRRR')
                        FROM LNSCHD  where reftype='P' and ACCTNO IN (SELECT LNACCTNO FROM DFGROUP WHERE GROUPID= l_GROUPID ) );


                    update lnschd set INTNMLACR = INTNMLACR + (CASE WHEN INTNMLACR>0 THEN l_intpena ELSE 0 END),
                         INTDUE =  INTDUE + (CASE WHEN INTDUE>0 THEN l_intpena ELSE 0 END),
                         FEEINTNMLACR = FEEINTNMLACR +  (CASE WHEN FEEINTNMLACR>0 THEN l_feepena ELSE 0 END),
                         FEEINTDUE = FEEINTDUE + (CASE WHEN FEEINTDUE>0 THEN l_feepena ELSE 0 END)
                    where reftype='P' and ACCTNO IN (SELECT LNACCTNO FROM DFGROUP WHERE GROUPID= v_groupid );

                end if;
                 */
        else
            plog.debug (pkgctx,' ADD 2');


                SELECT INTOVDPRIN , INTOVD, INTDUE, INTNMLACR , FEEINTNMLOVD ,FEEINTOVDACR, FEEINTDUE ,FEEINTNMLACR
                    INTO  v_INTOVDPRIN, v_INTOVD, v_INTDUE, v_INTNMLACR, v_FEEINTNMLOVD, v_FEEINTOVDACR, v_FEEDUE, v_FEEINTNMLACR
                FROM LNSCHD
                WHERE reftype='P' and ACCTNO IN (SELECT LNACCTNO FROM DFGROUP WHERE GROUPID= l_GROUPID );

                update lnschd set INTOVDPRIN = 0  ,
                    INTOVD= 0, INTDUE=0,INTNMLACR=0,INTPAID=INTPAID + l_intpaid,
                    FEEINTNMLOVD = 0, FEEINTOVDACR = 0, FEEINTDUE =0, FEEDUE = 0 ,
                    FEEINTNMLACR =0, feeintpaid=feeintpaid+l_feepaid
                where reftype='P' and ACCTNO IN (SELECT LNACCTNO FROM DFGROUP WHERE GROUPID= l_GROUPID );

                --UPDATE LNSCHDLOG
                -- PhuongHT edit
                UPDATE LNSCHDLOG SET INTOVDPRIN = -v_INTOVDPRIN ,
                    INTOVD=- v_INTOVD, INTDUE=-v_INTDUE,INTNMLACR=-v_INTNMLACR,INTPAID= l_intpaid,
                    FEEINTOVD =  -  v_FEEINTOVDACR, FEEINTOVDPRIN= - v_FEEINTNMLOVD,
                    FEEINTDUE = -v_FEEDUE, FEEDUE = 0,
                    FEEINTNMLACR = -v_FEEINTNMLACR, feeintpaid= l_feepaid
                WHERE (AUTOID, TXNUM, TXDATE) = (SELECT AUTOID, p_txmsg.txnum,TO_DATE(p_txmsg.txdate,'DD/MM/RRRR')
                            FROM LNSCHD  where reftype='P' and ACCTNO IN (SELECT LNACCTNO FROM DFGROUP WHERE GROUPID= l_GROUPID ) );
                 -- end of PhuongHT
                 update lnschd set
                        PAID = PAID + OVD + NML,
                       OVD= OVD -  OVD,
                       NML= NML - NML
                 where reftype='I' and ACCTNO IN (SELECT LNACCTNO FROM DFGROUP WHERE GROUPID= l_GROUPID );
                 -- PhuongHT add lnschdlog cho dong I
              INSERT INTO LNSCHDLOG (AUTOID, TXNUM, TXDATE, OVD, NML, PAID)
              SELECT AUTOID, p_txmsg.txnum, TO_DATE(p_txmsg.txdate,'DD/MM/RRRR'), -v_INTOVD, -v_INTDUE,
                      v_INTOVD + v_INTDUE from lnschd
                  where reftype='I' and ACCTNO IN (SELECT LNACCTNO FROM DFGROUP WHERE GROUPID= l_GROUPID );
        -- end of PhuongHT add

        end if;
    end if;

/*
    SELECT acctno, nvl(paid,0) paid, nvl(nml,0) nml, nvl(ovd,0) ovd, nvl(intnmlacr,0) intnmlacr,
        nvl(INTOVDPRIN,0) INTOVDPRIN, nvl(intovd,0) intovd, nvl(intdue,0) intdue, nvl(intpaid,0) intpaid,nvl(FEEINTNMLOVD,0) FEEINTNMLOVD,
        nvl(FEEINTOVDACR,0) FEEINTOVDACR , nvl(FEEINTNMLACR,0) FEEINTNMLACR, nvl(FEEINTDUE,0) FEEINTDUE, nvl(feeintpaid,0) feeintpaid
    into v_LNACCTNO,v_paid, v_nml, v_ovd, v_intnmlacr, v_INTOVDPRIN, v_intovd, v_intdue, v_intpaid, v_FEEINTNMLOVD, v_FEEINTOVDACR, v_FEEINTNMLACR, v_FEEDUE, v_feeintpaid
    FROM LNSCHD WHERE ACCTNO IN (SELECT LNACCTNO FROM DFGROUP WHERE GROUPID= l_GROUPID ) AND REFTYPE='P' ;
*/

    INSERT INTO LNTRAN (AUTOID,TXNUM,TXDATE,ACCTNO,TXCD,NAMT,CAMT,REF,DELTD,ACCTREF,TLTXCD,BKDATE,TRDESC)
    VALUES(SEQ_LNTRAN.NEXTVAL,p_txmsg.txnum,TO_DATE(p_txmsg.txdate,'DD/MM/RRRR'),v_LNACCTNO,'0014',v_paid,NULL,l_AFACCTNO,'N',l_AFACCTNO,p_txmsg.tltxcd,TO_DATE(p_txmsg.txdate,'DD/MM/RRRR'),NULL);

    INSERT INTO LNTRAN (AUTOID,TXNUM,TXDATE,ACCTNO,TXCD,NAMT,CAMT,REF,DELTD,ACCTREF,TLTXCD,BKDATE,TRDESC)
    VALUES(SEQ_LNTRAN.NEXTVAL,p_txmsg.txnum,TO_DATE(p_txmsg.txdate,'DD/MM/RRRR'),v_LNACCTNO,'0015',v_nml,NULL,l_AFACCTNO,'N',l_AFACCTNO,p_txmsg.tltxcd,TO_DATE(p_txmsg.txdate,'DD/MM/RRRR'),NULL);

    INSERT INTO LNTRAN (AUTOID,TXNUM,TXDATE,ACCTNO,TXCD,NAMT,CAMT,REF,DELTD,ACCTREF,TLTXCD,BKDATE,TRDESC)
    VALUES(SEQ_LNTRAN.NEXTVAL,p_txmsg.txnum,TO_DATE(p_txmsg.txdate,'DD/MM/RRRR'),v_LNACCTNO,'0017',v_ovd,NULL,l_AFACCTNO,'N',l_AFACCTNO,p_txmsg.tltxcd,TO_DATE(p_txmsg.txdate,'DD/MM/RRRR'),NULL);

    INSERT INTO LNTRAN (AUTOID,TXNUM,TXDATE,ACCTNO,TXCD,NAMT,CAMT,REF,DELTD,ACCTREF,TLTXCD,BKDATE,TRDESC)
    VALUES(SEQ_LNTRAN.NEXTVAL,p_txmsg.txnum,TO_DATE(p_txmsg.txdate,'DD/MM/RRRR'),v_LNACCTNO,'0041',v_intnmlacr,NULL,l_AFACCTNO,'N',l_AFACCTNO,p_txmsg.tltxcd,TO_DATE(p_txmsg.txdate,'DD/MM/RRRR'),NULL);

    INSERT INTO LNTRAN (AUTOID,TXNUM,TXDATE,ACCTNO,TXCD,NAMT,CAMT,REF,DELTD,ACCTREF,TLTXCD,BKDATE,TRDESC)
    VALUES(SEQ_LNTRAN.NEXTVAL,p_txmsg.txnum,TO_DATE(p_txmsg.txdate,'DD/MM/RRRR'),v_LNACCTNO,'0043',v_INTOVDPRIN,NULL,l_AFACCTNO,'N',l_AFACCTNO,p_txmsg.tltxcd,TO_DATE(p_txmsg.txdate,'DD/MM/RRRR'),NULL);

    INSERT INTO LNTRAN (AUTOID,TXNUM,TXDATE,ACCTNO,TXCD,NAMT,CAMT,REF,DELTD,ACCTREF,TLTXCD,BKDATE,TRDESC)
    VALUES(SEQ_LNTRAN.NEXTVAL,p_txmsg.txnum,TO_DATE(p_txmsg.txdate,'DD/MM/RRRR'),v_LNACCTNO,'0027',v_intovd,NULL,l_AFACCTNO,'N',l_AFACCTNO,p_txmsg.tltxcd,TO_DATE(p_txmsg.txdate,'DD/MM/RRRR'),NULL);

    INSERT INTO LNTRAN (AUTOID,TXNUM,TXDATE,ACCTNO,TXCD,NAMT,CAMT,REF,DELTD,ACCTREF,TLTXCD,BKDATE,TRDESC)
    VALUES(SEQ_LNTRAN.NEXTVAL,p_txmsg.txnum,TO_DATE(p_txmsg.txdate,'DD/MM/RRRR'),v_LNACCTNO,'0025',v_intdue,NULL,l_AFACCTNO,'N',l_AFACCTNO,p_txmsg.tltxcd,TO_DATE(p_txmsg.txdate,'DD/MM/RRRR'),NULL);

    INSERT INTO LNTRAN (AUTOID,TXNUM,TXDATE,ACCTNO,TXCD,NAMT,CAMT,REF,DELTD,ACCTREF,TLTXCD,BKDATE,TRDESC)
    VALUES(SEQ_LNTRAN.NEXTVAL,p_txmsg.txnum,TO_DATE(p_txmsg.txdate,'DD/MM/RRRR'),v_LNACCTNO,'0024',v_intpaid,NULL,l_AFACCTNO,'N',l_AFACCTNO,p_txmsg.tltxcd,TO_DATE(p_txmsg.txdate,'DD/MM/RRRR'),NULL);

    INSERT INTO LNTRAN (AUTOID,TXNUM,TXDATE,ACCTNO,TXCD,NAMT,CAMT,REF,DELTD,ACCTREF,TLTXCD,BKDATE,TRDESC)
    VALUES(SEQ_LNTRAN.NEXTVAL,p_txmsg.txnum,TO_DATE(p_txmsg.txdate,'DD/MM/RRRR'),v_LNACCTNO,'0083',v_FEEINTNMLOVD,NULL,l_AFACCTNO,'N',l_AFACCTNO,p_txmsg.tltxcd,TO_DATE(p_txmsg.txdate,'DD/MM/RRRR'),NULL);

    INSERT INTO LNTRAN (AUTOID,TXNUM,TXDATE,ACCTNO,TXCD,NAMT,CAMT,REF,DELTD,ACCTREF,TLTXCD,BKDATE,TRDESC)
    VALUES(SEQ_LNTRAN.NEXTVAL,p_txmsg.txnum,TO_DATE(p_txmsg.txdate,'DD/MM/RRRR'),v_LNACCTNO,'0085',v_FEEINTOVDACR,NULL,l_AFACCTNO,'N',l_AFACCTNO,p_txmsg.tltxcd,TO_DATE(p_txmsg.txdate,'DD/MM/RRRR'),NULL);

    INSERT INTO LNTRAN (AUTOID,TXNUM,TXDATE,ACCTNO,TXCD,NAMT,CAMT,REF,DELTD,ACCTREF,TLTXCD,BKDATE,TRDESC)
    VALUES(SEQ_LNTRAN.NEXTVAL,p_txmsg.txnum,TO_DATE(p_txmsg.txdate,'DD/MM/RRRR'),v_LNACCTNO,'0078',v_FEEINTNMLACR,NULL,l_AFACCTNO,'N',l_AFACCTNO,p_txmsg.tltxcd,TO_DATE(p_txmsg.txdate,'DD/MM/RRRR'),NULL);

    INSERT INTO LNTRAN (AUTOID,TXNUM,TXDATE,ACCTNO,TXCD,NAMT,CAMT,REF,DELTD,ACCTREF,TLTXCD,BKDATE,TRDESC)
    VALUES(SEQ_LNTRAN.NEXTVAL,p_txmsg.txnum,TO_DATE(p_txmsg.txdate,'DD/MM/RRRR'),v_LNACCTNO,'0081',v_FEEDUE,NULL,l_AFACCTNO,'N',l_AFACCTNO,p_txmsg.tltxcd,TO_DATE(p_txmsg.txdate,'DD/MM/RRRR'),NULL);

    INSERT INTO LNTRAN (AUTOID,TXNUM,TXDATE,ACCTNO,TXCD,NAMT,CAMT,REF,DELTD,ACCTREF,TLTXCD,BKDATE,TRDESC)
    VALUES(SEQ_LNTRAN.NEXTVAL,p_txmsg.txnum,TO_DATE(p_txmsg.txdate,'DD/MM/RRRR'),v_LNACCTNO,'0090',v_feeintpaid,NULL,l_AFACCTNO,'N',l_AFACCTNO,p_txmsg.tltxcd,TO_DATE(p_txmsg.txdate,'DD/MM/RRRR'),NULL);

    plog.debug (pkgctx,' UPDATE LNMAST ' || l_GROUPID);
    UPDATE LNMAST SET (prinpaid, prinnml, prinovd, intnmlacr, intovdacr, intnmlovd, intdue, intpaid, feeintnmlovd, feeintovdacr,
        feeintnmlacr, feeintdue, feeintpaid) = (SELECT nvl(paid,0) paid, nvl(nml,0) nml, nvl(ovd,0) ovd, nvl(intnmlacr,0) intnmlacr,
        nvl(INTOVDPRIN,0) INTOVDPRIN, nvl(intovd,0) intovd, nvl(intdue,0) intdue, nvl(intpaid,0) intpaid,nvl(FEEINTNMLOVD,0) FEEINTNMLOVD,
        nvl(FEEINTOVDACR,0) FEEINTOVDACR , nvl(FEEINTNMLACR,0) FEEINTOVDACR, nvl(FEEINTDUE,0) FEEINTOVDACR, nvl(feeintpaid,0) FEEINTOVDACR FROM LNSCHD WHERE LNMAST.ACCTNO=LNSCHD.ACCTNO AND LNSCHD.REFTYPE='P' ) WHERE LNMAST.ACCTNO IN
            (SELECT LNACCTNO FROM DFGROUP WHERE GROUPID= l_GROUPID );

     --xet xem co phai lan tra cuoi cung khong
     SELECT trunc(lns.nml)+trunc(lns.ovd)+trunc(lns.INTOVDPRIN)+trunc(lns.INTOVD)+trunc(lns.INTDUE)+trunc(lns.INTNMLACR)
            +trunc(lns.FEEINTOVDACR)+trunc(lns.FEEINTNMLOVD)+trunc(lns.FEEINTDUE)+trunc(lns.FEEINTNMLACR)
     INTO v_REMAINLNAMT
     FROM lnschd lns
     WHERE lns.reftype='P' and lns.ACCTNO IN (SELECT LNACCTNO FROM DFGROUP WHERE GROUPID= l_GROUPID );
     -- Neu la lan tra cuoi cung thi update vao LNSCHDLOG
     IF v_REMAINLNAMT <1 THEN
        UPDATE lnschdlog SET
            LASTPAID = 'Y'
        WHERE (AUTOID, TXNUM, TXDATE) = (SELECT AUTOID, p_txmsg.txnum,TO_DATE(p_txmsg.txdate,'DD/MM/RRRR')
                            FROM LNSCHD  where reftype='P' and ACCTNO IN (SELECT LNACCTNO FROM DFGROUP WHERE GROUPID= l_GROUPID));
     END IF;

    p_err_code:=0;
    plog.setendsection(pkgctx, 'pr_DFPaidDeal');
  EXCEPTION
  WHEN OTHERS
   THEN
      plog.debug (pkgctx,'got error on pr_DFPaidDeal');
      ROLLBACK;
      p_err_code := errnums.C_SYSTEM_ERROR;
      plog.error (pkgctx, SQLERRM);
      plog.setendsection (pkgctx, 'pr_DFPaidDeal');
      RAISE errnums.E_SYSTEM_ERROR;
  END pr_DFPaidDeal;



  ---pr_AddSEToGRDeal-----------
PROCEDURE pr_AddSEToGRDeal(p_txmsg in tx.msg_rectype,p_err_code  OUT varchar2)
  IS
    V_STRXML  varchar2(30000);
    l_count number;
    l_countN number;
    l_ORGAMT number;
    l_AddQTTY number;
    l_CODEID varchar2(6);
    l_DEALTYPE varchar2(1);
    l_DFACCTNO varchar2(20);
    l_REFID varchar2(50);
    l_AFACCTNO varchar2(20);
    l_GROUPID  varchar2(20);
    l_ACTYPE varchar2(4);
    v_strDesc varchar2(100);
    v_strEN_Desc varchar2(100);
    v_strCURRDATE date;
    l_txmsg               tx.msg_rectype;
    l_err_param varchar2(300);

  BEGIN
   plog.setbeginsection (pkgctx, 'pr_AddSEToGRDeal');

   plog.debug(pkgctx,'pr_AddSEToGRDeal HAILT: ' || V_STRXML);

    SELECT TXDESC,EN_TXDESC into v_strDesc, v_strEN_Desc FROM  TLTX WHERE TLTXCD='2647';
     SELECT TO_DATE (varvalue, systemnums.c_date_format)
               INTO v_strCURRDATE
               FROM sysvar
               WHERE grname = 'SYSTEM' AND varname = 'CURRDATE';
    l_txmsg.msgtype:='T';
    l_txmsg.local:='N';
    l_txmsg.tlid        := systemnums.c_system_userid;
    SELECT SYS_CONTEXT ('USERENV', 'HOST'),
             SYS_CONTEXT ('USERENV', 'IP_ADDRESS', 15)
      INTO l_txmsg.wsname, l_txmsg.ipaddress
    FROM DUAL;
    l_txmsg.off_line    := 'N';
    l_txmsg.deltd       := txnums.c_deltd_txnormal;
    l_txmsg.txstatus    := txstatusnums.c_txcompleted;
    l_txmsg.msgsts      := '0';
    l_txmsg.ovrsts      := '0';
    l_txmsg.batchname   := 'DAY';
    l_txmsg.txdate:=to_date(v_strCURRDATE,systemnums.c_date_format);
    l_txmsg.BUSDATE:=to_date(v_strCURRDATE,systemnums.c_date_format);
    l_txmsg.tltxcd:='2652';


    V_STRXML:= p_txmsg.txfields('06').VALUE;

    plog.debug(pkgctx,'pr_AddSEToGRDeal: ' || V_STRXML);

    l_countN:=REGEXP_COUNT(V_STRXML,'@');

    for l_count in 1.. l_countN loop

        l_GROUPID := substr(V_STRXML,1,instr(V_STRXML,'|',1,1)-1 ) ;
        l_AFACCTNO := substr(V_STRXML,instr(V_STRXML,'|',1,1)+1,instr(V_STRXML,'|',1,2)-instr(V_STRXML,'|',1,1)-1 ) ;
        l_CODEID := substr(V_STRXML,instr(V_STRXML,'|',1,2)+1,instr(V_STRXML,'|',1,3)-instr(V_STRXML,'|',1,2)-1 ) ;
        l_DEALTYPE := substr(V_STRXML,instr(V_STRXML,'|',1,3)+1,instr(V_STRXML,'|',1,4)-instr(V_STRXML,'|',1,3)-1 ) ;
        l_AddQTTY := substr(V_STRXML,instr(V_STRXML,'|',1,4)+1,instr(V_STRXML,'|',1,5)-instr(V_STRXML,'|',1,4)-1 ) ;
        l_REFID:= substr(V_STRXML,instr (V_STRXML,'|',1,5)+1,instr (V_STRXML,'@',1,1)-instr (V_STRXML,'|',1,5)-1);

        for rec in
        (
            select V.amtdf,V.amtln,V.AMTEXT,v.amtwit, al1.cdcontent DEALFLAGTRIGGER,DF.GROUPID,CF.CUSTODYCD,CF.FULLNAME,AF.ACCTNO AFACCTNO,CF.ADDRESS,CF.IDCODE,DF.LIMITCHK LIMITCHECK ,
            DF.ORGAMT -DF.RLSAMT AMT, DF.LNACCTNO , DF.STATUS DEALSTATUS ,DF.ACTYPE ,DF.RRTYPE, DF.DFTYPE, DF.CUSTBANK, DF.CIACCTNO,DF.FEEMIN,
            DF.TAX,DF.AMTMIN,DFB.DFRATE,DFB.IRATE,DFB.MRATE,DFB.LRATE,DF.RLSAMT,DF.DESCRIPTION,df.txdate ,
            (case when df.ciacctno is not null then df.ciacctno when df.custbank is not null then   df.custbank else '' end )
            RRID , decode (df.RRTYPE,'O',1,0) CIDRAWNDOWN,decode (df.RRTYPE,'B',1,0) BANKDRAWNDOWN,
            decode (df.RRTYPE,'C',1,0) CMPDRAWNDOWN,dftype.AUTODRAWNDOWN,'R' calltype, DFB.DEALTYPE,
            (CASE WHEN l_DEALTYPE='T' THEN 1 ELSE SEC.DFREFPRICE END) * DFB.DFRATE /100 CURRPRICE
            from dfgroup df, dftype, lnmast ln, afmast af , cfmast cf, allcode al1,V_DFGRPAMT V, DFBASKET DFB, securities_info SEC
            where df.lnacctno= ln.acctno and df.afacctno= af.acctno and af.custid= cf.custid and df.actype=dftype.actype
            and df.flagtrigger=al1.cdval and al1.cdname='FLAGTRIGGER'AND V.GROUPID = DF.GROUPID AND DFTYPE.BASKETID=DFB.BASKETID
            AND DFB.SYMBOL=SEC.SYMBOL
            AND DFB.SYMBOL IN (SELECT SYMBOL FROM SBSECURITIES WHERE CODEID=l_CODEID) AND DFB.DEALTYPE=l_DEALTYPE
            and DF.groupid = l_GROUPID  AND AF.ACCTNO = l_AFACCTNO
        )
        loop

            plog.debug(pkgctx,' rec 1 ' || l_AddQTTY);
            --Set txnum
            SELECT systemnums.C_BATCH_PREFIXED
                             || LPAD (seq_BATCHTXNUM.NEXTVAL, 8, '0')
                      INTO l_txmsg.txnum
                      FROM DUAL;

            --Set cac field giao dich
            --01  CODEID          C
            l_txmsg.txfields ('01').defname   := 'CODEID';
            l_txmsg.txfields ('01').TYPE      := 'C';
            l_txmsg.txfields ('01').VALUE     := l_CODEID;

            --03  AFACCTNO        C   20AFACCTNO
            l_txmsg.txfields ('03').defname   := 'AFACCTNO';
            l_txmsg.txfields ('03').TYPE      := 'C';
            l_txmsg.txfields ('03').VALUE     := l_AFACCTNO;

            --04  ACTYPE          C   20ACTYPE
            l_txmsg.txfields ('04').defname   := 'ACTYPE';
            l_txmsg.txfields ('04').TYPE      := 'C';
            l_txmsg.txfields ('04').VALUE     := rec.ACTYPE;


            --05  ACCTNO          C
            l_txmsg.txfields ('05').defname   := 'ACCTNO';
            l_txmsg.txfields ('05').TYPE      := 'C';
            l_txmsg.txfields ('05').VALUE     := l_AFACCTNO||l_CODEID;

            --06  DFTYPE          C   20DFTYPE
            l_txmsg.txfields ('06').defname   := 'DFTYPE';
            l_txmsg.txfields ('06').TYPE      := 'C';
            l_txmsg.txfields ('06').VALUE     := rec.DFTYPE;

            --08  MRATE           N   20MRATE
            l_txmsg.txfields ('08').defname   := 'MRATE';
            l_txmsg.txfields ('08').TYPE      := 'N';
            l_txmsg.txfields ('08').VALUE     := rec.MRATE;

            --09  LRATE           N   20LRATE
            l_txmsg.txfields ('09').defname   := 'LRATE';
            l_txmsg.txfields ('09').TYPE      := 'N';
            l_txmsg.txfields ('09').VALUE     := rec.LRATE;

            --10  DFRATE           N
            l_txmsg.txfields ('10').defname   := 'DFRATE';
            l_txmsg.txfields ('10').TYPE      := 'N';
            l_txmsg.txfields ('10').VALUE     := rec.DFRATE;

            --12  TRADE           N   03AVLSEWITHDRAW
            l_txmsg.txfields ('12').defname   := 'TRADE';
            l_txmsg.txfields ('12').TYPE      := 'N';
            l_txmsg.txfields ('12').VALUE     := 0;

            --14  IRATE           N   20IRATE
            l_txmsg.txfields ('14').defname   := 'IRATE';
            l_txmsg.txfields ('14').TYPE      := 'N';
            l_txmsg.txfields ('14').VALUE     := rec.IRATE;

            --15  RRTYPE          C   20RRTYPE
            l_txmsg.txfields ('15').defname   := 'RRTYPE';
            l_txmsg.txfields ('15').TYPE      := 'C';
            l_txmsg.txfields ('15').VALUE     := rec.RRTYPE;

            --16  AUTODRAWNDOWN   C   20AUTODRAWNDOWN
            l_txmsg.txfields ('16').defname   := 'AUTODRAWNDOWN';
            l_txmsg.txfields ('16').TYPE      := 'C';
            l_txmsg.txfields ('16').VALUE     := rec.AUTODRAWNDOWN;

            --17  CALLTYPE        C   20CALLTYPE
            l_txmsg.txfields ('17').defname   := 'CALLTYPE';
            l_txmsg.txfields ('17').TYPE      := 'C';
            l_txmsg.txfields ('17').VALUE     := rec.CALLTYPE;

            --18  RLSAMT          N   20RLSAMT
            l_txmsg.txfields ('18').defname   := 'RLSAMT';
            l_txmsg.txfields ('18').TYPE      := 'N';
            l_txmsg.txfields ('18').VALUE     := rec.RLSAMT;

            --19  QTTYTYPE        C
            l_txmsg.txfields ('19').defname   := 'QTTYTYPE';
            l_txmsg.txfields ('19').TYPE      := 'C';
            l_txmsg.txfields ('19').VALUE     := '002';

            --20  GROUPID         C
            l_txmsg.txfields ('20').defname   := 'GROUPID';
            l_txmsg.txfields ('20').TYPE      := 'C';
            l_txmsg.txfields ('20').VALUE     := l_GROUPID;

            --21  LNACCTNO        C   20LNACCTNO
            l_txmsg.txfields ('21').defname   := 'LNACCTNO';
            l_txmsg.txfields ('21').TYPE      := 'C';
            l_txmsg.txfields ('21').VALUE     := rec.LNACCTNO;

            --22  BLOCKED         N   03BLOCKTF
            l_txmsg.txfields ('22').defname   := 'BLOCKED';
            l_txmsg.txfields ('22').TYPE      := 'N';
            l_txmsg.txfields ('22').VALUE     := 0;

            --50  RRID            C   20RRID
            l_txmsg.txfields ('50').defname   := 'RRID';
            l_txmsg.txfields ('50').TYPE      := 'C';
            l_txmsg.txfields ('50').VALUE     := rec.RRID;

            --51  CIDRAWNDOWN     C   20CIDRAWNDOWN
            l_txmsg.txfields ('51').defname   := 'CIDRAWNDOWN';
            l_txmsg.txfields ('51').TYPE      := 'C';
            l_txmsg.txfields ('51').VALUE     := rec.CIDRAWNDOWN;

            --52  BANKDRAWNDOWN   C   20BANKDRAWNDOWN
            l_txmsg.txfields ('52').defname   := 'BANKDRAWNDOWN';
            l_txmsg.txfields ('52').TYPE      := 'C';
            l_txmsg.txfields ('52').VALUE     := rec.BANKDRAWNDOWN;

            --53  CMPDRAWNDOWN    C   20CMPDRAWNDOWN
            l_txmsg.txfields ('53').defname   := 'CMPDRAWNDOWN';
            l_txmsg.txfields ('53').TYPE      := 'C';
            l_txmsg.txfields ('53').VALUE     := rec.CMPDRAWNDOWN;

            --55  DEALTYPE        C
            l_txmsg.txfields ('55').defname   := 'DEALTYPE';
            l_txmsg.txfields ('55').TYPE      := 'C';
            l_txmsg.txfields ('55').VALUE     := l_DEALTYPE;

            --56  REFID        C
            l_txmsg.txfields ('56').defname   := 'REFID';
            l_txmsg.txfields ('56').TYPE      := 'C';
            l_txmsg.txfields ('56').VALUE     := l_REFID;

            --57  CUSTNAME        C   20FULLNAME
            l_txmsg.txfields ('57').defname   := 'CUSTNAME';
            l_txmsg.txfields ('57').TYPE      := 'C';
            l_txmsg.txfields ('57').VALUE     := rec.FULLNAME;

            --58  ADDRESS         C   20ADDRESS
            l_txmsg.txfields ('58').defname   := 'ADDRESS';
            l_txmsg.txfields ('58').TYPE      := 'C';
            l_txmsg.txfields ('58').VALUE     := rec.ADDRESS;

            --59  LICENSE         C   20IDCODE
            l_txmsg.txfields ('59').defname   := 'LICENSE';
            l_txmsg.txfields ('59').TYPE      := 'C';
            l_txmsg.txfields ('59').VALUE     := rec.IDCODE;

            --71  CURPRICE        N   01PRICE
            l_txmsg.txfields ('71').defname   := 'CURPRICE';
            l_txmsg.txfields ('71').TYPE      := 'N';
            l_txmsg.txfields ('71').VALUE     := rec.CURRPRICE;

            --72  CONST           N
            l_txmsg.txfields ('72').defname   := 'CONST';
            l_txmsg.txfields ('72').TYPE      := 'N';
            l_txmsg.txfields ('72').VALUE     := 0;

            --73  AMTLN           N   20AMTLN
            l_txmsg.txfields ('73').defname   := 'AMTLN';
            l_txmsg.txfields ('73').TYPE      := 'N';
            l_txmsg.txfields ('73').VALUE     := rec.AMTLN;

            --74  AMTDF           N   20AMTDF
            l_txmsg.txfields ('74').defname   := 'AMTDF';
            l_txmsg.txfields ('74').TYPE      := 'N';
            l_txmsg.txfields ('74').VALUE     := rec.AMTDF;

            --75  QTTY            N   03AVLSEWITHDRAW
            l_txmsg.txfields ('75').defname   := 'QTTY';
            l_txmsg.txfields ('75').TYPE      := 'N';
            l_txmsg.txfields ('75').VALUE     := l_AddQTTY;

            --88  CUSTODYCD       C   20CUSTODYCD
            l_txmsg.txfields ('88').defname   := 'CUSTODYCD';
            l_txmsg.txfields ('88').TYPE      := 'C';
            l_txmsg.txfields ('88').VALUE     := rec.CUSTODYCD;

            --99  LIMITCHECK      N   20LIMITCHECK
            l_txmsg.txfields ('99').defname   := 'LIMITCHECK';
            l_txmsg.txfields ('99').TYPE      := 'N';
            l_txmsg.txfields ('99').VALUE     := rec.LIMITCHECK;

            --30  C   DESC
            l_txmsg.txfields ('30').defname   := 'DESC';
            l_txmsg.txfields ('30').TYPE      := 'C';
            l_txmsg.txfields ('30').VALUE     := p_txmsg.txfields('30').VALUE;

            plog.debug(pkgctx,' rec 2 05 ' || l_AFACCTNO||l_CODEID);

            BEGIN
                IF txpks_#2652.fn_batchtxprocess (l_txmsg,
                                                 p_err_code,
                                                 l_err_param
                   ) <> systemnums.c_success
                THEN
                   plog.debug (pkgctx,
                               'got error 2652: ' || p_err_code
                   );
                   ROLLBACK;
                   RETURN;
                END IF;
            END;

        END LOOP;


        V_STRXML:= substr(V_STRXML,instr(V_STRXML,'@',1,1)+1);

    end loop;

    plog.debug(pkgctx,'pr_AddSEToGRDeal:  ' || p_txmsg.txfields('09').VALUE || '  ' || p_txmsg.txfields('08').VALUE || '  ' || p_txmsg.txfields('20').VALUE );

    IF p_txmsg.txfields('09').VALUE <> 'N' THEN
        update dfgroup set examt=p_txmsg.txfields('08').VALUE where groupid = p_txmsg.txfields('20').VALUE;
    END IF;

    plog.debug(pkgctx,' rec 3 ' || l_AddQTTY);

    p_err_code:=0;
    plog.setendsection(pkgctx, 'pr_AddSEToGRDeal');
EXCEPTION
    WHEN OTHERS
    THEN
      plog.debug (pkgctx,'got error on pr_AddSEToGRDeal');
      ROLLBACK;
      p_err_code := errnums.C_SYSTEM_ERROR;
      plog.error (pkgctx, SQLERRM);
      plog.setendsection (pkgctx, 'pr_AddSEToGRDeal');
      RAISE errnums.E_SYSTEM_ERROR;
END pr_AddSEToGRDeal;



  PROCEDURE pr_TransSEToOtherGrpDeal(p_txmsg in tx.msg_rectype ,p_err_code  OUT varchar2)
  IS
    V_STRXML  varchar2(30000);
    l_txmsg               tx.msg_rectype;
    l_countN number;
    l_count number;
    l_countTmp number;
    l_AMT number;
    l_QTTY number;
    l_EXECQTTY number;
    l_DFRATE  number;
    l_ACCTNO varchar2(20);
    l_SYMBOL varchar2(10);
    l_DEALTYPE varchar2(1);
    l_TOGROUPID VARCHAR2(20);
    l_REFID varchar2(20);
    l_DFREF varchar(50);
    l_DFACCTNO varchar2(20);
    l_DFACCTMP varchar2(20);
    l_DFACCTNOTEMP varchar2(20);
    v_dblCARCVQTTY number;
    v_dblRCVQTTY number;
    v_dbltmpRCVQTTY number;
    v_dblBLOCKQTTY number;
    v_dblAVLQTTY NUMBER;
    v_dblCACASHQTTY number;
    v_dblExecRCVQTTY number;

  BEGIN

    V_STRXML:= p_txmsg.txfields('06').VALUE;

    plog.error(pkgctx,'pr_TransSEToOtherGrpDeal: ' || V_STRXML);

    l_countN:=REGEXP_COUNT(V_STRXML,'@');

    for l_count in 1.. l_countN loop

        l_ACCTNO := substr(V_STRXML,1,instr(V_STRXML,'|',1,1)-1 ) ;
        l_SYMBOL := substr(V_STRXML,instr(V_STRXML,'|',1,1)+1,instr(V_STRXML,'|',1,2)-instr(V_STRXML,'|',1,1)-1 ) ;
        l_AMT := substr(V_STRXML,instr(V_STRXML,'|',1,2)+1,instr(V_STRXML,'|',1,3)-instr(V_STRXML,'|',1,2)-1 ) ;
        l_QTTY := substr(V_STRXML,instr(V_STRXML,'|',1,3)+1,instr(V_STRXML,'|',1,4)-instr(V_STRXML,'|',1,3)-1 ) ;
        l_DEALTYPE := substr(V_STRXML,instr(V_STRXML,'|',1,4)+1,instr(V_STRXML,'|',1,5)-instr(V_STRXML,'|',1,4)-1 ) ;
        l_TOGROUPID := substr(V_STRXML,instr(V_STRXML,'|',1,5)+1,instr(V_STRXML,'|',1,6)-instr(V_STRXML,'|',1,5)-1 ) ;
        l_REFID := substr(V_STRXML,instr(V_STRXML,'|',1,6)+1,instr(V_STRXML,'@',1,1)-instr(V_STRXML,'|',1,6)-1 ) ;

        SELECT SEQ_DFMAST.NEXTVAL DFACCTNO
          into l_DFACCTNO
        FROM DUAL;
        l_DFACCTNO:=substr('000000' || l_DFACCTNO,length('000000' || l_DFACCTNO)-5,6);
        l_DFACCTNO:=p_txmsg.brid || substr(to_char(p_txmsg.txdate,systemnums.c_date_format),1,2)
                              || substr(to_char(p_txmsg.txdate,systemnums.c_date_format),4,2)
                              || substr(to_char(p_txmsg.txdate,systemnums.c_date_format),9,2)
                              || l_DFACCTNO;

        plog.debug(pkgctx,'UDATE DFMAST ' || l_DEALTYPE || l_count || ' ' || l_DFACCTNO || ' ' || l_ACCTNO);

        if RTRIM(l_DEALTYPE) = 'M' then

            ---Kiem tra xem co du CK ko thi moi cho lam
            SELECT EXECQTTY INTO l_EXECQTTY from ODMAPEXT WHERE ORDERID = l_ACCTNO AND REFID=l_REFID;

            if l_EXECQTTY <  l_QTTY then
                p_err_code:= -400445;
                ROLLBACK;
                return;
            END IF;

            -- cap nhap giam QTTY, EXECQTTY trong ODMAPEXT doi voi lenh chuyen
            UPDATE ODMAPEXT SET QTTY = QTTY - l_QTTY, EXECQTTY = EXECQTTY - l_QTTY  WHERE ORDERID = l_ACCTNO AND REFID=l_REFID;

            -- cap nhap giam DFQTTY trong DFMAST voi ACCTNO=REFID (trong ODMAPEXT) cua GROUPID chuyen
            UPDATE DFMAST SET DFQTTY = DFQTTY - l_QTTY WHERE ACCTNO= l_REFID;

            plog.debug(pkgctx,'UDATE M :' || l_TOGROUPID || ' ' || l_SYMBOL );
    /*
            -- Lay DFRATE cua nguoi chuyen de kiem tra co' chung khoan va DFRATE nay` o ben nhan hay khong
            select count(*) into l_countTmp from dfmast where groupid = l_TOGROUPID AND DEALTYPE='N' and DFRATE = l_DFRATE AND
                CODEID IN (SELECT CODEID FROM SECURITIES_INFO WHERE SYMBOL=l_SYMBOL);

            -- Kiem tra trong GROUPID chuyen co ma chung khoan nay` chua, neu chua co thi sinh moi, neu co roi + vao DFQTTY
            select count(*) into l_countTmp from dfmast where groupid = l_TOGROUPID AND DEALTYPE='N' and DFRATE = l_DFRATE AND
                CODEID IN (SELECT CODEID FROM SECURITIES_INFO WHERE SYMBOL=l_SYMBOL);
    */
            -- Kiem tra trong GROUPID chuyen co ma chung khoan nay` chua, neu chua co thi sinh moi, neu co roi + vao DFQTTY
            select count(*) into l_countTmp from dfmast df1, dfmast df2 where df1.groupid = l_TOGROUPID AND df1.DEALTYPE='N' and df1.dealtype=df2.dealtype
                AND df2.acctno=l_REFID
                and df1.codeid=df2.codeid and
            df1.CODEID IN (SELECT CODEID FROM SECURITIES_INFO WHERE SYMBOL=l_SYMBOL);


            if l_countTmp >0 then
                select MAX( nvl(df1.acctno,'')) INTO l_DFACCTMP from dfmast df1, dfmast df2 where df1.groupid = l_TOGROUPID AND df1.DEALTYPE='N' and df1.dealtype=df2.dealtype
                    AND df2.acctno=l_REFID
                    and df1.codeid=df2.codeid and
                df1.CODEID IN (SELECT CODEID FROM SECURITIES_INFO WHERE SYMBOL=l_SYMBOL);


                UPDATE DFMAST SET DFQTTY = DFQTTY + l_QTTY WHERE ACCTNO = l_DFACCTMP;

                INSERT INTO DFTRAN(TXNUM,TXDATE,ACCTNO,TXCD,NAMT,CAMT,ACCTREF,DELTD,REF,AUTOID,TLTXCD,BKDATE,TRDESC)
                VALUES (p_txmsg.txnum, TO_DATE (p_txmsg.txdate, systemnums.C_DATE_FORMAT),l_DFACCTMP,'0012',l_QTTY,NULL,l_REFID,p_txmsg.deltd,l_DFACCTMP,seq_DFTRAN.NEXTVAL,'2688',p_txmsg.busdate,'' || '' || '');

                INSERT INTO DFTRAN(TXNUM,TXDATE,ACCTNO,TXCD,NAMT,CAMT,ACCTREF,DELTD,REF,AUTOID,TLTXCD,BKDATE,TRDESC)
                VALUES (p_txmsg.txnum, TO_DATE (p_txmsg.txdate, systemnums.C_DATE_FORMAT),l_REFID,'0011',l_QTTY,NULL,l_DFACCTMP,p_txmsg.deltd,l_REFID,seq_DFTRAN.NEXTVAL,'2688',p_txmsg.busdate,'' || '' || '');

                INSERT INTO ODMAPEXT (ORDERID, REFID, TYPE, ORDERNUM, QTTY, DELTD, STATUS, EXECQTTY)
                    VALUES(l_ACCTNO, l_DFACCTMP, 'D',1, l_QTTY, 'N', 'N', l_QTTY);

            ELSE

                INSERT INTO DFMAST (
                   ACCTNO, AFACCTNO, LNACCTNO, TXDATE, TXNUM, TXTIME,
                   ACTYPE, RRTYPE, DFTYPE, CUSTBANK,CIACCTNO, LNTYPE, FEE,
                   FEEMIN, TAX, AMTMIN, CODEID, REFPRICE, DFPRICE,
                   TRIGGERPRICE, DFRATE, IRATE, MRATE, LRATE, CALLTYPE,
                   DFQTTY, BQTTY,RCVQTTY,BLOCKQTTY,CARCVQTTY, RLSQTTY, DFAMT, RLSAMT, AMT,
                   INTAMTACR, FEEAMT, RLSFEEAMT, STATUS, DFREF,DESCRIPTION,LIMITCHK,CISVRFEE,GROUPID,DEALTYPE,CACASHQTTY,ARATE,ALRATE)
                SELECT l_DFACCTNO, AFACCTNO, (SELECT LNACCTNO FROM DFGROUP WHERE GROUPID=l_TOGROUPID), TXDATE, '', '',
                   ACTYPE, RRTYPE, DFTYPE, CUSTBANK,CIACCTNO, LNTYPE, FEE,
                   FEEMIN, TAX, AMTMIN, CODEID, REFPRICE, DFPRICE,
                   TRIGGERPRICE, DFRATE, IRATE, MRATE, LRATE, CALLTYPE,l_QTTY, 0,0,0,0, 0, 0, 0, l_AMT,
                   0, 0, 0, STATUS, DFREF,DESCRIPTION,LIMITCHK,CISVRFEE,l_TOGROUPID,DEALTYPE,0,ARATE,ALRATE FROM DFMAST WHERE ACCTNO=l_REFID;

                INSERT INTO DFTRAN(TXNUM,TXDATE,ACCTNO,TXCD,NAMT,CAMT,ACCTREF,DELTD,REF,AUTOID,TLTXCD,BKDATE,TRDESC)
                VALUES (p_txmsg.txnum, TO_DATE (p_txmsg.txdate, systemnums.C_DATE_FORMAT),l_DFACCTNO,'0012',l_QTTY,NULL,l_REFID,p_txmsg.deltd,l_DFACCTNO,seq_DFTRAN.NEXTVAL,'2688',p_txmsg.busdate,'' || '' || '');

                INSERT INTO DFTRAN(TXNUM,TXDATE,ACCTNO,TXCD,NAMT,CAMT,ACCTREF,DELTD,REF,AUTOID,TLTXCD,BKDATE,TRDESC)
                VALUES (p_txmsg.txnum, TO_DATE (p_txmsg.txdate, systemnums.C_DATE_FORMAT),l_REFID,'0011',l_QTTY,NULL,l_DFACCTNO,p_txmsg.deltd,l_REFID,seq_DFTRAN.NEXTVAL,'2688',p_txmsg.busdate,'' || '' || '');


                INSERT INTO ODMAPEXT (ORDERID, REFID, TYPE, ORDERNUM, QTTY, DELTD, STATUS, EXECQTTY)
                    VALUES(l_ACCTNO, l_DFACCTNO, 'D',1, l_QTTY, 'N', 'N', l_QTTY);

            end if;

        else

            v_dblCARCVQTTY:=0;
            v_dblRCVQTTY:=0;
            v_dblAVLQTTY:=0;
            v_dblBLOCKQTTY:=0;
            v_dblCACASHQTTY:=0;

            plog.debug(pkgctx,'TAKE PARA ' || l_count || ' ' || l_QTTY || ' ' || l_ACCTNO);

            IF l_DEALTYPE = 'N' THEN
                v_dblAVLQTTY:=l_QTTY;
            END IF;
            IF l_DEALTYPE = 'T' THEN
                v_dblCACASHQTTY:=l_QTTY;
            END IF;
            IF l_DEALTYPE = 'P' THEN
                v_dblCARCVQTTY:=l_QTTY;
            END IF;
            IF l_DEALTYPE = 'R' THEN
                v_dblRCVQTTY:=l_QTTY;
            END IF;
            IF l_DEALTYPE = 'B' THEN
                v_dblBLOCKQTTY:=l_QTTY;
            END IF;

              ---Kiem tra xem co du CK ko thi moi cho lam

            SELECT CASE WHEN l_DEALTYPE = 'N' THEN DFQTTY
                        WHEN l_DEALTYPE = 'T' THEN CACASHQTTY
                        WHEN l_DEALTYPE = 'P' THEN CARCVQTTY
                        WHEN l_DEALTYPE = 'R' THEN RCVQTTY
                        WHEN l_DEALTYPE = 'B' THEN BLOCKQTTY  END INTO l_EXECQTTY  FROM DFMAST WHERE ACCTNO = l_ACCTNO;

            if l_EXECQTTY <  l_QTTY then
                p_err_code:= -400445;
                ROLLBACK;
                return;
            END IF;



            plog.debug(pkgctx,'INSERT DFMAST ' || l_count || v_dblAVLQTTY || v_dblCARCVQTTY || v_dblRCVQTTY || v_dblBLOCKQTTY);

            -- lay DFREF de so sanh
            SELECT DFREF into l_DFREF FROM DFMAST WHERE ACCTNO = l_ACCTNO;
            /*
            -- Kiem tra trong GROUPID nhan co ma chung khoan nay` chua, neu chua co thi sinh moi, neu co roi + vao DFQTTY

            select DFRATE into l_DFRATE from dfmast where groupid = l_TOGROUPID AND DEALTYPE= l_DEALTYPE AND
                CODEID IN (SELECT CODEID FROM SECURITIES_INFO WHERE SYMBOL=l_SYMBOL);

            select count(*) into l_countTmp from dfmast where groupid = l_TOGROUPID AND DEALTYPE= l_DEALTYPE AND
                CODEID IN (SELECT CODEID FROM SECURITIES_INFO WHERE SYMBOL=l_SYMBOL) AND DFREF=l_DFREF;
            */

            -- Kiem tra trong GROUPID chuyen co ma chung khoan nay` chua, neu chua co thi sinh moi, neu co roi + vao DFQTTY
            select count(*) into l_countTmp from dfmast df1, dfmast df2 where df1.groupid = l_TOGROUPID AND df1.DEALTYPE= l_DEALTYPE and df1.dealtype=df2.dealtype
                AND df2.acctno=l_REFID and df1.codeid=df2.codeid and
                df1.CODEID IN (SELECT CODEID FROM SECURITIES_INFO WHERE SYMBOL=l_SYMBOL);

            if l_countTmp >0 then
                select nvl(max(df1.acctno),'') INTO l_DFACCTMP from dfmast df1, dfmast df2 where df1.groupid = l_TOGROUPID AND df1.DEALTYPE= l_DEALTYPE and df1.dealtype=df2.dealtype
                    AND df2.acctno=l_REFID and df1.codeid=df2.codeid and
                    df1.CODEID IN (SELECT CODEID FROM SECURITIES_INFO WHERE SYMBOL=l_SYMBOL);


               UPDATE DFMAST
               SET
                 BLOCKQTTY = BLOCKQTTY + v_dblBLOCKQTTY,
                 CARCVQTTY = CARCVQTTY + v_dblCARCVQTTY,
                 RCVQTTY = RCVQTTY + v_dblRCVQTTY,
                 DFQTTY = DFQTTY + v_dblAVLQTTY,
                 CACASHQTTY = CACASHQTTY + v_dblCACASHQTTY
              WHERE ACCTNO=l_DFACCTMP;


                -- 0012    U   C   DFQTTY
                INSERT INTO DFTRAN(TXNUM,TXDATE,ACCTNO,TXCD,NAMT,CAMT,ACCTREF,DELTD,REF,AUTOID,TLTXCD,BKDATE,TRDESC)
                    VALUES (p_txmsg.txnum, TO_DATE (p_txmsg.txdate, systemnums.C_DATE_FORMAT),l_DFACCTMP,'0012',v_dblAVLQTTY,NULL,l_DFACCTMP,p_txmsg.deltd,l_DFACCTMP,seq_DFTRAN.NEXTVAL,'2688',p_txmsg.busdate,'' || '' || '');

                -- 0042    U   C   RCVQTTY
                INSERT INTO DFTRAN(TXNUM,TXDATE,ACCTNO,TXCD,NAMT,CAMT,ACCTREF,DELTD,REF,AUTOID,TLTXCD,BKDATE,TRDESC)
                    VALUES (p_txmsg.txnum, TO_DATE (p_txmsg.txdate, systemnums.C_DATE_FORMAT),l_DFACCTMP,'0042',v_dblRCVQTTY,NULL,l_DFACCTMP,p_txmsg.deltd,l_DFACCTMP,seq_DFTRAN.NEXTVAL,'2688',p_txmsg.busdate,'' || '' || '');

                -- 0044    U   C   BLOCKQTTY
                INSERT INTO DFTRAN(TXNUM,TXDATE,ACCTNO,TXCD,NAMT,CAMT,ACCTREF,DELTD,REF,AUTOID,TLTXCD,BKDATE,TRDESC)
                    VALUES (p_txmsg.txnum, TO_DATE (p_txmsg.txdate, systemnums.C_DATE_FORMAT),l_DFACCTMP,'0044',v_dblBLOCKQTTY,NULL,l_DFACCTMP,p_txmsg.deltd,l_DFACCTMP,seq_DFTRAN.NEXTVAL,'2688',p_txmsg.busdate,'' || '' || '');

                -- 0046    U   C   CARCVQTTY
                INSERT INTO DFTRAN(TXNUM,TXDATE,ACCTNO,TXCD,NAMT,CAMT,ACCTREF,DELTD,REF,AUTOID,TLTXCD,BKDATE,TRDESC)
                    VALUES (p_txmsg.txnum, TO_DATE (p_txmsg.txdate, systemnums.C_DATE_FORMAT),l_DFACCTMP,'0046',v_dblCARCVQTTY,NULL,l_DFACCTMP,p_txmsg.deltd,l_DFACCTMP,seq_DFTRAN.NEXTVAL,'2688',p_txmsg.busdate,'' || '' || '');

                -- 0088    U   C   CACASHQTTY
                INSERT INTO DFTRAN(TXNUM,TXDATE,ACCTNO,TXCD,NAMT,CAMT,ACCTREF,DELTD,REF,AUTOID,TLTXCD,BKDATE,TRDESC)
                    VALUES (p_txmsg.txnum, TO_DATE (p_txmsg.txdate, systemnums.C_DATE_FORMAT),l_DFACCTMP,'0088',v_dblCACASHQTTY,NULL,l_DFACCTMP,p_txmsg.deltd,l_DFACCTMP,seq_DFTRAN.NEXTVAL,'2688',p_txmsg.busdate,'' || '' || '');


            ELSE

                INSERT INTO DFMAST (
                   ACCTNO, AFACCTNO, LNACCTNO, TXDATE, TXNUM, TXTIME,
                   ACTYPE, RRTYPE, DFTYPE, CUSTBANK,CIACCTNO, LNTYPE, FEE,
                   FEEMIN, TAX, AMTMIN, CODEID, REFPRICE, DFPRICE,
                   TRIGGERPRICE, DFRATE, IRATE, MRATE, LRATE, CALLTYPE,
                   DFQTTY, BQTTY,RCVQTTY,BLOCKQTTY,CARCVQTTY, RLSQTTY, DFAMT, RLSAMT, AMT,
                   INTAMTACR, FEEAMT, RLSFEEAMT, STATUS, DFREF,DESCRIPTION,LIMITCHK,CISVRFEE,GROUPID,DEALTYPE,CACASHQTTY,ARATE,ALRATE)
                SELECT l_DFACCTNO, AFACCTNO, (SELECT LNACCTNO FROM DFGROUP WHERE GROUPID=l_TOGROUPID), TXDATE, '', '',
                   ACTYPE, RRTYPE, DFTYPE, CUSTBANK,CIACCTNO, LNTYPE, FEE,
                   FEEMIN, TAX, AMTMIN, CODEID, REFPRICE, DFPRICE,
                   TRIGGERPRICE, DFRATE, IRATE, MRATE, LRATE, CALLTYPE,v_dblAVLQTTY, BQTTY,v_dblRCVQTTY,v_dblBLOCKQTTY,v_dblCARCVQTTY, 0, 0, 0, l_AMT,
                   0, 0, 0, STATUS, DFREF,DESCRIPTION,LIMITCHK,CISVRFEE,l_TOGROUPID,DEALTYPE,v_dblCACASHQTTY,ARATE,ALRATE FROM DFMAST WHERE ACCTNO=l_ACCTNO;

                -- 0012    U   C   DFQTTY
                INSERT INTO DFTRAN(TXNUM,TXDATE,ACCTNO,TXCD,NAMT,CAMT,ACCTREF,DELTD,REF,AUTOID,TLTXCD,BKDATE,TRDESC)
                    VALUES (p_txmsg.txnum, TO_DATE (p_txmsg.txdate, systemnums.C_DATE_FORMAT),l_DFACCTMP,'0012',v_dblAVLQTTY,NULL,l_DFACCTMP,p_txmsg.deltd,l_DFACCTMP,seq_DFTRAN.NEXTVAL,'2688',p_txmsg.busdate,'' || '' || '');

                -- 0042    U   C   RCVQTTY
                INSERT INTO DFTRAN(TXNUM,TXDATE,ACCTNO,TXCD,NAMT,CAMT,ACCTREF,DELTD,REF,AUTOID,TLTXCD,BKDATE,TRDESC)
                    VALUES (p_txmsg.txnum, TO_DATE (p_txmsg.txdate, systemnums.C_DATE_FORMAT),l_DFACCTMP,'0042',v_dblRCVQTTY,NULL,l_DFACCTMP,p_txmsg.deltd,l_DFACCTMP,seq_DFTRAN.NEXTVAL,'2688',p_txmsg.busdate,'' || '' || '');

                -- 0044    U   C   BLOCKQTTY
                INSERT INTO DFTRAN(TXNUM,TXDATE,ACCTNO,TXCD,NAMT,CAMT,ACCTREF,DELTD,REF,AUTOID,TLTXCD,BKDATE,TRDESC)
                    VALUES (p_txmsg.txnum, TO_DATE (p_txmsg.txdate, systemnums.C_DATE_FORMAT),l_DFACCTMP,'0044',v_dblBLOCKQTTY,NULL,l_DFACCTMP,p_txmsg.deltd,l_DFACCTMP,seq_DFTRAN.NEXTVAL,'2688',p_txmsg.busdate,'' || '' || '');

                -- 0046    U   C   CARCVQTTY
                INSERT INTO DFTRAN(TXNUM,TXDATE,ACCTNO,TXCD,NAMT,CAMT,ACCTREF,DELTD,REF,AUTOID,TLTXCD,BKDATE,TRDESC)
                    VALUES (p_txmsg.txnum, TO_DATE (p_txmsg.txdate, systemnums.C_DATE_FORMAT),l_DFACCTMP,'0046',v_dblCARCVQTTY,NULL,l_DFACCTMP,p_txmsg.deltd,l_DFACCTMP,seq_DFTRAN.NEXTVAL,'2688',p_txmsg.busdate,'' || '' || '');

                -- 0088    U   C   CACASHQTTY
                INSERT INTO DFTRAN(TXNUM,TXDATE,ACCTNO,TXCD,NAMT,CAMT,ACCTREF,DELTD,REF,AUTOID,TLTXCD,BKDATE,TRDESC)
                    VALUES (p_txmsg.txnum, TO_DATE (p_txmsg.txdate, systemnums.C_DATE_FORMAT),l_DFACCTMP,'0088',v_dblCACASHQTTY,NULL,l_DFACCTMP,p_txmsg.deltd,l_DFACCTMP,seq_DFTRAN.NEXTVAL,'2688',p_txmsg.busdate,'' || '' || '');


            END IF;

            plog.debug(pkgctx,'END INSERT DFMAST ' || l_count || ' ' || l_DFACCTNO || ' ' || l_ACCTNO );

            UPDATE DFMAST
               SET
                 BLOCKQTTY = BLOCKQTTY - v_dblBLOCKQTTY,
                 CARCVQTTY = CARCVQTTY - v_dblCARCVQTTY,
                 RCVQTTY = RCVQTTY - v_dblRCVQTTY,
                 DFQTTY = DFQTTY - v_dblAVLQTTY,
                 RLSQTTY = RLSQTTY + l_QTTY,
                 CACASHQTTY = CACASHQTTY - v_dblCACASHQTTY
              WHERE ACCTNO=l_ACCTNO;

              --- Giam trong STDFMAP
              if v_dblRCVQTTY >0 then

                v_dbltmpRCVQTTY:=v_dblRCVQTTY;

                for rec5 in (select * from stdfmap where dfacctno = l_ACCTNO and deltd <> 'Y')
                loop

                    v_dblExecRCVQTTY:= least(v_dbltmpRCVQTTY, rec5.dfqtty);

                    update stdfmap set dfqtty = dfqtty -  v_dblExecRCVQTTY, adfqtty = adfqtty - v_dblExecRCVQTTY, rlsamt = rlsamt / dfqtty * v_dblExecRCVQTTY
                            where dfacctno = rec5.dfacctno;

                    insert into stdfmap (txdate, stschdid, dfacctno, dfqtty, adfqtty, rlsamt, status, deltd)
                        select rec5.txdate, rec5.stschdid, l_DFACCTMP, v_dblExecRCVQTTY, v_dblExecRCVQTTY, 0, rec5.status, rec5.deltd from dual;

                    v_dbltmpRCVQTTY:= v_dbltmpRCVQTTY - v_dblExecRCVQTTY;
                    If v_dbltmpRCVQTTY = 0 Then
                        EXIT;
                    End IF;

                end loop;
              end if;

        INSERT INTO DFTRAN(TXNUM,TXDATE,ACCTNO,TXCD,NAMT,CAMT,ACCTREF,DELTD,REF,AUTOID,TLTXCD,BKDATE,TRDESC)
        VALUES (p_txmsg.txnum, TO_DATE (p_txmsg.txdate, systemnums.C_DATE_FORMAT),l_ACCTNO,'0043',v_dblBLOCKQTTY,NULL,l_DFACCTNO,p_txmsg.deltd,l_ACCTNO,seq_DFTRAN.NEXTVAL,p_txmsg.tltxcd,p_txmsg.busdate,'' || '' || '');

        INSERT INTO DFTRAN(TXNUM,TXDATE,ACCTNO,TXCD,NAMT,CAMT,ACCTREF,DELTD,REF,AUTOID,TLTXCD,BKDATE,TRDESC)
        VALUES (p_txmsg.txnum, TO_DATE (p_txmsg.txdate, systemnums.C_DATE_FORMAT),l_ACCTNO,'0045',v_dblCARCVQTTY,NULL,l_DFACCTNO,p_txmsg.deltd,l_ACCTNO,seq_DFTRAN.NEXTVAL,p_txmsg.tltxcd,p_txmsg.busdate,'' || '' || '');

        INSERT INTO DFTRAN(TXNUM,TXDATE,ACCTNO,TXCD,NAMT,CAMT,ACCTREF,DELTD,REF,AUTOID,TLTXCD,BKDATE,TRDESC)
        VALUES (p_txmsg.txnum, TO_DATE (p_txmsg.txdate, systemnums.C_DATE_FORMAT),l_ACCTNO,'0087',v_dblCACASHQTTY,NULL,l_DFACCTNO,p_txmsg.deltd,l_ACCTNO,seq_DFTRAN.NEXTVAL,p_txmsg.tltxcd,p_txmsg.busdate,'' || '' || '');

        INSERT INTO DFTRAN(TXNUM,TXDATE,ACCTNO,TXCD,NAMT,CAMT,ACCTREF,DELTD,REF,AUTOID,TLTXCD,BKDATE,TRDESC)
        VALUES (p_txmsg.txnum, TO_DATE (p_txmsg.txdate, systemnums.C_DATE_FORMAT),l_ACCTNO,'0041',v_dblRCVQTTY,NULL,l_DFACCTNO,p_txmsg.deltd,l_ACCTNO,seq_DFTRAN.NEXTVAL,p_txmsg.tltxcd,p_txmsg.busdate,'' || '' || '');

        INSERT INTO DFTRAN(TXNUM,TXDATE,ACCTNO,TXCD,NAMT,CAMT,ACCTREF,DELTD,REF,AUTOID,TLTXCD,BKDATE,TRDESC)
        VALUES (p_txmsg.txnum, TO_DATE (p_txmsg.txdate, systemnums.C_DATE_FORMAT),l_ACCTNO,'0011',v_dblAVLQTTY,NULL,l_DFACCTNO,p_txmsg.deltd,l_ACCTNO,seq_DFTRAN.NEXTVAL,p_txmsg.tltxcd,p_txmsg.busdate,'' || '' || '');

        INSERT INTO DFTRAN(TXNUM,TXDATE,ACCTNO,TXCD,NAMT,CAMT,ACCTREF,DELTD,REF,AUTOID,TLTXCD,BKDATE,TRDESC)
        VALUES (p_txmsg.txnum, TO_DATE (p_txmsg.txdate, systemnums.C_DATE_FORMAT),l_ACCTNO,'0016',l_QTTY,NULL,l_DFACCTNO,p_txmsg.deltd,l_ACCTNO,seq_DFTRAN.NEXTVAL,p_txmsg.tltxcd,p_txmsg.busdate,'' || '' || '');


            plog.debug(pkgctx,'END UPDATE DFMAST ' || l_count || ' ' || l_ACCTNO);

        end if;

        V_STRXML:= substr(V_STRXML,instr(V_STRXML,'@',1,1)+1);
        plog.debug(pkgctx,'END FOR ' || l_count || ' ' || V_STRXML);
    end loop;

    p_err_code:=0;
    plog.setendsection(pkgctx, 'pr_TransSEToOtherGrpDeal');
  EXCEPTION
  WHEN OTHERS
   THEN
      plog.debug (pkgctx,'got error on pr_TransSEToOtherGrpDeal');
      ROLLBACK;
      p_err_code := errnums.C_SYSTEM_ERROR;
      plog.error (pkgctx, SQLERRM);
      plog.debug(pkgctx,'pr_TransSEToOtherGrpDeal: ' || dbms_utility.format_error_backtrace);
      plog.setendsection (pkgctx, 'pr_TransSEToOtherGrpDeal');
      RAISE errnums.E_SYSTEM_ERROR;
  END pr_TransSEToOtherGrpDeal;




FUNCTION fn_OpenDealGrpAccount(p_txmsg in tx.msg_rectype,p_err_code out varchar2)
RETURN NUMBER
IS
    v_blnREVERSAL boolean;
    l_lngErrCode    number(20,0);
    v_strgroupid  varchar2(30);
    v_stractype varchar2(10);
    v_strAFACCTNO varchar2(10);
    v_strAUTODRAWNDOWN number;
    v_strAUTOPAID varchar2(10);
    v_strLIMITCHECK varchar2(10);
    v_strRRTYPE varchar2(10);
    v_strDFTYPE varchar2(10);
    v_strCODEID varchar2(10);
    v_strSEACCTNO varchar2(20);
    v_dblIRATE number;
    v_dblMRATE number;
    v_dblLRATE number;
    v_dblORGAMT number;
    v_dblARATE number;
    v_dblALRATE number;
    v_dblQTTY number;
    v_dblDFRATE number;
    v_dblDFPRICE number;
    v_dblAMT number;
    v_strRRID varchar2(20);
    v_strSTATUS varchar2(2) ;
    v_strDEALTYPE varchar2(2) ;
    v_strACCTNO varchar2(20);
    v_strdec varchar(500);
    v_DBLCOUNTdfgropid  number;
    v_strLNACCTNO  varchar2(20);
    v_strLNTYPE varchar2(20);
    v_strORDERID varchar2(20);
    v_dblCISVRFEE number;
    v_dblAMTMIN number;
    v_dblTAX number;
    v_dblFEEMIN number;
    v_dblFEE number;
    v_dblRCVQTTY number;
    v_dblCARCVQTTY number;
    v_dblBLOCKQTTY number;
    v_dblAVLQTTY NUMBER;
    v_dbLCACASHQTTY NUMBER;
    v_strCUSTBANK varchar2(20);
    v_strCIACCTNO varchar2(20);
    v_dblRemainRCVQTTY number(20,4);
    v_dblExecRCVQTTY number(20,4);
    v_dblReleaseAMT number(20,4);
    v_dbltriggerprice number(20,4);
    v_strcalltype varchar2(20);
    v_dbldtlirate  number(20,4);
    v_dbldtlmrate  number(20,4);
    v_dbldtllrate  number(20,4);
    v_strAFACCTNODRD varchar2(20);

BEGIN
    plog.setbeginsection (pkgctx, 'fn_OpenDealgrpAccount');
    plog.debug (pkgctx, '<<BEGIN OF fn_OpenDealgrpAccount');
   /***************************************************************************************************
    ** PUT YOUR SPECIFIC AFTER PROCESS HERE. DO NOT COMMIT/ROLLBACK HERE, THE SYSTEM WILL DO IT
    ***************************************************************************************************/
    l_lngErrCode:= errnums.C_BIZ_RULE_INVALID;
    p_err_code:=0;
    v_strgroupid:=p_txmsg.txfields('20').value;
    v_stractype:=p_txmsg.txfields('04').value;
    v_strAFACCTNO:=p_txmsg.txfields('03').value;
    v_strAUTODRAWNDOWN:=p_txmsg.txfields('16').value;
    v_strAUTOPAID:=p_txmsg.txfields('17').value;
    v_strDEALTYPE:=p_txmsg.txfields('18').value;
    v_strLIMITCHECK:=p_txmsg.txfields('99').value;
    v_strRRTYPE:=p_txmsg.txfields('15').value;
    v_strDFTYPE:=p_txmsg.txfields('06').value;
    v_strCODEID:=p_txmsg.txfields('01').value;
    v_strSEACCTNO:=p_txmsg.txfields('05').value;
    v_dblIRATE:=p_txmsg.txfields('14').value;
    v_dblMRATE:=p_txmsg.txfields('08').value;
    v_dblLRATE:=p_txmsg.txfields('09').value;
    v_dblORGAMT:=p_txmsg.txfields('41').value;
    v_dblQTTY:=p_txmsg.txfields('40').value;
    v_dbLCACASHQTTY:=p_txmsg.txfields('55').value;
    v_dblAVLQTTY:=p_txmsg.txfields('12').value;
    v_dblRCVQTTY :=p_txmsg.txfields('13').value;
    v_dblBLOCKQTTY:=p_txmsg.txfields('22').value;
    v_dblCARCVQTTY:=p_txmsg.txfields('23').value;
    v_dblDFRATE:=p_txmsg.txfields('07').value;
    v_dblDFPRICE:=p_txmsg.txfields('10').value;
    v_dblAMT:=p_txmsg.txfields('42').value;
    v_strRRID:=p_txmsg.txfields('50').value;
    v_strdec:=p_txmsg.txfields('30').value;
    v_strAFACCTNODRD :=p_txmsg.txfields('21').value;

select lntype into v_strLNTYPE from dftype  where actype =v_stractype;


    v_blnREVERSAL:=case when p_txmsg.deltd ='Y' then true else false end;
    if not v_blnREVERSAL then
        if p_txmsg.txfields('16').value='1' then
            v_strSTATUS:= 'A';
        else
            v_strSTATUS:= 'P';
        end if;

        v_dblAMT:=round(v_dblAMT,0);
        SELECT SEQ_DFMAST.NEXTVAL DFACCTNO
            into v_strACCTNO
        FROM DUAL;
       -- v_strACCTNO:=p_txmsg.txfields('02').value;
      --  if v_strACCTNO is null or length(v_strACCTNO)=0 then
            v_strACCTNO:=substr('000000' || v_strACCTNO,length('000000' || v_strACCTNO)-5,6);
            v_strACCTNO:=p_txmsg.brid || substr(to_char(p_txmsg.txdate,systemnums.c_date_format),1,2)
                                  || substr(to_char(p_txmsg.txdate,systemnums.c_date_format),4,2)
                                  || substr(to_char(p_txmsg.txdate,systemnums.c_date_format),9,2)
                                  || v_strACCTNO;
       -- end if;
        begin
          SELECT LNT.RRTYPE,DFT.DFTYPE,LNT.CUSTBANK,LNT.CIACCTNO,DFT.LNTYPE,DFT.FEE,DFT.FEEMIN,DFT.TAX,DFT.AMTMIN,DFT.CISVRFEE, DFT.LRATE, DFT.MRATE, DFT.IRATE, DFT.ARATE, DFT.ALRATE
            into    v_strRRTYPE,v_strDFTYPE,v_strCUSTBANK,v_strCIACCTNO,v_strLNTYPE,v_dblFEE,v_dblFEEMIN,v_dblTAX,v_dblAMTMIN,v_dblCISVRFEE,v_dblLRATE, v_dblMRATE, v_dblIRATE,v_dblARATE, v_dblALRATE
            FROM DFTYPE DFT, LNTYPE LNT WHERE DFT.LNTYPE = LNT.ACTYPE AND DFT.ACTYPE =p_txmsg.txfields('04').value;

        exception
        when others then
            plog.error(pkgctx,'l_lngErrCode: ' || errnums.C_DF_ACTYPE_NOTFOUND);
            p_err_code :=errnums.C_DF_ACTYPE_NOTFOUND;
            return l_lngErrCode;
        end;
          -- Kiem tra da co chua

        plog.debug (pkgctx, 'OPENDFGROUP_ACTYPE: ' || p_txmsg.txfields('04').value || ' DFT.LRATE, DFT.MRATE, DFT.IRATE ' || v_dblLRATE || v_dblMRATE || v_dblIRATE );

        if p_err_code <> 0 then
            p_err_code :=errnums.C_DF_LNSCHD_CANNOT_CREATE;
            return -1; --Co loi xay ra
        end if;


        If v_strDFTYPE = 'M' Then

            --Neu la cam co thi khong giai ngan va chuyen trang thai thanh N: Cho send len trung tam luu ky
            v_dblAMT := 0;
            v_strStatus := 'N';
        End If;

        --2.Open DFGROUP

          select  COUNT(groupid) into v_DBLCOUNTdfgropid from dfgroup where groupid =v_strgroupid;

        if v_DBLCOUNTdfgropid=0 then
        --TAO TAI KHOAN VAY LN
            v_strLNACCTNO:=CSPKS_LNPROC.fn_OpenLoanAccount( NVL(v_strAFACCTNODRD,p_txmsg.txfields('03').value),v_strLNTYPE,p_err_code);

        insert into dfgroup (groupid,actype,afacctno,lnacctno,dftype,flagtrigger,limitchk,custbank,rrtype,ciacctno,status,rlsfeeamt,feeamt,intamtacr,orgamt,amt,rlsamt,dfamt,calltype,lrate,mrate,irate,ARATE,ALRATE,amtmin,tax,feemin,fee,lntype,txtime,txdate,autopaid,description)
        values (v_strgroupid,v_stractype,v_strAFACCTNODRD,v_strLNACCTNO,v_strDFTYPE,'N',v_strLIMITCHECK, v_strCUSTBANK,v_strRRTYPE,v_strCIACCTNO,'N',0,0,0,v_dblORGAMT,0,0,0,'P',v_dblLRATE,v_dblMRATE,v_dblIRATE,v_dblARATE,v_dblALRATE,v_dblAMTMIN,v_dblTAX ,v_dblFEEMIN,v_dblFEE,v_strLNTYPE,p_txmsg.txnum,p_txmsg.txdate ,v_strAUTOPAID, v_strdec );

        end if;

select lnacctno into v_strLNACCTNO from dfgroup where  groupid=v_strgroupid;

        --2.Create loan schedule
      /*  if v_dblAMT>0 then

            l_lngErrCode:=CSPKS_LNPROC.fn_CreateLoanSchedule(v_strLNACCTNO,v_dblAMT,p_err_code);
            if l_lngErrCode <> 0 then
                plog.error(pkgctx,'l_lngErrCode: ' || errnums.C_DF_LNSCHD_CANNOT_CREATE);
                p_err_code :=errnums.C_DF_LNSCHD_CANNOT_CREATE;
                return l_lngErrCode;
            end if;
        end if;*/

        -- LAY THONG TIN DF CHI TIET

        plog.debug (pkgctx,'LOAD PARAM 2 ' || v_stractype || ' , ' || v_strCODEID || ' , ' || v_strDEALTYPE );

        SELECT  DFB.triggerprice ,DFB.calltype,DFB.irate, DFB.mrate,dfb.lrate into v_dbltriggerprice ,v_strcalltype ,v_dbldtlirate,v_dbldtlmrate,v_dbldtllrate FROM DFTYPE DF,dfbasket dfb,sbsecurities SB
        WHERE DF.basketid = dfb.basketid and df.actype= v_stractype AND  dfb.symbol=SB.symbol AND SB.CODEID =v_strCODEID AND DFB.DEALTYPE=v_strDEALTYPE ;

        --3. Open DFMAST




         plog.debug (pkgctx,'99:'||p_txmsg.txfields('99').value );
        INSERT INTO DFMAST (
                     ACCTNO, AFACCTNO, LNACCTNO, TXDATE, TXNUM, TXTIME,
                     ACTYPE, RRTYPE, DFTYPE, CUSTBANK,CIACCTNO, LNTYPE, FEE,
                     FEEMIN, TAX, AMTMIN, CODEID, REFPRICE, DFPRICE,
                     TRIGGERPRICE, DFRATE, IRATE, MRATE, LRATE, CALLTYPE,
                     CACASHQTTY, DFQTTY, BQTTY,RCVQTTY,BLOCKQTTY,CARCVQTTY, RLSQTTY, DFAMT, RLSAMT, AMT,
                     INTAMTACR, FEEAMT, RLSFEEAMT, STATUS, DFREF,DESCRIPTION,LIMITCHK,CISVRFEE,GROUPID,DEALTYPE,INITASSETQTTY,ARATE,ALRATE)
              VALUES
                     ( v_strACCTNO ,v_strAFACCTNO, v_strLNACCTNO, to_date(p_txmsg.txdate,systemnums.c_date_format), p_txmsg.txnum, p_txmsg.txtime,
                      v_stractype, v_strRRTYPE, v_strDFTYPE, v_strCUSTBANK,v_strCIACCTNO, v_strLNTYPE,  v_dblFEE ,
                      v_dblFEEMIN ,  v_dblTAX ,  v_dblAMTMIN ,v_strCODEID,  v_dblDFPRICE*100/v_dblDFRATE ,  v_dblDFPRICE ,
                      v_dblDFPRICE*v_dbldtllrate/v_dblDFRATE  , v_dblDFRATE  , v_dbldtlirate ,v_dbldtlmrate   ,  v_dbldtllrate ,v_strcalltype,
                      v_dbLCACASHQTTY,v_dblAVLQTTY ,0, v_dblRCVQTTY , v_dblBLOCKQTTY , v_dblCARCVQTTY, 0, 0, 0,  v_dblAMT ,
                     0, 0, 0, 'A', p_txmsg.txfields('29').value,p_txmsg.txfields('30').value,v_strLIMITCHECK,v_dblCISVRFEE,v_strgroupid,v_strDEALTYPE,
                     v_dblAVLQTTY + v_dblRCVQTTY + v_dblBLOCKQTTY,v_dblARATE, v_dblALRATE );
                     -- HaiLT cap nhap them truong INITASSETQTTY
-- cho nhan ve

           If p_txmsg.txfields('13').value > 0 Then
            v_strORDERID:='orderid';
            begin
                select orgorderid into v_strORDERID from stschd where autoid=p_txmsg.txfields('29').value;
                --update odmast set dfqtty =dfqtty + p_txmsg.txfields('13').value,LAST_CHANGE = SYSTIMESTAMP where orderid =v_strORDERID;
            exception when others then
                v_strORDERID:='orderid';
            end;

            --- Chung khoan cho ve
            v_dblRemainRCVQTTY:= p_txmsg.txfields('13').value;
            v_dblExecRCVQTTY:=0;
            v_dblReleaseAMT:=0;
            FOR rec_rcvdf IN
            (
            SELECT *
            FROM stschd
            WHERE qtty - aqtty > 0 and (to_char(txdate,'DD/MM/YYYY') || afacctno || codeid || to_char(clearday)) = p_txmsg.txfields('29').value
            and duetype ='RS' and status <> 'C' AND deltd <> 'Y'
            order BY autoid
            )
            LOOP
                v_dblExecRCVQTTY:= least(v_dblRemainRCVQTTY, rec_rcvdf.QTTY - rec_rcvdf.AQTTY);
                update odmast set dfqtty = dfqtty + v_dblExecRCVQTTY where orderid = rec_rcvdf.ORGORDERID;
                update stschd set aqtty = aqtty + v_dblExecRCVQTTY where autoid = rec_rcvdf.autoid;
                INSERT INTO stdfmap (stschdid, dfacctno, dfqtty, rlsamt,status, deltd, txdate,adfqtty)
                    VALUES(rec_rcvdf.AUTOID,v_strACCTNO,v_dblExecRCVQTTY,
                    CASE WHEN v_dblExecRCVQTTY < v_dblRemainRCVQTTY THEN round(p_txmsg.txfields('41').value/p_txmsg.txfields('13').value,0) * v_dblExecRCVQTTY
                    ELSE p_txmsg.txfields('41').value - v_dblReleaseAMT END,
                    'A','N',to_date(p_txmsg.txdate,'DD/MM/RRRR'),v_dblExecRCVQTTY);

                v_dblReleaseAMT:= v_dblReleaseAMT + (p_txmsg.txfields('41').value / p_txmsg.txfields('13').value) * v_dblExecRCVQTTY;
                v_dblRemainRCVQTTY:= v_dblRemainRCVQTTY - v_dblExecRCVQTTY;
                If v_dblRemainRCVQTTY = 0 Then
                    EXIT;
                End IF;
            END LOOP;
            --UPDATE STSCHD SET AQTTY= AQTTY + p_txmsg.txfields('13').value WHERE AUTOID=p_txmsg.txfields('29').value;
        End If;


     /*  If v_dblRCVQTTY > 0 Then
            v_strORDERID:='orderid';
            begin
                select orgorderid into v_strORDERID from stschd where autoid=p_txmsg.txfields('29').value;
                update odmast set dfqtty =dfqtty + p_txmsg.txfields('13').value,LAST_CHANGE = SYSTIMESTAMP where orderid =v_strORDERID;
            exception when others then
                v_strORDERID:='orderid';
            end;
            UPDATE STSCHD SET AQTTY= AQTTY + p_txmsg.txfields('13').value WHERE AUTOID=p_txmsg.txfields('29').value;
        End If;*/

        -- Chung khoan quyen cho ve
        If p_txmsg.txfields('23').value > 0 Then
            UPDATE CASCHD SET DFQTTY= DFQTTY + p_txmsg.txfields('23').value WHERE AUTOID=p_txmsg.txfields('29').value;
        End If;

        -- CA Tien cho ve
        If p_txmsg.txfields('55').value > 0 Then
            UPDATE CASCHD SET DFAMT= DFAMT + p_txmsg.txfields('55').value WHERE AUTOID=p_txmsg.txfields('29').value;
            UPDATE CIMAST SET RECEIVING= RECEIVING - p_txmsg.txfields('55').value WHERE ACCTNO= v_strAFACCTNO;
        End If;
        plog.debug (pkgctx,'UPDATE SEMASTDTL.DFQTTY ' || p_txmsg.txfields('22').value || ' ' || v_strAFACCTNO||v_strCODEID );

       /* If p_txmsg.txfields('22').value > 0 Then
            UPDATE SEMASTDTL SET DFQTTY= DFQTTY + p_txmsg.txfields('22').value
            WHERE acctno= v_strAFACCTNO||v_strCODEID
            AND TXNUM || to_char(TXDATE,'dd/mm/rrrr')=p_txmsg.txfields('29').value;
        End If;*/

    else
        select lnacctno
        into v_strLNACCTNO
        from dfmast
        where txnum = p_txmsg.txnum and txdate = to_date(p_txmsg.txdate,systemnums.c_date_format);

        delete from lnschd where acctno =v_strLNACCTNO;
        delete from lnmast where acctno =v_strLNACCTNO;
        delete from dfmast
        where txnum = p_txmsg.txnum and txdate = to_date(p_txmsg.txdate,systemnums.c_date_format);
        If p_txmsg.txfields('13').value > 0 Then
            v_strORDERID:='orderid';
            begin
                select orgorderid into v_strORDERID from stschd where autoid=p_txmsg.txfields('29').value;
                update odmast set dfqtty =dfqtty - p_txmsg.txfields('13').value where orderid =v_strORDERID;
            exception when others then
                v_strORDERID:='orderid';
            end;
            UPDATE STSCHD SET AQTTY= AQTTY - p_txmsg.txfields('13').value WHERE AUTOID=p_txmsg.txfields('29').value;
        End If;
        If p_txmsg.txfields('23').value > 0 Then
            UPDATE CASCHD SET DFQTTY= DFQTTY - p_txmsg.txfields('23').value WHERE AUTOID=p_txmsg.txfields('29').value;
        End If;
                -- CA Tien cho ve
        If p_txmsg.txfields('55').value > 0 Then
            UPDATE CASCHD SET DFAMT= DFAMT - p_txmsg.txfields('55').value WHERE AUTOID=p_txmsg.txfields('29').value;
        End If;
      /*  If p_txmsg.txfields('22').value > 0 Then
            UPDATE SEMASTDTL SET DFQTTY= DFQTTY - p_txmsg.txfields('22').value
            WHERE TXNUM || to_char(TXDATE,'dd/mm/rrrr')=p_txmsg.txfields('29').value
            AND acctno=v_strAFACCTNO||v_strCODEID;
        end if;*/
    end if; --end v_blnREVERSAL

    plog.debug (pkgctx, '<<END OF fn_OpenDealAccount');
    plog.setendsection (pkgctx, 'fn_OpenDealAccount');
    RETURN systemnums.C_SUCCESS;
EXCEPTION
WHEN OTHERS
   THEN
      p_err_code := errnums.C_SYSTEM_ERROR;
      plog.error (pkgctx, SQLERRM);
      plog.debug(pkgctx,'FN_OpenDealGrpAccount: ' || dbms_utility.format_error_backtrace);
       plog.setendsection (pkgctx, 'fn_OpenDealAccount');
      RAISE errnums.E_SYSTEM_ERROR;
END fn_OpenDealGrpAccount;



---------------------------------pr_ADVDFPayment------------------------------------------------
  PROCEDURE pr_ADVDFPayment(p_txmsg in tx.msg_rectype,p_stschdid varchar2, p_amt number,p_err_code  OUT varchar2)
  IS
      l_txmsg               tx.msg_rectype;
      v_strCURRDATE varchar2(20);
      v_strDesc varchar2(1000);
      v_strEN_Desc varchar2(1000);
      v_blnVietnamese BOOLEAN;
      l_err_param varchar2(300);
      l_MaxRow NUMBER(20,0);
      v_dblPPRINOVD number(20,0);
      v_dblPPRINNML number(20,0);
      v_dblPINTNMLOVD number(20,0);
      v_dblPINTOVDACR number(20,4);
      v_dblPINTDUE number(20,0);
      v_dblPINTNMLACR number(20,4);
      v_dblPFEEPAID number(20,0);
      v_dblPRINPAIDAMT number(20,0);    --SO TIEN TRA GOC
      v_dblPaidAMT  number(20,0);
      v_feerate number;
      --CONG THUC
      v_dbl001RATIO number(20,4);       --TY LE PHAN BO
      v_dbl001PRINAMT number(20,4);     --VINHLD THEM DE XAC DINH GOC TRA CHO NINTCD=001
      v_dbl001INTAMT number(20,4);      --VINHLD THEM DE XAC DINH LAI TRA CHO NINTCD=001

  BEGIN
    plog.setbeginsection(pkgctx, 'pr_ADVDFPayment');
    SELECT TXDESC,EN_TXDESC into v_strDesc, v_strEN_Desc FROM  TLTX WHERE TLTXCD='2643';
     SELECT varvalue
         INTO v_strCURRDATE
         FROM sysvar
         WHERE grname = 'SYSTEM' AND varname = 'CURRDATE';
    l_txmsg.msgtype:='T';
    l_txmsg.local:='N';
    plog.debug (pkgctx, 'begin 2643');
    --l_txmsg.tlid        := systemnums.c_system_userid;
    begin
        plog.debug (pkgctx, 'p_txmsg.TLID' || p_txmsg.TLID);
        l_txmsg.tlid        := p_txmsg.TLID;
    exception when others then
        l_txmsg.tlid        := systemnums.c_system_userid;
    end;
    SELECT SYS_CONTEXT ('USERENV', 'HOST'),
             SYS_CONTEXT ('USERENV', 'IP_ADDRESS', 15)
      INTO l_txmsg.wsname, l_txmsg.ipaddress
    FROM DUAL;
    l_txmsg.off_line    := 'N';
    l_txmsg.deltd       := txnums.c_deltd_txnormal;
    l_txmsg.txstatus    := txstatusnums.c_txcompleted;
    l_txmsg.msgsts      := '0';
    l_txmsg.ovrsts      := '0';
    --l_txmsg.batchname   := 'DAY';
    begin
        l_txmsg.batchname        := p_txmsg.txnum;
        plog.debug (pkgctx, 'p_txmsg.txnum' || p_txmsg.txnum);
    exception when others then
        l_txmsg.batchname        := 'DAY';
    end;
    l_txmsg.txdate:=to_date(v_strCURRDATE,systemnums.c_date_format);
    l_txmsg.tltxcd:='2643';
    for rec in
    (
        --VINHLD: LAY THEM NINTCD PHUONG PHAP TINH LAI
        --000. TRA LAI THEO TINH LAI CONG DON
        --001. TRA LAI THEO CACH TINH TREN CO SO GOC TRA.
        --Phan bo phi cung theo ty le nhu goc voi NINTCD=001
        --dealfee de dung xac dinh so phan bo phi,lai
        select df.FULLNAME, df.ADDRESS,df.IDCODE,df.RRID,df.codeid,
            df.CIDRAWNDOWN,df.BANKDRAWNDOWN,df.CMPDRAWNDOWN,df.LIMITCHECK,df.acctno,df.bqtty ,
            DF.NINTCD, df.dealfee, df.lnacctno, df.afacctno, df.LNTYPE,sts.qtty-sts.aqtty qtty,
            sts.autoid, df.odamt,
            df.dealfeerate,df.dealprinamt,
            df.PRINTFRQ1, df.rate1, df.PRINTFRQ2, df.rate2, df.PRINTFRQ3, df.rate3, df.rlsdate,
            df.PRINOVD,df.PRINNML,df.INTNMLOVD,df.INTOVDACR,df.INTDUE,df.INTNMLACR,df.AVLFEEAMT FEEPAID,
            round((sts.qtty-sts.aqtty + df.rlsqtty) * df.amt/(df.remainqtty + df.rlsqtty)
                          -df.rlsamt + df.dealfee,4) paidamt,
            'Thanh toan ' || df.description Des
        from stschd sts ,odmast od ,v_getDealInfo df
        where sts.orgorderid = od.orderid --and sts.qtty-sts.aqtty>0
        and od.dfacctno =df.acctno and sts.status<>'C' and sts.DUETYPE='RM'
        and od.exectype ='MS' and sts.autoid =p_stschdid
    )
    loop
     --Set txnum
        SELECT systemnums.C_BATCH_PREFIXED
                         || LPAD (seq_BATCHTXNUM.NEXTVAL, 8, '0')
                  INTO l_txmsg.txnum
                  FROM DUAL;
        begin
            l_txmsg.brid        := p_txmsg.BRID;
        exception when others then
            l_txmsg.brid        := substr(rec.AFACCTNO,1,4);
        end;

        --p_amt: maximum la tra het
        --XAC DINH TY LE PHAN BO CHO LOAI 001
        /*IF rec.NINTCD='001' THEN
           --SO TIEN NAY LA PHAN GOC SE PHAI TRA. PHAN AM SE DUA KHOANH NO. PHAN DUONG SE NHAN TIEN VE
           v_dblPRINPAIDAMT := rec.paidamt-rec.dealfee;
        ELSE
           v_dbl001RATIO :=1;
           v_dblPRINPAIDAMT := rec.paidamt;
        END IF;*/

        v_feerate:=case when rec.dealprinamt+rec.dealfee= 0 then 0 else  p_amt/(rec.dealprinamt+rec.dealfee) end;
        v_dblPRINPAIDAMT := round(p_amt/(1+rec.dealfeerate/100),0);

        --Cac dinh cac gia tri tra no

        /*IF rec.NINTCD='001' THEN
          v_dblPINTNMLOVD:= 0;
          v_dblPINTDUE:=0;
          v_dblPFEEPAID:=0; --N?U C?THU PH?THEO TIER TH?CUNG G?I H?M X? L?T?I ?Y
          v_dblPINTOVDACR:= v_dblPRINPAIDAMT*SP_SBS_CAL_INTOVDDUE(REC.PRINTFRQ3, REC.rate3, REC.rlsdate, TO_DATE(v_strCURRDATE,'DD/MM/RRRR'));
          v_dblPINTOVDACR:= ROUND(v_dblPINTOVDACR,0); --LAM TRON
          v_dblPINTNMLACR:=v_dblPRINPAIDAMT*SP_SBS_CAL_INTDUE(rec.PRINTFRQ1, rec.rate1, rec.PRINTFRQ2, rec.rate2,
                                  rec.PRINTFRQ3, rec.rate3, rec.rlsdate, TO_DATE(v_strCURRDATE,'DD/MM/RRRR'));
          v_dblPINTNMLACR:= ROUND(v_dblPINTNMLACR,0); --LAM TRON
          v_dblPRINPAIDAMT:=v_dblPRINPAIDAMT+v_dblPINTOVDACR+v_dblPINTNMLACR;
        ELSE
          v_dblPINTNMLOVD:= greatest(least (p_amt,rec.INTNMLOVD),0);
          v_dblPINTNMLOVD:= ROUND(v_dblPINTNMLOVD,0); --LAM TRON
          --2.Tra lai cong don qua han
          v_dblPINTOVDACR:= greatest(least (p_amt-v_dblPINTNMLOVD,rec.INTOVDACR),0);
          v_dblPINTOVDACR:= ROUND(v_dblPINTOVDACR,0); --LAM TRON
          --3.Tra lai den han
          v_dblPINTDUE:= greatest(least (p_amt-v_dblPINTNMLOVD-v_dblPINTOVDACR,rec.INTDUE),0);
          v_dblPINTDUE:= ROUND(v_dblPINTDUE,0); --LAM TRON
          --4.Tra lai cong don
          v_dblPINTNMLACR:= greatest(least (p_amt-v_dblPINTNMLOVD-v_dblPINTOVDACR-v_dblPINTDUE,rec.INTNMLACR),0);
          v_dblPINTNMLACR:= ROUND(v_dblPINTNMLACR,0); --LAM TRON
          --5.Tra phi
          v_dblPFEEPAID:= greatest(least (p_amt-v_dblPINTNMLOVD-v_dblPINTOVDACR-v_dblPINTDUE-v_dblPINTNMLACR,rec.FEEPAID),0);
          v_dblPFEEPAID:= ROUND(v_dblPFEEPAID,0); --LAM TRON
        END IF;*/
        --1.Uu tien tra lai qua han
        v_dblPINTNMLOVD:= greatest(least (p_amt,rec.INTNMLOVD*v_feerate,rec.INTNMLOVD),0);
        v_dblPINTNMLOVD:= ROUND(v_dblPINTNMLOVD,0); --LAM TRON
        --2.Tra lai cong don qua han
        v_dblPINTOVDACR:= greatest(least (p_amt-v_dblPINTNMLOVD,rec.INTOVDACR*v_feerate,rec.INTOVDACR),0);
        v_dblPINTOVDACR:= ROUND(v_dblPINTOVDACR,0); --LAM TRON
        --3.Tra lai den han
        v_dblPINTDUE:= greatest(least (p_amt-v_dblPINTNMLOVD-v_dblPINTOVDACR,rec.INTDUE*v_feerate,rec.INTDUE),0);
        v_dblPINTDUE:= ROUND(v_dblPINTDUE,0); --LAM TRON
        --4.Tra lai cong don
        v_dblPINTNMLACR:= greatest(least (p_amt-v_dblPINTNMLOVD-v_dblPINTOVDACR-v_dblPINTDUE,rec.INTNMLACR*v_feerate,rec.INTNMLACR),0);
        v_dblPINTNMLACR:= ROUND(v_dblPINTNMLACR,0); --LAM TRON
        --5.Tra phi
        v_dblPFEEPAID:= greatest(least (p_amt-v_dblPINTNMLOVD-v_dblPINTOVDACR-v_dblPINTDUE-v_dblPINTNMLACR,rec.FEEPAID*v_feerate,rec.FEEPAID),0);
        v_dblPFEEPAID:= ROUND(v_dblPFEEPAID,0); --LAM TRON

        --5.Tra goc qua han
        v_dblPPRINOVD:= greatest(least (p_amt-v_dblPINTNMLOVD-v_dblPINTOVDACR-v_dblPINTDUE-v_dblPINTNMLACR-v_dblPFEEPAID,rec.PRINOVD),0);
        v_dblPPRINOVD:=round(v_dblPPRINOVD,0);
        --6.Tra goc trong han
        v_dblPPRINNML:= greatest(least (p_amt-v_dblPINTNMLOVD-v_dblPINTOVDACR-v_dblPINTDUE-v_dblPINTNMLACR-v_dblPFEEPAID-v_dblPPRINOVD,rec.PRINNML),0);
        v_dblPPRINNML:=round(v_dblPPRINNML,0);
        --Set cac field giao dich
        --01   AUTOID       N
        l_txmsg.txfields ('01').defname   := 'AUTOID';
        l_txmsg.txfields ('01').TYPE      := 'N';
        l_txmsg.txfields ('01').VALUE     := rec.AUTOID;
        --02   ACCTNO       C
        l_txmsg.txfields ('02').defname   := 'ACCTNO';
        l_txmsg.txfields ('02').TYPE      := 'C';
        l_txmsg.txfields ('02').VALUE     := rec.ACCTNO;
        --03   LNACCTNO     C
        l_txmsg.txfields ('03').defname   := 'LNACCTNO';
        l_txmsg.txfields ('03').TYPE      := 'C';
        l_txmsg.txfields ('03').VALUE     := rec.lnacctno;
        --05   AFACCTNO     C
        l_txmsg.txfields ('05').defname   := 'AFACCTNO';
        l_txmsg.txfields ('05').TYPE      := 'C';
        l_txmsg.txfields ('05').VALUE     := rec.AFACCTNO;
        --06   SEACCTNO     C
        l_txmsg.txfields ('06').defname   := 'SEACCTNO';
        l_txmsg.txfields ('06').TYPE      := 'C';
        l_txmsg.txfields ('06').VALUE     := rec.AFACCTNO || rec.codeid;
        --07   LNTYPE       C
        l_txmsg.txfields ('07').defname   := 'LNTYPE';
        l_txmsg.txfields ('07').TYPE      := 'C';
        l_txmsg.txfields ('07').VALUE     := rec.LNTYPE;
        --10   QTTY       N
        l_txmsg.txfields ('10').defname   := 'QTTY';
        l_txmsg.txfields ('10').TYPE      := 'N';
        l_txmsg.txfields ('10').VALUE     := rec.QTTY;
        --41   ODAMT          N
        l_txmsg.txfields ('41').defname   := 'ODAMT';
        l_txmsg.txfields ('41').TYPE      := 'N';
        l_txmsg.txfields ('41').VALUE     := round(rec.ODAMT,0);
        --45   AMT          N
        l_txmsg.txfields ('45').defname   := 'AMT';
        l_txmsg.txfields ('45').TYPE      := 'N';
        l_txmsg.txfields ('45').VALUE     := round(p_amt/(1+rec.dealfeerate/100),0);--v_dblPRINPAIDAMT;  --VinhLD bo rec.paidamt
        --63   PPRINOVD     N
        l_txmsg.txfields ('63').defname   := 'PPRINOVD';
        l_txmsg.txfields ('63').TYPE      := 'N';
        l_txmsg.txfields ('63').VALUE     := v_dblPPRINOVD;
        --65   PPRINNML     N
        l_txmsg.txfields ('65').defname   := 'PPRINNML';
        l_txmsg.txfields ('65').TYPE      := 'N';
        l_txmsg.txfields ('65').VALUE     := v_dblPPRINNML;
        --72   PINTNMLOVD   N
        l_txmsg.txfields ('72').defname   := 'PINTNMLOVD';
        l_txmsg.txfields ('72').TYPE      := 'N';
        l_txmsg.txfields ('72').VALUE     := v_dblPINTNMLOVD;
        --74   PINTOVDACR   N
        l_txmsg.txfields ('74').defname   := 'PINTOVDACR';
        l_txmsg.txfields ('74').TYPE      := 'N';
        l_txmsg.txfields ('74').VALUE     := v_dblPINTOVDACR;
        --77   PINTDUE      N
        l_txmsg.txfields ('77').defname   := 'PINTDUE';
        l_txmsg.txfields ('77').TYPE      := 'N';
        l_txmsg.txfields ('77').VALUE     := v_dblPINTDUE;
        --80   PINTNMLACR   N
        l_txmsg.txfields ('80').defname   := 'PINTNMLACR';
        l_txmsg.txfields ('80').TYPE      := 'N';
        l_txmsg.txfields ('80').VALUE     := v_dblPINTNMLACR;
        --90   PFEEPAID     N
        l_txmsg.txfields ('90').defname   := 'PFEEPAID';
        l_txmsg.txfields ('90').TYPE      := 'N';
        l_txmsg.txfields ('90').VALUE     := v_dblPFEEPAID;
        --30   C   DESC
        l_txmsg.txfields ('30').defname   := 'DESC';
        l_txmsg.txfields ('30').TYPE      := 'C';
        l_txmsg.txfields ('30').VALUE := rec.Des;

        --94    SERLS           C
        l_txmsg.txfields ('94').defname   := 'SERLS';
        l_txmsg.txfields ('94').TYPE      := 'C';
        l_txmsg.txfields ('94').VALUE := 0;
        --95    RRID            C
        l_txmsg.txfields ('95').defname   := 'RRID';
        l_txmsg.txfields ('95').TYPE      := 'C';
        l_txmsg.txfields ('95').VALUE := rec.RRID;
        --96    CIDRAWNDOWN     C
        l_txmsg.txfields ('96').defname   := 'CIDRAWNDOWN';
        l_txmsg.txfields ('96').TYPE      := 'C';
        l_txmsg.txfields ('96').VALUE := rec.CIDRAWNDOWN;
        --97    BANKDRAWNDOWN   C
        l_txmsg.txfields ('97').defname   := 'BANKDRAWNDOWN';
        l_txmsg.txfields ('97').TYPE      := 'C';
        l_txmsg.txfields ('97').VALUE := rec.BANKDRAWNDOWN;
        --98    CMPDRAWNDOWN    C
        l_txmsg.txfields ('98').defname   := 'CMPDRAWNDOWN';
        l_txmsg.txfields ('98').TYPE      := 'C';
        l_txmsg.txfields ('98').VALUE := rec.CMPDRAWNDOWN;
        --99    LIMITCHECK      C
        l_txmsg.txfields ('99').defname   := 'LIMITCHECK';
        l_txmsg.txfields ('99').TYPE      := 'C';
        l_txmsg.txfields ('99').VALUE := rec.LIMITCHECK;

        --57    CUSTNAME    C
        l_txmsg.txfields ('57').defname   := 'CUSTNAME';
        l_txmsg.txfields ('57').TYPE      := 'C';
        l_txmsg.txfields ('57').VALUE := rec.FULLNAME;
        --58    ADDRESS     C
        l_txmsg.txfields ('58').defname   := 'ADDRESS';
        l_txmsg.txfields ('58').TYPE      := 'C';
        l_txmsg.txfields ('58').VALUE := rec.ADDRESS;
        --59    LICENSE     C
        l_txmsg.txfields ('59').defname   := 'LICENSE';
        l_txmsg.txfields ('59').TYPE      := 'C';
        l_txmsg.txfields ('59').VALUE := rec.IDCODE;



        BEGIN
            IF txpks_#2643.fn_batchtxprocess (l_txmsg,
                                             p_err_code,
                                             l_err_param
               ) <> systemnums.c_success
            THEN
               plog.debug (pkgctx,
                           'got error 2643: ' || p_err_code
               );
               ROLLBACK;
               RETURN;
            END IF;
        END;
    end loop;
    p_err_code:=0;
    plog.setendsection(pkgctx, 'pr_ADVDFPayment');
  EXCEPTION
  WHEN OTHERS
   THEN
      plog.debug (pkgctx,'got error on pr_ADVDFPayment');
      ROLLBACK;
      p_err_code := errnums.C_SYSTEM_ERROR;
      plog.error (pkgctx, SQLERRM);
      plog.setendsection (pkgctx, 'pr_ADVDFPayment');
      RAISE errnums.E_SYSTEM_ERROR;
  END pr_ADVDFPayment;


---------------------------------pr_DealAutoPayment------------------------------------------------
  PROCEDURE pr_DealAutoPayment(p_txmsg in tx.msg_rectype,p_dealID varchar2,p_autoid varchar2, p_qtty number, p_serls number,p_amt out number,p_err_code  OUT varchar2)
  IS
      l_txmsg               tx.msg_rectype;
      v_strCURRDATE varchar2(20);
      v_strDesc varchar2(1000);
      v_strEN_Desc varchar2(1000);
      v_blnVietnamese BOOLEAN;
      l_err_param varchar2(300);
      v_strINTPAIDMETHOD varchar2(1);
      l_MaxRow NUMBER(20,0);
      v_dblPPRINOVD number(20,0);
      v_dblPPRINNML number(20,0);
      v_dblPINTNMLOVD number(20,0);
      v_dblPINTOVDACR number(20,0);
      v_dblPINTDUE number(20,0);
      v_dblPINTNMLACR number(20,4);
      v_dblPFEEPAID number(20,0);
      v_dblPRINPAIDAMT number(20,0);    --SO TIEN TRA GOC
      v_feerate number;
      --CONG THUC
      v_dbl001RATIO number(20,4);       --TY LE PHAN BO
      v_dbl001PRINAMT number(20,4);     --VINHLD THEM DE XAC DINH GOC TRA CHO NINTCD=001
      v_dbl001INTAMT number(20,4);      --VINHLD THEM DE XAC DINH LAI TRA CHO NINTCD=001

      v_debtamt number;
      v_advamt number;
      v_CurAmt number;
      v_IntAmt number;
      v_FeeAmt number;
      l_baldefovd number;
      l_advminbal number;
  BEGIN
    plog.setbeginsection(pkgctx, 'pr_ADVDFPayment');
    SELECT TXDESC,EN_TXDESC into v_strDesc, v_strEN_Desc FROM  TLTX WHERE TLTXCD='2643';
     SELECT varvalue
         INTO v_strCURRDATE
         FROM sysvar
         WHERE grname = 'SYSTEM' AND varname = 'CURRDATE';
    l_txmsg.msgtype:='T';
    l_txmsg.local:='N';
    begin
        l_txmsg.tlid        := p_txmsg.TLID;
    exception when others then
        l_txmsg.tlid        := systemnums.c_system_userid;
    end;
    SELECT SYS_CONTEXT ('USERENV', 'HOST'),
             SYS_CONTEXT ('USERENV', 'IP_ADDRESS', 15)
      INTO l_txmsg.wsname, l_txmsg.ipaddress
    FROM DUAL;
    l_txmsg.off_line    := 'N';
    l_txmsg.deltd       := txnums.c_deltd_txnormal;
    l_txmsg.txstatus    := txstatusnums.c_txcompleted;
    l_txmsg.msgsts      := '0';
    l_txmsg.ovrsts      := '0';
    begin
        l_txmsg.batchname   := p_txmsg.TXNUM;
    exception when others then
        l_txmsg.batchname   := 'DLPM';
    end;

    l_txmsg.txdate:=to_date(v_strCURRDATE,systemnums.c_date_format);
    l_txmsg.tltxcd:='2643';
    for rec in
    (
        select df.FULLNAME, df.ADDRESS,df.IDCODE,df.RRID, df.CIDRAWNDOWN,df.BANKDRAWNDOWN,
            df.CMPDRAWNDOWN,df.LIMITCHECK,df.acctno,df.bqtty ,df.lnacctno,df.afacctno,df.codeid,
            DF.NINTCD, df.dealfee, df.LNTYPE,p_qtty qtty,df.odamt,
            df.dealfeerate,df.dealprinamt,
            df.PRINTFRQ1, df.rate1, df.PRINTFRQ2, df.rate2, df.PRINTFRQ3, df.rate3, df.rlsdate,
            df.PRINOVD,df.PRINNML,df.INTNMLOVD,df.INTOVDACR,df.INTDUE,df.INTNMLACR,df.AVLFEEAMT FEEPAID,
            greatest((p_qtty + df.rlsqtty) * df.amt/(df.remainqtty + df.rlsqtty)
                          -df.rlsamt + df.dealfee,0) paidamt,
            'Thanh toan ' || df.description Des, grp.afacctno AFACCTNODRD, grp.groupid
        from v_getDealInfo df, dfgroup grp
        where acctno=p_dealID and df.groupid= grp.groupid
    )
    loop
     --Set txnum
        SELECT systemnums.C_BATCH_PREFIXED
                         || LPAD (seq_BATCHTXNUM.NEXTVAL, 8, '0')
                  INTO l_txmsg.txnum
                  FROM DUAL;
        --l_txmsg.brid        := substr(rec.AFACCTNO,1,4);
        begin
            l_txmsg.brid        := p_txmsg.BRID;
        exception when others then
            l_txmsg.brid        := substr(rec.AFACCTNO,1,4);
        end;

        --p_amt: maximum la tra het
        --XAC DINH TY LE PHAN BO CHO LOAI 001
        /*IF rec.NINTCD='001' THEN
           --SO TIEN NAY LA PHAN GOC SE PHAI TRA. PHAN AM SE DUA KHOANH NO. PHAN DUONG SE NHAN TIEN VE
           v_dblPRINPAIDAMT := rec.paidamt-rec.dealfee;
        ELSE
           v_dbl001RATIO :=1;
           v_dblPRINPAIDAMT := rec.paidamt;
        END IF;*/

/*        SELECT nvl(adv.avladvance,0) + balance-odamt- nvl(execbuyamt,0) - ramt
        INTO l_baldefovd
                from cimast inner join afmast af on cimast.acctno=af.acctno
                left join
                (select * from v_getbuyorderinfo where afacctno = rec.afacctno) b
                on  cimast.acctno = b.afacctno
                left join
                (select sum(depoamt) avladvance,afacctno
                    from v_getAccountAvlAdvance where afacctno = rec.afacctno group by afacctno) adv
                on adv.afacctno=cimast.acctno
                WHERE cimast.acctno = rec.afacctno;
*/
        begin
            select
                --round(p_qtty/qtty*greatest(least(advamt*(1-sys1.varvalue*days/100/360), advamt-sys2.varvalue),0),0) depoamt
                round(p_qtty/qtty * greatest(least(
                    advamt/(1+(sts.days*ADVRATE/100/360+sts.days*ADVBANKRATE/100/360)),
                    advamt/(1+sts.days*ADVBANKRATE/100/360)-sts.ADVMINFEE,
                    advamt/(1+sts.days*ADVRATE/100/360)-sts.ADVMINFEEBANK,
                    advamt-sts.ADVMINFEE-sts.ADVMINFEEBANK),
                    0),0) depoamt,
                    GREATEST(sts.advminamt + sts.advminbank,0) advminbal
                into v_advamt, l_advminbal
            from
                (select sts.qtty,sts.amt-od.feeacr -
                       (case when cf.vat='Y' OR CF.WHTAX ='Y' then to_number(sys.varvalue+sys1.varvalue) else 0 end)/100 *  sts.amt advamt,
                        cleardate - to_date(v_strCURRDATE,'DD/MM/YYYY') days,
                        adt.advrate, adt.advbankrate, adt.advminfeebank, adt.advminfee, adt.advminamt , adt.advminbank
                from stschd sts, odmast od, afmast af, aftype aft,sysvar sys, adtype adt, afidtype map, cfmast cf, sysvar sys1
                where  sts.orgorderid= od.orderid and af.custid = cf.custid
                     and od.afacctno = af.acctno and af.actype = aft.actype
                     and sys.varname='ADVSELLDUTY' and sys.grname='SYSTEM'
                     and sys1.varname='WHTAX' and sys.grname='SYSTEM'
                     and sts.autoid=p_autoid
                     and aft.actype = map.aftype
                     and adt.actype = map.actype
                     and map.objname ='AD.ADTYPE'
                     and adt.autoadv ='Y'
                ) sts;
                /*,sysvar sys1,sysvar sys2
            where 0=0
                and sys1.varname='AINTRATE' and sys1.grname='SYSTEM'
                and sys2.varname='AMINBAL' and sys2.grname='SYSTEM';
                */
        exception when others then
            v_advamt:=0;
            l_advminbal :=0;
        end;

        v_dblPRINPAIDAMT := round(rec.paidamt-rec.dealfee,0);
        v_feerate:=case when rec.dealprinamt= 0 then 0 else  v_dblPRINPAIDAMT/rec.dealprinamt end;

        -- TruongLD Add 2011/09/21
        -- Theo yeu cau cua BVS neu so tien ung truoc < advmin --> ko cho cung
        -- Reset so tien ung ve = 0
        if v_advamt < l_advminbal then
           v_advamt := 0;
        end if;
        -- End TruongLD


        SELECT INTPAIDMETHOD into v_strINTPAIDMETHOD FROM LNMAST WHERE ACCTNO IN (SELECT LNACCTNO FROM DFMAST WHERE ACCTNO=p_dealID);

        -- Neu tra lai thu vao ky tra goc cuoi cung thi treo khoan tra no vao` trong DFGROUP roi lam = tay
        if instr('L', v_strINTPAIDMETHOD) >0 then
            SELECT CURAMT, CURINT, CURFEE into v_CurAmt, v_IntAmt, v_FeeAmt from v_getgrpdealformular;
            if v_CurAmt <= v_advamt and  v_advamt <  (v_CurAmt + v_IntAmt + v_FeeAmt)  then
                UPDATE DFGROUP SET DFBLOCKAMT = DFBLOCKAMT + v_advamt WHERE GROUPID IN (SELECT GROUPID FROM DFMAST WHERE ACCTNO=p_dealID);
                update stschd set aqtty =aqtty + rec.qtty where autoid =p_autoid;
            end if;

        ELSE

            --1.Uu tien tra lai qua han
            v_dblPINTNMLOVD:= greatest(least (v_dblPRINPAIDAMT,v_feerate*rec.INTNMLOVD,rec.INTNMLOVD),0);
            v_dblPINTNMLOVD:= ROUND(v_dblPINTNMLOVD,0); --LAM TRON
            --2.Tra lai cong don qua han
            v_dblPINTOVDACR:= greatest(least (v_dblPRINPAIDAMT-v_dblPINTNMLOVD,v_feerate*rec.INTOVDACR,rec.INTOVDACR),0);
            v_dblPINTOVDACR:= ROUND(v_dblPINTOVDACR,0); --LAM TRON
            --3.Tra lai den han
            v_dblPINTDUE:= greatest(least (v_dblPRINPAIDAMT-v_dblPINTNMLOVD-v_dblPINTOVDACR,v_feerate*rec.INTDUE,rec.INTDUE),0);
            v_dblPINTDUE:= ROUND(v_dblPINTDUE,0); --LAM TRON
            --4.Tra lai cong don
            v_dblPINTNMLACR:= greatest(least (v_dblPRINPAIDAMT-v_dblPINTNMLOVD-v_dblPINTOVDACR-v_dblPINTDUE,v_feerate*rec.INTNMLACR,rec.INTNMLACR),0);
            v_dblPINTNMLACR:= ROUND(v_dblPINTNMLACR,0); --LAM TRON
            --5.Tra phi
            v_dblPFEEPAID:= greatest(least (v_dblPRINPAIDAMT-v_dblPINTNMLOVD-v_dblPINTOVDACR-v_dblPINTDUE-v_dblPINTNMLACR,v_feerate*rec.FEEPAID,rec.FEEPAID),0);
            v_dblPFEEPAID:= ROUND(v_dblPFEEPAID,0); --LAM TRON

            --5.Tra goc qua han
            v_dblPPRINOVD:= greatest(least (v_dblPRINPAIDAMT,rec.PRINOVD),0);
            v_dblPPRINOVD:=round(v_dblPPRINOVD,0);
            --6.Tra goc trong han
            v_dblPPRINNML:= greatest(least (v_dblPRINPAIDAMT-v_dblPPRINOVD,rec.PRINNML),0);
            v_dblPPRINNML:= round(v_dblPPRINNML,0);

            --SO TIEN KHOANH NO
            /*v_debtamt:=
                GREATEST(LEAST(v_dblPINTNMLOVD+v_dblPINTOVDACR+v_dblPINTDUE+v_dblPINTNMLACR+v_dblPPRINOVD+v_dblPPRINNML+v_dblPFEEPAID - v_advamt,
                                0-l_baldefovd),0);*/
            v_debtamt:=
                GREATEST(v_dblPINTNMLOVD+v_dblPINTOVDACR+v_dblPINTDUE+v_dblPINTNMLACR+v_dblPPRINOVD+v_dblPPRINNML+v_dblPFEEPAID - v_advamt,0);
            v_debtamt:=round(v_debtamt,0);

            --Set cac field giao dich
            --01   AUTOID       N
            l_txmsg.txfields ('01').defname   := 'AUTOID';
            l_txmsg.txfields ('01').TYPE      := 'N';
            l_txmsg.txfields ('01').VALUE     := p_autoid;
            --02   ACCTNO       C
            l_txmsg.txfields ('02').defname   := 'ACCTNO';
            l_txmsg.txfields ('02').TYPE      := 'C';
            l_txmsg.txfields ('02').VALUE     := rec.ACCTNO;
            --03   LNACCTNO     C
            l_txmsg.txfields ('03').defname   := 'LNACCTNO';
            l_txmsg.txfields ('03').TYPE      := 'C';
            l_txmsg.txfields ('03').VALUE     := rec.lnacctno;
            --05   AFACCTNO     C
            l_txmsg.txfields ('05').defname   := 'AFACCTNO';
            l_txmsg.txfields ('05').TYPE      := 'C';
            l_txmsg.txfields ('05').VALUE     := rec.AFACCTNO;
            --21   AFACCTNODRD     C
            l_txmsg.txfields ('21').defname   := 'AFACCTNODRD';
            l_txmsg.txfields ('21').TYPE      := 'C';
            l_txmsg.txfields ('21').VALUE     := rec.AFACCTNODRD;
            --20   GROUPID     C
            l_txmsg.txfields ('20').defname   := 'GROUPID';
            l_txmsg.txfields ('20').TYPE      := 'C';
            l_txmsg.txfields ('20').VALUE     := rec.GROUPID;
            --06   SEACCTNO     C
            l_txmsg.txfields ('06').defname   := 'SEACCTNO';
            l_txmsg.txfields ('06').TYPE      := 'C';
            l_txmsg.txfields ('06').VALUE     := rec.AFACCTNO || rec.codeid;
            --07   LNTYPE       C
            l_txmsg.txfields ('07').defname   := 'LNTYPE';
            l_txmsg.txfields ('07').TYPE      := 'C';
            l_txmsg.txfields ('07').VALUE     := rec.LNTYPE;
            --10   QTTY       N
            l_txmsg.txfields ('10').defname   := 'QTTY';
            l_txmsg.txfields ('10').TYPE      := 'N';
            l_txmsg.txfields ('10').VALUE     := rec.QTTY;
            --41   ODAMT          N
            l_txmsg.txfields ('41').defname   := 'ODAMT';
            l_txmsg.txfields ('41').TYPE      := 'N';
            l_txmsg.txfields ('41').VALUE     := rec.ODAMT;
            --45   AMT          N
            l_txmsg.txfields ('45').defname   := 'AMT';
            l_txmsg.txfields ('45').TYPE      := 'N';
            l_txmsg.txfields ('45').VALUE     := v_dblPRINPAIDAMT;
            --22   DEBTAMT          N
            l_txmsg.txfields ('22').defname   := 'AMT';
            l_txmsg.txfields ('22').TYPE      := 'N';
            l_txmsg.txfields ('22').VALUE     := v_debtamt;
            --63   PPRINOVD     N
            l_txmsg.txfields ('63').defname   := 'PPRINOVD';
            l_txmsg.txfields ('63').TYPE      := 'N';
            l_txmsg.txfields ('63').VALUE     := v_dblPPRINOVD;
            --65   PPRINNML     N
            l_txmsg.txfields ('65').defname   := 'PPRINNML';
            l_txmsg.txfields ('65').TYPE      := 'N';
            l_txmsg.txfields ('65').VALUE     := v_dblPPRINNML;
            --72   PINTNMLOVD   N
            l_txmsg.txfields ('72').defname   := 'PINTNMLOVD';
            l_txmsg.txfields ('72').TYPE      := 'N';
            l_txmsg.txfields ('72').VALUE     := v_dblPINTNMLOVD;
            --74   PINTOVDACR   N
            l_txmsg.txfields ('74').defname   := 'PINTOVDACR';
            l_txmsg.txfields ('74').TYPE      := 'N';
            l_txmsg.txfields ('74').VALUE     := v_dblPINTOVDACR;
            --77   PINTDUE      N
            l_txmsg.txfields ('77').defname   := 'PINTDUE';
            l_txmsg.txfields ('77').TYPE      := 'N';
            l_txmsg.txfields ('77').VALUE     := v_dblPINTDUE;
            --80   PINTNMLACR   N
            l_txmsg.txfields ('80').defname   := 'PINTNMLACR';
            l_txmsg.txfields ('80').TYPE      := 'N';
            l_txmsg.txfields ('80').VALUE     := v_dblPINTNMLACR;
            --90   PFEEPAID     N
            l_txmsg.txfields ('90').defname   := 'PFEEPAID';
            l_txmsg.txfields ('90').TYPE      := 'N';
            l_txmsg.txfields ('90').VALUE     := v_dblPFEEPAID;
            --30   C   DESC
            l_txmsg.txfields ('30').defname   := 'DESC';
            l_txmsg.txfields ('30').TYPE      := 'C';
            l_txmsg.txfields ('30').VALUE := rec.des;

            --94    SERLS           C
            l_txmsg.txfields ('94').defname   := 'SERLS';
            l_txmsg.txfields ('94').TYPE      := 'C';
            --Neu cua lenh qua ETS thi =1 : se giai toa chung khoan tu Mortage--> Trade.
            --Neu cua lenh ban MS thi =0 : se khong giai toa chung khoan tu Mortage--> Trade. Cuoi ngay khi thanh toan se cat truc tiep tu mortage di.
            l_txmsg.txfields ('94').VALUE := p_serls;
            --95    RRID            C
            l_txmsg.txfields ('95').defname   := 'RRID';
            l_txmsg.txfields ('95').TYPE      := 'C';
            l_txmsg.txfields ('95').VALUE := rec.RRID;
            --96    CIDRAWNDOWN     C
            l_txmsg.txfields ('96').defname   := 'CIDRAWNDOWN';
            l_txmsg.txfields ('96').TYPE      := 'C';
            l_txmsg.txfields ('96').VALUE := rec.CIDRAWNDOWN;
            --97    BANKDRAWNDOWN   C
            l_txmsg.txfields ('97').defname   := 'BANKDRAWNDOWN';
            l_txmsg.txfields ('97').TYPE      := 'C';
            l_txmsg.txfields ('97').VALUE := rec.BANKDRAWNDOWN;
            --98    CMPDRAWNDOWN    C
            l_txmsg.txfields ('98').defname   := 'CMPDRAWNDOWN';
            l_txmsg.txfields ('98').TYPE      := 'C';
            l_txmsg.txfields ('98').VALUE := rec.CMPDRAWNDOWN;
            --99    LIMITCHECK      C
            l_txmsg.txfields ('99').defname   := 'LIMITCHECK';
            l_txmsg.txfields ('99').TYPE      := 'C';
            l_txmsg.txfields ('99').VALUE := rec.LIMITCHECK;

            --57    CUSTNAME    C
            l_txmsg.txfields ('57').defname   := 'CUSTNAME';
            l_txmsg.txfields ('57').TYPE      := 'C';
            l_txmsg.txfields ('57').VALUE := rec.FULLNAME;
            --58    ADDRESS     C
            l_txmsg.txfields ('58').defname   := 'ADDRESS';
            l_txmsg.txfields ('58').TYPE      := 'C';
            l_txmsg.txfields ('58').VALUE := rec.ADDRESS;
            --59    LICENSE     C
            l_txmsg.txfields ('59').defname   := 'LICENSE';
            l_txmsg.txfields ('59').TYPE      := 'C';
            l_txmsg.txfields ('59').VALUE := rec.IDCODE;

            p_amt:= l_txmsg.txfields ('72').VALUE+
                    l_txmsg.txfields ('74').VALUE+
                    l_txmsg.txfields ('77').VALUE+
                    l_txmsg.txfields ('80').VALUE+
                    l_txmsg.txfields ('63').VALUE+
                    l_txmsg.txfields ('65').VALUE+
                    l_txmsg.txfields ('90').VALUE;
            p_amt:=round(p_amt,0);
            BEGIN
                IF txpks_#2643.fn_batchtxprocess (l_txmsg,
                                                 p_err_code,
                                                 l_err_param
                   ) <> systemnums.c_success
                THEN
                   plog.debug (pkgctx,
                               'got error 2643: ' || p_err_code
                   );
                   ROLLBACK;
                   RETURN;
                END IF;
            END;
        end if;

    end loop;
    p_err_code:=0;
    plog.setendsection(pkgctx, 'pr_DealAutoPayment');
  EXCEPTION
  WHEN OTHERS
   THEN
      plog.debug (pkgctx,'got error on pr_DealAutoPayment');
      ROLLBACK;
      p_err_code := errnums.C_SYSTEM_ERROR;
      plog.error (pkgctx, SQLERRM);
      plog.setendsection (pkgctx, 'pr_DealAutoPayment');
      RAISE errnums.E_SYSTEM_ERROR;
  END pr_DealAutoPayment;

---------------------------------pr_DealReceive------------------------------------------------
  PROCEDURE pr_DealReceive(p_orderid varchar2,p_qtty number,p_err_code  OUT varchar2)
  IS
      l_txmsg               tx.msg_rectype;
      v_strCURRDATE varchar2(20);
      v_strPREVDATE varchar2(20);
      v_strNEXTDATE varchar2(20);
      v_strDesc varchar2(1000);
      v_strEN_Desc varchar2(1000);
      v_blnVietnamese BOOLEAN;
      l_err_param varchar2(300);
      l_MaxRow NUMBER(20,0);
  BEGIN
    plog.setbeginsection(pkgctx, 'pr_DealReceive');
    SELECT TXDESC,EN_TXDESC into v_strDesc, v_strEN_Desc FROM  TLTX WHERE TLTXCD='2661';
     SELECT TO_DATE (varvalue, systemnums.c_date_format)
               INTO v_strCURRDATE
               FROM sysvar
               WHERE grname = 'SYSTEM' AND varname = 'CURRDATE';
    l_txmsg.msgtype:='T';
    l_txmsg.local:='N';
    l_txmsg.tlid        := systemnums.c_system_userid;
    SELECT SYS_CONTEXT ('USERENV', 'HOST'),
             SYS_CONTEXT ('USERENV', 'IP_ADDRESS', 15)
      INTO l_txmsg.wsname, l_txmsg.ipaddress
    FROM DUAL;
    l_txmsg.off_line    := 'N';
    l_txmsg.deltd       := txnums.c_deltd_txnormal;
    l_txmsg.txstatus    := txstatusnums.c_txcompleted;
    l_txmsg.msgsts      := '0';
    l_txmsg.ovrsts      := '0';
    l_txmsg.batchname   := 'DAY';
    l_txmsg.txdate:=to_date(v_strCURRDATE,systemnums.c_date_format);
    l_txmsg.busdate:=to_date(v_strCURRDATE,systemnums.c_date_format);
    l_txmsg.tltxcd:='2661';
    for rec in
    (
       select df.acctno,sts.autoid,df.rcvqtty,least(sts.aqtty,df.rcvqtty,m.adfqtty) aqtty,sts.acctno seacctno,df.afacctno
        from stschd sts ,v_getDealInfo df, stdfmap m
        where df.rcvqtty>0 and sts.aqtty>0
        and sts.autoid =m.stschdid AND m.dfacctno = df.acctno and sts.status='C' and duetype ='RS' and sts.orgorderid=p_orderid
    )
    loop
        --Set txnum
        SELECT systemnums.C_BATCH_PREFIXED
                         || LPAD (seq_BATCHTXNUM.NEXTVAL, 8, '0')
                  INTO l_txmsg.txnum
                  FROM DUAL;
        l_txmsg.brid        := substr(rec.AFACCTNO,1,4);
        --Xac dinh xem nha day tu trong nuoc hay nuoc ngoai

        --Set cac field giao dich
        --01   N   AUTOID
        l_txmsg.txfields ('01').defname   := 'AUTOID';
        l_txmsg.txfields ('01').TYPE      := 'N';
        l_txmsg.txfields ('01').VALUE     := rec.AUTOID;

        --02   ACCTNO     C
        l_txmsg.txfields ('02').defname   := 'ACCTNO';
        l_txmsg.txfields ('02').TYPE      := 'C';
        l_txmsg.txfields ('02').VALUE     := rec.ACCTNO;
        --05   AFACCTNO   C
        l_txmsg.txfields ('05').defname   := 'AFACCTNO';
        l_txmsg.txfields ('05').TYPE      := 'C';
        l_txmsg.txfields ('05').VALUE     := rec.AFACCTNO;
        --06   C   SEACCTNO
        l_txmsg.txfields ('06').defname   := 'SEACCTNO';
        l_txmsg.txfields ('06').TYPE      := 'C';
        l_txmsg.txfields ('06').VALUE     := rec.SEACCTNO;
        --10   RCVQTTY    N
        l_txmsg.txfields ('10').defname   := 'RCVQTTY';
        l_txmsg.txfields ('10').TYPE      := 'N';
        l_txmsg.txfields ('10').VALUE     := rec.AQTTY;
        --11   CARCVQTTY    N
        l_txmsg.txfields ('11').defname   := 'CARCVQTTY';
        l_txmsg.txfields ('11').TYPE      := 'N';
        l_txmsg.txfields ('11').VALUE     := 0;
        --12   BLOCKQTTY    N
        l_txmsg.txfields ('12').defname   := 'BLOCKQTTY';
        l_txmsg.txfields ('12').TYPE      := 'N';
        l_txmsg.txfields ('12').VALUE     := 0;
        --30   C   DESC
        l_txmsg.txfields ('30').defname   := 'DESC';
        l_txmsg.txfields ('30').TYPE      := 'C';
        l_txmsg.txfields ('30').VALUE := v_strDesc;

        BEGIN
            IF txpks_#2661.fn_batchtxprocess (l_txmsg,
                                             p_err_code,
                                             l_err_param
               ) <> systemnums.c_success
            THEN
               plog.debug (pkgctx,
                           'got error 2661: ' || p_err_code
               );
               ROLLBACK;
               RETURN;
            END IF;
        END;
    end loop;
    p_err_code:=0;
    plog.setendsection(pkgctx, 'pr_DealReceive');
  EXCEPTION
  WHEN OTHERS
   THEN
      plog.debug (pkgctx,'got error on pr_DealReceive');
      ROLLBACK;
      p_err_code := errnums.C_SYSTEM_ERROR;
      plog.error (pkgctx, SQLERRM);
      plog.setendsection (pkgctx, 'pr_DealReceive');
      RAISE errnums.E_SYSTEM_ERROR;
  END pr_DealReceive;


---------------------------------pr_CADealReceive------------------------------------------------
  PROCEDURE pr_CADealReceive(p_refDealID varchar,p_qtty number, p_err_code  OUT varchar2)
  IS
      l_txmsg               tx.msg_rectype;
      v_strCURRDATE varchar2(20);
      v_strPREVDATE varchar2(20);
      v_strNEXTDATE varchar2(20);
      v_strDesc varchar2(1000);
      v_strEN_Desc varchar2(1000);
      v_blnVietnamese BOOLEAN;
      l_err_param varchar2(300);
      l_MaxRow NUMBER(20,0);
  BEGIN
    plog.setbeginsection(pkgctx, 'pr_CADealReceive');
    SELECT TXDESC,EN_TXDESC into v_strDesc, v_strEN_Desc FROM  TLTX WHERE TLTXCD='2661';
     SELECT TO_DATE (varvalue, systemnums.c_date_format)
               INTO v_strCURRDATE
               FROM sysvar
               WHERE grname = 'SYSTEM' AND varname = 'CURRDATE';
    l_txmsg.msgtype:='T';
    l_txmsg.local:='N';
    l_txmsg.tlid        := systemnums.c_system_userid;
    SELECT SYS_CONTEXT ('USERENV', 'HOST'),
             SYS_CONTEXT ('USERENV', 'IP_ADDRESS', 15)
      INTO l_txmsg.wsname, l_txmsg.ipaddress
    FROM DUAL;
    l_txmsg.off_line    := 'N';
    l_txmsg.deltd       := txnums.c_deltd_txnormal;
    l_txmsg.txstatus    := txstatusnums.c_txcompleted;
    l_txmsg.msgsts      := '0';
    l_txmsg.ovrsts      := '0';
    l_txmsg.batchname   := 'DAY';
    l_txmsg.txdate:=to_date(v_strCURRDATE,systemnums.c_date_format);
    l_txmsg.tltxcd:='2661';
    for rec in
    (
       select df.acctno,sts.autoid,df.carcvqtty,least(sts.dfqtty,df.carcvqtty,p_qtty) aqtty,sts.afacctno || (case when ca.iswft='Y' then (select codeid from sbsecurities where refcodeid=sts.codeid) else sts.codeid end) seacctno,df.afacctno
        from caschd sts ,v_getDealInfo df,camast ca
        where df.carcvqtty>0 and sts.dfqtty>0 and sts.status <> 'C' and sts.isse <> 'Y'
        and sts.autoid =df.dfref and sts.autoid=p_refDealID
        and ca.camastid =sts.camastid
    )
    loop
        --Set txnum
        SELECT systemnums.C_BATCH_PREFIXED
                         || LPAD (seq_BATCHTXNUM.NEXTVAL, 8, '0')
                  INTO l_txmsg.txnum
                  FROM DUAL;
        l_txmsg.brid        := substr(rec.AFACCTNO,1,4);
        --Xac dinh xem nha day tu trong nuoc hay nuoc ngoai

        --Set cac field giao dich
        --01   N   AUTOID
        l_txmsg.txfields ('01').defname   := 'AUTOID';
        l_txmsg.txfields ('01').TYPE      := 'N';
        l_txmsg.txfields ('01').VALUE     := rec.AUTOID;

        --02   ACCTNO     C
        l_txmsg.txfields ('02').defname   := 'ACCTNO';
        l_txmsg.txfields ('02').TYPE      := 'C';
        l_txmsg.txfields ('02').VALUE     := rec.ACCTNO;
        --05   AFACCTNO   C
        l_txmsg.txfields ('05').defname   := 'AFACCTNO';
        l_txmsg.txfields ('05').TYPE      := 'C';
        l_txmsg.txfields ('05').VALUE     := rec.AFACCTNO;
        --06   C   SEACCTNO
        l_txmsg.txfields ('06').defname   := 'SEACCTNO';
        l_txmsg.txfields ('06').TYPE      := 'C';
        l_txmsg.txfields ('06').VALUE     := rec.SEACCTNO;
        --10   RCVQTTY    N
        l_txmsg.txfields ('10').defname   := 'RCVQTTY';
        l_txmsg.txfields ('10').TYPE      := 'N';
        l_txmsg.txfields ('10').VALUE     := 0;
        --11   CARCVQTTY    N
        l_txmsg.txfields ('11').defname   := 'CARCVQTTY';
        l_txmsg.txfields ('11').TYPE      := 'N';
        l_txmsg.txfields ('11').VALUE     := rec.AQTTY;
        --12   BLOCKQTTY    N
        l_txmsg.txfields ('12').defname   := 'BLOCKQTTY';
        l_txmsg.txfields ('12').TYPE      := 'N';
        l_txmsg.txfields ('12').VALUE     := 0;
        --30   C   DESC
        l_txmsg.txfields ('30').defname   := 'DESC';
        l_txmsg.txfields ('30').TYPE      := 'C';
        l_txmsg.txfields ('30').VALUE := v_strDesc;

        BEGIN
            IF txpks_#2661.fn_batchtxprocess (l_txmsg,
                                             p_err_code,
                                             l_err_param
               ) <> systemnums.c_success
            THEN
               plog.debug (pkgctx,
                           'got error 2661: ' || p_err_code
               );
               ROLLBACK;
               RETURN;
            END IF;
        END;
    end loop;
    p_err_code:=0;
    plog.setendsection(pkgctx, 'pr_CADealReceive');
  EXCEPTION
  WHEN OTHERS
   THEN
      plog.debug (pkgctx,'got error on pr_CADealReceive');
      ROLLBACK;
      p_err_code := errnums.C_SYSTEM_ERROR;
      plog.error (pkgctx, SQLERRM);
      plog.setendsection (pkgctx, 'pr_CADealReceive');
      RAISE errnums.E_SYSTEM_ERROR;
  END pr_CADealReceive;

/* ---------------------------------fn_OpenDealAccount------------------------------------------------
FUNCTION fn_OpenDealAccount(p_txmsg in tx.msg_rectype,p_err_code out varchar2)
RETURN NUMBER
IS
    v_blnREVERSAL boolean;
    l_lngErrCode    number(20,0);
    v_dblAMT    number(20,0);
    v_strACCTNO varchar2(20);
    v_strRRTYPE varchar2(4);
    v_strDFTYPE varchar2(4);
    v_strCUSTBANK varchar2(200);
    v_strCIACCTNO varchar2(200);
    v_strLNTYPE varchar2(4);
    v_dblCISVRFEE    number(20,4);
    v_dblFEE    number(20,4);
    v_dblFEEMIN number(20,4);
    v_dblTAX    number(20,4);
    v_dblAMTMIN number(20,4);
    v_strLNACCTNO varchar2(30);
    v_strSTATUS char(1);
    v_strORDERID varchar2(50);
    v_dblMRCRLIMIT number(23,4);
BEGIN
    plog.setbeginsection (pkgctx, 'fn_OpenDealAccount');
    plog.debug (pkgctx, '<<BEGIN OF fn_OpenDealAccount');
    --***************************************************************************************************
    --** PUT YOUR SPECIFIC AFTER PROCESS HERE. DO NOT COMMIT/ROLLBACK HERE, THE SYSTEM WILL DO IT
    --***************************************************************************************************
    l_lngErrCode:= errnums.C_BIZ_RULE_INVALID;
    p_err_code:=0;
    v_blnREVERSAL:=case when p_txmsg.deltd ='Y' then true else false end;
    if not v_blnREVERSAL then
        if p_txmsg.txfields('16').value='1' then
            v_strSTATUS:= 'A';
        else
            v_strSTATUS:= 'P';
        end if;

        v_dblAMT:=to_number(p_txmsg.txfields('16').value) * (p_txmsg.txfields('12').value + p_txmsg.txfields('13').value +
                    p_txmsg.txfields('22').value + p_txmsg.txfields('23').value) * p_txmsg.txfields('10').value;
        v_dblAMT:=round(v_dblAMT,0);
        SELECT SEQ_DFMAST.NEXTVAL DFACCTNO
            into v_strACCTNO
        FROM DUAL;
        v_strACCTNO:=p_txmsg.txfields('02').value;
        if v_strACCTNO is null or length(v_strACCTNO)=0 then
            v_strACCTNO:=substr('000000' || v_strACCTNO,length('000000' || v_strACCTNO)-5,6);
            v_strACCTNO:=p_txmsg.brid || substr(to_char(p_txmsg.txdate,systemnums.c_date_format),1,2)
                                  || substr(to_char(p_txmsg.txdate,systemnums.c_date_format),4,2)
                                  || substr(to_char(p_txmsg.txdate,systemnums.c_date_format),9,2)
                                  || v_strACCTNO;
        end if;

        begin
            SELECT RRTYPE,DFTYPE,CUSTBANK,CIACCTNO,LNTYPE,FEE,FEEMIN,TAX,AMTMIN,CISVRFEE
            into    v_strRRTYPE,v_strDFTYPE,v_strCUSTBANK,v_strCIACCTNO,v_strLNTYPE,v_dblFEE,v_dblFEEMIN,v_dblTAX,v_dblAMTMIN,v_dblCISVRFEE
            FROM DFTYPE WHERE ACTYPE =p_txmsg.txfields('04').value;

        exception
        when others then
            plog.error(pkgctx,'l_lngErrCode: ' || errnums.C_DF_ACTYPE_NOTFOUND);
            p_err_code :=errnums.C_DF_ACTYPE_NOTFOUND;
            return l_lngErrCode;
        end;
        --1.Open LNMAST
        v_strLNACCTNO:=CSPKS_LNPROC.fn_OpenLoanAccount(p_txmsg.txfields('03').value,v_strLNTYPE,p_err_code);
        if p_err_code <> 0 then
            p_err_code :=errnums.C_DF_LNSCHD_CANNOT_CREATE;
            return -1; --Co loi xay ra
        end if;
        If v_strDFTYPE = 'M' Then
            --Neu la cam co thi khong giai ngan va chuyen trang thai thanh N: Cho send len trung tam luu ky
            v_dblAMT := 0;
            v_strStatus := 'N';
        End If;
        --2.Create loan schedule
        if v_dblAMT>0 then

            l_lngErrCode:=CSPKS_LNPROC.fn_CreateLoanSchedule(v_strLNACCTNO,v_dblAMT,p_err_code);
            if l_lngErrCode <> 0 then
                plog.error(pkgctx,'l_lngErrCode: ' || errnums.C_DF_LNSCHD_CANNOT_CREATE);
                p_err_code :=errnums.C_DF_LNSCHD_CANNOT_CREATE;
                return l_lngErrCode;
            end if;
        end if;

        --3. Open DFMAST
        INSERT INTO DFMAST (
                     ACCTNO, AFACCTNO, LNACCTNO, TXDATE, TXNUM, TXTIME,
                     ACTYPE, RRTYPE, DFTYPE, CUSTBANK,CIACCTNO, LNTYPE, FEE,
                     FEEMIN, TAX, AMTMIN, CODEID, REFPRICE, DFPRICE,
                     TRIGGERPRICE, DFRATE, IRATE, MRATE, LRATE, CALLTYPE,
                     DFQTTY, BQTTY,RCVQTTY,BLOCKQTTY,CARCVQTTY, RLSQTTY, DFAMT, RLSAMT, AMT,
                     INTAMTACR, FEEAMT, RLSFEEAMT, STATUS, DFREF,DESCRIPTION,LIMITCHK,CISVRFEE)
              VALUES
                     ( v_strACCTNO , p_txmsg.txfields('03').value, v_strLNACCTNO, to_date(p_txmsg.txdate,systemnums.c_date_format), p_txmsg.txnum, p_txmsg.txtime,
                      p_txmsg.txfields('04').value, v_strRRTYPE, v_strDFTYPE, v_strCUSTBANK,v_strCIACCTNO, v_strLNTYPE,  v_dblFEE ,
                      v_dblFEEMIN ,  v_dblTAX ,  v_dblAMTMIN , p_txmsg.txfields('01').value,  p_txmsg.txfields('06').value ,  p_txmsg.txfields('10').value ,
                      p_txmsg.txfields('11').value ,  p_txmsg.txfields('07').value ,  p_txmsg.txfields('14').value ,  p_txmsg.txfields('08').value ,  p_txmsg.txfields('09').value , p_txmsg.txfields('15').value,
                      p_txmsg.txfields('12').value ,0, p_txmsg.txfields('13').value , p_txmsg.txfields('22').value , p_txmsg.txfields('23').value , 0, 0, 0,  v_dblAMT ,
                     0, 0, 0, v_strSTATUS, p_txmsg.txfields('29').value,p_txmsg.txfields('30').value,decode(p_txmsg.txfields('99').value,'1','Y','N'),v_dblCISVRFEE);
        If p_txmsg.txfields('13').value > 0 Then
            v_strORDERID:='orderid';
            begin
                select orgorderid into v_strORDERID from stschd where autoid=p_txmsg.txfields('29').value;
                update odmast set dfqtty =dfqtty + p_txmsg.txfields('13').value,LAST_CHANGE = SYSTIMESTAMP where orderid =v_strORDERID;
            exception when others then
                v_strORDERID:='orderid';
            end;
            UPDATE STSCHD SET AQTTY= AQTTY + p_txmsg.txfields('13').value WHERE AUTOID=p_txmsg.txfields('29').value;
        End If;
        If p_txmsg.txfields('23').value > 0 Then
            UPDATE CASCHD SET DFQTTY= DFQTTY + p_txmsg.txfields('23').value WHERE AUTOID=p_txmsg.txfields('29').value;
        End If;
        If p_txmsg.txfields('22').value > 0 Then
            UPDATE SEMASTDTL SET DFQTTY= DFQTTY + p_txmsg.txfields('22').value WHERE TXNUM || TXDATE=p_txmsg.txfields('29').value;
        End If;
    else
        select lnacctno
        into v_strLNACCTNO
        from dfmast
        where txnum = p_txmsg.txnum and txdate = to_date(p_txmsg.txdate,systemnums.c_date_format);

        delete from lnschd where acctno =v_strLNACCTNO;
        delete from lnmast where acctno =v_strLNACCTNO;
        delete from dfmast
        where txnum = p_txmsg.txnum and txdate = to_date(p_txmsg.txdate,systemnums.c_date_format);
        If p_txmsg.txfields('13').value > 0 Then
            v_strORDERID:='orderid';
            begin
                select orgorderid into v_strORDERID from stschd where autoid=p_txmsg.txfields('29').value;
                update odmast set dfqtty =dfqtty - p_txmsg.txfields('13').value where orderid =v_strORDERID;
            exception when others then
                v_strORDERID:='orderid';
            end;
            UPDATE STSCHD SET AQTTY= AQTTY - p_txmsg.txfields('13').value WHERE AUTOID=p_txmsg.txfields('29').value;
        End If;
        If p_txmsg.txfields('23').value > 0 Then
            UPDATE CASCHD SET DFQTTY= DFQTTY - p_txmsg.txfields('23').value WHERE AUTOID=p_txmsg.txfields('29').value;
        End If;
        If p_txmsg.txfields('22').value > 0 Then
            UPDATE SEMASTDTL SET DFQTTY= DFQTTY - p_txmsg.txfields('22').value WHERE TXNUM || TXDATE=p_txmsg.txfields('29').value;
        End If;
    end if; --end v_blnREVERSAL

    plog.debug (pkgctx, '<<END OF fn_OpenDealAccount');
    plog.setendsection (pkgctx, 'fn_OpenDealAccount');
    RETURN systemnums.C_SUCCESS;
EXCEPTION
WHEN OTHERS
   THEN
      p_err_code := errnums.C_SYSTEM_ERROR;
      plog.error (pkgctx, SQLERRM);
       plog.setendsection (pkgctx, 'fn_OpenDealAccount');
      RAISE errnums.E_SYSTEM_ERROR;
END fn_OpenDealAccount;*/

 ---------------------------------fn_OpenDealAccount------------------------------------------------
FUNCTION fn_OpenDealAccount(p_txmsg in tx.msg_rectype,p_err_code out varchar2)
RETURN NUMBER
IS
    v_blnREVERSAL boolean;
    l_lngErrCode    number(20,0);
    v_dblAMT    number(20,0);
    v_strACCTNO varchar2(20);
    v_strRRTYPE varchar2(4);
    v_strDFTYPE varchar2(4);
    v_strCUSTBANK varchar2(200);
    v_strCIACCTNO varchar2(200);
    v_strLNTYPE varchar2(4);
    v_dblCISVRFEE    number(20,4);
    v_dblFEE    number(20,4);
    v_dblFEEMIN number(20,4);
    v_dblTAX    number(20,4);
    v_dblAMTMIN number(20,4);
    v_dblARATE  NUMBER;
    v_dblALRATE NUMBER;
    v_strLNACCTNO varchar2(30);
    v_strSTATUS char(1);
    v_strORDERID varchar2(50);
    v_dblMRCRLIMIT number(23,4);
    v_dblRemainRCVQTTY number(20,4);
    v_dblExecRCVQTTY number(20,4);
    v_dblReleaseAMT number(20,4);
BEGIN
    plog.setbeginsection (pkgctx, 'fn_OpenDealAccount');
    plog.debug (pkgctx, '<<BEGIN OF fn_OpenDealAccount');
   /***************************************************************************************************
    ** PUT YOUR SPECIFIC AFTER PROCESS HERE. DO NOT COMMIT/ROLLBACK HERE, THE SYSTEM WILL DO IT
    ***************************************************************************************************/
    l_lngErrCode:= errnums.C_BIZ_RULE_INVALID;
    p_err_code:=0;
    v_blnREVERSAL:=case when p_txmsg.deltd ='Y' then true else false end;
    if not v_blnREVERSAL then
        if p_txmsg.txfields('16').value='1' then
            v_strSTATUS:= 'A';
        else
            v_strSTATUS:= 'P';
        end if;

        v_dblAMT:=to_number(p_txmsg.txfields('16').value) * (p_txmsg.txfields('12').value + p_txmsg.txfields('13').value +
                    p_txmsg.txfields('22').value + p_txmsg.txfields('23').value) * p_txmsg.txfields('10').value;
        v_dblAMT:=round(v_dblAMT,0);
        SELECT SEQ_DFMAST.NEXTVAL DFACCTNO
            into v_strACCTNO
        FROM DUAL;
        v_strACCTNO:=p_txmsg.txfields('02').value;
        if v_strACCTNO is null or length(v_strACCTNO)=0 then
            v_strACCTNO:=substr('000000' || v_strACCTNO,length('000000' || v_strACCTNO)-5,6);
            v_strACCTNO:=p_txmsg.brid || substr(to_char(p_txmsg.txdate,systemnums.c_date_format),1,2)
                                  || substr(to_char(p_txmsg.txdate,systemnums.c_date_format),4,2)
                                  || substr(to_char(p_txmsg.txdate,systemnums.c_date_format),9,2)
                                  || v_strACCTNO;
        end if;

        begin
            SELECT LNT.RRTYPE,DFT.DFTYPE,LNT.CUSTBANK,LNT.CIACCTNO,DFT.LNTYPE,DFT.FEE,DFT.FEEMIN,DFT.TAX,DFT.AMTMIN,DFT.CISVRFEE, DFT.ARATE, DFT.ALRATE
            into    v_strRRTYPE,v_strDFTYPE,v_strCUSTBANK,v_strCIACCTNO,v_strLNTYPE,v_dblFEE,v_dblFEEMIN,v_dblTAX,v_dblAMTMIN,v_dblCISVRFEE, v_dblARATE, v_dblALRATE
            FROM DFTYPE DFT, LNTYPE LNT WHERE DFT.ACTYPE =p_txmsg.txfields('04').value and DFT.LNTYPE = LNT.ACTYPE;

        exception
        when others then
            plog.error(pkgctx,'l_lngErrCode: ' || errnums.C_DF_ACTYPE_NOTFOUND);
            p_err_code :=errnums.C_DF_ACTYPE_NOTFOUND;
            return l_lngErrCode;
        end;
        --1.Open LNMAST
        v_strLNACCTNO:=CSPKS_LNPROC.fn_OpenLoanAccount(p_txmsg.txfields('03').value,v_strLNTYPE,p_err_code);
        if p_err_code <> 0 then
            p_err_code :=errnums.C_DF_LNSCHD_CANNOT_CREATE;
            return -1; --Co loi xay ra
        end if;
        If v_strDFTYPE = 'M' Then
            --Neu la cam co thi khong giai ngan va chuyen trang thai thanh N: Cho send len trung tam luu ky
            v_dblAMT := 0;
            v_strStatus := 'N';
        End If;
        --2.Create loan schedule
        if v_dblAMT>0 then

            l_lngErrCode:=CSPKS_LNPROC.fn_CreateLoanSchedule(v_strLNACCTNO,v_dblAMT,p_err_code);
            if l_lngErrCode <> 0 then
                plog.error(pkgctx,'l_lngErrCode: ' || errnums.C_DF_LNSCHD_CANNOT_CREATE);
                p_err_code :=errnums.C_DF_LNSCHD_CANNOT_CREATE;
                return l_lngErrCode;
            end if;
        end if;

        --3. Open DFMAST
        INSERT INTO DFMAST (
                     ACCTNO, AFACCTNO, LNACCTNO, TXDATE, TXNUM, TXTIME,
                     ACTYPE, RRTYPE, DFTYPE, CUSTBANK,CIACCTNO, LNTYPE, FEE,
                     FEEMIN, TAX, AMTMIN, CODEID, REFPRICE, DFPRICE,
                     TRIGGERPRICE, DFRATE, IRATE, MRATE, LRATE, CALLTYPE,
                     DFQTTY, BQTTY,RCVQTTY,BLOCKQTTY,CARCVQTTY, RLSQTTY, DFAMT, RLSAMT, AMT,
                     INTAMTACR, FEEAMT, RLSFEEAMT, STATUS, DFREF,DESCRIPTION,LIMITCHK,CISVRFEE,TLID,ARATE,ALRATE)
              VALUES
                     ( v_strACCTNO , p_txmsg.txfields('03').value, v_strLNACCTNO, to_date(p_txmsg.txdate,systemnums.c_date_format), p_txmsg.txnum, p_txmsg.txtime,
                      p_txmsg.txfields('04').value, v_strRRTYPE, v_strDFTYPE, v_strCUSTBANK,v_strCIACCTNO, v_strLNTYPE,  v_dblFEE ,
                      v_dblFEEMIN ,  v_dblTAX ,  v_dblAMTMIN , p_txmsg.txfields('01').value,  p_txmsg.txfields('06').value ,  p_txmsg.txfields('10').value ,
                      p_txmsg.txfields('11').value ,  p_txmsg.txfields('07').value ,  p_txmsg.txfields('14').value ,  p_txmsg.txfields('08').value ,  p_txmsg.txfields('09').value , p_txmsg.txfields('15').value,
                      p_txmsg.txfields('12').value ,0, p_txmsg.txfields('13').value , p_txmsg.txfields('22').value , p_txmsg.txfields('23').value , 0, 0, 0,  v_dblAMT ,
                     0, 0, 0, v_strSTATUS, p_txmsg.txfields('29').value,p_txmsg.txfields('30').value,decode(p_txmsg.txfields('99').value,'1','Y','N'),v_dblCISVRFEE, '0000',v_dblARATE, v_dblALRATE);
        If p_txmsg.txfields('13').value > 0 Then
            v_strORDERID:='orderid';
            begin
                select orgorderid into v_strORDERID from stschd where autoid=p_txmsg.txfields('29').value;
                --update odmast set dfqtty =dfqtty + p_txmsg.txfields('13').value,LAST_CHANGE = SYSTIMESTAMP where orderid =v_strORDERID;
            exception when others then
                v_strORDERID:='orderid';
            end;

            v_dblRemainRCVQTTY:= p_txmsg.txfields('13').value;
            v_dblExecRCVQTTY:=0;
            v_dblReleaseAMT:=0;
            FOR rec_rcvdf IN
            (
            SELECT *
            FROM stschd
            WHERE qtty - aqtty > 0 and (to_char(txdate,'DD/MM/YYYY') || afacctno || codeid || to_char(clearday)) = p_txmsg.txfields('29').value
            and duetype ='RS' and status <> 'C' AND deltd <> 'Y'
            order BY autoid
            )
            LOOP
                v_dblExecRCVQTTY:= least(v_dblRemainRCVQTTY, rec_rcvdf.QTTY - rec_rcvdf.AQTTY);
                update odmast set dfqtty = dfqtty + v_dblExecRCVQTTY where orderid = rec_rcvdf.ORGORDERID;
                update stschd set aqtty = aqtty + v_dblExecRCVQTTY where autoid = rec_rcvdf.autoid;
                INSERT INTO stdfmap (stschdid, dfacctno, dfqtty, rlsamt,status, deltd, txdate,adfqtty)
                    VALUES(rec_rcvdf.AUTOID,v_strACCTNO,v_dblExecRCVQTTY,
                    CASE WHEN v_dblExecRCVQTTY < v_dblRemainRCVQTTY THEN round(p_txmsg.txfields('41').value/p_txmsg.txfields('13').value,0) * v_dblExecRCVQTTY
                    ELSE p_txmsg.txfields('41').value - v_dblReleaseAMT END,
                    'A','N',to_date(p_txmsg.txdate,'DD/MM/RRRR'),v_dblExecRCVQTTY);

                v_dblReleaseAMT:= v_dblReleaseAMT + (p_txmsg.txfields('41').value / p_txmsg.txfields('13').value) * v_dblExecRCVQTTY;
                v_dblRemainRCVQTTY:= v_dblRemainRCVQTTY - v_dblExecRCVQTTY;
                If v_dblRemainRCVQTTY = 0 Then
                    EXIT;
                End IF;
            END LOOP;
            --UPDATE STSCHD SET AQTTY= AQTTY + p_txmsg.txfields('13').value WHERE AUTOID=p_txmsg.txfields('29').value;
        End If;
        If p_txmsg.txfields('23').value > 0 Then
            UPDATE CASCHD SET DFQTTY= DFQTTY + p_txmsg.txfields('23').value WHERE AUTOID=p_txmsg.txfields('29').value;
        End If;
       /* If p_txmsg.txfields('22').value > 0 Then
            UPDATE SEMASTDTL SET DFQTTY= DFQTTY + p_txmsg.txfields('22').value
            WHERE TXNUM || TXDATE=p_txmsg.txfields('29').value
            AND acctno=p_txmsg.txfields('05').value;
        End If;*/
    else
        select lnacctno
        into v_strLNACCTNO
        from dfmast
        where txnum = p_txmsg.txnum and txdate = to_date(p_txmsg.txdate,systemnums.c_date_format);

        delete from lnschd where acctno =v_strLNACCTNO;
        delete from lnmast where acctno =v_strLNACCTNO;
        delete from dfmast
        where txnum = p_txmsg.txnum and txdate = to_date(p_txmsg.txdate,systemnums.c_date_format);
        If p_txmsg.txfields('13').value > 0 Then
            v_strORDERID:='orderid';
            begin
                select orgorderid into v_strORDERID from stschd where autoid=p_txmsg.txfields('29').value;
                --update odmast set dfqtty =dfqtty - p_txmsg.txfields('13').value where orderid =v_strORDERID;
            exception when others then
                v_strORDERID:='orderid';
            end;
            FOR rec_rcvdf IN
            (
            SELECT s.autoid, m.dfacctno, s.orgorderid, m.dfqtty
            FROM stschd s, dfmast d, stdfmap m
            WHERE s.autoid = m.stschdid
            AND d.acctno = m.dfacctno
            and d.txnum = p_txmsg.txnum
            and s.txdate = to_date(p_txmsg.txdate,'DD/MM/RRRR')
            and (to_char(s.txdate,'DD/MM/RRRR') || s.afacctno || s.codeid || to_char(clearday)) = p_txmsg.txfields('29').value
            ORDER BY autoid
            )
            LOOP
                UPDATE ODMAST SET DFQTTY= DFQTTY - rec_rcvdf.DFQTTY WHERE ORDERID=rec_rcvdf.ORGORDERID;
                UPDATE STSCHD SET AQTTY= AQTTY - rec_rcvdf.DFQTTY WHERE AUTOID=rec_rcvdf.AUTOID;
                UPDATE STDFMAP SET DELTD= 'Y'
                WHERE STSCHDID =rec_rcvdf.AUTOID and DFACCTNO =rec_rcvdf.DFACCTNO and txdate = to_date(p_txmsg.txdate,'DD/MM/RRRR');
            END LOOP;
            --UPDATE STSCHD SET AQTTY= AQTTY - p_txmsg.txfields('13').value WHERE AUTOID=p_txmsg.txfields('29').value;
        End If;
        If p_txmsg.txfields('23').value > 0 Then
            UPDATE CASCHD SET DFQTTY= DFQTTY - p_txmsg.txfields('23').value WHERE AUTOID=p_txmsg.txfields('29').value;
        End If;
      /*  If p_txmsg.txfields('22').value > 0 Then
            UPDATE SEMASTDTL SET DFQTTY= DFQTTY - p_txmsg.txfields('22').value
            WHERE TXNUM || TXDATE=p_txmsg.txfields('29').value
            AND acctno=p_txmsg.txfields('05').value;
        End If;*/
    end if; --end v_blnREVERSAL

    plog.debug (pkgctx, '<<END OF fn_OpenDealAccount');
    plog.setendsection (pkgctx, 'fn_OpenDealAccount');
    RETURN systemnums.C_SUCCESS;
EXCEPTION
WHEN OTHERS
   THEN
      p_err_code := errnums.C_SYSTEM_ERROR;
      plog.error (pkgctx, SQLERRM);
       plog.setendsection (pkgctx, 'fn_OpenDe-alAccount');
      RAISE errnums.E_SYSTEM_ERROR;
END fn_OpenDealAccount;

-- initial LOG
BEGIN
   SELECT *
   INTO logrow
   FROM tlogdebug
   WHERE ROWNUM <= 1;

   pkgctx    :=
      plog.init ('cspks_dfproc',
                 plevel => logrow.loglevel,
                 plogtable => (logrow.log4table = 'Y'),
                 palert => (logrow.log4alert = 'Y'),
                 ptrace => (logrow.log4trace = 'Y')
      );
END;
/
