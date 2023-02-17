SET DEFINE OFF;
CREATE OR REPLACE PACKAGE pck_hogw
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
     **  TienPQ      09-JUNE-2009    Created
     ** (c) 2009 by Financial Software Solutions. JSC.
     ----------------------------------------------------------------------------------------------------*/

    FUNCTION fn_obj2xml(p_txmsg tx.msg_rectype)
    RETURN VARCHAR2;

    FUNCTION fn_xml2obj(p_xmlmsg    VARCHAR2)
    RETURN tx.msg_rectype;

  FUNCTION fn_xml2obj_2B(p_xmlmsg    VARCHAR2) RETURN tx.msg_2B;
  FUNCTION fn_xml2obj_2D(p_xmlmsg    VARCHAR2) RETURN tx.msg_2D;
  FUNCTION fn_xml2obj_2G(p_xmlmsg    VARCHAR2) RETURN tx.msg_2G;
  FUNCTION fn_xml2obj_3B(p_xmlmsg    VARCHAR2) RETURN tx.msg_3B;
  Procedure PRC_PROCESS2G(V_MSGXML VARCHAR2);
  Procedure PRC_PROCESS3B(V_MSGXML VARCHAR2);
  Procedure PRC_1I(PV_REF IN OUT PKG_REPORT.REF_CURSOR);
  Procedure PRC_1C(PV_REF IN OUT PKG_REPORT.REF_CURSOR);
  Procedure PRC_1F(PV_REF IN OUT PKG_REPORT.REF_CURSOR);
  Procedure PRC_1G(PV_REF IN OUT PKG_REPORT.REF_CURSOR);
  Procedure PRC_1D(PV_REF IN OUT PKG_REPORT.REF_CURSOR);
  Procedure PRC_3B(PV_REF IN OUT PKG_REPORT.REF_CURSOR);
  Procedure PRC_3C(PV_REF IN OUT PKG_REPORT.REF_CURSOR);
  Procedure PRC_3D(PV_REF IN OUT PKG_REPORT.REF_CURSOR);
  Procedure PRC_GETORDER(PV_REF IN OUT PKG_REPORT.REF_CURSOR, v_MsgType VARCHAR2);
  Procedure PRC_PROCESS2B(V_MSGXML VARCHAR2);
  Procedure PRC_PROCESSMSG(V_MSGGROUP VARCHAR2);
  FUNCTION fn_xml2obj_2C(p_xmlmsg    VARCHAR2) RETURN tx.msg_2C;
  Procedure PRC_PROCESS2C(V_MSGXML VARCHAR2);
  PROCEDURE          CONFIRM_CANCEL_NORMAL_ORDER (
   pv_orderid   IN   VARCHAR2,
   pv_qtty      IN   NUMBER
);
  FUNCTION fn_xml2obj_2E(p_xmlmsg    VARCHAR2) RETURN tx.msg_2E;
  Procedure PRC_PROCESS2E(V_MSGXML VARCHAR2);
  Procedure PRC_PROCESS2I(V_MSGXML VARCHAR2);
  FUNCTION fn_xml2obj_2I(p_xmlmsg    VARCHAR2) RETURN tx.msg_2I;
  FUNCTION fn_xml2obj_2F(p_xmlmsg    VARCHAR2) RETURN tx.msg_2F;
  FUNCTION fn_xml2obj_2L(p_xmlmsg    VARCHAR2) RETURN tx.msg_2L;
  FUNCTION fn_xml2obj_3C(p_xmlmsg    VARCHAR2) RETURN tx.msg_3C;
  FUNCTION fn_xml2obj_3D(p_xmlmsg    VARCHAR2) RETURN tx.msg_3D;
  FUNCTION fn_xml2obj_TS(p_xmlmsg    VARCHAR2) RETURN tx.msg_TS;
  FUNCTION fn_xml2obj_SC(p_xmlmsg    VARCHAR2) RETURN tx.msg_SC;
  FUNCTION fn_xml2obj_TR(p_xmlmsg    VARCHAR2) RETURN tx.msg_TR;
  FUNCTION fn_xml2obj_BS(p_xmlmsg    VARCHAR2) RETURN tx.msg_BS;
  FUNCTION fn_xml2obj_TC(p_xmlmsg    VARCHAR2) RETURN tx.msg_TC;
  Procedure PRC_PROCESS2L(V_MSGXML VARCHAR2);
  Procedure PRC_PROCESS2F(V_MSGXML VARCHAR2);
  Procedure PRC_PROCESS3C(V_MSGXML VARCHAR2);
  Procedure PRC_PROCESSSC(V_MSGXML VARCHAR2,V_MSG_DATE VARCHAR2);
  Procedure PRC_PROCESSTR(V_MSGXML VARCHAR2);
  FUNCTION fn_xml2obj_GA(p_xmlmsg    VARCHAR2) RETURN tx.msg_GA;
  Procedure PRC_PROCESSGA(V_MSGXML VARCHAR2);
  FUNCTION fn_xml2obj_SU(p_xmlmsg    VARCHAR2) RETURN tx.msg_SU;
  FUNCTION fn_xml2obj_SS(p_xmlmsg    VARCHAR2) RETURN tx.msg_SS;
  Procedure PRC_PROCESSSU(V_MSGXML VARCHAR2);
  Procedure PRC_PROCESSSS(V_MSGXML VARCHAR2);
  Procedure PRC_PROCESSTS(V_MSGXML VARCHAR2,V_MSG_DATE VARCHAR2);
  Procedure PRC_PROCESSTC(V_MSGXML VARCHAR2);
  Procedure PRC_PROCESSBS(V_MSGXML VARCHAR2);
  Procedure PRC_PROCESS3D(V_MSGXML VARCHAR2);
  Procedure PRC_PROCESS2D(V_MSGXML VARCHAR2);
  FUNCTION          FNC_CHECK_ROOM
  ( v_Symbol IN varchar2,
    v_Volumn In number,
    v_Custodycd in varchar2,
    v_BorS in  Varchar2)
  RETURN  number;
  FUNCTION fnc_check_sec_hcm
      ( v_Symbol IN varchar2)
      RETURN  number;
  FUNCTION fnc_check_traderid
      ( v_Machtype IN varchar2,
        v_BORS IN varchar2,
        v_Via in varchar2 default null)
      RETURN  number;
  FUNCTION    FNC_CHECK_ISNOTBOND
      ( v_Symbol IN Varchar2)
      RETURN  number;
  FUNCTION          FNC_CHECK_P_STOCKBOND
      ( v_Msgtype Varchar2,v_Symbol IN Varchar2)
      RETURN  number;
  Procedure PRC_1E(PV_REF IN OUT PKG_REPORT.REF_CURSOR);
  PROCEDURE          MATCHING_NORMAL_ORDER (
   firm               IN   VARCHAR2,
   order_number       IN   NUMBER,
   order_entry_date   IN   VARCHAR2,
   side_alph          IN   VARCHAR2,
   filler             IN   VARCHAR2,
   deal_volume        IN   NUMBER,
   deal_price         IN   NUMBER,
   confirm_number     IN   Varchar2
);
    Procedure PRC_PROCESSAA(V_MSGXML VARCHAR2);
    FUNCTION fn_xml2obj_AA(p_xmlmsg    VARCHAR2) RETURN tx.msg_AA;
    Procedure PRC_PROCESSMSG_ERR;
    FUNCTION fn_get_delta_time
    RETURN INTEGER;
    FUNCTION fn_caculate_hose_time
    RETURN VARCHAR2;
END;
 
/


CREATE OR REPLACE PACKAGE BODY pck_hogw IS
  pkgctx plog.log_ctx;
  logrow tlogdebug%ROWTYPE;
  v_CheckProcess Boolean;

  FUNCTION fn_xml2obj(p_xmlmsg    VARCHAR2) RETURN tx.msg_rectype IS
    l_parser   xmlparser.parser;
    l_doc      xmldom.domdocument;
    l_nodeList xmldom.domnodelist;
    l_node     xmldom.domnode;

    l_fldname fldmaster.fldname%TYPE;
    l_txmsg   tx.msg_rectype;
  BEGIN
    plog.setbeginsection (pkgctx, 'fn_xml2obj');

    plog.debug(pkgctx,'msg length: ' || length(p_xmlmsg));
    l_parser := xmlparser.newparser();
    plog.debug(pkgctx,'1');
    xmlparser.parseclob(l_parser, p_xmlmsg);
    plog.debug(pkgctx,'2');
    l_doc := xmlparser.getdocument(l_parser);
    plog.debug(pkgctx,'3');
    xmlparser.freeparser(l_parser);

    plog.debug(pkgctx,'Prepare to parse Message Header');
    l_nodeList := xslprocessor.selectnodes(xmldom.makenode(l_doc),
                                           '/TransactMessage');
    --<<Begin of header transformation>>
    FOR i IN 0 .. xmldom.getlength(l_nodeList) - 1 LOOP
      plog.debug(pkgctx,'parse header i: ' || i);
      l_node         := xmldom.item(l_nodeList, i);
      l_txmsg.msgtype  := xmldom.getvalue(xmldom.getattributenode(xmldom.makeelement(l_node),
                                                                'MSGTYPE'));
      l_txmsg.txnum  := xmldom.getvalue(xmldom.getattributenode(xmldom.makeelement(l_node),
                                                                'TXNUM'));
      l_txmsg.txdate := TO_DATE(xmldom.getvalue(xmldom.getattributenode(xmldom.makeelement(l_node),
                                                                        'TXDATE')),
                                systemnums.c_date_format);

      l_txmsg.txtime := xmldom.getvalue(xmldom.getattributenode(xmldom.makeelement(l_node),
                                                                'TXTIME'));

      l_txmsg.brid := xmldom.getvalue(xmldom.getattributenode(xmldom.makeelement(l_node),
                                                              'BRID'));

      l_txmsg.tlid := xmldom.getvalue(xmldom.getattributenode(xmldom.makeelement(l_node),
                                                              'TLID'));

      l_txmsg.offid := xmldom.getvalue(xmldom.getattributenode(xmldom.makeelement(l_node),
                                                               'OFFID'));
      plog.debug(pkgctx,'get ovrrqs from xml: ' ||xmldom.getvalue(xmldom.getattributenode(xmldom.makeelement(l_node),
                                                                'OVRRQD')));
      l_txmsg.ovrrqd := xmldom.getvalue(xmldom.getattributenode(xmldom.makeelement(l_node),
                                                                'OVRRQD'));

      l_txmsg.chid := xmldom.getvalue(xmldom.getattributenode(xmldom.makeelement(l_node),
                                                              'CHID'));

      l_txmsg.chkid := xmldom.getvalue(xmldom.getattributenode(xmldom.makeelement(l_node),
                                                               'CHKID'));

      l_txmsg.txaction := xmldom.getvalue(xmldom.getattributenode(xmldom.makeelement(l_node),
                                                                  'MSGTYPE'));

      --l_txmsg.txaction := xmldom.getvalue(xmldom.getattributenode(xmldom.makeelement(l_node),'ACTIONFLAG'));

      l_txmsg.tltxcd := xmldom.getvalue(xmldom.getattributenode(xmldom.makeelement(l_node),
                                                                'TLTXCD'));

      l_txmsg.ibt := xmldom.getvalue(xmldom.getattributenode(xmldom.makeelement(l_node),
                                                             'IBT'));

      l_txmsg.brid2 := xmldom.getvalue(xmldom.getattributenode(xmldom.makeelement(l_node),
                                                               'BRID2'));

      l_txmsg.tlid2 := xmldom.getvalue(xmldom.getattributenode(xmldom.makeelement(l_node),
                                                               'TLID2'));

      l_txmsg.ccyusage := xmldom.getvalue(xmldom.getattributenode(xmldom.makeelement(l_node),
                                                                  'CCYUSAGE'));

      l_txmsg.off_line := xmldom.getvalue(xmldom.getattributenode(xmldom.makeelement(l_node),
                                                                  'OFFLINE'));

      l_txmsg.deltd := xmldom.getvalue(xmldom.getattributenode(xmldom.makeelement(l_node),
                                                               'DELTD'));

      l_txmsg.brdate := TO_DATE(xmldom.getvalue(xmldom.getattributenode(xmldom.makeelement(l_node),
                                                                        'BRDATE')),
                                systemnums.c_date_format);

      l_txmsg.busdate := TO_DATE(xmldom.getvalue(xmldom.getattributenode(xmldom.makeelement(l_node),
                                                                         'BUSDATE')),
                                 systemnums.c_date_format);

      l_txmsg.txdesc := xmldom.getvalue(xmldom.getattributenode(xmldom.makeelement(l_node),
                                                                'TXDESC'));

      l_txmsg.ipaddress := xmldom.getvalue(xmldom.getattributenode(xmldom.makeelement(l_node),
                                                                   'IPADDRESS'));

      l_txmsg.wsname := xmldom.getvalue(xmldom.getattributenode(xmldom.makeelement(l_node),
                                                                'WSNAME'));

      l_txmsg.txstatus := xmldom.getvalue(xmldom.getattributenode(xmldom.makeelement(l_node),
                                                                  'STATUS'));

      l_txmsg.msgsts := xmldom.getvalue(xmldom.getattributenode(xmldom.makeelement(l_node),
                                                                'MSGSTS'));

      l_txmsg.ovrsts := xmldom.getvalue(xmldom.getattributenode(xmldom.makeelement(l_node),
                                                                'OVRSTS'));

      l_txmsg.batchname := xmldom.getvalue(xmldom.getattributenode(xmldom.makeelement(l_node),
                                                                   'BATCHNAME'));

      plog.debug(pkgctx, 'msgamt: ' || xmldom.getvalue(xmldom.getattributenode(xmldom.makeelement(l_node),
                                                                'MSGAMT')));
      l_txmsg.msgamt := xmldom.getvalue(xmldom.getattributenode(xmldom.makeelement(l_node),
                                                                'MSGAMT'));

      plog.debug(pkgctx, 'msgacct: ' || xmldom.getvalue(xmldom.getattributenode(xmldom.makeelement(l_node),
                                                                'msgacct')));
      l_txmsg.msgacct := xmldom.getvalue(xmldom.getattributenode(xmldom.makeelement(l_node),
                                                                 'MSGACCT'));

      l_txmsg.msgamt := xmldom.getvalue(xmldom.getattributenode(xmldom.makeelement(l_node),
                                                                'FEEAMT'));

      l_txmsg.msgacct := xmldom.getvalue(xmldom.getattributenode(xmldom.makeelement(l_node),
                                                                 'VATAMT'));

      l_txmsg.chktime := xmldom.getvalue(xmldom.getattributenode(xmldom.makeelement(l_node),
                                                                 'VOUCHER'));

      l_txmsg.chktime := xmldom.getvalue(xmldom.getattributenode(xmldom.makeelement(l_node),
                                                                 'CHKTIME'));

      l_txmsg.offtime := xmldom.getvalue(xmldom.getattributenode(xmldom.makeelement(l_node),
                                                                 'OFFTIME'));
      -- tx control

      l_txmsg.txtype := xmldom.getvalue(xmldom.getattributenode(xmldom.makeelement(l_node),
                                                                'TXTYPE'));

      l_txmsg.nosubmit := xmldom.getvalue(xmldom.getattributenode(xmldom.makeelement(l_node),
                                                                  'NOSUBMIT'));

      l_txmsg.pretran := xmldom.getvalue(xmldom.getattributenode(xmldom.makeelement(l_node),
                                                                 'PRETRAN'));

      l_txmsg.late := xmldom.getvalue(xmldom.getattributenode(xmldom.makeelement(l_node),
                                                                 'LATE'));
      l_txmsg.local := xmldom.getvalue(xmldom.getattributenode(xmldom.makeelement(l_node),
                                                                 'LOCAL'));
      l_txmsg.glgp := xmldom.getvalue(xmldom.getattributenode(xmldom.makeelement(l_node),
                                                                 'GLGP'));
      l_txmsg.careby := xmldom.getvalue(xmldom.getattributenode(xmldom.makeelement(l_node),
                                                                 'CAREBY'));
      plog.debug(pkgctx,'Header:' || CHR(10) || 'txnum: ' ||
                           l_txmsg.txnum || CHR(10) || 'txaction: ' ||
                           l_txmsg.txaction || CHR(10) || 'txstatus: ' ||
                           l_txmsg.txstatus || CHR(10) || 'pretran: ' ||
                           l_txmsg.pretran
                           );
    END LOOP;
    --<<End of header transformation>>

    --<<Begin of fields transformation>>
    plog.debug(pkgctx,'Prepare to parse Message Fields');
    l_nodeList := xslprocessor.selectnodes(xmldom.makenode(l_doc),
                                           '/TransactMessage/fields/entry');

    FOR i IN 0 .. xmldom.getlength(l_nodeList) - 1 LOOP
      plog.debug(pkgctx,'parse fields: ' || i);
      l_node := xmldom.item(l_nodeList, i);
      l_fldname := xmldom.getvalue(xmldom.getattributenode(xmldom.makeelement(l_node),
                                                           'fldname'));
      l_txmsg.txfields(l_fldname).type := xmldom.getvalue(xmldom.getattributenode(xmldom.makeelement(l_node),
                                                                                  'fldtype'));
      l_txmsg.txfields(l_fldname).defname := xmldom.getvalue(xmldom.getattributenode(xmldom.makeelement(l_node),
                                                                                     'defname'));
      l_txmsg.txfields(l_fldname).value := xmldom.getnodevalue(xmldom.getfirstchild(l_node));
      plog.debug(pkgctx,'l_fldname(' || l_fldname || '): ' ||
                           l_txmsg.txfields(l_fldname).value);

    END LOOP;

    plog.debug(pkgctx,'Prepare to parse printinfo');
    l_nodeList := xslprocessor.selectnodes(xmldom.makenode(l_doc),
                                           '/TransactMessage/printinfo/entry');

    FOR i IN 0 .. xmldom.getlength(l_nodeList) - 1 LOOP
      plog.debug(pkgctx,'parse PrinInfo: ' || i);
      l_node := xmldom.item(l_nodeList, i);
      l_fldname := xmldom.getvalue(xmldom.getattributenode(xmldom.makeelement(l_node),
                                                           'fldname'));
      l_txmsg.txPrintInfo(l_fldname).custname := xmldom.getvalue(xmldom.getattributenode(xmldom.makeelement(l_node),
                                                                                         'custname'));
      l_txmsg.txPrintInfo(l_fldname).address := xmldom.getvalue(xmldom.getattributenode(xmldom.makeelement(l_node),
                                                                                        'address'));
      l_txmsg.txPrintInfo(l_fldname).license := xmldom.getvalue(xmldom.getattributenode(xmldom.makeelement(l_node),
                                                                                        'license'));
      l_txmsg.txPrintInfo(l_fldname).custody := xmldom.getvalue(xmldom.getattributenode(xmldom.makeelement(l_node),
                                                                                        'custody'));
      l_txmsg.txPrintInfo(l_fldname).bankac := xmldom.getvalue(xmldom.getattributenode(xmldom.makeelement(l_node),
                                                                                       'bankac'));
      l_txmsg.txPrintInfo(l_fldname).bankname := xmldom.getvalue(xmldom.getattributenode(xmldom.makeelement(l_node),
                                                                                       'bankname'));
      l_txmsg.txPrintInfo(l_fldname).bankque := xmldom.getvalue(xmldom.getattributenode(xmldom.makeelement(l_node),
                                                                                       'bankque'));
      l_txmsg.txPrintInfo(l_fldname).holdamt := xmldom.getvalue(xmldom.getattributenode(xmldom.makeelement(l_node),
                                                                                       'holdamt'));
      l_txmsg.txPrintInfo(l_fldname).value := xmldom.getnodevalue(xmldom.getfirstchild(l_node));
      plog.debug(pkgctx,'printinfo(' || l_fldname || '): ' ||
                           l_txmsg.txPrintInfo(l_fldname).value);

    END LOOP;

    plog.debug(pkgctx,'Prepare to parse Feemap');
    l_nodeList := xslprocessor.selectnodes(xmldom.makenode(l_doc),
                                           '/TransactMessage/feemap/entry');

    FOR i IN 0 .. xmldom.getlength(l_nodeList) - 1 LOOP
      plog.debug(pkgctx,'parse feemap: ' || i);
      l_node := xmldom.item(l_nodeList, i);
      l_txmsg.txInfo(l_fldname)(txnums.C_FEETRAN_FEECD) := xmldom.getvalue(xmldom.getattributenode(xmldom.makeelement(l_node),
                                                                                                   'feecd'));
      l_txmsg.txInfo(l_fldname)(txnums.C_FEETRAN_GLACCTNO) := xmldom.getvalue(xmldom.getattributenode(xmldom.makeelement(l_node),
                                                                                                      'glacctno'));
      l_txmsg.txInfo(l_fldname)(txnums.C_FEETRAN_FEEAMT) := xmldom.getvalue(xmldom.getattributenode(xmldom.makeelement(l_node),
                                                                                                    'feeamt'));
      l_txmsg.txInfo(l_fldname)(txnums.C_FEETRAN_VATAMT) := xmldom.getvalue(xmldom.getattributenode(xmldom.makeelement(l_node),
                                                                                                    'vatamt'));
      l_txmsg.txInfo(l_fldname)(txnums.C_FEETRAN_TXAMT) := xmldom.getvalue(xmldom.getattributenode(xmldom.makeelement(l_node),
                                                                                                   'txamt'));
      l_txmsg.txInfo(l_fldname)(txnums.C_FEETRAN_FEERATE) := xmldom.getvalue(xmldom.getattributenode(xmldom.makeelement(l_node),
                                                                                                     'feerate'));
      l_txmsg.txInfo(l_fldname)(txnums.C_FEETRAN_VATRATE) := xmldom.getvalue(xmldom.getattributenode(xmldom.makeelement(l_node),
                                                                                                     'vatrate'));
    END LOOP;

    plog.debug(pkgctx,'Prepare to parse vatvoucher');
    l_nodeList := xslprocessor.selectnodes(xmldom.makenode(l_doc),
                                           '/TransactMessage/vatvoucher/entry');

    FOR i IN 0 .. xmldom.getlength(l_nodeList) - 1 LOOP
      plog.debug(pkgctx,'parse vatvoucher: ' || i);
      l_node := xmldom.item(l_nodeList, i);
      l_txmsg.txInfo(l_fldname)(txnums.C_VATTRAN_VOUCHERNO) := xmldom.getvalue(xmldom.getattributenode(xmldom.makeelement(l_node),
                                                                                                       'voucherno'));
      l_txmsg.txInfo(l_fldname)(txnums.C_VATTRAN_VOUCHERTYPE) := xmldom.getvalue(xmldom.getattributenode(xmldom.makeelement(l_node),
                                                                                                         'vouchertype'));
      l_txmsg.txInfo(l_fldname)(txnums.C_VATTRAN_SERIALNO) := xmldom.getvalue(xmldom.getattributenode(xmldom.makeelement(l_node),
                                                                                                      'serieno'));
      l_txmsg.txInfo(l_fldname)(txnums.C_VATTRAN_VOUCHERDATE) := xmldom.getvalue(xmldom.getattributenode(xmldom.makeelement(l_node),
                                                                                                         'voucherdate'));
      l_txmsg.txInfo(l_fldname)(txnums.C_VATTRAN_CUSTID) := xmldom.getvalue(xmldom.getattributenode(xmldom.makeelement(l_node),
                                                                                                    'custid'));
      l_txmsg.txInfo(l_fldname)(txnums.C_VATTRAN_TAXCODE) := xmldom.getvalue(xmldom.getattributenode(xmldom.makeelement(l_node),
                                                                                                     'taxcode'));
      l_txmsg.txInfo(l_fldname)(txnums.C_VATTRAN_CUSTNAME) := xmldom.getvalue(xmldom.getattributenode(xmldom.makeelement(l_node),
                                                                                                      'custname'));
      l_txmsg.txInfo(l_fldname)(txnums.C_VATTRAN_ADDRESS) := xmldom.getvalue(xmldom.getattributenode(xmldom.makeelement(l_node),
                                                                                                     'address'));
      l_txmsg.txInfo(l_fldname)(txnums.C_VATTRAN_CONTENTS) := xmldom.getvalue(xmldom.getattributenode(xmldom.makeelement(l_node),
                                                                                                      'contents'));
      l_txmsg.txInfo(l_fldname)(txnums.C_VATTRAN_QTTY) := xmldom.getvalue(xmldom.getattributenode(xmldom.makeelement(l_node),
                                                                                                  'qtty'));
      l_txmsg.txInfo(l_fldname)(txnums.C_VATTRAN_PRICE) := xmldom.getvalue(xmldom.getattributenode(xmldom.makeelement(l_node),
                                                                                                   'price'));
      l_txmsg.txInfo(l_fldname)(txnums.C_VATTRAN_AMT) := xmldom.getvalue(xmldom.getattributenode(xmldom.makeelement(l_node),
                                                                                                 'amt'));
      l_txmsg.txInfo(l_fldname)(txnums.C_VATTRAN_VATRATE) := xmldom.getvalue(xmldom.getattributenode(xmldom.makeelement(l_node),
                                                                                                     'vatrate'));
      l_txmsg.txInfo(l_fldname)(txnums.C_VATTRAN_VATAMT) := xmldom.getvalue(xmldom.getattributenode(xmldom.makeelement(l_node),
                                                                                                    'vatamt'));
      l_txmsg.txInfo(l_fldname)(txnums.C_VATTRAN_DESCRIPTION) := xmldom.getvalue(xmldom.getattributenode(xmldom.makeelement(l_node),
                                                                                                         'description'));

    END LOOP;

    plog.debug(pkgctx,'Prepare to parse exception');
    l_nodeList := xslprocessor.selectnodes(xmldom.makenode(l_doc),
                                           '/TransactMessage/errorexception/entry');

    FOR i IN 0 .. xmldom.getlength(l_nodeList) - 1 LOOP
      plog.debug(pkgctx,'parse txException: ' || i);
      l_node := xmldom.item(l_nodeList, i);
      l_fldname := xmldom.getvalue(xmldom.getattributenode(xmldom.makeelement(l_node),
                                                           'fldname'));
      l_txmsg.txException(l_fldname).type:= xmldom.getvalue(xmldom.getattributenode(xmldom.makeelement(l_node),
                                                                                         'fldtype'));
      l_txmsg.txException(l_fldname).oldval := xmldom.getvalue(xmldom.getattributenode(xmldom.makeelement(l_node),
                                                                                        'oldval'));
      l_txmsg.txException(l_fldname).value := xmldom.getnodevalue(xmldom.getfirstchild(l_node));
      plog.debug(pkgctx,'Exception(' || l_fldname || '): ' ||
                           l_txmsg.txException(l_fldname).value);

    END LOOP;

    plog.debug(pkgctx,'Free resources associated');

    -- Free any resources associated with the document now it
    -- is no longer needed.
    DBMS_XMLDOM.freedocument(l_doc);
    -- Only used if variant is CLOB
    -- dbms_lob.freetemporary(p_xmlmsg);
    plog.setendsection(pkgctx, 'fn_xml2obj');
    RETURN l_txmsg;
  EXCEPTION
    WHEN OTHERS THEN
      --dbms_lob.freetemporary(p_xmlmsg);
      DBMS_XMLPARSER.freeparser(l_parser);
      DBMS_XMLDOM.freedocument(l_doc);
      plog.error(pkgctx, SQLERRM || '--' || dbms_utility.format_error_backtrace);
      plog.setendsection(pkgctx, 'fn_xml2obj');
      RAISE errnums.E_SYSTEM_ERROR;
  END fn_xml2obj;

  FUNCTION fn_obj2xml(p_txmsg tx.msg_rectype)
  RETURN VARCHAR2
  IS
   -- xmlparser
   l_parser              xmlparser.parser;
   -- Document
   l_doc            xmldom.domdocument;
   -- Elements
   l_element             xmldom.domelement;
   -- Nodes
   headernode      xmldom.domnode;
   docnode        xmldom.domnode;
   entrynode   xmldom.domnode;
   childnode   xmldom.domnode;
   textnode xmldom.DOMText;

   l_index varchar2(30); -- this must be match with arrtype index
   temp1          VARCHAR2 (32000);
   temp2          VARCHAR2 (2500);
BEGIN
   plog.setbeginsection(pkgctx, 'fn_obj2xml');

   l_parser              := xmlparser.newparser;
   xmlparser.parsebuffer (l_parser, '<TransactMessage/>');
   l_doc            := xmlparser.getdocument (l_parser);
   --xmldom.setversion (l_doc, '1.0');
   docnode        := xmldom.makenode (l_doc);

   --<< BEGIN OF CREATING MESSAGE HEADER>>
   l_element := xmldom.getdocumentelement(l_doc);
   xmldom.setattribute (l_element, 'MSGTYPE', p_txmsg.msgtype);
   xmldom.setattribute (l_element, 'TXNUM', p_txmsg.txnum);
   xmldom.setattribute (l_element, 'TXDATE', TO_CHAR(p_txmsg.txdate,systemnums.C_DATE_FORMAT));
   xmldom.setattribute (l_element, 'TXTIME', p_txmsg.txtime);
   xmldom.setattribute (l_element, 'BRID', p_txmsg.brid);
   xmldom.setattribute (l_element, 'TLID', p_txmsg.tlid);
   xmldom.setattribute (l_element, 'OFFID', p_txmsg.offid);
   xmldom.setattribute (l_element, 'OVRRQD', p_txmsg.ovrrqd);
   xmldom.setattribute (l_element, 'CHID', p_txmsg.chid);
   xmldom.setattribute (l_element, 'CHKID', p_txmsg.chkid);
   --xmldom.setattribute (l_element, 'ACTIONFLAG', p_txmsg.txaction);
   xmldom.setattribute (l_element, 'TLTXCD', p_txmsg.tltxcd);
   xmldom.setattribute (l_element, 'IBT', p_txmsg.ibt);
   xmldom.setattribute (l_element, 'BRID2', p_txmsg.brid2);
   xmldom.setattribute (l_element, 'TLID2', p_txmsg.tlid2);
   xmldom.setattribute (l_element, 'CCYUSAGE', p_txmsg.ccyusage);
   xmldom.setattribute (l_element, 'OFFLINE', p_txmsg.off_line);
   xmldom.setattribute (l_element, 'DELTD', p_txmsg.deltd);
   xmldom.setattribute (l_element, 'BRDATE', to_char(p_txmsg.brdate,systemnums.C_DATE_FORMAT));
   --xmldom.setattribute (l_element, 'PAGENO', p_txmsg.pageno);
   --xmldom.setattribute (l_element, 'TOTALPAGE', p_txmsg.totalpage);
   xmldom.setattribute (l_element, 'BUSDATE', to_char(p_txmsg.busdate,systemnums.C_DATE_FORMAT));
   xmldom.setattribute (l_element, 'TXDESC', p_txmsg.txdesc);
   xmldom.setattribute (l_element, 'IPADDRESS', p_txmsg.ipaddress);
   xmldom.setattribute (l_element, 'WSNAME', p_txmsg.wsname);
   xmldom.setattribute (l_element, 'STATUS', p_txmsg.txstatus);
   xmldom.setattribute (l_element, 'MSGSTS', p_txmsg.msgsts);
   xmldom.setattribute (l_element, 'OVRSTS', p_txmsg.ovrsts);
   xmldom.setattribute (l_element, 'BATCHNAME', p_txmsg.batchname);
   xmldom.setattribute (l_element, 'MSGAMT', p_txmsg.msgamt);
   xmldom.setattribute (l_element, 'MSGACCT', p_txmsg.msgacct);

   xmldom.setattribute (l_element, 'FEEAMT', p_txmsg.feeamt);
   xmldom.setattribute (l_element, 'VATAMT', p_txmsg.vatamt);
   xmldom.setattribute (l_element, 'VOUCHER', p_txmsg.voucher);

   xmldom.setattribute (l_element, 'CHKTIME', p_txmsg.chktime);
   xmldom.setattribute (l_element, 'OFFTIME', p_txmsg.offtime);
   xmldom.setattribute (l_element, 'TXTYPE', p_txmsg.txtype);
   xmldom.setattribute (l_element, 'NOSUBMIT', p_txmsg.nosubmit);
   xmldom.setattribute (l_element, 'PRETRAN', p_txmsg.pretran);

   --xmldom.setattribute (l_element, 'UPDATEMODE', p_txmsg.updatemode);
   xmldom.setattribute (l_element, 'LOCAL', p_txmsg.local);
   xmldom.setattribute (l_element, 'LATE', p_txmsg.late);
   --xmldom.setattribute (l_element, 'HOSTTIME', p_txmsg.HOSTTIME);
   --xmldom.setattribute (l_element, 'REFERENCE', p_txmsg.REFERENCE);
   xmldom.setattribute (l_element, 'GLGP', p_txmsg.glgp);
   xmldom.setattribute (l_element, 'CAREBY', p_txmsg.careby);

   headernode   := xmldom.appendchild (docnode, xmldom.makenode (l_element));
   --<< END of creating Message Header>>


   l_element             := xmldom.createelement (l_doc, 'fields');
   childnode    := xmldom.appendchild (headernode, xmldom.makenode (l_element));
   -- Create Fields
   l_index := p_txmsg.txfields.FIRST;
   plog.debug(pkgctx,'abt to populate fields,l_index: ' || l_index);
   WHILE (l_index IS NOT NULL)
   LOOP
       plog.debug(pkgctx,'loop with l_index: ' || l_index || ':' || p_txmsg.txfields(l_index).defname);

       l_element := xmldom.createelement (l_doc, 'entry');

       xmldom.setattribute (l_element, 'fldname', l_index);
       xmldom.setattribute (l_element, 'fldtype', p_txmsg.txfields(l_index).type);
       xmldom.setattribute (l_element, 'defname', p_txmsg.txfields(l_index).defname);
       entrynode   := xmldom.appendchild (childnode, xmldom.makenode(l_element));

       textnode := xmldom.createTextNode(l_doc, p_txmsg.txfields(l_index).value);
       entrynode := xmldom.appendChild(entrynode, xmldom.makeNode(textnode));
       -- get the next field
       l_index := p_txmsg.txfields.NEXT (l_index);
   END LOOP;
   -- Populate printInfo
   l_element             := xmldom.createelement (l_doc, 'printinfo');
   childnode    := xmldom.appendchild (headernode, xmldom.makenode (l_element));

   l_index := p_txmsg.txPrintInfo.FIRST;
   plog.debug(pkgctx,'prepare to populate printinfo, l_index: ' || l_index);
   WHILE (l_index IS NOT NULL)
   LOOP
       plog.debug(pkgctx,'loop with l_index: ' || l_index);
       l_element             := xmldom.createelement (l_doc, 'entry');

       xmldom.setattribute (l_element, 'fldname', l_index);
       xmldom.setattribute (l_element, 'custname', p_txmsg.txPrintInfo(l_index).custname);
       xmldom.setattribute (l_element, 'address', p_txmsg.txPrintInfo(l_index).address);
       xmldom.setattribute (l_element, 'license', p_txmsg.txPrintInfo(l_index).license);
       xmldom.setattribute (l_element, 'custody', p_txmsg.txPrintInfo(l_index).custody);
       xmldom.setattribute (l_element, 'bankac', p_txmsg.txPrintInfo(l_index).bankac);
       xmldom.setattribute (l_element, 'bankname', p_txmsg.txPrintInfo(l_index).bankname);
       xmldom.setattribute (l_element, 'bankque', p_txmsg.txPrintInfo(l_index).bankque);
       xmldom.setattribute (l_element, 'holdamt', p_txmsg.txPrintInfo(l_index).holdamt);
       entrynode   := xmldom.appendchild (childnode, xmldom.makenode (l_element));

       textnode := xmldom.createTextNode(l_doc, p_txmsg.txPrintInfo(l_index).value);
       entrynode := xmldom.appendChild(entrynode, xmldom.makeNode(textnode));
       -- get the next field
       l_index := p_txmsg.txPrintInfo.NEXT (l_index);
   END LOOP;

   -- Populate printInfo
   l_element             := xmldom.createelement (l_doc, 'ErrorException');
   childnode    := xmldom.appendchild (headernode, xmldom.makenode (l_element));

   l_index := p_txmsg.txException.FIRST;
   plog.debug(pkgctx,'prepare to populate ErrorException, l_index: ' || l_index);
   WHILE (l_index IS NOT NULL)
   LOOP
       plog.debug(pkgctx,'loop with l_index: ' || l_index);
       l_element             := xmldom.createelement (l_doc, 'entry');

       xmldom.setattribute (l_element, 'fldname', l_index);
       xmldom.setattribute (l_element, 'type', p_txmsg.txException(l_index).type);
       xmldom.setattribute (l_element, 'oldval', p_txmsg.txException(l_index).oldval);
       entrynode   := xmldom.appendchild (childnode, xmldom.makenode (l_element));

       textnode := xmldom.createTextNode(l_doc, p_txmsg.txException(l_index).value);
       entrynode := xmldom.appendChild(entrynode, xmldom.makeNode(textnode));
       -- get the next field
       l_index := p_txmsg.txException.NEXT (l_index);
   END LOOP;

   /*
   l_element             := xmldom.createelement (l_doc, 'ErrorException');
   childnode     := xmldom.appendchild (headernode, xmldom.makenode (l_element));

   l_element             := xmldom.createelement (l_doc, 'Entry');
   xmldom.setattribute (l_element, 'fldname', 'ERRSOURCE');
   xmldom.setattribute (l_element, 'fldtype', 'System.String');
   xmldom.setattribute (l_element, 'oldval', '');
   entrynode   := xmldom.appendchild (childnode, xmldom.makenode (l_element));
   textnode := xmldom.createTextNode(l_doc, '-100010');
   entrynode := xmldom.appendChild(entrynode, xmldom.makeNode(textnode));

   l_element             := xmldom.createelement (l_doc, 'Entry');
   xmldom.setattribute (l_element, 'fldname', 'ERRCODE');
   xmldom.setattribute (l_element, 'fldtype', 'System.Int64');
   xmldom.setattribute (l_element, 'oldval', '');
   entrynode   := xmldom.appendchild (childnode, xmldom.makenode (l_element));
   textnode := xmldom.createTextNode(l_doc, '-100010');
   entrynode := xmldom.appendChild(entrynode, xmldom.makeNode(textnode));

   l_element             := xmldom.createelement (l_doc, 'Entry');
   xmldom.setattribute (l_element, 'fldname', 'ERRMSG');
   xmldom.setattribute (l_element, 'fldtype', 'System.String');
   xmldom.setattribute (l_element, 'oldval', '');
   entrynode   := xmldom.appendchild (childnode, xmldom.makenode (l_element));
   textnode := xmldom.createTextNode(l_doc, '-100010');
   entrynode := xmldom.appendChild(entrynode, xmldom.makeNode(textnode));
   */

   xmldom.writetobuffer (l_doc, temp1);
   plog.debug(pkgctx,'got xml,length: ' || length(temp1));
   plog.debug(pkgctx,'got xml: ' || SUBSTR (temp1, 1, 1500));
   plog.debug(pkgctx,'got xml: ' || SUBSTR (temp1, 1501, 3000));
   --temp2          := SUBSTR (temp1, 1, 250);
   --DBMS_OUTPUT.put_line (temp2);

   --temp2          := SUBSTR (temp1, 251, 250);
   --DBMS_OUTPUT.put_line (temp2);
   plog.setendsection(pkgctx, 'fn_obj2xml');
   return temp1;
