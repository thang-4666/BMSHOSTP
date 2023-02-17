SET DEFINE OFF;
CREATE OR REPLACE PROCEDURE pr_insertlogplaceorder(v_txnum  varchar2,
                                 v_txdate Date,
                                 v_ipaddress  VARCHAR2,
                                 v_via  varchar2,
                                 v_otauthtype  varchar2,
                                 v_devicetype  VARCHAR2,
                                 v_device      VARCHAR2,
                                 v_username   VARCHAR2,
                                 v_acctno      VARCHAR2,
                                 v_errcode     VARCHAR2,
                                 v_model VARCHAR2,
                                 v_versionDevice VARCHAR2,
                                 v_versionCode VARCHAR2,
                                 v_type VARCHAR2)
is
BEGIN
  IF (v_txnum IS NOT NULL OR v_txdate IS NOT NULL OR v_ipaddress IS NOT NULL or v_via IS NOT NULL or
      v_otauthtype IS NOT NULL OR v_devicetype IS NOT NULL OR v_device IS NOT NULL or
      v_errcode IS NOT NULL or v_username IS NOT NULL or v_acctno IS NOT NULL ) THEN

    insert into logplaceorder (AUTOID, TXNUM, TXDATE, IPADDRESS, VIA, OTAUTHTYPE, DEVICETYPE, DEVICE, ERRORCODE, SYSDATES, USERNAME, ACCTNO,MODEL,VERSIONDEVICE,VERSIONCODE,TYPE)
    values (seq_iplog.nextval , v_txnum, v_txdate, v_ipaddress, v_via, v_otauthtype, v_devicetype, v_device, v_errcode,SYSDATE, v_username, v_acctno,
            v_model, v_versionDevice, v_versionCode, v_type);

  END IF;
end pr_insertlogplaceorder;
/
