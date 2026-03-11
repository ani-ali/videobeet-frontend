<script>
  import { goto } from '$app/navigation';

  let file = null;
  let title = '';
  let description = '';
  let uploading = false;
  let uploadProgress = 0;
  let uploadSuccess = false;
  let uploadError = null;
  let dragOver = false;
  let videoId = null;

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
    if (!file || !title.trim()) {
      uploadError = 'Please select a file and provide a title';
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
        }
      });

      // Handle completion
      xhr.addEventListener('load', () => {
        if (xhr.status === 200) {
          const response = xhr.responseText;
          // Extract video ID from response
          const match = response.match(/Video ID: ([a-f0-9-]+)/);
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
      });

      // Handle errors
      xhr.addEventListener('error', () => {
        uploadError = 'Network error. Please check your connection.';
        uploading = false;
      });

      // Send request
      xhr.open('POST', 'http://localhost:3000/home/main/video');
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
  <div class="max-w-3xl mx-auto px-4 py-12 sm:px-6 lg:px-8">
    <!-- Page Title -->
    <div class="mb-8 text-center">
      <h1 class="text-3xl font-bold text-gray-900">Upload Your Video</h1>
      <p class="text-gray-600 mt-2">Share your content with the world</p>
    </div>
    {#if !uploadSuccess}
      <!-- Upload Form -->
      <div class="bg-white rounded-lg shadow-lg p-8">
        <!-- Title Input -->
        <div class="mb-6">
          <label for="title" class="block text-sm font-medium text-gray-700 mb-2">
            Video Title <span class="text-red-500">*</span>
          </label>
          <input
            id="title"
            type="text"
            bind:value={title}
            placeholder="Enter video title"
            class="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2
                   focus:ring-indigo-500 focus:border-indigo-500 transition-colors"
            disabled={uploading}
          />
        </div>

        <!-- Description Input -->
        <div class="mb-6">
          <label for="description" class="block text-sm font-medium text-gray-700 mb-2">
            Description (Optional)
          </label>
          <textarea
            id="description"
            bind:value={description}
            placeholder="Enter video description"
            rows="4"
            class="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2
                   focus:ring-indigo-500 focus:border-indigo-500 transition-colors resize-none"
            disabled={uploading}
          />
        </div>

        <!-- Drag and Drop Area -->
        <div class="mb-6">
          <label class="block text-sm font-medium text-gray-700 mb-2">
            Video File <span class="text-red-500">*</span>
          </label>
          <div
            class="border-2 border-dashed rounded-lg p-8 text-center transition-colors
                   {dragOver ? 'border-indigo-500 bg-indigo-50' : 'border-gray-300 hover:border-gray-400'}"
            on:drop={handleDrop}
            on:dragover|preventDefault={() => dragOver = true}
            on:dragleave={() => dragOver = false}
          >
            {#if !file}
              <svg class="mx-auto h-12 w-12 text-gray-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2"
                      d="M7 16a4 4 0 01-.88-7.903A5 5 0 1115.9 6L16 6a5 5 0 011 9.9M15 13l-3-3m0 0l-3 3m3-3v12" />
              </svg>
              <p class="mt-3 text-base text-gray-900 font-medium">
                Drop your video here, or
                <label for="file-upload" class="text-indigo-600 hover:text-indigo-500 cursor-pointer">
                  browse
                </label>
              </p>
              <p class="mt-1 text-sm text-gray-600">
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
              <div class="space-y-3">
                <svg class="mx-auto h-12 w-12 text-green-500" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2"
                        d="M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z" />
                </svg>
                <div>
                  <p class="text-base font-medium text-gray-900">{file.name}</p>
                  <p class="text-sm text-gray-600">{formatFileSize(file.size)}</p>
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
          <div class="mb-6 bg-red-50 border border-red-200 rounded-lg p-4">
            <p class="text-red-800">{uploadError}</p>
          </div>
        {/if}

        <!-- Upload Progress -->
        {#if uploading}
          <div class="mb-6">
            <div class="flex items-center justify-between text-sm text-gray-600 mb-2">
              <span>Uploading and processing...</span>
              <span>{uploadProgress}%</span>
            </div>
            <div class="w-full bg-gray-200 rounded-full h-3">
              <div
                class="bg-indigo-600 h-3 rounded-full transition-all duration-300"
                style="width: {uploadProgress}%"
              ></div>
            </div>
            <p class="mt-2 text-xs text-gray-500">
              Please don't close this page. The video will be processed after upload.
            </p>
          </div>
        {/if}

        <!-- Upload Button -->
        {#if file && !uploading}
          <button
            on:click={uploadVideo}
            class="w-full bg-indigo-600 text-white py-3 px-4 rounded-lg font-medium
                   hover:bg-indigo-700 transition-colors focus:outline-none focus:ring-2
                   focus:ring-offset-2 focus:ring-indigo-500 disabled:opacity-50 disabled:cursor-not-allowed"
            disabled={!title.trim()}
          >
            Upload Video
          </button>
        {/if}
      </div>
    {:else}
      <!-- Success State -->
      <div class="bg-white rounded-lg shadow-lg p-12 text-center">
        <div class="mx-auto flex items-center justify-center h-20 w-20 rounded-full bg-green-100">
          <svg class="h-12 w-12 text-green-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M5 13l4 4L19 7" />
          </svg>
        </div>
        <h2 class="mt-6 text-2xl font-bold text-gray-900">Upload Successful!</h2>
        <p class="mt-2 text-gray-600">Your video "{title}" has been processed and is ready to watch.</p>

        {#if videoId}
          <div class="mt-6 space-y-3">
            <button
              on:click={goToVideo}
              class="w-full bg-indigo-600 text-white py-3 px-4 rounded-lg font-medium
                     hover:bg-indigo-700 transition-colors"
            >
              Watch Video
            </button>
            <button
              on:click={resetForm}
              class="w-full bg-gray-200 text-gray-700 py-3 px-4 rounded-lg font-medium
                     hover:bg-gray-300 transition-colors"
            >
              Upload Another Video
            </button>
          </div>

          <!-- Share Link -->
          <div class="mt-8 p-4 bg-gray-50 rounded-lg">
            <p class="text-sm text-gray-600 mb-2">Share this link:</p>
            <div class="flex items-center gap-2">
              <input
                type="text"
                value="http://localhost:5173/video/{videoId}"
                readonly
                class="flex-1 px-3 py-2 border border-gray-300 rounded-lg text-sm bg-white"
              />
              <button
                on:click={() => navigator.clipboard.writeText(`http://localhost:5173/video/${videoId}`)}
                class="px-4 py-2 bg-gray-700 text-white rounded-lg text-sm hover:bg-gray-800 transition-colors"
              >
                Copy
              </button>
            </div>
          </div>
        {/if}
      </div>
    {/if}

    <!-- Info Section -->
    <div class="mt-8 bg-blue-50 border border-blue-200 rounded-lg p-6">
      <h3 class="text-lg font-semibold text-blue-900 mb-2">ℹ️ Video Processing Info</h3>
      <ul class="space-y-1 text-sm text-blue-800">
        <li>• Your video will be converted to HLS format for adaptive streaming</li>
        <li>• A thumbnail will be automatically generated from your video</li>
        <li>• Processing time depends on video size and duration</li>
        <li>• Maximum file size: 1GB</li>
        <li>• Supported formats: MP4, AVI, MOV, MKV</li>
      </ul>
    </div>
  </div>
</div>