<%@ Page Language="C#" AutoEventWireup="true" CodeFile="Inspecciones.aspx.cs" Inherits="Inspecciones" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
<meta http-equiv="Content-Type" content="text/html; charset=utf-8"/>
    <title>Certel</title>
    <link rel="shortcut icon" href="css/images/favicon.ico" type="image/x-icon" />
    <link rel="icon" href="css/images/favicon.ico" type="image/x-icon" />
    <link href="bower_components/font-awesome/css/font-awesome.min.css" rel="stylesheet" />
    <link href="bower_components/bootstrap/dist/css/bootstrap.min.css" rel="stylesheet" />
    <link href="bower_components/jquery-ui/jquery-ui.min.css" rel="stylesheet"/>
    <link href="bower_components/jquery-ui/jquery-ui.theme.min.css" rel="stylesheet" />
    <link href="bower_components/jqGrid/ui.jqgrid.css" rel="stylesheet" />
    <link href="bower_components/alertify.js/alertify.min.css" rel="stylesheet" />
    <link href="bower_components/alertify.js/bootstrap.min.css" rel="stylesheet" />
    <link href="bower_components/select2/dist/css/select2.min.css" rel="stylesheet" />
    <link href="bower_components/jquery.steps/demo/css/jquery.steps.css" rel="stylesheet" />
    <link href="bower_components/bootstrap-switch.css" rel="stylesheet" />
    <link href="bower_components/magnific-popup.css" rel="stylesheet" />
    <link href="css/certel.css" rel="stylesheet" />
    <link href="css/elementos/inspecciones.css?301120162025" rel="stylesheet" />
