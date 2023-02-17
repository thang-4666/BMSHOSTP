SET DEFINE OFF;
CREATE OR REPLACE TRIGGER TRG_STSCHD_BEFORE 
 BEFORE
  INSERT
 ON stschd
REFERENCING NEW AS NEWVAL OLD AS OLDVAL
 FOR EACH ROW
begin
    --Gianh them phan bo chung khoan quyen trong truong hop khop lenh lan dau tien
    if inserting then
        if :newval.DUETYPE = 'RM' then
            for rec in (
                select nvl(sum(qtty),0) qtty, nvl(sum(ARIGHT),0) ARIGHT from SEPITALLOCATE where orgorderid = :newval.orgorderid
            )
            loop
                :newval.RIGHTQTTY := rec.qtty;
                :newval.ARIGHT:= rec.ARIGHT;
                exit;
            end loop;
        end if;
    end if;
    --End Gianh them phan bo chung khoan quyen trong truong hop khop lenh lan dau tien
END;
/
