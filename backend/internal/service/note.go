package service

import (
	"backend/internal/db"
	"backend/internal/model"
	"errors"
)

// CreateNote 创建新笔记
func CreateNote(note *model.Note) error {
	return db.DB.Create(note).Error
}

// DeleteNote 删除笔记（加强校验：必须是该用户的笔记）
func DeleteNote(noteID, userID uint) error {
	// 使用 Unscoped() 可以物理删除，不使用则触发 gorm.Model 的软删除
	result := db.DB.Where("id = ? AND user_id = ?", noteID, userID).Delete(&model.Note{})
	if result.Error != nil {
		return result.Error
	}
	if result.RowsAffected == 0 {
		return errors.New("笔记不存在或无权限操作")
	}
	return nil
}

// UpdateNote 更新笔记（加强校验：必须是该用户的笔记）
func UpdateNote(noteID, userID uint, data map[string]interface{}) error {
	result := db.DB.Model(&model.Note{}).
		Where("id = ? AND user_id = ?", noteID, userID).
		Updates(data)

	if result.Error != nil {
		return result.Error
	}
	if result.RowsAffected == 0 {
		return errors.New("修改失败：笔记不存在或无权限")
	}
	return nil
}

// GetNoteListByUserID 获取用户的笔记列表（带分页）
func GetNoteListByUserID(userID uint, page, pageSize int) ([]model.Note, int64, error) {
	var notes []model.Note
	var total int64

	// 计算偏移量
	offset := (page - 1) * pageSize

	// 统计总数
	db.DB.Model(&model.Note{}).Where("user_id = ?", userID).Count(&total)

	// 查询数据
	err := db.DB.Where("user_id = ?", userID).
		Order("updated_at desc"). // 按最后修改时间倒序
		Offset(offset).
		Limit(pageSize).
		Find(&notes).Error

	return notes, total, err
}

// GetNoteByID 获取单条笔记详情
func GetNoteByID(noteID, userID uint) (model.Note, error) {
	var note model.Note
	err := db.DB.Where("id = ? AND user_id = ?", noteID, userID).First(&note).Error
	return note, err
}
