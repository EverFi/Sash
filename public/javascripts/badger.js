/*

Badge Issuing API Code

Usage:

include: <script src="http://www.someplace.net/badge.js

Badger.issue('http://www.someplace.net/badge/assertion_url', 'jimmy_john12')

*/

window.Badger = (function(){
  var modalTemplate = Handlebars.compile(window.TMPL.issueModal);

  var handleEarnResponse = function(res, username, callback){
    if(res && res.earned){
      res.username = username;
      var modal = $(modalTemplate(res));
      modal.on('click', '[data-dismiss]', function(){
        $(modal).remove();
      });
      $('body').append(modal);
      callback(res, badge, username);
    }
    // Don't bother doing anything, the user will
    // never even know!
    alert("user already has badge, dufus");
  }

  return {
    earn: function(badge, username, callback){
      var d = {username: username};
      $.getJSON(badge+"?callback=?", d, function(res) {
        handleEarnResponse(res, username, callback);
      });
    }
  }

})()