-- deal with exceptions
EXCEPTION
   WHEN others
   THEN
      plog.error(pkgctx,SQLERRM);
      plog.setendsection(pkgctx, 'fn_obj2xml');
      RAISE errnums.E_SYSTEM_ERROR;
END;


FUNCTION fn_xml2obj_2B(p_xmlmsg    VARCHAR2) RETURN tx.msg_2B IS
    l_parser   xmlparser.parser;
    l_doc      xmldom.domdocument;
    l_nodeList xmldom.domnodelist;
    l_node     xmldom.domnode;
    n     xmldom.domnode;

    l_fldname fldmaster.fldname%TYPE;
    l_txmsg   tx.msg_2B;
    v_Key Varchar2(100);
    v_Value Varchar2(100);


  BEGIN
    plog.setbeginsection (pkgctx, 'fn_xml2obj');

    plog.debug(pkgctx,'msg length: ' || length(p_xmlmsg));
    l_parser := xmlparser.newparser();
    plog.debug(pkgctx,'1');
    xmlparser.parseclob(l_parser, p_xmlmsg);
    plog.debug(pkgctx,'2');
    l_doc := xmlparser.getdocument(l_parser);
    plog.debug(pkgctx,'3');
    xmlparser.freeparser(l_parser);

    plog.debug(pkgctx,'Prepare to parse Message Fields');

    l_nodeList := xslprocessor.selectnodes(xmldom.makenode(l_doc),
                                           '/ArrayOfHoSEMessageEntry/hoSEMessageEntry');

    FOR i IN 0 .. xmldom.getlength(l_nodeList) - 1 LOOP
      plog.debug(pkgctx,'parse fields: ' || i);
      l_node := xmldom.item(l_nodeList, i);
      dbms_xslprocessor.valueOf(l_node,'key',v_Key);
      dbms_xslprocessor.valueOf(l_node,'value',v_Value);
      If v_Key ='order_number'  Then
        l_txmsg.order_number := TRIM(v_Value);
      Elsif v_Key ='firm' Then
        l_txmsg.firm := v_Value;
      Elsif v_Key ='order_entry_date' Then
        l_txmsg.order_entry_date := v_Value;
      End if;

      --v_Key:=xmldom.getnodevalue(xmldom.getfirstchild(l_node));
      --v_Key:=xmldom.getnodevalue(xmldom.getfirstchild('key'));
    END LOOP;


    plog.debug(pkgctx,'msg 2B l_txmsg.order_number: '||l_txmsg.order_number||' l_txmsg.firm ='|| l_txmsg.firm);
    plog.debug(pkgctx,'Free resources associated');

    -- Free any resources associated with the document now it
    -- is no longer needed.
    DBMS_XMLDOM.freedocument(l_doc);
    -- Only used if variant is CLOB
    -- dbms_lob.freetemporary(p_xmlmsg);

    plog.setendsection(pkgctx, 'fn_xml2obj');
    RETURN l_txmsg;
  EXCEPTION
    WHEN OTHERS THEN
      --dbms_lob.freetemporary(p_xmlmsg);
      DBMS_XMLPARSER.freeparser(l_parser);
      DBMS_XMLDOM.freedocument(l_doc);
      plog.error(pkgctx, SQLERRM || '--' || dbms_utility.format_error_backtrace);
      plog.setendsection(pkgctx, 'fn_xml2obj');
      RAISE errnums.E_SYSTEM_ERROR;
  END fn_xml2obj_2B;

  FUNCTION fn_xml2obj_2E(p_xmlmsg    VARCHAR2) RETURN tx.msg_2E IS
    l_parser   xmlparser.parser;
    l_doc      xmldom.domdocument;
    l_nodeList xmldom.domnodelist;
    l_node     xmldom.domnode;
    n     xmldom.domnode;

    l_fldname fldmaster.fldname%TYPE;
    l_txmsg   tx.msg_2E;
    v_Key Varchar2(100);
    v_Value Varchar2(100);


  BEGIN
    plog.setbeginsection (pkgctx, 'fn_xml2obj_2E');

    plog.debug(pkgctx,'msg length: ' || length(p_xmlmsg));
    l_parser := xmlparser.newparser();
    plog.debug(pkgctx,'1');
    xmlparser.parseclob(l_parser, p_xmlmsg);
    plog.debug(pkgctx,'2');
    l_doc := xmlparser.getdocument(l_parser);
    plog.debug(pkgctx,'3');
    xmlparser.freeparser(l_parser);

    plog.debug(pkgctx,'Prepare to parse Message Fields');

    l_nodeList := xslprocessor.selectnodes(xmldom.makenode(l_doc),
                                           '/ArrayOfHoSEMessageEntry/hoSEMessageEntry');

    FOR i IN 0 .. xmldom.getlength(l_nodeList) - 1 LOOP
      plog.debug(pkgctx,'parse fields: ' || i);
      l_node := xmldom.item(l_nodeList, i);
      dbms_xslprocessor.valueOf(l_node,'key',v_Key);
      dbms_xslprocessor.valueOf(l_node,'value',v_Value);
      If v_Key ='order_number'  Then
        l_txmsg.order_number := TRIM(v_Value);
      Elsif v_Key ='confirm_number' Then
        l_txmsg.confirm_number := TRIM(v_Value);
      Elsif v_Key ='price' Then
        l_txmsg.price := v_Value;
      Elsif v_Key ='side' Then
        l_txmsg.side := v_Value;
      Elsif v_Key ='firm' Then
        l_txmsg.firm := v_Value;
      Elsif v_Key ='volume' Then
        l_txmsg.volume := v_Value;
      Elsif v_Key ='order_entry_date' Then
        l_txmsg.order_entry_date := v_Value;
      Elsif v_Key ='filler' Then
        l_txmsg.order_entry_date := v_Value;
      End if;

      --v_Key:=xmldom.getnodevalue(xmldom.getfirstchild(l_node));
      --v_Key:=xmldom.getnodevalue(xmldom.getfirstchild('key'));
    END LOOP;


    plog.debug(pkgctx,'msg 2E l_txmsg.order_number: '||l_txmsg.order_number||' l_txmsg.confirm_number ='|| l_txmsg.confirm_number);
    plog.debug(pkgctx,'Free resources associated');

    -- Free any resources associated with the document now it
    -- is no longer needed.
    DBMS_XMLDOM.freedocument(l_doc);
    -- Only used if variant is CLOB
    -- dbms_lob.freetemporary(p_xmlmsg);

    plog.setendsection(pkgctx, 'fn_xml2obj_2E');
    RETURN l_txmsg;
  EXCEPTION
    WHEN OTHERS THEN
      --dbms_lob.freetemporary(p_xmlmsg);
      DBMS_XMLPARSER.freeparser(l_parser);
      DBMS_XMLDOM.freedocument(l_doc);
      plog.error(pkgctx, SQLERRM || '--' || dbms_utility.format_error_backtrace);
      plog.setendsection(pkgctx, 'fn_xml2obj_2E');
      RAISE errnums.E_SYSTEM_ERROR;
  END fn_xml2obj_2E;


  FUNCTION fn_xml2obj_2F(p_xmlmsg    VARCHAR2) RETURN tx.msg_2F IS
    l_parser   xmlparser.parser;
    l_doc      xmldom.domdocument;
    l_nodeList xmldom.domnodelist;
    l_node     xmldom.domnode;
    n     xmldom.domnode;

    l_fldname fldmaster.fldname%TYPE;
    l_txmsg   tx.msg_2F;
    v_Key Varchar2(100);
    v_Value Varchar2(100);


  BEGIN
    plog.setbeginsection (pkgctx, 'fn_xml2obj_2F');

    plog.debug(pkgctx,'msg length: ' || length(p_xmlmsg));
    l_parser := xmlparser.newparser();
    plog.debug(pkgctx,'1');
    xmlparser.parseclob(l_parser, p_xmlmsg);
    plog.debug(pkgctx,'2');
    l_doc := xmlparser.getdocument(l_parser);
    plog.debug(pkgctx,'3');
    xmlparser.freeparser(l_parser);

    plog.debug(pkgctx,'Prepare to parse Message Fields');

    l_nodeList := xslprocessor.selectnodes(xmldom.makenode(l_doc),
                                           '/ArrayOfHoSEMessageEntry/hoSEMessageEntry');

    FOR i IN 0 .. xmldom.getlength(l_nodeList) - 1 LOOP
      plog.debug(pkgctx,'parse fields: ' || i);
      l_node := xmldom.item(l_nodeList, i);
      dbms_xslprocessor.valueOf(l_node,'key',v_Key);
      dbms_xslprocessor.valueOf(l_node,'value',v_Value);
      If v_Key ='confirm_number'  Then
        l_txmsg.confirm_number := v_Value;
      Elsif v_Key ='firm_buy' Then
        l_txmsg.firm_buy := v_Value;
      Elsif v_Key ='price' Then
        l_txmsg.price := v_Value;
      Elsif v_Key ='side_b' Then
        l_txmsg.side_b := v_Value;
      Elsif v_Key ='volume' Then
        l_txmsg.volume := v_Value;
      Elsif v_Key ='security_symbol' Then
        l_txmsg.security_symbol := v_Value;
      Elsif v_Key ='trader_id_buy' Then
        l_txmsg.trader_id_buy := v_Value;
      Elsif v_Key ='board' Then
        l_txmsg.board := v_Value;
      Elsif v_Key ='contra_firm_sell' Then
        l_txmsg.contra_firm_sell := v_Value;
      Elsif v_Key ='trader_id_contra_side_sell' Then
        l_txmsg.trader_id_contra_side_sell := v_Value;
      End if;

      --v_Key:=xmldom.getnodevalue(xmldom.getfirstchild(l_node));
      --v_Key:=xmldom.getnodevalue(xmldom.getfirstchild('key'));
    END LOOP;


    plog.debug(pkgctx,'msg 2F l_txmsg.confirm_number: '||l_txmsg.confirm_number
                    ||' l_txmsg.contra_firm_sell'|| l_txmsg.contra_firm_sell);
    plog.debug(pkgctx,'Free resources associated');

    -- Free any resources associated with the document now it
    -- is no longer needed.
    DBMS_XMLDOM.freedocument(l_doc);
    -- Only used if variant is CLOB
    -- dbms_lob.freetemporary(p_xmlmsg);

    plog.setendsection(pkgctx, 'fn_xml2obj_2F');
    RETURN l_txmsg;
  EXCEPTION
    WHEN OTHERS THEN
      --dbms_lob.freetemporary(p_xmlmsg);
      DBMS_XMLPARSER.freeparser(l_parser);
      DBMS_XMLDOM.freedocument(l_doc);
      plog.error(pkgctx, SQLERRM || '--' || dbms_utility.format_error_backtrace);
      plog.setendsection(pkgctx, 'fn_xml2obj_2F');
      RAISE errnums.E_SYSTEM_ERROR;
  END fn_xml2obj_2F;

  FUNCTION fn_xml2obj_2L(p_xmlmsg    VARCHAR2) RETURN tx.msg_2L IS
    l_parser   xmlparser.parser;
    l_doc      xmldom.domdocument;
    l_nodeList xmldom.domnodelist;
    l_node     xmldom.domnode;
    n     xmldom.domnode;

    l_fldname fldmaster.fldname%TYPE;
    l_txmsg   tx.msg_2L;
    v_Key Varchar2(100);
    v_Value Varchar2(100);


  BEGIN
    plog.setbeginsection (pkgctx, 'fn_xml2obj_2L');

    plog.debug(pkgctx,'msg length: ' || length(p_xmlmsg));
    l_parser := xmlparser.newparser();
    plog.debug(pkgctx,'1');
    xmlparser.parseclob(l_parser, p_xmlmsg);
    plog.debug(pkgctx,'2');
    l_doc := xmlparser.getdocument(l_parser);
    plog.debug(pkgctx,'3');
    xmlparser.freeparser(l_parser);

    plog.debug(pkgctx,'Prepare to parse Message Fields');

    l_nodeList := xslprocessor.selectnodes(xmldom.makenode(l_doc),
                                           '/ArrayOfHoSEMessageEntry/hoSEMessageEntry');

    FOR i IN 0 .. xmldom.getlength(l_nodeList) - 1 LOOP
      plog.debug(pkgctx,'parse fields: ' || i);
      l_node := xmldom.item(l_nodeList, i);
      dbms_xslprocessor.valueOf(l_node,'key',v_Key);
      dbms_xslprocessor.valueOf(l_node,'value',v_Value);
      If v_Key ='confirm_number'  Then
        l_txmsg.confirm_number := v_Value;
      Elsif v_Key ='price' Then
       --Format v_Price 000066500000 value: 66.5
         --l_txmsg.price := Substr(v_Value,1,6)+ To_number('0.'||Substr(v_Value,7,6));
         l_txmsg.price := TO_NUMBER(v_Value)/1000000;

      Elsif v_Key ='side' Then
        l_txmsg.side := v_Value;
      Elsif v_Key ='contra_firm' Then
        l_txmsg.contra_firm := v_Value;
      Elsif v_Key ='firm' Then
        l_txmsg.firm := v_Value;
      Elsif v_Key ='volume' Then
        l_txmsg.volume := v_Value;
      Elsif v_Key ='deal_id' Then
        l_txmsg.deal_id := v_Value;
      End if;

      --v_Key:=xmldom.getnodevalue(xmldom.getfirstchild(l_node));
      --v_Key:=xmldom.getnodevalue(xmldom.getfirstchild('key'));
    END LOOP;


    plog.debug(pkgctx,'msg 2L l_txmsg.confirm_number: '||l_txmsg.confirm_number
                    ||' l_txmsg.firm'|| l_txmsg.firm);
    plog.debug(pkgctx,'Free resources associated');

    -- Free any resources associated with the document now it
    -- is no longer needed.
    DBMS_XMLDOM.freedocument(l_doc);
    -- Only used if variant is CLOB
    -- dbms_lob.freetemporary(p_xmlmsg);

    plog.setendsection(pkgctx, 'fn_xml2obj_2L');
    RETURN l_txmsg;
  EXCEPTION
    WHEN OTHERS THEN
      --dbms_lob.freetemporary(p_xmlmsg);
      DBMS_XMLPARSER.freeparser(l_parser);
      DBMS_XMLDOM.freedocument(l_doc);
      plog.error(pkgctx, SQLERRM || '--' || dbms_utility.format_error_backtrace);
      plog.setendsection(pkgctx, 'fn_xml2obj_2L');
      RAISE errnums.E_SYSTEM_ERROR;
  END fn_xml2obj_2L;

  FUNCTION fn_xml2obj_3C(p_xmlmsg    VARCHAR2) RETURN tx.msg_3C IS
    l_parser   xmlparser.parser;
    l_doc      xmldom.domdocument;
    l_nodeList xmldom.domnodelist;
    l_node     xmldom.domnode;
    n     xmldom.domnode;

    l_fldname fldmaster.fldname%TYPE;
    l_txmsg   tx.msg_3C;
    v_Key Varchar2(100);
    v_Value Varchar2(100);


  BEGIN
    plog.setbeginsection (pkgctx, 'fn_xml2obj_3C');

    plog.debug(pkgctx,'msg length: ' || length(p_xmlmsg));
    l_parser := xmlparser.newparser();
    plog.debug(pkgctx,'1');
    xmlparser.parseclob(l_parser, p_xmlmsg);
    plog.debug(pkgctx,'2');
    l_doc := xmlparser.getdocument(l_parser);
    plog.debug(pkgctx,'3');
    xmlparser.freeparser(l_parser);

    plog.debug(pkgctx,'Prepare to parse Message Fields');

    l_nodeList := xslprocessor.selectnodes(xmldom.makenode(l_doc),
                                           '/ArrayOfHoSEMessageEntry/hoSEMessageEntry');

    FOR i IN 0 .. xmldom.getlength(l_nodeList) - 1 LOOP
      plog.debug(pkgctx,'parse fields: ' || i);
      l_node := xmldom.item(l_nodeList, i);
      dbms_xslprocessor.valueOf(l_node,'key',v_Key);
      dbms_xslprocessor.valueOf(l_node,'value',v_Value);
      If v_Key ='contra_firm'  Then
        l_txmsg.contra_firm := v_Value;
      Elsif v_Key ='security_symbol' Then
        l_txmsg.security_symbol := v_Value;
      Elsif v_Key ='confirm_number' Then
        l_txmsg.confirm_number := v_Value;
      Elsif v_Key ='firm' Then
        l_txmsg.firm := v_Value;
      Elsif v_Key ='side' Then
        l_txmsg.side := v_Value;
      Elsif v_Key ='trader_id' Then
        l_txmsg.trader_id := v_Value;
      End if;

      --v_Key:=xmldom.getnodevalue(xmldom.getfirstchild(l_node));
      --v_Key:=xmldom.getnodevalue(xmldom.getfirstchild('key'));
    END LOOP;


    plog.debug(pkgctx,'msg 3C l_txmsg.confirm_number: '||l_txmsg.confirm_number
                    ||' l_txmsg.contra_firm'|| l_txmsg.contra_firm);
    plog.debug(pkgctx,'Free resources associated');

    -- Free any resources associated with the document now it
    -- is no longer needed.
    DBMS_XMLDOM.freedocument(l_doc);
    -- Only used if variant is CLOB
    -- dbms_lob.freetemporary(p_xmlmsg);

    plog.setendsection(pkgctx, 'fn_xml2obj_3C');
    RETURN l_txmsg;
  EXCEPTION
    WHEN OTHERS THEN
      --dbms_lob.freetemporary(p_xmlmsg);
      DBMS_XMLPARSER.freeparser(l_parser);
      DBMS_XMLDOM.freedocument(l_doc);
      plog.error(pkgctx, SQLERRM || '--' || dbms_utility.format_error_backtrace);
      plog.setendsection(pkgctx, 'fn_xml2obj_3C');
      RAISE errnums.E_SYSTEM_ERROR;
  END fn_xml2obj_3C;

  FUNCTION fn_xml2obj_3D(p_xmlmsg    VARCHAR2) RETURN tx.msg_3D IS
    l_parser   xmlparser.parser;
    l_doc      xmldom.domdocument;
    l_nodeList xmldom.domnodelist;
    l_node     xmldom.domnode;
    n     xmldom.domnode;

    l_fldname fldmaster.fldname%TYPE;
    l_txmsg   tx.msg_3D;
    v_Key Varchar2(100);
    v_Value Varchar2(100);


  BEGIN
    plog.setbeginsection (pkgctx, 'fn_xml2obj_3D');

    plog.debug(pkgctx,'msg length: ' || length(p_xmlmsg));
    l_parser := xmlparser.newparser();
    plog.debug(pkgctx,'1');
    xmlparser.parseclob(l_parser, p_xmlmsg);
    plog.debug(pkgctx,'2');
    l_doc := xmlparser.getdocument(l_parser);
    plog.debug(pkgctx,'3');
    xmlparser.freeparser(l_parser);

    plog.debug(pkgctx,'Prepare to parse Message Fields');

    l_nodeList := xslprocessor.selectnodes(xmldom.makenode(l_doc),
                                           '/ArrayOfHoSEMessageEntry/hoSEMessageEntry');

    FOR i IN 0 .. xmldom.getlength(l_nodeList) - 1 LOOP
      plog.debug(pkgctx,'parse fields: ' || i);
      l_node := xmldom.item(l_nodeList, i);
      dbms_xslprocessor.valueOf(l_node,'key',v_Key);
      dbms_xslprocessor.valueOf(l_node,'value',v_Value);
      If v_Key ='firm'  Then
        l_txmsg.firm := v_Value;
      Elsif v_Key ='confirm_number' Then
        l_txmsg.confirm_number := v_Value;
      Elsif v_Key ='reply_code' Then
        l_txmsg.reply_code := v_Value;
      End if;

      --v_Key:=xmldom.getnodevalue(xmldom.getfirstchild(l_node));
      --v_Key:=xmldom.getnodevalue(xmldom.getfirstchild('key'));
    END LOOP;


    plog.debug(pkgctx,'msg 3D l_txmsg.confirm_number: '||l_txmsg.confirm_number
                    ||' l_txmsg.firm'|| l_txmsg.firm);
    plog.debug(pkgctx,'Free resources associated');

    -- Free any resources associated with the document now it
    -- is no longer needed.
    DBMS_XMLDOM.freedocument(l_doc);
    -- Only used if variant is CLOB
    -- dbms_lob.freetemporary(p_xmlmsg);

    plog.setendsection(pkgctx, 'fn_xml2obj_3D');
    RETURN l_txmsg;
  EXCEPTION
    WHEN OTHERS THEN
      --dbms_lob.freetemporary(p_xmlmsg);
      DBMS_XMLPARSER.freeparser(l_parser);
      DBMS_XMLDOM.freedocument(l_doc);
      plog.error(pkgctx, SQLERRM || '--' || dbms_utility.format_error_backtrace);
      plog.setendsection(pkgctx, 'fn_xml2obj_3D');
      RAISE errnums.E_SYSTEM_ERROR;
  END fn_xml2obj_3D;

    FUNCTION fn_xml2obj_2D(p_xmlmsg    VARCHAR2) RETURN tx.msg_2D IS
    l_parser   xmlparser.parser;
    l_doc      xmldom.domdocument;
    l_nodeList xmldom.domnodelist;
    l_node     xmldom.domnode;
    n     xmldom.domnode;

    l_fldname fldmaster.fldname%TYPE;
    l_txmsg   tx.msg_2D;
    v_Key Varchar2(100);
    v_Value Varchar2(100);


  BEGIN
    plog.setbeginsection (pkgctx, 'fn_xml2obj_2D');

    plog.debug(pkgctx,'msg length: ' || length(p_xmlmsg));
    l_parser := xmlparser.newparser();
    plog.debug(pkgctx,'1');
    xmlparser.parseclob(l_parser, p_xmlmsg);
    plog.debug(pkgctx,'2');
    l_doc := xmlparser.getdocument(l_parser);
    plog.debug(pkgctx,'3');
    xmlparser.freeparser(l_parser);

    plog.debug(pkgctx,'Prepare to parse Message Fields');

    l_nodeList := xslprocessor.selectnodes(xmldom.makenode(l_doc),
                                           '/ArrayOfHoSEMessageEntry/hoSEMessageEntry');

    FOR i IN 0 .. xmldom.getlength(l_nodeList) - 1 LOOP
      plog.debug(pkgctx,'parse fields: ' || i);
      l_node := xmldom.item(l_nodeList, i);
      dbms_xslprocessor.valueOf(l_node,'key',v_Key);
      dbms_xslprocessor.valueOf(l_node,'value',v_Value);
      If v_Key ='ordernumber'  Then
        l_txmsg.ordernumber := Trim(v_Value);
      Elsif v_Key ='price' Then
        l_txmsg.price := Trim(v_Value);
      End if;

      --v_Key:=xmldom.getnodevalue(xmldom.getfirstchild(l_node));
      --v_Key:=xmldom.getnodevalue(xmldom.getfirstchild('key'));
    END LOOP;


    plog.debug(pkgctx,'msg 2D l_txmsg.order_number: '||l_txmsg.ordernumber
                    ||' l_txmsg.price'|| l_txmsg.price);
    plog.debug(pkgctx,'Free resources associated');

    -- Free any resources associated with the document now it
    -- is no longer needed.
    DBMS_XMLDOM.freedocument(l_doc);
    -- Only used if variant is CLOB
    -- dbms_lob.freetemporary(p_xmlmsg);

    plog.setendsection(pkgctx, 'fn_xml2obj_2D');
    RETURN l_txmsg;
  EXCEPTION
    WHEN OTHERS THEN
      --dbms_lob.freetemporary(p_xmlmsg);
      DBMS_XMLPARSER.freeparser(l_parser);
      DBMS_XMLDOM.freedocument(l_doc);
      plog.error(pkgctx, SQLERRM || '--' || dbms_utility.format_error_backtrace);
      plog.setendsection(pkgctx, 'fn_xml2obj_2D');
      RAISE errnums.E_SYSTEM_ERROR;
  END fn_xml2obj_2D;



  FUNCTION fn_xml2obj_TS(p_xmlmsg    VARCHAR2) RETURN tx.msg_TS IS
    l_parser   xmlparser.parser;
    l_doc      xmldom.domdocument;
    l_nodeList xmldom.domnodelist;
    l_node     xmldom.domnode;
    n     xmldom.domnode;

    l_fldname fldmaster.fldname%TYPE;
    l_txmsg   tx.msg_TS;
    v_Key Varchar2(100);
    v_Value Varchar2(100);


  BEGIN
    plog.setbeginsection (pkgctx, 'fn_xml2obj_TS');

    plog.debug(pkgctx,'msg length: ' || length(p_xmlmsg));
    l_parser := xmlparser.newparser();
    plog.debug(pkgctx,'1');
    xmlparser.parseclob(l_parser, p_xmlmsg);
    plog.debug(pkgctx,'2');
    l_doc := xmlparser.getdocument(l_parser);
    plog.debug(pkgctx,'3');
    xmlparser.freeparser(l_parser);

    plog.debug(pkgctx,'Prepare to parse Message Fields');

    l_nodeList := xslprocessor.selectnodes(xmldom.makenode(l_doc),
                                           '/ArrayOfHoSEMessageEntry/hoSEMessageEntry');

    FOR i IN 0 .. xmldom.getlength(l_nodeList) - 1 LOOP
      plog.debug(pkgctx,'parse fields: ' || i);
      l_node := xmldom.item(l_nodeList, i);
      dbms_xslprocessor.valueOf(l_node,'key',v_Key);
      dbms_xslprocessor.valueOf(l_node,'value',v_Value);
      If v_Key ='timestamp'  Then
        l_txmsg.timestamp := v_Value;
      End if;

    END LOOP;


    plog.debug(pkgctx,'msg TS l_txmsg.timestamp: '||l_txmsg.timestamp);
    plog.debug(pkgctx,'Free resources associated');

    -- Free any resources associated with the document now it
    -- is no longer needed.
    DBMS_XMLDOM.freedocument(l_doc);
    -- Only used if variant is CLOB
    -- dbms_lob.freetemporary(p_xmlmsg);

    plog.setendsection(pkgctx, 'fn_xml2obj_TS');
    RETURN l_txmsg;
  EXCEPTION
    WHEN OTHERS THEN
      --dbms_lob.freetemporary(p_xmlmsg);
      DBMS_XMLPARSER.freeparser(l_parser);
      DBMS_XMLDOM.freedocument(l_doc);
      plog.error(pkgctx, SQLERRM || '--' || dbms_utility.format_error_backtrace);
      plog.setendsection(pkgctx, 'fn_xml2obj_TS');
      RAISE errnums.E_SYSTEM_ERROR;
  END fn_xml2obj_TS;


  FUNCTION fn_xml2obj_SC(p_xmlmsg    VARCHAR2) RETURN tx.msg_SC IS
    l_parser   xmlparser.parser;
    l_doc      xmldom.domdocument;
    l_nodeList xmldom.domnodelist;
    l_node     xmldom.domnode;
    n     xmldom.domnode;

    l_fldname fldmaster.fldname%TYPE;
    l_txmsg   tx.msg_SC;
    v_Key Varchar2(100);
    v_Value Varchar2(100);


  BEGIN
    plog.setbeginsection (pkgctx, 'fn_xml2obj_SC');

    plog.debug(pkgctx,'msg length: ' || length(p_xmlmsg));
    l_parser := xmlparser.newparser();
    plog.debug(pkgctx,'1');
    xmlparser.parseclob(l_parser, p_xmlmsg);
    plog.debug(pkgctx,'2');
    l_doc := xmlparser.getdocument(l_parser);
    plog.debug(pkgctx,'3');
    xmlparser.freeparser(l_parser);

    plog.debug(pkgctx,'Prepare to parse Message Fields');

    l_nodeList := xslprocessor.selectnodes(xmldom.makenode(l_doc),
                                           '/ArrayOfHoSEMessageEntry/hoSEMessageEntry');

    FOR i IN 0 .. xmldom.getlength(l_nodeList) - 1 LOOP
      plog.debug(pkgctx,'parse fields: ' || i);
      l_node := xmldom.item(l_nodeList, i);
      dbms_xslprocessor.valueOf(l_node,'key',v_Key);
      dbms_xslprocessor.valueOf(l_node,'value',v_Value);
      If v_Key ='timestamp'  Then
        l_txmsg.timestamp := v_Value;
      Elsif v_Key ='system_control_code' Then
        l_txmsg.system_control_code := v_Value;
      End if;

    END LOOP;


    plog.debug(pkgctx,'msg SC l_txmsg.timestamp: '||l_txmsg.timestamp
                       ||'l_txmsg.system_control_code: '||l_txmsg.system_control_code);
    plog.debug(pkgctx,'Free resources associated');

    -- Free any resources associated with the document now it
    -- is no longer needed.
    DBMS_XMLDOM.freedocument(l_doc);
    -- Only used if variant is CLOB
    -- dbms_lob.freetemporary(p_xmlmsg);

    plog.setendsection(pkgctx, 'fn_xml2obj_SC');
    RETURN l_txmsg;
  EXCEPTION
    WHEN OTHERS THEN
      --dbms_lob.freetemporary(p_xmlmsg);
      DBMS_XMLPARSER.freeparser(l_parser);
      DBMS_XMLDOM.freedocument(l_doc);
      plog.error(pkgctx, SQLERRM || '--' || dbms_utility.format_error_backtrace);
      plog.setendsection(pkgctx, 'fn_xml2obj_SC');
      RAISE errnums.E_SYSTEM_ERROR;
  END fn_xml2obj_SC;



 FUNCTION fn_xml2obj_SU(p_xmlmsg    VARCHAR2) RETURN tx.msg_SU IS
    l_parser   xmlparser.parser;
    l_doc      xmldom.domdocument;
    l_nodeList xmldom.domnodelist;
    l_node     xmldom.domnode;
    n     xmldom.domnode;

    l_fldname fldmaster.fldname%TYPE;
    l_txmsg   tx.msg_SU;
    v_Key Varchar2(100);
    v_Value Varchar2(100);


  BEGIN
    plog.setbeginsection (pkgctx, 'fn_xml2obj_SU');

    plog.debug(pkgctx,'msg length: ' || length(p_xmlmsg));
    l_parser := xmlparser.newparser();
    plog.debug(pkgctx,'1');
    xmlparser.parseclob(l_parser, p_xmlmsg);
    plog.debug(pkgctx,'2');
    l_doc := xmlparser.getdocument(l_parser);
    plog.debug(pkgctx,'3');
    xmlparser.freeparser(l_parser);

    plog.debug(pkgctx,'Prepare to parse Message Fields');

    l_nodeList := xslprocessor.selectnodes(xmldom.makenode(l_doc),
                                           '/ArrayOfHoSEMessageEntry/hoSEMessageEntry');

    FOR i IN 0 .. xmldom.getlength(l_nodeList) - 1 LOOP
      plog.debug(pkgctx,'parse fields: ' || i);
      l_node := xmldom.item(l_nodeList, i);
      dbms_xslprocessor.valueOf(l_node,'key',v_Key);
      dbms_xslprocessor.valueOf(l_node,'value',v_Value);
      If v_Key ='floor_price'  Then
        l_txmsg.floor_price := trim(v_Value);
      Elsif v_Key ='benefit' Then
        l_txmsg.benefit := trim(v_Value);
      Elsif v_Key ='ceiling_price' Then
        l_txmsg.ceiling_price := trim(v_Value);
      Elsif v_Key ='open_price' Then
        l_txmsg.open_price := trim(v_Value);
      Elsif v_Key ='security_name' Then
        l_txmsg.security_name := trim(v_Value);
      Elsif v_Key ='security_number_new' Then
        l_txmsg.security_number_new := trim(v_Value);
      Elsif v_Key ='prior_close_price' Then
        l_txmsg.prior_close_price := trim(v_Value);
      Elsif v_Key ='halt_resume_flag' Then
        l_txmsg.halt_resume_flag := trim(v_Value);
      Elsif v_Key ='notice' Then
        l_txmsg.notice := trim(v_Value);
      Elsif v_Key ='delist' Then
        l_txmsg.delist := trim(v_Value);
      Elsif v_Key ='par_value' Then
        l_txmsg.par_value := trim(v_Value);
      Elsif v_Key ='total_shares_traded' Then
        l_txmsg.total_shares_traded := trim(v_Value);
      Elsif v_Key ='security_number_old' Then
        l_txmsg.security_number_old := trim(v_Value);
      Elsif v_Key ='board_lot' Then
        l_txmsg.board_lot := trim(v_Value);
      Elsif v_Key ='highest_price' Then
        l_txmsg.highest_price := trim(v_Value);
      Elsif v_Key ='suspension' Then
        l_txmsg.suspension := trim(v_Value);
      Elsif v_Key ='sector_number' Then
        l_txmsg.sector_number := trim(v_Value);
      Elsif v_Key ='client_id_required' Then
        l_txmsg.client_id_required := trim(v_Value);
      Elsif v_Key ='sdc_flag' Then
        l_txmsg.sdc_flag := trim(v_Value);
      Elsif v_Key ='prior_close_date' Then
        l_txmsg.prior_close_date := trim(v_Value);
      Elsif v_Key ='market_id' Then
        l_txmsg.market_id := trim(v_Value);
      Elsif v_Key ='meeting' Then
        l_txmsg.meeting := trim(v_Value);
      Elsif v_Key ='filler_5' Then
        l_txmsg.filler_5 := trim(v_Value);
      Elsif v_Key ='security_symbol' Then
        l_txmsg.security_symbol := trim(v_Value);
      Elsif v_Key ='split' Then
        l_txmsg.split := trim(v_Value);
      Elsif v_Key ='filler_4' Then
        l_txmsg.filler_4 := trim(v_Value);
      Elsif v_Key ='security_type' Then
        l_txmsg.security_type := trim(v_Value);
      Elsif v_Key ='filler_3' Then
        l_txmsg.filler_3 := trim(v_Value);
      Elsif v_Key ='lowest_price' Then
        l_txmsg.lowest_price := trim(v_Value);
      Elsif v_Key ='filler_2' Then
        l_txmsg.filler_2 := trim(v_Value);
      Elsif v_Key ='filler_1' Then
        l_txmsg.filler_1 := trim(v_Value);
      Elsif v_Key ='last_sale_price' Then
        l_txmsg.last_sale_price := trim(v_Value);
      /*--Ngay 10/04/2017 CW NamTV Them thong tin ma chung quyen*/
      Elsif v_Key ='underlying_symbol' Then
        l_txmsg.underlyingsymbol := v_Value;
      Elsif v_Key ='issuer_name' Then
        l_txmsg.issuername := v_Value;
      Elsif v_Key ='covered_warrant_type' Then
        l_txmsg.coveredwarranttype := v_Value;
      Elsif v_Key ='maturity_date' Then
        l_txmsg.maturitydate := v_Value;
      Elsif v_Key ='last_trading_date' Then
        l_txmsg.lasttradingdate := v_Value;
      Elsif v_Key ='exercise_price' Then
        l_txmsg.exerciseprice := v_Value;
      Elsif v_Key ='exercise_ratio' Then
        l_txmsg.exerciseratio := v_Value;
      Elsif v_Key ='listed_share' Then
        l_txmsg.listedshare := v_Value;
      /*--NamTV End*/
      --LoLeHSX
      Elsif v_Key = 'odd_lot_halt_resume_flag' Then
        l_txmsg.odd_lot_halt_resume_flag := v_Value;
      --End LoLeHSX
      End if;

    END LOOP;


    plog.debug(pkgctx,'msg SU l_txmsg.security_symbol: '||l_txmsg.security_symbol
                       ||'l_txmsg.ceiling_price: '||l_txmsg.ceiling_price
                       ||'l_txmsg.floor_price: '||l_txmsg.floor_price);
    plog.debug(pkgctx,'Free resources associated');

    -- Free any resources associated with the document now it
    -- is no longer needed.
    DBMS_XMLDOM.freedocument(l_doc);
    -- Only used if variant is CLOB
    -- dbms_lob.freetemporary(p_xmlmsg);

    plog.setendsection(pkgctx, 'fn_xml2obj_SU');
    RETURN l_txmsg;
  EXCEPTION
    WHEN OTHERS THEN
      --dbms_lob.freetemporary(p_xmlmsg);
      DBMS_XMLPARSER.freeparser(l_parser);
      DBMS_XMLDOM.freedocument(l_doc);
      plog.error(pkgctx, SQLERRM || '--' || dbms_utility.format_error_backtrace);
      plog.setendsection(pkgctx, 'fn_xml2obj_SU');
      RAISE errnums.E_SYSTEM_ERROR;
  END fn_xml2obj_SU;




