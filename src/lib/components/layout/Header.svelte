<script>
  import { page } from '$app/stores';
</script>

<header class="bg-gradient-to-r from-indigo-600 to-purple-600 shadow-lg sticky top-0 z-40">
  <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
    <div class="flex items-center justify-between h-16">
      <!-- Logo/Brand -->
      <a href="/" class="flex items-center gap-2">
        <svg class="w-8 h-8 text-white" fill="currentColor" viewBox="0 0 20 20">
          <path d="M2 6a2 2 0 012-2h6a2 2 0 012 2v8a2 2 0 01-2 2H4a2 2 0 01-2-2V6zM14.553 7.106A1 1 0 0014 8v4a1 1 0 00.553.894l2 1A1 1 0 0018 13V7a1 1 0 00-1.447-.894l-2 1z"/>
        </svg>
        <span class="text-white text-xl font-bold">VideoStream</span>
      </a>

      <!-- Navigation -->
      <nav class="flex items-center gap-6">
        <a
          href="/"
          class="text-white/90 hover:text-white transition-colors font-medium
                 {$page.url.pathname === '/' ? 'text-white border-b-2 border-white/50' : ''}"
        >
          Home
        </a>
        <a
          href="/upload"
          class="text-white/90 hover:text-white transition-colors font-medium
                 {$page.url.pathname === '/upload' ? 'text-white border-b-2 border-white/50' : ''}"
        >
          Upload
        </a>
      </nav>

      <!-- Upload Button -->
      <a
        href="/upload"
        class="flex items-center gap-2 px-4 py-2 bg-white/20 hover:bg-white/30
               backdrop-blur-sm text-white rounded-lg transition-colors"
      >
        <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2"
                d="M7 16a4 4 0 01-.88-7.903A5 5 0 1115.9 6L16 6a5 5 0 011 9.9M15 13l-3-3m0 0l-3 3m3-3v12"/>
        </svg>
        Upload Video
      </a>
    </div>
  </div>
</header>