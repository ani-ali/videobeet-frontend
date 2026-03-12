<script>
  import { page } from '$app/stores';
  import logo from '$lib/assets/favicon.svg';
</script>

<header class="bg-white border-b border-gray-200 shadow-sm sticky top-0 z-40">
  <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
    <div class="flex items-center justify-between h-16">
      <!-- Logo/Brand -->
      <a href="/" class="flex items-center gap-3">
        <img src={logo} alt="VideoBeet" class="w-8 h-10" />
        <span class="text-gray-900 text-xl font-bold">VideoBeet</span>
      </a>

      <!-- Navigation -->
      <nav class="flex items-center gap-8">
        <a
          href="/"
          class="text-gray-700 hover:text-blue-600 transition-colors font-medium
                 {$page.url.pathname === '/' ? 'text-blue-600 border-b-2 border-blue-600' : ''}"
        >
          Videos
        </a>
        <a
          href="/upload"
          class="text-gray-700 hover:text-blue-600 transition-colors font-medium
                 {$page.url.pathname === '/upload' ? 'text-blue-600 border-b-2 border-blue-600' : ''}"
        >
          Upload
        </a>
      </nav>
    </div>
  </div>
</header>