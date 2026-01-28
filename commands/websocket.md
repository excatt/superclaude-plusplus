# WebSocket Skill

실시간 통신 설계 가이드를 실행합니다.

## WebSocket 개요

```
HTTP (단방향)          WebSocket (양방향)
Client → Server        Client ⇄ Server

┌────────┐ Handshake ┌────────┐
│ Client │ ────────→ │ Server │
│        │ ←──────── │        │
│        │   Upgrade │        │
│        │ ⇄⇄⇄⇄⇄⇄⇄⇄ │        │
└────────┘ Full-duplex└────────┘
```

## 사용 사례

```
1. 채팅 애플리케이션
2. 실시간 알림
3. 라이브 대시보드
4. 협업 도구 (동시 편집)
5. 게임
6. 주식/암호화폐 시세
```

## Socket.IO 구현

### 서버
```javascript
const { Server } = require('socket.io');
const io = new Server(httpServer, {
  cors: { origin: '*' },
  pingTimeout: 60000,
});

// 연결 처리
io.on('connection', (socket) => {
  console.log('Connected:', socket.id);

  // 인증
  const token = socket.handshake.auth.token;
  const user = verifyToken(token);
  socket.data.user = user;

  // 룸 참가
  socket.join(`user:${user.id}`);

  // 이벤트 수신
  socket.on('message', async (data) => {
    const message = await saveMessage(data);

    // 특정 룸에 브로드캐스트
    io.to(`room:${data.roomId}`).emit('message', message);
  });

  // 타이핑 인디케이터
  socket.on('typing', (roomId) => {
    socket.to(`room:${roomId}`).emit('typing', {
      userId: user.id,
      name: user.name,
    });
  });

  // 연결 해제
  socket.on('disconnect', (reason) => {
    console.log('Disconnected:', socket.id, reason);
  });
});
```

### 클라이언트
```javascript
import { io } from 'socket.io-client';

const socket = io('http://localhost:3000', {
  auth: { token: 'jwt-token' },
  reconnection: true,
  reconnectionDelay: 1000,
  reconnectionAttempts: 5,
});

// 연결 상태
socket.on('connect', () => {
  console.log('Connected:', socket.id);
});

socket.on('disconnect', (reason) => {
  console.log('Disconnected:', reason);
});

socket.on('connect_error', (error) => {
  console.error('Connection error:', error);
});

// 메시지 수신
socket.on('message', (message) => {
  addMessageToUI(message);
});

// 메시지 전송
function sendMessage(roomId, content) {
  socket.emit('message', { roomId, content });
}

// 타이핑 상태
function startTyping(roomId) {
  socket.emit('typing', roomId);
}
```

## 네이티브 WebSocket

### 서버 (Node.js ws)
```javascript
const WebSocket = require('ws');
const wss = new WebSocket.Server({ server: httpServer });

const clients = new Map();

wss.on('connection', (ws, req) => {
  const userId = authenticateRequest(req);
  clients.set(userId, ws);

  ws.on('message', (data) => {
    const message = JSON.parse(data);
    handleMessage(ws, message);
  });

  ws.on('close', () => {
    clients.delete(userId);
  });

  // Ping/Pong (연결 유지)
  ws.isAlive = true;
  ws.on('pong', () => { ws.isAlive = true; });
});

// 연결 상태 체크
setInterval(() => {
  wss.clients.forEach((ws) => {
    if (!ws.isAlive) return ws.terminate();
    ws.isAlive = false;
    ws.ping();
  });
}, 30000);

// 브로드캐스트
function broadcast(message) {
  wss.clients.forEach((client) => {
    if (client.readyState === WebSocket.OPEN) {
      client.send(JSON.stringify(message));
    }
  });
}
```

### 클라이언트
```javascript
class WebSocketClient {
  constructor(url) {
    this.url = url;
    this.handlers = new Map();
    this.reconnectAttempts = 0;
    this.maxReconnectAttempts = 5;
    this.connect();
  }

  connect() {
    this.ws = new WebSocket(this.url);

    this.ws.onopen = () => {
      console.log('Connected');
      this.reconnectAttempts = 0;
    };

    this.ws.onmessage = (event) => {
      const { type, payload } = JSON.parse(event.data);
      const handler = this.handlers.get(type);
      if (handler) handler(payload);
    };

    this.ws.onclose = () => {
      this.reconnect();
    };

    this.ws.onerror = (error) => {
      console.error('WebSocket error:', error);
    };
  }

  reconnect() {
    if (this.reconnectAttempts < this.maxReconnectAttempts) {
      this.reconnectAttempts++;
      const delay = Math.min(1000 * Math.pow(2, this.reconnectAttempts), 30000);
      setTimeout(() => this.connect(), delay);
    }
  }

  on(type, handler) {
    this.handlers.set(type, handler);
  }

  send(type, payload) {
    if (this.ws.readyState === WebSocket.OPEN) {
      this.ws.send(JSON.stringify({ type, payload }));
    }
  }
}
```

