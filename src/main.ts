import { createApp } from 'vue'
import App from './App'
import router from './router'
import store from './store'
import Antd from 'ant-design-vue';
import "tailwindcss/tailwind.css"
import 'ant-design-vue/dist/antd.css';
import './utils/web3Provider'

createApp(App).use(store).use(Antd).use(router).mount('#app')
