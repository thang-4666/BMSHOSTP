SET DEFINE OFF;
CREATE OR REPLACE PROCEDURE pr_odsettlementreceivemoneyt0(p_bchmdl varchar,p_err_code  OUT varchar2,p_FromRow number,p_ToRow number, p_lastRun OUT varchar2)
  IS
      l_txmsg               tx.msg_rectype;
      v_strCURRDATE varchar2(20);
      v_strPREVDATE varchar2(20);
      v_strNEXTDATE varchar2(20);
      v_strDesc varchar2(1000);
      v_strEN_Desc varchar2(1000);
      v_blnVietnamese BOOLEAN;
      v_dblProfit number(20,0);
      v_dblLoss number(20,0);
      v_dblAVLRCVAMT  number(20,0);
      v_dblVATRATE number(20,0);
      l_err_param varchar2(300);
      l_MaxRow number(20,0);
      v_COMPANYCD VARCHAR2(10);
  BEGIN
    --plog.setbeginsection(pkgctx, 'pr_ODSettlementReceiveMoney');

    v_COMPANYCD:=cspks_system.fn_get_sysvar ('SYSTEM', 'COMPANYCD');

    SELECT COUNT(*) MAXROW into l_MaxRow FROM  STSCHD;
    IF l_MaxRow>p_ToRow THEN
        p_lastRun:='N';
    ELSE
        p_lastRun:='Y';
    END IF;
    SELECT TXDESC,EN_TXDESC into v_strDesc, v_strEN_Desc FROM  TLTX WHERE TLTXCD='8866';
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
    l_txmsg.batchname   := p_bchmdl;
    l_txmsg.txdate:=to_date(v_strCURRDATE,systemnums.c_date_format);
    l_txmsg.busdate:=to_date(v_strCURRDATE,systemnums.c_date_format);
    l_txmsg.tltxcd:='8866';
    v_dblProfit:=0;
    v_dblLoss:=0;
    for rec in
    (
        SELECT SUBSTR(MAX(CUSTODYCD),4,1) CUSTODYCD,MAX(COSTPRICE) COSTPRICE ,CLR2.SBDATE, TO_DATE( v_strCURRDATE,systemnums.c_date_format) CURRDATE,
            SUM(CASE WHEN CLR1.HOLIDAY='Y' THEN 0 ELSE 1 END) WITHHOLIDAY,
            SUM(CASE WHEN CLR1.HOLIDAY='Y' THEN 1 ELSE 1 END) WITHOUTHOLIDAY,
            CASE WHEN CI.COREBANK='Y' THEN 1 ELSE 0 END COREBANK,
            MST.AUTOID, MST.AFACCTNO,MAX(ODMST.ORDERQTTY) ORGORDERQTTY,MAX(ODMST.EXECTYPE) EXECTYPE,MAX(ODMST.QUOTEPRICE) ORGQUOTEPRICE, MST.ACCTNO, MIN(MST.DUETYPE) DUETYPE, MIN(MST.TXDATE) TXDATE, MIN(MST.ORGORDERID) ORGORDERID, MIN(MST.CLEARCD) CLEARCD, MIN(MST.CLEARDAY) CLEARDAY,
            MIN(SEC.CODEID) CODEID, MIN(SEC.SYMBOL) SYMBOL, MIN(SEC.PARVALUE) PARVALUE, MIN(TYP.VATRATE) VATRATE, MIN(ODMST.FEEACR-ODMST.FEEAMT) AVLFEEAMT,
            MIN(MST.AMT) AMT, MIN(MST.AAMT) AAMT, MIN(MST.FAMT) FAMT, MIN(MST.QTTY) QTTY,MIN(ODMST.EXECQTTY) SQTTY , MIN(MST.AQTTY) AQTTY, ROUND(MIN(MST.AMT/MST.QTTY),4) MATCHPRICE,MIN(ODMST.ACTYPE) ACTYPE
            FROM SBCLDR CLR1, SBCLDR CLR2, 
            stschd MST, ODMAST ODMST,AFMAST AF,CFMAST CF,CIMAST CI, ODTYPE TYP, SBSECURITIES SEC
            WHERE ODMST.AFACCTNO=AF.ACCTNO AND AF.CUSTID=CF.CUSTID AND  CLR1.SBDATE>=MST.TXDATE AND CLR1.SBDATE<CLR2.SBDATE AND CLR2.SBDATE>=MST.TXDATE
            AND CLR1.CLDRTYPE=SEC.TRADEPLACE AND CLR2.CLDRTYPE=SEC.TRADEPLACE AND ODMST.AFACCTNO=CI.AFACCTNO
            AND ODMST.ACTYPE=TYP.ACTYPE AND MST.ORGORDERID=ODMST.ORDERID AND MST.CODEID=SEC.CODEID AND SEC.TRADEPLACE <> '003'
            AND CLR2.SBDATE=TO_DATE( v_strCURRDATE,systemnums.c_date_format) +1 AND MST.STATUS='N' AND MST.DELTD<>'Y'
            AND (MST.DUETYPE='RM' )
            AND CF.CUSTATCOM ='Y'
            and mst.clearday =0
            GROUP BY MST.AUTOID, CLR2.SBDATE, MST.AFACCTNO, MST.ACCTNO,CI.COREBANK
            HAVING MIN(MST.CLEARDAY)<=
            (CASE WHEN MIN(MST.CLEARCD)='B' THEN SUM(CASE WHEN CLR1.HOLIDAY='Y' THEN 0 ELSE 1 END) ELSE SUM(CASE WHEN CLR1.HOLIDAY='Y' THEN 1 ELSE 1 END) END)
            ORDER BY ORGORDERID
    )
    loop
        --Set txnum
        SELECT systemnums.C_BATCH_PREFIXED
                         || LPAD (seq_BATCHTXNUM.NEXTVAL, 8, '0')
                  INTO l_txmsg.txnum
                  FROM DUAL;
        l_txmsg.brid        := substr(rec.AFACCTNO,1,4);
        --Xac dinh xem nha day tu trong nuoc hay nuoc ngoai
        IF rec.custodycd='F' then
            v_blnVietnamese:= false;
        else
            v_blnVietnamese:= true;
        end if;
        v_dblAVLRCVAMT := rec.AMT;
        v_dblVATRATE := rec.VATRATE;
        --Tinh gia tri lai lo cho tu doanh
        If rec.CUSTODYCD= 'P' Then
            If rec.AMT > rec.COSTPRICE * rec.QTTY Then
                v_dblProfit := round(rec.AMT - rec.COSTPRICE * rec.QTTY,0);
                v_dblLoss := 0;
            Else
                v_dblProfit := 0;
                v_dblLoss := round(rec.COSTPRICE * rec.QTTY - rec.AMT,0);
            End If;
        end if;
        --Set cac field giao dich
        --01   N   AUTOID
        l_txmsg.txfields ('01').defname   := 'AUTOID';
        l_txmsg.txfields ('01').TYPE      := 'N';
        l_txmsg.txfields ('01').VALUE     := rec.AUTOID;

        --03   C   ORGORDERID
        l_txmsg.txfields ('03').defname   := 'ORGORDERID';
        l_txmsg.txfields ('03').TYPE      := 'C';
        l_txmsg.txfields ('03').VALUE     := rec.ORGORDERID;
        --04   C   AFACCTNO
        l_txmsg.txfields ('04').defname   := 'AFACCTNO';
        l_txmsg.txfields ('04').TYPE      := 'C';
        l_txmsg.txfields ('04').VALUE     := rec.AFACCTNO;
        --05   C   CIACCTNO
        l_txmsg.txfields ('05').defname   := 'CIACCTNO';
        l_txmsg.txfields ('05').TYPE      := 'C';
        l_txmsg.txfields ('05').VALUE     := rec.ACCTNO;
        --06   C   SEACCTNO
        l_txmsg.txfields ('06').defname   := 'SEACCTNO';
        l_txmsg.txfields ('06').TYPE      := 'C';
        l_txmsg.txfields ('06').VALUE     := rec.AFACCTNO || rec.CODEID;
        --07   C   SYMBOL
        l_txmsg.txfields ('07').defname   := 'SYMBOL';
        l_txmsg.txfields ('07').TYPE      := 'C';
        l_txmsg.txfields ('07').VALUE     := rec.SYMBOL;
        --08   N   AMT
        l_txmsg.txfields ('08').defname   := 'AMT';
        l_txmsg.txfields ('08').TYPE      := 'N';
        l_txmsg.txfields ('08').VALUE     := round(rec.AMT,0);
        --09   N   QTTY
        l_txmsg.txfields ('09').defname   := 'QTTY';
        l_txmsg.txfields ('09').TYPE      := 'N';
        l_txmsg.txfields ('09').VALUE     := rec.QTTY;
        --10   N   RAMT
        l_txmsg.txfields ('10').defname   := 'RAMT';
        l_txmsg.txfields ('10').TYPE      := 'N';
        l_txmsg.txfields ('10').VALUE     := round(rec.AMT,0);
        --11   N   AAMT
        l_txmsg.txfields ('11').defname   := 'AAMT';
        l_txmsg.txfields ('11').TYPE      := 'N';
        l_txmsg.txfields ('11').VALUE     := round(rec.AAMT,0);
        --12   N   FEEAMT
        l_txmsg.txfields ('12').defname   := 'FEEAMT';
        l_txmsg.txfields ('12').TYPE      := 'N';
        l_txmsg.txfields ('12').VALUE     := 0;
        --13   N   VAT
        l_txmsg.txfields ('13').defname   := 'VAT';
        l_txmsg.txfields ('13').TYPE      := 'N';
        l_txmsg.txfields ('13').VALUE     := 0;
        --14   N   PROFITAMT
        l_txmsg.txfields ('14').defname   := 'PROFITAMT';
        l_txmsg.txfields ('14').TYPE      := 'N';
        l_txmsg.txfields ('14').VALUE     := v_dblProfit;
        --15   N   LOSSAMT
        l_txmsg.txfields ('15').defname   := 'LOSSAMT';
        l_txmsg.txfields ('15').TYPE      := 'N';
        l_txmsg.txfields ('15').VALUE     := v_dblLoss;
        --16   N   COSTPRICE
        l_txmsg.txfields ('16').defname   := 'COSTPRICE';
        l_txmsg.txfields ('16').TYPE      := 'N';
        l_txmsg.txfields ('16').VALUE     := rec.COSTPRICE;
        --31   N   COREBANK
        l_txmsg.txfields ('31').defname   := 'COREBANK';
        l_txmsg.txfields ('31').TYPE      := 'N';
        l_txmsg.txfields ('31').VALUE     := rec.COREBANK;
        --30   C   DESC
        l_txmsg.txfields ('30').defname   := 'DESC';
        l_txmsg.txfields ('30').TYPE      := 'C';
        l_txmsg.txfields ('30').VALUE := utf8nums.c_const_TLTX_TXDESC_8866 ||' ' || trim(to_char(rec.SQTTY,'999,999,999,999,999')) || ' ' || rec.SYMBOL || ' ' || UTF8NUMS.C_CONST_DATE_VI || ' ' || to_char(rec.TXDATE);
        /*If v_blnVietnamese = True Then
            l_txmsg.txfields ('30').VALUE := v_strDesc || ' ' || rec.SQTTY || ' ' || rec.SYMBOL || ' ' || substr(rec.ORGORDERID, 5, 2) || '/' || substr(rec.ORGORDERID, 7, 2) || '/' || substr(rec.ORGORDERID, 9, 2);
        Else
            l_txmsg.txfields ('30').VALUE := v_strEN_Desc || ' ' || rec.SQTTY || ' ' || rec.SYMBOL || ' ' || substr(rec.ORGORDERID, 5, 2) || '/' || substr(rec.ORGORDERID, 7, 2) || '/' || substr(rec.ORGORDERID, 9, 2);
        End If;*/
        --44   N   PARVALUE
        l_txmsg.txfields ('44').defname   := 'PARVALUE';
        l_txmsg.txfields ('44').TYPE      := 'N';
        l_txmsg.txfields ('44').VALUE     := rec.PARVALUE;

        --53   N   MICD
        l_txmsg.txfields ('53').defname   := 'MICD';
        l_txmsg.txfields ('53').TYPE      := 'C';
        l_txmsg.txfields ('53').VALUE     := '';

        --60   N   ISMORTAGE
        l_txmsg.txfields ('60').defname   := 'ISMORTAGE';
        l_txmsg.txfields ('60').TYPE      := 'N';
        l_txmsg.txfields ('60').VALUE     := (case when rec.EXECTYPE='MS' then 1 else 0 end);
        BEGIN
            IF txpks_#8866.fn_batchtxprocess (l_txmsg,
                                             p_err_code,
                                             l_err_param
               ) <> systemnums.c_success
            THEN

               ROLLBACK;
               RETURN;
            --ELSE
                --txpks_sepitlog.pr_DeductionPIT(rec.ORGORDERID,rec.ACCTNO, rec.AFACCTNO || rec.CODEID, rec.CODEID, rec.QTTY, P_ERR_CODE=>p_err_code);
                --HaiLT bo tinh thue TNCN de tinh o cho khac
                --txpks_sepitlog.pr_SellStockCALog(P_ORDERID=>rec.ORGORDERID, P_ACCTNO=>rec.ACCTNO,
                --P_AFACCTNO=>rec.AFACCTNO, P_SEACCTNO=>rec.AFACCTNO || rec.CODEID, P_CODEID=>rec.CODEID, P_QTTY=>rec.QTTY,
                --P_ACTYPE=>rec.ACTYPE, P_TXDATE=>rec.TXDATE, P_ERR_CODE=>p_err_code);
                --End of HaiLT bo tinh thue TNCN de tinh o cho khac
            END IF;
        END;
    end loop;
    p_err_code:=0;
    --plog.setendsection(pkgctx, 'pr_ODSettlementReceiveMoney');
  EXCEPTION
  WHEN OTHERS
   THEN
      --plog.debug (pkgctx,'got error on receive money');
      ROLLBACK;
      p_err_code := errnums.C_SYSTEM_ERROR;
      --plog.error (pkgctx, SQLERRM);
      --plog.setendsection (pkgctx, 'pr_ODSettlementReceiveMoney');
      RAISE errnums.E_SYSTEM_ERROR;
  END pr_ODSettlementReceiveMoneyT0;
 
 
 
 
 
 
 
 
 
 
 
 
 
/
