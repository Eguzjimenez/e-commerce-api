namespace Concre_Innova_API.Application.Security
{
    public class RequestUserContext
    {
        public int? UserId { get; set; }
        public int? RoleId { get; set; }
        public string RoleName { get; set; } = "Desconocido";
        public string IpAddress { get; set; } = string.Empty;
        public bool HasAuthenticatedIdentity { get; set; }

        public bool IsAuthenticated => HasAuthenticatedIdentity && UserId.HasValue && RoleId.HasValue;
    }
}
