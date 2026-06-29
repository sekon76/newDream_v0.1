package com.fishingapp.domain.point.controller;

import com.fishingapp.domain.point.dto.PointCreateRequest;
import com.fishingapp.domain.point.dto.PointResponse;
import com.fishingapp.domain.point.dto.PointUpdateRequest;
import com.fishingapp.domain.point.service.FishingPointService;
import com.fishingapp.domain.user.entity.User;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/points")
@RequiredArgsConstructor
public class FishingPointController {

    private final FishingPointService fishingPointService;

    @PostMapping
    public ResponseEntity<PointResponse> create(
            @AuthenticationPrincipal User user,
            @Valid @RequestBody PointCreateRequest request) {
        return ResponseEntity.status(HttpStatus.CREATED).body(fishingPointService.create(user, request));
    }

    @GetMapping
    public ResponseEntity<List<PointResponse>> findAll(@AuthenticationPrincipal User user) {
        return ResponseEntity.ok(fishingPointService.findAll(user));
    }

    @GetMapping("/{id}")
    public ResponseEntity<PointResponse> findOne(
            @AuthenticationPrincipal User user,
            @PathVariable Long id) {
        return ResponseEntity.ok(fishingPointService.findOne(user, id));
    }

    @PutMapping("/{id}")
    public ResponseEntity<PointResponse> update(
            @AuthenticationPrincipal User user,
            @PathVariable Long id,
            @Valid @RequestBody PointUpdateRequest request) {
        return ResponseEntity.ok(fishingPointService.update(user, id, request));
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Void> delete(
            @AuthenticationPrincipal User user,
            @PathVariable Long id) {
        fishingPointService.delete(user, id);
        return ResponseEntity.noContent().build();
    }
}
