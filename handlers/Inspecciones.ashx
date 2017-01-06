<%@ WebHandler Language="C#" Class="Inspecciones" %>

using System;
using System.Web;
using System.Linq;
using System.Web.Script.Serialization;
using System.Linq.Dynamic;
using System.Web.SessionState;
using System.Collections.Generic;
using System.IO;
public class Inspecciones : IHttpHandler, IRequiresSessionState
{

    private static readonly log4net.ILog log = log4net.LogManager.GetLogger
   (System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
    public void ProcessRequest(HttpContext context)
    {
        log4net.Config.DOMConfigurator.Configure();
        var post = HttpContext.Current;
        var data = new object();
        var action = post.Request["1"];
        var serializer = new JavaScriptSerializer();
        string sidx, sord;
        int page, rows;
        DataUser ds = (DataUser)context.Session["dataUser"];
        if (ds == null)
            context.Response.Redirect("certificaciondeascensores.cl");
        switch (action)
        {
            case "grid":
                sidx = post.Request["sidx"];
                sord = post.Request["sord"];
                page = int.Parse(post.Request["page"]);
                rows = int.Parse(post.Request["rows"]);
                var it = post.Request["it"];
                var desde = post.Request["desde"].Trim();
                DateTime? dDesde = null;
                if (desde != string.Empty)
                    dDesde = DateTime.ParseExact(desde, "dd-MM-yyyy", null);
                var hasta = post.Request["hasta"].Trim();
                DateTime? dHasta = null;
                if (hasta != string.Empty)
                    dHasta = DateTime.ParseExact(hasta, "dd-MM-yyyy", null).AddDays(1);
                data = GetInspecciones(sidx, sord, page, rows, it, dDesde, dHasta, ds);
                break;
            case "getInspeccion":
                var id = int.Parse(post.Request["id"]);
                data = GetInspeccion(id);
                break;
            case "getSpecificDataInspeccion":
                var id1 = int.Parse(post.Request["id"]);
                data = GetSpecificDataInspeccion(id1);
                break;
            case "editSpecificDataInspeccion":
                var info = post.Request["info"];
                var inspeccion = int.Parse(post.Request["inspeccion"]);
                var all = bool.Parse(post.Request["all"]);
                data = EditSpecificDataInspeccion(info, inspeccion, all);
                break;
            case "getNormas":
                var inspeccionId1 = int.Parse(post.Request["id"]);
                data = GetNormas(inspeccionId1);
                break;
            case "addOrRemoveNorma":
                var aor_id = int.Parse(post.Request["id"]);
                var aor_state = bool.Parse(post.Request["state"]);
                var aor_inspeccion = int.Parse(post.Request["inspeccion"]);
                data = AddOrRemoveNorma(aor_inspeccion, aor_id, aor_state);
                break;
            case "getCheckList":
                var inspeccionId = int.Parse(post.Request["id"]);
                var titleId = int.Parse(post.Request["title"]);
                data = GetCheckList(inspeccionId, titleId);
                break;
            case "getCheckListF2":
                var inspeccionId2 = int.Parse(post.Request["id"]);
                data = GetCheckListF2(inspeccionId2);
                break;
            case "setCumplimiento":
                var sc_cumplimiento = int.Parse(post.Request["cumplimiento"]);
                var sc_caracteristica = int.Parse(post.Request["caracteristica"]);
                var sc_inspeccion = int.Parse(post.Request["inspeccion"]);
                data = SetCumplimiento(sc_cumplimiento, sc_caracteristica, sc_inspeccion);
                break;
            case "writeObservacion":
                data = WriteObservacion(post);
                break;
            case "uploadImage":
                data = UploadImage(post);
                break;
            case "uploadImageTecnica":
                data = UploadImageTecnica(post);
                break;
            case "getPhotos":
                data = GetPhotos(post);
                break;
            case "removePhoto":
                data = RemovePhoto(post);
                break;
            case "saveCalificacion":
                data = SaveCalificacion(post, ds);
                break;
            case "saveObservacionTecnica":
                data = SaveObservacionTecnica(post);
                break;
            case "editOT":
                data = EditOT(post);
                break;
            case "getObservacionesTecnicas":
                data = GetObservacionesTecnicas(post);
                break;
            case "removeObservacionTecnica":
                data = RemoveObservacionTecnica(post);
                break;
            case "setTipoInforme":
                data = SetTipoInforme(post);
                break;
            case "deleteInspeccion":
                data = DeleteInspeccion(post);
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
    private static object Plantilla(HttpContext post)
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
            log.Error("Inspecciones/Plantilla", ex);
            return new { done = false, message = ex.ToString() };
        }
    }
    private static object EditOT(HttpContext post)
    {
        try
        {
            var id = int.Parse(post.Request["id"]);
            var texto = post.Request["text"];
            using (var db = new CertelEntities())
            {
                var ot = db.ObservacionTecnica.Find(id);
                ot.Texto = texto;
                db.SaveChanges();
                return new { done = true, message = "Registro Actualizado" };
            }
        }
        catch (Exception ex)
        {
            log.Error("Inspecciones/EditOT", ex);
            return new { done = false, message = ex.ToString() };
        }
    }
    private static object DeleteInspeccion(HttpContext post)
    {
        try
        {
            var inspeccionId = int.Parse(post.Request["id"]);
            using (var db = new CertelEntities())
            {
                var inspeccion = db.Inspeccion.Find(inspeccionId);
                if(inspeccion == null)
                    return new { done = false, message = "Esta inspección ya no existe" };
                var path = HttpContext.Current.Server.MapPath("~/fotos/");

                if(inspeccion.Inspeccion1.Any())
                    return new { done = false, message = "Esta inspección tiene una inspección en Fase 2, cuando finalice la fase 2, puede eliminarla." };
                var cumplimientos = inspeccion.Cumplimiento.ToList();
                cumplimientos.ForEach(f => {
                    var fotos = f.Fotografias.ToList();
                    fotos.ForEach(ff =>
                    {
                        if(File.Exists(path + ff.URL))
                            File.Delete(path + ff.URL);
                        db.Fotografias.Remove(ff);
                    });
                    db.Cumplimiento.Remove(f);
                });
                var obsTecns = inspeccion.ObservacionTecnica.ToList();
                obsTecns.ForEach(f => {
                    var fotos = f.FotografiaTecnica.ToList();
                    fotos.ForEach(ff => {
                        if(File.Exists(path + ff.URL))
                            File.Delete(path + ff.URL);
                        db.FotografiaTecnica.Remove(ff);
                    });
                    db.ObservacionTecnica.Remove(f);
                });
                var inspeccionNorma = inspeccion.InspeccionNorma.ToList();
                inspeccionNorma.ForEach(f => { db.InspeccionNorma.Remove(f); });
                var informes = inspeccion.Informe.ToList();
                informes.ForEach(f => { db.Informe.Remove(f); });
                var valores = inspeccion.ValoresEspecificos.ToList();
                valores.ForEach(f => { db.ValoresEspecificos.Remove(f); });
                db.Inspeccion.Remove(inspeccion);

                db.SaveChanges();
                return new { done = true, message = "Inspección Eliminada" };

            }
        }
        catch (Exception ex)
        {
            log.Error("Inspecciones/DeleteInspeccion", ex);
            return new { done = false, message = ex.ToString() };
        }
    }
    private static object SetTipoInforme(HttpContext post)
    {
        try
        {
            var inspeccionId = int.Parse(post.Request["inspeccion"]);
            var informeId = int.Parse(post.Request["informe"]);
            using (var db = new CertelEntities())
            {
                var inspeccion = db.Inspeccion
                                    .Find(inspeccionId);
                inspeccion.TipoInformeID = informeId;
                db.SaveChanges();
                return new { done = false, message = "OK" };
            }
        }
        catch (Exception ex)
        {
            log.Error("Inspecciones/SetTipoInforme", ex);
            return new { done = false, message = ex.ToString() };
        }
    }
    private static object RemoveObservacionTecnica(HttpContext post)
    {
        try
        {
            var id = int.Parse(post.Request["id"]);
            using (var db = new CertelEntities())
            {

                var observacion = db.ObservacionTecnica
                                    .Find(id);
                if (observacion == null) return new { done = false, message = "Ha ocurrido un error" };

                var fotos = db.FotografiaTecnica
                                .Where(w => w.ObservacionTecnicaID == id)
                                .ToList();
                foreach(var f in fotos)
                {
                    var fileName = HttpContext.Current.Server.MapPath("~/fotos/") + f.URL;
                    File.Delete(fileName);
                    db.FotografiaTecnica.Remove(f);
                    db.SaveChanges();
                }

                db.ObservacionTecnica.Remove(observacion);
                db.SaveChanges();
                return new { done = true, message = "Observación eliminada exitosamente" };
            }
        }
        catch (Exception ex)
        {
            log.Error("Inspecciones/RemoveObservacionTecnica", ex);
            return new { done = false, message = ex.ToString() };
        }
    }
    private static object SaveObservacionTecnica(HttpContext post)
    {
        try
        {
            var inspeccionId = int.Parse(post.Request["inspeccionId"]);
            var texto = post.Request["texto"];
            using (var db = new CertelEntities())
            {
                var observacion = new ObservacionTecnica
                {
                    InspeccionID = inspeccionId,
                    Texto = texto,
                };
                db.ObservacionTecnica.Add(observacion);
                db.SaveChanges();
                return new { done = true, message = "ok", id = observacion.ID };
            }
        }
        catch (Exception ex)
        {
            log.Error("Inspecciones/SaveObservacionTecnica", ex);
            return new { done = false, message = ex.ToString() };
        }
    }
    private static object GetObservacionesTecnicas(HttpContext post)
    {
        try
        {
            var inspeccionId = int.Parse(post.Request["inspeccionId"]);
            using (var db = new CertelEntities())
            {
                var observaciones = db.ObservacionTecnica
                                        .Where(w => w.InspeccionID == inspeccionId)
                                        .Select(s => new
                                        {
                                            Id = s.ID,
                                            Texto = s.Texto,
                                            Image = s.FotografiaTecnica.Select(ss => "fotos/" + ss.URL).FirstOrDefault() ?? string.Empty
                                        })
                                        .ToList();
                return observaciones;
            }
        }
        catch (Exception ex)
        {
            log.Error("Inspecciones/GetObservacionesTecnicas", ex);
            return new { done = false, message = ex.ToString() };
        }
    }
    private static object SaveCalificacion(HttpContext post, DataUser ds)
    {
        try
        {
            var inspeccionId = int.Parse(post.Request["inspeccionId"]);
            var val = int.Parse(post.Request["val"]);
            var dias = int.Parse(post.Request["dias"]);
            var creafase2 = bool.Parse(post.Request["creafase2"]);
            var mensaje = "Guardado";
            using (var db = new CertelEntities())
            {
                var inspeccion = db.Inspeccion
                                    .Find(inspeccionId);
                inspeccion.Calificacion = val;
                if (val == 0 || val == 2)
                    inspeccion.DiasPlazo = dias;
                db.SaveChanges();
                bool crea;
                if (creafase2)
                {
                    if(inspeccion.Fase == 1)
                    {
                        if(!inspeccion.Inspeccion1.Any())
                        {
                            var fase2 = new Inspeccion
                            {
                                EstadoID = 1,
                                Fase = 2,
                                FechaCreacion = DateTime.Now,
                                InspeccionFase1 = inspeccion.ID,
                                AparatoID = inspeccion.AparatoID,
                                AlturaPisos = inspeccion.AlturaPisos,
                                Destinatario = inspeccion.Destinatario,
                                DestinoProyectoID = inspeccion.DestinoProyectoID,
                                FechaInstalacion = inspeccion.FechaInstalacion,
                                Ingeniero = inspeccion.Ingeniero,
                                IT = inspeccion.IT,
                                NombreEdificio = inspeccion.NombreEdificio,
                                NombreProyecto = inspeccion.NombreProyecto,
                                TipoInformeID = inspeccion.TipoInformeID,
                                TipoFuncionamientoID = inspeccion.TipoFuncionamientoID,
                                ServicioID = inspeccion.ServicioID,
                                Numero = inspeccion.Numero,
                                Ubicacion = inspeccion.Ubicacion,
                                PermisoEdificacion = inspeccion.PermisoEdificacion,
                                RecepcionMunicipal = inspeccion.RecepcionMunicipal,


                            };

                            if(inspeccion.FechaEntrega.HasValue)
                                fase2.FechaInspeccion = inspeccion.FechaEntrega.Value.AddDays(dias);

                            db.Inspeccion.Add(fase2);
                            db.SaveChanges();


                            var inspeccionNormaOriginal = inspeccion.InspeccionNorma.ToList();
                            foreach(var i in inspeccionNormaOriginal)
                            {
                                var inspeccionNorma = new InspeccionNorma
                                {
                                    InspeccionID = fase2.ID,
                                    NormaID = i.NormaID
                                };
                                db.InspeccionNorma.Add(inspeccionNorma);
                                db.SaveChanges();
                            }
                            var especificos = inspeccion.ValoresEspecificos.ToList();
                            foreach(var i in especificos)
                            {
                                var valoresEspecificos = new ValoresEspecificos
                                {
                                    EspecificoID = i.EspecificoID,
                                    InspeccionID = fase2.ID,
                                    Valor = i.Valor
                                };
                                db.ValoresEspecificos.Add(valoresEspecificos);
                                db.SaveChanges();
                            }
                            mensaje = "La calificación fue guardada. La fase 2 ha sido creada";

                        }
                        else {
                            mensaje = "La calificación fue guardada, pero no se creó una Fase 2, porque ya existe una.";
                        }
                    }
                    else {
                        mensaje = "La calificación ha sido guardada. Se especificará en el informe, que se creará una fase 3, materia de otra cotización";
                    }
                    crea = true;
                }
                else {
                    crea = false;
                }
                inspeccion.CreaFaseSiguiente = crea;
                db.SaveChanges();
                return new { done = true, message = mensaje };
            }

        }

        catch (Exception ex)
        {
            log.Error("Inspecciones/Plantilla", ex);
            return new { done = false, message = ex.ToString() };
        }
    }
    private static object RemovePhoto(HttpContext post)
    {
        try
        {
            var id = int.Parse(post.Request["id"]);

            using (var db = new CertelEntities())
            {
                var photo = db.Fotografias
                                .Where(w => w.ID == id)
                                .FirstOrDefault();
                if (photo == null)
                {
                    return new { done = false, message = "Fotografía ya no existe" };
                }

                var fileName = HttpContext.Current.Server.MapPath("~/fotos/") + photo.URL;
                File.Delete(fileName);
                db.Fotografias.Remove(photo);
                db.SaveChanges();

                return new { done = true, message = "Fotografía borrada exitosamente" };
            }
        }
        catch (Exception ex)
        {
            log.Error("Inspecciones/Plantilla", ex);
            return new { done = false, message = ex.ToString() };
        }
    }

    private static object GetPhotos(HttpContext post)
    {
        try
        {
            using (var db = new CertelEntities())
            {
                var car = int.Parse(post.Request["caracteristica"]);
                var insp = int.Parse(post.Request["inspeccion"]);
                var cumplimiento = db.Cumplimiento
                                    .Where(w => w.InspeccionID == insp)
                                    .Where(w => w.CaracteristicaID == car)
                                    .FirstOrDefault();
                if (cumplimiento == null)
                    return new { done = false, code = 2, message = "Primero seleccione una evaluación" };

                var photos = db.Fotografias
                                .Where(w => w.CumplimientoID == cumplimiento.ID)
                                .ToList();

                if (photos.Count() == 0)
                    return new { done = false, code = 1, message = "No hay fotografías" };

                return new
                {
                    done = true,
                    message = "No hay fotografías",
                    photos = photos
                            .Select(s => new
                            {
                                Id = s.ID,
                                URL = "fotos/" + s.URL
                            })
                };

            }
        }
        catch (Exception ex)
        {
            log.Error("Inspecciones/Plantilla", ex);
            return new { done = false, code = 0, message = ex.ToString() };
        }
    }

    private static object UploadImage(HttpContext post)
    {
        try
        {

            var inspeccion = int.Parse(post.Request["inspeccion"]);
            var caracteristica = int.Parse(post.Request["caracteristica"]);
            string str_image = string.Empty;

            using (var db = new CertelEntities())
            {
                var cumplimiento = db.Cumplimiento
                                    .Where(w => w.CaracteristicaID == caracteristica)
                                    .Where(w => w.InspeccionID == inspeccion)
                                    .FirstOrDefault();
                if (cumplimiento == null)
                {
                    return new { done = false, message = "Primero ingrese una evaluación para esta característica" };
                }
                else
                {
                    HttpPostedFile file = post.Request.Files[0];
                    string fileName = file.FileName;
                    string fileExtension = file.ContentType;


                    if (!string.IsNullOrEmpty(fileName))
                    {
                        var date = DateTime.Now.ToString("ddMMyyyyHHmmss");
                        fileExtension = Path.GetExtension(fileName);
                        str_image = inspeccion + "_" + caracteristica + "_" + date + fileExtension;
                        string pathToSave = HttpContext.Current.Server.MapPath("~/fotos/") + str_image;
                        file.SaveAs(pathToSave);

                    }

                    // Save To BBDD
                    var photo = new Fotografias
                    {
                        CumplimientoID = cumplimiento.ID,
                        URL = str_image,

                    };
                    db.Fotografias.Add(photo);
                    db.SaveChanges();
                    return new { done = true, message = "Fotografía agregada correctamente" };
                }

            }
        }
        catch (Exception ex)
        {
            log.Error("Inspecciones/UploadImage", ex);
            return new { done = false, message = ex.ToString() };
        }
    }
    private static object UploadImageTecnica(HttpContext post)
    {
        try
        {

            var obs = post.Request["obs"];
            var inspeccionId = int.Parse(post.Request["inspeccion"]);
            string str_image = string.Empty;

            using (var db = new CertelEntities())
            {

                HttpPostedFile file = post.Request.Files[0];
                string fileName = file.FileName;
                string fileExtension = file.ContentType;
                if (!string.IsNullOrEmpty(fileName))
                {
                    var date = DateTime.Now.ToString("ddMMyyyyHHmmss");
                    fileExtension = Path.GetExtension(fileName);
                    str_image = inspeccionId + "_OT_" + date + fileExtension;
                    string pathToSave = HttpContext.Current.Server.MapPath("~/fotos/") + str_image;
                    file.SaveAs(pathToSave);

                }
                var observacion = new ObservacionTecnica
                {
                    InspeccionID = inspeccionId,
                    Texto = obs,
                };
                db.ObservacionTecnica.Add(observacion);
                db.SaveChanges();
                // Save To BBDD
                var photo = new FotografiaTecnica
                {
                    ObservacionTecnicaID = observacion.ID,
                    URL = str_image,

                };
                db.FotografiaTecnica.Add(photo);
                db.SaveChanges();
                return new { done = true, message = "Fotografía agregada correctamente" };
            }


        }
        catch (Exception ex)
        {
            log.Error("Inspecciones/UploadImageTecnica", ex);
            return new { done = false, message = ex.ToString() };
        }
    }
    private static object WriteObservacion(HttpContext post)
    {
        try
        {
            var observacion = post.Request["observacion"];
            var inspeccion = int.Parse(post.Request["inspeccion"]);
            var caracteristica = int.Parse(post.Request["caracteristica"]);

            using (var db = new CertelEntities())
            {
                var exists = db.Cumplimiento
                                .Where(w => w.InspeccionID == inspeccion)
                                .Where(w => w.CaracteristicaID == caracteristica)
                                .FirstOrDefault();
                if (exists == null)
                {
                    return new
                    {
                        done = false,
                        message = "Primero ingrese un cumplimiento"
                    };
                }
                else
                {
                    exists.Observacion = observacion;
                    exists.Fecha = DateTime.Now;
                }
                db.SaveChanges();
                return new
                {
                    done = true,
                    message = "Observación guardada"
                };
            }
        }
        catch (Exception ex)
        {
            log.Error("Inspecciones/Plantilla", ex);
            return new { done = false, message = ex.ToString() };
        }
    }

    private static object SetCumplimiento(int eval, int caracteristica, int inspeccion)
    {
        try
        {
            using (var db = new CertelEntities())
            {
                var exists = db.Cumplimiento
                                .Where(w => w.CaracteristicaID == caracteristica)
                                .Where(w => w.InspeccionID == inspeccion)
                                .FirstOrDefault();
                if (exists == null)
                {
                    var evaluacion = new Cumplimiento
                    {
                        CaracteristicaID = caracteristica,
                        EvaluacionID = eval,
                        InspeccionID = inspeccion,
                        Fecha = DateTime.Now
                    };
                    db.Cumplimiento.Add(evaluacion);

                }
                else
                {
                    exists.EvaluacionID = eval;
                    exists.Fecha = DateTime.Now;

                }


                db.SaveChanges();
                return new
                {
                    done = true,
                    message = "Cumplimiento Guardado oK"
                };
            }
        }
        catch (Exception ex)
        {
            log.Error("Inspecciones/SetCumplimiento", ex);
            return new { done = false, message = ex.ToString() };
        }
    }


    private static object AddOrRemoveNorma(int inspeccion, int id, bool check)
    {
        try
        {
            using (var db = new CertelEntities())
            {

                if (check)
                {
                    var ni = new InspeccionNorma
                    {
                        InspeccionID = inspeccion,
                        NormaID = id
                    };
                    db.InspeccionNorma.Add(ni);
                    db.SaveChanges();
                    //var norma = db.Norma.Find(id);
                    //var asociadas = norma.NormasAsociadas.ToList();
                    //foreach(var a in asociadas)
                    //{
                    //    var ni1 = new InspeccionNorma
                    //    {
                    //        InspeccionID = inspeccion,
                    //        NormaID = a.Norma1.ID
                    //    };
                    //    db.InspeccionNorma.Add(ni1);
                    //    db.SaveChanges();
                    //}

                    return new
                    {
                        done = true,
                        message = "OK"
                    };
                }
                else
                {
                    var ni = db.InspeccionNorma
                                .AsEnumerable()
                                .Where(w => w.NormaID == id)
                                .Where(w => w.InspeccionID == inspeccion)
                                .ToList();
                    if (ni.Count == 0)
                        return new
                        {
                            done = false,
                            message = "Ha ocurrido un error"
                        };
                    ni.ForEach(f => { db.InspeccionNorma.Remove(f); });
                    db.SaveChanges();
                    return new
                    {
                        done = true,
                        message = "OK"
                    };
                }

            }
        }
        catch (Exception ex)
        {
            log.Error("Inspecciones/AddOrRemoveNorma", ex);
            return new { done = false, message = ex.ToString() };
        }
    }
    private static object GetNormas(int inspeccion)
    {
        try
        {
            using (var db = new CertelEntities())
            {
                var inspec = db.Inspeccion
                                .Find(inspeccion);

                var ni = inspec.InspeccionNorma
                            .Select(s => s.NormaID)
                            .ToList();

                var normas = db.Norma
                                .Where(w => w.NormasAsociadas.Any() || w.Principal == true)
                                .Select(s => new
                                {
                                    Id = s.ID,
                                    Nombre = s.Nombre,
                                    Checked = ni.Contains(s.ID),
                                    Hijas = s.NormasAsociadas.Select(ss => ss.ID).ToList()
                                })
                                .ToList();
                var informes = db.TipoInforme
                                    .Select(s => new
                                    {
                                        Id = s.ID,
                                        Nombre = s.Descripcion,
                                        Cheched = inspec.TipoInformeID == s.ID
                                    }).ToList();
                return new { done = true, normas = normas, informes = informes };
            }
        }
        catch (Exception ex)
        {
            log.Error("Inspecciones/GetNormas", ex);
            return new { done = false, message = ex.ToString() };
        }
    }

    private static object GetCheckList(int inspeccionId, int title)
    {
        try
        {
            using (var db = new CertelEntities())
            {
                var inspeccion = db.Inspeccion.Find(inspeccionId);
                var titles = new TitulosInspeccion(inspeccion).ListaInspeccion;
                var first = titles.First();
                List<Norma> normasList = new List<Norma>();
                var normasReguladoras = db.InspeccionNorma
                                            .Where(w => w.InspeccionID == inspeccionId)
                                            .Where(w => w.Norma.Principal == true)
                                            ;

                foreach(var n in normasReguladoras)
                {
                    normasList.Add(n.Norma);
                    var asociadas = n.Norma.NormasAsociadas;
                    foreach(var a in asociadas)
                    {
                        normasList.Add(a.Norma1);
                    }
                }
                if (normasList.Count == 0)
                {
                    return new { done = false, code = 1, message = "No hay normas asignadas a esta inspección. ¿Desea agregarlas?" };
                }
                var data =
                    normasList
                        .Where(w => title == 0 ? true : w.Titulo.Any(a => a.ID == title))
                        .Select(n => new
                        {
                            Id = n.ID,
                            Text = n.Nombre,
                            Titulos = n.Titulo
                                    .Where(w => title == 0 ? true : w.ID == title)
                                    .Select(s => new
                                    {
                                        Id = s.ID,
                                        Text = s.Texto,
                                        Requisitos = s.Requisito
                                                .Where(w => w.Habilitado == true)
                                                  .Select(r => new
                                                  {
                                                      Id = r.ID,
                                                      Text = r.Descripcion,
                                                      Caracteristicas = r.Caracteristica
                                                                            .Where(w => w.Habilitado == true)
                                                                            .Select(c => new
                                                                            {
                                                                                Id = c.ID,
                                                                                Text = c.Descripcion,
                                                                                Cumplimiento = c.Cumplimiento
                                                                                                .Where(w => w.InspeccionID == inspeccionId)
                                                                                                .Select(cu => new
                                                                                                {
                                                                                                    Id = cu.EvaluacionID,
                                                                                                    Text = cu.Evaluacion.Descripcion,
                                                                                                    Observacion = cu.Observacion,
                                                                                                    HasFotos = cu.Fotografias.Any()
                                                                                                })
                                                                                                .FirstOrDefault()
                                                                            })
                                                                            .ToList()
                                                  })
                                                  .ToList()
                                    })
                            .ToList()
                        })
                        .ToList();

                return new { done = true, data = data };
            }
        }
        catch (Exception ex)
        {
            log.Error("Inspecciones/GetCheckList", ex);
            return new { done = false, code = 0, message = ex.ToString() };
        }
    }
    private static object GetCheckListF2(int inspeccionId)
    {
        try
        {
            using (var db = new CertelEntities())
            {
                var inspeccion = db.Inspeccion.Find(inspeccionId);

                var noConformidadesAnteriores = db.Cumplimiento
                                                .Where(w => w.InspeccionID == inspeccion.InspeccionFase1)
                                                .Where(w => w.EvaluacionID == 3)
                                                .Select(s => (int)s.CaracteristicaID)
                                                .ToList();
                var normasReguladoras = db.InspeccionNorma
                                            .Where(w => w.InspeccionID == inspeccion.InspeccionFase1)
                                            .ToList();
                var data =
                    normasReguladoras
                        .Where(w => w.Norma.Titulo.Any(ww => ww.Requisito.Any(www => www.Caracteristica.Any(wwww => noConformidadesAnteriores.Contains(wwww.ID)))))
                        .Select(n => new
                        {
                            Id = n.ID,
                            Text = n.Norma.Nombre,
                            Titulos = n.Norma.Titulo.Where(ww => ww.Requisito.Any(www => www.Caracteristica.Any(wwww => noConformidadesAnteriores.Contains(wwww.ID))))
                            .Select(s => new
                            {
                                Id = s.ID,
                                Text = s.Texto,
                                Requisitos = s.Requisito
                                                  .Where(w => w.Caracteristica.Any(ww => noConformidadesAnteriores.Contains(ww.ID)))
                                                  .Select(r => new
                                                  {
                                                      Id = r.ID,
                                                      Text = r.Descripcion,
                                                      Caracteristicas = r.Caracteristica
                                                                            .Where(w => noConformidadesAnteriores.Contains(w.ID))
                                                                            .Select(c => new
                                                                            {
                                                                                Id = c.ID,
                                                                                Text = c.Descripcion,
                                                                                Cumplimiento = c.Cumplimiento
                                                                                                .Where(w => w.InspeccionID == inspeccionId)
                                                                                                .Select(cu => new
                                                                                                {
                                                                                                    Id = cu.EvaluacionID,
                                                                                                    Text = cu.Evaluacion.Descripcion,
                                                                                                    Observacion = cu.Observacion,
                                                                                                    Fotografia = cu.Fotografia
                                                                                                })
                                                                                                .FirstOrDefault()
                                                                            })
                                                                            .ToList()
                                                  })
                                                  .ToList()
                            })
                                .ToList()
                        })
                        .ToList();



                return new { done = true, data = data };
            }
        }
        catch (Exception ex)
        {
            log.Error("Inspecciones/GetCheckList", ex);
            return new { done = false, code = 0, message = ex.ToString() };
        }
    }
    private static object EditSpecificDataInspeccion(string info, int inspeccionId, bool all)
    {
        try
        {
            var deserializer = new JavaScriptSerializer();
            var specific = deserializer.Deserialize<List<SpecificData>>(info);
            using (var db = new CertelEntities())
            {
                var inspeccionesList = new List<Inspeccion>();
                var inspeccion = db.Inspeccion.Find(inspeccionId);

                if(all)
                {
                    inspeccionesList =  db.Inspeccion
                         .Where(w => w.ServicioID == inspeccion.ServicioID)
                         .ToList();
                }
                else
                {
                    inspeccionesList.Add(inspeccion);
                }
                foreach (var i in inspeccionesList)
                {
                    foreach (var s in specific)
                    {
                        var existRecord = db.ValoresEspecificos
                                            .Where(w => w.InspeccionID == i.ID)
                                            .Where(w => w.EspecificoID == s.name)
                                            .FirstOrDefault();
                        if (existRecord != null)
                        {
                            if (s.value == string.Empty)
                            {
                                db.ValoresEspecificos.Remove(existRecord);
                                db.SaveChanges();
                            }
                            else
                            {
                                existRecord.Valor = s.value;
                                db.SaveChanges();
                            }

                            continue;
                        }
                        if (s.value == string.Empty)
                            continue;


                        var ve = new ValoresEspecificos
                        {
                            InspeccionID = i.ID,
                            EspecificoID = s.name,
                            Valor = s.value
                        };
                        db.ValoresEspecificos.Add(ve);
                        db.SaveChanges();
                    }
                }


                return new
                {
                    done = true,
                    message = "Registros Actualizados"
                };
            }



        }
        catch (Exception ex)
        {
            log.Error("Inspecciones/EditSpecificDataInspeccion", ex);
            return new { done = false, message = ex.ToString() };
        }
    }
    private static object GetInspeccion(int id)
    {
        try
        {
            using (var db = new CertelEntities())
            {
                var inspeccion = db.Inspeccion
                                    .Find(id);
                if (inspeccion == null)
                {
                    return new { done = false, message = "Inspección no existe" };
                }
                var data = new
                {
                    ItServicio = inspeccion.Servicio.IT,
                    Ubicacion = inspeccion.Ubicacion,
                    FechaInstalacion = inspeccion.FechaInstalacion.HasValue ? inspeccion.FechaInstalacion.Value.ToString("dd-MM-yyyy") : string.Empty,
                    FechaInspeccion = inspeccion.FechaInspeccion.HasValue ? inspeccion.FechaInspeccion.Value.ToString("dd-MM-yyyy") : string.Empty,
                    Aparato = inspeccion.AparatoID,
                    TipoFuncionamiento = inspeccion.TipoFuncionamientoID,
                    Destino = inspeccion.DestinoProyectoID == null ? string.Empty : inspeccion.DestinoProyecto.Descripcion,
                    DestinoId = inspeccion.DestinoProyectoID,
                    PermisoEdificacion = inspeccion.PermisoEdificacion,
                    RecepcionMunicipal = inspeccion.RecepcionMunicipal,
                    Altura = inspeccion.AlturaPisos == null ? string.Empty : inspeccion.AlturaPisos.ToString(),
                    Ingeniero = inspeccion.Ingeniero,
                    Nombre = inspeccion.NombreProyecto,
                    Edificio = inspeccion.NombreEdificio,
                    Numero = inspeccion.Numero
                };
                return new
                {
                    done = true,
                    data = data
                };
            }
        }
        catch (Exception ex)
        {
            log.Error("Inspecciones/GetInspeccion", ex);
            return new { done = false, message = ex.ToString() };
        }
    }

    private static object GetSpecificDataInspeccion(int id)
    {
        try
        {
            using (var db = new CertelEntities())
            {
                var i = db.Inspeccion
                            .Where(w => w.ID == id)
                            .FirstOrDefault();
                if (i == null)
                {
                    return new { done = false, message = "Inspección no existe" };
                }
                var data = db.Especificos
                               .Select(s => new
                               {
                                   Id = s.ID,
                                   Nombre = s.Nombre,
                                   Valor = s.ValoresEspecificos
                                                .Where(w => w.InspeccionID == i.ID)
                                                .Select(ss => ss.Valor)
                                                .FirstOrDefault()
                               }).ToList();


                return new
                {
                    done = true,
                    data = data
                };
            }
        }
        catch (Exception ex)
        {
            log.Error("Inspecciones/GetInspeccion", ex);
            return new { done = false, message = ex.ToString() };
        }
    }

    private static object GetInspecciones(string sidx, string sord, int page, int rows, string it, DateTime? desde, DateTime? hasta, DataUser ds)
    {
        try
        {
            using (var db = new CertelEntities())
            {
                var isRevisador = ds.Roles.Contains(2) || ds.Roles.Contains(3);
                var isAprobador = ds.Roles.Contains(3);
                var defaultDate = new DateTime(2016, 01, 01);
                var list = db.Inspeccion
                                .Where(w => isRevisador ? true : w.Ingeniero == ds.Usuario)
                                .Where(w => w.Servicio.IT.Contains(it))
                                .Where(w => desde == null
                                    ? w.FechaCreacion >= defaultDate
                                    : w.FechaCreacion >= desde.Value)
                                .Where(w => hasta == null
                                    ? w.FechaCreacion <= DateTime.Now
                                    : w.FechaCreacion <= hasta.Value);
                int pageSize = rows;
                int totalRecords = list.Count();
                int totalPages = (int)Math.Ceiling((float)totalRecords / (float)pageSize);
                totalPages = totalPages == 0 ? 1 : totalPages;
                var result = list
                    .OrderBy(sidx + " " + sord)
                    .Skip((page - 1) * pageSize)
                    .Take(pageSize);
                var date = new DateTime();
                var grid = new
                {
                    page = page,
                    records = totalRecords,
                    total = totalPages,
                    rows = result
                            .AsEnumerable()
                           .Select(x => new
                           {
                               Id = x.ID,
                               ItServicio = x.Servicio.IT,
                               It = x.IT,
                               Aparato = x.Aparato.Nombre,
                               Funcionamiento = x.TipoFuncionamientoAparato.Descripcion,
                               FechaCreacion = x.FechaCreacion.ToString("dd-MM-yyyy"),
                               FechaInspeccion = x.FechaInspeccion.Value.ToString("dd-MM-yyyy"),
                               FechaEntrega = x.FechaEntrega.HasValue ? x.FechaEntrega.Value.ToString("dd-MM-yyyy") : string.Empty,
                               Fase = x.Fase,
                               HasInforme = x.Informe.Any(),
                               Estado = x.EstadoInspeccion.Descripcion,
                               Ingeniero = x.Ingeniero == null ? string.Empty : x.Usuario.Nombre + " " + x.Usuario.Apellido,
                               EstadoId = x.EstadoID,
                               Revisar = !isRevisador ? 0 : x.FechaRevision.HasValue ? 1 : 2,
                               Aprobar = !isAprobador || !x.FechaRevision.HasValue ? 0 : x.FechaAprobacion.HasValue ? 1 : 2,
                               Revisar1 = !isRevisador ? 0 : x.FechaRevision.HasValue ? 1 : 2,
                               Aprobado = x.FechaAprobacion.HasValue,
                               Today = date = DateTime.Today,
                               AtrasadaInspeccion = date > x.FechaInspeccion && !x.Cumplimiento.Any(),
                               AtrasadaEntrega = !x.FechaEntrega.HasValue ? false : date > x.FechaEntrega.Value,
                               Destinatario = x.Destinatario,
                               Fase1 = x.Fase,
                               Califica = x.Calificacion,
                               HasNextFase = x.Inspeccion1.Any() || x.CreaFaseSiguiente == true
                           })
                           .ToList()
                };
                return grid;
            }

        }
        catch (Exception ex)
        {
            log.Error("ERROR AL CARGAR GRILLA DE Inspecciones", ex);
            return new { done = false, message = ex.ToString() };
        }
    }


    public bool IsReusable
    {
        get
        {
            return true;
        }
    }

    public class SpecificData
    {
        public int name { get; set; }
        public string value { get; set; }
    }

}