<template>
  <div class="article-view" v-if="article">
    <h1>{{ article.title }}</h1>
    <img v-if="article.thumbnail" :src="article.thumbnail" :alt="article.title">
    <div class="meta">
      <span>{{ formatDate(article.createDate) }}</span>
      <span :class="['status', getStatusClass(article.status)]">{{ getStatusText(article.status) }}</span>
    </div>
    <div class="content" v-html="article.content"></div>
  </div>
</template>

<script>
import axios from 'axios';

export default {
  name: 'ArticleView',
  data() {
    return {
      article: null,
    };
  },
  methods: {
    async fetchArticle() {
      try {
        const response = await axios.get(`http://localhost:8000/api/articles/${this.$route.params.id}`);
        this.article = response.data;
      } catch (error) {
        console.error('Error fetching article:', error);
      }
    },
    formatDate(dateString) {
      return new Date(dateString).toLocaleDateString();
    },
    getStatusText(status) {
      const statusMap = {
        0: 'Draft',
        1: 'Published',
        2: 'Archived',
      };
      return statusMap[status] || 'Unknown';
    },
    getStatusClass(status) {
      const classMap = {
        0: 'draft',
        1: 'published',
        2: 'archived',
      };
      return classMap[status] || '';
    },
  },
  mounted() {
    this.fetchArticle();
  },
};
</script>

<style scoped>
.article-view {
  max-width: 800px;
  margin: 0 auto;
  padding: 20px;
}

img {
  max-width: 100%;
  height: auto;
  margin-bottom: 20px;
}

.meta {
  display: flex;
  justify-content: space-between;
  margin-bottom: 20px;
  font-size: 0.9em;
  color: #666;
}

.status {
  padding: 2px 6px;
  border-radius: 4px;
  font-weight: bold;
}

.draft { background-color: #ffd700; }
.published { background-color: #90ee90; }
.archived { background-color: #d3d3d3; }

.content {
  line-height: 1.6;
}
</style>