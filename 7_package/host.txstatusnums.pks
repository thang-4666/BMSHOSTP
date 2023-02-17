SET DEFINE OFF;
CREATE OR REPLACE PACKAGE txstatusnums IS
      c_txlogged              CONSTANT CHAR (1) := 0;
      c_txcompleted           CONSTANT CHAR (1) := 1;
      c_txerroroccured        CONSTANT CHAR (1) := 2;
      c_txcashier             CONSTANT CHAR (1) := 3;
      c_txpending             CONSTANT CHAR (1) := 4;
      c_txrejected            CONSTANT CHAR (1) := 5;
      c_txmsgrequired         CONSTANT CHAR (1) := 6;
      c_txdeleting            CONSTANT CHAR (1) := 7;     --Pending to delete
      c_txrefuse              CONSTANT CHAR (1) := 8;
      c_txdeleted             CONSTANT CHAR (1) := 9;
      c_txremittance          CONSTANT CHAR (2) := 10;
END; 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
/
