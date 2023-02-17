SET DEFINE OFF;
CREATE OR REPLACE PACKAGE pck_gwtransfer
  IS
--
-- To modify this template, edit file PKGSPEC.TXT in TEMPLATE
-- directory of SQL Navigator
--
-- Purpose: Briefly explain the functionality of the package
--
-- MODIFICATION HISTORY
-- Person      Date    Comments
-- ---------   ------  ------------------------------------------
   -- Enter package declarations as shown below


     PROCEDURE pr_PutbatchProcessB2C;
     PROCEDURE pr_PutbatchProcessC2B;
     PROCEDURE pr_Complete_PutbatchC2B;
     PROCEDURE pr_CreateFileCheck(F_DATE IN  VARCHAR2,T_DATE IN  VARCHAR2 );


END; 
 
 
 
 
 
 
 
 
 
 
 
/


CREATE OR REPLACE PACKAGE BODY pck_gwtransfer
IS
  pkgctx   plog.log_ctx:= plog.init ('txpks_txpks_auto',
                 plevel => 30,
                 plogtable => true,
                 palert => false,
                 ptrace => false);

--
-- To modify this template, edit file PKGBODY.TXT in TEMPLATE
-- directory of SQL Navigator
--
-- Purpose: Briefly explain the functionality of the package body
--
-- MODIFICATION HISTORY
-- Person      Date    Comments
-- ---------   ------  ------------------------------------------
   -- Enter procedure, function bodies as shown below

  FUNCTION Correct_ReMark(v_Remark IN nvarchar2,v_leng in NUMERIC)
   RETURN  nvarchar2 IS
    v_Result nvarchar2(100);
    v_strIN nvarchar2(100);
    BEGIN
    v_strIN:=SUbstr(translate(v_Remark , ' ~ ` - # ^ * _ < > ;  { } [ ] |\',' '),0,v_leng) ;
    v_Result := fn_banhgw_convert_to_vn(v_strIN);
    RETURN v_Result;
    END;



   PROCEDURE pr_PutbatchProcessB2C
    IS
      -- Enter the procedure variables here. As shown below
      v_errcode NUMBER;
      V_COUNT number;
     ---------------
      v_rqsautoid varchar2(30);
      v_txnum varchar(10);
      v_txdate varchar(20);
      v_status varchar(3);
      v_errmsg varchar(250);
      v_custodycd varchar(20);
      v_afacctno varchar(20);
      l_bankacctno  varchar(50);
      l_glmast varchar(50);
      l_bankid varchar(20);
      v_REFID varchar(23);
      v_rqssrc varchar(23);
      v_rqstyp  varchar(23);
      v_strBANKID varchar(100);
      v_strHOSTSTATUS varchar(100);
      ---------------------
---
Cursor C_AFACCTNO_UT(v_Custodycd Varchar2) IS
SELECT nvl(Min(AF.ACCTNO),'NULL') ACCTNO FROM AFMAST AF, CFMAST CF WHERE CF.CUSTID=AF.CUSTID AND AF.STATUS in ('A') /*AND  defbankrece='Y'*/ AND CF.CUSTODYCD=v_Custodycd;

Cursor C_AFACCTNO_NM(v_Custodycd Varchar2) IS
SELECT nvl(Min(AF.ACCTNO),'NULL') ACCTNO FROM AFMAST AF, CFMAST CF WHERE CF.CUSTID=AF.CUSTID AND AF.STATUS in ('A') AND CF.CUSTODYCD=v_Custodycd;

Cursor C_BANKINFO(v_BankID Varchar2) IS
SELECT nvl(Min(BANKACCTNO),'NULL')BANKACCTNO, nvl(Min(GLACCOUNT),'NULL') GLACCOUNT FROM BANKNOSTRO WHERE shortname=v_BankID;



   BEGIN

   Select varvalue into v_strBANKID from sysvar where GRNAME='BANKGW' and VARNAME ='DEFAULTBANKID' ;
   Select varvalue into v_strHOSTSTATUS from sysvar where varname ='HOSTATUS';

       FOR rec IN
       (   SELECT mst.autoid,rqssrc,rqstyp,txdate,
                  rqs_REFID.cvalue REFID, UPPER(rqs_ACCTNO.cvalue) custodycd, rqs_AMOUNT.nvalue AMOUNT,rqs_DESCRIPTION.cvalue DESCRIPTION
            FROM borqslog mst, borqslogdtl  rqs_REFID, borqslogdtl  rqs_ACCTNO,
                 borqslogdtl  rqs_AMOUNT, borqslogdtl rqs_DESCRIPTION
            WHERE rqstyp = 'CRA' AND status = 'P' AND rqssrc = 'MSB'
            AND rqs_REFID.autoid = mst.autoid AND rqs_REFID.varname = 'REFID'
            AND rqs_ACCTNO.autoid = mst.autoid AND rqs_ACCTNO.varname = 'ACCTNO'
            AND rqs_AMOUNT.autoid = mst.autoid AND rqs_AMOUNT.varname = 'AMOUNT'
            AND rqs_DESCRIPTION.autoid = mst.autoid AND rqs_DESCRIPTION.varname = 'DESCRIPTION'
            AND ROWNUM <= 10
            ORDER BY mst.autoid
       )
       LOOP
                v_custodycd:=rec.custodycd;
                v_rqsautoid:= rec.AUTOID;
                v_REFID :=rec.REFID;
                v_rqssrc :=rec.rqssrc;
                v_rqstyp:=rec.rqstyp;

                if v_strHOSTSTATUS ='0' then
                return ;
                end if ;

                 --1. Check thong tin REFID
                If LENGTH(rec.REFID) <> 23 or SUBSTR(rec.REFID,0,2) <>'BO' then
                 v_errcode:=-660050;
                 v_errmsg:='INVALID REFID FORMAT!';
                 end if;

                 --2. Check so tien phai lon hon khong
                 if to_number(rec.AMOUNT) <0 then
                 v_errcode:=-660053;  --khong thay afacctno
                 v_errmsg:='Amount less than 0!';
                 end if;

                 Select count(*) into V_COUNT from borqslog where requestid=rec.REFID;
                 IF V_COUNT > 1 THEN
                        v_errcode:=-660051;
                        v_errmsg:='DOUBLE REFID!';
                        RAISE errnums.E_BIZ_RULE_INVALID;
                 END IF;

                 --3. Lay so tieu khoan nhan tien
                 OPEN C_AFACCTNO_UT(v_custodycd);
                    FETCH C_AFACCTNO_UT INTO v_afacctno;
                    IF v_afacctno='NULL' THEN
                        OPEN C_AFACCTNO_NM(v_custodycd);
                        FETCH C_AFACCTNO_NM INTO v_afacctno;
                            IF v_afacctno='NULL' THEN
                             v_errcode:=-660052;  --khong thay afacctno
                             v_errmsg:='Cannot found afacctno!';
                             RAISE errnums.E_BIZ_RULE_INVALID;
                             END IF;
                    END IF;



                 --4. Lay thong tin ngan hang
                 OPEN C_BANKINFO(v_strBANKID);
                    FETCH  C_BANKINFO INTO l_bankacctno,l_glmast;
                    IF l_bankacctno='NULL' THEN
                     v_errcode:=-660059;  --Khong tim thay thong tin Banks trong he thong
                     v_errmsg:='Cannot found BANKINFO!';
                     RAISE errnums.E_BIZ_RULE_INVALID;
                     END IF;


                 --5. Gen giao dich nhan chuyen khoan 1141
                 txpks_auto.pr_ReceiveTransfer(v_afacctno ,v_strBANKID ,l_bankacctno,l_glmast ,rec.refid ,rec.AMOUNT ,rec.DESCRIPTION ,v_errcode  ,v_txdate  ,v_txnum );


                --6. XU LY LOI
                IF v_errcode=0 THEN
                    v_status:='C';
                ELSE
                    BEGIN
                        SELECT ERRDESC INTO v_errmsg FROM DEFERROR WHERE ERRNUM=v_errcode;
                    EXCEPTION
                    WHEN OTHERS THEN
                        v_errcode:= -99999;
                        v_errmsg:='UNDEFINED ERROR!';
                    END;
                    v_status:='E';
                END IF;
                --7. Cap nhat da xu ly
                UPDATE BORQSLOG
                SET ERRNUM = v_errcode, ERRMSG = v_errmsg, STATUS = v_status, TXDATE= v_txdate, TXNUM=v_txnum
                WHERE autoid = v_rqsautoid;
                --8. Cap nhat vao bang de chuyen qua ngan hang
                INSERT INTO GW_UPDATETRANS (AUTOID,RQSSRC,RQSTYP,FUNCTIONNAME,DIRECTION,REFID,STATUS,ERRNUM,PROCESS)
                VALUES(seq_GWUPDATETRAN.nextval ,rec.RQSSRC,rec.RQSTYP,'UPDATETRANSACTIONSTATUS','C2B',REC.REFID,v_status,v_errcode,'N');
                COMMIT;

       END LOOP;


   EXCEPTION
      WHEN errnums.E_BIZ_RULE_INVALID THEN
          UPDATE BORQSLOG SET ERRNUM = v_errcode, ERRMSG = v_errmsg, STATUS = 'E'
          WHERE autoid = v_rqsautoid;

          -- plog.error(pkgctx, 'quyet.kieu BANK 1' || sqlerrm);
       --9. Cap nhat vao bang de chuyen qua ngan hang
           INSERT INTO GW_UPDATETRANS (AUTOID,RQSSRC,RQSTYP,FUNCTIONNAME,DIRECTION,REFID,STATUS,ERRNUM,PROCESS)
           VALUES(seq_GWUPDATETRAN.nextval ,v_RQSSRC,v_RQSTYP,'UPDATETRANSACTIONSTATUS','C2B',v_REFID,'E',v_errcode,'N');
      WHEN OTHERS THEN
           plog.error(pkgctx, 'quyet.kieu BANK 2' || sqlerrm);
        v_errmsg:= SQLERRM;
          UPDATE BORQSLOG SET ERRNUM = '-1', ERRMSG = 'Error in process: ' || v_errmsg, STATUS = 'E'
          WHERE autoid = v_rqsautoid;

   END;


   PROCEDURE pr_PutbatchProcessC2B
    IS
      v_errcode NUMBER;
      v_status varchar(3);
      v_errmsg varchar(250);
      v_strbatchid  varchar(23);
      v_strTRANSACTIONID  varchar(23);
      V_COUNT number;
      v_strRemark VARCHAR2(500);
      v_strHOSTSTATUS varchar(23);
      v_strBENEFCUSTNAME  VARCHAR2(100);


   BEGIN
   V_COUNT:=0;

   Select 'BI' || to_char(sysdate,'yyyyMMddhhMMssSSS') into v_strbatchid from dual;
   Select varvalue into v_strHOSTSTATUS from sysvar where varname ='HOSTATUS';

   FOR rec IN
       (    Select (Case when ( SUBSTR(a.bankid,0,INSTRC(a.bankid,'.') -1)='302' ) OR a.bankid ='302' then 1 else 2 end) TYPE ,
            a.ACCTNO ,a.BENEFCUSTNAME, benefacct ACCOUNT,AMT AMOUNT,nvl(SUBSTR(a.bankid,0,INSTRC(a.bankid,'.')-1),a.bankid)BANKCODE,
            SUBSTR(a.bankid,INSTRC(a.bankid,'.')+1,LENGTH(a.bankid) -INSTRC(a.bankid,'.')) BANKBRANCHCODE , benefbank BANKNAME ,
            SUBSTR(b.txdesc ,INSTRC(b.txdesc,'/')+1,LENGTH(b.txdesc)-INSTRC(b.txdesc,'/'))  REMARK,
            a.TXNUM,a.TXDATE  from CIREMITTANCE a , Tllog b
            WHERE rmstatus='P' and a.deltd ='N'
            AND (a.txnum = b.txnum and a.txdate = b.txdate)
            AND LENGTH(a.bankid) > 0
            and b.txstatus=1
            and (a.txnum || a.txdate) not in
            ( Select (b.txnum || b.txdate)from gw_putbatchtrans b
              union all
              Select (b.txnum || b.txdate)from gw_putbatchtrans_hist b
            )
            and (SUBSTR(a.bankid,0,INSTRC(a.bankid,'.') -1)='302' OR a.bankid ='302' ) -- hotfix chuyen tien
            --and  a.ACCTNO like '0001%' -- hotfix chi cac tieu khoan hoi so moi duoc chuyen tien
            AND ROWNUM <= 10
       )
   LOOP
         if v_strHOSTSTATUS ='0' then
                return ;
         end if ;

        V_COUNT:=V_COUNT+1;
        v_strTRANSACTIONID :=v_strbatchid || lpad(to_char(v_count),4,'0');
        v_strRemark :=Correct_ReMark(rec.REmark,40);
        v_strBENEFCUSTNAME := UPPER(Correct_ReMark(rec.BENEFCUSTNAME,99));

       --1. Day xuong database cho day len GW , trang thai se la W
        INSERT INTO GW_PUTBATCHTRANS (AUTOID,TXNUM,TXDATE,BATCHID,TRANSACTIONID,FUNCTIONNAME,DIRECTION,TYPE,ACCTNO,BENEFCUSTNAME,ACCOUNT,AMOUNT,BANKCODE,BANKBRANCHCODE,BANKNAME,REMARK,STATUS,ERRNUM,ERRMSG,PROCESS)
        VALUES(seq_PUTBATCHTRANS.nextval,rec.TXNUM,TO_DATE(rec.TXDATE,'DD/MM/RRRR'),v_strbatchid,v_strTRANSACTIONID,'PUTBATCH','C2B',rec.TYPE,rec.ACCTNO,v_strBENEFCUSTNAME,rec.ACCOUNT,rec.AMOUNT,rec.BANKCODE,rec.BANKBRANCHCODE,rec.BANKNAME,v_strRemark,'P',0,NULL,'N');

       --2. Danh dau trong CIREMITTANCE la da duoc day xuong GW_PUTBATCHTRANS cho boc len GW
        Update CIREMITTANCE CI Set rmstatus='W' where CI.txnum=Rec.txnum and Ci.Txdate =rec.txdate;
        COMMIT;

    END LOOP;


   EXCEPTION
      WHEN errnums.E_BIZ_RULE_INVALID THEN
         -- UPDATE BORQSLOG SET ERRNUM = v_errcode, ERRMSG = v_errmsg, STATUS = 'E'
         -- WHERE autoid = v_rqsautoid;
       --9. Cap nhat vao bang de chuyen qua ngan hang
           --INSERT INTO GW_UPDATETRANS (AUTOID,RQSSRC,RQSTYP,FUNCTIONNAME,DIRECTION,REFID,STATUS,ERRNUM,PROCESS)
           --VALUES(seq_GWUPDATETRAN.nextval ,v_RQSSRC,v_RQSTYP,'UPDATETRANSACTIONSTATUS','C2B',v_REFID,'E',v_errcode,'N');
           null;
      WHEN OTHERS THEN
      null;
        v_errmsg:= SQLERRM;
         -- UPDATE BORQSLOG SET ERRNUM = '-1', ERRMSG = 'Error in process: ' || v_errmsg, STATUS = 'E'
       --   WHERE autoid = v_rqsautoid;
       Null;
   END;

 PROCEDURE pr_Complete_PutbatchC2B
    IS
      -- Enter the procedure variables here. As shown below
      v_errcode NUMBER;
      --V_COUNT number;

      ---------------------
      v_status varchar(3);
      v_errmsg varchar(250);
      v_strbatchid  varchar(23);
      v_strTRANSACTIONID  varchar(23);
      V_COUNT number;
      v_strRemark VARCHAR2(500);

      l_txmsg               tx.msg_rectype;
      v_strCURRDATE varchar2(20);
      l_err_param varchar2(300);
      v_strbankacctno varchar2(300);
      v_fullnameBank varchar2(300);
      v_GLmap varchar2(300);
      v_BANKACCNAME varchar2(300);
      v_POTXNUM varchar2(100);
      v_strREFID varchar2(100);
      v_strAutoID varchar2(100);
      v_strBANKID varchar2(100);
      v_strHOSTSTATUS varchar2(100);


   BEGIN
   Select varvalue into v_strBANKID from sysvar where GRNAME='BANKGW' and VARNAME ='DEFAULTBANKID' ;
   Select varvalue into v_strHOSTSTATUS from sysvar where varname ='HOSTATUS';

   V_COUNT:=0;

   Select 'BI' || to_char(sysdate,'yyyyMMddhhMMssSSS') into v_strbatchid from dual;
   Select bankacctno,fullname,glaccount,ownername INTO v_strbankacctno,v_fullnameBank,v_GLmap,v_BANKACCNAME from banknostro where shortname=v_strBANKID ;

   FOR rec IN
       (    SELECT GWU.status, GWU.REFID REFID,FN_GET_LOCATION(af.brid) LOCATION, SUBSTR(RM.TXNUM,1,4) BRID, CF.FULLNAME,T1.TLNAME MAKER,T2.TLNAME OFFICER,
           CF.CUSTODYCD , CD1.CDCONTENT DESC_IDTYPE, CF.IDCODE,
           AF.ACCTNO ,CF.CUSTID, RM.TXDATE, RM.TXNUM, RM.BANKID,RM.BENEFBANK,RM.CITYEF,RM.CITYBANK,
           RM.BENEFACCT, RM.BENEFCUSTNAME, RM.BENEFLICENSE, RM.BENEFIDDATE, RM.BENEFIDPLACE, RM.AMT, RM.FEEAMT,AF.ACCTNO || ' : ' ||TL.TXDESC DESCRIPTION,
           RM.FEETYPE,CF.IDDATE,CF.IDPLACE,CF.ADDRESS,A1.CDCONTENT FEENAME,  '' GLACCTNO,  '' POTXNUM, '' POTXDATE, '' BANKNAME, '' BANKACC, '001' POTYPE
           FROM CIREMITTANCE RM, AFMAST AF, CFMAST CF, ALLCODE A1,  ALLCODE CD1,(SELECT TLID, TLNAME FROM TLPROFILES UNION ALL SELECT '____' TLID, '____' TLNAME FROM DUAL) T1,
           (SELECT TLID, TLNAME FROM TLPROFILES UNION ALL SELECT '____' TLID, '____' TLNAME FROM DUAL) T2,
           (SELECT * FROM TLLOG WHERE TLTXCD in('1101','1108','1111','1185') AND TXSTATUS='1') TL , gw_putbatchtrans GWP , gw_updatetrans GWU
           WHERE CF.CUSTID=AF.CUSTID AND RM.ACCTNO=AF.ACCTNO AND RM.DELTD='N' AND RM.RMSTATUS='W' AND TL.TXNUM=RM.TXNUM AND TL.TXDATE=RM.TXDATE
           AND CD1.CDTYPE='CF' AND CD1.CDNAME='IDTYPE' AND CD1.CDVAL=CF.IDTYPE
           AND A1.CDTYPE='SA' AND A1.CDNAME='IOROFEE' AND A1.CDVAL=NVL(RM.FEETYPE,'0')
           AND (CASE WHEN TL.TLID IS NULL THEN '____' ELSE TL.TLID END)=T1.TLID
           AND (CASE WHEN TL.OFFID IS NULL THEN '____' ELSE TL.OFFID END)=T2.TLID AND  0 = 0
           AND RM.TXNUM =  GWP.TXNUM and RM.TXDATE = GWP.TXDATE
           AND GWP.transactionid = GWU.REFID
           AND GWP.direction ='C2B'
           AND GWU.direction='B2C'
           AND GWU.functionname='UPDATETRANS'
           --AND GWU.status =0
           and GWU.PROCESS='N'
       )
       LOOP
      ------------------------------------------------------


   v_strREFID := REC.REFID;

    if v_strHOSTSTATUS ='0' then
                return ;
     end if ;

   if Rec.STATUS <>'0' then
   -- Neu ngan gang bao co loi
        UPDATE GW_UPDATETRANS SET PROCESS ='Y' WHERE  RQSSRC='MSB' AND DIRECTION='B2C' AND FUNCTIONNAME='UPDATETRANS' AND   REFID = V_STRREFID;
        UPDATE GW_PUTBATCHTRANS SET STATUS ='E' , errnum =Rec.status  WHERE FUNCTIONNAME ='PUTBATCH' AND DIRECTION ='C2B' AND TRANSACTIONID= V_STRREFID;
        Update CIREMITTANCE CI Set rmstatus='E' where CI.txnum=Rec.txnum and Ci.Txdate =rec.txdate;
        COMMIT;
        return;
   end if ;

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
    l_txmsg.batchname   := 'INT';
    l_txmsg.txdate:=to_date(v_strCURRDATE,systemnums.c_date_format);
    l_txmsg.busdate:=to_date(v_strCURRDATE,systemnums.c_date_format);
    l_txmsg.tltxcd:='1104';

    --Set txnum
    SELECT systemnums.C_BATCH_PREFIXED
                     || LPAD (seq_BATCHTXNUM.NEXTVAL, 8, '0')
              INTO l_txmsg.txnum
              FROM DUAL;
    l_txmsg.brid        := substr(REC.ACCTNO,1,4);

   -- p_txnum:=l_txmsg.txnum;
   -- p_txdate:=l_txmsg.txdate;

  --Set cac field giao dich
    --03   ACCTNO          C
    l_txmsg.txfields ('03').defname   := 'ACCTNO';
    l_txmsg.txfields ('03').TYPE      := 'C';
    l_txmsg.txfields ('03').VALUE     := REC.ACCTNO;
     --91   ADDRESS         C
    l_txmsg.txfields ('91').defname   := 'ADDRESS';
    l_txmsg.txfields ('91').TYPE      := 'C';
    l_txmsg.txfields ('91').VALUE     :=  REC.ADDRESS;
     --90   CUSTNAME        C
    l_txmsg.txfields ('90').defname   := 'CUSTNAME';
    l_txmsg.txfields ('90').TYPE      := 'C';
    l_txmsg.txfields ('90').VALUE     :=REC.FULLNAME;
     --04   ACCTNO          C
    l_txmsg.txfields ('04').defname   := 'CUSTODYCD';
    l_txmsg.txfields ('04').TYPE      := 'C';
    l_txmsg.txfields ('04').VALUE     := REC.CUSTODYCD;
     --03   ACCTNO          C
    l_txmsg.txfields ('92').defname   := 'LICENSE';
    l_txmsg.txfields ('92').TYPE      := 'C';
    l_txmsg.txfields ('92').VALUE     := REC.IDCODE;
        --03   ACCTNO          C
    l_txmsg.txfields ('67').defname   := 'IDDATE';
    l_txmsg.txfields ('67').TYPE      := 'C';
    l_txmsg.txfields ('67').VALUE     := REC.IDDATE;

    --02   BANKID          C
    l_txmsg.txfields ('06').defname   := 'TXDATE';
    l_txmsg.txfields ('06').TYPE      := 'D';
    l_txmsg.txfields ('06').VALUE     := REC.TXDATE;

    --07   BANKID          C
    l_txmsg.txfields ('07').defname   := 'TXNUM';
    l_txmsg.txfields ('07').TYPE      := 'C';
    l_txmsg.txfields ('07').VALUE     := REC.TXNUM;

    --06   GLMAST          C
    l_txmsg.txfields ('81').defname   := 'BENEFACCT';
    l_txmsg.txfields ('81').TYPE      := 'C';
    l_txmsg.txfields ('81').VALUE     := REC.BENEFACCT;

    --10   AMT          N
    l_txmsg.txfields ('05').defname   := 'BANKID';
    l_txmsg.txfields ('05').TYPE      := 'C';
    l_txmsg.txfields ('05').VALUE     := REC.BANKID;

    --30   DESC            C
    l_txmsg.txfields ('10').defname   := 'AMT';
    l_txmsg.txfields ('10').TYPE      := 'N';
    l_txmsg.txfields ('10').VALUE     :=REC.AMT;


    --82   CUSTODYCD   C
    l_txmsg.txfields ('32').defname   := 'CITYBANK';
    l_txmsg.txfields ('32').TYPE      := 'C';
    l_txmsg.txfields ('32').VALUE     := REC.CITYBANK;



    --92   LICENSE         C
    l_txmsg.txfields ('33').defname   := 'CITYEF';
    l_txmsg.txfields ('33').TYPE      := 'C';
    l_txmsg.txfields ('33').VALUE     :=REC.CITYEF;
    --93   IDDATE          C
    l_txmsg.txfields ('80').defname   := 'BENEFBANK';
    l_txmsg.txfields ('80').TYPE      := 'C';
    l_txmsg.txfields ('80').VALUE     :=REC.BENEFBANK;
    --94   IDPLACE         C
    l_txmsg.txfields ('30').defname   := 'DESC';
    l_txmsg.txfields ('30').TYPE      := 'C';
    l_txmsg.txfields ('30').VALUE     :=REC.DESCRIPTION;
      --94   IDPLACE         C
    l_txmsg.txfields ('82').defname   := 'BENEFCUSTNAME';
    l_txmsg.txfields ('82').TYPE      := 'C';
    l_txmsg.txfields ('82').VALUE     :=REC.BENEFCUSTNAME;
      --94   IDPLACE         C
    l_txmsg.txfields ('83').defname   := 'RECEIVLICENSE';
    l_txmsg.txfields ('83').TYPE      := 'C';
    l_txmsg.txfields ('83').VALUE     :='';
      --94   IDPLACE         C
    l_txmsg.txfields ('95').defname   := 'RECEIVIDDATE';
    l_txmsg.txfields ('95').TYPE      := 'C';
    l_txmsg.txfields ('95').VALUE :='';

        --94   IDPLACE         C
    l_txmsg.txfields ('96').defname   := 'RECEIVIDPLACE';
    l_txmsg.txfields ('96').TYPE      := 'C';
    l_txmsg.txfields ('96').VALUE :='';
      --94   IDPLACE         C
    l_txmsg.txfields ('98').defname   := 'POTXDATE';
    l_txmsg.txfields ('98').TYPE      := 'C';
    l_txmsg.txfields ('98').VALUE     := REC.TXDATE;
      --94   IDPLACE         C
    l_txmsg.txfields ('08').defname   := 'BANKACC';
    l_txmsg.txfields ('08').TYPE      := 'C';
    l_txmsg.txfields ('08').VALUE :=v_strbankacctno;
      --94   IDPLACE         C
    l_txmsg.txfields ('09').defname   := 'IORO';
    l_txmsg.txfields ('09').TYPE      := 'C';
    l_txmsg.txfields ('09').VALUE     :=REC.FEETYPE;

            --94   IDPLACE         C
    l_txmsg.txfields ('15').defname   := 'GLMAST';
    l_txmsg.txfields ('15').TYPE      := 'C';
    l_txmsg.txfields ('15').VALUE     :=v_GLmap;
      --94   IDPLACE         C
    l_txmsg.txfields ('85').defname   := 'BANKNAME';
    l_txmsg.txfields ('85').TYPE      := 'C';
    l_txmsg.txfields ('85').VALUE     :=v_fullnameBank;
      --94   IDPLACE         C

      SELECT NVL(MAX(ODR)+1,1) INTO v_strAutoID  FROM
                  (SELECT ROWNUM ODR, INVACCT
                  FROM (SELECT TXNUM INVACCT FROM POMAST WHERE BRID = REC.BRID ORDER BY TXNUM) DAT
                  ) INVTAB;

    v_POTXNUM := REC.BRID || LPAD(v_strAutoID,6,'0');

    l_txmsg.txfields ('99').defname   := 'POTXNUM';
    l_txmsg.txfields ('99').TYPE      := 'C';
    l_txmsg.txfields ('99').VALUE     := v_POTXNUM;
      --94   IDPLACE         C
    l_txmsg.txfields ('86').defname   := 'BANKACCNAME';
    l_txmsg.txfields ('86').TYPE      := 'C';
    l_txmsg.txfields ('86').VALUE :=  v_BANKACCNAME;
       --94   IDPLACE         C
    l_txmsg.txfields ('17').defname   := 'POTYPE';
    l_txmsg.txfields ('17').TYPE      := 'C';
    l_txmsg.txfields ('17').VALUE :=REC.POTYPE;
    BEGIN
        IF txpks_#1104.fn_autotxprocess (l_txmsg,
                                         v_errcode,
                                         l_err_param
           ) <> systemnums.c_success
        THEN
           plog.debug (pkgctx,
                       'got error 1104: ' || v_errcode
           );
           ROLLBACK;
           RETURN;
        END IF;
    END;
    v_errcode:=0;
    plog.setendsection(pkgctx, 'pr_Complete_PutbatchC2B');
      -----------------END-----------------------------------
        UPDATE GW_UPDATETRANS SET PROCESS ='Y' WHERE  RQSSRC='MSB' AND DIRECTION='B2C' AND FUNCTIONNAME='UPDATETRANS' AND   REFID = V_STRREFID;
        UPDATE GW_PUTBATCHTRANS SET STATUS ='C' WHERE FUNCTIONNAME ='PUTBATCH' AND DIRECTION ='C2B' AND TRANSACTIONID= V_STRREFID;
        COMMIT;
    END LOOP;


   EXCEPTION
      WHEN errnums.E_BIZ_RULE_INVALID THEN

        UPDATE GW_UPDATETRANS SET PROCESS ='Y' WHERE  RQSSRC='MSB' AND DIRECTION='B2C' AND FUNCTIONNAME='UPDATETRANS' AND   REFID = V_STRREFID;
        UPDATE GW_PUTBATCHTRANS SET STATUS ='E' WHERE FUNCTIONNAME ='PUTBATCH' AND DIRECTION ='C2B' AND TRANSACTIONID= V_STRREFID;
        COMMIT;

      WHEN OTHERS THEN

        UPDATE GW_UPDATETRANS SET PROCESS ='Y' WHERE  RQSSRC='MSB' AND DIRECTION='B2C' AND FUNCTIONNAME='UPDATETRANS' AND   REFID = V_STRREFID;
        UPDATE GW_PUTBATCHTRANS SET STATUS ='E' WHERE FUNCTIONNAME ='PUTBATCH' AND DIRECTION ='C2B' AND TRANSACTIONID= V_STRREFID;
        COMMIT;
        v_errmsg:= SQLERRM;
       Null;
   END;


   PROCEDURE pr_CreateFileCheck(
   F_DATE IN  VARCHAR2,
   T_DATE IN  VARCHAR2
   )
    IS
      v_TotalB2C          VARCHAR2(25);
      v_TotalB2C_Success  VARCHAR2(25);
      v_TotalB2CAMT       VARCHAR2(25);
      v_TotalC2B            VARCHAR2(25);
      v_TotalC2B_Success    VARCHAR2(25);
      v_TotalC2BAMT         VARCHAR2(25);
      v_TotalC2BN            VARCHAR2(25);
      v_TotalC2BN_Success    VARCHAR2(25);
      v_TotalC2BNAMT         VARCHAR2(25);
      v_TotalC2BL            VARCHAR2(25);
      v_TotalC2BL_Success    VARCHAR2(25);
      v_TotalC2BLAMT         VARCHAR2(25);
      v_errmsg            VARCHAR2(200);

   BEGIN

             Delete from  GW_TRANSCHKFILE ;


            --1 BANH GUI SANG NGAN HANG
             Select count(*) into v_TotalB2C
             from borqslog
             where rqstyp='CRA' and  rqssrc='MSB'
             and txdate >= TO_DATE (F_DATE, 'DD/MM/YYYY')
             and txdate <= TO_DATE (T_DATE, 'DD/MM/YYYY');

            --2. Nhung giao dich thanh cong---
            Select count(*) into v_TotalB2C_Success
            from borqslog where rqstyp='CRA' and  rqssrc='MSB'
            and status ='C'
            and txdate >= TO_DATE (F_DATE, 'DD/MM/YYYY')
            and txdate <= TO_DATE (T_DATE, 'DD/MM/YYYY');

            --3. Tong Tien cua cac giao dich thanh cong
            Select SUM(msgamt) into v_TotalB2CAMT from borqslog where rqstyp='CRA'
            and  rqssrc='MSB'
            and status ='C'
            and txdate >= TO_DATE (F_DATE, 'DD/MM/YYYY')
            and txdate <= TO_DATE (T_DATE, 'DD/MM/YYYY');

            INSERT INTO GW_TRANSCHKFILE (STT,TRANS_CODE,TRANS_NAME,TOTAL_TRANS_MSBS,SUCCESS_TRANS_MSBS,TOTAL_AMOUNT_MSBS,TOTAL_FEE_MSBS,FROM_DATE,TO_DATE)
            VALUES('1','B2C','Tu MSB sang MSBS',v_TotalB2C,v_TotalB2C_Success,v_TotalB2CAMT,'0',F_DATE,T_DATE);

            ----MSBS chuyen sang BANK ===============================
            Select count(*)  into v_TotalC2B from
              (
                Select * from gw_putbatchtrans
                union all
                Select * from gw_putbatchtrans_hist
              )
            where direction ='C2B' and functionname ='PUTBATCH' and process ='Y' and  status <>'P'
            and txdate >= TO_DATE (F_DATE, 'DD/MM/YYYY')
            and txdate <= TO_DATE (T_DATE, 'DD/MM/YYYY');


            Select count(*) into v_TotalC2B_Success from
            (
                Select * from gw_putbatchtrans
                union all
                Select * from gw_putbatchtrans_hist
             )
            where direction ='C2B' and functionname ='PUTBATCH' and process ='Y' and  status ='C'
            and txdate >= TO_DATE (F_DATE, 'DD/MM/YYYY')
            and txdate <= TO_DATE (T_DATE, 'DD/MM/YYYY');

            Select  nvl(SUM(AMOUNT),0) into v_TotalC2BAMT from
            (
                Select * from gw_putbatchtrans
                union all
                Select * from gw_putbatchtrans_hist
            )
            where direction ='C2B' and functionname ='PUTBATCH' and process ='Y' and  status ='C'
            and txdate >= TO_DATE (F_DATE, 'DD/MM/YYYY')
            and txdate <= TO_DATE (T_DATE, 'DD/MM/YYYY');

            INSERT INTO GW_TRANSCHKFILE (STT,TRANS_CODE,TRANS_NAME,TOTAL_TRANS_MSBS,SUCCESS_TRANS_MSBS,TOTAL_AMOUNT_MSBS,TOTAL_FEE_MSBS,FROM_DATE,TO_DATE)
            VALUES('2','C2B','Tu MSBS sang BANK',v_TotalC2B,v_TotalC2B_Success,v_TotalC2BAMT,'0',F_DATE,T_DATE);

            ----3. MSBS chuyen sang BANK NOI BO ===============================
            Select count(*)  into v_TotalC2BN from
            (
                Select * from gw_putbatchtrans
                union all
                Select * from gw_putbatchtrans_hist
            )
            where direction ='C2B' and functionname ='PUTBATCH' and process ='Y' and  status <>'P' and type='1'
            and txdate >= TO_DATE (F_DATE, 'DD/MM/YYYY')
            and txdate <= TO_DATE (T_DATE, 'DD/MM/YYYY');


            Select count(*) into v_TotalC2BN_Success from
            (
                Select * from gw_putbatchtrans
                union all
                Select * from gw_putbatchtrans_hist
            )
            where direction ='C2B' and functionname ='PUTBATCH' and process ='Y' and  status ='C' and type='1'
            and txdate >= TO_DATE (F_DATE, 'DD/MM/YYYY')
            and txdate <= TO_DATE (T_DATE, 'DD/MM/YYYY');

            Select  nvl(SUM(AMOUNT),0) into v_TotalC2BNAMT from
            (
                Select * from gw_putbatchtrans
                union all
                Select * from gw_putbatchtrans_hist
            )
            where direction ='C2B' and functionname ='PUTBATCH' and process ='Y' and  status ='C' and type='1'
            and txdate >= TO_DATE (F_DATE, 'DD/MM/YYYY')
            and txdate <= TO_DATE (T_DATE, 'DD/MM/YYYY');

            INSERT INTO GW_TRANSCHKFILE (STT,TRANS_CODE,TRANS_NAME,TOTAL_TRANS_MSBS,SUCCESS_TRANS_MSBS,TOTAL_AMOUNT_MSBS,TOTAL_FEE_MSBS,FROM_DATE,TO_DATE)
            VALUES('3','C2BN','Tu MSBS sang BANK NOI BO',v_TotalC2BN,v_TotalC2BN_Success,v_TotalC2BNAMT,'0',F_DATE,T_DATE);

            ----4. MSBS chuyen sang BANK LIEN NGAN HANG ===============================
            Select count(*)  into v_TotalC2BL from
            (
                Select * from gw_putbatchtrans
                union all
                Select * from gw_putbatchtrans_hist
            )
            where direction ='C2B' and functionname ='PUTBATCH' and process ='Y' and  status <>'P' and type='2'
            and txdate >= TO_DATE (F_DATE, 'DD/MM/YYYY')
            and txdate <= TO_DATE (T_DATE, 'DD/MM/YYYY');


            Select count(*) into v_TotalC2BL_Success from
            (
                Select * from gw_putbatchtrans
                union all
                Select * from gw_putbatchtrans_hist
            )
            where direction ='C2B' and functionname ='PUTBATCH' and process ='Y' and  status ='C'  and type='2'
            and txdate >= TO_DATE (F_DATE, 'DD/MM/YYYY')
            and txdate <= TO_DATE (T_DATE, 'DD/MM/YYYY');

            Select nvl(SUM(AMOUNT),0) into v_TotalC2BLAMT from
            (
                Select * from gw_putbatchtrans
                union all
                Select * from gw_putbatchtrans_hist
            )

            where direction ='C2B' and functionname ='PUTBATCH' and process ='Y' and  status ='C'  and type='2'
            and txdate >= TO_DATE (F_DATE, 'DD/MM/YYYY')
            and txdate <= TO_DATE (T_DATE, 'DD/MM/YYYY');

            INSERT INTO GW_TRANSCHKFILE (STT,TRANS_CODE,TRANS_NAME,TOTAL_TRANS_MSBS,SUCCESS_TRANS_MSBS,TOTAL_AMOUNT_MSBS,TOTAL_FEE_MSBS,FROM_DATE,TO_DATE)
            VALUES('4','C2BL','Tu MSBS sang BANK Lien ngan hang',v_TotalC2BL,v_TotalC2BL_Success,v_TotalC2BLAMT,'0',F_DATE,T_DATE);


   EXCEPTION
      WHEN errnums.E_BIZ_RULE_INVALID THEN
           null;
      WHEN OTHERS THEN
      null;
   END;

END; 
/
