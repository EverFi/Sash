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
      response = {
        earned: true,
        badge: {
          id: "1234",
          name: "Super Badge",
          image: "http://localhost:3000/images/logo-badge.png",
          details: "Badge for being awesome"
        },
        message: "Badge was successfully Awarded!"
      }

      var modal = $(modalTemplate(response));

      $('body').append(modal);
      callback(response, badge, username);
    }
  }

})()

