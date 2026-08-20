namespace Concre_Innova_API.Application.DTOs.Responses
{
    /// <summary>Fila del listado de facturas del administrador.</summary>
    public class FacturaItemResponseDto
    {
        public int IdVenta { get; set; }
        public int IdPedido { get; set; }
        public DateTime FechaVenta { get; set; }
        public DateTime? FechaVencimiento { get; set; }
        public string? MetodoPago { get; set; }
        public string? EstadoPago { get; set; }
        public decimal Total { get; set; }
        public string? Observaciones { get; set; }
        public string? EstadoPedido { get; set; }
        public int? IdCliente { get; set; }
        public string? Cliente { get; set; }
        public string? CorreoCliente { get; set; }
        public int TotalPagos { get; set; }
        public decimal MontoPagado { get; set; }
        public string? EstadoFactura { get; set; }
        public int? DiasParaVencer { get; set; }
    }

    /// <summary>Totales del filtro aplicado, para el encabezado de la vista.</summary>
    public class FacturaResumenResponseDto
    {
        public int TotalPagadas { get; set; }
        public int TotalPendientes { get; set; }
        public int TotalVencidas { get; set; }
        public int TotalEnRevision { get; set; }
        public decimal MontoPorCobrar { get; set; }
    }

    public class FacturaListadoResponseDto : PaginatedResponseDto<FacturaItemResponseDto>
    {
        public FacturaResumenResponseDto Resumen { get; set; } = new();
    }

    public class FacturaLineaResponseDto
    {
        public int IdDetalle { get; set; }
        public int IdProducto { get; set; }
        public string? NombreProducto { get; set; }
        public string? NombreVariante { get; set; }
        public int Cantidad { get; set; }
        public decimal PrecioUnitario { get; set; }
        public decimal Subtotal { get; set; }
    }

    public class FacturaPagoResponseDto
    {
        public int IdPago { get; set; }
        public decimal Monto { get; set; }
        public DateTime? FechaPago { get; set; }
        public string? MetodoPago { get; set; }
        public string? Referencia { get; set; }
        public string? ComprobanteArchivo { get; set; }
    }

    public class FacturaDetalleResponseDto
    {
        public int IdVenta { get; set; }
        public int IdPedido { get; set; }
        public DateTime FechaVenta { get; set; }
        public DateTime? FechaVencimiento { get; set; }
        public string? MetodoPago { get; set; }
        public string? EstadoPago { get; set; }
        public decimal Total { get; set; }
        public string? Observaciones { get; set; }
        public string? EstadoPedido { get; set; }
        public DateTime? FechaPedido { get; set; }
        public string? DireccionEntrega { get; set; }
        public string? Cliente { get; set; }
        public string? CorreoCliente { get; set; }
        public string? TelefonoCliente { get; set; }
        public string? EstadoFactura { get; set; }

        public IEnumerable<FacturaLineaResponseDto> Lineas { get; set; } =
            Array.Empty<FacturaLineaResponseDto>();

        public IEnumerable<FacturaPagoResponseDto> Pagos { get; set; } =
            Array.Empty<FacturaPagoResponseDto>();
    }
}
