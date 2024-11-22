using Microsoft.AspNetCore.Mvc;

namespace Stashed.WebAPI.Models;

public static class ResponseError
{
    public static ObjectResult BadRequest(Exception e)
    {
        return BadRequest(e.Message);
    }

    public static ObjectResult BadRequest(string message)
    {
        return BuildObjectResult(400, message);
    }

    public static ObjectResult ServerError(Exception e)
    {
        return ServerError(e.Message);
    }

    public static ObjectResult ServerError(string message)
    {
        return BuildObjectResult(500, message);
    }

    private static ObjectResult BuildObjectResult(int statusCode, string message)
    {
        return new ObjectResult(new { Error = message })
        {
            StatusCode = statusCode
        };
    }
}