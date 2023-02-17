SET DEFINE OFF;
CREATE OR REPLACE FORCE VIEW VW_SE2245
(REQID, OBJNAME, TRFCODE, OBJKEY, TXDATE, 
 AFACCTNO, MSGACCT, NOTES, MSGSTATUS, VSD_ERR_MSG, 
 CREATEDATE, TLID, TLNAME, CODEID, BLOCKEDQTTY, 
 TRADEQTTY, EFFDATE, RECUSTODYCD, DESCRIPTION, PARVALUE, 
 INWARD, SYMBOL, REFTXNUM, REFTXDATE)
BEQUEATH DEFINER
AS 
((SELECT reqid, objname, trfcode, objkey, txdate, afacctno, msgacct, notes,msgstatus, vsd_err_msg, createdate, tlid, tlname,
           sb2.codeid, blockedqtty, tradeqtty, effdate, recustodycd, description, sb2.parvalue, re.inward, sb2.symbol, re.reftxnum, re.reftxdate
    FROM sbsecurities SB1, sbsecurities sb2,
    (
        SELECT req.reqid, req.objname, req.trfcode,req.objkey,TO_DATE (req.txdate, 'DD/MM/RRRR')txdate, req.afacctno, req.msgacct,
               req.notes, a1.cdcontent msgstatus,req.vsd_err_msg,TO_CHAR (req.createdate, 'hh24:mi:ss.') createdate, req.tlid, tl.tlname,
               dtl.symbol symbol, dtl.blockedqtty blockedqtty,dtl.tradeqtty tradeqtty,dtl.effdate effdate,dtl.recustodycd recustodycd,
               nvl(dtl.inward,substr(dtl.recustodycd,1,3)) inward,a3.cdcontent description, reftxnum, reftxdate, dtl.SECTYPE
        FROM vsdtxreq req, vsdtrfcode vcd, allcode a1,
             tlprofiles tl, allcode a3,
             (
                SELECT  lg.referenceid,
                        MAX(CASE WHEN vdtl.fldname = 'SYMBOL' THEN vdtl.fldval
                                 WHEN vdtl.fldname = 'SYMBOL_CGD' THEN vdtl.fldval  || '_CGD'
                                 ELSE '' END) symbol,
                        MAX(CASE WHEN vdtl.fldname = 'BLOCKEDQTTY' THEN TO_NUMBER(REPLACE (vdtl.fldval, ','))
                                 ELSE 0 END) blockedqtty,
                        MAX(CASE WHEN vdtl.fldname = 'QTTY' THEN TO_NUMBER(REPLACE (vdtl.fldval, ','))
                             ELSE 0 END) tradeqtty,
                        MAX(CASE WHEN vdtl.fldname = 'VSDEFFDATE' THEN TO_DATE(vdtl.fldval,'RRRR/MM/DD')
                                 ELSE null END) effdate,
                        MAX(CASE WHEN vdtl.fldname = 'CUSTODYCD' THEN vdtl.fldval
                                 ELSE '' END) recustodycd,
                        MAX(CASE WHEN vdtl.fldname = 'REFCUSTODYCD' THEN substr(fldval, 1, 3)
                                 ELSE '' END) inward,
                        MAX(CASE WHEN vdtl.fldname = 'SECTYPE' THEN fldval
                                 ELSE '' END) SECTYPE
                FROM vsdtrflogdtl vdtl, vsdtrflog lg
                WHERE lg.autoid = vdtl.refautoid
                group by lg.referenceid
             ) dtl
        WHERE a1.cdtype = 'SA'
       AND a1.cdname = 'VSDTXREQSTS'
       AND a1.cdval = req.msgstatus 
       AND a3.cdtype = 'SE'
       AND a3.cdname = 'DESC2245'
       AND a3.cdval = req.trfcode
       AND req.tlid = tl.tlid(+)
       AND req.reqid = dtl.referenceid
       AND req.trfcode = vcd.trfcode
       AND vcd.tltxcd = '2245'
       AND req.status <> 'C'
    ) re
    WHERE sb1.symbol = re.symbol
    AND CASE WHEN re.SECTYPE LIKE 'NORM' THEN SB2.codeid ELSE SB2.refcodeid END = SB1.codeid

  )
)
/
