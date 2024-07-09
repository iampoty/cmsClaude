<template>
  <div>
    <div class="topbar">
      <h1>CMS System</h1>
      <div v-if="!isLoggedIn">
        <input v-model="loginInfo.username" placeholder="Username" />
        <input v-model="loginInfo.password" type="password" placeholder="Password" />
        <button @click="login">Login</button>
      </div>
      <div v-else>
        Welcome, {{ username }}!
        <button @click="logout">Logout</button>
      </div>
    </div>
    <div class="container" v-if="isLoggedIn">
      <h2>Article List</h2>
      <table>
        <thead>
          <tr>
            <th>Thumbnail</th>
            <th>Title</th>
            <th>Content</th>
            <th>Author</th>
            <th>Created</th>
            <th>Last Updated</th>
            <th>Status</th>
            <th>Actions</th>
          </tr>
        </thead>
        <tbody>
          <tr v-for="article in articles" :key="article.id">
            <td data-label="Thumbnail">
        <img v-if="article.thumbnail" :src="article.thumbnail" alt="Thumbnail" style="max-width: 100px; max-height: 100px;" />
      </td>
            <td data-label="Title">
              <router-link :to="'/cms/' + article.id">{{ article.title }}</router-link>
            </td>
            <td data-label="Content">{{ article.content.substring(0, 50) }}...</td>
            <td data-label="Author">{{ article.author }}</td>
            <td data-label="Created">{{ formatDate(article.createDate) }}</td>
            <td data-label="Last Updated">{{ formatDate(article.lastUpdate) }}</td>
            <td data-label="Status">{{ getStatusText(article.status) }}</td>
            <td data-label="Actions">
              <button @click="editArticle(article)">Edit</button>
              <button @click="deleteArticle(article.id)">Delete</button>
            </td>
          </tr>
        </tbody>
      </table>

      <h2>{{ isEditing ? 'Edit' : 'Create' }} Article</h2>
      <form @submit.prevent="submitArticle">
  <input v-model="currentArticle.title" placeholder="Title" required />
  <textarea v-model="currentArticle.content" placeholder="Content" required></textarea>
  <input v-model="currentArticle.thumbnail" placeholder="Thumbnail URL" />
  <select v-model="currentArticle.status">
    <option value="0">Draft</option>
    <option value="1">Published</option>
    <option value="2">Archived</option>
  </select>
  <button type="submit">{{ isEditing ? 'Update' : 'Create' }}</button>
  <button v-if="isEditing" @click="cancelEdit">Cancel</button>
</form>

      <div v-if="isAdmin">
        <h2>Create User</h2>
        <form @submit.prevent="createUser">
          <input v-model="newUser.username" placeholder="Username" required />
          <input v-model="newUser.password" type="password" placeholder="Password" required />
          <input v-model="newUser.firstName" placeholder="First Name" required />
          <input v-model="newUser.lastName" placeholder="Last Name" required />
          <select v-model="newUser.role">
            <option value="user">User</option>
            <option value="admin">Admin</option>
          </select>
          <button type="submit">Create User</button>
        </form>
      </div>
    </div>

    <div v-if="isAdmin">
      <h2>Admin Actions</h2>
      <router-link to="/logs">View Logs</router-link>
    </div>
  </div>
</template>

<script>
import axios from 'axios';