FUNCTION fn_xml2obj_SS(p_xmlmsg    VARCHAR2) RETURN tx.msg_SS IS
    l_parser   xmlparser.parser;
    l_doc      xmldom.domdocument;
    l_nodeList xmldom.domnodelist;
    l_node     xmldom.domnode;
    n     xmldom.domnode;

    l_fldname fldmaster.fldname%TYPE;
    l_txmsg   tx.msg_SS;
    v_Key Varchar2(100);
    v_Value Varchar2(100);


  BEGIN
    plog.setbeginsection (pkgctx, 'fn_xml2obj_SS');

    plog.debug(pkgctx,'msg length: ' || length(p_xmlmsg));
    l_parser := xmlparser.newparser();
    plog.debug(pkgctx,'1');
    xmlparser.parseclob(l_parser, p_xmlmsg);
    plog.debug(pkgctx,'2');
    l_doc := xmlparser.getdocument(l_parser);
    plog.debug(pkgctx,'3');
    xmlparser.freeparser(l_parser);

    plog.debug(pkgctx,'Prepare to parse Message Fields');

    l_nodeList := xslprocessor.selectnodes(xmldom.makenode(l_doc),
                                           '/ArrayOfHoSEMessageEntry/hoSEMessageEntry');

    FOR i IN 0 .. xmldom.getlength(l_nodeList) - 1 LOOP

      plog.debug(pkgctx,'parse fields: ' || i);
      l_node := xmldom.item(l_nodeList, i);
      dbms_xslprocessor.valueOf(l_node,'key',v_Key);
      dbms_xslprocessor.valueOf(l_node,'value',v_Value);

      If v_Key ='board_lot'  Then
        l_txmsg.board_lot := trim(v_Value);
      Elsif v_Key ='floor_price' Then
        l_txmsg.floor_price := trim(v_Value);
      Elsif v_Key ='benefit' Then
        l_txmsg.benefit := trim(v_Value);
      Elsif v_Key ='suspension' Then
        l_txmsg.suspension := trim(v_Value);
      Elsif v_Key ='sector_number' Then
        l_txmsg.sector_number := trim(v_Value);
      Elsif v_Key ='system_control_code' Then
        l_txmsg.system_control_code := trim(v_Value);
      Elsif v_Key ='ceiling' Then
        l_txmsg.ceiling := trim(v_Value);
      Elsif v_Key ='meeting' Then
        l_txmsg.meeting := trim(v_Value);
      Elsif v_Key ='security_number' Then
        l_txmsg.security_number := trim(v_Value);
      Elsif v_Key ='filler_6' Then
        l_txmsg.filler_6 := trim(v_Value);
      Elsif v_Key ='filler_5' Then
        l_txmsg.filler_5 := trim(v_Value);
      Elsif v_Key ='prior_close_price' Then
        l_txmsg.prior_close_price := trim(v_Value);
      Elsif v_Key ='halt_resume_flag' Then
        l_txmsg.halt_resume_flag := trim(v_Value);
      Elsif v_Key ='filler_4' Then
        l_txmsg.filler_4 := trim(v_Value);
      Elsif v_Key ='split' Then
        l_txmsg.split := trim(v_Value);
      Elsif v_Key ='security_type' Then
        l_txmsg.security_type := trim(v_Value);
      Elsif v_Key ='filler_3' Then
        l_txmsg.filler_3 := trim(v_Value);
      Elsif v_Key ='delist' Then
        l_txmsg.delist := trim(v_Value);
      Elsif v_Key ='filler_2' Then
        l_txmsg.filler_2 := trim(v_Value);
      Elsif v_Key ='notice' Then
        l_txmsg.notice := trim(v_Value);
      Elsif v_Key ='filler_1' Then
        l_txmsg.filler_1 := trim(v_Value);
      /*--Ngay 10/04/2017 CW NamTV Them thong tin ma chung quyen*/
      Elsif v_Key ='underlying_symbol' Then
        l_txmsg.underlyingsymbol := v_Value;
      Elsif v_Key ='issuer_name' Then
        l_txmsg.issuername := v_Value;
      Elsif v_Key ='covered_warrant_type' Then
        l_txmsg.coveredwarranttype := v_Value;
      Elsif v_Key ='maturity_date' Then
        l_txmsg.maturitydate := v_Value;
      Elsif v_Key ='last_trading_date' Then
        l_txmsg.lasttradingdate := v_Value;
      Elsif v_Key ='exercise_price' Then
        l_txmsg.exerciseprice := v_Value;
      Elsif v_Key ='exercise_ratio' Then
        l_txmsg.exerciseratio := v_Value;
      Elsif v_Key ='listed_share' Then
        l_txmsg.listedshare := v_Value;
      /*--NamTV End*/
      --LoLeHSX
      Elsif v_Key = 'odd_lot_halt_resume_flag' Then
        l_txmsg.odd_lot_halt_resume_flag := v_Value;
      --End LoLeHSX
      End if;
    END LOOP;


    plog.debug(pkgctx,'msg SU l_txmsg.security_number: '||l_txmsg.security_number
                       ||'l_txmsg.ceiling: '||l_txmsg.ceiling
                       ||'l_txmsg.floor_price: '||l_txmsg.floor_price);
    plog.debug(pkgctx,'Free resources associated');

    -- Free any resources associated with the document now it
    -- is no longer needed.
    DBMS_XMLDOM.freedocument(l_doc);
    -- Only used if variant is CLOB
    -- dbms_lob.freetemporary(p_xmlmsg);

    plog.setendsection(pkgctx, 'fn_xml2obj_SS');
    RETURN l_txmsg;
  EXCEPTION
    WHEN OTHERS THEN
      --dbms_lob.freetemporary(p_xmlmsg);
      DBMS_XMLPARSER.freeparser(l_parser);
      DBMS_XMLDOM.freedocument(l_doc);
      plog.error(pkgctx, SQLERRM || '--' || dbms_utility.format_error_backtrace);
      plog.setendsection(pkgctx, 'fn_xml2obj_SS');
      RAISE errnums.E_SYSTEM_ERROR;
  END fn_xml2obj_SS;


  FUNCTION fn_xml2obj_TR(p_xmlmsg    VARCHAR2) RETURN tx.msg_TR IS
    l_parser   xmlparser.parser;
    l_doc      xmldom.domdocument;
    l_nodeList xmldom.domnodelist;
    l_node     xmldom.domnode;
    n     xmldom.domnode;

    l_fldname fldmaster.fldname%TYPE;
    l_txmsg   tx.msg_TR;
    v_Key Varchar2(100);
    v_Value Varchar2(100);


  BEGIN
    plog.setbeginsection (pkgctx, 'fn_xml2obj_TR');

    plog.debug(pkgctx,'msg length: ' || length(p_xmlmsg));
    l_parser := xmlparser.newparser();
    plog.debug(pkgctx,'1');
    xmlparser.parseclob(l_parser, p_xmlmsg);
    plog.debug(pkgctx,'2');
    l_doc := xmlparser.getdocument(l_parser);
    plog.debug(pkgctx,'3');
    xmlparser.freeparser(l_parser);

    plog.debug(pkgctx,'Prepare to parse Message Fields');

    l_nodeList := xslprocessor.selectnodes(xmldom.makenode(l_doc),
                                           '/ArrayOfHoSEMessageEntry/hoSEMessageEntry');

    FOR i IN 0 .. xmldom.getlength(l_nodeList) - 1 LOOP
      plog.debug(pkgctx,'parse fields: ' || i);
      l_node := xmldom.item(l_nodeList, i);
      dbms_xslprocessor.valueOf(l_node,'key',v_Key);
      dbms_xslprocessor.valueOf(l_node,'value',v_Value);
      If v_Key ='current_room'  Then
        l_txmsg.current_room := v_Value;
      Elsif v_Key ='security_number' Then
        l_txmsg.security_number := v_Value;
      Elsif v_Key ='total_room' Then
        l_txmsg.total_room := v_Value;
      End if;

    END LOOP;


    plog.debug(pkgctx,'msg TR l_txmsg.security_number: '||l_txmsg.security_number
                       ||'l_txmsg.current_room: '||l_txmsg.current_room);
    plog.debug(pkgctx,'Free resources associated');

    -- Free any resources associated with the document now it
    -- is no longer needed.
    DBMS_XMLDOM.freedocument(l_doc);
    -- Only used if variant is CLOB
    -- dbms_lob.freetemporary(p_xmlmsg);

    plog.setendsection(pkgctx, 'fn_xml2obj_TR');
    RETURN l_txmsg;
  EXCEPTION
    WHEN OTHERS THEN
      --dbms_lob.freetemporary(p_xmlmsg);
      DBMS_XMLPARSER.freeparser(l_parser);
      DBMS_XMLDOM.freedocument(l_doc);
      plog.error(pkgctx, SQLERRM || '--' || dbms_utility.format_error_backtrace);
      plog.setendsection(pkgctx, 'fn_xml2obj_TR');
      RAISE errnums.E_SYSTEM_ERROR;
  END fn_xml2obj_TR;


FUNCTION fn_xml2obj_GA(p_xmlmsg    VARCHAR2) RETURN tx.msg_GA IS
    l_parser   xmlparser.parser;
    l_doc      xmldom.domdocument;
    l_nodeList xmldom.domnodelist;
    l_node     xmldom.domnode;
    n     xmldom.domnode;

    l_fldname fldmaster.fldname%TYPE;
    l_txmsg   tx.msg_GA;
    v_Key Varchar2(100);
    v_Value Varchar2(100);


  BEGIN
    plog.setbeginsection (pkgctx, 'fn_xml2obj_GA');

    plog.debug(pkgctx,'msg length: ' || length(p_xmlmsg));
    l_parser := xmlparser.newparser();
    plog.debug(pkgctx,'1');
    xmlparser.parseclob(l_parser, p_xmlmsg);
    plog.debug(pkgctx,'2');
    l_doc := xmlparser.getdocument(l_parser);
    plog.debug(pkgctx,'3');
    xmlparser.freeparser(l_parser);

    plog.debug(pkgctx,'Prepare to parse Message Fields');

    l_nodeList := xslprocessor.selectnodes(xmldom.makenode(l_doc),
                                           '/ArrayOfHoSEMessageEntry/hoSEMessageEntry');

    FOR i IN 0 .. xmldom.getlength(l_nodeList) - 1 LOOP
      plog.debug(pkgctx,'parse fields: ' || i);
      l_node := xmldom.item(l_nodeList, i);
      dbms_xslprocessor.valueOf(l_node,'key',v_Key);
      dbms_xslprocessor.valueOf(l_node,'value',v_Value);
      If v_Key ='admin_message_text'  Then
        l_txmsg.admin_message_text := v_Value;
      Elsif v_Key ='admin_message_length' Then
        l_txmsg.admin_message_length := v_Value;
      End if;

    END LOOP;


    plog.debug(pkgctx,'msg GA l_txmsg.admin_message_text: '||l_txmsg.admin_message_text
                       ||'l_txmsg.admin_message_length: '||l_txmsg.admin_message_length);
    plog.debug(pkgctx,'Free resources associated');

    -- Free any resources associated with the document now it
    -- is no longer needed.
    DBMS_XMLDOM.freedocument(l_doc);
    -- Only used if variant is CLOB
    -- dbms_lob.freetemporary(p_xmlmsg);

    plog.setendsection(pkgctx, 'fn_xml2obj_GA');
    RETURN l_txmsg;
  EXCEPTION
    WHEN OTHERS THEN
      --dbms_lob.freetemporary(p_xmlmsg);
      DBMS_XMLPARSER.freeparser(l_parser);
      DBMS_XMLDOM.freedocument(l_doc);
      plog.error(pkgctx, SQLERRM || '--' || dbms_utility.format_error_backtrace);
      plog.setendsection(pkgctx, 'fn_xml2obj_GA');
      RAISE errnums.E_SYSTEM_ERROR;
  END fn_xml2obj_GA;

  FUNCTION fn_xml2obj_BS(p_xmlmsg    VARCHAR2) RETURN tx.msg_BS IS
    l_parser   xmlparser.parser;
    l_doc      xmldom.domdocument;
    l_nodeList xmldom.domnodelist;
    l_node     xmldom.domnode;
    n     xmldom.domnode;

    l_fldname fldmaster.fldname%TYPE;
    l_txmsg   tx.msg_BS;
    v_Key Varchar2(100);
    v_Value Varchar2(100);


  BEGIN
    plog.setbeginsection (pkgctx, 'fn_xml2obj_BS');

    plog.debug(pkgctx,'msg length: ' || length(p_xmlmsg));
    l_parser := xmlparser.newparser();
    plog.debug(pkgctx,'1');
    xmlparser.parseclob(l_parser, p_xmlmsg);
    plog.debug(pkgctx,'2');
    l_doc := xmlparser.getdocument(l_parser);
    plog.debug(pkgctx,'3');
    xmlparser.freeparser(l_parser);

    plog.debug(pkgctx,'Prepare to parse Message Fields');

    l_nodeList := xslprocessor.selectnodes(xmldom.makenode(l_doc),
                                           '/ArrayOfHoSEMessageEntry/hoSEMessageEntry');

    FOR i IN 0 .. xmldom.getlength(l_nodeList) - 1 LOOP
      plog.debug(pkgctx,'parse fields: ' || i);
      l_node := xmldom.item(l_nodeList, i);
      dbms_xslprocessor.valueOf(l_node,'key',v_Key);
      dbms_xslprocessor.valueOf(l_node,'value',v_Value);
      If v_Key ='firm'  Then
        l_txmsg.firm := v_Value;
      Elsif v_Key ='automatch_halt_flag' Then
        l_txmsg.automatch_halt_flag := v_Value;
      Elsif v_Key ='put_through_halt_flag' Then
        l_txmsg.put_through_halt_flag := v_Value;
      End if;

    END LOOP;


    plog.debug(pkgctx,'msg BS l_txmsg.firm: '||l_txmsg.firm
                       ||'l_txmsg.automatch_halt_flag: '||l_txmsg.automatch_halt_flag
                       ||'l_txmsg.put_through_halt_flag: '||l_txmsg.put_through_halt_flag);
    plog.debug(pkgctx,'Free resources associated');

    -- Free any resources associated with the document now it
    -- is no longer needed.
    DBMS_XMLDOM.freedocument(l_doc);
    -- Only used if variant is CLOB
    -- dbms_lob.freetemporary(p_xmlmsg);

    plog.setendsection(pkgctx, 'fn_xml2obj_BS');
    RETURN l_txmsg;
  EXCEPTION
    WHEN OTHERS THEN
      --dbms_lob.freetemporary(p_xmlmsg);
      DBMS_XMLPARSER.freeparser(l_parser);
      DBMS_XMLDOM.freedocument(l_doc);
      plog.error(pkgctx, SQLERRM || '--' || dbms_utility.format_error_backtrace);
      plog.setendsection(pkgctx, 'fn_xml2obj_BS');
      RAISE errnums.E_SYSTEM_ERROR;
  END fn_xml2obj_BS;

  FUNCTION fn_xml2obj_TC(p_xmlmsg    VARCHAR2) RETURN tx.msg_TC IS
    l_parser   xmlparser.parser;
    l_doc      xmldom.domdocument;
    l_nodeList xmldom.domnodelist;
    l_node     xmldom.domnode;
    n     xmldom.domnode;

    l_fldname fldmaster.fldname%TYPE;
    l_txmsg   tx.msg_TC;
    v_Key Varchar2(100);
    v_Value Varchar2(100);


  BEGIN
    plog.setbeginsection (pkgctx, 'fn_xml2obj_TC');

    plog.debug(pkgctx,'msg length: ' || length(p_xmlmsg));
    l_parser := xmlparser.newparser();
    plog.debug(pkgctx,'1');
    xmlparser.parseclob(l_parser, p_xmlmsg);
    plog.debug(pkgctx,'2');
    l_doc := xmlparser.getdocument(l_parser);
    plog.debug(pkgctx,'3');
    xmlparser.freeparser(l_parser);

    plog.debug(pkgctx,'Prepare to parse Message Fields');

    l_nodeList := xslprocessor.selectnodes(xmldom.makenode(l_doc),
                                           '/ArrayOfHoSEMessageEntry/hoSEMessageEntry');

    FOR i IN 0 .. xmldom.getlength(l_nodeList) - 1 LOOP
      plog.debug(pkgctx,'parse fields: ' || i);
      l_node := xmldom.item(l_nodeList, i);
      dbms_xslprocessor.valueOf(l_node,'key',v_Key);
      dbms_xslprocessor.valueOf(l_node,'value',v_Value);
      If v_Key ='firm'  Then
        l_txmsg.firm := v_Value;
      Elsif v_Key ='trader_id' Then
        l_txmsg.trader_id := v_Value;
      Elsif v_Key ='trader_status' Then
        l_txmsg.trader_status := v_Value;
      End if;

    END LOOP;


    plog.debug(pkgctx,'msg TC l_txmsg.firm: '||l_txmsg.firm
                       ||'l_txmsg.trader_id: '||l_txmsg.trader_id
                       ||'l_txmsg.trader_status: '||l_txmsg.trader_status);
    plog.debug(pkgctx,'Free resources associated');

    -- Free any resources associated with the document now it
    -- is no longer needed.
    DBMS_XMLDOM.freedocument(l_doc);
    -- Only used if variant is CLOB
    -- dbms_lob.freetemporary(p_xmlmsg);

    plog.setendsection(pkgctx, 'fn_xml2obj_TC');
    RETURN l_txmsg;
  EXCEPTION
    WHEN OTHERS THEN
      --dbms_lob.freetemporary(p_xmlmsg);
      DBMS_XMLPARSER.freeparser(l_parser);
      DBMS_XMLDOM.freedocument(l_doc);
      plog.error(pkgctx, SQLERRM || '--' || dbms_utility.format_error_backtrace);
      plog.setendsection(pkgctx, 'fn_xml2obj_TC');
      RAISE errnums.E_SYSTEM_ERROR;
  END fn_xml2obj_TC;



  FUNCTION fn_xml2obj_2I(p_xmlmsg    VARCHAR2) RETURN tx.msg_2I IS
    l_parser   xmlparser.parser;
    l_doc      xmldom.domdocument;
    l_nodeList xmldom.domnodelist;
    l_node     xmldom.domnode;
    n     xmldom.domnode;

    l_fldname fldmaster.fldname%TYPE;
    l_txmsg   tx.msg_2I;
    v_Key Varchar2(100);
    v_Value Varchar2(100);


  BEGIN
    plog.setbeginsection (pkgctx, 'fn_xml2obj_2I');

    plog.debug(pkgctx,'msg length: ' || length(p_xmlmsg));
    l_parser := xmlparser.newparser();
    plog.debug(pkgctx,'1');
    xmlparser.parseclob(l_parser, p_xmlmsg);
    plog.debug(pkgctx,'2');
    l_doc := xmlparser.getdocument(l_parser);
    plog.debug(pkgctx,'3');
    xmlparser.freeparser(l_parser);

    plog.debug(pkgctx,'Prepare to parse Message Fields');

    l_nodeList := xslprocessor.selectnodes(xmldom.makenode(l_doc),
                                           '/ArrayOfHoSEMessageEntry/hoSEMessageEntry');

    FOR i IN 0 .. xmldom.getlength(l_nodeList) - 1 LOOP
      plog.debug(pkgctx,'parse fields: ' || i);
      l_node := xmldom.item(l_nodeList, i);
      dbms_xslprocessor.valueOf(l_node,'key',v_Key);
      dbms_xslprocessor.valueOf(l_node,'value',v_Value);
      If v_Key ='confirm_number'  Then
        l_txmsg.confirm_number := TRIM(v_Value);
      Elsif v_Key ='price' Then
        l_txmsg.price := v_Value;
      Elsif v_Key ='order_number_sell' Then
        l_txmsg.order_number_sell := TRIM(v_Value);
      Elsif v_Key ='order_entry_date_sell' Then
        l_txmsg.order_entry_date_sell := TRIM(v_Value);
      Elsif v_Key ='firm' Then
        l_txmsg.firm := v_Value;
      Elsif v_Key ='volume' Then
        l_txmsg.volume := v_Value;
      Elsif v_Key ='order_number_buy' Then
        l_txmsg.order_number_buy := v_Value;
      Elsif v_Key ='order_entry_date_buy' Then
        l_txmsg.order_entry_date_buy := v_Value;
      End if;

      --v_Key:=xmldom.getnodevalue(xmldom.getfirstchild(l_node));
      --v_Key:=xmldom.getnodevalue(xmldom.getfirstchild('key'));
    END LOOP;


    plog.debug(pkgctx,'msg 2I l_txmsg.order_number_sell: '||l_txmsg.order_number_sell
                     ||' l_txmsg.order_number_buy: '||l_txmsg.order_number_buy
                     ||' l_txmsg.confirm_number: '||l_txmsg.confirm_number);
    plog.debug(pkgctx,'Free resources associated');

    -- Free any resources associated with the document now it
    -- is no longer needed.
    DBMS_XMLDOM.freedocument(l_doc);
    -- Only used if variant is CLOB
    -- dbms_lob.freetemporary(p_xmlmsg);

    plog.setendsection(pkgctx, 'fn_xml2obj_2I');
    RETURN l_txmsg;
  EXCEPTION
    WHEN OTHERS THEN
      --dbms_lob.freetemporary(p_xmlmsg);
      DBMS_XMLPARSER.freeparser(l_parser);
      DBMS_XMLDOM.freedocument(l_doc);
      plog.error(pkgctx, SQLERRM || '--' || dbms_utility.format_error_backtrace);
      plog.setendsection(pkgctx, 'fn_xml2obj_2I');
      RAISE errnums.E_SYSTEM_ERROR;
  END fn_xml2obj_2I;


FUNCTION fn_xml2obj_2C(p_xmlmsg    VARCHAR2) RETURN tx.msg_2C IS
    l_parser   xmlparser.parser;
    l_doc      xmldom.domdocument;
    l_nodeList xmldom.domnodelist;
    l_node     xmldom.domnode;
    n     xmldom.domnode;

    l_fldname fldmaster.fldname%TYPE;
    l_txmsg   tx.msg_2C;
    v_Key Varchar2(100);
    v_Value Varchar2(100);


  BEGIN
    plog.setbeginsection (pkgctx, 'fn_xml2obj');

    plog.debug(pkgctx,'msg length: ' || length(p_xmlmsg));
    l_parser := xmlparser.newparser();
    plog.debug(pkgctx,'1');
    xmlparser.parseclob(l_parser, p_xmlmsg);
    plog.debug(pkgctx,'2');
    l_doc := xmlparser.getdocument(l_parser);
    plog.debug(pkgctx,'3');
    xmlparser.freeparser(l_parser);

    plog.debug(pkgctx,'Prepare to parse Message Fields');

    l_nodeList := xslprocessor.selectnodes(xmldom.makenode(l_doc),
                                           '/ArrayOfHoSEMessageEntry/hoSEMessageEntry');

    FOR i IN 0 .. xmldom.getlength(l_nodeList) - 1 LOOP
      plog.debug(pkgctx,'parse fields: ' || i);
      l_node := xmldom.item(l_nodeList, i);
      dbms_xslprocessor.valueOf(l_node,'key',v_Key);
      dbms_xslprocessor.valueOf(l_node,'value',v_Value);
      If v_Key ='order_number'  Then
        l_txmsg.order_number := trim(v_Value);
      Elsif v_Key ='firm' Then
        l_txmsg.firm := v_Value;
      Elsif v_Key ='order_entry_date' Then
        l_txmsg.order_entry_date := v_Value;
      Elsif v_Key ='cancel_shares' Then
        l_txmsg.cancel_shares := v_Value;
      Elsif v_Key ='order_cancel_status' Then
        l_txmsg.order_cancel_status := v_Value;
      End if;

      --v_Key:=xmldom.getnodevalue(xmldom.getfirstchild(l_node));
      --v_Key:=xmldom.getnodevalue(xmldom.getfirstchild('key'));
    END LOOP;


    plog.debug(pkgctx,'msg 2C l_txmsg.order_number: '||l_txmsg.order_number||
                        ' l_txmsg.firm ='|| l_txmsg.firm ||'l_txmsg.cancel_shares ='||l_txmsg.cancel_shares);
    plog.debug(pkgctx,'Free resources associated');

    -- Free any resources associated with the document now it
    -- is no longer needed.
    DBMS_XMLDOM.freedocument(l_doc);
    -- Only used if variant is CLOB
    -- dbms_lob.freetemporary(p_xmlmsg);

    plog.setendsection(pkgctx, 'fn_xml2obj');
    RETURN l_txmsg;
  EXCEPTION
    WHEN OTHERS THEN
      --dbms_lob.freetemporary(p_xmlmsg);
      DBMS_XMLPARSER.freeparser(l_parser);
      DBMS_XMLDOM.freedocument(l_doc);
      plog.error(pkgctx, SQLERRM || '--' || dbms_utility.format_error_backtrace);
      plog.setendsection(pkgctx, 'fn_xml2obj');
      RAISE errnums.E_SYSTEM_ERROR;
  END fn_xml2obj_2C;
