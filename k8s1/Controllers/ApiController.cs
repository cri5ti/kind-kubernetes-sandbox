using System;
using System.Diagnostics;
using System.Linq;
using System.Security.Cryptography;
using System.Text;
using System.Threading;
using Microsoft.AspNetCore.Mvc;

namespace k8s1.Controllers
{
	[ApiController]
	[Route("[controller]")]
	public class ApiController : ControllerBase
	{
		[HttpGet]
		public string Get()
		{
			return "Guid: " + StaticGuid + " at " + DateTime.Now.ToString();
		}
		
		[HttpGet("compute")]
		public string LongCompute([FromQuery] int seconds = 1)
		{
			var count = 0;
			
			var watch = Stopwatch.StartNew();

			SpinWait.SpinUntil(() =>
			{
				count++;
				sha512();
				return false;
			}, TimeSpan.FromSeconds(seconds));
			
			watch.Stop();

			return $"computed {count} sha512 hashes in {watch.Elapsed}";
		}
		
		public static long sha512()
		{
			var data = Encoding.UTF8.GetBytes(generateStringToHash());
			using var hash = SHA512.Create();
			var h = hash.ComputeHash(data);
			return h.Aggregate(0, (i, b) => (byte) (i ^ b));
		}
 
		public static String generateStringToHash()
		{
			return Guid.NewGuid().ToString() + DateTime.Now.ToString();
		}
		
		static readonly Guid StaticGuid = Guid.NewGuid();
	}
}