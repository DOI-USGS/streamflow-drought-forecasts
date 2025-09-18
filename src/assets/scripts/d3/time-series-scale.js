import { scaleLinear, scaleTime, scaleSymlog } from "d3-scale";

const DATA_PADDING_RATIO = 0.2;

/*
 * Returns a D3 scale suitable for plotting a horizontal timescale
 * @param {Array of Number} domain - two element array representing Epoch time in milliseconds.
 *      If null the default domain of [0, 1] is used
 * @param {Number} rangeSize - The width of the xScale within the view box.
 * @returns {Object} - D3 linear scale
 */
export const timeScale = function (domain, rangeSize) {
  const scale = scaleTime().range([0, rangeSize]);
  if (domain) {
    scale.domain(domain.map(d => new Date(d)));
  }
  return scale;
};

/*
 * Returns a D3 scaled suitable for plotting the vertical value scale for a time series
 * @param {Array of Number or String that can be coerced to a number} domain - two element array representing the
 *      domain of the values to be drawn.
 * @param {Number} rangeSize -  height of the scale within the viewBox
 * @param {Boolean} useLogScale
 * @param {Boolean} reverseRange
 * @returns {Object} - D3 scale that can be used to plot the vertical value.
 */
export const waterDataScale = function (
  domain,
  rangeSize,
  useLogScale,
  reverseRange,
) {
  const scale = useLogScale ? scaleSymlog() : scaleLinear();
  if (reverseRange) {
    scale.range([0, rangeSize]);
  } else {
    scale.range([rangeSize, 0]);
  }

  if (domain.length) {
    let extendedDomain;
    const domainIsPositive = domain[0] >= 0 && domain[1] > 0;

    // If both the min and max domain are zero set the domain to a constant around zero.
    if (domain[0] === 0 && domain[1] === 0) {
      extendedDomain = [-0.5, 0.5];
    } else {
      // If the min and max are the same just divide the min by 2 for the padding
      const padding =
        domain[0] === domain[1]
          ? domain[0] / 2
          : DATA_PADDING_RATIO * (domain[1] - domain[0]);
      extendedDomain = [domain[0] - padding, domain[1] + padding];
    }

    if (useLogScale && domainIsPositive) {
      // Log scales lower-bounded based on the order of magnitude of the domain minimum
      const absLog10 = Math.abs(Math.log10(domain[0]));
      const logDomainLow = (domain[0] * absLog10) / (absLog10 + 1);
      //Use the lesser padding to prevent large padding if magnitude change is small
      if (!isNaN(logDomainLow) && extendedDomain[0] < logDomainLow) {
        extendedDomain[0] = logDomainLow;
      }
    }

    if (domainIsPositive) {
      // For positive domains, a zero-lower bound on the y-axis is enforced.
      extendedDomain[0] = Math.max(0, extendedDomain[0]);
    }
    scale.domain(extendedDomain);
  }
  return scale;
};
