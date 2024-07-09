package main

import (
	"context"
	"encoding/json"
	"fmt"
	"log"
	"net/http"
	"time"

	"github.com/golang-jwt/jwt"
	"github.com/gorilla/mux"
	"github.com/rs/cors"
	"go.mongodb.org/mongo-driver/bson"
	"go.mongodb.org/mongo-driver/bson/primitive"
	"go.mongodb.org/mongo-driver/mongo"
	"go.mongodb.org/mongo-driver/mongo/options"
	"golang.org/x/crypto/bcrypt"
)

type Article struct {
	ID         primitive.ObjectID `json:"id" bson:"_id,omitempty"`
	Title      string             `json:"title" bson:"title"`
	Content    string             `json:"content" bson:"content"`
	Thumbnail  string             `json:"thumbnail" bson:"thumbnail"`
	CreateDate time.Time          `json:"createDate" bson:"createDate"`
	LastUpdate time.Time          `json:"lastUpdate" bson:"lastUpdate"`
	Status     int                `json:"status" bson:"status"`
	Author     string             `json:"author" bson:"author"`
}

type User struct {
	ID        primitive.ObjectID `json:"id" bson:"_id,omitempty"`
	Username  string             `json:"username" bson:"username"`
	Password  string             `json:"password" bson:"password"`
	FirstName string             `json:"firstName" bson:"firstName"`
	LastName  string             `json:"lastName" bson:"lastName"`
	Role      string             `json:"role" bson:"role"`
}

type Log struct {
	ID        primitive.ObjectID `json:"id" bson:"_id,omitempty"`
	Action    string             `json:"action" bson:"action"`
	Username  string             `json:"username" bson:"username"`
	Timestamp time.Time          `json:"timestamp" bson:"timestamp"`
	Details   string             `json:"details" bson:"details"`
}

var client *mongo.Client
var collection *mongo.Collection
var userCollection *mongo.Collection
var logCollection *mongo.Collection

func getArticles(w http.ResponseWriter, r *http.Request) {
	w.Header().Set("Content-Type", "application/json")

	var articles []Article
	cur, err := collection.Find(context.Background(), bson.M{})
	if err != nil {
		http.Error(w, err.Error(), http.StatusInternalServerError)
		return
	}
	defer cur.Close(context.Background())

	for cur.Next(context.Background()) {
		var article Article
		err := cur.Decode(&article)
		if err != nil {
			http.Error(w, err.Error(), http.StatusInternalServerError)
			return
		}
		articles = append(articles, article)
	}

	json.NewEncoder(w).Encode(articles)
}

func createArticle(w http.ResponseWriter, r *http.Request) {
	w.Header().Set("Content-Type", "application/json")
	var article Article
	_ = json.NewDecoder(r.Body).Decode(&article)

	// ดึงข้อมูลผู้ใช้จาก token
	tokenString := r.Header.Get("Authorization")
	token, _ := jwt.Parse(tokenString, func(token *jwt.Token) (interface{}, error) {
		return []byte("your-secret-key"), nil
	})
	claims, _ := token.Claims.(jwt.MapClaims)
	username := claims["username"].(string)

	// ค้นหาข้อมูลผู้ใช้
	var user User
	err := userCollection.FindOne(context.Background(), bson.M{"username": username}).Decode(&user)
	if err != nil {
		http.Error(w, err.Error(), http.StatusInternalServerError)
		return
	}

	// กำหนดชื่อผู้เขียนจากชื่อ-นามสกุลของผู้ใช้
	article.Author = user.FirstName + " " + user.LastName

	now := time.Now()
	article.CreateDate = now
	article.LastUpdate = now

	result, err := collection.InsertOne(context.Background(), article)
	if err != nil {
		http.Error(w, err.Error(), http.StatusInternalServerError)
		return
	}

	article.ID = result.InsertedID.(primitive.ObjectID)
	createLog("create_article", username, fmt.Sprintf("Created article: %s", article.Title))

	json.NewEncoder(w).Encode(article)
}

func getArticle(w http.ResponseWriter, r *http.Request) {
	w.Header().Set("Content-Type", "application/json")
	params := mux.Vars(r)
	id, _ := primitive.ObjectIDFromHex(params["id"])

	var article Article
	err := collection.FindOne(context.Background(), bson.M{"_id": id}).Decode(&article)
	if err != nil {
		http.Error(w, err.Error(), http.StatusNotFound)
		return
	}

	json.NewEncoder(w).Encode(article)
}

