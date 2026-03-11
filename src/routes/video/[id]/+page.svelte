<script>
  import { page } from '$app/stores';
  import { onMount } from 'svelte';
  import VideoPlayer from '$lib/components/video/VideoPlayer.svelte';
  import VideoInfo from '$lib/components/video/VideoInfo.svelte';
  import ShareModal from '$lib/components/modals/ShareModal.svelte';

  // Video ID from URL
  let videoId = '';
  $: videoId = $page.params.id;

  // State variables
  let loading = true;
  let error = null;
  let videoInfo = null;
  let showShareModal = false;

  /**
   * Fetch video information from API
   */
  async function fetchVideoInfo() {
    try {
      const response = await fetch(`http://localhost:3000/api/video/${videoId}`);
      if (!response.ok) throw new Error('Video not found');

      videoInfo = await response.json();
    } catch (err) {
      error = err.message;
    } finally {
      loading = false;
    }
  }

  // Fetch video info when component mounts
  onMount(() => {
    fetchVideoInfo();
  });

  /**
   * Handle share button click
   */
  function handleShare() {
    showShareModal = true;
  }
</script>

<svelte:head>
  <title>{videoInfo?.title || 'Video'} - VideoStream</title>
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
      <!-- Video Player Component -->
      <VideoPlayer {videoInfo} />

      <!-- Video Info Component -->
      <VideoInfo {videoInfo} on:share={handleShare} />
    {/if}
  </div>

  <!-- Share Modal Component -->
  <ShareModal bind:showModal={showShareModal} {videoInfo} />
</div>