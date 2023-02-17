SET DEFINE OFF;
CREATE OR REPLACE TRIGGER TRG_SECURITIES_INFO_BEFORE 
 BEFORE
  INSERT OR UPDATE
 ON securities_info
REFERENCING NEW AS NEWVAL OLD AS OLDVAL
 FOR EACH ROW
declare
l_MAXDEBTQTTYRATE number(20,4);
l_MAXDEBTSE number(20,4);
l_IRATIO number(20,4);
begin
    if :OLDVAL.marginrefprice is null
        or :OLDVAL.listingqtty is null
        or :OLDVAL.marginrefprice <> :NEWVAL.marginrefprice
        or :OLDVAL.listingqtty <> :NEWVAL.listingqtty then

        select to_number(varvalue)/100 into l_MAXDEBTQTTYRATE from sysvar where grname = 'MARGIN' and varname = 'MAXDEBTQTTYRATE';
        select to_number(varvalue) into l_MAXDEBTSE from sysvar where grname = 'MARGIN' and varname = 'MAXDEBTSE';
        select 1 - to_number(varvalue)/100 into l_IRATIO from sysvar where grname = 'MARGIN' and varname = 'IRATIO';
        :NEWVAL.roomlimit:= least(:NEWVAL.listingqtty*l_MAXDEBTQTTYRATE, l_MAXDEBTSE/:NEWVAL.marginrefprice/l_IRATIO);
    end if;
    IF :newval.listingqtty <> :oldval.listingqtty OR :newval.basicprice <> :oldval.basicprice or
        :newval.openprice <> :oldval.openprice OR :newval.prevcloseprice <> :oldval.prevcloseprice or
        :newval.closeprice <> :oldval.closeprice or :newval.avgprice <> :oldval.avgprice or
        :newval.ceilingprice <> :oldval.ceilingprice or :newval.floorprice <> :oldval.floorprice or
        :newval.marginprice <> :oldval.marginprice or :newval.marginrefprice <> :oldval.marginrefprice or
        :newval.roomlimit <> :oldval.roomlimit or :newval.roomlimitmax <> :oldval.roomlimitmax or
        :newval.dfrefprice <> :oldval.dfrefprice or :newval.syroomlimit <> :oldval.syroomlimit or
        :newval.syroomused <> :oldval.syroomused or :newval.margincallprice <> :oldval.margincallprice or
        :newval.marginrefcallprice <> :oldval.marginrefcallprice or :newval.dfrlsprice <> :oldval.dfrlsprice or
        :newval.roomlimitmax_set <> :oldval.roomlimitmax_set or :newval.syroomlimit_set <> :oldval.syroomlimit_set or
        :newval.roomused <> :oldval.roomused or :newval.newprice <> :oldval.newprice or
        :newval.newceilingprice <> :oldval.newceilingprice or :newval.newfloorprice <> :oldval.newfloorprice or
        :newval.newbasicprice <> :oldval.newbasicprice then
        insert into securities_info_log
            (autoid, codeid, symbol, txdate, listingqtty,
           tradeunit, listingstatus, adjustqtty, listtingdate,
           referencestatus, adjustrate, referencerate,
           referencedate, status, basicprice, openprice,
           prevcloseprice, currprice, closeprice, avgprice,
           ceilingprice, floorprice, mtmprice, mtmpricecd,
           internalbidprice, internalaskprice, pe, eps, divyeild,
           dayrange, yearrange, tradelot, tradebuysell,
           telelimitmin, telelimitmax, onlinelimitmin,
           onlinelimitmax, repolimitmin, repolimitmax,
           advancedlimitmin, advancedlimitmax, marginlimitmin,
           marginlimitmax, secureratiotmin, secureratiomax,
           depofeeunit, depofeelot, mortageratiomin,
           mortageratiomax, securedratiomin, securedratiomax,
           current_room, bminamt, sminamt, marginprice,
           marginrefprice, roomlimit, roomlimitmax, dfrefprice,
           syroomlimit, syroomused, margincallprice,
           marginrefcallprice, dfrlsprice, roomlimitmax_set,syroomlimit_set,last_change)
        SELECT :oldval.autoid, :oldval.codeid, :oldval.symbol, :oldval.txdate, :oldval.listingqtty,
           :oldval.tradeunit, :oldval.listingstatus, :oldval.adjustqtty, :oldval.listtingdate,
           :oldval.referencestatus, :oldval.adjustrate, :oldval.referencerate,
           :oldval.referencedate, :oldval.status, :oldval.basicprice, :oldval.openprice,
           :oldval.prevcloseprice, :oldval.currprice, :oldval.closeprice, :oldval.avgprice,
           :oldval.ceilingprice, :oldval.floorprice, :oldval.mtmprice, :oldval.mtmpricecd,
           :oldval.internalbidprice, :oldval.internalaskprice, :oldval.pe, :oldval.eps, :oldval.divyeild,
           :oldval.dayrange, :oldval.yearrange, :oldval.tradelot, :oldval.tradebuysell,
           :oldval.telelimitmin, :oldval.telelimitmax, :oldval.onlinelimitmin,
           :oldval.onlinelimitmax, :oldval.repolimitmin, :oldval.repolimitmax,
           :oldval.advancedlimitmin, :oldval.advancedlimitmax, :oldval.marginlimitmin,
           :oldval.marginlimitmax, :oldval.secureratiotmin, :oldval.secureratiomax,
           :oldval.depofeeunit, :oldval.depofeelot, :oldval.mortageratiomin,
           :oldval.mortageratiomax, :oldval.securedratiomin, :oldval.securedratiomax,
           :oldval.current_room, :oldval.bminamt, :oldval.sminamt, :oldval.marginprice,
           :oldval.marginrefprice, :oldval.roomlimit, :oldval.roomlimitmax, :oldval.dfrefprice,
           :oldval.syroomlimit, :oldval.syroomused, :oldval.margincallprice,
           :oldval.marginrefcallprice, :oldval.dfrlsprice, :oldval.roomlimitmax_set,:oldval.syroomlimit_set, SYSTIMESTAMP
        FROM dual;
    end if;
exception when others then
null;
end;
/
