# GoalQuest - Gamified Goal Tracking Application
## Documentation Package

# 1. Feature Specification Document

## 1.1 Core Features

### User Management
- User registration and authentication
- Profile customization
- User preferences and settings
- Avatar system with customizable characters

### Task Management
- Task creation, editing, and deletion
- Task categories and tags
- Recurring tasks support
- Priority levels (Low, Medium, High)
- Subtask creation and management
- Due dates and reminders
- Task difficulty levels affecting XP rewards

### XP and Rewards System
- XP earning through task completion
- Progressive XP scale based on task difficulty
- Streak bonuses and multipliers
- Virtual store for reward redemption
- Custom reward creation
- Reward categories (Material Items, Experiences, Self-Care)
- Savings goals tracking
- Partial reward redemption

### Gamification Elements
- Level progression system
- Achievement badges
- Daily quests and challenges
- Power-ups and boosters
- Character progression
- Skill trees for different life areas
- Seasonal events and special challenges

### Analytics and Tracking
- Progress visualization
- Habit formation tracking
- Productivity analytics
- Goal completion rates
- XP earning history
- Time tracking for tasks

### Social Features
- Friend connections
- Group challenges
- Leaderboards
- Social feed
- Achievement sharing
- Accountability partnerships

## 1.2 Advanced Features

### Integrations
- Calendar synchronization
- Health app integration
- Smart device connectivity
- Location-based tasks
- Export capabilities

### AI and Automation
- Smart task suggestions
- Intelligent reward recommendations
- Automated progress tracking
- Personalized goal setting assistance
- Smart notifications

# 2. Software Requirements Specification (SRS)

## 2.1 Functional Requirements

### User Authentication
- Users shall be able to register using email or social media accounts
- Users shall be able to reset passwords
- Users shall be able to manage their profile information
- System shall support multiple authentication methods

### Task Management
- Users shall be able to create, edit, and delete tasks
- System shall support task categorization
- System shall calculate XP rewards based on task difficulty
- System shall track task completion status
- System shall support recurring task creation
- System shall provide task reminder notifications

### Reward System
- System shall track user XP balance
- System shall maintain a reward store
- Users shall be able to redeem XP for rewards
- System shall verify reward eligibility
- System shall track reward redemption history

### Gamification
- System shall track user level progression
- System shall award achievements based on user actions
- System shall generate daily quests
- System shall maintain user streaks
- System shall calculate multipliers and bonuses

### Social Features
- Users shall be able to connect with other users
- Users shall be able to participate in group challenges
- System shall maintain leaderboards
- Users shall be able to share achievements

## 2.2 Non-Functional Requirements

### Performance
- App shall load within 3 seconds on 4G networks
- Database queries shall complete within 100ms
- App shall support 100,000 concurrent users
- Background sync shall occur every 15 minutes

### Security
- All user data shall be encrypted at rest
- All network communications shall use HTTPS
- Passwords shall be hashed using bcrypt
- API access shall require authentication
- Rate limiting shall be implemented

### Reliability
- System shall have 99.9% uptime
- Data backups shall occur every 6 hours
- System shall handle network interruptions gracefully
- Offline functionality shall be supported

### Scalability
- System shall support horizontal scaling
- Database shall support sharding
- Caching system shall be implemented
- Load balancing shall be configured

# 3. Technical Documentation

## 3.1 Technology Stack

### Frontend (Flutter)
- Flutter SDK 3.x
- Dart 3.x
- State Management: Riverpod
- Local Storage: Hive
- Network: Dio
- Authentication: firebase_auth
- Analytics: firebase_analytics

### Backend (Go)
- Go 1.22+
- Framework: Gin-Gonic
- ORM: GORM
- Database: PostgreSQL
- Cache: Redis
- Search: Elasticsearch
- Message Queue: RabbitMQ
- File Storage: AWS S3
- Authentication: JWT with golang-jwt
- Validation: validator/v10
- Testing: testify

### Infrastructure
- Cloud Provider: AWS
- Container Orchestration: Kubernetes
- CI/CD: GitHub Actions
- Monitoring: Prometheus + Grafana
- Logging: ELK Stack

## 3.2 System Architecture

### Microservices
1. Authentication Service (`auth-service`)
```go
package models

type User struct {
    ID        uint      `gorm:"primaryKey"`
    Email     string    `gorm:"uniqueIndex;not null"`
    Username  string    `gorm:"uniqueIndex;not null"`
    Password  string    `gorm:"not null"`
    XP        int64     `gorm:"default:0"`
    Level     int       `gorm:"default:1"`
    CreatedAt time.Time
    UpdatedAt time.Time
}
```

2. Task Service (`task-service`)
```go
package models

type Task struct {
    ID              uint      `gorm:"primaryKey"`
    UserID          uint      `gorm:"index;not null"`
    Title           string    `gorm:"not null"`
    Description     string
    Difficulty      string    `gorm:"type:enum('EASY','MEDIUM','HARD')"`
    XPReward        int64     `gorm:"not null"`
    DueDate         time.Time
    Status          string    `gorm:"type:enum('PENDING','COMPLETED');default:'PENDING'"`
    Recurring       bool      `gorm:"default:false"`
    RecurringPattern string
    CreatedAt       time.Time
    UpdatedAt       time.Time
}
```

3. Reward Service (`reward-service`)
```go
package models

type Reward struct {
    ID          uint      `gorm:"primaryKey"`
    Title       string    `gorm:"not null"`
    Description string
    XPCost      int64     `gorm:"not null"`
    Category    string    `gorm:"not null"`
    Available   bool      `gorm:"default:true"`
    CreatedAt   time.Time
    UpdatedAt   time.Time
}
```

