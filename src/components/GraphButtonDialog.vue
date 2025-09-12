<template>
  <div>
    <div
      id="graph-button-container"
    >
      <button
        class="graph-button info-button"
        @click="showGraphDialog"
      >
        <span
          class="button-icon"
          aria-hidden="true"
          title="How do I read this graph?" 
        />
      </button>
    </div>
    <DialogBox
      v-model="graphDialogShown"
    >
      <template #dialogTitle>
        <div
          id="graph-title-container"
        >
          <div
            class="graph-button info-button static"
          >
            <span
              class="button-icon"
              aria-hidden="true"
            />
          </div>
          <p>{{ text.title }}</p>
        </div>
      </template>
      <template #dialogContent>
        <div
          id="graph-content-container"
        >
          <div
            id="timeseries-legend-container"
          >
            <TimeseriesLegend 
              id="timeseries-legend"
            />
          </div>
          <div>
            <p v-html="text.intro" />
            <h2 v-html="text.heading1" />
            <p v-html="text.paragraph2" />
            <h2 v-html="text.heading2" />
            <p v-html="text.paragraph2" />
            <h2 v-html="text.heading3" />
            <p v-html="text.paragraph3a" />
            <p v-html="text.paragraph3b" />
            <p v-html="text.paragraph3c" />
            <p v-html="text.paragraph3d" />
            <p v-html="text.paragraph3e" />
            <h2 v-html="text.heading4" />
            <p v-html="text.paragraph4" />
            <h2 v-html="text.heading5" />
            <p v-html="text.paragraph5" />
            <h2 v-html="text.heading6" />
            <p v-html="text.paragraph6" />
          </div>
        </div>
      </template>
    </DialogBox>
  </div>
</template>

<script setup>
  import { ref } from 'vue';
  import DialogBox from './DialogBox.vue';
  import TimeseriesLegend  from "@/assets/svgs/timeseries_legend_v2.svg";

  const props = defineProps({
    text: {
      type: Object,
      default: () => ({}),
      required: true,
    },
  })

  // global variables
  const graphDialogShown = ref(false);

  function showGraphDialog() {
    graphDialogShown.value = true;
  }
</script>

<style>
.graph-button {
   background-image: url("data:image/svg+xml;charset=utf-8,%3Csvg viewBox='0 0 110 110' xmlns='http://www.w3.org/2000/svg'  %3E%3Cpath d='M55,22.5c-17.94928,0-32.5,14.55072-32.5,32.5s14.55072,32.5,32.5,32.5,32.5-14.55078,32.5-32.5-14.55072-32.5-32.5-32.5ZM54.91113,78.64062c-3.35205.15039-6.15283-2.41211-6.30273-5.76367-.1499-3.35254,2.40869-6.21387,5.76074-6.36426,3.35156-.14941,6.2168,2.46973,6.36719,5.82227.14941,3.35156-2.47363,6.15625-5.8252,6.30566ZM62.41699,53.94092c-3.65039,3.03271-4.04199,3.84326-3.95703,5.73291.10059,2.25488-1.52637,4.09863-4.20801,4.21875-2.68115.12012-4.52539-1.50684-4.65088-4.31152-.16602-3.71631.61133-5.46143,3.96484-8.29736,2.41113-2.0625,4.60596-3.50488,4.4917-6.06348-.13574-3.04785-2.12109-3.75244-4.49756-3.646-1.9502.08691-2.89014.92236-3.95996,1.58105-.65723.33447-1.25586.60596-2.16992.64697-2.98633.1333-4.54395-1.93408-4.62842-3.82373-.08447-1.88867,1.19092-3.41162,2.67383-4.39453,2.38037-1.38818,4.7832-2.28955,8.92676-2.47461,6.09473-.27246,13.12207,2.58838,13.47949,10.57178.21777,4.87598-2.75977,7.94043-5.46484,10.25977Z'/%3E%3C/svg%3E")
}
.graph-button .button-icon {
  background-position: 50%;
  background-repeat: no-repeat;
  display: block;
  height: 100%;
  width: 100%;
}
#graph-title-container {
  display: flex;
  gap: 1rem;
}
#graph-content-container {
  margin-top: 3rem;
  display: flex;
  flex-direction: column;
  gap: 1rem;
}
#timeseries-legend-container {
  width: 320px;
  margin: auto;
}
#timeseries-legend {
  width: 100%;
  height: 100%;
}
</style>