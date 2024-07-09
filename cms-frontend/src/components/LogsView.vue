<!-- src/components/LogsView.vue -->
<template>
    <div class="logs-view">
      <h2>System Logs</h2>
      <table>
        <thead>
          <tr>
            <th>Action</th>
            <th>Username</th>
            <th>Timestamp</th>
            <th>Details</th>
          </tr>
        </thead>
        <tbody>
          <tr v-for="log in logs" :key="log.id">
            <td>{{ log.action }}</td>
            <td>{{ log.username }}</td>
            <td>{{ formatDate(log.timestamp) }}</td>
            <td>{{ log.details }}</td>
          </tr>
        </tbody>
      </table>
    </div>
  </template>
  
  <script>
  import axios from 'axios';
  
  export default {
    name: 'LogsView',
    data() {
      return {
        logs: []
      };
    },
    methods: {
      fetchLogs() {
        axios.get('http://localhost:8000/api/logs', {
          headers: { Authorization: localStorage.getItem('token') }
        })
          .then(response => {
            this.logs = response.data;
          })
          .catch(error => {
            console.error("There was an error fetching the logs!", error);
          });
      },
      formatDate(dateString) {
        return new Date(dateString).toLocaleString();
      }
    },
    mounted() {
      this.fetchLogs();
    }
  };
  </script>
  
  <style scoped>
  .logs-view {
    padding: 20px;
  }
  
  table {
    width: 100%;
    border-collapse: collapse;
  }
  
  th, td {
    border: 1px solid #ddd;
    padding: 8px;
    text-align: left;
  }
  
  th {
    background-color: #f2f2f2;
  }
  </style>