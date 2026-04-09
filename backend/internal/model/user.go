package model

import (
	"gorm.io/gorm"
)

type User struct {
	gorm.Model
	Phone    string `gorm:"type:varchar(255);uniqueIndex" json:"phone"`
	Password string `gorm:"type:varchar(255)" json:"password"`
	Name     string `gorm:"type:varchar(255)" json:"name"`
	Sex      string `gorm:"type:varchar(255)" json:"sex"`
	Avatar   string `gorm:"type:varchar(255)" json:"avatar"`
}
