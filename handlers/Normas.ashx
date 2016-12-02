<%@ WebHandler Language="C#" Class="Normas" %>

using System;
using System.Web;
using System.Linq;
using System.Web.Script.Serialization;
using System.Linq.Dynamic;
public class Normas : IHttpHandler {

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
            case "getNormas":
                var nombre = post.Request["nombre"];
                data = GetNormas(nombre);
                break;
            case "addNorma":
                var add_nombre = post.Request["nombre"];
                var add_tipo = int.Parse(post.Request["tipo"]);
                var add_tituloRegulacion = post.Request["tituloRegulacion"];
                //var add_principal = int.Parse(post.Request["principal"]);
                int ti;
                var add_tipo_informe = int.TryParse(post.Request["tipoInforme"], out ti);
                var add_parrafo = post.Request["parrafo"];
                data = AddNorma(add_nombre, add_tipo, add_tituloRegulacion, ti, add_parrafo);
                break;
            case "editNorma":
                var edit_nombre = post.Request["nombre"];
                var edit_tipo = int.Parse(post.Request["tipo"]);
                var edit_tituloRegulacion = post.Request["tituloRegulacion"];
                var edit_id = int.Parse(post.Request["id"]);
                int ti1;
                var edit_tipo_informe = int.TryParse(post.Request["tipoInforme"], out ti1);
                var edit_parrafo = post.Request["parrafo"];
                data = EditNorma(edit_nombre, edit_tipo, edit_tituloRegulacion, edit_id, ti1, edit_parrafo);
                break;
            case "getTitulos":
                var gr_normaId = int.Parse(post.Request["normaId"]);
                data = GetTitulos(gr_normaId);
                break;
            case "addTitle":
                var at_title = post.Request["title"];
                var at_norma = int.Parse(post.Request["norma"]);
                data = AddTitle(at_title, at_norma);
                break;
            case "removeTitle":
                var rt_id = int.Parse(post.Request["id"]);
                data = RemoveTitle(rt_id);
                break;
            case "editTitle":
                var et_title = post.Request["title"];
                var et_id = int.Parse(post.Request["id"]);
                data = EditTitle(et_title, et_id);
                break;
            case "grid_requisitos":
                sidx = post.Request["sidx"];
                sord = post.Request["sord"];
                page = int.Parse(post.Request["page"]);
                rows = int.Parse(post.Request["rows"]);
                var gr_title = int.Parse(post.Request["title"]);
                data = GetRequisitos(sidx, sord, page, rows, gr_title);
                break;
            case "grid_caracteristicas":
                sidx = post.Request["sidx"];
                sord = post.Request["sord"];
                page = int.Parse(post.Request["page"]);
                rows = int.Parse(post.Request["rows"]);
                var gr_req = int.Parse(post.Request["requisito"]);
                data = GetCaracteristicas(sidx, sord, page, rows, gr_req);
                break;
            case "addRequisito":
                var text = post.Request["text"];
                var title = int.Parse(post.Request["title"]);
                data = AddRequisito(text, title);
                break;
            case "addCaracteristica":
                var ac_text = post.Request["text"];
                var ac_req = int.Parse(post.Request["requisito"]);
                data = AddCaracteristica(ac_text, ac_req);
                break;
            case "editRequisito":
                var text1 = post.Request["text"];
                var er_id = int.Parse(post.Request["id"]);
                data = EditRequisito(text1, er_id);
                break;
            case "editCaracteristica":
                var ac_text1 = post.Request["text"];
                var ec_id = int.Parse(post.Request["id"]);
                data = EditCaracteristica(ac_text1, ec_id);
                break;
            case "removeRequisito":
                var rr_id = int.Parse(post.Request["id"]);
                data = RemoveRequisito(rr_id);
                break;
            case "removeCaracteristica":
                var rc_id = int.Parse(post.Request["id"]);
                data = RemoveCaracteristica(rc_id);
                break;
            case "getTerminos":
                data = GetTerminos(post);
                break;
            case "saveTermino":
                data = SaveTermino(post);
                break;
            case "removeTermino":
                data = RemoveTermino(post);
                break;
            case "editTermino":
                data = EditTermino(post);
                break;
            case "addSecondaryNorm":
                data = AddSecondaryNorm(post);
                break;
            case "removeSecondaryNorm":
                data = RemoveSecondaryNorm(post);
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
    private static object RemoveSecondaryNorm(HttpContext post)
    {
        try
        {
            var primary = int.Parse(post.Request["primary"]);
            var secondary = int.Parse(post.Request["secondary"]);

            using (var db = new CertelEntities())
            {
                var exists = db.NormasAsociadas
                                .Where(w => w.NormaPrincipalID == primary)
                                .Where(w => w.NormaSecundariaID == secondary)
                                .FirstOrDefault();
                if (exists == null)
                    return new { done = false, message = "Registro ya se había eliminado" };


                db.NormasAsociadas.Remove(exists);
                db.SaveChanges();
                return new
                {
                    done = true,
                    message = "Norma eliminada correctamente",

                };
            }
        }
        catch(Exception ex)
        {
            log.Error("Excepción Normas/RemoveRequisito", ex);
            return new
            {
                done = false,
                message = ex.ToString()
            };
        }
    }
    private static object AddSecondaryNorm(HttpContext post)
    {
        try
        {
            var primary = int.Parse(post.Request["primary"]);
            var secondary = int.Parse(post.Request["secondary"]);

            using (var db = new CertelEntities())
            {
                var exists = db.NormasAsociadas
                                .Where(w => w.NormaPrincipalID == primary)
                                .Where(w => w.NormaSecundariaID == secondary)
                                .Any();
                if (exists)
                    return new { done = false, message = "La norma ya está asociada a la Norma principal" };

                var normaAsociada = new NormasAsociadas
                {
                    NormaPrincipalID = primary,
                    NormaSecundariaID = secondary,
                };
                db.NormasAsociadas.Add(normaAsociada);
                db.SaveChanges();
                var segunda = db.Norma.Find(secondary);
                return new
                {
                    done = true,
                    message = "Norma agregada correctamente",
                    item = new
                    {
                        Nombre = segunda.Nombre,
                        Id = segunda.ID
                    }
                };
            }
        }
        catch(Exception ex)
        {
            log.Error("Excepción Normas/RemoveRequisito", ex);
            return new
            {
                done = false,
                message = ex.ToString()
            };
        }
    }
    private static object SaveTermino(HttpContext post)
    {
        try
        {
            var termino = post.Request["termino"];
            var definicion = post.Request["definicion"];
            var norma = int.Parse(post.Request["norma"]);
            using (var db = new CertelEntities())
            {
                var exists = db.TerminosYDefiniciones
                                .Where(w => w.Termino == termino)
                                .Where(w => w.NormaID == norma)
                                .Any();
                if(exists)
                {
                    return new
                    {
                        done = false,
                        message = "Ya existe un término '" + termino + "', para la Norma."
                    };
                }
                var terminoyDef = new TerminosYDefiniciones
                {
                    NormaID = norma,
                    Definicion = definicion,
                    Termino = termino
                };
                db.TerminosYDefiniciones.Add(terminoyDef);
                db.SaveChanges();
                return new
                {
                    done = true,
                    message = "OK"
                };
            }
        }
        catch(Exception ex)
        {
            log.Error("Excepción Normas/RemoveRequisito", ex);
            return new
            {
                done = false,
                message = ex.ToString()
            };
        }
    }
    private static object RemoveTermino(HttpContext post)
    {
        try
        {
            var id = int.Parse(post.Request["id"]);
            using (var db = new CertelEntities())
            {
                var termino = db.TerminosYDefiniciones
                                .Find(id);
                if (termino == null) return new { done = false, message = "Error. No existe" };

                db.TerminosYDefiniciones.Remove(termino);
                db.SaveChanges();
                return new { done = true, message = "Término eliminado correctamente" };
            }
        }
        catch(Exception ex)
        {
            log.Error("Excepción Normas/RemoveTermino", ex);
            return new
            {
                done = false,
                message = ex.ToString()
            };
        }
    }
    private static object EditTermino(HttpContext post)
    {
        try
        {
            var termino = post.Request["termino"];
            var definicion = post.Request["definicion"];
            var id = int.Parse(post.Request["id"]);
            using (var db = new CertelEntities())
            {
                var exists = db.TerminosYDefiniciones
                                .Find(id);

                if(exists != null)
                {
                    exists.Termino = termino;
                    exists.Definicion = definicion;
                    db.SaveChanges();
                    return new
                    {
                        done = true,
                        message = "Término modificado correctamente"
                    };
                }
                else
                {
                    return new
                    {
                        done = false,
                        message = "Error. No existe término"
                    };
                }

            }
        }
        catch(Exception ex)
        {
            log.Error("Excepción Normas/EditTermino", ex);
            return new
            {
                done = false,
                message = ex.ToString()
            };
        }
    }
    private static object GetTerminos(HttpContext post)
    {
        try
        {
            var normaId = int.Parse(post.Request["norma"]);
            using (var db = new CertelEntities())
            {
                var terminos = db.TerminosYDefiniciones
                                    .Where(w => w.NormaID == normaId)
                                    .Select(s => new
                                    {
                                        Id = s.ID,
                                        Termino = s.Termino,
                                        Definicion = s.Definicion
                                    })
                                    .ToList();
                return new
                {
                    done = true,
                    data = terminos
                };
            }
        }
        catch(Exception ex)
        {
            log.Error("Excepción Normas/GetTerminos", ex);
            return new
            {
                done = false,
                message = ex.ToString()
            };

        }
    }
    private static object RemoveRequisito(int er_id)
    {
        try
        {
            using (var db = new CertelEntities())
            {
                var req = db.Requisito
                            .Where(w => w.ID == er_id)
                            .FirstOrDefault();
                if (req == null)
                    return new
                    {
                        done = false,
                        message = "Error, requisito no existe!"
                    };
                req.Habilitado = !(bool)req.Habilitado;
                db.SaveChanges();

                // Add Pending Updates
                var inspectores = db.Usuario
                                    .Where(w => w.UsuarioRol.Any(ww => ww.Rol == 1))
                                    .ToList();

                foreach (var i in inspectores)
                {
                    var caracteristicas = db.Caracteristica
                                            .Where(w => w.RequisitoID == er_id)
                                            .ToList();
                    foreach (var c in caracteristicas)
                    {
                        var pending = new ActualizacionesPendientes
                        {
                            CaracteristicaID = c.ID,
                            PdaID = i.Pda.Select(s => s.ID).FirstOrDefault(),
                        };
                        db.ActualizacionesPendientes.Add(pending);

                    }
                    db.SaveChanges();

                }


                var sendToPush = new {
                    notificationType = 1,
                    entity = "R",
                    id = er_id,
                    enabled = req.Habilitado
                };

                new SendFcm("eLJkAlwWChY:APA91bFnG9E1el70IYXR8nGH_KzB0-zdeAB_-z4OrrKuZuuCi9Arqy-xupQ3v3L8KHqv6TfhOa1MAaVlgoSrktIcU9R-aw5m7TjCVRar_ueUNDOO5VpY7lrgjY4g9JQNrz79Covc8XKC", sendToPush);

                return new
                {
                    done = true,
                    message = "Requisito eliminado exitosamente"
                };
            }
        }
        catch (Exception ex)
        {
            log.Error("Excepción Normas/RemoveRequisito", ex);
            return new
            {
                done = false,
                message = ex.ToString()
            };
        }
    }

