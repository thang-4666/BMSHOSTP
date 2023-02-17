SET DEFINE OFF;
CREATE OR REPLACE PROCEDURE pr_gen_sbcurrdate
as
v_currdate date;
v_count number;

begin
    select to_date(varvalue,'DD/MM/RRRR') into v_currdate from sysvar where varname ='CURRDATE' and grname ='SYSTEM';
    --Gen lich business
    delete from sbcurrdate;

    v_count:=0;
    for rec in (select * from sbcldr where sbdate >=v_currdate and cldrtype ='000' and holiday ='N' order by sbdate)
    loop
        insert into sbcurrdate (currdate,sbdate,numday,sbtype)
        values (v_currdate,rec.sbdate,v_count,'B' );
        v_count:=v_count+1;
    end loop;
    v_count:=0;
    for rec in (select * from sbcldr where sbdate <v_currdate and cldrtype ='000'  and holiday ='N'  order by sbdate desc)
    loop

        v_count:=v_count-1;
        insert into sbcurrdate (currdate,sbdate,numday,sbtype)
        values (v_currdate,rec.sbdate,v_count,'B' );
    end loop;

    --Gen lich normal
    v_count:=0;
    for rec in (select * from sbcldr where sbdate >=v_currdate and cldrtype ='000' order by sbdate)
    loop
        insert into sbcurrdate (currdate,sbdate,numday,sbtype)
        values (v_currdate,rec.sbdate,v_count,'N' );
        v_count:=v_count+1;
    end loop;
    v_count:=0;
    for rec in (select * from sbcldr where sbdate <v_currdate and cldrtype ='000'  order by sbdate desc)
    loop

        v_count:=v_count-1;
        insert into sbcurrdate (currdate,sbdate,numday,sbtype)
        values (v_currdate,rec.sbdate,v_count,'N' );
    end loop;
end;

 
 
 
 
 
 
 
 
 
 
 
 
 
/
