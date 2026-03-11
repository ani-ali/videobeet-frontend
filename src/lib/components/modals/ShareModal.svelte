<script>
  export let showModal = false;
  export let videoInfo = {};

  let copySuccess = false;

  /**
   * Copies the current URL to clipboard
   */
  async function copyLink() {
    const url = window.location.href;
    try {
      await navigator.clipboard.writeText(url);
      copySuccess = true;
      setTimeout(() => copySuccess = false, 2000);
    } catch (err) {
      console.error('Failed to copy:', err);
    }
  }

  /**
   * Closes the share modal
   */
  function closeModal() {
    showModal = false;
    copySuccess = false;
  }

  /**
   * Generates Twitter share URL
   */
  function getTwitterShareUrl() {
    const text = encodeURIComponent(videoInfo?.title || 'Check out this video!');
    const url = encodeURIComponent(window.location.href);
    return `https://twitter.com/intent/tweet?url=${url}&text=${text}`;
  }

  /**
   * Generates WhatsApp share URL
   */
  function getWhatsAppShareUrl() {
    const text = encodeURIComponent(`${videoInfo?.title || 'Check out this video!'} ${window.location.href}`);
    return `https://wa.me/?text=${text}`;
  }
</script>

{#if showModal}
  <!-- Modal Backdrop -->
  <div
    class="fixed inset-0 bg-black/50 flex items-center justify-center z-50 p-4"
    on:click={closeModal}
  >
    <!-- Modal Content -->
    <div
      class="bg-gray-800 rounded-lg p-6 max-w-md w-full"
      on:click|stopPropagation
    >
      <!-- Modal Header -->
      <div class="flex items-center justify-between mb-4">
        <h2 class="text-xl font-bold text-white">Share Video</h2>
        <button
          on:click={closeModal}
          class="text-gray-400 hover:text-white transition-colors"
          aria-label="Close modal"
        >
          <svg class="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2"
                  d="M6 18L18 6M6 6l12 12"/>
          </svg>
        </button>
      </div>

      <div class="space-y-4">
        <!-- Copy Link Section -->
        <div>
          <label class="block text-sm font-medium text-gray-300 mb-2">
            Video Link
          </label>
          <div class="flex items-center gap-2">
            <input
              type="text"
              value={window.location.href}
              readonly
              class="flex-1 px-3 py-2 bg-gray-700 border border-gray-600
                     rounded-lg text-gray-200 text-sm"
            />
            <button
              on:click={copyLink}
              class="px-4 py-2 bg-indigo-600 hover:bg-indigo-700
                     text-white rounded-lg text-sm transition-colors"
            >
              {copySuccess ? 'Copied!' : 'Copy'}
            </button>
          </div>
        </div>

        <!-- Social Share Buttons -->
        <div>
          <label class="block text-sm font-medium text-gray-300 mb-2">
            Share on Social Media
          </label>
          <div class="flex gap-2">
            <!-- Twitter/X -->
            <a
              href={getTwitterShareUrl()}
              target="_blank"
              rel="noopener noreferrer"
              class="flex-1 px-4 py-2 bg-black hover:bg-gray-900
                     text-white rounded-lg text-center transition-colors
                     flex items-center justify-center gap-2"
            >
              <svg class="w-4 h-4" fill="currentColor" viewBox="0 0 24 24">
                <path d="M18.244 2.25h3.308l-7.227 8.26 8.502 11.24H16.17l-5.214-6.817L4.99 21.75H1.68l7.73-8.835L1.254 2.25H8.08l4.713 6.231zm-1.161 17.52h1.833L7.084 4.126H5.117z"/>
              </svg>
              X (Twitter)
            </a>

            <!-- WhatsApp -->
            <a
              href={getWhatsAppShareUrl()}
              target="_blank"
              rel="noopener noreferrer"
              class="flex-1 px-4 py-2 bg-green-600 hover:bg-green-700
                     text-white rounded-lg text-center transition-colors
                     flex items-center justify-center gap-2"
            >
              <svg class="w-4 h-4" fill="currentColor" viewBox="0 0 24 24">
                <path d="M17.472 14.382c-.297-.149-1.758-.867-2.03-.967-.273-.099-.471-.149-.67.15-.197.297-.767.966-.94 1.164-.173.199-.347.223-.644.075-.297-.15-1.255-.463-2.39-1.475-.883-.788-1.48-1.761-1.653-2.059-.173-.297-.018-.458.13-.606.134-.133.298-.347.446-.52.149-.174.198-.298.298-.497.099-.198.05-.371-.025-.52-.075-.149-.669-1.612-.916-2.207-.242-.579-.487-.5-.669-.51-.173-.008-.371-.01-.57-.01-.198 0-.52.074-.792.372-.272.297-1.04 1.016-1.04 2.479 0 1.462 1.065 2.875 1.213 3.074.149.198 2.096 3.2 5.077 4.487.709.306 1.262.489 1.694.625.712.227 1.36.195 1.871.118.571-.085 1.758-.719 2.006-1.413.248-.694.248-1.289.173-1.413-.074-.124-.272-.198-.57-.347m-5.421 7.403h-.004a9.87 9.87 0 01-5.031-1.378l-.361-.214-3.741.982.998-3.648-.235-.374a9.86 9.86 0 01-1.51-5.26c.001-5.45 4.436-9.884 9.888-9.884 2.64 0 5.122 1.03 6.988 2.898a9.825 9.825 0 012.893 6.994c-.003 5.45-4.437 9.884-9.885 9.884m8.413-18.297A11.815 11.815 0 0012.05 0C5.495 0 .16 5.335.157 11.892c0 2.096.547 4.142 1.588 5.945L.057 24l6.305-1.654a11.882 11.882 0 005.683 1.448h.005c6.554 0 11.89-5.335 11.893-11.893a11.821 11.821 0 00-3.48-8.413Z"/>
              </svg>
              WhatsApp
            </a>
          </div>
        </div>
      </div>
    </div>
  </div>
{/if}