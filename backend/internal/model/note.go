package model

import "gorm.io/gorm"

type Note struct {
	gorm.Model
	UserID  uint   `gorm:"index" json:"user_id"`     // 关联用户
	Title   string `gorm:"size:255" json:"title"`    // 标题
	Content string `gorm:"type:text" json:"content"` // 内容
	Source  string `gorm:"size:20;default:'manual'"` // 来源：manual(手动), ai(语音识别)
}
