package controller

import (
	"net/http"
	"sync"

	"github.com/gin-gonic/gin"
	"github.com/gorilla/websocket"
)

// 允许跨域
var upgrader = websocket.Upgrader{
	CheckOrigin: func(r *http.Request) bool {
		return true
	},
}

type RoomHub struct {
	rooms map[string]map[uint]*websocket.Conn
	mu    sync.Mutex
}

// Broadcast 把消息同时发给房间里的所有人
func (h *RoomHub) Broadcast(roomID string, message interface{}) {
	h.mu.Lock()
	defer h.mu.Unlock()
	if clients, ok := h.rooms[roomID]; ok {
		for _, conn := range clients {
			_ = conn.WriteJSON(message)
		}
	}
}

func RoomWS(c *gin.Context) {
	conn, err := upgrader.Upgrade(c.Writer, c.Request, nil)
	if err != nil {
		return
	}

	// 退出清理逻辑
	defer func() {
		_ = conn.Close()
	}()

	for {
		if _, _, err := conn.ReadMessage(); err != nil {
			break
		}
	}
}
