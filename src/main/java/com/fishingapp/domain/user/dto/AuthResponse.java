package com.fishingapp.domain.user.dto;

import com.fishingapp.domain.user.entity.MapProvider;
import lombok.Builder;
import lombok.Getter;

@Getter
@Builder
public class AuthResponse {
    private String accessToken;
    private String tokenType;
    private long expiresIn;
    private MapProvider mapProvider;
}
