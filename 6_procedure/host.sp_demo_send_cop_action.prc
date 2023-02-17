SET DEFINE OFF;
CREATE OR REPLACE PROCEDURE "SP_DEMO_SEND_COP_ACTION" (p_camastid varchar2)
IS
v_status varchar2(10);
BEGIN
    pr_tuning_log('sp_demo_send_cop_action', 'Begin send coporate action :' || p_camastid );

    select status into v_status from camast where camastid = p_camastid;
    if v_status='A' then
        pr_tuning_log('sp_demo_send_cop_action', '  Begin update status :' || p_camastid );
        update camast set status ='S' where camastid = p_camastid;
        commit;
        pr_tuning_log('sp_demo_send_cop_action', '  End update status :' || p_camastid );

        --Ghi log
        --Khong ghi nhan vao cho giao, cho ve
        /*pr_tuning_log('sp_demo_send_cop_action', '  Begin update master CI,SE table:' || p_camastid );
        for rec in (
            select * from caschd where camastid=p_camastid and status ='A'
        )
        loop
            update cimast set receiving = receiving + rec.amt where acctno = rec.afacctno;
            update semast set receiving = receiving + rec.qtty where afacctno = rec.afacctno and  codeid = rec.codeid;
            --update semast set NETTING = NETTING + rec.aqtty where afacctno = rec.afacctno and codeid = rec.excodeid;
        end loop;
        pr_tuning_log('sp_demo_send_cop_action', '  End update master CI,SE table:' || p_camastid );
        commit;*/
        pr_tuning_log('sp_demo_send_cop_action', '  Begin update caschd status :' || p_camastid );
        update caschd set status ='S' where camastid = p_camastid and deltd <> 'Y' and status ='A';
        pr_tuning_log('sp_demo_send_cop_action', '  End update caschd status :' || p_camastid );
        commit;

    end if;
    pr_tuning_log('sp_demo_send_cop_action', 'End send coporate action :' || p_camastid );
end;

 
 
 
 
/
