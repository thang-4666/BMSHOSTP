SET DEFINE OFF;
CREATE OR REPLACE TRIGGER TRG_ODMAST_AFTER 
 AFTER
   INSERT OR UPDATE OF execqtty, cancelqtty, dfqtty, adjustqtty, edstatus, taxsellamt, orderqtty, remainqtty, orderid, deltd, errod, orstatus, feeacr, codeid, seacctno, afacctno, dfacctno
 ON odmast
REFERENCING NEW AS NEWVAL OLD AS OLDVAL
 FOR EACH ROW
DECLARE
    diff NUMBER(20,8);
    v_hostatus varchar2(10);
    v_errmsg varchar2(2000);
    v_custid varchar2(10);
    v_currdate date;
    v_symbol varchar2(20);
    v_debugmsg varchar2(1700);
    l_afacctno varchar2(20);
    l_seacctno varchar2(20);
    l_orderid varchar2(20);
    diff_cancel NUMBER(20,0);
    diff_exec NUMBER(20,0);
    l_err_code varchar2(100);
    
    l_blOrderid varchar2(50);
BEGIN
SELECT      VARVALUE
INTO        V_HOSTATUS
FROM        SYSVAR
WHERE       VARNAME = 'HOSTATUS';

IF V_HOSTATUS = '1' THEN
    /*--Begin ThongPM add cho phan day thong tin ra buffer
    l_afacctno := :newval.afacctno;
    if instr('/AB/AS/CB/CS/', :newval.exectype) > 0 then
      l_orderid := :newval.reforderid;
    else
      l_orderid := :newval.orderid;
    end if;

    msgpks_system.sp_notification_obj('ODMAST', l_orderid, l_afacctno);

    if instr('/NS/MS/SS/', :newval.exectype) > 0 then
      l_seacctno := :newval.seacctno;
      msgpks_system.sp_notification_obj('SEMAST', l_seacctno, l_afacctno);
    elsif instr('/NB/', :newval.exectype) > 0 then
      msgpks_system.sp_notification_obj('CIMAST', l_afacctno, l_afacctno);
    end if;

    Insert into OL_LOG(acctno,status,logtime,applytime)
    values (:NEWVAL.afacctno,'N',sysdate,null);
    --End ThongPM add*/

    --Begin GianhVG Log trigger for buffer
    l_afacctno := :newval.afacctno;
    if instr('/AB/AS/CB/CS/', :newval.exectype) > 0 then
      l_orderid := :newval.reforderid;
    else
      l_orderid := :newval.orderid;
    end if;
    jbpks_auto.pr_trg_account_log(l_orderid,'OD');

    if instr('/NS/MS/SS/AS', :newval.exectype) > 0 then
        jbpks_auto.pr_trg_account_log(:newval.seacctno,'SE');
        -- Lenh danh dau loi thi cap nhat lai buffer
        -- TheNN, 11-Oct-2012
        IF :newval.errod <> :oldval.errod THEN
            jbpks_auto.pr_trg_account_log(:newval.ciacctno,'CI');
        END IF;
        -- End: TheNN, 11-Oct-2012
    elsif instr('/NB/AB/', :newval.exectype) > 0 then
        jbpks_auto.pr_trg_account_log(:newval.ciacctno,'CI');
        jbpks_auto.pr_trg_account_log(:newval.seacctno,'SE');
        /*if :newval.execqtty <> :oldval.execqtty then
            jbpks_auto.pr_trg_account_log(:newval.seacctno,'SE');
        end if;*/
    end if;
    --End GianhVG Log trigger for buffer


    --Gianh VG comment doan phan bo chung khoan quyen mua, dua sang trigger cua IOD de phan bo
    /*--Begin HaiLT add cho phan xu ly ban chung khoan quyen
    if updating then
        if nvl(:newval.execqtty,0) <> nvl(:oldval.execqtty,0) then
            if instr('/NS/MS/SS/', :newval.exectype) > 0 then
                cspks_caproc.pr_allocate_right_stock(:newval.orderid);
            end if;
        end if;
    end if;*/
