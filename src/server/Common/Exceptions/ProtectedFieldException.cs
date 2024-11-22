namespace Stashed.Common.Exceptions;

public class ProtectedFieldException : Exception
{
    public ProtectedFieldException(string message) : base(message)
    {
    }
}