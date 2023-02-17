SET DEFINE OFF;
CREATE OR REPLACE PROCEDURE "SP_RM_UNHOLDCANCELOD"
   ( pv_strORDERID IN VARCHAR2,
     pv_dblCancelQtty IN NUMBER,
     pv_strErrorCode OUT VARCHAR2)
   IS
   l_txmsg tx.msg_rectype;
   v_strAFAcctNo VARCHAR2(10);
   v_strCOREBANK VARCHAR2(10);
   v_strBANKCODE  VARCHAR2(10);
   v_dblBratio  NUMBER(20,4);
   v_dblQuotePrice NUMBER(20,4);
   v_dblUnholdBalance NUMBER(20,0);
   v_tltxcd VARCHAR2(4);
   v_strDesc VARCHAR2(250);
   v_strEN_Desc VARCHAR2(250);
   v_strNotes VARCHAR2(250);
   v_strCURRDATE VARCHAR2(10);
   l_err_param VARCHAR2(10);
BEGIN
    v_dblUnholdBalance:=0;
    --Lay thong tin lenh, gia, ti le ky quy va check luon tk do co phai corebank hay ko
    SELECT OD.AFACCTNO,CI.COREBANK,AF.BANKNAME BANKCODE,OD.BRATIO,OD.QUOTEPRICE,
    DECODE(OD.EXECTYPE,'NB','CB','NS','CS','MS','CS') || '.' || SI.SYMBOL || ': '
    || TO_CHAR(pv_dblCancelQtty) || '@' || DECODE(OD.PRICETYPE,'LO',
    TO_CHAR(OD.QUOTEPRICE), OD.PRICETYPE) NOTES
    INTO v_strAFAcctNo,v_strCOREBANK,v_strBANKCODE,v_dblBratio,v_dblQuotePrice,v_strNotes
    FROM ODMAST OD,CIMAST CI,AFMAST AF,CFMAST CF,SECURITIES_INFO SI
    WHERE OD.AFACCTNO=CI.AFACCTNO AND OD.CODEID=SI.CODEID
    AND OD.AFACCTNO=AF.ACCTNO AND AF.CUSTID=CF.CUSTID
    AND OD.ORDERID=pv_strORDERID;
    --Neu tk la corebank thi tinh gia tri can huy
    IF v_strCOREBANK='Y' THEN
        v_dblUnholdBalance := pv_dblCancelQtty*v_dblQuotePrice*v_dblBratio/100;
        --Generate lenh unhold doi voi tk corebank
        IF v_dblUnholdBalance>0 THEN
            v_tltxcd:='6640';

            SELECT TXDESC,EN_TXDESC into v_strDesc, v_strEN_Desc
            FROM  TLTX WHERE TLTXCD=v_tltxcd;

            SELECT varvalue
            INTO v_strCURRDATE
            FROM sysvar
            WHERE grname = 'SYSTEM' AND varname = 'CURRDATE';

            SELECT systemnums.C_BATCH_PREFIXED
            || LPAD (seq_BATCHTXNUM.NEXTVAL, 8, '0')
            INTO l_txmsg.txnum
            FROM DUAL;

            l_txmsg.brid := substr(v_strAFAcctNo,1,4);

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
            l_txmsg.batchname   := 'BANK';
            l_txmsg.txdate:=to_date(v_strCURRDATE,systemnums.c_date_format);
            l_txmsg.busdate:=to_date(v_strCURRDATE,systemnums.c_date_format);
            l_txmsg.tltxcd:=v_tltxcd;
            SELECT TXDESC,EN_TXDESC into v_strDesc, v_strEN_Desc
            FROM  TLTX WHERE TLTXCD=v_tltxcd;

            FOR rec IN
            (
                SELECT CF.CUSTODYCD,CF.FULLNAME,CF.ADDRESS,CF.IDCODE LICENSE,AF.CAREBY,
                AF.BANKACCTNO,AF.BANKNAME||':'||CRB.BANKNAME BANKNAME,0 BANKAVAIL,
                CI.HOLDBALANCE BANKHOLDED,getavlpp(AF.ACCTNO) AVLRELEASE,CI.HOLDBALANCE HOLDAMT
                FROM AFMAST AF,CFMAST CF,CIMAST CI,CRBDEFBANK CRB
                WHERE AF.CUSTID=CF.CUSTID AND CI.AFACCTNO=AF.ACCTNO
                AND AF.BANKNAME=CRB.BANKCODE AND AF.ACCTNO=v_strAFAcctNo
            )
            LOOP
                l_txmsg.txfields ('88').defname   := 'CUSTODYCD';
                l_txmsg.txfields ('88').TYPE      := 'C';
                l_txmsg.txfields ('88').VALUE     := rec.CUSTODYCD;

                l_txmsg.txfields ('03').defname   := 'SECACCOUNT';
                l_txmsg.txfields ('03').TYPE      := 'C';
                l_txmsg.txfields ('03').VALUE     := v_strAFAcctNo;

                l_txmsg.txfields ('90').defname   := 'CUSTNAME';
                l_txmsg.txfields ('90').TYPE      := 'C';
                l_txmsg.txfields ('90').VALUE     := rec.FULLNAME;

                l_txmsg.txfields ('91').defname   := 'ADDRESS';
                l_txmsg.txfields ('91').TYPE      := 'C';
                l_txmsg.txfields ('91').VALUE     := rec.ADDRESS;

                l_txmsg.txfields ('92').defname   := 'LICENSE';
                l_txmsg.txfields ('92').TYPE      := 'C';
                l_txmsg.txfields ('92').VALUE     := rec.LICENSE;

                l_txmsg.txfields ('97').defname   := 'CAREBY';
                l_txmsg.txfields ('97').TYPE      := 'C';
                l_txmsg.txfields ('97').VALUE     := rec.CAREBY;

                l_txmsg.txfields ('93').defname   := 'BANKACCT';
                l_txmsg.txfields ('93').TYPE      := 'C';
                l_txmsg.txfields ('93').VALUE     := rec.BANKACCTNO;

                l_txmsg.txfields ('95').defname   := 'BANKNAME';
                l_txmsg.txfields ('95').TYPE      := 'C';
                l_txmsg.txfields ('95').VALUE     := rec.BANKNAME;

                l_txmsg.txfields ('11').defname   := 'BANKAVAIL';
                l_txmsg.txfields ('11').TYPE      := 'N';
                l_txmsg.txfields ('11').VALUE     := rec.BANKAVAIL;

                l_txmsg.txfields ('12').defname   := 'BANKHOLDED';
                l_txmsg.txfields ('12').TYPE      := 'N';
                l_txmsg.txfields ('12').VALUE     := rec.BANKHOLDED;

                l_txmsg.txfields ('13').defname   := 'AVLRELEASE';
                l_txmsg.txfields ('13').TYPE      := 'N';
                l_txmsg.txfields ('13').VALUE     := rec.AVLRELEASE;

                l_txmsg.txfields ('96').defname   := 'HOLDAMT';
                l_txmsg.txfields ('96').TYPE      := 'N';
                l_txmsg.txfields ('96').VALUE     := rec.HOLDAMT;

                l_txmsg.txfields ('10').defname   := 'AMOUNT';
                l_txmsg.txfields ('10').TYPE      := 'N';
                l_txmsg.txfields ('10').VALUE     := v_dblUnholdBalance;

                l_txmsg.txfields ('30').defname   := 'DESC';
                l_txmsg.txfields ('30').TYPE      := 'C';
                l_txmsg.txfields ('30').VALUE     := v_strDesc;
            END LOOP;

            BEGIN
                IF txpks_#6600.fn_batchtxprocess (l_txmsg,
                                                 pv_strErrorCode,
                                                 l_err_param
                   ) <> systemnums.c_success
                THEN
                   ROLLBACK;
                   RETURN;
                END IF;
            END;

            --Tao yeu cau UNHOLD gui sang Bank. REFCODE=ORDERID
            INSERT INTO CRBTXREQ (REQID, OBJTYPE, OBJNAME, TRFCODE, REFCODE, OBJKEY, TXDATE,
                BANKCODE, BANKACCT, AFACCTNO, TXAMT, STATUS, REFTXNUM, REFTXDATE, REFVAL, NOTES)
            SELECT SEQ_CRBTXREQ.NEXTVAL, 'V', 'ODMAST', 'UNHOLD', pv_strORDERID, pv_strORDERID, v_strCURRDATE,
                v_strBANKCODE, l_txmsg.txfields ('93').VALUE,
                 v_strAFAcctNo, v_dblUnholdBalance, 'P', null, null, null, v_strNotes
            FROM DUAL;
        END IF;
    END IF;
    pv_strErrorCode:=0;
EXCEPTION
    WHEN others THEN
        pv_strErrorCode:='-1'; --System error
        return;
END; -- Procedure

 
 
 
 
/
