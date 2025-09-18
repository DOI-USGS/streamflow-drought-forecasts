<template>
  <section>
    <div
      id="icon-container"
    >
      <button
        v-if="!siteIntermittent"
        class="icon-button"
        :title="text.icons.normal.promptTrue"
        data-open-modal
        aria-controls="normal-dialog”"
        @click="showNormalDialog"
      >
        <NormalIcon
          class="hydrology-icon"
          aria-hidden="true"
        />
      </button>
      <button
        v-if="siteIntermittent"
        class="icon-button"
        :title="text.icons.intermittent.promptTrue"
        data-open-modal
        aria-controls="intermittent-dialog”"
        @click="showIntermittentDialog"
      >
        <IntermittentIcon
          class="hydrology-icon"
          aria-hidden="true"
        />
      </button>
      <button
        class="icon-button"
        :disabled="!siteRegulated"
        :title="siteRegulated ? text.icons.regulated.promptTrue : text.icons.regulated.promptFalse"
        data-open-modal
        aria-controls="regulated-dialog"
        @click="showRegulatedDialog"
      >
        <DamIcon
          class="hydrology-icon"
          aria-hidden="true"
        />
      </button>
      <button
        class="icon-button"
        :disabled="!siteSnowDominated"
        :title="siteSnowDominated ? text.icons.snow.promptTrue : text.icons.snow.promptFalse"
        data-open-modal
        aria-controls="snow-dialog"
        @click="showSnowDialog"
      >
        <SnowIcon
          class="hydrology-icon"
          aria-hidden="true"
        />
      </button>
      <button
        class="icon-button"
        :disabled="!siteIceImpacted"
        :title="siteIceImpacted ? text.icons.ice.promptTrue : text.icons.ice.promptFalse"
        data-open-modal
        aria-controls="ice-dialog"
        @click="showIceDialog"
      >
        <FrozenIcon
          class="hydrology-icon"
          aria-hidden="true"
        />
      </button>
    </div>
  </section>
</template>

<script setup>
  import { storeToRefs } from "pinia";
  import { useGlobalDataStore } from "@/stores/global-data-store";
  import DamIcon from "@/assets/svgs/dam.svg";
  import IntermittentIcon from "@/assets/svgs/intermittent.svg";
  import SnowIcon from "@/assets/svgs/snow.svg";
  import FrozenIcon  from "@/assets/svgs/frozen.svg";
  import NormalIcon  from "@/assets/svgs/normal.svg";
  import text from "@/assets/text/text.js";

  const props = defineProps({
    siteRegulated: {
        type: Boolean,
        required: true,
        default: false
    },
    siteIntermittent: {
        type: Boolean,
        required: true,
        default: false
    },
    siteSnowDominated: {
        type: Boolean,
        required: true,
        default: false
    },
    siteIceImpacted: {
        type: Boolean,
        required: true,
        default: false
    },
  })

  // global variables
  const globalDataStore = useGlobalDataStore();
  const { normalDialogShown } = storeToRefs(globalDataStore);
  const { intermittentDialogShown } = storeToRefs(globalDataStore);
  const { regulatedDialogShown } = storeToRefs(globalDataStore); 
  const { snowDialogShown } = storeToRefs(globalDataStore);
  const { iceDialogShown } = storeToRefs(globalDataStore);
  
  function showNormalDialog() {
    normalDialogShown.value = true;
  }
  function showIntermittentDialog() {
    intermittentDialogShown.value = true;
  }
  function showRegulatedDialog() {
    regulatedDialogShown.value = true;
  }
  function showSnowDialog() {
    snowDialogShown.value = true;
  }
  function showIceDialog() {
    iceDialogShown.value = true;
  }
</script>

<style scoped lang="scss">
$icon-height: 35px;
#icon-container {
  display: flex;
  flex-direction: row;
  gap: 6px;
  margin: 0 0 3px 3px;
  height: $icon-height;
  @media only screen and (min-width: 641px) {
    margin: 0 0 3px 3px;
  }
}
.icon-button {
  cursor: pointer;
  display: flex;
  align-items: center;
  background-color: transparent;
  border: none;
  width: $icon-height;
  height: $icon-height;
  padding: 0;
  border-radius: 4px;
}
.icon-button:hover {
  transform: scale(1.2);
}
.icon-button:disabled {
  opacity: 0.25;
  cursor: not-allowed;
}
.icon-button:disabled:hover {
  box-shadow: none;
  transform: scale(1);
}
.hydrology-icon {
  width: $icon-height;
  height: $icon-height;
}
</style>