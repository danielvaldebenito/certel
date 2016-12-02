using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.Linq;
using System.Web;

/// <summary>
/// Descripción breve de StartPdf
/// </summary>
public class StartPdf
{
	public StartPdf(string filename)
	{
        string path = HttpContext.Current.Server.MapPath("~/pdf/") + filename;
        Process.Start(path);
	}
}