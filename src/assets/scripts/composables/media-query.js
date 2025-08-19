import { useMediaQuery } from "@vueuse/core";
import { computed } from "vue";

import config from "@/assets/scripts/config.js";

/*
 * Returns a string representing the current screen size
 * @return {String} 'desktop', 'tablet', or 'phone'
 */
export function useScreenCategory() {
  const isLarge = useMediaQuery(
    `screen and (min-width: ${config.USWDS_LARGE_SCREEN}px)`,
  );
  const isMedium = useMediaQuery(
    `screen and (min-width: ${config.USWDS_MEDIUM_SCREEN}px)`,
  );
  return computed(() =>
    isLarge.value ? "desktop" : isMedium.value ? "tablet" : "phone",
  );
}
