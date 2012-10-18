define(['vendor/handlebars', 'vendor/massrel', './vendor/moment'], function(Handlebars, massrel, moment) {

  var BASIC = {
    future: "in %s",
    past: "%s ago",
    s: "%d sec",
    m: "1 min",
    mm: "%d mins",
    h: "1 hour",
    hh: "%d hours",
    d: "1 day",
    dd: "%d days",
    M: "1 month",
    MM: "%d months",
    y: "1 year",
    yy: "%d years"
  };

  var CONCISE = {
    future: "in %s",
    past: "%s ago",
    s: "%ds",
    m: "%dm",
    mm: "%dm",
    h: "%dh",
    hh: "%dh",
    d: "%dd",
    dd: "%dd",
    M: "%dmo",
    MM: "%dmo",
    y: "%dy",
    yy: "%dy"
  };

  var DEFAULT = moment.relativeTime;

  function prettyDate(date, fullDate) {
    date = new Date(massrel.helpers.fix_date(date));
    var m = moment(date);
    var hoursAgo = moment().diff(m, 'hours');
    var displayDate;
    if(!fullDate) {
      if(hoursAgo >= 24) { // display date
        displayDate = m.format('D MMM')
      }
      else { // relative date
        moment.relativeTime = CONCISE;
        displayDate = m.fromNow(true); // "true" removes "ago" fromt the date string
        moment.relativeTime = DEFAULT;
      }
    }
    else {
      displayDate = m.format('h:mm A - D MMM YY');
    }

    return displayDate;
  }

  return prettyDate;
});
