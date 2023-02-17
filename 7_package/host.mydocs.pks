SET DEFINE OFF;
CREATE OR REPLACE PACKAGE mydocs
      AS
 PROCEDURE doc_dir_setup;
 PROCEDURE list   (in_doc    IN VARCHAR2);
 PROCEDURE load   (in_doc    IN VARCHAR2,
                   in_id     IN NUMBER);
 PROCEDURE search (in_search IN VARCHAR2,
                   in_id     IN NUMBER);
END mydocs;
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
/
