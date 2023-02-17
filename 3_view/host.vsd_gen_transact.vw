SET DEFINE OFF;
CREATE OR REPLACE FORCE VIEW VSD_GEN_TRANSACT
(OBJNAME, FLDNAME, DEFNAME, CAPTION, FLDTYPE, 
 FIELDCODE, L_TEXT)
BEQUEATH DEFINER
AS 
SELECT  t.objname,
t.fldname,
t.defname,
t.caption,
t.fldtype,
h.fieldcode,
'--'||t.fldname||'    '||t.caption ||'   '||t.fldtype||chr(10)|| '     l_txmsg.txfields ('''||t.fldname||''').defname   := '''||t.defname||''';'||chr(10)||
'     l_txmsg.txfields ('''||t.fldname||''').TYPE      := '''||t.fldtype||''';'||chr(10)||
'     l_txmsg.txfields ('''||t.fldname||''').value      := rec.'||case nvl(h.fieldcode,'a') when 'a' then t.defname else h.fieldcode end ||';'
L_text
from fldmaster t ,  searchfld h --,search k
WHERE -- k.searchcode=h.searchcode
-- k.tltxcd=t.objname
T.OBJNAME=H.Searchcode(+)
and t.fldname=h.fldcd(+)
/
