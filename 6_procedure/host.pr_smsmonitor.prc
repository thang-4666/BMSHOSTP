SET DEFINE OFF;
CREATE OR REPLACE PROCEDURE pr_smsmonitor (pv_sourcename IN VARCHAR2)
   IS
  v_count NUMBER;
  v_value NUMBER;
  v_lastvalue VARCHAR2(100);
  v_string VARCHAR2(100);
  v_maxminute VARCHAR2(10);
  v_hostatus char(1);
  v_currdate varchar2(100);
  v_countBstatus number(10);
BEGIN
  SELECT varvalue INTO v_maxminute FROM sysvar WHERE varname = 'NAFTERTRANFERED';
  DELETE FROM SMSMonitorController WHERE to_date(lastdatetime,'DD/MM/YYYY') < to_date(SYSDATE,'DD/MM/YYYY');
  --------nhac chay batch
  IF pv_sourcename = 'BATCHTIME' THEN
     v_hostatus:= CSPKS_SYSTEM.fn_get_sysvar('SYSTEM','HOSTATUS');
     v_currdate:= CSPKS_SYSTEM.fn_get_sysvar('SYSTEM','CURRDATE');
     IF to_date(SYSDATE,'DD/MM/RRRR') = to_date(SYSDATE,'DD/MM/RRRR') THEN --neu ngay he thong = ngay hien tai
        SELECT COUNT(1) INTO v_count FROM sbbatchsts where bchdate = to_date(v_currdate,'DD/MM/RRRR') and trim(bchsts) = 'Y';
        SELECT COUNT(1) INTO v_value FROM SMSMonitorController WHERE sourcename = pv_sourcename;
        IF v_count = 0 AND v_value = 0 THEN
           pr_monitorsendsms('Flex monitor: Canh bao qua gio chua chay xu ly cuoi ngay!',pv_sourcename);
           INSERT INTO SMSMonitorController (sourcename, smscontent, lastdatetime, smsstatus, lastvalue)
           VALUES (pv_sourcename, 'Flex monitor: Canh bao qua gio chua chay xu ly cuoi ngay!',SYSDATE, 'Y','done');
        END IF;
     END IF;
  END IF;
  -----tat ca cac chi nhanh da dong cua
  IF pv_sourcename = 'BRINACTIVE' THEN
        pr_monitorsendsms('Flex monitor: Tat ca cac chi nhanh da dong cua!',pv_sourcename);
        INSERT INTO SMSMonitorController (sourcename, smscontent, lastdatetime, smsstatus, lastvalue)
        VALUES (pv_sourcename, 'Flex monitor: Tat ca cac chi nhanh da dong cua!',SYSDATE, 'Y','done');
  END IF;

  --------2G and 3
  IF pv_sourcename = 'HOSE2GMSG' THEN
    FOR r IN (SELECT od.orderid , od.orderqtty, sb.symbol, cf.custodycd, a.cdcontent exectype, od.FEEDBACKMSG
                     FROM odmast od, cfmast cf, sbsecurities sb, allcode a
                     WHERE ORSTATUS = '6' AND od.custid = cf.custid AND od.codeid = sb.codeid
                     AND a.cdtype = 'OD' AND a.cdname = 'EXECTYPE' AND a.cdval = od.exectype
                     AND sb.tradeplace = '001' and od.txdate = getcurrdate
                     AND orderid NOT IN (SELECT lastvalue FROM SMSMonitorController WHERE sourcename = pv_sourcename)
             )
    LOOP
       v_string := 'Flex monitor: Loi 2G TK ' || r.custodycd || ' ' || r.exectype || ' ' || r.symbol
                   || ' ' || r.orderqtty ||', ' || r.FEEDBACKMSG || '.';
       INSERT INTO SMSMonitorController (sourcename, smscontent, lastdatetime, smsstatus, lastvalue)
        VALUES (pv_sourcename, v_string,SYSDATE, 'Y',r.orderid);
        pr_monitorsendsms(v_string,pv_sourcename);
    END LOOP;
  ELSIF  pv_sourcename = 'HNX3MSG' THEN
    FOR r IN (SELECT od.orderid , od.orderqtty, sb.symbol, cf.custodycd, a.cdcontent exectype, od.FEEDBACKMSG
                     FROM odmast od, cfmast cf, sbsecurities sb, allcode a
                     WHERE ORSTATUS = '6' AND od.custid = cf.custid AND od.codeid = sb.codeid
                     AND a.cdtype = 'OD' AND a.cdname = 'EXECTYPE' AND a.cdval = od.exectype
                     AND sb.tradeplace IN ('002','005') and od.txdate = getcurrdate
                     AND orderid NOT IN (SELECT lastvalue FROM SMSMonitorController WHERE sourcename = pv_sourcename)
             )
    LOOP
       v_string := 'Flex monitor: Loi Msg 3 TK ' || r.custodycd || ' ' || r.exectype || ' ' || r.symbol
                   || ' ' || r.orderqtty ||', ' || r.FEEDBACKMSG || '.';
       INSERT INTO SMSMonitorController (sourcename, smscontent, lastdatetime, smsstatus, lastvalue)
        VALUES (pv_sourcename, v_string,SYSDATE, 'Y',r.orderid);
        pr_monitorsendsms(v_string,pv_sourcename);
    END LOOP;
  END IF;

