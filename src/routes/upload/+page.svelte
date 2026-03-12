<script>
  import { goto } from '$app/navigation';
  import { API_BASE_URL } from '$lib/config';

  let file = null;
  let title = '';
  let description = '';
  let uploading = false;
  let uploadProgress = 0;
  let uploadSuccess = false;
  let uploadError = null;
  let dragOver = false;
  let videoId = null;
  let processing = false;

  // File validation
  const acceptedFormats = ['.mp4', '.avi', '.mov', '.mkv'];
  const maxFileSize = 1024 * 1024 * 1024; // 1GB

  function handleDrop(e) {
    e.preventDefault();
    dragOver = false;

    const droppedFile = e.dataTransfer.files[0];
    if (droppedFile) {
      validateAndSetFile(droppedFile);
    }
  }

  function handleFileSelect(e) {
    const selectedFile = e.target.files[0];
    if (selectedFile) {
      validateAndSetFile(selectedFile);
    }
  }

  function validateAndSetFile(selectedFile) {
    uploadError = null;

    // Check file extension
    const fileName = selectedFile.name.toLowerCase();
    const hasValidExtension = acceptedFormats.some(format => fileName.endsWith(format));

    if (!hasValidExtension) {
      uploadError = `Invalid file format. Accepted formats: ${acceptedFormats.join(', ')}`;
      return;
    }

    // Check file size
    if (selectedFile.size > maxFileSize) {
      uploadError = `File too large. Maximum size: 1GB`;
      return;
    }

    file = selectedFile;

    // Auto-fill title from filename if empty
    if (!title) {
      const nameWithoutExt = selectedFile.name.replace(/\.[^/.]+$/, "");
      title = nameWithoutExt;
    }
  }

  function removeFile() {
    file = null;
    uploadError = null;
    uploadSuccess = false;
    videoId = null;
  }

  async function uploadVideo() {
    if (!file || !title.trim() || !description.trim()) {
      uploadError = 'Please fill in all required fields';
      return;
    }

    uploading = true;
    uploadError = null;
    uploadProgress = 0;

    const formData = new FormData();
    formData.append('file', file);
    formData.append('title', title.trim());
    if (description.trim()) {
      formData.append('description', description.trim());
    }

    try {
      // Create XMLHttpRequest for progress tracking
      const xhr = new XMLHttpRequest();

      // Track upload progress
      xhr.upload.addEventListener('progress', (e) => {
        if (e.lengthComputable) {
          uploadProgress = Math.round((e.loaded / e.total) * 100);
          // when upload completes, show processing state
          if (uploadProgress === 100) {
            processing = true;
          }
        }
      });

      // Handle completion
      xhr.addEventListener('load', () => {
        if (xhr.status === 200) {
          const response = xhr.responseText;
          // Extract video ID from response - updated regex pattern
          const match = response.match(/id:\s*([a-f0-9-]+)/);
          if (match) {
            videoId = match[1];
            uploadSuccess = true;
          } else {
            uploadSuccess = true;
          }
        } else {
          uploadError = 'Upload failed. Please try again.';
        }
        uploading = false;
        processing = false;
      });

      // Handle errors
      xhr.addEventListener('error', () => {
        uploadError = 'Network error. Please check your connection.';
        uploading = false;
        processing = false;
      });

      // Send request
      xhr.open('POST', `${API_BASE_URL}/api/upload`);
      xhr.send(formData);

    } catch (error) {
      uploadError = error.message;
      uploading = false;
    }
  }

  function formatFileSize(bytes) {
    if (bytes === 0) return '0 Bytes';
    const k = 1024;
    const sizes = ['Bytes', 'KB', 'MB', 'GB'];
    const i = Math.floor(Math.log(bytes) / Math.log(k));
    return Math.round(bytes / Math.pow(k, i) * 100) / 100 + ' ' + sizes[i];
  }

  function goToVideo() {
    if (videoId) {
      goto(`/video/${videoId}`);
    }
  }

  function goHome() {
    goto('/');
  }

  function resetForm() {
    removeFile();
    title = '';
    description = '';
  }
