USE DB_VIAJAVA;
GO

-- 'PENDENTE','APROVADO', 'RECUSADO', 'ESTORNADO' - PAGAMENTO
-- 'PENDENTE', 'CONCLUÍDO', 'RECUSADO', 'CANCELADO'  - RESERVA

GO
-- Atualiza o status_reserva para 'CONFIRMADO' quando o pagamento for aprovado
-- Caso o pagamento seja recusado, a reserva terá o status atualizado para "recusado'
-- Caso o pagamento seja estornado, a reserva será cancelada
    
CREATE TRIGGER tg_pagamento
ON TB_PAGAMENTOS
AFTER INSERT, UPDATE
AS
BEGIN
    UPDATE R
    SET R.STATUS_RESERVA = CASE 
        WHEN I.STATUS_PAGAMENTO = 'APROVADO' THEN 'CONFIRMADO'
        WHEN I.STATUS_PAGAMENTO = 'RECUSADO' THEN 'RECUSADO'
        WHEN I.STATUS_PAGAMENTO = 'ESTORNADO' THEN 'CANCELADO'
                            END
    FROM TB_RESERVAS R
    INNER JOIN inserted I ON R.ID = I.RESERVA_ID
    WHERE I.STATUS_PAGAMENTO IN ('APROVADO', 'RECUSADO', 'ESTORNADO');
END
GO

-- =================================================================
-- TESTES DOS TRIGGERS DE PAGAMENTO
-- =================================================================

-- Primeiro, vamos criar algumas reservas de teste para testar os triggers
DECLARE @usuario_teste UNIQUEIDENTIFIER = (SELECT TOP 1 ID FROM TB_USUARIOS WHERE EMAIL = 'ana@email.com');
DECLARE @pacote_teste UNIQUEIDENTIFIER = (SELECT TOP 1 ID FROM TB_PACOTES WHERE TITULO = 'Praias do Nordeste');

-- Reservas para teste dos triggers
DECLARE @reserva_teste1 UNIQUEIDENTIFIER = NEWID();
DECLARE @reserva_teste2 UNIQUEIDENTIFIER = NEWID();
DECLARE @reserva_teste3 UNIQUEIDENTIFIER = NEWID();
DECLARE @reserva_teste4 UNIQUEIDENTIFIER = NEWID();
DECLARE @reserva_teste5 UNIQUEIDENTIFIER = NEWID();
DECLARE @reserva_teste6 UNIQUEIDENTIFIER = NEWID();

INSERT INTO TB_RESERVAS (ID, USUARIO_ID, PACOTE_ID, VALOR_TOTAL, DATA_VIAGEM, STATUS_RESERVA) VALUES
(@reserva_teste1, @usuario_teste, @pacote_teste, 1500.00, '2025-12-01', 'PENDENTE'),
(@reserva_teste2, @usuario_teste, @pacote_teste, 1500.00, '2025-12-02', 'PENDENTE'),
(@reserva_teste3, @usuario_teste, @pacote_teste, 1500.00, '2025-12-03', 'PENDENTE'),
(@reserva_teste4, @usuario_teste, @pacote_teste, 1500.00, '2025-12-04', 'PENDENTE'),
(@reserva_teste5, @usuario_teste, @pacote_teste, 1500.00, '2025-12-05', 'PENDENTE'),
(@reserva_teste6, @usuario_teste, @pacote_teste, 1500.00, '2025-12-06', 'PENDENTE');

-- =================================================================
-- TESTE 1: INSERT com STATUS_PAGAMENTO = 'APROVADO'
-- Deve atualizar STATUS_RESERVA para 'CONFIRMADO'
-- =================================================================
INSERT INTO TB_PAGAMENTOS (ID, RESERVA_ID, METODO, VALOR_PAGO, DATA_PAGAMENTO, STATUS_PAGAMENTO) 
VALUES (NEWID(), @reserva_teste1, 'PIX', 1500.00, GETDATE(), 'APROVADO');

-- =================================================================
-- TESTE 2: INSERT com STATUS_PAGAMENTO = 'RECUSADO'
-- Deve atualizar STATUS_RESERVA para 'RECUSADO'
-- =================================================================
INSERT INTO TB_PAGAMENTOS (ID, RESERVA_ID, METODO, VALOR_PAGO, DATA_PAGAMENTO, STATUS_PAGAMENTO) 
VALUES (NEWID(), @reserva_teste2, 'CARTAO', 1500.00, GETDATE(), 'RECUSADO');

-- =================================================================
-- TESTE 3: INSERT com STATUS_PAGAMENTO = 'ESTORNADO'
-- Deve atualizar STATUS_RESERVA para 'CANCELADO'
-- =================================================================
INSERT INTO TB_PAGAMENTOS (ID, RESERVA_ID, METODO, VALOR_PAGO, DATA_PAGAMENTO, STATUS_PAGAMENTO) 
VALUES (NEWID(), @reserva_teste3, 'BOLETO', 1500.00, GETDATE(), 'ESTORNADO');