    private static object RemoveCaracteristica(int id)
    {
        try
        {
            using (var db = new CertelEntities())
            {
                var car = db.Caracteristica
                            .Where(w => w.ID == id)
                            .FirstOrDefault();
                if (car == null)
                    return new
                    {
                        done = false,
                        message = "Error, característica no existe!"
                    };
                car.Habilitado = !(bool)car.Habilitado;

                if (!car.Cumplimiento.Any() && car.Habilitado == true)
                {
                    car.ActualizacionesPendientes
                            .ToList()
                            .ForEach(f => {
                                db.ActualizacionesPendientes.Remove(f);

                            });
                    db.Caracteristica.Remove(car);
                    db.SaveChanges();
                    return new
                    {
                        done = true,
                        message = "Característica eliminada exitosamente"
                    };
                }

                db.SaveChanges();

                // Add Pending Updates
                var inspectores = db.Usuario
                                    .Where(w => w.UsuarioRol.Any(ww => ww.Rol == 1))
                                    .Where(w => w.Pda.Any())
                                    .ToList();

                foreach (var i in inspectores)
                {
                    var pending = new ActualizacionesPendientes
                    {
                        CaracteristicaID = id,
                        PdaID = i.Pda.Select(s => s.ID).FirstOrDefault(),
                    };
                    db.ActualizacionesPendientes.Add(pending);
                    db.SaveChanges();
                }

                return new
                {
                    done = true,
                    message = "Característica desactivada exitosamente"
                };
            }
        }
        catch (Exception ex)
        {
            log.Error("Excepción Normas/RemoveCaracterística", ex);
            return new
            {
                done = false,
                message = ex.ToString()
            };
        }
    }

