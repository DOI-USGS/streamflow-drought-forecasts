<template>
  <button 
    class="close-button" 
    type="button"
    :title="buttonTitle"
    :style="{width: buttonDim, height: buttonDim}"
  >
    <span 
      class="symbol"
    >
      <svg 
        xmlns="http://www.w3.org/2000/svg"
        viewBox="0 0 20 20"
        :style="{width: buttonSvgDim, height: buttonSvgDim, transform: `rotate(${buttonRotate})`}"
      >
        <line 
          class="symbol-line"
          x1="10"
          y1="1"
          x2="10"
          y2="19"
        />
        <line
          class="symbol-line"
          x1="19"
          y1="10"
          x2="1"
          y2="10"
        />
      </svg>  
    </span>
  </button>
</template>

<script setup>
  const props = defineProps({
    buttonTitle: {
      type: String,
      required: true,
      default: 'button'
    },
    buttonDim: {
      type: String,
      required: false,
      default: '29px'
    },
    buttonSvgDim: {
      type: String,
      required: false,
      default: '22px'
    },
    buttonRotate: {
      type: Number,
      required: false,
      default: 45
    }
  })
</script>

<style scoped lang="scss">
  .close-button {
    display: flex;
    align-items: center;
    justify-content: center;
    background-color: transparent;
    border: 0;
    padding: 0;
    cursor: pointer;
  }
  .symbol {
    display: flex;
    align-items: center;
    margin: 0 auto 0 auto;
  }
  .symbol svg {
    transform: rotate(45deg);
  }
  .symbol-line {
    stroke: var(--color-text);
    stroke-width: 0.8px;
  }
</style>