IF pv_sourcename <> 'HNX3MSG' AND  pv_sourcename <> 'HOSE2GMSG' AND pv_sourcename <> 'BATCHTIME' THEN
  BEGIN
        SELECT COUNT(1) INTO v_count FROM SMSMonitorController WHERE sourcename = pv_sourcename;
  EXCEPTION WHEN OTHERS THEN
    v_count:=0;
  END;
  IF v_count > 0 THEN
    SELECT lastvalue INTO v_lastvalue FROM SMSMonitorController WHERE sourcename = pv_sourcename;
    IF pv_sourcename = 'MONEYTRANFER' THEN --qua thoi gian chuyen tien
        SELECT COUNT(1) INTO v_value FROM
               (SELECT 1 FROM crbbankrequest
               WHERE status = 'P'
               AND TRUNC(( SYSDATE - to_date(to_char(createdt,'dd/MM/yyyy hh:mi:ss AM'),'dd/MM/yyyy hh:mi:ss AM') ) * 24 * 60) > v_maxminute
               UNION ALL
               SELECT 1 FROM crbtxreq WHERE status = 'P'
               AND TRUNC(( SYSDATE - to_date(to_char(createdate,'dd/MM/yyyy hh:mi:ss AM'),'dd/MM/yyyy hh:mi:ss AM') ) * 24 * 60) > v_maxminute
               ) ;
        IF v_lastvalue < v_value THEN
          UPDATE SMSMonitorController SET lastvalue = v_value, smsstatus = 'Y', lastdatetime = SYSDATE WHERE sourcename = pv_sourcename;
          pr_monitorsendsms('Flex monitor: Co ' || v_value || ' lenh chuyen tien chua thuc hien sau ' || v_maxminute || ' phut.',pv_sourcename);
        END IF;
      ELSIF pv_sourcename = 'HOSECONNECTION' THEN --mat ket noi HOSE
        SELECT COUNT(1) INTO v_value FROM SMSMonitorController WHERE sourcename = pv_sourcename AND lastvalue = 1;
        IF v_value <> 0 THEN
          --chi gui tin khi dut ket noi trong gio giao dich
             UPDATE smsMonitorController SET lastvalue = -1, smsstatus = 'Y', lastdatetime = SYSDATE WHERE sourcename = pv_sourcename;
             select count(*) into v_countBstatus from ood , sbsecurities sb
             where ood.codeid = sb.codeid and sb.tradeplace = '001' and ood.oodstatus = 'B';
          IF to_char(SYSDATE,'hh24') >= 9 AND to_char(SYSDATE,'hh24') <= 16 THEN
             pr_monitorsendsms('Flex monitor: Gateway HSX Termination. ' || v_countBstatus || ' orders status B',pv_sourcename);
          END IF;
        END IF;
      ELSIF pv_sourcename = 'HNXCONNECTION' THEN --mat ket noi HNX
        SELECT COUNT(1) INTO v_value FROM SMSMonitorController WHERE sourcename = pv_sourcename AND lastvalue = 1;
        IF v_value <> 0 THEN
          --chi gui tin khi dut ket noi trong gio giao dich
             UPDATE smsMonitorController SET lastvalue = -1, smsstatus = 'Y', lastdatetime = SYSDATE WHERE sourcename = pv_sourcename;
             select count(*) into v_countBstatus from ood , sbsecurities sb
             where ood.codeid = sb.codeid and sb.tradeplace = '002' and ood.oodstatus = 'B';
          IF to_char(SYSDATE,'hh24') >= 9 AND to_char(SYSDATE,'hh24') <= 16 THEN
             pr_monitorsendsms('Flex monitor: Gateway HNX Termination. ' || v_countBstatus || ' orders status B',pv_sourcename);
          END IF;
        END IF;
      ELSIF pv_sourcename = 'PORFOLIOERROR' THEN --loi tu doanh
        FOR rec IN ( SELECT * FROM pmtxmsg WHERE status = 'E' AND autoid > (SELECT lastvalue FROM smsmonitorcontroller WHERE sourcename = pv_sourcename )ORDER BY autoid)
        LOOP
          pr_monitorsendsms('Flex monitor: He thong nhan duoc loi tu doanh: ' || rec.errorcode || ':' || rec.errordesc,pv_sourcename);
          UPDATE smsmonitorcontroller SET lastvalue = rec.autoid, smsstatus = 'Y', lastdatetime = SYSDATE WHERE sourcename = pv_sourcename;
        END LOOP;
      ELSIF pv_sourcename = 'HOSESCMSG' THEN --chuyen phien HOSE
         SELECT sysvalue INTO v_string FROM ordersys WHERE sysname = 'CONTROLCODE';
         IF v_string <> v_lastvalue THEN
            pr_monitorsendsms('Flex monitor: San HOSE chuyen sang phien ' || v_string || '.', pv_sourcename);
            UPDATE smsmonitorcontroller SET lastvalue = v_string, smsstatus = 'Y', lastdatetime = SYSDATE WHERE sourcename = pv_sourcename;
         END IF;
      ELSIF pv_sourcename = 'HNXhMSG' THEN --chuyen phien HNX
         SELECT sysvalue INTO v_string FROM ordersys_ha WHERE sysname = 'CONTROLCODE';
         IF v_string <> v_lastvalue THEN
            pr_monitorsendsms('Flex monitor: San HNX chuyen sang phien ' || v_string || '.', pv_sourcename);
            UPDATE smsmonitorcontroller SET lastvalue = v_string, smsstatus = 'Y', lastdatetime = SYSDATE WHERE sourcename = pv_sourcename;
         END IF;
      ELSE --gui trang thai services 'SERVICESSTATUS'
         UPDATE SMSMonitorController SET lastvalue = '-1', smsstatus = 'Y', lastdatetime = SYSDATE WHERE sourcename = pv_sourcename;
           pr_monitorsendsms('Flex monitor: Services ' || pv_sourcename || ' mat ket noi, vui long kiem tra he thong ','SERVICESSTATUS');
    END IF;
  ELSE
    IF  pv_sourcename = 'MONEYTRANFER' THEN
        SELECT COUNT(1) INTO v_value FROM
               (SELECT 1 FROM crbbankrequest
               WHERE status = 'P'
               AND TRUNC(( SYSDATE - to_date(to_char(createdt,'dd/MM/yyyy hh:mi:ss AM'),'dd/MM/yyyy hh:mi:ss AM') ) * 24 * 60) > v_maxminute
               UNION ALL
               SELECT 1 FROM crbtxreq WHERE status = 'P'
               AND TRUNC(( SYSDATE - to_date(to_char(createdate,'dd/MM/yyyy hh:mi:ss AM'),'dd/MM/yyyy hh:mi:ss AM') ) * 24 * 60) > v_maxminute
               ) ;
        INSERT INTO SMSMonitorController (sourcename, smscontent, lastdatetime, smsstatus, lastvalue)
        VALUES (pv_sourcename, 'Flex monitor: Co ' || v_value || ' lenh chuyen tien chua thuc hien sau ' || v_maxminute || ' phut.' ,
              SYSDATE, 'Y', v_value);
         pr_monitorsendsms('Flex monitor: Co ' || v_value || ' lenh chuyen tien chua thuc hien sau ' || v_maxminute || ' phut.',pv_sourcename);
    ELSIF pv_sourcename = 'HOSECONNECTION' THEN
      --lan dau bat monitor trong ngay khong gui sms dut ket noi
      INSERT INTO SMSMonitorController (sourcename, smscontent, lastdatetime, smsstatus, lastvalue)
        VALUES (pv_sourcename, 'Flex monitor: Trang thai ket noi voi san HOSE bi gian doan',SYSDATE, 'Y', '-1');
    ELSIF pv_sourcename = 'HNXCONNECTION' THEN
      --lan dau bat monitor trong ngay khong gui sms dut ket noi
      INSERT INTO SMSMonitorController (sourcename, smscontent, lastdatetime, smsstatus, lastvalue)
        VALUES (pv_sourcename, 'Flex monitor: Trang thai ket noi voi san HNX bi gian doan',SYSDATE, 'Y', '-1');
    ELSIF pv_sourcename = 'PORFOLIOERROR' THEN
      INSERT INTO SMSMonitorController (sourcename, smscontent, lastdatetime, smsstatus, lastvalue)
        VALUES (pv_sourcename, 'Flex monitor: Loi tu doanh',SYSDATE, 'Y','0');
      FOR rec IN ( SELECT * FROM pmtxmsg WHERE status = 'E' ORDER BY autoid)
        LOOP
          pr_monitorsendsms('Flex monitor: He thong nhan duoc loi tu doanh: ' || rec.errorcode || ':' || rec.errordesc,pv_sourcename);
          UPDATE smsmonitorcontroller SET lastvalue = rec.autoid, smsstatus = 'Y', lastdatetime = SYSDATE WHERE sourcename = pv_sourcename;
        END LOOP;
    ELSIF pv_sourcename = 'HOSESCMSG' THEN --chuyen phien HOSE
         SELECT sysvalue INTO v_string FROM ordersys WHERE sysname = 'CONTROLCODE';
         pr_monitorsendsms('Flex monitor: San HOSE chuyen sang phien ' || v_string || '.',pv_sourcename);
         INSERT INTO SMSMonitorController (sourcename, smscontent, lastdatetime, smsstatus, lastvalue)
         VALUES (pv_sourcename, 'Flex monitor: San HOSE chuyen sang phien ' || v_string || '.',SYSDATE, 'Y', v_string);
    ELSIF pv_sourcename = 'HNXhMSG' THEN --chuyen phien HNX
         SELECT sysvalue INTO v_string FROM ordersys_ha WHERE sysname = 'CONTROLCODE';
         pr_monitorsendsms('Flex monitor: San HNX chuyen sang phien ' || v_string || '.', pv_sourcename);
         INSERT INTO SMSMonitorController (sourcename, smscontent, lastdatetime, smsstatus, lastvalue)
         VALUES (pv_sourcename, 'Flex monitor: San HNX chuyen sang phien ' || v_string || '.',SYSDATE, 'Y', v_string);
    ELSE  --gui trang thai services 'SERVICESSTATUS'
      INSERT INTO SMSMonitorController (sourcename, smscontent, lastdatetime, smsstatus, lastvalue)
        VALUES (pv_sourcename, 'Flex monitor: Services ' || pv_sourcename || ' mat ket noi, vui long kiem tra he thong ',SYSDATE, 'Y', '-1');
       pr_monitorsendsms('Flex monitor: Services ' || pv_sourcename || ' mat ket noi, vui long kiem tra he thong ','SERVICESSTATUS');
    END IF;
  END IF;
END IF;
EXCEPTION
    WHEN OTHERS THEN
        return;
END;
 
/
