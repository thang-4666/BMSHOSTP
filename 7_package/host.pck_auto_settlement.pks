SET DEFINE OFF;
CREATE OR REPLACE PACKAGE pck_auto_settlement is

  -- Purpose : Auto Settlement Middle Of Day

  PROCEDURE pr_create_job_process (p_trade_date   VARCHAR2,
                                   p_action       VARCHAR2, --A: AUTO, M:Manual
                                   p_cleartype    varchar2, --Loai TTBT 1: Co phieu, 2: Trai phieu
                                   p_err_code      OUT VARCHAR2);
  PROCEDURE pr_process_settlement(p_mod    NUMBER, p_cleartype varchar2);
  PROCEDURE pr_process_settlement_buy(pv_acctno   IN     VARCHAR2,
                                      pv_autoid   IN     VARCHAR2,
                                      pv_routerid IN     VARCHAR2,
                                      pv_isauto   IN     VARCHAR2 DEFAULT 'Y',
                                      pv_cleartype IN varchar2, --TTBT T+1.5 TP: them p_cleartype
                                      pv_err_code OUT    VARCHAR2);
   PROCEDURE pr_process_settlement_sell(pv_acctno   IN     VARCHAR2,
                                        pv_autoid   IN     VARCHAR2,
                                        pv_routerid IN     VARCHAR2,
                                        pv_isauto   IN     VARCHAR2 DEFAULT 'Y',
                                        pv_cleartype IN varchar2, --TTBT T+1.5 TP: them p_cleartype
                                        pv_err_code OUT    VARCHAR2);
   PROCEDURE pr_create_send_smsemail(pv_actinon    VARCHAR2, -- B - Star, K - Ket thuc , E - error
                                     p_mod         NUMBER DEFAULT 0,
                                  p_error       VARCHAR2 DEFAULT '',
                                  p_cleartype    varchar2 default '1' --Loai TTBT 1: Co phieu, 2: Trai phieu --TTBT T+1.5 TP
                                  );
   PROCEDURE pr_get_listClearingT15 (p_refcursor in out pkg_report.ref_cursor,
                                     p_custodycd VARCHAR2,
                                     p_afacctno  VARCHAR2,
                                     p_status    VARCHAR2,
                                     p_cleartype    varchar2 default '1' --Loai TTBT 1: Co phieu, 2: Trai phieu --TTBT T+1.5 TP
                                     );
   PROCEDURE pr_get_MonitorDetail (p_refcursor in out pkg_report.ref_cursor,
                                  p_currdate VARCHAR2,
                                  p_cleartype    varchar2 default '1' --TTBT T+1.5 TP: Loai TTBT 1: Co phieu, 2: Trai phieu --TTBT T+1.5 TP
                                  );
   PROCEDURE pr_get_EMS_ClearingT15 (p_refcursor in out pkg_report.ref_cursor,
                                    p_currdate VARCHAR2,
                                    p_cleartype    varchar2 default '1' --Loai TTBT 1: Co phieu, 2: Trai phieu --TTBT T+1.5 TP
                                    );
   PROCEDURE PR_RMSPAIDADV(P_BCHMDL VARCHAR,p_afacctno varchar2, p_cleartype varchar2, P_ERR_CODE OUT VARCHAR2); --TTBT T+1.5 TP them p_cleartype

    PROCEDURE pr_lockaccount(pv_acctno     VARCHAR2, --TTBT T+1.5 TP
                         pv_actinon    VARCHAR2,
                         pv_duetype    VARCHAR2,
                         pv_cleartype   VARCHAR2,
                         p_err_code    OUT VARCHAR2);

end pck_auto_settlement;
/


CREATE OR REPLACE PACKAGE BODY pck_auto_settlement is
  pkgctx plog.log_ctx;
  logrow tlogdebug%ROWTYPE;

PROCEDURE pr_createJob (p_job_name   VARCHAR2,
                        p_job_action VARCHAR2,
                        p_err_code   OUT VARCHAR2)
IS
BEGIN
  plog.setBeginSection(pkgctx, 'pr_createJob');
  p_err_code := systemnums.C_SUCCESS;
  DBMS_SCHEDULER.CREATE_JOB (
      job_name           => p_job_name,
      job_type           => 'PLSQL_BLOCK',
      job_action         => p_job_action,
      start_date         => systimestamp,
      auto_drop          => TRUE,
      enabled            => TRUE,
      comments           => p_job_name);
  COMMIT;
  plog.setEndSection(pkgctx, 'pr_createJob');
EXCEPTION
  WHEN OTHERS THEN
    p_err_code := errnums.C_SYSTEM_ERROR;
    plog.error(pkgctx, SQLERRM || dbms_utility.format_error_backtrace);
    plog.setEndSection(pkgctx, 'pr_createJob');
END;

PROCEDURE pr_create_job_process (p_trade_date   VARCHAR2,
                                 p_action       VARCHAR2, --A: AUTO, M:Manual
                                 p_cleartype    varchar2, --Loai TTBT 1: Co phieu, 2: Trai phieu --TTBT T+1.5 TP
                                 p_err_code      OUT VARCHAR2)
