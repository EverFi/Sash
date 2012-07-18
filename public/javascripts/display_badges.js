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

    fetch: function (callback){
      var self, xhr;
      self = this
      xhr = $.getJSON(
        this.url,
        { username: this.user }
      );
      xhr.done( function(badges){
        self.render(badges)
        self.target.trigger('badge_load:success', [badges]);
      } );
      xhr.fail( function() {
        $(self.target).trigger('badge_load:fail') 
      })
      if(callback) xhr.complete(callback);
      return xhr;
    },

    render: function(badges) {
      var html = [];
      for(var i=0,l=badges.length;i< l;i++) {
        var b = badges[i];
        b.description = _.stripTags(b.description);
        html.push(this.template(b));
      }
      html = html.join('');
      this.target.html(html);
      this.target.trigger('badge_render', [badges]);
    }
  }

  window.Badger = Badger;

})();
