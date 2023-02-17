SET DEFINE OFF;
CREATE OR REPLACE PACKAGE pck_homsg
is
 /*----------------------------------------------------------------------------------------------------
     ** Module   : COMMODITY SYSTEM
     ** and is copyrighted by FSS.
     **
     **    All rights reserved.  No part of this work may be reproduced, stored in a retrieval system,
     **    adopted or transmitted in any form or by any means, electronic, mechanical, photographic,
     **    graphic, optic recording or otherwise, translated in any language or computer language,
     **    without the prior written permission of Financial Software Solutions. JSC.
     **
     **  MODIFICATION HISTORY
     **  Person      Date           Comments
     **  Phuongntn    06/11/2014    Created
     ** (c) 2009 by Financial Software Solutions. JSC.
     ----------------------------------------------------------------------------------------------------*/
 Procedure PRC_2B(v_orderid VARCHAR2);
 Procedure PRC_2B_deal(v_orderid VARCHAR2);
 Procedure PRC_2C(v_orderid VARCHAR2,v_cancel_shares VARCHAR2);
 Procedure PRC_2D(v_orderid VARCHAR2,v_price VARCHAR2);
 Procedure PRC_2E(v_orderid VARCHAR2, v_volume VARCHAR2,v_price VARCHAR2, v_confirm_number VARCHAR2 );
 Procedure PRC_2E_deal(v_order_number VARCHAR2,v_orderid VARCHAR2, v_volume VARCHAR2,v_price VARCHAR2, v_confirm_number VARCHAR2 );
 Procedure PRC_2I(v_orderid_buy VARCHAR2,v_orderid_sell VARCHAR2,  v_volume VARCHAR2,v_price VARCHAR2, v_confirm_number VARCHAR2 );
  Procedure PRC_2I_deal(v_orderid_buy VARCHAR2,v_orderid_sell VARCHAR2,  v_volume VARCHAR2,v_price VARCHAR2, v_confirm_number VARCHAR2 );
 Procedure PRC_2F(firm_buy VARCHAR2,trader_id_buy VARCHAR2, contra_firm_sell VARCHAR2,trader_id_contra_side_sell VARCHAR2, security_symbol VARCHAR2, volume VARCHAR2 ,price VARCHAR2,confirm_number  VARCHAR2);
 Procedure PRC_2G(v_orderid VARCHAR2,msg_type VARCHAR2, reject_reason_code VARCHAR2 );
 Procedure PRC_2L(side VARCHAR2,v_orderid VARCHAR2, confirm_number VARCHAR2, volume VARCHAR2, price VARCHAR2, firm VARCHAR2);
 Procedure PRC_3D(reply_code VARCHAR2, confirm_number VARCHAR2, firm VARCHAR2);
 Procedure PRC_3C(firm VARCHAR2,contra_firm VARCHAR2, trader_id VARCHAR2, side VARCHAR2, security_symbol VARCHAR2, confirm_number VARCHAR2);
 Procedure PRC_3B(reply_code VARCHAR2,v_orderid VARCHAR2, firm VARCHAR2);
 Procedure PRC_SU(halt_resume_flag VARCHAR2,ceiling_price VARCHAR2,floor_price VARCHAR2,suspension VARCHAR2,delist VARCHAR2,security_number_new VARCHAR2   ,security_symbol VARCHAR2, highest_price VARCHAR2,lowest_price VARCHAR2, prior_close_price VARCHAR2, last_sale_price VARCHAR2 );
 Procedure PRC_SS(ceiling VARCHAR2,floor_price VARCHAR2,prior_close_price varchar2, halt_resume_flag VARCHAR2,suspension VARCHAR2,delist VARCHAR2,security_number VARCHAR2 );
 Procedure PRC_SC(Time_stamp VARCHAR2,System_Control_Code VARCHAR2 );
END;

 
 
 
 
/


