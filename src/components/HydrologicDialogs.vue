<template>
  <div
    id="icon-dialogs-container"
  >
    <DialogBox
      v-model="normalDialogShown"
      dialog-id="normal-dialog"
    >
      <template #dialogTitle>
        <div
          class="title-container"
        >
          <NormalIcon
            class="hydrology-icon"
            aria-hidden="true"
          />
          <p v-html="text.icons.normal.title" />
        </div>
      </template>
      <template #dialogContent>
        <div class="content-container">
          <p v-html="text.icons.normal.paragraph1" />
        </div>        
      </template>
    </DialogBox>
    <DialogBox
      v-model="intermittentDialogShown"
      dialog-id="intermittent-dialog"
    >
      <template #dialogTitle>
        <div
          class="title-container"
        >
          <IntermittentIcon
            class="hydrology-icon"
            aria-hidden="true"
          />
          <p v-html="text.icons.intermittent.title" />
        </div>
      </template>
      <template #dialogContent>
        <div class="content-container">
          <p v-html="text.icons.intermittent.paragraph1" />
          <p v-html="text.icons.intermittent.paragraph2" />
        </div>        
      </template>
    </DialogBox>
    <DialogBox
      v-model="regulatedDialogShown"
      dialog-id="regulated-dialog"
    >
      <template #dialogTitle>
        <div
          class="title-container"
        >
          <DamIcon
            class="hydrology-icon"
            aria-hidden="true"
          />
          <p v-html="text.icons.regulated.title" />
        </div>
      </template>
      <template #dialogContent>
        <div class="content-container">
          <p v-html="text.icons.regulated.paragraph1" />
          <p v-html="text.icons.regulated.paragraph2" />
        </div>        
      </template>
    </DialogBox>
    <DialogBox
      v-model="snowDialogShown"
      dialog-id="snow-dialog"
    >
      <template #dialogTitle>
        <div
          class="title-container"
        >
          <SnowIcon
            class="hydrology-icon"
            aria-hidden="true"
          />
          <p v-html="text.icons.snow.title" />
        </div>
      </template>
      <template #dialogContent>
        <div class="content-container">
          <p v-html="text.icons.snow.paragraph1" />
          <p v-html="text.icons.snow.paragraph2" />
        </div>  
      </template>
    </DialogBox>
    <DialogBox
      v-model="iceDialogShown"
      dialog-id="ice-dialog"
    >
      <template #dialogTitle>
        <div
          class="title-container"
        >
          <FrozenIcon
            class="hydrology-icon"
            aria-hidden="true"
          />
          <p v-html="text.icons.ice.title" />
        </div>
      </template>
      <template #dialogContent>
        <div class="content-container">
          <p v-html="text.icons.ice.paragraph1" />
          <p v-html="text.icons.ice.paragraph2" />
        </div>        
      </template>
    </DialogBox>
  </div>
</template>

<script setup>
  import { storeToRefs } from "pinia";
  import { useGlobalDataStore } from "@/stores/global-data-store";
  import DialogBox from "./DialogBox.vue";
  import DamIcon from "@/assets/svgs/dam.svg";
  import IntermittentIcon from "@/assets/svgs/intermittent.svg";
  import SnowIcon from "@/assets/svgs/snow.svg";
  import FrozenIcon  from "@/assets/svgs/frozen.svg";
  import NormalIcon  from "@/assets/svgs/normal.svg";
  import text from "@/assets/text/text.js";

  // global variables
  const globalDataStore = useGlobalDataStore();
  const { normalDialogShown } = storeToRefs(globalDataStore);
  const { intermittentDialogShown } = storeToRefs(globalDataStore);
  const { regulatedDialogShown } = storeToRefs(globalDataStore); 
  const { snowDialogShown } = storeToRefs(globalDataStore);
  const { iceDialogShown } = storeToRefs(globalDataStore);
</script>

<style scoped lang="scss">
  $icon-height: 35px;
  .hydrology-icon {
    width: $icon-height;
    height: $icon-height;
  }
  #icon-dialogs-container .title-container {
    display: flex;
    gap: 1rem;
    align-content: center;
  }
   #icon-dialogs-container .title-container p {
    padding: 0;
    line-height: $icon-height;
  }
  #icon-dialogs-container .content-container p {
    font-weight: 400;
  }
</style>