FUNCTION fn_xml2obj_2G(p_xmlmsg    VARCHAR2) RETURN tx.msg_2G IS
 l_parser   xmlparser.parser;
    l_doc      xmldom.domdocument;
    l_nodeList xmldom.domnodelist;
    l_node     xmldom.domnode;
    n     xmldom.domnode;

    l_fldname fldmaster.fldname%TYPE;
    l_txmsg   tx.msg_2G;
    v_Key Varchar2(100);
    v_Value Varchar2(500);


  BEGIN
    plog.setbeginsection (pkgctx, 'fn_xml2obj_2G');

    plog.debug(pkgctx,'msg length: ' || length(p_xmlmsg));
    l_parser := xmlparser.newparser();
    plog.debug(pkgctx,'1');
    xmlparser.parseclob(l_parser, p_xmlmsg);
    plog.debug(pkgctx,'2');
    l_doc := xmlparser.getdocument(l_parser);
    plog.debug(pkgctx,'3');
    xmlparser.freeparser(l_parser);

    plog.debug(pkgctx,'Prepare to parse Message Fields');

    l_nodeList := xslprocessor.selectnodes(xmldom.makenode(l_doc),
                                           '/ArrayOfHoSEMessageEntry/hoSEMessageEntry');

    FOR i IN 0 .. xmldom.getlength(l_nodeList) - 1 LOOP
      plog.debug(pkgctx,'parse fields: ' || i);
      l_node := xmldom.item(l_nodeList, i);
      dbms_xslprocessor.valueOf(l_node,'key',v_Key);
      dbms_xslprocessor.valueOf(l_node,'value',v_Value);
      If v_Key ='order_number'  Then
        l_txmsg.order_number := v_Value;
      Elsif v_Key ='firm' Then
        l_txmsg.firm := v_Value;
      Elsif v_Key ='order_entry_date' Then
        l_txmsg.order_entry_date := v_Value;
      Elsif v_Key ='reject_reason_code' Then
        l_txmsg.reject_reason_code := v_Value;
      Elsif v_Key ='original_message_text' Then
        l_txmsg.original_message_text := v_Value;
      ELSIF v_key='msg_type' then
        l_txmsg.msg_type:=v_Value;
      ELSIF v_key='deal_id' then
        l_txmsg.deal_id:=v_Value;
      End if;


      --v_Key:=xmldom.getnodevalue(xmldom.getfirstchild(l_node));
      --v_Key:=xmldom.getnodevalue(xmldom.getfirstchild('key'));
    END LOOP;


    plog.debug(pkgctx,'msg 2G l_txmsg.order_number: '||l_txmsg.order_number||' l_txmsg.firm ='|| l_txmsg.firm);
    plog.debug(pkgctx,'Free resources associated');

    -- Free any resources associated with the document now it
    -- is no longer needed.
    DBMS_XMLDOM.freedocument(l_doc);
    -- Only used if variant is CLOB
    -- dbms_lob.freetemporary(p_xmlmsg);

    plog.setendsection(pkgctx, 'fn_xml2obj');
    RETURN l_txmsg;
  EXCEPTION
    WHEN OTHERS THEN
      --dbms_lob.freetemporary(p_xmlmsg);
      DBMS_XMLPARSER.freeparser(l_parser);
      DBMS_XMLDOM.freedocument(l_doc);
      plog.error(pkgctx, SQLERRM || '--' || dbms_utility.format_error_backtrace);
      plog.setendsection(pkgctx, 'fn_xml2obj');
      RAISE errnums.E_SYSTEM_ERROR;
End   fn_xml2obj_2G;
FUNCTION fn_xml2obj_3B(p_xmlmsg    VARCHAR2) RETURN tx.msg_3B IS
 l_parser   xmlparser.parser;
    l_doc      xmldom.domdocument;
    l_nodeList xmldom.domnodelist;
    l_node     xmldom.domnode;
    n     xmldom.domnode;

    l_fldname fldmaster.fldname%TYPE;
    l_txmsg   tx.msg_3B;
    v_Key Varchar2(100);
    v_Value Varchar2(500);


  BEGIN
    plog.setbeginsection (pkgctx, 'fn_xml2obj_3b');

    plog.debug(pkgctx,'msg length: ' || length(p_xmlmsg));
    l_parser := xmlparser.newparser();
    plog.debug(pkgctx,'1');
    xmlparser.parseclob(l_parser, p_xmlmsg);
    plog.debug(pkgctx,'2');
    l_doc := xmlparser.getdocument(l_parser);
    plog.debug(pkgctx,'3');
    xmlparser.freeparser(l_parser);

    plog.debug(pkgctx,'Prepare to parse Message Fields');

    l_nodeList := xslprocessor.selectnodes(xmldom.makenode(l_doc),
                                           '/ArrayOfHoSEMessageEntry/hoSEMessageEntry');

    FOR i IN 0 .. xmldom.getlength(l_nodeList) - 1 LOOP
      plog.debug(pkgctx,'parse fields: ' || i);
      l_node := xmldom.item(l_nodeList, i);
      dbms_xslprocessor.valueOf(l_node,'key',v_Key);
      dbms_xslprocessor.valueOf(l_node,'value',v_Value);
      If v_Key ='confirm_number'  Then
        l_txmsg.confirm_number := v_Value;
      Elsif v_Key ='firm' Then
        l_txmsg.firm := v_Value;
      Elsif v_Key ='deal_id' Then
        l_txmsg.deal_id := v_Value;
      Elsif v_Key ='client_id_buyer' Then
        l_txmsg.client_id_buyer := v_Value;
      Elsif v_Key ='reply_code' Then
        l_txmsg.reply_code := v_Value;
      End if;
      --v_Key:=xmldom.getnodevalue(xmldom.getfirstchild(l_node));
      --v_Key:=xmldom.getnodevalue(xmldom.getfirstchild('key'));
    END LOOP;


    plog.debug(pkgctx,'msg 3b l_txmsg.deal_id: '||l_txmsg.deal_id||' l_txmsg.firm ='|| l_txmsg.firm);
    plog.debug(pkgctx,'Free resources associated');

    -- Free any resources associated with the document now it
    -- is no longer needed.
    DBMS_XMLDOM.freedocument(l_doc);
    -- Only used if variant is CLOB
    -- dbms_lob.freetemporary(p_xmlmsg);

    plog.setendsection(pkgctx, 'fn_xml2obj');
    RETURN l_txmsg;
  EXCEPTION
    WHEN OTHERS THEN
      --dbms_lob.freetemporary(p_xmlmsg);
      DBMS_XMLPARSER.freeparser(l_parser);
      DBMS_XMLDOM.freedocument(l_doc);
      plog.error(pkgctx, SQLERRM || '--' || dbms_utility.format_error_backtrace);
      plog.setendsection(pkgctx, 'fn_xml2obj');
      RAISE errnums.E_SYSTEM_ERROR;
End   fn_xml2obj_3B;
FUNCTION fn_xml2obj_AA(p_xmlmsg    VARCHAR2) RETURN tx.msg_AA IS
    l_parser   xmlparser.parser;
    l_doc      xmldom.domdocument;
    l_nodeList xmldom.domnodelist;
    l_node     xmldom.domnode;
    n     xmldom.domnode;

    l_fldname fldmaster.fldname%TYPE;
    l_txmsg   tx.msg_AA;
    v_Key Varchar2(100);
    v_Value Varchar2(100);


  BEGIN
    plog.setbeginsection (pkgctx, 'fn_xml2obj_AA');

    plog.debug(pkgctx,'msg length: ' || length(p_xmlmsg));
    l_parser := xmlparser.newparser();
    plog.debug(pkgctx,'1');
    xmlparser.parseclob(l_parser, p_xmlmsg);
    plog.debug(pkgctx,'2');
    l_doc := xmlparser.getdocument(l_parser);
    plog.debug(pkgctx,'3');
    xmlparser.freeparser(l_parser);

    plog.debug(pkgctx,'Prepare to parse Message Fields');

    l_nodeList := xslprocessor.selectnodes(xmldom.makenode(l_doc),
                                           '/ArrayOfHoSEMessageEntry/hoSEMessageEntry');

    FOR i IN 0 .. xmldom.getlength(l_nodeList) - 1 LOOP
      plog.debug(pkgctx,'parse fields: ' || i);
      l_node := xmldom.item(l_nodeList, i);
      dbms_xslprocessor.valueOf(l_node,'key',v_Key);
      dbms_xslprocessor.valueOf(l_node,'value',v_Value);
      If v_Key ='time'  Then
        l_txmsg.time_od := trim(v_Value);
      Elsif v_Key ='price' Then
        l_txmsg.price := trim(v_Value);
      Elsif v_Key ='side' Then
        l_txmsg.side := trim(v_Value);
      Elsif v_Key ='firm' Then
        l_txmsg.firm := trim(v_Value);
      Elsif v_Key ='security_number' Then
        l_txmsg.security_number := trim(v_Value);
      Elsif v_Key ='volume' Then
        l_txmsg.volume := trim(v_Value);
      Elsif v_Key ='trader' Then
        l_txmsg.trader := v_Value;
      Elsif v_Key ='board' Then
        l_txmsg.board := trim(v_Value);
      Elsif v_Key ='add_cancel_flag' Then
        l_txmsg.add_cancel_flag := trim(v_Value);
      Elsif v_Key ='contact' Then
        l_txmsg.contact := trim(v_Value);
      End if;

    END LOOP;


   /* plog.debug(pkgctx,'msg TR l_txmsg.security_number: '||l_txmsg.security_number
                       ||'l_txmsg.current_room: '||l_txmsg.current_room);
    plog.debug(pkgctx,'Free resources associated');*/

    -- Free any resources associated with the document now it
    -- is no longer needed.
    DBMS_XMLDOM.freedocument(l_doc);
    -- Only used if variant is CLOB
    -- dbms_lob.freetemporary(p_xmlmsg);

    plog.setendsection(pkgctx, 'fn_xml2obj_AA');
    RETURN l_txmsg;
  EXCEPTION
    WHEN OTHERS THEN
      --dbms_lob.freetemporary(p_xmlmsg);
      DBMS_XMLPARSER.freeparser(l_parser);
      DBMS_XMLDOM.freedocument(l_doc);
      plog.error(pkgctx, SQLERRM || '--' || dbms_utility.format_error_backtrace);
      plog.setendsection(pkgctx, 'fn_xml2obj_AA');
      RAISE errnums.E_SYSTEM_ERROR;
  END fn_xml2obj_AA;


Procedure PRC_1I(PV_REF IN OUT PKG_REPORT.REF_CURSOR) is

    v_err VARCHAR2(200);
    v_Temp VARCHAR2(30);
    v_Check BOOLEAN;
    v_strSysCheckBuySell VARCHAR2(30);
    v_Order_Number varchar2(10);

    CURSOR C_1I IS
    SELECT 'M' BOARD_ALPH,CUSTODYCD CLIENT_ID_ALPH,'     ' FILLER_1,'     ' FILLER_2,
        FIRM,
        CASE
        WHEN  SUBSTR(CUSTODYCD,4,1) = 'A' OR SUBSTR(CUSTODYCD,4,1) ='B' THEN 'M'
        WHEN  SUBSTR(CUSTODYCD,4,1) ='E' OR SUBSTR(CUSTODYCD,4,1) ='F' THEN 'F'
        ELSE  SUBSTR(CUSTODYCD,4,1) END PORT_CLIENT_FLAG_ALPH,
        QUOTEPRICE PRICE,ORDERQTTY PUBLISHED_VOLUME ,ORDERQTTY VOLUME,SYMBOL SECURITY_SYMBOL_ALPH,
        BORS SIDE_ALPH, PCK_HOGW.FNC_CHECK_TRADERID('N',BORS,VIA) TRADER_ID_ALPH,ORDERID,CODEID, SENDNUM,oddlot,tradelot
    FROM    ho_send_order
    WHERE PCK_HOGW.FNC_CHECK_ROOM(SYMBOL,ORDERQTTY,CUSTODYCD,BORS)<>'0'
        --and ROWNUM BETWEEN 0 AND (SELECT SYSVALUE FROM ORDERSYS WHERE SYSNAME='HOSESENDSIZE')

        --phuongntn edit
        --check voi gio cua So tra ve
        -- AND to_char(sysdate,'hh24miss') >'090000'--> T?i sao ko l?y b?ng???

        --end edit
        ;
  /*  Cursor c_Check_Doiung(v_BorS Varchar2, v_Custodycd Varchar2,v_Codeid Varchar2, v_controlcode VARCHAR2, v_strTRADEBUYSELLPT varchar2 ) is
                       SELECT ORGORDERID FROM ood o , odmast od
                       WHERE o.orgorderid = od.orderid and o.custodycd =v_Custodycd and o.codeid=v_Codeid
                             And o.bors <> v_BorS
                             And od.remainqtty >0
                             and od.deltd<>'Y'
                             AND od.EXECTYPE in ('NB','NS','MS')
                             And o.oodstatus in ('B','S')
                             AND NVL(od.hosesession,'N') = v_controlcode
                             and (v_strTRADEBUYSELLPT='N'
                                  or (v_strTRADEBUYSELLPT='Y' and od.matchtype <>'P'));*/

     -- ThangPV chinh sua lo le HSX 30-05-2022 ROC 1.3
   Cursor c_Check_Doiung(v_BorS Varchar2, v_Custodycd Varchar2,v_Codeid Varchar2, v_controlcode VARCHAR2, v_strTRADEBUYSELLPT varchar2,v_tradelot number ) is
                       SELECT ORGORDERID FROM ood o , odmast od
                       WHERE o.orgorderid = od.orderid and o.custodycd =v_Custodycd and o.codeid=v_Codeid
                             And o.bors <> v_BorS
                             And od.remainqtty >0
                             and od.deltd<>'Y'
                             AND od.EXECTYPE in ('NB','NS','MS')
                             And o.oodstatus in ('B','S')
                             AND NVL(od.hosesession,'N') = v_controlcode
                             AND ((v_strTRADEBUYSELLPT ='Y' AND od.ORDERQTTY >= v_tradelot  AND od.MATCHTYPE='N' )
                             OR
                               (v_strTRADEBUYSELLPT ='N' And ( od.MATCHTYPE='P' OR ( od.MATCHTYPE='N' AND od.ORDERQTTY >= v_tradelot) )));
    --end ThangPV chinh sua lo le HSX 30-05-2022 ROC 1.3

   Cursor C_Send_Size is SELECT SYSVALUE FROM ORDERSYS WHERE SYSNAME='HOSESENDSIZE';
   v_Send_Size  Number;
   v_Count_Order varchar2(10);
   l_controlcode varchar2(10);
   l_strTRADEBUYSELLPT  VARCHAR2(10); -- Y Thi cho phep dat lenh thoa thuan doi ung



BEGIN
    plog.setbeginsection (pkgctx, 'PRC_1I');
    Begin
        Select VARVALUE into v_strSysCheckBuySell from sysvar where GRNAME ='SYSTEM' and VARNAME ='TRADEBUYSELL';
    Exception When OTHERS Then
        v_strSysCheckBuySell:='N';
    End;

    Begin
          Select VARVALUE Into l_strTRADEBUYSELLPT
          From sysvar
          Where GRNAME ='SYSTEM' and VARNAME ='TRADEBUYSELLPT' ;
    EXCEPTION when OTHERS Then
            l_strTRADEBUYSELLPT:='N';
    End;

    Open C_Send_Size;
    Fetch C_Send_Size Into v_Send_Size;
    If C_Send_Size%notfound Then
     v_Send_Size:=100;
    End if;
    Close C_Send_Size;

    v_Count_Order:=0;
    FOR I IN C_1I
    LOOP
        BEGIN
            SAVEPOINT sp#2;

            --Kiem tra neu co lenh doi ung Block, Sent chua khop het thi khong day len GW.
            --Sysvar ko cho BuySell thi check doi ung.
            v_Check:=False;
            --ThangPV chinh sua lo le HSX 27-04-2022
            l_controlcode:=fn_get_controlcode(i.security_symbol_alph,i.oddlot);

            -- ThangPV chinh sua lo le HSX 30-05-2022 ROC 1.3
            --If v_strSysCheckBuySell ='N' and l_controlcode in ('P','A','I','J','G','K') Then
            If v_strSysCheckBuySell ='N' and l_controlcode in ('P','A','I','J','G','K') AND i.oddlot='N' Then
                 --Open c_Check_Doiung(I.SIDE_ALPH, I.CLIENT_ID_ALPH,I.CODEID,l_controlcode,l_strTRADEBUYSELLPT);
                 Open c_Check_Doiung(I.SIDE_ALPH, I.CLIENT_ID_ALPH,I.CODEID,l_controlcode,l_strTRADEBUYSELLPT,I.Tradelot);
                 Fetch c_Check_Doiung into v_Temp;
                   If c_Check_Doiung%found then
                    v_Check:=True;
                   End if;
                 Close c_Check_Doiung;
            End if;
            --Kiem tra lenh goc da huy sua:

            IF (Not v_Check)   THEN

               SELECT seq_ordermap.NEXTVAL Into v_Order_Number From dual;

               INSERT INTO ho_1i
                        (firm, trader_id_alph, order_number, client_id_alph,
                         security_symbol_alph, side_alph, volume, published_volume,
                         price, board_alph, filler_1, port_client_flag_alph,
                         filler_2, orderid, status, sendnum
                        )
                 VALUES (I.firm, I.trader_id_alph, v_Order_Number, I.client_id_alph,
                         I.security_symbol_alph, I.side_alph, I.volume, I.published_volume,
                         I.price, I.board_alph, I.filler_1, I.port_client_flag_alph,
                         I.filler_2, I.orderid, 'N', I.sendnum
                        );
              --XU LY LENH 1I
                --1.1DAY VAO ORDERMAP.
                INSERT INTO ORDERMAP(ctci_order,orgorderid) VALUES (v_Order_Number,I.orderid);
                --1.2 CAP NHAT OOD.
                UPDATE OOD SET OODSTATUS='B' WHERE ORGORDERID=I.orderid;
                UPDATE ODMAST SET hosesession= l_controlcode WHERE ORDERID=I.orderid;
              --  UPDATE ODMAST SET ORSTATUS='11' WHERE ORDERID=I.ORDERID;
                --1.3 DAY LENH VAO ODQUEUE
                INSERT INTO ODQUEUE SELECT * FROM OOD WHERE ORGORDERID = I.orderid;
                v_Count_Order:=v_Count_Order+1;
            END IF;
        EXCEPTION WHEN OTHERS THEN
            plog.error(pkgctx, SQLERRM || '--' || dbms_utility.format_error_backtrace);
            ROLLBACK TO SAVEPOINT sp#2;
        END;
         Exit WHEN v_Count_Order >= v_Send_Size;
    END LOOP;

    --LAY DU LIEU RA GW.
    OPEN PV_REF FOR
    SELECT
        RPAD(FIRM,3,' ') FIRM,
        RPAD(TRADER_ID_ALPH,4,' ') TRADER_ID,
        RPAD(ORDER_NUMBER,8,' ') ORDER_NUMBER,
        RPAD(CLIENT_ID_ALPH,10,' ') CLIENT_ID,
        RPAD(SECURITY_SYMBOL_ALPH,8,' ') SECURITY_SYMBOL,
        RPAD(SIDE_ALPH,1,' ') SIDE,
        RPAD(VOLUME,8,' ') VOLUME,
        RPAD(PUBLISHED_VOLUME,8,' ') PUBLISHED_VOLUME,
        RPAD(PRICE,6,' ') PRICE,
        RPAD(BOARD_ALPH,1,' ') BOARD,
        RPAD(FILLER_1,5,' ') FILLER_1,
        RPAD(PORT_CLIENT_FLAG_ALPH,1,' ') PORT_CLIENT_FLAG,
        RPAD(FILLER_2,5,' ') FILLER_2,
        ORDERID||SENDNUM BOORDERID
    FROM ho_1i WHERE STATUS ='N'
    Order by to_number(ORDER_NUMBER);
    --Cap nhat trang thai bang tam ra GW.
    UPDATE ho_1i SET STATUS ='Y',DATE_TIME = SYSDATE WHERE STATUS ='N';
    plog.setendsection (pkgctx, 'PRC_1I');

EXCEPTION WHEN OTHERS THEN
    plog.error(pkgctx, SQLERRM || '--' || dbms_utility.format_error_backtrace);
    plog.setendsection (pkgctx, 'PRC_1I');
    RAISE errnums.E_SYSTEM_ERROR;
END PRC_1I;

  --Day lenh huy len Gw
Procedure PRC_1C(PV_REF IN OUT PKG_REPORT.REF_CURSOR) is

    v_err VARCHAR2(200);

    CURSOR C_1C IS

    SELECT FIRM,CTCI_ORDER ORDER_NUMBER,ORDERID,SUBSTR(ORDERID,5,4) ORDER_ENTRY_DATE,
       SENDNUM
    FROM (
        SELECT ODM.CTCI_ORDER,S.VARVALUE FIRM, A.ORGORDERID ORDERID,A.SENDNUM
        FROM OOD A, SBSECURITIES B, ODMAST C,ODMAST E,
             SYSVAR S,ORDERMAP ODM,SECURITIES_INFO SI
        WHERE A.CODEID = B.CODEID
          AND A.ORGORDERID = E.ORDERID
          AND E.REFORDERID=C.ORDERID
          AND E.REFORDERID=ODM.ORGORDERID
          AND B.CODEID = C.CODEID
          AND A.codeid = SI.codeid
          AND C.ORSTATUS NOT IN ('3','0','6','8') AND C.MATCHTYPE ='N' AND C.REMAINQTTY >0 AND C.DELTD <> 'Y'
          AND B.TRADEPLACE='001'
          AND A.OODSTATUS = 'N'
          AND S.GRNAME='SYSTEM' AND S.VARNAME='FIRM'
          AND C.ORDERQTTY >  (SELECT NVL(SUM(VOLUME),0) FROM F2E_2I WHERE ORDERNUMBER =ODM.CTCI_ORDER)
          --AND TO_CHAR(SYSDATE,'HH24MI')>='0847'
          --AND to_char(sysdate,'hh24miss') <='104505'
          AND C.HOSESESSION <>'A'
       /*   AND INSTR((select inperiod from msgmast where msgtype ='1C'),
                    (SELECT SYSVALUE FROM ORDERSYS WHERE SYSNAME='CONTROLCODE')) >0 */
                    AND ((INSTR((select inperiod from msgmast where msgtype ='1C'),
                    (SELECT SYSVALUE FROM ORDERSYS WHERE SYSNAME='CONTROLCODE')) > 0
                 AND C.ORDERQTTY >= SI.TRADELOT)
               OR
               (INSTR((select inperiod from msgmast where msgtype ='1C_ODD'),
                    (SELECT SYSVALUE FROM ORDERSYS WHERE SYSNAME='CONTROLCODE_ODD_LOT')) >0
                 AND C.ORDERQTTY < SI.TRADELOT)
                    )
        AND PCK_HOGW.FNC_CHECK_TRADERID('N',A.BORS,C.VIA) <> '0'
      )

     WHERE ROWNUM BETWEEN 0 AND (SELECT SYSVALUE FROM ORDERSYS WHERE SYSNAME='HOSESENDSIZE');

     CURSOR C_1C_ADMEND IS
                SELECT FIRM,CTCI_ORDER ORDER_NUMBER,ORDERID,SUBSTR(ORDERID,5,4) ORDER_ENTRY_DATE,
                       AdmendPrice,sendnum
                FROM (
                SELECT ODM.CTCI_ORDER,S.VARVALUE FIRM, A.ORGORDERID ORDERID, e.quoteprice AdmendPrice, A.sendnum
                FROM OOD A, SBSECURITIES B, ODMAST C,ODMAST E,
                      SYSVAR S,ORDERMAP ODM
                WHERE (A.CODEID = B.CODEID AND A.ORGORDERID = E.ORDERID
                  AND E.REFORDERID=C.ORDERID)
                  AND E.REFORDERID=ODM.ORGORDERID
                  AND B.CODEID = C.CODEID
                  AND C.ORSTATUS NOT IN ('3','0','6','8') AND C.MATCHTYPE ='N' AND C.REMAINQTTY >0
                  AND B.TRADEPLACE='001'
                  AND a.OODSTATUS IN ('N') AND E.exectype IN ('AS','AB') and e.deltd<>'Y'
                  AND S.GRNAME='SYSTEM' AND S.VARNAME='FIRM'
                  AND C.HOSESESSION <>'A'
                  AND INSTR((select inperiod from msgmast where msgtype ='1C'),
                    (SELECT SYSVALUE FROM ORDERSYS WHERE SYSNAME='CONTROLCODE')) >0
                  );

BEGIN
    plog.setbeginsection (pkgctx, 'PRC_1C');
    FOR I IN C_1C
    LOOP
        INSERT INTO ho_1c
                    (order_entry_date, order_number, firm, orderid, date_time,
                     status,sendnum
                    )
             VALUES (I.order_entry_date, I.order_number, I.firm, I.orderid, '',
                     'N',i.sendnum
                    );
        --XU LY LENH 1C
        --1.1 CAP NHAT OOD.
        UPDATE OOD SET OODSTATUS='B' WHERE ORGORDERID=I.orderid;
        --1.2 DAY LENH VAO ODQUEUE
        INSERT INTO ODQUEUE SELECT * FROM OOD WHERE ORGORDERID = I.orderid;
    END LOOP;
    FOR I IN C_1C_ADMEND
      LOOP
        INSERT INTO ho_1c
                    (order_entry_date, order_number, firm, orderid, date_time,
                     status,sendnum

                    )
             VALUES (I.order_entry_date, I.order_number, I.firm, I.orderid, '',
                     'N',i.sendnum

                    );
      --XU LY LENH 1C
        --1.1 CAP NHAT OOD.
        UPDATE OOD SET OODSTATUS='B' WHERE ORGORDERID=I.orderid;
        --1.2 DAY LENH VAO ODQUEUE
        INSERT INTO ODQUEUE SELECT * FROM OOD WHERE ORGORDERID = I.orderid;
      END LOOP;
    --LAY DU LIEU RA GW.
    OPEN PV_REF FOR
    SELECT
        RPAD(ORDER_ENTRY_DATE,4,' ') ORDER_ENTRY_DATE,
        RPAD(ORDER_NUMBER,8,' ') ORDER_NUMBER,
        RPAD(FIRM,3,' ') FIRM,
        ORDERID||SENDNUM BOORDERID
    FROM ho_1c WHERE STATUS ='N';
    --Cap nhat trang thai bang tam ra GW.
    UPDATE ho_1c SET STATUS ='Y',DATE_TIME = SYSDATE WHERE STATUS ='N';
    plog.setendsection (pkgctx, 'PRC_1C');

EXCEPTION WHEN OTHERS THEN
    plog.error(pkgctx, SQLERRM || '--' || dbms_utility.format_error_backtrace);
    plog.setendsection (pkgctx, 'PRC_1C');
    RAISE errnums.E_SYSTEM_ERROR;
END PRC_1C;

 --Day message lenh thong thuong 1F len Gw
Procedure PRC_1F(PV_REF IN OUT PKG_REPORT.REF_CURSOR) Is

    v_err VARCHAR2(200);
    v_Temp VARCHAR2(30);
    v_Check BOOLEAN;
    v_strSysCheckBuySell VARCHAR2(30);
    v_DblODQUEUE Number ;
    v_Order_Number varchar2(10);

    CURSOR C_1F IS
    SELECT
        ORDERID,
        FIRM,
        FNC_CHECK_TRADERID('P',BORS) TRADER_ID_ALPH,
        BCLIENTID CLIENT_ID_BUYER_ALPH,
        SCLIENTID CLIENT_ID_SELLER_ALPH,
        SYMBOL
        SECURITY_SYMBOL_ALPH,
        'B' BOARD_ALPH,
        lpad(floor(QUOTEPRICE),6,'0')||rpad(replace((QUOTEPRICE -floor(QUOTEPRICE)),'.',''),6,'0') PRICE,
        '        ' FILLER_1,
        '        ' FILLER_2,
        '        ' FILLER_3,
        (CASE WHEN BCUSTODIAN='P' THEN ORDERQTTY ELSE 0 END) BROKER_PORTFOLIO_VOLUME_BUYER,
        (CASE WHEN SCUSTODIAN='P' THEN ORDERQTTY ELSE 0 END) BROKER_PORTFOLIO_VOLUME_SELLER,
        (CASE WHEN BCUSTODIAN='C' THEN ORDERQTTY ELSE 0 END) BROKER_CLIENT_VOLUME_BUYER,
        (CASE WHEN SCUSTODIAN='C' THEN ORDERQTTY ELSE 0 END) BROKER_CLIENT_VOLUME_SELLER,
        (CASE WHEN BCUSTODIAN='F' OR  BCUSTODIAN='E' THEN ORDERQTTY ELSE 0 END) BROKER_FOREIGN_VOLUME_BUYER,
        (CASE WHEN SCUSTODIAN='F' OR  SCUSTODIAN='E' THEN ORDERQTTY ELSE 0 END) BROKER_FOREIGN_VOLUME_SELLER,
        (CASE WHEN BCUSTODIAN='A' OR  BCUSTODIAN='B' THEN ORDERQTTY ELSE 0 END) MUTUAL_FUND_VOLUME_BUYER,
        (CASE WHEN SCUSTODIAN='A' OR  SCUSTODIAN='B' THEN ORDERQTTY ELSE 0 END) MUTUAL_FUND_VOLUME_SELLER, CODEID,
        SENDNUM,
        oddlot,  --ThangPV chinh sua lo le HSX 05-12-2022
        tradelot    --ThangPV chinh sua lo le HSX 30-05-2022 ROC 1.3
    FROM
    SEND_PUTTHROUGH_ORDER_TO_HOSE
    --ThangPV chinh sua lo le HSX 05-12-2022
    /*
    WHERE  INSTR((select inperiod from msgmast where msgtype ='1F'),
     (SELECT SYSVALUE FROM ORDERSYS WHERE SYSNAME='CONTROLCODE')) >0
    And PCK_HOGW.FNC_CHECK_TRADERID('P',BORS) <> '0'
    And PCK_HOGW.fnc_check_P_stockbond('1F',SYMBOL) <>'0'
    AND ( SCUSTODIAN='F' or PCK_HOGW.FNC_CHECK_ROOM(SYMBOL,ORDERQTTY,BCLIENTID,'B')<>'0')
    ; */

    WHERE(
          (
             INSTR((select inperiod from msgmast where msgtype ='1F'),(SELECT SYSVALUE FROM ORDERSYS WHERE SYSNAME='CONTROLCODE')) >0
              And
              PCK_HOGW.fnc_check_P_stockbond('1F',SYMBOL) <>'0'
              AND oddlot = 'N'
          )
          OR
          (
            INSTR((select inperiod from msgmast where msgtype ='1F_ODD'),(SELECT SYSVALUE FROM ORDERSYS WHERE SYSNAME='CONTROLCODE')) >0
            AND oddlot = 'Y'
          )
          OR
          (
            INSTR((select inperiod from msgmast where msgtype ='1F_ODD'),(SELECT SYSVALUE FROM ORDERSYS WHERE SYSNAME='CONTROLCODE_ODD_LOT')) >0
            AND oddlot = 'Y'
          )
         )
        AND PCK_HOGW.FNC_CHECK_TRADERID('P',BORS) <> '0'
        AND ( SCUSTODIAN='F' or PCK_HOGW.FNC_CHECK_ROOM(SYMBOL,ORDERQTTY,BCLIENTID,'B')<>'0')
    ;
    --end ThangPV chinh sua lo le HSX 05-12-2022
    --ThangPV chinh sua lo le HSX 30-05-2022 ROC 1.3
   /* Cursor c_Check_Doiung(v_BorS Varchar2, v_Custodycd Varchar2,v_Codeid Varchar2) is
                       SELECT ORGORDERID FROM ood o , odmast od
                       WHERE o.orgorderid = od.orderid and o.custodycd =v_Custodycd and o.codeid=v_Codeid
                             And o.bors <> v_BorS
                             And od.remainqtty >0
                             AND od.EXECTYPE in ('NB','NS','MS')
                             And o.oodstatus in ('B','S'); */
    Cursor c_Check_Doiung(v_BorS Varchar2, v_Custodycd Varchar2,v_Codeid Varchar2,v_tradelot number) is
                       SELECT ORGORDERID FROM ood o , odmast od
                       WHERE o.orgorderid = od.orderid and o.custodycd =v_Custodycd and o.codeid=v_Codeid
                             And o.bors <> v_BorS
                             And od.remainqtty >0
                             AND od.EXECTYPE in ('NB','NS','MS')
                             And o.oodstatus in ('B','S')
                             And (od.MATCHTYPE='P' OR (od.MATCHTYPE='N' AND od.ORDERQTTY >= v_tradelot) );
    --end ThangPV chinh sua lo le HSX 30-05-2022 ROC 1.3

    l_strTRADEBUYSELLPT  VARCHAR2(10); -- Y Thi cho phep dat lenh thoa thuan doi ung
    l_controlcode varchar2(10);