func updateArticle(w http.ResponseWriter, r *http.Request) {
	w.Header().Set("Content-Type", "application/json")
	params := mux.Vars(r)
	id, _ := primitive.ObjectIDFromHex(params["id"])

	var article Article
	_ = json.NewDecoder(r.Body).Decode(&article)
	article.LastUpdate = time.Now()

	filter := bson.M{"_id": id}
	update := bson.M{"$set": article}

	_, err := collection.UpdateOne(context.Background(), filter, update)
	if err != nil {
		http.Error(w, err.Error(), http.StatusInternalServerError)
		return
	}

	article.ID = id
	createLog("update_article", getUsernameFromToken(r), fmt.Sprintf("Updated article: %s", article.Title))

	json.NewEncoder(w).Encode(article)
}

func deleteArticle(w http.ResponseWriter, r *http.Request) {
	w.Header().Set("Content-Type", "application/json")
	params := mux.Vars(r)
	id, _ := primitive.ObjectIDFromHex(params["id"])

	_, err := collection.DeleteOne(context.Background(), bson.M{"_id": id})
	if err != nil {
		http.Error(w, err.Error(), http.StatusInternalServerError)
		return
	}

	createLog("delete_article", getUsernameFromToken(r), fmt.Sprintf("Deleted article with ID: %s", id.Hex()))

	w.WriteHeader(http.StatusNoContent)
}

func createUser(w http.ResponseWriter, r *http.Request) {
	if !isAdmin(r) {
		http.Error(w, "Unauthorized", http.StatusUnauthorized)
		return
	}

	var user User
	_ = json.NewDecoder(r.Body).Decode(&user)

	hashedPassword, _ := bcrypt.GenerateFromPassword([]byte(user.Password), bcrypt.DefaultCost)
	user.Password = string(hashedPassword)

	result, err := userCollection.InsertOne(context.Background(), user)
	if err != nil {
		http.Error(w, err.Error(), http.StatusInternalServerError)
		return
	}

	user.ID = result.InsertedID.(primitive.ObjectID)
	user.Password = "" // ไม่ส่งรหัสผ่านกลับไปยัง client
	json.NewEncoder(w).Encode(user)
}

func login(w http.ResponseWriter, r *http.Request) {
	var loginInfo struct {
		Username string `json:"username"`
		Password string `json:"password"`
	}
	_ = json.NewDecoder(r.Body).Decode(&loginInfo)

	var user User
	err := userCollection.FindOne(context.Background(), bson.M{"username": loginInfo.Username}).Decode(&user)
	if err != nil {
		http.Error(w, "Invalid credentials", http.StatusUnauthorized)
		return
	}

	err = bcrypt.CompareHashAndPassword([]byte(user.Password), []byte(loginInfo.Password))
	if err != nil {
		http.Error(w, "Invalid credentials", http.StatusUnauthorized)
		return
	}

	token := jwt.NewWithClaims(jwt.SigningMethodHS256, jwt.MapClaims{
		"username": user.Username,
		"role":     user.Role,
		"exp":      time.Now().Add(time.Hour * 24).Unix(),
	})

	tokenString, err := token.SignedString([]byte("your-secret-key"))
	if err != nil {
		http.Error(w, err.Error(), http.StatusInternalServerError)
		return
	}

	if err == nil {
		createLog("login", user.Username, "User logged in successfully")
	}

	json.NewEncoder(w).Encode(map[string]string{"token": tokenString})
}

func authMiddleware(next http.HandlerFunc) http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		tokenString := r.Header.Get("Authorization")
		if tokenString == "" {
			http.Error(w, "Unauthorized", http.StatusUnauthorized)
			return
		}

		token, err := jwt.Parse(tokenString, func(token *jwt.Token) (interface{}, error) {
			return []byte("your-secret-key"), nil
		})

		if err != nil || !token.Valid {
			http.Error(w, "Unauthorized", http.StatusUnauthorized)
			return
		}

		next.ServeHTTP(w, r)
	}
}

