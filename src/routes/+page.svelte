<script>
  import { onMount } from 'svelte';
  import VideoCard from '$lib/components/video/VideoCard.svelte';

  let videos = [];
  let loading = true;
  let error = null;

  /**
   * Fetch all videos from the API
   */
  async function fetchVideos() {
    try {
      const response = await fetch('http://localhost:3000/api/videos');
      if (!response.ok) throw new Error('Failed to fetch videos');

      const data = await response.json();
      videos = data.videos || [];
    } catch (err) {
      error = err.message;
    } finally {
      loading = false;
    }
  }

  // Fetch videos when component mounts
  onMount(() => {
    fetchVideos();
  });
</script>

<svelte:head>
  <title>VideoStream - Share Your Videos</title>
</svelte:head>

<!-- Main Container -->
<div class="min-h-screen bg-gray-900">
  <!-- Hero Section -->
  <div class="bg-gradient-to-b from-indigo-600/20 to-transparent">
    <div class="max-w-7xl mx-auto px-4 py-12 sm:px-6 lg:px-8">
      <div class="text-center">
        <h1 class="text-4xl font-bold text-white mb-4">
          Welcome to VideoStream
        </h1>
        <p class="text-xl text-gray-300 mb-8">
          Discover and share amazing videos
        </p>
        <a
          href="/upload"
          class="inline-flex items-center gap-2 px-6 py-3 bg-indigo-600
                 hover:bg-indigo-700 text-white rounded-lg font-medium
                 transition-colors shadow-lg"
        >
          <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2"
                  d="M7 16a4 4 0 01-.88-7.903A5 5 0 1115.9 6L16 6a5 5 0 011 9.9M15 13l-3-3m0 0l-3 3m3-3v12"/>
          </svg>
          Upload Your Video
        </a>
      </div>
    </div>
  </div>

  <!-- Content Section -->
  <div class="max-w-7xl mx-auto px-4 pb-12 sm:px-6 lg:px-8">
    {#if loading}
      <!-- Loading State -->
      <div class="flex flex-col items-center justify-center py-12">
        <div class="animate-spin rounded-full h-12 w-12 border-b-2 border-indigo-600"></div>
        <p class="mt-4 text-gray-300">Loading videos...</p>
      </div>
    {:else if error}
      <!-- Error State -->
      <div class="bg-red-900/50 border border-red-500 rounded-lg p-6 text-center">
        <p class="text-red-300 font-semibold">Error: {error}</p>
        <p class="text-red-400 mt-2">Make sure the backend is running on localhost:3000</p>
        <button
          on:click={fetchVideos}
          class="mt-4 px-4 py-2 bg-red-600 hover:bg-red-700
                 text-white rounded-lg transition-colors"
        >
          Try Again
        </button>
      </div>
    {:else if videos.length === 0}
      <!-- Empty State -->
      <div class="bg-gray-800 rounded-lg p-12 text-center">
        <svg class="mx-auto h-16 w-16 text-gray-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2"
                d="M15 10l4.553-2.276A1 1 0 0121 8.618v6.764a1 1 0 01-1.447.894L15 14M5 18h8a2 2 0 002-2V8a2 2 0 00-2-2H5a2 2 0 00-2 2v8a2 2 0 002 2z"/>
        </svg>
        <p class="text-white font-semibold mt-4 text-lg">No videos uploaded yet</p>
        <p class="text-gray-400 mt-2">Be the first to share a video!</p>
        <a
          href="/upload"
          class="inline-block mt-6 px-6 py-3 bg-indigo-600 hover:bg-indigo-700
                 text-white rounded-lg font-medium transition-colors"
        >
          Upload First Video
        </a>
      </div>
    {:else}
      <!-- Videos Section Header -->
      <div class="mb-6">
        <h2 class="text-2xl font-bold text-white">Latest Videos</h2>
        <p class="text-gray-400 mt-1">{videos.length} video{videos.length !== 1 ? 's' : ''} available</p>
      </div>

      <!-- Video Grid -->
      <div class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 xl:grid-cols-4 gap-6">
        {#each videos as video}
          <VideoCard {video} />
        {/each}
      </div>
    {/if}
  </div>
</div>