4. Social Service (`social-service`)
```go
package models

type FriendConnection struct {
    ID        uint      `gorm:"primaryKey"`
    UserID    uint      `gorm:"index;not null"`
    FriendID  uint      `gorm:"index;not null"`
    Status    string    `gorm:"type:enum('PENDING','ACCEPTED','REJECTED')"`
    CreatedAt time.Time
    UpdatedAt time.Time
}
```

5. Analytics Service (`analytics-service`)
```go
package models

type UserActivity struct {
    ID        uint      `gorm:"primaryKey"`
    UserID    uint      `gorm:"index;not null"`
    Activity  string    `gorm:"not null"`
    XPEarned  int64
    Metadata  JSON      `gorm:"type:jsonb"`
    CreatedAt time.Time
}
```

### Service Communication
- gRPC for inter-service communication
- Event-driven architecture using RabbitMQ
- Redis for distributed caching

```go
// Proto definition example
syntax = "proto3";

package task;

service TaskService {
    rpc CreateTask(CreateTaskRequest) returns (Task);
    rpc CompleteTask(CompleteTaskRequest) returns (Task);
    rpc GetUserTasks(GetUserTasksRequest) returns (TaskList);
}

message Task {
    string id = 1;
    string user_id = 2;
    string title = 3;
    string description = 4;
    string difficulty = 5;
    int64 xp_reward = 6;
    string status = 7;
    // ... other fields
}
```

## 3.3 API Documentation

### Middleware Setup
```go
package middleware

func AuthMiddleware() gin.HandlerFunc {
    return func(c *gin.Context) {
        token := c.GetHeader("Authorization")
        // Token validation logic
        if !valid {
            c.AbortWithStatus(401)
            return
        }
        c.Next()
    }
}
```

### Router Setup
```go
package routes

func SetupRoutes(r *gin.Engine) {
    api := r.Group("/api")
    {
        auth := api.Group("/auth")
        {
            auth.POST("/register", handlers.Register)
            auth.POST("/login", handlers.Login)
            auth.POST("/refresh", handlers.RefreshToken)
        }

        tasks := api.Group("/tasks").Use(middleware.Auth())
        {
            tasks.GET("/", handlers.GetTasks)
            tasks.POST("/", handlers.CreateTask)
            tasks.PUT("/:id", handlers.UpdateTask)
            tasks.DELETE("/:id", handlers.DeleteTask)
            tasks.POST("/:id/complete", handlers.CompleteTask)
        }
        
        // Additional routes...
    }
}
```

### Sample Handler Implementation
```go
package handlers

func CreateTask(c *gin.Context) {
    var task models.Task
    if err := c.ShouldBindJSON(&task); err != nil {
        c.JSON(400, gin.H{"error": err.Error()})
        return
    }

    userID, _ := c.Get("userID")
    task.UserID = userID.(uint)

    if err := db.Create(&task).Error; err != nil {
        c.JSON(500, gin.H{"error": "Failed to create task"})
        return
    }

    // Publish task created event
    events.PublishTaskCreated(task)

    c.JSON(201, task)
}
```

## 3.4 Database Management

### Migration Setup
```go
package database

func AutoMigrate(db *gorm.DB) error {
    return db.AutoMigrate(
        &models.User{},
        &models.Task{},
        &models.Reward{},
        &models.Achievement{},
        &models.FriendConnection{},
    )
}
```

### Repository Pattern Implementation
```go
package repository

type TaskRepository interface {
    Create(task *models.Task) error
    Update(task *models.Task) error
    Delete(id uint) error
    FindByID(id uint) (*models.Task, error)
    FindByUserID(userID uint) ([]models.Task, error)
}

type taskRepository struct {
    db *gorm.DB
}

func NewTaskRepository(db *gorm.DB) TaskRepository {
    return &taskRepository{db: db}
}
```

## 3.5 Testing Strategy

### Unit Testing
```go
package handlers_test

func TestCreateTask(t *testing.T) {
    // Setup
    router := setupTestRouter()
    
    // Test data
    task := models.Task{
        Title:       "Test Task",
        Description: "Test Description",
        Difficulty:  "EASY",
    }
    
    // Perform request
    w := performRequest(router, "POST", "/api/tasks", task)
    
    // Assert
    assert.Equal(t, 201, w.Code)
    
    var response models.Task
    err := json.Unmarshal(w.Body.Bytes(), &response)
    assert.Nil(t, err)
    assert.Equal(t, task.Title, response.Title)
}
```

## 3.6 Deployment Configuration

### Dockerfile
```dockerfile
FROM golang:1.22-alpine

WORKDIR /app

COPY go.mod go.sum ./
RUN go mod download

COPY . .
RUN go build -o main .

EXPOSE 8080

CMD ["./main"]
```

### Kubernetes Configuration
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: task-service
spec:
  replicas: 3
  selector:
    matchLabels:
      app: task-service
  template:
    metadata:
      labels:
        app: task-service
    spec:
      containers:
      - name: task-service
        image: goalquest/task-service:latest
        ports:
        - containerPort: 8080
        env:
        - name: DB_HOST
          valueFrom:
            configMapKeyRef:
              name: app-config
              key: db_host
```

## 3.7 Monitoring and Logging

### Prometheus Metrics
```go
package metrics

func RegisterMetrics() {
    taskCompletions := promauto.NewCounter(prometheus.CounterOpts{
        Name: "task_completions_total",
        Help: "The total number of completed tasks",
    })

    taskCreations := promauto.NewCounter(prometheus.CounterOpts{
        Name: "task_creations_total",
        Help: "The total number of created tasks",
    })
}
```

### Structured Logging
```go
package logger

var log = logrus.New()

func InitLogger() {
    log.SetFormatter(&logrus.JSONFormatter{})
    log.SetOutput(os.Stdout)
    log.SetLevel(logrus.InfoLevel)
}
```
