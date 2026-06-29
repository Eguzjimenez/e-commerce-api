using Concre_Innova_API.Application.Interfaces.Services;
using System.Collections.Concurrent;

namespace Concre_Innova_API.Application.Services
{
    public class LoginAttemptService : ILoginAttemptService
    {
        private const int MaximumFailedAttempts = 5;
        private static readonly TimeSpan LockoutDuration = TimeSpan.FromMinutes(15);
        private static readonly ConcurrentDictionary<string, LoginAttemptState> AttemptsByEmail =
            new(StringComparer.OrdinalIgnoreCase);

        public bool IsBlocked(string email, out DateTime? blockedUntil)
        {
            blockedUntil = null;
            var normalizedEmail = NormalizeEmail(email);

            if (!AttemptsByEmail.TryGetValue(normalizedEmail, out var state))
                return false;

            if (state.BlockedUntil is null)
                return false;

            if (state.BlockedUntil <= DateTime.UtcNow)
            {
                AttemptsByEmail.TryRemove(normalizedEmail, out _);
                return false;
            }

            blockedUntil = state.BlockedUntil;
            return true;
        }

        public void RecordFailedAttempt(string email)
        {
            var normalizedEmail = NormalizeEmail(email);

            AttemptsByEmail.AddOrUpdate(
                normalizedEmail,
                _ => new LoginAttemptState { FailedAttempts = 1 },
                (_, current) =>
                {
                    current.FailedAttempts++;

                    if (current.FailedAttempts >= MaximumFailedAttempts)
                        current.BlockedUntil = DateTime.UtcNow.Add(LockoutDuration);

                    return current;
                });
        }

        public void ResetAttempts(string email)
        {
            AttemptsByEmail.TryRemove(NormalizeEmail(email), out _);
        }

        private static string NormalizeEmail(string email)
        {
            return string.IsNullOrWhiteSpace(email) ? string.Empty : email.Trim().ToLowerInvariant();
        }

        private class LoginAttemptState
        {
            public int FailedAttempts { get; set; }
            public DateTime? BlockedUntil { get; set; }
        }
    }
}
