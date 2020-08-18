CREATE OR REPLACE PACKAGE   YZ_DESCARGA
AS
   PROCEDURE YZ_EXISTENCIA (FPATH       IN VARCHAR2,
                                           FFILE       IN VARCHAR2,
                                           ID_CCFILE   IN NUMBER);

   PROCEDURE YZ_SELECT_ (FINI IN VARCHAR2, FFIN IN VARCHAR2);

   PROCEDURE YZ_LOGS (V_PROCESS        IN VARCHAR2,
                              V_DESC_PROCESS   IN VARCHAR2);

   PROCEDURE YZ_DESCARGA_FO (P_BLOB         BLOB,
                                       P_DIRECTORY    VARCHAR2,
                                       P_FILENAME     VARCHAR2);
END YZ_DESCARGA; 