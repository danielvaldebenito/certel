var SELECTED_NORMA;
var SELECTED_NORMA_NAME;
var SELECTED_TITLE;
var SELECTED_TITLE_NAME;
var SELECTED_REQUISITO;
var SELECTED_REQUISITO_TEXT;
var SELECTED_CARACTERISTICA;
var SELECTED_CARACTERISTICA_TEXT;
var SELECTED_TERMINO_ID;
$(document).ready(function () {
    
    // comboboxs
    combobox($('#add-tipo'), { 1: 'tipoNorma' }, 'Seleccione...');
    combobox($('#edit-tipo'), { 1: 'tipoNorma' }, '');
    //combobox($('#add-norma-principal'), { 1: 'normas', norma: 0 }, 'Esta es la norma principal');
    combobox($('#edit-tipo-informe'), { 1: 'tipoInforme' }, 'Seleccione...');
    combobox($('#add-tipo-informe'), { 1: 'tipoInforme' }, 'Seleccione...');
    
    $('#edit-tipo').change(function () {
        var val = $(this).val();
        if(val == 1)
        {
            $('#fg-parrafo').hide()
            $('#fg-tipo-informe').show();
        }
        else
        {
            $('#fg-parrafo').show();
            $('#fg-tipo-informe').hide();
        }
    });
    $('#add-tipo').change(function () {
        var val = $(this).val();
        if (val == 1) {
            $('#a_fg-parrafo').hide()
            $('#a_fg-tipo-informe').show();
        }
        else {
            $('#a_fg-parrafo').show();
            $('#a_fg-tipo-informe').hide();
        }
    });
    
    // tabs
    $('#tabs').tabs({
        active: 0,
        hide: { effect: "blind", duration: 100 },
        show: { effect: "blind", duration: 100 },
        heightStyle: "content"
    });
    $('#reload').click(function () {
        $('#formFiltros').submit();
    });
    // grids
    
    $("#grid-caracteristicas").jqGrid({
        mtype: "POST",
        datatype: "json",
        shrinkToFix: true,
        colModel: [
            { label: 'Id', name: 'Id', key: true, hidden: true },
            { label: 'Habilitado', name: 'Habilitado', hidden: true },
            { label: 'Texto', index: 'Descripcion', name: 'Texto', width: 300, cellattr: function (rowId, tv, rawObject, cm, rdata) { return 'style="white-space: normal; padding: 5px"' }, sortable: true },
            { label: '', name: '', width: 50, formatter: btnEdit, align: 'center' },
            { label: '', name: '', width: 50, formatter: btnRemove, align: 'center' },
        ],
        sortname: 'Descripcion', sortorder: 'asc',
        viewrecords: true,
        height: 300,
        rowNum: 20,
        pager: "#pager-grid-caracteristicas",
        caption: 'SELECCIONE UN REQUISITO',
        hoverrows: false,
        rowattr: function (rd)
        {
            if(rd.Habilitado == false)
            {
                return { "class": "redRow" };
            }
        },
        onCellSelect: function (rowid, iCol, cellcontent, e) {
            SELECTED_CARACTERISTICA = $('#grid-caracteristicas').getCell(rowid, 'Id');
            SELECTED_CARACTERISTICA_TEXT = $('#grid-caracteristicas').getCell(rowid, 'Texto');
            if (iCol == 3) {
                if (!SELECTED_REQUISITO) {
                    alertify.error('Primero seleccione un requisito');
                    return;
                };
                console.log(SELECTED_CARACTERISTICA_TEXT);
                
                $('#edit-caracteristica-dialog').dialog({
                    modal: true, bgiframe: false, width: 800,
                    title: 'Editar Caracteristica Norma: "' + SELECTED_NORMA_NAME + '" - Título: "' + SELECTED_TITLE_NAME + ' - Requisito: ' + SELECTED_REQUISITO_TEXT + ' "',
                    draggable: true, resizable: false, closeOnEscape: true, autoOpen: true, show: 'clip', hide: 'puff',
                    open: function (type, data) {
                        $(this).find('form')[0].reset();
                        $('#edit-caracteristica-text').val(SELECTED_CARACTERISTICA_TEXT);
                    },
                    close: function () {
                        $('.no-validate').removeClass('no-validate');
                    },
                    buttons: [
                        {
                            id: 'btn-edit-caracteristica',
                            text: 'Guardar',
                            click: function () {
                                $('#edit-caracteristica-dialog-form').submit();
                            }
                        }
                    ]
                });
            }
            else if (iCol == 4) {
                var habilitado = $(this).getCell(rowid, 'Habilitado');
                console.log(habilitado);
                var mensaje = habilitado == 'true' ? '¿Está seguro que desea eliminar esta característica?' : '¿Está seguro que desea activar esta característica?'
                alertify.confirm('Certel S.A.',
                mensaje,
                function (e) {
                    $.ajax({
                        url: 'handlers/Normas.ashx',
                        data: {
                            1: 'removeCaracteristica',
                            id: SELECTED_CARACTERISTICA
                        },
                        success: function (result) {
                            if (result.done) {
                                alertify.success(result.message);
                                loadPanelRequisitos(SELECTED_NORMA);
                                reloadGridCaracteristicas(SELECTED_REQUISITO, SELECTED_REQUISITO_TEXT);
                            }
                            else {
                                alertify.error(result.message);
                            }
                        }
                    });
                },
                function (e) {

                })
                .set('labels',
                    {
                        ok: habilitado == 'true' ? "Eliminar" : "Activar",
                        cancel: 'Cancelar'
                    });
            }
        }
    }).navGrid('#pager-grid-caracteristicas',
                {
                    edit: false, add: false, del: false, search: false,
                    refresh: true, view: false, position: "left", cloneToTop: false
                });

    $("#grid-requisitos").jqGrid({
        mtype: "POST",
        datatype: "json",
        shrinkToFix: true,
        colModel: [
            { label: 'Id', name: 'Id', key: true, hidden: true },
            { label: 'Texto', index: 'Descripcion', name: 'Texto', width: 300, cellattr: function (rowId, tv, rawObject, cm, rdata) { return 'style="white-space: normal;padding: 5px"' }, sortable: true },
            { label: '', name: 'CaracteristicasCount', hidden: true },
            { label: '', name: '', width: 50, formatter: btnCaracteristica, align: 'center' },
            { label: '', name: '', width: 50, formatter: btnEdit, align: 'center' },
            { label: '', name: '', width: 50, formatter: btnRemove, align: 'center' },
            { label: '', name: 'Habilitado', hidden: true },
        ],
        sortname: 'Descripcion', sortorder: 'asc',
        viewrecords: true,
        height: 300,
        width: '100%',
        rowNum: 30,
        pager: "#pager-grid-requisitos",
        caption: 'REQUISITOS',
        hoverrows: false,
        rowattr: function (rd) {
            if (rd.Habilitado == false) {
                return { "class": "redRow" };
            }
        },
        onCellSelect: function (rowid, iCol, cellcontent, e) {

            SELECTED_REQUISITO = $('#grid-requisitos').getCell(rowid, 'Id');
            SELECTED_REQUISITO_TEXT = $('#grid-requisitos').getCell(rowid, 'Texto');
            if (iCol == 3) {
                reloadGridCaracteristicas(SELECTED_REQUISITO, SELECTED_REQUISITO_TEXT);
            }
            else if (iCol == 4) {
                
                $('#edit-requisito-dialog').dialog({
                    modal: true, bgiframe: false, width: 800,
                    title: 'Editar Requisito Norma: "' + SELECTED_NORMA_NAME + '" - Título: "' + SELECTED_TITLE_NAME + '"',
                    draggable: true, resizable: false, closeOnEscape: true, autoOpen: true, show: 'clip', hide: 'puff',
                    open: function (type, data) {
                        $(this).find('form')[0].reset();
                        $('#edit-requisito-text').val(SELECTED_REQUISITO_TEXT);
                    },
                    close: function () {
                        $('.no-validate').removeClass('no-validate');
                    },
                    buttons: [
                        {
                            id: 'btn-edit-title',
                            text: 'Guardar',
                            click: function () {
                                $('#edit-requisito-dialog-form').submit();
                            }
                        }
                    ]
                });
            }
            else if (iCol == 5) {
                var habilitado = $(this).getCell(rowid, 'Habilitado');
                console.log(habilitado);
                var mensaje = habilitado == 'true' ? '¿Está seguro que desea eliminar este requisito?' : '¿Está seguro que desea activar este requisito?'
                alertify.confirm('Certel S.A.',
                mensaje,
                function (e) {
                    $.ajax({
                        url: 'handlers/Normas.ashx',
                        data: {
                            1: 'removeRequisito',
                            id: SELECTED_REQUISITO
                        },
                        success: function (result) {
                            if (result.done) {
                                alertify.success(result.message);
                                loadPanelRequisitos(SELECTED_NORMA);
                                reloadGridRequisitos(SELECTED_TITLE, SELECTED_TITLE_NAME);
                            }
                            else {
                                alertify.error(result.message);
                            }
                        }
                    });
                },
                function (e) {

                })
                .set('labels',
                    {
                        ok: habilitado == 'true' ? "Eliminar" : "Activar",
                        cancel: 'Cancelar'
                    });;
            }
        }
    }).navGrid('#pager-grid-requisitos',
                {
                    edit: false, add: false, del: false, search: false,
                    refresh: true, view: false, position: "left", cloneToTop: false
                });
    // submit principal data
    $('#formFiltros').submit(function (e) {
        e.preventDefault();
        loadPanel($('#f_nombre').val());
        return false;
    })
    .submit()
    .find('input')
        .keyup(function () {
            $(this).closest('form').submit();
        });

    // Add norma
    $('#add').click(function () {
        $('#add-dialog').dialog({
            modal: true, bgiframe: false, width: 800, title: 'Nueva Norma', draggable: true,
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
                        $('#add-dialog-form').submit();
                    }
                }
            ]
        });
    });
    $('#add-dialog-form').submit(function (e) {
        
        e.preventDefault();
        if (!validateForm($(this)))
        {
            alertify.error('Complete los datos requeridos');
            return false;
        }
          
        $.ajax({
            url: 'handlers/Normas.ashx',
            data: {
                1: 'addNorma',
                nombre: $('#add-nombre').val(),
                tipo: $('#add-tipo').val(),
                tituloRegulacion: $('#add-titulo-regulacion').val(),
               // principal: $('#add-norma-principal').val(),
                parrafo: $('#add-parrafo').val(),
                tipoInforme: $('#add-tipo-informe').val()
            },
            success: function (result) {
                if (result.done) {
                    alertify.success(result.message);
                    $('#add-dialog').dialog('close');
                    $('#formFiltros').submit();
                   // combobox($('#add-norma-principal'), { 1: 'normas', norma: 0 }, 'Esta es la norma principal');
                }
                else
                    alertify.error(result.message);
            }
        });
        return false;
    });
    // Edit norma
    $('#edit-dialog-form').submit(function (e) {

        e.preventDefault();
        if (!validateForm($(this))) {
            alertify.error('Complete los datos requeridos');
            return false;
        }

        $.ajax({
            url: 'handlers/Normas.ashx',
            data: {
                1: 'editNorma',
                nombre: $('#edit-nombre').val(),
                tipo: $('#edit-tipo').val(),
                tituloRegulacion: $('#edit-titulo-regulacion').val(),
                
                parrafo: $('#edit-parrafo').val(),
                tipoInforme: $('#edit-tipo-informe').val(),
                id: SELECTED_NORMA
            },
            success: function (result) {
                if (result.done) {
                    alertify.success(result.message);
                    $('#edit-dialog').dialog('close');
                    $('#formFiltros').submit();
                }
                else
                    alertify.error(result.message);
            }
        });
        return false;
    });
    // Add Title
    $('#add-title').click(function(){
        $('#add-title-dialog').dialog({
            modal: true, bgiframe: false, width: 800, title: 'Nuevo Título para la Norma ' + SELECTED_NORMA_NAME, draggable: true,
            resizable: false, closeOnEscape: true, autoOpen: true, show: 'clip', hide: 'puff',
            open: function (type, data) {
                $(this).find('form')[0].reset();
            },
            close: function () {
                $('#add-title-dialog-form input, add-title-dialog-form select, add-title-dialog-form textarea').removeClass('no-validate')
            },
            buttons: [
                {
                    id: 'btn-add-title',
                    text: 'Guardar',
                    click: function () {
                        $('#add-title-dialog-form').submit();
                    }
                }
            ]
        });
    });
    $('#add-title-dialog-form').submit(function(e){
        e.preventDefault();
        if (!validateForm($(this))) {
            alertify.error('Complete los datos requeridos');
            return false;
        }

        $.ajax({
            url: 'handlers/Normas.ashx',
            data: {
                1: 'addTitle',
                title: $('#add-title-title').val(),
                norma: SELECTED_NORMA
            },
            success: function (result) {
                if (result.done) {
                    alertify.success(result.message);
                    $('#add-title-dialog').dialog('close');
                    loadPanelRequisitos(SELECTED_NORMA);
                }
                else
                    alertify.error(result.message);
            }
        });
        return false;
    });
    // edit title
    $('#edit-title-dialog-form').submit(function (e) {
        e.preventDefault();
        if (!validateForm($(this))) {
            alertify.error('Complete los datos requeridos');
            return false;
        }

        $.ajax({
            url: 'handlers/Normas.ashx',
            data: {
                1: 'editTitle',
                title: $('#edit-title-title').val(),
                id: SELECTED_TITLE
            },
            success: function (result) {
                if (result.done) {
                    alertify.success(result.message);
                    $('#edit-title-dialog').dialog('close');
                    loadPanelRequisitos(SELECTED_NORMA);
                }
                else
                    alertify.error(result.message);
            }
        });
        return false;
    });
    // add característica
    $('#add-caracteristica').click(function () {
        if (!SELECTED_REQUISITO)
        {
            alertify.error('Primero seleccione un requisito');
            return;
        }
        $('#add-caracteristica-dialog').dialog({
            modal: true, bgiframe: false, width: 800,
            title: 'Nueva Caracteristica Norma: "' + SELECTED_NORMA_NAME + '" - Título: "' + SELECTED_TITLE_NAME + ' - Requisito: ' + SELECTED_REQUISITO_TEXT + ' "',
            draggable: true, resizable: false, closeOnEscape: true, autoOpen: true, show: 'clip', hide: 'puff',
            open: function (type, data) {
                $(this).find('form')[0].reset();
            },
            close: function () { },
            buttons: [
                {
                    id: 'btn-add-caracteristica',
                    text: 'Guardar',
                    click: function () {
                        $('#add-caracteristica-dialog-form').submit();
                    }
                }
            ]
        });
    });
    $('#add-caracteristica-dialog-form').submit(function (e) {
        e.preventDefault();
        if (!validateForm($(this))) {
            alertify.error('Complete los datos requeridos');
            return false;
        }

        $.ajax({
            url: 'handlers/Normas.ashx',
            data: {
                1: 'addCaracteristica',
                text: $('#add-caracteristica-text').val(),
                requisito: SELECTED_REQUISITO
            },
            success: function (result) {
                if (result.done) {
                    alertify.success(result.message);
                    $('#add-caracteristica-dialog').dialog('close');
                    reloadGridCaracteristicas(SELECTED_REQUISITO, SELECTED_REQUISITO_TEXT);
                    loadPanelRequisitos(SELECTED_NORMA);
                }
                else
                    alertify.error(result.message);
            }
        });
        return false;
    });
    // add requisito
    $('#add-requisito').click(function () {
        $('#add-requisito-dialog').dialog({
            modal: true, bgiframe: false, width: 800,
            title: 'Nuevo Requisito Norma: "' + SELECTED_NORMA_NAME + '" - Título: "' + SELECTED_TITLE_NAME + '"',
            draggable: true, resizable: false, closeOnEscape: true, autoOpen: true, show: 'clip', hide: 'puff',
            open: function (type, data) {
                $(this).find('form')[0].reset();
            },
            close: function () { },
            buttons: [
                {
                    id: 'btn-add-title',
                    text: 'Guardar',
                    click: function () {
                        $('#add-requisito-dialog-form').submit();
                    }
                }
            ]
        });
    });
    $('#add-requisito-dialog-form').submit(function (e) {
        e.preventDefault();
        if (!validateForm($(this))) {
            alertify.error('Complete los datos requeridos');
            return false;
        }

        $.ajax({
            url: 'handlers/Normas.ashx',
            data: {
                1: 'addRequisito',
                text: $('#add-requisito-text').val(),
                title: SELECTED_TITLE
            },
            success: function (result) {
                if (result.done) {
                    alertify.success(result.message);
                    $('#add-requisito-dialog').dialog('close');
                    reloadGridRequisitos(SELECTED_TITLE, SELECTED_TITLE_NAME);
                    SELECTED_REQUISITO = result.id;
                    SELECTED_REQUISITO_TEXT = $('#add-requisito-text').val();
                    reloadGridCaracteristicas(SELECTED_REQUISITO, SELECTED_REQUISITO_TEXT);
                    loadPanelRequisitos(SELECTED_NORMA);
                }
                else
                    alertify.error(result.message);
            }
        });
        return false;
    });
    // edit característica
    $('#edit-caracteristica-dialog-form').submit(function (e) {
        e.preventDefault();
        if (!validateForm($(this))) {
            alertify.error('Complete los datos requeridos');
            return false;
        }

        $.ajax({
            url: 'handlers/Normas.ashx',
            data: {
                1: 'editCaracteristica',
                text: $('#edit-caracteristica-text').val(),
                id: SELECTED_CARACTERISTICA
            },
            success: function (result) {
                if (result.done) {
                    alertify.success(result.message);
                    $('#edit-caracteristica-dialog').dialog('close');
                    reloadGridCaracteristicas(SELECTED_REQUISITO, SELECTED_REQUISITO_TEXT);
                    loadPanelRequisitos(SELECTED_NORMA);
                }
                else
                    alertify.error(result.message);
            }
        });
        return false;
    });
    // edit requisito
    $('#edit-requisito-dialog-form').submit(function (e) {
        e.preventDefault();
        if (!validateForm($(this))) {
            alertify.error('Complete los datos requeridos');
            return false;
        }

        $.ajax({
            url: 'handlers/Normas.ashx',
            data: {
                1: 'editRequisito',
                text: $('#edit-requisito-text').val(),
                id: SELECTED_REQUISITO
            },
            success: function (result) {
                if (result.done) {
                    alertify.success(result.message);
                    $('#edit-requisito-dialog').dialog('close');
                    reloadGridRequisitos(SELECTED_TITLE, SELECTED_TITLE_NAME);
                    loadPanelRequisitos(SELECTED_NORMA);
                }
                else
                    alertify.error(result.message);
            }
        });
        return false;
    });

    // add termino y definición
    $('#terminos-submit').click(function (e) {
        $('#terminos-form').submit();
    });
    $('#terminos-form').submit(function (e) {
        e.preventDefault();
        if (!validateForm($(this))) {
            alertify.error('Complete los datos requeridos');
            return false;
        }
        $.ajax({
            url: 'handlers/Normas.ashx',
            method: 'POST',
            data: {
                1: 'saveTermino',
                termino: $('#termino').val(),
                definicion: $('#definicion').val(),
                norma: SELECTED_NORMA
            },
            success: function (result) {
                if(result.done) {
                    loadPanelTerminos(SELECTED_NORMA);
                    alertify.success(result.message);
                    $('#terminos-form')[0].reset();
                    $('#termino').focus();
                }
                else {
                    alertify.error(result.message);
                }
            }
        });
    });
    $('#edit-terminos-form').submit(function (e) {
        e.preventDefault();
        if (!validateForm($(this))) {
            alertify.error('Complete los datos requeridos');
            return false;
        }
        $.ajax({
            url: 'handlers/Normas.ashx',
            method: 'POST',
            data: {
                1: 'editTermino',
                termino: $('#edit-termino').val(),
                definicion: $('#edit-definicion').val(),
                id: SELECTED_TERMINO_ID,
                
            },
            success: function (result) {
                if (result.done) {
                    alertify.success(result.message);
                    loadPanelTerminos(SELECTED_NORMA);
                    $('#edit-terminos').dialog('close');
                }
                else {
                    alertify.error(result.message);
                }
            }
        });
    });
    $('#edit-terminos-submit').click(function () {
        $('#edit-terminos-form').submit();
    });
    // Resize Panels
    $(window).bind('resize', function (e) {

        // grid
        if (grid = $('.ui-jqgrid-btable:visible')) {
            grid.each(function (index) {
                gridId = $(this).attr('id');
                gridParentWidth = $('#gbox_' + gridId).parent().width();
                gridParentHeight = $('#gbox_' + gridId).parent().height();
                $('#' + gridId).setGridWidth(gridParentWidth);
                //$('#' + gridId).setGridHeight(gridParentHeight - 60);
            });
        }

    }).trigger('resize');
    
});

