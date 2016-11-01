import nodeResolve from 'rollup-plugin-node-resolve';
import commonjs from 'rollup-plugin-commonjs';

export default {
  entry: 'web/components/app.js',
  dest: 'web/app-bundle.js',
  sourceMap: true,
  plugins: [
    nodeResolve(),
    commonjs()
  ]
};
