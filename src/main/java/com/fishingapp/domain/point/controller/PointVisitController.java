package com.fishingapp.domain.point.controller;

import com.fishingapp.domain.point.dto.PointVisitCreateRequest;
import com.fishingapp.domain.point.dto.PointVisitResponse;
import com.fishingapp.domain.point.dto.PointVisitUpdateRequest;
import com.fishingapp.domain.point.service.PointVisitService;
import com.fishingapp.domain.user.entity.User;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/points/{pointId}/visits")
@RequiredArgsConstructor
public class PointVisitController {

    private final PointVisitService pointVisitService;

    @PostMapping
    public ResponseEntity<PointVisitResponse> create(
            @AuthenticationPrincipal User user,
            @PathVariable Long pointId,
            @Valid @RequestBody PointVisitCreateRequest request) {
        return ResponseEntity.status(HttpStatus.CREATED)
                .body(pointVisitService.create(user, pointId, request));
    }

    @GetMapping
    public ResponseEntity<List<PointVisitResponse>> findAll(
            @AuthenticationPrincipal User user,
            @PathVariable Long pointId) {
        return ResponseEntity.ok(pointVisitService.findAll(user, pointId));
    }

    @GetMapping("/{visitId}")
    public ResponseEntity<PointVisitResponse> findOne(
            @AuthenticationPrincipal User user,
            @PathVariable Long pointId,
            @PathVariable Long visitId) {
        return ResponseEntity.ok(pointVisitService.findOne(user, pointId, visitId));
    }

    @PutMapping("/{visitId}")
    public ResponseEntity<PointVisitResponse> update(
            @AuthenticationPrincipal User user,
            @PathVariable Long pointId,
            @PathVariable Long visitId,
            @Valid @RequestBody PointVisitUpdateRequest request) {
        return ResponseEntity.ok(pointVisitService.update(user, pointId, visitId, request));
    }

    @DeleteMapping("/{visitId}")
    public ResponseEntity<Void> delete(
            @AuthenticationPrincipal User user,
            @PathVariable Long pointId,
            @PathVariable Long visitId) {
        pointVisitService.delete(user, pointId, visitId);
        return ResponseEntity.noContent().build();
    }
}
