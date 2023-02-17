SET DEFINE OFF;
CREATE OR REPLACE TRIGGER trg_fomast_after
 AFTER
  INSERT OR UPDATE
 ON fomast
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
BEGIN
SELECT      VARVALUE
INTO        V_HOSTATUS
FROM        SYSVAR
WHERE       VARNAME = 'HOSTATUS';

IF V_HOSTATUS = '1' THEN
    --Begin GianhVG Log trigger for buffer
    if inserting then
        jbpks_auto.pr_trg_account_log(:newval.acctno,'OD');
    else
        if :newval.status<>:oldval.status then
            jbpks_auto.pr_trg_account_log(:newval.acctno,'OD');
        end if;
    end if;
    
    -- Them vao xu ly cho lenh Bloomberg
    -- Chi lenh bi loi moi log loi vao bang event cua Bloomberg de xu ly
    -- DungNH, 02-Nov-2015
    If :newval.Via = 'L' AND :newval.Status in ('R') and  :newval.exectype not in ('AS','AB','CS','CB') Then
        pck_blg.Prc_Event('FOMAST',:newval.acctno,:newval.acctno,:newval.afacctno);
        -- Update lai trong bl_odmast
        pck_fo_bl.bl_rejectfo(:newval.blorderid,:newval.acctno,'R',:newval.FEEDBACKMSG,:newval.exectype);
    Elsif :newval.Via = 'L' AND :newval.Status in ('R') and  :newval.exectype in ('AS','AB','CS','CB') Then
        pck_blg.Prc_Event('FOMAST_CANCEL',:newval.acctno,:newval.acctno,:newval.afacctno);
        -- Update lai trong bl_odmast
        pck_fo_bl.bl_rejectfo(:newval.blorderid,:newval.acctno,'R',:newval.FEEDBACKMSG,:newval.exectype);
    End if;
    -- Ket thuc: Them vao xu ly cho lenh Bloomberg
    
END IF;
/*EXCEPTION
WHEN OTHERS THEN
    v_errmsg := substr(sqlerrm, 1, 200);
    pr_error(v_debugmsg || ' ' || v_errmsg, 'trg_fomast_after');*/
END;
/
