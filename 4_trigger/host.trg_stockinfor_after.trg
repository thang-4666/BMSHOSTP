SET DEFINE OFF;
CREATE OR REPLACE TRIGGER TRG_STOCKINFOR_AFTER
 AFTER
 INSERT OR UPDATE
 ON STOCKINFOR
 REFERENCING OLD AS OLDVAL NEW AS NEWVAL
 FOR EACH ROW
declare
 v_tradingsessionid VARCHAR2(100);
 v_plobycloseprice VARCHAR2(5);
 v_udppriceplo    VARCHAR2(5);
 v_codeid         VARCHAR2(10);
 v_tradeunit      number;
  pkgctx plog.log_ctx;

begin
  BEGIN
    SELECT HB.TRADINGSESSIONID
    INTO v_tradingsessionid
    from hasecurity_req hr, HA_BRD hb
    WHERE  hr.tradingsessionsubid = hb.BRD_CODE
    AND HR.SYMBOL = :newval.SYMBOL;
  exception
    when others then
      v_tradingsessionid:= 'XXX';
  end;
  if(v_tradingsessionid ='PCLOSE') then
     begin
       select VARVALUE into v_plobycloseprice from sysvar  where GRNAME ='SYSTEM' and VARNAME = 'PLOBYCLOSEPRICE';
       select VARVALUE into v_udppriceplo from sysvar  where GRNAME ='SYSTEM' and VARNAME = 'UPDPRICEPLO';
      exception
      when others then
        v_plobycloseprice:= 'N';
        v_udppriceplo:= 'N';
      end;
      select s.codeid , s.tradeunit
      into v_codeid,v_tradeunit
      from SECURITIES_INFO s where s.symbol = :newval.SYMBOL;
      if(v_plobycloseprice ='Y' and v_udppriceplo ='Y' and ((:newval.CLOSEPRICE <> :oldval.CLOSEPRICE and UPDATING) or INSERTING )and :newval.CLOSEPRICE >0) then
        update fomast fo set fo.price = :newval.CLOSEPRICE / v_tradeunit, fo.quoteprice = :newval.CLOSEPRICE / v_tradeunit
        where  fo.exectype = 'NB' and fo.pricetype = 'PLO' and getcurrdate between fo.effdate and fo.expdate
        and fo.codeid = v_codeid ;
        for rec in ( select * from odmast od
                      where  od.pricetype = 'PLO' and od.exectype = 'NB'
                       and od.txdate = getcurrdate and od.codeid = v_codeid) loop
             insert into LOGCHANGEPRICEPLO(AUTOID, ORDERID, SYSDATES, OLDPRICE, NEWPRICE)
             values (seq_logchangepriceplo.nextval,rec.orderid, sysdate, rec.quoteprice, :newval.CLOSEPRICE);  
             update odmast o set  o.quoteprice = :newval.CLOSEPRICE 
             where o.orderid = rec.orderid;
        end loop;

       
        

      end if;
  end if;
exception
  when others then
    plog.error(pkgctx, SQLERRM);
    plog.setEndSection(pkgctx, 'TRG_STOCKINFOR_AFTER');
end;
/
