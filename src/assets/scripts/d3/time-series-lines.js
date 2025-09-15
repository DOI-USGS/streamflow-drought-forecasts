import { line as d3Line } from "d3-shape";

const CIRCLE_RADIUS_SINGLE_PT = 5;

const drawLineSegment = function (
  group,
  { segment, dataKind, xScale, yScale, transitionLength },
) {
  let lineElem;
    const dvLine = d3Line()
      .x((d) => xScale(d.dateTime))
      .y((d) => yScale(d.value));
    lineElem = group
      .selectAll("path")
      .data([segment.points], d => d[0].id)
    lineElem
      .join(
        enter => enter.append("path")
          .attr("id", d => "path-" + d[0].id)
          .attr("class", "ts-line")
          .attr("d", dvLine)
        ,
        update => update
          .transition().duration(transitionLength)
          .attr("d", dvLine)
      )
  lineElem.classed(segment.class, true).classed(`ts-${dataKind}`, true);
};

/*
 * Render the segment of dataKind using the scales.
 * @param {D3 selector} group
 * @param {Object} segment
 * @param {String} dataKind - can be 'primary' or 'compare'
 * @param {D3 scale} xScale
 * @param {D3 scale} yScale
 */
const drawDataSegment = function (
  group,
  { segment, dataKind, xScale, yScale, transitionLength },
) {
  drawLineSegment(group, { segment, dataKind, xScale, yScale, transitionLength });
};
/*
 * Render a set of lines if visible using the scales. The tsKey string is used for various class names so that this element
 * can be styled by using the class name.
 * @param {Boolean} visible
 * @param {String} currentMethodID
 * @param {Array of Object} - Each object is suitable for passing to drawDataLine
 * @param {String} timeRangeKind - 'current' or 'compare'
 * @param {Object} xScale - D3 scale for the x axis
 * @param {Object} yScale - D3 scale for the y axis
 * @param {Boolean} enableClip - Set if lines should be clipped to the width/height of the container.
 */
export const drawDataSegments = function (
  elem,
  { visible, segments, dataKind, xScale, yScale, transitionLength, enableClip, clipIdKey },
) {
  const elemClass = `ts-${dataKind}-group`;

  // have to turn this off for transition
//   elem.selectAll(`.${elemClass}`).remove();
  let lineGroup = elem.selectAll(`.${elemClass}`)
  if (lineGroup.nodes().length === 0) {
    lineGroup = elem.append("g").attr("class", elemClass);
  }

  if (!visible || !segments || !segments.length) {
    return;
  }

  if (enableClip) {
    lineGroup.attr("clip-path", `url(#${clipIdKey}-chart-clip)`);
  }

  segments.forEach((segment) => {
    drawDataSegment(lineGroup, { segment, dataKind, xScale, yScale, transitionLength });
  });
};
