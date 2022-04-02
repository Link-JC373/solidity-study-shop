module.exports = {
  purge: [],
  darkMode: false, // or 'media' or 'class'
  theme: {
    extend: {
      screens: {
        'print': {'raw': 'print'},
        // => @media print { ... }
      }
    }
  },
  variants: {
    extend: {},
  },
  plugins: [],
}
