<%@ WebHandler Language="C#" Class="Combobox" %>

using System;
using System.Web;
using System.Linq;
using System.Web.Script.Serialization;
using System.Collections.Generic;
public class Combobox : IHttpHandler {

    private static readonly log4net.ILog log = log4net.LogManager.GetLogger
   (System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
    public void ProcessRequest (HttpContext context) {

        log4net.Config.DOMConfigurator.Configure();
        var post = HttpContext.Current;
        var data = new object();
        var action = post.Request["1"];
        var serializer = new JavaScriptSerializer();

        switch (action)
        {
            case "tipoNorma":
                data = GetTipoNorma();
                break;
            case "clientes":
                data = GetClientes();
                break;
            case "aparatos":
                data = GetAparatos();
                break;
            case "inspectores":
                data = GetInspectores();
                break;
            case "tipoFuncionamiento":
                data = GetTipoFuncionamiento();
                break;
            case "normas":
                var norma = int.Parse(post.Request["norma"]);
                data = GetNormas(norma);
                break;
            case "tipoInforme":
                data = GetTipoInforme();
                break;
            case "destinoProyecto":
                data = GetDestinoProyecto();
                break;
            case "normasAsociadas":
                data = GetNormasInspeccion (post);
                break;
            case "titulosInspeccion":
                data = GetTitulosInspeccion(post);
                break;
            default:
                context.Response.Write("No se ha seleccionado ninguna opción");
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
    private static object GetTitulosInspeccion (HttpContext post)
    {
        try
        {
            var inspeccionId = int.Parse(post.Request["inspeccionId"]);
            using (var db = new CertelEntities())
            {
                var inspeccion = db.Inspeccion.Find(inspeccionId);
                var titles = new TitulosInspeccion(inspeccion).ListaInspeccion;

                var data = titles
                            .Distinct()
                            .Select(s => new {
                                Value = s.ID,
                                Text = s.Texto
                            })
                            .ToList();
                return new
                {
                    done = true,
                    message = "OK",
                    data = data
                };
            }
        }
        catch (Exception ex)
        {
            log.Error("Excepción Combobox/TitulosNorma", ex);
            return new { done = false, message = ex.ToString() };
        }
    }

    private static object GetNormasInspeccion (HttpContext post)
    {
        try
        {
            var inspeccionId = int.Parse(post.Request["inspeccionId"]);
            using (var db = new CertelEntities())
            {
                var data = db.InspeccionNorma
                            .Where(w => w.InspeccionID == inspeccionId)
                            .Distinct()
                            .OrderBy(o => o.Norma.NormasAsociadas1.Any())
                            .Select(s => new
                            {
                                Value = s.NormaID,
                                Text = s.Norma.Nombre
                            })
                            .ToList();
                return new
                {
                    done = true,
                    message = "OK",
                    data = data
                };
            }
        }
        catch (Exception ex)
        {
            log.Error("Excepción Combobox/NormasInspeccion", ex);
            return new { done = false, message = ex.ToString() };
        }
    }

    private static object GetDestinoProyecto()
    {
        try
        {
            using (var db = new CertelEntities())
            {
                var data = db.DestinoProyecto
                            .OrderBy(o => o.Descripcion)
                            .Select(s => new
                            {
                                Value = s.ID,
                                Text = s.Descripcion
                            })
                            .ToList();
                return new
                {
                    done = true,
                    message = "OK",
                    data = data
                };
            }
        }
        catch (Exception ex)
        {
            log.Error("Excepción Combobox/TipoInforme", ex);
            return new { done = false, message = ex.ToString() };
        }
    }
    private static object GetTipoInforme()
    {
        try
        {
            using (var db = new CertelEntities())
            {
                var data = db.TipoInforme
                            .OrderBy(o => o.Descripcion)
                            .Select(s => new
                            {
                                Value = s.ID,
                                Text = s.Descripcion
                            })
                            .ToList();
                return new
                {
                    done = true,
                    message = "OK",
                    data = data
                };
            }
        }
        catch (Exception ex)
        {
            log.Error("Excepción Combobox/TipoInforme", ex);
            return new { done = false, message = ex.ToString() };
        }
    }
    private static object GetNormas(int norma)
    {
        try
        {
            using (var db = new CertelEntities())
            {
                var data = db.Norma
                            .Where(w => w.ID != norma)
                            .OrderBy(o => o.Nombre)
                            .Select(s => new
                            {
                                Value = s.ID,
                                Text = s.Nombre
                            })
                            .ToList();
                return new
                {
                    done = true,
                    message = "OK",
                    data = data
                };
            }
        }
        catch (Exception ex)
        {
            log.Error("Excepción Combobox/Aparatos", ex);
            return new { done = false, message = ex.ToString() };
        }
    }

    private static object GetTipoFuncionamiento()
    {
        try
        {
            using (var db = new CertelEntities())
            {
                var data = db.TipoFuncionamientoAparato
                            .OrderBy(o => o.Descripcion)
                            .Select(s => new
                            {
                                Value = s.ID,
                                Text = s.Descripcion
                            })
                            .ToList();
                return new
                {
                    done = true,
                    message = "OK",
                    data = data
                };
            }
        }
        catch (Exception ex)
        {
            log.Error("Excepción Combobox/Aparatos", ex);
            return new { done = false, message = ex.ToString() };
        }
    }

    private static object GetAparatos()
    {
        try
        {
            using (var db = new CertelEntities())
            {
                var data = db.Aparato
                            .OrderBy(o => o.Nombre)
                            .Select(s => new
                            {
                                Value = s.ID,
                                Text = s.Nombre
                            })
                            .ToList();
                return new
                {
                    done = true,
                    message = "OK",
                    data = data
                };
            }
        }
        catch (Exception ex)
        {
            log.Error("Excepción Combobox/Aparatos", ex);
            return new { done = false, message = ex.ToString() };
        }
    }
    private static object GetInspectores()
    {
        try
        {
            using (var db = new CertelEntities())
            {
                var data = db.Usuario
                            .Where(w => w.UsuarioRol.Where(u => u.Rol == 1).Any())
                            .Select(s => new
                            {
                                Value = s.NombreUsuario,
                                Text = string.Concat(s.Nombre, " ", s.Apellido)
                            })
                            .ToList();
                return new
                {
                    done = true,
                    message = "OK",
                    data = data
                };
            }
        }
        catch (Exception ex)
        {
            log.Error("Excepción Combobox/TipoNorma", ex);
            return new { done = false, message = ex.ToString() };
        }
    }
    private static object GetTipoNorma()
    {
        try
        {
            using (var db = new CertelEntities())
            {
                var data = db.TipoNorma
                            .Select(s => new
                            {
                                Value = s.ID,
                                Text = s.Descripcion
                            })
                            .ToList();
                return new
                {
                    done = true,
                    message = "OK",
                    data = data
                };
            }
        }
        catch(Exception ex)
        {
            log.Error("Excepción Combobox/TipoNorma", ex);
            return new { done = false, message = ex.ToString() };
        }
    }

    private static object GetClientes()
    {
        try
        {
            using (var db = new CertelEntities())
            {
                var data = db.Cliente
                            .OrderBy(o => o.Nombre)
                            .Select(s => new
                            {
                                Value = s.ID,
                                Text = s.Nombre
                            })
                            .ToList();
                return new
                {
                    done = true,
                    message = "OK",
                    data = data
                };
            }
        }
        catch (Exception ex)
        {
            log.Error("Excepción Combobox/Clientes", ex);
            return new { done = false, message = ex.ToString() };
        }
    }
    public bool IsReusable {
        get {
            return true;
        }
    }

}