IS
l_currdate       DATE;
l_page_size      NUMBER := 3;
l_job_name       VARCHAR2(100);
l_job_action     VARCHAR2(1000);
l_beginTime      NUMBER;
l_endTime        NUMBER;
l_currTime       NUMBER;
l_clearauto      VARCHAR2(1);
v_router_total   NUMBER;
v_isrun          NUMBER;
v_error          varchar2(2000);
BEGIN
  plog.setBeginSection(pkgctx, 'pr_create_job_process');
  p_err_code  := systemnums.C_SUCCESS;
  l_currdate  := TO_DATE(cspks_system.fn_get_sysvar('SYSTEM','CURRDATE'), systemnums.C_DATE_FORMAT);
  l_page_size := cspks_system.fn_get_sysvar('SYSTEM','JOBAUTOSETTLEMENT');
  --TTBT T+1.5 TP
  if p_cleartype not in ('1','2') then
    v_error := 'Loai TTBT khong dung';
    pr_create_send_smsemail('E',0,v_error,'-1');
    p_err_code := '-700213';
    return;
  end if;
  if p_cleartype = '2' then --Neu TP
      l_clearauto := upper(cspks_system.fn_get_sysvar('SYSTEM','BONDCLEARINGAUTO'));
      l_beginTime := REPLACE(cspks_system.fn_get_sysvar('SYSTEM','BONDCLEARINGSTARTTIME'),':','');
      l_endTime   := REPLACE(cspks_system.fn_get_sysvar('SYSTEM','BONDCLEARINGENDTIME'),':','');
  else --Neu CP, CCQ, CW
      l_clearauto := upper(cspks_system.fn_get_sysvar('SYSTEM','CLEARINGAUTO'));
      l_beginTime := REPLACE(cspks_system.fn_get_sysvar('SYSTEM','CLEARINGSTARTTIME'),':','');
      l_endTime   := REPLACE(cspks_system.fn_get_sysvar('SYSTEM','CLEARINGENDTIME'),':','');
  end if;
  --End TTBT T+1.5 TP
  l_currTime  := TO_CHAR(SYSDATE,'hh24miss');

  SELECT count(*) INTO v_isrun FROM odcfclearing_check WHERE status='P' and cleartype = p_cleartype; --TTBT T+1.5 TP: Them dieu kien p_cleartype

  IF l_clearauto = p_action AND TO_DATE(p_trade_date, systemnums.C_DATE_FORMAT) = l_currdate AND v_isrun = 0
     AND ((l_clearauto = 'A' AND l_currTime >= l_beginTime AND l_currTime <= l_endTime) or l_clearauto = 'M') THEN

     INSERT INTO odcfclearing_check_HIST SELECT * FROM odcfclearing_check where cleartype = p_cleartype; --TTBT T+1.5 TP: Them dieu kien p_cleartype
     DELETE FROM odcfclearing_check where cleartype = p_cleartype; --TTBT T+1.5 TP: Them dieu kien p_cleartype
     COMMIT;

     INSERT INTO odcfclearing_tmp(autoid,custid,afacctno,clearday,router_id,isbuy,issell,cleartype) --TTBT T+1.5 TP: cleartype
          SELECT seq_odcfclearing_tmp.nextval, sts.custid, sts.afacctno, sts.cleardate, MOD(rownum, l_page_size), sts.isbuy, sts.issell, p_cleartype cleartype
            FROM (SELECT af.custid, sts.afacctno, cleardate,
                         MAX(CASE WHEN sts.duetype ='RS' THEN 'Y' ELSE 'N' END) isbuy,
                         MAX(CASE WHEN sts.duetype ='RM' THEN 'Y' ELSE 'N' END) issell
                   FROM stschd sts, afmast af, sbsecurities sb, cfmast cf
                  WHERE sts.afacctno = af.acctno
                    AND sts.codeid = sb.codeid
                    and af.custid = cf.custid
                    AND ((sb.sectype NOT IN ('003','006','012') and p_cleartype = '1') or (sb.sectype IN ('003','006','012') and p_cleartype = '2')) --TTBT T+1.5 TP: cleartype = 1 la CP, = 2 la TP
                    AND sts.cleardate = l_currdate
                    AND sts.status = 'N'
                    AND sts.deltd <> 'Y'
                    AND sts.duetype IN ('RS','RM')
                    AND cf.custatcom = 'Y'
               GROUP BY af.custid, sts.afacctno, cleardate) sts
             WHERE NOT EXISTS (SELECT 1 FROM odcfclearing_tmp WHERE afacctno = sts.afacctno AND clearday = sts.cleardate AND status <> 'E' and cleartype = p_cleartype); --TTBT T+1.5 TP: them dk p_cleartype

    SELECT count(DISTINCT ROUTER_ID) INTO v_router_total FROM odcfclearing_tmp WHERE clearday = l_currdate  AND status ='P';

    IF v_router_total > 0 AND l_page_size > 0  THEN
      -- send sms/email thanh toan bu tru - bat dau
      pr_create_send_smsemail('B',l_page_size,'',p_cleartype); --TTBT T+1.5 TP: p_cleartype
      -- tao job xu ly thanh toan bu tru
      FOR i IN 0..l_page_size-1
      LOOP
        INSERT INTO odcfclearing_check(autoid,clearday,router_total,router_id,cleartype)
           VALUES ( seq_odcfclearing_check.nextval,l_currdate,v_router_total,i,p_cleartype); --TTBT T+1.5 TP: p_cleartype
        if p_cleartype = '2' then --TTBT T+1.5 TP
            l_job_name   := 'AUTO_SETTLEMENT_BOND_' || i;
        else
            l_job_name   := 'AUTO_SETTLEMENT_' || i;
        end if;
        l_job_action := 'BEGIN pck_auto_settlement.pr_process_settlement(' || i || ','''||p_cleartype||'''); END;';
        pr_createJob(l_job_name, l_job_action,p_err_code);
        plog.error(pkgctx, 'End Create Job: job_name=' || l_job_name || ',job_action=' || l_job_action);
      END LOOP;
    --TTBT T+1.5 TP them gui SMS TH khong co tai khoan nao can TTBT
    elsif v_router_total <= 0 then
        v_error := v_error ||' - '|| 'Khong co tai khoan can TTBT';
        pr_create_send_smsemail('E',0,v_error,p_cleartype);
    --End TTBT T+1.5 TP them p_cleartype
    END IF;

  ELSE
    IF TO_DATE(p_trade_date, systemnums.C_DATE_FORMAT) <> l_currdate THEN
       v_error := v_error ||' - '|| 'Sai ngay TTBT';
    END IF;

    IF l_clearauto = 'A' AND (l_currTime < l_beginTime OR l_currTime > l_endTime) THEN
       v_error := v_error ||' - '|| 'Ngoai thoi gian TTBT tu dong';
    END IF;

    IF v_isrun <> 0 THEN
       v_error := v_error ||' - '|| 'Con tien trinh dang xu ly';
    END IF;

    -- send sms/email thanh toan bu tru - stop do loi
    pr_create_send_smsemail('E',0,v_error,p_cleartype); --TTBT T+1.5 TP them p_cleartype
    p_err_code := '1';
    plog.error(pkgctx, 'Sai ngay giao dich ' || p_trade_date);
  END IF;
  plog.setEndSection(pkgctx, 'pr_create_job_process');
EXCEPTION
  WHEN OTHERS THEN
    p_err_code := errnums.C_SYSTEM_ERROR;
    ROLLBACK;
    plog.error(pkgctx, SQLERRM || dbms_utility.format_error_backtrace);
    plog.setEndSection(pkgctx, 'pr_create_job_process');
END;

PROCEDURE pr_process_settlement(p_mod    NUMBER, p_cleartype varchar2) --TTBT T+1.5 TP: them p_cleartype
IS
l_RCVSECTIME      sysvar.varvalue%TYPE;
l_RCVCASHTIME     sysvar.varvalue%TYPE;
l_err_code        VARCHAR2(10);
BEGIN
  plog.setBeginSection(pkgctx, 'pr_process_settlement');
  plog.error(pkgctx, 'Begin pr_process_settlement mod=' || p_mod||', cleartype='||p_cleartype);
  -- Chuan bi than so
  l_RCVSECTIME  := cspks_system.fn_get_sysvar('SYSTEM','RCVSECTIME');
  l_RCVCASHTIME := cspks_system.fn_get_sysvar('SYSTEM','RCVCASHTIME');

  -- Bat Dau Xu Ly
  FOR rec IN (SELECT * FROM odcfclearing_tmp WHERE router_id = p_mod AND status ='P' and cleartype = p_cleartype) --TTBT T+1.5 TP: them p_cleartype
  LOOP
    -- xu ly ck mua
    IF l_RCVSECTIME = 'CN' AND rec.isbuy = 'Y' THEN
      pr_process_settlement_buy(rec.afacctno,rec.autoid,rec.router_id,'Y',p_cleartype,l_err_code); --TTBT T+1.5 TP: them p_cleartype
    END IF;
    -- xu ly tien ban
    IF l_RCVCASHTIME = 'CN' AND rec.issell = 'Y' THEN
      pr_process_settlement_sell(rec.afacctno,rec.autoid,rec.router_id,'Y',p_cleartype,l_err_code); --TTBT T+1.5 TP: them p_cleartype
    END IF;

    UPDATE odcfclearing_tmp  SET status ='C', process_time = systimestamp WHERE autoid = rec.autoid;
    COMMIT;
  END LOOP;

  -- send sms/email thanh toan bu tru - ket thuc
  pr_create_send_smsemail('K',p_mod+1,'',p_cleartype);

  UPDATE odcfclearing_check SET status ='C' WHERE router_id = p_mod AND status ='P' and cleartype = p_cleartype; --TTBT T+1.5 TP: them p_cleartype
  COMMIT;

  plog.error(pkgctx, 'End pr_process_settlement mod=' || p_mod||', cleartype='||p_cleartype);
  plog.setEndSection(pkgctx, 'pr_process_settlement');
EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    --TTBT T+1.5 TP: them p_cleartype
    pr_create_send_smsemail('E',0,'Exception',p_cleartype);
    UPDATE odcfclearing_check SET status ='E' WHERE router_id = p_mod AND status ='P' and cleartype = p_cleartype;
    UPDATE odcfclearing_tmp SET status ='E' WHERE router_id = p_mod AND status ='P' and cleartype = p_cleartype;
    --End TTBT T+1.5 TP: them p_cleartype
    plog.error(pkgctx, 'End pr_process_settlement mod=' || p_mod || ' With Error ');
    plog.error(pkgctx, SQLERRM || dbms_utility.format_error_backtrace);
    plog.setEndSection(pkgctx, 'pr_process_settlement');
END;

-- xu ly mua
PROCEDURE pr_process_settlement_buy(pv_acctno   IN     VARCHAR2,
                                    pv_autoid   IN     VARCHAR2,
                                    pv_routerid IN     VARCHAR2,
                                    pv_isauto   IN     VARCHAR2 DEFAULT 'Y',
                                    pv_cleartype IN varchar2, --TTBT T+1.5 TP: them p_cleartype
                                    pv_err_code OUT    VARCHAR2)
IS
l_txmsg           tx.msg_rectype;
l_currdate        DATE;
l_desc_8868       VARCHAR2(1000);
l_en_desc_8868    VARCHAR2(1000);
l_desc_2661       VARCHAR2(1000);
v_blnVietnamese   BOOLEAN;
v_errcheck        BOOLEAN;
l_err_param       VARCHAR2(300);
l_err_code        VARCHAR2(300);

BEGIN
  plog.setBeginSection(pkgctx, 'pr_process_settlement_buy');
  plog.error(pkgctx, 'Begin pr_process_settlement_buy autoid=' ||pv_autoid ||' mod=' || pv_routerid);
  -- Chuan bi than so
  l_currdate    := to_date(cspks_system.fn_get_sysvar('SYSTEM','CURRDATE'),'DD/MM/RRRR');
  v_errcheck := FALSE;
  pv_err_code := 0;

  SELECT MAX(CASE WHEN TLTXCD ='8868' THEN TXDESC ELSE '' END),
         MAX(CASE WHEN TLTXCD ='8868' THEN EN_TXDESC ELSE '' END),
         MAX(CASE WHEN TLTXCD ='2661' THEN TXDESC ELSE '' END)
   INTO  l_desc_8868, l_en_desc_8868,l_desc_2661
   FROM TLTX WHERE TLTXCD IN ('2661','8868');
   -- Bat Dau Xu Ly
   l_txmsg.msgtype     := 'T';
   l_txmsg.local       := 'N';
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
   l_txmsg.batchname   := 'AUTO_SETTLEMENT';
   l_txmsg.txdate      := l_currdate;
   l_txmsg.busdate     := l_currdate;
   -- Nhan chung khoan cuoi ngay
   SAVEPOINT begin_sec_settlement;
      BEGIN
          --TTBT T+1.5 TP: them xu ly deadlock
          pr_lockaccount(pv_acctno,'Y','RS',pv_cleartype,pv_err_code);
          IF pv_err_code <> 0 THEN
             pr_lockaccount(pv_acctno,'N','RS',pv_cleartype,l_err_code);
          ELSE
          --End TTBT T+1.5 TP: them xu ly deadlock
              --Nhan chung khoan mua
              FOR rec_se IN (
                SELECT MST.AUTOID,CLR2.SBDATE,MST.AFACCTNO,MST.ACCTNO,MAX(CF.BRID) BRID, MAX(CF.CUSTODYCD) CUSTODYCD,
                       MIN(MST.ORGORDERID) ORGORDERID,MIN(SEC.SYMBOL) SYMBOL,
                       MIN(MST.AMT) AMT, MIN(MST.QTTY) QTTY,ROUND(MIN(MST.AMT/MST.QTTY),4) MATCHPRICE,
                       MIN(SEC.PARVALUE) PARVALUE,MIN(ODMST.FEEACR) FEEACR, MIN(ODMST.EXECQTTY) SQTTY
                  FROM SBCLDR CLR1, SBCLDR CLR2, STSCHD MST, ODMAST ODMST,AFMAST AF,CFMAST CF, SBSECURITIES SEC
                 WHERE ODMST.AFACCTNO = AF.ACCTNO
                   AND AF.CUSTID = CF.CUSTID
                   AND CLR1.SBDATE >= MST.TXDATE
                   AND CLR1.SBDATE < CLR2.SBDATE
                   AND CLR2.SBDATE >= MST.TXDATE
                   AND CLR1.CLDRTYPE = SEC.TRADEPLACE
                   AND CLR2.CLDRTYPE = SEC.TRADEPLACE
                   AND MST.ORGORDERID = ODMST.ORDERID
                   AND MST.CODEID = SEC.CODEID
                   AND SEC.TRADEPLACE <> '003'
                   AND MST.STATUS = 'N'
                   AND MST.DELTD <> 'Y'
                   AND MST.DUETYPE = 'RS'
                   AND CF.CUSTATCOM ='Y'
                   AND CLR2.SBDATE = l_currdate
                   AND AF.ACCTNO = pv_acctno
                   AND ((SEC.SECTYPE NOT IN ('003','006','012') and pv_cleartype = '1') or (SEC.SECTYPE IN ('003','006','012') and pv_cleartype = '2')) --TTBT T+1.5 TP: cleartype = 1 la CP, = 2 la TP
                 GROUP BY MST.AUTOID, CLR2.SBDATE, MST.AFACCTNO, MST.ACCTNO
                HAVING MIN(MST.CLEARDAY)<= (CASE WHEN MIN(MST.CLEARCD)='B' THEN SUM(CASE WHEN CLR1.HOLIDAY='Y' THEN 0 ELSE 1 END) ELSE SUM(CASE WHEN CLR1.HOLIDAY='Y' THEN 1 ELSE 1 END) END)
                ORDER BY ORGORDERID
                ) LOOP
                    IF v_errcheck = FALSE THEN
                      --Set txnum
                      SELECT systemnums.C_BATCH_PREFIXED
                                       || LPAD (seq_BATCHTXNUM.NEXTVAL, 8, '0')
                        INTO l_txmsg.txnum
                        FROM DUAL;
                      l_txmsg.brid        := rec_se.BRID;
                      IF SUBSTR(rec_se.CUSTODYCD,4,1)='F' THEN
                         v_blnVietnamese:= FALSE;
                      ELSE
                         v_blnVietnamese:= TRUE;
                      end if;
                      l_txmsg.tltxcd      := '8868';
                      --Set cac field giao dich
                      --01   N   AUTOID
                      l_txmsg.txfields ('01').defname   := 'AUTOID';
                      l_txmsg.txfields ('01').TYPE      := 'N';
                      l_txmsg.txfields ('01').VALUE     := rec_se.AUTOID;

                      --03   C   ORGORDERID
                      l_txmsg.txfields ('03').defname   := 'ORGORDERID';
                      l_txmsg.txfields ('03').TYPE      := 'C';
                      l_txmsg.txfields ('03').VALUE     := rec_se.ORGORDERID;
                      --04   C   AFACCTNO
                      l_txmsg.txfields ('04').defname   := 'AFACCTNO';
                      l_txmsg.txfields ('04').TYPE      := 'C';
                      l_txmsg.txfields ('04').VALUE     := rec_se.AFACCTNO;
                      --05   C   CIACCTNO
                      l_txmsg.txfields ('05').defname   := 'CIACCTNO';
                      l_txmsg.txfields ('05').TYPE      := 'C';
                      l_txmsg.txfields ('05').VALUE     := rec_se.AFACCTNO;
                      --06   C   SEACCTNO
                      l_txmsg.txfields ('06').defname   := 'SEACCTNO';
                      l_txmsg.txfields ('06').TYPE      := 'C';
                      l_txmsg.txfields ('06').VALUE     := rec_se.ACCTNO;
                      --07   C   SYMBOL
                      l_txmsg.txfields ('07').defname   := 'SYMBOL';
                      l_txmsg.txfields ('07').TYPE      := 'C';
                      l_txmsg.txfields ('07').VALUE     := rec_se.SYMBOL;
                      --08   N   AMT
                      l_txmsg.txfields ('08').defname   := 'AMT';
                      l_txmsg.txfields ('08').TYPE      := 'N';
                      l_txmsg.txfields ('08').VALUE     := round(rec_se.AMT,0);
                      --09   N   QTTY
                      l_txmsg.txfields ('09').defname   := 'QTTY';
                      l_txmsg.txfields ('09').TYPE      := 'N';
                      l_txmsg.txfields ('09').VALUE     := rec_se.QTTY;
                      --10   N   MATCHPRICE
                      l_txmsg.txfields ('10').defname   := 'MATCHPRICE';
                      l_txmsg.txfields ('10').TYPE      := 'N';
                      l_txmsg.txfields ('10').VALUE     := rec_se.MATCHPRICE;
                      --11   N   RCVQTTY
                      l_txmsg.txfields ('11').defname   := 'RCVQTTY';
                      l_txmsg.txfields ('11').TYPE      := 'N';
                      l_txmsg.txfields ('11').VALUE     := rec_se.QTTY;
                      --12   N   PARVALUE
                      l_txmsg.txfields ('12').defname   := 'PARVALUE';
                      l_txmsg.txfields ('12').TYPE      := 'N';
                      l_txmsg.txfields ('12').VALUE     := rec_se.PARVALUE;
                      --13   N   FEEACR
                      l_txmsg.txfields ('13').defname   := 'FEEACR';
                      l_txmsg.txfields ('13').TYPE      := 'N';
                      l_txmsg.txfields ('13').VALUE     := rec_se.FEEACR;
                      --30   C   DESC
                      l_txmsg.txfields ('30').defname   := 'DESC';
                      l_txmsg.txfields ('30').TYPE      := 'C';

                      IF V_BLNVIETNAMESE = TRUE THEN
                        L_TXMSG.TXFIELDS('30').VALUE := l_desc_8868 || ' ' ||
                                                        TRIM(TO_CHAR(rec_se.SQTTY,
                                                                     '999,999,999,999,999,999,999')) || ' ' ||
                                                        rec_se.SYMBOL || ' ' ||
                                                        UTF8NUMS.C_CONST_DATE_VI || ' ' ||
                                                        SUBSTR(rec_se.ORGORDERID, 5, 2) || '/' ||
                                                        SUBSTR(rec_se.ORGORDERID, 7, 2) || '/' ||
                                                        SUBSTR(rec_se.ORGORDERID, 9, 2);
                      ELSE
                        L_TXMSG.TXFIELDS('30').VALUE := l_en_desc_8868 || ' ' ||
                                                        TRIM(TO_CHAR(rec_se.SQTTY,
                                                                     '999,999,999,999,999,999,999')) || ' ' ||
                                                        rec_se.SYMBOL || ' date ' ||
                                                        SUBSTR(rec_se.ORGORDERID, 5, 2) || '/' ||
                                                        SUBSTR(rec_se.ORGORDERID, 7, 2) || '/' ||
                                                        SUBSTR(rec_se.ORGORDERID, 9, 2);
                      END IF;
                      UPDATE SECMAST
                         SET MAPAVL = 'Y'
                       WHERE ORDERID = rec_se.ORGORDERID
                         AND ACCTNO = rec_se.AFACCTNO;

                      BEGIN
                          IF txpks_#8868.fn_batchtxprocess (l_txmsg,pv_err_code,l_err_param) <> systemnums.c_success THEN
                             ROLLBACK TO begin_sec_settlement;
                             v_errcheck := TRUE;
                             EXIT;
                          END IF;
                      END;
                    END IF;
                    EXIT WHEN v_errcheck = TRUE;
               END LOOP;

              --Phong toa chung khoan ve cho deal
              FOR rec_df IN (
                  SELECT df.acctno,sts.autoid,df.rcvqtty,least(sts.aqtty,m.adfqtty,df.rcvqtty) aqtty,sts.acctno seacctno,df.afacctno
                    FROM stschd sts ,v_getDealInfo df, stdfmap m, sbsecurities sb
                   WHERE df.rcvqtty > 0
                     AND sts.aqtty > 0
                     AND sts.codeid = sb.codeid
                     AND ((sb.SECTYPE NOT IN ('003','006','012') and pv_cleartype = '1') or (sb.SECTYPE IN ('003','006','012') and pv_cleartype = '2')) --TTBT T+1.5 TP: cleartype = 1 la CP, = 2 la TP
                     AND sts.autoid =m.stschdid
                     AND m.dfacctno = df.acctno
                     AND sts.status = 'C'
                     AND duetype ='RS'
                     AND df.afacctno = pv_acctno
                ) LOOP
                   IF v_errcheck = FALSE THEN
                     --Set txnum
                      SELECT systemnums.C_BATCH_PREFIXED
                                       || LPAD (seq_BATCHTXNUM.NEXTVAL, 8, '0')
                                INTO l_txmsg.txnum
                                FROM DUAL;
                      l_txmsg.brid        := substr(rec_df.AFACCTNO,1,4);
                      l_txmsg.tltxcd     := '2661';
                      --Set cac field giao dich
                      --01   N   AUTOID
                      l_txmsg.txfields ('01').defname   := 'AUTOID';
                      l_txmsg.txfields ('01').TYPE      := 'N';
                      l_txmsg.txfields ('01').VALUE     := rec_df.AUTOID;

                      --02   ACCTNO     C
                      l_txmsg.txfields ('02').defname   := 'ACCTNO';
                      l_txmsg.txfields ('02').TYPE      := 'C';
                      l_txmsg.txfields ('02').VALUE     := rec_df.ACCTNO;
                      --05   AFACCTNO   C
                      l_txmsg.txfields ('05').defname   := 'AFACCTNO';
                      l_txmsg.txfields ('05').TYPE      := 'C';
                      l_txmsg.txfields ('05').VALUE     := rec_df.AFACCTNO;
                      --06   C   SEACCTNO
                      l_txmsg.txfields ('06').defname   := 'SEACCTNO';
                      l_txmsg.txfields ('06').TYPE      := 'C';
                      l_txmsg.txfields ('06').VALUE     := rec_df.SEACCTNO;
                      --10   RCVQTTY    N
                      l_txmsg.txfields ('10').defname   := 'RCVQTTY';
                      l_txmsg.txfields ('10').TYPE      := 'N';
                      l_txmsg.txfields ('10').VALUE     := rec_df.AQTTY;
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
                      l_txmsg.txfields ('30').VALUE     := l_desc_2661;

                      BEGIN
                          IF txpks_#2661.fn_batchtxprocess (l_txmsg,pv_err_code,l_err_param) <> systemnums.c_success THEN
                             ROLLBACK TO begin_sec_settlement;
                             v_errcheck := TRUE;
                             EXIT;
                          END IF;
                      END;
                   END IF;
                  EXIT WHEN v_errcheck = TRUE;
               END LOOP;
           END IF; --TTBT T+1.5 TP: Them xu ly deadlock
           -- danh dau ts
           /*IF fn_markedafpralloc(pv_acctno,
                                null,
                                'A',
                                'M',
                                null,
                                'N',
                                'N',
                                l_currdate,
                                '',
                                pv_err_code) <> systemnums.C_SUCCESS then
                    null;
           END IF;*/
           --
           pv_err_code := NVL(pv_err_code,0);
           --log xu ly
           INSERT INTO odcfclearing_log (autoid,afacctno,key_id,router_id,function_id,log_date,status,error_code,isauto,cleartype)
                VALUES(seq_odcfclearing_log.nextval,pv_acctno,pv_autoid, pv_routerid,'RCVSECTIME',l_currdate,decode(NVL(pv_err_code,0),0,'C','E'),decode(NVL(pv_err_code,0),0,'',pv_err_code||':'||l_err_param||'- GD: '||l_txmsg.tltxcd),pv_isauto,pv_cleartype); --TTBT T+1.5 TP: Them pv_cleartype
           pr_lockaccount(pv_acctno,'N','RS',pv_cleartype,pv_err_code); --TTBT T+1.5 TP: Them xu ly deadlock
      COMMIT;
      EXCEPTION
        WHEN OTHERS THEN
          plog.error(pkgctx, 'Error On ' ||pv_acctno||', cleartype='||pv_cleartype||': '||SQLERRM || dbms_utility.format_error_backtrace);
          ROLLBACK TO begin_sec_settlement;
          INSERT INTO odcfclearing_log (autoid,afacctno,key_id,router_id,function_id,log_date,status,error_code,isauto,cleartype)
               VALUES(seq_odcfclearing_log.nextval,pv_acctno,pv_autoid, pv_routerid,'RCVSECTIME',l_currdate,'E','EXCEPTION '|| pv_acctno,pv_isauto,pv_cleartype); --TTBT T+1.5 TP: Them pv_cleartype
          pr_lockaccount(pv_acctno,'N','RS',pv_cleartype,pv_err_code); --TTBT T+1.5 TP: Them xu ly deadlock
          COMMIT;
      END;

  plog.error(pkgctx, 'End pr_process_settlement_buy autoid=' ||pv_autoid||'  mod=' || pv_routerid||', cleartype='||pv_cleartype);
  plog.setEndSection(pkgctx, 'pr_process_settlement_buy');
EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    INSERT INTO odcfclearing_log (autoid,afacctno,key_id,router_id,function_id,log_date,status,error_code,cleartype)
               VALUES(seq_odcfclearing_log.nextval,pv_acctno,pv_autoid, pv_routerid,'RCVSECTIME',l_currdate,'E','EXCEPTION '|| pv_acctno,pv_cleartype); --TTBT T+1.5 TP: Them pv_cleartype
    COMMIT;
    plog.error(pkgctx, 'End pr_process_settlement_buy autoid=' ||pv_autoid||'  mod=' || pv_routerid ||', cleartype='||pv_cleartype|| ' With Error ');
    plog.error(pkgctx, SQLERRM || dbms_utility.format_error_backtrace);
    plog.setEndSection(pkgctx, 'pr_process_settlement_buy');
END;

-- xy ly ban
PROCEDURE pr_process_settlement_sell(pv_acctno   IN     VARCHAR2,
                                     pv_autoid   IN     VARCHAR2,
                                     pv_routerid IN     VARCHAR2,
                                     pv_isauto   IN     VARCHAR2 DEFAULT 'Y',
                                     pv_cleartype IN varchar2, --TTBT T+1.5 TP: them p_cleartype
                                     pv_err_code OUT    VARCHAR2)
IS
l_txmsg             tx.msg_rectype;
l_currdate          DATE;
v_count             NUMBER;
l_desc_0066         VARCHAR2(1000);
l_desc_8856         VARCHAR2(1000);
l_desc_8866         VARCHAR2(1000);
v_errcheck          BOOLEAN;
l_err_param         VARCHAR2(300);
v_dblProfit         NUMBER;
v_dblLoss           NUMBER;
v_dblAVLRCVAMT      NUMBER(20,0);
v_dblVATRATE        NUMBER(20,0);
v_dblAVLFEEAMT      NUMBER(20,0);
v_dblFEEAMT         NUMBER(20,0);
v_strORGORDERID     VARCHAR2(100);
l_vatrate           NUMBER;
l_rightrate         NUMBER;
l_ISCOREBANK        NUMBER;
v_trftype_sell      VARCHAR2(100);
v_bankcode_sell     VARCHAR2(100);
v_bankname_sell     VARCHAR2(300);
v_desacctno_sell    VARCHAR2(100);
v_desacctname_sell  VARCHAR2(300);
v_trftype_fee       VARCHAR2(100);
v_bankcode_fee      VARCHAR2(100);
v_bankname_fee      VARCHAR2(300);
v_desacctno_fee     VARCHAR2(100);
v_desacctname_fee   VARCHAR2(300);
v_trftype_tax       VARCHAR2(100);
v_bankcode_tax      VARCHAR2(100);
v_bankname_tax      VARCHAR2(300);
v_desacctno_tax     VARCHAR2(100);
v_desacctname_tax   VARCHAR2(300);
l_orgtxnum          VARCHAR2(100);
l_orgdate           VARCHAR2(10);
l_orgreqid          NUMBER(20,0);
l_err_code          VARCHAR2(2000);
BEGIN
  plog.setBeginSection(pkgctx, 'pr_process_settlement_sell');
  plog.error(pkgctx, 'Begin pr_process_settlement_sell autoid=' ||pv_autoid||'  mod=' || pv_routerid||' cleartype='||pv_cleartype );
  -- Chuan bi tham so
  l_currdate    := to_date(cspks_system.fn_get_sysvar('SYSTEM','CURRDATE'),'DD/MM/RRRR');
  l_vatrate     := cspks_system.fn_get_sysvar('SYSTEM','ADVSELLDUTY');
  l_rightrate   := cspks_system.fn_get_sysvar('SYSTEM','ADVVATDUTY');
  v_errcheck := FALSE;
  pv_err_code := 0;

  SELECT MAX(CASE WHEN TLTXCD ='0066' THEN TXDESC ELSE '' END),
         MAX(CASE WHEN TLTXCD ='8856' THEN TXDESC ELSE '' END),
         MAX(CASE WHEN TLTXCD ='8866' THEN TXDESC ELSE '' END)
   INTO   l_desc_0066, l_desc_8856 ,l_desc_8866
   FROM TLTX WHERE TLTXCD IN ('0066','8856','8866');

   BEGIN
       SELECT MAX(CASE WHEN TRFCODE = 'TRFODSELL' THEN CRA.TRFCODE ELSE '' END) TRFTYPE_SELL,
             MAX(CASE WHEN TRFCODE = 'TRFODSELL' THEN CRB.BANKCODE ELSE '' END) BANKCODE_SELL,
             MAX(CASE WHEN TRFCODE = 'TRFODSELL' THEN CRB.BANKCODE||':'||CRB.BANKNAME ELSE '' END) BANKNAME_SELL,
             MAX(CASE WHEN TRFCODE = 'TRFODSELL' THEN CRA.REFACCTNO ELSE '' END) DESACCTNO_SELL,
             MAX(CASE WHEN TRFCODE = 'TRFODSELL' THEN CRA.REFACCTNAME ELSE '' END) DESACCTNAME_SELL,
             MAX(CASE WHEN TRFCODE = 'TRFODSFEE' THEN CRA.TRFCODE ELSE '' END) TRFTYPE_FEE,
             MAX(CASE WHEN TRFCODE = 'TRFODSFEE' THEN CRB.BANKCODE ELSE '' END) BANKCODE_FEE,
             MAX(CASE WHEN TRFCODE = 'TRFODSFEE' THEN CRB.BANKCODE||':'||CRB.BANKNAME ELSE '' END) BANKNAME_FEE,
             MAX(CASE WHEN TRFCODE = 'TRFODSFEE' THEN CRA.REFACCTNO ELSE '' END) DESACCTNO_FEE,
             MAX(CASE WHEN TRFCODE = 'TRFODSFEE' THEN CRA.REFACCTNAME ELSE '' END) DESACCTNAME_FEE,
             MAX(CASE WHEN TRFCODE = 'TRFODTAX' THEN CRA.TRFCODE ELSE '' END) TRFTYPE_TAX,
             MAX(CASE WHEN TRFCODE = 'TRFODTAX' THEN CRB.BANKCODE ELSE '' END) BANKCODE_TAX,
             MAX(CASE WHEN TRFCODE = 'TRFODTAX' THEN CRB.BANKCODE||':'||CRB.BANKNAME ELSE '' END) BANKNAME_TAX,
             MAX(CASE WHEN TRFCODE = 'TRFODTAX' THEN CRA.REFACCTNO ELSE '' END) DESACCTNO_TAX,
             MAX(CASE WHEN TRFCODE = 'TRFODTAX' THEN CRA.REFACCTNAME ELSE '' END) DESACCTNAME_TAX
         INTO v_trftype_sell, v_bankcode_sell, v_bankname_sell, v_desacctno_sell, v_desacctname_sell,
              v_trftype_fee, v_bankcode_fee, v_bankname_fee, v_desacctno_fee, v_desacctname_fee,
              v_trftype_tax, v_bankcode_tax, v_bankname_tax, v_desacctno_tax, v_desacctname_tax
        FROM AFMAST AF, CRBDEFACCT CRA,CRBDEFBANK CRB
       WHERE AF.BANKNAME = CRB.BANKCODE
         AND CRB.BANKCODE = CRA.REFBANK
         AND AF.COREBANK = 'Y'
         AND AF.ACCTNO = pv_acctno
         AND CRA.TRFCODE IN ('TRFODSELL','TRFODSFEE','TRFODTAX');
    EXCEPTION WHEN OTHERS THEN
       v_trftype_sell     := '';
       v_bankcode_sell    := '';
       v_bankname_sell    := '';
       v_desacctno_sell   := '';
       v_desacctname_sell := '';
       v_trftype_fee      := '';
       v_bankcode_fee     := '';
       v_bankname_fee     := '';
       v_desacctno_fee    := '';
       v_desacctname_fee  := '';
    END;
    l_txmsg.msgtype     := 'T';
    l_txmsg.local       := 'N';
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
    l_txmsg.batchname   := 'AUTO_SETTLEMENT';
    l_txmsg.txdate      := l_currdate;
    l_txmsg.busdate     := l_currdate;
    -- Nhan tien cuoi ngay
   SAVEPOINT begin_cash_settlement;
      BEGIN
          --TTBT T+1.5 TP: them xu ly deadlock
          pr_lockaccount(pv_acctno,'Y','RM',pv_cleartype,pv_err_code);
          IF pv_err_code <> 0 THEN
             pr_lockaccount(pv_acctno,'N','RM',pv_cleartype,l_err_code);
          ELSE
              --End TTBT T+1.5 TP: them xu ly deadlock
              --Nhan tien ban va tra phi lenh ban
              FOR rec_ci IN (
                  SELECT MST.AUTOID, MAX(CF.CUSTODYCD) CUSTODYCD, MAX(CF.FULLNAME) FULLNAME, MAX(CF.ADDRESS) ADDRESS,MAX(CF.IDCODE) LICENSE,
                         MST.AFACCTNO, MST.ACCTNO, MIN(MST.ORGORDERID) ORGORDERID,
                         MIN(MST.AMT) AMT,MAX(COSTPRICE) COSTPRICE, MIN(MST.QTTY) QTTY, MIN(SEC.CODEID) CODEID,MIN(ODMST.TXNUM) ODTXNUM,
                         MIN(SEC.SYMBOL) SYMBOL,MIN(MST.AAMT) AAMT,CASE WHEN CI.COREBANK='Y' THEN 1 ELSE 0 END COREBANK,
                         MIN(MST.TXDATE) TXDATE, MIN(SEC.PARVALUE) PARVALUE,MAX(ODMST.EXECTYPE) EXECTYPE,MIN(CEIL(ODMST.FEEACR)) FEEACR,
                         MIN(ODMST.FEEACR-ODMST.FEEAMT) AVLFEEAMT, MIN(TYP.VATRATE) VATRATE, MAX(CF.BRID) BRID, MIN(ODMST.EXECQTTY) SQTTY,
                         MAX(AF.BANKNAME) BANKNAME, MIN(MST.CLEARDATE) DUEDATE, MIN(ODMST.EXECAMT) EXECAMT, MAX(AF.BANKACCTNO) BANKACCTNO
                   FROM SBCLDR CLR1, SBCLDR CLR2,STSCHD MST, ODMAST ODMST,AFMAST AF,CFMAST CF,CIMAST CI,ODTYPE TYP,SBSECURITIES SEC
                  WHERE ODMST.AFACCTNO = AF.ACCTNO
                    AND AF.CUSTID = CF.CUSTID
                    AND CLR1.SBDATE >= MST.TXDATE
                    AND CLR1.SBDATE < CLR2.SBDATE
                    AND CLR2.SBDATE >= MST.TXDATE
                    AND CLR1.CLDRTYPE = SEC.TRADEPLACE
                    AND CLR2.CLDRTYPE = SEC.TRADEPLACE
                    AND ODMST.AFACCTNO = CI.AFACCTNO
                    AND ODMST.ACTYPE = TYP.ACTYPE
                    AND MST.ORGORDERID = ODMST.ORDERID
                    AND MST.CODEID = SEC.CODEID
                    AND SEC.TRADEPLACE <> '003'
                    AND CLR2.SBDATE = l_currdate
                    AND AF.ACCTNO = pv_acctno
                    AND MST.STATUS = 'N'
                    AND MST.DELTD <> 'Y'
                    AND MST.DUETYPE = 'RM'
                    AND CF.CUSTATCOM ='Y'
                    AND ((SEC.SECTYPE NOT IN ('003','006','012') and pv_cleartype = '1') or (SEC.SECTYPE IN ('003','006','012') and pv_cleartype = '2')) --TTBT T+1.5 TP: cleartype = 1 la CP, = 2 la TP
                  GROUP BY MST.AUTOID, CLR2.SBDATE, MST.AFACCTNO, MST.ACCTNO,CI.COREBANK
                  HAVING MIN(MST.CLEARDAY)<=
                  (CASE WHEN MIN(MST.CLEARCD)='B' THEN SUM(CASE WHEN CLR1.HOLIDAY='Y' THEN 0 ELSE 1 END) ELSE SUM(CASE WHEN CLR1.HOLIDAY='Y' THEN 1 ELSE 1 END) END)
                  ORDER BY ORGORDERID
                ) LOOP
                    v_strORGORDERID:='orderid';
                    v_dblAVLFEEAMT:=0;

                    IF v_errcheck = FALSE THEN
                      -- 1.Nhan tien ban
                      --Set txnum
                      SELECT systemnums.C_BATCH_PREFIXED
                                       || LPAD (seq_BATCHTXNUM.NEXTVAL, 8, '0')
                                INTO l_txmsg.txnum
                                FROM DUAL;
                      l_txmsg.brid       := rec_ci.BRID;
                      l_txmsg.tltxcd     := '8866';
                      --Tinh gia tri lai lo cho tu doanh
                      If substr(rec_ci.CUSTODYCD,1,4) = 'P' Then
                          If rec_ci.AMT > rec_ci.COSTPRICE * rec_ci.QTTY Then
                              v_dblProfit := round(rec_ci.AMT - rec_ci.COSTPRICE * rec_ci.QTTY,0);
                              v_dblLoss := 0;
                          Else
                              v_dblProfit := 0;
                              v_dblLoss := round(rec_ci.COSTPRICE * rec_ci.QTTY - rec_ci.AMT,0);
                          End If;
                      end if;
                      --Set cac field giao dich
                      --01   N   AUTOID
                      l_txmsg.txfields ('01').defname   := 'AUTOID';
                      l_txmsg.txfields ('01').TYPE      := 'N';
                      l_txmsg.txfields ('01').VALUE     := rec_ci.AUTOID;

                      --03   C   ORGORDERID
                      l_txmsg.txfields ('03').defname   := 'ORGORDERID';
                      l_txmsg.txfields ('03').TYPE      := 'C';
                      l_txmsg.txfields ('03').VALUE     := rec_ci.ORGORDERID;
                      --04   C   AFACCTNO
                      l_txmsg.txfields ('04').defname   := 'AFACCTNO';
                      l_txmsg.txfields ('04').TYPE      := 'C';
                      l_txmsg.txfields ('04').VALUE     := rec_ci.AFACCTNO;
                      --05   C   CIACCTNO
                      l_txmsg.txfields ('05').defname   := 'CIACCTNO';
                      l_txmsg.txfields ('05').TYPE      := 'C';
                      l_txmsg.txfields ('05').VALUE     := rec_ci.ACCTNO;
                      --06   C   SEACCTNO
                      l_txmsg.txfields ('06').defname   := 'SEACCTNO';
                      l_txmsg.txfields ('06').TYPE      := 'C';
                      l_txmsg.txfields ('06').VALUE     := rec_ci.AFACCTNO || rec_ci.CODEID;
                      --07   C   SYMBOL
                      l_txmsg.txfields ('07').defname   := 'SYMBOL';
                      l_txmsg.txfields ('07').TYPE      := 'C';
                      l_txmsg.txfields ('07').VALUE     := rec_ci.SYMBOL;
                      --08   N   AMT
                      l_txmsg.txfields ('08').defname   := 'AMT';
                      l_txmsg.txfields ('08').TYPE      := 'N';
                      l_txmsg.txfields ('08').VALUE     := round(rec_ci.AMT,0);
                      --09   N   QTTY
                      l_txmsg.txfields ('09').defname   := 'QTTY';
                      l_txmsg.txfields ('09').TYPE      := 'N';
                      l_txmsg.txfields ('09').VALUE     := rec_ci.QTTY;
                      --10   N   RAMT
                      l_txmsg.txfields ('10').defname   := 'RAMT';
                      l_txmsg.txfields ('10').TYPE      := 'N';
                      l_txmsg.txfields ('10').VALUE     := round(rec_ci.AMT,0);
                      --11   N   AAMT
                      l_txmsg.txfields ('11').defname   := 'AAMT';
                      l_txmsg.txfields ('11').TYPE      := 'N';
                      l_txmsg.txfields ('11').VALUE     := round(rec_ci.AAMT,0);
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
                      l_txmsg.txfields ('16').VALUE     := rec_ci.COSTPRICE;
                      --31   N   COREBANK
                      l_txmsg.txfields ('31').defname   := 'COREBANK';
                      l_txmsg.txfields ('31').TYPE      := 'N';
                      l_txmsg.txfields ('31').VALUE     := rec_ci.COREBANK;
                      --30   C   DESC
                      l_txmsg.txfields ('30').defname   := 'DESC';
                      l_txmsg.txfields ('30').TYPE      := 'C';
                      l_txmsg.txfields ('30').VALUE     := l_desc_8866 ||' ' || trim(to_char(rec_ci.SQTTY,'999,999,999,999,999')) || ' ' || rec_ci.SYMBOL || ' ' || UTF8NUMS.C_CONST_DATE_VI || ' ' || TO_CHAR(rec_ci.TXDATE, 'DD/MM/RRRR');
                      --44   N   PARVALUE
                      l_txmsg.txfields ('44').defname   := 'PARVALUE';
                      l_txmsg.txfields ('44').TYPE      := 'N';
                      l_txmsg.txfields ('44').VALUE     := rec_ci.PARVALUE;

                      --53   N   MICD
                      l_txmsg.txfields ('53').defname   := 'MICD';
                      l_txmsg.txfields ('53').TYPE      := 'C';
                      l_txmsg.txfields ('53').VALUE     := '';

                      --60   N   ISMORTAGE
                      l_txmsg.txfields ('60').defname   := 'ISMORTAGE';
                      l_txmsg.txfields ('60').TYPE      := 'N';
                      l_txmsg.txfields ('60').VALUE     := (case when rec_ci.EXECTYPE='MS' then 1 else 0 end);
                      BEGIN
                          IF txpks_#8866.fn_batchtxprocess (l_txmsg,pv_err_code,l_err_param) <> systemnums.c_success THEN
                             ROLLBACK TO begin_cash_settlement;
                             v_errcheck := TRUE;
                             EXIT;
                          END IF;
                      END;

                      -- 2.Tra phi lenh ban
                      IF v_strORGORDERID <> rec_ci.ORGORDERID THEN
                         v_strORGORDERID := rec_ci.ORGORDERID;
                         v_dblAVLFEEAMT := rec_ci.AVLFEEAMT;
                      END IF;
                      v_dblAVLRCVAMT := rec_ci.AMT;
                      v_dblVATRATE := rec_ci.VATRATE;

                      IF v_dblAVLFEEAMT <= v_dblAVLRCVAMT THEN
                         v_dblFEEAMT := v_dblAVLFEEAMT;
                         v_dblAVLFEEAMT := 0;
                      ELSE
                         v_dblFEEAMT := v_dblAVLRCVAMT;
                         v_dblAVLFEEAMT := v_dblAVLFEEAMT - v_dblAVLRCVAMT;
                      END IF;

                      IF v_dblFEEAMT > 0 THEN
                         --Set txnum
                         SELECT systemnums.C_BATCH_PREFIXED
                                           || LPAD (seq_BATCHTXNUM.NEXTVAL, 8, '0')
                           INTO l_txmsg.txnum FROM DUAL;
                         l_txmsg.brid       := rec_ci.BRID;
                         l_txmsg.tltxcd     := '8856';

                         --Set cac field giao dich
                         --01   N   AUTOID
                         l_txmsg.txfields ('01').defname   := 'AUTOID';
                         l_txmsg.txfields ('01').TYPE      := 'N';
                         l_txmsg.txfields ('01').VALUE     := rec_ci.AUTOID;

                         --03   C   ORGORDERID
                         l_txmsg.txfields ('03').defname   := 'ORGORDERID';
                         l_txmsg.txfields ('03').TYPE      := 'C';
                         l_txmsg.txfields ('03').VALUE     := rec_ci.ORGORDERID;
                         --04   C   AFACCTNO
                         l_txmsg.txfields ('04').defname   := 'AFACCTNO';
                         l_txmsg.txfields ('04').TYPE      := 'C';
                         l_txmsg.txfields ('04').VALUE     := rec_ci.AFACCTNO;
                            --05   C   CIACCTNO
                         l_txmsg.txfields ('05').defname   := 'CIACCTNO';
                         l_txmsg.txfields ('05').TYPE      := 'C';
                         l_txmsg.txfields ('05').VALUE     := rec_ci.ACCTNO;
                            --06   C   SEACCTNO
                         l_txmsg.txfields ('06').defname   := 'SEACCTNO';
                         l_txmsg.txfields ('06').TYPE      := 'C';
                         l_txmsg.txfields ('06').VALUE     := rec_ci.AFACCTNO || rec_ci.CODEID;
                            --07   C   SYMBOL
                         l_txmsg.txfields ('07').defname   := 'SYMBOL';
                         l_txmsg.txfields ('07').TYPE      := 'C';
                         l_txmsg.txfields ('07').VALUE     := rec_ci.SYMBOL;
                            --08   N   AMT
                         l_txmsg.txfields ('08').defname   := 'AMT';
                         l_txmsg.txfields ('08').TYPE      := 'N';
                         l_txmsg.txfields ('08').VALUE     := 0;
                            --09   N   QTTY
                         l_txmsg.txfields ('09').defname   := 'QTTY';
                         l_txmsg.txfields ('09').TYPE      := 'N';
                         l_txmsg.txfields ('09').VALUE     := rec_ci.QTTY;
                            --10   N   RAMT
                         l_txmsg.txfields ('10').defname   := 'RAMT';
                         l_txmsg.txfields ('10').TYPE      := 'N';
                         l_txmsg.txfields ('10').VALUE     := 0;
                            --11   N   AAMT
                         l_txmsg.txfields ('11').defname   := 'AAMT';
                         l_txmsg.txfields ('11').TYPE      := 'N';
                         l_txmsg.txfields ('11').VALUE     := 0;
                            --12   N   FEEAMT
                         l_txmsg.txfields ('12').defname   := 'FEEAMT';
                         l_txmsg.txfields ('12').TYPE      := 'N';
                         l_txmsg.txfields ('12').VALUE     := round(v_dblFEEAMT,0);

                            --13   N   VAT
                         l_txmsg.txfields ('13').defname   := 'VAT';
                         l_txmsg.txfields ('13').TYPE      := 'N';
                         l_txmsg.txfields ('13').VALUE     := round(v_dblVATRATE * v_dblFEEAMT,0);
                            --14   N   PROFITAMT
                         l_txmsg.txfields ('14').defname   := 'PROFITAMT';
                         l_txmsg.txfields ('14').TYPE      := 'N';
                         l_txmsg.txfields ('14').VALUE     := 0;
                            --15   N   LOSSAMT
                         l_txmsg.txfields ('15').defname   := 'LOSSAMT';
                         l_txmsg.txfields ('15').TYPE      := 'N';
                         l_txmsg.txfields ('15').VALUE     := 0;
                            --16   N   COSTPRICE
                         l_txmsg.txfields ('16').defname   := 'COSTPRICE';
                         l_txmsg.txfields ('16').TYPE      := 'N';
                         l_txmsg.txfields ('16').VALUE     := rec_ci.COSTPRICE;
                            --30   C   DESC
                         l_txmsg.txfields ('30').defname   := 'DESC';
                         l_txmsg.txfields ('30').TYPE      := 'C';
                         l_txmsg.txfields ('30').VALUE     := l_desc_8856 ||' ' || trim(to_char(rec_ci.SQTTY,'999,999,999,999,999')) || ' ' || rec_ci.SYMBOL || ' ' || UTF8NUMS.C_CONST_DATE_VI || ' ' || to_char(rec_ci.TXDATE);

                            --44   N   PARVALUE
                         l_txmsg.txfields ('44').defname   := 'PARVALUE';
                         l_txmsg.txfields ('44').TYPE      := 'N';
                         l_txmsg.txfields ('44').VALUE     := rec_ci.PARVALUE;

                            --53   N   MICD
                         l_txmsg.txfields ('53').defname   := 'MICD';
                         l_txmsg.txfields ('53').TYPE      := 'C';
                         l_txmsg.txfields ('53').VALUE     := '';

                            --60   N   ISMORTAGE
                         l_txmsg.txfields ('60').defname   := 'ISMORTAGE';
                         l_txmsg.txfields ('60').TYPE      := 'N';
                         l_txmsg.txfields ('60').VALUE     := (case when rec_ci.EXECTYPE='MS' then 1 else 0 end);

                            --31   N   COREBANK
                         l_txmsg.txfields ('31').defname   := 'COREBANK';
                         l_txmsg.txfields ('31').TYPE      := 'N';
                         l_txmsg.txfields ('31').VALUE     := rec_ci.COREBANK;

                         BEGIN
                             IF txpks_#8856.fn_batchtxprocess (l_txmsg,pv_err_code,l_err_param) <> systemnums.c_success THEN
                                ROLLBACK TO begin_cash_settlement;
                                v_errcheck := TRUE;
                                EXIT;
                             END IF;
                         END;
                       END IF;

                      IF rec_ci.COREBANK = 1 THEN
                         -- gen bang ke nhan tien ban:SAMTTRF
                         -- check da ton tai bang ke chua
                         SELECT COUNT(*) INTO v_count
                           FROM CRBTXREQ REQ
                          WHERE REQ.TRFCODE='TRFODSELL' AND REQ.OBJNAME='6665'
                           AND (REQ.TXDATE=l_currdate OR (REQ.STATUS NOT IN ('E') AND REQ.TXDATE < l_currdate))
                           AND (TRUNC(REQ.REFCODE)=TRUNC(rec_ci.ORGORDERID) OR (TRUNC(REQ.REFCODE)=TRUNC(to_char(rec_ci.txdate,'DDMMRRRR')|| to_char(rec_ci.duedate,'DDMMRRRR') || rec_ci.afacctno)));
                         IF v_count = 0 AND round(rec_ci.EXECAMT-rec_ci.aamt) > 0 THEN
                           --set txnum
                            SELECT systemnums.C_BATCH_PREFIXED
                                                 || LPAD (seq_BATCHTXNUM.NEXTVAL, 8, '0')
                                          INTO l_txmsg.txnum
                                          FROM DUAL;
                            l_txmsg.brid       := rec_ci.BRID;
                            l_txmsg.tltxcd     := '6665';

                            --Set cac field giao dich
                            --06   C   TRFTYPE
                            l_txmsg.txfields ('06').defname   := 'TRFTYPE';
                            l_txmsg.txfields ('06').TYPE      := 'C';
                            l_txmsg.txfields ('06').VALUE     := v_trftype_sell;

                            --08   C   DUEDATE
                            l_txmsg.txfields ('08').defname   := 'DUEDATE';
                            l_txmsg.txfields ('08').TYPE      := 'C';
                            l_txmsg.txfields ('08').VALUE     := TO_DATE(rec_ci.DUEDATE,systemnums.C_DATE_FORMAT);

                            --03  SECACCOUNT
                            l_txmsg.txfields ('03').defname   := 'SECACCOUNT';
                            l_txmsg.txfields ('03').TYPE      := 'C';
                            l_txmsg.txfields ('03').VALUE     := rec_ci.AFACCTNO;

                            --90  CUSTNAME
                            l_txmsg.txfields ('90').defname   := 'CUSTNAME';
                            l_txmsg.txfields ('90').TYPE      := 'C';
                            l_txmsg.txfields ('90').VALUE     := rec_ci.FULLNAME;

                            --91  ADDRESS
                            l_txmsg.txfields ('91').defname   := 'ADDRESS';
                            l_txmsg.txfields ('91').TYPE      := 'C';
                            l_txmsg.txfields ('91').VALUE     := rec_ci.ADDRESS;

                            --92  LICENSE
                            l_txmsg.txfields ('92').defname   := 'LICENSE';
                            l_txmsg.txfields ('92').TYPE      := 'C';
                            l_txmsg.txfields ('92').VALUE     := rec_ci.LICENSE;

                            --93  BANKACCTNO
                            l_txmsg.txfields ('93').defname   := 'BANKACCTNO';
                            l_txmsg.txfields ('93').TYPE      := 'C';
                            l_txmsg.txfields ('93').VALUE     := rec_ci.BANKACCTNO;
                            --05  DESACCTNO
                            l_txmsg.txfields ('05').defname   := 'DESACCTNO';
                            l_txmsg.txfields ('05').TYPE      := 'C';
                            l_txmsg.txfields ('05').VALUE     := v_desacctno_sell;

                            --07  DESACCTNAME
                            l_txmsg.txfields ('07').defname   := 'DESACCTNAME';
                            l_txmsg.txfields ('07').TYPE      := 'C';
                            l_txmsg.txfields ('07').VALUE     := v_DESACCTNAME_sell;

                            --94  BANKNAME
                            l_txmsg.txfields ('94').defname   := 'BANKNAME';
                            l_txmsg.txfields ('94').TYPE      := 'C';
                            l_txmsg.txfields ('94').VALUE     := v_BANKNAME_sell;

                            --95  BANKQUE
                            l_txmsg.txfields ('95').defname   := 'BANKQUE';
                            l_txmsg.txfields ('95').TYPE      := 'C';
                            l_txmsg.txfields ('95').VALUE     := v_BANKCODE_sell;

                            --10  AMOUNT
                            l_txmsg.txfields ('10').defname   := 'AMOUNT';
                            l_txmsg.txfields ('10').TYPE      := 'N';
                            l_txmsg.txfields ('10').VALUE     := round(rec_ci.EXECAMT); -- tk corebank k ung

                            --04  ORDERID
                            l_txmsg.txfields ('04').defname   := 'ORDERID';
                            l_txmsg.txfields ('04').TYPE      := 'C';
                            l_txmsg.txfields ('04').VALUE     := rec_ci.ORGORDERID;

                            --11  TXNUM
                            l_txmsg.txfields ('11').defname   := 'TXNUM';
                            l_txmsg.txfields ('11').TYPE      := 'C';
                            l_txmsg.txfields ('11').VALUE     := rec_ci.ODTXNUM;

                            --30   C   DESC
                            l_txmsg.txfields ('30').defname   := 'DESC';
                            l_txmsg.txfields ('30').TYPE      := 'C';
                            --l_txmsg.txfields ('30').VALUE := utf8nums.c_const_TLTX_TXDESC_6665 || rec_ci.CUSTODYCD  ||  utf8nums.c_const_TLTX_TXDESC_6663_amt || trim(to_char(rec_ci.EXECAMT,'999,999,999,999,999,999,999')) || ' '|| utf8nums.c_const_TLTX_TXDESC_6663_date || TO_DATE(rec_ci.TXDATE,'DD/MM/RRRR');
                            L_TXMSG.TXFIELDS('30').VALUE := UTF8NUMS.C_CONST_TLTX_TXDESC_6665 ||
                                          rec_ci.CUSTODYCD ||
                                          UTF8NUMS.C_CONST_TLTX_TXDESC_6663_DATE ||
                                          rec_ci.DUEDATE;

                            BEGIN
                               IF txpks_#6665.fn_batchtxprocess (l_txmsg,pv_err_code,l_err_param) <> systemnums.c_success THEN
                                  ROLLBACK TO begin_cash_settlement;
                                  v_errcheck := TRUE;
                                  EXIT;
                               END IF;
                             END;
                          END IF;
                         -- gen bang ke thu phi ban: SFEETRF
                         -- check da ton tai bang ke chua
                         SELECT COUNT(*) INTO v_count
                           FROM CRBTXREQ REQ
                          WHERE REQ.TRFCODE='TRFODSFEE' AND REQ.OBJNAME='6666'
                            AND (REQ.TXDATE=l_currdate OR (REQ.STATUS NOT IN ('E') AND REQ.TXDATE < l_currdate))
                            AND TRUNC(REQ.REFCODE)=TRUNC(rec_ci.ORGORDERID);
                         IF v_count = 0 AND rec_ci.EXECAMT > 0 AND rec_ci.FEEACR > 0 THEN

                            IF rec_ci.TXDATE < l_currdate THEN
                               BEGIN
                                   SELECT REQID,OBJKEY,TO_CHAR(TXDATE,'DD/MM/RRRR')
                                   INTO l_orgreqid,l_orgtxnum,l_orgdate
                                   FROM CRBTXREQ
                                   WHERE REFCODE=rec_ci.ORGORDERID AND TRFCODE=v_trftype_fee AND STATUS ='E';

                                   cspks_rmproc.pr_RollbackCITRAN(l_orgtxnum,l_orgdate,pv_err_code);

                                   UPDATE CRBTXREQ SET STATUS='D' WHERE REQID=l_orgreqid;
                               EXCEPTION
                                   WHEN NO_DATA_FOUND THEN
                                       plog.error(pkgctx, 'Khong tim thay yeu cau tuong ung trong CRBTXREQ');
                                   WHEN OTHERS THEN
                                       plog.error(pkgctx, 'Co qua nhieu dong trung nhau trong CRBTXREQ');
                               END;
                             END IF;
                              --set txnum
                             SELECT systemnums.C_BATCH_PREFIXED
                                                   || LPAD (seq_BATCHTXNUM.NEXTVAL, 8, '0')
                                            INTO l_txmsg.txnum
                                            FROM DUAL;
                              l_txmsg.brid       := rec_ci.BRID;
                              l_txmsg.tltxcd     := '6666';

                              --Set cac field giao dich
                              --06   C   TRFTYPE
                              l_txmsg.txfields ('06').defname   := 'TRFTYPE';
                              l_txmsg.txfields ('06').TYPE      := 'C';
                              l_txmsg.txfields ('06').VALUE     := v_trftype_fee;

                              --08   C   DUEDATE
                              l_txmsg.txfields ('08').defname   := 'DUEDATE';
                              l_txmsg.txfields ('08').TYPE      := 'C';
                              l_txmsg.txfields ('08').VALUE     := TO_DATE(rec_ci.DUEDATE,systemnums.C_DATE_FORMAT);

                              --03  SECACCOUNT
                              l_txmsg.txfields ('03').defname   := 'SECACCOUNT';
                              l_txmsg.txfields ('03').TYPE      := 'C';
                              l_txmsg.txfields ('03').VALUE     := rec_ci.AFACCTNO;

                              --90  CUSTNAME
                              l_txmsg.txfields ('90').defname   := 'CUSTNAME';
                              l_txmsg.txfields ('90').TYPE      := 'C';
                              l_txmsg.txfields ('90').VALUE     := rec_ci.FULLNAME;

                              --91  ADDRESS
                              l_txmsg.txfields ('91').defname   := 'ADDRESS';
                              l_txmsg.txfields ('91').TYPE      := 'C';
                              l_txmsg.txfields ('91').VALUE     := rec_ci.ADDRESS;

                              --92  LICENSE
                              l_txmsg.txfields ('92').defname   := 'LICENSE';
                              l_txmsg.txfields ('92').TYPE      := 'C';
                              l_txmsg.txfields ('92').VALUE     := rec_ci.LICENSE;

                              --93  BANKACCTNO
                              l_txmsg.txfields ('93').defname   := 'BANKACCTNO';
                              l_txmsg.txfields ('93').TYPE      := 'C';
                              l_txmsg.txfields ('93').VALUE     := rec_ci.BANKACCTNO;

                              --05  DESACCTNO
                              l_txmsg.txfields ('05').defname   := 'DESACCTNO';
                              l_txmsg.txfields ('05').TYPE      := 'C';
                              l_txmsg.txfields ('05').VALUE     := v_desacctno_fee;

                              --07  DESACCTNAME
                              l_txmsg.txfields ('07').defname   := 'DESACCTNAME';
                              l_txmsg.txfields ('07').TYPE      := 'C';
                              l_txmsg.txfields ('07').VALUE     := v_DESACCTNAME_fee;

                              --94  BANKNAME
                              l_txmsg.txfields ('94').defname   := 'BANKNAME';
                              l_txmsg.txfields ('94').TYPE      := 'C';
                              l_txmsg.txfields ('94').VALUE     := v_BANKNAME_fee;

                              --95  BANKQUE
                              l_txmsg.txfields ('95').defname   := 'BANKQUE';
                              l_txmsg.txfields ('95').TYPE      := 'C';
                              l_txmsg.txfields ('95').VALUE     := v_BANKCODE_fee;

                              --10  AMOUNT
                              l_txmsg.txfields ('10').defname   := 'AMOUNT';
                              l_txmsg.txfields ('10').TYPE      := 'N';
                              l_txmsg.txfields ('10').VALUE     := rec_ci.FEEACR;

                              --04  ORDERID
                              l_txmsg.txfields ('04').defname   := 'ORDERID';
                              l_txmsg.txfields ('04').TYPE      := 'C';
                              l_txmsg.txfields ('04').VALUE     := rec_ci.ORGORDERID;

                              --11  TXNUM
                              l_txmsg.txfields ('11').defname   := 'TXNUM';
                              l_txmsg.txfields ('11').TYPE      := 'C';
                              l_txmsg.txfields ('11').VALUE     := rec_ci.ODTXNUM;

                              --30   C   DESC
                              l_txmsg.txfields ('30').defname   := 'DESC';
                              l_txmsg.txfields ('30').TYPE      := 'C';
                              l_txmsg.txfields ('30').VALUE := UTF8NUMS.C_CONST_TLTX_TXDESC_6666 ||
                                          rec_ci.CUSTODYCD ||
                                          UTF8NUMS.C_CONST_TLTX_TXDESC_6663_DATE ||
                                          rec_ci.DUEDATE;

                              BEGIN
                                 IF txpks_#6666.fn_batchtxprocess (l_txmsg,pv_err_code,l_err_param) <> systemnums.c_success THEN
                                    ROLLBACK TO begin_cash_settlement;
                                    v_errcheck := TRUE;
                                    EXIT;
                                 END IF;
                             END;
                         END IF;
                      END IF;
                    END IF;
                    EXIT WHEN v_errcheck = TRUE;
                 END LOOP;
              --Tra thue lenh ban
              FOR rec_vat IN (
                  SELECT MST.ACCTNO,CASE WHEN CI.COREBANK='Y' THEN 1 ELSE 0 END COREBANK,MST.ACTYPE,CF.VAT,
                         SUM(ST.AMT) SELLAMT,SUM(OD.TAXSELLAMT) TAXSELLAMT,SUM(ST.ARIGHT) SELLRIGHTAMT,
                         MAX(ST.TXDATE) TXDATE,MAX(ST.CLEARDATE) DUEDATE, MAX(CF.BRID) BRID,
                         MAX(CF.CUSTODYCD) CUSTODYCD, MAX(CF.FULLNAME) FULLNAME, MAX(CF.ADDRESS) ADDRESS,
                         MAX(CF.IDCODE) LICENSE,MAX(MST.BANKACCTNO) BANKACCTNO,
                         MAX( CASE WHEN  cf.whtax='Y' THEN  REPLACE ( l_desc_0066,'TNCN','') ELSE l_desc_0066  END  || ' ' ||
                               TO_CHAR(ST.TXDATE, 'DD/MM/RRRR')) TRDESC
                    FROM AFMAST MST,AFTYPE TYP,STSCHD ST, SBSECURITIES SB, ODMAST OD,CIMAST CI, CFMAST CF
                    WHERE MST.ACTYPE = TYP.ACTYPE AND MST.ACCTNO=ST.ACCTNO
                      AND ST.ORGORDERID = OD.ORDERID
                      AND ST.CODEID = SB.CODEID
                      AND MST.ACCTNO=CI.AFACCTNO
                      AND ST.DUETYPE = 'RM'
                      AND ST.CLEARDATE = l_currdate
                      AND MST.STATUS <> 'C'
                      AND CF.VAT = 'Y'
                      AND st.deltd = 'N'
                      AND CF.CUSTID = MST.CUSTID
                      AND CF.CUSTATCOM='Y'
                      AND MST.ACCTNO = pv_acctno
                      AND ((SB.SECTYPE NOT IN ('003','006','012') and pv_cleartype = '1') or (SB.SECTYPE IN ('003','006','012') and pv_cleartype = '2')) --TTBT T+1.5 TP: cleartype = 1 la CP, = 2 la TP
                    GROUP BY mst.ACCTNO , MST.ACTYPE, CF.VAT,CI.COREBANK
                    ORDER BY mst.ACCTNO
                  ) LOOP
                    IF v_errcheck = FALSE THEN
                       IF rec_vat.TAXSELLAMT>0 or rec_vat.SELLRIGHTAMT>0 then
                          --Set txnum
                          SELECT systemnums.C_BATCH_PREFIXED
                                           || LPAD (seq_BATCHTXNUM.NEXTVAL, 8, '0')
                                    INTO l_txmsg.txnum
                                    FROM DUAL;
                          l_txmsg.brid       := rec_vat.BRID;
                          l_txmsg.tltxcd     := '0066';

                          --Set cac field giao dich
                          --03  ACCTNO      C
                          l_txmsg.txfields ('03').defname   := 'ACCTNO';
                          l_txmsg.txfields ('03').TYPE      := 'C';
                          l_txmsg.txfields ('03').VALUE     := rec_vat.ACCTNO;
                           --07  PERCENT     N
                          l_txmsg.txfields ('07').defname   := 'PERCENT';
                          l_txmsg.txfields ('07').TYPE      := 'N';
                          l_txmsg.txfields ('07').VALUE     := 100;
                          --08  ICCFBAL     N
                          l_txmsg.txfields ('08').defname   := 'ICCFBAL';
                          l_txmsg.txfields ('08').TYPE      := 'N';
                          l_txmsg.txfields ('08').VALUE     := round(rec_vat.SELLAMT,0);
                          --09  ICCFRATE    N
                          l_txmsg.txfields ('09').defname   := 'FEEAMT';
                          l_txmsg.txfields ('09').TYPE      := 'N';
                          l_txmsg.txfields ('09').VALUE     := l_vatrate;
                          --10  INTAMT      N
                          l_txmsg.txfields ('10').defname   := 'INTAMT';
                          l_txmsg.txfields ('10').TYPE      := 'N';
                          l_txmsg.txfields ('10').VALUE     := rec_vat.TAXSELLAMT;--round(l_vatrate/100*REC.SELLAMT,0);
                          --11  RIGHTRATE    N
                          l_txmsg.txfields ('11').defname   := 'FEEAMT';
                          l_txmsg.txfields ('11').TYPE      := 'N';
                          l_txmsg.txfields ('11').VALUE     := l_rightrate;
                          --12  INTRIGHTAMT      N
                          l_txmsg.txfields ('12').defname   := 'INTAMT';
                          l_txmsg.txfields ('12').TYPE      := 'N';
                          l_txmsg.txfields ('12').VALUE     := round(rec_vat.SELLRIGHTAMT,0);
                          --30    DESC        C
                          l_txmsg.txfields ('30').defname   := 'DESC';
                          l_txmsg.txfields ('30').TYPE      := 'C';
                          l_txmsg.txfields ('30').VALUE     := rec_vat.TRDESC;
                          --31    COREBANK        N
                          l_txmsg.txfields ('31').defname   := 'COREBANK';
                          l_txmsg.txfields ('31').TYPE      := 'N';
                          l_txmsg.txfields ('31').VALUE     := rec_vat.COREBANK;
                          BEGIN
                              IF txpks_#0066.fn_batchtxprocess (l_txmsg,pv_err_code,l_err_param) <> systemnums.c_success THEN
                                 ROLLBACK TO begin_cash_settlement;
                                 v_errcheck := TRUE;
                                 EXIT;
                              END IF;
                          END;

                          IF rec_vat.COREBANK =1 THEN
                             SELECT COUNT(*) INTO v_count
                               FROM CRBTXREQ REQ
                              WHERE REQ.TRFCODE='TRFODTAX'
                               AND (REQ.TXDATE=l_currdate OR (REQ.STATUS IN ('P','A','S','C') AND REQ.TXDATE < l_currdate))
                               AND TRUNC(REQ.REFCODE)=TRUNC(to_char(rec_vat.txdate,'DDMMRRRR')|| to_char(rec_vat.duedate,'DDMMRRRR') || rec_vat.acctno);

                             IF rec_vat.TAXSELLAMT>0 AND v_count = 0 THEN
                               --set txnum
                                SELECT systemnums.C_BATCH_PREFIXED
                                                     || LPAD (seq_BATCHTXNUM.NEXTVAL, 8, '0')
                                              INTO l_txmsg.txnum
                                              FROM DUAL;
                                l_txmsg.brid       := rec_vat.BRID;
                                l_txmsg.tltxcd     := '6682';

                                --Set cac field giao dich
                                --06   C   TRFTYPE
                                l_txmsg.txfields ('06').defname   := 'TRFTYPE';
                                l_txmsg.txfields ('06').TYPE      := 'C';
                                l_txmsg.txfields ('06').VALUE     := v_trftype_tax;

                                --08   C   DUEDATE
                                l_txmsg.txfields ('08').defname   := 'DUEDATE';
                                l_txmsg.txfields ('08').TYPE      := 'C';
                                l_txmsg.txfields ('08').VALUE     := TO_DATE(rec_vat.DUEDATE,systemnums.C_DATE_FORMAT);

                                --03  SECACCOUNT
                                l_txmsg.txfields ('03').defname   := 'SECACCOUNT';
                                l_txmsg.txfields ('03').TYPE      := 'C';
                                l_txmsg.txfields ('03').VALUE     := rec_vat.ACCTNO;

                                --90  CUSTNAME
                                l_txmsg.txfields ('90').defname   := 'CUSTNAME';
                                l_txmsg.txfields ('90').TYPE      := 'C';
                                l_txmsg.txfields ('90').VALUE     := rec_vat.FULLNAME;

                                --91  ADDRESS
                                l_txmsg.txfields ('91').defname   := 'ADDRESS';
                                l_txmsg.txfields ('91').TYPE      := 'C';
                                l_txmsg.txfields ('91').VALUE     := rec_vat.ADDRESS;

                                --92  LICENSE
                                l_txmsg.txfields ('92').defname   := 'LICENSE';
                                l_txmsg.txfields ('92').TYPE      := 'C';
                                l_txmsg.txfields ('92').VALUE     := rec_vat.LICENSE;

                                --93  BANKACCTNO
                                l_txmsg.txfields ('93').defname   := 'BANKACCTNO';
                                l_txmsg.txfields ('93').TYPE      := 'C';
                                l_txmsg.txfields ('93').VALUE     := rec_vat.BANKACCTNO;

                                --05  DESACCTNO
                                l_txmsg.txfields ('05').defname   := 'DESACCTNO';
                                l_txmsg.txfields ('05').TYPE      := 'C';
                                l_txmsg.txfields ('05').VALUE     := v_DESACCTNO_tax;

                                --07  DESACCTNAME
                                l_txmsg.txfields ('07').defname   := 'DESACCTNAME';
                                l_txmsg.txfields ('07').TYPE      := 'C';
                                l_txmsg.txfields ('07').VALUE     := v_DESACCTNAME_tax;

                                --94  BANKNAME
                                l_txmsg.txfields ('94').defname   := 'BANKNAME';
                                l_txmsg.txfields ('94').TYPE      := 'C';
                                l_txmsg.txfields ('94').VALUE     := v_BANKNAME_tax;

                                --95  BANKQUE
                                l_txmsg.txfields ('95').defname   := 'BANKQUE';
                                l_txmsg.txfields ('95').TYPE      := 'C';
                                l_txmsg.txfields ('95').VALUE     := v_BANKCODE_tax;

                                --10  AMOUNT
                                l_txmsg.txfields ('10').defname   := 'AMOUNT';
                                l_txmsg.txfields ('10').TYPE      := 'N';
                                l_txmsg.txfields ('10').VALUE     := CEIL(rec_vat.TAXSELLAMT);

                                --31  TXNUM
                                l_txmsg.txfields ('31').defname   := 'ORGTXNUM';
                                l_txmsg.txfields ('31').TYPE      := 'C';
                                l_txmsg.txfields ('31').VALUE     := TRUNC(to_char(rec_vat.txdate,'DDMMRRRR') || to_char(rec_vat.DUEDATE,'DDMMRRRR') || rec_vat.ACCTNO);

                                --30   C   DESC
                                l_txmsg.txfields ('30').defname   := 'DESC';
                                l_txmsg.txfields ('30').TYPE      := 'C';
                                l_txmsg.txfields ('30').VALUE := utf8nums.c_const_TLTX_TXDESC_6682_DIV || rec_vat.CUSTODYCD || utf8nums.c_const_TLTX_TXDESC_6663_amt || trim(to_char(rec_vat.TAXSELLAMT,'999,999,999,999,999,999,999'))
                                                                    || utf8nums.c_const_TLTX_TXDESC_6663_date || TO_DATE(rec_vat.TXDATE,'DD/MM/RRRR');

                                BEGIN
                                    IF txpks_#6682.fn_batchtxprocess (l_txmsg,pv_err_code,l_err_param) <> systemnums.c_success THEN
                                       ROLLBACK TO begin_cash_settlement;
                                       v_errcheck := TRUE;
                                       EXIT;
                                    END IF;
                                END;
                              END IF;
                              IF rec_vat.SELLRIGHTAMT>0 AND v_count = 0 THEN
                                 --set txnum
                                  SELECT systemnums.C_BATCH_PREFIXED
                                                       || LPAD (seq_BATCHTXNUM.NEXTVAL, 8, '0')
                                                INTO l_txmsg.txnum
                                                FROM DUAL;
                                  l_txmsg.brid       := rec_vat.BRID;
                                  l_txmsg.tltxcd     := '6682';

                                  --Set cac field giao dich
                                  --06   C   TRFTYPE
                                  l_txmsg.txfields ('06').defname   := 'TRFTYPE';
                                  l_txmsg.txfields ('06').TYPE      := 'C';
                                  l_txmsg.txfields ('06').VALUE     := v_trftype_tax;

                                  --08   C   DUEDATE
                                  l_txmsg.txfields ('08').defname   := 'DUEDATE';
                                  l_txmsg.txfields ('08').TYPE      := 'C';
                                  l_txmsg.txfields ('08').VALUE     := TO_DATE(rec_vat.DUEDATE,systemnums.C_DATE_FORMAT);

                                  --03  SECACCOUNT
                                  l_txmsg.txfields ('03').defname   := 'SECACCOUNT';
                                  l_txmsg.txfields ('03').TYPE      := 'C';
                                  l_txmsg.txfields ('03').VALUE     := rec_vat.ACCTNO;

                                  --90  CUSTNAME
                                  l_txmsg.txfields ('90').defname   := 'CUSTNAME';
                                  l_txmsg.txfields ('90').TYPE      := 'C';
                                  l_txmsg.txfields ('90').VALUE     := rec_vat.FULLNAME;

                                  --91  ADDRESS
                                  l_txmsg.txfields ('91').defname   := 'ADDRESS';
                                  l_txmsg.txfields ('91').TYPE      := 'C';
                                  l_txmsg.txfields ('91').VALUE     := rec_vat.ADDRESS;

                                  --92  LICENSE
                                  l_txmsg.txfields ('92').defname   := 'LICENSE';
                                  l_txmsg.txfields ('92').TYPE      := 'C';
                                  l_txmsg.txfields ('92').VALUE     := rec_vat.LICENSE;

                                  --93  BANKACCTNO
                                  l_txmsg.txfields ('93').defname   := 'BANKACCTNO';
                                  l_txmsg.txfields ('93').TYPE      := 'C';
                                  l_txmsg.txfields ('93').VALUE     := rec_vat.BANKACCTNO;

                                  --05  DESACCTNO
                                  l_txmsg.txfields ('05').defname   := 'DESACCTNO';
                                  l_txmsg.txfields ('05').TYPE      := 'C';
                                  l_txmsg.txfields ('05').VALUE     := v_DESACCTNO_tax;

                                  --07  DESACCTNAME
                                  l_txmsg.txfields ('07').defname   := 'DESACCTNAME';
                                  l_txmsg.txfields ('07').TYPE      := 'C';
                                  l_txmsg.txfields ('07').VALUE     := v_DESACCTNAME_tax;

                                  --94  BANKNAME
                                  l_txmsg.txfields ('94').defname   := 'BANKNAME';
                                  l_txmsg.txfields ('94').TYPE      := 'C';
                                  l_txmsg.txfields ('94').VALUE     := v_BANKNAME_tax;

                                  --95  BANKQUE
                                  l_txmsg.txfields ('95').defname   := 'BANKQUE';
                                  l_txmsg.txfields ('95').TYPE      := 'C';
                                  l_txmsg.txfields ('95').VALUE     := v_BANKCODE_tax;

                                  --10  AMOUNT
                                  l_txmsg.txfields ('10').defname   := 'AMOUNT';
                                  l_txmsg.txfields ('10').TYPE      := 'N';
                                  l_txmsg.txfields ('10').VALUE     := CEIL(rec_vat.SELLRIGHTAMT);

                                  --31  TXNUM
                                  l_txmsg.txfields ('31').defname   := 'ORGTXNUM';
                                  l_txmsg.txfields ('31').TYPE      := 'C';
                                  l_txmsg.txfields ('31').VALUE     := TRUNC(to_char(rec_vat.txdate,'DDMMRRRR') || to_char(rec_vat.DUEDATE,'DDMMRRRR') || rec_vat.ACCTNO);

                                  --30   C   DESC
                                  l_txmsg.txfields ('30').defname   := 'DESC';
                                  l_txmsg.txfields ('30').TYPE      := 'C';
                                  l_txmsg.txfields ('30').VALUE := utf8nums.c_const_TLTX_TXDESC_6682_RI || rec_vat.CUSTODYCD ||' ' || utf8nums.c_const_TLTX_TXDESC_6663_date || TO_DATE(rec_vat.TXDATE,'DD/MM/RRRR');
                                  BEGIN
                                      IF txpks_#6682.fn_batchtxprocess (l_txmsg,pv_err_code,l_err_param) <> systemnums.c_success THEN
                                         ROLLBACK TO begin_cash_settlement;
                                         v_errcheck := TRUE;
                                         EXIT;
                                      END IF;
                                  END;
                              END IF;
                          END IF;
                       END IF;
                    END IF;
                    EXIT WHEN v_errcheck = TRUE;
                 END LOOP;
              --Hoan ung truoc lenh ban
              FOR rec_adv IN (
                  SELECT MST.AUTOID,MST.ACCTNO,MST.ISMORTAGE,MST.AMT - MST.PAIDAMT AMT ,MST.FEEAMT FEEAMT, MST.VATAMT, TO_CHAR(MST.TXDATE,'DD/MM/YYYY') TXDATE,
                         MST.RRTYPE, MST.CIACCTNO, MST.CUSTBANK, MST.ODDATE, MST.PAIDDATE,
                         decode(MST.RRTYPE, 'O', 1,0) CIDRAWNDOWN,
                         decode(MST.RRTYPE, 'B', 1,0) BANKDRAWNDOWN,
                         decode(MST.RRTYPE, 'C', 1,0) CMPDRAWNDOWN,
                       (UTF8NUMS.C_CONST_DESC_8851 || ', ' ||
                           UTF8NUMS.C_CONST_DESC_8851_ODDATE || ' ' ||
                           TO_CHAR(MST.TXDATE, 'DD/MM/RRRR') || ', ' ||
                           UTF8NUMS.C_CONST_DESC_8851_TXDATE || ' ' ||
                           TO_CHAR(MST.ODDATE, 'DD/MM/RRRR') || '') TXDESC
                  FROM ADSCHD MST
                  WHERE STATUS='N'
                    AND DELTD <> 'Y'
                    AND CLEARDT<= l_currdate
                    AND MST.ACCTNO = pv_acctno
                    AND NOT EXISTS --Ngay 23/08/2022 NamTv loai tru hoan ung trai phieu
                    (
                        SELECT AD.TXNUM,AD.TXDATE
                        FROM ADSCHDDTL AD, VW_ODMAST_ALL OD, SBSECURITIES SB
                        WHERE AD.ORDERID=OD.ORDERID AND OD.CODEID=SB.CODEID
                            AND MST.TXDATE=AD.TXDATE AND MST.TXNUM=AD.TXNUM
                            AND ((SB.SECTYPE IN ('003','006','012') and pv_cleartype = '1') or (SB.SECTYPE NOT IN ('003','006','012') and pv_cleartype = '2')) --TTBT T+1.5 TP: cleartype = 1 la CP, = 2 la TP
                    )
                  ORDER BY MST.AUTOID
                  ) LOOP
                    IF v_errcheck = FALSE THEN
                        SELECT (CASE WHEN corebank = 'Y' THEN 1 ELSE 0 END) INTO l_ISCOREBANK FROM cimast WHERE acctno = rec_adv.acctno;
                        --Set txnum
                        plog.debug(pkgctx, 'Loop for autoid:' || rec_adv.AUTOID);
                        SELECT systemnums.C_BATCH_PREFIXED
                                         || LPAD (seq_BATCHTXNUM.NEXTVAL, 8, '0')
                                  INTO l_txmsg.txnum
                                  FROM DUAL;
                        l_txmsg.brid        := substr(rec_adv.ACCTNO,1,4);
                        l_txmsg.tltxcd      := '8851';
                        --Set cac field giao dich

                        --09   STAUTOID     N
                        l_txmsg.txfields ('09').defname   := 'STAUTOID';
                        l_txmsg.txfields ('09').TYPE      := 'N';
                        l_txmsg.txfields ('09').VALUE     := rec_adv.AUTOID;

                        --03   ACCTNO       C
                        l_txmsg.txfields ('03').defname   := 'ACCTNO';
                        l_txmsg.txfields ('03').TYPE      := 'C';
                        l_txmsg.txfields ('03').VALUE     := rec_adv.ACCTNO;

                        --10   PAIDAMT      N
                        l_txmsg.txfields ('10').defname   := 'PAIDAMT';
                        l_txmsg.txfields ('10').TYPE      := 'N';
                        l_txmsg.txfields ('10').VALUE     := round(rec_adv.AMT,0);
                        --11   PAIDFEEAMT   N
                        l_txmsg.txfields ('11').defname   := 'PAIDFEEAMT';
                        l_txmsg.txfields ('11').TYPE      := 'N';
                        l_txmsg.txfields ('11').VALUE     := round(rec_adv.FEEAMT,0);
                        --12   N   FEEAMT
                        l_txmsg.txfields ('12').defname   := 'FEEAMT';
                        l_txmsg.txfields ('12').TYPE      := 'N';
                        l_txmsg.txfields ('12').VALUE     := 0;

                        --30   C   DESC
                        l_txmsg.txfields ('30').defname   := 'DESC';
                        l_txmsg.txfields ('30').TYPE      := 'C';
                        l_txmsg.txfields ('30').VALUE     := rec_adv.txdesc ;

                        --60   N   ISMORTAGE
                        l_txmsg.txfields ('60').defname   := 'ISMORTAGE';
                        l_txmsg.txfields ('60').TYPE      := 'N';
                        l_txmsg.txfields ('60').VALUE     := rec_adv.ISMORTAGE;

                        --44   C   RRTYPE
                        l_txmsg.txfields ('44').defname   := 'RRTYPE';
                        l_txmsg.txfields ('44').TYPE      := 'C';
                        l_txmsg.txfields ('44').VALUE     := rec_adv.RRTYPE;

                        --04   C   CIACCTNO
                        l_txmsg.txfields ('04').defname   := 'CIACCTNO';
                        l_txmsg.txfields ('04').TYPE      := 'C';
                        l_txmsg.txfields ('04').VALUE     := rec_adv.CIACCTNO;

                        --05   C   CUSTBANK
                        l_txmsg.txfields ('05').defname   := 'CUSTBANK';
                        l_txmsg.txfields ('05').TYPE      := 'C';
                        l_txmsg.txfields ('05').VALUE     := rec_adv.CUSTBANK;

                        --94   N   ISCOREBANK
                        l_txmsg.txfields ('94').defname   := 'ISMORTAGE';
                        l_txmsg.txfields ('94').TYPE      := 'N';
                        l_txmsg.txfields ('94').VALUE     := l_ISCOREBANK; --1: la tai khoan corebank; 0: la tai khoan tai CTchung khoan

                        --96   C   CIDRAWNDOWN
                        l_txmsg.txfields ('96').defname   := 'CIDRAWNDOWN';
                        l_txmsg.txfields ('96').TYPE      := 'C';
                        l_txmsg.txfields ('96').VALUE     := rec_adv.CIDRAWNDOWN;

                        --97   C   BANKDRAWNDOWN
                        l_txmsg.txfields ('97').defname   := 'BANKDRAWNDOWN';
                        l_txmsg.txfields ('97').TYPE      := 'C';
                        l_txmsg.txfields ('97').VALUE     := rec_adv.BANKDRAWNDOWN;

                        --98   C   CMPDRAWNDOWN
                        l_txmsg.txfields ('98').defname   := 'CMPDRAWNDOWN';
                        l_txmsg.txfields ('98').TYPE      := 'C';
                        l_txmsg.txfields ('98').VALUE     := rec_adv.CMPDRAWNDOWN;

                        /*--99   C   ALLORONE         hoan ung 1 lenh hoac all
                        l_txmsg.txfields ('99').defname   := 'ALLORONE';
                        l_txmsg.txfields ('99').TYPE      := 'C';
                        l_txmsg.txfields ('99').VALUE     := 'ALL';*/

                        BEGIN
                            IF txpks_#8851.fn_batchtxprocess (l_txmsg,pv_err_code,l_err_param) <> systemnums.c_success THEN
                                 ROLLBACK TO begin_cash_settlement;
                                 v_errcheck := TRUE;
                                 EXIT;
                            END IF;
                        END;
                        IF l_ISCOREBANK =1 THEN
                            BEGIN
                                PCK_AUTO_SETTLEMENT.PR_RMSPAIDADV(l_txmsg.batchname,rec_adv.ACCTNO,pv_cleartype,pv_err_code);
                              IF pv_err_code <> systemnums.c_success THEN
                                 ROLLBACK TO begin_cash_settlement;
                                 v_errcheck := TRUE;
                                 EXIT;
                              END IF;
                            END;
                        END IF;
                    END IF;
                    EXIT WHEN v_errcheck = TRUE;
                 END LOOP;
             END IF; --TTBT T+1.5 TP: Them xu ly deadlock

          -- danh dau ts
           /*IF fn_markedafpralloc(pv_acctno,
                                null,
                                'A',
                                'M',
                                null,
                                'N',
                                'N',
                                l_currdate,
                                '',
                                pv_err_code) <> systemnums.C_SUCCESS then
                    NULL;
           END IF;*/

          pv_err_code := NVL(pv_err_code,0);
          --log xu ly
          INSERT INTO odcfclearing_log (autoid,afacctno,key_id,router_id,function_id,log_date,status,error_code,isauto,cleartype)
               VALUES(seq_odcfclearing_log.nextval,pv_acctno,pv_autoid, pv_routerid,'RCVCASHTIME',l_currdate,decode(NVL(pv_err_code,0),0,'C','E'),decode(NVL(pv_err_code,0),0,'',pv_err_code||':'||l_err_param||'- GD: '||l_txmsg.tltxcd),pv_isauto,pv_cleartype); --TTBT T+1.5 TP: them pv_cleartype
          pr_lockaccount(pv_acctno,'N','RM',pv_cleartype,pv_err_code); --TTBT T+1.5 TP: Them xu ly deadlock
        COMMIT;
      EXCEPTION
        WHEN OTHERS THEN
          plog.error(pkgctx, 'Error On ' || pv_acctno||', cleartype= '||pv_cleartype||': '||SQLERRM || dbms_utility.format_error_backtrace);
          ROLLBACK TO begin_cash_settlement;

          INSERT INTO odcfclearing_log (autoid,afacctno,key_id,router_id,function_id,log_date,status,error_code,isauto, cleartype)
               VALUES(seq_odcfclearing_log.nextval,pv_acctno,pv_autoid, pv_routerid,'RCVCASHTIME',l_currdate,'E','EXCEPTION '|| pv_acctno,pv_isauto,pv_cleartype); --TTBT T+1.5 TP: them pv_cleartype
          pr_lockaccount(pv_acctno,'N','RM',pv_cleartype,pv_err_code); --TTBT T+1.5 TP: Them xu ly deadlock
          COMMIT;
      END;

  plog.error(pkgctx, 'End pr_process_settlement_sellautoid=' ||pv_autoid||'  mod=' || pv_routerid ||', cleartype= '||pv_cleartype);
  plog.setEndSection(pkgctx, 'pr_process_settlement_sell');
EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    INSERT INTO odcfclearing_log (autoid,afacctno,key_id,router_id,function_id,log_date,status,error_code,isauto,cleartype)
               VALUES(seq_odcfclearing_log.nextval,pv_acctno,pv_autoid, pv_routerid,'RCVSECTIME',l_currdate,'E','EXCEPTION '|| pv_acctno,pv_isauto,pv_cleartype);--TTBT T+1.5 TP: them pv_cleartype
    pr_lockaccount(pv_acctno,'N','RM',pv_cleartype,pv_err_code); --TTBT T+1.5 TP: Them xu ly deadlock
    COMMIT;
    plog.error(pkgctx, 'End pr_process_settlement_sell autoid=' ||pv_autoid||'  mod=' || pv_routerid ||', cleartype= '||pv_cleartype || ' With Error ');
    plog.error(pkgctx, SQLERRM || dbms_utility.format_error_backtrace);
    plog.setEndSection(pkgctx, 'pr_process_settlement_sell');
END;

-- sinh sms/email
PROCEDURE pr_create_send_smsemail(pv_actinon    VARCHAR2, -- B - Star, K - Ket thuc , E - error, M - thong bao action manual
                                  p_mod         NUMBER,
                                  p_error       VARCHAR2 DEFAULT '',
                                  p_cleartype    varchar2 default '1' --Loai TTBT 1: Co phieu, 2: Trai phieu --TTBT T+1.5 TP
                                  )
IS
l_currdate       VARCHAR2(10);
l_currTime       VARCHAR2(10);
l_sms            VARCHAR2(2000);
l_datasource     varchar2(2000);
l_cleartype      varchar2(100); --TTBT T+1.5 TP
l_t              varchar2(10);
BEGIN
  plog.setBeginSection(pkgctx, 'pr_create_send_smsemail');
  plog.error(pkgctx, 'Begin pr_create_send_smsemail action=' || pv_actinon||', p_cleartype='||p_cleartype||', p_mod='||p_mod);
  -- Chuan bi than so
  l_sms       := cspks_system.fn_get_sysvar('SYSTEM','CLEARINGNOTIFY_SMS');
  l_currdate  := cspks_system.fn_get_sysvar('SYSTEM','CURRDATE');
  l_currTime  := TO_CHAR(SYSDATE,'hh24:mi:ss');

  --TTBT T+1.5 TP
  if p_cleartype = '1' then
    l_cleartype := '(Chung khoan, CCQ, CW)';
    l_t := 'T+1.5';
  elsif p_cleartype = '2' then
    l_cleartype := '(Trai phieu)';
    l_t := 'T+1';
  elsif p_cleartype = '-1' then
    l_cleartype := '';
    l_t := '';
  else
    l_cleartype := '(Khac)';
    l_t := '';
  end if;
  --End TTBT T+1.5 TP

  IF pv_actinon ='B' THEN
    -- send sms/email thanh toan bu tru - bat dau
    l_datasource := 'select ''Bat dau tien trinh thanh toan bu tru '||l_t||' '||l_cleartype||' luc '|| l_currTime ||' ngay '|| l_currdate ||'. So tien trinh xu ly: '|| p_mod ||'.'' detail from dual';
    /*INSERT INTO emaillog (AUTOID,EMAIL,TEMPLATEID,DATASOURCE,STATUS,CREATETIME)
        VALUES(seq_emaillog.nextval,l_sms,'0666' ,'select ''Bat dau tien trinh thanh toan bu tru T + 1.5 luc '|| l_currTime ||' ngay '|| l_currdate ||'. So tien trinh xu ly: '|| p_mod ||'.'' detail from dual'  , 'A', sysdate);*/

    INSERT INTO log_email_clearing (autoid,email,datasource,sentdate,senttime,cleartype)
     VALUES ( seq_log_email_clearing.nextval,l_sms,'Bat dau '||p_mod|| ' tien trinh TTBT '||l_t||' '||l_cleartype||' ',l_currdate,l_currTime,p_cleartype);

  ELSIF pv_actinon ='K' THEN
      -- send sms/email thanh toan bu tru - ket thuc
    l_datasource := 'select ''Ket thuc tien trinh thu '|| p_mod ||' thanh toan bu tru '||l_t||' '||l_cleartype||' luc '|| l_currTime ||' ngay '|| l_currdate||''' detail from dual';
    /*INSERT INTO emaillog (AUTOID,EMAIL,TEMPLATEID,DATASOURCE,STATUS,CREATETIME)
        VALUES(seq_emaillog.nextval,l_sms,'0666' ,'select ''Ket thuc tien trinh thu '|| p_mod ||' thanh toan bu tru T + 1.5 luc '|| l_currTime ||' ngay '|| l_currdate||''' detail from dual'  , 'A', sysdate);*/

    INSERT INTO log_email_clearing (autoid,email,datasource,sentdate,senttime,cleartype)
     VALUES ( seq_log_email_clearing.nextval,l_sms,'Ket thuc TTBT '||l_t||' '||l_cleartype||' - tien trinh thu '||p_mod||'',l_currdate,l_currTime,p_cleartype);

  ELSIF pv_actinon ='M' THEN
    -- send sms/email thanh toan bu tru - thanh toan manual
    l_datasource := 'select ''Thong bao da nhan duoc dien thanh toan bu tru '||l_t||' '||l_cleartype||' ngay '|| l_currdate ||'.'' detail from dual';
    /*INSERT INTO emaillog (AUTOID,EMAIL,TEMPLATEID,DATASOURCE,STATUS,CREATETIME)
        VALUES(seq_emaillog.nextval,l_sms,'0666' ,'select ''Thong bao da nhan duoc dien thanh toan bu tru T + 1.5 ngay '|| l_currdate ||'.'' detail from dual'  , 'A', sysdate);*/

    INSERT INTO log_email_clearing (autoid,email,datasource,sentdate,senttime,cleartype)
     VALUES ( seq_log_email_clearing.nextval,l_sms,'Thong bao da nhan dien TTBT '||l_t||' '||l_cleartype||'',l_currdate,l_currTime,p_cleartype);
  ELSE
    --  -- send sms/email thanh toan bu tru - stop - khong tm dieu kien thuc hien
    l_datasource := 'select ''STOP tien trinh thanh toan bu tru '||l_t||' '||l_cleartype||' luc '|| l_currTime ||' ngay '|| l_currdate ||'. Do :'|| p_error ||''' detail from dual';
    /*INSERT INTO emaillog (AUTOID,EMAIL,TEMPLATEID,DATASOURCE,STATUS,CREATETIME)
        VALUES(seq_emaillog.nextval,l_sms,'0666' ,'select ''STOP tien trinh thanh toan bu tru T + 1.5 luc '|| l_currTime ||' ngay '|| l_currdate ||'. Do :'|| p_error ||''' detail from dual'  , 'A', sysdate);*/

    INSERT INTO log_email_clearing (autoid,email,datasource,sentdate,senttime,cleartype)
     VALUES ( seq_log_email_clearing.nextval,l_sms,'STOP tien trinh TTBT '||l_t||' '||l_cleartype||'. Do '|| p_error ||'',l_currdate,l_currTime,p_cleartype);
  END IF;

  FOR MOBILE IN (
                            SELECT REGEXP_SUBSTR (l_sms,
                                             '[^,]+',
                                             1,
                                             LEVEL)
                                 TXT
                            FROM DUAL
                            CONNECT BY REGEXP_SUBSTR (l_sms,
                                             '[^,]+',
                                             1,
                                             LEVEL)
                                 IS NOT NULL)
    LOOP
      INSERT INTO emaillog (AUTOID,EMAIL,TEMPLATEID,DATASOURCE,STATUS,CREATETIME)
            VALUES(seq_emaillog.nextval,trim(MOBILE.TXT),'0666' ,l_datasource  , 'A', sysdate);
    END LOOP;


  plog.error(pkgctx, 'End pr_create_send_smsemail mod=' || p_mod);
  plog.setEndSection(pkgctx, 'pr_create_send_smsemail');
