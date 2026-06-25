IF COL_LENGTH('Productos', 'Tamano') IS NULL
BEGIN
    ALTER TABLE Productos
        ADD Tamano VARCHAR(80) NOT NULL
            CONSTRAINT DF_Productos_Tamano DEFAULT ('No especificado');
END;

IF COL_LENGTH('Productos', 'Material') IS NULL
BEGIN
    ALTER TABLE Productos
        ADD Material VARCHAR(80) NOT NULL
            CONSTRAINT DF_Productos_Material DEFAULT ('No especificado');
END;

EXEC sp_executesql N'
UPDATE Productos
SET
    Tamano = CASE
        WHEN Nombre COLLATE Latin1_General_CI_AI LIKE ''%20cm%'' THEN ''20cm''
        WHEN Nombre COLLATE Latin1_General_CI_AI LIKE ''%30cm%'' THEN ''30cm''
        WHEN Nombre COLLATE Latin1_General_CI_AI LIKE ''%XL%'' THEN ''XL''
        WHEN Nombre COLLATE Latin1_General_CI_AI LIKE ''%Grande%'' THEN ''Grande''
        ELSE ''Mediano''
    END,
    Material = CASE
        WHEN Nombre COLLATE Latin1_General_CI_AI LIKE ''%Ceramica%''
            OR CONVERT(NVARCHAR(MAX), Descripcion) COLLATE Latin1_General_CI_AI LIKE ''%Ceramica%''
            THEN ''Ceramica''
        WHEN Nombre COLLATE Latin1_General_CI_AI LIKE ''%Marmol%''
            OR CONVERT(NVARCHAR(MAX), Descripcion) COLLATE Latin1_General_CI_AI LIKE ''%Marmol%''
            THEN ''Marmol''
        WHEN Nombre COLLATE Latin1_General_CI_AI LIKE ''%Terracota%''
            OR CONVERT(NVARCHAR(MAX), Descripcion) COLLATE Latin1_General_CI_AI LIKE ''%Terracota%''
            THEN ''Terracota''
        WHEN Nombre COLLATE Latin1_General_CI_AI LIKE ''%Concreto%''
            OR CONVERT(NVARCHAR(MAX), Descripcion) COLLATE Latin1_General_CI_AI LIKE ''%Concreto%''
            THEN ''Concreto''
        WHEN Nombre COLLATE Latin1_General_CI_AI LIKE ''%Planta%''
            OR CONVERT(NVARCHAR(MAX), Descripcion) COLLATE Latin1_General_CI_AI LIKE ''%Planta%''
            THEN ''Natural''
        ELSE ''No especificado''
    END
WHERE Tamano = ''No especificado''
    OR Material = ''No especificado'';
';
