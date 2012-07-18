(function(){

  var BADGE_TEMPLATE =
    "<div class='badge'>"+
      "<div class='badge-name'>{{name}}</div>"+
      "{{^seen}}<div class='not-seen'></div>{{/seen}}"+
      "<div class='badge-image'><img src='{{image}}' "+
      "title='{{description}}' rel=tipsy /></div>"+
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
        var b = badges[i];
        b.description = _.str.stripTags(b.description);
        html.push(this.template(b));
      }
      html = html.join('');
      this.target.html(html);
      $('[rel=tipsy]').tipsy({fade: true, gravity: 'n', html: true});
    }
  }

  window.Badger = Badger;

  $.fn.stripTags = function(){
    return this.replaceWith(this.html().replace(/<\/?[^>]+>/gi, ''));
  }

  $(document).ready(function(){
    var badger = new Badger({user: 'unicorn71'});
    badger.fetch();
  });

})();