</head>
<body>
    <div id="cssmenu"></div>
    <div class="container-fluid">
        <div class="row">
            <div class="col-xs-12">
                <div class="page-header">
                    <h1>Inspecciones</h1>
                </div>
            </div>
        </div>
        <div class="row">
            <div class="col-xs-12 col-sm-12 col-md-3 col-lg-3">
                <div class="panel panel-default">
                    <div class="panel-heading">
                        <h3>FILTROS <span id="f_remove"><i class="fa fa-remove"></i></span></h3>
                    </div>
                    <div class="panel-body" data-height-full="true">
                        <form id="formFiltros">
                            <div class="form-group">
                                <label for="f_it">IT Servicio</label>
                                <input type="text" class="form-control" id="f_it"/>
                            </div>
                            <div class="form-group">
                                <label for="f_cliente">Fecha Creación</label>
                                <div class="input-group">
                                    <input type="text" class="form-control" id="f_desde" placeholder="Desde" readonly/>
                                    <span class="input-group-addon"><i class="fa fa-calendar"></i></span>
                                    <input type="text" class="form-control" id="f_hasta" placeholder="Hasta" readonly/>
                                </div>
                                
                            </div>

                        </form>
                    </div>
                </div>
            </div>
            <div class="col-xs-12 col-sm-12 col-md-9 col-lg-9">
                <div class="panel panel-default">
                    <div class="panel-heading">
                        <h3>REGISTROS <span id="add"><i class="fa fa-plus"></i></span></h3>
                    </div>
                    <div class="panel-body" data-height-full="true">
                        <table id="grid"></table>
                        <div id="pager"></div>
                    </div>
                </div>
            </div>
        </div>
    </div>
    
  
     <%--Foot-Page--%>
    <div class="foot-page">Certel - Certificación en Elevación S.A.</div>

    <%--Lock Screen--%>
    <div class="lock-screen">
        <i class="fa fa-cog fa-spin fa-5x fa-fw margin-bottom"></i>
        <span class="sr-only">Cargando...</span>
    </div>
    <%--Edit Inspecciones--%>
    <div id="edit-inspeccion-dialog" class="dialog">
        <div class="container-fluid">
            <div class="row">
                <div class="col-xs-12 col-lg-12 col-md-12 col-sm-12">
                    <form id="edit-inspeccion-form">
                        <div class="col-xs-12 col-lg-12 col-md-12 col-sm-12">
                            <div class="form-group">
                                <label for="ei-it">IT (*)</label>
                                <input id="ei-it" type="text" class="form-control" placeholder="IT Servicio" disabled required maxlength="50" />
                            </div>
                        </div>
                        <div class="col-xs-12 col-lg-12 col-md-12 col-sm-12">
                            <div class="form-group">
                                <label for="ei-ubicacion">Ubicación (*)</label>
                                <input id="ei-ubicacion" type="text" class="form-control" placeholder="Ubicación" required maxlength="300" />
                            </div>
                        </div>
                        <div class="col-xs-12 col-lg-12 col-md-12 col-sm-12">
                            <div class="form-group">
                                <label for="ei-edificio">Nombre del edificio (*)</label>
                                <input id="ei-edificio" type="text" class="form-control" placeholder="Nombre del edificio" required maxlength="100" />
                            </div>
                        </div>
                        <div class="col-xs-12 col-lg-6 col-md-6 col-sm-12">
                            <div class="form-group">
                                <label for="ei-fecha-instalacion">Fecha Instalación</label>
                                <input id="ei-fecha-instalacion" type="text" class="form-control" readonly />
                            </div>
                        </div>
                        <div class="col-xs-12 col-lg-6 col-md-6 col-sm-12">
                            <div class="form-group">
                                <label for="ei-fecha-inspeccion">Fecha Inspección (*)</label>
                                <input id="ei-fecha-inspeccion" type="text" class="form-control" readonly required />
                            </div>
                        </div>

                        <div class="col-xs-12 col-lg-4 col-md-4 col-sm-12">
                            <div class="form-group">
                                <label for="ei-aparato">Tipo de elevador (*)</label>
                                <select class="form-control" id="ei-aparato" required></select>
                            </div>
                        </div>
                        <div class="col-xs-12 col-lg-4 col-md-4 col-sm-12">
                            <div class="form-group">
                                <label for="ei-tipo-funcionamiento">Tipo de funcionamiento (*)</label>
                                <select class="form-control" id="ei-tipo-funcionamiento" required></select>
                            </div>
                        </div>
                        <div class="col-xs-12 col-lg-4 col-md-4 col-sm-12">
                            <div class="form-group">
                                <label for="ei-numero">Número único del elevador (*)</label>
                                <input class="form-control" type="text" id="ei-numero" required />
                            </div>
                        </div>
                        <div class="col-xs-12 col-lg-12 col-md-12 col-sm-12">
                            <div class="form-group">
                                <label for="ei-nombre">Nombre del proyecto (*)</label>
                                <input id="ei-nombre" type="text" class="form-control" placeholder="Nombre del proyecto" required maxlength="100" />
                            </div>
                        </div>
                        <div class="col-xs-12 col-lg-4 col-md-4 col-sm-12">
                            <div class="form-group">
                                <label for="ei-destino">Destino proyecto (*)</label>
                                <select id="ei-destino" class="form-control" required>
                                    <option value="0">Seleccione...</option>
                                </select>
                            </div>
                        </div>
                        <div class="col-xs-12 col-lg-4 col-md-4 col-sm-12">
                            <div class="form-group">
                                <label for="ei-permiso-edificacion">Permiso edificación</label>
                                <input id="ei-permiso-edificacion" type="text" class="form-control" maxlength="50" />
                            </div>
                        </div>
                        <div class="col-xs-12 col-lg-4 col-md-4 col-sm-12">
                            <div class="form-group">
                                <label for="ei-recepcion-municipal">Recepción Municipal</label>
                                <input id="ei-recepcion-municipal" type="text" class="form-control" maxlength="50" />
                            </div>
                        </div>
                        <div class="col-xs-12 col-lg-4 col-md-4 col-sm-12">
                            <div class="form-group">
                                <label for="ei-altura">Altura en pisos</label>
                                <input id="ei-altura" type="number" class="form-control" min="1" />
                            </div>
                        </div>
                        <div class="col-xs-12 col-lg-8 col-md-8 col-sm-12">
                            <div class="form-group">
                                <label for="ei-ingeniero">Ingeniero Inspector (*)</label>
                                <select class="form-control" id="ei-ingeniero" required></select>
                            </div>
                        </div>
                    </form>
                </div>

            </div>
        </div>
    </div>
    <%--Add Inspecciones--%>
    <div id="add-inspeccion-dialog" class="dialog">
        <div class="container-fluid">
            <div class="row">
                <div class="col-xs-12 col-lg-12 col-md-12 col-sm-12">
                    <form id="add-inspeccion-form">
                        <div class="col-xs-12 col-lg-12 col-md-12 col-sm-12">
                            <div class="form-group">
                                <label for="ai-it">IT (*)</label>
                                <input id="ai-it" type="text" class="form-control" placeholder="IT Servicio" required maxlength="50" />
                            </div>
                        </div>
                        <div class="col-xs-12 col-lg-12 col-md-12 col-sm-12">
                            <div class="form-group">
                                <label for="ai-ubicacion">Ubicación (*)</label>
                                <input id="ai-ubicacion" type="text" class="form-control" placeholder="Ubicación" required maxlength="300" />
                            </div>
                        </div>
                        <div class="col-xs-12 col-lg-12 col-md-12 col-sm-12">
                            <div class="form-group">
                                <label for="ai-edificio">Nombre del edificio (*)</label>
                                <input id="ai-edificio" type="text" class="form-control" placeholder="Nombre del edificio" required maxlength="300" />
                            </div>
                        </div>
                        <div class="col-xs-12 col-lg-6 col-md-6 col-sm-12">
                            <div class="form-group">
                                <label for="ai-fecha-instalacion">Fecha Instalación (*)</label>
                                <input id="ai-fecha-instalacion" type="text" class="form-control" readonly required />
                            </div>
                        </div>
                        <div class="col-xs-12 col-lg-6 col-md-6 col-sm-12">
                            <div class="form-group">
                                <label for="ai-fecha-inspeccion">Fecha Inspección (*)</label>
                                <input id="ai-fecha-inspeccion" type="text" class="form-control" readonly required />
                            </div>
                        </div>
                        <div class="col-xs-12 col-lg-4 col-md-4 col-sm-12">
                            <div class="form-group">
                                <label for="ai-aparato">Tipo de elevador (*)</label>
                                <select class="form-control" id="ai-aparato" required></select>
                            </div>
                        </div>
                        <div class="col-xs-12 col-lg-4 col-md-4 col-sm-12">
                            <div class="form-group">
                                <label for="ai-tipo-funcionamiento">Tipo de funcionamiento (*)</label>
                                <select class="form-control" id="ai-tipo-funcionamiento" required></select>
                            </div>
                        </div>
                        <div class="col-xs-12 col-lg-4 col-md-4 col-sm-12">
                            <div class="form-group">
                                <label for="ai-numero">Número único del elevador (*)</label>
                                <input id="ai-numero" type="text" class="form-control" required" />
                            </div>
                        </div>
                        <div class="col-xs-12 col-lg-12 col-md-12 col-sm-12">
                            <div class="form-group">
                                <label for="ai-nombre">Nombre del proyecto (*)</label>
                                <input id="ai-nombre" type="text" class="form-control" required maxlength="50" placeholder="Nombre del proyecto" />
                            </div>
                        </div>
                        <div class="col-xs-12 col-lg-4 col-md-4 col-sm-12">
                            <div class="form-group">
                                <label for="ai-destino">Destino proyecto (*)</label>
                                <select id="ai-destino" class="form-control" required>
                                    <option value="0">Seleccione...</option>
                                </select>
                            </div>
                        </div>
                        <div class="col-xs-12 col-lg-4 col-md-4 col-sm-12">
                            <div class="form-group">
                                <label for="ai-permiso-edificacion">Permiso edificación</label>
                                <input id="ai-permiso-edificacion" type="text" class="form-control" maxlength="50" />
                            </div>
                        </div>
                        <div class="col-xs-12 col-lg-4 col-md-4 col-sm-12">
                            <div class="form-group">
                                <label for="ai-recepcion-municipal">Recepción Municipal</label>
                                <input id="ai-recepcion-municipal" type="text" class="form-control" maxlength="50" />
                            </div>
                        </div>
                        <div class="col-xs-12 col-lg-4 col-md-4 col-sm-12">
                            <div class="form-group">
                                <label for="ai-altura">Altura en pisos</label>
                                <input id="ai-altura" type="number" class="form-control" min="1" />
                            </div>
                        </div>
                        <div class="col-xs-12 col-lg-8 col-md-8 col-sm-12">
                            <div class="form-group">
                                <label for="ai-ingeniero">Ingeniero Inspector(*)</label>
                                <select class="form-control" id="ai-ingeniero" required></select>
                            </div>
                        </div>
                    </form>
                        
                       
                           
                       
                        
                    </div>
                    
                </div>
            </div>
        </div>
    <%--Especific data--%>
    <div id="edit-inspeccion-specific-dialog" class="dialog">
        <div class="container-fluid">
            <div class="row">
                <div class="col-xs-12 col-lg-12 col-md-12 col-sm-12">
                    <form id="edit-inspeccion-specific-form">
                    </form>

                </div>

            </div>

        </div>
    </div>
    <%--Check-list Dialog--%>
    <div id="check-list-dialog" class="dialog">
        
        <div class="panel-default">
            <div class="panel-heading">
                <h3>
                    Check-List
                </h3>
            </div>
            <div class="panel-body">
                <div class="chl-panel-filters col-xs-12">
                    <form id="chl-filters-form">
                        <div class="form-group">
                            <label>Título</label>
                            <select id="chl-f-titulo" class="form-control">
                                <option value="0">Seleccione un título</option>
                            </select>
                        </div>
                    </form>
                </div>
                <div id="check-list-panel"></div>
            </div>
        </div>
        
        
    </div>
    <%--Check-list Dialog f2--%>
    <div id="check-list-dialog-f2" class="dialog">
        
        <div class="panel-default">
            <div class="panel-heading">
                <h3>
                    Check-List
                </h3>
            </div>
            <div class="panel-body">
                <div id="check-list-panel-f2"></div>
            </div>
        </div>
        
        
    </div>
    <div id="asign-normas-dialog" class="dialog">
        <div class="panel-default">
            <div class="panel-heading">
                <h3>Normas </h3>
            </div>
            <div class="panel-body">
                <form id="asign-normas-form"></form>
            </div>
        </div>
        <div class="panel-default">
            <div class="panel-heading">
                <h3>Tipo de Informe </h3>
            </div>
            <div class="panel-body">
                <form id="asign-informe-form"></form>
            </div>
        </div>
    </div>
    <div id="writing-observacion-dialog" class="dialog">
        <form id="wod-form">
            <div class="form-group">
                <label for="wod-observacion">Observación</label>
                <textarea id="wod-observacion" maxlength="5000" class="form-control"></textarea>
            </div>
        </form>
    </div>
    <div id="see-photos-dialog" class="dialog">
        <div class="fileUpload chl-btn">
            <div class="btn btn-default chl-foto" title="Agregar Fotografía">
                <i class="fa fa-2x fa-camera"></i>
                <i class="fa fa-plus"></i>
                <input type="file" id="add-photo" class="upload" accept=".jpg, .gif, .png, .jpeg" />
            </div>
        </div>

        <div id="panel-fotos" class="panel-flex"></div>
      
    </div>
    <div id="wizard-informe-dialog" class="dialog">
        <div class="col-xs-12 panel-default">
            <div class="panel-body" id="panel-wizard"></div>
        </div>
    </div>
    <div id="calificacion-dialog" class="dialog" role="group">
        <div class="col-xs-12 panel-default">
            <div class="panel-body">
                <div class="form-group">
                    <div class="btn-group btn-block btn-group-lg btn-group-vertical" data-toggle="buttons">
                        <label class="btn btn-success active">
                            <input type="radio" name="calificacion" id="califica" autocomplete="off" value="1"  />
                            Califica
                        </label>
                        <label class="btn btn-warning">
                            <input type="radio" name="calificacion" id="calificaconobs" autocomplete="off" value="2" />
                            Califica con observaciones menores
                        </label>
                        <label class="btn btn-danger">
                            <input type="radio" name="calificacion" id="nocalifica" autocomplete="off" value="0" />
                            No califica
                        </label>
                    </div>
                </div>
                
                <div class="form-group" id="plazo" style="display:none">
                    <label >Días Plazo</label>
                    <input type="number" value="30" step="30" min="0" id="diasplazo" class="form-control" />
                </div>
                <div class="form-group" id="fase2" style="display:none">
                    <input type="checkbox" id="crearfase2" />
                    <label for="crearfase2">Crear Fase Siguiente</label>
                </div>
            </div>
        </div>
    </div>
    <div id="observaciones-tecnicas-dialog" class="dialog">
        <div class="container-fluid">
            <div class="row">
                <div class="col-xs-12"><ul id="obs-tec-list" class="list-group"></ul></div>
                <div class="col-xs-12" id="panel-obs">
                    
                </div>
                <div class="col-xs-12">
                    <div class="input-group">
                        <textarea rows="3" class="form-control" maxlength="5000" id="obs-tec"></textarea>
                        <span class="input-group-addon btn btn-default" id="save-obs-tec">
                            <i class="fa fa-save"></i> Guardar
                        </span>
                        <span class="input-group-addon btn btn-default fileUpload">
                            <i class="fa fa-2x fa-camera"></i>
                            <i class="fa fa-plus"></i>
                            <input type="file" id="add-photo2" class="upload" accept=".jpg, .gif, .png, .jpeg" />
                        </span>
                    </div>
                    
                </div>
            </div>
        </div>
    </div>
    <div id="add-photo-observacion-tecnica" class="dialog">
        <div class="container-fluid">
            <div class="row">
                <div class="col-xs-12 text-center">
                    <img src="#" alt="" id="add-photo-observacion-tecnica-img" class="img-rounded" />
                </div>
                <div class="col-xs-12">
                    <textarea id="add-observacion-tecnica" class="form-control" rows="5" placeholder="Escriba su observación..."></textarea>
                </div>
            </div>
        </div>
    </div>
    <div id="aprobacion-dialog" class="dialog">
        <div class="container-fluid">
            <div class="row">
                <div class="col-xs-12">
                    <div id="message"></div>
                    <form id="aprobacion-form">
                        <div class="form-group">
                            <label>Fecha real de entrega del informe</label>
                            <input type="text" class="form-control" id="fecha_entrega" readonly required/>
                        </div>
                        <div class="form-group">
                            <label>Destinatario del Informe</label>
                            <input type="text"  class="form-control" placeholder="Nombre Destinatario del Informe" id="destinatario" required />
                        </div>
                    </form>
                    
                </div>
            </div>
        </div>
    </div>
    <div id="exists-informe-dialog" class="dialog">
        <div class="container-fluid">
            <div class="row">
                <div class="col-xs-12">
                    <div class="alert alert-info">
                        Ya existe un informe para esta inspección. 
                        <br />
                        ¿Qué desea hacer?
                    </div>
                </div>
            </div>
        </div>
    </div>
</body>
<script src="bower_components/jquery/dist/jquery.min.js"></script>
<script src="bower_components/bootstrap/dist/js/bootstrap.min.js"></script>
<script src="bower_components/jquery.steps/build/jquery.steps.min.js"></script>
<script src="bower_components/jquery-ui/jquery-ui.min.js"></script>
<script src="bower_components/jqGrid/jquery.jqGrid.min.js"></script>
<script src="bower_components/jqGrid/grid.locale-es.js"></script>
<script src="bower_components/alertify.js/alertify.min.js"></script>
<script src="bower_components/bootstrap-switch.js"></script>
<script src="bower_components/magnific-popup.js"></script>
<script src="js/menu.js"></script>
<script src="js/certel.js"></script>
<script src="js/elementos/inspecciones.js?301120162025"></script>
</html>
