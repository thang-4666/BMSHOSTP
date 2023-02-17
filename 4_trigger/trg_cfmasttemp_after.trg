SET DEFINE OFF;
CREATE OR REPLACE TRIGGER TRG_CFMASTTEMP_AFTER 
 AFTER
  INSERT
 ON cfmasttemp
REFERENCING NEW AS NEWVAL OLD AS OLDVAL
 FOR EACH ROW
DECLARE
    -- local variables here
  v_str_datasource VARCHAR2(1000);
BEGIN
    -- gui email thong bao dang ky thanh cong

    IF NMPKS_EMS.CHECKEMAIL(:NEWVAL.EMAIL) THEN
    v_str_datasource := 'select ''' || :newval.idcode || ''' idcode, '''
                                    || :newval.mobile || ''' mobile from dual' ;
        INSERT INTO EMAILLOG
            (AUTOID,  EMAIL, DATASOURCE, CREATETIME, STATUS, TEMPLATEID)
        VALUES
            (SEQ_EMAILLOG.NEXTVAL,

             :NEWVAL.EMAIL,
             V_STR_DATASOURCE,
             getcurrdate,
             'A',
             '0225');
    END IF;

END TRG_CFMASTTEMP_AFTER;
/
