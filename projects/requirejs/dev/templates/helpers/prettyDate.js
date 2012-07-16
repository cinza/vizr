define(['vendor/handlebars', 'vendor/massrel'], function(Handlebars, massrel) {
  /*
   * JavaScript Pretty Date
   * Copyright (c) 2008 John Resig (jquery.com)
   * Licensed under the MIT license.
   * Modified by Troy Warr.
   */

  // takes an ISO time and returns a string representing how long ago the date represents
  function prettyDate(time, format) {
    var date = new Date((time || '').replace(/-/g, '/').replace(/[TZ][^hu]/g, ' ')),
        diff = (((new Date()).getTime() - date.getTime()) / 1000),
        dayDiff = Math.floor(diff / 86400),
        mthDiff = (((new Date()).getFullYear() - date.getFullYear()) * 12) + ((new Date()).getMonth() + 1) - (date.getMonth() + 1),
        // time format options
        timeFormat = {
          basic: {
            justNow: 'a moment ago',
            oneMinuteAgo: '1 min ago',
            minutesAgo: ' mins ago',
            oneHourAgo: '1 hour ago',
            hoursAgo: ' hours ago',
            yesterday: 'yesterday',
            daysAgo: ' days ago',
            oneWeekAgo: '1 week ago',
            weeksAgo: ' weeks ago',
            oneMonthAgo: 'last month',
            monthsAgo: 'months ago',
            oneYearAgo: 'last year',
            yearsAgo: 'years ago'
          },
          concise: {
            justNow: 'now',
            oneMinuteAgo: '1m',
            minutesAgo: 'm',
            oneHourAgo: '1h',
            hoursAgo: 'h',
            yesterday: '1d',
            daysAgo: 'd',
            oneWeekAgo: '1w',
            weeksAgo: 'w',
            oneMonthAgo: '1m',
            monthsAgo: 'm',
            oneYearAgo: '1y',
            yearsAgo: 'y'
          }
        },
        timeStr;
    
    format  = format && typeof format === 'string' ? format : 'basic';
    timeStr = timeFormat[format];
  
    if (isNaN(dayDiff) || dayDiff < 0) {
      return timeStr.justNow;
    } else if (dayDiff >= 31) {
      return;
    }
  
    return (dayDiff === 0) && (
      (diff < 60 && timeStr.justNow) ||
      (diff < 120 && timeStr.oneMinuteAgo) ||
      (diff < 3600 && Math.floor( diff / 60 ) + timeStr.minutesAgo) ||
      (diff < 7200 && timeStr.oneHourAgo) ||
      (diff < 86400 && Math.floor( diff / 3600 ) + timeStr.hoursAgo)
    ) || (mthDiff === 0) && (
      (dayDiff === 1 && timeStr.yesterday) ||
      (dayDiff < 7 && dayDiff + timeStr.daysAgo) ||
      (dayDiff < 14 && timeStr.oneWeekAgo) ||
      (dayDiff < 31 && Math.ceil( dayDiff / 7 ) + timeStr.weeksAgo)
    ) ||
    (mthDiff === 1 && timeStr.oneMonthAgo) ||
    (mthDiff < 12 && mthDiff + timeStr.monthsAgo) ||
    (mthDiff === 12 && timeStr.oneYearAgo) ||
    (Math.floor(mthDiff / 12) + timeStr.yearsAgo);
  
  }

  function prettyTwitterDate(date, format) {
    date = massrel.helpers.fix_twitter_date(date);
    return prettyDate(date, format);
  }

  Handlebars.registerHelper('prettyDate', prettyTwitterDate);

  return prettyTwitterDate;
});