SET DEFINE OFF;
CREATE OR REPLACE PROCEDURE pr_revert_trading_allocating(p_orderid varchar2) is
--v_orderrow odmast%rowtype;
v_tllogrow tllog%rowtype;
v_aamt number;
v_aqtty number;
begin
    for rec_orderrow in
    (
    select * from odmast where orderid = p_orderid and errod ='N'
    )
    loop

        SELECT SUM(AAMT), SUM(AQTTY) INTO v_aamt, v_aqtty FROM STSCHD WHERE ORGORDERID = p_orderid;

        IF v_aamt > 0 or v_aqtty > 0 THEN
            dbms_output.put_line('Error: Da thuc hien ung truoc/cam co, ko duoc revert!');
            rollback;
        ELSE
            -- REVERT TLLOG
             UPDATE TLLOG SET DELTD = 'Y' WHERE TLTXCD in( '8804','8809','8814') AND MSGACCT = p_orderid;

             FOR I IN (SELECT * FROM TLLOG WHERE TLTXCD in( '8804','8809','8814') AND MSGACCT = p_orderid)
             LOOP
                 SELECT * INTO v_tllogrow FROM TLLOG WHERE TLTXCD in( '8804','8809','8814') AND MSGACCT = p_orderid AND TXNUM = i.TXNUM;
                 -- REVERT TLLOGFLD
                 --DELETE TLLOGFLD WHERE TXNUM = v_tllogrow.TXNUM;

                 -- REVERT AFTRAN
                 UPDATE AFTRAN SET DELTD = 'Y' WHERE TXNUM = v_tllogrow.TXNUM;
              /*   IF SQL%ROWCOUNT <> 1 THEN
                     dbms_output.put_line('Error: Duplicate AFTRAN. Going to rollback');
                     rollback;
                 END IF;*/

                 -- REVERT ODTRAN
                 UPDATE ODTRAN SET DELTD = 'Y' WHERE TXNUM = v_tllogrow.TXNUM AND ACCTNO = p_orderid;
                 secnet_un_map(v_tllogrow.txnum,to_char(v_tllogrow.txdate,'DD/MM/RRRR'));
             END LOOP;


/*             -- REVERT AFMAST
             UPDATE      afmast
             SET         dmatchamt = NVL(dmatchamt,0) - rec_orderrow.MATCHAMT
             WHERE       acctno = rec_orderrow.AFACCTNO;
             IF SQL%ROWCOUNT <> 1 THEN
                dbms_output.put_line('Error: Duplicate AFMAST. Going to rollback');
                rollback;
             END IF;*/

             -- REVERT IOD
             DELETE      IOD
             WHERE       ORGORDERID = p_orderid;

             -- REVERT odchanging_trigger_log
             DELETE      odchanging_trigger_log
             WHERE       orderid = p_orderid;

             -- REVERT orderdeal
             DELETE      orderdeal
             WHERE       orderid = p_orderid;

             -- REVERT ODMAST
             UPDATE odmast
             SET         execamt = NVL(execamt,0) - rec_orderrow.EXECAMT,
                         execqtty = NVL(execqtty,0) - rec_orderrow.EXECQTTY,
                         matchamt = NVL(matchamt,0) - rec_orderrow.MATCHAMT,
                         orstatus = '2',
                         --cancelqtty = cancelqtty - rec_orderrow.CANCELQTTY,
                         --remainqtty = remainqtty + rec_orderrow.EXECQTTY + rec_orderrow.CANCELQTTY,
                         remainqtty = remainqtty + rec_orderrow.EXECQTTY,
                         last_change = SYSTIMESTAMP
             WHERE       orderid = p_orderid;

             -- REVERT STSCHD
             DELETE      STSCHD
             WHERE       ORGORDERID = p_orderid;
            --        COMMIT;
        END IF;


    end loop;
end;

 
 
 
 
 
 
 
 
 
 
 
/