EXCEPTION
  WHEN OTHERS THEN
    plog.error(pkgctx, 'End pr_create_send_smsemail action=' || pv_actinon ||' With Error ');
    plog.error(pkgctx, SQLERRM || dbms_utility.format_error_backtrace);
    plog.setEndSection(pkgctx, 'pr_create_send_smsemail');
END;
-- Danh sach thanh toan bu tru t+1.5 - gom cac tk chua thanh toan va thanh toan loi
PROCEDURE pr_get_listClearingT15 (p_refcursor in out pkg_report.ref_cursor,
                                  p_custodycd VARCHAR2,
                                  p_afacctno  VARCHAR2,
                                  p_status    VARCHAR2,
                                  p_cleartype    varchar2 default '1' --TTBT T+1.5 TP: Loai TTBT 1: Co phieu, 2: Trai phieu --TTBT T+1.5 TP
                                  )
IS
  v_custodycd  VARCHAR2(20);
  v_afacctno   VARCHAR2(10);
  v_status     VARCHAR2(10);
  v_currdate    date;
BEGIN
    plog.setendsection(pkgctx, 'pr_get_listClearingT15');

    IF upper(p_custodycd) = 'ALL' OR p_custodycd IS NULL THEN
       v_custodycd := '%';
    ELSE
       v_custodycd := p_custodycd||'%';
    END IF;

    IF upper(p_afacctno) = 'ALL' OR p_afacctno IS NULL THEN
       v_afacctno := '%';
    ELSE
       v_afacctno := p_afacctno;
    END IF;

    IF upper(p_status) = 'ALL' OR p_status IS NULL THEN
       v_status := '%';
    ELSE
       v_status := p_status;
    END IF;
    v_currdate  := getcurrdate;
    OPEN p_refcursor FOR
      SELECT row_number() over (order by od.status,cf.custodycd, af.acctno) STT, cf.custodycd, af.acctno, odtemp.clearday,
             --CASE WHEN od.function_id =  'RCVSECTIME' THEN 'Mua' ELSE 'B? END functionid,
             CASE WHEN odtemp.isbuy =  'Y' THEN 'Mua' ELSE 'Ban' END functionid,
             NVL(od.status,odtemp.status) status,a.cdcontent statusname,
             CASE WHEN od.status = 'C' THEN '' ELSE od.error_code END error_code, nvl(od.key_id,odtemp.autoid) autoid, odtemp.router_id routerid
        FROM odcfclearing_tmp odtemp,afmast af, cfmast cf, allcode a,
             (SELECT afacctno,function_id,key_id, MIN(status) status, MAX(error_code) error_code FROM odcfclearing_log
               WHERE log_date = v_currdate GROUP BY afacctno,function_id,key_id) od
       WHERE odtemp.autoid = od.key_id(+)
         AND odtemp.afacctno = af.acctno
         AND odtemp.custid = cf.custid
         AND NVL(od.status,odtemp.status) = a.cdval
         AND a.cdname ='ODCLSTATUS'
         AND a.cdtype ='OD'
         AND NVL(od.status,odtemp.status) LIKE v_status
         AND cf.custodycd LIKE v_custodycd
         AND af.acctno LIKE v_afacctno
         and odtemp.cleartype = p_cleartype --TTBT T+1.5 TP them p_cleartype
       ;
    plog.setendsection(pkgctx, 'pr_get_listClearingT15');
