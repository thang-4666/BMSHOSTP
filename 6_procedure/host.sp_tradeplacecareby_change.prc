SET DEFINE OFF;
CREATE OR REPLACE PROCEDURE sp_tradeplacecareby_change
   ( p_tradeid IN Varchar2,
     p_grpid IN Varchar2,
     p_type IN Varchar2,
     p_tlid IN Varchar2
     )
   IS
BEGIN
    if p_type = 'REMOVE' then --Xoa thong tin careby cua nhom trc khi insert lai
        for rec in (select * from TRADECAREBY where tradeid = p_tradeid)
        loop
            INSERT INTO MAINTAIN_LOG (TABLE_NAME,RECORD_KEY,MAKER_ID,MAKER_DT,APPROVE_RQD,APPROVE_ID,APPROVE_DT,MOD_NUM,COLUMN_NAME,FROM_VALUE,TO_VALUE,ACTION_FLAG,CHILD_TABLE_NAME,CHILD_RECORD_KEY,MAKER_TIME,APPROVE_TIME)
            VALUES('TRADEPLACE','TRAID = ''' || rec.tradeid || '''',p_tlid,getcurrdate,'N',NULL ,NULL,0,'TRADEID',
                rec.tradeid,NULL ,'DELETE','TRADECAREBY','GRPID = ''' || rec.grpid || '''',TO_CHAR(SYSDATE, 'HH24:MI:SS'),NULL);

            INSERT INTO MAINTAIN_LOG (TABLE_NAME,RECORD_KEY,MAKER_ID,MAKER_DT,APPROVE_RQD,APPROVE_ID,APPROVE_DT,MOD_NUM,COLUMN_NAME,FROM_VALUE,TO_VALUE,ACTION_FLAG,CHILD_TABLE_NAME,CHILD_RECORD_KEY,MAKER_TIME,APPROVE_TIME)
            VALUES('TRADEPLACE','TRAID = ''' || rec.tradeid || '''',p_tlid,getcurrdate,'N',NULL ,NULL,0,'GRPID',
                rec.grpid,NULL ,'DELETE','TRADECAREBY','GRPID = ''' || rec.grpid || '''',TO_CHAR(SYSDATE, 'HH24:MI:SS'),NULL);
        end loop;

        delete from TRADECAREBY where tradeid = p_tradeid;
        Commit;
    ELSIF p_type = 'ADD' then -- Insert lai careby vao cho nhom
        Delete from TRADECAREBY Where grpid = p_grpid;
        Insert into TRADECAREBY (tradeid, grpid) values (p_tradeid, p_grpid);

        INSERT INTO MAINTAIN_LOG (TABLE_NAME,RECORD_KEY,MAKER_ID,MAKER_DT,APPROVE_RQD,APPROVE_ID,APPROVE_DT,MOD_NUM,COLUMN_NAME,FROM_VALUE,TO_VALUE,ACTION_FLAG,CHILD_TABLE_NAME,CHILD_RECORD_KEY,MAKER_TIME,APPROVE_TIME)
        VALUES('TRADEPLACE','TRAID = ''' || p_tradeid || '''',p_tlid,getcurrdate,'N',NULL ,NULL,0,'TRADEID',
            NULL,p_tradeid ,'ADD','TRADECAREBY','GRPID = ''' || p_grpid || '''',TO_CHAR(SYSDATE, 'HH24:MI:SS'),NULL);

        INSERT INTO MAINTAIN_LOG (TABLE_NAME,RECORD_KEY,MAKER_ID,MAKER_DT,APPROVE_RQD,APPROVE_ID,APPROVE_DT,MOD_NUM,COLUMN_NAME,FROM_VALUE,TO_VALUE,ACTION_FLAG,CHILD_TABLE_NAME,CHILD_RECORD_KEY,MAKER_TIME,APPROVE_TIME)
        VALUES('TRADEPLACE','TRAID = ''' || p_tradeid || '''',p_tlid,getcurrdate,'N',NULL ,NULL,0,'GRPID',
            NULL,p_grpid ,'ADD','TRADECAREBY','GRPID = ''' || p_grpid || '''',TO_CHAR(SYSDATE, 'HH24:MI:SS'),NULL);

        Commit;
    end if;
EXCEPTION
    WHEN OTHERS THEN
    RETURN ;
END; -- Procedure

 
 
 
 
/
