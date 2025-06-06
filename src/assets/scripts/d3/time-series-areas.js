import { area as d3Area } from "d3-shape";

const drawArea = function (
  group,
  { segment, dataKind, xScale, yScale, transitionLength },
) {
  let areaElem;
  const areaGenerator = d3Area()
    .x((d) => xScale(d.dateTime))
    .y0((d) => yScale(d.value))
    .y1((d) => yScale(d.value_min));

  areaElem = group
    .selectAll("area")
    .data([segment.points], d => d[0].id)
  console.log(areaElem)
  console.log(areaElem.data())
  areaElem
    .join(
      enter => enter.append("path")
        .attr("id", d => "area-" + d[0].id)
        .attr("class", "ts-area")
        .attr("d", d => areaGenerator(d))
      ,
      update => update
        .transition().duration(transitionLength)
        .attr("d", d => areaGenerator(d))
    )
  areaElem.classed(segment.class, true).classed(`ts-${dataKind}`, true);
}

export const drawDataAreas = function (
  elem,
  { visible, segments, dataKind, xScale, yScale, transitionLength, enableClip },
) {
  // const elemClass = `ts-${dataKind}-group`;

  // have to turn this off for transition
//   elem.selectAll(`.${elemClass}`).remove();
  // let areaGroup = elem.selectAll(`.${elemClass}`)
  // if (areaGroup.nodes().length === 0) {
  //   areaGroup = elem.append("g").attr("class", elemClass);
  // }

  // if (!visible || !segments || !segments.length) {
  //   return;
  // }

  // if (enableClip) {
  //   areaGroup.attr("clip-path", "url(#iv-graph-clip)");
  // }

  segments.forEach((segment) => {
    const elemClass = `ts-${dataKind}-${segment.id}-group`;
    let areaGroup = elem.selectAll(`.${elemClass}`)
    if (areaGroup.nodes().length === 0) {
      areaGroup = elem.append("g").attr("class", elemClass);
    }

    if (!visible || !segments || !segments.length) {
      return;
    }

    if (enableClip) {
      areaGroup.attr("clip-path", "url(#iv-graph-clip)");
    }
    drawArea(areaGroup, { segment, dataKind, xScale, yScale, transitionLength });
  });
};
