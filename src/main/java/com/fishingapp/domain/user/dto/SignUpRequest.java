package com.fishingapp.domain.user.dto;

import com.fishingapp.domain.user.entity.MapProvider;
import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;
import lombok.Getter;

@Getter
public class SignUpRequest {

    @NotBlank @Email
    private String email;

    @NotBlank
    @Size(min = 8, message = "비밀번호는 8자 이상이어야 합니다.")
    private String password;

    @NotBlank
    @Size(min = 2, max = 20, message = "닉네임은 2~20자여야 합니다.")
    private String nickname;

    @NotNull(message = "지도 서비스를 선택해주세요. (NAVER 또는 KAKAO)")
    private MapProvider mapProvider;
}
