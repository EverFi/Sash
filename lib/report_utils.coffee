ReportUtils =

  generateTimePeriodData: (theData) ->
    base = ReportUtils.chart.baseDataObject "bar"
    utils = ReportUtils

    # created today
    today = ReportUtils.time.getTimePeriodData "today", theData
    today.type = "bar"
    base.main.push today

    # this week
    thisWeek = utils.time.getTimePeriodData "This-Week", theData
    thisWeek.type = "bar"
    base.comp.push thisWeek

    # this month
    thisMonth = utils.time.getTimePeriodData "This-Month", theData
    thisMonth.type = "bar"
    base.comp.push thisMonth

    # created this year
    thisYear = utils.time.getTimePeriodData "This-Year", theData
    thisYear.type = "bar"
    base.comp.push thisYear

    return base

  time:

    getTimePeriodData: (period, theData) ->
      label;
      if period.indexOf '-'  > -1
        label = period.replace '-', ' '
        period = period.replace '-', ''
      else
        label = period.charAt(0).toUpperCase() + period.slice 1
      
      period = period.charAt(0).toUpperCase() + period.slice 1
      obj = {}
      obj.className = '.' + period.toLowerCase()
      obj.data = []
      x = label
      y = 0

      for k, timeArray of theData
        todayDates = ReportUtils.time.happened_.apply null, [ period, timeArray ]
        y += todayDates.length
  
      obj.data.push
        x:x
        y:y
      
      return obj

    isThisYear: (date) ->
      date = new XDate( date )
      thisYear = new XDate( new Date() ).getYear()
      return ( date.getYear() == thisYear )

    isThisWeek: (date) ->
      date = new XDate( date );
      thisWeek = new XDate( new Date() ).getWeek();
      thisYear = new XDate( new Date() ).getYear();
      return ( date.getWeek() == thisWeek ) && ( date.getYear() == thisYear );

    isToday: (date) ->
      date = new Date(date);
      now = new Date();
      return ( date.setHours(0,0,0,0) == now.setHours(0,0,0,0) );

    isThisMonth: (date) ->
      date = new XDate( date );
      thisMonth = new XDate( new Date() ).getMonth();
      thisYear = new XDate( new Date() ).getYear();
      return ( date.getMonth() == thisMonth ) && ( date.getYear() == thisYear )

    happened_: (period, times) ->
      self = this
      dates = []
      func = 'is' + period

      for time, i in times
        if ReportUtils.time[ func ].apply null, [ time ]
          dates.push time
      return dates   

  chart:
    baseDataObject: (type) ->
      base =
        type: type
        xScale: "ordinal"
        yScale: "linear"
        main: []
        comp: []

module.exports = ReportUtils