using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

/// <summary>
/// Descripción breve de TitulosInspeccion
/// </summary>
public class TitulosInspeccion
{
    public Inspeccion Inspeccion { get; set; }
    public List<Titulo> ListaInspeccion { get; set; }
    public TitulosInspeccion(Inspeccion inspeccion)
    {
        Inspeccion = inspeccion;
        ListaInspeccion = Get();
    }
    public List<Titulo> Get()
    {
        if (Inspeccion == null)
            return null;
        using (var db = new CertelEntities())
        {
            var inspeccionNorma = Inspeccion.InspeccionNorma;
            var normas = inspeccionNorma.Select(s => s.Norma).ToList();
            

            var titulosList = new List<Titulo>();
            foreach (var n in normas)
            {
                var titulos = n.Titulo.ToList();
                foreach (var t in titulos)
                {
                    titulosList.Add(t);
                }
                var otrasNormas = n.NormasAsociadas.Select(s => s.Norma1).ToList();

                foreach (var on in otrasNormas)
                {
                    var titulosNA = on.Titulo.ToList();
                    foreach (var t in titulosNA)
                    {
                        titulosList.Add(t);
                    }
                }
            }
            return titulosList;
        }
    }
}