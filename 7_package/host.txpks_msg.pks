SET DEFINE OFF;
CREATE OR REPLACE PACKAGE txpks_msg
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

END;

 
 
 
 
/


CREATE OR REPLACE PACKAGE BODY txpks_msg IS
  pkgctx plog.log_ctx;
  logrow tlogdebug%ROWTYPE;

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
      l_txmsg.warning := xmldom.getvalue(xmldom.getattributenode(xmldom.makeelement(l_node),
                                                                 'WARNING'));
      l_txmsg.sessionid := xmldom.getvalue(xmldom.getattributenode(xmldom.makeelement(l_node),
                                                                 'SESSIONID'));
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

    plog.debug(pkgctx,'Prepare to parse warning exception');
    l_nodeList := xslprocessor.selectnodes(xmldom.makenode(l_doc),
                                           '/TransactMessage/warningexception/entry');

    FOR i IN 0 .. xmldom.getlength(l_nodeList) - 1 LOOP
      plog.debug(pkgctx,'parse txWarningException: ' || i);
      l_node := xmldom.item(l_nodeList, i);
      l_fldname := xmldom.getvalue(xmldom.getattributenode(xmldom.makeelement(l_node),
                                                           'errnum'));
      l_txmsg.txWarningException(l_fldname).errlev:= xmldom.getvalue(xmldom.getattributenode(xmldom.makeelement(l_node),
                                                                                         'errlev'));
      l_txmsg.txWarningException(l_fldname).value := xmldom.getnodevalue(xmldom.getfirstchild(l_node));
      plog.debug(pkgctx,'WarningException(' || l_fldname || '): ' ||
                           l_txmsg.txWarningException(l_fldname).value);

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
      plog.error(pkgctx, SQLERRM);
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
   xmldom.setattribute (l_element, 'WARNING', p_txmsg.WARNING);
   xmldom.setattribute (l_element, 'SESSIONID', p_txmsg.SESSIONID);
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

   -- warningmessage
   l_element             := xmldom.createelement (l_doc, 'WarningException');
   childnode    := xmldom.appendchild (headernode, xmldom.makenode (l_element));

   l_index := p_txmsg.txWarningException.FIRST;
   plog.debug(pkgctx,'prepare to populate WarningException, l_index: ' || l_index);
   WHILE (l_index IS NOT NULL)
   LOOP
       plog.debug(pkgctx,'loop with l_index: ' || l_index);
       l_element             := xmldom.createelement (l_doc, 'entry');

       xmldom.setattribute (l_element, 'errnum', l_index);
       xmldom.setattribute (l_element, 'errlev', p_txmsg.txWarningException(l_index).errlev);
       entrynode   := xmldom.appendchild (childnode, xmldom.makenode (l_element));

       textnode := xmldom.createTextNode(l_doc, p_txmsg.txWarningException(l_index).value);
       entrynode := xmldom.appendChild(entrynode, xmldom.makeNode(textnode));
       -- get the next field
       l_index := p_txmsg.txWarningException.NEXT (l_index);
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
BEGIN
  FOR i IN (SELECT * FROM tlogdebug) LOOP
    logrow.loglevel  := i.loglevel;
    logrow.log4table := i.log4table;
    logrow.log4alert := i.log4alert;
    logrow.log4trace := i.log4trace;
  END LOOP;

  pkgctx := plog.init('txpks_msg',
                      plevel => NVL(logrow.loglevel,30),
                      plogtable => (NVL(logrow.log4table,'Y') = 'Y'),
                      palert => (logrow.log4alert = 'Y'),
                      ptrace => (logrow.log4trace = 'Y'));
END txpks_msg;

/