func isAdmin(r *http.Request) bool {
	tokenString := r.Header.Get("Authorization")
	token, _ := jwt.Parse(tokenString, func(token *jwt.Token) (interface{}, error) {
		return []byte("your-secret-key"), nil
	})

	if claims, ok := token.Claims.(jwt.MapClaims); ok && token.Valid {
		return claims["role"] == "admin"
	}

	return false
}

func createInitialAdminUser() {
	var existingAdmin User
	err := userCollection.FindOne(context.Background(), bson.M{"username": "tharin"}).Decode(&existingAdmin)
	if err == nil {
		return
	}

	hashedPassword, err := bcrypt.GenerateFromPassword([]byte("tthhaarriinn"), bcrypt.DefaultCost)
	if err != nil {
		log.Fatal(err)
	}

	adminUser := User{
		Username:  "tharin",
		Password:  string(hashedPassword),
		FirstName: "Admin",
		LastName:  "",
		Role:      "admin",
	}

	_, err = userCollection.InsertOne(context.Background(), adminUser)
	if err != nil {
		log.Fatal(err)
	}

	fmt.Println("Initial admin user created successfully")
}

func createLog(action, username, details string) {
	log := Log{
		Action:    action,
		Username:  username,
		Timestamp: time.Now(),
		Details:   details,
	}
	_, err := logCollection.InsertOne(context.Background(), log)
	if err != nil {
		fmt.Printf("Error creating log: %v\n", err)
	}
}

func getUsernameFromToken(r *http.Request) string {
	tokenString := r.Header.Get("Authorization")
	token, _ := jwt.Parse(tokenString, func(token *jwt.Token) (interface{}, error) {
		return []byte("your-secret-key"), nil
	})
	if claims, ok := token.Claims.(jwt.MapClaims); ok && token.Valid {
		return claims["username"].(string)
	}
	return ""
}

func getLogs(w http.ResponseWriter, r *http.Request) {
	if !isAdmin(r) {
		http.Error(w, "Unauthorized", http.StatusUnauthorized)
		return
	}

	w.Header().Set("Content-Type", "application/json")

	var logs []Log
	cur, err := logCollection.Find(context.Background(), bson.M{})
	if err != nil {
		http.Error(w, err.Error(), http.StatusInternalServerError)
		return
	}
	defer cur.Close(context.Background())

	for cur.Next(context.Background()) {
		var log Log
		err := cur.Decode(&log)
		if err != nil {
			http.Error(w, err.Error(), http.StatusInternalServerError)
			return
		}
		logs = append(logs, log)
	}

	json.NewEncoder(w).Encode(logs)
}

func main() {
	ctx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
	defer cancel()
	client, err := mongo.Connect(ctx, options.Client().ApplyURI("mongodb://localhost:27017"))
	if err != nil {
		log.Fatal(err)
	}
	defer client.Disconnect(ctx)

	database := client.Database("cmstest")
	collection = database.Collection("articles")
	userCollection = database.Collection("users")
	logCollection = database.Collection("logs")

	createInitialAdminUser()

	router := mux.NewRouter()

	router.HandleFunc("/api/login", login).Methods("POST")
	router.HandleFunc("/api/users", authMiddleware(createUser)).Methods("POST")
	router.HandleFunc("/api/articles", getArticles).Methods("GET")
	router.HandleFunc("/api/articles/{id}", getArticle).Methods("GET")
	router.HandleFunc("/api/articles", authMiddleware(createArticle)).Methods("POST")
	router.HandleFunc("/api/articles/{id}", authMiddleware(updateArticle)).Methods("PUT")
	router.HandleFunc("/api/articles/{id}", authMiddleware(deleteArticle)).Methods("DELETE")
	router.HandleFunc("/api/logs", authMiddleware(getLogs)).Methods("GET")

	c := cors.New(cors.Options{
		// AllowedOrigins: []string{"http://localhost:8080"},
		AllowedOrigins: []string{"http://localhost:*"},
		AllowedMethods: []string{"GET", "POST", "PUT", "DELETE", "OPTIONS"},
		AllowedHeaders: []string{"Content-Type", "Authorization"},
	})

	handler := c.Handler(router)

	log.Println("Server is running on http://localhost:8000")
	log.Fatal(http.ListenAndServe(":8000", handler))
}
