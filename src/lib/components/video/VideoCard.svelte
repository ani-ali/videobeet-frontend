<script>
  import { API_BASE_URL } from '$lib/config';

  export let video = {};

  // Check if video is still processing
  $: isProcessing = !video.duration || !video.resolution;

  /**
   * Format video duration for display
   */
  function formatDuration(seconds) {
    if (!seconds) return '';
    const mins = Math.floor(seconds / 60);
    const secs = Math.floor(seconds % 60);
    return `${mins}:${secs.toString().padStart(2, '0')}`;
  }

  /**
   * Format upload date for display
   */
  function formatDate(dateString) {
    if (!dateString) return '';
    const date = new Date(dateString);
    const now = new Date();
    const diff = now - date;
    const days = Math.floor(diff / (1000 * 60 * 60 * 24));

    if (days === 0) return 'Today';
    if (days === 1) return 'Yesterday';
    if (days < 7) return `${days} days ago`;
    if (days < 30) return `${Math.floor(days / 7)} weeks ago`;
    if (days < 365) return `${Math.floor(days / 30)} months ago`;
    return `${Math.floor(days / 365)} years ago`;
  }
</script>

<!-- Video Card -->
<a
  href="/video/{video.id}"
  class="group block bg-gray-800 rounded-lg overflow-hidden hover:bg-gray-750
         transition-all duration-300 hover:scale-[1.02] sm:hover:scale-105 shadow-lg hover:shadow-2xl"
>
  <!-- Thumbnail Container -->
  <div class="relative aspect-video bg-gray-700">
    {#if isProcessing}
      <!-- Processing Overlay -->
      <div class="absolute inset-0 bg-gray-900/90 flex flex-col items-center justify-center">
        <div class="animate-spin rounded-full h-8 w-8 sm:h-10 sm:w-10 border-b-2 border-indigo-600 mb-2"></div>
        <span class="text-white text-xs sm:text-sm font-medium">Processing...</span>
      </div>
    {:else if video.thumbnail_url}
      <img
        src="{API_BASE_URL}{video.thumbnail_url}"
        alt={video.title}
        class="w-full h-full object-cover"
        loading="lazy"
      />
    {:else}
      <!-- Placeholder if no thumbnail -->
      <div class="flex items-center justify-center h-full">
        <svg class="w-12 sm:w-16 h-12 sm:h-16 text-gray-600" fill="currentColor" viewBox="0 0 20 20">
          <path d="M2 6a2 2 0 012-2h6a2 2 0 012 2v8a2 2 0 01-2 2H4a2 2 0 01-2-2V6zM14.553 7.106A1 1 0 0014 8v4a1 1 0 00.553.894l2 1A1 1 0 0018 13V7a1 1 0 00-1.447-.894l-2 1z"/>
        </svg>
      </div>
    {/if}

    <!-- Duration Badge (only if not processing) -->
    {#if !isProcessing && video.duration}
      <div class="absolute bottom-1 sm:bottom-2 right-1 sm:right-2 bg-black/80 text-white text-xs px-1.5 sm:px-2 py-0.5 sm:py-1 rounded">
        {formatDuration(video.duration)}
      </div>
    {/if}

    <!-- Resolution Badge (only if not processing) -->
    {#if !isProcessing && video.resolution}
      <div class="absolute top-1 sm:top-2 right-1 sm:right-2 bg-red-600 text-white text-xs px-1.5 sm:px-2 py-0.5 sm:py-1 rounded">
        {video.resolution.split('x')[1]}p
      </div>
    {/if}

    <!-- Processing Status Badge -->
    {#if isProcessing}
      <div class="absolute top-1 sm:top-2 left-1 sm:left-2 bg-yellow-600 text-white text-xs px-1.5 sm:px-2 py-0.5 sm:py-1 rounded flex items-center gap-1">
        <svg class="w-3 h-3 animate-pulse" fill="currentColor" viewBox="0 0 20 20">
          <path fill-rule="evenodd" d="M10 18a8 8 0 100-16 8 8 0 000 16zm1-12a1 1 0 10-2 0v4a1 1 0 00.293.707l2.828 2.829a1 1 0 101.415-1.415L11 9.586V6z" clip-rule="evenodd"/>
        </svg>
        Processing
      </div>
    {/if}
  </div>

  <!-- Video Info -->
  <div class="p-3 sm:p-4">
    <!-- Title -->
    <h3 class="font-semibold text-white group-hover:text-indigo-400 transition-colors
               line-clamp-2 mb-1.5 sm:mb-2 text-sm sm:text-base">
      {video.title}
    </h3>

    <!-- Metadata -->
    <div class="flex flex-col sm:flex-row items-start sm:items-center gap-1 sm:gap-3 text-xs sm:text-sm text-gray-400">
      {#if isProcessing}
        <!-- Show processing status instead of view count -->
        <span class="text-yellow-500 font-medium">Video processing...</span>
      {:else}
        <!-- Views -->
        <span class="flex items-center gap-1">
          <svg class="w-3 sm:w-4 h-3 sm:h-4" fill="currentColor" viewBox="0 0 20 20">
            <path d="M10 12a2 2 0 100-4 2 2 0 000 4z"/>
            <path fill-rule="evenodd" d="M.458 10C1.732 5.943 5.522 3 10 3s8.268 2.943 9.542 7c-1.274 4.057-5.064 7-9.542 7S1.732 14.057.458 10zM14 10a4 4 0 11-8 0 4 4 0 018 0z" clip-rule="evenodd"/>
          </svg>
          {video.view_count || 0} views
        </span>
      {/if}

      <!-- Upload Date -->
      {#if video.upload_date}
        <span class="hidden sm:inline">•</span>
        <span>{formatDate(video.upload_date)}</span>
      {/if}
    </div>

    <!-- Description Preview - Hidden on very small screens -->
    {#if video.description}
      <p class="hidden sm:block text-gray-500 text-xs sm:text-sm mt-2 line-clamp-2">
        {video.description}
      </p>
    {/if}
  </div>
</a>