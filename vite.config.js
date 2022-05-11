import { defineConfig } from "vite";
import coffee from "vite-plugin-coffee";

export default defineConfig({
  plugins: [
    coffee({
      jsx: false,
    }),
  ],
});