    private static object EditRequisito(string text1, int er_id)
    {
        try
        {
            using (var db = new CertelEntities())
            {
                var req = db.Requisito
                            .Where(w => w.ID == er_id)
                            .FirstOrDefault();
                if(req == null)
                    return new
                    {
                        done = false,
                        message = "Error, requisito no existe!"
                    };
                req.Descripcion = text1;
                db.SaveChanges();
                return new
                {
                    done = true,
                    message = "Requisito modificado exitosamente"
                };
            }
        }
        catch (Exception ex)
        {
            log.Error("Excepción Normas/EditRequisito", ex);
            return new
            {
                done = false,
                message = ex.ToString()
            };
        }
    }

    private static object EditCaracteristica(string text1, int er_id)
    {
        try
        {
            using (var db = new CertelEntities())
            {
                var car = db.Caracteristica
                            .Where(w => w.ID == er_id)
                            .FirstOrDefault();
                if (car == null)
                    return new
                    {
                        done = false,
                        message = "Error, característica no encontrada!"
                    };
                car.Descripcion = text1;
                db.SaveChanges();

                // Add Pending Updates
                var inspectores = db.Usuario
                                    .Where(w => w.UsuarioRol.Any(ww => ww.Rol == 1))
                                    .Where(w => w.Pda.Any())
                                    .ToList();

                foreach (var i in inspectores)
                {
                    var pending = new ActualizacionesPendientes
                    {
                        CaracteristicaID = er_id,
                        PdaID = i.Pda.Select(s => s.ID).FirstOrDefault(),
                    };
                    db.ActualizacionesPendientes.Add(pending);
                    db.SaveChanges();
                }
                //var send = new SendFcm("eLJkAlwWChY:APA91bFnG9E1el70IYXR8nGH_KzB0-zdeAB_-z4OrrKuZuuCi9Arqy-xupQ3v3L8KHqv6TfhOa1MAaVlgoSrktIcU9R-aw5m7TjCVRar_ueUNDOO5VpY7lrgjY4g9JQNrz79Covc8XKC", new { daniel = "valdebenito", seba = "conlledo", code = 1 });
                var send = new SendFcm("eLJkAlwWChY:APA91bFnG9E1el70IYXR8nGH_KzB0-zdeAB_-z4OrrKuZuuCi9Arqy-xupQ3v3L8KHqv6TfhOa1MAaVlgoSrktIcU9R-aw5m7TjCVRar_ueUNDOO5VpY7lrgjY4g9JQNrz79Covc8XKC", new { hola = "asdasd", chao = "asdasd", code = 2 });
                return new
                {
                    done = true,
                    message = "Característica modificada exitosamente"
                };
            }
        }
        catch (Exception ex)
        {
            log.Error("Excepción Normas/EditCaracteristica", ex);
            return new
            {
                done = false,
                message = ex.ToString()
            };
        }
    }

