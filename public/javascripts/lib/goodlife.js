(function(GoodLife){

  GoodLife.store = {

    _loadItems: function() {
      var items = localStorage.getItem('items');
      if ( !items ) {
        localStorage.setItem('items', JSON.stringify({}));
      }
      return JSON.parse( localStorage.getItem('items') );
    },

    _saveItems: function(newItems) {
      localStorage.setItem('items', JSON.stringify(newItems));
    },

    MAX_AGE: 60000,

    setCacheMaxAge: function (age) {
      this.MAX_AGE = age;
    },

    itemExists: function(key) {
      var items = this._loadItems();
      if ( localStorage.getItem( key ) && items[ key ] ) {
        return true;
      }
      return false;
    },

    _birth: function(key) {
      var items = this._loadItems();
      items[ key ] = {};
      items[ key ].birth = Date.now();
      this._saveItems( items );
    },

    _kill: function(key) {
      var items = this._loadItems();
      delete items[ key ];
      this._saveItems( items );
    },

    age: function(key) {
      var items = this._loadItems();
      if ( this.itemExists( key ) ) {
        var items = this._loadItems();
        if ( items[ key ] ) {
          var age = Date.now() - items[ key ].birth;
          return age;
        }
      }
    },

    _isTooOld: function(key) {
      return this.age( key ) > this.MAX_AGE;
    },

    _markAccess: function(key) {
      if ( this.itemExists( key ) ) {
        var items = this._loadItems();
        items[ key ].lastAccess = Date.now();
        this._saveItems( items );
      }
    },

    init: function() {
      localStorage.setItem('items', JSON.stringify({}));
    },

    localStorageSupport: function() {
      try {
        return 'localStorage' in window && window['localStorage'] !== null;
      } catch (e) {
        return false;
      }
    },

    get: function(key) {
      if ( this.localStorageSupport() && this.itemExists( key ) ) {
        if ( !this._isTooOld( key ) ) {
          this._markAccess( key );
          var tmp = localStorage.getItem( key );
          var items = this._loadItems();
          if ( items[ key ].isObject ) {
            tmp = JSON.parse( tmp );
          } else if ( items[ key ].isNumber ) {
            tmp = parseFloat( tmp );
          }
          return tmp;
        }
      }
    },

    save: function(key, data) {
      if ( this.localStorageSupport() ) {
        var markObject;
        var markNumber;
        if ( typeof data === 'object' ) {
          data = JSON.stringify( data );
          markObject = true;
        } else if ( typeof data === 'number' ) {
          markNumber = true;
        }
        localStorage.setItem(key, data);
        this._birth( key );
        if ( markObject ) {
          var items = this._loadItems();
          items[ key ].isObject = true;
          this._saveItems( items );
        } else if ( markNumber ) {
          var items = this._loadItems();
          items[ key ].isNumber = true;
          this._saveItems( items );
        }
        if ( !items ) { items = this._loadItems(); }
        return items[ key ].birth;
      }
    },

    remove: function(key) {
      if ( this.localStorageSupport() ) {
        var items = this._loadItems();
        localStorage.removeItem(key);
        delete items[ key ];
        this._saveItems( items );
      }
    },

    clear: function() {
      if ( this.localStorageSupport() ) {
        localStorage.clear();
        this.init();
      }
    }
  };

})(window.GoodLife = window.GoodLife || {});
