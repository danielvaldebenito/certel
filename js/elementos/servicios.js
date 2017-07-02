var SELECTED_SERVICE;
var SELECTED_SERVICE_IT;
var CLOSE_DIALOG = false;
$(document).ready(function () {
    // datepickers
    $('#f_desde, #f_hasta, #ai-fecha-inspeccion').datepicker();
    var currrentYear = new Date().getFullYear()
    $('#ai-fecha-instalacion, #ai-fec, #ai-fvc').datepicker({ changeYear: true, yearRange: "1935:2030" });
    // comboboxs
    combobox($('#add-cliente'), { 1: 'clientes' }, 'Seleccione...');
    combobox($('#ai-destino'), { 1: 'destinoProyecto' });
    // grid inspecciones
    $('#add-cliente').select2({ width: '100%', dropdownCssClass: 'ui-dialog' });
    $('#ac_rut').Rut({
        format_on: 'keyup'
    })
    $("#grid-inspecciones").jqGrid({
        url: 'handlers/Servicios.ashx',
        mtype: "POST",
        postData: {
            1: 'gridInspecciones',
            serviceId: 0
        },
        datatype: "json",
        shrinkToFix: true,
        colModel: [
            { label: 'Id', name: 'Id', key: true, hidden: true },
            { label: 'IT', name: 'IT', width: 75, align: 'center' },
            { label: 'Fecha Creación', name: 'FechaCreacion', width: 150, sortable: true, align: 'center' },
            { label: 'Fecha Inspección', name: 'FechaInspeccion', width: 150, sortable: true, align: 'center' },
            { label: 'Aparato', name: 'Aparato', width: 100, sortable: true },
            { label: 'Funcionamiento', name: 'Funcionamiento', width: 150, sortable: true },
            { label: 'Estado', name: 'Estado', width: 150, hidden: true },
            { label: 'Estado', name: 'EstadoId', formatter: estadoServicio, width: 50, align: 'center', sortable: true },
        ],
        sortname: 'FechaCreacion', sortorder: 'desc',
        viewrecords: true,
        height: 250,
        rowNum: 20,
        pager: "#pager-inspecciones",
        caption: 'INSPECCIONES IT',
        onCellSelect: function (rowid, iCol, cellcontent, e) {
            
        }
    })
    .navGrid('#pager-inspecciones',
        {
            edit: false, add: false, del: false, search: false,
            refresh: true, view: false, position: "left", cloneToTop: false
        });

    $('#add-inspeccion').click(function () {
        openNewInspeccionDialog()
    });

    $("#grid").jqGrid({
        url: 'handlers/Servicios.ashx',
        mtype: "POST",
        postData: {
            1: 'grid',
            cliente: $('#f_cliente').val(),
            desde: $('#f_desde').val(),
            hasta: $('#f_hasta').val()
        },
        datatype: "json",
        autowidth: true,
        shrinkToFix: true,
        colModel: [
            { label: 'Id', name: 'Id', key: true, hidden: true },
            { label: 'IT', name: 'IT', width: 75, align: 'center' },
            { label: 'Fecha Creación', name: 'FechaCreacion', width: 150, sortable: true, align: 'center' },
            { label: 'Cliente', name: 'Cliente', width: 150, sortable: true },
            { label: 'Estado', name: 'Estado', width: 150, hidden: true },
            { label: 'Estado', name: 'EstadoId', formatter: estadoServicio, width: 30, align: 'center', sortable: true },
            { label: 'Inspecciones', name: 'Insp', formatter: inspecciones, width: 30, align: 'center', sortable: true },
        ],
        sortname: 'FechaCreacion', sortorder: 'desc',
        viewrecords: true,
        height: 250,
        rowNum: 20,
        pager: "#pager",
        caption: 'SERVICIOS REGISTRADOS EN EL SISTEMA',
        onCellSelect: function (rowid, iCol, cellcontent, e) {
            var serviceId = $('#grid').getCell(rowid, 'Id');
            var serviceIt = $('#grid').getCell(rowid, 'IT');
            SELECTED_SERVICE = serviceId;
            SELECTED_SERVICE_IT = serviceIt;
            switch(iCol)
            {
                case 6:
                    openInspectionsDialog();
                    break;
            }
        }
    }).navGrid('#pager',
                {
                    edit: false, add: false, del: false, search: false,
                    refresh: true, view: false, position: "left", cloneToTop: false
                });

    function estadoServicio(cellvalue, options, rowObject)
    {
        var color = '';
        switch (cellvalue)
        {
            case 1: color = "rojo"; break;
            case 2: color = "amarillo"; break;
            case 3: color = "verde"; break;
        }
        return '<div class="btn-grid ' + color + '"><i class="fa fa-circle"></i></div>';
    }

    function inspecciones(cellvalue, options, rowObject) {
        
        return '<div class="btn-grid verde"><i class="fa fa-list"></i></div>';
    }
    // submit principal data
    $('#formFiltros').submit(function (e) {
        e.preventDefault();
        jQuery("#grid")
            .jqGrid('setGridParam',
               {
                   url: 'handlers/Servicios.ashx',
                   postData: {
                       1: 'grid',
                       cliente: $('#f_cliente').val(),
                       desde: $('#f_desde').val(),
                       hasta: $('#f_hasta').val()
                   },
               })
       .trigger("reloadGrid");
        return false;
    })
    .submit()
    .find('input')
        .keyup(function () {
            $(this).closest('form').submit();
        })
        .change(function () {
            $(this).closest('form').submit();
        });
    $('#f_remove').click(function () {
        $('#formFiltros')[0].reset();
        $('#formFiltros').submit();
    });

    $('#add-service-form').submit(function (e) {
        e.preventDefault();
        if (!validateForm($(this)))
        {
            alertify.error('Complete los datos requeridos');
            return false;
        }
          
        $.ajax({
            url: 'handlers/Servicios.ashx',
            data: {
                1: 'addService',
                cliente: $('#add-cliente').val(),
                it: $('#add-it').val()
            },
            success: function (result) {
                if (result.done) {
                    SELECTED_SERVICE = result.id;
                    SELECTED_SERVICE_IT = result.it;
                    alertify.success(result.message);
                    $('#add-service-dialog').dialog('close');
                    $('#formFiltros').submit();
                    openInspectionsDialog(result.id)
                    
                }
                else
                    alertify.error(result.message);
            }
        });
        return false;
    
    });
    $('#add-client-form').submit(function (e) {
        e.preventDefault();
        if(!validateForm($(this)))
        {
            alertify.error('Complete los datos requeridos');
            return;
        }
        var validateRut = $.Rut.validar($('#ac_rut').val());
        if (!validateRut) {
            alertify.error('Rut Ingresado no es válido');
            return;
        }
        $.ajax({
            url: 'handlers/Servicios.ashx',
            data: {
                1: 'addClient',
                rut: $('#ac_rut').val(),
                nombre: $('#ac_nombre').val(),
                direccion: $('#ac_direccion').val(),
                telefono: $('#ac_telefono').val(),
                email: $('#ac_mail').val()
            },
            success: function (result) {
                if (result.done) {
                    alertify.success(result.message);
                    $('#add-client-dialog').dialog('close');
                    combobox($('#add-cliente'), { 1: 'clientes' }, 'Seleccione...');
                    $('#add-cliente').val(result.id).trigger('change');
                }
                else
                    alertify.error(result.message);
            }
        });
        return false;
    });
    // add inspeccion submit
    
    $('#add-inspeccion-form').submit(function (e) {
        e.preventDefault();
        if (!validateForm($(this))) {
            alertify.error('Complete los datos requeridos');
            return false;
        }

        $.ajax({
            url: 'handlers/Servicios.ashx',
            data: {
                1: 'addInspeccion',
                ubicacion: $('#ai-ubicacion').val(),
                fechaInstalacion: $('#ai-fecha-instalacion').val(),
                fechaInspeccion: $('#ai-fecha-inspeccion').val(),
                aparato: $('#ai-aparato').val(),
                funcionamiento: $('#ai-tipo-funcionamiento').val(),
                destino: $('#ai-destino').val(),
                permiso: $('#ai-permiso-edificacion').val(),
                recepcion: $('#ai-recepcion-municipal').val(),
                altura: $('#ai-altura').val() || 0,
                ingeniero: $('#ai-ingeniero').val(),
                nombre: $('#ai-nombre').val(),
                edificio: $('#ai-edificio').val(),
                numero: $('#ai-numero').val(),
                fec: $('#ai-fec').val(),
                fvc: $('#ai-fvc').val(),
                servicio: SELECTED_SERVICE,
                itServicio: SELECTED_SERVICE_IT
            },
            success: function (result) {
                if (result.done) {
                    alertify.success(result.message);
                    
                    reloadGridInspecciones();
                    if(CLOSE_DIALOG)
                        $('#add-inspeccion-dialog').dialog('close');
                }
                else
                    alertify.error(result.message);
            }
        });
        return false;

    });
    $('#add-service').click(function () {
        
        $('#add-service-dialog').dialog({
            modal: true, bgiframe: false, width: 600, title: 'Nuevo Servicio', draggable: true,
            resizable: false, closeOnEscape: true, autoOpen: true, show: 'clip', hide: 'puff',
            open: function (type, data) {
                $(this).find('form')[0].reset();
            },
            close: function () {

            },
            buttons: [
                {
                    id: 'btn-add',
                    text: 'Guardar',
                    click: function () {
                        $('#add-service-form').submit();
                    }
                }
            ]
        });
    });
    $('#add-client').click(function () {
        $('#add-client-dialog').dialog({
            modal: true, bgiframe: false, width: '50%', title: 'Nuevo Cliente', draggable: true,
            resizable: false, closeOnEscape: true, autoOpen: true, show: 'clip', hide: 'puff',
            open: function (type, data) {
                
                $(this).find('form')[0].reset();
            },
            close: function () {

            },
            buttons: [{
                id: 'newClientSave',
                text: 'Guardar',
                click: function () {
                    $('#add-client-form').submit();
                }
            }, {
                id: 'newClientClose',
                text: 'Cerrar',
                click: function () {
                    $('#add-client-dialog').dialog('close');
                }
            }]
        });
    });
    
    combobox($('#ai-aparato'), { 1: 'aparatos' }, 'Seleccione...');
    combobox($('#ai-ingeniero'), { 1: 'inspectores' }, 'Seleccione...');
    combobox($('#ai-tipo-funcionamiento'), { 1: 'tipoFuncionamiento' }, 'Seleccione...');
    // Resize Panels
    $(window).bind('resize', function (e) {

        // grid
        if (grid = $('.ui-jqgrid-btable:visible')) {
            grid.each(function (index) {
                gridId = $(this).attr('id');
                gridParentWidth = $('#gbox_' + gridId).parent().width();
                gridParentHeight = $('#gbox_' + gridId).parent().height();
                $('#' + gridId).setGridWidth(gridParentWidth);
                $('#' + gridId).setGridHeight(gridParentHeight - 80);
            });
        }

    }).trigger('resize');
    
});

