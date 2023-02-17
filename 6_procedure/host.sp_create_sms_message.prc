SET DEFINE OFF;
CREATE OR REPLACE PROCEDURE "SP_CREATE_SMS_MESSAGE" IS
  v_currdate      varchar2(10);
  v_phonenumber   varchar2(20);
  v_smsid         varchar2(10);
  v_message       varchar2(160);
  v_ordertype     varchar2(10);
  v_createtime    varchar2(20);
  v_createdate    varchar2(20);
  V_HOSTATUS varchar2(10);
  --pkgctx plog.log_ctx;
BEGIN
  --plog.setbeginsection(pkgctx, 'SP_CREATE_SMS_MESSAGE');
  SELECT      VARVALUE
  INTO        V_HOSTATUS
  FROM        SYSVAR
  WHERE       VARNAME = 'HOSTATUS';
  If V_HOSTATUS='1' then
      select varvalue into v_currdate
      from sysvar where varname = 'CURRDATE';
      --Chuyen du lieu tu bang IOD sang IODSMSLOG de lam du lieu tho cho qua trinh tao SMS
      --plog.debug (pkgctx, 'BEGIN: INSERT INTO IODSMSLOG');
      insert into iodsmslog(autoid, txdate,txnum, txtime, custodycd, acctno,
           mobile, orderid, bors, pricetype, exectype, symbol,
           qtty, price, matchqtty, matchprice, status)
      select seq_iodsmslog.nextval,a.txdate,a.txnum,a.txtime, a.custodycd,od.afacctno,
           cf.mobile,od.orderid,a.bors,od.pricetype, 'M',a.symbol,
           a.qtty,a.price,a.matchqtty,a.matchprice,'A'
      from iod a, cfmast cf, odmast od
      where  a.orgorderid=od.orderid
            and a.deltd<>'Y'
            and od.deltd<>'Y'
            and  a.custodycd=cf.custodycd
            and a.txdate = to_date(v_currdate,systemnums.C_DATE_FORMAT)
            and  not exists (select txnum from iodsmslog i  where i.txnum=a.txnum and i.txdate=a.txdate);
      commit;
    End if;
  --plog.debug (pkgctx, 'END: INSERT INTO IODSMSLOG');
  /*
  for rec in
  (
      SELECT TO_CHAR(TXDATE,'DD/MM/RRRR') TXDATE, custodycd, bors, symbol, max(txtime) txtime, sum(matchqtty) KLK,
             round(sum(matchqtty*matchprice)/sum(matchqtty)) GKTB
      from iodsmslog
      where status = 'A'
      group by txdate, custodycd, bors, symbol
  )
  loop
      select substr(nvl(mobile,'0'),1,16), decode(rec.bors, 'B', 'Mua', 'S', 'Ban'),
             to_char(sysdate, 'HH24:MI:SS'), to_char(sysdate, systemnums.C_DATE_FORMAT),
             seq_smsmobile.nextval
             into v_phonenumber, v_ordertype, v_createtime, v_createdate ,v_smsid
      from cfmast where custodycd = rec.custodycd;
      v_message := 'ECC - Tai khoan: ' || rec.custodycd || '. ' || v_ordertype || ': ' || rec.symbol || ', Khoi luong khop: ' || rec.klk || ', Gia khop TB: ' || rec.gktb || ', Thoi gian khop: ' || rec.txtime || '. Ngay: ' || rec.txdate;
      --plog.debug (pkgctx, 'v_message: ' || v_message);

      if length(v_phonenumber) > 2 then
         if substr (v_phonenumber,1,1) = '0' then
            v_phonenumber := '84' || substr(v_phonenumber, 2, length(v_phonenumber) - 1);
         end if;
      end if;
      -- Tao message de gui tin nhan
      insert into smsmobile (autoid, smsid, phonenumber, smstype, message, status, createtime, CREATEDATE)
      values(v_smsid, v_smsid, v_phonenumber, 'O', v_message, 'A', v_createtime,
                      to_date(v_createdate, systemnums.C_DATE_FORMAT));
      -- Cap nhat lai trang thai cua bang IODSMSLOG ghi nhan da tao SMS cho nhung lenh khop hien tai.
      update iodsmslog set status = 'C'
      where custodycd = rec.custodycd
            and txdate = to_date(v_currdate,systemnums.C_DATE_FORMAT)
            and status = 'A';
      commit;
  end loop;
  */
  --plog.setendsection(pkgctx, 'SP_CREATE_SMS_MESSAGE');
--EXCEPTION
--  WHEN OTHERS
--   THEN
      --plog.error (pkgctx, SQLERRM);
      --plog.setendsection (pkgctx, 'SP_CREATE_SMS_MESSAGE');
END;

 
 
 
 
/
