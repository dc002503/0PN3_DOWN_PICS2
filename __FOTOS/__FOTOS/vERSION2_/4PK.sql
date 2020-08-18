CREATE OR REPLACE PACKAGE OPEN.FT_ENER_SEIS_MESES_UPD
AS
---00 LA RUTA TIENE QUE LLEVAR / XXXXXXX /
--1
  PROCEDURE CREAR_CARPETAS (fini IN VARCHAR2, ffin IN VARCHAR2, ruta_descarga IN VARCHAR2);
  
--2
   PROCEDURE LOG_RUTAS (v_process        IN VARCHAR2,
                              v_desc_process   IN VARCHAR2);

-- 3
  PROCEDURE DESCARGA_FOTOS (p_blob         BLOB,
                                       p_directory    VARCHAR2,
                                       p_filename     VARCHAR2);

--4  
   PROCEDURE LOG_EXISTENCIA(FPATH       IN VARCHAR2,
                                           FFILE       IN VARCHAR2,
                                           ID_CCFILE   IN NUMBER);

 

END FT_ENER_SEIS_MESES_UPD;
/