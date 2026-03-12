<script>
  import { page } from '$app/stores';
  import { onMount } from 'svelte';
  import VideoPlayer from '$lib/components/video/VideoPlayer.svelte';
  import VideoInfo from '$lib/components/video/VideoInfo.svelte';
  import ShareModal from '$lib/components/modals/ShareModal.svelte';
  import { API_BASE_URL } from '$lib/config';

  // Video ID from URL
  let videoId = '';
  $: videoId = $page.params.id;

  // State variables
  let loading = true;
  let error = null;
  let videoInfo = null;
  let showShareModal = false;
  let processingCheckInterval = null;
  let isProcessing = false;

  /**
   * Fetch video information from API
   */
  async function fetchVideoInfo() {
    try {
      const response = await fetch(`${API_BASE_URL}/api/videos/${videoId}`);
      if (!response.ok) throw new Error('Video not found');

      videoInfo = await response.json();

      // Check if video is still processing (no duration or resolution means still processing)
      if (!videoInfo.duration || !videoInfo.resolution) {
        isProcessing = true;
        startProcessingCheck();
      } else {
        isProcessing = false;
        stopProcessingCheck();
      }
    } catch (err) {
      error = err.message;
    } finally {
      loading = false;
    }
  }

  /**
   * Start periodic checking for video processing status
   */
  function startProcessingCheck() {
    // Check every 3 seconds
    processingCheckInterval = setInterval(async () => {
      try {
        const response = await fetch(`${API_BASE_URL}/api/videos/${videoId}`);
        if (response.ok) {
          const updatedInfo = await response.json();
          videoInfo = updatedInfo;

          // If processing is complete, stop checking
          if (updatedInfo.duration && updatedInfo.resolution) {
            isProcessing = false;
            stopProcessingCheck();
          }
        }
      } catch (err) {
        console.error('Error checking video status:', err);
      }
    }, 3000);
  }

  /**
   * Stop checking for processing status
   */
  function stopProcessingCheck() {
    if (processingCheckInterval) {
      clearInterval(processingCheckInterval);
      processingCheckInterval = null;
    }
  }

  // Fetch video info when component mounts
  onMount(() => {
    fetchVideoInfo();

    // Cleanup on unmount
    return () => {
      stopProcessingCheck();
    };
  });

  /**
   * Handle share button click
   */
  function handleShare() {
    showShareModal = true;
  }
</script>

<svelte:head>
  <title>{videoInfo?.title || 'Video'} - VideoBeet</title>
  <script src="https://cdn.jsdelivr.net/npm/hls.js@latest"></script>
</svelte:head>

<!-- Main Container -->
<div class="min-h-screen bg-gray-900">
  <div class="max-w-6xl mx-auto p-4">
    {#if loading}
      <!-- Loading State -->
      <div class="flex flex-col items-center justify-center py-32">
        <div class="animate-spin rounded-full h-16 w-16 border-b-2 border-white"></div>
        <p class="mt-4 text-white">Loading video...</p>
      </div>
    {:else if error}
      <!-- Error State -->
      <div class="bg-red-900/50 border border-red-500 rounded-lg p-6 text-center">
        <p class="text-red-300 font-semibold">{error}</p>
        <p class="text-red-400 mt-2">Make sure the backend is running</p>
        <a href="/" class="inline-block mt-4 px-4 py-2 bg-red-600 hover:bg-red-700
                          text-white rounded-lg transition-colors">
          Go to Home
        </a>
      </div>
    {:else if videoInfo}
      {#if isProcessing}
        <!-- Processing State -->
        <div class="bg-gray-800 rounded-lg p-8 text-center">
          <div class="mb-6">
            <div class="inline-flex items-center justify-center w-20 h-20 rounded-full bg-indigo-600/20">
              <div class="animate-spin rounded-full h-12 w-12 border-b-2 border-indigo-600"></div>
            </div>
          </div>
          <h2 class="text-2xl font-bold text-white mb-2">Video is Processing</h2>
          <p class="text-gray-400 mb-6">
            Your video "{videoInfo.title}" is being converted for optimal streaming.
            This usually takes 1-3 minutes depending on video size.
          </p>
          <div class="flex justify-center gap-4">
            <a href="/" class="px-6 py-2 bg-gray-700 hover:bg-gray-600 text-white rounded-lg transition-colors">
              Browse Other Videos
            </a>
            <button
              on:click={() => window.location.reload()}
              class="px-6 py-2 bg-indigo-600 hover:bg-indigo-700 text-white rounded-lg transition-colors"
            >
              Check Again
            </button>
          </div>
          <p class="text-xs text-gray-500 mt-4">
            Page will automatically refresh when processing is complete
          </p>
        </div>
      {:else}
        <!-- Video Ready - Show Player -->
        <VideoPlayer {videoInfo} />

        <!-- Video Info Component -->
        <VideoInfo {videoInfo} on:share={handleShare} />
      {/if}
    {/if}
  </div>

  <!-- Share Modal Component -->
  <ShareModal bind:showModal={showShareModal} {videoInfo} />
</div>
