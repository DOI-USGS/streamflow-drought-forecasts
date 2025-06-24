import { ticks } from "d3-array";
import { format } from "d3-format";
// import { DateTime, Interval } from "luxon";

const WATER_DATA_DEFAULT_TICK_COUNT = 5;
const MAX_WATER_DEFAULT_TICK_COUNT = 12;

/*
 * Return ticks between startDateTime and endDateTime where the tick marks are interval apart and
 * start at startOffset
 * @param {DateTime} startDateTime
 * @param {DateTime} endDateTime
 * @param {Object} interval - a Luxon object that can be used in the .plus method to set the length between tick marks
 * @param {Object} startOffset - a Luxon object than can be used in the .plus method to set where the first tick mark begins
 * @return {Array of Number} - tick marks in milliseconds.
 */
// const getTimeTicks = function (
//   startDateTime,
//   endDateTime,
//   interval,
//   startOffset,
// ) {
//   let dateTime;
//   const startOffsetKind = Object.keys(startOffset)[0];
//   if (startOffsetKind === "years") {
//     dateTime = startDateTime.startOf("year");
//   } else if (startOffsetKind === "months") {
//     dateTime = startDateTime.startOf("month");
//   } else {
//     dateTime = startDateTime.startOf("day");
//   }
//   dateTime = dateTime.plus(startOffset);

//   let result = [];
//   while (dateTime < endDateTime) {
//     result.push(dateTime.toMillis());
//     dateTime = dateTime.plus(interval);
//   }
//   return result;
// };

/*
 * Returns an array of tickCount tick marks between startDate and endDate. The tick marks will
 * always start on unit where unit represents a string that can be used by the Luxon method .startOf.
 * @param {Number} startMillis in milliseconds
 * @param {Number} endMillis in milliseconds
 * @param {String} unit - string that can be used with the luxon method .startOf
 * @param {String} tickCount - the desired number of ticks
 * @param {String} ianaTimeZone - used when converting time in milliseconds to DateTime.
 * @return {Array of Number} - tick marks in milliseconds.
 */
// const getDefaultTimeTicks = function (
//   startMillis,
//   endMillis,
//   unit,
//   tickCount,
//   ianaTimeZone,
// ) {
//   const addToEnd = {};
//   addToEnd[unit] = 1;
//   //Ensure that we always increment the ticks by at least one millisecond
//   const tickInterval = Math.ceil((endMillis - startMillis) / (tickCount + 1));
//   const endDateTime = DateTime.fromMillis(endMillis, { zone: ianaTimeZone });
//   let result = [];

//   let dateTime = DateTime.fromMillis(startMillis + tickInterval / 2, {
//     zone: ianaTimeZone,
//   });
//   while (dateTime < endDateTime) {
//     let tickDateTime = dateTime.plus(addToEnd).startOf(unit);
//     result.push(tickDateTime.toMillis());
//     dateTime = dateTime.plus(tickInterval);
//   }

//   return result;
// };

/*
 * Generate the values for ticks to place on a time series graph along with an appropriate format function
 * that can be used to produce a string representing the tick value. This should be used for time series that have
 * minute accuracy.
 *
 * @param startMillis - start datetime in the form of milliseconds since 1970-01-01 UTC
 * @param endMillis - end datetime in the form of milliseconds since 1970-01-01 UTC
 * @param ianaTimeZone - Internet Assigned Numbers Authority designation for a time zone
 * @returns {Object} with two properties, dates {Array of Number timestamp in milliseconds} and
 *      format {String} the format that should be used  to display the dates.
 */
// export const generateTimeTicks = function (
//   startMillis,
//   endMillis,
//   ianaTimeZone,
// ) {
//   const startDateTime = DateTime.fromMillis(startMillis, {
//     zone: ianaTimeZone,
//   });
//   const endDateTime = DateTime.fromMillis(endMillis, { zone: ianaTimeZone });
//   const length = Interval.fromDateTimes(startDateTime, endDateTime);
//   const dayCount = length.count("days");
//   const weekCount = length.count("weeks");
//   const monthCount = length.count("months");
//   const yearCount = length.count("years");

//   /*
//    * Returns a function that takes timeInMillis parameters and returns a string that using format to generate the string.
//    */
//   const formatFnc = (format) => {
//     return function (timeInMillis) {
//       return DateTime.fromMillis(timeInMillis, { zone: ianaTimeZone }).toFormat(
//         format,
//       );
//     };
//   };

