import { actions, hardhat, react } from '@wagmi/cli/plugins';
import { defineConfig } from '@wagmi/cli'
export default defineConfig({
  out: 'src/generated.ts',
  plugins: [
    hardhat({
      project: './hardhat',
    }),
    react(),
    actions(),
  ],
})