SET DEFINE OFF;
CREATE OR REPLACE TRIGGER TRG_AFMAST_AFTER 
 AFTER 
 INSERT OR UPDATE
 ON AFMAST
 REFERENCING OLD AS OLDVAL NEW AS NEWVAL
 FOR EACH ROW
declare
    --v_afacctno varchar2(20);
    --v_errmsg varchar2(10000);
    v_CUSTODYCD varchar2(20);
    v_CAREBY varchar2(20);
begin
    if fopks_api.fn_is_ho_active then
        /*v_afacctno := :newval.acctno;
        msgpks_system.sp_notification_obj('AFMAST',
                                          :newval.acctno,
                                          v_afacctno);*/

        --Log trigger for buffer if modify advancedline
        -- TheNN, 04-Feb-2012
        IF :newval.ADVANCELINE <> :oldval.ADVANCELINE or :newval.AUTOADV <> :oldval.AUTOADV
            OR :NEWVAL.MRCRLIMITMAX <> :OLDVAL.MRCRLIMITMAX OR :NEWVAL.MRCRLIMIT <> :OLDVAL.MRCRLIMIT OR :NEWVAL.CLAMTLIMIT <> :OLDVAL.CLAMTLIMIT  THEN
            jbpks_auto.pr_trg_account_log(:newval.acctno,'CI');
        END IF;
        --End Log trigger for buffer
    end if;
    ---DungNH log lai thay doi truong MRCRLIMITMAX
    --NGOC.VU log lai theo issiu VCBSDEPII-467
    if updating and :newval.MRCRLIMITMAX <> :oldval.MRCRLIMITMAX then
       /* INSERT INTO AFMAST_LOG (AUTOID, TXDATE, FIELD,TXTYPE,AMT,ACCTNO,DELTD)
        VALUES (SEQ_AFMAST_LOG.NEXTVAL,GETCURRDATE,'MRCRLIMITMAX','D',:oldval.MRCRLIMITMAX,:newval.acctno,'N');

        INSERT INTO AFMAST_LOG (AUTOID, TXDATE, FIELD,TXTYPE,AMT,ACCTNO,DELTD)
        VALUES (SEQ_AFMAST_LOG.NEXTVAL,GETCURRDATE,'MRCRLIMITMAX','C',:newval.MRCRLIMITMAX,:newval.acctno,'N');
        */
        if :newval.MRCRLIMITMAX > :oldval.MRCRLIMITMAX then
          
        INSERT INTO AFMAST_LOG (AUTOID, TXDATE, FIELD,TXTYPE,AMT,ACCTNO,DELTD, O_AMT,N_AMT)
        VALUES (SEQ_AFMAST_LOG.NEXTVAL,GETCURRDATE,'MRCRLIMITMAX','C',:newval.MRCRLIMITMAX - :oldval.MRCRLIMITMAX,:newval.acctno,'N',:oldval.MRCRLIMITMAX,:newval.MRCRLIMITMAX);
        
        else
          
        INSERT INTO AFMAST_LOG (AUTOID, TXDATE, FIELD,TXTYPE,AMT,ACCTNO,DELTD, O_AMT,N_AMT)
        VALUES (SEQ_AFMAST_LOG.NEXTVAL,GETCURRDATE,'MRCRLIMITMAX','D',:oldval.MRCRLIMITMAX - :newval.MRCRLIMITMAX,:newval.acctno,'N',:oldval.MRCRLIMITMAX,:newval.MRCRLIMITMAX);
        end if;

      end if;
    if INSERTING and :newval.MRCRLIMITMAX > 0 then
      
        INSERT INTO AFMAST_LOG (AUTOID, TXDATE, FIELD,TXTYPE,AMT,ACCTNO,DELTD, O_AMT,N_AMT)
        VALUES (SEQ_AFMAST_LOG.NEXTVAL,GETCURRDATE,'MRCRLIMITMAX','C',:newval.MRCRLIMITMAX,:newval.acctno,'N',0,:newval.MRCRLIMITMAX);
        
       --INSERT INTO AFMAST_LOG (AUTOID, TXDATE, FIELD,TXTYPE,AMT,ACCTNO,DELTD)
       -- VALUES (SEQ_AFMAST_LOG.NEXTVAL,GETCURRDATE,'MRCRLIMITMAX','C',:newval.MRCRLIMITMAX,:newval.acctno,'N');
    
    end if;
    ---end DungNH
    
end;
/