    private static object AddCaracteristica(string text, int req)
    {
        try
        {
            using (var db = new CertelEntities())
            {
                var exists = db.Caracteristica
                                .Where(w => w.Descripcion == text)
                                .Where(w => w.RequisitoID == req)
                                .Where(w => w.Habilitado)
                                .FirstOrDefault();
                if (exists != null)
                    return new
                    {
                        done = false,
                        message = "Ya existe esta característica para el requisito '" + exists.Requisito.Descripcion + "'"
                    };

                var caracteristica = new Caracteristica
                {
                    RequisitoID = req,
                    Descripcion = text,
                    Habilitado = true,
                };
                db.Caracteristica.Add(caracteristica);
                db.SaveChanges();

                // Add Pending Updates
                var inspectores = db.Usuario
                                    .Where(w => w.UsuarioRol.Any(ww => ww.Rol == 1))
                                    .Where(w => w.Pda.Any())
                                    .ToList();

                foreach(var i in inspectores)
                {
                    if(i.Pda != null)
                    {
                        var pending = new ActualizacionesPendientes
                        {
                            CaracteristicaID = caracteristica.ID,
                            PdaID = i.Pda.Select(s => s.ID).FirstOrDefault(),
                        };
                        db.ActualizacionesPendientes.Add(pending);
                        db.SaveChanges();
                    }

                }


                return new
                {
                    done = true,
                    message = "Característica creada exitosamente"
                };
            }
        }
        catch (Exception ex)
        {
            log.Error("Excepción Normas/AddCaracteristica", ex);
            return new
            {
                done = false,
                message = ex.ToString()
            };
        }
    }
    private static object AddRequisito(string text, int title)
    {
        try
        {
            using (var db = new CertelEntities())
            {
                var exists = db.Requisito
                                .Where(w => w.Descripcion == text)
                                .Where(w => w.TituloID == title)
                                .FirstOrDefault();
                if (exists != null)
                    return new
                    {
                        done = false,
                        message = "Ya existe este requisito para el título " + exists.Titulo.Texto
                    };

                var requisito = new Requisito
                {
                    TituloID = title,
                    Descripcion = text,
                    Habilitado = true,
                };
                db.Requisito.Add(requisito);
                db.SaveChanges();
                return new
                {
                    done = true,
                    message = "Requisito creado exitosamente",
                    id = requisito.ID
                };
            }
        }
        catch(Exception ex)
        {
            log.Error("Excepción Normas/AddRequisito", ex);
            return new
            {
                done = false,
                message = ex.ToString()
            };
        }
    }

