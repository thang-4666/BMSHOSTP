SET DEFINE OFF;
CREATE OR REPLACE PROCEDURE pr_gen_sbcurrdate4new
as
v_currdate date;
v_count number;

begin
    select to_date(varvalue,'DD/MM/RRRR') into v_currdate from sysvar where varname ='CURRDATE' and grname ='SYSTEM';
    --Gen lich business
    delete from sbcurrdate4new;
    
    for rec_trade in (select cdval tradeplace from allcode where cdname='TRADEPLACE' AND CDTYPE='SE' AND CDVAL IN ('001','002','005'))
    LOOP
          v_count:=0;
          for rec in (select * from sbcldr where sbdate >=v_currdate and cldrtype =rec_trade.tradeplace and holiday ='N' order by sbdate)
          loop
              insert into sbcurrdate4new (currdate,sbdate,numday,sbtype,tradeplace)
              values (v_currdate,rec.sbdate,v_count,'B',rec_trade.tradeplace );
              v_count:=v_count+1;
          end loop;
          v_count:=0;
          for rec in (select * from sbcldr where sbdate <v_currdate and cldrtype =rec_trade.tradeplace  and holiday ='N'  order by sbdate desc)
          loop

              v_count:=v_count-1;
              insert into sbcurrdate4new (currdate,sbdate,numday,sbtype,tradeplace)
              values (v_currdate,rec.sbdate,v_count,'B',rec_trade.tradeplace );
          end loop;

          --Gen lich normal
          v_count:=0;
          for rec in (select * from sbcldr where sbdate >=v_currdate and cldrtype =rec_trade.tradeplace order by sbdate)
          loop
              insert into sbcurrdate4new (currdate,sbdate,numday,sbtype,tradeplace)
              values (v_currdate,rec.sbdate,v_count,'N',rec_trade.tradeplace );
              v_count:=v_count+1;
          end loop;
          v_count:=0;
          for rec in (select * from sbcldr where sbdate <v_currdate and cldrtype =rec_trade.tradeplace  order by sbdate desc)
          loop

              v_count:=v_count-1;
              insert into sbcurrdate4new (currdate,sbdate,numday,sbtype,tradeplace)
              values (v_currdate,rec.sbdate,v_count,'N' ,rec_trade.tradeplace);
          end loop;
     END LOOP;
end;
 
 
 
 
/