BEGIN
    plog.setbeginsection (pkgctx, 'PRC_1F');
    Begin
          Select VARVALUE into v_strSysCheckBuySell
          From sysvar
          Where GRNAME ='SYSTEM' and VARNAME ='TRADEBUYSELL';
        Exception When OTHERS Then
            v_strSysCheckBuySell:='N';
    End;

    Begin
          Select VARVALUE Into l_strTRADEBUYSELLPT
          From sysvar
          Where GRNAME ='SYSTEM' and VARNAME ='TRADEBUYSELLPT' ;
      EXCEPTION when OTHERS Then
          l_strTRADEBUYSELLPT:='N';
    End;

    FOR I IN C_1F
    LOOP

    --Kiem tra neu co lenh doi ung Block, Sent chua khop het thi khong day len GW.
    --Sysvar ko cho BuySell thi check doi ung.
        v_Check:=False;
        l_controlcode:=fn_get_controlcode(i.SECURITY_SYMBOL_ALPH,i.oddlot);

        If v_strSysCheckBuySell ='N' and  l_controlcode in('P','A') and l_strTRADEBUYSELLPT ='N' Then
        --ThangPV chinh sua lo le HSX 30-05-2022 ROC 1.3
         --Open c_Check_Doiung('S', I.CLIENT_ID_SELLER_ALPH,I.CODEID);
         Open c_Check_Doiung('S', I.CLIENT_ID_SELLER_ALPH,I.CODEID, I.Tradelot);
         Fetch c_Check_Doiung into v_Temp;
           If c_Check_Doiung%found then
            v_Check:=True;
           End if;
         Close c_Check_Doiung;

         If Not v_Check  Then
            --ThangPV chinh sua lo le HSX 30-05-2022 ROC 1.3
             --Open c_Check_Doiung('B', I.CLIENT_ID_BUYER_ALPH,I.CODEID);
             Open c_Check_Doiung('B', I.CLIENT_ID_BUYER_ALPH,I.CODEID, I.Tradelot);
             Fetch c_Check_Doiung into v_Temp;
               If c_Check_Doiung%found then
                v_Check:=True;
               End if;
             Close c_Check_Doiung;
         End if;
        End if;

        IF Not v_Check THEN

        --- Check Xem trong ODQUEUE da co lenh nay chua,neu co thi ko xu ly nua
              v_DblODQUEUE :=1 ;
              Begin
                Select count(orgorderid) into v_DblODQUEUE
                From ODQUEUE
                Where  orgorderid  =  I.orderid ;
              Exception When OTHERS Then
                v_DblODQUEUE :=1 ;
              End;

              IF v_DblODQUEUE = 0 THEN
                    SELECT seq_ordermap.NEXTVAL Into v_Order_Number From dual;
                    INSERT INTO ho_1f
                        (board_alph, price, security_symbol_alph,
                         client_id_seller_alph, client_id_buyer_alph, trader_id_alph,
                         firm, order_number, filler_3, broker_foreign_volume_seller,
                         mutual_fund_volume_seller, broker_client_volume_seller,
                         broker_portfolio_volume_seller, filler_2,
                         broker_foreign_volume_buyer, mutual_fund_volume_buyer,
                         broker_client_volume_buyer, broker_portfolio_volume_buyer,
                         filler_1, orderid, date_time, status,SENDNUM
                        )
                    VALUES (I.board_alph, I.price, I.security_symbol_alph,
                         I.client_id_seller_alph, I.client_id_buyer_alph, I.trader_id_alph,
                         I.firm, v_Order_Number, I.filler_3, I.broker_foreign_volume_seller,
                         I.mutual_fund_volume_seller, I.broker_client_volume_seller,
                         I.broker_portfolio_volume_seller, I.filler_2,
                         I.broker_foreign_volume_buyer, I.mutual_fund_volume_buyer,
                         I.broker_client_volume_buyer, I.broker_portfolio_volume_buyer,
                         I.filler_1, I.orderid, '','N',I.SENDNUM
                         );
                   --XU LY LENH 1F
                    --1.1DAY VAO ORDERMAP.
                    INSERT INTO ORDERMAP(ctci_order,orgorderid) VALUES (v_Order_Number,I.orderid);
                    --1.2 CAP NHAT OOD.
                    UPDATE OOD SET OODSTATUS='B' WHERE ORGORDERID=I.orderid;
                    UPDATE ODMAST SET hosesession= l_controlcode WHERE ORDERID=I.orderid;
                    --1.3 DAY LENH VAO ODQUEUE
                    INSERT INTO ODQUEUE SELECT * FROM OOD WHERE ORGORDERID = I.orderid;
                    Exit; -- GWHOSE bi loi neu boc 7 lenh thoa thuan 1 luc
             END IF ;
        END IF; --Not v_Check
    END LOOP;
    --LAY DU LIEU RA GW.
    OPEN PV_REF FOR
    SELECT
        RPAD(BOARD_ALPH,1,' ') BOARD,
        RPAD(PRICE,12,' ') PRICE,
        RPAD(SECURITY_SYMBOL_ALPH,8,' ') SECURITY_SYMBOL,
        RPAD(CLIENT_ID_SELLER_ALPH,10,' ') CLIENT_ID_SELLER,
        RPAD(CLIENT_ID_BUYER_ALPH,10,' ') CLIENT_ID_BUYER,
        RPAD(TRADER_ID_ALPH,4,' ') TRADER_ID,
        RPAD(FIRM,3,' ') FIRM,
        RPAD(ORDER_NUMBER,5,' ') DEAL_ID,
        RPAD(FILLER_3,32,' ') FILLER_3,
        RPAD(BROKER_FOREIGN_VOLUME_SELLER,8,' ') BROKER_FOREIGN_VOLUME_SELLER,
        RPAD(MUTUAL_FUND_VOLUME_SELLER,8,' ') MUTUAL_FUND_VOLUME_SELLER,
        RPAD(BROKER_CLIENT_VOLUME_SELLER,8,' ') BROKER_CLIENT_VOLUME_SELLER,
        RPAD(BROKER_PORTFOLIO_VOLUME_SELLER,8,' ') BROKER_PORTFOLIO_VOLUME_SELLER,
        RPAD(FILLER_2,32,' ') FILLER_2,
        RPAD(BROKER_FOREIGN_VOLUME_BUYER,8,' ') BROKER_FOREIGN_VOLUME_BUYER,
        RPAD(MUTUAL_FUND_VOLUME_BUYER,8,' ') MUTUAL_FUND_VOLUME_BUYER,
        RPAD(BROKER_CLIENT_VOLUME_BUYER,8,' ') BROKER_CLIENT_VOLUME_BUYER,
        RPAD(BROKER_PORTFOLIO_VOLUME_BUYER,8,' ') BROKER_PORTFOLIO_VOLUME_BUYER,
        RPAD(FILLER_1,8,' ') FILLER_1,
        ORDERID||SENDNUM BORDERID
    FROM ho_1f WHERE STATUS ='N';
    --Cap nhat trang thai bang tam ra GW.
    UPDATE ho_1f SET STATUS ='Y',DATE_TIME = SYSDATE WHERE STATUS ='N';
    plog.setendsection (pkgctx, 'PRC_1F');

EXCEPTION WHEN OTHERS THEN
    plog.error(pkgctx, SQLERRM || '--' || dbms_utility.format_error_backtrace);
    plog.setendsection (pkgctx, 'PRC_1F');
    RAISE errnums.E_SYSTEM_ERROR;
END PRC_1F;

--Day message lenh thong thuong 1G len Gw
Procedure PRC_1G(PV_REF IN OUT PKG_REPORT.REF_CURSOR) Is

    v_err VARCHAR2(200);
    v_Temp VARCHAR2(30);
    v_Check BOOLEAN;
    v_strSysCheckBuySell VARCHAR2(30);
    v_DblODQUEUE Number ;
    v_Order_Number varchar2(10);

    CURSOR C_1G IS
    SELECT  ORDERID,FIRM FIRM_SELLER,FNC_CHECK_TRADERID('P',BORS) TRADER_ID_SELLER_ALPH,
        SCLIENTID CLIENT_ID_SELLER_ALPH,CONTRAFIRM CONTRA_FIRM_BUYER,
        BTRADERID TRADER_ID_BUYER_ALPH,SYMBOL SECURITY_SYMBOL_ALPH,'B' BOARD_ALPH,
        LPAD(FLOOR(QUOTEPRICE),6,'0')||RPAD(REPLACE((QUOTEPRICE -FLOOR(QUOTEPRICE)),'.',''),6,'0')  PRICE,'    ' FILLER_1,'        ' FILLER_2,
        (CASE WHEN SCUSTODIAN='P' THEN ORDERQTTY ELSE 0 END) BROKER_PORTFOLIO_VOLUME_SELLER,
        (CASE WHEN SCUSTODIAN='C' THEN ORDERQTTY ELSE 0 END) BROKER_CLIENT_VOLUME_SELLER,
        (CASE WHEN SCUSTODIAN='F' OR SCUSTODIAN='E' THEN ORDERQTTY ELSE 0 END) BROKER_FOREIGN_VOLUME_SELLER,
        (CASE WHEN SCUSTODIAN='A' OR SCUSTODIAN='B' THEN ORDERQTTY ELSE 0 END) MUTUAL_FUND_VOLUME_SELLER,
        BORS, CODEID,SENDNUM,oddlot,     --ThangPV chinh sua lo le HSX 05-12-2022
        tradelot    --ThangPV chinh sua lo le HSX 30-05-2022 ROC 1.3
    FROM
       send_2firm_pt_order_to_hose
    WHERE
    --ThangPV chinh sua lo le HSX 05-12-2022
      /*  INSTR((select inperiod from msgmast where msgtype ='1G'),
        (SELECT SYSVALUE FROM ORDERSYS WHERE SYSNAME='CONTROLCODE')) >0
        AND PCK_HOGW.FNC_CHECK_TRADERID('P',BORS) <> '0'
        And PCK_HOGW.fnc_check_P_stockbond('1G',SYMBOL) <>'0'
    --And PCK_HOGW.FNC_CHECK_SEC_HCM(SYMBOL) <> '0';*/

    (
         ( INSTR((select inperiod from msgmast where msgtype ='1G'),(SELECT SYSVALUE FROM ORDERSYS WHERE SYSNAME='CONTROLCODE')) >0
           AND oddlot = 'N'
           And PCK_HOGW.fnc_check_P_stockbond('1G',SYMBOL) <>'0'
         )
         OR
         ( INSTR((select inperiod from msgmast where msgtype ='1G_ODD'),(SELECT SYSVALUE FROM ORDERSYS WHERE SYSNAME='CONTROLCODE')) >0
            AND oddlot = 'Y'
         )
         OR
         (
           INSTR((select inperiod from msgmast where msgtype ='1G_ODD'),(SELECT SYSVALUE FROM ORDERSYS WHERE SYSNAME='CONTROLCODE_ODD_LOT')) >0
           AND oddlot = 'Y'
         )
    )
    AND PCK_HOGW.FNC_CHECK_TRADERID('P',BORS) <> '0';
    --end ThangPV chinh sua lo le HSX 05-12-2022

    --ThangPV chinh sua lo le HSX 30-05-2022 ROC 1.3
   /* Cursor c_Check_Doiung(v_BorS Varchar2, v_Custodycd Varchar2,v_Codeid Varchar2) is
           SELECT ORGORDERID FROM ood o , odmast od
           WHERE o.orgorderid = od.orderid and o.custodycd =v_Custodycd and o.codeid=v_Codeid
                 And o.bors <> v_BorS
                 And od.remainqtty >0
                 AND od.EXECTYPE in ('NB','NS','MS')
                 And o.oodstatus in ('B','S');*/
     Cursor c_Check_Doiung(v_BorS Varchar2, v_Custodycd Varchar2,v_Codeid Varchar2, v_tradelot number) is
           SELECT ORGORDERID FROM ood o , odmast od
           WHERE o.orgorderid = od.orderid and o.custodycd =v_Custodycd and o.codeid=v_Codeid
                 And o.bors <> v_BorS
                 And od.remainqtty >0
                 AND od.EXECTYPE in ('NB','NS','MS')
                 And o.oodstatus in ('B','S')
                 And (od.MATCHTYPE='P' OR (od.MATCHTYPE='N' AND od.ORDERQTTY >= v_tradelot) );
    --end ThangPV chinh sua lo le HSX 30-05-2022 ROC 1.3

    l_strTRADEBUYSELLPT  VARCHAR2(10); -- Y Thi cho phep dat lenh thoa thuan doi ung
     l_controlcode varchar2(10);


BEGIN
    plog.setbeginsection (pkgctx, 'PRC_1G');

    Begin
            Select VARVALUE into v_strSysCheckBuySell from sysvar where GRNAME ='SYSTEM' and VARNAME ='TRADEBUYSELL';
        Exception When OTHERS Then
            v_strSysCheckBuySell:='N';
    End;

    Begin
          Select VARVALUE Into l_strTRADEBUYSELLPT
          From sysvar
          Where GRNAME ='SYSTEM' and VARNAME ='TRADEBUYSELLPT' ;
      EXCEPTION when OTHERS Then
          l_strTRADEBUYSELLPT:='N';
    End;

    FOR I IN C_1G
    LOOP

    --Kiem tra neu co lenh doi ung Block, Sent chua khop het thi khong day len GW.
    --Sysvar ko cho BuySell thi check doi ung.
        v_Check:=False;
         l_controlcode:=fn_get_controlcode(i.SECURITY_SYMBOL_ALPH,i.oddlot);    --ThangPV chinh sua lo le HSX 05-12-2022
        If v_strSysCheckBuySell ='N' and  l_controlcode in ('P','A') and l_strTRADEBUYSELLPT='N' Then
            --ThangPV chinh sua lo le HSX 30-05-2022 ROC 1.3
            --Open c_Check_Doiung(I.BORS, I.CLIENT_ID_SELLER_ALPH,I.CODEID);
            Open c_Check_Doiung(I.BORS, I.CLIENT_ID_SELLER_ALPH,I.CODEID, I.Tradelot);
            Fetch c_Check_Doiung into v_Temp;
            If c_Check_Doiung%found then
                v_Check:=True;
            End if;
            Close c_Check_Doiung;
        End if;

        IF Not v_Check THEN

        -- Check xem da co lenh trong ODQUEUE chua neu co roi thi ko cho da lenh vao nua

            v_DblODQUEUE :=1 ;
            Begin
                Select count(orgorderid) into v_DblODQUEUE  from ODQUEUE  where  orgorderid  =  I.orderid ;
            Exception When OTHERS Then
                v_DblODQUEUE :=1 ;
            End;

            IF v_DblODQUEUE = 0 THEN

                SELECT seq_ordermap.NEXTVAL Into v_Order_Number From dual;
                INSERT INTO ho_1g
                    (firm_seller, filler_2, client_id_seller_alph,
                     broker_foreign_volume_seller, mutual_fund_volume_seller,
                     broker_client_volume_seller, broker_portfolio_volume_seller,
                     filler_1, order_number, board_alph, price,
                     security_symbol_alph, trader_id_buyer_alph,
                     contra_firm_buyer, trader_id_seller_alph, orderid,
                     date_time, status,SENDNUM
                    )
                VALUES (I.firm_seller, I.filler_2, I.client_id_seller_alph,
                     I.broker_foreign_volume_seller, I.mutual_fund_volume_seller,
                     I.broker_client_volume_seller, I.broker_portfolio_volume_seller,
                     I.filler_1, v_Order_Number, I.board_alph, I.price,
                     I.security_symbol_alph, I.trader_id_buyer_alph,
                     I.contra_firm_buyer, I.trader_id_seller_alph, I.orderid,
                     '', 'N',I.SENDNUM
                    );
               --XU LY LENH 1G
                --1.1DAY VAO ORDERMAP.
                INSERT INTO ORDERMAP(ctci_order,orgorderid) VALUES (v_Order_Number,I.orderid);
                --1.2 CAP NHAT OOD.
                UPDATE OOD SET OODSTATUS='B' WHERE ORGORDERID=I.orderid;
                UPDATE ODMAST SET hosesession= l_controlcode WHERE ORDERID=I.orderid;
                --1.3 DAY LENH VAO ODQUEUE
                INSERT INTO ODQUEUE SELECT * FROM OOD WHERE ORGORDERID = I.orderid;
                Exit; -- GWHOSE bi loi neu boc 7 lenh thoa thuan 1 luc
            END IF ;
        End if;
    END LOOP;
    --LAY DU LIEU RA GW.
    OPEN PV_REF FOR
    SELECT
        RPAD(FIRM_SELLER,3,' ') FIRM_SELLER,
        RPAD(FILLER_2,32,' ') FILLER_2,
        RPAD(CLIENT_ID_SELLER_ALPH,10,' ') CLIENT_ID_SELLER,
        RPAD(BROKER_FOREIGN_VOLUME_SELLER,8,' ') BROKER_FOREIGN_VOLUME_SELLER,
        RPAD(MUTUAL_FUND_VOLUME_SELLER,8,' ') MUTUAL_FUND_VOLUME_SELLER,
        RPAD(BROKER_CLIENT_VOLUME_SELLER,8,' ') BROKER_CLIENT_VOLUME_SELLER,
        RPAD(BROKER_PORTFOLIO_VOLUME_SELLER,8,' ') BROKER_PORTFOLIO_VOLUME_SELLER,
        RPAD(FILLER_1,4,' ') FILLER_1,
        RPAD(ORDER_NUMBER,5,' ') DEAL_ID,
        RPAD(BOARD_ALPH,1,' ') BOARD,
        RPAD(PRICE,12,' ') PRICE,
        RPAD(SECURITY_SYMBOL_ALPH,8,' ') SECURITY_SYMBOL,
        RPAD(TRADER_ID_BUYER_ALPH,4,' ') TRADER_ID_BUYER,
        RPAD(CONTRA_FIRM_BUYER,3,' ') CONTRA_FIRM_BUYER,
        RPAD(TRADER_ID_SELLER_ALPH,4,' ') TRADER_ID_SELLER,
        ORDERID||SENDNUM BOORDERID

    FROM ho_1g WHERE STATUS ='N';
    --Cap nhat trang thai bang tam ra GW.
    UPDATE ho_1g SET STATUS ='Y',DATE_TIME = SYSDATE WHERE STATUS ='N';
    plog.setendsection (pkgctx, 'PRC_1G');

EXCEPTION WHEN OTHERS THEN
    plog.error(pkgctx, SQLERRM || '--' || dbms_utility.format_error_backtrace);
    plog.setendsection (pkgctx, 'PRC_1G');
    RAISE errnums.E_SYSTEM_ERROR;
END PRC_1G;

  --Day message lenh thong thuong 1D len Gw
Procedure PRC_1D(PV_REF IN OUT PKG_REPORT.REF_CURSOR) is

    v_err VARCHAR2(200);

    CURSOR C_1D IS
    SELECT ORDER_NUMBER ORDER_NUMBER,S.SYSVALUE FIRM ,SUBSTR(ORGORDERID,5,4) ORDER_ENTRY_DATE,
        ORGORDERID ORDERID , CUSTODYCD_CHANGE CLIENT_ID_ALPH,' ' FILLER
    From ORDER_CHANGE , ORDERSYS s
    WHERE
        S.SYSNAME ='FIRM'
        AND STATUS='N'
        AND INSTR((select inperiod from msgmast where msgtype ='1D'),
        (SELECT SYSVALUE FROM ORDERSYS WHERE SYSNAME='CONTROLCODE')) >0;
BEGIN
    plog.setbeginsection (pkgctx, 'PRC_1D');
    FOR I IN C_1D
    LOOP
        INSERT INTO ho_1d
               (client_id_alph, order_entry_date, order_number, firm,
                filler, orderid, date_time, status
               )
        VALUES (I.client_id_alph, I.order_entry_date, I.order_number, I.firm,
                I.filler, I.orderid, '', 'N'
        );
        --XU LY LENH 1D
        Update ORDER_CHANGE SET status ='Y',TIME_SEND=sysdate WHERE ORGORDERID = I.orderid;
    END LOOP;
    --LAY DU LIEU RA GW.
    OPEN PV_REF FOR
    SELECT
        RPAD(CLIENT_ID_ALPH,10,' ') CLIENT_ID,
        RPAD(ORDER_ENTRY_DATE,4,' ') ORDER_ENTRY_DATE,
        RPAD(ORDER_NUMBER,8,' ') ORDER_NUMBER,
        RPAD(FIRM,3,' ') FIRM,
        RPAD(FILLER,17,' ') FILLER

    FROM ho_1d WHERE STATUS ='N';
    --Cap nhat trang thai bang tam ra GW.
    UPDATE ho_1D SET STATUS ='Y',DATE_TIME = SYSDATE WHERE STATUS ='N';
    plog.setendsection (pkgctx, 'PRC_1D');

EXCEPTION WHEN OTHERS THEN
    plog.error(pkgctx, SQLERRM || '--' || dbms_utility.format_error_backtrace);
    plog.setendsection (pkgctx, 'PRC_1D');
    RAISE errnums.E_SYSTEM_ERROR;
END PRC_1D;

 --Day message chap nhan/tu choi lenh thoa thuan len Gw
Procedure PRC_3B(PV_REF IN OUT PKG_REPORT.REF_CURSOR) is

    v_err VARCHAR2(200);
    v_Temp VARCHAR2(30);
    v_Check BOOLEAN;
    v_strSysCheckBuySell VARCHAR2(30);

    CURSOR C_3B IS
    SELECT FIRM,CONFIRMNUMBER CONFIRM_NUMBER,SEQ_ORDERMAP.NEXTVAL ORDER_NUMBER,CUSTODYCD CLIENT_ID_BUYER_ALPH,
    STATUS REPLY_CODE_ALPH,'    ' FILLER_1,ORGORDERID ORDERID,
    (CASE WHEN SUBSTR(CUSTODYCD,4,1)='P' THEN QTTY ELSE 0 END) BROKER_PORTFOLIO_VOLUME,
    (CASE WHEN SUBSTR(CUSTODYCD,4,1)='C' THEN QTTY ELSE 0 END) BROKER_CLIENT_VOLUME,
    (CASE WHEN SUBSTR(CUSTODYCD,4,1)='A' or SUBSTR(CUSTODYCD,4,1)='B' THEN QTTY ELSE 0 END) BROKER_MUTUAL_FUND_VOLUME,
    (CASE WHEN SUBSTR(CUSTODYCD,4,1)='F' or SUBSTR(CUSTODYCD,4,1)='E' THEN QTTY ELSE 0 END) BROKER_FOREIGN_VOLUME,
    '   ' FILLER_2, CODEID, TradeLot, SYMBOL
    FROM
        (SELECT A.FIRM,
                A.CONFIRMNUMBER,
                A.STATUS,
                C.CUSTODYCD,
                C.QTTY,
                C.ORGORDERID,
                B.CODEID, INF.Tradelot,S.SYMBOL
         FROM ORDERPTACK A, ODMAST B,OOD C, SBSECURITIES S, SECURITIES_INFO INF
         WHERE
            A.STATUS IN ('A') AND
            A.CONFIRMNUMBER=B.CONFIRM_NO AND
            B.ORDERID=C.ORGORDERID AND
            s.codeid=INF.Codeid AND
            B.DELTD <>'Y' AND
            A.ISSEND <>'Y' AND
            C.SYMBOL =S.SYMBOL  AND
            S.TRADEPLACE ='001'
         )
    WHERE INSTR((select inperiod from msgmast where msgtype ='3B'),
                   (SELECT SYSVALUE FROM ORDERSYS WHERE SYSNAME='CONTROLCODE')) >0
    AND PCK_HOGW.FNC_CHECK_SEC_HCM(SYMBOL) <> '0' --Kiem tra halt
    AND PCK_HOGW.FNC_CHECK_TRADERID('P','B') <> '0';



-- Lay message tu choi mua thoa thuan
    CURSOR C_3B_REJECT IS
    SELECT FIRM,CONFIRMNUMBER CONFIRM_NUMBER,0 ORDER_NUMBER,' ' CLIENT_ID_BUYER_ALPH,
        a.STATUS REPLY_CODE_ALPH,'    ' FILLER_1,' ' ORDERID,
        0 BROKER_PORTFOLIO_VOLUME,
        0 BROKER_CLIENT_VOLUME,
        0 BROKER_MUTUAL_FUND_VOLUME,
        0 BROKER_FOREIGN_VOLUME,
        '   ' FILLER_2
    FROM ORDERPTACK A, SBSECURITIES S
    WHERE A.STATUS = ('C') AND A.ISSEND <>'Y'
        AND TRIM(A.SECURITYSYMBOL) =S.SYMBOL AND S.TRADEPLACE ='001'
        AND INSTR((select inperiod from msgmast where msgtype ='3B'),
                   (SELECT SYSVALUE FROM ORDERSYS WHERE SYSNAME='CONTROLCODE')) >0;
--ThangPV chinh sua lo le HSX 30-05-2022 ROC 1.3
  /*  Cursor c_Check_Doiung(v_BorS Varchar2, v_Custodycd Varchar2,v_Codeid Varchar2) is
                      SELECT ORGORDERID FROM ood o , odmast od
                      WHERE o.orgorderid = od.orderid and o.custodycd =v_Custodycd and o.codeid=v_Codeid
                            And o.bors <> v_BorS
                            And od.remainqtty >0
                            AND od.EXECTYPE in ('NB','NS','MS')
                            And o.oodstatus in ('B','S'); */

    Cursor c_Check_Doiung(v_BorS Varchar2, v_Custodycd Varchar2,v_Codeid Varchar2, v_Tradelot number) is
                      SELECT ORGORDERID FROM ood o , odmast od
                      WHERE o.orgorderid = od.orderid and o.custodycd =v_Custodycd and o.codeid=v_Codeid
                            And o.bors <> v_BorS
                            And od.remainqtty >0
                            AND od.EXECTYPE in ('NB','NS','MS')
                            And o.oodstatus in ('B','S')
                            And (od.MATCHTYPE='P' OR (od.MATCHTYPE='N' AND od.ORDERQTTY >= v_tradelot) );

    --end ThangPV chinh sua lo le HSX 30-05-2022 ROC 1.3

BEGIN
    plog.setbeginsection (pkgctx, 'PRC_3B');
    FOR I IN C_3B
    LOOP
        --Kiem tra neu co lenh doi ung Block, Sent chua khop het thi khong day len GW.
        --Sysvar ko cho BuySell thi check doi ung.
        v_Check:=False;

        Begin
          Select VARVALUE into v_strSysCheckBuySell from sysvar where GRNAME ='SYSTEM' and VARNAME ='TRADEBUYSELL';
        Exception When OTHERS Then
          v_strSysCheckBuySell:='N';
        End;
        If v_strSysCheckBuySell ='N' Then
            --ThangPV chinh sua lo le HSX 30-05-2022 ROC 1.3
            --Open c_Check_Doiung('B', I.CLIENT_ID_BUYER_ALPH,I.CODEID);
            Open c_Check_Doiung('B', I.CLIENT_ID_BUYER_ALPH,I.CODEID, I.Tradelot);
            Fetch c_Check_Doiung into v_Temp;
            If c_Check_Doiung%found then
            v_Check:=True;
            End if;
            Close c_Check_Doiung;
        End if;

        IF Not v_Check THEN

               INSERT INTO ho_3b
                           (filler_2, broker_foreign_volume, broker_mutual_fund_volume,
                            broker_client_volume, broker_portfolio_volume, filler_1,
                            reply_code_alph, client_id_buyer_alph, order_number, firm,
                            confirm_number, orderid, date_time, status
                           )
                    VALUES (I.filler_2, I.broker_foreign_volume, I.broker_mutual_fund_volume,
                            I.broker_client_volume, I.broker_portfolio_volume, I.filler_1,
                            I.reply_code_alph, I.client_id_buyer_alph, I.order_number, I.firm,
                            I.confirm_number, I.orderid, '', 'N'
                           );
             --XU LY LENH 3B
               --1.1DAY VAO ORDERMAP.
               INSERT INTO ORDERMAP(ctci_order,orgorderid) VALUES (I.order_number,I.orderid);
               --1.2 CAP NHAT OOD.
               UPDATE OOD SET OODSTATUS='B' WHERE ORGORDERID=I.orderid;
               --1.3 DAY LENH VAO ODQUEUE
               INSERT INTO ODQUEUE SELECT * FROM OOD WHERE ORGORDERID = I.orderid;
               --1.4 Update msg chao ban da dc confirm
               UPDATE ORDERPTACK SET ISSEND='Y' WHERE  trim(CONFIRMNUMBER)=trim(I.confirm_number);

        END IF;
    END LOOP;

    FOR I IN C_3B_REJECT
    LOOP
        INSERT INTO ho_3b
                   (filler_2, broker_foreign_volume, broker_mutual_fund_volume,
                    broker_client_volume, broker_portfolio_volume, filler_1,
                    reply_code_alph, client_id_buyer_alph, order_number, firm,
                    confirm_number, orderid, date_time, status
                   )
            VALUES (I.filler_2, I.broker_foreign_volume, I.broker_mutual_fund_volume,
                    I.broker_client_volume, I.broker_portfolio_volume, I.filler_1,
                    I.reply_code_alph, I.client_id_buyer_alph, I.order_number, I.firm,
                    I.confirm_number, I.orderid, '', 'N'
                   );
        UPDATE ORDERPTACK SET ISSEND='Y' WHERE  trim(CONFIRMNUMBER)=trim(I.confirm_number);
    END LOOP;
    --LAY DU LIEU RA GW.
    --thunt-21/05/2021:N? d? d?tru?ng CONFIRM_NUMBER-theo HOSE
    OPEN PV_REF FOR
        SELECT
        RPAD(FILLER_2,32,' ') FILLER_2,
        RPAD(BROKER_FOREIGN_VOLUME,8,' ') BROKER_FOREIGN_VOLUME,
        RPAD(BROKER_MUTUAL_FUND_VOLUME,8,' ') BROKER_MUTUAL_FUND_VOLUME,
        RPAD(BROKER_CLIENT_VOLUME,8,' ') BROKER_CLIENT_VOLUME,
        RPAD(BROKER_PORTFOLIO_VOLUME,8,' ') BROKER_PORTFOLIO_VOLUME,
        RPAD(FILLER_1,4,' ') FILLER_1,
        RPAD(REPLY_CODE_ALPH,1,' ') REPLY_CODE,
        RPAD(CLIENT_ID_BUYER_ALPH,10,' ') CLIENT_ID_BUYER,
        RPAD(ORDER_NUMBER,5,' ') DEAL_ID,
        RPAD(FIRM,3,' ') FIRM,
        RPAD(CONFIRM_NUMBER,12,' ') CONFIRM_NUMBER

    FROM ho_3B WHERE STATUS ='N';
    --Cap nhat trang thai bang tam ra GW.
    UPDATE ho_3B SET STATUS ='Y',DATE_TIME = SYSDATE WHERE STATUS ='N';
    plog.setendsection (pkgctx, 'PRC_3B');

EXCEPTION WHEN OTHERS THEN
    plog.error(pkgctx, SQLERRM || '--' || dbms_utility.format_error_backtrace);
    plog.setendsection (pkgctx, 'PRC_3B');
    RAISE errnums.E_SYSTEM_ERROR;
END PRC_3B;

--Day message yeu cau huy lenh thoa thuan 3C len Gw
Procedure PRC_3C(PV_REF IN OUT PKG_REPORT.REF_CURSOR) is

    v_err VARCHAR2(200);

    CURSOR C_3C IS
    SELECT FIRM,CONTRAFIRM CONTRAFIRM,TRADEID TRADEID,CONFIRMNUMBER CONFIRMNUMBER,
             SECURITYSYMBOL SECURITYSYMBOL,SIDE SIDE
    FROM CANCELORDERPTACK
    WHERE SORR='S' AND MESSAGETYPE='3C'
    AND STATUS='N' AND ISCONFIRM='N'
    AND PCK_HOGW.FNC_CHECK_SEC_HCM(SECURITYSYMBOL) <> '0'
    AND INSTR((select inperiod from msgmast where msgtype ='3C'  AND msgmast.RORS ='S'),
               (SELECT SYSVALUE FROM ORDERSYS WHERE SYSNAME='CONTROLCODE')) >0
   AND PCK_HOGW.FNC_CHECK_TRADERID('P','S') <> '0';
BEGIN
    plog.setbeginsection (pkgctx, 'PRC_3C');
    FOR I IN C_3C
    LOOP
        INSERT INTO ho_3c
           (contrafirm, securitysymbol, confirmnumber, firm, side,
            tradeid, date_time, status
           )
        VALUES (I.contrafirm, I.securitysymbol, I.confirmnumber, I.firm, I.side,
            I.tradeid, '', 'N'
           );
        --XU LY LENH 3C
        UPDATE CANCELORDERPTACK
        SET STATUS='S'
        WHERE MESSAGETYPE='3C' AND SORR='S' AND CONFIRMNUMBER=I.confirmnumber;
    END LOOP;
    --LAY DU LIEU RA GW.--thunt-21/05/2021:N? d? d?tru?ng CONFIRM_NUMBER-theo HOSE
    OPEN PV_REF FOR
    SELECT
        RPAD(CONTRAFIRM,3,' ') CONTRA_FIRM,
        RPAD(SECURITYSYMBOL,8,' ') SECURITY_SYMBOL,
        RPAD(CONFIRMNUMBER,12,' ') CONFIRM_NUMBER,
        RPAD(FIRM,3,' ') FIRM,
        RPAD(SIDE,1,' ') SIDE,
        RPAD(TRADEID,4,' ') TRADER_ID
    FROM ho_3C
    WHERE STATUS ='N';
    --Cap nhat trang thai bang tam ra GW.
    UPDATE ho_3C SET STATUS ='Y',DATE_TIME = SYSDATE WHERE STATUS ='N';
    plog.setendsection (pkgctx, 'PRC_3C');

EXCEPTION WHEN OTHERS THEN
    plog.error(pkgctx, SQLERRM || '--' || dbms_utility.format_error_backtrace);
    plog.setendsection (pkgctx, 'PRC_3C');
    RAISE errnums.E_SYSTEM_ERROR;
END PRC_3C;


