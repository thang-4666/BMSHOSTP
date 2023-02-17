SET DEFINE OFF;
CREATE OR REPLACE PROCEDURE "RPT_ALLCODE" (pv_refCursor IN OUT PKG_REPORT.ref_cursor, pv_strXML IN NVARCHAR2)
   IS
--
-- Purpose: Briefly explain the functionality of the procedure
--
-- MODIFICATION HISTORY
-- Person      Date    Comments
-- MinhTK   20-Nov-06  Created
-- ---------   ------  -------------------------------------------
    v_xmlType           XMLType;
    v_xmlDocument       DBMS_XMLDOM.DOMDocument;
    v_xmlDocElement     DBMS_XMLDOM.DOMElement;
    v_xmlNode           DBMS_XMLDOM.DOMNode;
    v_xmlNodelist       DBMS_XMLDOM.DOMNodelist;
    v_xmlNodeElement    DBMS_XMLDOM.DOMElement;

    v_strFLDNAME        VARCHAR2(100);
    v_strDATATYPE       VARCHAR2(5);
    v_strFLDVALUE       NVARCHAR2(4000);
    v_strDEFVALUE       NVARCHAR2(4000);

    v_strFilter         VARCHAR2(4000);
    v_strSQL            VARCHAR2(4000);
   -- Declare program variables as shown above
BEGIN
    -- Build the filter of SQL statement
    v_xmlType := XMLType(pv_strXML);
    v_xmlDocument := DBMS_XMLDOM.newDOMDocument(v_xmlType);
    v_xmlDocElement := DBMS_XMLDOM.getDocumentElement(v_xmlDocument);
    v_xmlNodelist := DBMS_XMLDOM.getElementsByTagName(v_xmlDocElement, 'Entry');

    v_strFilter := NULL;
    For i in 1..DBMS_XMLDOM.getLength(v_xmlNodelist) loop
        v_xmlNode := DBMS_XMLDOM.Item(v_xmlNodelist, i-1);
        v_xmlNodeElement := DBMS_XMLDOM.makeElement(v_xmlNode);

        v_strFLDNAME := DBMS_XMLDOM.getAttribute(v_xmlNodeElement, 'fldname');
        v_strDATATYPE := DBMS_XMLDOM.getAttribute(v_xmlNodeElement, 'fldtype');
        v_strFLDVALUE := DBMS_XMLDOM.getAttribute(v_xmlNodeElement, 'fldvalue');
        v_strDEFVALUE := DBMS_XMLDOM.getAttribute(v_xmlNodeElement, 'flddefval');

        If (v_strFLDVALUE <> v_strDEFVALUE) then
            If (v_strDATATYPE = 'C') then
                v_strFilter := v_strFilter || ' AND ' || v_strFLDNAME || ' = ' || '''' || v_strFLDVALUE || '''';
            ElsIf (v_strDATATYPE = 'N') then
                v_strFilter := v_strFilter || ' AND ' || v_strFLDNAME || ' = ' || v_strFLDVALUE;
            ElsIf (v_strDATATYPE = 'D') then
                v_strFilter := v_strFilter || ' AND ' || v_strFLDNAME || ' = TO_DATE(' || '''' || v_strFLDVALUE || '''' ||', ' || '''' || 'dd/MM/yyyy' || '''' || ')';
            End if;
        End if;
    End loop;

    v_strSQL := 'SELECT CDTYPE, CDNAME, CDVAL, CDCONTENT FROM ALLCODE WHERE 0=0';

    -- Open ref cursor to get data from database
    Open pv_refCursor for
        v_strSQL || NVL(v_strFilter, ' AND 1=1');
EXCEPTION
    WHEN OTHERS THEN
        Return;
END; -- Procedure

 
 
 
 
/
