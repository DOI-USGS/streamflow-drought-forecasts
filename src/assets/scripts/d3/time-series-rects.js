import { timeDay as d3TimeDay } from "d3-time";
const WIDTH_IN_DAYS = 5;

const drawRect = function (
  group,
  { segment, dataKind, xScale, yScale, transitionLength },
) {
  let rectElem;
  rectElem = group
    .selectAll("rect")
    .data(segment.points, d => d.id)
  // console.log(rectElem)
  // console.log(rectElem.data())
  rectElem
    .join(
      enter => enter.append("rect")
        .attr("id", d => "rect-" + d.id)
        .attr("class", "ts-area")
        .attr("x", d => xScale(d3TimeDay.offset(d.dateTime, - WIDTH_IN_DAYS/2)))
        .attr("y", d => yScale(d.value_max))
        .attr("width", d => xScale(d3TimeDay.offset(d.dateTime, WIDTH_IN_DAYS)) - xScale(d.dateTime))
        .attr("height", d => yScale(d.value_min) - yScale(d.value_max))
      ,
      update => update
        .transition().duration(transitionLength)
        .attr("x", d => xScale(d3TimeDay.offset(d.dateTime, - WIDTH_IN_DAYS/2)))
        .attr("y", d => yScale(d.value_max))
        .attr("height", d => yScale(d.value_min) - yScale(d.value_max))
    )
  rectElem.classed(segment.class, true).classed(`ts-${dataKind}`, true);
}

export const drawDataRects = function (
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
    drawRect(areaGroup, { segment, dataKind, xScale, yScale, transitionLength });
  });
};
