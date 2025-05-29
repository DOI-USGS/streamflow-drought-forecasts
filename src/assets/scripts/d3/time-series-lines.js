import { line as d3Line, line } from "d3-shape";

const CIRCLE_RADIUS_SINGLE_PT = 5;

const drawLineSegment = function (
  group,
  { segment, dataKind, xScale, yScale },
) {
  let lineElem;
  if (segment.points.length === 1) {
    lineElem = group
      .selectAll("circle")      
      .data(segment.points, d => d.id)
    console.log('POINT LINE ELEM')
    console.log(lineElem)
    lineElem
      .join(
        enter => enter.append("circle")
          .attr("id", d => "circle-" + d.id)
          .attr("class", "ts-point")
          .attr("r", CIRCLE_RADIUS_SINGLE_PT)
          .attr("cx", (d) => xScale(d.dateTime))
          .attr("cy", 0)
          .call(enter => enter.transition().duration(2000)
            .attr("cy", (d) => yScale(d.value))
          ),
        update => update.transition().duration(2000)
          .attr("cy", (d) => yScale(d.value))
      )
    //   .enter()
    // //   .data(segment.points)
    // //   .enter()
    //   .append("circle")
    // //   .data(segment.points)
    //   .attr("r", CIRCLE_RADIUS_SINGLE_PT)
    //   .attr("cx", (d) => xScale(d.dateTime))
    //   .attr("cy", (d) => yScale(d.value));
  } else {
    const dvLine = d3Line()
      .x((d) => xScale(d.dateTime))
      .y((d) => yScale(d.value));
    lineElem = group
      .selectAll("path")
      .data([segment.points])
    console.log('LINE ELEM')
    console.log(lineElem)
    lineElem
      .join(
        enter => enter.append("path")
          .attr("id", d => "path-" + d.id)
          .attr("class", "ts-line")
          .attr('d', d3Line()
            .x((d) => xScale(d.dateTime))
            .y(0)
          )
          .call(enter => enter.transition().duration(2000)
            .attr("d", dvLine)
          ),
        update => update
          .transition().duration(2000)
          .attr("d", dvLine)
      )
    //   .enter()
    //   .append("path")
    //   .attr("d", dvLine);
    // lineElem = group.append("path").datum(segment.points)
    //   .attr("d", dvLine);
  }
  lineElem.classed(segment.class, true).classed(`ts-${dataKind}`, true);
};

const drawMaskSegment = function (
  group,
  { segment, dataKind, xScale, yScale },
) {
  const [yRangeStart, yRangeEnd] = yScale.range();
  const xRangeStart = xScale(segment.points[0].dateTime);
  const xRangeEnd = xScale(segment.points[segment.points.length - 1].dateTime);

  // Some data is shown with the yAxis decreasing from top to bottom
  const yTop = yRangeEnd > yRangeStart ? yRangeStart : yRangeEnd;

  const xSpan = xRangeEnd - xRangeStart;
  const rectWidth = xSpan > 1 ? xSpan : 1;
  const rectHeight = Math.abs(yRangeEnd - yRangeStart);

  const maskGroup = group.append("g").attr("class", "iv-mask-group");

  maskGroup
    .append("rect")
    .attr("x", xRangeStart)
    .attr("y", yTop)
    .attr("width", rectWidth)
    .attr("height", rectHeight)
    .classed("mask", true)
    .classed(segment.class, true);
  maskGroup
    .append("rect")
    .attr("x", xRangeStart)
    .attr("y", yRangeEnd)
    .attr("width", rectWidth)
    .attr("height", rectHeight)
    .attr("fill", `url(#hash-${dataKind}`);
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
  { segment, dataKind, xScale, yScale },
) {
  if (segment.isMasked) {
    drawMaskSegment(group, { segment, dataKind, xScale, yScale });
  } else {
    drawLineSegment(group, { segment, dataKind, xScale, yScale });
  }
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
  { visible, segments, dataKind, xScale, yScale, enableClip },
) {
  const elemClass = `ts-${dataKind}-group`;

  // have to turn this off for transition
//   elem.selectAll(`.${elemClass}`).remove();
  let lineGroup = elem.selectAll(`.${elemClass}`)
  if (lineGroup.nodes().length === 0) {
    lineGroup = elem.append("g").attr("class", elemClass);
  }
//   console.log('line class')
//   console.log(lineClass)
//   console.log(lineClass.nodes())
//   const lineGroup = elem.append("g").attr("class", elemClass);
  if (!visible || !segments || !segments.length) {
    return;
  }

  if (enableClip) {
    lineGroup.attr("clip-path", "url(#iv-graph-clip)");
  }

  segments.forEach((segment) => {
    drawDataSegment(lineGroup, { segment, dataKind, xScale, yScale });
  });
};
