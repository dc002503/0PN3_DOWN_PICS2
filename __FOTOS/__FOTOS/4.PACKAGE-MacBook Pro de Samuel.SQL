create or replace PACKAGE   YZ_DESCARGA
AS
   PROCEDURE OPEN.YZ_EXISTENCIA (FPATH       IN VARCHAR2,
                                           FFILE       IN VARCHAR2,
                                           ID_CCFILE   IN NUMBER);

   PROCEDURE OPEN.YZ_SELECT_ (fini IN VARCHAR2, ffin IN VARCHAR2);

   PROCEDURE OPEN.YZ_LOGS (v_process        IN VARCHAR2,
                              v_desc_process   IN VARCHAR2);

   PROCEDURE OPEN.YZ_DESCARGA_FO (p_blob         BLOB,
                                       p_directory    VARCHAR2,
                                       p_filename     VARCHAR2);
END OPEN.YZ_DESCARGA;