EXCEPTION
WHEN OTHERS
THEN
  plog.error (pkgctx, SQLERRM || dbms_utility.format_error_backtrace);
  plog.setendsection (pkgctx, 'pr_get_listClearingT15');
  return;
END pr_get_listClearingT15;

-- thong tin monitor
PROCEDURE pr_get_MonitorDetail (p_refcursor in out pkg_report.ref_cursor,
                                p_currdate VARCHAR2,
                                p_cleartype    varchar2 default '1' --TTBT T+1.5 TP: Loai TTBT 1: Co phieu, 2: Trai phieu --TTBT T+1.5 TP
                                )
IS
l_currdate       DATE;
l_page_size      NUMBER := 3;
l_beginTime      VARCHAR2(10);
l_endTime        VARCHAR2(10);
l_currTime       NUMBER;
l_clearauto      VARCHAR2(1);
l_clearautoname  VARCHAR2(10);
v_success_sell   NUMBER;
v_error_sell     NUMBER;
v_success_buy    NUMBER;
v_error_buy      NUMBER;
v_totalcf        NUMBER;
v_totalcf_sucess NUMBER;
v_isrun          VARCHAR2(1);
BEGIN
    plog.setendsection(pkgctx, 'pr_get_MonitorDetail');

    l_currdate  := TO_DATE(p_currdate, systemnums.C_DATE_FORMAT);
    l_currTime  := to_number(to_char(SYSDATE,'hh24miss'));
    --TTBT T+1.5 TP
    if p_cleartype = '2' then
        -- thoi gian bat dau
        l_beginTime := cspks_system.fn_get_sysvar('SYSTEM','BONDCLEARINGSTARTTIME');
        -- thoi gian ket thuc
        l_endTime   := cspks_system.fn_get_sysvar('SYSTEM','BONDCLEARINGENDTIME');
        -- co chay tu dong hay khong
        l_clearauto := upper(cspks_system.fn_get_sysvar('SYSTEM','BONDCLEARINGAUTO'));
    else
        -- thoi gian bat dau
        l_beginTime := cspks_system.fn_get_sysvar('SYSTEM','CLEARINGSTARTTIME');
        -- thoi gian ket thuc
        l_endTime   := cspks_system.fn_get_sysvar('SYSTEM','CLEARINGENDTIME');
        -- co chay tu dong hay khong
        l_clearauto := upper(cspks_system.fn_get_sysvar('SYSTEM','CLEARINGAUTO'));
    end if;
    --End TTBT T+1.5 TP
    SELECT cdcontent INTO l_clearautoname FROM allcode a WHERE cdname='ISCLEARAUTO' AND cdval=l_clearauto;
    -- tien trinh dang chay hay k
    SELECT  count(DISTINCT ROUTER_ID) INTO v_isrun FROM odcfclearing_check
    WHERE status='P'
        and cleartype = p_cleartype --TTBT T+1.5 TP them p_cleartype
        ;
    -- so tien trinh chay
    l_page_size := cspks_system.fn_get_sysvar('SYSTEM','JOBAUTOSETTLEMENT');

    -- tong so tk xu ly
    SELECT COUNT(*) INTO v_totalcf
    FROM (SELECT distinct af.custid, sts.afacctno, cleardate, sts.duetype
            FROM stschd sts, afmast af, sbsecurities sb, cfmast cf
           WHERE sts.afacctno = af.acctno
             AND sts.codeid = sb.codeid
             and af.custid = cf.custid
             AND ((sb.sectype NOT IN ('003','006','012') and p_cleartype = '1') or (sb.sectype IN ('003','006','012') and p_cleartype = '2')) --TTBT T+1.5 TP them p_cleartype
             AND sts.cleardate = l_currdate
             AND sts.duetype IN ('RS','RM')
             AND sts.deltd <> 'Y'
             AND CF.custatcom = 'Y'
             );

    -- tong so tk da xu ly thanh cong
    SELECT COUNT(*) INTO v_totalcf_sucess
    FROM (SELECT DISTINCT afacctno,function_id FROM odcfclearing_log
            WHERE log_date = l_currdate
                and cleartype = p_cleartype --TTBT T+1.5 TP them p_cleartype
        );

    -- mua - thanh cong
    SELECT COUNT(*) INTO v_success_buy
    FROM ( SELECT afacctno,function_id, MIN(status) status FROM odcfclearing_log
            WHERE log_date = l_currdate
                and cleartype = p_cleartype --TTBT T+1.5 TP them p_cleartype
            GROUP BY afacctno,function_id)
    WHERE status ='C' AND function_id='RCVSECTIME';
    -- ban - thanh cong
    SELECT COUNT(*) INTO v_success_sell
    FROM ( SELECT afacctno,function_id, MIN(status) status FROM odcfclearing_log
            WHERE log_date = l_currdate
                and cleartype = p_cleartype --TTBT T+1.5 TP them p_cleartype
            GROUP BY afacctno,function_id)
    WHERE status ='C' AND function_id='RCVCASHTIME';
    -- mua - loi
    SELECT COUNT(*) INTO v_error_buy
    FROM ( SELECT afacctno,function_id, MIN(status) status FROM odcfclearing_log
            WHERE log_date = l_currdate
                and cleartype = p_cleartype --TTBT T+1.5 TP them p_cleartype
            GROUP BY afacctno,function_id)
    WHERE status ='E' AND function_id='RCVSECTIME';
    -- ban loi
    SELECT COUNT(*) INTO v_error_sell
    FROM ( SELECT afacctno,function_id, MIN(status) status FROM odcfclearing_log
            WHERE log_date = l_currdate
                and cleartype = p_cleartype --TTBT T+1.5 TP them p_cleartype
            GROUP BY afacctno,function_id)
    WHERE status ='E' AND function_id='RCVCASHTIME';

    OPEN p_refcursor FOR
         SELECT v_isrun isrun,l_page_size processnumber,
                l_clearauto isauto,l_clearautoname isautoname, l_beginTime ||' - '|| l_endTime processtime,
                v_totalcf totalcf, v_totalcf_sucess totalsucess,
                v_success_buy successbuy ,v_success_sell successsell,
                v_error_buy errorbuy, v_error_sell errorsell,
                l_currdate currdate, l_currTime currTime, to_number(REPLACE(l_beginTime,':',''))  beginTime, to_number(REPLACE(l_endTime,':','')) endTime
           FROM dual
       ;
    plog.setendsection(pkgctx, 'pr_get_MonitorDetail');
