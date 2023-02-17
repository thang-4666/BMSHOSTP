SET DEFINE OFF;
CREATE OR REPLACE package pck_gw_ultility is

  -- Author  : duyanh.hoang
  -- Created : 05-Aug-2021
  -- Purpose : Contain GW Function
  
  PROCEDURE pr_receive_message (p_msgGroup   VARCHAR2,
                                p_msgType    VARCHAR2,
                                p_msgXml     VARCHAR2,
                                p_gwtype     VARCHAR2);

  PROCEDURE pr_update_gwstatus (p_value   VARCHAR2,
                                p_desc    VARCHAR2,
                                p_gwtype  VARCHAR2);

  PROCEDURE pr_get_order (p_refCuror  IN OUT pkg_report.ref_cursor,
                          p_msgType   VARCHAR2,
                          p_gwtype    VARCHAR2);

end pck_gw_ultility;
/


CREATE OR REPLACE PACKAGE BODY pck_gw_ultility IS
  --pkgctx plog.log_ctx;
  --logrow tlogdebug%ROWTYPE;

  GW_HSX CONSTANT VARCHAR2(10) := 'hsx';
  GW_HNX CONSTANT VARCHAR2(10) := 'hnx';
  L_INVALID_GWTYPE_EXCEPTION   EXCEPTION;
  PRAGMA EXCEPTION_INIT( L_INVALID_GWTYPE_EXCEPTION, -100000 );

  PROCEDURE pr_receive_message (p_msgGroup   VARCHAR2,
                                p_msgType    VARCHAR2,
                                p_msgXml     VARCHAR2,
                                p_gwtype     VARCHAR2)
  IS
  BEGIN
    plog.error('day la log pr_receive_message: '||p_gwtype);
    IF p_gwtype = GW_HSX THEN
      INSERT INTO msgreceivetemp (id, msg_date, msggroup, msgtype, msgxml, process)
      VALUES (seq_msgreceivetemp.nextval, SYSDATE, p_msgGroup, p_msgType, p_msgXml, 'N');

    ELSIF p_gwtype = GW_HNX THEN
      INSERT INTO msgreceivetemp_ha (id, msg_date, msggroup, msgtype, msgxml, process)
      VALUES (seq_msgreceivetemp.nextval, SYSDATE, p_msgGroup, p_msgType, p_msgXml, 'N');

    ELSE
      RAISE L_INVALID_GWTYPE_EXCEPTION;
    END IF;
  END;

  PROCEDURE pr_update_gwstatus (p_value   VARCHAR2,
                                p_desc    VARCHAR2,
                                p_gwtype  VARCHAR2)
  IS
  BEGIN
    plog.error('day la log p_value: '||p_value);
    IF p_gwtype = GW_HSX THEN
      UPDATE ordersys SET sysvalue = p_value, sysdesc = p_desc WHERE sysname = 'HOSEGWSTATUS';

    ELSIF p_gwtype = GW_HNX THEN
      UPDATE ordersys SET sysvalue = p_value WHERE sysname = 'HOSEGWSTATUS';

    ELSE
      RAISE L_INVALID_GWTYPE_EXCEPTION;
    END IF;
  END;

  PROCEDURE pr_get_order (p_refCuror  IN OUT pkg_report.ref_cursor,
                          p_msgType   VARCHAR2,
                          p_gwtype    VARCHAR2)
  IS
  BEGIN
    IF p_gwtype = GW_HSX THEN
      pck_hogw.PRC_GETORDER(p_refCuror, p_msgType);

    ELSIF p_gwtype = GW_HNX THEN
      pck_hagw.PRC_GETORDER(p_refCuror, p_msgType);

    ELSE
      RAISE L_INVALID_GWTYPE_EXCEPTION;
    END IF;
  END;

BEGIN
  NULL;
  /*FOR i IN (SELECT * FROM tlogdebug) LOOP
    logrow.loglevel  := i.loglevel;
    logrow.log4table := i.log4table;
    logrow.log4alert := i.log4alert;
    logrow.log4trace := i.log4trace;
  END LOOP;

  pkgctx := plog.init('pck_gw_ultility',
            plevel => NVL(logrow.loglevel,30),
            plogtable => (NVL(logrow.log4table,'Y') = 'Y'),
            palert => (logrow.log4alert = 'Y'),
            ptrace => (logrow.log4trace = 'Y'));*/

END pck_gw_ultility;
/
