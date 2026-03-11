<script>
  export let video = {};

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
         transition-all duration-300 hover:scale-105 shadow-lg hover:shadow-2xl"
>
  <!-- Thumbnail Container -->
  <div class="relative aspect-video bg-gray-700">
    {#if video.thumbnail_url}
      <img
        src="http://localhost:3000{video.thumbnail_url}"
        alt={video.title}
        class="w-full h-full object-cover"
        loading="lazy"
      />
    {:else}
      <!-- Placeholder if no thumbnail -->
      <div class="flex items-center justify-center h-full">
        <svg class="w-16 h-16 text-gray-600" fill="currentColor" viewBox="0 0 20 20">
          <path d="M2 6a2 2 0 012-2h6a2 2 0 012 2v8a2 2 0 01-2 2H4a2 2 0 01-2-2V6zM14.553 7.106A1 1 0 0014 8v4a1 1 0 00.553.894l2 1A1 1 0 0018 13V7a1 1 0 00-1.447-.894l-2 1z"/>
        </svg>
      </div>
    {/if}

    <!-- Duration Badge -->
    {#if video.duration}
      <div class="absolute bottom-2 right-2 bg-black/80 text-white text-xs px-2 py-1 rounded">
        {formatDuration(video.duration)}
      </div>
    {/if}

    <!-- Resolution Badge -->
    {#if video.resolution}
      <div class="absolute top-2 right-2 bg-red-600 text-white text-xs px-2 py-1 rounded">
        {video.resolution.split('x')[1]}p
      </div>
    {/if}
  </div>

  <!-- Video Info -->
  <div class="p-4">
    <!-- Title -->
    <h3 class="font-semibold text-white group-hover:text-indigo-400 transition-colors
               line-clamp-2 mb-2">
      {video.title}
    </h3>

    <!-- Metadata -->
    <div class="flex items-center gap-3 text-sm text-gray-400">
      <!-- Views -->
      <span class="flex items-center gap-1">
        <svg class="w-4 h-4" fill="currentColor" viewBox="0 0 20 20">
          <path d="M10 12a2 2 0 100-4 2 2 0 000 4z"/>
          <path fill-rule="evenodd" d="M.458 10C1.732 5.943 5.522 3 10 3s8.268 2.943 9.542 7c-1.274 4.057-5.064 7-9.542 7S1.732 14.057.458 10zM14 10a4 4 0 11-8 0 4 4 0 018 0z" clip-rule="evenodd"/>
        </svg>
        {video.view_count || 0} views
      </span>

      <!-- Upload Date -->
      {#if video.upload_date}
        <span>•</span>
        <span>{formatDate(video.upload_date)}</span>
      {/if}
    </div>

    <!-- Description Preview -->
    {#if video.description}
      <p class="text-gray-500 text-sm mt-2 line-clamp-2">
        {video.description}
      </p>
    {/if}
  </div>
</a>