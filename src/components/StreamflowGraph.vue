<template>
  <g
    ref="streamflowGroup"
    class="streamflow-group"
    :transform="transform"
  >
    <path d="M 10,30 A 20,20 0,0,1 50,30" />
  </g>
</template>

<script setup>
  import { select } from "d3-selection";
  import { ref, watchEffect } from "vue";

  /*
 * A component that renders shaded regions and horizontal lines used to
 * represent flood levels on the graph.
 * @vue-prop {String} transform - transform to use on the group that renders the lines.
 *      Defaults to the empty string.
 * @vue-prop {Function} xScale - The D3 scale function used to translate the dateTime to a X coordinate.
 * @vue-prop {Function} yScale - The D3 scale function used to translate the statValue to a Y coordinate.
 */

const props = defineProps({
  transform: {
    type: String,
    default: "",
  },
  streamflowData: {
    type: Object,
    default: () => ({}),
    required: true,
  },  
  xDomain: {
    type: Object,
    default: () => ({}),
    required: true,
  },
  yDomain: {
    type: Array,
    required: true,
  },
});

const streamflowGroup = ref(null);

watchEffect(() => {
  // This removes any existing children (e.g., children associated w/ other sites)
//   if (streamflowGroup.value) {
//     select(streamflowGroup.value).selectChildren().remove();
//   }

  // https://code.usgs.gov/wma/iow/waterdataui/-/blob/main/assets/src/scripts/vue-components/time-series-graph/FloodLevelsGraph.vue
  if (props.streamflowData) {
    console.log('in streamflow graph')
    console.log(props.streamflowData)
  }

  if (props.yDomain) {
    console.log('streamflow graph y domain')
    console.log(props.yDomain)
  }

  if (props.xDomain) {
    console.log('streamflow graph x domain')
    console.log(props.xDomain)
  }
});

</script>