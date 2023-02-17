SET DEFINE OFF;
CREATE OR REPLACE PACKAGE cspks_esb AS
    PROCEDURE sp_rePushOrder;
    PROCEDURE sp_notify_order(pv_orderid IN VARCHAR,pv_Afacctno IN VARCHAR);
    PROCEDURE sp_place_order (f_orderid IN VARCHAR);    --Place order
    PROCEDURE sp_set_message_queue (f_content IN VARCHAR, f_queue IN VARCHAR);                  --Th? t?c dua message v?o queue
    FUNCTION fn_get_message_queue (f_queue IN VARCHAR) RETURN varchar;                          --??c message trong queue
    FUNCTION fn_get_order_message (f_orderid IN VARCHAR, f_afacctno IN VARCHAR) RETURN varchar; --Tra chuoi order message
END CSPKS_ESB;

 
 
 
 
/


CREATE OR REPLACE PACKAGE BODY cspks_esb AS
      -- Private variable declarations
      pkgctx plog.log_ctx;
      logrow tlogdebug%rowtype;
    PROCEDURE sp_rePushOrder AS
        CURSOR C_D IS SELECT ACCTNO,AFACCTNO FROM FOMAST WHERE STATUS='P';
        v_count INTEGER;
    BEGIN
        plog.setbeginsection(pkgctx, 'sp_rePushOrder');
        v_count:=0;
        FOR I IN C_D
          LOOP
          v_count:=v_count+1;
            plog.info('Re push.:'||i.acctno||' :: '||i.afacctno);
            cspks_esb.sp_notify_order(PV_ORDERID=>I.ACCTNO, PV_AFACCTNO=>I.AFACCTNO);
            if mod(v_count,100)=0 then commit;
            end if;
        END LOOP;
        commit;
        plog.info('Total push.:'||v_count);
        plog.setendsection(pkgctx, 'sp_rePushOrder');
    END sp_rePushOrder;
    PROCEDURE sp_notify_order(pv_orderid IN VARCHAR,pv_Afacctno IN VARCHAR) AS
         message2esb VARCHAR(1000);
    BEGIN
           SELECT CSPKS_ESB.fn_get_order_message(pv_orderid,pv_Afacctno) INTO message2esb FROM DUAL;
           CSPKS_ESB.sp_set_message_queue(message2esb, 'QUEUES.txaqs_flex2esb');

           Insert into FLEX2ESBLOG(msgbody,msgtime,msgdest,msgparms) values
            (message2esb,SYSTIMESTAMP,'txaqs_flex2esb',
                pv_orderid ||' '||pv_Afacctno );
              /* Ket thuc Dua su kien vao queue */
          return;
    END;
    PROCEDURE sp_place_order(f_orderid IN VARCHAR) AS
            p_err_code     VARCHAR(16);
            p_err_message VARCHAR(100);
    BEGIN
        plog.setbeginsection(pkgctx, 'sp_place_order');
        p_err_code:='0';
        --Goi ham dat lenh
        --INSERT INTO ESB2FLEXLOG (MSGBODY, MSGTIME) SELECT 'ORDERID: ' || f_orderid, SYSTIMESTAMP FROM DUAL;
        txpks_auto.pr_fo2odsyn(f_orderid,p_err_code);
        If nvl(p_err_code,'0') <> '0' Then
              --Cap nhat trang thai tu choi
              UPDATE FOMAST SET DELTD='Y' WHERE ACCTNO=f_orderid;
              p_err_message:=cspks_system.fn_get_errmsg(p_err_code);
              plog.error(pkgctx, 'sp_place_order.:Error:'||f_orderid|| '.:'  || p_err_message);
              plog.setendsection(pkgctx, 'sp_place_order');
        End If;
        plog.info(pkgctx,'sp_place_order.:'||f_orderid||'.:v_errorCode.:'||p_err_code);
        COMMIT;
        plog.setendsection(pkgctx, 'sp_place_order');
    END sp_place_order;

    PROCEDURE sp_set_message_queue(f_content IN VARCHAR, f_queue IN VARCHAR) AS
        r_enqueue_options    DBMS_AQ.ENQUEUE_OPTIONS_T;
        r_message_properties DBMS_AQ.MESSAGE_PROPERTIES_T;
        v_message_handle     RAW(16);
        o_payload            SYS.AQ$_JMS_TEXT_MESSAGE;
    BEGIN
        o_payload := SYS.AQ$_JMS_TEXT_MESSAGE.CONSTRUCT;
        o_payload.SET_TEXT(f_content);

        DBMS_AQ.ENQUEUE(
                queue_name         => f_queue,
                enqueue_options    => r_enqueue_options,
                message_properties => r_message_properties,
                payload            => o_payload,
                msgid              => v_message_handle
            );
        COMMIT;
    END sp_set_message_queue;

    FUNCTION fn_get_message_queue(f_queue IN VARCHAR) RETURN varchar AS
        r_dequeue_options    DBMS_AQ.DEQUEUE_OPTIONS_T;
        r_message_properties DBMS_AQ.MESSAGE_PROPERTIES_T;
        v_message_handle     RAW(16);
        o_payload            SYS.AQ$_JMS_TEXT_MESSAGE;
        v_alert_msg          clob;
    BEGIN
        r_dequeue_options.dequeue_mode := DBMS_AQ.BROWSE;
        DBMS_AQ.DEQUEUE(
            queue_name         => f_queue,
            dequeue_options    => r_dequeue_options,
            message_properties => r_message_properties,
            payload            => o_payload,
            msgid              => v_message_handle
         );
        o_payload.GET_TEXT(v_alert_msg);

        return v_alert_msg;
    EXCEPTION
        WHEN OTHERS THEN
            return '';
    end fn_get_message_queue;

    FUNCTION fn_get_order_message(f_orderid IN VARCHAR, f_afacctno IN VARCHAR) RETURN varchar AS
        v_afclass   varchar(6);
        v_return    varchar2(1000);
    BEGIN

        If f_afacctno ='OD' then
            v_return :=  '{"id":"' || f_orderid || '"}';
        Else
            select MOD(to_number(f_afacctno),20) into v_afclass from dual;
            v_return := '<?xml version="1.0" encoding="UTF-8"?><root><header><category>Orders</category><class>';
            v_return := v_return || v_afclass || '</class></header><body>{"OrderID": "' || f_orderid || '"}</body></root>';
        End if;
        return v_return;
    EXCEPTION
        WHEN OTHERS THEN
            return '';
    end fn_get_order_message;
begin
  -- Initialization
  for i in (select * from tlogdebug)
  loop
    logrow.loglevel  := i.loglevel;
    logrow.log4table := i.log4table;
    logrow.log4alert := i.log4alert;
    logrow.log4trace := i.log4trace;
  end loop;

  pkgctx := plog.init('CSPKS_ESB',
                      plevel     => nvl(logrow.loglevel, 30),
                      plogtable  => (nvl(logrow.log4table, 'N') = 'Y'),
                      palert     => (nvl(logrow.log4alert, 'N') = 'Y'),
                      ptrace     => (nvl(logrow.log4trace, 'N') = 'Y'));
END CSPKS_ESB;

/
