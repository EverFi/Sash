$(document).ready(function(){
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
    }).done(function(response, xhr){
      form.parents("li").remove();
    });

    e.preventDefault();
  })
})
