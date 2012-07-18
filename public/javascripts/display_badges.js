(function(){

  var BADGE_TEMPLATE =
    "<div class='badge'>"+
      "<div class='badge-name'>{{name}}</div>"+
      "{{^seen}}<div class='not-seen'></div>{{/seen}}"+
      "<img src='{{image}}' />"+
    "</div>";

  function Badger(options){
    this.template = Handlebars.compile(options.template || BADGE_TEMPLATE);
    this.target = options.target || $('#badge-target');
    this.user = options.user;
    this.url = 'http://localhost:3000/users/badges.json?callback=?';
  }

  Badger.prototype = {

    fetch: function (){
      var self, xhr;
      self = this
      xhr = $.getJSON(
        this.url,
        { username: this.user }
      );
      xhr.done( function(badges){ self.render(badges) } );
      xhr.fail( function() {
        $(self.target).trigger('badge_display:fail') 
      })
      return xhr;
    },

    render: function(badges) {
      var html = [];
      for(var i=0,l=badges.length;i< l;i++) {
        html.push(this.template(badges[i]));
      }
      html = html.join('');
      this.target.html(html);
    }
  }

  window.Badger = Badger;

  $(document).ready(function(){
    var badger = new Badger({user: 'unicorn71'});
    badger.fetch();
  });

})();
