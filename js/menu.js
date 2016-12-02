$(function () {

    
    $.ajax({
        url: 'handlers/Menu.ashx',
        type: 'POST',
        success: function (result) {
            if (result.code == 999)
            {
                window.location = 'Login.aspx';
            }
            console.log('menu', result);
            var menu = $('<nav>')
                .attr('id', '_Menu_container')
                .addClass('navbar')
                .addClass('navbar-default')
                .attr('role', 'navigation')

            menu
             .append($('<div>')
                .addClass('navbar-header')
                .append($('<button>')
                    .addClass('navbar-toggle')
                    .addClass('collapsed')
                    .attr('data-toggle', 'collapse')
                    .attr('data-target', '#bs-example-navbar-collapse-1')
                    .attr('aria-expanded', false)
                    .append($('<span>')
                        .addClass('sr-only')
                        .text('toggle navigation'))
                    .append($('<span>')
                       .addClass('icon-bar'))
                    .append($('<span>')
                       .addClass('icon-bar'))
                    .append($('<span>')
                       .addClass('icon-bar')))
                .append($('<a>')
                    .addClass('navbar-brand')
                    .prop('href', 'Login.aspx')
                    .append($('<img>')
                        .prop('src', 'css/images/logo.png')
                        .prop('width', '100')
                        )));
            var nav = $('<div>')
               .addClass('collapse')
               .addClass('navbar-collapse')
                .addClass('navbar-ex1-collapse')
               .attr('id', 'bs-example-navbar-collapse-1')
            var ul = $('<ul>')
                   .addClass('nav')
                   .addClass('navbar-nav');

            var items = ["Normas", "Inspecciones", "Servicios"];
            for (var i = 0; i < items.length; i++) {

                ul.append($('<li>')
                         .addClass('menu-li')
                         //.addClass(activo == item.ModuloId ? 'active' : '')
                         .append($('<a>')
                             .addClass('menu-li-a')
                             .text(items[i])
                             .prop('href', items[i] + '.aspx')))

            }

            var userUl = $('<ul>')
                         .addClass('nav')
                         .addClass('navbar-nav')
                         .addClass('navbar-right')
                         .append($('<li>')
                             .addClass('dropdown')
                             .append($('<a>')
                                 .addClass('name-user')
                                 .addClass('dropdown-toggle')
                                 .attr('data-toggle', 'dropdown')
                                 .text(result.Nombre)
                                 .append($('<b>')
                                     .addClass('caret')))
                                 .append($('<ul>')
                                 .addClass('dropdown-menu')
                                 .append($('<li>')
                                     .append($('<a>')
                                         .text('Salir')
                                         .prop('href', 'Login.aspx')))
                                .append($('<li>')
                                     .append($('<a>')
                                         .text('Cambiar Contraseña')
                                         .click(function () {
                                             div = $('<div>')
                                                        .prop('id', 'changePass')
                                                        .append(form = $('<form>')
                                                            .append($('<div>')
                                                                .addClass('form-group')
                                                                .append($('<label>')
                                                                    .prop('for', 'chp_pass'))
                                                                .append($('<input>')
                                                                    .addClass('form-control')
                                                                    .prop('type', 'password')
                                                                    .prop('id', 'chp_pass')
                                                                    .prop('placeholder', 'Actual Contraseña')))
                                                            .append($('<div>')
                                                                .addClass('form-group')
                                                                .append($('<label>')
                                                                    .prop('for', 'chp_pass1'))
                                                                .append($('<input>')
                                                                    .addClass('form-control')
                                                                    .prop('type', 'password')
                                                                    .prop('id', 'chp_pass1')
                                                                    .prop('placeholder', 'Nueva Contraseña. (De 4 a 8 caracteres)')))
                                                            .append($('<div>')
                                                                .addClass('form-group')
                                                                .append($('<label>')
                                                                    .prop('for', 'chp_pass2'))
                                                                .append($('<input>')
                                                                    .addClass('form-control')
                                                                    .prop('type', 'password')
                                                                    .prop('id', 'chp_pass2')
                                                                    .prop('placeholder', 'Repita Nueva Contraseña. (De 4 a 8 caracteres)')))
                                                        .submit(function () {
                                                            console.log('submit');
                                                            if (!$('#chp_pass').val() || !$('#chp_pass1').val() || !$('#chp_pass2').val()) {
                                                                alertify.error('Complete los datos');
                                                                return false;
                                                            }
                                                            if ($('#chp_pass1').val() != $('#chp_pass2').val()) {
                                                                alertify.error('Las contraseñas no coindiden!');
                                                                return false;
                                                            }
                                                            if ($('#chp_pass1').val().length < 4 || $('#chp_pass1').val().length > 8) {
                                                                alertify.error('La contraseña debe tener entre 4 y 8 caracteres');
                                                                return false;
                                                            }

                                                            $.ajax({
                                                                url: 'handlers/ChangePass.ashx',
                                                                method: 'post',
                                                                data: {
                                                                    oldPass: $('#chp_pass').val(),
                                                                    newPass: $('#chp_pass1').val()
                                                                },
                                                                success: function (result) {

                                                                    if (result.code == 1) {
                                                                        alertify.success(result.message);
                                                                        div.dialog('close');
                                                                    }
                                                                    else {
                                                                        alertify.error(result.message);
                                                                    }
                                                                }
                                                            })
                                                            return false;
                                                        }))
                                                        .appendTo($('body'))
                                                        .css('display', 'none')
                                                        .dialog({
                                                            modal: true,
                                                            title: 'Cambiar Contraseña',
                                                            autoOpen: true,
                                                            width: 400,
                                                            close: function () {
                                                                div.remove();
                                                            },
                                                            buttons: [
                                                                {
                                                                    id: 'savenewpass',
                                                                    text: 'Cambiar',
                                                                    click: function () {
                                                                        form.submit();
                                                                    }
                                                                }
                                                            ]
                                                        });
                                         })))))
            nav.append(ul);
            nav.append(userUl);
            menu.append(nav);
            $("#cssmenu")
             .append(menu)

        }
    });

            
            

            
            
})
    //});

    