    private static object GetRequisitos(string sidx, string sord, int page, int rows, int title)
    {
        try
        {
            using (var db = new CertelEntities())
            {
                var list = db.Requisito
                                .Where(w => w.TituloID == title)
                                //.Where(w => w.Habilitado != false)
                                .ToList();
                int pageSize = rows;
                int totalRecords = list.Count();
                int totalPages = (int)Math.Ceiling((float)totalRecords / (float)pageSize);
                totalPages = totalPages == 0 ? 1 : totalPages;
                var result = list
                    .OrderBy(sidx + " " + sord)
                    .Skip((page - 1) * pageSize)
                    .Take(pageSize);
                var grid = new
                {
                    page = page,
                    records = totalRecords,
                    total = totalPages,
                    rows = result

                           .Select(x => new
                           {
                               Id = x.ID,
                               Texto = x.Descripcion,
                               Habilitado = x.Habilitado,
                               CaracteristicasCount = x.Caracteristica
                                                        .Count
                           })
                           .ToList()
                };
                return grid;
            }

        }
        catch (Exception ex)
        {
            log.Error("ERROR AL CARGAR GRILLA DE Requisitos", ex);
            return new { done = false, message = ex.ToString() };
        }
    }
    private static object GetCaracteristicas(string sidx, string sord, int page, int rows, int requisito)
    {
        try
        {
            using (var db = new CertelEntities())
            {
                var list = db.Caracteristica
                                .Where(w => w.RequisitoID == requisito)
                                //.Where(w => w.Habilitado)
                                .ToList();
                int pageSize = rows;
                int totalRecords = list.Count();
                int totalPages = (int)Math.Ceiling((float)totalRecords / (float)pageSize);
                totalPages = totalPages == 0 ? 1 : totalPages;
                var result = list
                    .OrderBy(sidx + " " + sord)
                    .Skip((page - 1) * pageSize)
                    .Take(pageSize);
                var grid = new
                {
                    page = page,
                    records = totalRecords,
                    total = totalPages,
                    rows = result

                           .Select(x => new
                           {
                               Id = x.ID,
                               Texto = x.Descripcion,
                               Habilitado = x.Habilitado
                           })
                           .ToList()
                };
                return grid;
            }

        }
        catch (Exception ex)
        {
            log.Error("ERROR AL CARGAR GRILLA DE Característica", ex);
            return new { done = false, message = ex.ToString() };
        }
    }
    private static object RemoveTitle(int title)
    {
        try
        {
            using (var db = new CertelEntities())
            {
                var exists = db.Titulo
                                .Where(w => w.ID == title)
                                .FirstOrDefault();
                if (exists == null)
                    return new
                    {
                        done = false,
                        message = "El título ya no existe!"
                    };

                var requisitos = exists.Requisito.ToList();
                foreach(var r in requisitos)
                {
                    r.Habilitado = false;
                    var caracts = r.Caracteristica.ToList();
                    foreach(var c in caracts)
                    {
                        c.Habilitado = false;
                        
                    }
                    db.SaveChanges();
                }
                db.Titulo.Remove(exists);
                db.SaveChanges();
                return new
                {
                    done = true,
                    message = "Título ha sido eliminado correctamente"
                };
            }
        }
        catch (Exception ex)
        {
            log.Error("Excepción Normas/RemoveTitle", ex);
            return new
            {
                done = false,
                message = ex.ToString()
            };
        }
    }
    private static object EditTitle(string title, int id)
    {
        try
        {
            using (var db = new CertelEntities())
            {
                var exists = db.Titulo
                                .Where(w => w.ID == id)
                                .FirstOrDefault();
                if (exists == null)
                    return new
                    {
                        done = false,
                        message = "El título ya no existe!"
                    };

                exists.Texto = title;
                db.SaveChanges();
                return new
                {
                    done = true,
                    message = "Título ha sido modificado correctamente"
                };
            }
        }
        catch (Exception ex)
        {
            log.Error("Excepción Normas/EditTitle", ex);
            return new
            {
                done = false,
                message = ex.ToString()
            };
        }
    }
    private static object AddTitle(string title, int norma)
    {
        try
        {
            using (var db = new CertelEntities())
            {
                var exists = db.Titulo
                                .Where(w => w.Texto == title)
                                .Where(w => w.NormaID == norma)
                                .Any();
                if (exists)
                    return new
                    {
                        done = false,
                        message = "Ya existe un título '" + title + "' para la norma seleccionada"
                    };
                var newTitle = new Titulo
                {
                    NormaID = norma,
                    Texto = title
                };
                db.Titulo.Add(newTitle);
                db.SaveChanges();
                return new
                {
                    done = true,
                    message = "Título ingresado correctamente a la norma"
                };
            }
        }
        catch (Exception ex)
        {
            log.Error("Excepción Normas/AddTitle", ex);
            return new
            {
                done = false,
                message = ex.ToString()
            };
        }
    }



