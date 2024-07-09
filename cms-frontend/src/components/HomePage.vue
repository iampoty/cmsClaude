<template>
  <div class="home">
    <h1>Latest Articles</h1>
    <div class="filter">
      <select v-model="selectedStatus" @change="fetchArticles">
        <option value="">All</option>
        <option value="0">Draft</option>
        <option value="1">Published</option>
        <option value="2">Archived</option>
      </select>
    </div>
    <div class="article-grid">
      <article-card v-for="article in articles" :key="article.id" :article="article" @click="openArticle(article.id)" />
    </div>
    <button v-if="hasMore" @click="loadMore">Load More</button>
  </div>
</template>

<script>
import axios from 'axios';
import ArticleCard from './ArticleCard.vue';

export default {
  name: 'HomePage',
  components: {
    ArticleCard,
  },
  data() {
    return {
      articles: [],
      page: 1,
      limit: 2,
      hasMore: true,
      selectedStatus: '',
    };
  },
  methods: {
    async fetchArticles() {
      try {
        const response = await axios.get('http://localhost:8000/api/articles', {
          params: {
            page: this.page,
            limit: this.limit,
            status: this.selectedStatus,
          },
        });
        if (this.page === 1) {
          this.articles = response.data;
        } else {
          this.articles = [...this.articles, ...response.data];
        }
        this.hasMore = response.data.length === this.limit;
      } catch (error) {
        console.error('Error fetching articles:', error);
      }
    },
    loadMore() {
      this.page += 1;
      this.fetchArticles();
    },
    openArticle(id) {
      this.$router.push(`/article/${id}`);
    },
    async pullRefresh() {
      this.page = 1;
      await this.fetchArticles();
    },
    // เพิ่มเมธอดนี้ใน methods
    setupPullRefresh() {
      let startY;
      const pullThreshold = 100;
      const container = document.querySelector('.home');

      container.addEventListener('touchstart', (e) => {
        startY = e.touches[0].pageY;
      });

      container.addEventListener('touchmove', (e) => {
        const currentY = e.touches[0].pageY;
        const pullDistance = currentY - startY;
        if (pullDistance > pullThreshold && window.scrollY === 0) {
          e.preventDefault();
          // แสดงตัวบ่งชี้การรีเฟรช
        }
      });

      container.addEventListener('touchend', (e) => {
        const endY = e.changedTouches[0].pageY;
        const pullDistance = endY - startY;
        if (pullDistance > pullThreshold && window.scrollY === 0) {
          this.pullRefresh();
        }
      });
    },

    removePullRefresh() {
      // ลบ event listeners ที่เพิ่มใน setupPullRefresh
    },
  },
  mounted() {
    this.fetchArticles();
    this.setupPullRefresh();
  },
  beforeUnmount() {
    this.removePullRefresh();
  },
};
</script>

<style scoped>
.home {
  max-width: 1200px;
  margin: 0 auto;
  padding: 20px;
}

.filter {
  margin-bottom: 20px;
}

.article-grid {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(300px, 1fr));
  gap: 20px;
}

@media (max-width: 768px) {
  .article-grid {
    grid-template-columns: 1fr;
  }
}

button {
  display: block;
  margin: 20px auto;
  padding: 10px 20px;
  background-color: #41b883;
  color: white;
  border: none;
  cursor: pointer;
}
</style>