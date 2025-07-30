USE DB_VIAJAVA;
GO

-- 'PENDENTE','APROVADO', 'RECUSADO', 'ESTORNADO' - PAGAMENTO
-- 'PENDENTE', 'CONCLUÍDO', 'RECUSADO', 'CANCELADO'  - RESERVA

GO
-- Atualiza o status_reserva para 'CONFIRMADO' quando o pagamento for APPROVED
-- Caso o pagamento seja recusado, a reserva terá o status atualizado para "recusado'
-- Caso o pagamento seja estornado, a reserva será cancelada
    
CREATE TRIGGER TG_PAYMENTS
ON TB_PAYMENTS
AFTER INSERT, UPDATE
AS
BEGIN
    UPDATE B
    SET B.BOOKING_STATUS = CASE 
        WHEN I.PAYMENT_STATUS = 'APPROVED' THEN 'CONFIRMED'
        WHEN I.PAYMENT_STATUS = 'REJECTED' THEN 'REJECTED'
        WHEN I.PAYMENT_STATUS = 'REFUNDED' THEN 'CANCELLED'
                            END
    FROM TB_BOOKINGS B
    INNER JOIN inserted I ON B.ID = I.BOOKING_ID
    WHERE I.PAYMENT_STATUS IN ('APPROVED', 'REJECTED', 'REFUNDED');
END
GO