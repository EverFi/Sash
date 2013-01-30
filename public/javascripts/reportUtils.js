
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
    }


  },

  badges: {

    earned_: function(period, earnedTimes) {
      var dates = [];
      var func = 'is' + period;
      earnedTimes.forEach(function(time){
        if ( ReportUtils.time[ func ].apply(null, [ time ] ) ) {
          dates.push( time );
        }
      });
      return dates;
    },

    earnedThisMonth: function(earnedTimes) {
      var dates = [];
      earnedTimes.forEach(function(time){
        if ( ReportUtils.time.isThisMonth( time ) ) {
          dates.push( time );
        }
      });
      return dates;
    },

    earnedThisYear: function(earnedTimes) {
      var dates = [];
      earnedTimes.forEach(function(time){
        if ( ReportUtils.time.isThisYear( time ) ) {
          dates.push( time );
        }
      });
      return dates;
    },

    earnedThisWeek: function(earnedTimes) {
      var dates = [];
      earnedTimes.forEach(function(time){
        if ( ReportUtils.time.isThisWeek( time ) ) {
          dates.push( time );
        }
      });
      return dates;
    },

    earnedToday: function(earnedTimes) {
      var dates = [];
      earnedTimes.forEach(function(time){
        if ( ReportUtils.time.isToday( time ) ) {
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