export default {
  name: 'HelloWorld',
  data() {
    return {
      articles: [],
      currentArticle: {
        title: '',
        content: '',
        thumbnail: '',
        status: 0,
      },
      isEditing: false,
      isLoggedIn: false,
      username: '',
      isAdmin: false,
      loginInfo: {
        username: localStorage.getItem('username') || '',
        password: ''
      },
      newUser: {
        username: '',
        password: '',
        firstName: '',
        lastName: '',
        role: 'user'
      }
    };
  },
  methods: {
    fetchArticles() {
      axios.get('http://localhost:8000/api/articles', {
        headers: { Authorization: localStorage.getItem('token') }
      })
        .then(response => {
          this.articles = response.data;
        })
        .catch(error => {
          console.error("There was an error fetching the articles!", error);
        });
    },
    submitArticle() {
      if (this.isEditing) {
        this.updateArticle();
      } else {
        this.createArticle();
      }
    },
    createArticle() {
      axios.post('http://localhost:8000/api/articles', this.currentArticle, {
        headers: { Authorization: localStorage.getItem('token') }
      })
        .then(() => {
          this.fetchArticles();
          this.resetForm();
        })
        .catch(error => {
          console.error("There was an error creating the article!", error);
        });
    },
    updateArticle() {
      axios.put(`http://localhost:8000/api/articles/${this.currentArticle.id}`, this.currentArticle, {
        headers: { Authorization: localStorage.getItem('token') }
      })
        .then(() => {
          this.fetchArticles();
          this.resetForm();
        })
        .catch(error => {
          console.error("There was an error updating the article!", error);
        });
    },
    deleteArticle(id) {
      if (confirm('Are you sure you want to delete this article?')) {
        axios.delete(`http://localhost:8000/api/articles/${id}`, {
          headers: { Authorization: localStorage.getItem('token') }
        })
          .then(() => {
            this.fetchArticles();
          })
          .catch(error => {
            console.error("There was an error deleting the article!", error);
          });
      }
    },
    editArticle(article) {
      this.currentArticle = { ...article };
      this.isEditing = true;
    },
    cancelEdit() {
      this.resetForm();
    },
    resetForm() {
      this.currentArticle = {
        title: '',
        content: '',
        thumbnail: '',
        status: 0
      };
      this.isEditing = false;
    },
    formatDate(dateString) {
      return new Date(dateString).toLocaleString();
    },
    getStatusText(status) {
      switch (parseInt(status)) {
        case 0: return 'Draft';
        case 1: return 'Published';
        case 2: return 'Archived';
        default: return 'Unknown';
      }
    },
    login() {
      axios.post('http://localhost:8000/api/login', this.loginInfo)
        .then(response => {
          localStorage.setItem('token', response.data.token);
          localStorage.setItem('username', this.loginInfo.username);
          this.isLoggedIn = true;
          this.username = this.loginInfo.username;
          this.isAdmin = this.checkIfAdmin(response.data.token);
          this.fetchArticles();
        })
        .catch(error => {
          console.error("Login failed", error);
        });
    },
    logout() {
      localStorage.removeItem('token');
      localStorage.removeItem('username');
      this.isLoggedIn = false;
      this.username = '';
      this.isAdmin = false;
      this.loginInfo.username = '';
      this.loginInfo.password = '';
    },
    createUser() {
      axios.post('http://localhost:8000/api/users', this.newUser, {
        headers: { Authorization: localStorage.getItem('token') }
      })
        .then(() => {
          alert('User created successfully');
          this.newUser = {
            username: '',
            password: '',
            firstName: '',
            lastName: '',
            role: 'user'
          };
        })
        .catch(error => {
          console.error("Error creating user", error);
        });
    },
    checkIfAdmin(token) {
      const payload = JSON.parse(atob(token.split('.')[1]));
      return payload.role === 'admin';
    }
  },
  mounted() {
    const token = localStorage.getItem('token');
    const username = localStorage.getItem('username');
    if (token) {
      this.isLoggedIn = true;
      this.username = username;
      this.loginInfo.username = username;
      this.isAdmin = this.checkIfAdmin(token);
      this.fetchArticles();
    }
  },
  beforeUnmount() {
    // ถ้าคุณต้องการล้างข้อมูลเมื่อออกจากหน้า
    // localStorage.removeItem('token');
    // localStorage.removeItem('username');
  },
};
</script>

<style scoped>
.topbar {
  background-color: #35495e;
  color: white;
  padding: 10px 20px;
  text-align: left;
}

.topbar h1 {
  margin: 0;
  font-size: 1.5em;
}

.container {
  padding: 20px;
  max-width: 1200px;
  margin: 0 auto;
}

h2 {
  margin-top: 20px;
  font-size: 1.3em;
}

table {
  width: 100%;
  border-collapse: collapse;
  margin-bottom: 20px;
}

th,
td {
  border: 1px solid #ddd;
  padding: 8px;
  text-align: left;
}

th {
  background-color: #f2f2f2;
  font-weight: bold;
}

tr:nth-child(even) {
  background-color: #f9f9f9;
}

input,
textarea,
select {
  display: block;
  margin-bottom: 10px;
  width: 100%;
  padding: 10px;
  font-size: 16px;
  box-sizing: border-box;
}

button {
  padding: 10px 20px;
  font-size: 16px;
  background-color: #41b883;
  color: white;
  border: none;
  cursor: pointer;
  margin-right: 10px;
  margin-bottom: 10px;
}

button:hover {
  background-color: #35495e;
}

.modal {
  position: fixed;
  z-index: 1;
  left: 0;
  top: 0;
  width: 100%;
  height: 100%;
  overflow: auto;
  background-color: rgba(0, 0, 0, 0.4);
}

.modal-content {
  background-color: #fefefe;
  margin: 15% auto;
  padding: 20px;
  border: 1px solid #888;
  width: 80%;
  max-width: 600px;
}

@media screen and (max-width: 768px) {
  .topbar {
    text-align: center;
  }

  table,
  thead,
  tbody,
  th,
  td,
  tr {
    display: block;
  }

  thead tr {
    position: absolute;
    top: -9999px;
    left: -9999px;
  }

  tr {
    margin-bottom: 15px;
  }

  td {
    border: none;
    position: relative;
    padding-left: 50%;
  }

  td:before {
    position: absolute;
    top: 6px;
    left: 6px;
    width: 45%;
    padding-right: 10px;
    white-space: nowrap;
    content: attr(data-label);
    font-weight: bold;
  }

  .modal-content {
    width: 95%;
  }
}

@media screen and (max-width: 480px) {
  button {
    width: 100%;
  }
}
</style>