--Day message yeu cau huy lenh thoa thuan 3C len Gw
Procedure PRC_1E(PV_REF IN OUT PKG_REPORT.REF_CURSOR) is

    v_err VARCHAR2(200);

    CURSOR C_1E IS
    SELECT s.sectype,A.AUTOID, A.TIMESTAMP, A.MESSAGETYPE, A.FIRM, FNC_CHECK_TRADERID('P',A.SIDE)  TRADEID,
        A.SECURITYSYMBOL, A.SIDE, to_number(Replace(A.VOLUME,',','')) VOLUME, lpad(floor(A.PRICE),6,'0')||rpad(replace((A.PRICE -floor(A.PRICE)),'.',''),6,'0') PRICE , A.BOARD, A.SENDTIME,
        A.STATUS, A.CONTACT, A.OFFSET, A.ISSEND, A.ISACTIVE, A.DELETED,
        A.REFID, A.BRID, A.TLID, A.IPADDRESS, A.ADVDATE,to_char(sysdate,'HH24MISS') TIME
    FROM ORDERPTADV A,sbsecurities s,
    securities_info i           --ThangPV chinh sua lo le HSX 05-12-2022
    WHERE A.DELETED <> 'Y' AND A.ISSEND='N' AND A.ISACTIVE='Y'
        and  PCK_HOGW.FNC_CHECK_TRADERID('P',A.SIDE) <> '0'
        AND trim(a.securitysymbol) =trim(s.SYMBOL)
        AND s.codeid=i.codeid           --ThangPV chinh sua lo le HSX 05-12-2022
        --and PCK_HOGW.fnc_check_P_stockbond('1E',SECURITYSYMBOL) <>'0'
        AND (
              (PCK_HOGW.fnc_check_P_stockbond('1E',SECURITYSYMBOL) <>'0' AND to_number(Replace(A.VOLUME,',','')) >= i.tradelot )
              OR
              ( INSTR((select inperiod from msgmast where msgtype ='1E_ODD'),(SELECT SYSVALUE FROM ORDERSYS WHERE SYSNAME='CONTROLCODE')) >0
                AND to_number(Replace(A.VOLUME,',','')) < i.tradelot
              )
              OR
              ( INSTR((select inperiod from msgmast where msgtype ='1E_ODD'),(SELECT SYSVALUE FROM ORDERSYS WHERE SYSNAME='CONTROLCODE_ODD_LOT')) >0
                AND to_number(Replace(A.VOLUME,',','')) < i.tradelot
              )
            )       --end ThangPV chinh sua lo le HSX 05-12-2022
        And s.tradeplace ='001'
        And PCK_HOGW.FNC_CHECK_SEC_HCM(SECURITYSYMBOL) <> '0';
BEGIN
    plog.setbeginsection (pkgctx, 'PRC_1E');

    --XU LY LENH 1E
    FOR I IN C_1E
    LOOP
        INSERT INTO ho_1e
           (contact, status, TIMESTAMP, firm, tradeid, securitysymbol,
            side, volume, board, price, autoid, SENTSTATUS
           )
        VALUES (I.contact, I.status, I.TIMESTAMP, I.firm, I.tradeid, I.securitysymbol,
            I.side, I.volume, I.board, I.price, I.autoid, 'N'
           );
        --XU LY LENH 1E
        UPDATE ORDERPTADV SET ISSEND='Y' WHERE AUTOID =I.autoid;
    END LOOP;

    --LAY DU LIEU RA GW.
    OPEN PV_REF FOR
    SELECT
        RPAD(CONTACT,20,' ') CONTACT,
        RPAD(STATUS,1,' ') ADD_CANCEL_FLAG,
        RPAD(TIMESTAMP,6,' ') TIME,
        RPAD(FIRM,3,' ') FIRM,
        RPAD(TRADEID,4,' ') TRADER_ID,
        RPAD(SECURITYSYMBOL,8,' ') SECURITY_SYMBOL,
        RPAD(SIDE,1,' ') SIDE,
        RPAD(VOLUME,8,' ') VOLUME,
        RPAD(BOARD,1,' ') BOARD,
        RPAD(PRICE,12,' ') PRICE
    FROM ho_1e
    WHERE SENTSTATUS ='N';

    --Cap nhat trang thai bang tam ra GW.
    UPDATE ho_1E SET SENTSTATUS ='Y' WHERE SENTSTATUS ='N';
    plog.setendsection (pkgctx, 'PRC_1E');

EXCEPTION WHEN OTHERS THEN
    plog.error(pkgctx, SQLERRM || '--' || dbms_utility.format_error_backtrace);
    plog.setendsection (pkgctx, 'PRC_1E');
    RAISE errnums.E_SYSTEM_ERROR;
END PRC_1E;


--Day message chap nhan/tu choi huy 3D len Gw
Procedure PRC_3D(PV_REF IN OUT PKG_REPORT.REF_CURSOR) is

    v_err VARCHAR2(200);

    CURSOR C_3D IS
    SELECT FIRM,CONTRAFIRM CONTRAFIRM,TRADEID TRADEID,CONFIRMNUMBER CONFIRMNUMBER,
        SECURITYSYMBOL SECURITYSYMBOL,SIDE SIDE,STATUS REPLY_CODE
    FROM CANCELORDERPTACK
    WHERE SORR='R'
    --AND MESSAGETYPE='3D'
    AND STATUS in ('A','C') AND ISCONFIRM='N'
    AND SORR ='R'
    AND PCK_HOGW.FNC_CHECK_SEC_HCM(SECURITYSYMBOL) <> '0'
    AND INSTR((select inperiod from msgmast where msgtype ='3D'),
               (SELECT SYSVALUE FROM ORDERSYS WHERE SYSNAME='CONTROLCODE')) >0
    AND PCK_HOGW.FNC_CHECK_TRADERID('P','B') <> '0';
BEGIN
    plog.setbeginsection (pkgctx, 'PRC_3D');
    FOR I IN C_3D
    LOOP
        INSERT INTO ho_3d
           (reply_code, confirmnumber, firm, date_time, status
           )
        VALUES (I.reply_code, I.confirmnumber, I.firm, '', 'N'
           );
        --XU LY LENH 3D
        UPDATE CANCELORDERPTACK SET ISCONFIRM='Y'
        WHERE STATUS in ('A','C') AND SORR='R'
        AND Trim(CONFIRMNUMBER)=TRIM(I.confirmnumber);
    END LOOP;
    --LAY DU LIEU RA GW.-thunt-21/05/2021:N? d? d?tru?ng CONFIRM_NUMBER-theo HOSE
    OPEN PV_REF FOR
    SELECT
        RPAD(REPLY_CODE,1,' ') REPLY_CODE,
        RPAD(CONFIRMNUMBER,12,' ') CONFIRM_NUMBER,
        RPAD(FIRM,3,' ') FIRM
    FROM ho_3D WHERE STATUS ='N';
    --Cap nhat trang thai bang tam ra GW.
    UPDATE ho_3D SET STATUS ='Y',DATE_TIME = SYSDATE WHERE STATUS ='N';
    plog.setendsection (pkgctx, 'PRC_3D');

EXCEPTION WHEN OTHERS THEN
    plog.error(pkgctx, SQLERRM || '--' || dbms_utility.format_error_backtrace);
    plog.setendsection (pkgctx, 'PRC_3D');
    RAISE errnums.E_SYSTEM_ERROR;
END PRC_3D;

  --LAY MESSAGE DAY LEN GW.
Procedure PRC_GETORDER(PV_REF IN OUT PKG_REPORT.REF_CURSOR, v_MsgType VARCHAR2) is
BEGIN
    plog.setbeginsection (pkgctx, 'PRC_GETORDER');
    IF v_MsgType ='1I' THEN
      PRC_1I(PV_REF);
    ELSIF v_MsgType ='1C' THEN
      PRC_1C(PV_REF);
    ELSIF v_MsgType ='1D' THEN
      PRC_1D(PV_REF);
    ELSIF v_MsgType ='1F' THEN
      PRC_1F(PV_REF);
    ELSIF v_MsgType ='1G' THEN
      PRC_1G(PV_REF);
    ELSIF v_MsgType ='3B' THEN
      PRC_3B(PV_REF);
    ELSIF v_MsgType ='3C' THEN
      PRC_3C(PV_REF);
    ELSIF v_MsgType ='3D' THEN
      PRC_3D(PV_REF);
    ELSIF v_MsgType ='1E' THEN
      PRC_1E(PV_REF);
    END IF;
    plog.setendsection (pkgctx, 'PRC_GETORDER');

EXCEPTION WHEN OTHERS THEN
    plog.error(pkgctx, SQLERRM || '--' || dbms_utility.format_error_backtrace);
    plog.error(pkgctx, 'HOGW-PRC_GETORDER SQLERRM v_MsgType = '||v_MsgType);
    plog.setendsection (pkgctx, 'PRC_GETORDER');
    RAISE errnums.E_SYSTEM_ERROR;
END PRC_GETORDER;

  --XU LY MESSAGE NHAN VE
Procedure PRC_PROCESSMSG(V_MSGGROUP VARCHAR2) is
    CURSOR C_MSG_RECEIVE IS
    Select * from
    (
    SELECT MSGTYPE,ID, REPLACE(MSGXML,'&',' ') MSGXML, PROCESS,MSG_DATE FROM MSGRECEIVETEMP WHERE MSGGROUP =V_MSGGROUP  AND PROCESS ='N' order by ID
    )
    where  ROWNUM BETWEEN 0 AND (SELECT SYSVALUE FROM ORDERSYS WHERE SYSNAME='HOSERECEIVESIZE');
    V_MSG_RECEIVE C_MSG_RECEIVE%ROWTYPE;
BEGIN
    plog.setbeginsection (pkgctx, 'PRC_PROCESSMSG');
    OPEN C_MSG_RECEIVE;
    LOOP
        FETCH C_MSG_RECEIVE INTO V_MSG_RECEIVE;
        EXIT WHEN C_MSG_RECEIVE%NOTFOUND;
        -- Gan gia tri xu ly msg thanh cong
        -- TH xu ly loi thi se khong cap nhat PROCESS = 'Y'
        Begin
            INSERT INTO HOMSGQUEUE(ID,LOGTIME) VALUES(V_MSG_RECEIVE.ID,SYSDATE);
            v_CheckProcess := TRUE;
            IF V_MSG_RECEIVE.MSGTYPE ='2B' THEN
              PRC_PROCESS2B(V_MSG_RECEIVE.MSGXML);
            ELSIF V_MSG_RECEIVE.MSGTYPE ='2C' THEN
              PRC_PROCESS2C(V_MSG_RECEIVE.MSGXML);
            ELSIF V_MSG_RECEIVE.MSGTYPE ='2E' THEN
              PRC_PROCESS2E(V_MSG_RECEIVE.MSGXML);
            ELSIF V_MSG_RECEIVE.MSGTYPE ='2G' THEN
              PRC_PROCESS2G(V_MSG_RECEIVE.MSGXML);
            ELSIF V_MSG_RECEIVE.MSGTYPE ='2D' THEN
              PRC_PROCESS2D(V_MSG_RECEIVE.MSGXML);
            ELSIF V_MSG_RECEIVE.MSGTYPE ='2I' THEN
              PRC_PROCESS2I(V_MSG_RECEIVE.MSGXML);
            ELSIF V_MSG_RECEIVE.MSGTYPE ='2L' THEN
              PRC_PROCESS2L(V_MSG_RECEIVE.MSGXML);
            ELSIF V_MSG_RECEIVE.MSGTYPE ='2F' THEN
              PRC_PROCESS2F(V_MSG_RECEIVE.MSGXML);
            ELSIF V_MSG_RECEIVE.MSGTYPE ='3B' THEN
              PRC_PROCESS3B(V_MSG_RECEIVE.MSGXML);
            ELSIF V_MSG_RECEIVE.MSGTYPE ='3C' THEN
              PRC_PROCESS3C(V_MSG_RECEIVE.MSGXML);
            ELSIF V_MSG_RECEIVE.MSGTYPE ='SC' THEN
              PRC_PROCESSSC(V_MSG_RECEIVE.MSGXML,TO_CHAR(V_MSG_RECEIVE.MSG_DATE,'HH24MISS'));
            ELSIF V_MSG_RECEIVE.MSGTYPE ='TR' THEN
              PRC_PROCESSTR(V_MSG_RECEIVE.MSGXML);
            ELSIF V_MSG_RECEIVE.MSGTYPE ='GA' THEN
              PRC_PROCESSGA(V_MSG_RECEIVE.MSGXML);
            ELSIF V_MSG_RECEIVE.MSGTYPE ='SU' THEN
              PRC_PROCESSSU(V_MSG_RECEIVE.MSGXML);
            ELSIF V_MSG_RECEIVE.MSGTYPE ='SS' THEN
              PRC_PROCESSSS(V_MSG_RECEIVE.MSGXML);
            ELSIF V_MSG_RECEIVE.MSGTYPE ='TC' THEN
              PRC_PROCESSTC(V_MSG_RECEIVE.MSGXML);
            ELSIF V_MSG_RECEIVE.MSGTYPE ='TS' THEN
              PRC_PROCESSTS(V_MSG_RECEIVE.MSGXML,TO_CHAR(V_MSG_RECEIVE.MSG_DATE,'HH24MISS'));
            ELSIF V_MSG_RECEIVE.MSGTYPE ='BS' THEN
              PRC_PROCESSBS(V_MSG_RECEIVE.MSGXML);
            ELSIF V_MSG_RECEIVE.MSGTYPE ='3D' THEN
              PRC_PROCESS3D(V_MSG_RECEIVE.MSGXML);
            ELSIF V_MSG_RECEIVE.MSGTYPE ='AA' THEN
              PRC_PROCESSAA(V_MSG_RECEIVE.MSGXML);
            END IF;
            -- Chi cap nhat trang thai neu xu ly thanh cong
            IF v_CheckProcess = TRUE THEN
                  UPDATE MSGRECEIVETEMP SET PROCESS ='Y',PROCESSTIME=SYSDATE, PROCESSNUM=PROCESSNUM+1 WHERE ID =V_MSG_RECEIVE.ID;
            Else
                  UPDATE MSGRECEIVETEMP SET PROCESS ='E',PROCESSTIME=SYSDATE, PROCESSNUM=PROCESSNUM+1 WHERE ID =V_MSG_RECEIVE.ID;
                  plog.error(pkgctx,'PRC_PROCESSMSG '||'Cant not process MSG ID = '||V_MSG_RECEIVE.ID||' V_MSG_RECEIVE.MSGTYPE = '||V_MSG_RECEIVE.MSGTYPE);
            END IF;
            COMMIT;
         EXCEPTION WHEN OTHERS THEN
            plog.error(pkgctx, SQLERRM || '--' || dbms_utility.format_error_backtrace);
            rollback;
            UPDATE MSGRECEIVETEMP SET PROCESS ='R',PROCESSTIME=SYSDATE, PROCESSNUM=PROCESSNUM+1 WHERE ID =V_MSG_RECEIVE.ID;
            plog.error(pkgctx,'PRC_PROCESSMSG '||'exeption in process MSG ID = '||V_MSG_RECEIVE.ID||' V_MSG_RECEIVE.MSGTYPE = '||V_MSG_RECEIVE.MSGTYPE);
            commit;
         End;
    END LOOP;
    CLOSE C_MSG_RECEIVE;

plog.setendsection (pkgctx, 'PRC_PROCESSMSG');

EXCEPTION WHEN OTHERS THEN
    plog.error(pkgctx, SQLERRM || '--' || dbms_utility.format_error_backtrace);
    plog.setendsection (pkgctx, 'PRC_PROCESSMSG');
    ROLLBACK;
    RAISE errnums.E_SYSTEM_ERROR;
END PRC_PROCESSMSG;

 --PROCESS MSG 2b
Procedure PRC_PROCESS2B(V_MSGXML VARCHAR2) is
    V_TX2B   tx.msg_2B;
    V_ORGORDERID VARCHAR2(20);
BEGIN
    plog.setbeginsection (pkgctx, 'PRC_PROCESS2B');

    V_TX2B:=fn_xml2obj_2B(V_MSGXML);

    --XU LY MESSAGE 2B.
    SELECT ORGORDERID
    INTO V_ORGORDERID
    FROM ORDERMAP
    WHERE ctci_order= TRIM(V_TX2B.ORDER_NUMBER);

    -- Cap nhat trang thai trong OOD va ODMAST
    UPDATE OOD SET
        OODSTATUS = 'S',
        TXTIME = TO_CHAR(SYSDATE,'HH24:MI:SS'),
        SENTTIME = SYSTIMESTAMP
    WHERE ORGORDERID = V_ORGORDERID and  OODSTATUS <> 'S';

    UPDATE ODMAST SET
        ORSTATUS = '2',
        HOSESESSION = (SELECT SYSVALUE  FROM ORDERSYS WHERE SYSNAME = 'CONTROLCODE')
    WHERE ORDERID = V_ORGORDERID AND ORSTATUS IN( '8','11');

    plog.setendsection (pkgctx, 'PRC_PROCESS2B');

EXCEPTION WHEN OTHERS THEN
    plog.error(pkgctx, SQLERRM || '--' || dbms_utility.format_error_backtrace);
    v_CheckProcess := FALSE;
    plog.error(pkgctx,'PRC_PROCESS2B Khong tim so hieu lenh goc V_TX2B.ORDER_NUMBER: '||V_TX2B.ORDER_NUMBER);
    plog.setendsection (pkgctx, 'PRC_PROCESS2B');
    ROLLBACK;
END PRC_PROCESS2B;

  --PROCESS MSG 2C
Procedure PRC_PROCESS2C(V_MSGXML VARCHAR2) is
    V_TX2C   tx.msg_2C;
    V_ORGORDERID VARCHAR2(20);
BEGIN
    plog.setbeginsection (pkgctx, 'PRC_PROCESS2C');

    V_TX2C:=fn_xml2obj_2C(V_MSGXML);
    SELECT ORGORDERID
    INTO V_ORGORDERID FROM ORDERMAP
    WHERE ctci_order =TRIM(V_TX2C.order_number);
    CONFIRM_CANCEL_NORMAL_ORDER(V_ORGORDERID,V_TX2C.cancel_shares);

    plog.setendsection (pkgctx, 'PRC_PROCESS2C');
EXCEPTION WHEN OTHERS THEN
    plog.error(pkgctx, SQLERRM || '--' || dbms_utility.format_error_backtrace);
    v_CheckProcess := FALSE;
    plog.error(pkgctx,'PRC_PROCESS2C Khong tim so hieu lenh goc V_TX2C.ORDER_NUMBER: '||V_TX2C.ORDER_NUMBER);
    plog.setendsection (pkgctx, 'PRC_PROCESS2C');
    ROLLBACK;
END PRC_PROCESS2C;

 --PROCESS MSG 2E
Procedure PRC_PROCESS2E(V_MSGXML VARCHAR2) is
    V_TX2E   tx.msg_2E;
    V_ORGORDERID VARCHAR2(20);
BEGIN
    plog.setbeginsection (pkgctx, 'PRC_PROCESS2E');

    V_TX2E:=fn_xml2obj_2E(V_MSGXML);

    --XU LY MESSAGE 2E.
    --1.1 Lay so hieu lenh
    SELECT ORGORDERID INTO V_ORGORDERID FROM ORDERMAP
    WHERE ctci_order=TRIM(V_TX2E.order_number);
    --1.2 Cap nhat trang thai lenh thanh Sent: S
    UPDATE OOD SET
    OODSTATUS = 'S',
    TXTIME = TO_CHAR(SYSDATE,'HH24:MI:SS'),
    SENTTIME = SYSTIMESTAMP
    WHERE ORGORDERID = V_ORGORDERID and OODSTATUS <> 'S';

    --Goi thu tuc khop lenh
    MATCHING_NORMAL_ORDER (V_TX2E.firm,V_TX2E.order_number,V_TX2E.order_entry_date,
                            V_TX2E.side,V_TX2E.filler,V_TX2E.volume,
                            V_TX2E.price, V_TX2E.confirm_number);
    plog.setendsection (pkgctx, 'PRC_PROCESS2E');
EXCEPTION WHEN OTHERS THEN
    plog.error(pkgctx, SQLERRM || '--' || dbms_utility.format_error_backtrace);
    v_CheckProcess := FALSE;
    plog.error(pkgctx,'PRC_PROCESS2E Khong tim so hieu lenh goc V_TX2E.ORDER_NUMBER: '||V_TX2E.ORDER_NUMBER);
    plog.setendsection (pkgctx, 'PRC_PROCESS2E');
    ROLLBACK;
END PRC_PROCESS2E;

--- process 2g
Procedure PRC_PROCESS2G(V_MSGXML VARCHAR2) is
    V_TX2G   tx.msg_2G;
    V_ORGORDERID VARCHAR2(20);
    v_msgReject varchar2(200);
    v_orderqtty number;
    v_codeid varchar2(10);
    v_contrafirm varchar2(10);
    v_custodycd varchar2(10);
    v_RefOrderID  varchar2(20);
    v_ptdeal      varchar2(20);
    v_qtty number;
BEGIN
    plog.setbeginsection (pkgctx, 'PRC_PROCESS2G');

    V_TX2G:=fn_xml2obj_2G(V_MSGXML);
    Insert into ctci_reject --Ghi log b? t? ch?i
        (firm,
        order_number,
        reject_reason_code,
        original_message_text,
        order_entry_date,
        msgtype)
    VALUES
        (V_TX2G.FIRM,
        V_TX2G.order_number,
        V_TX2G.reject_reason_code,
        V_TX2G.original_message_text,
        V_TX2G.order_entry_date,
        V_TX2G.msg_type);
    --XU LY MESSAGE 2G.
    If V_TX2G.msg_type='1G' then
         SELECT ORGORDERID
        INTO V_ORGORDERID
        FROM ORDERMAP
        WHERE ctci_order = TRIM(V_TX2G.deal_id);
    else
        SELECT ORGORDERID
        INTO V_ORGORDERID
        FROM ORDERMAP
        WHERE ctci_order = TRIM(V_TX2G.ORDER_NUMBER);
    end if;
    --Ly do tu choi
    Begin
        Select cdcontent  Into v_msgReject
        From allcode
        Where cdname = 'REJECT_REASON_CODE'
            and cdval =V_TX2G.reject_reason_code;
    Exception when OTHERS  then
        v_msgReject:=V_TX2G.reject_reason_code;
    End;

    If V_TX2G.msg_type='1I' then --Dat lenh thuong
        UPDATE OOD
        SET OODSTATUS = 'S',
            TXTIME    = TO_CHAR(SYSDATE, 'HH24:MI:SS'),
            SENTTIME  = SYSTIMESTAMP
        WHERE ORGORDERID = V_ORGORDERID
            and OODSTATUS <> 'S';
        Select remainqtty into v_qtty
        From odmast Where Orderid = V_ORGORDERID;


        CONFIRM_CANCEL_NORMAL_ORDER(V_ORGORDERID, v_qtty);
        Update odmast
        set
            EXECQTTY   = 0,
            ORSTATUS   = '6',--Bi tu choi boi so
            FEEDBACKMSG= v_msgReject
        Where Orderid = V_ORGORDERID;
     elsif V_TX2G.msg_type='1F' then --Thoa thuan cung cong ty (can huy lenh mua tuong ung)
        --Tim thong tin lenh mua doi ung
        select orderqtty, codeid, contrafirm, cf.custodycd, ptdeal
        into
        v_orderqtty,
        v_codeid,
        v_contrafirm,
        v_custodycd,
        v_ptdeal
        from odmast, cfmast cf
        where Orderid = V_ORGORDERID
        and odmast.custid = cf.custid;

        select orderid
        into v_RefOrderID
        from odmast
        where codeid = v_codeid
        and orderqtty = v_orderqtty
        and clientid = v_custodycd
        and contrafirm = (select sysvalue from ordersys where sysname='FIRM')
        and matchtype = 'P'
        and ptdeal =v_ptdeal ;

        CONFIRM_CANCEL_NORMAL_ORDER(v_RefOrderID,v_orderqtty);
        CONFIRM_CANCEL_NORMAL_ORDER(V_ORGORDERID,v_orderqtty);

        UPDATE OOD
        SET OODSTATUS = 'S',
        TXTIME    = TO_CHAR(SYSDATE, 'HH24:MI:SS'),
        SENTTIME  = SYSTIMESTAMP
        WHERE ORGORDERID in ( v_RefOrderID,V_ORGORDERID)
        and OODSTATUS <> 'S';

        Update odmast
        set
        EXECQTTY   = 0,
        ORSTATUS   = '6',
        FEEDBACKMSG= v_msgReject
        Where Orderid  in (v_RefOrderID,V_ORGORDERID);
    elsif V_TX2G.msg_type='1G' then --Thoa thuan khac cong ty
        --Tim thong tin lenh ban goc
        select orderqtty
        into
        v_orderqtty
        from odmast
        where Orderid = V_ORGORDERID
        and matchtype = 'P' ;

        CONFIRM_CANCEL_NORMAL_ORDER(V_ORGORDERID,v_orderqtty);

        UPDATE OOD
        SET OODSTATUS = 'S',
        TXTIME    = TO_CHAR(SYSDATE, 'HH24:MI:SS'),
        SENTTIME  = SYSTIMESTAMP
        WHERE ORGORDERID = V_ORGORDERID
        and OODSTATUS <> 'S';

        Update odmast
        set
        EXECQTTY   = 0,
        ORSTATUS   = '6',
        FEEDBACKMSG= v_msgReject
        Where Orderid  in (V_ORGORDERID);
        --end add
    elsIf v_tx2g.msg_type='1C'  then --Tu chooi huy lenh

        --Tim orderid lenh yeu cau huy : v_RefOrderID
        --Cap nhat trang thai lenh yeu cau huy /suu
        Select orderid  Into v_RefOrderID
        From odmast
        Where reforderid  = V_ORGORDERID
            and exectype in ('CS','CB','AB','AS')
            and ORSTATUS <>'6' ; --huy ban/mua

        UPDATE OOD
        SET OODSTATUS = 'S',
            TXTIME    = TO_CHAR(SYSDATE, 'HH24:MI:SS'),
            SENTTIME  = SYSTIMESTAMP
        WHERE ORGORDERID = v_RefOrderID
            and OODSTATUS <> 'S';

        Update odmast
        set
            EXECQTTY   = 0,
            MATCHAMT   = 0,
            Execamt    = 0,
            ORSTATUS   = '6',
            FEEDBACKMSG= v_msgReject
        Where Orderid = v_RefOrderID;
         --Xu ly cho phep dat lai lenh huy
        DELETE odchanging WHERE orderid =v_RefOrderID;

      update  fomast set status='R', feedbackmsg=v_msgReject
      WHERE orgacctno=v_RefOrderID;
    elsIf v_tx2g.msg_type='3C'  then --Tu choi huy lenh

        --Tim orderid lenh yeu cau huy : v_RefOrderID
        --Cap nhat trang thai lenh yeu cau huy /sua
        UPDATE CANCELORDERPTACK
        SET status='S' , isconfirm='Y'
        WHERE ordernumber= V_ORGORDERID
        AND SORR='S' AND MESSAGETYPE='3C'
        AND STATUS='S';

    End if;

    plog.setendsection (pkgctx, 'PRC_PROCESS2G');

EXCEPTION WHEN OTHERS THEN
    plog.error(pkgctx, SQLERRM || '--' || dbms_utility.format_error_backtrace);
    v_CheckProcess := FALSE;
    plog.error(pkgctx,'PRC_PROCESS2G V_TX2G.ORDER_NUMBER = '||V_TX2G.ORDER_NUMBER);
    plog.setendsection (pkgctx, 'PRC_PROCESS2G');
    rollback;
END PRC_PROCESS2G;

--PROCESS MSG 2I
Procedure PRC_PROCESS2I(V_MSGXML VARCHAR2) is
    V_TX2I   tx.msg_2I;
    V_Buy_ORGORDERID VARCHAR2(20);
    V_Sell_ORGORDERID VARCHAR2(20);

BEGIN
    plog.setbeginsection (pkgctx, 'PRC_PROCESS2I');

    V_TX2I:=fn_xml2obj_2I(V_MSGXML);
    -- Lay so hieu lenh goc truoc de trong TH chua update vao OrderMap
    -- do msg 2I ve qua' nhanh thi se bi exeption
    SELECT ORGORDERID
    INTO V_Buy_ORGORDERID
    FROM ORDERMAP
    WHERE ctci_order=TRIM(V_TX2I.order_number_buy);

    SELECT ORGORDERID
    INTO V_Sell_ORGORDERID
    FROM ORDERMAP
    WHERE ctci_order=TRIM(V_TX2I.order_number_sell);

    -- Cap nhat trang thai trong OOD
    UPDATE OOD SET
        OODSTATUS = 'S',
        TXTIME = TO_CHAR(SYSDATE,'HH24:MI:SS'),
        SENTTIME = SYSTIMESTAMP
    WHERE ORGORDERID = V_Buy_ORGORDERID and OODSTATUS <> 'S';

    UPDATE OOD SET
        OODSTATUS = 'S',
        TXTIME = TO_CHAR(SYSDATE,'HH24:MI:SS'),
        SENTTIME = SYSTIMESTAMP
    WHERE ORGORDERID = V_Sell_ORGORDERID and OODSTATUS <> 'S';

    --Goi thu thuc khop lenh voi lenh mua B
    MATCHING_NORMAL_ORDER (V_TX2I.firm,V_TX2I.order_number_buy,V_TX2I.order_entry_date_buy,
                            'B','',V_TX2I.volume,
                            V_TX2I.price, V_TX2I.confirm_number);

    --Goi thu thuc khop lenh voi lenh ban S
    MATCHING_NORMAL_ORDER (V_TX2I.firm,V_TX2I.order_number_sell,V_TX2I.order_entry_date_sell,
                            'S','',V_TX2I.volume,
                            V_TX2I.price, V_TX2I.confirm_number);
    plog.setendsection (pkgctx, 'PRC_PROCESS2I');
EXCEPTION WHEN OTHERS THEN
    plog.error(pkgctx, SQLERRM || '--' || dbms_utility.format_error_backtrace);
    v_CheckProcess := FALSE;
    plog.error(pkgctx,'PRC_PROCESS2I Khong tim so hieu lenh goc V_TX2I.order_number_buy: '||V_TX2I.order_number_buy);
    plog.error(pkgctx,'PRC_PROCESS2I Khong tim so hieu lenh goc V_TX2I.order_number_sell: '||V_TX2I.order_number_sell);
    plog.setendsection (pkgctx, 'PRC_PROCESS2I');
    rollback;
END;
--PROCESS MSG 2L
Procedure PRC_PROCESS2L(V_MSGXML VARCHAR2) is
    V_TX2L   tx.msg_2L;
    V_ORGORDERID VARCHAR2(20);
    v_strContraOrderId VARCHAR2(20);
    V_OneFirm Boolean;
    v_StrClientID Varchar2(20);
    v_strCUSTODYCD Varchar2(20);
    v_strBorS Varchar2(20);
    v_dblCTCI_order Varchar2(20);

   /* -- Cursor nay truoc day dat ten la C_TWOFIRM nhung sai ban chat nen doi ten lai thanh C_ONEFIRM
    CURSOR C_ONEFIRM(v_strORDERID Varchar2) IS
    SELECT OD.ORDERID ORDERID,od.CONTRAFIRM CONTRAFIRM,OD.TRADERID TRADERID,
        OD.CLIENTID CLIENTID,O1.CUSTODYCD CUSTODYCD,O1.BORS BORS,
        o2.orgorderid ContraOrderId
    FROM ORDERMAP MAP,ODMAST OD,OOD O1, OOD O2, odmast om2
    WHERE O1.ORGORDERID=OD.ORDERID AND TRIM(OD.CLIENTID) IS NOT NULL
        AND TRIM(OD.TRADERID) IS NOT NULL
        AND MAP.ORGORDERID=OD.orderid
        AND od.ORDERID=v_strORDERID
        and od.clientid = O2.custodycd
        and o1.bors <> o2.bors
        and o1.qtty = o2.qtty
        and o1.price = o2.price
        and o2.norp='P'
        and o2.oodstatus<>'S'
        and o2.Deltd <>'Y'
        and o2.orgorderid=om2.orderid
        and om2.exectype in ('NB','NS')
        and om2.remainqtty = o2.qtty;*/

    -- Check lenh onefirm bawng truong ptdeal
    CURSOR C_ONEFIRM(v_strORDERID Varchar2) IS
    SELECT OD.ORDERID ORDERID,od.CONTRAFIRM CONTRAFIRM,OD.TRADERID TRADERID,
        OD.CLIENTID CLIENTID,O1.CUSTODYCD CUSTODYCD,O1.BORS BORS,
        om2.orderid ContraOrderId
    FROM ORDERMAP MAP,ODMAST OD,OOD O1, odmast om2
    WHERE O1.ORGORDERID=OD.ORDERID
        AND TRIM(OD.CLIENTID) IS NOT NULL
        AND TRIM(OD.TRADERID) IS NOT NULL
        AND MAP.ORGORDERID=OD.orderid
        AND od.ORDERID=v_strORDERID
        and NVL(od.ptdeal,'XX') = NVL(om2.ptdeal,'YY')
        AND OD.EXECTYPE<>OM2.EXECTYPE
        AND OD.ORDERID<>OM2.ORDERID
        and om2.Deltd <>'Y'
        and od.matchtype = om2.matchtype
        and od.quoteprice = om2.quoteprice
        and od.orderqtty = om2.orderqtty;

    vc_ONEFIRM C_ONEFIRM%Rowtype;
    Cursor c_Ctci_Order(v_strORDERID Varchar2) is
    Select CTCI_ORDER
    From ORDERMAP
    WHERE Orgorderid=v_strORDERID;
    v_CTCI_order Varchar2(20);

