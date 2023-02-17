SET DEFINE OFF;
CREATE OR REPLACE PROCEDURE "GENERALWORKING" is

-- Declare program variables as shown above
    v_PrevDate varchar2(10);     -- Ngay lam viec truoc do
    v_TxDate varchar2(10);      -- Ngay lam viec hien tai
    v_NextDate varchar2(10);    -- Ngay lam viec tiep theo
    v_MinBKDate varchar2(20);      -- Giao dich thuc hien vao ngay Back Date


BEGIN

   /* -- Lay tham so ve ngay giao dich
    select varvalue into v_PrevDate from sysvar where upper(grname) = 'SYSTEM' AND upper(varname) = 'PREVDATE';
    select varvalue into v_TxDate from sysvar where upper(grname) = 'SYSTEM' AND upper(varname) = 'CURRDATE';
    select varvalue into v_NextDate from sysvar where upper(grname) = 'SYSTEM' AND upper(varname) = 'NEXTDATE';

    --********* TINH CAC CHI TIEU BAO CAO KET QUA KINH DOANH *************
    --- Ngay Back Date lau nhat
    select min(bkdate) into v_MinBKDate
    from gltran
    where nvl(deltd,'N') <> 'Y' and amt <>0
        and ( substr(acctno,7,1) in ('5','6','7','8') or substr(acctno,7,3) = '911' );

    v_MinBKDate := dtoc(v_MinBKDate );

    if v_MinBKDate is not null then
        MIS_GETDATA_GL0003 ('A','0001', v_MinBKDate, v_TxDate,'%');
    end if;
    --********* Ket thuc: TINH CAC CHI TIEU BAO CAO KET QUA KINH DOANH *************
    --********* Nhom GL *************
    GLGROUP;*/


    commit;
END; -- Procedure

 
 
 
 
/
