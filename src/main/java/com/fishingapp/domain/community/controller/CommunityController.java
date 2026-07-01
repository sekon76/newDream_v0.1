package com.fishingapp.domain.community.controller;

import com.fishingapp.domain.community.dto.CommunityPostDetail;
import com.fishingapp.domain.community.dto.CommunityPostSummary;
import com.fishingapp.domain.community.service.CommunityService;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/community")
@RequiredArgsConstructor
public class CommunityController {

    private final CommunityService communityService;

    @GetMapping("/posts")
    public ResponseEntity<Page<CommunityPostSummary>> getPosts(
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "20") int size) {
        return ResponseEntity.ok(communityService.getPosts(page, size));
    }

    @GetMapping("/posts/{visitId}")
    public ResponseEntity<CommunityPostDetail> getPost(@PathVariable Long visitId) {
        return ResponseEntity.ok(communityService.getPost(visitId));
    }
}