EXCEPTION
WHEN OTHERS
THEN
  plog.error (pkgctx, SQLERRM || dbms_utility.format_error_backtrace);
  plog.setendsection (pkgctx, 'pr_get_MonitorDetail');
  return;
END pr_get_MonitorDetail;

-- thong tin gui email/sms canh bao
PROCEDURE pr_get_EMS_ClearingT15 (p_refcursor in out pkg_report.ref_cursor,
                                  p_currdate VARCHAR2,
                                  p_cleartype    varchar2 default '1' --TTBT T+1.5 TP Loai TTBT 1: Co phieu, 2: Trai phieu --TTBT T+1.5 TP
                                  )
IS
BEGIN
    plog.setendsection(pkgctx, 'pr_get_EMS_ClearingT15');

    OPEN p_refcursor FOR
        SELECT senttime, email, datasource
          FROM log_email_clearing
         WHERE sentdate = p_currdate
            and (case when cleartype not in ('1','2') then p_cleartype else cleartype end) = p_cleartype --TTBT T+1.5 TP them p_cleartype
         ORDER BY create_time ;
    plog.setendsection(pkgctx, 'pr_get_EMS_ClearingT15');
EXCEPTION
WHEN OTHERS
THEN
  plog.error (pkgctx, SQLERRM || dbms_utility.format_error_backtrace);
  plog.setendsection (pkgctx, 'pr_get_EMS_ClearingT15');
  return;