    private static object EditNorma(string nombre, int tipo, string tituloRegulacion, int id, int tipoInforme, string parrafo)
    {
        try
        {
            using (var db = new CertelEntities())
            {
                var norma = db.Norma
                                    .Where(w => w.ID == id)
                                    .FirstOrDefault();
                if (norma == null)
                    return new
                    {
                        done = false,
                        message = "Norma no existe. Probablemente fue eliminada antes de esta modificación"
                    };
                if(tipo == 2 && norma.TipoNormaID == 1)
                {
                    var asociadas = norma.NormasAsociadas.ToList();
                    asociadas.ForEach(f => { db.NormasAsociadas.Remove(f); });
                    db.SaveChanges();
                }
                norma.Nombre = nombre;
                norma.TipoNormaID = tipo;
                norma.TituloRegulacion = tituloRegulacion;
                norma.Principal = tipo == 1;
                norma.ParrafoIntroductorio = tipo == 1 ? null : parrafo;

                if (tipoInforme != 0)
                    norma.TipoInformeID = tipoInforme;
                db.SaveChanges();
                return new
                {
                    done = true,
                    message = "Norma modificada correctamente"
                };
            }
        }
        catch (Exception ex)
        {
            log.Error("Excepción Normas/EditNorma", ex);
            return new
            {
                done = false,
                message = ex.ToString()
            };
        }
    }

