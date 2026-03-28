      ******************************************************************
      *  Open Cobol ESQL (Ocesql) Sample Program
      *
      *  FETCHTBL --- demonstrates CONNECT, SELECT COUNT(*),
      *               DECLARE cursor, FETCH cursor, COMMIT,
      *               ROLLBACK, DISCONNECT
      *
      *  Copyright 2013 Tokyo System House Co., Ltd.
      ******************************************************************
       IDENTIFICATION              DIVISION.
      ******************************************************************
       PROGRAM-ID.                 FETCH-POLICY.
       AUTHOR.                     TSH.
       DATE-WRITTEN.               2013-06-28.

      ******************************************************************
       DATA                        DIVISION.
      ******************************************************************
       WORKING-STORAGE             SECTION.
       01  D-POL-REC.
           05  D-POL-ID            PIC  X(10).
           05  FILLER              PIC  X(2)  VALUE SPACE.
           05  D-POL-HOLDER        PIC  X(20).
           05  FILLER              PIC  X(2)  VALUE SPACE.
           05  D-POL-PREMIUM       PIC  ZZ,ZZZ,ZZ9.
           05  FILLER              PIC  X(2)  VALUE SPACE.
           05  D-POL-STATUS        PIC  X(10).

       EXEC SQL BEGIN DECLARE SECTION END-EXEC.
       01  DBNAME                  PIC  X(30) VALUE "testdb".
       01  USERNAME                PIC  X(30) VALUE "postgres".
       01  PASSWD                  PIC  X(10) VALUE SPACE.

       01  POL-REC-VARS.
           05  POL-ID              PIC  X(10).
           05  POL-HOLDER          PIC  X(50).
           05  POL-PREMIUM         PIC  S9(10)V99.
           05  POL-STATUS          PIC  X(10).

       01  POL-CNT                 PIC  9(04).
       EXEC SQL END DECLARE SECTION END-EXEC.

       EXEC SQL INCLUDE SQLCA END-EXEC.
      ******************************************************************
       PROCEDURE                   DIVISION.
      ******************************************************************
       MAIN-RTN.
           DISPLAY "*** FETCH POLICY STARTED ***".

      *    WHENEVER IS NOT YET SUPPORTED :(
      *      EXEC SQL WHENEVER SQLERROR PERFORM ERROR-RTN END-EXEC.

      *    CONNECT
           MOVE  "testdb"          TO   DBNAME.
           MOVE  "postgres"        TO   USERNAME.
           MOVE  SPACE             TO   PASSWD.
           EXEC SQL
               CONNECT :USERNAME IDENTIFIED BY :PASSWD USING :DBNAME
           END-EXEC.
           IF  SQLCODE NOT = ZERO PERFORM ERROR-RTN STOP RUN.

      *    SELECT COUNT(*) INTO HOST-VARIABLE
           EXEC SQL
               SELECT COUNT(*) INTO :POL-CNT FROM policies
           END-EXEC.
           DISPLAY "TONG SO DON BAO HIEM: " POL-CNT.

      *    DECLARE CURSOR
           EXEC SQL
               DECLARE C1 CURSOR FOR
               SELECT policy_id, holder_name, premium, status
                      FROM policies
                      ORDER BY policy_id
           END-EXEC.
           EXEC SQL
               OPEN C1
           END-EXEC.

      *    FETCH
           DISPLAY "---- -------------------- ------".
           DISPLAY "NO   NAME                 SALARY".
           DISPLAY "---- -------------------- ------".

           EXEC SQL
               FETCH C1 INTO :POL-ID, :POL-HOLDER, :POL-PREMIUM,
                                :POL-STATUS
           END-EXEC.
           PERFORM UNTIL SQLCODE NOT = ZERO
              MOVE  POL-ID          TO    D-POL-ID
              MOVE  POL-HOLDER      TO    D-POL-HOLDER
              MOVE  POL-PREMIUM     TO    D-POL-PREMIUM
              MOVE  POL-STATUS      TO    D-POL-STATUS
              DISPLAY D-POL-REC

              EXEC SQL
                  FETCH C1 INTO :POL-ID, :POL-HOLDER, :POL-PREMIUM,
                                :POL-STATUS
              END-EXEC
           END-PERFORM.

      *    CLOSE CURSOR
           EXEC SQL
               CLOSE C1
           END-EXEC.

      *    COMMIT
           EXEC SQL
               COMMIT WORK
           END-EXEC.

      *    DISCONNECT
           EXEC SQL
               DISCONNECT ALL
           END-EXEC.

      *    END
           DISPLAY "*** FETCHTBL FINISHED ***".
           STOP RUN.
           

      ******************************************************************
       ERROR-RTN.
      ******************************************************************
           DISPLAY "*** SQL ERROR ***".
           DISPLAY "SQLCODE: " SQLCODE " " NO ADVANCING.
           EVALUATE SQLCODE
              WHEN  +10
                 DISPLAY "Record not found"
              WHEN  -01
                 DISPLAY "Connection falied"
              WHEN  -20
                 DISPLAY "Internal error"
              WHEN  -30
                 DISPLAY "PostgreSQL error"
                 DISPLAY "ERRCODE: "  SQLSTATE
                 DISPLAY SQLERRMC
              *> TO RESTART TRANSACTION, DO ROLLBACK.
                 EXEC SQL
                     ROLLBACK
                 END-EXEC
              WHEN  OTHER
                 DISPLAY "Undefined error"
                 DISPLAY "ERRCODE: "  SQLSTATE
                 DISPLAY SQLERRMC
           END-EVALUATE.
      ******************************************************************