function loadPanelTerminos(norma)
{
    
    $.ajax({
        url: 'handlers/Normas.ashx',
        data: {
            1: 'getTerminos',
            norma: norma
        },
        success: function (result) {
            console.log(result);
            $('#terminos-list').empty();
            if(result.done)
            {
                $(result.data).each(function(i, item){
                    $('#terminos-list')
                        .append($('<li>')
                            .addClass('list-group-item')
                            .append($('<label>')
                                .text(item.Termino))
                            .append($('<br />'))
                            .append($('<span>')
                                .text(item.Definicion))
                        
                        .append($('<div>')
                            .addClass('botonera')
                            .append($('<i>')
                                .addClass('fa fa-pencil')
                                .click(function () {
                                    SELECTED_TERMINO_ID = item.Id;
                                    editTermino(item.Id, item.Termino, item.Definicion);
                                }))

                            .append($('<i>')
                                .addClass('fa fa-remove')
                                .click(function () {
                                    removeTermino(item.Id);
                                }))));
                });
                
            }
        }
    })
}
function removeTermino(id)
{
    alertify.confirm('Certel', '¿Está seguro de eliminar este término?', function () {
        $.ajax({
            url: 'handlers/Normas.ashx',
            type: 'POST',
            data: {
                1: 'removeTermino',
                id: id
            },
            success: function(result)
            {
                if(result.done)
                {
                    alertify.success(result.message);
                    loadPanelTerminos(SELECTED_NORMA);
                }
                else
                {
                    alertify.error(result.message);
                }

            }
        })
    }, function () { });
}
function editTermino(id, termino, definicion)
{

    $('#edit-terminos').dialog({
        modal: true, bgiframe: false, width: 800, title: 'Editar Término ' + termino, draggable: true,
        resizable: false, closeOnEscape: true, autoOpen: true, show: 'clip', hide: 'puff',
        open: function (type, data) {
            $(this).find('form')[0].reset();
            $('#edit-termino').val(termino);
            $('#edit-definicion').val(definicion);
        },
        close: function () {
            $(this).find('form')[0].reset();
            $('#edit-termino, #edit-definicion').removeClass('no-validate');
        }
    });
}
function loadPanel(nombre)
{
    $('#panelNormas').empty();
    $('#panelNormas2').empty();
    $.ajax({
        url: 'handlers/Normas.ashx',
        data: {
            1: 'getNormas',
            nombre: nombre
        },
        success: function(result)
        {
            $('#panelNormas').empty();
            $('#panelNormas2').empty();
            $(result.principales).each(function (i, item) {
                var principal;
                principal = $('<div>')
                .addClass('node')
                .append($('<div>')
                    .addClass('title')
                    .text(item.Nombre))
                .append($('<div>')
                    .addClass('subtitle')
                    .text(item.TituloRegulacion))
                .appendTo($('#panelNormas'))
                .click(function () {
                    SELECTED_NORMA = item.Id;
                    SELECTED_NORMA_NAME = item.Nombre;
                    //combobox($('#edit-norma-principal'), { 1: 'normas', norma: SELECTED_NORMA }, 'Esta es la norma principal');
                    openEditDialog(item, null);
                    loadPanelRequisitos(item.Id);
                    loadPanelTerminos(item.Id);
                })
                .droppable({
                    accept: ".node-secundario",
                    drop: function (event, ui) {
                        var draggableId = ui.draggable.data('id');
                        addSecondaryNorm(draggableId, item.Id, principal);
                    }
                });
                ;
                var secs = item.Secundarias;
                $(secs).each(function (j, jtem) {
                    addLabelSecondary(principal, jtem, item);
                });
            });

            $(result.secundarias).each(function (s, secundaria) {
                $('<div>')
                    .addClass('node node-secundario')
                    .data('id', secundaria.Id)
                    .append($('<div>')
                        .addClass('title')
                        .text(secundaria.Nombre))
                    .append($('<div>')
                        .addClass('subtitle')
                        .text(secundaria.TituloRegulacion))
                    .appendTo($('#panelNormas2'))
                    .click(function () {
                        SELECTED_NORMA = secundaria.Id;
                        SELECTED_NORMA_NAME = secundaria.Nombre;
                        //combobox($('#edit-norma-principal'), { 1: 'normas', norma: SELECTED_NORMA }, 'Esta es la norma principal');
                        openEditDialog(secundaria, null)
                        loadPanelRequisitos(secundaria.Id);
                        loadPanelTerminos(secundaria.Id);
                    })
                    .draggable({
                        helper: 'clone',
                        revert: 'invalid',
                        zIndex: 99999,
                        containment: "document",
                        appendTo: 'body'
                    });
            });
            
        }
    });
}
function removeSecondaryNorm(secondary, primary, label)
{
    $.ajax({
        url: 'handlers/Normas.ashx',
        data: {
            1: 'removeSecondaryNorm',
            secondary: secondary,
            primary: primary
        },
        success: function (result) {
            if (result.done) {
                label.remove();
            }
            else
                alertify.error(result.message);
        }
    });
}
function addLabelSecondary(principal, jtem, item)
{
    var label;
    principal.append(label = $('<div>')
            .addClass('secondary')
            .append($('<label>')
                .addClass('label label-default')
                .text(jtem.Nombre))
            .append($('<span>')
                .append($('<i>')
                    .addClass('fa fa-remove'))
            .click(function (e) {
                e.preventDefault();
                e.stopPropagation();
                removeSecondaryNorm(jtem.Id, item.Id, label)
            })));
}
function addSecondaryNorm(secondary, primary, principal)
{
    $.ajax({
        url: 'handlers/Normas.ashx',
        data: {
            1: 'addSecondaryNorm',
            secondary: secondary,
            primary: primary
        },
        success: function (result) {
            if (result.done) {
                alertify.success(result.message);
                var item = { Id: primary }
                addLabelSecondary(principal, result.item, item);
            }
            else
                alertify.error(result.message);
        }
    });
}