-- =================================================================
-- TESTE 4: UPDATE de 'PENDENTE' para 'APROVADO'
-- Deve atualizar STATUS_RESERVA para 'CONFIRMADO'
-- =================================================================
-- Inserir pagamento pendente primeiro
DECLARE @pag_teste4 UNIQUEIDENTIFIER = NEWID();
INSERT INTO TB_PAGAMENTOS (ID, RESERVA_ID, METODO, VALOR_PAGO, DATA_PAGAMENTO, STATUS_PAGAMENTO) 
VALUES (@pag_teste4, @reserva_teste4, 'PIX', 1500.00, GETDATE(), 'PENDENTE');

-- Atualizar para aprovado
UPDATE TB_PAGAMENTOS 
SET STATUS_PAGAMENTO = 'APROVADO' 
WHERE ID = @pag_teste4;

-- =================================================================
-- TESTE 5: UPDATE de 'APROVADO' para 'ESTORNADO'
-- Deve atualizar STATUS_RESERVA para 'CANCELADO'
-- =================================================================
-- Inserir pagamento aprovado primeiro
DECLARE @pag_teste5 UNIQUEIDENTIFIER = NEWID();
INSERT INTO TB_PAGAMENTOS (ID, RESERVA_ID, METODO, VALOR_PAGO, DATA_PAGAMENTO, STATUS_PAGAMENTO) 
VALUES (@pag_teste5, @reserva_teste5, 'CARTAO', 1500.00, GETDATE(), 'APROVADO');

-- Atualizar para estornado
UPDATE TB_PAGAMENTOS 
SET STATUS_PAGAMENTO = 'ESTORNADO' 
WHERE ID = @pag_teste5;

-- =================================================================
-- TESTE 6: UPDATE de 'PENDENTE' para 'RECUSADO'
-- Deve atualizar STATUS_RESERVA para 'RECUSADO'
-- =================================================================
-- Inserir pagamento pendente primeiro
DECLARE @pag_teste6 UNIQUEIDENTIFIER = NEWID();
INSERT INTO TB_PAGAMENTOS (ID, RESERVA_ID, METODO, VALOR_PAGO, DATA_PAGAMENTO, STATUS_PAGAMENTO) 
VALUES (@pag_teste6, @reserva_teste6, 'BOLETO', 1500.00, GETDATE(), 'PENDENTE');

-- Atualizar para recusado
UPDATE TB_PAGAMENTOS 
SET STATUS_PAGAMENTO = 'RECUSADO' 
WHERE ID = @pag_teste6;

-- =================================================================
-- TESTE 7: INSERT com STATUS_PAGAMENTO = 'PENDENTE'
-- NÃO deve alterar STATUS_RESERVA (trigger só atua em APROVADO, RECUSADO, ESTORNADO)
-- =================================================================
DECLARE @reserva_teste7 UNIQUEIDENTIFIER = NEWID();
INSERT INTO TB_RESERVAS (ID, USUARIO_ID, PACOTE_ID, VALOR_TOTAL, DATA_VIAGEM, STATUS_RESERVA) 
VALUES (@reserva_teste7, @usuario_teste, @pacote_teste, 1500.00, '2025-12-07', 'PENDENTE');

INSERT INTO TB_PAGAMENTOS (ID, RESERVA_ID, METODO, VALOR_PAGO, DATA_PAGAMENTO, STATUS_PAGAMENTO) 
VALUES (NEWID(), @reserva_teste7, 'PIX', 1500.00, GETDATE(), 'PENDENTE');

-- =================================================================
-- VERIFICAÇÃO DOS RESULTADOS DOS TESTES
-- =================================================================
SELECT 
    R.STATUS_RESERVA,
    P.STATUS_PAGAMENTO,
    P.METODO,
    CASE 
        WHEN P.STATUS_PAGAMENTO = 'APROVADO' AND R.STATUS_RESERVA = 'CONFIRMADO' THEN 'OK'
        WHEN P.STATUS_PAGAMENTO = 'RECUSADO' AND R.STATUS_RESERVA = 'RECUSADO' THEN 'OK'
        WHEN P.STATUS_PAGAMENTO = 'ESTORNADO' AND R.STATUS_RESERVA = 'CANCELADO' THEN 'OK'
        WHEN P.STATUS_PAGAMENTO = 'PENDENTE' AND R.STATUS_RESERVA = 'PENDENTE' THEN 'OK'
        ELSE 'ERRO'
    END as RESULTADO_TESTE
FROM TB_RESERVAS R
INNER JOIN TB_PAGAMENTOS P ON R.ID = P.RESERVA_ID
WHERE R.ID IN (@reserva_teste1, @reserva_teste2, @reserva_teste3, @reserva_teste4, @reserva_teste5, @reserva_teste6, @reserva_teste7)
ORDER BY R.DATA_RESERVA;

-- =================================================================
-- LIMPEZA DOS DADOS DE TESTE DO TRIGGER
-- =================================================================

DELETE FROM TB_PAGAMENTOS WHERE RESERVA_ID IN (@reserva_teste1, @reserva_teste2, @reserva_teste3, @reserva_teste4, @reserva_teste5, @reserva_teste6, @reserva_teste7);
DELETE FROM TB_RESERVAS WHERE ID IN (@reserva_teste1, @reserva_teste2, @reserva_teste3, @reserva_teste4, @reserva_teste5, @reserva_teste6, @reserva_teste7);
GO