CREATE OR REPLACE PACKAGE BODY pck_homsg IS
  pkgctx plog.log_ctx;
  logrow tlogdebug%ROWTYPE;
  v_CheckProcess Boolean;
  ----------------------------------------------
  --SS: PRC_SS(security_type VARCHAR2,ceiling VARCHAR2,floor_price VARCHAR2,prior_close_price VARCHAR2
  --,halt_resume_flag VARCHAR2,suspension VARCHAR2,delist VARCHAR2,security_number VARCHAR2 )
  ----------------------------------------------
 Procedure PRC_SS(ceiling VARCHAR2,floor_price VARCHAR2,prior_close_price varchar2, halt_resume_flag VARCHAR2,suspension VARCHAR2,delist VARCHAR2,security_number VARCHAR2 )
   is
  xmlTemp VARCHAR2(4000);
  v_id NUMBER;
  BEGIN
  plog.setbeginsection (pkgctx, 'PRC_SS');
  xmlTemp:='<?xml version="1.0" encoding="utf-8"?><ArrayOfHoSEMessageEntry xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"><hoSEMessageEntry><key>board_lot</key><value>10</value></hoSEMessageEntry><hoSEMessageEntry><key>floor_price</key><value>@floor_price@</value></hoSEMessageEntry><hoSEMessageEntry><key>benefit</key><value> </value></hoSEMessageEntry><hoSEMessageEntry><key>suspension</key><value>@suspension@</value></hoSEMessageEntry><hoSEMessageEntry><key>sector_number</key><value>1</value></hoSEMessageEntry><hoSEMessageEntry><key>system_control_code</key><value> </value></hoSEMessageEntry><hoSEMessageEntry><key>ceiling</key><value>@ceiling@</value></hoSEMessageEntry><hoSEMessageEntry><key>meeting</key><value> </value></hoSEMessageEntry><hoSEMessageEntry><key>security_number</key><value>@security_number@</value></hoSEMessageEntry><hoSEMessageEntry><key>filler_6</key><value> </value></hoSEMessageEntry><hoSEMessageEntry><key>halt_resume_flag</key><value>@halt_resume_flag@</value></hoSEMessageEntry><hoSEMessageEntry><key>filler_5</key><value>    </value></hoSEMessageEntry><hoSEMessageEntry><key>prior_close_price</key><value>@prior_close_price@</value></hoSEMessageEntry><hoSEMessageEntry><key>filler_4</key><value> </value></hoSEMessageEntry><hoSEMessageEntry><key>split</key><value> </value></hoSEMessageEntry><hoSEMessageEntry><key>filler_3</key><value> </value></hoSEMessageEntry><hoSEMessageEntry><key>security_type</key><value>@security_type@</value></hoSEMessageEntry><hoSEMessageEntry><key>delist</key><value>@delist@</value></hoSEMessageEntry><hoSEMessageEntry><key>filler_2</key><value> </value></hoSEMessageEntry><hoSEMessageEntry><key>notice</key><value> </value></hoSEMessageEntry><hoSEMessageEntry><key>filler_1</key><value> </value></hoSEMessageEntry></ArrayOfHoSEMessageEntry>';
  select   REPLACE(xmlTemp,'@prior_close_price@',prior_close_price) into xmlTemp from dual;
  select   REPLACE(xmlTemp,'@halt_resume_flag@',halt_resume_flag) into xmlTemp from dual;
  select   REPLACE(xmlTemp,'@ceiling@',ceiling) into xmlTemp from dual;
  select   REPLACE(xmlTemp,'@floor_price@',floor_price) into xmlTemp from dual;
  select   REPLACE(xmlTemp,'@suspension@',suspension) into xmlTemp from dual;
  select   REPLACE(xmlTemp,'@delist@',delist) into xmlTemp from dual;
  select   REPLACE(xmlTemp,'@security_number@',security_number) into xmlTemp from dual;

  SELECT  seq_msgid.nextval Into v_id From dual;
  insert into msgreceivetemp (ID, MSG_DATE, MSGGROUP, MSGTYPE, MSGXML, PROCESS)
          values  (v_id , getcurrdate, 'PRS', 'SS', xmlTemp, 'N');
  COMMIT;
  plog.setendsection (pkgctx, 'PRC_SS');
  EXCEPTION WHEN OTHERS THEN
    plog.error(pkgctx, SQLERRM);
    plog.setendsection (pkgctx, 'PRC_SS');
    RAISE errnums.E_SYSTEM_ERROR;
  END PRC_SS;
  ----------------------------------------------
  --SU:  PRC_SU(security_type VARCHAR2,halt_resume_flag VARCHAR2,ceiling_price VARCHAR2,floor_price VARCHAR2
  --,prior_close_price VARCHAR2,lowest_price VARCHAR2,highest_price VARCHAR2   ,last_sale_price VARCHAR2
  --,open_price VARCHAR2,suspension VARCHAR2,delist VARCHAR2,security_number_new VARCHAR2
  --  ,security_symbol VARCHAR2,board_lot VARCHAR2)
  ----------------------------------------------
 Procedure PRC_SU(halt_resume_flag VARCHAR2,ceiling_price VARCHAR2,floor_price VARCHAR2,suspension VARCHAR2,delist VARCHAR2,security_number_new VARCHAR2   ,security_symbol VARCHAR2, highest_price VARCHAR2,lowest_price VARCHAR2, prior_close_price VARCHAR2, last_sale_price VARCHAR2 )
    is
  xmlTemp VARCHAR2(4000);
  v_id NUMBER;
  v_order_number VARCHAR2(20);  BEGIN
  plog.setbeginsection (pkgctx, 'PRC_SU');
  xmlTemp:='<?xml version="1.0" encoding="utf-8"?><ArrayOfHoSEMessageEntry xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"><hoSEMessageEntry><key>floor_price</key><value>@floor_price@</value></hoSEMessageEntry><hoSEMessageEntry><key>benefit</key><value> </value></hoSEMessageEntry><hoSEMessageEntry><key>ceiling_price</key><value>@ceiling_price@</value></hoSEMessageEntry><hoSEMessageEntry><key>open_price</key><value>0</value></hoSEMessageEntry><hoSEMessageEntry><key>security_name</key><value>CTCP VAT TU XANG DAU     </value></hoSEMessageEntry><hoSEMessageEntry><key>security_number_new</key><value>@security_number_new@</value></hoSEMessageEntry><hoSEMessageEntry><key>halt_resume_flag</key><value>@halt_resume_flag@</value></hoSEMessageEntry><hoSEMessageEntry><key>prior_close_price</key><value>@prior_close_price@</value></hoSEMessageEntry><hoSEMessageEntry><key>notice</key><value> </value></hoSEMessageEntry><hoSEMessageEntry><key>delist</key><value>@delist@</value></hoSEMessageEntry><hoSEMessageEntry><key>par_value</key><value>1000</value></hoSEMessageEntry><hoSEMessageEntry><key>total_shares_traded</key><value>0</value></hoSEMessageEntry><hoSEMessageEntry><key>security_number_old</key><value>574</value></hoSEMessageEntry><hoSEMessageEntry><key>board_lot</key><value>10</value></hoSEMessageEntry><hoSEMessageEntry><key>highest_price</key><value>@highest_price@</value></hoSEMessageEntry><hoSEMessageEntry><key>suspension</key><value>@suspension@</value></hoSEMessageEntry><hoSEMessageEntry><key>sector_number</key><value>1</value></hoSEMessageEntry><hoSEMessageEntry><key>client_id_required</key><value> </value></hoSEMessageEntry><hoSEMessageEntry><key>sdc_flag</key><value> </value></hoSEMessageEntry><hoSEMessageEntry><key>total_values_traded</key><value>0</value></hoSEMessageEntry><hoSEMessageEntry><key>prior_close_date</key><value>20140113</value></hoSEMessageEntry><hoSEMessageEntry><key>market_id</key><value>A</value></hoSEMessageEntry><hoSEMessageEntry><key>meeting</key><value> </value></hoSEMessageEntry><hoSEMessageEntry><key>security_symbol</key><value>@security_symbol@</value></hoSEMessageEntry><hoSEMessageEntry><key>filler_5</key><value> </value></hoSEMessageEntry><hoSEMessageEntry><key>split</key><value> </value></hoSEMessageEntry><hoSEMessageEntry><key>filler_4</key><value> </value></hoSEMessageEntry><hoSEMessageEntry><key>security_type</key><value>S</value></hoSEMessageEntry><hoSEMessageEntry><key>filler_3</key><value>   </value></hoSEMessageEntry><hoSEMessageEntry><key>lowest_price</key><value>@lowest_price@</value></hoSEMessageEntry><hoSEMessageEntry><key>filler_2</key><value> </value></hoSEMessageEntry><hoSEMessageEntry><key>filler_1</key><value> </value></hoSEMessageEntry><hoSEMessageEntry><key>last_sale_price</key><value>@last_sale_price@</value></hoSEMessageEntry></ArrayOfHoSEMessageEntry>';
  select   REPLACE(xmlTemp,'@halt_resume_flag@',halt_resume_flag) into xmlTemp from dual;
  select   REPLACE(xmlTemp,'@ceiling_price@',ceiling_price) into xmlTemp from dual;
  select   REPLACE(xmlTemp,'@floor_price@',floor_price) into xmlTemp from dual;
  select   REPLACE(xmlTemp,'@lowest_price@',lowest_price) into xmlTemp from dual;
  select   REPLACE(xmlTemp,'@highest_price@',highest_price) into xmlTemp from dual;
  select   REPLACE(xmlTemp,'@suspension@',suspension) into xmlTemp from dual;
  select   REPLACE(xmlTemp,'@delist@',delist) into xmlTemp from dual;
  select   REPLACE(xmlTemp,'@security_number_new@',security_number_new) into xmlTemp from dual;
  select   REPLACE(xmlTemp,'@security_symbol@',security_symbol) into xmlTemp from dual;
  select   REPLACE(xmlTemp,'@prior_close_price@',prior_close_price) into xmlTemp from dual;
  select   REPLACE(xmlTemp,'@last_sale_price@',last_sale_price) into xmlTemp from dual;

  SELECT  seq_msgid.nextval Into v_id From dual;
  insert into msgreceivetemp (ID, MSG_DATE, MSGGROUP, MSGTYPE, MSGXML, PROCESS)
          values  (v_id , getcurrdate, 'PRS', 'SU', xmlTemp, 'N');
  COMMIT;
  plog.setendsection (pkgctx, 'PRC_SU');
  EXCEPTION WHEN OTHERS THEN
    plog.error(pkgctx, SQLERRM);
    plog.setendsection (pkgctx, 'PRC_SU');
    RAISE errnums.E_SYSTEM_ERROR;
  END PRC_SU;

  ----------------------------------------------
  --2B: So hieu lenh Flex
  ----------------------------------------------
 Procedure PRC_2B(v_orderid VARCHAR2)
    is
  xmlTemp VARCHAR2(4000);
  v_id NUMBER;
  order_number VARCHAR2(20);
  BEGIN
  plog.setbeginsection (pkgctx, 'PRC_2B');
   SELECT  CTCI_ORDER
        INTO  order_number
        FROM ORDERMAP
        WHERE ORGorderid= TRIM(v_orderid);
  xmlTemp:='<?xml version="1.0" encoding="utf-8"?><ArrayOfHoSEMessageEntry xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"><hoSEMessageEntry><key>order_number</key><value>@order_number@</value></hoSEMessageEntry><hoSEMessageEntry><key>firm</key><value>2  </value></hoSEMessageEntry><hoSEMessageEntry><key>order_entry_date</key><value>2001</value></hoSEMessageEntry></ArrayOfHoSEMessageEntry>';
  select   REPLACE(xmlTemp,'@order_number@',order_number) into xmlTemp from dual;
  SELECT  seq_msgid.nextval Into v_id From dual;
  insert into msgreceivetemp (ID, MSG_DATE, MSGGROUP, MSGTYPE, MSGXML, PROCESS)
          values  (v_id , getcurrdate, 'CTCI', '2B', xmlTemp, 'N');
  COMMIT;
  plog.setendsection (pkgctx, 'PRC_2B');
  EXCEPTION WHEN OTHERS THEN
    plog.error(pkgctx, SQLERRM);
    plog.setendsection (pkgctx, 'PRC_2B');
    RAISE errnums.E_SYSTEM_ERROR;
  END PRC_2B;
  ---------------------------------------
  Procedure PRC_2B_deal(v_orderid VARCHAR2)
    is
  xmlTemp VARCHAR2(4000);
  v_id NUMBER;
  order_number VARCHAR2(20);
  BEGIN
  plog.setbeginsection (pkgctx, 'PRC_2B_deal');
   SELECT  v_orderid
        INTO  order_number
        FROM dual; 
       -- WHERE ORGorderid= TRIM(v_orderid);
  xmlTemp:='<?xml version="1.0" encoding="utf-8"?><ArrayOfHoSEMessageEntry xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"><hoSEMessageEntry><key>order_number</key><value>@order_number@</value></hoSEMessageEntry><hoSEMessageEntry><key>firm</key><value>2  </value></hoSEMessageEntry><hoSEMessageEntry><key>order_entry_date</key><value>2001</value></hoSEMessageEntry></ArrayOfHoSEMessageEntry>';
  select   REPLACE(xmlTemp,'@order_number@',order_number) into xmlTemp from dual;
  SELECT  seq_msgid.nextval Into v_id From dual;
  insert into msgreceivetemp (ID, MSG_DATE, MSGGROUP, MSGTYPE, MSGXML, PROCESS)
          values  (v_id , getcurrdate, 'CTCI', '2B', xmlTemp, 'N');
  COMMIT;
  plog.setendsection (pkgctx, 'PRC_2B_deal');
  EXCEPTION WHEN OTHERS THEN
    plog.error(pkgctx, SQLERRM);
    plog.setendsection (pkgctx, 'PRC_2B_deal');
    RAISE errnums.E_SYSTEM_ERROR;
  END PRC_2B_deal;
   ----------------------------------------------
  --2C: So hieu lenh Flex, KL huy thanh cong
  ----------------------------------------------
 Procedure PRC_2C(v_orderid VARCHAR2,v_cancel_shares VARCHAR2)
    is
  xmlTemp VARCHAR2(4000);
  v_id NUMBER;
  v_order_number VARCHAR2(20);
  BEGIN
  plog.setbeginsection (pkgctx, 'PRC_2C');
   SELECT  CTCI_ORDER
        INTO  v_order_number
        FROM ORDERMAP
        WHERE ORGorderid= TRIM(v_orderid);
  xmlTemp:='<?xml version="1.0" encoding="utf-8"?><ArrayOfHoSEMessageEntry xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"><hoSEMessageEntry><key>order_number</key><value>@v_order_number@</value></hoSEMessageEntry><hoSEMessageEntry><key>firm</key><value>@v_firm@</value></hoSEMessageEntry><hoSEMessageEntry><key>order_entry_date</key><value>2001</value></hoSEMessageEntry><hoSEMessageEntry><key>cancel_shares</key><value>@v_cancel_shares@</value></hoSEMessageEntry><hoSEMessageEntry><key>order_cancel_status</key><value> </value></hoSEMessageEntry></ArrayOfHoSEMessageEntry>';
  select   REPLACE(xmlTemp,'@v_order_number@',trim(v_order_number)) into xmlTemp from dual;
  select   REPLACE(xmlTemp,'@v_cancel_shares@',trim(v_cancel_shares)) into xmlTemp from dual;
  SELECT  seq_msgid.nextval Into v_id From dual;
  insert into msgreceivetemp (ID, MSG_DATE, MSGGROUP, MSGTYPE, MSGXML, PROCESS)
          values  (v_id , getcurrdate, 'CTCI', '2C', xmlTemp, 'N');
  COMMIT;
  plog.setendsection (pkgctx, 'PRC_2C');
  EXCEPTION WHEN OTHERS THEN
    plog.error(pkgctx, SQLERRM);
    plog.setendsection (pkgctx, 'PRC_2C');
    RAISE errnums.E_SYSTEM_ERROR;
  END PRC_2C;
    ----------------------------------------------
  --2D: So hieu lenh Flex, gia dat cua lenh (lenh MP)
  ----------------------------------------------
 Procedure PRC_2D(v_orderid VARCHAR2,v_price VARCHAR2)
    is
  xmlTemp VARCHAR2(4000);
  v_id NUMBER;
  v_order_number VARCHAR2(20);
  BEGIN
  plog.setbeginsection (pkgctx, 'PRC_2D');
   SELECT  order_number
        INTO v_order_number
        FROM ho_1i
        WHERE orderid= TRIM(v_orderid)
      --  AND sendnum = (SELECT MAX(sendnum) FROM ho_1i WHERE orderid= TRIM(v_orderid))
      ;
      xmlTemp:='<?xml version="1.0" encoding="utf-8"?><ArrayOfHoSEMessageEntry xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"><hoSEMessageEntry><key>clientid</key><value>002FIS1588</value></hoSEMessageEntry><hoSEMessageEntry><key>orderentrydate</key><value>1802</value></hoSEMessageEntry><hoSEMessageEntry><key>price</key><value>9.5   </value></hoSEMessageEntry><hoSEMessageEntry><key>firm</key><value>2  </value></hoSEMessageEntry><hoSEMessageEntry><key>ordernumber</key><value>@v_ordernumber@</value></hoSEMessageEntry><hoSEMessageEntry><key>port_clientflag</key><value>F</value></hoSEMessageEntry><hoSEMessageEntry><key>filler</key><value>        </value></hoSEMessageEntry><hoSEMessageEntry><key>published_volume</key><value>        </value></hoSEMessageEntry></ArrayOfHoSEMessageEntry>';
      select   REPLACE(xmlTemp,'@v_price@',trim(v_price)) into xmlTemp from dual;
      select   REPLACE(xmlTemp,'@v_ordernumber@',trim(v_order_number)) into xmlTemp from dual;
  SELECT  seq_msgid.nextval Into v_id From dual;
  insert into msgreceivetemp (ID, MSG_DATE, MSGGROUP, MSGTYPE, MSGXML, PROCESS)
          values  (v_id , getcurrdate, 'CTCI', '2D', xmlTemp, 'N');
  COMMIT;
  plog.setendsection (pkgctx, 'PRC_2D');
  EXCEPTION WHEN OTHERS THEN
    plog.error(pkgctx, SQLERRM);
    plog.setendsection (pkgctx, 'PRC_2D');
    RAISE errnums.E_SYSTEM_ERROR;
  END PRC_2D;
  ----------------------------------------------
  --2E: So hieu lenh Flex, KL khop, Gia khop, So hieu deal khop
  ----------------------------------------------
 Procedure PRC_2E(v_orderid VARCHAR2, v_volume VARCHAR2,v_price VARCHAR2, v_confirm_number VARCHAR2 )
  IS
  xmlTemp VARCHAR2(4000);
  v_id NUMBER;
  v_order_number VARCHAR2(20);
  v_firm VARCHAR2(3);
  v_order_entry_date VARCHAR2(50);
  v_filler  VARCHAR2(50);
  v_side    VARCHAR2(1);
  BEGIN
  plog.setbeginsection (pkgctx, 'PRC_2E');
   SELECT  firm,order_number,side_alph, date_time ,to_char(date_time,'DDMM')
        INTO v_firm, v_order_number,v_side, v_order_entry_date,v_filler
        FROM ho_1i
        WHERE orderid= TRIM(v_orderid)
       -- AND sendnum = (SELECT MAX(sendnum) FROM ho_1i WHERE orderid= TRIM(v_orderid))
       ;
      xmlTemp:='<?xml version="1.0" encoding="utf-8"?><ArrayOfHoSEMessageEntry xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"><hoSEMessageEntry><key>order_number</key><value>@v_order_number@</value></hoSEMessageEntry><hoSEMessageEntry><key>confirm_number</key><value>@v_confirm_number@</value></hoSEMessageEntry><hoSEMessageEntry><key>price</key><value>@v_price@</value></hoSEMessageEntry><hoSEMessageEntry><key>side</key><value>@v_side@</value></hoSEMessageEntry><hoSEMessageEntry><key>firm</key><value>@v_firm@</value></hoSEMessageEntry><hoSEMessageEntry><key>volume</key><value>@v_volume@</value></hoSEMessageEntry><hoSEMessageEntry><key>order_entry_date</key><value>@v_order_entry_date@</value></hoSEMessageEntry><hoSEMessageEntry><key>filler</key><value>@v_filler@</value></hoSEMessageEntry></ArrayOfHoSEMessageEntry>';
      select   REPLACE(xmlTemp,'@v_order_number@',trim(v_order_number)) into xmlTemp from dual;
      select   REPLACE(xmlTemp,'@v_confirm_number@',trim(v_confirm_number)) into xmlTemp from dual;
      select   REPLACE(xmlTemp,'@v_price@',trim(v_price)) into xmlTemp from dual;
      select   REPLACE(xmlTemp,'@v_side@',trim(v_side)) into xmlTemp from dual;
      select   REPLACE(xmlTemp,'@v_volume@',trim(v_volume)) into xmlTemp from dual;
      select   REPLACE(xmlTemp,'@v_firm@',trim(v_firm)) into xmlTemp from dual;
      select   REPLACE(xmlTemp,'@v_order_entry_date@',trim(v_order_entry_date)) into xmlTemp from dual;
      select   REPLACE(xmlTemp,'@v_filler@',trim(v_filler)) into xmlTemp from dual;
  SELECT  seq_msgid.nextval Into v_id From dual;
  insert into msgreceivetemp (ID, MSG_DATE, MSGGROUP, MSGTYPE, MSGXML, PROCESS)
          values  (v_id , getcurrdate, 'CTCI', '2E', xmlTemp, 'N');
  COMMIT;
  plog.setendsection (pkgctx, 'PRC_2E');
  EXCEPTION WHEN OTHERS THEN
    plog.error(pkgctx, SQLERRM);
    plog.setendsection (pkgctx, 'PRC_2E');
    RAISE errnums.E_SYSTEM_ERROR;
  END PRC_2E;
  
  Procedure PRC_2E_deal( v_order_number VARCHAR2, v_orderid VARCHAR2, v_volume VARCHAR2,v_price VARCHAR2, v_confirm_number VARCHAR2 )
  IS
  xmlTemp VARCHAR2(4000);
  v_id NUMBER;
 -- v_order_number VARCHAR2(20);
  v_firm VARCHAR2(3);
  v_order_entry_date VARCHAR2(50);
  v_filler  VARCHAR2(50);
  v_side    VARCHAR2(1);
  BEGIN
  plog.setbeginsection (pkgctx, 'PRC_2E_deal');
  
  SELECT  CONTRAfrm, SUBSTR(EXECTYPE,2,1), to_char(TXDATE,'dd/mm/rrrr') ,to_char(TXDATE,'DDMM')
        INTO v_firm, v_side, v_order_entry_date,v_filler
   FROM ODMAST
        WHERE orderid= TRIM(v_orderid)
       -- AND sendnum = (SELECT MAX(sendnum) FROM ho_1i WHERE orderid= TRIM(v_orderid))
       ;
      xmlTemp:='<?xml version="1.0" encoding="utf-8"?><ArrayOfHoSEMessageEntry xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"><hoSEMessageEntry><key>order_number</key><value>@v_order_number@</value></hoSEMessageEntry><hoSEMessageEntry><key>confirm_number</key><value>@v_confirm_number@</value></hoSEMessageEntry><hoSEMessageEntry><key>price</key><value>@v_price@</value></hoSEMessageEntry><hoSEMessageEntry><key>side</key><value>@v_side@</value></hoSEMessageEntry><hoSEMessageEntry><key>firm</key><value>@v_firm@</value></hoSEMessageEntry><hoSEMessageEntry><key>volume</key><value>@v_volume@</value></hoSEMessageEntry><hoSEMessageEntry><key>order_entry_date</key><value>@v_order_entry_date@</value></hoSEMessageEntry><hoSEMessageEntry><key>filler</key><value>@v_filler@</value></hoSEMessageEntry></ArrayOfHoSEMessageEntry>';
      select   REPLACE(xmlTemp,'@v_order_number@',trim(v_order_number)) into xmlTemp from dual;
      select   REPLACE(xmlTemp,'@v_confirm_number@',trim(v_confirm_number)) into xmlTemp from dual;
      select   REPLACE(xmlTemp,'@v_price@',trim(v_price)) into xmlTemp from dual;
      select   REPLACE(xmlTemp,'@v_side@',trim(v_side)) into xmlTemp from dual;
      select   REPLACE(xmlTemp,'@v_volume@',trim(v_volume)) into xmlTemp from dual;
      select   REPLACE(xmlTemp,'@v_firm@',trim(v_firm)) into xmlTemp from dual;
      select   REPLACE(xmlTemp,'@v_order_entry_date@',trim(v_order_entry_date)) into xmlTemp from dual;
      select   REPLACE(xmlTemp,'@v_filler@',trim(v_filler)) into xmlTemp from dual;
  SELECT  seq_msgid.nextval Into v_id From dual;
  insert into msgreceivetemp (ID, MSG_DATE, MSGGROUP, MSGTYPE, MSGXML, PROCESS)
          values  (v_id , getcurrdate, 'CTCI', '2E', xmlTemp, 'N');
  COMMIT;
  plog.setendsection (pkgctx, 'PRC_2E_deal');
  EXCEPTION WHEN OTHERS THEN
    plog.error(pkgctx, SQLERRM);
    plog.setendsection (pkgctx, 'PRC_2E_deal');
    RAISE errnums.E_SYSTEM_ERROR;
  END PRC_2E_deal;
  ----------------------------------------------
  --2I: so hieu lenh mua, so hieu lenh ban, khoi luong khop, gia khop, so hieu deal khop
  ----------------------------------------------
 Procedure PRC_2I(v_orderid_buy VARCHAR2,v_orderid_sell VARCHAR2, v_volume VARCHAR2,v_price VARCHAR2, v_confirm_number VARCHAR2 )

  IS
  xmlTemp VARCHAR2(4000);
  v_id NUMBER;
  v_order_number_buy VARCHAR2(20);
  v_order_number_sell VARCHAR2(20);
  v_firm VARCHAR2(3);
  v_order_entry_date VARCHAR2(50);
  BEGIN
  plog.setbeginsection (pkgctx, 'PRC_2I');

  SELECT  firm,order_number
        INTO v_firm, v_order_number_buy
        FROM ho_1i
        WHERE orderid= TRIM(v_orderid_buy)
       -- AND sendnum = (SELECT MAX(sendnum) FROM ho_1i WHERE orderid= TRIM(v_orderid_buy))
       ;
   SELECT  order_number
        INTO  v_order_number_sell
        FROM ho_1i
        WHERE orderid= TRIM(v_orderid_sell)
       -- AND sendnum = (SELECT MAX(sendnum) FROM ho_1i WHERE orderid= TRIM(v_orderid_sell))
       ;
      xmlTemp:='<?xml version="1.0" encoding="utf-8"?><ArrayOfHoSEMessageEntry xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"><hoSEMessageEntry><key>confirm_number</key><value>@confirm_number@</value></hoSEMessageEntry><hoSEMessageEntry><key>price</key><value>@price@</value></hoSEMessageEntry><hoSEMessageEntry><key>order_number_sell</key><value>@order_number_sell@</value></hoSEMessageEntry><hoSEMessageEntry><key>order_entry_date_sell</key><value>2001</value></hoSEMessageEntry><hoSEMessageEntry><key>firm</key><value>@firm@</value></hoSEMessageEntry><hoSEMessageEntry><key>volume</key><value>@volume@</value></hoSEMessageEntry><hoSEMessageEntry><key>order_number_buy</key><value>@order_number_buy@</value></hoSEMessageEntry><hoSEMessageEntry><key>order_entry_date_buy</key><value>2001</value></hoSEMessageEntry></ArrayOfHoSEMessageEntry>';
      select   REPLACE(xmlTemp,'@order_number_buy@',trim(v_order_number_buy)) into xmlTemp from dual;
      select   REPLACE(xmlTemp,'@order_number_sell@',trim(v_order_number_sell)) into xmlTemp from dual;
      select   REPLACE(xmlTemp,'@confirm_number@',trim(v_confirm_number)) into xmlTemp from dual;
      select   REPLACE(xmlTemp,'@price@',trim(v_price)) into xmlTemp from dual;
      select   REPLACE(xmlTemp,'@volume@',trim(v_volume)) into xmlTemp from dual;
      select   REPLACE(xmlTemp,'@firm@',trim(v_firm)) into xmlTemp from dual;
  SELECT  seq_msgid.nextval Into v_id From dual;
  insert into msgreceivetemp (ID, MSG_DATE, MSGGROUP, MSGTYPE, MSGXML, PROCESS)
          values  (v_id , getcurrdate, 'CTCI', '2I', xmlTemp, 'N');
  COMMIT;
  plog.setendsection (pkgctx, 'PRC_2I');
  EXCEPTION WHEN OTHERS THEN
    plog.error(pkgctx, SQLERRM);
    plog.setendsection (pkgctx, 'PRC_2I');
    RAISE errnums.E_SYSTEM_ERROR;
  END PRC_2I;
  
  
  Procedure PRC_2I_deal(v_orderid_buy VARCHAR2,v_orderid_sell VARCHAR2, v_volume VARCHAR2,v_price VARCHAR2, v_confirm_number VARCHAR2 )

  IS
  xmlTemp VARCHAR2(4000);
  v_id NUMBER;
  v_order_number_buy VARCHAR2(20);
  v_order_number_sell VARCHAR2(20);
  v_firm VARCHAR2(3);
  v_order_entry_date VARCHAR2(50);
  BEGIN
  plog.setbeginsection (pkgctx, 'PRC_2I_deal');
  v_firm:='002';
  SELECT  v_orderid_buy
        INTO  v_order_number_buy
        FROM dual
       -- AND sendnum = (SELECT MAX(sendnum) FROM ho_1i WHERE orderid= TRIM(v_orderid_buy))
       ;
   SELECT  v_orderid_sell
        INTO  v_order_number_sell
        FROM dual
       -- AND sendnum = (SELECT MAX(sendnum) FROM ho_1i WHERE orderid= TRIM(v_orderid_sell))
       ;
      xmlTemp:='<?xml version="1.0" encoding="utf-8"?><ArrayOfHoSEMessageEntry xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"><hoSEMessageEntry><key>confirm_number</key><value>@confirm_number@</value></hoSEMessageEntry><hoSEMessageEntry><key>price</key><value>@price@</value></hoSEMessageEntry><hoSEMessageEntry><key>order_number_sell</key><value>@order_number_sell@</value></hoSEMessageEntry><hoSEMessageEntry><key>order_entry_date_sell</key><value>2001</value></hoSEMessageEntry><hoSEMessageEntry><key>firm</key><value>@firm@</value></hoSEMessageEntry><hoSEMessageEntry><key>volume</key><value>@volume@</value></hoSEMessageEntry><hoSEMessageEntry><key>order_number_buy</key><value>@order_number_buy@</value></hoSEMessageEntry><hoSEMessageEntry><key>order_entry_date_buy</key><value>2001</value></hoSEMessageEntry></ArrayOfHoSEMessageEntry>';
      select   REPLACE(xmlTemp,'@order_number_buy@',trim(v_order_number_buy)) into xmlTemp from dual;
      select   REPLACE(xmlTemp,'@order_number_sell@',trim(v_order_number_sell)) into xmlTemp from dual;
      select   REPLACE(xmlTemp,'@confirm_number@',trim(v_confirm_number)) into xmlTemp from dual;
      select   REPLACE(xmlTemp,'@price@',trim(v_price)) into xmlTemp from dual;
      select   REPLACE(xmlTemp,'@volume@',trim(v_volume)) into xmlTemp from dual;
      select   REPLACE(xmlTemp,'@firm@',trim(v_firm)) into xmlTemp from dual;
  SELECT  seq_msgid.nextval Into v_id From dual;
  insert into msgreceivetemp (ID, MSG_DATE, MSGGROUP, MSGTYPE, MSGXML, PROCESS)
          values  (v_id , getcurrdate, 'CTCI', '2I', xmlTemp, 'N');
  COMMIT;
  plog.setendsection (pkgctx, 'PRC_2I_deal');
  EXCEPTION WHEN OTHERS THEN
    plog.error(pkgctx, SQLERRM);
    plog.setendsection (pkgctx, 'PRC_2I_deal');
    RAISE errnums.E_SYSTEM_ERROR;
  END PRC_2I_deal;
  ----------------------------------------------
  --2F: firm buy, trader_id_buy, contra_firm_sell, trader_id_contra_side_sell, security_symbol,
  --volume,price,  confirm_number
  ----------------------------------------------
 Procedure PRC_2F(firm_buy VARCHAR2,trader_id_buy VARCHAR2, contra_firm_sell VARCHAR2,trader_id_contra_side_sell VARCHAR2, security_symbol VARCHAR2, volume VARCHAR2 ,price VARCHAR2,confirm_number  VARCHAR2)
  IS
  xmlTemp VARCHAR2(4000);
  v_id NUMBER;
  BEGIN
  plog.setbeginsection (pkgctx, 'PRC_2F');
       xmlTemp:='<?xml version="1.0" encoding="utf-8"?><ArrayOfHoSEMessageEntry xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"><hoSEMessageEntry><key>confirm_number</key><value>@confirm_number@</value></hoSEMessageEntry><hoSEMessageEntry><key>firm_buy</key><value>@firm_buy@</value></hoSEMessageEntry><hoSEMessageEntry><key>price</key><value>@price@</value></hoSEMessageEntry><hoSEMessageEntry><key>side_b</key><value>B</value></hoSEMessageEntry><hoSEMessageEntry><key>volume</key><value>@volume@</value></hoSEMessageEntry><hoSEMessageEntry><key>security_symbol</key><value>@security_symbol@</value></hoSEMessageEntry><hoSEMessageEntry><key>trader_id_buy</key><value>@trader_id_buy@</value></hoSEMessageEntry><hoSEMessageEntry><key>board</key><value>B</value></hoSEMessageEntry><hoSEMessageEntry><key>contra_firm_sell</key><value>@contra_firm_sell@</value></hoSEMessageEntry><hoSEMessageEntry><key>trader_id_contra_side_sell</key><value>@trader_id_contra_side_sell@</value></hoSEMessageEntry></ArrayOfHoSEMessageEntry>';
      select   REPLACE(xmlTemp,'@firm_buy@',trim(firm_buy)) into xmlTemp from dual;
      select   REPLACE(xmlTemp,'@trader_id_buy@',trim(trader_id_buy)) into xmlTemp from dual;
      select   REPLACE(xmlTemp,'@contra_firm_sell@',trim(contra_firm_sell)) into xmlTemp from dual;
      select   REPLACE(xmlTemp,'@trader_id_contra_side_sell@',trim(trader_id_contra_side_sell)) into xmlTemp from dual;
      select   REPLACE(xmlTemp,'@security_symbol@',trim(security_symbol)) into xmlTemp from dual;
      select   REPLACE(xmlTemp,'@volume@',trim(volume)) into xmlTemp from dual;
      select   REPLACE(xmlTemp,'@price@',trim(price)) into xmlTemp from dual;
      select   REPLACE(xmlTemp,'@confirm_number@',trim(confirm_number)) into xmlTemp from dual;
  SELECT  seq_msgid.nextval Into v_id From dual;
  insert into msgreceivetemp (ID, MSG_DATE, MSGGROUP, MSGTYPE, MSGXML, PROCESS)
          values  (v_id , getcurrdate, 'CTCI', '2F', xmlTemp, 'N');
  COMMIT;
  plog.setendsection (pkgctx, 'PRC_2F');
  EXCEPTION WHEN OTHERS THEN
    plog.error(pkgctx, SQLERRM);
    plog.setendsection (pkgctx, 'PRC_2F');
    RAISE errnums.E_SYSTEM_ERROR;
  END PRC_2F;
  ----------------------------------------------
  --2G:So Hieu Lenh, Loai lenh bi tu choi, ly do tu choi
  ----------------------------------------------
 Procedure PRC_2G(v_orderid VARCHAR2,msg_type VARCHAR2, reject_reason_code VARCHAR2 )
  IS
  xmlTemp VARCHAR2(4000);
  v_id NUMBER;
  order_number VARCHAR2(20);
  BEGIN
  plog.setbeginsection (pkgctx, 'PRC_2G');
   SELECT ctci_order  INTO order_number
        FROM ORDERMAP WHERE ORGORDERID= TRIM(v_orderid);
   xmlTemp:='<?xml version="1.0" encoding="utf-8"?><ArrayOfHoSEMessageEntry xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"><hoSEMessageEntry><key>order_number</key><value>@order_number@</value></hoSEMessageEntry><hoSEMessageEntry><key>firm</key><value>002</value></hoSEMessageEntry><hoSEMessageEntry><key>msg_type</key><value>@msg_type@</value></hoSEMessageEntry><hoSEMessageEntry><key>board</key><value>M</value></hoSEMessageEntry><hoSEMessageEntry><key>port_client_flag</key><value>C</value></hoSEMessageEntry><hoSEMessageEntry><key>price</key><value>20.8  </value></hoSEMessageEntry><hoSEMessageEntry><key>trader_id</key><value>22  </value></hoSEMessageEntry><hoSEMessageEntry><key>side</key><value>S</value></hoSEMessageEntry><hoSEMessageEntry><key>volume</key><value>10      </value></hoSEMessageEntry><hoSEMessageEntry><key>security_symbol</key><value>HAG     </value></hoSEMessageEntry><hoSEMessageEntry><key>client_id</key><value>002C180666</value></hoSEMessageEntry><hoSEMessageEntry><key>original_message_text</key><value>1I00222  3669    002C180666HAG     S10      10      20.8  M     C                                                                                                                                                                        </value></hoSEMessageEntry><hoSEMessageEntry><key>reject_reason_code</key><value>@reject_reason_code@</value></hoSEMessageEntry><hoSEMessageEntry><key>filler_2</key><value>     </value></hoSEMessageEntry><hoSEMessageEntry><key>filler_1</key><value>     </value></hoSEMessageEntry><hoSEMessageEntry><key>published_volume</key><value>10      </value></hoSEMessageEntry><hoSEMessageEntry><key>original_firm</key><value>002</value></hoSEMessageEntry></ArrayOfHoSEMessageEntry>';
      select   REPLACE(xmlTemp,'@order_number@',trim(order_number)) into xmlTemp from dual;
      select   REPLACE(xmlTemp,'@msg_type@',trim(msg_type)) into xmlTemp from dual;
      select   REPLACE(xmlTemp,'@reject_reason_code@',trim(reject_reason_code)) into xmlTemp from dual;
  SELECT  seq_msgid.nextval Into v_id From dual;
  insert into msgreceivetemp (ID, MSG_DATE, MSGGROUP, MSGTYPE, MSGXML, PROCESS)
          values  (v_id , getcurrdate, 'CTCI', '2G', xmlTemp, 'N');
  COMMIT;
  plog.setendsection (pkgctx, 'PRC_2G');
  EXCEPTION WHEN OTHERS THEN
    plog.error(pkgctx, SQLERRM);
    plog.setendsection (pkgctx, 'PRC_2G');
    RAISE errnums.E_SYSTEM_ERROR;
  END PRC_2G;
  ----------------------------------------------
  --2L:Side (B: mua -- S:ban -- X cung cty)
  --confirm_number, deal_id, firm , volume, price
  ----------------------------------------------
 Procedure PRC_2L(side VARCHAR2,v_orderid VARCHAR2, confirm_number VARCHAR2, volume VARCHAR2, price VARCHAR2, firm VARCHAR2)
  IS
  xmlTemp VARCHAR2(4000);
  v_id NUMBER;
  order_number VARCHAR2(20);
  BEGIN
  plog.setbeginsection (pkgctx, 'PRC_2L');
     SELECT ctci_order  INTO order_number
        FROM ORDERMAP WHERE ORGORDERID= TRIM(v_orderid);
      xmlTemp:='<?xml version="1.0" encoding="utf-8"?><ArrayOfHoSEMessageEntry xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"><hoSEMessageEntry><key>confirm_number</key><value>@confirm_number@</value></hoSEMessageEntry><hoSEMessageEntry><key>price</key><value>@price@</value></hoSEMessageEntry><hoSEMessageEntry><key>side</key><value>@side@</value></hoSEMessageEntry><hoSEMessageEntry><key>contra_firm</key><value>2  </value></hoSEMessageEntry><hoSEMessageEntry><key>firm</key><value>@firm@</value></hoSEMessageEntry><hoSEMessageEntry><key>volume</key><value>@volume@</value></hoSEMessageEntry><hoSEMessageEntry><key>deal_id</key><value>@deal_id@</value></hoSEMessageEntry></ArrayOfHoSEMessageEntry>';
      select   REPLACE(xmlTemp,'@side@',trim(side)) into xmlTemp from dual;
      select   REPLACE(xmlTemp,'@confirm_number@',trim(confirm_number)) into xmlTemp from dual;
      select   REPLACE(xmlTemp,'@deal_id@',trim(order_number)) into xmlTemp from dual;
      select   REPLACE(xmlTemp,'@firm@',trim(firm)) into xmlTemp from dual;
      select   REPLACE(xmlTemp,'@volume@',trim(volume)) into xmlTemp from dual;
      select   REPLACE(xmlTemp,'@price@',trim(price)) into xmlTemp from dual;
  SELECT  seq_msgid.nextval Into v_id From dual;
  insert into msgreceivetemp (ID, MSG_DATE, MSGGROUP, MSGTYPE, MSGXML, PROCESS)
          values  (v_id , getcurrdate, 'CTCI', '2L', xmlTemp, 'N');
  COMMIT;
  plog.setendsection (pkgctx, 'PRC_2L');
  EXCEPTION WHEN OTHERS THEN
    plog.error(pkgctx, SQLERRM);
    plog.setendsection (pkgctx, 'PRC_2L');
    RAISE errnums.E_SYSTEM_ERROR;
  END PRC_2L;
  ----------------------------------------------
  --3B:reply_code (C ko dong y -- A Chap thuan --S chap thuan nuoc ngoai ko du room
  --v_orderid, confirm_number, firm
  ----------------------------------------------
 Procedure PRC_3B(reply_code VARCHAR2,v_orderid VARCHAR2,  firm VARCHAR2)
  IS
  xmlTemp VARCHAR2(4000);
  v_id NUMBER;
  deal_id VARCHAR2(20);

  BEGIN
  plog.setbeginsection (pkgctx, 'PRC_3B');
  SELECT ctci_order  INTO deal_id
        FROM ORDERMAP WHERE ORGORDERID= TRIM(v_orderid);
      xmlTemp:='<?xml version="1.0" encoding="utf-8"?><ArrayOfHoSEMessageEntry xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"><hoSEMessageEntry><key>confirm_number</key><value>@confirm_number@</value></hoSEMessageEntry><hoSEMessageEntry><key>broker_portfolio_volume</key><value>        </value></hoSEMessageEntry><hoSEMessageEntry><key>firm</key><value>@firm@</value></hoSEMessageEntry><hoSEMessageEntry><key>reply_code</key><value>@reply_code@</value></hoSEMessageEntry><hoSEMessageEntry><key>client_id_buyer</key><value>          </value></hoSEMessageEntry><hoSEMessageEntry><key>broker_foreign_volume</key><value>        </value></hoSEMessageEntry><hoSEMessageEntry><key>broker_mutual_fund_volume</key><value>        </value></hoSEMessageEntry><hoSEMessageEntry><key>deal_id</key><value>@deal_id@</value></hoSEMessageEntry><hoSEMessageEntry><key>filler_2</key><value>                                </value></hoSEMessageEntry><hoSEMessageEntry><key>filler_1</key><value>    </value></hoSEMessageEntry><hoSEMessageEntry><key>broker_client_volume</key><value>        </value></hoSEMessageEntry></ArrayOfHoSEMessageEntry>';
      select   REPLACE(xmlTemp,'@reply_code@',trim(reply_code)) into xmlTemp from dual;
      select   REPLACE(xmlTemp,'@deal_id@',trim(deal_id)) into xmlTemp from dual;
      select   REPLACE(xmlTemp,'@firm@',trim(firm)) into xmlTemp from dual;
  SELECT  seq_msgid.nextval Into v_id From dual;
  insert into msgreceivetemp (ID, MSG_DATE, MSGGROUP, MSGTYPE, MSGXML, PROCESS)
          values  (v_id , getcurrdate, 'CTCI', '3B', xmlTemp, 'N');
  COMMIT;
  plog.setendsection (pkgctx, 'PRC_3B');
  EXCEPTION WHEN OTHERS THEN
    plog.error(pkgctx, SQLERRM);
    plog.setendsection (pkgctx, 'PRC_3B');
    RAISE errnums.E_SYSTEM_ERROR;
  END PRC_3B;
   ----------------------------------------------
  --3C:reply_code (C ko dong y -- A Chap thuan --S chap thuan nuoc ngoai ko du room
  --v_orderid, confirm_number, firm
  ----------------------------------------------
 Procedure PRC_3C(firm VARCHAR2,contra_firm VARCHAR2, trader_id VARCHAR2, side VARCHAR2, security_symbol VARCHAR2, confirm_number VARCHAR2)
  IS
  xmlTemp VARCHAR2(4000);
  v_id NUMBER;
  order_number VARCHAR2(20);

  BEGIN
  plog.setbeginsection (pkgctx, 'PRC_3C');
      xmlTemp:='<?xml version="1.0" encoding="utf-8"?><ArrayOfHoSEMessageEntry xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"><hoSEMessageEntry><key>confirm_number</key><value>@confirm_number@</value></hoSEMessageEntry><hoSEMessageEntry><key>price</key><value>@price@</value></hoSEMessageEntry><hoSEMessageEntry><key>side</key><value>@side@</value></hoSEMessageEntry><hoSEMessageEntry><key>contra_firm</key><value>@contra_firm@</value></hoSEMessageEntry><hoSEMessageEntry><key>firm</key><value>@firm@</value></hoSEMessageEntry><hoSEMessageEntry><key>security_symbol</key><value>@security_symbol@</value></hoSEMessageEntry><hoSEMessageEntry><key>trader_id</key><value>@trader_id@</value></hoSEMessageEntry></ArrayOfHoSEMessageEntry>';
      select   REPLACE(xmlTemp,'@firm@',trim(firm)) into xmlTemp from dual;
      select   REPLACE(xmlTemp,'@contra_firm@',trim(contra_firm)) into xmlTemp from dual;
      select   REPLACE(xmlTemp,'@trader_id@',trim(trader_id)) into xmlTemp from dual;
      select   REPLACE(xmlTemp,'@side@',trim(side)) into xmlTemp from dual;
      select   REPLACE(xmlTemp,'@security_symbol@',trim(security_symbol)) into xmlTemp from dual;
      select   REPLACE(xmlTemp,'@confirm_number@',trim(confirm_number)) into xmlTemp from dual;
  SELECT  seq_msgid.nextval Into v_id From dual;
  insert into msgreceivetemp (ID, MSG_DATE, MSGGROUP, MSGTYPE, MSGXML, PROCESS)
          values  (v_id , getcurrdate, 'CTCI', '3C', xmlTemp, 'N');
  COMMIT;
  plog.setendsection (pkgctx, 'PRC_3C');
  EXCEPTION WHEN OTHERS THEN
    plog.error(pkgctx, SQLERRM);
    plog.setendsection (pkgctx, 'PRC_3C');
    RAISE errnums.E_SYSTEM_ERROR;
  END PRC_3C;
   ----------------------------------------------
  --3D:reply_code (C ko dong y -- A Chap thuan --S ko chap thuan
  --v_orderid, confirm_number, firm
  ----------------------------------------------
 Procedure PRC_3D(reply_code VARCHAR2, confirm_number VARCHAR2, firm VARCHAR2)
  IS
  xmlTemp VARCHAR2(4000);
  v_id NUMBER;
  order_number VARCHAR2(20);

  BEGIN
  plog.setbeginsection (pkgctx, 'PRC_3D');
      xmlTemp:='<?xml version="1.0" encoding="utf-8"?><ArrayOfHoSEMessageEntry xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"><hoSEMessageEntry><key>confirm_number</key><value>@confirm_number@</value></hoSEMessageEntry><hoSEMessageEntry><key>price</key><value>@price@</value></hoSEMessageEntry><hoSEMessageEntry><key>side</key><value>@side@</value></hoSEMessageEntry><hoSEMessageEntry><key>contra_firm</key><value>2  </value></hoSEMessageEntry><hoSEMessageEntry><key>firm</key><value>@firm@</value></hoSEMessageEntry><hoSEMessageEntry><key>volume</key><value>@volume@</value></hoSEMessageEntry><hoSEMessageEntry><key>deal_id</key><value>@deal_id@</value></hoSEMessageEntry><hoSEMessageEntry><key>reply_code</key><value>@reply_code@</value></hoSEMessageEntry></ArrayOfHoSEMessageEntry>';
      select   REPLACE(xmlTemp,'@reply_code@',trim(reply_code)) into xmlTemp from dual;
      select   REPLACE(xmlTemp,'@confirm_number@',trim(confirm_number)) into xmlTemp from dual;
      select   REPLACE(xmlTemp,'@firm@',trim(firm)) into xmlTemp from dual;
  SELECT  seq_msgid.nextval Into v_id From dual;
  insert into msgreceivetemp (ID, MSG_DATE, MSGGROUP, MSGTYPE, MSGXML, PROCESS)
          values  (v_id , getcurrdate, 'CTCI', '3D', xmlTemp, 'N');
  COMMIT;
  plog.setendsection (pkgctx, 'PRC_3D');
  EXCEPTION WHEN OTHERS THEN
    plog.error(pkgctx, SQLERRM);
    plog.setendsection (pkgctx, 'PRC_3D');
    RAISE errnums.E_SYSTEM_ERROR;
  END PRC_3D;
 -- MSG SC KET THUC GD
  Procedure PRC_SC(Time_stamp VARCHAR2,System_Control_Code VARCHAR2)
  IS
  xmlTemp VARCHAR2(4000);
  v_id NUMBER;
  timestamp VARCHAR2(20);

  BEGIN
  plog.setbeginsection (pkgctx, 'PRC_SC');
      xmlTemp:='<?xml version="1.0" encoding="utf-8"?><ArrayOfHoSEMessageEntry xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"><hoSEMessageEntry><key>timestamp</key><value>@timestamp@</value></hoSEMessageEntry><hoSEMessageEntry><key>system_control_code</key><value>@system_control_code@</value></hoSEMessageEntry></ArrayOfHoSEMessageEntry>';
      select   REPLACE(xmlTemp,'@system_control_code@',trim(system_control_code)) into xmlTemp from dual;
      select    REPLACE(xmlTemp,'@timestamp@',trim(Time_stamp)) into xmlTemp from dual;
  SELECT  seq_msgid.nextval Into v_id From dual;
  insert into msgreceivetemp (ID, MSG_DATE, MSGGROUP, MSGTYPE, MSGXML, PROCESS)
          values  (v_id , getcurrdate, 'CTCI', 'SC', xmlTemp, 'N');
  COMMIT;
  plog.setendsection (pkgctx, 'PRC_SC');
  EXCEPTION WHEN OTHERS THEN
    plog.error(pkgctx, SQLERRM);
    plog.setendsection (pkgctx, 'PRC_SC');
    RAISE errnums.E_SYSTEM_ERROR;
  END PRC_SC;
END pck_homsg;

/
