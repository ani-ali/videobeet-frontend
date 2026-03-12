<script>
  import { onMount } from 'svelte';
  import VideoControls from './VideoControls.svelte';
  import { API_BASE_URL } from '$lib/config';

  export let videoInfo = {};

  // Video player elements and state
  let videoElement = null;
  let hls = null;
  let isPlaying = false;
  let currentTime = 0;
  let duration = 0;
  let bufferedPercent = 0;
  let volume = 1;
  let isMuted = false;
  let isBuffering = false;

  onMount(() => {
    if (videoInfo.status === 'ready') {
      setTimeout(initPlayer, 100);
    }

    return () => {
      if (hls) {
        hls.destroy();
      }
    };
  });

  /**
   * Initialize HLS player
   */
  function initPlayer() {
    if (!videoElement || !window.Hls) return;

    const videoUrl = `${API_BASE_URL}${videoInfo.playlist_url}`;

    if (window.Hls.isSupported()) {
      hls = new window.Hls();
      hls.loadSource(videoUrl);
      hls.attachMedia(videoElement);

      hls.on(window.Hls.Events.MANIFEST_PARSED, () => {
        duration = videoElement.duration;
      });

      // Add event listeners
      videoElement.addEventListener('progress', updateBuffer);
      videoElement.addEventListener('timeupdate', updateTime);
      videoElement.addEventListener('loadedmetadata', () => {
        duration = videoElement.duration;
      });

      // Buffering state events
      videoElement.addEventListener('waiting', () => {
        isBuffering = true;
      });
      videoElement.addEventListener('playing', () => {
        isBuffering = false;
      });
      videoElement.addEventListener('canplay', () => {
        isBuffering = false;
      });
    }
  }

  /**
   * Update buffer progress
   */
  function updateBuffer() {
    if (videoElement && videoElement.buffered.length > 0) {
      const bufferedEnd = videoElement.buffered.end(videoElement.buffered.length - 1);
      bufferedPercent = (bufferedEnd / duration) * 100;
    }
  }

  /**
   * Update current time
   */
  function updateTime() {
    if (videoElement) {
      currentTime = videoElement.currentTime;
    }
  }

  /**
   * Play/Pause toggle
   */
  function togglePlay() {
    if (!videoElement) return;

    if (isPlaying) {
      videoElement.pause();
    } else {
      videoElement.play();
    }
    isPlaying = !isPlaying;
  }

  /**
   * Seek to position
   */
  function handleSeek(e) {
    const seekTime = e.detail;
    if (videoElement) {
      videoElement.currentTime = seekTime;
      currentTime = seekTime;
    }
  }

  /**
   * Volume control
   */
  function handleVolumeChange(e) {
    volume = e.detail;
    if (videoElement) {
      videoElement.volume = volume;
      isMuted = volume === 0;
    }
  }

  /**
   * Toggle mute
   */
  function toggleMute() {
    if (videoElement) {
      isMuted = !isMuted;
      videoElement.muted = isMuted;
    }
  }

  /**
   * Toggle fullscreen
   */
  function toggleFullscreen() {
    if (videoElement) {
      if (!document.fullscreenElement) {
        videoElement.requestFullscreen();
      } else {
        document.exitFullscreen();
      }
    }
  }
</script>

<!-- Video Player Container -->
<div class="relative bg-black rounded-lg overflow-hidden shadow-2xl">
  <!-- Video element -->
  <video
    bind:this={videoElement}
    class="w-full aspect-video cursor-pointer"
    on:click={togglePlay}
  />

  <!-- Custom Controls -->
  <VideoControls
    {isPlaying}
    {currentTime}
    {duration}
    {bufferedPercent}
    {volume}
    {isMuted}
    on:play={togglePlay}
    on:seek={handleSeek}
    on:volumeChange={handleVolumeChange}
    on:mute={toggleMute}
    on:fullscreen={toggleFullscreen}
  />

  <!-- Buffering/Loading Indicator -->
  {#if isBuffering}
    <div class="absolute inset-0 flex items-center justify-center bg-black/30 pointer-events-none">
      <div class="bg-black/70 rounded-full p-4">
        <div class="animate-spin rounded-full h-12 w-12 border-b-2 border-white"></div>
      </div>
    </div>
  {/if}

  <!-- Buffer Progress Indicator (shown when buffer is low) -->
  {#if !isBuffering && bufferedPercent < 100 && ((bufferedPercent / 100 * duration) - currentTime) < 5}
    <div class="absolute top-4 right-4 bg-black/70 text-white px-3 py-1 rounded-lg text-sm">
      Buffering: {Math.round(bufferedPercent)}%
    </div>
  {/if}
</div>