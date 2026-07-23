package com.fishingapp.domain.preference.controller;

import com.fishingapp.domain.preference.dto.PreferredRegionRequest;
import com.fishingapp.domain.preference.dto.PreferredRegionResponse;
import com.fishingapp.domain.preference.service.PreferredRegionService;
import com.fishingapp.domain.user.entity.User;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/preferred-regions")
@RequiredArgsConstructor
public class PreferredRegionController {

    private final PreferredRegionService preferredRegionService;

    @PostMapping
    public ResponseEntity<PreferredRegionResponse> create(
            @AuthenticationPrincipal User user,
            @Valid @RequestBody PreferredRegionRequest request) {
        return ResponseEntity.status(HttpStatus.CREATED).body(preferredRegionService.create(user, request));
    }

    @GetMapping
    public ResponseEntity<List<PreferredRegionResponse>> findAll(@AuthenticationPrincipal User user) {
        return ResponseEntity.ok(preferredRegionService.findAll(user));
    }

    @PutMapping("/{regionId}")
    public ResponseEntity<PreferredRegionResponse> update(
            @AuthenticationPrincipal User user,
            @PathVariable Long regionId,
            @Valid @RequestBody PreferredRegionRequest request) {
        return ResponseEntity.ok(preferredRegionService.update(user, regionId, request));
    }

    @DeleteMapping("/{regionId}")
    public ResponseEntity<Void> delete(
            @AuthenticationPrincipal User user,
            @PathVariable Long regionId) {
        preferredRegionService.delete(user, regionId);
        return ResponseEntity.noContent().build();
    }
}
