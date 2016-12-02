<%@ WebHandler Language="C#" Class="Informes" %>

using System;
using System.Web;
using System.Linq;
using System.Web.Script.Serialization;
using System.Linq.Dynamic;
using System.Web.SessionState;
using System.Collections.Generic;
using System.IO;

public class Informes : IHttpHandler, IRequiresSessionState
{

    private static readonly log4net.ILog log = log4net.LogManager.GetLogger
  (System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
    public void ProcessRequest (HttpContext context) {
        log4net.Config.DOMConfigurator.Configure();
        var post = HttpContext.Current;
        var data = new object();
        var action = post.Request["1"];
        var serializer = new JavaScriptSerializer();
        string sidx, sord;
        int page, rows;
        switch (action)
        {
            case "getStruct":
                data = GetStruct(post);
                break;
        }
        if (data != null)
        {
            var json = serializer.Serialize(data);
            context.Response.ContentType = "application/json";
            context.Response.Write(json);
            context.Response.Flush();

        }
    }

    private static object Plantilla2(HttpContext post)
    {
        try
        {
            using (var db = new CertelEntities())
            {
                return null;
            }
        }
        catch (Exception ex)
        {
            log.Error("SetInforme/Plantilla", ex);
            return new { done = false, message = ex.ToString() };
        }
    }

    private static object GetStruct(HttpContext post)
    {
        try
        {
            using (var db = new CertelEntities())
            {
                var id = int.Parse(post.Request["id"]);
                var inspeccion = db.Inspeccion
                                    .Where(w => w.ID == id)
                                    .FirstOrDefault();
                var estructuraList = db.EstructuraInfome.ToList();
                var list = new List<Plantilla>();
                // titulo
                var title = estructuraList
                                .Where(w => w.ID == 0)
                                    .Select(s => new Plantilla
                                    {
                                        Id = s.ID,
                                        Title = string.Format(s.Título, inspeccion.Aparato.Nombre).ToUpper(),
                                        Nombre = s.Nombre,
                                        Custom = s.CustomInforme
                                                    .Where(w => w.InspeccionID == id)
                                                    .Select(c => c.Texto).FirstOrDefault(),
                                        Text = s.Texto
                                    }).FirstOrDefault();
                list.Add(title);

                // 1
                var inspeccionDe = estructuraList
                                    .Where(w => w.ID == 1)
                                    .Select(s => new Plantilla
                                    {
                                        Id = s.ID,
                                        Nombre = s.Nombre,
                                        Title = string.Format(s.Título, inspeccion.Aparato.Nombre, inspeccion.DestinoProyecto).ToUpper(),
                                        Custom = s.CustomInforme
                                                    .Where(w => w.InspeccionID == id)
                                                    .Select(c => c.Texto).FirstOrDefault(),
                                        Text = string.Format(s.Texto, inspeccion.Fase, inspeccion.Aparato.Nombre, inspeccion.DestinoProyecto, inspeccion.DestinoProyecto)
                                    }).FirstOrDefault();
                list.Add(inspeccionDe);
                
                // subtitulo
                var subTitle = estructuraList
                                    .Where(w => w.ID == 2)
                                    .Select(s => new Plantilla
                                    {
                                        Id = s.ID,
                                        Title = string.Format(s.Título, inspeccion.IT).ToUpper(),
                                        Nombre = s.Nombre,
                                        Custom = s.CustomInforme
                                                    .Where(w => w.InspeccionID == id)
                                                    .Select(c => c.Texto).FirstOrDefault(),
                                        Text = s.Texto
                                    }).FirstOrDefault();
                list.Add(subTitle);
                
                
                
                // alcance

                var alcance = estructuraList
                                    .Where(w => w.ID == 3)
                                    .Select(s => new Plantilla
                                    {
                                        Id = s.ID,
                                        Nombre = s.Nombre,
                                        Title = s.Título,
                                        Custom = s.CustomInforme
                                                    .Where(w => w.InspeccionID == id)
                                                    .Select(c => c.Texto).FirstOrDefault(),
                                        Text = string.Format(s.Texto, inspeccion.Aparato.Nombre, inspeccion.InspeccionNorma.Select(n => n.Norma.Nombre).FirstOrDefault(), inspeccion.Aparato.Nombre, inspeccion.Aparato.Nombre), 
                                    }).FirstOrDefault();
                list.Add(inspeccionDe);



                return new
                {
                    done = true,
                    data = list
                };
            }
        }
        catch (Exception ex)
        {
            log.Error("Informe/GetStruct", ex);
            return new { done = false, message = ex.ToString() };
        }
    }
    public bool IsReusable {
        get {
            return true;
        }
    }

    
    public class Plantilla
    {
        public int Id { get; set; }
        public string Nombre { get; set; }
        public string Text { get; set; }
        public string Title { get; set; }
        public string Custom { get; set; }
    }
}