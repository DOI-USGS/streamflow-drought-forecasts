import { timeDay as d3TimeDay } from "d3-time";
const WIDTH_IN_DAYS = 4; /* Must equal pipeline p0_bar_width_days - 1*/

const drawDiamond = function (
  group,
  { segment, dataKind, xScale, yScale, transitionLength },
) {
  let rectElem;
  rectElem = group
    .selectAll("rect")
    .data(segment.points, d => d.id)
  rectElem
    .join(
      enter => enter.append("rect")
        .attr("id", d => "rect-" + d.id)
        .attr("class", d => d.class ? `ts-rect rect-${d.class}` : "ts-rect")
        .attr("x", d => xScale(d3TimeDay.offset(d.dateTime, - WIDTH_IN_DAYS/2)))
        .attr("y", d => yScale(d.value) - (xScale(d3TimeDay.offset(d.dateTime, WIDTH_IN_DAYS)) - xScale(d.dateTime)) / 2)
        .attr("width", d => xScale(d3TimeDay.offset(d.dateTime, WIDTH_IN_DAYS)) - xScale(d.dateTime))
        .attr("height", d => xScale(d3TimeDay.offset(d.dateTime, WIDTH_IN_DAYS)) - xScale(d.dateTime))
        .attr("transform", d => `rotate(45 
          ${xScale(d3TimeDay.offset(d.dateTime, - WIDTH_IN_DAYS/2)) + (xScale(d3TimeDay.offset(d.dateTime, WIDTH_IN_DAYS)) - xScale(d.dateTime))/2} 
          ${(yScale(d.value) - (xScale(d3TimeDay.offset(d.dateTime, WIDTH_IN_DAYS)) - xScale(d.dateTime)) / 2) + (xScale(d3TimeDay.offset(d.dateTime, WIDTH_IN_DAYS)) - xScale(d.dateTime))/2})`
        )
      ,
      update => update
        .transition().duration(transitionLength)
        .attr("x", d => xScale(d3TimeDay.offset(d.dateTime, - WIDTH_IN_DAYS/2)))
        .attr("y", d => yScale(d.value) - (xScale(d3TimeDay.offset(d.dateTime, WIDTH_IN_DAYS)) - xScale(d.dateTime)) / 2)
        .attr("transform", d => `rotate(45 
          ${xScale(d3TimeDay.offset(d.dateTime, - WIDTH_IN_DAYS/2)) + (xScale(d3TimeDay.offset(d.dateTime, WIDTH_IN_DAYS)) - xScale(d.dateTime))/2} 
          ${(yScale(d.value) - (xScale(d3TimeDay.offset(d.dateTime, WIDTH_IN_DAYS)) - xScale(d.dateTime)) / 2) + (xScale(d3TimeDay.offset(d.dateTime, WIDTH_IN_DAYS)) - xScale(d.dateTime))/2})`
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
