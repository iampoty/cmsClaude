<template>
    <div class="article-card" @click="$emit('click')">
      <img v-if="article.thumbnail" :src="article.thumbnail" :alt="article.title">
      <div class="content">
        <h2>{{ article.title }}</h2>
        <p>{{ article.content.substring(0, 100) }}...</p>
        <div class="meta">
          <span>{{ formatDate(article.createDate) }}</span>
          <span :class="['status', getStatusClass(article.status)]">{{ getStatusText(article.status) }}</span>
        </div>
      </div>
    </div>
  </template>
  
  <script>
  export default {
    name: 'ArticleCard',
    props: {
      article: {
        type: Object,
        required: true,
      },
    },
    methods: {
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
  };
  </script>
  
  <style scoped>
  .article-card {
    background-color: #fff;
    border-radius: 8px;
    box-shadow: 0 2px 4px rgba(0, 0, 0, 0.1);
    overflow: hidden;
    cursor: pointer;
    transition: transform 0.3s ease;
  }
  
  .article-card:hover {
    transform: translateY(-5px);
  }
  
  .article-card img {
    width: 100%;
    height: 200px;
    object-fit: cover;
  }
  
  .content {
    padding: 15px;
  }
  
  h2 {
    margin-top: 0;
    font-size: 1.2em;
  }
  
  .meta {
    display: flex;
    justify-content: space-between;
    margin-top: 10px;
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
  </style>