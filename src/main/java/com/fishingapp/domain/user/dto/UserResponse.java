package com.fishingapp.domain.user.dto;

import com.fishingapp.domain.user.entity.MapProvider;
import com.fishingapp.domain.user.entity.User;
import lombok.Getter;

import java.time.LocalDateTime;

@Getter
public class UserResponse {
    private final Long id;
    private final String email;
    private final String nickname;
    private final MapProvider mapProvider;
    private final LocalDateTime createdAt;

    public UserResponse(User user) {
        this.id = user.getId();
        this.email = user.getEmail();
        this.nickname = user.getNickname();
        this.mapProvider = user.getMapProvider();
        this.createdAt = user.getCreatedAt();
    }
}
