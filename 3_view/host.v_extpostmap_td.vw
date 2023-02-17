SET DEFINE OFF;
CREATE OR REPLACE FORCE VIEW V_EXTPOSTMAP_TD
(TLTXCD, IBT, DORC, FLDTYPE, BRID, 
 ACCTNO, ACNAME, AMTEXP, ACFLD, ACFLDDESC, 
 SUBTXNO, REFFLD, NEGATIVECD, ISRUN, TXCD)
BEQUEATH DEFINER
AS 
select      tltxcd, ibt, dorc, fldtype, brid,
            case when fldtype = 'V' then (select acctno from glref where acname = ext.acname and glgrp = '6666')
            else (select acctno from glrefcom where acname = ext.acname) end acctno,
            acname, amtexp,
            acfld,
            (select caption from fldmaster where objname = ext.tltxcd and fldname = ext.acfld) acflddesc,
            subtxno, reffld, negativecd, isrun, txcd
from        extpostmap ext
order by    tltxcd, subtxno, dorc desc
/
