$(document).ready(function () {
    $('#user').focus();
    $('#form-login').submit(function (e) {
        e.preventDefault();
        $.ajax({
            url: 'handlers/Login.ashx',
            method: 'post',
            data: {
                user: $('#user').val(),
                pass: $('#pass').val(),
            },
            success: function (result) {
                console.log(result);
                if(result.done)
                {
                    window.location.replace('Inspecciones.aspx');
                }
                else
                {
                    alertify.error(result.message);
                    $('#pass').val('').focus();
                }
            }

        })
    });

});