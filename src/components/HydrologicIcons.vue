<template>
  <section
    id="icon-container"
  >
    <button
      class="icon-button"
      :disabled="!siteRegulated"
      @click="showRegulatedDialog"
    >
      <DamIcon
        class="hydrology-icon"
      />
    </button>
    <button
      class="icon-button"
      :disabled="!siteIntermittent"
      @click="showIntermittentDialog"
    >
      <IntermittentIcon
        class="hydrology-icon"
      />
    </button>
    <button
      class="icon-button"
      :disabled="!siteSnowDominated"
      @click="showSnowDialog"
    >
      <SnowIcon
        class="hydrology-icon"
      />
    </button>
    <button
      class="icon-button"
      :disabled="!siteIceImpacted"
      @click="showIceDialog"
    >
      <FrozenIcon
        class="hydrology-icon"
      />
    </button>
    <DialogBox
      v-model="regulatedDialogShown"
    >
      <template #dialogContent>
        <h1>Site highly regulated</h1>
      </template>
    </DialogBox>
    <DialogBox
      v-model="intermittentDialogShown"
    >
      <template #dialogContent>
        <h1>Site intermittent</h1>
      </template>
    </DialogBox>
    <DialogBox
      v-model="snowDialogShown"
    >
      <template #dialogContent>
        <h1>Site snow-dominated</h1>
      </template>
    </DialogBox>
    <DialogBox
      v-model="iceDialogShown"
    >
      <template #dialogContent>
        <h1>Site ice impacted</h1>
      </template>
    </DialogBox>
  </section>
</template>

<script setup>
  import { ref } from 'vue';
  import DialogBox from "./DialogBox.vue";
  import DamIcon from "@/assets/svgs/dam.svg";
  import IntermittentIcon from "@/assets/svgs/intermittent.svg";
  import SnowIcon from "@/assets/svgs/snow.svg";
  import FrozenIcon  from "@/assets/svgs/frozen.svg";

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

  const regulatedDialogShown = ref(false);
  const intermittentDialogShown = ref(false);
  const snowDialogShown = ref(false);
  const iceDialogShown = ref(false);

  function showRegulatedDialog() {
    regulatedDialogShown.value = true;
  }
  function showIntermittentDialog() {
    intermittentDialogShown.value = true;
  }
  function showSnowDialog() {
    snowDialogShown.value = true;
  }
  function showIceDialog() {
    iceDialogShown.value = true;
  }
</script>

<style>
#icon-container {
  display: flex;
  flex-direction: row;
  gap: 3px;
}
.icon-button {
  cursor: pointer;
  display: flex;
  align-items: center;
  background-color: transparent;
  border: none;
  width: 30px;
  height: 30px;
  padding: 0;
}
.icon-button:disabled {
  opacity: 0.25;
  cursor: not-allowed;
}
.hydrology-icon {
  width: 30px;
  height: 30px;
}
</style>