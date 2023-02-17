SET DEFINE OFF;
CREATE OR REPLACE PROCEDURE pr_insertiplog (v_txnum  varchar2,
                                           v_txdate Date,
                                           v_ipaddress  VARCHAR2,
                                           v_via  varchar2,
                                           v_otauthtype  varchar2,
                                           v_devicetype  VARCHAR2,
                                           v_device      VARCHAR2,
                                           v_note     VARCHAR2,
                                           v_input    VARCHAR2 default '')
IS
BEGIN
    --Them vao bang IPLOG.
       IF (v_txnum IS NOT NULL And v_txdate IS NOT NULL And v_ipaddress IS NOT NULL And v_via IS NOT NULL) THEN
          insert into iplog (AUTOID, TXNUM, TXDATE, IPADDRESS, VIA, OTAUTHTYPE, DEVICETYPE, DEVICE, NOTE, SYSDATES, INPUT)
          values (seq_iplog.nextval , v_txnum, v_txdate, substr(v_ipaddress,1,200), v_via, v_otauthtype, v_devicetype, v_device, v_note,SYSDATE, v_input);
    END IF;
end;
/
