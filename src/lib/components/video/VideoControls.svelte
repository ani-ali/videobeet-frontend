<script>
  import { createEventDispatcher } from 'svelte';

  export let isPlaying = false;
  export let currentTime = 0;
  export let duration = 0;
  export let bufferedPercent = 0;
  export let volume = 1;
  export let isMuted = false;

  const dispatch = createEventDispatcher();

  /**
   * Format time helper
   */
  function formatTime(seconds) {
    if (isNaN(seconds)) return '0:00';
    const mins = Math.floor(seconds / 60);
    const secs = Math.floor(seconds % 60);
    return `${mins}:${secs.toString().padStart(2, '0')}`;
  }

  /**
   * Handle seek on progress bar click
   */
  function handleSeek(e) {
    const rect = e.currentTarget.getBoundingClientRect();
    const percent = (e.clientX - rect.left) / rect.width;
    const seekTime = percent * duration;
    dispatch('seek', seekTime);
  }

  /**
   * Handle volume change
   */
  function handleVolumeChange(e) {
    const rect = e.currentTarget.getBoundingClientRect();
    const percent = (e.clientX - rect.left) / rect.width;
    const newVolume = Math.max(0, Math.min(1, percent));
    dispatch('volumeChange', newVolume);
  }
</script>

<!-- Custom Controls Overlay -->
<div class="absolute bottom-0 left-0 right-0 bg-gradient-to-t from-black/90 to-transparent p-4">
  <div class="flex items-center gap-4">
    <!-- Play/Pause Button -->
    <button
      class="text-white hover:text-gray-300 transition-colors"
      on:click={() => dispatch('play')}
      aria-label={isPlaying ? 'Pause' : 'Play'}
    >
      {#if isPlaying}
        <svg class="w-8 h-8" fill="currentColor" viewBox="0 0 20 20">
          <path fill-rule="evenodd" d="M5 4.5A1.5 1.5 0 016.5 3h1A1.5 1.5 0 019 4.5v11A1.5 1.5 0 017.5 17h-1A1.5 1.5 0 015 15.5v-11zM11 4.5A1.5 1.5 0 0112.5 3h1A1.5 1.5 0 0115 4.5v11a1.5 1.5 0 01-1.5 1.5h-1A1.5 1.5 0 0111 15.5v-11z"/>
        </svg>
      {:else}
        <svg class="w-8 h-8" fill="currentColor" viewBox="0 0 20 20">
          <path d="M6.3 2.841A1.5 1.5 0 004 4.11v11.78a1.5 1.5 0 002.3 1.269l9.344-5.89a1.5 1.5 0 000-2.538L6.3 2.84z"/>
        </svg>
      {/if}
    </button>

    <!-- Time Display -->
    <span class="text-white text-sm font-mono">
      {formatTime(currentTime)}
    </span>

    <!-- Progress Bar -->
    <div
      class="flex-1 relative h-2 bg-gray-700 rounded-full cursor-pointer group"
      on:click={handleSeek}
    >
      <!-- Buffer Bar -->
      <div
        class="absolute h-full bg-gray-600 rounded-full"
        style="width: {bufferedPercent}%"
      ></div>
      <!-- Progress Bar -->
      <div
        class="absolute h-full bg-red-600 rounded-full group-hover:bg-red-500 transition-colors"
        style="width: {(currentTime / duration) * 100}%"
      >
        <span class="absolute right-0 top-1/2 transform translate-x-1/2 -translate-y-1/2
                     w-4 h-4 bg-white rounded-full opacity-0 group-hover:opacity-100
                     transition-opacity"></span>
      </div>
    </div>

    <!-- Duration Display -->
    <span class="text-white text-sm font-mono">
      {formatTime(duration)}
    </span>

    <!-- Volume Controls -->
    <button
      class="text-white hover:text-gray-300 transition-colors"
      on:click={() => dispatch('mute')}
      aria-label={isMuted ? 'Unmute' : 'Mute'}
    >
      {#if isMuted}
        <svg class="w-6 h-6" fill="currentColor" viewBox="0 0 20 20">
          <path fill-rule="evenodd" d="M9.383 3.076A1 1 0 0110 4v12a1 1 0 01-1.707.707L4.586 13H2a1 1 0 01-1-1V8a1 1 0 011-1h2.586l3.707-3.707a1 1 0 011.09-.217zM12.293 7.293a1 1 0 011.414 0L15 8.586l1.293-1.293a1 1 0 111.414 1.414L16.414 10l1.293 1.293a1 1 0 01-1.414 1.414L15 11.414l-1.293 1.293a1 1 0 01-1.414-1.414L13.586 10l-1.293-1.293a1 1 0 010-1.414z" clip-rule="evenodd"/>
        </svg>
      {:else if volume > 0.5}
        <svg class="w-6 h-6" fill="currentColor" viewBox="0 0 20 20">
          <path fill-rule="evenodd" d="M9.383 3.076A1 1 0 0110 4v12a1 1 0 01-1.707.707L4.586 13H2a1 1 0 01-1-1V8a1 1 0 011-1h2.586l3.707-3.707a1 1 0 011.09-.217zM14.657 2.929a1 1 0 011.414 0A9.972 9.972 0 0118 10a9.972 9.972 0 01-2.929 7.071 1 1 0 01-1.414-1.414A7.971 7.971 0 0016 10c0-2.21-.894-4.208-2.343-5.657a1 1 0 010-1.414zm-2.829 2.828a1 1 0 011.415 0A5.983 5.983 0 0114 10a5.984 5.984 0 01-1.757 4.243 1 1 0 01-1.415-1.415A3.984 3.984 0 0012 10a3.983 3.983 0 00-1.172-2.828 1 1 0 010-1.415z" clip-rule="evenodd"/>
        </svg>
      {:else if volume > 0}
        <svg class="w-6 h-6" fill="currentColor" viewBox="0 0 20 20">
          <path fill-rule="evenodd" d="M9.383 3.076A1 1 0 0110 4v12a1 1 0 01-1.707.707L4.586 13H2a1 1 0 01-1-1V8a1 1 0 011-1h2.586l3.707-3.707a1 1 0 011.09-.217zM11.828 5.757a1 1 0 011.415 0A3.984 3.984 0 0114 10a3.983 3.983 0 01-1.172 2.828 1 1 0 11-1.415-1.415A1.984 1.984 0 0012 10c0-.552-.223-1.048-.586-1.414a1 1 0 010-1.415z" clip-rule="evenodd"/>
        </svg>
      {:else}
        <svg class="w-6 h-6" fill="currentColor" viewBox="0 0 20 20">
          <path fill-rule="evenodd" d="M9.383 3.076A1 1 0 0110 4v12a1 1 0 01-1.707.707L4.586 13H2a1 1 0 01-1-1V8a1 1 0 011-1h2.586l3.707-3.707a1 1 0 011.09-.217z" clip-rule="evenodd"/>
        </svg>
      {/if}
    </button>

    <!-- Volume Slider -->
    <div
      class="w-24 h-2 bg-gray-700 rounded-full cursor-pointer group"
      on:click={handleVolumeChange}
    >
      <div
        class="h-full bg-white rounded-full group-hover:bg-gray-300 transition-colors"
        style="width: {volume * 100}%"
      ></div>
    </div>

    <!-- Fullscreen Button -->
    <button
      class="text-white hover:text-gray-300 transition-colors ml-2"
      on:click={() => dispatch('fullscreen')}
      aria-label="Fullscreen"
    >
      <svg class="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2"
              d="M4 8V4m0 0h4M4 4l5 5m11-1V4m0 0h-4m4 0l-5 5M4 16v4m0 0h4m-4 0l5-5m11 5l-5-5m5 5v-4m0 4h-4"/>
      </svg>
    </button>
  </div>
</div>