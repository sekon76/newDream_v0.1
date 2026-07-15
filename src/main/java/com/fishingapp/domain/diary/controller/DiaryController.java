package com.fishingapp.domain.diary.controller;

import com.fishingapp.domain.diary.dto.DiaryCreateRequest;
import com.fishingapp.domain.diary.dto.DiaryResponse;
import com.fishingapp.domain.diary.dto.DiaryUpdateRequest;
import com.fishingapp.domain.diary.service.DiaryService;
import com.fishingapp.domain.user.entity.User;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/diaries")
@RequiredArgsConstructor
public class DiaryController {

    private final DiaryService diaryService;

    @PostMapping
    public ResponseEntity<DiaryResponse> create(
            @AuthenticationPrincipal User user,
            @Valid @RequestBody DiaryCreateRequest request) {
        return ResponseEntity.status(HttpStatus.CREATED).body(diaryService.create(user, request));
    }

    @GetMapping
    public ResponseEntity<List<DiaryResponse>> findAll(@AuthenticationPrincipal User user) {
        return ResponseEntity.ok(diaryService.findAll(user));
    }

    @GetMapping("/{diaryId}")
    public ResponseEntity<DiaryResponse> findOne(
            @AuthenticationPrincipal User user,
            @PathVariable Long diaryId) {
        return ResponseEntity.ok(diaryService.findOne(user, diaryId));
    }

    @PutMapping("/{diaryId}")
    public ResponseEntity<DiaryResponse> update(
            @AuthenticationPrincipal User user,
            @PathVariable Long diaryId,
            @Valid @RequestBody DiaryUpdateRequest request) {
        return ResponseEntity.ok(diaryService.update(user, diaryId, request));
    }

    @DeleteMapping("/{diaryId}")
    public ResponseEntity<Void> delete(
            @AuthenticationPrincipal User user,
            @PathVariable Long diaryId) {
        diaryService.delete(user, diaryId);
        return ResponseEntity.noContent().build();
    }
}
