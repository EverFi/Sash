Badgifier = (function() {

  IssueBadge = function() {

  }

  IssueBadge.prototype = {

  }

  window.IssueBadge = IssueBadge;

  return {
    IssueBadge: IssueBadge,
    badgify: function() {
      console.log("badgify!");
      $(document).on('click', '[data-issueBadge]', function(){
        var username, badgeID;
        badgeID = $(this).data('badge');
        username = $(this).data('username');
        console.log(badgeID, username);
        Badger.earn(badgeID, username, function(badgingResponse){
          // Here we will show the interface saying 'Congrats you
          // were issued this awesome new badge!'

          console.log(badgingResponse, 'issued the badge mfer!');
        });
      })
    }
  }

})();


$(document).ready(function() {
  Badgifier.badgify();
});
