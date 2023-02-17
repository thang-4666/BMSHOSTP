SET DEFINE OFF;
CREATE OR REPLACE PACKAGE cspks_deploy
 /*----------------------------------------------------------------------------------------------------
     ** Module   : CORE SYSTEM
     ** and is copyrighted by FSS.
     **
     **    All rights reserved.  No part of this work may be reproduced, stored in a retrieval system,
     **    adopted or transmitted in any form or by any means, electronic, mechanical, photographic,
     **    graphic, optic recording or otherwise, translated in any language or computer language,
     **    without the prior written permission of Financial Software Solutions. JSC.
     **
     **  MODIFICATION HISTORY
     **  Person      Date           Comments
     **  TienPQ      10-Nov-2008    Created
     ** (c) 2008 by Financial Software Solutions. JSC.
     ----------------------------------------------------------------------------------------------------*/
 IS

  FUNCTION fn_encrypt(p_name varchar2, p_error out varchar2)
  RETURN BOOLEAN;

  FUNCTION fn_dump2file (p_path VARCHAR2, p_file_name VARCHAR2, p_dep_user VARCHAR2, p_dev_user VARCHAR2, p_error OUT VARCHAR2)
   RETURN BOOLEAN;
END;

 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
/


CREATE OR REPLACE PACKAGE BODY cspks_deploy
IS
   FUNCTION fn_dump2file (
      p_path          IN    VARCHAR2,
      p_file_name   IN      VARCHAR2,
      p_dep_user    IN VARCHAR2,
      p_dev_user    IN VARCHAR2,
      p_error       OUT   VARCHAR2
   )
      RETURN BOOLEAN
   IS
      l_file_handle   UTL_FILE.file_type;     --declare a handle for the file
      l_temp          CLOB;
      l_count         NUMBER (10);
      l_n   number(10);
      l_max_buffer number(10):=30000;
   BEGIN
      l_file_handle := UTL_FILE.fopen (p_path, p_file_name, 'W');
      DBMS_METADATA.set_transform_param (DBMS_METADATA.session_transform,
                                         'PRETTY',
                                         TRUE
                                        );
      DBMS_METADATA.set_transform_param (DBMS_METADATA.session_transform,
                                         'SQLTERMINATOR',
                                         TRUE
                                        );

      FOR j IN (SELECT   object_name,
                         DECODE (object_type,
                                 'PACKAGE BODY', 'PACKAGE',
                                 object_type
                                ) object_type
                    FROM user_objects
                   WHERE object_type IN --('TABLE')
                                    ('FUNCTION', 'PROCEDURE', 'PACKAGE BODY')
                     AND object_name NOT IN ('CSPKS_DEPLOY')
                     AND status = 'VALID'
                ORDER BY object_name)
      LOOP
         /*
           UTL_FILE.put(l_file_handle, 'CREATE OR REPLACE ');

           FOR I IN (

                     SELECT text --into l_source

                       FROM user_source

                      WHERE NAME = J.NAME

                        AND TYPE = J.TYPE

                     )
           LOOP

             UTL_FILE.put(l_file_handle, I.TEXT || CHR(10));

           --UTL_FILE.fflush(l_file_handle);

           END LOOP;

           UTL_FILE.put(l_file_handle, '/');
         */
         --DBMS_OUTPUT.put_line (j.object_type || ',' || j.object_name);

         SELECT DBMS_METADATA.get_ddl (j.object_type, j.object_name)
           INTO l_temp
           FROM DUAL;

         --DBMS_OUTPUT.put_line (LENGTH (l_temp));
         l_temp := replace(l_temp,'"' || p_dev_user || '".',NVL(p_dep_user,''));
         IF LENGTH (l_temp) > 32000
         THEN
            l_count := 0;
            l_n := ROUND (LENGTH (l_temp) / l_max_buffer) + 1;
            --DBMS_OUTPUT.put_line ('n:'||l_n);
            FOR k IN 1 .. l_n
            LOOP
               l_count := (k - 1) * l_max_buffer + 1;
               --DBMS_OUTPUT.put_line ('l_count:' || l_count);
               UTL_FILE.put (l_file_handle, SUBSTR (l_temp, l_count, l_max_buffer));
               UTL_FILE.fflush (l_file_handle);
            END LOOP;
            --UTL_FILE.put(l_file_handle,chr(10));
            UTL_FILE.fflush (l_file_handle);
         ELSE
            UTL_FILE.put_line (l_file_handle, l_temp);
            UTL_FILE.fflush (l_file_handle);
         END IF;
      END LOOP;

      --If the file is open, close it. This does not normally need to be checked b4 closing
      IF UTL_FILE.is_open (l_file_handle)
      THEN
         UTL_FILE.fclose (l_file_handle);
      END IF;

      RETURN TRUE;
   EXCEPTION
      WHEN OTHERS
      THEN
         IF UTL_FILE.is_open (l_file_handle)
         THEN
            UTL_FILE.fclose (l_file_handle);
         END IF;

         p_error := SQLERRM;
         RETURN FALSE;
   END;

   FUNCTION fn_encrypt (p_name VARCHAR2, p_error OUT VARCHAR2)
      RETURN BOOLEAN
   IS
      l_source   DBMS_SQL.varchar2a;
      l_wrap     DBMS_SQL.varchar2a;
      E_ENCRYPTED_ALREADY EXCEPTION;
      pkgctx     plog.log_ctx;
      l_count    NUMBER (5, 0);
   BEGIN
      pkgctx :=
              plog.init ('ENCRYPT', plevel => plog.ldebug, plogtable => TRUE);

      FOR j IN (SELECT DISTINCT NAME, TYPE
                           FROM user_source
                          WHERE TYPE IN
                                   ('PACKAGE BODY')
                            AND NAME like
                                   DECODE (p_name,
                                           NULL, 'TXPKS%',
                                           UPPER (p_name)
                                          )
                            AND NAME <> 'CSPKS_DEPLOY'
                            )
      LOOP
         BEGIN
            l_count := 1;
            l_source (l_count) := 'CREATE OR REPLACE ';

            FOR i IN (SELECT text,line                             --into l_source
                        FROM user_source
                       WHERE NAME = j.NAME AND TYPE = j.TYPE)
            LOOP
               IF i.line =1 AND INSTR(I.TEXT,'wrapped') > 0 THEN
                dbms_output.put_line('ENCRYPTED ALREADY!!!');
                p_error := '<<ENCRYPTED ALREADY>>';
                RAISE E_ENCRYPTED_ALREADY;
              END IF;
               l_count := l_count + 1;
               l_source (l_count) := i.text;
            END LOOP;

            -- ONLY ENCRYPT IF THE STORE PROCEDURE IS PLAIN TEXT
            --IF INSTR (UPPER (l_source (l_count)), 'END') > 0
            --THEN
               SYS.DBMS_DDL.create_wrapped (DDL      => l_source,
                                            lb       => 1,
                                            ub       => l_count
                                           );               --l_source.count);
               /*
                 l_wrap := SYS.DBMS_DDL.WRAP(ddl => l_source,
                                            lb => 1,ub => l_source.count);
                 execute immediate l_wrap;
                */
               plog.DEBUG (pkgctx, 'ENCRYPTED ' || j.NAME);
            --END IF;
         EXCEPTION
            WHEN E_ENCRYPTED_ALREADY
            THEN
               p_error := p_error || j.NAME || ',';
               plog.DEBUG (pkgctx,
                           j.NAME || 'WAS ENCRYPTED ALREADY '
                          );
            WHEN OTHERS
            THEN
               p_error := p_error || j.NAME || ',';
               plog.DEBUG (pkgctx,
                           'ERROR WHEN WRAP ' || j.NAME || ': ' || SQLERRM
                          );
         --dbms_output.put_line('ERROR WHEN WRAP ' || J.NAME || ': ' || SQLERRM);
         END;
      END LOOP;

      IF NVL (p_error, 'X') <> 'X' AND LENGTH (p_error) > 0
      THEN
         RETURN FALSE;
      ELSE
         RETURN TRUE;
      END IF;
   END fn_encrypt;

   FUNCTION fn_wrap2file (
      p_name        IN       VARCHAR2,
      p_path        IN       VARCHAR2,
      p_file_name   IN       VARCHAR2,
      p_error       OUT      VARCHAR2
   )
      RETURN BOOLEAN
   IS
      l_source        DBMS_SQL.varchar2a;
      l_wrap          DBMS_SQL.varchar2a;
      pkgctx          plog.log_ctx;
      l_count         NUMBER (5, 0);
      l_file_handle   UTL_FILE.file_type;     --declare a handle for the file
   BEGIN
      pkgctx :=
            plog.init ('WRAP2FILE', plevel => plog.ldebug, plogtable => TRUE);
      l_file_handle := UTL_FILE.fopen (p_path, p_file_name, 'W');

      FOR j IN (SELECT DISTINCT NAME, TYPE
                           FROM user_source
                          WHERE TYPE IN
                                   ('FUNCTION',
                                    'PROCEDURE',
                                    'PACKAGE',
                                    'PACKAGE BODY'
                                   )
                            AND NAME =
                                   DECODE (p_name,
                                           NULL, NAME,
                                           UPPER (p_name)
                                          )
                            AND NAME <> 'CSPKS_DEPLOY'
                       ORDER BY NAME)
      LOOP
         BEGIN
            l_count := 1;
            l_source (l_count) := 'CREATE OR REPLACE ';

            FOR i IN (SELECT text
                        --into l_source
                      FROM   user_source
                       WHERE NAME = j.NAME AND TYPE = j.TYPE)
            LOOP
               l_count := l_count + 1;
               l_source (l_count) := i.text;
            END LOOP;

            -- ONLY ENCRYPT IF THE STORE PROCEDURE IS PLAIN TEXT
            IF INSTR (UPPER (l_source (l_count)), 'END') > 0
            THEN
               l_wrap :=
                  SYS.DBMS_DDL.wrap (DDL      => l_source, lb => 1,
                                     ub       => l_count);

               FOR n IN 1 .. l_count
               LOOP
                  UTL_FILE.put_line (l_file_handle, l_wrap (n));
               END LOOP;

               UTL_FILE.put_line (l_file_handle, '/');
               UTL_FILE.fflush (l_file_handle);
               plog.DEBUG (pkgctx, 'WRAP2FILE ' || j.NAME);
            END IF;
         EXCEPTION
            WHEN OTHERS
            THEN
               p_error := p_error || j.NAME || ',';
               plog.DEBUG (pkgctx,
                           'ERROR WHEN WRAP ' || j.NAME || ': ' || SQLERRM
                          );
         --dbms_output.put_line('ERROR WHEN WRAP ' || J.NAME || ': ' || SQLERRM);
         END;
      END LOOP;

      IF UTL_FILE.is_open (l_file_handle)
      THEN
         UTL_FILE.fclose (l_file_handle);
      END IF;

      IF NVL (p_error, 'X') <> 'X' AND LENGTH (p_error) > 0
      THEN
         RETURN FALSE;
      ELSE
         RETURN TRUE;
      END IF;
   END fn_wrap2file;
END;

/
