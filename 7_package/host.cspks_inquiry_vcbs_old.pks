SET DEFINE OFF;
CREATE OR REPLACE PACKAGE cspks_inquiry_vcbs_old
IS
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
     **  FSS      20-mar-2010    Created
     ** (c) 2008 by Financial Software Solutions. JSC.
     ----------------------------------------------------------------------------------------------------*/

  procedure pr_tblstatementvcbshist
    (p_refcursor in out pkg_report.ref_cursor,
     p_custodycd  IN  varchar2 ,
     p_fdate     IN  varchar2 ,
     p_tdate     IN  varchar2
    );

  procedure pr_tblsstatementvcbshist
    (p_refcursor in out pkg_report.ref_cursor,
     p_custodycd  IN  varchar2 ,
     p_symbol    IN  varchar2 ,
     p_fdate     IN  varchar2 ,
     p_tdate     IN  varchar2
    );
   procedure pr_tblbookordervcbshist
    (p_refcursor in out pkg_report.ref_cursor,
     p_custodycd  IN  varchar2 ,
     p_symbol    IN  varchar2 ,
     p_fdate     IN  varchar2 ,
     p_tdate     IN  varchar2
    );



END;
 
 
 
 
/


CREATE OR REPLACE PACKAGE BODY cspks_inquiry_vcbs_old
IS
   -- declare log context
   pkgctx   plog.log_ctx;
   logrow   tlogdebug%ROWTYPE;

---------------------------------pr_OpenLoanAccount------------------------------------------------
procedure pr_tblstatementvcbshist
    (p_refcursor in out pkg_report.ref_cursor,
     p_custodycd  IN  varchar2 ,
     p_fdate     IN  varchar2 ,
     p_tdate     IN  varchar2
    )
IS

BEGIN

OPEN P_REFCURSOR FOR
    SELECT TRANSDATE,BRANCHID,TRANSCODE,INCDEC,CASH,NOTE,ACCOUNT,ACCOUNT_TYPE,CUSTODYCD
    FROM TBLSTATEMENTVCBSHIST
    WHERE CUSTODYCD =P_CUSTODYCD
    AND TRANSDATE BETWEEN to_date (p_fdate,'DD/MM/YYYY') AND to_date (p_tdate,'DD/MM/YYYY')
    ORDER BY TRANSDATE
    ;

    plog.setendsection(pkgctx, 'pr_tblstatementvcbshist');
EXCEPTION
WHEN OTHERS
THEN
  plog.error (pkgctx, SQLERRM || dbms_utility.format_error_backtrace);
  plog.setendsection (pkgctx, 'pr_tblstatementvcbshist');
  return;
END pr_tblstatementvcbshist;

procedure pr_tblsstatementvcbshist
    (p_refcursor in out pkg_report.ref_cursor,
     p_custodycd  IN  varchar2 ,
     p_symbol    IN  varchar2 ,
     p_fdate     IN  varchar2 ,
     p_tdate     IN  varchar2
    )
IS
v_symbol varchar2(300);

BEGIN

if p_symbol = 'ALL' OR p_symbol IS NULL THEN
v_symbol:='%';
ELSE
v_symbol:=p_symbol;
END IF ;

OPEN P_REFCURSOR FOR
    SELECT TICKERS,TRANSDATE,BRANCHID,TRANSCODE,INCDEC,VOLUME,NOTE,ACCOUNT,ACCOUNT_TYPE,CUSTODYCD
    FROM tblsstatementvcbshist
    WHERE CUSTODYCD =P_CUSTODYCD
    AND TRANSDATE BETWEEN to_date (p_fdate,'DD/MM/YYYY') AND to_date (p_tdate,'DD/MM/YYYY')
    AND TRIM(TICKERS) LIKE  v_symbol
    ORDER BY TRANSDATE,TICKERS    ;
    plog.setendsection(pkgctx, 'pr_tblsstatementvcbshist');
EXCEPTION
WHEN OTHERS
THEN
  plog.error (pkgctx, SQLERRM || dbms_utility.format_error_backtrace);
  plog.setendsection (pkgctx, 'pr_tblsstatementvcbshist');
  return;
END pr_tblsstatementvcbshist;


procedure pr_tblbookordervcbshist
    (p_refcursor in out pkg_report.ref_cursor,
     p_custodycd  IN  varchar2 ,
     p_symbol    IN  varchar2 ,
     p_fdate     IN  varchar2 ,
     p_tdate     IN  varchar2
    )
IS
v_symbol varchar2(300);

BEGIN

if p_symbol = 'ALL' OR p_symbol IS NULL THEN
v_symbol:='%';
ELSE
v_symbol:=p_symbol;
END IF ;

OPEN P_REFCURSOR FOR
    SELECT MATCHDEALID,TRANSDATE,ORDERTYPE,TICKERS,MATCHVOLUME,MATCHPRICE,MATCHVALUE,ORDERDEALID,ACCOUNT,BRANCHID,DEALSTATE,PRICETYPE,CUSTODYCD
    FROM TBLBOOKORDERVCBSHIST
    WHERE CUSTODYCD =P_CUSTODYCD
    AND TRANSDATE BETWEEN to_date (p_fdate,'DD/MM/YYYY') AND to_date (p_tdate,'DD/MM/YYYY')
    AND trim(TICKERS) LIKE  v_symbol
 ORDER BY TRANSDATE,TICKERS    ;

    plog.setendsection(pkgctx, 'pr_tblbookordervcbshist');
EXCEPTION
WHEN OTHERS
THEN
  plog.error (pkgctx, SQLERRM || dbms_utility.format_error_backtrace);
  plog.setendsection (pkgctx, 'pr_tblbookordervcbshist');
  return;
END pr_tblbookordervcbshist;


-- initial LOG
BEGIN
   SELECT *
   INTO logrow
   FROM tlogdebug
   WHERE ROWNUM <= 1;

   pkgctx    :=
      plog.init ('cspks_inquiry_vcbs_old',
                 plevel => logrow.loglevel,
                 plogtable => (logrow.log4table = 'Y'),
                 palert => (logrow.log4alert = 'Y'),
                 ptrace => (logrow.log4trace = 'Y')
      );
END;
/
