package controller

import (
	"backend/internal/model"
	"backend/internal/service"
	"backend/pkg/utils"
	"strconv"

	"github.com/gin-gonic/gin"
)

func CreateNote(c *gin.Context) {
	var note model.Note
	if err := c.ShouldBindJSON(&note); err != nil {
		utils.Error(c, "参数错误")
		return
	}

	// 从中间件获取当前登录用户ID
	uid, _ := c.Get("user_id")
	note.UserID = uid.(uint)

	if err := service.CreateNote(&note); err != nil {
		utils.Error(c, "创建笔记失败")
		return
	}
	utils.Success(c, note)
}

// DeleteNote 删除笔记
func DeleteNote(c *gin.Context) {
	var req struct {
		ID uint `json:"id" binding:"required"`
	}
	if err := c.ShouldBindJSON(&req); err != nil {
		utils.Error(c, "请提供笔记ID")
		return
	}

	uid, _ := c.Get("user_id")
	if err := service.DeleteNote(req.ID, uid.(uint)); err != nil {
		utils.Error(c, "删除失败: "+err.Error())
		return
	}

	utils.Success(c, "删除成功")
}

// UpdateNote 更新笔记
func UpdateNote(c *gin.Context) {
	var req struct {
		ID      uint   `json:"id" binding:"required"`
		Title   string `json:"title"`
		Content string `json:"content"`
	}
	if err := c.ShouldBindJSON(&req); err != nil {
		utils.Error(c, "参数解析失败")
		return
	}

	uid, _ := c.Get("user_id")

	updateData := make(map[string]interface{})
	if req.Title != "" {
		updateData["title"] = req.Title
	}
	if req.Content != "" {
		updateData["content"] = req.Content
	}

	if err := service.UpdateNote(req.ID, uid.(uint), updateData); err != nil {
		utils.Error(c, "更新失败")
		return
	}

	utils.Success(c, "更新成功")
}

// GetNoteList 获取笔记列表
func GetNoteList(c *gin.Context) {
	uid, _ := c.Get("user_id")

	// 获取分页参数（可选）
	page, _ := strconv.Atoi(c.DefaultQuery("page", "1"))
	pageSize, _ := strconv.Atoi(c.DefaultQuery("size", "10"))

	notes, total, err := service.GetNoteListByUserID(uid.(uint), page, pageSize)
	if err != nil {
		utils.Error(c, "获取列表失败")
		return
	}

	utils.Success(c, gin.H{
		"list":  notes,
		"total": total,
		"page":  page,
	})
}

// GetNoteDetail 获取详情
func GetNoteDetail(c *gin.Context) {
	noteID, _ := strconv.Atoi(c.Query("id"))
	uid, _ := c.Get("user_id")

	note, err := service.GetNoteByID(uint(noteID), uid.(uint))
	if err != nil {
		utils.Error(c, "未找到该笔记")
		return
	}

	utils.Success(c, note)
}
