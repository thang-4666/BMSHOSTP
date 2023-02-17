SET DEFINE OFF;
CREATE OR REPLACE TRIGGER TRG_IOD_AFTER 
 AFTER 
 INSERT OR DELETE OR UPDATE
 ON IOD
 REFERENCING OLD AS OLDVAL NEW AS NEWVAL
 FOR EACH ROW
declare
  -- local variables here
  l_side               varchar2(10);
  l_header             varchar2(160);
  --l_footer             varchar2(160);
  l_total_matched_qtty number;
  l_afacctno           varchar2(10);
  -- Private variable declarations
  pkgctx plog.log_ctx;
  logrow tlogdebug%rowtype;

   v_parvalue number(20,4);
   v_dblPrice number(20,4);
   v_dblDelPrice number(20,4);
   --v_dblDelMatchQtty number(20,4);
   v_recSTSCHD number(20,4);
    l_via    varchar2(1);
    l_blorderid varchar2(30);
begin

  -- Initialization
  for i in (select * from tlogdebug)
  loop
    logrow.loglevel  := i.loglevel;
    logrow.log4table := i.log4table;
    logrow.log4alert := i.log4alert;
    logrow.log4trace := i.log4trace;
  end loop;

  pkgctx := plog.init('TRG_IOD_AFTER',
                      plevel         => nvl(logrow.loglevel, 30),
                      plogtable      => (nvl(logrow.log4table, 'N') = 'Y'),
                      palert         => (nvl(logrow.log4alert, 'N') = 'Y'),
                      ptrace         => (nvl(logrow.log4trace, 'N') = 'Y'));

  plog.setBeginSection(pkgctx, 'TRG_IOD_AFTER');
  --SMS khop lenh ThongPM
  if inserting  then
      select execqtty, afacctno, via, nvl(blorderid,'a')
        into l_total_matched_qtty, l_afacctno, l_via, l_blorderid
        from odmast
       where odmast.orderid = :newval.orgorderid;
  end if;
  if deleting or updating then
      select execqtty, afacctno
        into l_total_matched_qtty, l_afacctno
        from odmast
       where odmast.orderid = :oldval.orgorderid;
  end if;
  if inserting then
      l_total_matched_qtty := l_total_matched_qtty + :newval.matchqtty;
      plog.debug(pkgctx, 'matched quantity' || l_total_matched_qtty);

      if :newval.bors = 'B' then
        l_side := 'MUA ';
      else
        l_side := 'BAN ';
      end if;

  l_header := l_side || :newval.symbol || ' ';
      --l_footer := 'TONG KHOP ' || l_total_matched_qtty || '/' || :newval.qtty;

      insert into SMSMATCHED
        (autoid, CUSTODYCD, AFACCTNO, TXDATE, HEADER, MATCHQTTY, MATCHPRICE, ORDERID, ORDERQTTY, TOTALQTTY, CREATEDATE, PRICE)
      values
        (SEQ_SMSMATCHED.nextval,
         :newval.custodycd,
         l_afacctno,
         :newval.txdate,
         l_header,
         :newval.matchqtty,
         :newval.matchprice,
         :newval.orgorderid,
         :newval.qtty,
         l_total_matched_qtty,
         sysdate,
         :newval.price);
      plog.setEndSection(pkgctx, 'TRG_IOD_AFTER');
      --End SMS khop lenh ThongPM
  end if;

  --Begin Thuc hien phan bo ban chung khoan Quyen --> Thay cho Trigger trong ODMAST
  --01. Truong hop xoa lenh khop
  if :oldval.bors='S' and (updating or deleting) then
    if :newval.deltd <> 'N' or deleting then
        SELECT PARVALUE INTO v_parvalue from sbsecurities where codeid=:oldval.codeid;
        v_dblDelPrice:= :oldval.matchprice;
        if v_dblDelPrice < v_parvalue then
            v_parvalue := v_dblDelPrice;
        end if;

        for rec in (
            select * from SEPITALLOCATE where txnum= :oldval.txnum and txdate = :oldval.txdate
        )
        loop
            UPDATE STSCHD SET RIGHTQTTY= RIGHTQTTY - rec.QTTY, ARIGHT=ARIGHT - rec.ARIGHT
            WHERE  orgorderid=rec.orgorderid and duetype ='RM';
            update SEPITLOG set MAPQTTY= MAPQTTY - rec.QTTY where autoid=rec.sepitlog_id;
        end loop;
        delete from SEPITALLOCATE where txnum= :oldval.txnum and txdate = :oldval.txdate;
    end if;
  end if;
  --02. Truong hop khop lenh
  if :newval.bors='S' and inserting then
    SELECT PARVALUE INTO v_parvalue from sbsecurities where codeid=:newval.codeid;
    v_dblPrice:= :newval.MATCHPRICE;

    if v_dblPrice<v_parvalue then
        v_parvalue:=v_dblPrice;
    end if;

    v_recSTSCHD:=:newval.matchqtty;
    for rec in (
        SELECT * FROM SEPITLOG WHERE AFACCTNO=l_afacctno
        AND CODEID=:newval.codeid AND QTTY-MAPQTTY>0 AND DELTD <> 'Y' ORDER BY PITRATE desc, TXDATE, AUTOID
    )
    loop
         IF v_recSTSCHD < rec.QTTY-rec.MAPQTTY then

            UPDATE STSCHD SET RIGHTQTTY= RIGHTQTTY + v_recSTSCHD,
                ARIGHT = ARIGHT + v_recSTSCHD * rec.CARATE * v_parvalue * rec.PITRATE/100
                WHERE DUETYPE='RM' AND ORGORDERID=:newval.orgorderid
                AND AFACCTNO=rec.afacctno AND CODEID=rec.codeid
                AND DELTD <> 'Y' AND STATUS='N';

            UPDATE SEPITLOG SET MAPQTTY= MAPQTTY + v_recSTSCHD
                WHERE AFACCTNO=rec.afacctno AND CODEID=rec.codeid AND TXDATE= rec.txdate AND TXNUM=rec.txnum and autoid = rec.autoid;

            INSERT INTO SEPITALLOCATE (CAMASTID,AFACCTNO,CODEID,PITRATE,QTTY,PRICE,ARIGHT,ORGORDERID,TXNUM,TXDATE,CARATE,SEPITLOG_ID) VALUES(
                    rec.CAMASTID, rec.AFACCTNO, rec.CODEID, rec.PITRATE,v_recSTSCHD, v_parvalue, v_recSTSCHD * rec.CARATE * v_parvalue * rec.PITRATE/100,
                    :newval.orgorderid, :newval.TXNUM,:newval.TXDATE,rec.CARATE,rec.AUTOID);

            v_recSTSCHD:=0;

        else
            UPDATE STSCHD SET RIGHTQTTY = RIGHTQTTY + rec.qtty - rec.mapqtty,
                ARIGHT = ARIGHT + (rec.qtty - rec.mapqtty) * rec.CARATE * v_parvalue * rec.PITRATE/100
                WHERE DUETYPE='RM' AND ORGORDERID=:newval.orgorderid AND AFACCTNO=rec.afacctno AND CODEID=rec.codeid AND
                DELTD <> 'Y' AND STATUS='N';

            UPDATE SEPITLOG SET MAPQTTY = MAPQTTY + rec.qtty - rec.mapqtty, STATUS='C' WHERE
                AFACCTNO=rec.afacctno AND CODEID=rec.codeid AND TXDATE= rec.txdate AND TXNUM=rec.txnum and autoid = rec.autoid;

            INSERT INTO SEPITALLOCATE (CAMASTID,AFACCTNO,CODEID,PITRATE,QTTY,PRICE,ARIGHT,ORGORDERID,TXNUM,TXDATE,CARATE,SEPITLOG_ID) VALUES(
                    rec.CAMASTID, rec.AFACCTNO, rec.CODEID, rec.PITRATE,rec.qtty - rec.mapqtty, v_parvalue, (rec.qtty - rec.mapqtty) * rec.CARATE * v_parvalue * rec.PITRATE/100,
                    :newval.orgorderid, :newval.TXNUM,:newval.TXDATE,rec.CARATE,rec.AUTOID);

            v_recSTSCHD:=v_recSTSCHD- (rec.qtty - rec.mapqtty);
        end if;
        exit when v_recSTSCHD<=0;
    End loop;
  end if;
  --End Thuc hien phan bo ban chung khoan Quyen --> Thay cho Trigger trong ODMAST

    -- Them vao de xu ly cho lenh Bloomberg
    -- DungNH, 02-Nov-2015
    IF l_via = 'L' or l_blorderid <> 'a' then 
        if :newval.qtty = :newval.matchqtty Then  --FILLED
            pck_blg.Prc_Event('IOD_FILLED',:newval.txnum,:newval.orgorderid,:newval.orgorderid);
        Else
            pck_blg.Prc_Event('IOD_PART_FILLED',:newval.txnum,:newval.orgorderid,:newval.orgorderid);
        end if;
    End if;
    -- Ket thuc: Them vao de xu ly cho lenh Bloomberg

exception
  when others then
    plog.error(pkgctx, sqlerrm);
    plog.setEndSection(pkgctx, 'TRG_IOD_AFTER');
end TRG_OTRIGHT_AFTER;
/
