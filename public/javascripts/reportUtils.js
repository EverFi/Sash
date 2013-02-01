
var ReportUtils = {

  

  time: {

    isThisYear: function(date) {
      date = new XDate( date );
      var thisYear = new XDate( new Date() ).getYear();
      return ( date.getYear() === thisYear );
    },

    isThisWeek: function(date) {
      date = new XDate( date );
      var thisWeek = new XDate( new Date() ).getWeek();
      var thisYear = new XDate( new Date() ).getYear();
      return ( date.getWeek() === thisWeek ) && ( date.getYear() === thisYear );
    },

    isToday: function(date) {
      date = new Date(date);
      var now = new Date();
      return ( date.setHours(0,0,0,0) === now.setHours(0,0,0,0) );
    },

    isThisMonth: function(date) {
      date = new XDate( date );
      var thisMonth = new XDate( new Date() ).getMonth();
      var thisYear = new XDate( new Date() ).getYear();
      return ( date.getMonth() === thisMonth ) && ( date.getYear() === thisYear );
    },

    happened_: function(period, times) {
      var self = this;
      var dates = [];
      var func = 'is' + period;
      if ( typeof times === 'string') {
        var tmp = [];
        tmp.push(times);
        times = tmp;
      }

      times.forEach(function(time){
        if ( ReportUtils.time[ func ].apply(null, [ time ] ) ) {
          dates.push( time );
        }
      });
      return dates;
    }


  },

  chart: {

    baseDataObject: function(type) {
      return {
        type: type,
        xScale: "ordinal",
        yScale: "linear",
        type: "bar",
        main: [],
        comp: []
      };
    }

  }

};