BEGIN
    plog.setbeginsection (pkgctx, 'PRC_PROCESS2L');

    V_TX2L:=fn_xml2obj_2L(V_MSGXML);

    --XU LY MESSAGE 2L.
    --Neu la lenh thoa thuan mua:
    If V_TX2L.side ='B' Then
        Select ORDERID Into V_ORGORDERID
        from Odmast
        WHERE   ORSTATUS  not like '%4%'
            AND trim(CONFIRM_NO)=trim(V_TX2L.confirm_number)
            and txdate = getcurrdate;
        v_strBORS:='B';

    Else --Thoa thuan ban, hoac Onefirm: Deal_ID chinh la so hieu lenh cty gui len
        Select ORGORDERID ORDERID  Into V_ORGORDERID
        From ORDERMAP
        WHERE CTCI_ORDER=trim(V_TX2L.deal_id);
        v_strBORS:='S';
    End if;
    --Lay so hieu lenh CTCI:
    OPEN c_Ctci_Order(V_ORGORDERID);
    Fetch c_Ctci_Order into v_CTCI_order;
    Close c_Ctci_Order;

    --Kiem tra xem day la lenh one-firm or two-firm put-through order

    Open C_ONEFIRM(V_ORGORDERID);
    Fetch C_ONEFIRM into vc_ONEFIRM;
    If C_ONEFIRM%notfound then
      V_OneFirm := false;
    Else  --OneFirm
      V_OneFirm := true;
      v_StrClientID  :=vc_ONEFIRM.CLIENTID;
      v_strCUSTODYCD :=vc_ONEFIRM.CUSTODYCD;
      v_strBORS      :=vc_ONEFIRM.BORS;
      v_strContraOrderId :=vc_ONEFIRM.ContraOrderId;
    End if;
    Close C_ONEFIRM;

    UPDATE OOD SET
      OODSTATUS = 'S',
      TXTIME = TO_CHAR(SYSDATE,'HH24:MI:SS'),
      SENTTIME = SYSTIMESTAMP
    WHERE ORGORDERID = V_ORGORDERID and OODSTATUS <> 'S';

    --Khop lenh
    -- 1.1 Neu khop cung cong ty
    If V_OneFirm=True then
      plog.debug(pkgctx,'Khop lenh cung cong ty');
      --1.1.1 Khop lenh ban
            --Goi thu thuc khop lenh voi lenh ban S
      plog.debug(pkgctx,'Khop lenh ban '||V_TX2L.deal_id);
      MATCHING_NORMAL_ORDER (V_TX2L.firm,V_TX2L.deal_id,
                               '',
                               'S','',V_TX2L.volume,
                              V_TX2L.price, V_TX2L.confirm_number);

      If v_strContraOrderId is not null then
          --Lay so hieu lenh tu Ordermap de khop lenh.
          Select SEQ_ORDERMAP.NEXTVAL into v_dblCTCI_order from dual;
          INSERT INTO ORDERMAP(ctci_order,orgorderid)
          VALUES (v_dblCTCI_order ,v_strContraOrderId);

          UPDATE OOD SET
              OODSTATUS = 'S',
              TXTIME = TO_CHAR(SYSDATE,'HH24:MI:SS'),
              SENTTIME = SYSTIMESTAMP
            WHERE ORGORDERID = v_strContraOrderId and OODSTATUS <> 'S';

          plog.debug(pkgctx,'Khop lenh doi ung '||v_dblCTCI_order);
          --Thuc hien khop
          MATCHING_NORMAL_ORDER (V_TX2L.firm,v_dblCTCI_order,
                               '',
                               'B','',V_TX2L.volume,
                              V_TX2L.price, V_TX2L.confirm_number);
      End if;

    Else --Neu khop khac cong ty.
          plog.debug(pkgctx,'Khop lenh khac cong ty: '||v_CTCI_order);
          MATCHING_NORMAL_ORDER (V_TX2L.firm,v_CTCI_order,
                               '',
                              v_strBORS,'',V_TX2L.volume,
                              V_TX2L.price, V_TX2L.confirm_number);
    End if;

    plog.setendsection (pkgctx, 'PRC_PROCESS2L');

EXCEPTION WHEN OTHERS THEN
    plog.error(pkgctx, SQLERRM || '--' || dbms_utility.format_error_backtrace);
    v_CheckProcess := FALSE;
    plog.error(pkgctx,'PRC_PROCESS2L V_TX2L.confirm_number = '||V_TX2L.confirm_number);
    plog.error(pkgctx,'PRC_PROCESS2L V_TX2L.deal_id = '||V_TX2L.deal_id);
    plog.setendsection (pkgctx, 'PRC_PROCESS2L');
    rollback;
END PRC_PROCESS2L;

-- Process msg 3B
Procedure PRC_PROCESS3B(V_MSGXML VARCHAR2) is
    V_TX3b   tx.msg_3B;
    V_ORGORDERID VARCHAR2(20);
    p_err_param varchar2(30);
    p_err_code varchar2(30);
BEGIN
    plog.setbeginsection (pkgctx, 'PRC_PROCESS3B');
    plog.debug(pkgctx,'BEGIN PRC_PROCESS3b');
    V_TX3b:=fn_xml2obj_3B(V_MSGXML);

    V_ORGORDERID:=null;
    --XU LY MESSAGE 3B.
    BEGIN
        SELECT ORGORDERID INTO V_ORGORDERID
        FROM ORDERMAP WHERE ctci_order= TRIM(V_TX3b.deal_id);
    EXCEPTION WHEN OTHERS THEN
        -- Chi xay ra trong truong hop tu choi lenh mua cua doi tac, truong hop nay ko phai xu lu gi
        plog.error(pkgctx,'PRC_PROCESS3b'||'Khong tim so hieu lenh goc V_TX3b.deal_id: '||V_TX3b.deal_id);
    END;
    IF V_ORGORDERID is not null Then
        UPDATE OOD SET
        OODSTATUS = 'S',
        TXTIME = TO_CHAR(SYSDATE,'HH24:MI:SS'),
        SENTTIME = SYSTIMESTAMP
        WHERE ORGORDERID = V_ORGORDERID and oodstatus <> 'S';

        IF V_TX3b.reply_code in ('C','S') THEN  -- Doi tac tu choi mua hoac HOSE khong chap nhan
          Update odmast
          Set deltd ='Y', CANCELQTTY =ORDERQTTY,
               REMAINQTTY=0,EXECQTTY =0 ,MATCHAMT =0,Execamt =0, ORSTATUS = '2'
          Where MATCHTYPE ='P'  And Orderid = V_ORGORDERID;
          ----Ducnv + hailt
          Update ood set  deltd ='Y' where orgorderid = V_ORGORDERID;

          -- Xu ly cho lenh thoa thuan nhom BVS
          For vc in (Select orderid
                    From odmast
                    Where grporder='Y' and  orderid= V_ORGORDERID)
          Loop
              cspks_seproc.pr_executeod9996(V_ORGORDERID,p_err_code,p_err_param);
          End loop;
         ----End of Ducnv
        END IF;

        Insert into orderptack( messagetype, firm, side,        confirmnumber,
            status, issend,        ordernumber,        trading_date )
        Values ('3B',V_TX3b.firm,'S',V_TX3b.confirm_number,
            V_TX3b.reply_code,'S',V_ORGORDERID,trunc(sysdate));
    End if;

    plog.setendsection (pkgctx, 'PRC_PROCESS3B');

EXCEPTION WHEN OTHERS THEN
    plog.error(pkgctx, SQLERRM || '--' || dbms_utility.format_error_backtrace);
    v_CheckProcess := FALSE;
    plog.error(pkgctx,'PRC_PROCESS3B V_TX3b.deal_id = '||V_TX3b.deal_id);
    plog.setendsection (pkgctx, 'PRC_PROCESS3B');
    rollback;
END PRC_PROCESS3B;

--PROCESS MSG 3C
Procedure PRC_PROCESS3C(V_MSGXML VARCHAR2) is
    V_TX3C   tx.msg_3C;
    V_ORGORDERID VARCHAR2(20);
BEGIN
    plog.setbeginsection (pkgctx, 'PRC_PROCESS3C');

    V_TX3C:=fn_xml2obj_3C(V_MSGXML);

    --XU LY MESSAGE 3C.
    --1.1 Lay so hieu lenh
    INSERT INTO Cancelorderptack
              (sorr, TIMESTAMP, messagetype, firm, contrafirm, tradeid,
               side, securitysymbol, confirmnumber, status, isconfirm,
               ordernumber, brid, tlid, txtime, ipaddress, trading_date
              )
       VALUES ('R', to_char(sysdate,'hh24miss'), '', V_TX3C.firm, V_TX3C.contra_firm, V_TX3C.trader_id,
               V_TX3C.side, V_TX3C.security_symbol, V_TX3C.confirm_number, 'N', 'N',
               '', '', '', '', '', trunc(sysdate)
              );

    plog.setendsection (pkgctx, 'PRC_PROCESS3C');
EXCEPTION WHEN OTHERS THEN
    plog.error(pkgctx,'PRC_PROCESS3C '|| SQLERRM || '--' || dbms_utility.format_error_backtrace);
    v_CheckProcess := FALSE;
    plog.setendsection (pkgctx, 'PRC_PROCESS3C');
    rollback;
END PRC_PROCESS3C;


--PROCESS MSG 3D
Procedure PRC_PROCESS3D(V_MSGXML VARCHAR2) is
    V_TX3D   tx.msg_3D;
    V_ORGORDERID VARCHAR2(20);
    v_afaccount VARCHAR2(20);
    p_err_param varchar2(30);
    p_err_code varchar2(30);
BEGIN
    plog.setbeginsection (pkgctx, 'PRC_PROCESS3D');

    V_TX3D:=fn_xml2obj_3D(V_MSGXML);

    plog.debug (pkgctx, 'PRC_PROCESS3D Parse successful');

    --XU LY MESSAGE 3D.
    Insert into msg_3d(confirm_number,firm,reply_code)
       values(V_TX3D.CONFIRM_NUMBER ,V_TX3D.FIRM ,V_TX3D.REPLY_CODE);
    plog.debug (pkgctx, 'PRC_PROCESS3D Insert msg_3d successful');
    --Cap nhat trang thai

    If V_TX3D.REPLY_CODE = 'C' Then --Doi tac tu choi huy
      --THUC HIEN CAP NHAT YEU CAU HUY TRONG HE THONG KHONG THANH CONG
        UPDATE CANCELORDERPTACK
        SET STATUS='C', ISCONFIRM='Y'
        WHERE MESSAGETYPE='3C' AND SORR='S' AND CONFIRMNUMBER=V_TX3D.CONFIRM_NUMBER;
        plog.debug (pkgctx, 'PRC_PROCESS3D Update CONTRA DISAPPROVE successful');
    ElsIf V_TX3D.REPLY_CODE = 'S' Then --HOSE tu choi huy
      --THUC HIEN CAP NHAT YEU CAU HUY TRONG HE THONG KHONG THANH CONG
        UPDATE CANCELORDERPTACK
        SET STATUS='S', ISCONFIRM='Y'
        WHERE MESSAGETYPE='3C' AND SORR='S' AND CONFIRMNUMBER=V_TX3D.CONFIRM_NUMBER;
        plog.debug (pkgctx, 'PRC_PROCESS3D Update SYSTEM SET DISAPPROVE successful');
    ElsIf V_TX3D.REPLY_CODE = 'A' Then --DONG Y HUY
        --HUC HIEN CAP NHAT YEU CAU HUY TRONG HE THONG KHONG THANH CONG
        UPDATE CANCELORDERPTACK
        SET STATUS='A', ISCONFIRM='Y'
        WHERE MESSAGETYPE='3C' AND SORR='S' AND CONFIRMNUMBER=V_TX3D.CONFIRM_NUMBER;

        --Giai toa lenh thoa thuan da khop
        --Xu ly Odmast
        plog.debug (pkgctx, 'PRC_PROCESS3D Update CANCELORDERPTACK successful');

        For i in (Select orgorderid ,codeid,bors,matchprice,matchqtty,txnum,txdate ,custodycd
                    From iod
                    Where NorP ='P'
                    And trim(confirm_no) =trim(V_TX3D.CONFIRM_NUMBER))
        Loop

            Update odmast
            Set deltd ='Y', CANCELQTTY =ORDERQTTY,
                            REMAINQTTY=0,EXECQTTY =0 ,MATCHAMT =0,Execamt =0
            Where MATCHTYPE ='P'
                And Orderid = i.orgorderid;

            Update ood
            Set  deltd ='Y'
            Where orgorderid = i.orgorderid;

            Update stschd
            Set deltd = 'Y'
            Where  orgorderid = i.orgorderid;
            -- Xu ly cho lenh thoa thuan nhom BVS
            For vc in (Select orderid
                       From odmast
                       Where grporder='Y' and  orderid= i.orgorderid)
            Loop
                cspks_seproc.pr_executeod9996(i.orgorderid,p_err_code,p_err_param);
            End loop;


            If i.bors = 'B' then
                -- quyet.kieu : Them cho LINHLNB 21/02/2012
                -- Begin Danh sau tai san LINHLNB

                Select  afacctno into v_afaccount  from ODMAST   Where MATCHTYPE ='P' And Orderid = i.orgorderid;

                INSERT INTO odchanging_trigger_log (AFACCTNO,CODEID,AMT,TXNUM,TXDATE,ERRCODE,LAST_CHANGE,ORDERID,ACTIONFLAG, QTTY)
                VALUES( v_afaccount,i.codeid ,i.matchprice * i.matchqtty,i.txnum, i.txdate,NULL,systimestamp,i.orgorderid,'C', i.matchqtty);
                -- End Danh dau tai san LINHLNB
            End if ;
        End Loop;
        plog.debug (pkgctx, 'PRC_PROCESS3D Update odmast  successful');

        --Xu ly IOD
        Update iod
        Set Deltd ='Y'
        Where NorP ='P'
            And trim(confirm_no) =trim(V_TX3D.CONFIRM_NUMBER);
    End if; --V_TX3D.REPLY_CODE = 'A'

    plog.setendsection (pkgctx, 'PRC_PROCESS3D');

EXCEPTION WHEN OTHERS THEN
    plog.error(pkgctx,SQLERRM || '--' || dbms_utility.format_error_backtrace);
    plog.error(pkgctx,'PRC_PROCESS3D V_TX3D.CONFIRM_NUMBER = ' || V_TX3D.CONFIRM_NUMBER);
    v_CheckProcess := FALSE;
    plog.setendsection (pkgctx, 'PRC_PROCESS3D');
    rollback;
END PRC_PROCESS3D;


--PROCESS MSG 2D
Procedure PRC_PROCESS2D(V_MSGXML VARCHAR2) is
    V_TX2D   tx.msg_2D;
    V_ORGORDERID VARCHAR2(20);
    PV_ORDERID VARCHAR2(20);
BEGIN
    plog.setbeginsection (pkgctx, 'PRC_PROCESS2D');

    V_TX2D:=fn_xml2obj_2D(V_MSGXML);

    -- Cap nhat lai gia qua msg 2D de giai toa
    Select Orgorderid into PV_ORDERID
    From Ordermap
    Where ctci_order =V_TX2D.ordernumber;

    UPDATE ODMAST
    Set quoteprice = V_TX2D.price *1000
    WHERE ORDERID =PV_ORDERID;

    --XU LY MESSAGE 2D.
    -- CONFIRM_REPLACE_NORMAL_ORDER(V_TX2D.ordernumber,V_TX2D.price);

    plog.setendsection (pkgctx, 'PRC_PROCESS2D');

EXCEPTION WHEN OTHERS THEN
    plog.error(pkgctx,SQLERRM || '--' || dbms_utility.format_error_backtrace);
    plog.error(pkgctx,'PRC_PROCESS2D V_TX2D.ordernumber = ' || V_TX2D.ordernumber);
    v_CheckProcess := FALSE;
    plog.setendsection (pkgctx, 'PRC_PROCESS2D');
    rollback;
END PRC_PROCESS2D;



Procedure PRC_PROCESS2F(V_MSGXML VARCHAR2) is
    V_TX2F   tx.msg_2F;
    V_ORGORDERID VARCHAR2(20);
BEGIN
    plog.setbeginsection (pkgctx, 'PRC_PROCESS2F');

    V_TX2F:=fn_xml2obj_2F(V_MSGXML);

    --XU LY MESSAGE 2F.
    --1.1 Lay so hieu lenh
    INSERT INTO orderptack
          (TIMESTAMP, messagetype, firm, buyertradeid, side,
           sellercontrafirm, sellertradeid, securitysymbol, volume,
           price, board, confirmnumber, offset, status, issend,
           ordernumber, brid, tlid, txtime, ipaddress, trading_date,
           sclientid
          )
    VALUES (TO_CHAR(SYSDATE,'HH24MISS'), '', V_TX2F.firm_buy, V_TX2F.trader_id_buy, V_TX2F.side_b,
           V_TX2F.contra_firm_sell, V_TX2F.trader_id_contra_side_sell, trim(V_TX2F.security_symbol), V_TX2F.volume,
           V_TX2F.price, V_TX2F.board, TRIM(V_TX2F.confirm_number), '', 'N', 'N',
           '', '', '', '', '', TRUNC(SYSDATE),
           ''
          );

    plog.setendsection (pkgctx, 'PRC_PROCESS2F');

EXCEPTION WHEN OTHERS THEN
    plog.error(pkgctx,SQLERRM || '--' || dbms_utility.format_error_backtrace);
    plog.error(pkgctx,'PRC_PROCESS2F V_TX2F.confirm_number = ' || V_TX2F.confirm_number);
    v_CheckProcess := FALSE;
    plog.setendsection (pkgctx, 'PRC_PROCESS2F');
    rollback;
END PRC_PROCESS2F;


 --PROCESS MSG SU
Procedure PRC_PROCESSSU(V_MSGXML VARCHAR2) is
    V_TXSU   tx.msg_SU;
    V_ORGORDERID VARCHAR2(20);
    V_UpdatePrice Varchar2(10);
    v_Count Number(10);
    v_Halt  Varchar2(10);
    v_Security_Type Varchar2(10);
    v_strErrCode  Varchar2(20);
    v_strErrM Varchar2(200);
    l_CODEID    varchar2(100);
    v_odd_lot_halt  varchar2(2); --LoLeHSX

BEGIN
    plog.setbeginsection (pkgctx, 'PRC_PROCESSSU');

    V_TXSU:=fn_xml2obj_SU(V_MSGXML);


    --XU LY MESSAGE SU.

    SELECT count(1) Into v_Count
    FROM Ho_Sec_Info
    WHERE Floor_code ='10'
    And Stock_ID = Trim(V_TXSU.security_number_new);

    If V_TXSU.security_type ='S' Then
        v_Security_Type:=1; --COMMON_STOCK
    Elsif V_TXSU.security_type ='D' Then
        v_Security_Type:=2; --DEBENTURE
    Elsif V_TXSU.security_type in ('U','E') Then
        v_Security_Type:=3; --UNIT_TRUST
    --Ngay 07/03/2017 CW NamTv add them loai CK la chung quyen
    Elsif V_TXSU.security_type ='W' Then
     v_Security_Type:=4; --Covered Warrant
    --End NamTV
    End if;

    --Kiem tra trong bang HO_SEC_INFO,SECURITIES_INFO, SBSECURITIES,
    --Neu co roi thi Update, chua co thi Insert bang HO_SEC_INFO
    If v_Count >0 Then
        UPDATE Ho_Sec_info
        SET        Time  =  to_char(sysdate,'hh24miss'),
            halt_resume_flag =   V_TXSU.HALT_RESUME_FLAG,
            ceiling_price =      V_TXSU.CEILING_PRICE ,
            floor_price =        V_TXSU.FLOOR_PRICE ,
            basic_price =        V_TXSU.PRIOR_CLOSE_PRICE ,
            prior_close_price =  V_TXSU.PRIOR_CLOSE_PRICE ,
            lowest_price =       V_TXSU.LOWEST_PRICE ,
            highest_price =      V_TXSU.HIGHEST_PRICE ,
            match_price =        V_TXSU.LAST_SALE_PRICE ,
            open_price =         V_TXSU.OPEN_PRICE ,
            suspension =         V_TXSU.SUSPENSION,
            delist =             V_TXSU.DELIST,
             /*--Ngay 07/03/2017 CW NamTV cap nhat thong tin chung quyen*/
             underlyingsymbol = V_TXSU.UNDERLYINGSYMBOL, /*Ma CK co so*/
             issuername       = V_TXSU.ISSUERNAME,   /*Ten TCPH CKSC*/
             coveredwarranttype  = V_TXSU.COVEREDWARRANTTYPE,   /*Loai chung quyen*/
             maturitydate        = V_TXSU.MATURITYDATE,   /*Ngay het han chung quyen*/
             lasttradingdate     = V_TXSU.LASTTRADINGDATE,   /*Ngay giao dich cuoi cung*/
             exerciseprice      = V_TXSU.EXERCISEPRICE,   /*Gia thuc hien*/
             exerciseratio       = V_TXSU.EXERCISERATIO,    /*Ty le thuc hien*/
             /*--NamTV End*/
            security_number_new= v_txsu.security_number_new,
            security_number_old= v_txsu.security_number_old,
            code = trim(V_TXSU.SECURITY_SYMBOL),
            ODD_LOT_HALT_RESUME_FLAG = V_TXSU.odd_lot_halt_resume_flag --LoLeHSX
        Where FLOOR_CODE ='10'
            and STOCK_ID =  V_TXSU.security_number_new;
    Else
          INSERT INTO Ho_sec_info
             (floor_code, date_no, trading_date, TIME, stock_id, code,
             stock_type, trading_unit,
             highest_price, lowest_price, ceiling_price,
             floor_price,
             prior_close_price, PARVALUE ,
             halt_resume_flag , DELIST, SUSPENSION,
             /*--Ngay 07/03/2017 CW NamTV cap nhat thong tin chung quyen*/
             underlyingsymbol, issuername, coveredwarranttype, maturitydate,
             lasttradingdate, exerciseprice, exerciseratio,
             /*--End NamTV*/
             security_number_new,security_number_old,
             ODD_LOT_HALT_RESUME_FLAG) --LoLeHSX
             VALUES ('10', '10',
             trunc(sysdate), to_char(sysdate,'hh24miss'), trim(V_TXSU.SECURITY_NUMBER_NEW) , trim(V_TXSU.SECURITY_SYMBOL),
             v_Security_Type, V_TXSU.BOARD_LOT ,
             V_TXSU.HIGHEST_PRICE , V_TXSU.LOWEST_PRICE , V_TXSU.CEILING_PRICE,
             V_TXSU.FLOOR_PRICE,
             V_TXSU.PRIOR_CLOSE_PRICE, V_TXSU.PAR_VALUE ,
             V_TXSU.HALT_RESUME_FLAG, V_TXSU.DELIST, V_TXSU.SUSPENSION,
             /*--Ngay 07/03/2017 CW NamTV cap nhat thong tin chung quyen*/
             V_TXSU.UNDERLYINGSYMBOL, V_TXSU.ISSUERNAME, V_TXSU.COVEREDWARRANTTYPE, V_TXSU.MATURITYDATE,
             V_TXSU.LASTTRADINGDATE, V_TXSU.EXERCISEPRICE,  V_TXSU.EXERCISERATIO,
             /*--End NamTV*/
             v_txsu.security_number_new, v_txsu.security_number_old,
             V_TXSU.odd_lot_halt_resume_flag --LoLeHSX
             );

    End if;

    --Cap nhat thong tin HALT vao BO.
    If V_TXSU.HALT_RESUME_FLAG in ('H')  or V_TXSU.suspension ='S' or V_TXSU.delist ='D' Then
        v_Halt:='Y';
    Else
        v_Halt:='N';
    End if;
    --LoLeHSX Cap nhat thong tin halt lo le
    If V_TXSU.odd_lot_halt_resume_flag in ('H') Then
      v_odd_lot_halt := 'Y';
    Else
      v_odd_lot_halt := 'N';
    End if;
    --End LoLeHSX

    UPDATE SBSECURITIES
    SET HALT =  v_Halt,
        odd_lot_halt = v_odd_lot_halt --LoLeHSX
    WHERE SYMBOL=TRIM(V_TXSU.security_symbol);
    COMMIT;

    --Ngay 07/04/2017 CW NamTv cap nhat thong tin listedshare
    IF  v_Security_Type=4 THEN
      BEGIN
        UPDATE SECURITIES_INFO SET LISTINGQTTY=V_TXSU.LISTEDSHARE
            WHERE SYMBOL=TRIM(V_TXSU.security_symbol);

        UPDATE SBSECURITIES SET
            /*--Ngay 07/03/2017 CW NamTV cap nhat thong tin chung quyen*/
            underlyingsymbol = V_TXSU.UNDERLYINGSYMBOL, /*Ma CK co so*/
            issuername       = V_TXSU.ISSUERNAME,   /*Ten TCPH CKSC*/
            coveredwarranttype  = V_TXSU.COVEREDWARRANTTYPE,   /*Loai chung quyen*/
            maturitydate        = to_date(to_date(V_TXSU.MATURITYDATE,'RRRR/MM/DD'),'DD/MM/RRRR'),  /*Ngay het han chung quyen*/
            lasttradingdate     = to_date(to_date(V_TXSU.LASTTRADINGDATE,'RRRR/MM/DD'),'DD/MM/RRRR'),   /*Ngay giao dich cuoi cung*/
            exerciseprice      = TO_NUMBER(V_TXSU.EXERCISEPRICE) * 0.1,   /*Gia thuc hien*/
            exerciseratio       = to_char(TO_NUMBER(SUBSTR(V_TXSU.EXERCISERATIO,0,INSTR(V_TXSU.EXERCISERATIO,':') - 1)) * 10000) || '/' ||
                        to_char(TO_NUMBER(SUBSTR(V_TXSU.EXERCISERATIO,INSTR(V_TXSU.EXERCISERATIO,':')+1,LENGTH(V_TXSU.EXERCISERATIO))*10000)) /*Ty le thuc hien*/
            /*--NamTV End*/
            WHERE SYMBOL=TRIM(V_TXSU.security_symbol);
      EXCEPTION WHEN OTHERS THEN
           NULL;
      END;
        commit;
    END IF;
    --NamTv End

    --Cap nhat thong tin co phieu moi
    cspks_odproc.Pr_Update_SecInfo(TRIM(V_TXSU.security_symbol),nvl(V_TXSU.CEILING_PRICE*10,0),nvl(V_TXSU.FLOOR_PRICE*10,0),nvl(V_TXSU.PRIOR_CLOSE_PRICE*10,0),'001',v_Halt,v_strErrCode);
     commit;
    --Cap nhat thong tin ticksize
      select codeid into l_CODEID from securities_info where SYMBOL =TRIM(V_TXSU.security_symbol);
      DELETE FROM securities_ticksize WHERE codeid=l_CODEID;
      If V_TXSU.security_type in ('U','S') THEN --Co phieu, chung chi quy dong
                 INSERT INTO SECURITIES_TICKSIZE (AUTOID, CODEID, SYMBOL, TICKSIZE, FROMPRICE, TOPRICE, STATUS)
                 VALUES (SEQ_SECURITIES_TICKSIZE.NEXTVAL, l_CODEID, TRIM(V_TXSU.security_symbol), 10, 0, 9999, 'Y');

                 INSERT INTO SECURITIES_TICKSIZE (AUTOID, CODEID, SYMBOL, TICKSIZE, FROMPRICE, TOPRICE, STATUS)
                 VALUES (SEQ_SECURITIES_TICKSIZE.NEXTVAL, l_CODEID, TRIM(V_TXSU.security_symbol), 50, 10000, 49999, 'Y');

                 INSERT INTO SECURITIES_TICKSIZE (AUTOID, CODEID, SYMBOL, TICKSIZE, FROMPRICE, TOPRICE, STATUS)
                 VALUES (SEQ_SECURITIES_TICKSIZE.NEXTVAL, l_CODEID, TRIM(V_TXSU.security_symbol), 100, 50000, 100000000, 'Y');
      Elsif V_TXSU.security_type ='D' Then
                 INSERT INTO SECURITIES_TICKSIZE (AUTOID, CODEID, SYMBOL, TICKSIZE, FROMPRICE, TOPRICE, STATUS)
                 VALUES (SEQ_SECURITIES_TICKSIZE.NEXTVAL, l_CODEID, TRIM(V_TXSU.security_symbol), 1, 0, 100000000, 'Y');
      Elsif V_TXSU.security_type in ('E') Then
                 INSERT INTO SECURITIES_TICKSIZE (AUTOID, CODEID, SYMBOL, TICKSIZE, FROMPRICE, TOPRICE, STATUS)
                 VALUES (SEQ_SECURITIES_TICKSIZE.NEXTVAL, l_CODEID, TRIM(V_TXSU.security_symbol), 10, 0, 100000000, 'Y');
      Elsif V_TXSU.security_type in ('W') Then
                 INSERT INTO SECURITIES_TICKSIZE (AUTOID, CODEID, SYMBOL, TICKSIZE, FROMPRICE, TOPRICE, STATUS)
                 VALUES (SEQ_SECURITIES_TICKSIZE.NEXTVAL, l_CODEID, TRIM(V_TXSU.security_symbol), 10, 0, 100000000, 'Y');

      End if;
      commit;
      --End cap nhat thong tin ticksize
     -- Cap nhat gia cuoi ngay
    Pr_updatepricefromgw(TRIM(V_TXSU.security_symbol), nvl(V_TXSU.LAST_SALE_PRICE *10,0),nvl(V_TXSU.FLOOR_PRICE *10,0) ,nvl(V_TXSU.CEILING_PRICE *10,0),'CN',v_strErrCode,v_strErrM);

    plog.setendsection (pkgctx, 'PRC_PROCESSSU');
EXCEPTION WHEN OTHERS THEN
    plog.error(pkgctx,SQLERRM || '--' || dbms_utility.format_error_backtrace);
    plog.error(pkgctx,'PRC_PROCESSSU V_TXSU.SECURITY_SYMBOL = ' || V_TXSU.SECURITY_SYMBOL);
    v_CheckProcess := FALSE;
    plog.setendsection (pkgctx, 'PRC_PROCESSSU');
    rollback;
END PRC_PROCESSSU;



 --PROCESS MSG SS
Procedure PRC_PROCESSSS(V_MSGXML VARCHAR2) is
    V_TXSS   tx.msg_SS;
    V_ORGORDERID VARCHAR2(20);
    v_Security_Type Varchar2(10);
    v_Halt  Varchar2(10);
    V_UpdatePrice  Varchar2(10);
    v_Symbol  Varchar2(20);
    v_strCodeID Varchar2(10);
    v_strErrCode Varchar2(20);
    v_strErrM Varchar2(200);
    v_odd_lot_halt  varchar2(2); --LoLeHSX
BEGIN
    plog.setbeginsection (pkgctx, 'PRC_PROCESSSS');

    V_TXSS:=fn_xml2obj_SS(V_MSGXML);

    If V_TXSS.security_type ='S' Then
        v_Security_Type:=1; --COMMON_STOCK
    Elsif V_TXSS.security_type ='D' Then
        v_Security_Type:=2; --DEBENTURE
    Elsif V_TXSS.security_type in ('U','E') Then
        v_Security_Type:=3; --UNIT_TRUST
    /*--Ngay 07/03/2017 CW NamTv add them loai CK la chung quyen*/
    Elsif V_TXSS.security_type ='W' Then
     v_Security_Type:=4; /*--Covered Warrant*/
    /*--End NamTV*/
    End if;

    --XU LY MESSAGE SS.

    UPDATE HO_sec_info
    SET  ceiling_price = V_TXSS.CEILING,
        floor_price =       V_TXSS.FLOOR_PRICE,
        halt_resume_flag =  V_TXSS.HALT_RESUME_FLAG,
        delist =            V_TXSS.DELIST,
        suspension =        V_TXSS.SUSPENSION,
        prior_close_price = V_TXSS.PRIOR_CLOSE_PRICE,
        --Ngay 07/03/2017 CW NamTV cap nhat thong tin chung quyen
        underlyingsymbol = V_TXSS.UNDERLYINGSYMBOL, /*Ma CK co so*/
        issuername       = V_TXSS.ISSUERNAME,   /*Ten TCPH CKSC*/
        coveredwarranttype  = V_TXSS.COVEREDWARRANTTYPE,   /*Loai chung quyen*/
        maturitydate        = V_TXSS.MATURITYDATE,   /*Ngay het han chung quyen*/
        lasttradingdate     = V_TXSS.LASTTRADINGDATE,   /*Ngay giao dich cuoi cung*/
        exerciseprice      = V_TXSS.EXERCISEPRICE,   /*Gia thuc hien*/
        exerciseratio       = V_TXSS.EXERCISERATIO,    /*Ty le thuc hien*/
        /*--NamTV End*/
        ODD_LOT_HALT_RESUME_FLAG = V_TXSS.odd_lot_halt_resume_flag --LoLeHSX
    Where FLOOR_CODE ='10' and STOCK_ID =  V_TXSS.security_number;

    commit;
    --Cap nhat thong tin HALT vao BO.
    If nvl(V_TXSS.halt_resume_flag,'-') in ('H')  or nvl(V_TXSS.suspension,'-') ='S'  or nvl(V_TXSS.delist,'-') ='D' Then
        v_Halt:='Y';
    Else
        v_Halt:='N';
    End if;

    --LoLeHSX Cap nhat thong tin halt lo le
    If V_TXSS.odd_lot_halt_resume_flag in ('H') Then
      v_odd_lot_halt := 'Y';
    Else
      v_odd_lot_halt := 'N';
    End if;
    --End LoLeHSX

    v_strCodeID:='xxxx';
    v_Symbol:='yyyy';
    For Vc in(SELECT s.symbol,s.codeid
              From HO_SEC_INFO H, Securities_info S
              Where H.code=S.symbol
                And H.STOCK_ID = TRIM(V_TXSS.security_number)
              )
    Loop
        v_strCodeID:=vc.codeid;
        v_Symbol:=vc.symbol;
    End loop;

    UPDATE SBSECURITIES
        SET HALT = v_Halt,
            odd_lot_halt = v_odd_lot_halt --LoLeHSX
       WHERE codeid=v_strCodeID;
    Commit;

    --Ngay 07/04/2017 CW NamTv cap nhat thong tin listedshare
    IF  v_Security_Type=4 THEN
      BEGIN
        UPDATE SECURITIES_INFO SET LISTINGQTTY=V_TXSS.LISTEDSHARE
            WHERE codeid=v_strCodeID;

        UPDATE SBSECURITIES SET
            /*--Ngay 07/03/2017 CW NamTV cap nhat thong tin chung quyen*/
            underlyingsymbol = V_TXSS.UNDERLYINGSYMBOL, /*Ma CK co so*/
            issuername       = V_TXSS.ISSUERNAME,   /*Ten TCPH CKSC*/
            coveredwarranttype  = V_TXSS.COVEREDWARRANTTYPE,   /*Loai chung quyen*/
            maturitydate        = to_date(to_date(V_TXSS.MATURITYDATE,'RRRR/MM/DD'),'DD/MM/RRRR'),  /*Ngay het han chung quyen*/
            lasttradingdate     = to_date(to_date(V_TXSS.LASTTRADINGDATE,'RRRR/MM/DD'),'DD/MM/RRRR'),   /*Ngay giao dich cuoi cung*/
            exerciseprice      = TO_NUMBER(V_TXSS.EXERCISEPRICE) * 0.1,   /*Gia thuc hien*/
            exerciseratio       = to_char(TO_NUMBER(SUBSTR(V_TXSS.EXERCISERATIO,0,INSTR(V_TXSS.EXERCISERATIO,':') - 1))*10000) || '/' ||
                        to_char(TO_NUMBER(SUBSTR(V_TXSS.EXERCISERATIO,INSTR(V_TXSS.EXERCISERATIO,':')+1,LENGTH(V_TXSS.EXERCISERATIO))*10000)) /*Ty le thuc hien*/
            /*--NamTV End*/
            WHERE codeid=v_strCodeID;
        commit;
      EXCEPTION WHEN OTHERS THEN
           NULL;
      END;
    END IF;

    -- Cap nhat gia dau ngay
    Pr_updatepricefromgw(v_Symbol, nvl(V_TXSS.PRIOR_CLOSE_PRICE * 10,0), nvl(V_TXSS.FLOOR_PRICE *10,0) ,nvl(V_TXSS.CEILING *10,0),'DN',v_strErrCode,v_strErrM);
    --phuongnt add
    --case chuyen san, moi niem yet,giai toa lenh ko sai
   Cspks_odproc.Pr_Update_SecInfo(v_Symbol,nvl(V_TXSS.CEILING*10,0),nvl(V_TXSS.FLOOR_PRICE*10,0),nvl(V_TXSS.PRIOR_CLOSE_PRICE*10,0),'001',v_Halt,v_strErrCode,
        V_TXSS.odd_lot_halt_resume_flag --LoLeHSX
   );
    plog.setendsection (pkgctx, 'PRC_PROCESSSS');

