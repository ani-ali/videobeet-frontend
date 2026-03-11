<script>
  import { createEventDispatcher } from 'svelte';

  export let videoInfo = {};

  const dispatch = createEventDispatcher();

  /**
   * Format duration time
   */
  function formatTime(seconds) {
    if (!seconds || isNaN(seconds)) return '';
    const mins = Math.floor(seconds / 60);
    const secs = Math.floor(seconds % 60);
    return `${mins}:${secs.toString().padStart(2, '0')}`;
  }

  /**
   * Format upload date
   */
  function formatDate(dateString) {
    if (!dateString) return '';
    return new Date(dateString).toLocaleDateString();
  }
</script>

<!-- Video Info Section -->
<div class="mt-6 bg-gray-800 rounded-lg p-6">
  <!-- Title -->
  <h1 class="text-2xl font-bold text-white mb-3">
    {videoInfo.title || 'Untitled Video'}
  </h1>

  <!-- Metadata and Share Button -->
  <div class="flex items-center justify-between mb-4">
    <!-- Video Metadata -->
    <div class="flex items-center gap-4 text-gray-400">
      <!-- View Count -->
      <span class="flex items-center gap-1">
        <svg class="w-4 h-4" fill="currentColor" viewBox="0 0 20 20">
          <path d="M10 12a2 2 0 100-4 2 2 0 000 4z"/>
          <path fill-rule="evenodd" d="M.458 10C1.732 5.943 5.522 3 10 3s8.268 2.943 9.542 7c-1.274 4.057-5.064 7-9.542 7S1.732 14.057.458 10zM14 10a4 4 0 11-8 0 4 4 0 018 0z" clip-rule="evenodd"/>
        </svg>
        {videoInfo.view_count || 0} views
      </span>

      <!-- Resolution Badge -->
      {#if videoInfo.resolution}
        <span class="px-2 py-1 bg-gray-700 rounded text-xs font-medium">
          {videoInfo.resolution}
        </span>
      {/if}

      <!-- Duration -->
      {#if videoInfo.duration}
        <span class="flex items-center gap-1">
          <svg class="w-4 h-4" fill="currentColor" viewBox="0 0 20 20">
            <path fill-rule="evenodd" d="M10 18a8 8 0 100-16 8 8 0 000 16zm1-12a1 1 0 10-2 0v4a1 1 0 00.293.707l2.828 2.829a1 1 0 101.415-1.415L11 9.586V6z" clip-rule="evenodd"/>
          </svg>
          {formatTime(videoInfo.duration)}
        </span>
      {/if}

      <!-- Upload Date -->
      {#if videoInfo.upload_date}
        <span class="flex items-center gap-1">
          <svg class="w-4 h-4" fill="currentColor" viewBox="0 0 20 20">
            <path fill-rule="evenodd" d="M6 2a1 1 0 00-1 1v1H4a2 2 0 00-2 2v10a2 2 0 002 2h12a2 2 0 002-2V6a2 2 0 00-2-2h-1V3a1 1 0 10-2 0v1H7V3a1 1 0 00-1-1zm0 5a1 1 0 000 2h8a1 1 0 100-2H6z" clip-rule="evenodd"/>
          </svg>
          {formatDate(videoInfo.upload_date)}
        </span>
      {/if}
    </div>

    <!-- Share Button -->
    <button
      on:click={() => dispatch('share')}
      class="px-4 py-2 bg-indigo-600 hover:bg-indigo-700 text-white rounded-lg
             flex items-center gap-2 transition-colors"
    >
      <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2"
              d="M4 16v1a3 3 0 003 3h10a3 3 0 003-3v-1m-4-8l-4-4m0 0L8 8m4-4v12"/>
      </svg>
      Share
    </button>
  </div>

  <!-- Description -->
  {#if videoInfo.description}
    <div class="border-t border-gray-700 pt-4">
      <h3 class="text-sm font-semibold text-gray-300 mb-2">Description</h3>
      <p class="text-gray-400 whitespace-pre-wrap">
        {videoInfo.description}
      </p>
    </div>
  {/if}
</div>