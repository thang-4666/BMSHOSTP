SET DEFINE OFF;
CREATE OR REPLACE PROCEDURE pr_process_camast (pv_camastid IN VARCHAR2, pv_ActionFlag IN VARCHAR2)
IS
    l_count INTEGER;
    l_optcodeid VARCHAR2(20);
    l_optsymbol camast.optsymbol%TYPE;
    l_catype    camast.catype%TYPE;
BEGIN
    FOR rec IN
    (
       SELECT * FROM camast WHERE camastid = pv_camastid
    )
    LOOP
       IF rec.catype = '014' THEN
           SELECT COUNT(*) INTO l_count FROM sbsecurities WHERE symbol = rec.optsymbol;

           IF l_count <= 0 THEN
               SELECT   LPAD(NVL (MAX (odr) + 1, 1),6,000000) INTO l_optcodeid
                  FROM   (SELECT   ROWNUM odr, invacct
                            FROM   (  SELECT   codeid invacct
                                        FROM   sbsecurities
                                    ORDER BY   codeid) dat
                           WHERE   TO_NUMBER (invacct) = ROWNUM) invtab;

                INSERT INTO sbsecurities (codeid,issuerid,symbol,sectype,investmenttype,risktype,parvalue,foreignrate,status,tradeplace,depository,securedratio,mortageratio,reporatio,issuedate,expdate,intperiod,intrate, halt)
                        SELECT  l_optcodeid ,issuerid, rec.optsymbol ,'004' sectype,investmenttype,risktype,parvalue,foreignrate,status,tradeplace,depository,securedratio,mortageratio,reporatio,issuedate,expdate,intperiod,intrate, 'Y' halt
                          FROM sbsecurities WHERE codeid= rec.codeid;

                INSERT INTO securities_info (autoid,codeid,symbol,txdate,listingqtty,tradeunit,listingstatus,adjustqtty,listtingdate,referencestatus,adjustrate,referencerate,referencedate,status,basicprice,openprice,prevcloseprice,currprice)
                       SELECT seq_securities_info.nextval, l_optcodeid, rec.optsymbol,txdate,listingqtty,tradeunit,listingstatus,adjustqtty,listtingdate,referencestatus,adjustrate,referencerate,referencedate,'N' status,0 basicprice,0 openprice,0 prevcloseprice,0 currprice
                          FROM securities_info WHERE codeid= rec.codeid;

                INSERT INTO securities_ticksize (autoid,codeid,symbol,ticksize,fromprice,toprice,status)
                        SELECT seq_securities_ticksize.nextval, l_optcodeid ,rec.optsymbol,ticksize,fromprice,toprice,status
                        FROM securities_ticksize  WHERE codeid= rec.codeid;

               UPDATE camast SET optcodeid = l_optcodeid WHERE camastid = pv_camastid;
           END IF;
       ELSIF rec.catype IN ('010','011','021','012','013','020') THEN
           SELECT symbol INTO l_optsymbol FROM sbsecurities WHERE codeid = rec.codeid;

           UPDATE camast SET optsymbol = l_optsymbol, excodeid = codeid WHERE camastid = pv_camastid;
       END IF;

    END LOOP;
END;
 
/