function openEditDialog(item, principal)
{
    $('#edit-dialog').dialog({
        modal: true, bgiframe: false, width: 800, title: 'Editar Norma ' + name, draggable: true,
        resizable: false, closeOnEscape: true, autoOpen: true, show: 'clip', hide: 'puff',
        open: function (type, data) {
            $(this).find('form')[0].reset();
            $('#tabs').tabs({ active: 0 });
            $('#edit-nombre').val(item.Nombre);
            $('#edit-tipo').val(item.TipoNormaId);
            $('#edit-titulo-regulacion').val(item.TituloRegulacion);
            if (item.TipoNormaId == 1)
            {
                $('#edit-tipo-informe').val(item.TipoInformeId);
                // $('#edit-norma-principal').val(0);
                $('#edit-parrafo').val('');
                $('#fg-parrafo').hide();
                $('#fg-tipo-informe').show();
            }
            else {
                $('#edit-parrafo').val(item.Parrafo);
                $('#edit-tipo-informe').val(0);
                $('#fg-tipo-informe').hide();
                $('#fg-parrafo').show();
            }
            
        },
        close: function () {
            $('#edit-dialog-form input, #edit-dialog-form select, #edit-dialog-form textarea').removeClass('no-validate');
        },
        buttons: [
            {
                id: 'btn-edit',
                text: 'Guardar',
                click: function () {
                    $('#edit-dialog-form').submit();
                }
            }
        ]
    });
}
function loadPanelRequisitos(normaId)
{
    $('#panel-requisitos').empty();
    $.ajax({
        url: 'Handlers/Normas.ashx',
        data: { 1: 'getTitulos', normaId: normaId },
        success: function (result) {
            console.log(result);
            if (result.length > 0) {
                var list;
                $('#panel-requisitos')
                   .append(list = $('<div>')
                   .addClass('list-group'));
                $(result).each(function (i, item) {
                    list
                        .append($('<button>')
                                .prop('type', 'button')
                                .addClass('list-group-item')
                                .text(item.Titulo)
                                .append($('<i>')
                                        .addClass('fa fa-trash pull-right')
                                        .prop('title', 'Eliminar')
                                        .tooltip()
                                        .click(function () {
                                            removeTitle(item.Id, item.Titulo, item.Requisitos);
                                        }))
                                .append($('<i>')
                                        .addClass('fa fa-pencil pull-right')
                                        .prop('title', 'Modificar')
                                        .tooltip()
                                        .click(function () {
                                            $('#edit-title-dialog').dialog({
                                                modal: true, bgiframe: false, width: 800, title: 'Editar Título ' + item.Titulo, draggable: true,
                                                resizable: false, closeOnEscape: true, autoOpen: true, show: 'clip', hide: 'puff',
                                                open: function (type, data) {
                                                    $(this).find('form')[0].reset();
                                                    $('#edit-title-title').val(item.Titulo);
                                                    SELECTED_TITLE = item.Id;
                                                },
                                                close: function () {
                                                    $('#edit-title-dialog-form input, #edit-title-dialog-form select, #edit-title-dialog-form textarea').removeClass('no-validate');
                                                },
                                                buttons: [
                                                    {
                                                        id: 'btn-edit-title',
                                                        text: 'Guardar',
                                                        click: function () {
                                                            $('#edit-title-dialog-form').submit();
                                                        }
                                                    }
                                                ]
                                            });
                                        }))
                                .append($('<i>')
                                    .addClass('fa fa-list pull-right')
                                    .prop('title', 'Requisitos (' + item.Requisitos + ')')
                                    .tooltip()
                                    .click(function () {
                                        SELECTED_TITLE = item.Id;
                                        SELECTED_TITLE_NAME = item.Titulo;
                                        reloadGridRequisitos(item.Id, item.Titulo);
                                        $('#panel-caracteristicas').hide();
                                        $('#grid-requisitos-dialog').dialog({
                                            modal: true, bgiframe: false, width: $(window).width() - 20, height: $(window).height() - 20, title: 'Requisitos Título "' + item.Titulo + '"', draggable: true,
                                            resizable: false, closeOnEscape: true, autoOpen: true, show: 'clip', hide: 'puff',
                                            open: function(){
                                                //resizeGrid($('#grid-requisitos'));
                                            },
                                            buttons:
                                                [{
                                                    id: 'btnCerrar',
                                                    text: 'Cerrar',
                                                    click: function () {
                                                        $(this).dialog('close');
                                                    }
                                                }]
                                        });
                                    }))
                                );
                })
            }
        }

    });
}
function reloadGridRequisitos(id, text)
{
    jQuery("#grid-requisitos")
        .jqGrid('setGridParam',
                {
                    url: 'handlers/Normas.ashx',
                    postData: { 1: 'grid_requisitos', title: id },
                })
        .jqGrid('setCaption', text)
        .trigger("reloadGrid");
}
function reloadGridCaracteristicas(id, text) {
    if (text.length > 20)
        text = text.substring(0, 19) + '...';

    
    $('#panel-caracteristicas').show();
    jQuery("#grid-caracteristicas")
        .jqGrid('setGridParam',
                {
                    url: 'handlers/Normas.ashx',
                    postData: { 1: 'grid_caracteristicas', requisito: id },
                })
        .jqGrid('setCaption', text)
        .trigger("reloadGrid");
    
        
}
function removeTitle(id, title, requisitos)
{
    var message = requisitos > 0
                    ?   'Este título contiene ' + requisitos + ' requisitos. Presione Aceptar si desea eliminar todo el contenido.'
                    :   '¿Está seguro que desea eliminar este título?'
    alertify.confirm('Certel S.A.',
        message,
        function (e) {
            $.ajax({
                url: 'handlers/Normas.ashx',
                data: {
                    1: 'removeTitle',
                    id: id
                },
                success: function (result) {
                    if(result.done)
                    {
                        alertify.success(result.message);
                        loadPanelRequisitos(SELECTED_NORMA);
                        
                    }
                    else
                    {
                        alertify.error(result.message);
                    }
                }
            });
        },
        function (e) {

        })
        .set('labels',
            {
                ok: 'Aceptar',
                cancel: 'Cancelar'
            });
}
function showChildGrid(parentRowID, parentRowKey) {
    SELECTED_REQUISITO = parentRowKey;
    var childGridID = parentRowID + "_table";
    var childGridPagerID = parentRowID + "_pager";
    console.log(parentRowID, parentRowKey);
    // send the parent row primary key to the server so that we know which grid to show
    var childGridURL = parentRowKey + ".json";
    //childGridURL = childGridURL + "&parentRowID=" + encodeURIComponent(parentRowKey)

    // add a table and pager HTML elements to the parent grid row - we will render the child grid here
    $('#' + parentRowID).append('<table id=' + childGridID + '></table><div id=' + childGridPagerID + ' class=scroll></div>');

    $("#" + childGridID).jqGrid({
        url: 'handlers/Normas.ashx',
        postData: { 1: 'grid_caracteristicas', requisito: parentRowKey },
        mtype: "POST",
        datatype: "json",
        autowidth: true,
        shrinkToFix: true,
        colModel: [
            { label: 'Id', name: 'Id', key: true, hidden: true },
            { label: 'Habilitado', name: 'Habilitado', hidden: true },
            { label: 'Texto', index: 'Descripcion', name: 'Texto', width: 300, cellattr: function (rowId, tv, rawObject, cm, rdata) { return 'style="white-space: normal; padding: 5px"' }, sortable: true },
            { label: '', name: '', width: 50, formatter: btnEdit, align: 'center' },
            { label: '', name: '', width: 50, formatter: btnRemove, align: 'center' },
        ],
        sortname: 'Descripcion', sortorder: 'asc',
        viewrecords: true,
        width: 500,
        height: '100%',
        rownumbers: true, // show row numbers
        rownumWidth: 25, // the width of the row numbers columns
        rowNum: 30,
        pager: "#" + childGridPagerID,
        caption: 'SELECCIONE UN REQUISITO',
        
        onCellSelect: function (rowid, iCol, cellcontent, e) {
            SELECTED_CARACTERISTICA = $(this).getCell(rowid, 'Id');
            SELECTED_CARACTERISTICA_TEXT = $(this).getCell(rowid, 'Texto');
            if (iCol == 4) {
                if (!SELECTED_REQUISITO) {
                    alertify.error('Primero seleccione un requisito');
                    return;
                };
                console.log(SELECTED_CARACTERISTICA_TEXT);
                
                $('#edit-caracteristica-dialog').dialog({
                    modal: true, bgiframe: false, width: 800,
                    title: 'Editar Caracteristica Norma: "' + SELECTED_NORMA_NAME + '" - Título: "' + SELECTED_TITLE_NAME + ' - Requisito: ' + SELECTED_REQUISITO_TEXT + ' "',
                    draggable: true, resizable: false, closeOnEscape: true, autoOpen: true, show: 'clip', hide: 'puff',
                    open: function (type, data) {
                        $(this).find('form')[0].reset();
                        $('#edit-caracteristica-text').val(SELECTED_CARACTERISTICA_TEXT);
                    },
                    close: function () {
                        $('.no-validate').removeClass('no-validate');
                    },
                    buttons: [
                        {
                            id: 'btn-edit-caracteristica',
                            text: 'Guardar',
                            click: function () {
                                $('#edit-caracteristica-dialog-form').submit();
                            }
                        }
                    ]
                });
            }
            else if (iCol == 5) {
                alertify.confirm('Certel S.A.',
                '¿Está seguro que desea eliminar esta característica?',
                function (e) {
                    $.ajax({
                        url: 'handlers/Normas.ashx',
                        data: {
                            1: 'removeCaracteristica',
                            id: SELECTED_CARACTERISTICA
                        },
                        success: function (result) {
                            if (result.done) {
                                alertify.success(result.message);
                                loadPanelRequisitos(SELECTED_NORMA);
                                $("#" + childGridID).jqGrid().trigger('reloadGrid');
                                //reloadGridCaracteristicas(SELECTED_REQUISITO, SELECTED_REQUISITO_TEXT);
                            }
                            else {
                                alertify.error(result.message);
                            }
                        }
                    });
                },
                function (e) {

                })
                .set('labels',
                    {
                        ok: 'Aceptar',
                        cancel: 'Cancelar'
                    });
            }
        }
    }).navGrid( "#" + childGridPagerID,
                {
                    edit: false, add: false, del: false, search: false,
                    refresh: true, view: false, position: "left", cloneToTop: false
                });
        

}
function btnEdit() {
    return '<div class="btn-grid azul"><i class="fa fa-pencil"></i></div>'
}
function btnCaracteristica() {
    return '<div class="btn-grid verde"><i class="fa fa-list"></i></div>'
}
function btnRemove(cellvalue, option, rowObject) {
    var habilitado = rowObject.Habilitado == true;
    if (habilitado)
        return '<div class="btn-grid rojo"><i class="fa fa-trash"></i></div>';
    else
        return '<div class="btn-grid verde"><i class="fa fa-check"></i></div>';
}