//   let result = {
//     dates: [],
//     format: {},
//   };

//   if (dayCount <= 3) {
//     // Generates 4 tick marks that are on the start of a hour
//     result = {
//       dates: getDefaultTimeTicks(
//         startMillis,
//         endMillis,
//         "minute",
//         3,
//         ianaTimeZone,
//       ),
//       format: formatFnc("MMM dd hh:mm a"),
//     };
//   } else if (dayCount > 3 && dayCount <= 8) {
//     // Tick marks every day
//     result = {
//       dates: getTimeTicks(startDateTime, endDateTime, { days: 1 }, { days: 1 }),
//       format: formatFnc("MMM dd"),
//     };
//   } else if (dayCount > 8 && dayCount <= 15) {
//     // Tick marks every other day
//     result = {
//       dates: getTimeTicks(startDateTime, endDateTime, { days: 2 }, { days: 1 }),
//       format: formatFnc("MMM dd"),
//     };
//   } else if (dayCount > 15 && dayCount <= 29) {
//     //Tick marks every fourth day
//     result = {
//       dates: getTimeTicks(startDateTime, endDateTime, { days: 4 }, { days: 1 }),
//       format: formatFnc("MMM dd"),
//     };
//   } else if (weekCount > 4 && weekCount <= 8) {
//     //Tick marks every week
//     result = {
//       dates: getTimeTicks(
//         startDateTime,
//         endDateTime,
//         { weeks: 1 },
//         { days: 3 },
//       ),
//       format: formatFnc("MMM dd"),
//     };
//   } else if (weekCount > 8 && weekCount <= 15) {
//     // Tick marks every other week
//     result = {
//       dates: getTimeTicks(
//         startDateTime,
//         endDateTime,
//         { weeks: 2 },
//         { days: 7 },
//       ),
//       format: formatFnc("MMM dd"),
//     };
//   } else if (weekCount > 15 && monthCount <= 8) {
//     //Tick marks every month
//     result = {
//       dates: getTimeTicks(
//         startDateTime,
//         endDateTime,
//         { months: 1 },
//         { months: 1 },
//       ),
//       format: formatFnc("MMM yyyy"),
//     };
//   } else if (monthCount > 8 && monthCount <= 15) {
//     //Tick marks every other month
//     result = {
//       dates: getTimeTicks(
//         startDateTime,
//         endDateTime,
//         { months: 2 },
//         { months: 1 },
//       ),
//       format: formatFnc("MMM yyyy"),
//     };
//   } else if (monthCount > 15 && monthCount <= 29) {
//     // Tick marks every 4 months
//     result = {
//       dates: getTimeTicks(
//         startDateTime,
//         endDateTime,
//         { months: 4 },
//         { months: 2 },
//       ),
//       format: formatFnc("MMM yyyy"),
//     };
//   } else if (monthCount > 29 && monthCount <= 43) {
//     // Tick marks every 6 months
//     result = {
//       dates: getTimeTicks(
//         startDateTime,
//         endDateTime,
//         { months: 6 },
//         { months: 3 },
//       ),
//       format: formatFnc("MMM yyyy"),
//     };
//   } else if (monthCount > 43 && yearCount <= 8) {
//     // Tick marks every year
//     result = {
//       dates: getTimeTicks(
//         startDateTime,
//         endDateTime,
//         { years: 1 },
//         { years: 1 },
//       ),
//       format: formatFnc("MMM yyyy"),
//     };
//   } else {
//     // Generate 6 tick marks and put them at the beginning of the year of that date.
//     result = {
//       dates: getDefaultTimeTicks(
//         startMillis,
//         endMillis,
//         "month",
//         6,
//         ianaTimeZone,
//       ),
//       format: formatFnc("MMM yyyy"),
//     };
//   }

//   return result;
// };

/*
 * This function will generate an array of tick values between nearestToZero and yDomainStart.
 * It is designed to add additional tick marks between the last tick mark generated by the standard
 * D3 tick function and the start of the yDomain. If using this on ranges that include zero, use the
 * function twice, once for the negative numbers and once for the positive tick numbers and set yDomainStart
 * to zero.
 * @param {Number} nearestToZero
 * @param {Number} yDomainStart
 * @return {Array of Number}
 */
