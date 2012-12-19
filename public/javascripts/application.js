
window.Utils = {
  form: {
    basicValidation: function (form) {
      var inputs = $( 'input:required', form );
      var stat = true;
      $.each(inputs, function (index, input){
        if ( !$(this).val() || $(this).val() === '' ) {
          stat = false;
        }
      });
      return stat;
    }
  }
}

$(document).ready(function(){

  // Remote form hadler
  $('form[data-remote=true]').on('submit', function(e){
    var method, form, action, methodOveride, params;
    form = $(this);
    action = form.attr("action");
    method = form.attr("method");
    method = method || 'get';
    params = form.serialize();
    if(params.match(/_method=delete/));
      if(!confirm('are you sure?')) return false;

    $.ajax({
      url: action,
      data: params,
      type: method
    }).done(function(response, stat, xhr){
      form.trigger('ajax:success', [response, stat, xhr]);
    });

    e.preventDefault();
  })

  // On the delete form, remove the parent LI on success
  $('form.delete').on('ajax:success', function(e, response, stat, xhr){
    $(this).parents("li").remove();
  });

  // Validate create form
  $('form.new-badge input, textarea').on('change', function(e) {
    if ( Utils.form.basicValidation( $('form.new-badge') ) ) {
      $('input:submit').removeAttr('disabled')
    }
  });
});