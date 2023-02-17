SET DEFINE OFF;
CREATE OR REPLACE PROCEDURE "SA0010" (
   PV_REFCURSOR   IN OUT   PKG_REPORT.REF_CURSOR,
   OPT            IN       VARCHAR2,
   BRID           IN       VARCHAR2,
   TLGOUPS        IN       VARCHAR2,
   TLSCOPE        IN       VARCHAR2,
   AUTHID         IN       VARCHAR2,
   PV_TYPE         IN       VARCHAR2
   )
IS
--

-- ---------   ------  -------------------------------------------
   V_STROPTION        VARCHAR2 (5);       -- A: ALL; B: BRANCH; S: SUB-BRANCH
   V_STRBRID          VARCHAR2 (4);              -- USED WHEN V_NUMOPTION > 0
   V_STRAUTHID         VARCHAR2 (6);
   V_STRGRPID              VARCHAR2 (6);
    V_STRGRPID1              VARCHAR2 (6);
   V_STRGRPNAME            VARCHAR2 (500);
   V_STRACTIVE             VARCHAR2 (6);
   V_STRDESCRIPTION        VARCHAR2 (500);
   V_STRCOU                VARCHAR2 (6);
   V_STRGRPTYPE            VARCHAR2 (500);
   V_TYPE                  VARCHAR2(100);

 PV_CUR      PKG_REPORT.REF_CURSOR;
BEGIN

   V_STROPTION := OPT;


   IF (V_STROPTION <> 'A') AND (BRID <> 'ALL')
   THEN
      V_STRBRID := BRID;
   ELSE
      V_STRBRID := '%%';
   END IF;

   -- GET REPORT'S PARAMETERS

   IF(AUTHID <> 'ALL')
   THEN
        V_STRAUTHID  := AUTHID;
   ELSE
        V_STRAUTHID  := '%%';
   END IF;

   V_TYPE:=PV_TYPE;
/*      V_STRAUTHID:= AUTHID;*/

   -- END OF GETTING REPORT'S PARAMETERS

OPEN PV_CUR
    FOR
    SELECT TLGR.TLID, TLGR.TLNAME

    FROM TLPROFILES TLGR
    WHERE
         TLGR.TLID LIKE V_STRAUTHID;
LOOP

FETCH PV_CUR
   INTO V_STRGRPID1,V_STRGRPNAME;
  EXIT WHEN PV_CUR%NOTFOUND;

END LOOP;

IF V_TYPE='A' THEN
    OPEN PV_REFCURSOR
    FOR

         -- XUNG DOT QUYEN
      SELECT V_STRAUTHID TLID,V_STRGRPNAME NAME1, tlp.tlname,nvl(tlp.tlfullname,'')tlfullname ,tlp.tlid TLID1,tlr.grpname,tlg.grpid,  au.CMDCODE CMDCODE1, au.CMDCODE||':'|| a.name CMDCODE,AU.CMDTYPE, A1.CDCONTENT AREA,
             (CASE WHEN AU.CMDTYPE ='M' THEN MAX(DECODE(CASE WHEN ME.MENUTYPE IN ('A','P') THEN '' ELSE SUBSTR(AU.STRAUTH,3,1) END,'Y','X','')) ELSE '' END)addn,
             (CASE WHEN AU.CMDTYPE IN ('M','R') THEN '' ELSE MAX(DECODE(SUBSTR(AU.STRAUTH,1,1),'Y','X','')) END) BACK,
             (CASE WHEN AU.CMDTYPE ='M' THEN MAX(DECODE(CASE WHEN ME.MENUTYPE IN ('A','P') THEN '' ELSE SUBSTR(AU.STRAUTH,5,1) END,'Y','X','')) ELSE '' END)APP
      FROM tlgrpusers tlg, tlgroups tlr, tlprofiles tlp, brgrpparam br, cmdauth au, allcode a1, CMDMENU ME,VW_CMDMENU_ALL_RPT PT,
           (select cmdid id,cmdname name  from cmdmenu union all select tltxcd id, txdesc name from tltx union all select rptid id,description name  from rptmaster) a
      WHERE tlr.grpid = tlg.grpid AND tlp.tlid = tlg.tlid
            and a.id=au.cmdcode AND AU.CMDCODE=PT.CMDID
            AND br.brid = tlp.brid AND br.paratype = 'TLGROUPS'
            AND br.paravalue = tlr.grpid
            and tlr.grpid=au.authid
            and au.authtype='G'
          --  AND AU.STRAUTH<>'NNNN' AND AU.CMDALLOW<>'N' AND  AU.STRAUTH<>'NN' AND AU.STRAUTH<>'NNNNN'
            and tlp.tlid  LIKE V_STRAUTHID
            AND br.deltd = 'N' AND tlr.active = 'Y'
            AND A1.CDTYPE='SY' AND A1.CDNAME='RIGHTSCOPE'
            AND A1.CDVAL=AU.RIGHTSCOPE
            AND AU.CMDCODE=ME.CMDID(+)
            GROUP BY tlp.tlname,tlp.tlid,tlr.grpname,tlg.grpid, au.CMDCODE, A1.CDCONTENT,
                  AU.CMDTYPE,AU.CMDTYPE,ME.MENUTYPE,tlp.tlfullname,a.name
      order by  TLP.TLID,au.cmdcode
          ;

