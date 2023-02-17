SET DEFINE OFF;
CREATE OR REPLACE PROCEDURE pr_rmexca3350(p_rundate IN varchar2,p_err_code  OUT varchar2)
  IS

    l_txmsg tx.msg_rectype;
    l_CURRDATE varchar2(20);
    l_Desc varchar2(1000);
    l_EN_Desc varchar2(1000);
    l_OrgDesc varchar2(1000);
    l_EN_OrgDesc varchar2(1000);
    l_err_param varchar2(300);
    l_tltx  varchar2(4);
    l_begindate varchar2(10);
  BEGIN
    l_tltx:='6643';

    SELECT TXDESC,EN_TXDESC into l_OrgDesc, l_EN_OrgDesc FROM  TLTX WHERE TLTXCD=l_tltx;
     SELECT TO_DATE (varvalue, systemnums.c_date_format)
               INTO l_CURRDATE
               FROM sysvar
               WHERE grname = 'SYSTEM' AND varname = 'CURRDATE';
    l_begindate:=l_CURRDATE;
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
    l_txmsg.batchname   := 'RMEXCA3350';
    l_txmsg.txdate:=to_date(l_CURRDATE,systemnums.c_date_format);
    l_txmsg.busdate:=to_date(l_CURRDATE,systemnums.c_date_format);
    l_txmsg.tltxcd:=l_tltx;

    for rec in
    (
        SELECT LOG.TXNUM,LOG.TXDATE,LOG.TLTXCD,CRA.TRFCODE TRFTYPE,AF.ACCTNO AFACCTNO,CF.CUSTODYCD,
        CF.FULLNAME,CF.ADDRESS,CF.IDCODE LICENSE,CEIL(LOG.MSGAMT) AMOUNT,CEIL(NVL(TLF1.NVALUE,0)) DUTYAMT,AF.BANKACCTNO,
        CRA.REFACCTNO DESACCTNO,CRA.REFACCTNAME DESACCTNAME,
        CRB.BANKCODE,(CRB.BANKNAME || ':' || CRB.BANKNAME) BANKNAME,
        LOG.MSGACCT ACCTNO,TLF.CVALUE DEST
        FROM
        TLLOGALL LOG,TLLOGFLDALL TLF,TLLOGFLDALL TLF1,AFMAST AF,CFMAST CF,CIMAST CI,CRBDEFACCT CRA,CRBDEFBANK CRB
        WHERE AF.ACCTNO = LOG.MSGACCT AND CI.AFACCTNO = AF.ACCTNO AND AF.CUSTID=CF.CUSTID
        AND LOG.TXNUM=TLF.TXNUM AND LOG.TXDATE=TLF.TXDATE AND TLF.FLDCD='30'
        AND LOG.TXNUM=TLF1.TXNUM AND LOG.TXDATE=TLF1.TXDATE AND TLF1.FLDCD='20'
        AND AF.BANKNAME=CRA.REFBANK AND CRA.TRFCODE='TRFCACASH' AND AF.BANKNAME=CRB.BANKCODE
        AND CI.corebank='Y' AND LOG.DELTD<>'Y' AND LOG.TXDATE=TO_DATE(p_rundate,'DD/MM/RRRR')
        AND AF.BANKACCTNO IS NOT NULL AND LOG.TLTXCD IN ('3350','3354')
        AND NOT EXISTS (
          SELECT REQ.REFCODE FROM (SELECT * FROM CRBTXREQ UNION ALL SELECT * FROM CRBTXREQHIST) REQ
          WHERE REQ.TRFCODE='TRFCACASH'
          AND (REQ.TXDATE=TO_DATE(l_CURRDATE,'DD/MM/RRRR') OR REQ.TXDATE=TO_DATE(p_rundate,'DD/MM/RRRR'))
          AND TRUNC(REQ.REFCODE)=TRUNC(LOG.TXNUM)
        )
        ORDER BY LOG.AUTOID ASC
    )
    loop -- rec
        --set txnum
        SELECT systemnums.C_BATCH_PREFIXED
                             || LPAD (seq_BATCHTXNUM.NEXTVAL, 8, '0')
                      INTO l_txmsg.txnum
                      FROM DUAL;
        l_txmsg.brid        := substr(rec.AFACCTNO,1,4);

        --Set cac field giao dich
        --06   C   TRFTYPE
        l_txmsg.txfields ('06').defname   := 'TRFTYPE';
        l_txmsg.txfields ('06').TYPE      := 'C';
        l_txmsg.txfields ('06').VALUE     := rec.TRFTYPE;

        --03  SECACCOUNT
        l_txmsg.txfields ('03').defname   := 'SECACCOUNT';
        l_txmsg.txfields ('03').TYPE      := 'C';
        l_txmsg.txfields ('03').VALUE     := rec.AFACCTNO;

        --90  CUSTNAME
        l_txmsg.txfields ('90').defname   := 'CUSTNAME';
        l_txmsg.txfields ('90').TYPE      := 'C';
        l_txmsg.txfields ('90').VALUE     := rec.FULLNAME;

        --91  ADDRESS
        l_txmsg.txfields ('91').defname   := 'ADDRESS';
        l_txmsg.txfields ('91').TYPE      := 'C';
        l_txmsg.txfields ('91').VALUE     := rec.ADDRESS;

        --92  LICENSE
        l_txmsg.txfields ('92').defname   := 'LICENSE';
        l_txmsg.txfields ('92').TYPE      := 'C';
        l_txmsg.txfields ('92').VALUE     := rec.LICENSE;

        --93  BANKACCTNO
        l_txmsg.txfields ('93').defname   := 'BANKACCTNO';
        l_txmsg.txfields ('93').TYPE      := 'C';
        l_txmsg.txfields ('93').VALUE     := rec.BANKACCTNO;

        --05  DESACCTNO
        l_txmsg.txfields ('05').defname   := 'DESACCTNO';
        l_txmsg.txfields ('05').TYPE      := 'C';
        l_txmsg.txfields ('05').VALUE     := rec.DESACCTNO;

        --07  DESACCTNAME
        l_txmsg.txfields ('07').defname   := 'DESACCTNAME';
        l_txmsg.txfields ('07').TYPE      := 'C';
        l_txmsg.txfields ('07').VALUE     := rec.DESACCTNAME;

        --94  BANKNAME
        l_txmsg.txfields ('94').defname   := 'BANKNAME';
        l_txmsg.txfields ('94').TYPE      := 'C';
        l_txmsg.txfields ('94').VALUE     := rec.BANKNAME;

        --95  BANKQUE
        l_txmsg.txfields ('95').defname   := 'BANKQUE';
        l_txmsg.txfields ('95').TYPE      := 'C';
        l_txmsg.txfields ('95').VALUE     := rec.BANKCODE;

        --10  AMOUNT
        l_txmsg.txfields ('10').defname   := 'AMOUNT';
        l_txmsg.txfields ('10').TYPE      := 'N';
        IF rec.TLTXCD='3350' THEN
            l_txmsg.txfields ('10').VALUE     := rec.AMOUNT;
        ELSE
            l_txmsg.txfields ('10').VALUE     := rec.AMOUNT - rec.DUTYAMT;
        END IF;

        --02  CATXNUM
        l_txmsg.txfields ('02').defname   := 'CATXNUM';
        l_txmsg.txfields ('02').TYPE      := 'C';
        l_txmsg.txfields ('02').VALUE     := rec.TXNUM;

        --30   C   DESC
        l_txmsg.txfields ('30').defname   := 'DESC';
        l_txmsg.txfields ('30').TYPE      := 'C';
        l_txmsg.txfields ('30').VALUE := rec.DEST || ' , TK : ' || rec.CUSTODYCD;

        BEGIN
            IF txpks_#6643.fn_batchtxprocess (l_txmsg,
                                             p_err_code,
                                             l_err_param
               ) <> systemnums.c_success
            THEN

               ROLLBACK;
               RETURN;
            END IF;
        END;
    end loop; -- rec

    commit;
    
    sp_exec_create_crbtxreq_tltxcd(p_err_code,l_tltx,null);
    
    commit;

    p_err_code:=0;
  EXCEPTION
  WHEN OTHERS
   THEN
      p_err_code := errnums.C_SYSTEM_ERROR;
      RAISE errnums.E_SYSTEM_ERROR;
  END;
 
 
 
 
 
 
 
 
 
 
 
 
 
/
