SET DEFINE OFF;
CREATE OR REPLACE PROCEDURE "SP_RM_EXECTXREQ"
(
    p_errcode in out varchar2,
    p_reqid in number,
    p_reqtrancode in varchar2,
    p_batchid in varchar2,
    p_version in varchar2,
    p_rdate in varchar2
)
IS
    v_strbankcode varchar2(100);
    v_strtrfcode varchar2(100);
    v_strtxdate varchar2(10);
    v_straffectdate varchar2(10);
    v_strafacctno varchar2(100);
    v_strnote varchar2(5000);
    v_trflogid number(20,0);
    v_strrversion varchar2(100);
    v_strrdate varchar2(10);
    v_strrstatus varchar2(10);
    v_dbltxamt number(20,0);
BEGIN
p_errcode:='0';

SELECT BANKCODE,TRFCODE,TO_CHAR(TXDATE,'DD/MM/RRRR') TXDATE,AFFECTDATE,AFACCTNO,TXAMT,NOTES
INTO v_strbankcode,v_strtrfcode,v_strtxdate,v_straffectdate,v_strafacctno,v_dbltxamt,v_strnote
FROM CRBTXREQ WHERE REQID=p_reqid;

IF p_version<>'N/A' THEN
    BEGIN
        UPDATE CRBTRFLOG SET VERSIONLOCAL=p_batchid, STATUS='S', SENDTST=SYSDATE
        WHERE VERSION=TO_NUMBER(p_version) AND REFBANK=v_strbankcode AND TRFCODE=v_strtrfcode
        AND TXDATE=TO_DATE(p_rdate,'DD/MM/RRRR');

        UPDATE CRBTRFLOGDTL SET ITEMTRANCODE=p_reqtrancode,STATUS='S'
        WHERE REFREQID=p_reqid AND VERSION=TO_NUMBER(p_version)
        AND TRFCODE=v_strtrfcode AND TXDATE=TO_DATE(p_rdate,'DD/MM/RRRR');
    END;
ELSE
    BEGIN
        BEGIN
            SELECT VERSION,TXDATE,STATUS INTO v_strrversion,v_strrdate,v_strrstatus FROM (
                SELECT * FROM CRBTRFLOG
                WHERE REFBANK=v_strbankcode AND TRFCODE=v_strtrfcode
                AND TXDATE>=TO_DATE(v_strtxdate,'DD/MM/RRRR')
                AND STATUS IN ('P','A','S')
                ORDER BY TXDATE DESC,VERSION DESC
            ) WHERE ROWNUM<=1;
        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                BEGIN
                    v_strrversion:=NULL;
                    v_strrdate:=NULL;
                    v_strrstatus:=NULL;
                END;
        END;

        IF v_strrversion IS NOT NULL THEN
            BEGIN
                INSERT INTO CRBTRFLOGDTL (AUTOID, VERSION,BANKCODE,TRFCODE,TXDATE, REFREQID, AFACCTNO, AMT, REFNOTES, STATUS)
                VALUES(SEQ_CRBTRFLOGDTL.NEXTVAL,v_strrversion,v_strbankcode,v_strtrfcode,TO_DATE(v_strrdate,'DD/MM/RRRR'),
                p_reqid,v_strafacctno,v_dbltxamt,v_strnote,v_strrstatus);

                UPDATE CRBTXREQ SET STATUS='A' WHERE REQID=p_reqid;
            END;
        ELSE
            BEGIN
                v_strrdate:=v_strtxdate;
                v_strrstatus:='S';

                SELECT SEQ_CRBTRFLOG.NEXTVAL INTO v_trflogid FROM DUAL;

                SELECT  NVL(MAX(ODR)+1,1) INTO v_strrversion FROM
                (SELECT ROWNUM ODR, INVACCT
                FROM (SELECT VERSION INVACCT
                FROM CRBTRFLOG WHERE TXDATE=TO_DATE(v_strtxdate,'DD/MM/RRRR') AND TRFCODE=v_strtrfcode
                ORDER BY TO_NUMBER(VERSION)) WHERE TO_NUMBER(INVACCT)=ROWNUM) INVTAB;

                INSERT INTO CRBTRFLOG (AUTOID, VERSION, TXDATE, AFFECTDATE, TLID, CREATETST, REFBANK, TRFCODE, STATUS,ERRSTS, FEEDBACK)
                SELECT v_trflogid, v_strrversion, TO_DATE(v_strrdate,'DD/MM/RRRR'), TO_DATE(v_straffectdate,'DD/MM/RRRR'), '000',
                SYSTIMESTAMP, v_strbankcode, v_strtrfcode, v_strrstatus,'N', TO_CHAR(p_reqid) FROM DUAL;

                INSERT INTO CRBTRFLOGDTL (AUTOID, VERSION,BANKCODE,TRFCODE,TXDATE, REFREQID, AFACCTNO, AMT, REFNOTES, STATUS)
                VALUES(SEQ_CRBTRFLOGDTL.NEXTVAL,v_strrversion,v_strbankcode,v_strtrfcode,TO_DATE(v_strrdate,'DD/MM/RRRR'),
                p_reqid,v_strafacctno,v_dbltxamt,v_strnote,v_strrstatus);

                UPDATE CRBTXREQ SET STATUS='A' WHERE REQID=p_reqid;
            END;
        END IF;
    END;
END IF;

COMMIT;
p_errcode:='0';
EXCEPTION
    WHEN OTHERS THEN
        p_errcode:='1';
END; -- Procedure

 
 
 
 
/