</script>

<div class="min-h-screen bg-gray-50">
  <div class="max-w-3xl mx-auto px-4 py-6 sm:py-12 sm:px-6 lg:px-8">
    <!-- Page Title -->
    <div class="mb-6 sm:mb-8 text-center">
      <h1 class="text-2xl sm:text-3xl font-bold text-gray-900">Upload Your Video</h1>
      <p class="text-gray-600 mt-2 text-sm sm:text-base">Share your content with the world</p>
    </div>
    {#if !uploadSuccess}
      <!-- Upload Form -->
      <div class="bg-white rounded-lg shadow-lg p-4 sm:p-6 md:p-8">
        <!-- Title Input -->
        <div class="mb-4 sm:mb-6">
          <label for="title" class="block text-sm font-medium text-gray-700 mb-2">
            Video Title <span class="text-red-500">*</span>
          </label>
          <input
            id="title"
            type="text"
            bind:value={title}
            placeholder="Enter video title"
            class="w-full px-3 sm:px-4 py-2 border border-gray-300 rounded-lg focus:ring-2
                   focus:ring-indigo-500 focus:border-indigo-500 transition-colors text-sm sm:text-base"
            disabled={uploading}
          />
        </div>

        <!-- Description Input -->
        <div class="mb-4 sm:mb-6">
          <label for="description" class="block text-sm font-medium text-gray-700 mb-2">
            Description <span class="text-red-500">*</span>
          </label>
          <textarea
            id="description"
            bind:value={description}
            placeholder="Enter video description"
            rows="3"
            class="w-full px-3 sm:px-4 py-2 border border-gray-300 rounded-lg focus:ring-2
                   focus:ring-indigo-500 focus:border-indigo-500 transition-colors resize-none text-sm sm:text-base"
            disabled={uploading}
          />
        </div>

        <!-- Drag and Drop Area -->
        <div class="mb-4 sm:mb-6">
          <label class="block text-sm font-medium text-gray-700 mb-2">
            Video File <span class="text-red-500">*</span>
          </label>
          <div
            class="border-2 border-dashed rounded-lg p-4 sm:p-6 md:p-8 text-center transition-colors
                   {dragOver ? 'border-indigo-500 bg-indigo-50' : 'border-gray-300 hover:border-gray-400'}"
            on:drop={handleDrop}
            on:dragover|preventDefault={() => dragOver = true}
            on:dragleave={() => dragOver = false}
          >
            {#if !file}
              <svg class="mx-auto h-10 sm:h-12 w-10 sm:w-12 text-gray-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2"
                      d="M7 16a4 4 0 01-.88-7.903A5 5 0 1115.9 6L16 6a5 5 0 011 9.9M15 13l-3-3m0 0l-3 3m3-3v12" />
              </svg>
              <p class="mt-2 sm:mt-3 text-sm sm:text-base text-gray-900 font-medium">
                Drop your video here, or
                <label for="file-upload" class="text-indigo-600 hover:text-indigo-500 cursor-pointer">
                  browse
                </label>
              </p>
              <p class="mt-1 text-xs sm:text-sm text-gray-600">
                MP4, AVI, MOV, MKV up to 1GB
              </p>
              <input
                id="file-upload"
                type="file"
                accept=".mp4,.avi,.mov,.mkv"
                on:change={handleFileSelect}
                class="hidden"
              />
            {:else}
              <!-- File Selected -->
              <div class="space-y-2 sm:space-y-3">
                <svg class="mx-auto h-10 sm:h-12 w-10 sm:w-12 text-green-500" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2"
                        d="M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z" />
                </svg>
                <div>
                  <p class="text-sm sm:text-base font-medium text-gray-900 break-all px-2">{file.name}</p>
                  <p class="text-xs sm:text-sm text-gray-600">{formatFileSize(file.size)}</p>
                </div>
                {#if !uploading}
                  <button
                    on:click={removeFile}
                    class="text-red-600 hover:text-red-500 text-sm font-medium"
                  >
                    Remove file
                  </button>
                {/if}
              </div>
            {/if}
          </div>
        </div>

        <!-- Error Message -->
        {#if uploadError}
          <div class="mb-4 sm:mb-6 bg-red-50 border border-red-200 rounded-lg p-3 sm:p-4">
            <p class="text-red-800 text-sm sm:text-base">{uploadError}</p>
          </div>
        {/if}

        <!-- Upload Progress -->
        {#if uploading}
          <div class="mb-4 sm:mb-6">
            {#if processing}
              <!-- Processing State -->
              <div class="text-center py-4">
                <div class="inline-flex items-center justify-center w-12 h-12 mb-3">
                  <div class="animate-spin rounded-full h-10 w-10 border-b-2 border-indigo-600"></div>
                </div>
                <p class="text-sm sm:text-base font-medium text-gray-700 mb-1">Processing your video...</p>
                <p class="text-xs sm:text-sm text-gray-500">
                  Converting video for optimal streaming. This may take a moment.
                </p>
              </div>
            {:else}
              <!-- Upload Progress Bar -->
              <div class="flex items-center justify-between text-xs sm:text-sm text-gray-600 mb-2">
                <span>Uploading video...</span>
                <span>{uploadProgress}%</span>
              </div>
              <div class="w-full bg-gray-200 rounded-full h-2 sm:h-3">
                <div
                  class="bg-indigo-600 h-2 sm:h-3 rounded-full transition-all duration-300"
                  style="width: {uploadProgress}%"
                ></div>
              </div>
              <p class="mt-2 text-xs text-gray-500">
                Please don't close this page. The video will be processed after upload.
              </p>
            {/if}
          </div>
        {/if}

        <!-- Upload Button -->
        {#if file && !uploading}
          <button
            on:click={uploadVideo}
            class="w-full bg-indigo-600 text-white py-2.5 sm:py-3 px-4 rounded-lg font-medium text-sm sm:text-base
                   hover:bg-indigo-700 transition-colors focus:outline-none focus:ring-2
                   focus:ring-offset-2 focus:ring-indigo-500 disabled:opacity-50 disabled:cursor-not-allowed"
            disabled={!title.trim() || !description.trim()}
          >
            Upload Video
          </button>
        {/if}
      </div>
    {:else}
      <!-- Success State -->
      <div class="bg-white rounded-lg shadow-lg p-6 sm:p-8 md:p-12 text-center">
        <!-- Success Animation -->
        <div class="mx-auto flex items-center justify-center h-16 w-16 sm:h-20 sm:w-20 rounded-full bg-green-100 animate-bounce">
          <svg class="h-10 w-10 sm:h-12 sm:w-12 text-green-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M5 13l4 4L19 7" />
          </svg>
        </div>

        <h2 class="mt-4 sm:mt-6 text-xl sm:text-2xl font-bold text-gray-900">Upload Successful!</h2>
        <p class="mt-2 text-sm sm:text-base text-gray-600 px-2">
          Your video <span class="font-semibold">"{title}"</span> is ready!
        </p>

        <!-- Action Buttons -->
        <div class="mt-6 sm:mt-8 space-y-3">
          {#if videoId}
            <!-- Primary Watch Button with Icon -->
            <button
              on:click={goToVideo}
              class="w-full bg-gradient-to-r from-indigo-600 to-purple-600 text-white py-3 sm:py-4 px-6 rounded-lg
                     font-semibold text-base sm:text-lg hover:from-indigo-700 hover:to-purple-700
                     transition-all transform hover:scale-[1.02] shadow-lg flex items-center justify-center gap-2"
            >
              <svg class="w-5 h-5 sm:w-6 sm:h-6" fill="currentColor" viewBox="0 0 20 20">
                <path d="M10 12a2 2 0 100-4 2 2 0 000 4z"/>
                <path fill-rule="evenodd" d="M.458 10C1.732 5.943 5.522 3 10 3s8.268 2.943 9.542 7c-1.274 4.057-5.064 7-9.542 7S1.732 14.057.458 10zM14 10a4 4 0 11-8 0 4 4 0 018 0z" clip-rule="evenodd"/>
              </svg>
              Watch Your Video Now
            </button>
          {:else}
            <!-- Fallback if no video ID -->
            <button
              on:click={goHome}
              class="w-full bg-gradient-to-r from-indigo-600 to-purple-600 text-white py-3 sm:py-4 px-6 rounded-lg
                     font-semibold text-base sm:text-lg hover:from-indigo-700 hover:to-purple-700
                     transition-all transform hover:scale-[1.02] shadow-lg"
            >
              Go to Videos
            </button>
          {/if}

          <!-- Secondary Button -->
          <button
            on:click={resetForm}
            class="w-full bg-gray-100 text-gray-700 py-2.5 sm:py-3 px-4 rounded-lg font-medium text-sm sm:text-base
                   hover:bg-gray-200 transition-colors border border-gray-300"
          >
            Upload Another Video
          </button>
        </div>

        <!-- Share Section -->
        {#if videoId}
          <div class="mt-6 sm:mt-8 p-3 sm:p-4 bg-gray-50 rounded-lg">
            <p class="text-xs sm:text-sm text-gray-600 mb-2">Share this link:</p>
            <div class="flex flex-col sm:flex-row items-stretch sm:items-center gap-2">
              <input
                type="text"
                value="http://localhost:5173/video/{videoId}"
                readonly
                class="flex-1 px-2 sm:px-3 py-2 border border-gray-300 rounded-lg text-xs sm:text-sm bg-white"
              />
              <button
                on:click={() => navigator.clipboard.writeText(`http://localhost:5173/video/${videoId}`)}
                class="px-3 sm:px-4 py-2 bg-gray-700 text-white rounded-lg text-xs sm:text-sm hover:bg-gray-800 transition-colors
                       flex items-center justify-center gap-1"
              >
                <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M8 16H6a2 2 0 01-2-2V6a2 2 0 012-2h8a2 2 0 012 2v2m-6 12h8a2 2 0 002-2v-8a2 2 0 00-2-2h-8a2 2 0 00-2 2v8a2 2 0 002 2z"/>
                </svg>
                Copy Link
              </button>
            </div>
          </div>
        {/if}
      </div>
    {/if}

    <!-- Info Section - Clean shadcn style -->
    <div class="mt-8 space-y-4">
      <!-- Guidelines Card -->
      <div class="border rounded-lg p-6 bg-white">
        <h3 class="text-sm font-medium text-gray-900 mb-4">Upload Guidelines</h3>
        <div class="space-y-3 text-sm text-gray-600">
          <div class="flex justify-between">
            <span>Maximum file size</span>
            <span class="font-medium text-gray-900">1GB</span>
          </div>
          <div class="flex justify-between">
            <span>Accepted formats</span>
            <span class="font-medium text-gray-900">MP4, AVI, MOV, MKV</span>
          </div>
          <div class="flex justify-between">
            <span>Video processing</span>
            <span class="font-medium text-gray-900">HLS adaptive streaming</span>
          </div>
          <div class="flex justify-between">
            <span>Thumbnail generation</span>
            <span class="font-medium text-gray-900">Automatic</span>
          </div>
        </div>
      </div>

      <!-- Tips Card -->
      <div class="border rounded-lg p-6 bg-slate-50">
        <h3 class="text-sm font-medium text-gray-900 mb-4">Tips for best results</h3>
        <ul class="space-y-2 text-sm text-gray-600">
          <li>Use descriptive titles and descriptions for better discoverability</li>
          <li>MP4 format provides the best compatibility across all devices</li>
          <li>Videos under 500MB will upload and process faster</li>
          <li>Higher resolution videos provide better viewing experience</li>
        </ul>
      </div>
    </div>
  </div>
</div>