import { createRouter, createWebHistory } from 'vue-router'
import HomeCMS from '../components/HelloWorld.vue'
import LogsView from '../components/LogsView.vue'
import HomePage from '../components/HomePage.vue'
import ArticleView1 from '../components/ArticleView1.vue'
// import Home from '../components/Home.vue'
import ArticleView from '../components/ArticleView.vue'

const routes = [
  {
    path: '/',
    name: 'HomePage',
    component: HomePage
  },
  {
    path: '/article/:id',
    name: 'ArticleView',
    component: ArticleView
  },
  {
    path: '/cms',
    name: 'HomeCMS',
    component: HomeCMS
  },
  {
    path: '/logs',
    name: 'Logs',
    component: LogsView
  },
  {
    path: '/cms/:articleid',
    name: 'ArticleView1',
    component: ArticleView1
  }
]

const router = createRouter({
  history: createWebHistory(process.env.BASE_URL),
  routes
})

export default router