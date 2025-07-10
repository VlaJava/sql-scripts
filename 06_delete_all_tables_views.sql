USE DB_VIAJAVA
GO

IF EXISTS(SELECT * FROM sys.tables WHERE name = 'TB_AVALIACOES')
DROP TABLE TB_AVALIACOES;
GO

IF EXISTS (SELECT * FROM sys.tables WHERE name = 'TB_PAGAMENTOS')
DROP TABLE TB_PAGAMENTOS;

IF EXISTS (SELECT * FROM sys.tables WHERE name = 'TB_VIAJANTES')
DROP TABLE TB_VIAJANTES
GO

IF EXISTS(SELECT * FROM sys.tables WHERE name = 'TB_RESERVAS')
DROP TABLE TB_RESERVAS;
GO

IF EXISTS(SELECT * FROM sys.tables WHERE name = 'TB_DOCUMENTOS')
DROP TABLE TB_DOCUMENTOS;
GO

IF EXISTS(SELECT * FROM sys.tables WHERE name = 'TB_ROLES')
DROP TABLE TB_ROLES;
GO

IF EXISTS(SELECT * FROM sys.tables WHERE name = 'TB_PACOTES')
DROP TABLE TB_PACOTES;
GO

IF EXISTS(SELECT * FROM sys.tables WHERE name = 'TB_USUARIOS')
DROP TABLE TB_USUARIOS;
GO

IF EXISTS (SELECT * FROM sys.views WHERE name = 'vw_general_metrics')
DROP VIEW vw_general_metrics 
GO

IF EXISTS (SELECT * FROM sys.views WHERE name = 'vw_faturamento_mensal')
DROP VIEW vw_faturamento_mensal
GO

IF EXISTS (SELECT * FROM sys.views WHERE name = 'vw_destinos_populares')
DROP VIEW vw_destinos_populares
GO

IF EXISTS (SELECT * FROM sys.views WHERE name = 'vw_metricas_gerais')
DROP VIEW vw_metricas_gerais
GO

IF EXISTS (SELECT * FROM sys.triggers WHERE name = 'tg_pagamento_concluido')
DROP TRIGGER tg_pagamento_concluido
GO

IF EXISTS (SELECT * FROM sys.triggers WHERE name = 'tg_pagamento_recusado')
DROP TRIGGER tg_pagamento_recusado
GO

SELECT * FROM sys.tables;
SELECT * FROM sys.views;
SELECT * FROM sys.triggers;