EXCEPTION WHEN OTHERS THEN
    plog.error(pkgctx,SQLERRM || '--' || dbms_utility.format_error_backtrace);
    plog.error(pkgctx,'PRC_PROCESSSS V_TXSS.security_number = ' || V_TXSS.security_number);
    v_CheckProcess := FALSE;
    plog.setendsection (pkgctx, 'PRC_PROCESSSS');
    rollback;
END PRC_PROCESSSS;



  --PROCESS MSG SC
Procedure PRC_PROCESSSC(V_MSGXML VARCHAR2,V_MSG_DATE VARCHAR2) is
    V_TXSC   tx.msg_SC;
    V_ORGORDERID VARCHAR2(20);
    v_Controlcode VARCHAR2(20);
    V_DELTA_TIME number;
    l_timemsg       VARCHAR2(10);
    l_timeordersys  VARCHAR2(10);
    l_delta_time      INTEGER;
    l_TIMESTAMPO  VARCHAR2(20);
    p_err_code  VARCHAR2(300);
     p_err_message  VARCHAR2(300);
BEGIN
    plog.setbeginsection (pkgctx, 'PRC_PROCESSSC');

    V_TXSC:=fn_xml2obj_SC(V_MSGXML);

    --XU LY MESSAGE SC.

    BEGIN
        SELECT SYSVALUE INTO V_CONTROLCODE
        FROM  ORDERSYS
        WHERE SYSNAME='CONTROLCODE';
    EXCEPTION WHEN OTHERS THEN
        V_CONTROLCODE:='';
    END;
--ThangPV chinh sua lo le HSX 27-04-2022
--    IF V_CONTROLCODE ='O' AND V_TXSC.SYSTEM_CONTROL_CODE ='F' THEN
 --     NULL;
 --   ELSE
    IF V_TXSC.system_control_code IN ('E','L','M','S') THEN
      IF V_TXSC.system_control_code IN ('E','M') THEN
        UPDATE ORDERSYS SET SYSVALUE='E' WHERE SYSNAME='CONTROLCODE_ODD_LOT';
      ELSE
        UPDATE ORDERSYS SET SYSVALUE=V_TXSC.SYSTEM_CONTROL_CODE WHERE SYSNAME='CONTROLCODE_ODD_LOT';
      END IF;
    ELSE
    IF V_CONTROLCODE ='O' AND V_TXSC.SYSTEM_CONTROL_CODE ='F' THEN
        NULL;
      ELSE  --End ThangPV chinh sua lo le HSX 27-04-2022
        UPDATE ORDERSYS
        SET SYSVALUE=V_TXSC.SYSTEM_CONTROL_CODE
        WHERE SYSNAME='CONTROLCODE';

        UPDATE ORDERSYS
        SET SYSVALUE= LPAD(V_TXSC.TIMESTAMP,6,'0')
        WHERE SYSNAME='TIMESTAMP';
        COMMIT;
         --phuongntn tinh thoi gian chenh lech HO-Flex, cap nhat odersys
         l_timemsg:=NVL(V_MSG_DATE,TO_CHAR(SYSDATE,'HH24MISS'));
         l_timeordersys:=LPAD(V_TXSC.TIMESTAMP,6,'0');
         l_delta_time:=TO_NUMBER(SUBSTR(l_timeordersys,1,2)) * 3600
                    + TO_NUMBER(SUBSTR(l_timeordersys,3,2)) * 60
                    + TO_NUMBER(SUBSTR(l_timeordersys,5,2))
                - (
                    TO_NUMBER(SUBSTR(l_timemsg,1,2)) * 3600
                        + TO_NUMBER(SUBSTR(l_timemsg,3,2)) * 60
                        + TO_NUMBER(SUBSTR(l_timemsg,5,2))
                    );

          UPDATE ORDERSYS SET SYSVALUE= tO_CHAR(l_delta_time) WHERE SYSNAME='DELTATIME';
        --phuongntn end
        If V_TXSC.SYSTEM_CONTROL_CODE ='O' then
              --phuongntn edit tho gio cua So lenh MP
              Begin
                  l_TIMESTAMPO:=to_char(to_date(LPAD(V_TXSC.TIMESTAMP,6,'0'),'hh24miss' )+ 10/3600/24,'hh24miss');
                  UPDATE ORDERSYS SET SYSVALUE= l_TIMESTAMPO WHERE SYSNAME='TIMESTAMPO';
              EXCEPTION WHEN OTHERS THEN
                  UPDATE ORDERSYS SET SYSVALUE= to_char(sysdate + 10/3600/24,'hh24miss') WHERE SYSNAME='TIMESTAMPO';
                  plog.error(pkgctx,SQLERRM || '--' || dbms_utility.format_error_backtrace);
              End;
              --end edit
              --ThangPV chinh sua lo le HSX 27-04-2022
              --VCBSDEPII-1159    1.0.2.11
              For vc in ( select od.orderid , od.afacctno, od.orderqtty
                      from odmast od , ood , sbsecurities s
                      where od.orderid = ood.orgorderid
                           and od.txdate = getcurrdate
                           and od.deltd <> 'Y'
                          and ood.oodstatus IN ('N','B')
                          and od.pricetype ='ATO'
                          and s.codeid = od.codeid
                          and s.tradeplace= '001')
              LOOP
                  CONFIRM_CANCEL_NORMAL_ORDER(vc.orderid, vc.orderqtty);
              End loop;
              --End ThangPV chinh sua lo le HSX 27-04-2022
        End if ;
         -- DUCNV sinh lenh huy cho lenh RP khi vao phien ATC
        If V_TXSC.SYSTEM_CONTROL_CODE ='A' then
            For vc in (Select
                       f.username,
                       o.orderid acctno,
                       f.afacctno,
                       f.exectype ,
                       f.symbol,
                       f.remainqtty quantity,
                       f.quoteprice,
                       f.pricetype,
                       f.timetype,
                       f.book,
                       f.via,
                      '' dealid,
                       f.direct,
                       f.effdate,
                       f.expdate,
                       f.tlid,
                       f.quoteqtty,
                       f.limitprice
                        From odmast o, fomast f, rootordermap R, sbsecurities s
                        Where
                               o.pricetype='LO'
                              and o.remainqtty>0
                              and o.orderid = r.orderid
                              and r.foacctno=f.acctno
                              and f.pricetype='RP'
                              and o.codeid=s.codeid
                              and s.tradeplace='001')
            LOOP

               fopks_api.pr_PlaceOrder('CANCELORDER',
                        vc.username,
                        vc.acctno ,
                        vc.afacctno ,
                        vc.exectype  ,
                        vc.symbol  ,
                        vc.quantity  ,
                        vc.quoteprice  ,
                        vc.pricetype ,
                        vc.timetype ,
                        vc.book ,
                        vc.via ,
                        vc.dealid ,
                        vc.direct ,
                        vc.effdate ,
                        vc.expdate ,
                        vc.tlid  ,
                        vc.quoteqtty ,
                        vc.limitprice ,
                        p_err_code ,
                        p_err_message
                        );
                 Insert into logrporder(txdate,orderid) values(getcurrdate,vc.acctno);
            End loop;

        End if;
        -- End of DUCNV ----------------
    End IF;
    END IF;

    plog.setendsection (pkgctx, 'PRC_PROCESSSC');

EXCEPTION WHEN OTHERS THEN
    plog.error(pkgctx,SQLERRM || '--' || dbms_utility.format_error_backtrace);
    plog.error(pkgctx,'PRC_PROCESSSC V_TXSC.SYSTEM_CONTROL_CODE = ' || V_TXSC.SYSTEM_CONTROL_CODE);
    v_CheckProcess := FALSE;
    plog.setendsection (pkgctx, 'PRC_PROCESSSC');
    rollback;
END PRC_PROCESSSC;

--PROCESS MSG TS
Procedure PRC_PROCESSTS(V_MSGXML VARCHAR2,V_MSG_DATE VARCHAR2) is
    V_TXTS   tx.msg_TS;
    V_ORGORDERID VARCHAR2(20);
    V_DELTA_TIME number;
    l_timemsg       VARCHAR2(10);
    l_timeordersys  VARCHAR2(10);
    l_delta_time      INTEGER;
BEGIN
    plog.setbeginsection (pkgctx, 'PRC_PROCESSTS');

    V_TXTS:=fn_xml2obj_TS(V_MSGXML);

    --XU LY MESSAGE TS.

    UPDATE ORDERSYS
    SET SYSVALUE= Lpad(V_TXTS.timestamp,6,'0')
    WHERE SYSNAME='TIMESTAMP';
   --phuongntn tinh thoi gian chenh lech HO-Flex, cap nhat odersys
         l_timemsg:=NVL(V_MSG_DATE,TO_CHAR(SYSDATE,'HH24MISS'));
         l_timeordersys:= Lpad(V_TXTS.timestamp,6,'0');
         l_delta_time:=TO_NUMBER(SUBSTR(l_timeordersys,1,2)) * 3600
                    + TO_NUMBER(SUBSTR(l_timeordersys,3,2)) * 60
                    + TO_NUMBER(SUBSTR(l_timeordersys,5,2))
                - (
                    TO_NUMBER(SUBSTR(l_timemsg,1,2)) * 3600
                        + TO_NUMBER(SUBSTR(l_timemsg,3,2)) * 60
                        + TO_NUMBER(SUBSTR(l_timemsg,5,2))
                    );
   UPDATE ORDERSYS SET SYSVALUE= tO_CHAR(l_delta_time) WHERE SYSNAME='DELTATIME';

    --phuongntn end
    plog.setendsection (pkgctx, 'PRC_PROCESSTS');

EXCEPTION WHEN OTHERS THEN
    plog.error(pkgctx,SQLERRM || '--' || dbms_utility.format_error_backtrace);
    plog.error(pkgctx,'PRC_PROCESSTS V_TXTS.timestamp= ' || V_TXTS.timestamp);
    v_CheckProcess := FALSE;
    plog.setendsection (pkgctx, 'PRC_PROCESSTS');
    rollback;
END PRC_PROCESSTS;


  --PROCESS MSG TC
Procedure PRC_PROCESSTC(V_MSGXML VARCHAR2) is
    V_TXTC   tx.msg_TC;
    V_ORGORDERID VARCHAR2(20);
    v_Count Number(10);
BEGIN
    plog.setbeginsection (pkgctx, 'PRC_PROCESSTC');

    V_TXTC:=fn_xml2obj_TC(V_MSGXML);

    --XU LY MESSAGE TC.
    SELECT COUNT(1) Into v_Count
    FROM TRADERID
    WHERE TO_NUMBER(TRADERID) = TO_NUMBER(TRIM(V_TXTC.TRADER_ID))
        and to_number(firm)=to_number(TRIM(V_TXTC.firm));
    --Neu co thi Update, chua co thi Insert
    If v_Count >0 Then
        UPDATE TRADERID
        SET STATUS = TRIM(V_TXTC.TRADER_STATUS),
            TRADING_DATE = SYSDATE
        WHERE  TO_NUMBER(TRADERID) = TO_NUMBER(TRIM(V_TXTC.TRADER_ID))
        and to_number(firm)=to_number(TRIM(V_TXTC.firm));
    Else
        INSERT INTO TRADERID(FIRM, TRADERID,STATUS,TRADING_DATE)
        VALUES(TRIM(V_TXTC.FIRM), TRIM(V_TXTC.TRADER_ID),TRIM(V_TXTC.TRADER_STATUS),SYSDATE);
    End if;

    plog.setendsection (pkgctx, 'PRC_PROCESSTC');
EXCEPTION WHEN OTHERS THEN
    plog.error(pkgctx,SQLERRM || '--' || dbms_utility.format_error_backtrace);
    plog.error(pkgctx,'PRC_PROCESSTC V_TXTC.TRADER_ID = ' ||V_TXTC.TRADER_ID);
    v_CheckProcess := FALSE;
    plog.setendsection (pkgctx, 'PRC_PROCESSTC');
    rollback;
END PRC_PROCESSTC;

  --PROCESS MSG BS
Procedure PRC_PROCESSBS(V_MSGXML VARCHAR2) is
    V_TXBS   tx.msg_BS;

BEGIN
    plog.setbeginsection (pkgctx, 'PRC_PROCESSBS');
    V_TXBS:=fn_xml2obj_BS(V_MSGXML);

    --XU LY MESSAGE BS.
    UPDATE TRADERID
    SET AUTOMATCH_HALT = TRIM(V_TXBS.AUTOMATCH_HALT_FLAG)
        , PUTTHROUGH_HALT = TRIM(V_TXBS.PUT_THROUGH_HALT_FLAG)
        , TRADING_DATE = SYSDATE
    WHERE  TO_NUMBER(TRIM(V_TXBS.FIRM))= TO_NUMBER(FIRM) ;

    plog.setendsection (pkgctx, 'PRC_PROCESSBS');

EXCEPTION WHEN OTHERS THEN
    plog.error(pkgctx,SQLERRM || '--' || dbms_utility.format_error_backtrace);
    plog.error(pkgctx,'PRC_PROCESSBS V_TXBS.FIRM = ' ||V_TXBS.FIRM);
    v_CheckProcess := FALSE;
    plog.setendsection (pkgctx, 'PRC_PROCESSBS');
    rollback;
END PRC_PROCESSBS;

  --PROCESS MSG TR
Procedure PRC_PROCESSTR(V_MSGXML VARCHAR2) is
    V_TXTR   tx.msg_TR;
    V_ORGORDERID VARCHAR2(20);
BEGIN
    plog.setbeginsection (pkgctx, 'PRC_PROCESSTR');

    V_TXTR:=fn_xml2obj_TR(V_MSGXML);

    --XU LY MESSAGE TR.
    UPDATE HO_SEC_INFO
    SET TRADING_DATE=trunc(SYSDATE), CURRENT_ROOM=V_TXTR.current_room,
      TOTAL_ROOM =V_TXTR.total_room
    WHERE FLOOR_CODE ='10' And STOCK_ID= V_TXTR.security_number;


    UPDATE SECURITIES_INFO
    SET    current_room=V_TXTR.current_room
    WHERE TRIM(SYMBOL) In (SELECT TRIM(CODE) From HO_SEC_INFO
                          Where TRIM(STOCK_ID) = TRIM(V_TXTR.security_number));

    plog.setendsection (pkgctx, 'PRC_PROCESSTR');

EXCEPTION WHEN OTHERS THEN
    plog.error(pkgctx,SQLERRM || '--' || dbms_utility.format_error_backtrace);
    plog.error(pkgctx,'PRC_PROCESSTR V_TXTR.security_number = ' ||V_TXTR.security_number);
    v_CheckProcess := FALSE;
    plog.setendsection (pkgctx, 'PRC_PROCESSTR');
    rollback;
END PRC_PROCESSTR;

 --PROCESS MSG GA
Procedure PRC_PROCESSGA(V_MSGXML VARCHAR2) is
    V_TXGA   tx.msg_GA;
    V_ORGORDERID VARCHAR2(20);
BEGIN
    plog.setbeginsection (pkgctx, 'PRC_PROCESSGA');

    V_TXGA:=fn_xml2obj_GA(V_MSGXML);

    --XU LY MESSAGE GA.
    INSERT INTO ga
          (trading_date, msg_length, msg_text
          )
    VALUES (sysdate, V_TXGA.admin_message_length, V_TXGA.admin_message_text
          );

    plog.setendsection (pkgctx, 'PRC_PROCESSGA');

EXCEPTION WHEN OTHERS THEN
    plog.error(pkgctx,SQLERRM || '--' || dbms_utility.format_error_backtrace);
    plog.error(pkgctx,'PRC_PROCESSGA V_TXGA.admin_message_text = ' ||V_TXGA.admin_message_text);
    v_CheckProcess := FALSE;
    plog.setendsection (pkgctx, 'PRC_PROCESSGA');
    rollback;
END PRC_PROCESSGA;
 --PROCESS MSG AA - Thong tin lenh quang cao tu HO
Procedure PRC_PROCESSAA(V_MSGXML VARCHAR2) is
    V_TXAA   tx.msg_AA;
    V_Symbol    VARCHAR2(20);
    V_UpdatePrice Varchar2(10);
    v_Count Number(10);
    v_Halt  Varchar2(10);
    v_Security_Type Varchar2(10);
    v_strErrCode  Varchar2(20);
    v_strErrM Varchar2(200);
BEGIN
    plog.setbeginsection (pkgctx, 'PRC_PROCESSAA');

    V_TXAA:=fn_xml2obj_AA(V_MSGXML);

    --XU LY MESSAGE AA.
    -- Lay ma CK
    SELECT hs.code
    INTO V_Symbol
    FROM ho_sec_info hs
    WHERE hs.stock_id = V_TXAA.security_number;

    -- Neu them moi lenh quang cao
    IF V_TXAA.add_cancel_flag = 'A' THEN
    -- Insert vao bang orderptadv
        INSERT INTO orderptadv (AUTOID,TIMESTAMP,MESSAGETYPE,FIRM,TRADEID,SECURITYSYMBOL,SIDE,VOLUME,PRICE,
                              BOARD,SENDTIME,STATUS,CONTACT,OFFSET,ISSEND,ISACTIVE,
                              DELETED,REFID,BRID,TLID,IPADDRESS,ADVDATE,TOCOMPID)
        VALUES(seq_ORDERPTADV.NEXTVAL,V_TXAA.time_od,'AA',V_TXAA.firm,V_TXAA.trader,V_Symbol,V_TXAA.side,V_TXAA.volume,trim(V_TXAA.price),
        V_TXAA.board,NULL,'A',V_TXAA.contact,NULL,NULL,'N',
        'N',0,NULL,NULL,NULL,getcurrdate,NULL);
    ELSIF V_TXAA.add_cancel_flag = 'C' THEN
    -- Cap nhat trang thai lenh quang cao
        UPDATE orderptadv
        SET status = 'C',
            DELETED='Y'
        WHERE trim(contact) = trim(V_TXAA.contact)
            AND SECURITYSYMBOL = V_Symbol
            AND FIRM = V_TXAA.firm
            AND TRADEID = V_TXAA.trader
            AND VOLUME = V_TXAA.volume
            AND PRICE = V_TXAA.price;
    END IF;
    plog.setendsection (pkgctx, 'PRC_PROCESSAA');

EXCEPTION WHEN OTHERS THEN
    plog.error(pkgctx,SQLERRM || '--' || dbms_utility.format_error_backtrace);
    plog.error(pkgctx,'PRC_PROCESSAA V_TXAA.security_number = ' ||V_TXAA.security_number);
    v_CheckProcess := FALSE;
    plog.setendsection (pkgctx, 'PRC_PROCESSAA');
    rollback;
END PRC_PROCESSAA;

--Huy lenh thuong + giai toa lenh ATO
PROCEDURE          CONFIRM_CANCEL_NORMAL_ORDER (
   pv_orderid   IN   VARCHAR2,
   pv_qtty      IN   NUMBER
)
IS
BEGIN
    plog.setBEGINsection (pkgctx, 'CONFIRM_CANCEL_NORMAL_ORDER');
    pck_hogwex.CONFIRM_CANCEL_NORMAL_ORDER (
                                            pv_orderid,
                                            pv_qtty,
                                            v_CheckProcess);
    plog.setendsection (pkgctx, 'CONFIRM_CANCEL_NORMAL_ORDER');
EXCEPTION WHEN others THEN
    plog.error(pkgctx,SQLERRM || '--' || dbms_utility.format_error_backtrace);
    plog.error(pkgctx,'HOGW-CONFIRM_CANCEL_NORMAL_ORDER PV_ORDERID='||PV_ORDERID);
    v_CheckProcess := FALSE;
    plog.setendsection (pkgctx, 'CONFIRM_CANCEL_NORMAL_ORDER');
    rollback;
END CONFIRM_CANCEL_NORMAL_ORDER;





PROCEDURE          MATCHING_NORMAL_ORDER (
                    firm               IN   VARCHAR2,
                    order_number       IN   NUMBER,
                    order_entry_date   IN   VARCHAR2,
                    side_alph          IN   VARCHAR2,
                    filler             IN   VARCHAR2,
                    deal_volume        IN   NUMBER,
                    deal_price         IN   NUMBER,
                    confirm_number     IN   Varchar2
                    )
IS

BEGIN
    plog.setbeginsection (pkgctx, 'matching_normal_order');
    plog.error(pkgctx,'HOGW-matching_normal_order order_number='||order_number);
    pck_hogwex.MATCHING_NORMAL_ORDER (
                           firm ,
                           order_number,
                           order_entry_date,
                           side_alph,
                           filler,
                           deal_volume,
                           deal_price,
                           confirm_number,
                           v_CheckProcess);
    plog.setendsection (pkgctx, 'matching_normal_order');
EXCEPTION   WHEN OTHERS THEN
    plog.error(pkgctx,SQLERRM || '--' || dbms_utility.format_error_backtrace);
    plog.error(pkgctx,'HOGW-matching_normal_order order_number='||order_number);
    v_CheckProcess := FALSE;
    plog.setendsection (pkgctx, 'matching_normal_order');
    rollback;
END matching_normal_order;



  --CHECK ROOM
FUNCTION    FNC_CHECK_ROOM
            ( v_Symbol IN varchar2,
            v_Volumn In number,
            v_Custodycd in varchar2,
            v_BorS in  Varchar2)  RETURN  number IS
    Cursor c_SecInfo(vc_Symbol varchar2) is
         Select CURRENT_ROOM
         From ho_Sec_info
         Where  CODE =TRIM(vc_Symbol);
    v_CurrentRoom Number;
    v_Result Number;
BEGIN
--  return '1';
    If v_BorS ='B' and substr(v_Custodycd,4,1) ='F' then
         Open c_SecInfo(v_Symbol);
         Fetch c_SecInfo into v_CurrentRoom;
         If c_SecInfo%notfound  Or v_CurrentRoom < v_Volumn Then
            v_Result :=0;
         Else
            v_Result :=1;
         End if;
         Close c_SecInfo;
    Else
         v_Result :=1;
    End if;
    RETURN v_Result;
END FNC_CHECK_ROOM;

    --CHECK HCM
FUNCTION fnc_check_sec_hcm
    ( v_Symbol IN varchar2)
      RETURN  number IS
    Cursor c_SecInfo(vc_Symbol varchar2) is
        Select 1
        From ho_Sec_info
        where  CODE =TRIM(vc_Symbol) and FLOOR_CODE ='10'
        And NVL(SUSPENSION,'1') <>'S'
        And NVL(delist,'1') <>'D'
        And NVL(halt_resume_flag,'1') not in ('H','P');
      v_Number Number(10);
      v_Result Number(10);
BEGIN
  Open c_SecInfo(v_Symbol);
  Fetch c_SecInfo into v_Number;
  If c_SecInfo%notfound  Then
      v_Result :=0;
  Else
     v_Result :=1;
  End if;
  Close c_SecInfo;
  RETURN v_Result;
END;
    --CHECK TRADERID
FUNCTION fnc_check_traderid
      ( v_Machtype IN varchar2,
        v_BORS IN varchar2,
        v_Via in varchar2 default null)
      RETURN  number IS

    Cursor c_Putthourgh(v_BuySell varchar2) is
        Select TRADERID from Traderid where
        TO_NUMBER(firm) = (select TO_NUMBER(sysvalue) from ordersys where SYSNAME ='FIRM')
        and nvl(status,' ') <>'S' And Via ='F'
        and nvl(PUTTHROUGH_HALT,' ') <> 'A' and  nvl(PUTTHROUGH_HALT,' ') <> trim(v_BuySell);

    Cursor c_Normal(v_BuySell varchar2,vc_Via varchar2) is
        Select TRADERID from Traderid where
        TO_NUMBER(firm) = (select TO_NUMBER(sysvalue) from ordersys where SYSNAME ='FIRM')
        and nvl(status,' ') <> 'S' And Via =vc_Via
        and nvl(AUTOMATCH_HALT,' ') <> 'A' and  nvl(AUTOMATCH_HALT,' ') <> trim(v_BuySell);
     v_TraderID varchar2(10);
     v_Via_Tmp  varchar2(10);
BEGIN
    v_TraderID :='1';

    If v_Via ='O' then
        v_Via_Tmp :='O';
    Else  --tai san, hoac Tele deu cho ve F
        v_Via_Tmp :='F';
    End if;

    If v_Machtype ='P' then
        Open c_Putthourgh(v_BORS);
        Fetch c_Putthourgh into v_TraderID;
        If c_Putthourgh%notfound then
           v_TraderID :='0';
        End if;
        Close c_Putthourgh;
        RETURN v_TraderID;
    Else
        Open c_Normal(v_BORS,v_Via_Tmp);
        Fetch c_Normal into v_TraderID;
        If c_Normal%notfound then
             v_TraderID :='0';
        End if;
        Close c_Normal;
        RETURN v_TraderID;
    End if;
END;



FUNCTION    FNC_CHECK_ISNOTBOND
    ( v_Symbol IN Varchar2)
    RETURN  number IS
    Cursor c_Sbsecurities(v_Symbol_Sec varchar2)  is
    Select * from sbsecurities Where SYMBOL =TRIM(v_Symbol_Sec);
    v_Sbsecurities   c_Sbsecurities%Rowtype;
    v_Return Number;
BEGIN
    Open c_Sbsecurities(v_Symbol);
    Fetch c_Sbsecurities into v_Sbsecurities;
    Close c_Sbsecurities;

    If v_Sbsecurities.SECTYPE ='006' then --Trai phieu
        v_Return:= 0;
    Else
        v_Return:= 1;
    End if;
    Return v_Return;
END;

FUNCTION          FNC_CHECK_P_STOCKBOND
        ( v_Msgtype Varchar2,v_Symbol IN Varchar2)
        RETURN  number IS

    Cursor c_Msgmast(v_Msgtype varchar2)  is
      Select * from Msgmast Where RORS ='S' And trim(msgtype) =trim(v_Msgtype);
    Cursor c_Sbsecurities(v_Symbol_Sec varchar2)  is
      Select * from sbsecurities Where SYMBOL =TRIM(v_Symbol_Sec);
    Cursor c_Sc is select SYSVALUE from ordersys where SYSNAME ='CONTROLCODE';
    v_Sc varchar2(10);

    v_Msgmast   c_Msgmast%Rowtype;
    v_Sbsecurities   c_Sbsecurities%Rowtype;
    v_Return Number;
BEGIN
    Open c_Sc;
    Fetch c_Sc into v_Sc;
    Close c_Sc;

    Open c_Msgmast(v_Msgtype);
    Fetch c_Msgmast into v_Msgmast;
    Close c_Msgmast;

    Open c_Sbsecurities(v_Symbol);
    Fetch c_Sbsecurities into v_Sbsecurities;
    Close c_Sbsecurities;

    If v_Sbsecurities.SECTYPE ='006' then --Trai phieu
     If instr(Nvl(v_Msgmast.bond,' '),v_Sc)>0 then
       v_Return:= 1;
      Else
      v_Return:= 0;
      End if;
    Else
      If instr(nvl(v_Msgmast.stock,' '),v_Sc)>0 then
       v_Return:= 1;
      Else
       v_Return:= 0;
      End if;
    End if;
    Return v_Return;
END FNC_CHECK_P_STOCKBOND;


Procedure PRC_PROCESSMSG_ERR is
 v_IsProcess VARCHAR2(1);
BEGIN
    plog.setbeginsection (pkgctx, 'PRC_PROCESSMSG_ERR');
    v_IsProcess:='N';
    Begin
       Select SYSVALUE Into v_IsProcess From Ordersys
       Where SYSNAME ='ISPROCESS';
    Exception When others then
         v_IsProcess:='N';
    End;
    If v_IsProcess = 'Y' then
        DELETE HOMSGQUEUE
        WHERE  ID IN (SELECT ID FROM msgreceivetemp WHERE PROCESS='E' AND PROCESSNUM < 10 );
        Update msgreceivetemp set process='N',processtime=sysdate,processnum=processnum+1 WHERE PROCESS='E' AND PROCESSNUM < 10;
        COMMIT;
    End if;
    plog.setendsection (pkgctx, 'PRC_PROCESSMSG_ERR');
EXCEPTION WHEN OTHERS THEN
    plog.error(pkgctx, SQLERRM || '--' || dbms_utility.format_error_backtrace);
    plog.setendsection (pkgctx, 'PRC_PROCESSMSG_ERR');
    ROLLBACK;
    RAISE errnums.E_SYSTEM_ERROR;
END PRC_PROCESSMSG_ERR;
--Tinh thoi gian chenh lenh Giua HO va DB Flex
FUNCTION fn_get_delta_time
RETURN INTEGER as
    l_timeordersys  VARCHAR2(10);
    l_timemsg       VARCHAR2(10);
    l_delta_time      INTEGER;

BEGIN
    SELECT sysvalue INTO l_timeordersys FROM ordersys WHERE sysname = 'TIMESTAMP';
    SELECT NVL(TO_CHAR(MAX(msg_date),'HH24MISS'),'00:00:00') INTO l_timemsg FROM msgreceivetemp
    WHERE msgtype in ('SC','TS');


    IF l_timemsg = '00:00:00' THEN
        RETURN 0;
    END IF;

    SELECT TO_NUMBER(SUBSTR(l_timeordersys,1,2)) * 3600
                    + TO_NUMBER(SUBSTR(l_timeordersys,3,2)) * 60
                    + TO_NUMBER(SUBSTR(l_timeordersys,5,2))
                - (
                    TO_NUMBER(SUBSTR(l_timemsg,1,2)) * 3600
                        + TO_NUMBER(SUBSTR(l_timemsg,3,2)) * 60
                        + TO_NUMBER(SUBSTR(l_timemsg,5,2))
                    )
           INTO l_delta_time FROM DUAL;
  RETURN l_delta_time;
EXCEPTION
  WHEN OTHERS THEN
    RETURN 0;
END fn_get_delta_time;
FUNCTION fn_caculate_hose_time

RETURN VARCHAR2 as
    l_delta_time  VARCHAR2(10);
    l_timesysdate   VARCHAR2(10);
    l_hosetime      INTEGER;
    l_returntime    VARCHAR2(10);

BEGIN
    SELECT sysvalue INTO l_delta_time FROM ordersys WHERE sysname = 'DELTATIME';
    SELECT TO_CHAR(systimestamp,'HH24MISS') INTO l_timesysdate FROM dual;

    IF l_delta_time = 9999 THEN
        RETURN TO_CHAR(systimestamp,'HH24MISS');
    END IF;

    SELECT l_delta_time
                + (
                    TO_NUMBER(SUBSTR(l_timesysdate,1,2)) * 3600
                        + TO_NUMBER(SUBSTR(l_timesysdate,3,2)) * 60
                        + TO_NUMBER(SUBSTR(l_timesysdate,5,2))
                    )
           INTO l_hosetime FROM DUAL;

    SELECT TRIM(TO_CHAR(MOD(FLOOR(l_hosetime/3600),24),'09'))
                || TRIM(TO_CHAR(FLOOR(MOD(l_hosetime,3600)/60),'09'))
                || TRIM(TO_CHAR(MOD(MOD(l_hosetime,3600),60),'09'))
           INTO l_returntime FROM DUAL;
  RETURN l_returntime;
EXCEPTION
  WHEN OTHERS THEN
    RETURN TO_CHAR(systimestamp,'HH24MISS');
END fn_caculate_hose_time;

BEGIN
  FOR i IN (SELECT * FROM tlogdebug) LOOP
    logrow.loglevel  := i.loglevel;
    logrow.log4table := i.log4table;
    logrow.log4alert := i.log4alert;
    logrow.log4trace := i.log4trace;
  END LOOP;

  pkgctx := plog.init('pck_hogw',
                      plevel => NVL(logrow.loglevel,30),
                      plogtable => (NVL(logrow.log4table,'Y') = 'Y'),
                      palert => (logrow.log4alert = 'Y'),
                      ptrace => (logrow.log4trace = 'Y'));
END PCK_HOGW;
/
