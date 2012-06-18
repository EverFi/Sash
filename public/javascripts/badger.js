/*

Badge Issuing API Code

Usage:

include: <script src="http://www.someplace.net/badge.js

Badger.issue('http://www.someplace.net/badge/assertion_url', 'jimmy_john12')

*/

window.Badger = (function(){
  var modalTemplate = Handlebars.compile(window.TMPL.issueModal);

  return {
    earn: function(badge, username, callback){
      var d = {username: username};
      $.getJSON(badge, d, function(r){
        if(r && r.earned){
          r.username = username;
          var modal = $(modalTemplate(r));
          modal.on('click', '[data-dismiss]', function(){
            $(modal).remove();
          })
          $('body').append(modal);
          callback(r, badge, username);
        }
        // Don't bother doing anything, the user will
        // never even know!
      })
    }
  }

})()

