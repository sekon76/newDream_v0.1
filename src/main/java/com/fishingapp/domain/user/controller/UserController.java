package com.fishingapp.domain.user.controller;

import com.fishingapp.domain.user.dto.PasswordChangeRequest;
import com.fishingapp.domain.user.dto.UserResponse;
import com.fishingapp.domain.user.entity.User;
import com.fishingapp.domain.user.service.UserService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/users")
@RequiredArgsConstructor
public class UserController {

    private final UserService userService;

    @GetMapping("/me")
    public ResponseEntity<UserResponse> me(@AuthenticationPrincipal User user) {
        return ResponseEntity.ok(new UserResponse(user));
    }

    @PutMapping("/me/password")
    public ResponseEntity<Void> changePassword(
            @AuthenticationPrincipal User user,
            @Valid @RequestBody PasswordChangeRequest request) {
        userService.changePassword(user, request);
        return ResponseEntity.noContent().build();
    }
}
