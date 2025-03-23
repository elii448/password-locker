import { defineConfig } from 'vite';
import laravel from 'laravel-vite-plugin';
import tailwindcss from '@tailwindcss/vite';

export default defineConfig({
    plugins: [
        laravel({
            input: ['resources/css/app.css', 'resources/js/app.js'],
            content: [
                "./vendor/vormkracht10/filament-2fa/resources/**.*.blade.php",
            ],
            refresh: true,
        }),
        tailwindcss(),
    ],
});
