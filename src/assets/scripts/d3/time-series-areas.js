import { area as d3Area } from "d3-shape";

const drawArea = function (
  group,
  { segment, dataKind, xScale, yScale, transitionLength },
) {
  let areaElem;
  const areaGenerator = d3Area()
    .x((d) => xScale(d.dateTime))
    .y0((d) => yScale(d.value_max))
    .y1((d) => yScale(d.value_min));

  areaElem = group
    .selectAll("path")
    .data([segment.points], d => d[0].id)
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
      ,
      exit => exit
        .remove()
    )
  areaElem.classed(segment.class, true).classed(`ts-${dataKind}`, true);
}

export const drawDataAreas = function (
  elem,
  { visible, segments, groupedAreas = false, allGroupsRepresented = true, allGroups = undefined, dataKind, xScale, yScale, transitionLength, enableClip, clipIdKey },
) {
  if (groupedAreas && allGroupsRepresented) {
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
        areaGroup.attr("clip-path", `url(#${clipIdKey}-chart-clip)`);
      }
      drawArea(areaGroup, { segment, dataKind, xScale, yScale, transitionLength });
    });
  } else if (groupedAreas && !allGroupsRepresented) {
    const representedGroups = [...new Set(segments.map(segment => segment.id))];
    const notRepresentedGroups = allGroups.filter(item => !representedGroups.includes(item))
    notRepresentedGroups.forEach((notRepresentedGroup) => {
      const elemClass = `ts-${dataKind}-${notRepresentedGroup}-group`;
      elem.selectAll(`.${elemClass}`).remove();
    })
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
        areaGroup.attr("clip-path", `url(#${clipIdKey}-chart-clip)`);
      }
      drawArea(areaGroup, { segment, dataKind, xScale, yScale, transitionLength });
    });
  } else {
    segments.forEach((segment) => {
      const elemClass = `ts-${dataKind}-group`;
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
      drawArea(areaGroup, { segment, dataKind, xScale, yScale, transitionLength });
    });
  }
};