END pr_get_EMS_ClearingT15;

PROCEDURE PR_RMSPAIDADV(P_BCHMDL VARCHAR,p_afacctno varchar2, p_cleartype varchar2, P_ERR_CODE OUT VARCHAR2) IS --TTBT T+1.5 TP them p_cleartype

    L_TXMSG      TX.MSG_RECTYPE;
    L_CURRDATE   VARCHAR2(20);
    L_DESC       VARCHAR2(1000);
    L_EN_DESC    VARCHAR2(1000);
    L_ORGDESC    VARCHAR2(1000);
    L_EN_ORGDESC VARCHAR2(1000);
    L_ERR_PARAM  VARCHAR2(300);
    L_TLTX       VARCHAR2(4);
    L_BEGINDATE  VARCHAR2(10);
    L_ORGTXNUM   VARCHAR2(100);
    L_ORGDATE    VARCHAR2(10);
    L_ORGREQID   NUMBER(20, 0);

  BEGIN
    PLOG.SETBEGINSECTION(PKGCTX, 'pr_rmSPAIDADV');
    L_TLTX := '6667';

    --SELECT VARVALUE INTO l_begindate
    --FROM SYSVAR WHERE VARNAME='SYSTEMSTARTDATE';

    SELECT TXDESC, EN_TXDESC
      INTO L_ORGDESC, L_EN_ORGDESC
      FROM TLTX
     WHERE TLTXCD = L_TLTX;
    SELECT TO_DATE(VARVALUE, SYSTEMNUMS.C_DATE_FORMAT)
      INTO L_CURRDATE
      FROM SYSVAR
     WHERE GRNAME = 'SYSTEM'
       AND VARNAME = 'CURRDATE';
    L_BEGINDATE     := L_CURRDATE;
    L_TXMSG.MSGTYPE := 'T';
    L_TXMSG.LOCAL   := 'N';
    L_TXMSG.TLID    := SYSTEMNUMS.C_SYSTEM_USERID;
    PLOG.DEBUG(PKGCTX, 'l_txmsg.tlid' || L_TXMSG.TLID);
    SELECT SYS_CONTEXT('USERENV', 'HOST'),
           SYS_CONTEXT('USERENV', 'IP_ADDRESS', 15)
      INTO L_TXMSG.WSNAME, L_TXMSG.IPADDRESS
      FROM DUAL;
    L_TXMSG.OFF_LINE  := 'N';
    L_TXMSG.DELTD     := TXNUMS.C_DELTD_TXNORMAL;
    L_TXMSG.TXSTATUS  := TXSTATUSNUMS.C_TXCOMPLETED;
    L_TXMSG.MSGSTS    := '0';
    L_TXMSG.OVRSTS    := '0';
    L_TXMSG.BATCHNAME := P_BCHMDL;
    L_TXMSG.TXDATE    := TO_DATE(L_CURRDATE, SYSTEMNUMS.C_DATE_FORMAT);
    L_TXMSG.BUSDATE   := TO_DATE(L_CURRDATE, SYSTEMNUMS.C_DATE_FORMAT);
    L_TXMSG.TLTXCD    := L_TLTX;

    PLOG.DEBUG(PKGCTX, 'Begin loop');
    --TRFADPAID
    FOR REC IN (SELECT OD.CLEARDATE DUEDATE,
                       CRA.TRFCODE TRFTYPE,
                       OD.AFACCTNO,
                       CF.CUSTODYCD,
                       CF.FULLNAME,
                       CF.ADDRESS,
                       CF.IDCODE LICENSE,
                       AF.BANKACCTNO,
                       CRB.BANKCODE,
                       CRB.BANKCODE || ':' || CRB.BANKNAME BANKNAME,
                       CRA.REFACCTNO DESACCTNO,
                       CRA.REFACCTNAME DESACCTNAME,
                       CEIL(OD.AAMT) AMOUNT
                  FROM (SELECT OD.AFACCTNO,
                               TO_CHAR(OD.CLEARDATE, 'DD/MM/RRRR') CLEARDATE,
                               SUM(NVL(AD.AAMT, 0)) AAMT
                          FROM (SELECT OD.*, STS.CLEARDATE
                                  FROM STSCHD STS, ODMAST OD, sbsecurities sb
                                 WHERE OD.ORDERID = STS.ORGORDERID
                                   AND STS.CLEARDATE =
                                       TO_DATE(L_BEGINDATE, 'DD/MM/RRRR')
                                   AND STS.DUETYPE = 'RM'
                                   AND STS.DELTD <> 'Y'
                                   AND OD.EXECAMT > 0
                                   AND STS.STATUS = 'C'
                                   and od.codeid = sb.codeid
                                   and ((sb.tradeplace not in ('003','006','012') and p_cleartype = '1') or (sb.tradeplace in ('003','006','012') and p_cleartype = '2')) --TTBT T+1.5 TP them p_cleartype
                               ) OD,
                               (SELECT DTL.ORDERID, SUM(AAMT) AAMT
                                  FROM ADSCHD AD, ADSCHDDTL DTL
                                 WHERE AD.TXNUM = DTL.TXNUM
                                   AND AD.TXDATE = DTL.TXDATE
                                   AND AD.DELTD <> 'Y'
                                   AND DTL.DELTD <> 'Y'
                                 GROUP BY DTL.ORDERID) AD
                         WHERE OD.ORDERID = AD.ORDERID(+)
                         GROUP BY OD.AFACCTNO, OD.CLEARDATE) OD,
                       AFMAST AF,
                       CFMAST CF,
                       CIMAST CI,
                       CRBDEFACCT CRA,
                       CRBDEFBANK CRB
                 WHERE OD.AFACCTNO = AF.ACCTNO
                   AND AF.CUSTID = CF.CUSTID
                   AND AF.BANKNAME = CRB.BANKCODE
                   AND AF.BANKNAME = CRA.REFBANK
                   AND CRA.TRFCODE = 'TRFAUTOADPAID'
                   AND AF.ACCTNO = CI.AFACCTNO
                   AND CI.COREBANK = 'Y'
                   AND OD.AAMT > 0
                   AND AF.ACCTNO = p_afacctno
                   AND NOT EXISTS
                 ( --Loai bo nhung ban ke cua ngay hom nay va nhung ban ke thanh cong cua cac ngay hom truoc
                        SELECT REQ.REFCODE
                          FROM CRBTXREQ REQ
                         WHERE REQ.TRFCODE = 'TRFAUTOADPAID'
                           AND REQ.OBJNAME = '6667'
                           AND (REQ.TXDATE = TO_DATE(L_CURRDATE, 'DD/MM/RRRR') OR
                               (REQ.STATUS NOT IN ('E') AND
                               REQ.TXDATE <
                               TO_DATE(L_CURRDATE, 'DD/MM/RRRR')))
                           AND REQ.REFCODE = OD.CLEARDATE || OD.AFACCTNO)

                ) LOOP
      -- rec
      PLOG.DEBUG(PKGCTX, 'Loop for account : ' || REC.AFACCTNO);

      --Neu la order cua ngay hom truoc,
      --thi phai revert lai giao dich CI truoc do
      /*IF rec.TXDATE<TO_DATE(l_CURRDATE,systemnums.C_DATE_FORMAT) THEN
       BEGIN
           SELECT REQID,OBJKEY,TO_CHAR(TXDATE,'DD/MM/RRRR')
           INTO l_orgreqid,l_orgtxnum,l_orgdate
           FROM CRBTXREQ
           WHERE REFCODE=rec.ORDERID AND TRFCODE=rec.TRFTYPE AND STATUS IN ('E');

           cspks_rmproc.pr_RollbackCITRAN(l_orgtxnum,l_orgdate,p_err_code);

           UPDATE CRBTXREQ SET STATUS='D' WHERE REQID=l_orgreqid;
       EXCEPTION
           WHEN NO_DATA_FOUND THEN
               plog.error(pkgctx, 'Khong tim thay yeu cau tuong ung trong CRBTXREQ');
               --RAISE errnums.E_SYSTEM_ERROR;
           WHEN OTHERS THEN
               plog.error(pkgctx, 'Co qua nhieu dong trung nhau trong CRBTXREQ');
       END;
      END IF;*/
      --set txnum
      SELECT SYSTEMNUMS.C_BATCH_PREFIXED ||
             LPAD(SEQ_BATCHTXNUM.NEXTVAL, 8, '0')
        INTO L_TXMSG.TXNUM
        FROM DUAL;
      L_TXMSG.BRID := SUBSTR(REC.AFACCTNO, 1, 4);

      --Set cac field giao dich
      --06   C   TRFTYPE
      L_TXMSG.TXFIELDS('06').DEFNAME := 'TRFTYPE';
      L_TXMSG.TXFIELDS('06').TYPE := 'C';
      L_TXMSG.TXFIELDS('06').VALUE := REC.TRFTYPE;

      --08   C   DUEDATE
      L_TXMSG.TXFIELDS('08').DEFNAME := 'DUEDATE';
      L_TXMSG.TXFIELDS('08').TYPE := 'C';
      L_TXMSG.TXFIELDS('08').VALUE := TO_DATE(REC.DUEDATE,
                                              SYSTEMNUMS.C_DATE_FORMAT);

      --03  SECACCOUNT
      L_TXMSG.TXFIELDS('03').DEFNAME := 'SECACCOUNT';
      L_TXMSG.TXFIELDS('03').TYPE := 'C';
      L_TXMSG.TXFIELDS('03').VALUE := REC.AFACCTNO;

      --90  CUSTNAME
      L_TXMSG.TXFIELDS('90').DEFNAME := 'CUSTNAME';
      L_TXMSG.TXFIELDS('90').TYPE := 'C';
      L_TXMSG.TXFIELDS('90').VALUE := REC.FULLNAME;

      --91  ADDRESS
      L_TXMSG.TXFIELDS('91').DEFNAME := 'ADDRESS';
      L_TXMSG.TXFIELDS('91').TYPE := 'C';
      L_TXMSG.TXFIELDS('91').VALUE := REC.ADDRESS;

      --92  LICENSE
      L_TXMSG.TXFIELDS('92').DEFNAME := 'LICENSE';
      L_TXMSG.TXFIELDS('92').TYPE := 'C';
      L_TXMSG.TXFIELDS('92').VALUE := REC.LICENSE;

      --93  BANKACCTNO
      L_TXMSG.TXFIELDS('93').DEFNAME := 'BANKACCTNO';
      L_TXMSG.TXFIELDS('93').TYPE := 'C';
      L_TXMSG.TXFIELDS('93').VALUE := REC.BANKACCTNO;

      --05  DESACCTNO
      L_TXMSG.TXFIELDS('05').DEFNAME := 'DESACCTNO';
      L_TXMSG.TXFIELDS('05').TYPE := 'C';
      L_TXMSG.TXFIELDS('05').VALUE := REC.DESACCTNO;

      --07  DESACCTNAME
      L_TXMSG.TXFIELDS('07').DEFNAME := 'DESACCTNAME';
      L_TXMSG.TXFIELDS('07').TYPE := 'C';
      L_TXMSG.TXFIELDS('07').VALUE := REC.DESACCTNAME;

      --94  BANKNAME
      L_TXMSG.TXFIELDS('94').DEFNAME := 'BANKNAME';
      L_TXMSG.TXFIELDS('94').TYPE := 'C';
      L_TXMSG.TXFIELDS('94').VALUE := REC.BANKNAME;

      --95  BANKQUE
      L_TXMSG.TXFIELDS('95').DEFNAME := 'BANKQUE';
      L_TXMSG.TXFIELDS('95').TYPE := 'C';
      L_TXMSG.TXFIELDS('95').VALUE := REC.BANKCODE;

      --10  AMOUNT
      L_TXMSG.TXFIELDS('10').DEFNAME := 'AMOUNT';
      L_TXMSG.TXFIELDS('10').TYPE := 'N';
      L_TXMSG.TXFIELDS('10').VALUE := REC.AMOUNT;

      --04  ORDERID
      L_TXMSG.TXFIELDS('04').DEFNAME := 'ORDERID';
      L_TXMSG.TXFIELDS('04').TYPE := 'C';
      L_TXMSG.TXFIELDS('04').VALUE := REC.DUEDATE || REC.AFACCTNO;

      --11  TXNUM
      L_TXMSG.TXFIELDS('11').DEFNAME := 'TXNUM';
      L_TXMSG.TXFIELDS('11').TYPE := 'C';
      L_TXMSG.TXFIELDS('11').VALUE := REC.DUEDATE || REC.AFACCTNO;

      --30   C   DESC
      L_TXMSG.TXFIELDS('30').DEFNAME := 'DESC';
      L_TXMSG.TXFIELDS('30').TYPE := 'C';
      L_TXMSG.TXFIELDS('30').VALUE := UTF8NUMS.C_CONST_TLTX_TXDESC_6667 ||
                                      REC.CUSTODYCD ||
                                      UTF8NUMS.C_CONST_TLTX_TXDESC_6663_DATE ||
                                      REC.DUEDATE;

      BEGIN
        IF TXPKS_#6667.FN_BATCHTXPROCESS(L_TXMSG, P_ERR_CODE, L_ERR_PARAM) <>
           SYSTEMNUMS.C_SUCCESS THEN
          PLOG.DEBUG(PKGCTX, 'got error 6667: ' || P_ERR_CODE);
          ROLLBACK;
          RETURN;
        END IF;
      END;
    END LOOP; -- rec

    P_ERR_CODE := 0;
    PLOG.SETENDSECTION(PKGCTX, 'pr_rmSPAIDADV');
  EXCEPTION
    WHEN OTHERS THEN
      P_ERR_CODE := ERRNUMS.C_SYSTEM_ERROR;
      PLOG.ERROR(PKGCTX, DBMS_UTILITY.FORMAT_ERROR_BACKTRACE);
      PLOG.ERROR(PKGCTX, SQLERRM);
      PLOG.SETENDSECTION(PKGCTX, 'pr_rmSPAIDADV');
      RAISE ERRNUMS.E_SYSTEM_ERROR;
  END PR_RMSPAIDADV;
