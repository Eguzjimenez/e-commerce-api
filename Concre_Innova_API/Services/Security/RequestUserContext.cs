namespace Concre_Innova_API.Services.Security
{
    public class RequestUserContext
    {
        public int? UserId { get; set; }
        public int? RoleId { get; set; }
        public string RoleName { get; set; } = "Desconocido";
        public string IpAddress { get; set; } = string.Empty;

        public bool IsAuthenticated => UserId.HasValue && RoleId.HasValue;
    }
}
