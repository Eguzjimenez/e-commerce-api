using System.Net.Mail;

namespace Concre_Innova_API.Shared.Helpers
{
    public static class EmailAddressValidator
    {
        public static bool IsValid(string? email)
        {
            if (string.IsNullOrWhiteSpace(email))
                return false;

            try
            {
                var address = new MailAddress(email);
                return address.Address == email.Trim();
            }
            catch
            {
                return false;
            }
        }
    }
}
