<template>
  <div id="warning-container">
    <div
      id="warning-content"
    >
      <p>
        You are viewing an <b>experimental</b> application. Please click here 
      </p>
      <span>
        <FaqButton />
      </span> 
      <p>
        to learn about current limitations of this tool.
      </p>
    </div>
  </div>
</template>

<script setup>
  import FaqButton from './FaqButton.vue';
</script>

<style scoped lang="scss">
  #warning-container {
    background-color: #b9c7d2;
    padding-bottom: 0.3em;
    padding-top: 0.3em;
  }
  #warning-content {
    display: flex;
    flex-direction: row;
    margin: auto;
    align-items: center;
    max-width: max-content;
    p {
      text-align: center;
      font-weight: 400;
      line-height: 35px;
      padding: 0;
      font-size: 1.6rem;
      color: var(--usgs-blue);
    }
  }
</style>