/*
    if updating then
        --Neu la lenh ban thoa thuan tong bi huy
        if nvl(:newval.exectype,0) ='NS' and :newval.matchtype='P' and :newval.grporder='Y' and :newval.cancelqtty>0 and :newval.deltd<>'Y' then
            cspks_odproc.pr_CancelGroupOrder(:NEWval.orderid);
        end if;
    end if;
*/
    --End HaiLT add
    --Begin GianhVG Add xu ly cho lenh ban cam co, ban cam co tong
    if inserting then
        --Thuc hien ghi nhan cac deal cho lenh MS
        if :NEWval.exectype ='MS' then
            cspks_odproc.pr_MortgageSellAllocate(:NEWval.orderid,:NEWval.afacctno, :NEWval.codeid,:NEWval.dfacctno,:NEWval.orderqtty);
            if :NEWval.execqtty<>0 then
                cspks_odproc.pr_MortgageSellMatch(:NEWval.orderid,:NEWval.execqtty,:NEWval.execamt,:NEWval.afacctno, :NEWval.codeid);
            end if;
        end if;
    else
        --Thuc hien cap nhat ghi nhan cho cac deal cho lenh MS
        if :NEWval.exectype ='MS' then
            if :NEWval.deltd <> 'Y' then
                diff_cancel:=:NEWval.cancelqtty + :NEWval.adjustqtty-:OLDval.Cancelqtty-:Oldval.adjustqtty;
                if diff_cancel<>0 then
                    cspks_odproc.pr_MortgageSellRelease(:NEWval.orderid,:NEWval.afacctno, :NEWval.codeid,:NEWval.dfacctno,:NEWval.orderqtty,diff_cancel);
                end if;
                diff_exec:=:NEWval.execqtty - :Oldval.execqtty;
                if diff_exec<>0 then
                    cspks_odproc.pr_MortgageSellMatch(:NEWval.orderid,diff_exec,:NEWval.execamt - :Oldval.execamt,:NEWval.afacctno, :NEWval.codeid);
                end if;

            else
                update odmapext set deltd='Y' where orderid = :NEWval.orderid;
                if :NEWval.execqtty > 0 then
                    cspks_odproc.pr_MortgageSellMatch(:NEWval.orderid,-(:NEWval.execqtty),-(:NEWval.execamt),:NEWval.afacctno, :NEWval.codeid);
                end if;
            end if;
        end if;
    end if;
    --End GianhVG add

    if inserting then
        if instr('/NB/', :newval.exectype) > 0 then
            cspks_odproc.pr_semargininfoupdate(:newval.afacctno,:newval.codeid,:newval.remainqtty);
        end if;
    end if;
    if updating then
        if instr('/NS/MS/SS/', :newval.exectype) > 0 then
            if :newval.execqtty > :oldval.execqtty then
                cspks_odproc.pr_semargininfoupdate(:newval.afacctno,:newval.codeid,(:newval.execqtty) - (:oldval.execqtty));
            end if;
        end if;
        if instr('/NB/', :newval.exectype) > 0 then
            if :newval.cancelqtty > :oldval.cancelqtty then
                cspks_odproc.pr_semargininfoupdate(:newval.afacctno,:newval.codeid,-((:newval.cancelqtty)-(:oldval.cancelqtty)));
            end if;
        end if;
    end if;
    
    -- Them vao xu ly cho lenh Bloomberg
    -- Log vao bang event cua Bloomberg de xu ly
    -- DungNH, 02-Nov-2015
    -- Them vao xu ly cho lenh Bloomberg
    -- Log vao bang event cua Bloomberg de xu ly
    -- TheNN, 18-Jun-2013
    IF :newval.via = 'L' THEN
        --If :newval.exectype in ('NB','NS') Then
            --If :newval.ORSTATUS = '8' and :newval.edstatus = 'N' AND :newval.blorderid IS NOT NULL Then
            --    pck_blg.Prc_Event('ODMAST',:newval.orderid,:newval.orderid,l_afacctno);
            --Els
            --if :newval.edstatus ='W' AND :oldval.edstatus <> 'W' Then --Huy thanh cong
                --pck_blg.Prc_Event('CANCELLED',:newval.orderid,:newval.orderid,l_afacctno);
            /*Elsif :newval.edstatus ='S' AND :oldval.edstatus <> 'S' AND nvl(:newval.blorderid,'a') <> 'a' Then --Sua thanh cong
                pck_blg.Prc_Event('REPLACED',:newval.orderid,:newval.orderid,l_afacctno);*/
            --Elsif :newval.ORSTATUS = '5' AND :newval.edstatus ='N' Then
            /*if :newval.ORSTATUS = '5' AND :newval.edstatus ='N' and :oldval.ORSTATUS <> '5' Then
                pck_blg.Prc_Event('DONE4DAY',:newval.orderid,:newval.orderid,l_afacctno);
            Elsif :newval.REMAINQTTY = 0 and :oldval.REMAINQTTY > 0 AND (:newval.ORDERQTTY - :newval.EXECQTTY) > 0 AND :newval.edstatus ='N' Then
                pck_blg.Prc_Event('DONE4DAY',:newval.orderid,:newval.orderid,l_afacctno);
            End if;*/
        --if inserting AND :newval.exectype in ('CB','CS') and :newval.orstatus = '7' AND :newval.edstatus ='C' Then  --Cancel Pending
        --        pck_blg.Prc_Event('CANCEL_PENDING',:newval.orderid,:newval.orderid,l_afacctno);
        --Els
        if inserting AND :newval.exectype in ('AB','AS') and :newval.orstatus = '7' AND :newval.edstatus ='A' Then  --Cancel Pending
                pck_blg.Prc_Event('REPLACE_PENDING',:newval.orderid,:newval.orderid,l_afacctno);
        Elsif :newval.exectype in ('CB','CS') and :newval.orstatus = '0' Then  --Cancel Pending
                pck_blg.Prc_Event('CANCEL_FILLED',:newval.orderid,:newval.orderid,l_afacctno);
        Elsif :newval.exectype in ('AB','AS') and :newval.orstatus = '0' Then  --Cancel Pending
                pck_blg.Prc_Event('REPLACE_FILLED',:newval.orderid,:newval.orderid,l_afacctno);
       /* elsif :newval.exectype in ('AB','AS') and :newval.edstatus = 'S' Then  --Replaced
            pck_fo_bl.bl_Update_AmendOrder(:newval.foacctno, :newval.adjustqtty);*/
        End if;
    END IF;
    if :newval.exectype in ('NB','NS') AND :newval.edstatus ='S' AND :oldval.edstatus <> 'S' AND nvl(:newval.blorderid,'a') <> 'a' Then --Sua thanh cong
        pck_blg.Prc_Event('REPLACED',:newval.orderid,:newval.orderid,l_afacctno);
    END IF;
    if :newval.exectype in ('AB','AS') and :newval.edstatus = 'S' AND nvl(:newval.blorderid,'a') <> 'a' Then  --Replaced
        pck_fo_bl.bl_Update_AmendOrder(:newval.foacctno, :newval.blorderid, :newval.adjustqtty,:newval.quoteprice);
    END IF;
    if updating AND :newval.exectype in ('NB','NS') AND nvl(:newval.blorderid,'a') <> 'a' AND :oldval.blorderid IS NULL AND :newval.execqtty >0  Then --Sua thanh cong
        pck_blg.Prc_Event('MAPORDER',:newval.orderid,:newval.blorderid,l_afacctno);
    elsif updating AND :newval.exectype in ('NB','NS') AND nvl(:newval.blorderid,'a') = 'a' AND nvl(:oldval.blorderid,'a') <> 'a' AND :newval.execqtty >0  Then --Sua thanh cong
        pck_blg.Prc_Event('UNMAPORDER',:newval.orderid,:oldval.blorderid,l_afacctno);
    END IF;
    --Phuong edit: xu ly cho lenh BloomBerg: khi day lenh huy/sua/khop lenh
    if updating  then
      l_blOrderid:= :oldval.blorderid;
      -- lenh BloomBerg
      if nvl(l_blOrderid,'a') <> 'a' then
        -- huy lenh
        if (:newval.cancelqtty > :oldval.cancelqtty) then
           pck_fo_bl.bl_odmast_CancelOrder(l_blOrderid,:newval.cancelqtty,:newval.orderid, :newval.orstatus, :newval.edstatus);
        end if;
        --sua lenh giam khoi luong
        if (:newval.exectype IN ('NB','NS') and  :newval.cancelqtty =0 and (:newval.adjustqtty <> :oldval.adjustqtty )and (:newval.adjustqtty <(:oldval.orderqtty- :oldval.execqtty))) then
           pck_fo_bl.bl_odmast_AmendOrder(l_blOrderid,:newval.adjustqtty,:oldval.orderqtty,:oldval.execqtty);
        end if;
        -- khop lenh
        if (:newval.execqtty <> :oldval.execqtty) then
           pck_fo_bl.bl_odmast_MatchOrder(l_blOrderid,:newval.execqtty-:oldval.execqtty,0);
        end if;
        if (:newval.execamt <> :oldval.execamt) then
           pck_fo_bl.bl_odmast_MatchOrder(l_blOrderid,0,:newval.execamt-:oldval.execamt);
        end if;
      end if;
    end if;

    -- end of PhuongHT edit xu ly cho lenh BloomBerg: khi day lenh huy/sua/khop lenh
    
END IF;
/*EXCEPTION
WHEN OTHERS THEN
    v_errmsg := substr(sqlerrm, 1, 200);
    pr_error(v_debugmsg || ' ' || v_errmsg, 'TRG_ODMAST_ACC_INFO');*/
END;
/