const generateAdditionalLogTickValues = function (nearestToZero, yDomainStart) {
  let result = [];
  let nextTick = nearestToZero;
  while (nextTick > 2 && nextTick > yDomainStart) {
    nextTick = Math.ceil(nextTick / 2);
    result.push(nextTick);
  }
  return result;
};

/*
 * This function is used to round a tickValue to the nearest power of 10 if tick is above 100,
 * if the tick is between 100 and 20, round to the nearest multiple of 10, and if between 2 and 20
 * to the nearest multiple of 2. This is used to round tick marks calculated by the generatedAdditionalLogTickValues
 * for display that is suitable for log scales.
 * @param {Number} tickValue
 * @return Number
 */
const getRoundedLogTickValue = function (tickValue) {
  let roundingFactor = 1;
  const absTickValue = Math.abs(tickValue);
  if (absTickValue > 100) {
    roundingFactor = Math.pow(10, Math.floor(Math.log10(absTickValue)));
  } else if (absTickValue > 20) {
    roundingFactor = 10;
  } else if (absTickValue > 2) {
    roundingFactor = 2;
  }
  return Math.ceil(tickValue / roundingFactor) * roundingFactor;
};

/*
 * Returns an Object which contains three properties, one for an array of tick marks for the domain, one for a format function
 * suitable for displaying the tick marks, and maxTickLabelLength which contains the maximum number of characters needed
 * to display the tick marks. If useSymlog is true, tick marks suitable for
 * a symlog scale will be generated. If reverseRange is true, the tick marks are returned in reverse order
 * @param {Array of Number} domain - should be a two element array
 * @param {Boolean} useSymlog
 * @param {Boolean} reverseRange
 */
export const getWaterDataTicks = function (domain, useSymlog, reverseRange) {
  let tickValues = ticks(domain[0], domain[1], WATER_DATA_DEFAULT_TICK_COUNT);
  let tickFormat;
  if (useSymlog) {
    // For large magnitudes on log scales, the ticks can end up too close together to be
    // legible on the graph. This code generates additional tick marks by dividing up the range
    // between the tick mark closest to zero. If the domain is from negative to positive, the ticks
    // should be generated for the positive and negative domains separately.
    if (domain[0] > 0) {
      tickValues = [
        ...tickValues,
        ...generateAdditionalLogTickValues(tickValues[0], domain[0]),
      ];
    } else if (domain[1] < 0) {
      const additionalTicks = generateAdditionalLogTickValues(
        Math.abs(tickValues[0]),
        Math.abs(domain[1]),
      ).map((value) => -value);
      tickValues = [...tickValues, ...additionalTicks];
    } else {
      const positiveTickClosestToZero = tickValues.filter(
        (value) => value > 0,
      )[0];
      const negativeTickClosestToZero = tickValues
        .filter((value) => value < 0)
        .slice(-1);
      tickValues = [
        ...tickValues,
        ...generateAdditionalLogTickValues(positiveTickClosestToZero, 0),
        ...generateAdditionalLogTickValues(-negativeTickClosestToZero, 0).map(
          (value) => -value,
        ),
      ];
    }
    tickValues = tickValues.sort((a, b) => a - b);
    // Remove ticks if there are too many
    while (tickValues.length > MAX_WATER_DEFAULT_TICK_COUNT) {
      tickValues = tickValues.filter((_, index) => index % 2);
    }
    let roundedTickValues = tickValues.map(getRoundedLogTickValue);
    roundedTickValues = [...new Set(roundedTickValues)].filter(
      (value) => value > domain[0] && value < domain[1],
    );
    if (roundedTickValues.length > 1) {
      tickValues = roundedTickValues;
    } else {
      tickValues.filter((value) => value > domain[0] && value < domain[1]);
    }
  }

  // Determine the best format to use based on the tickValues generated.
  if (tickValues.find((value) => !Number.isInteger(value))) {
    let digits = 2;
    if (tickValues.length > 1) {
      digits = Math.ceil(
        Math.abs(
          Math.log10(
            (tickValues[tickValues.length - 1] - tickValues[0]) /
              tickValues.length,
          ),
        ),
      );
      tickFormat = format(`,.${digits}f`);
    } else {
      tickFormat = format(",.2f");
    }
  } else {
    tickFormat = format(",d");
  }
  const tickLengths = tickValues.map((value) => tickFormat(value).length);
  return {
    tickValues: reverseRange ? tickValues.reverse() : tickValues,
    tickFormat: tickFormat,
    maxTickLabelLength: Math.max(...tickLengths),
  };
};
