import { createApp } from 'vue'
import App from './App.vue'
import router from './router'
// import Home from './views/Home.vue'
// import ArticleView from './views/ArticleView.vue'

createApp(App).mount('#app')
createApp(App).use(router).mount('#app')