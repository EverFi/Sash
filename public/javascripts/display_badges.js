(function(){
  var HoneyBadger = (window.HoneyBadger || {});
  var BADGE_TEMPLATE =
    "<div class='badge'>"+
      "<div class='badge-name'>{{name}}</div>"+
      "{{^seen}}<div class='not-seen'></div>{{/seen}}"+
      "<div class='badge-image'><img src='{{image}}' "+
      "title='{{description}}' rel=tipsy /></div>"+
    "</div>";

  // badger accepts an options object with a target element,
  // string template for rendering one badge and a username of
  // the person who's badges you would like to show

  HoneyBadger.Display = function (options){
    this.template = Handlebars.compile(options.template || BADGE_TEMPLATE);
    this.target = options.target || $('#badge-target');
    this.username = options.username;
    this.url = 'http://localhost:3000/users/badges.json?callback=?';
  }

  var checkForNewBadges function(badges){
    var newBadges = [];
    for(var i=0,l=badges.length;i<l;i++){
      if(!badges[i].seen){
        newBadges.push(badges[i]);
      }
    }
    if(newBadges.length > 0) {
      $(document).trigger('new_badges', [newBadges]);
    }
  }

  HoneyBadger.Display.prototype = {

    fetch: function (callback){
      var self, xhr;
      self = this
      xhr = $.getJSON(
        this.url,
        { username: this.username }
      );
      xhr.done( function(badges){
        self.render(badges)
        self.target.trigger('badge_load:success', [badges]);
        checkForNewBadges(badges);
      } );
      xhr.fail( function() {
        $(self.target).trigger('badge_load:fail');
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
    },

    markBadgeSeen: function(badge) {
      $.getJSON(
        'http:/localhost:3000/users/badges/'+ badge.id+'/seen',
        {username: this.username},
        function(){
          //OK THANKS BYE!
      });
    }

  }

  window.HoneyBadger = HoneyBadger;

})();
