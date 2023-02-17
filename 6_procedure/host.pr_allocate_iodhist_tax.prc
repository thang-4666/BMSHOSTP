SET DEFINE OFF;
CREATE OR REPLACE PROCEDURE "PR_ALLOCATE_IODHIST_TAX" (pv_orderid varchar2)
is
    v_dblrate number;
    v_dbltaxsellamt number;
    v_dbliodtaxsellamt number;
    v_dblGapamt number;
begin
    select od.taxrate/100 into v_dblrate
    from vw_odmast_all od where od.orderid = pv_orderid;

    if v_dblrate>0 then
        update iodhist iod set iodtaxsellamt = floor(v_dblrate * iod.matchprice * iod.matchqtty) where iod.orgorderid=pv_orderid;
    end if;

    select max(od.taxsellamt), sum(iod.iodtaxsellamt) iodtaxsellamt
        into v_dbltaxsellamt, v_dbliodtaxsellamt
    from vw_odmast_all od, iodhist iod
    where od.orderid = iod.orgorderid
    and iod.deltd <> 'Y'
    and od.orderid = pv_orderid
    group by od.orderid;

    if v_dbltaxsellamt>v_dbliodtaxsellamt then
        v_dblGapamt:=v_dbltaxsellamt-v_dbliodtaxsellamt;
        for rec in (
            select  iod.* from iodhist iod, vw_odmast_all od
            where od.orderid = pv_orderid
            and iod.deltd <> 'Y'
            and iod.orgorderid= od.orderid
            and od.taxsellamt>0 and od.execamt>0
            order by (iod.matchqtty* iod.matchprice * od.taxrate/100 - floor(iod.matchqtty* iod.matchprice * od.taxrate/100)) desc, iod.orgorderid
        )
        loop
            update iodhist set iodtaxsellamt= iodtaxsellamt+1 where txnum = rec.txnum and txdate = rec.txdate and orgorderid =rec.orgorderid;
            v_dblGapamt:=v_dblGapamt-1;
            EXIT when v_dblGapamt<=0;
        end loop;
    end if;
    if v_dbltaxsellamt<v_dbliodtaxsellamt then
        v_dblGapamt:=v_dbliodtaxsellamt-v_dbltaxsellamt;
        for rec in (
            select  iod.* from iodhist iod, vw_odmast_all od
            where od.orderid = pv_orderid
            and iod.orgorderid= od.orderid
            and od.taxsellamt>0 and od.execamt>0
            order by (iod.matchqtty* iod.matchprice * od.taxrate/100 - floor(iod.matchqtty* iod.matchprice * od.taxrate/100)), iod.orgorderid
        )
        loop
            update iodhist set iodtaxsellamt= iodtaxsellamt-1 where txnum = rec.txnum and txdate = rec.txdate and orgorderid =rec.orgorderid;
            v_dblGapamt:=v_dblGapamt-1;
            EXIT when v_dblGapamt<=0;
        end loop;
    end if;
exception when others then
    return;
end;

 
 
 
 
/
