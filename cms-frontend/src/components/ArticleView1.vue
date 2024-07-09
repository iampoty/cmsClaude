<!-- src/components/ArticleView.vue -->
<template>
    <div class="article-view">
      <h1>{{ article.title }}</h1>
      <p><strong>Author:</strong> {{ article.author }}</p>
      <p><strong>Created:</strong> {{ formatDate(article.createDate) }}</p>
      <p><strong>Last Updated:</strong> {{ formatDate(article.lastUpdate) }}</p>
      <p><strong>Status:</strong> {{ getStatusText(article.status) }}</p>
      <div class="content">
        {{ article.content }}
      </div>
      <router-link to="/cms">Back to Articles</router-link>
    </div>
  </template>
  
  <script>
  import axios from 'axios';
  
  export default {
    name: 'ArticleView',
    data() {
      return {
        article: {}
      };
    },
    methods: {
      fetchArticle() {
        const articleId = this.$route.params.articleid;
        axios.get(`http://localhost:8000/api/articles/${articleId}`, {
          headers: { Authorization: localStorage.getItem('token') }
        })
          .then(response => {
            this.article = response.data;
          })
          .catch(error => {
            console.error("There was an error fetching the article!", error);
          });
      },
      formatDate(dateString) {
        return new Date(dateString).toLocaleString();
      },
      getStatusText(status) {
        switch(parseInt(status)) {
          case 0: return 'Draft';
          case 1: return 'Published';
          case 2: return 'Archived';
          default: return 'Unknown';
        }
      }
    },
    mounted() {
      this.fetchArticle();
    }
  };
  </script>
  
  <style scoped>
  .article-view {
    max-width: 800px;
    margin: 0 auto;
    padding: 20px;
  }
  .content {
    margin-top: 20px;
    margin-bottom: 20px;
    white-space: pre-wrap;
  }
  </style>