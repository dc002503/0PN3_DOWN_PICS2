CREATE OR REPLACE PACKAGE BODY OPEN.YZ_DESCARGA
AS
   PROCEDURE YZ_EXISTENCIA (FPATH       IN VARCHAR2,
                                           FFILE       IN VARCHAR2,
                                           ID_CCFILE   IN NUMBER)
   -- TAREA: Se necesita implantación para PROCEDURE FT_ENER_DOWN_FILES_UPD_CCFILE.YZ_EXISTENCIA
   AS
      BB               INT;
      h_fd             UTL_FILE.file_type;
      e_fatal          EXCEPTION;


      RUTA_Y_ARCHIVO   VARCHAR2 (5000);
   BEGIN
      BEGIN
         h_fd := UTL_FILE.fopen (fpath, ffile, 'r');
      EXCEPTION
         WHEN UTL_FILE.invalid_path
         THEN
            RAISE e_fatal;
         WHEN UTL_FILE.invalid_mode
         THEN
            RAISE e_fatal;
         WHEN UTL_FILE.invalid_operation
         THEN
            RAISE e_fatal;
         WHEN OTHERS
         THEN
            RAISE e_fatal;
      END;

      UTL_FILE.fclose (h_fd);
      BB := 0;

      RUTA_Y_ARCHIVO := (FPATH || FFILE);

      DBMS_OUTPUT.PUT_LINE ('29 ->' || 1);
      DBMS_OUTPUT.PUT_LINE ('Existe el archivo indicado ');
      DBMS_OUTPUT.PUT_LINE (
         'Existe:  ' || FPATH || ' junto el archivo:  ' || FFILE);

      /*

          BEGIN


        ---UPDATE
             UPDATE OPEN.CC_FILE
                SET FILE_SYS_LOCATION = RUTA_Y_ARCHIVO -- VA A LLENAR EL FILE_SYS CON LA NUEVA RUTA DE LA IMAGEN EN DISCO
              --,
              --FILE_SRC=

              WHERE FILE_ID = ID_CCFILE; -- ES LA REFERENCIA QUE HACE UNICA EL VAL DE ESTA TRANSACCION

              
      YZ_LOGS ('UPDATE BEGIN CC_FILE', '<: ');
      YZ_LOGS (' ID_FILE: ', ID_CCFILE);
      YZ_LOGS (' CONTENIDO: ', FPATH);
      YZ_LOGS (' : ', RUTA_Y_ARCHIVO);
      YZ_LOGS ('END UPDATE CC_FILE', ' :>');
      --END;

              */
      /*LOG*/
      YZ_LOGS ('Existe y ruta:  ', FPATH || ' ' || FFILE);
   EXCEPTION
      WHEN e_fatal
      THEN
         BB := 1;
         DBMS_OUTPUT.PUT_LINE ('39-> ' || 0);
         DBMS_OUTPUT.PUT_LINE (
               'No Existe la ruta indicada:  '
            || FPATH
            || 'junto el archivo:  '
            || FFILE);


         /*LOG*/
         YZ_LOGS ('No Existe la ruta indicada:  ',
                          FPATH || ' ' || FFILE);
      WHEN OTHERS
      THEN
         raise_application_error (-20000, ' OTRO TIPO DE ERROR NO MANEJADO ');
         YZ_LOGS ('OTRO TIPO DE ERROR NO MANEJADO :  ',
                          FPATH || ' ' || FFILE);

         --    BOUT:=1;
         BEGIN
            /*LOG*/
            YZ_LOGS ('ERROR AL MANEJAR:  ', FPATH || '' || FFILE);
         END;

         BB := 0;
         --   BOUT:=1;
         DBMS_OUTPUT.PUT_LINE ('53 -> ' || 0);
   -- TAREA:  FT_ENER_DOWN_FILES_UPD_CCFILE.YZ_EXISTENCIA
   END YZ_EXISTENCIA;



   PROCEDURE YZ_SELECT_ (fini IN VARCHAR2, ffin IN VARCHAR2)
   -- TAREA: Se necesita implantación para PROCEDURE FT_ENER_DOWN_FILES_UPD_CCFILE.YZ_SELECT_

   /* 4 sept 2019
   Guarda dentro de tabla ARCHIVOS_DESCARGADOS_TABLA -> el historial de los registros,
   y tambien guarda todas las tranasacciones que se operarom a
   LQ_PROCESS_LOG
   */

   IS
      /*  |||||||||||||||||||||||||||||||||||    VARIABLES    |||||||||||||||||||||||||||||||||||     */
      /*  |||||||||||||||||||||||||||||||||||    VARIABLES    |||||||||||||||||||||||||||||||||||     */

      ---VARIABLE QUE CAPTURA LA CONSTRUCCION DE LA FOTO
      NUERROR                 NUMBER;
      SBERROR                 VARCHAR2 (4000);
      NUINDCOMS               NUMBER := -1;

      --VARIABLE PARA LA CREACIN DE CARPETAS
      TIPOORDER               VARCHAR2 (4000);
      IDORDER                 VARCHAR2 (4000);
      LEGALORDER              VARCHAR2 (4000);
      NOMBREORDER             VARCHAR2 (4000);

      ---OBTENER EL ID
      FILEID                  NUMBER;

      -- CREA LA RUTA DEL ARCHIVO
      NOMBRE_ARCHIVO          VARCHAR2 (4000);

      --- PARA CREAR LA RUTAA
      NOMBRECONCATENA         VARCHAR2 (4000);
      RUTAFINAL               VARCHAR2 (4000);
      LIMPIANOMBRE            VARCHAR2 (4000);                     -- NO USADO
      flag_                   BOOLEAN := FALSE;                    -- NO USADO

      ---FILE TO WRITE
      CONTENIDO_SAV           VARCHAR2 (4000);
      FECHACREACION_ARCHIVO   VARCHAR2 (20);

      -- VERIFICA LA CONCAT DE LAS RUTAS
      STRING_RUTAF            VARCHAR2 (4000);
      STRING_ARCHIVOF         VARCHAR2 (4000);

      ---VERIFICA SI CREO EL ARCHIVO
      NUMOPERATORIO           NUMBER;


      v_file                  UTL_FILE.FILE_TYPE;
      d_directory1            VARCHAR2 (4000);

      /*  |||||||||||||||||||||||||||||||||||           |||||||||||||||||||||||||||||||||||     */
      /*  |||||||||||||||||||||||||||||||||||           |||||||||||||||||||||||||||||||||||     */

      --NIS-Orden-Nombre_archivo-Fecha_Legalizacion
      CURSOR CUCOMPSESU
      IS
       SELECT 
                
                "FILE_ID" FILE_ID
                ,
                "OBJECT_LEVEL" OBJECT_LEVEL --OR_ORDER
                ,
                TO_CHAR(CC.LOAD_DATE,'DDMMYYYY') LEGALIZATION_DATE --FECHA
                , 
                "OBJECT_ID" OBJECT_ID -- Identificador
                ,
                CC.FILE_NAME NombreOrdern --
                ,
                "FILE_NAME" V_LOB_IMAGE_NAME 
                ,
                FILE_SRC
                FROM CC_FILE CC
                WHERE 
                    CC.FILE_SRC IS NOT NULL 
                    AND
                    --LOAD_DATE BETWEEN '01012019' AND '02012019'
                      LOAD_DATE between fini and ffin
                  --  AND ROWNUM <10 
                 ORDER BY OBJECT_ID ASC
                ;
      -----CURSOR--
      SUBTYPE STYCOMPSE IS CUCOMPSESU%ROWTYPE;

      TYPE TYTBCOMS IS TABLE OF STYCOMPSE
         INDEX BY BINARY_INTEGER;

      TBCOMS                  TYTBCOMS;
   BEGIN
      TIPOORDER := '';
      IDORDER := '';
      LEGALORDER := '';
      NOMBREORDER := '';
      NOMBRECONCATENA := '';
      RUTAFINAL := '';

      --ASIGNA CERP AL ID DE LA TABLA
      NUMOPERATORIO := 0;

      /*LOG*/
      YZ_LOGS ('DescargaFotosAServidor',
                       'Inicia Proceso Extraer Datos Liquidacion');

      ------ SE ESCRIBE DENTRO DE LA TABLA DE LOGS
      FECHACREACION_ARCHIVO := CURRENT_DATE;

      -----Se valida que el CURSOR este cerrado
      IF CUCOMPSESU%ISOPEN
      THEN
         CLOSE CUCOMPSESU;
      END IF;

      -----Se ejecuta el cursor con las ordenes cuyos archivos serán descargados
      OPEN CUCOMPSESU;

      FETCH CUCOMPSESU
         BULK COLLECT INTO TBCOMS;

      CLOSE CUCOMPSESU;

      NUINDCOMS := TBCOMS.FIRST;

      /*LOG*/
      --CargaMensLog('FOTOS_OSF','Inicia procesos Fotos'||' Fecha Ini : '||to_char(fini)||' Fecha Fin: '||to_char(ffin));
      YZ_LOGS (
         'FOTOS_OSF',
            'Inicia procesos Fotos'
         || ' Fecha Ini : '
         || TO_CHAR (fini)
         || ' Fecha Fin: '
         || TO_CHAR (ffin));


      --CONTIENEN DATOS
      WHILE NUINDCOMS IS NOT NULL
      LOOP
         flag_ := TRUE;

         --ASIGNAR PUNTEROS
         TIPOORDER := (TBCOMS (NUINDCOMS).OBJECT_LEVEL);
         IDORDER := (TBCOMS (NUINDCOMS).OBJECT_ID);
         LEGALORDER := (TBCOMS (NUINDCOMS).LEGALIZATION_DATE);
         NOMBREORDER := (TBCOMS (NUINDCOMS).V_LOB_IMAGE_NAME);

         --OBTENER EL FILE_ID
         FILEID := (TBCOMS (NUINDCOMS).FILE_ID);

         /*LOG*/
         ---CargaMensLog('FOTOS_OSF','Orden : '||to_char(IDORDER));
         YZ_LOGS ('FOTOS_OSF', 'Orden : ' || TO_CHAR (IDORDER));

         /*  |||||||||||||||||||||||||||||||||||     CREAR CARPETAS       |||||||||||||||||||||||||||||||||||     */
         /*  |||||||||||||||||||||||||||||||||||     CREAR CARPETAS       |||||||||||||||||||||||||||||||||||     */
         /*                              */

        -- JAVA_ARC ('/openfotos'); ---Crea la carpeta base
         YZ_LOGS ('FOTOS_OSF', 'Crea la carpeta base: ' || '/opensmartflex15/imagenes2020/samuel');
         JAVA_ARC ('/opensmartflex15/imagenes2020/samuel'); ---Crea la carpeta base

         --1- CREA LA PRIMER CARPETA
         IF (TIPOORDER IS NULL)
          -- so OBJECT_LEVEL IS NULL  
         THEN
           YZ_LOGS ('FOTOS_', '? SE ENCONTRO UN REGISTRO QUE NO CONTIENE DESCRIPOR O ES NULO ');
            DBMS_OUTPUT.put_line (
                  '? SE ENCONTRO UN REGISTRO QUE NO CONTIENE DESCRIPOR O ES NULO '
               || IDORDER);
            DBMS_OUTPUT.put_line ('? LINE 98 ' || 'XD ');
            TIPOORDER := 'OR_ORDER'; --SE ESTABLECE POR DEFECTO YA QUE NO EXISTE DENTRO DE LA TABLA OR_ORDER
            NOMBRECONCATENA := '/';

            NOMBRECONCATENA := NOMBRECONCATENA || TIPOORDER;
            -- >>>> / OR
        --    JAVA_ARC ('/openfotos' || NOMBRECONCATENA); -- >>>> / OR
              JAVA_ARC ('/opensmartflex15/imagenes2020/samuel' || NOMBRECONCATENA); -- >>>> / OR
            ---2-CREA LA SEGUNDA CARPETA
            -- >>>> / OR / LEG
            NOMBRECONCATENA := NOMBRECONCATENA || '/' || LEGALORDER;
           -- JAVA_ARC ('/openfotos' || NOMBRECONCATENA); -- >>>> / OR / LEG
            JAVA_ARC ('/opensmartflex15/imagenes2020/samuel'|| NOMBRECONCATENA); -- >>>> / OR / LEG

            ----3-CREA LA SIGUENTES CARPETAS RECURSIVO
            -- >>>> / OR / LEG / OR_FECHA
            NOMBRECONCATENA :=
               NOMBRECONCATENA || '/' || TIPOORDER || '_' || IDORDER;               
          --  JAVA_ARC ('/openfotos' || NOMBRECONCATENA); -- >>>> / OR / LEG / OR_FECHA
               JAVA_ARC ('/opensmartflex15/imagenes2020/samuel'|| NOMBRECONCATENA); -- >>>> / OR / LEG / OR_FECHA
         /*-  - -- - - - Se usa el metodo que descargará el archivo - - - - - - - - - -*/
         /*-      - -- - - -                                        - - - - - - - - - -*/

         ---ASIGNAR EN NOMBRE DE LA VARIABLE FINAL
         ---CUNADO ENCUENTRA UN NULL -> REEMPLAZA EL VALOR
         ELSE
            NOMBRECONCATENA := '/';                               -- >>>> / OR
            NOMBRECONCATENA := NOMBRECONCATENA || TIPOORDER;      -- >>>> / OR
          --  JAVA_ARC ('/openfotos' || NOMBRECONCATENA);
            JAVA_ARC ('/opensmartflex15/imagenes2020/samuel' || NOMBRECONCATENA);
            --2-CREA LA SEGUNDA CARPETA -- >>>> / OR / LEG
            NOMBRECONCATENA := NOMBRECONCATENA || '/' || LEGALORDER;
            --JAVA_ARC ('/openfotos' || NOMBRECONCATENA); -- >>>> / OR / LEG
            
            JAVA_ARC ('/opensmartflex15/imagenes2020/samuel' || NOMBRECONCATENA);
           
            ---3-CREA LAS SIGUIENTES CARPETAS RECURSIVO  -- >>>> / OR / LEG / OR_FECHA
            NOMBRECONCATENA :=
               NOMBRECONCATENA || '/' || TIPOORDER || '_' || IDORDER;
           -- JAVA_ARC ('/openfotos' || NOMBRECONCATENA); -- >>>> / OR / LEG / OR_FECHA
           JAVA_ARC ('/opensmartflex15/imagenes2020/samuel' || NOMBRECONCATENA);
         END IF;

         ---PARA CREAR LA RUTA
         RUTAFINAL := NOMBRECONCATENA;

         /* --------DESCARGA FOTOS A CARPETA         */
         /* --------DESCARGA FOTOS A CARPETA         */

         ENER_DESCARGA_ARCHIVO (
            TBCOMS (NUINDCOMS).FILE_SRC,                 --Archivo a descargar
           -- '/openfotos' || RUTAFINAL, --Ruta donde quedará el archivoz
          '/opensmartflex15/imagenes2020/samuel' || RUTAFINAL,
               --'T_'||TBCOMS(NUINDCOMS).LEGALIZATION_DATE||'-'||TBCOMS(NUINDCOMS).NIS||'-'||TBCOMS(NUINDCOMS).SGC_ORDEN||'-'||TBCOMS(NUINDCOMS).OBJECT_ID||'-'||TBCOMS(NUINDCOMS).FILE_NAME); --Nombre del archivo
               TBCOMS (NUINDCOMS).LEGALIZATION_DATE
            || '-'          
            || TBCOMS (NUINDCOMS).OBJECT_ID
            || '-'
            || TBCOMS (NUINDCOMS).V_LOB_IMAGE_NAME);             --Nombre del archivo


         /*--PARA GUARDAR EL NOMBRE      */
         NOMBRE_ARCHIVO := (CONCAT (NOMBREORDER, '.txt'));


         /*INDICA SI LA CARPETA Y EL ARCHIVO FUERON CREADOS */
         STRING_RUTAF :=
           -- ('/openfotos' || RUTAFINAL || '/');
              ('/opensmartflex15/imagenes2020/samuel' || RUTAFINAL || '/');
         STRING_ARCHIVOF :=
            (   TBCOMS (NUINDCOMS).LEGALIZATION_DATE
             || '-'
             || TBCOMS (NUINDCOMS).OBJECT_ID
             || '-'
             || TBCOMS (NUINDCOMS).V_LOB_IMAGE_NAME);


         /*VERIFICA QUE EL ARCHIVO Y LA RUTA EXISTA. EN CASO CONTRARIO ESCRIBE EN LOGS*/

         /*SE ENVIA LA RUTA, NOMBRE DEL ARCHIVO, Y EL NUM DE FILE_ID
                 SI ES CORRECTO QUE EXISTE SOBRE ESCRIBE DENTRO DE CC_TABLE*/

         YZ_EXISTENCIA (STRING_RUTAF, STRING_ARCHIVOF, FILEID);

         --ESCRITURA DE ARCHIVOS
         CONTENIDO_SAV :=
            (   '   '
             || LEGALORDER
             || '    '
             || TIPOORDER
             || '   '
             || IDORDER
             || '    '
             || NOMBREORDER);

         /*LOG*/
         YZ_LOGS (
            'FOTOS_OSF',
               'NOMBRE_ARCHIVO'
            || '  : '
            || TO_CHAR (NOMBRE_ARCHIVO)
            || ' RUTA: '
            || TO_CHAR (RUTAFINAL));


         /*  ||||||||||||||||||||||||||||||||||| USING LQ_PROCESS_LOG 2   |||||||||||||||||||||||||||||||||||     */
         BEGIN
            INSERT INTO OPEN.YZ_ARCHIVOS_DESCARGAD (id_unk,
                                                            id_ccfile,
                                                            nombre_file,
                                                            direccion)
                 VALUES (OPEN.YZ_SECUEN.NEXTVAL,
                         FILEID,
                         NOMBRE_ARCHIVO,
                         RUTAFINAL);
         END;

         /*  |||||||||||||||||||||||||||||||||||              |||||||||||||||||||||||||||||||||||     */


         --CONTINUA CON LA SIGUIENTE TUPLA
         NUINDCOMS := TBCOMS.NEXT (NUINDCOMS);

         ---- LIMPIA LA VARIABLES DE LOS PUNTEROS CUANDO TERMINA UN CILO DEL LOOP
         TIPOORDER := '';
         IDORDER := '';
         LEGALORDER := '';
         NOMBREORDER := '';
         NOMBRECONCATENA := '';
         RUTAFINAL := '';
      END LOOP;

      COMMIT;
      
   EXCEPTION
      WHEN ex.CONTROLLED_ERROR
      THEN
         Errors.GETERROR (NUERROR, SBERROR);
         DBMS_OUTPUT.put_line ('ERROR CONTROLLED ');
         DBMS_OUTPUT.put_line ('error onuErrorCode: ' || NUERROR);
         DBMS_OUTPUT.put_line ('error osbErrorMess: ' || SBERROR);

         IF CUCOMPSESU%ISOPEN
         THEN
            CLOSE CUCOMPSESU;
         END IF;

         ROLLBACK;
      WHEN OTHERS
      THEN
         Errors.SETERROR;
         Errors.GETERROR (NUERROR, SBERROR);
         DBMS_OUTPUT.put_line ('ERROR CONTROLLED ');
         DBMS_OUTPUT.put_line ('error onuErrorCode: ' || NUERROR);
         DBMS_OUTPUT.put_line ('error osbErrorMess: ' || SBERROR);

         IF CUCOMPSESU%ISOPEN
         THEN
            CLOSE CUCOMPSESU;
         END IF;

         ROLLBACK;
   -- TAREA: FT_ENER_DOWN_FILES_UPD_CCFILE.YZ_SELECT_
   END YZ_SELECT_;



   PROCEDURE YZ_LOGS (v_process        IN VARCHAR2,
                              v_desc_process   IN VARCHAR2)
   -- TAREA: Se necesita implantación para PROCEDURE FT_ENER_DOWN_FILES_UPD_CCFILE.YZ_LOGS
   IS
   BEGIN
      INSERT INTO OPEN.LQ_PROCESS_LOG (PROCESS_USER,
                                       PROCESS_DATE,
                                       PROCESS_ID,
                                       PROCESS,
                                       PROCESS_DESC)
           VALUES (USER,
                   SYSDATE,
                   OPEN.SEQ_LQ_PROCESS_LOG.NEXTVAL,
                   v_process,
                   v_desc_process);
   -- TAREA: FT_ENER_DOWN_FILES_UPD_CCFILE.YZ_LOGS
   END YZ_LOGS;



   PROCEDURE YZ_DESCARGA_FO (p_blob         BLOB,
                                       p_directory    VARCHAR2,
                                       p_filename     VARCHAR2)
   -- TAREA: Se necesita implantación para PROCEDURE FT_ENER_DOWN_FILES_UPD_CCFILE.YZ_DESCARGA_FO
   IS
      t_fh    UTL_FILE.file_type;
      t_len   PLS_INTEGER := 32767;
   BEGIN
      t_fh := UTL_FILE.fopen (p_directory, p_filename, 'wb');

      FOR i IN 0 .. TRUNC ( (DBMS_LOB.getlength (p_blob) - 1) / t_len)
      LOOP
         UTL_FILE.put_raw (t_fh,
                           DBMS_LOB.SUBSTR (p_blob, t_len, i * t_len + 1));
      END LOOP;

      UTL_FILE.fclose (t_fh);
   -- TAREA: FT_ENER_DOWN_FILES_UPD_CCFILE.YZ_DESCARGA_FO
   END YZ_DESCARGA_FO;
END YZ_DESCARGA;


-------------------BODY ---
-------------------BODY ---
/