    private static object AddNorma(string nombre, int tipo, string tituloRegulacion, int tipoInforme, string parrafo)
    {
        try
        {
            using (var db = new CertelEntities())
            {
                var existName = db.Norma
                                    .Where(w => w.Nombre == nombre)
                                    .Any();
                if (existName)
                    return new
                    {
                        done = false,
                        message = "Ya existe una norma con el nombre '" + nombre + "'"
                    };
                var norma = new Norma
                {
                    Nombre = nombre,
                    TipoNormaID = tipo,
                    TituloRegulacion = tituloRegulacion,
                    Habilitado = true,
                    Principal = tipo == 1,
                    ParrafoIntroductorio = tipo == 1 ? null : parrafo
                };

                if (tipoInforme != 0)
                    norma.TipoInformeID = tipoInforme;

                db.Norma.Add(norma);
                db.SaveChanges();
                return new {
                    done = true,
                    message = "Norma creada correctamente"
                };
            }
        }
        catch (Exception ex)
        {
            log.Error("Excepción Normas/AddNorma", ex);
            return new
            {
                done = false,
                message = ex.ToString()
            };
        }
    }


    private static object GetNormas(string nombre)
    {
        try
        {
            using (var db = new CertelEntities())
            {
                var principales = db.Norma
                                .Where(w => w.Nombre.Contains(nombre))
                                .Where(w => w.TipoNormaID == 1)
                                .Select(s => new
                                {
                                    Id = s.ID,
                                    Nombre = s.Nombre,
                                    TipoNormaId = s.TipoNormaID,
                                    TituloRegulacion = s.TituloRegulacion,
                                    TipoInformeId = s.TipoInformeID,
                                    Parrafo = s.ParrafoIntroductorio,
                                    Secundarias = s.NormasAsociadas
                                                    .Select(ss => new {
                                                        Id = ss.Norma1.ID,
                                                        Nombre = ss.Norma1.Nombre
                                                    }).ToList()
                                })
                                .ToList();
                var secundarias = db.Norma
                                .Where(w => w.Nombre.Contains(nombre))
                                .Where(w => w.TipoNormaID == 2)
                                .Select(s => new
                                {
                                    Id = s.ID,
                                    Nombre = s.Nombre,
                                    TipoNormaId = s.TipoNormaID,
                                    TituloRegulacion = s.TituloRegulacion,
                                    TipoInformeId = s.TipoInformeID,
                                    Parrafo = s.ParrafoIntroductorio,

                                })
                                .ToList();
                return new
                {
                    principales = principales,
                    secundarias = secundarias
                };
            }
        }
        catch(Exception ex)
        {
            log.Error("Excepción Normas/GetNormas", ex);
            return new
            {
                done = false,
                message = ex.ToString()
            };
        }
    }

    private static object GetTitulos(int norma)
    {
        try
        {
            using (var db = new CertelEntities())
            {
                var requisitos = db.Titulo
                                .Where(w => w.NormaID == norma)
                                .Select(s => new
                                {
                                    Id = s.ID,
                                    Titulo = s.Texto,
                                    Requisitos = s.Requisito
                                                    .Where(w => w.Habilitado != false)
                                                    .Count()
                                })
                                .ToList();
                return requisitos;
            }
        }
        catch (Exception ex)
        {
            log.Error("Excepción Normas/GetRequisitos", ex);
            return new
            {
                done = false,
                message = ex.ToString()
            };
        }
    }

    public bool IsReusable {
        get {
            return true;
        }
    }

}