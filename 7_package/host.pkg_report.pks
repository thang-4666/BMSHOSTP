SET DEFINE OFF;
CREATE OR REPLACE PACKAGE pkg_report 
  IS
--
-- Purpose: Identify ref cursor for creating reports
--
-- MODIFICATION HISTORY
-- Person      Date    Comments
-- MinhTK   10-Nov-06  Created
-- ---------   ------  ------------------------------------------
    Type ref_cursor is ref cursor;
END; -- Package spec
/
