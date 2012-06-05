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
})
