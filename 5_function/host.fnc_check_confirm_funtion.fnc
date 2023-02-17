SET DEFINE OFF;
CREATE OR REPLACE FUNCTION fnc_check_confirm_funtion(
    pv_ConfirmLevel number,
    pv_Username varchar2,
    pv_ConfirmUsername varchar2,
    pv_ConfirmPassword  varchar2,
    pv_CMDMenu varchar2
)
return varchar2
is
    v_dblErrcode number;
    v_count number;
    v_tlid varchar2(10);
    v_errmsg    varchar2(100);
BEGIN
 --return 'OK';
  --- check khi chay cuoi ngay hoac chay giua ngay cac tham so chua duoc duyet thi khong cho chay.
  if pv_CMDMenu in ('011009','011005','011002') then
    v_count := 0 ;
    v_errmsg := '|';
    select count(1) into v_count from citype where apprv_sts = 'P';
    if (v_count > 0) then
        v_errmsg := v_errmsg || 'CITYPE|';
    end if;
    select count(1) into v_count from aftype where apprv_sts = 'P';
    if (v_count > 0) then
        v_errmsg := v_errmsg || 'AFTYPE|';
    end if;
    select count(1) into v_count from lntype where apprv_sts = 'P';
    if (v_count > 0) then
        v_errmsg := v_errmsg || 'LNTYPE|';
    end if;
    select count(1) into v_count from dftype where apprv_sts = 'P';
    if (v_count > 0) then
        v_errmsg := v_errmsg || 'DFTYPE|';
    end if;
    select count(1) into v_count from retype where apprv_sts = 'P';
    if (v_count > 0) then
        v_errmsg := v_errmsg || 'RETYPE|';
    end if;
    select count(1) into v_count from adtype where apprv_sts = 'P';
    if (v_count > 0) then
        v_errmsg := v_errmsg || 'ADTYPE|';
    end if;
    select count(1) into v_count from mrtype where apprv_sts = 'P';
    if (v_count > 0) then
        v_errmsg := v_errmsg || 'MRTYPE|';
    end if;
    select count(1) into v_count from odtype where apprv_sts = 'P';
    if (v_count > 0) then
        v_errmsg := v_errmsg || 'ODTYPE|';
    end if;
    select count(1) into v_count from tdtype where apprv_sts = 'P';
    if (v_count > 0) then
        v_errmsg := v_errmsg || 'TDTYPE|';
    end if;
    if LENGTH(v_errmsg) > 2 then
        v_dblErrcode:= -100905;
        return v_errmsg || cspks_system.fn_get_errmsg (v_dblErrcode);
    end if;

    v_count := 0 ;
    v_errmsg := '|';
    select count(1) into v_count from citype where apprv_sts = 'E';
    if (v_count > 0) then
        v_errmsg := v_errmsg || 'CITYPE|';
    end if;
    select count(1) into v_count from aftype where apprv_sts = 'E';
    if (v_count > 0) then
        v_errmsg := v_errmsg || 'AFTYPE|';
    end if;
    select count(1) into v_count from lntype where apprv_sts = 'E';
    if (v_count > 0) then
        v_errmsg := v_errmsg || 'LNTYPE|';
    end if;
    select count(1) into v_count from dftype where apprv_sts = 'E';
    if (v_count > 0) then
        v_errmsg := v_errmsg || 'DFTYPE|';
    end if;
    select count(1) into v_count from retype where apprv_sts = 'E';
    if (v_count > 0) then
        v_errmsg := v_errmsg || 'RETYPE|';
    end if;
    select count(1) into v_count from adtype where apprv_sts = 'E';
    if (v_count > 0) then
        v_errmsg := v_errmsg || 'ADTYPE|';
    end if;
    select count(1) into v_count from mrtype where apprv_sts = 'E';
    if (v_count > 0) then
        v_errmsg := v_errmsg || 'MRTYPE|';
    end if;
    select count(1) into v_count from odtype where apprv_sts = 'E';
    if (v_count > 0) then
        v_errmsg := v_errmsg || 'ODTYPE|';
    end if;
    select count(1) into v_count from tdtype where apprv_sts = 'E';
    if (v_count > 0) then
        v_errmsg := v_errmsg || 'TDTYPE|';
    end if;
    if LENGTH(v_errmsg) > 2 then
        v_dblErrcode:= -100906;
        return v_errmsg || cspks_system.fn_get_errmsg (v_dblErrcode);
    end if;
    v_count := 0;
  end if;
  --- check khi dong cua hoi so kiem tra xem con giao dich nao chua duyen khong.
  if pv_CMDMenu = '011002' then
    v_count := 0;
    select count(*) into v_count from tllog where deltd <> 'Y' and txstatus in ('4','7','3');
    --Con giao dich Pending, thong bao loi
    if nvl(v_count,0) > 0 then
        v_dblErrcode:= -100148;
        return cspks_system.fn_get_errmsg (v_dblErrcode);
    end if;

    SELECT count(*) into v_count FROM BRGRP WHERE ISACTIVE = 'Y' AND STATUS='A';
    --Con chi nhanh dang hoat dong.
    if nvl(v_count,0) > 0 then
        v_dblErrcode:= -100029;
        return cspks_system.fn_get_errmsg (v_dblErrcode);
    end if;
  end if;

  ---end

    if pv_ConfirmLevel =0 then
        return 'OK';
    elsif pv_ConfirmLevel =1 then
        --Kiem tra Username va Pass co hop le hay khong
        if pv_ConfirmUsername <> pv_Username then
            v_dblErrcode:= -100900;
            return cspks_system.fn_get_errmsg (v_dblErrcode);
        end if;
        --Kiem tra Username con ton tai hay khong
        select count(1) into v_count from tlprofiles where upper(tlname) =upper(pv_ConfirmUsername) and active ='Y';
        if v_count <=0 then
            v_dblErrcode:= -100901;
            return cspks_system.fn_get_errmsg (v_dblErrcode);
        end if;
        --Kiem tra password co dung khong
        select count(1) into v_count from tlprofiles where upper(tlname) =upper(pv_ConfirmUsername) and active ='Y' and PIN = genencryptpassword (pv_ConfirmPassword);
        if v_count <=0 then
            v_dblErrcode:= -100902;
            return cspks_system.fn_get_errmsg (v_dblErrcode);
        end if;

        --Check them cac luat khac neu can
        return 'OK';
    elsif pv_ConfirmLevel =2 then
        --Kiem tra Username va Pass co hop le hay khong
        if upper(pv_ConfirmUsername) = upper(pv_Username) then
            v_dblErrcode:= -100903;
            return cspks_system.fn_get_errmsg (v_dblErrcode);
        end if;
        --Kiem tra Username con ton tai hay khong
        select count(1) into v_count from tlprofiles where upper(tlname) =upper(pv_ConfirmUsername) and active ='Y';
        if v_count <=0 then
            v_dblErrcode:= -100901;
            return cspks_system.fn_get_errmsg (v_dblErrcode);
        end if;
        --Kiem tra password co dung khong
        select count(1) into v_count from tlprofiles where upper(tlname) =upper(pv_ConfirmUsername) and active ='Y' and PIN = genencryptpassword (pv_ConfirmPassword);
        if v_count <=0 then
            v_dblErrcode:= -100902;
            return cspks_system.fn_get_errmsg (v_dblErrcode);
        end if;
        select tlid into v_tlid from tlprofiles where upper(tlname) =upper(pv_ConfirmUsername);
        --Kiem tra User nam co quyen thuc hien tren chuc nang hien t?i hay khong.
        SELECT count(1) into v_count FROM CMDAUTH WHERE AUTHTYPE='U' AND CMDCODE= pv_CMDMenu
        AND AUTHID=v_tlid and CMDALLOW ='Y';
        if v_count <=0 then
            --Kiem tra quyen nhom
            SELECT count(1) into v_count FROM CMDAUTH WHERE AUTHTYPE='G' AND CMDCODE=pv_CMDMenu and CMDALLOW ='Y'
            AND AUTHID in (SELECT M.GRPID FROM TLGRPUSERS M, TLGROUPS A WHERE M.GRPID = A.GRPID AND M.TLID = v_tlid AND A.ACTIVE = 'Y');
            if v_count <= 0 then
                --Thong bao khong co quyen
                v_dblErrcode:= -100904;
                return cspks_system.fn_get_errmsg (v_dblErrcode);
            end if;
        end if;
        return 'OK';
    else
        return 'OK';
    end if;
exception when others then
    v_dblErrcode:= -100990;
    return cspks_system.fn_get_errmsg (v_dblErrcode);
end;

 
 
 
 
/