--TTBT T+1.5 TP
PROCEDURE pr_lockaccount(pv_acctno     VARCHAR2,
                         pv_actinon    VARCHAR2,
                         pv_duetype    VARCHAR2,
                         pv_cleartype   VARCHAR2,
                         p_err_code    OUT VARCHAR2)
IS
l_currdate       DATE;
l_timestemp      TIMESTAMP(6);
BEGIN
  plog.setBeginSection(pkgctx, 'pr_lockaccount');

  SELECT TO_DATE(SY.VARVALUE,'DD/MM/RRRR') INTO l_currdate FROM SYSVAR SY WHERE SY.GRNAME='SYSTEM'AND SY.VARNAME='CURRDATE';
  l_timestemp := SYSTIMESTAMP;

  IF pv_actinon ='Y' THEN
     -- lock cimast
     INSERT INTO accupdate (acctno,updatetype,createdate)
          VALUES (pv_acctno, 'CI', l_timestemp);

     -- lock semast
     INSERT INTO accupdate (acctno,updatetype,createdate)
     SELECT DISTINCT sts.acctno, 'SE', l_timestemp
       FROM stschd sts, afmast af, cfmast cf, sbsecurities sb
      WHERE sts.afacctno = af.acctno
        AND af.custid = cf.custid
        AND sts.codeid = sb.codeid
        AND ((sb.sectype NOT IN ('003','006','012') and pv_cleartype = '1') or (sb.sectype IN ('003','006','012') and pv_cleartype = '2'))
        AND sts.status = 'N'
        AND sts.deltd <> 'Y'
        AND cf.custatcom = 'Y'
        AND sts.duetype = pv_duetype
        AND sts.cleardate = l_currdate
        AND af.acctno = pv_acctno;
  ELSE
      DELETE accupdate WHERE substr(acctno,1,10) = pv_acctno AND updatetype IN ('CI','SE');
  END IF;

  plog.setEndSection(pkgctx, 'pr_lockaccount');
EXCEPTION
  WHEN OTHERS THEN
    p_err_code:='-100200';
    plog.error(pkgctx, SQLERRM || dbms_utility.format_error_backtrace);
    plog.setEndSection(pkgctx, 'pr_lockaccount');
END;
--End TTBT T+1.5 TP
begin
  FOR i IN (SELECT * FROM tlogdebug) LOOP
      logrow.loglevel  := i.loglevel;
      logrow.log4table := i.log4table;
      logrow.log4alert := i.log4alert;
      logrow.log4trace := i.log4trace;
  END LOOP;
  pkgctx := plog.init('pck_auto_settlement',
                      plevel => NVL(logrow.loglevel,30),
                      plogtable => (NVL(logrow.log4table,'Y') = 'Y'),
                      palert => (logrow.log4alert = 'Y'),
                      ptrace => (logrow.log4trace = 'Y'));
end pck_auto_settlement;
/