## 확장 패턴

### Redis Pub/Sub (다중 서버)
```javascript
const Redis = require('ioredis');
const pub = new Redis();
const sub = new Redis();

// 메시지 발행
async function publishMessage(channel, message) {
  await pub.publish(channel, JSON.stringify(message));
}

// 구독 및 클라이언트 전달
sub.subscribe('chat:messages');
sub.on('message', (channel, message) => {
  const data = JSON.parse(message);

  // 해당 룸의 클라이언트에게 전달
  io.to(`room:${data.roomId}`).emit('message', data);
});
```

### 연결 관리
```javascript
class ConnectionManager {
  constructor() {
    this.connections = new Map(); // userId -> Set<socket>
  }

  add(userId, socket) {
    if (!this.connections.has(userId)) {
      this.connections.set(userId, new Set());
    }
    this.connections.get(userId).add(socket);
  }

  remove(userId, socket) {
    const sockets = this.connections.get(userId);
    if (sockets) {
      sockets.delete(socket);
      if (sockets.size === 0) {
        this.connections.delete(userId);
      }
    }
  }

  sendToUser(userId, event, data) {
    const sockets = this.connections.get(userId);
    if (sockets) {
      sockets.forEach(socket => socket.emit(event, data));
    }
  }

  isOnline(userId) {
    return this.connections.has(userId);
  }
}
```

## 메시지 프로토콜

### 구조화된 메시지
```javascript
// 메시지 형식
{
  "type": "MESSAGE_TYPE",
  "id": "unique-id",
  "timestamp": "2024-01-15T10:00:00Z",
  "payload": { /* 데이터 */ }
}

// 타입 정의
const MessageTypes = {
  // 채팅
  CHAT_MESSAGE: 'chat:message',
  CHAT_TYPING: 'chat:typing',

  // 알림
  NOTIFICATION: 'notification',

  // 상태
  PRESENCE_UPDATE: 'presence:update',

  // 시스템
  ERROR: 'system:error',
  ACK: 'system:ack',
};
```

### 에러 처리
```javascript
socket.on('message', async (data, callback) => {
  try {
    const result = await processMessage(data);
    callback({ success: true, data: result });
  } catch (error) {
    callback({ success: false, error: error.message });
    socket.emit('error', {
      code: error.code,
      message: error.message,
    });
  }
});
```

## 최적화

### 연결 풀링
```javascript
// 클라이언트당 연결 수 제한
io.use((socket, next) => {
  const userId = socket.data.user.id;
  const connections = getConnectionCount(userId);

  if (connections >= MAX_CONNECTIONS_PER_USER) {
    return next(new Error('Too many connections'));
  }
  next();
});
```

### 메시지 압축
```javascript
const io = new Server(httpServer, {
  perMessageDeflate: {
    threshold: 1024, // 1KB 이상만 압축
  },
});
```

### 배치 처리
```javascript
// 메시지 배칭
const messageBuffer = [];
const BATCH_INTERVAL = 100; // ms

function queueMessage(message) {
  messageBuffer.push(message);
}

setInterval(() => {
  if (messageBuffer.length > 0) {
    io.emit('messages', messageBuffer);
    messageBuffer.length = 0;
  }
}, BATCH_INTERVAL);
```

## 체크리스트

### 구현
- [ ] 연결/재연결 처리
- [ ] 인증
- [ ] 룸/채널 관리
- [ ] 에러 처리

### 확장성
- [ ] 다중 서버 지원 (Redis Pub/Sub)
- [ ] 연결 수 관리
- [ ] 메시지 압축/배칭

### 안정성
- [ ] Heartbeat (Ping/Pong)
- [ ] 메시지 확인 (ACK)
- [ ] 오프라인 메시지 처리

## 출력 형식

```
## WebSocket Design

### Architecture
```
[Client] ⇄ [Load Balancer] ⇄ [WS Server 1]
                            ⇄ [WS Server 2]
                                   ↕
                              [Redis Pub/Sub]
```

### Events
| 이벤트 | 방향 | 설명 |
|--------|------|------|
| message | 양방향 | 채팅 메시지 |
| typing | C→S | 타이핑 상태 |

### Implementation
```javascript
// 서버/클라이언트 코드
```

### Scaling Strategy
- Redis Pub/Sub
- Sticky Sessions
```

---

요청에 맞는 WebSocket 구현을 설계하세요.
