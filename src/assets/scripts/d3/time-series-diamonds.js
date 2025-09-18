import { timeDay as d3TimeDay } from "d3-time";
const WIDTH_IN_DAYS = 4; /* Must equal pipeline p0_bar_width_days - 1*/

const drawDiamond = function (
  group,
  { segment, dataKind, xScale, yScale, transitionLength },
) {
  let rectElem;
  // precompute key positioning parameters for each data point
  const xStarts = segment.points.map(d => xScale(d3TimeDay.offset(d.dateTime, - WIDTH_IN_DAYS/2)));
  const rectWidthsHeights = segment.points.map(d => xScale(d3TimeDay.offset(d.dateTime, WIDTH_IN_DAYS)) - xScale(d.dateTime));
  const yStarts = segment.points.map((d, index) => yScale(d.value) - rectWidthsHeights[index]/2);
  rectElem = group
    .selectAll("rect")
    .data(segment.points, d => d.id)
  rectElem
    .join(
      enter => enter.append("rect")
        .attr("id", d => "rect-" + d.id)
        .attr("class", d => d.class ? `ts-rect rect-${d.class}` : "ts-rect")
        .attr("x", (d,i) => xStarts[i])
        .attr("y", (d,i) => yStarts[i])
        .attr("width", (d, i) => rectWidthsHeights[i])
        .attr("height", (d, i) => rectWidthsHeights[i])
        .attr("transform", (d,i) => `rotate(45 
          ${xStarts[i] + rectWidthsHeights[i]/2} 
          ${yStarts[i] + rectWidthsHeights[i]/2})`
        )
      ,
      update => update
        .transition().duration(transitionLength)
        .attr("x", (d,i) => xStarts[i])
        .attr("y", (d,i) => yStarts[i])
        .attr("transform", (d,i) => `rotate(45 
          ${xStarts[i] + rectWidthsHeights[i]/2} 
          ${yStarts[i] + rectWidthsHeights[i]/2})`
        )
    )
  rectElem.classed(segment.class, true).classed(`ts-${dataKind}`, true);
}

export const drawDataDiamonds = function (
  elem,
  { visible, segments, dataKind, xScale, yScale, transitionLength, enableClip, clipIdKey },
) {
  const elemClass = `ts-${dataKind}-group`;

  // have to turn this off for transition
//   elem.selectAll(`.${elemClass}`).remove();
  let areaGroup = elem.selectAll(`.${elemClass}`)
  if (areaGroup.nodes().length === 0) {
    areaGroup = elem.append("g").attr("class", elemClass);
  }

  if (!visible || !segments || !segments.length) {
    return;
  }

  if (enableClip) {
    areaGroup.attr("clip-path", `url(#${clipIdKey}-chart-clip)`);
  }

  segments.forEach((segment) => {
    drawDiamond(areaGroup, { segment, dataKind, xScale, yScale, transitionLength });
  });
};
