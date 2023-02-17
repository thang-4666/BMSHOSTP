SET DEFINE OFF;
CREATE OR REPLACE PROCEDURE pr_externalupdatecfmast (pv_err_code in out varchar2, pv_custid in varchar2)
is
begin
    --Cap nhat thong tin tu khach hang sang tieu khoan.
    for rec in (select * from cfmast where custid = pv_custid)
    loop
        update cfotheracc set
            acnidcode=rec.idcode,
            acniddate=rec.iddate,
            acnidplace=rec.idplace,
            bankacname=rec.fullname
        where custid = rec.custid;

        update afmast set
            brid = rec.brid
        where custid = rec.custid;
    end loop;
end;

 
 
 
 
/
