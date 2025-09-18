<template>
  <div
    class="checkbox_wrap toggle-container"
    aria-label="Toggle container"
  >
    <label
      class="toggle-label"
      :aria-label="ariaLabel"
    >
      <!-- Left label for either/or use case -->
      <span 
        v-if="leftLabel" 
        class="toggle-text left" 
        :class="{ tactive: !modelValue }" 
        :title="leftLabel"
        aria-hidden="true"
      >
        {{ leftLabel }}
      </span>
      
      <!-- Toggle switch -->
      <input 
        type="checkbox" 
        class="toggle-input" 
        :checked="modelValue"
        :aria-checked="modelValue"
        @change="$emit('update:modelValue', !modelValue)"
      >
      <span 
        class="toggle-slider"
        :style="{ backgroundColor: modelValue ? rightColor : leftColor }"
        aria-hidden="true"
      />

      <!-- Right label for either/or use case or single toggle label -->
      <span 
        v-if="rightLabel" 
        class="toggle-text right" 
        :class="{ tactive: modelValue, inactive: !modelValue }"
        :title="rightLabel"
        aria-hidden="true"
      >
        {{ rightLabel }}
      </span>
      <!-- Single label -->
      <span 
        v-else-if="label" 
        class="toggle-text right"
        :class="{ tactive: modelValue, inactive: !modelValue }"
        :title="label"
        aria-hidden="true"
      >
        {{ label }}
      </span>
    </label>
  </div>
</template>

<script setup>
defineProps({
  modelValue: Boolean, // v-model binding for toggle state

  // optional props for either/or labels
  leftLabel: {
    type: String,
    required: false,
    default: null
  },
  rightLabel: {
    type: String,
    required: false,
    default: null
  },

  // optional prop for single label (on/off use case)
  label: {
    type: String,
    required: false,
    default: null
  },
  // colors for each label and inactive state
  leftColor: {
    type: String,
    default: 'var(--inactive-grey)' 
  },
  rightColor: {
    type: String,
    default: 'var(--soft-black)' 
  },
  inactiveColor: {
    type: String,
    default: 'var(--inactive-grey)' 
  },
  ariaLabel: {
    type: String,
    default: 'Show'
  }
});

defineEmits(['update:modelValue']);
</script>

<style scoped lang="scss">
$activeFontWeight: 400;
.toggle-container {
  display: flex;
  align-items: start;
  gap: 10px;
  margin-left: 5px;
  margin-bottom: 0.3rem;
}

/* toggle label for positioning */
.toggle-label {
  display: flex;
  align-items: center;
  gap: 8px;
  cursor: pointer;
  position: relative;
}
.toggle-label:has(:focus-visible) {
  border: 2px solid var(--usgs-blue);
  border-radius: 10px;
  padding: 0 3px 0 3px;
  margin: -2px -5px -2px -5px;
}
/* text styles */
.toggle-text {
  transition: color 0.3s ease;
  color: var(--inactive-text-grey);
}
.toggle-text.left {
  text-align: right;
}
/* pseudo element to prevent shifting */
.toggle-text::before {
  display: block;
  content: attr(title);
  font-weight: $activeFontWeight;
  height: 0;
  overflow: hidden;
  visibility: hidden;
}

.toggle-text.tactive {
  color: var(--black-soft); /* active label is black */
  font-weight: $activeFontWeight;
}

/* toggle input (hidden) */
.toggle-input {
  position: absolute;
  left: -9999px;
}
.toggle-input:focus-visible {
  outline: none; /* removes focus outline */
}

.toggle-label:focus-visible {
  outline: none; /* removes focus outline */
}

/* toggle slider styles */
.toggle-slider {
  flex-shrink: 0;
  position: relative;
  width: 40px;
  height: 20px;
  border-radius: 20px;
  transition: background-color 0.3s ease;
}

.toggle-slider::before {
  content: "";
  position: absolute;
  width: 16px;
  height: 16px;
  background-color: white;
  border-radius: 50%;
  top: 2px;
  left: 2px;
  transition: transform 0.3s ease;
}

/* move slider to the right when checked */
.toggle-input:checked + .toggle-slider::before {
  top: 2px;
  transform: translateX(20px);
}

</style>