ELSE
    OPEN PV_REFCURSOR
    FOR
 SELECT B.* from
    (SELECT  TLID,CMDCODE, COUNT(1) FROM(
     SELECT DISTINCT TLP.TLID, AU.CMDCODE, A1.CDCONTENT AREA
             ,(CASE WHEN AU.CMDTYPE ='M' THEN (DECODE(CASE WHEN ME.MENUTYPE IN ('A','P') THEN '' ELSE SUBSTR(AU.STRAUTH,3,1) END,'Y','X','')) ELSE '' END)addn
             ,(CASE WHEN AU.CMDTYPE IN ('M','R') THEN '' ELSE (DECODE(SUBSTR(AU.STRAUTH,1,1),'Y','X','')) END) BACK
             ,(CASE WHEN AU.CMDTYPE ='M' THEN (DECODE(CASE WHEN ME.MENUTYPE IN ('A','P') THEN '' ELSE SUBSTR(AU.STRAUTH,5,1) END,'Y','X','')) ELSE '' END)APP
      FROM tlgrpusers tlg, tlgroups tlr, tlprofiles tlp, brgrpparam br, cmdauth au, allcode a1, CMDMENU ME  , VW_CMDMENU_ALL_RPT PT,
           (select cmdid id,cmdname name  from cmdmenu union all select tltxcd id, txdesc name from tltx union all select rptid id,description name  from rptmaster) a
      WHERE tlr.grpid = tlg.grpid AND tlp.tlid = tlg.tlid
            and a.id=au.cmdcode AND AU.CMDCODE=PT.CMDID
            AND br.brid = tlp.brid AND br.paratype = 'TLGROUPS'
            AND br.paravalue = tlr.grpid
            and tlr.grpid=au.authid
            and au.authtype='G'
             and tlp.tlid  LIKE V_STRAUTHID
            AND br.deltd = 'N' AND tlr.active = 'Y'
          --  AND AU.STRAUTH<>'NNNN' AND AU.CMDALLOW<>'N' AND  AU.STRAUTH<>'NN' AND AU.STRAUTH<>'NNNNN'
            AND A1.CDTYPE='SY' AND A1.CDNAME='RIGHTSCOPE'
            AND A1.CDVAL=AU.RIGHTSCOPE
            AND AU.CMDCODE=ME.CMDID(+)    )
            GROUP BY   TLID,CMDCODE
            HAVING COUNT(1)>1)A,
      (SELECT V_STRAUTHID TLID,V_STRGRPNAME NAME1,tlp.tlname,nvl(tlp.tlfullname,'')tlfullname ,tlp.tlid TLID1,tlr.grpname,tlg.grpid,  au.CMDCODE CMDCODE1,  au.CMDCODE||':'|| a.name CMDCODE,AU.CMDTYPE, A1.CDCONTENT AREA,
             (CASE WHEN AU.CMDTYPE ='M' THEN MAX(DECODE(CASE WHEN ME.MENUTYPE IN ('A','P') THEN '' ELSE SUBSTR(AU.STRAUTH,3,1) END,'Y','X','')) ELSE '' END)addn,
             (CASE WHEN AU.CMDTYPE IN ('M','R') THEN '' ELSE MAX(DECODE(SUBSTR(AU.STRAUTH,1,1),'Y','X','')) END) BACK,
             (CASE WHEN AU.CMDTYPE ='M' THEN MAX(DECODE(CASE WHEN ME.MENUTYPE IN ('A','P') THEN '' ELSE SUBSTR(AU.STRAUTH,5,1) END,'Y','X','')) ELSE '' END)APP
      FROM tlgrpusers tlg, tlgroups tlr, tlprofiles tlp, brgrpparam br, cmdauth au, allcode a1, CMDMENU ME  , VW_CMDMENU_ALL_RPT PT,
           (select cmdid id,cmdname name  from cmdmenu union all select tltxcd id, txdesc name from tltx union all select rptid id,description name  from rptmaster) a
      WHERE tlr.grpid = tlg.grpid AND tlp.tlid = tlg.tlid
            and a.id=au.cmdcode AND AU.CMDCODE=PT.CMDID
            AND br.brid = tlp.brid AND br.paratype = 'TLGROUPS'
            AND br.paravalue = tlr.grpid
            and tlr.grpid=au.authid
            and au.authtype='G'
             and tlp.tlid  LIKE V_STRAUTHID
          --  AND AU.STRAUTH<>'NNNN' AND AU.CMDALLOW<>'N' AND  AU.STRAUTH<>'NN' AND AU.STRAUTH<>'NNNNN'
            AND br.deltd = 'N' AND tlr.active = 'Y'
            AND A1.CDTYPE='SY' AND A1.CDNAME='RIGHTSCOPE'
            AND A1.CDVAL=AU.RIGHTSCOPE
            AND AU.CMDCODE=ME.CMDID(+)
            GROUP BY tlp.tlname,tlp.tlid,tlr.grpname,tlg.grpid, au.CMDCODE, A1.CDCONTENT,
                  AU.CMDTYPE,AU.CMDTYPE,ME.MENUTYPE,tlp.tlfullname,a.name)B
      WHERE A.TLID=B.TLID1 AND A.CMDCODE=B.CMDCODE1

      ORDER BY B.TLID1 ,B.CMDCODE1;

      END IF;

    EXCEPTION
    WHEN OTHERS THEN
        RETURN;
    END;                                                              -- PROCEDURE

 
 
 
 
/
