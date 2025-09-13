import { ref, watchEffect } from "vue";

import config from "@/assets/scripts/config.js";

import { useScreenCategory } from "@/assets/scripts/composables/media-query";
import { getWaterDataTicks } from "@/assets/scripts/d3/time-series-tick-marks";

/*
 * Returns a ref representing the layout of the time series graph where width/height ore
 * the dimensions of the SVG. The margin properties define the area to the top, bottom, left, and right of the graph
 * itself and are used to provide space for axis labels, etc.
 * @param {Ref of Number} containerWidth
 * @param {Array} resultDomain
 * @param {String} scaleKind
 * @returns Ref object with the following properties
 *    @prop {Number} width
 *    @prop {Number} height
 *    @prop {Object} margin - has number properties top, bottom, left, and right.
 */
export function useTimeSeriesLayout(containerWidth, resultDomain, scaleKind) {
  const ASPECT_RATIO = 0.8 / 1;
  const MARGIN = {
    top: 15,
    right: 5,
    bottom: 25,
    left: 5,
  };

  const layout = ref({
    width: 100,
    height: 50,
    margin: {
      ...MARGIN,
    },
  });
  const screenCategory = useScreenCategory();

  watchEffect(() => {
    if (containerWidth.value) {
      layout.value.width = containerWidth.value;
      layout.value.height = layout.value.width * ASPECT_RATIO;
    }
  });

  watchEffect(() => {
    const maxYTickLabelLength = resultDomain
      ? getWaterDataTicks(
          resultDomain,
          scaleKind == "log",
          false,
        ).maxTickLabelLength
      : 0;
    layout.value.margin.left = Math.max(MARGIN.left + maxYTickLabelLength * 8, MARGIN.left + maxYTickLabelLength + 20); /* min value to make sure axis label not cut off */
    layout.value.margin.bottom =
      MARGIN.bottom + config.DATA_STATUS_BAR_HEIGHT[screenCategory.value];
  });

  return layout;
}