function openInspectionsDialog()
{
    $('#ai-it').val(SELECTED_SERVICE_IT);
    reloadGridInspecciones();
    $('#inspecciones-dialog').dialog({
        modal: true, bgiframe: false, width: '60%', title: 'Inspecciones IT: ' + SELECTED_SERVICE_IT, draggable: true,
        resizable: false, closeOnEscape: true, autoOpen: true, show: 'clip', hide: 'puff',
        open: function (type, data) {
            // $(this).find('form')[0].reset();
        },
        close: function () {

        },
        buttons: [{
            id: 'btn-close',
            text: 'Cerrar',
            click: function () {
                $('#inspecciones-dialog').dialog('close');
            }
        }]
    });
}

function openNewInspeccionDialog()
{
    
    $('#add-inspeccion-dialog').dialog({
        modal: true, bgiframe: false, width: '80%', title: 'Nueva Inspección IT: ' + SELECTED_SERVICE_IT, draggable: true,
        resizable: false, closeOnEscape: true, autoOpen: true, show: 'clip', hide: 'puff',
        open: function (type, data) {
            // $(this).find('form')[0].reset();
        },
        close: function () {
            $('#add-inspeccion-form')[0].reset();
        },
        buttons: [
            {
                id: 'btn-add-i2',
                text: 'Guardar y Crear Nuevo',
                click: function () {
                    $('#add-inspeccion-form').submit();
                    CLOSE_DIALOG = false;
                }
            },
            {
                id: 'btn-add-i',
                text: 'Guardar y Cerrar',
                click: function () {
                    $('#add-inspeccion-form').submit();
                    CLOSE_DIALOG = true;
                }
            },
            {
                id: 'btn-add-close',
                text: 'Cancelar',
                click: function () {
                    $(this).dialog('close');
                }
            },
        ]
    });
}
function reloadGridInspecciones()
{
    jQuery("#grid-inspecciones")
            .jqGrid('setGridParam',
               {
                   url: 'handlers/Servicios.ashx',
                   postData: {
                       1: 'gridInspecciones',
                       serviceId: SELECTED_SERVICE
                   },
               })
            .jqGrid('setCaption', 'IT: ' + SELECTED_SERVICE_IT)
       .trigger("reloadGrid");
}

