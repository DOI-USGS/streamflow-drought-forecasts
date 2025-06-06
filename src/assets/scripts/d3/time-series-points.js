const CIRCLE_RADIUS_SINGLE_PT = 5;

const drawPoint = function (
  group,
  { segment, dataKind, xScale, yScale, transitionLength },
) {
  let pointElems;
  pointElems = group
    .selectAll("circle")      
    .data(segment.points, d => d.id)
  pointElems
    .join(
      enter => enter.append("circle")
        .attr("id", d => "circle-" + d.id)
        .attr("class", "ts-point")
        .attr("r", CIRCLE_RADIUS_SINGLE_PT)
        .attr("cx", (d) => xScale(d.dateTime))
        .attr("cy", 0)
        .attr("cy", (d) => yScale(d.value))
        .call(enter => enter.transition().duration(transitionLength)
          .attr("cy", (d) => yScale(d.value))
        ),
      update => update.transition().duration(transitionLength)
        .attr("cy", (d) => yScale(d.value))
    )
  pointElems.classed(segment.class, true).classed(`ts-${dataKind}`, true);
}

export const drawDataPoints = function (
  elem,
  { visible, segments, dataKind, xScale, yScale, transitionLength, enableClip },
) {
  const elemClass = `ts-${dataKind}-group`;

  // have to turn this off for transition
//   elem.selectAll(`.${elemClass}`).remove();
  let pointGroup = elem.selectAll(`.${elemClass}`)
  if (pointGroup.nodes().length === 0) {
    pointGroup = elem.append("g").attr("class", elemClass);
  }

  if (!visible || !segments || !segments.length) {
    return;
  }

  if (enableClip) {
    pointGroup.attr("clip-path", "url(#iv-graph-clip)");
  }

  segments.forEach((segment) => {
    drawPoint(pointGroup, { segment, dataKind, xScale, yScale, transitionLength });
  });
};
