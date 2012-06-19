
window.TMPL = {

  issueModal: "\
    <div class='modal'>\
      <div class='modal-header'>\
        <button href='#' class='close' data-dismiss>x</button>\
        <h3>Hey <em>{{username}}</em>! You were just awarded \
          this awesome badge!</h3>\
      </div>\
      <div class='modal-body'>\
        <h4>{{badge.name}}</h4>\
        <img src='{{badge.image}}' />\
        <div class='details'>\
          {{badge.details}} \
        </div>\
        <ul>\
          <li><a hrew='#'>View all your badges!</a></li>\
        </ul>\
      </div>\
    </div>\
  "
}
