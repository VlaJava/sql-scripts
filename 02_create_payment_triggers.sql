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
