SET DEFINE OFF;
CREATE OR REPLACE TRIGGER TRG_AF_SMSMONITORMANAGER 
BEFORE INSERT ON SMSMonitorManager 
FOR EACH ROW
BEGIN
  SELECT SEQ_SMSMonitorManager.NEXTVAL
  INTO   :new.autoid
  FROM   dual;
END
;
/
